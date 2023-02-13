import argparse
import sys

from analysis.utils import APPOINTMENTS_OUTPUT_DIR as OUTPUT_DIR
from analysis.utils import read


def parse_args(args):
    parser = argparse.ArgumentParser()
    parser.add_argument("--unique-col", required=True)
    parser.add_argument("--index-cols", action="extend", nargs="+", required=True)
    return parser.parse_args(args)


def main():
    args = parse_args(sys.argv[1:])
    # We assume the first column in the list of columns is a date column.
    date_col = args.index_cols[0]

    f_in = OUTPUT_DIR / "dataset_long.csv.gz"
    dataset_long = read(f_in, args.index_cols, date_col, args.unique_col)
    num_patients = dataset_long.groupby(args.index_cols).nunique()
    del dataset_long

    measure = num_patients.reset_index()
    del num_patients
    measure.columns = ["date", "practice", "value"]  # rename columns
    measure["population"] = 1
    measure = measure.loc[
        :, ["practice", "population", "value", "date"]
    ]  # reorder columns
    f_out = OUTPUT_DIR / f"measure_num_unique_patients_by_{date_col}.csv"
    measure.to_csv(f_out, index=False)


if __name__ == "__main__":
    main()