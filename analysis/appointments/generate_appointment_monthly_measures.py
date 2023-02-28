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

    f_in = OUTPUT_DIR / "dataset_long.csv.gz"

    #################################################################
    ### Generate proportion lead time measures                    ###
    #################################################################

    value_col = "lead_time_in_days"

    dataset_long = read(
        f_in=f_in, index_cols=args.index_cols, date_col=date_col, value_col=value_col
    )

    for value_threshold in args.value_thresholds:
        dataset_long["threshold_mask"] = dataset_long[value_col] <= value_threshold
        total_counts = dataset_long.groupby(args.index_cols + ["threshold_mask"]).size()

        total_counts = total_counts.unstack("threshold_mask", fill_value=0)
        total_counts["denominator"] = total_counts.sum(axis=1)
        total_counts.rename(columns={True: "numerator"}, inplace=True)
        total_counts["value"] = total_counts["numerator"] / total_counts["denominator"]

        measure = total_counts.reset_index().rename(columns={date_col: "date"})
        del total_counts
        measure_monthly = measure.loc[:, ["value", "date"]]  # reorder columns

        f_out = (
            OUTPUT_DIR
            / f"measure_monthly_proportion_{value_col}_within_{value_threshold}days_by_{date_col}.csv"
        )
        measure_monthly.to_csv(f_out, index=False)
        del measure_monthly

        ### Dropping this column to ensure that there is no confusion due to
        ### multiple overwritings of 'threshold_mask'.
        dataset_long = dataset_long.drop("threshold_mask", axis=1)

    #################################################################
    ### Generate median lead time measure                         ###
    #################################################################

    ### Note that dataset_long was created in the previous measure
    ### using the correct parameters for read() so needn't be read in
    ### again.

    medians = dataset_long.groupby(args.index_cols).median()
    del dataset_long

    measure = medians.reset_index()
    del medians
    measure.columns = ["date", "practice", "value"]  # rename columns
    measure_monthly = measure.loc[:, ["value", "date"]]  # reorder columns

    f_out = OUTPUT_DIR / f"measure_monthly_median_{value_col}_by_{date_col}.csv"
    measure_monthly.to_csv(f_out, index=False)
    del measure_monthly

    #################################################################
    ### Generate num patients measure                             ###
    #################################################################

    unique_col = "patient_id"

    dataset_long = read(
        f_in=f_in, index_cols=args.index_cols, date_col=date_col, value_col=unique_col
    )
    num_patients = dataset_long.groupby(args.index_cols).nunique()
    del dataset_long

    measure = num_patients.reset_index()
    del num_patients
    measure.columns = ["date", "practice", "value"]  # rename columns
    measure_monthly = measure.loc[:, ["value", "date"]]  # reorder columns

    f_out = OUTPUT_DIR / f"measure_monthly_num_unique_patients_by_{date_col}.csv"
    measure_monthly.to_csv(f_out, index=False)
    del measure_monthly

    #################################################################
    ### Generate num appointment measure                          ###
    #################################################################

    dataset_long = read(f_in=f_in, index_cols=args.index_cols, date_col=date_col)
    counts = dataset_long.groupby(args.index_cols).size()
    del dataset_long

    measure = counts.reset_index()
    del counts
    measure.columns = ["date", "practice", "value"]  # rename columns

    ### Creating a measure file for a monthly decile plot
    measure_monthly = measure.loc[:, ["value", "date"]]  # reorder columns
    f_out = OUTPUT_DIR / f"measure_monthly_num_appointments_by_{date_col}.csv"
    measure_monthly.to_csv(f_out, index=False)
    del measure_monthly


if __name__ == "__main__":
    main()
