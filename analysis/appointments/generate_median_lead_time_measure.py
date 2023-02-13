import argparse
import sys

import pandas

from analysis.utils import APPOINTMENTS_OUTPUT_DIR as OUTPUT_DIR, read


def parse_args(args):
    parser = argparse.ArgumentParser()
    parser.add_argument("--value-col", required=True)
    parser.add_argument("--index-cols", action="extend", nargs="+", required=True)
    return parser.parse_args(args)


def main():
    args = parse_args(sys.argv[1:])
    # We assume the first column in the list of columns is a date column.
    date_col = args.index_cols[0]

    f_in = OUTPUT_DIR / "dataset_long.csv.gz"
    dataset_long = read(f_in, args.index_cols, date_col, args.value_col)
    medians = dataset_long.groupby(args.index_cols).median()
    del dataset_long

    measure = medians.reset_index()
    del medians
    measure.columns = ["date", "practice", "value"]  # rename columns
    measure["population"] = 1
    measure = measure.loc[
        :, ["practice", "population", "value", "date"]
    ]  # reorder columns
    f_out = OUTPUT_DIR / f"measure_median_{args.value_col}_by_{date_col}.csv"
    measure.to_csv(f_out, index=False)


if __name__ == "__main__":
    main()
