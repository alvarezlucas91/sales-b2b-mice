import datetime

from utils import CONFIG_FILE
from utils.email import send_mail
from utils.export_data import save_data_as_excel
from utils.gather_data import gather_data


def main(booking_date: str):
    df = gather_data(config_file=CONFIG_FILE.get('reports').get('credito_individual'),
                     config_section='GATHER_DATA_CREDITO_INDIVIDUAL', params=[booking_date])
    filename = f'report_reservas_con_crédito_individual_{datetime.date.today()}.xlsx'
    save_data_as_excel(data=df, filename=filename)
    send_mail(attachments=[filename], secret_name='EMAIL_CONFIG_REPORT_CREDITO_INDIVIDUAL')
