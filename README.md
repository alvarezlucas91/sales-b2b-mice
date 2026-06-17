# ETL Airline Commercial Sales B2B — MICE Reporting Platform

Apache Airflow–based ETL and reporting platform that consolidates commercial sales data from multiple airline reservation systems (ODS/Navitaire, DMV, Redshift) and distributes 40+ automated daily reports to internal teams and external partners via email, SharePoint, and FTP. Deployed on Kubernetes using infrastructure-as-code (Terraform).

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Apache Airflow (Kubernetes)                  │
│                                                                     │
│  ┌────────────────┐   ┌──────────────────────────────────────────┐  │
│  │   ETL Jobs     │   │         Report Jobs (40+)                │  │
│  │                │   │                                          │  │
│  │  Alliances     │   │  Commercial: AB, Codeshare, Fraud,       │  │
│  │  ETL           │   │  Extra Seats, Noshow, IAG Capacity       │  │
│  │                │   │                                          │  │
│  │  Group         │   │  Tour Operators: TTOO, TBA-SAS,          │  │
│  │  Allotments    │   │  Groups, Charter, Allotments, PNRS       │  │
│  │  ETL           │   │                                          │  │
│  │                │   │  Partners: Travelfusion, Ypsilon,        │  │
│  │  Sandbox       │   │  Huagati, Sundio, Corendon, Mundiplan    │  │
│  │  Revenue       │   │                                          │  │
│  │  Copy          │   │  Operations: PMR, Cabin Bag, Cruises,    │  │
│  └────────────────┘   │  Sports Groups, Monitoring, Disruption   │  │
│                       └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
             │                              │
             ▼                              ▼
   ┌──────────────────┐         ┌─────────────────────────┐
   │  Amazon Redshift │         │  Distribution channels  │
   │  (data warehouse)│         │  - Email (SMTP)         │
   └──────────────────┘         │  - SharePoint (OAuth2)  │
                                │  - FTP (partner uploads)│
                                │  - Redshift (analytics) │
                                │  - Tableau (refresh)    │
                                └─────────────────────────┘
```

---

## Step-by-step execution

### Step 1 — ETL: Alliances (`python/etl/alliances.py`)

Extracts inter-airline alliance bookings (codeshare records where operating carrier ≠ marketing carrier) from the ODS reservation system and loads them into the data warehouse.

**Flow:**

1. `get_data()` — Queries ODS via two SQL modes:
   - `GET_ALLIANCES_BY_SEGMENT`: aggregates at segment level
   - `GET_ALLIANCES_BY_FLIGHT`: aggregates at flight level
2. `save_to_s3()` — Writes result as gzip-compressed CSV to S3:
   `s3://company-data-lake-{env}/commercial/salesb2b/mice/alliances/`
3. `save_to_redshift()` — Runs a `COPY ... FROM S3` into `salesb2b.stg_cust_alliance`
4. The entry point (`alliances_main.py`) accepts `--date_from` / `--date_to` parameters, defaulting to yesterday when omitted.

---

### Step 2 — ETL: Group Allotments (`python/etl/groups_allotments.py`)

Processes group allotment movements — adds, cancellations, exchanges, and price joins — and loads the final table into Redshift.

**Key functions:**

| Function | Purpose |
|---|---|
| `get_cancelled()` | Recovers canceled allotment records from ODS staging |
| `get_move_gral()` | Loads staging tables: `sales_pax`, `sales_pax_hi`, `mov_gral` |
| `swap_pax()` | Row-level swap logic for passenger exchanges |
| `extract_num_pax()` | Parses passenger count from free-text fields |
| `join_with_prices()` | Enriches movement records with pricing info from DMV |

**Execution modes** (controlled via `--mode` CLI arg):
- `incremental` — processes movements from the last run checkpoint
- `historic` — full backfill from a configured start date
- `range` — explicit date range passed as parameters

Final output loads to `salesb2b.cust_group_allotment` in Redshift.

---

### Step 3 — ETL: Sandbox Revenue Copy (`python/etl/sandbox_revenue.py`)

Mirrors the processed group allotment data from the main schema into a revenue sandbox schema for downstream analytics teams. Runs as a simple INSERT-SELECT after the Group Allotments ETL completes.

---

### Step 4 — Report generation (40+ reports)

Each report follows the same pattern:

```
1. Gather    → Execute SQL query/queries via gather_data.py
               Sources: ODS (MSSQL), DMV (MSSQL), Navitaire (MSSQL), Redshift
2. Transform → Pandas: rename columns, calculate derived fields, format dates
3. Export    → Excel (openpyxl, multi-sheet) via export_data.py
4. Distribute→ send_email / sharepoint_upload / ftp_upload
```

Each report is a self-contained Python module (`python/reports/{report_name}/`):
- `__init__.py` — report logic
- `__main__.py` — Airflow pod entry point (loads config, calls the module)

Report configuration (`config/reports/{report_name}.cfg`):

```ini
[QUERY]
QUERY_ODS = reports/ttoo/sql/gather.sql       # ODS SQL path
QUERY_REDSHIFT = reports/ttoo/sql/summary.sql # Redshift SQL path (optional)

[REPORT]
FILENAME = report_ttoo_{date_from}_{date_to}.xlsx
SHEET_NAME = Data
```

Secrets (email addresses, SMTP password, FTP credentials, SharePoint tokens) are loaded at runtime from **AWS Secrets Manager** via the `secret.cfg` key mapping — nothing is hardcoded.

---

### Step 5 — Data distribution

#### Email (`python/utils/email.py`)
Uses `vysession` (internal auth library) + SMTP. Loads the email config struct from Secrets Manager:
```json
{
  "smtp_host": "...", "smtp_port": 587,
  "username": "...", "password": "...",
  "from": "data-team@company.com",
  "to": ["recipient@partner.com"],
  "subject": "Daily Report {date}"
}
```

#### SharePoint upload (`python/utils/sharepoint_upload.py`)
OAuth2 client credentials flow against Microsoft Graph API:
1. `POST /oauth2/v2.0/token` with `client_id`, `client_secret`, `tenant_id` (from Secrets Manager)
2. `PUT /drives/{drive_id}/items/{path}:/content` to upload the Excel file

#### FTP upload (`python/utils/ftp_upload_file.py`)
Standard `ftplib` connection with credentials from Secrets Manager. Used for partner-facing deliveries.

---

### Step 6 — Airflow orchestration (`deploy/dags/`)

Each job has a corresponding Airflow DAG:

```python
# Typical DAG structure
start_semaphore
    └─► [task_1, task_2, ...]    # KubernetesPodOperator
            └─► tableau_refresh  # Only on prod
                    └─► finish_semaphore
                            └─► ko_semaphore (on failure)
```

Kubernetes pods are configured via `KubernetesPodOperator`:
- Image pulled from private ECR registry
- Resources fetched from Airflow variables (`M_container_resources`, `L_container_resources`)
- Env vars injected: `env`, `id_exec`, `id_job`, `id_dag`, `id_task`

**Scheduling**: most reports run daily at `17 5 * * *` (05:17 UTC), triggered after the ODS data export window closes.

---

## Configuration system

```
config/
├── project.cfg        # team_name, product_name, project_name
├── secret.cfg         # AWS Secrets Manager key names per credential
├── mailing.cfg        # Error notification config
├── etl/
│   ├── alliances.cfg  # SQL paths, S3 paths, Redshift table
│   └── group_allotment.cfg
└── reports/
    └── {report}.cfg   # One .cfg per report: SQL paths, filename, sheet names
```

At startup, `python/utils/__init__.py` auto-scans the `config/` tree and populates a `CONFIG_FILE` dict so any module can access settings by path key (e.g., `CONFIG_FILE['reports']['ttoo']`).

---

## Infrastructure as code (Terraform)

```
deploy/
├── aws/
│   ├── main.tf                   # IAM policy + role (IRSA)
│   └── permissions/
│       ├── policy.json           # Least-privilege: S3, Redshift, Secrets Manager, ES
│       └── trust-relationships.json  # Kubernetes ServiceAccount IRSA trust
├── kubernetes/
│   └── main.tf                   # Role, RoleBinding, ServiceAccount
├── ecr/
│   └── main.tf                   # ECR repository for Docker image
└── datadog/
    ├── main.tf                   # Monitoring dashboards
    └── dashboard.json            # Datadog dashboard definition
```

**IAM least-privilege policy** (`deploy/aws/permissions/policy.json`):
- S3: scoped to `company-data-lake-{env}/commercial/salesb2b/mice/*`
- Secrets Manager: scoped to `data/commercial/salesb2b/mice*`
- Elasticsearch: scoped to `company-central-logging` domain
- IRSA: trust relationship allows the pod's ServiceAccount to assume the IAM role

---

## Observability

- **Elasticsearch**: structured logs from every job step (`log_to_elastic=True` in `project.cfg`)
- **Datadog**: dashboard tracking DAG success rate, execution time, and failure counts
- **Airflow**: task-level status, retries, and SLA monitoring
- **Semaphore operators**: `StartSemaphoreOperator` / `FinishSemaphoreOperator` enforce mutex execution for reports that share Redshift write paths

---

## Repository structure

```
python/
├── alliances_main.py           # Entry point: Alliance ETL
├── groups_allotment_main.py    # Entry point: Group Allotment ETL
├── sandbox_revenue_main.py     # Entry point: Revenue sandbox copy
├── etl/                        # ETL business logic
│   ├── alliances.py
│   ├── groups_allotments.py
│   └── sandbox_revenue.py
├── reports/                    # 40+ report modules (one folder each)
│   └── {report_name}/
│       ├── __init__.py         # Report logic
│       └── __main__.py         # Airflow pod entry point
└── utils/                      # Shared utilities
    ├── __init__.py             # Config auto-loader (CONFIG_FILE)
    ├── email.py                # SMTP sender
    ├── export_data.py          # Pandas → Excel/CSV
    ├── ftp_connect.py          # FTP connection wrapper
    ├── ftp_upload_file.py      # FTP upload
    ├── gather_data.py          # SQL execution (ODS + Redshift)
    ├── sharepoint_upload.py    # MS Graph SharePoint upload
    └── vy_sql_custom.py        # SQL with explicit commit/rollback

config/
├── project.cfg                 # Project metadata
├── secret.cfg                  # Secrets Manager key mappings
├── etl/                        # ETL-specific configs
└── reports/                    # One .cfg per report

query/
├── etl/                        # SQL for alliances + allotment ETL
└── reports/                    # SQL for each report (one folder per report)

deploy/
├── dags/                       # Airflow DAGs (~45 files, one per job)
├── aws/                        # Terraform: IAM, permissions
├── kubernetes/                 # Terraform: K8s RBAC
├── ecr/                        # Terraform: ECR repository
└── datadog/                    # Terraform: monitoring dashboards
```

---

## Running locally

```bash
pip install -r requirements.txt
cp .env.example .env   # fill in DB credentials and AWS config

# Run the Alliance ETL
python -m python.alliances_main --date_from 2024-01-01 --date_to 2024-01-31

# Run a specific report
python -m python.reports.codeshare_bookings --date_from 2024-01-01 --date_to 2024-01-02
```

**Required secrets** (loaded from AWS Secrets Manager at runtime):
```
ODS_SQLS_HOST, ODS_SQLS_PORT, ODS_SQLS_USER, ODS_SQLS_PASSWORD
DMV_SQLS_HOST, DMV_SQLS_PORT, DMV_SQLS_USER, DMV_SQLS_PASSWORD
REDSHIFT_HOST, REDSHIFT_PORT, REDSHIFT_USER, REDSHIFT_PASSWORD, REDSHIFT_DATABASE
SHAREPOINT_CLIENT_ID, SHAREPOINT_TENANT_ID, SHAREPOINT_CLIENT_SECRET
```

---

## Notes

- `vyservices` is an internal Python package providing SQL/Redshift connection helpers (`vy_sql`, `vy_redshift`) and centralized logging (`LOGGER_NAME`). Replace these imports with your preferred database connection library (e.g., SQLAlchemy + psycopg2).
- `manifest.json` (IDE database connection metadata) is excluded — it contained internal hostnames.
- AWS Account IDs and S3 bucket names have been replaced with placeholder values.
