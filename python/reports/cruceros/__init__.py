import datetime

from utils import CONFIG_FILE
from utils.email import send_mail
from utils.export_data import save_data_as_excel
from utils.gather_data import gather_data


def main():
    df = gather_data(config_file=CONFIG_FILE.get('reports').get('cruceros'),
                     config_section='GATHER_DATA_CRUCEROS')
    filename = f'report_cruceros_{datetime.date.today()}.xlsx'
    save_data_as_excel(data=df, filename=filename)
    send_mail(attachments=[filename], secret_name='EMAIL_CONFIG_REPORT_CRUCEROS')
