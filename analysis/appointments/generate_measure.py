import pandas

from analysis.utils import APPOINTMENTS_OUTPUT_DIR as OUTPUT_DIR

f_in = OUTPUT_DIR / "dataset_long.csv"
f_out = OUTPUT_DIR / "measure_median_lead_time_in_days.csv"


def read(f_in):
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

    index_cols = ["booked_month", "practice"]
    value_cols = ["lead_time_in_days"]
    date_cols = ["booked_month"]
    return pandas.read_csv(
        f_in,
        usecols=index_cols + value_cols,
        parse_dates=date_cols,
        engine="c",
        index_col=index_cols,
    )


def main():
    dataset_long = read(f_in)

    # FIXME: Until we rerun the `appointments_generate_dataset_sql` action, lead times
    # will be negated (7a44dfa). They shouldn't be, so we take their absolute value.
    dataset_long["lead_time_in_days"] = dataset_long["lead_time_in_days"].abs()

    by_practice = dataset_long.groupby(["booked_month", "practice"]).median()
    del dataset_long

    measure = by_practice.reset_index().loc[:, ["lead_time_in_days", "booked_month"]]
    del by_practice
    measure.columns = ["value", "date"]  # rename columns
    measure["population"] = 1
    measure = measure.loc[:, ["population", "value", "date"]]  # reorder columns
    measure.to_csv(f_out, index=False)


if __name__ == "__main__":
    main()
