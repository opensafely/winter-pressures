import argparse
import sys

import pandas

from analysis.utils import APPOINTMENTS_OUTPUT_DIR as OUTPUT_DIR


def read(f_in, index_cols, date_col):
    # @iaindillingham did some work previously to investigate how we might read in
    # sqlrunner outputs most efficiently.
    #
    # These investigations recommended that:
    # - only thise columns required should be read in, using the usecols argument
    # - all dates be parsed at read in, using the parse_dates argument
    # - the index be defined at read in, using the index_col argument
    #
    return pandas.read_csv(
        f_in,
        usecols=index_cols,
        parse_dates=[date_col],
        engine="c",
        index_col=index_cols,
    )


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
    measure["population"] = 1
    measure = measure.loc[
        :, ["practice", "population", "value", "date"]
    ]  # reorder columns
    f_out = OUTPUT_DIR / f"measure_num_appointments_by_{date_col}.csv"
    measure.to_csv(f_out, index=False)


if __name__ == "__main__":
    main()
