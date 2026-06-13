"""
RUN FIRST
# pip install invoke
# pip install awscli

# Install sonar
Download zip from https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/
extract the zip and copy the full path to bin/sonar-scanner.bat
Use the command --sonar="<full-path>"

BUILD
Deploy the necessary files to DEV environ.
command: invoke build --suffix="<suffix_value>" --step="<airflow, cloudformation, docker>"
ARGS:
--suffix (not required): Suffix is used when more than 1 developer is testing in dev
and they do not want to have conflict in each process (example: resource usage). Default is empty.
--step (not required): Can be airflow, cloudformation and docker. Default run all steps.
    Airflow upload the dag into s3 folder.
    Cloudformation upload the DeployDefinition.yaml to Cloudformation.
    Docker build the image and upload the image into AWS ECR.


TEST
Test the information.
command: invoke test --suffix="-<suffix_value>" --cmd="<command_line>"
ARGS:
--suffix (not required): Suffix is used when more than 1 developer is testing in dev
and they do not want to have conflict in each process (example: resource usage). Default is empty.
--cmd (not required): Command line necessary to run the container. Default is empty.
--step (not required): Can be docker or jenkins. Default run all steps.
    Docker build image and run the container.
    Jenkins check if exist the files for jenkins deployment.
"""
from invoke import task
import configparser
import os
from pathlib import Path

config = configparser.RawConfigParser()
config.read('./config/project.cfg')
area: str = config.get('project', 'product_name')
product: str = config.get('project', 'team_name')
project: str = config.get('project', 'project_name')
print("project:", area, product, project)
current_path: str = Path(os.path.abspath(__file__)).parent
account_id = '123456789012'

@task
def build(c, suffix=None, step=None, sonartoken=None):
    list_steps = [
        None,
         'airflow',
        # 'cloudformation',
        # 'sonar',
        # 'lambda-function',
        'docker'
    ]

    if step is not None:
        print("step:", step)
    else:
        print(f"Executing all steps {', '.join(list_steps[1:])}")

    if suffix is None:
        suffix=''
    if step not in list_steps:
        raise ValueError(f'step not found in {list_steps}')
    if step == 'sonar' and sonartoken is None:
        raise ValueError('Command --sonartoken not found. Add the token for the sonar server.')

    if step == 'docker' and 'docker' in list_steps:
        print("load docker")
        c.run(
            "aws ecr get-login-password --region eu-west-1 --profile default | "
            "docker login --username AWS --password-stdin "
            f"123456789012.dkr.ecr.eu-west-1.amazonaws.com/{product}-{project}"
        )
        c.run(
            "docker build -f Dockerfile -t "
            f"{account_id}.dkr.ecr.eu-west-1.amazonaws.com/{product}-{project}:latest "
            f"--build-arg ACCOUNT_ID={account_id} "
            " --progress=plain . "
        )
        c.run(
            f"docker push {account_id}.dkr.ecr.eu-west-1.amazonaws.com/{product}-{project}:latest "
        )
    # upload airflow files
    if step == 'airflow' and 'airflow' in list_steps:
        print("upload DAGs to Airflow")
        c.run(
            'aws --region eu-west-1 --profile default s3 sync ./deploy/dags s3://airflow-company-dev/k8s-dags/ --exclude \"*\" --include \"*.py\"'
        )

    if step == 'sonar' and 'sonar' in list_steps:
        c.run(
            f'docker run --rm -e SONAR_HOST_URL="http://${SONAR_HOST}:9000/" -e SONAR_LOGIN="{sonartoken}" -v "{current_path}:/usr/src" sonarsource/sonar-scanner-cli'
        )


@task
def test(c, suffix=None, step=None, cmd=None):
    if suffix is None:
        suffix = ""
    if cmd is None:
        cmd = ""
    if step == "docker" or step is None:
        print("run docker")
        c.run(
            "docker build . -t "
            f"{account_id}.dkr.ecr.eu-west-1.amazonaws.com/{product}-{project}:latest"
            " --progress=plain"
        )
        c.run(
            "docker run --rm --env-file ./.aws_credentials "
            f"{account_id}.dkr.ecr.eu-west-1.amazonaws.com/{product}-{project}:latest"
            f" {cmd}"
        )
    if step == "jenkins" or step is None:
        print("check jenkins files")
        c.run("DIR Jenkinsfile")
        c.run("DIR sonar-project.properties")