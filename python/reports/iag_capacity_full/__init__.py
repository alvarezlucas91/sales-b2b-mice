import datetime

from vyservices import vy_secret

from utils import CONFIG_FILE
from utils.email import send_mail
from utils.export_data import save_data_as_excel
from utils.gather_data import gather_data


def main():
    today_date = datetime.date.today().strftime("%Y%m%d")

    df = gather_data(config_file=CONFIG_FILE.get('reports').get('iag_capacity_full'), config_section='GATHER_DATA',
                     params=[today_date])

    filename = f'iag_capacity_full_{today_date}.xlsx'
    save_data_as_excel(data=df, filename=filename)
    send_mail(attachments=[filename], secret_name='EMAIL_CONFIG_REPORT_IAG_CAPACITY_FULL')
