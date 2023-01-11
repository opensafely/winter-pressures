from analysis import reshape_dataset


def test_split_suffix():
    assert reshape_dataset.split_suffix("booked_date_1") == ("booked_date", 1)
