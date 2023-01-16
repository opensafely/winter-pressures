import itertools
import re

import more_itertools
import numpy
import pyarrow

from analysis.utils import OUTPUT_DIR


def split_suffix(s):
    pattern = r"(?P<col_name>\w+)_(?P<col_suffix>\d+)"
    match = re.match(pattern, s)
    col_name = match.group("col_name")
    col_suffix = int(match.group("col_suffix"))
    return col_name, col_suffix


def stacker(table_wide, index_names, group_size, suffix_name):
    index_table = table_wide.select(index_names)
    stack_table = table_wide.drop(index_names)

    columns_grouper = more_itertools.grouper(stack_table.columns, group_size)
    column_names_grouper = more_itertools.grouper(stack_table.column_names, group_size)
    for columns, column_names in zip(columns_grouper, column_names_grouper):
        column_names, suffixes = zip(*(split_suffix(x) for x in column_names))
        assert len(set(suffixes)) == 1, "Suffixes don't match. Is group_size correct?"
        suffix = suffixes[0]
        # numpy.full uses roughly 515 MiB for an array of 25 million elements; a list
        # comprehension uses roughly 893 MiB.
        suffix_column = pyarrow.array(
            numpy.full(shape=len(table_wide), fill_value=suffix)
        )
        yield pyarrow.Table.from_arrays(
            arrays=list(
                itertools.chain(index_table.columns, columns, [suffix_column]),
            ),
            names=list(
                itertools.chain(index_table.column_names, column_names, [suffix_name])
            ),
        )


def reshape_pyarrow(f_in, f_out, index_names, group_size, suffix_name):
    with pyarrow.memory_map(str(f_in), "rb") as source:
        table_wide = pyarrow.ipc.open_file(source).read_all()

    stack = stacker(table_wide, index_names, group_size, suffix_name)
    table_long = pyarrow.concat_tables(list(stack))

    with pyarrow.OSFile(str(f_out), "wb") as sink:
        with pyarrow.ipc.new_file(sink, table_long.schema) as writer:
            for batch in table_long.to_batches():
                writer.write(batch)


def main():
    f_in = OUTPUT_DIR / "dataset_wide.arrow"
    f_out = OUTPUT_DIR / "dataset_long.arrow"
    index_names = ["patient_id", "practice", "region"]
    group_size = 2
    suffix_name = "appointment_num"
    reshape_pyarrow(f_in, f_out, index_names, group_size, suffix_name)


if __name__ == "__main__":
    main()
