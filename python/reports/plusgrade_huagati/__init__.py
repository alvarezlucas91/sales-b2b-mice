from datetime import date

from utils import CONFIG_FILE
from utils.email import send_mail
from utils.export_data import save_data_as_excel
from utils.gather_data import gather_data


def main() -> None:
    df_diario = gather_data(config_file=CONFIG_FILE.get('reports').get('plusgrade_huagati'),
                     config_section='GATHER_DATA')

    filename = f'report_plusgrade_huagati_{date.today().strftime("%Y%m%d")}.xlsx'
    save_data_as_excel(data=df_diario, filename=filename)
    send_mail(attachments=[filename], secret_name='EMAIL_CONFIG_REPORT_PLUSGRADE')
