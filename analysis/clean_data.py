import pandas as pd
import sys

sys.path.append("lib")

from utilities import OUTPUT_DIR, match_input_files_by_tag


def clean_data():

    for file in OUTPUT_DIR.iterdir():

        # Identify wide format input files
        if match_input_files_by_tag(file.name,"long"):
            # Read contents of file
            df = pd.read_csv(OUTPUT_DIR / file.name)
            df['booked_date_appointment'] = pd.to_datetime(df['booked_date_appointment'])
            df['start_date_appointment'] = pd.to_datetime(df['start_date_appointment'])
            df_clean = df.loc[df['booked_date_appointment'] > df['start_date_appointment']]
            new_file_name = file.name.replace("long", "clean")
            df_clean.to_csv(OUTPUT_DIR / new_file_name, index=False)

if __name__ == "__main__":
    clean_data()