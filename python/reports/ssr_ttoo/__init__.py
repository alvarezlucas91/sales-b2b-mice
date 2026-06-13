import logging

from vyservices.vy_utils import LOGGER_NAME

from utils import CONFIG_FILE
from utils.email import send_mail
from utils.export_data import save_data_as_excel
from utils.gather_data import gather_data

logger = logging.getLogger(LOGGER_NAME)


def main(start_date: str, end_date: str) -> object:
    df = gather_data(config_file=CONFIG_FILE.get('reports').get('ssr_ttoo'),
                     config_section='GATHER_DATA', params=[start_date, end_date])
    filename = f'ssr_ttoo_{start_date}_{end_date}.xlsx'
    save_data_as_excel(data=df, filename=filename)
    send_mail(attachments=[filename], secret_name='EMAIL_CONFIG_REPORT_SSR_TTOO')