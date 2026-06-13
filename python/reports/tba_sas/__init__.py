import datetime

from utils import CONFIG_FILE
from utils.email import send_mail
from utils.export_data import save_data_as_excel_sheets
from utils.gather_data import gather_data


def main():
    df_tba = gather_data(config_file=CONFIG_FILE.get('reports').get('tba_sas'),
                            config_section='GATHER_DATA_TBA')
    df_tba_comments = gather_data(config_file=CONFIG_FILE.get('reports').get('tba_sas'),
                                  config_section='GATHER_DATA_TBA_COMMENTS')
    df_tba_cancelaciones = gather_data(config_file=CONFIG_FILE.get('reports').get('tba_sas'),
                            config_section='GATHER_DATA_CANCELACIONES')
    filename = f'report_tba_sas_{datetime.date.today()}.xlsx'
    save_data_as_excel_sheets(data=[df_tba, df_tba_comments, df_tba_cancelaciones], filename=filename, sheets_name=['Tba', 'TbaComments', 'Cancelaciones'])
    send_mail(attachments=[filename], secret_name='EMAIL_CONFIG_REPORT_TBA_SAS')