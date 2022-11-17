import pandas as pd
import sys

sys.path.append("lib")

from utilities import OUTPUT_DIR, match_wide_input_files, get_date_input_file
from study_variables import stump_list, id_variables


def reformat_appointment_data():
    for file in OUTPUT_DIR.iterdir():

        ### Identify wide format input files
        if match_wide_input_files(file.name):
            ### Extract the date
            date = get_date_input_file(file.name)
            ### Read contents of file
            df = pd.read_csv(OUTPUT_DIR / file.name)
            ### Convert contents to long form
            df_long = pd.wide_to_long(df,
                stubnames=stump_list,
                i=id_variables,
                j='num',
                sep="_" ).reset_index()
            ### Write contents to file
            df_long.to_csv(OUTPUT_DIR / f'input_long_{date}.csv')

if __name__ == "__main__":
    reformat_appointment_data()