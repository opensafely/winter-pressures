import re

import more_itertools
import pandas
import pyarrow

from analysis.utils import OUTPUT_DIR


def reshape_pandas(f_in, f_out):
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


def strip_suffix(s):
    return re.match(r"(\w+)_\d+", s).group(1)


def reshape_pyarrow(f_in, f_out):
    with pyarrow.memory_map(str(f_in), "rb") as memory_mapped_file:
        table_wide = pyarrow.ipc.open_file(memory_mapped_file).read_all()

    index_cols = table_wide.column_names[:3]
    stack_cols = table_wide.column_names[3:]

    table_long_groups = []
    for stack_cols_group in more_itertools.grouper(stack_cols, 2):
        stack_cols_group = list(stack_cols_group)
        arrays = list(table_wide.select(index_cols + stack_cols_group))
        names = index_cols + [strip_suffix(x) for x in stack_cols_group]
        table_long_group = pyarrow.Table.from_arrays(arrays, names)
        table_long_groups.append(table_long_group)

    table_long = pyarrow.concat_tables(table_long_groups)

    with pyarrow.OSFile(str(f_out), "wb") as sink:
        with pyarrow.ipc.new_file(sink, table_long.schema) as writer:
            for batch in table_long.to_batches():
                writer.write(batch)


def main():
    f_in = OUTPUT_DIR / "dataset_wide.arrow"
    f_out = OUTPUT_DIR / "dataset_long.arrow"
    reshape_pyarrow(f_in, f_out)


if __name__ == "__main__":
    main()
