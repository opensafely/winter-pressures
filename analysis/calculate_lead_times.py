import pandas as pd

from lib.utilities import OUTPUT_DIR, match_long_input_files


def calculate_lead_times():
    for file in OUTPUT_DIR.iterdir():

        ### Identify wide format input files
        if match_long_input_files(file.name):
            ### Read contents of file
            df = pd.read_csv(OUTPUT_DIR / file.name)
            ### Convert string dates actual dates and calculate lead time
            df[['booked_date_appointment','start_date_appointment']] = df[['booked_date_appointment','start_date_appointment']].apply(pd.to_datetime)
            df['lead_time'] = (df['booked_date_appointment'] - df['start_date_appointment']).dt.days
            ### Write contents to file
            new_file_name = file.name.replace("long", "processed")
            df.to_csv(OUTPUT_DIR / new_file_name, index=False)

if __name__ == "__main__":
    calculate_lead_times()