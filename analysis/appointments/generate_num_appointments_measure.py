import argparse
import sys
import numpy as np
import pandas as pd

from analysis.utils import APPOINTMENTS_OUTPUT_DIR as OUTPUT_DIR
from analysis.utils import read
from analysis.utils import seasonal_map
from analysis.utils import summarise_to_seasons


def parse_args(args):
    parser = argparse.ArgumentParser()
    parser.add_argument("--index-cols", action="extend", nargs="+", required=True)
    return parser.parse_args(args)


def main():
    args = parse_args(sys.argv[1:])
    # We assume the first column in the list of columns is a date column.
    date_col = args.index_cols[0]

    f_in = OUTPUT_DIR / "dataset_long.csv.gz"
    dataset_long = read(f_in, args.index_cols, date_col)
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

    ### Creating seasonal summaries
    index_cols_nodate = args.index_cols[1:]
    measure_season = summarise_to_seasons(measure, index_cols_nodate, "date")
    del measure

    f_out = OUTPUT_DIR / f"measure_seasonal_num_appointments_by_{date_col}.csv"
    measure_season.to_csv(f_out, index=False)


if __name__ == "__main__":
    main()
