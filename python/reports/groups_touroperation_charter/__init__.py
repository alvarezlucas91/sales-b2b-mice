import datetime

from utils import CONFIG_FILE
from utils.email import send_mail
from utils.export_data import save_data_as_excel_sheets
from utils.gather_data import gather_data


def main():
    df_grupos = gather_data(config_file=CONFIG_FILE.get('reports').get('groups_touroperation_charter'),
                            config_section='GATHER_DATA_GROUPS')
    df_ttoo_charter = gather_data(config_file=CONFIG_FILE.get('reports').get('groups_touroperation_charter'),
                                  config_section='GATHER_DATA_TOUROPERATION_CHARTER')
    filename = f'report_bookings_groups_touroperation_charter_{datetime.date.today()}.xlsx'
    save_data_as_excel_sheets(data=[df_grupos, df_ttoo_charter], filename=filename, sheets_name=['GROUPS', 'TTOO_CHARTER'])
    send_mail(attachments=[filename], secret_name='EMAIL_CONFIG_REPORT_GROUPS_TOUROPERATION_CHARTER')
