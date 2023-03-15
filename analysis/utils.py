### decile plots
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import matplotlib
import functools
import itertools
import pathlib
import string
from datetime import date
import re
import argparse
import pandas
import json
import glob
import jsonschema
import analysis.charts as charts

BASE_DIR = pathlib.Path(__file__).parents[1]
OUTPUT_DIR = BASE_DIR / "output"
APPOINTMENTS_OUTPUT_DIR = OUTPUT_DIR / "appointments"

# import json study_dates (from design.R)
with open("./lib/design/study_dates.json") as f:
  study_dates = json.load(f)

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
    df["year_month"] = str(df["year"]) + "-" + str(df["month_n"].zfill(2))

    # Use the mapping provided to map from the month to the season
    df.loc[df["month_n"].isin(mapping["winter"]), "season"] = 1
    df.loc[df["month_n"].isin(mapping["summer"]), "season"] = 0
    df.loc[df["year_month"].isin(study_dates["winter_dates"][0]), "season"] = 1
    df.loc[df["year_month"].isin(study_dates["summer_dates"][0]), "season"] = 0

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

def filter_by_date(d, date_col, start_date, end_date):
    return d.reset_index().set_index(date_col).loc[start_date:end_date]

def read(f_in, index_cols, date_col, value_col=None, start_date='1900-01-01', end_date=str(date.today())):
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

    d_in = pandas.read_csv(
        f_in, usecols=usecols, parse_dates=[date_col], engine="c", index_col=index_cols,
    )

    d_in = filter_by_date( d_in, date_col, start_date, end_date )
    d_in = d_in.reset_index().set_index(index_cols)

    return d_in


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


## 

DEFAULT_CONFIG = {
    "show_outer_percentiles": False,
    "tables": {
        "output": True,
    },
    "charts": {
        "output": True,
    },
}

CONFIG_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "properties": {
        "show_outer_percentiles": {"type": "boolean"},
        "tables": {
            "type": "object",
            "additionalProperties": False,
            "properties": {
                "output": {"type": "boolean"},
            },
        },
        "charts": {
            "type": "object",
            "additionalProperties": False,
            "properties": {
                "output": {"type": "boolean"},
            },
        },
    },
}

MEASURE_FNAME_REGEX = re.compile(r"measure_(?P<id>\w+)\.csv")


def get_measure_tables(input_files):
    for input_file in input_files:
        measure_fname_match = re.match(MEASURE_FNAME_REGEX, input_file.name)
        if measure_fname_match is not None:
            measure_table = pandas.read_csv(input_file, parse_dates=["date"])
            measure_table.attrs["id"] = measure_fname_match.group("id")
            yield measure_table


def drop_zero_denominator_rows(measure_table):
    """
    Zero-denominator rows could cause the deciles to be computed incorrectly, so should
    be dropped beforehand. For example, a practice can have zero registered patients. If
    the measure is computed from the number of registered patients by practice, then
    this practice will have a denominator of zero and, consequently, a value of inf.
    Depending on the implementation, this practice's value may be sorted as greater than
    other practices' values, which may increase the deciles.
    """
    # It's non-trivial to identify the denominator column without the associated Measure
    # instance. It's much easier to test the value column for inf, which is returned by
    # Pandas when the second argument of a division operation is zero.
    is_not_inf = measure_table["value"] != np.inf
    num_is_inf = len(is_not_inf) - is_not_inf.sum()
    # logger.info(f"Dropping {num_is_inf} zero-denominator rows")
    return measure_table[is_not_inf].reset_index(drop=True)


def get_deciles_table(measure_table, config):
    return charts.add_percentiles(
        measure_table,
        period_column="date",
        column="value",
        show_outer_percentiles=config["show_outer_percentiles"],
    )


def write_deciles_table(deciles_table, path, filename):
    create_dir(path)
    deciles_table.to_csv(path / filename, index=False)


def get_deciles_chart(measure_table, config):
    return charts.deciles_chart(
        measure_table,
        period_column="date",
        column="value",
        show_outer_percentiles=config["show_outer_percentiles"],
    )


def write_deciles_chart(deciles_chart, path, filename):
    create_dir(path)
    deciles_chart.savefig(path / filename, bbox_inches="tight")


def create_dir(path):
    pathlib.Path(path).mkdir(parents=True, exist_ok=True)


def get_path(*args):
    return pathlib.Path(*args).resolve()


def match_paths(pattern):
    return [get_path(x) for x in glob.glob(pattern)]


def parse_config(config_json):
    user_config = json.loads(config_json)
    config = DEFAULT_CONFIG.copy()
    config.update(user_config)
    try:
        jsonschema.validate(config, CONFIG_SCHEMA)
    except jsonschema.ValidationError as e:
        raise argparse.ArgumentTypeError(e.message) from e
    return config


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input-files",
        required=True,
        type=match_paths,
        help="Glob pattern for matching one or more input files",
    )
    parser.add_argument(
        "--output-dir",
        required=True,
        type=get_path,
        help="Path to the output directory",
    )
    parser.add_argument(
        "--config",
        default=DEFAULT_CONFIG.copy(),
        type=parse_config,
        help="JSON-encoded configuration",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    input_files = args.input_files
    output_dir = args.output_dir
    config = args.config

    for measure_table in get_measure_tables(input_files):
        measure_table = drop_zero_denominator_rows(measure_table)
        id_ = measure_table.attrs["id"]
        if config["tables"]["output"]:
            deciles_table = get_deciles_table(measure_table, config)
            fname = f"deciles_table_{id_}.csv"
            write_deciles_table(deciles_table, output_dir, fname)

        if config["charts"]["output"]:
            chart = get_deciles_chart(measure_table, config)
            fname = f"deciles_chart_{id_}.png"
            write_deciles_chart(chart, output_dir, fname)


if __name__ == "__main__":
    main()