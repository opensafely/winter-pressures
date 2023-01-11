from analysis import reshape_dataset


def test_strip_suffix():
    assert reshape_dataset.strip_suffix("booked_date_1") == "booked_date"
