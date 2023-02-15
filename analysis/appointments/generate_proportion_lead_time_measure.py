import argparse
import sys
import numpy as np
import pandas as pd

from analysis.utils import APPOINTMENTS_OUTPUT_DIR as OUTPUT_DIR
from analysis.utils import read
from analysis.utils import summarise_to_seasons
from analysis.utils import seasonal_map


def parse_args(args):
    parser = argparse.ArgumentParser()
    parser.add_argument("--value-col", required=True)
    parser.add_argument("--value-threshold", required=True, type=int)
    parser.add_argument("--index-cols", action="extend", nargs="+", required=True)
    return parser.parse_args(args)


def main():
    args = parse_args(sys.argv[1:])
    # We assume the first column in the list of columns is a date column.
    date_col = args.index_cols[0]

    f_in = OUTPUT_DIR / "dataset_long.csv.gz"

    dataset_long = read(f_in, args.index_cols, date_col, args.value_col)
    dataset_long["threshold_mask"] = (
        dataset_long[args.value_col] <= args.value_threshold
    )
    total_counts = dataset_long.groupby(args.index_cols + ["threshold_mask"]).size()
    del dataset_long

    total_counts = total_counts.unstack("threshold_mask", fill_value=0)
    total_counts["denominator"] = total_counts.sum(axis=1)
    total_counts.rename(columns={True: "numerator"}, inplace=True)
    total_counts["value"] = total_counts["numerator"] / total_counts["denominator"]

    ### Creating a measure file for a monthly decile plot ###########
    measure = total_counts.reset_index().rename(columns={date_col: "date"})
    del total_counts
    measure_monthly = measure.loc[:, ["value", "date"]]  # reorder columns

    f_out = (
        OUTPUT_DIR
        / f"measure_monthly_proportion_{args.value_col}_within_{args.value_threshold}days_by_{date_col}.csv"
    )
    measure_monthly.to_csv(f_out, index=False)
    del measure_monthly

    ### Creating seasonal summaries #################################
    index_cols_nodate = args.index_cols[1:]
    #  Sum the numerator values for each practice across the months
    # (as defined by analysis.utils.summarise_to_seasons())
    summary_index = ["practice", "year", "season"]
    measure_season_num = summarise_to_seasons(
        measure, index_cols_nodate, date_col="date", value_col="numerator"
    ).set_index(summary_index)
    #  Sum the denominator values for each practice across the months
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
        / f"measure_seasonal_proportion_{args.value_col}_within_{args.value_threshold}days_by_{date_col}.csv"
    )
    measure_season.to_csv(f_out, index=False)


if __name__ == "__main__":
    main()
