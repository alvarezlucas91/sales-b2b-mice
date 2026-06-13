import datetime
import logging
import pandas as pd
from vyservices.vy_utils import LOGGER_NAME, get_data_file_path, create_folder
from openpyxl.styles import Alignment, Font

from utils import CONFIG_FILE
from utils.email import send_mail
from pathlib import Path
from utils.gather_data import gather_data

logger = logging.getLogger(LOGGER_NAME)

def main():
    today_date = datetime.date.today().strftime("%Y%m%d")

    df = gather_data(config_file=CONFIG_FILE.get('reports').get('monitorizacion_ventas_diario'),
                     config_section='GATHER_DATA',
                     params=[today_date])

    pivot_df = df.pivot_table(index='HORA', columns=['channel_lvl1', 'channelLvl2', 'DAY'], values='DATOS', aggfunc="sum")

    pivot_df.loc['TOTAL'] = pivot_df.sum()

    filename = f'monitorizacion_ventas_diario_{today_date}.xlsx'
    file_path = get_data_file_path(data_file=filename)

    try:
        create_folder(Path(file_path).parent)
        logger.info(f"COMIENZO DE GUARDADO EN {file_path}")

        writer = pd.ExcelWriter(file_path, engine='openpyxl')
        if 'Sheet1' in writer.sheets:
            worksheet = writer.sheets['Sheet1']
        else:
            pivot_df.to_excel(writer, sheet_name='Sheet1', index=True, startrow=1, header=True)
            worksheet = writer.sheets['Sheet1']

        for cell in worksheet['5']:
            if cell.alignment.horizontal == "center" and cell.alignment.vertical == "center":
                cell.alignment = Alignment(horizontal="center", vertical="center", wrap_text=False)

        for row in worksheet.iter_rows(min_row=2, max_row=4, min_col=1, max_col=1):
            for cell in row:
                cell.value = None

        worksheet.merge_cells('A2:A4')
        cell = worksheet['A2']
        cell.alignment = Alignment(horizontal="center", vertical="center")
        cell.font = Font(bold=True)
        cell.value = "HORA"

        worksheet.delete_rows(5)

        writer.close()
        logger.info(f"El archivo {file_path} se ha guardado con éxito.")

        send_mail(attachments=[file_path], secret_name='EMAIL_CONFIG_REPORT_MONITORIZACION_VENTAS_DIARIO')

    except Exception as ex:
        logger.error(f"ERROR: {main.__name__} - {ex}")
        raise

if __name__ == "__main__":
    main()
