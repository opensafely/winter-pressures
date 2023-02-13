import argparse
import sys

import pandas

from analysis.utils import APPOINTMENTS_OUTPUT_DIR as OUTPUT_DIR, read


# def read(f_in, index_cols, value_col, date_col):
#     # @iaindillingham did some work previously to investigate how we might read in
#     # sqlrunner outputs most efficiently.
#     #
#     # These investigations recommended that:
#     # - only thise columns required should be read in, using the usecols argument
#     # - all dates be parsed at read in, using the parse_dates argument
#     # - the index be defined at read in, using the index_col argument
#     #
#     return pandas.read_csv(
#         f_in,
#         usecols=index_cols + [value_col],
#         parse_dates=[date_col],
#         engine="c",
#         index_col=index_cols,
#     )


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

    dataset_long = read(f_in, args.index_cols, args.value_col, date_col)
    dataset_long["threshold_mask"] = ( dataset_long[args.value_col] <= args.value_threshold )
    total_counts = dataset_long.groupby(args.index_cols + ["threshold_mask"]).size()
    del dataset_long

    total_counts = total_counts.unstack("threshold_mask", fill_value=0)
    total_counts["population"] = total_counts.sum(axis=1)
    measure = total_counts.reset_index().rename(columns={True: "value", date_col: "date"})
    del total_counts

    measure = measure.loc[
        :, ["practice", "population", "value", "date"]
    ]  # reorder columns

    f_out = (
        OUTPUT_DIR
        / f"measure_proportion_{args.value_col}_within{args.value_threshold}days_by_{date_col}.csv"
    )
    measure.to_csv(f_out, index=False)


if __name__ == "__main__":
    main()
