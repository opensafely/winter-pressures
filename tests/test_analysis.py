"""Tests

Run the tests with:

```
opensafely exec python:latest pytest --disable-warnings
```
"""
import pyarrow
import pytest

from analysis import reshape_dataset


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
    assert sub_stack_2["patient_id"].to_pylist() == [1, 2, 3]
    assert sub_stack_2["lead_time_in_days"].to_pylist() == [2, None, 2]

    assert sub_stack_3.column_names == [
        "patient_id",
        "practice",
        "booked_date",
        "lead_time_in_days",
        "appointment_num",
    ]
    assert sub_stack_3["patient_id"].to_pylist() == [1, 2, 3]
    assert sub_stack_3["lead_time_in_days"].to_pylist() == [None, None, None]
