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
import json

from pandas import testing
from analysis.appointments import reshape_dataset
from analysis.utils import summarise_to_seasons, filter_by_date, flatten

test_month_start = pd.to_datetime("2021-01-01")
plus_month = 8
test_month_end = test_month_start + pd.DateOffset(months=plus_month)

@pytest.fixture
def monthly_table_with_index():
    test_data = pd.DataFrame(
        {
            "date": pd.date_range(start=test_month_start, end=test_month_end, freq="M") + pd.offsets.MonthBegin(0),
            "practice": 1,
        }
    )
    return test_data.set_index(['date','practice'])

### Some testing parameters to be used by test_filter_by_date();
### these scenarios test that the filter_by_date function to check 
### that the correct number of months are present in the output
### data frame.
### Scenario 1: Request to filter data to 4 months, defined by
###             test_month_start to four months later, where those
###             four months all exist in our dataset. We expect to
###             have four months in the resulting dataset.
### Scenario 2: Request to filter data to 4 months, where the start
###             date is four months AFTER the end date. We expect to
###             have zero months in the resulting dataset.
### Scenario 3: Request to filter data to 12 months, where the input
###             data only runs to 8 months after the start date. We
###             expect to have eight months in the resulting dataset.
### Scenario 4: Request to filter data to 1 month before the start date
###             to 1 month after the end date (i.e., 10 months in total)
###             of the input data. We expect to have eight months
###             in the resulting dataset.
@pytest.mark.parametrize(
    "test_start_date, test_end_date, num_months",
    [
        (test_month_start, test_month_start + pd.DateOffset(months=4), 4),
        (test_month_start + pd.DateOffset(months=4), test_month_start, 0),
        (test_month_start, test_month_start + pd.DateOffset(months=12), plus_month),
        (test_month_start - pd.DateOffset(months=1), test_month_end + pd.DateOffset(months=1), plus_month),
    ],
)

def test_filter_by_date(monthly_table_with_index, test_start_date, test_end_date, num_months ):

    obs_filtered = filter_by_date(
        monthly_table_with_index,
        date_col="date",
        start_date = str(test_start_date),
        end_date = str(test_end_date)
    )
    
    exp_months = pd.date_range(start=test_start_date, end=test_end_date, freq="M") + pd.offsets.MonthBegin(0)
    exp_months = exp_months.intersection(monthly_table_with_index.index.get_level_values('date'))
    exp_months = exp_months.strftime('%Y-%m-%d').rename('date')

    obs_months = obs_filtered.index.strftime('%Y-%m-%d')

    assert len(obs_filtered) == num_months
    assert all(exp_months == obs_months)


@pytest.fixture
def monthly_table():
    test_data = pd.DataFrame(
        {
            "date": pd.Series(
                [
                    ### Practice 1
                    "2022-01-01",  # some winter dates
                    "2022-02-01",  # ...
                    "2022-03-01",  # ...
                    "2021-06-01",  # some summer dates
                    "2021-07-01",  # ...
                    "2021-08-01",  # ...
                    "2021-04-01",  # some neither dates
                    "2021-05-01",  # ...
                    ### Practice 2
                    "2022-01-01",  # some winter dates
                    "2022-02-01",  # ...
                    "2022-03-01",  # ...
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
            "year": pd.Series([2021, 2022, 2021, 2022]),
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
            "year": pd.Series([2021, 2022, 2021, 2022]),
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
