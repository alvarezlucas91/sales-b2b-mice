from datetime import datetime, timedelta
from pathlib import Path

import pendulum
from airflow import models
from airflow.models import Variable
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import (
    KubernetesPodOperator,
)
from finishSemaphoreOperator import FinishSemaphoreOperator
from koSemaphoreOperator import KOSemaphoreOperator
from kubernetes.client import models as k8s_models
from startSemaphoreOperator import StartSemaphoreOperator

local_tz = pendulum.timezone("Europe/Madrid")
environment = Variable.get("env")
account = Variable.get("account")

default_args = {
    "owner": "sales",
    "depends_on_past": False,
    "start_date": datetime.now(tz=local_tz) - timedelta(days=7),
    "email": [],
    "email_on_failure": "",
    "email_on_retry": False,
    "retries": 0,
    "retry_delay": 0
}


def define_capacity(capacity):
    resources = Variable.get(capacity, deserialize_json=True)
    return k8s_models.V1ResourceRequirements(limits=resources["limits"], requests=resources["requests"])


with models.DAG(
        dag_id=Path(__file__).stem,
        max_active_runs=1,
        default_args=default_args,
        schedule_interval=None if environment == "dev" else "0 8 * * 1",
        tags=["commercial", "salesb2b", "mice", "report", "residentes_b2b"],
        catchup=False
) as dag:
    start = StartSemaphoreOperator(task_id="start", dag=dag)

    ko = KOSemaphoreOperator(task_id="ko", dag=dag, trigger_rule="one_failed")
    finish = FinishSemaphoreOperator(
        task_id="finish",
        dag=dag,
    )

    run_pod = KubernetesPodOperator(
        task_id="salesb2b-mice-report-residentes-b2b",
        name=Path(__file__).stem,
        namespace="airflow-commercial",
        image=f"{account}.dkr.ecr.eu-west-1.amazonaws.com/commercial-salesb2b-mice:{environment}",
        image_pull_secrets=[k8s_models.V1LocalObjectReference("ecr-auth")],
        image_pull_policy="Always",
        arguments=f'-m reports.residentes_b2b'.split(),
        env_vars={
            "env": Variable.get("env"),
            "id_exec": "{{ ti.xcom_pull('start', key='id_exec') }}",
            "id_job": "{{ ti.xcom_pull('start', key='id_job') }}",
            "id_dag": "{{ dag.dag_id }}",
            "id_task": "{{ task.task_id }}",
        },
        labels={"app.kubernetes.io/component": "{{ task.task_id }}",
                "tags.datadoghq.com/service": "commercial-salesb2b-mice", "tags.datadoghq.com/env": environment
                },
        container_resources=define_capacity("S_container_resources"),
        startup_timeout_seconds=1000,
        get_logs=True,
        in_cluster=True,
        service_account_name="commercial-salesb2b-mice-sa",
    )

    start >> run_pod >> [finish, ko]
