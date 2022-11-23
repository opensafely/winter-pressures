import pandas as pd
import sys
from collections import defaultdict

sys.path.append("lib")

from utilities import OUTPUT_DIR, match_input_files_by_tag


def summarise_lead_times(batch_column="batch",summary_variables=["practice"],tag="lead_time"):

    df_dict = defaultdict(list)

    for file in OUTPUT_DIR.iterdir():

        # Identify wide format input files
        if match_input_files_by_tag(file.name,"processed"):
            # Read contents of file
            df = pd.read_csv(OUTPUT_DIR / file.name)
            this_batch = df['batch'].unique()[0] # There should only be one value
            
            # For each summary variable:
            for v in summary_variables:
                # Define how the data should be summarised
                aggregate_function = {'patient_id':['size', 'nunique'], 'lead_time':['median']}

                # Do the summarising (and add the batch information too)
                df_summary = ( df.groupby([batch_column,v]).agg(aggregate_function) ).reset_index()
                df_summary['batch'] = this_batch

                # Rename columns appropriately
                # i.e., combine the multi index headers generated by the agg() function
                df_summary = df_summary.swaplevel(axis=1)
                df_summary.columns = ["_".join(a) for a in df_summary.columns.to_flat_index()]
                df_summary.columns = df_summary.columns.str.replace(r"^_","", regex=True)

                df_dict[v].append(df_summary)

    for v in summary_variables:
        measure_file_name = f"measure_{tag}_{v}.csv"
        df_measure = ( pd.concat(df_dict[v])[['batch','nunique_patient_id','median_lead_time']]
                        .rename( columns={'batch':'date','nunique_patient_id':'population','median_lead_time':'value'} ) )
        df_measure = df_measure[['population', 'value', 'date']]

        df_measure.to_csv(OUTPUT_DIR / measure_file_name, index=False)

if __name__ == "__main__":
    summarise_lead_times(batch_column="batch",summary_variables=["practice"],tag="lead_time")