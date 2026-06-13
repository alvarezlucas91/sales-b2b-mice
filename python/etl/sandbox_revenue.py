from vyservices.vy_redshift import execute_raw_query
from vyservices.vy_utils import get_query_file_path, format_file_with_ordered_params

QUERY_SUB_FOLDER = 'etl/sandbox_revenue/redshift'

SANDBOX_REVENUE_SCHEMA = 'sandbox_revenue'
CUST_ALLOTMENTS = 'cust_group_allotment'


def copy_cust_allotments():
    # Truncate
    query_path = get_query_file_path(f'{QUERY_SUB_FOLDER}/insert/insert_cust_allotments.sql')
    query = format_file_with_ordered_params(query_path, params=[])
    execute_raw_query(query)


def truncate_table(table: str, schema: str = SANDBOX_REVENUE_SCHEMA):
    query_path = get_query_file_path(f'{QUERY_SUB_FOLDER}/truncate/truncate.sql')
    query = format_file_with_ordered_params(query_path, [f"{schema}.{table}"])
    execute_raw_query(query)


def main():
    # CUST ALLOTMENTS
    truncate_table(table=CUST_ALLOTMENTS)
    copy_cust_allotments()
