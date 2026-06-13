import datetime

from utils import CONFIG_FILE
from utils.email import send_mail
from utils.export_data import save_data_as_excel
from utils.gather_data import gather_data


def main():
    df = gather_data(config_file=CONFIG_FILE.get('reports').get('grupos_deportivos'),
                     config_section='GATHER_DATA_GRUPOS_DEPORTIVOS', source='redshift')
    filename = f'report_grupos_deportivos_{datetime.date.today()}.xlsx'
    save_data_as_excel(data=df, filename=filename)
    send_mail(attachments=[filename], secret_name='EMAIL_CONFIG_REPORT_GRUPOS_DEPORTIVOS')
