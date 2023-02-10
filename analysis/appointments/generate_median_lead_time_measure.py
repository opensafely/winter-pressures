import argparse
import sys

import pandas

from analysis.utils import APPOINTMENTS_OUTPUT_DIR as OUTPUT_DIR


def read(f_in, index_cols, value_col, date_col):
    # How do we ensure `pandas.read_csv` is as efficient as possible? Let's do some
    # profiling! Our dummy long dataset:
    # * has 10 million rows (10 appointments for 1 million patients)
    # * has five columns (patient_id, practice, region, booked_month, lead_time_in_days)
    # * occupies 372MB on disk

    # The following table shows the peak memory consumption when parsing the CSV file
    # (read_csv) and the memory consumption of the resulting data frame (memory_usage)
    # in MiB, with each of the arguments applied in turn.

    # | read_csv | memory_usage | arguments   |
    # | -------- | ------------ | ----------- |
    # | 1668     | 1564         | default     |
    # | 579      | 791          | usecols     |
    # | 636      | 228          | parse_dates |
    # | 600      | 228          | engine      |
    # | 602      | 95           | index_col   |

    # The peak memory consumption was determined by `%memit`; the memory consumption was
    # determined by `dataset_long.memory_usage(deep=True).sum() / 1_024**2`.

    # The following arguments increase the peak memory consumption or the memory
    # consumption of the resulting data frame, so should be avoided:
    # * infer_datetime_format=True
    # * date_parser=dateutil.parser.isoparse
    # * memory_map=True
    # * squeeze=True

    return pandas.read_csv(
        f_in,
        usecols=index_cols + [value_col],
        parse_dates=[date_col],
        engine="c",
        index_col=index_cols,
    )


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
    dataset_long = read(f_in, args.index_cols, args.value_col, date_col)
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
