from datetime import date

from utils import CONFIG_FILE
from utils.email import send_mail
from utils.export_data import save_data_as_excel
from utils.gather_data import gather_data


def main(start_date: date, end_date: date, date_format="%Y%m%d") -> None:
    start_date = start_date.strftime(date_format)
    end_date = end_date.strftime(date_format)

    df = gather_data(config_file=CONFIG_FILE.get('reports').get('billetes_vendidos_por_ib'),
                     config_section='GATHER_DATA', params=[start_date, end_date])
    filename = f'weekly_report_billetes_vendidos_por_ib_{start_date}_{end_date}.xlsx'
    save_data_as_excel(data=df, filename=filename)
    send_mail(attachments=[filename], secret_name='EMAIL_CONFIG_REPORT_BILLETES_VENDIDOS_POR_IB')
