import datetime

from utils import CONFIG_FILE
from utils.email import send_mail
from utils.export_data import save_data_as_excel_sheets
from utils.gather_data import gather_data
from vyservices import vy_secret

def main():
    params = eval(vy_secret.get_secret_key_value('OWNERS_CONFIG_REPORT_RESERVAS_NUMERO_TARJETA_VUELING'))
    df_resumen = gather_data(config_file=CONFIG_FILE.get('reports').get('reservas_numero_tarjeta_vueling'),
                            config_section='GATHER_DATA_RESUMEN', params=params)
    df_owner1 = gather_data(config_file=CONFIG_FILE.get('reports').get('reservas_numero_tarjeta_vueling'),
                                  config_section='GATHER_DATA_OWNER1', params=params)
    df_owner2 = gather_data(config_file=CONFIG_FILE.get('reports').get('reservas_numero_tarjeta_vueling'),
                                  config_section='GATHER_DATA_OWNER2', params=params)

    filename = f'report_reservas_numero_tarjeta_vueling_{datetime.date.today()}.xlsx'
    save_data_as_excel_sheets(data=[df_resumen, df_owner1, df_owner2], filename=filename, sheets_name=['Resumen', 'Detalle Owner1', 'Detalle Owner2'])
    send_mail(attachments=[filename], secret_name='EMAIL_CONFIG_REPORT_RESERVAS_NUMERO_TARJETA_VUELING')
