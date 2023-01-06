import pandas

from analysis.utils import OUTPUT_DIR

f_in = OUTPUT_DIR / "dataset_wide.csv"
f_out = OUTPUT_DIR / "dataset_long.csv"


def main():
    dataset_wide = pandas.read_csv(f_in)
    dataset_long = pandas.wide_to_long(
        dataset_wide,
        ["booked_date", "lead_time_in_days"],
        ["patient_id", "practice", "region"],
        "appointment_num",
        sep="_",
    )
    dataset_long.to_csv(f_out)


if __name__ == "__main__":
    main()
