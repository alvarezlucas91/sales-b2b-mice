from datetime import date
from dateutil.relativedelta import relativedelta
from vyservices.vy_secret import get_secret_key_value
from utils import CONFIG_FILE
from utils.ftp_connect import ftp_connect
from utils.ftp_upload_file import ftp_upload_file

ftp_host = get_secret_key_value('FTP_HOST_IBERIA_GONOW_ANCILLARIES')
ftp_pass = get_secret_key_value('FPT_PASS_IBERIA_GONOW_ANCILLARIES')
ftp_port = get_secret_key_value('FTP_PORT_IBERIA_GONOW_ANCILLARIES')
ftp_user = get_secret_key_value('FTP_USER_IBERIA_GONOW_ANCILLARIES')

config_file = CONFIG_FILE.get('reports').get('iberia_ancillaries_gonow')
config_section = 'GATHER_DATA_IBERIA_ANCILLARIES_GONOW'
filename = f'ANCILLARIESGONOW_{(date.today() - relativedelta(months=1)).strftime("%Y%m")}.csv'


def main() -> None:
    ftp_conn = ftp_connect(ftp_host, ftp_pass, ftp_port, ftp_user)
    ftp_upload_file(ftp=ftp_conn, config_file=config_file, config_section=config_section, filename=filename)
