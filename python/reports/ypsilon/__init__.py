import datetime

from vyservices import vy_secret

from utils import CONFIG_FILE
from utils.email import send_mail
from utils.export_data import save_data_as_excel, compress_file_as_zip
from utils.gather_data import gather_data


def main():
    today_date = datetime.date.today().strftime("%Y%m%d")

    df = gather_data(config_file=CONFIG_FILE.get('reports').get('ypsilon'), config_section='GATHER_DATA',
                     params=[today_date])

    filename = f'ypsilon_{today_date}.xlsx'
    save_data_as_excel(data=df, filename=filename)
    compress_file_as_zip(filename=filename,
                         password=vy_secret.get_secret_key_value('PASSWORD_ZIP_CONFIG_REPORT_YPSILON'))

    send_mail(attachments=[filename.replace('xlsx', 'zip')], secret_name='EMAIL_CONFIG_REPORT_YPSILON')
