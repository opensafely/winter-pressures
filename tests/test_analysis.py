"""Tests

Run the tests with:

```
opensafely exec python:latest pytest --disable-warnings
```
"""
import pyarrow
import pytest
import pandas as pd
import numpy as np

from pandas import testing
from analysis.appointments import reshape_dataset
from analysis.utils import summarise_to_seasons


@pytest.fixture
def monthly_table():
    test_data = pd.DataFrame(
        {
            "date": pd.Series(
                [
                    ### Practice 1
                    "2021-01-01",  # some winter dates
                    "2021-02-01",  # ...
                    "2021-03-01",  # ...
                    "2021-06-01",  # some summer dates
                    "2021-07-01",  # ...
                    "2021-08-01",  # ...
                    "2021-04-01",  # some neither dates
                    "2021-05-01",  # ...
                    ### Practice 2
                    "2021-01-01",  # some winter dates
                    "2021-02-01",  # ...
                    "2021-03-01",  # ...
                    "2021-06-01",  # some summer dates
                    "2021-07-01",  # ...
                    "2021-08-01",  # ...
                    "2021-04-01",  # some neither dates
                    "2021-05-01",  # ...
                ]
            ),
            "practice": pd.Series([1] * 8 + [2] * 8),
            "value": pd.Series(
                [0, 1, 2, 3, 4, 5, 100, 200, 6, 7, 8, 9, 10, 11, 300, 400]
            ),
        }
    )
    test_data["date"] = pd.to_datetime(test_data["date"])
    return test_data


def test_summarise_to_seasons_by_sum(monthly_table):

    obs_sum = summarise_to_seasons(
        monthly_table,
        index_cols=["practice"],
        date_col="date",
        value_col="value",
        summary_method=np.sum,
    )

    exp_sum = pd.DataFrame(
        {
            "practice": pd.Series([1, 1, 2, 2]),
            "year": pd.Series([2021, 2021, 2021, 2021]),
            "season": pd.Series([0, 1, 0, 1]),
            "value": pd.Series([12, 3, 30, 21]),
        }
    )

    testing.assert_frame_equal(obs_sum, exp_sum)


def test_summarise_to_seasons_by_median(monthly_table):

    obs_sum = summarise_to_seasons(
        monthly_table,
        index_cols=["practice"],
        date_col="date",
        value_col="value",
        summary_method=np.median,
    )

    exp_sum = pd.DataFrame(
        {
            "practice": pd.Series([1, 1, 2, 2]),
            "year": pd.Series([2021, 2021, 2021, 2021]),
            "season": pd.Series([0, 1, 0, 1]),
            "value": pd.Series([4, 1, 10, 7]),
        }
    )

    testing.assert_frame_equal(obs_sum, exp_sum)


def test_split_suffix():
    assert reshape_dataset.split_suffix("booked_date_1") == ("booked_date", 1)


@pytest.mark.parametrize(
    "columns,mask",
    [
        (([1, None],), [True, False]),
        (([1, None], [1, 2]), [True, False]),
        (([1, None, 3], [1, 2, 3]), [True, False, True]),
    ],
)
def test_are_valid(columns, mask):
    columns = tuple(pyarrow.array(x) for x in columns)
    mask = pyarrow.array(mask)
    assert reshape_dataset.are_valid(columns) == mask


def test_stacker():
    # arrange
    table_wide = pyarrow.Table.from_arrays(
        arrays=[
            pyarrow.array([1, 2, 3]),
            pyarrow.array([1, 2, 3]),
            pyarrow.array(["2022-01-01", "2022-01-01", "2022-01-01"]),
            pyarrow.array([1, 1, 1]),
            pyarrow.array(["2022-02-02", None, "2022-02-02"]),
            pyarrow.array([2, None, 2]),
            pyarrow.array([None, None, None]),
            pyarrow.array([None, None, None]),
        ],
        names=[
            "patient_id",
            "practice",
            "booked_date_1",
            "lead_time_in_days_1",
            "booked_date_2",
            "lead_time_in_days_2",
            "booked_date_3",
            "lead_time_in_days_3",
        ],
    )

    # act
    stack = reshape_dataset.stacker(
        table_wide, ["patient_id", "practice"], 2, "appointment_num"
    )
    sub_stack_1, sub_stack_2, sub_stack_3 = list(stack)

    # assert
    assert sub_stack_1.column_names == [
        "patient_id",
        "practice",
        "booked_date",
        "lead_time_in_days",
        "appointment_num",
    ]
    assert sub_stack_1["patient_id"].to_pylist() == [1, 2, 3]
    assert sub_stack_1["lead_time_in_days"].to_pylist() == [1, 1, 1]

    assert sub_stack_2.column_names == [
        "patient_id",
        "practice",
        "booked_date",
        "lead_time_in_days",
        "appointment_num",
    ]
    assert sub_stack_2["patient_id"].to_pylist() == [1, 3]
    assert sub_stack_2["lead_time_in_days"].to_pylist() == [2, 2]

    assert sub_stack_3.column_names == [
        "patient_id",
        "practice",
        "booked_date",
        "lead_time_in_days",
        "appointment_num",
    ]
    assert sub_stack_3["patient_id"].to_pylist() == []
    assert sub_stack_3["lead_time_in_days"].to_pylist() == []
