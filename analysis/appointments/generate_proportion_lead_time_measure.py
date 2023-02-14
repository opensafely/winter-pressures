import argparse
import sys

from analysis.utils import APPOINTMENTS_OUTPUT_DIR as OUTPUT_DIR
from analysis.utils import read


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

    measure = total_counts.reset_index().rename(columns={date_col: "date"})
    del total_counts

    measure = measure.loc[:, ["value", "date"]]  # reorder columns

    f_out = (
        OUTPUT_DIR
        / f"measure_proportion_{args.value_col}_within_{args.value_threshold}days_by_{date_col}.csv"
    )
    measure.to_csv(f_out, index=False)


if __name__ == "__main__":
    main()
