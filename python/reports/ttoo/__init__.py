import datetime

from utils import CONFIG_FILE
from utils.email import send_mail
from utils.export_data import save_data_as_excel
from utils.gather_data import gather_data


def main(nom_iata: str, num_iata: str, today_date: str):
    df = gather_data(config_file=CONFIG_FILE.get('reports').get('ttoo'), config_section='GATHER_DATA_REPORTS_TTOO',
                     params=[num_iata, today_date])
    filename = f'report_{nom_iata.lower().replace(" ", "_")}_{datetime.date.today()}.xlsx'
    save_data_as_excel(data=df, filename=filename)
    send_mail(attachments=[filename], secret_name=f'EMAIL_CONFIG_TTOO_REPORT_{nom_iata.upper()}')
