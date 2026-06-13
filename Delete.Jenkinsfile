import org.jenkinsci.plugins.pipeline.modeldefinition.Utils
def team = "commercial"
def product = "salesb2b"
def project = "mice"

// GIT
def repo_name = "vy-data-${team}-${product}-${project}"
def credentialsAzure = "${credentialsAzure}"
def account = "${env.account}"
def repository = "${team}-${product}-${project}"

// ECR
def ecr_latest = "${account}.dkr.ecr.eu-west-1.amazonaws.com/${repository}:latest"
def ecr_dev = "${account}.dkr.ecr.eu-west-1.amazonaws.com/${repository}:${env.environment}"

// KUBERNETES
def service_account = "${team}-${product}-${project}-sa"
def eks_namespace ="airflow-${team}"

// TERRAFORM
def terraform_bucket="vueling-terraform-state-${env.environment}"
def terraform_init_AWS = "terraform init -backend-config=bucket=${terraform_bucket} -backend-config='region=eu-west-1' -backend-config='key=${team}/${product}/${project}/AWS'"
def terraform_init_datadog = "terraform init -backend-config=bucket=${terraform_bucket} -backend-config='region=eu-west-1' -backend-config='key=${team}/${product}/${project}/datadog'"
def terraform_init_k8s = "terraform init -backend-config=bucket=${terraform_bucket} -backend-config='region=eu-west-1' -backend-config='key=${team}/${product}/${project}/k8s'"
def datadog_dashboard_name ="${team}-${product}-${project}"
if(env.datadog_allowed == "true" && env.environment != "dev") {
    datadog_dashboard_name="${team}-${product}-${project}-${env.environment}"
}

podTemplate(inheritFrom: 'vy-deployment-eks'){ 
     node(POD_LABEL) {
        stage('Clone code') {
            checkout scm: [$class: 'GitSCM', userRemoteConfigs: [[url: "https://vuelingdata.visualstudio.com/Cloud/_git/${repo_name}", credentialsId: "${credentialsAzure}" ]], branches: [[name: "${env_branch}"]]], poll: false
        }
        stage('Destroy Terraform AWS') {
            container('terraform') {
                dir('./deploy/aws'){
                    sh "${terraform_init_AWS}"
                    sh "terraform destroy --auto-approve \
                        -var environment=${env.environment} \
                        -var service_account=${service_account} \
                        -var account=${account} \
                        -var eks_id=${eks_id} \
                        -var eks_namespace=${eks_namespace} \
                        -var team=${team} \
                        -var product=${product} \
                        -var project=${project} \
						-var ecr_name=${repository}"
                }
            }
        }
        stage('Destroy Terraform Datadog') {
            if(env.datadog_allowed != "true") {
                return Utils.markStageSkippedForConditional('Terraform Datadog')
            } else {
                container('terraform') {
                    dir('./deploy/datadog'){
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            try {
                                sh "${terraform_init_datadog}"
                                sh "terraform destroy --auto-approve \
                                -var datadog_api_key=${env.datadog_api_key} \
                                -var datadog_app_key=${env.datadog_app_key} \
                                -var dashboard_name=${datadog_dashboard_name} \
                                -var image_name=${repository} \
                                -var eks_namespace=${eks_namespace}"
                            } catch (Exception e) {
                                error("Destroy Terraform Datadog: ${e.message}")
                            }
                        }
                    }
                }
            }
        }
        stage('Destroy Terraform k8s') {
            container('terraform') {
                dir('./deploy/kubernetes'){
                    sh "${terraform_init_k8s}"
                    sh "terraform destroy --auto-approve \
                        -var account=${account} \
                        -var eks_namespace=${eks_namespace} \
                        -var team=${team} \
                        -var product=${product} \
                        -var project=${project} \
                        -var service_account=${service_account}"
                }
            }
        }
        stage('Destroy dags') {
            container('kubecontainer') {
                dir("./deploy/dags") {
                    def pythonFiles = sh(returnStdout: true, script: 'find . -type f -name "*.py"').trim().split('\n')
                    pythonFiles.each { filePath ->
                       def file = new File(filePath)
                       def fileName = file.getName()
                       sh "aws s3 rm ${env.s3_dags}${fileName}"
                    }
                }
            }
        }
    }
}

