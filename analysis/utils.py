import functools
import itertools
import pathlib
import string

import numpy as np
import pandas

BASE_DIR = pathlib.Path(__file__).parents[1]
OUTPUT_DIR = BASE_DIR / "output"
APPOINTMENTS_OUTPUT_DIR = OUTPUT_DIR / "appointments"

# A mapping from season (string) to a list of months (as integer);
month_to_season_map = {"winter": [1, 2, 3, 12], "summer": [6, 7, 8, 9]}


def summarise_to_seasons(
    df,
    index_cols,
    date_col,
    value_col="value",
    summary_method=np.sum,
    mapping=month_to_season_map,
):
    """
    Summarises data in a dataframe to seasons.
    df: the dataframe
    index_cols: the name of the columns to use to group the data
    date_col: the name of the column containing the date (this must be pandas.datetime type)
    value_col: the name of the column containing the value to be summarise [default="value"]
    summary_method: the function to use when summarising the data [default=np.sum]
    mapping: a dictionary mapping the season to a list of months
    """

    #  Remove any unecessary data before we do any calculations
    df = df.loc[:, index_cols + [date_col, value_col]]

    # Extract the month and year and represent as integers
    df["month_n"] = df[date_col].dt.month.astype(np.int32)
    df["year"] = df[date_col].dt.year.astype(np.int32)

    # Use the mapping provided to map from the month to the season
    df.loc[df["month_n"].isin(mapping["winter"]), "season"] = 1
    df.loc[df["month_n"].isin(mapping["summer"]), "season"] = 0

    # Remove columns that are no longer necessary and remove
    # any rows that contain NA values (these will be rows for months
    # that are not represented in the mapping dictionary)
    df = df.drop(["month_n"], axis=1)
    df = df.dropna()
    df["season"] = df["season"].astype(int)

    # Group the data and summarise using the summary_method
    df = df.groupby(index_cols + ["season", "year"]).agg(func=summary_method)

    # Reorder columns
    df = df.reset_index().loc[:, ["practice", "year", "season", value_col]]

    return df


def read(f_in, index_cols, date_col, value_col=None):
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

    usecols = index_cols
    if value_col:
        usecols = index_cols + [value_col]

    return pandas.read_csv(
        f_in, usecols=usecols, parse_dates=[date_col], engine="c", index_col=index_cols,
    )


def to_series(f):
    @functools.wraps(f)
    def wrapper(self, *args):
        name = f.__name__.replace("_generate_", "")
        suffix = f"_{args[0]}" if args else ""
        return pandas.Series(f(self), index=self._idx, name=f"{name}{suffix}")

    return wrapper


class DummyDatasetGenerator:
    _dates = pandas.date_range("2021-01-01", "2021-12-31").strftime("%Y-%m-%d")
    _chars = list(string.ascii_letters)

    def __init__(self, num_patients, num_appointments, seed=1):
        self._idx = pandas.RangeIndex(1, num_patients + 1, name="patient_id")
        self.num_appointments = num_appointments
        self._rng = np.random.default_rng(seed)

    @property
    def num_patients(self):
        return len(self._idx)

    @to_series
    def _generate_practice(self):
        return self._rng.integers(1, 11, self.num_patients)

    @to_series
    def _generate_region(self):
        return (
            "".join(x) for x in self._rng.choice(self._chars, (self.num_patients, 16))
        )

    @to_series
    def _generate_booked_date(self):
        return self._rng.choice(self._dates, self.num_patients)

    @to_series
    def _generate_lead_time_in_days(self):
        return self._rng.integers(10, size=self.num_patients)

    def generate(self):
        admin = (self._generate_practice(), self._generate_region())
        appointments = itertools.chain.from_iterable(
            (self._generate_booked_date(i), self._generate_lead_time_in_days(i))
            for i in range(1, self.num_appointments + 1)
        )
        return pandas.concat(itertools.chain(admin, appointments), axis=1).reset_index()
