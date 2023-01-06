import pandas
from pandas.api.types import is_datetime64_any_dtype
from pandas.tseries.offsets import MonthBegin

from analysis.utils import OUTPUT_DIR

f_in = OUTPUT_DIR / "dataset_long.arrow"
f_out = OUTPUT_DIR / "measure_median_lead_time_in_days_by_nunique_patient_id.csv"


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
