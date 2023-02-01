import pandas
from pandas.api.types import is_datetime64_any_dtype
from pandas.tseries.offsets import MonthBegin

from analysis.utils import APPOINTMENTS_OUTPUT_DIR as OUTPUT_DIR

f_in = OUTPUT_DIR / "dataset_long.arrow"
f_out = OUTPUT_DIR / "measure_median_lead_time_in_days_by_nunique_patient_id.csv"


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
    dataset_long = pandas.read_feather(f_in)

    # Although booked_date is derived from column of type date, it is represented as a
    # string by the dummy data generator. That may be a bug in the dummy data generator,
    # so we log and, if necessary, cast.
    print(f"booked_date is of type {dataset_long.booked_date.dtypes}")
    if not is_datetime64_any_dtype(dataset_long["booked_date"]):
        dataset_long["booked_date"] = pandas.to_datetime(dataset_long["booked_date"])

    dataset_long["booked_date"] = dataset_long["booked_date"] - MonthBegin(1)

    by_practice = dataset_long.groupby(["booked_date", "practice"]).aggregate(
        {
            "patient_id": ["nunique"],
            "lead_time_in_days": ["median"],
        }
    )
    by_practice.columns = pandas.Index(
        [f"{l2}_{l1}" for l1, l2 in by_practice.columns.to_flat_index()]
    )

    measure = by_practice.reset_index().loc[
        :,
        [
            "nunique_patient_id",
            "median_lead_time_in_days",
            "booked_date",
        ],
    ]
    measure.columns = ["population", "value", "date"]
    measure.to_csv(f_out, index=False)


if __name__ == "__main__":
    main()
