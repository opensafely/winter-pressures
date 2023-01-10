import functools
import itertools
import pathlib
import string

import numpy
import pandas

BASE_DIR = pathlib.Path(__file__).parents[1]
OUTPUT_DIR = BASE_DIR / "output"


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
        self._rng = numpy.random.default_rng(seed)

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
