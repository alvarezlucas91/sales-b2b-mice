from utils import CONFIG_FILE
from utils.email import send_mail
from utils.export_data import save_data_as_excel
from utils.gather_data import gather_data


def main(start_date: str, end_date: str) -> None:
    df = gather_data(config_file=CONFIG_FILE.get('reports').get('fraud'),
                     config_section='GATHER_DATA', params=[start_date, end_date])
    filename = f'report_fraud_{start_date}_{end_date}.xlsx'
    save_data_as_excel(data=df, filename=filename)
    send_mail(attachments=[filename], secret_name='EMAIL_CONFIG_REPORT_FRAUD')
