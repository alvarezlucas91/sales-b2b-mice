import datetime

from vyservices.vy_secret import get_secret_key_value

from utils import CONFIG_FILE
from utils.export_data import save_data_as_excel
from utils.gather_data import gather_data
from utils.sharepoint_upload import get_sharepoint_token, upload_file_sharepoint


def main() -> None:
    df_ticket = gather_data(config_file=CONFIG_FILE.get('reports').get('mup_mc'),
                            config_section='GATHER_DATA_TICKET_ACTUAL')
    df_ancillaries = gather_data(config_file=CONFIG_FILE.get('reports').get('mup_mc'),
                                 config_section='GATHER_DATA_ANC_ACTUAL')
    filename = f'report_reservas_mup_mc_{datetime.date.today()}.xlsx'
    df_ticket.merge(df_ancillaries, left_on="yearmon_str", right_on="yearmon_str")
    save_data_as_excel(data=df_ticket.merge(df_ancillaries, left_on="yearmon_str", right_on="yearmon_str"),
                       filename=filename)
    token = get_sharepoint_token()
    path_file = get_secret_key_value('SHAREPOINT_PATH_FILE_REPORT_MCC')
    upload_file_sharepoint(filename=filename, token=token, path_file=path_file)
