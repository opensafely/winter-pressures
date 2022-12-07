import pandas as pd
import re
import json

from lib.utilities import OUTPUT_DIR, match_long_input_files
from lib.study_variables import season_map


# Reading in configuration variables
with open('analysis/config.json', 'r') as f:
    config = json.load(f)

# Building a mapping to classify dates as specific COVID waves
wave_match = re.compile('^wave\d{1}')
wave_keys = [ s for s in config.keys() if wave_match.match(s) ]

wave_dataframe_list = list()

for w in wave_keys:
    this_wave_dates = pd.date_range(start=config[w]['start_date'], end=config[w]['end_date']).to_series()
    this_wave_dataframe = pd.DataFrame( { 'date': this_wave_dates, 'wave': w } )
    wave_dataframe_list.append(this_wave_dataframe)

wave_map = pd.concat(wave_dataframe_list).reset_index(drop=True)

def fill_wave_gaps(df):
    # Classify dates before the pandemic as 'pre-pandemic'
    df.loc[pd.to_datetime(df['booked_date_appointment']) < pd.to_datetime(config['wave1']['start_date']), ['booked_date_wave']] = "pre-pandemic"
    df.loc[pd.to_datetime(df['start_date_appointment']) < pd.to_datetime(config['wave1']['start_date']), ['start_date_wave']] = "pre-pandemic"
    # Everything else is 'other' - we are not yet post-pandemic
    df.fillna({'booked_date_wave': 'other','start_date_wave': 'other'},inplace=True)
    return df

def add_temporal_variables():
    for file in OUTPUT_DIR.iterdir():

        # Identify wide format input files
        if match_long_input_files(file.name):
            # Read contents of file
            df = pd.read_csv(OUTPUT_DIR / file.name)
            df['booked_date_appointment'] = pd.to_datetime(df['booked_date_appointment'])
            df['start_date_appointment'] = pd.to_datetime(df['start_date_appointment'])

            # Classify dates by pandemic wave
            df['booked_date_wave'] = df['booked_date_appointment'].map(wave_map.set_index('date')['wave'].to_dict())
            df['start_date_wave'] = df['start_date_appointment'].map(wave_map.set_index('date')['wave'].to_dict())
            df = fill_wave_gaps( df )

            # Classify dates by season
            df['booked_date_season'] = pd.to_datetime(df['booked_date_appointment']).dt.month.map(season_map)
            df['start_date_season'] = pd.to_datetime(df['start_date_appointment']).dt.month.map(season_map)

            # Write contents to file
            new_file_name = file.name.replace('long','full')
            df.to_csv(OUTPUT_DIR / new_file_name, index=False )

if __name__ == "__main__":
    add_temporal_variables()