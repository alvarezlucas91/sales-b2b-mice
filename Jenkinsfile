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
def ecr_env = "${account}.dkr.ecr.eu-west-1.amazonaws.com/${repository}:${env.environment}"

// KUBERNETES
def now = new Date()
def service_account = "${team}-${product}-${project}-sa"
def eks_namespace ="airflow-${team}"
def current = "${account}.dkr.ecr.eu-west-1.amazonaws.com/${repository}:${now.format("yyyy.MM.dd_HHmm", TimeZone.getTimeZone('UTC'))}"

def environment_tag ="${environment_tag}"

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
        stage('Terraform AWS') {
            container('terraform') {
                dir('./deploy/aws'){
                    sh "${terraform_init_AWS}"
                    sh "terraform apply --auto-approve \
                        -var environment=${env.environment} \
                        -var service_account=${service_account} \
                        -var account=${account} \
                        -var eks_id=${eks_id} \
                        -var eks_namespace=${eks_namespace} \
                        -var team=${team} \
                        -var product=${product} \
                        -var project=${project} \
                        -var environment_tag=${environment_tag} \
						-var ecr_name=${repository}"
                }
            }
        }
        stage("Build and push image"){
            container('kaniko') {
                sh "/kaniko/executor --context `pwd` --destination ${ecr_latest} --destination ${ecr_env} --destination ${current} --build-arg  ACCOUNT_ID=${account} --snapshot-mode=time --cache=false"
            }
        }
        stage('Terraform Datadog') {
            if(env.datadog_allowed != "true") {
                return Utils.markStageSkippedForConditional('Terraform Datadog')
            } else {
                container('terraform') {
                    dir('./deploy/datadog'){
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            try {
                                sh "${terraform_init_datadog}"
                                sh "terraform apply --auto-approve \
                                -var datadog_api_key=${env.datadog_api_key} \
                                -var datadog_app_key=${env.datadog_app_key} \
                                -var dashboard_name=${datadog_dashboard_name} \
                                -var image_name=${repository} \
                                -var eks_namespace=${eks_namespace}"
                            } catch (Exception e) {
                                error("Terraform Datadog failed: ${e.message}")
                            }
                        }
                    }
                }
            }
        }
        stage('Terraform k8s') {
            container('terraform') {
                dir('./deploy/kubernetes'){
                    sh "${terraform_init_k8s}"
                    sh "terraform apply --auto-approve \
                        -var account=${account} \
                        -var eks_namespace=${eks_namespace} \
                        -var team=${team} \
                        -var product=${product} \
                        -var project=${project} \
                        -var service_account=${service_account}"
                }
            }
        }
        stage('Upload dags') {
            container('kubecontainer') {
                dir("./deploy/dags") {
                     sh "aws s3 sync . "+env.s3_dags+' --exclude "*" --include "*.py"'
                }
            }
        }
    }
}
