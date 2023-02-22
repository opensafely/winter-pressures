import argparse
import sys
import numpy as np
import pandas as pd

from analysis.utils import APPOINTMENTS_OUTPUT_DIR as OUTPUT_DIR
from analysis.utils import read
from analysis.utils import summarise_to_seasons


def parse_args(args):
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--value-thresholds", action="extend", nargs="+", required=True, type=int
    )
    parser.add_argument("--index-cols", action="extend", nargs="+", required=True)
    return parser.parse_args(args)


def main():
    args = parse_args(sys.argv[1:])
    # We assume the first column in the list of columns is a date column.
    date_col = args.index_cols[0]
    index_cols_nodate = args.index_cols[1:]

    f_in = OUTPUT_DIR / "dataset_long.csv.gz"

    #################################################################
    ### Generate proportion lead time measures                    ###
    #################################################################

    value_col = "lead_time_in_days"

    dataset_long = read(f_in, args.index_cols, date_col, value_col)

    for value_threshold in args.value_thresholds:
        dataset_long["threshold_mask"] = dataset_long[value_col] <= value_threshold
        total_counts = dataset_long.groupby(args.index_cols + ["threshold_mask"]).size()

        total_counts = total_counts.unstack("threshold_mask", fill_value=0)
        total_counts["denominator"] = total_counts.sum(axis=1)
        total_counts.rename(columns={True: "numerator"}, inplace=True)
        total_counts["value"] = total_counts["numerator"] / total_counts["denominator"]

        measure = total_counts.reset_index().rename(columns={date_col: "date"})
        del total_counts

        ### Now that we have monthly data, we can calculate seasonal summaries

        # Sum the numerator values for each practice across the months
        # (as defined by analysis.utils.summarise_to_seasons())
        summary_index = ["practice", "year", "season"]
        measure_season_num = summarise_to_seasons(
            measure, index_cols_nodate, date_col="date", value_col="numerator"
        ).set_index(summary_index)

        # Sum the denominator values for each practice across the months
        # (as defined by analysis.utils.summarise_to_seasons())
        measure_season_denom = summarise_to_seasons(
            measure, index_cols_nodate, date_col="date", value_col="denominator"
        ).set_index(summary_index)
        del measure

        # Combine the numerators and denominators
        measure_season = measure_season_num.join(measure_season_denom)
        del measure_season_num
        del measure_season_denom

        # Calculate the proportion
        measure_season["value"] = (
            measure_season["numerator"] / measure_season["denominator"]
        )

        # Prepare data for output
        measure_season = measure_season.reset_index().loc[
            :, ["practice", "year", "season", "value"]
        ]

        f_out = (
            OUTPUT_DIR
            / f"measure_seasonal_proportion_{value_col}_within_{value_threshold}days_by_{date_col}.csv"
        )
        measure_season.to_csv(f_out, index=False)

        ### Dropping this column to ensure that there is no confusion due to
        ### multiple overwritings of 'threshold_mask'.
        dataset_long = dataset_long.drop( "threshold_mask", axis=1 )

    #################################################################
    ### Generate median lead time measure                         ###
    #################################################################

    ### Note that dataset_long was created in the previous measure
    ### using the correct parameters for read() so needn't be read in
    ### again.

    medians = dataset_long.groupby(args.index_cols).median()
    del dataset_long

    measure = medians.reset_index()
    measure.columns = ["date", "practice", "value"]
    del medians

    ### Now that we have monthly data, we can calculate seasonal summaries

    measure_season = summarise_to_seasons(
        measure, index_cols_nodate, date_col="date", summary_method=np.median
    )
    del measure

    f_out = OUTPUT_DIR / f"measure_seasonal_median_{value_col}_by_{date_col}.csv"
    measure_season.to_csv(f_out, index=False)

    #################################################################
    ### Generate num patients measure                             ###
    #################################################################

    unique_col = "patient_id"

    dataset_long = read(f_in, args.index_cols, date_col, unique_col)
    num_patients = dataset_long.groupby(args.index_cols).nunique()
    del dataset_long

    measure = num_patients.reset_index()
    measure.columns = ["date", "practice", "value"]
    del num_patients

    ### Now that we have monthly data, we can calculate seasonal summaries

    measure_season = summarise_to_seasons(measure, index_cols_nodate, date_col="date")
    del measure

    f_out = OUTPUT_DIR / f"measure_seasonal_num_unique_patients_by_{date_col}.csv"
    measure_season.to_csv(f_out, index=False)

    #################################################################
    ### Generate num appointment measure                          ###
    #################################################################

    dataset_long = read(f_in, args.index_cols, date_col)
    counts = dataset_long.groupby(args.index_cols).size()
    del dataset_long

    measure = counts.reset_index()
    measure.columns = ["date", "practice", "value"]
    del counts

    ### Now that we have monthly data, we can calculate seasonal summaries

    measure_season = summarise_to_seasons(measure, index_cols_nodate, date_col="date")
    del measure

    f_out = OUTPUT_DIR / f"measure_seasonal_num_appointments_by_{date_col}.csv"
    measure_season.to_csv(f_out, index=False)


if __name__ == "__main__":
    main()
