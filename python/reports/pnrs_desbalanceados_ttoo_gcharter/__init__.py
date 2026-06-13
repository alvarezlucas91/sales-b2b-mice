from utils import CONFIG_FILE

from utils.email import send_mail
from utils.export_data import save_data_as_excel
from utils.gather_data import gather_data


def main(start_date: str, end_date: str):
    df = gather_data(config_file=CONFIG_FILE.get('reports').get('pnrs_desbalanceados_ttoo_gcharter'),
                     config_section='GATHER_DATA',
                     params=[start_date, end_date])
    filename = f'pnrs_desbalanceados_ttoo_gcharter_{start_date}_{end_date}.xlsx'
    save_data_as_excel(data=df, filename=filename)
    send_mail(attachments=[filename], secret_name='EMAIL_CONFIG_REPORT_PNRS_DESBALANCEADOS_TTOO_GCHARTER')
