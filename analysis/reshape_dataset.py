import pandas

from analysis.utils import OUTPUT_DIR

f_in = OUTPUT_DIR / "dataset_wide.arrow"
f_out = OUTPUT_DIR / "dataset_long.arrow"


def main():
    dataset_wide = pandas.read_feather(f_in)
    dataset_long = pandas.wide_to_long(
        dataset_wide,
        ["booked_date", "lead_time_in_days"],
        ["patient_id", "practice", "region"],
        "appointment_num",
        sep="_",
    )
    # dataset_long has a MultiIndex; feather only supports a RangeIndex. So, we reset
    # before we write.
    dataset_long.reset_index().to_feather(f_out)


if __name__ == "__main__":
    main()
