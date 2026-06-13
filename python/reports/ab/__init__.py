import datetime

from vyservices.vy_secret import get_secret_key_value

from utils import CONFIG_FILE
from utils.export_data import save_data_as_excel_sheets
from utils.gather_data import gather_data
from utils.sharepoint_upload import get_sharepoint_token, upload_file_sharepoint


def main():
    df_mups = gather_data(config_file=CONFIG_FILE.get('reports').get('ab'),
                          config_section='GATHER_DATA_BI_MUPS')
    df_pax = gather_data(config_file=CONFIG_FILE.get('reports').get('ab'),
                         config_section='GATHER_DATA_BI_PAX')
    df_anc = gather_data(config_file=CONFIG_FILE.get('reports').get('ab'),
                         config_section='GATHER_DATA_BI_ANC')
    df_anc2 = gather_data(config_file=CONFIG_FILE.get('reports').get('ab'),
                          config_section='GATHER_DATA_BI_ANC2')
    filename = f'report_ab_{datetime.date.today()}.xlsx'
    save_data_as_excel_sheets(data=[df_mups, df_pax, df_anc, df_anc2], filename=filename,
                              sheets_name=['BI MUPS', 'BI PAX', 'BI ANC', 'BI ANC 2'])
    token = get_sharepoint_token()
    path_file = get_secret_key_value('SHAREPOINT_PATH_FILE_REPORT_AB')
    upload_file_sharepoint(filename=filename, token=token, path_file=path_file)
