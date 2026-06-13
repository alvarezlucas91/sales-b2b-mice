import datetime

from utils import CONFIG_FILE
from utils.email import send_mail
from utils.export_data import save_data_as_excel_sheets
from utils.gather_data import gather_data


def main():
    df_sales = gather_data(config_file=CONFIG_FILE.get('reports').get('ttoo_allotments'),
                            config_section='GATHER_DATA_SALES')
    df_no_iatas = gather_data(config_file=CONFIG_FILE.get('reports').get('ttoo_allotments'),
                                  config_section='GATHER_DATA_NO_IATAS')
    filename = f'report_ttoo_allotments_{datetime.date.today()}.xlsx'
    save_data_as_excel_sheets(data=[df_sales, df_no_iatas], filename=filename, sheets_name=['SALES', 'NO_IATAS'])
    send_mail(attachments=[filename], secret_name='EMAIL_CONFIG_REPORT_TTOO_ALLOTMENTS')
