import itertools
import re

import more_itertools
import pyarrow

from analysis.utils import OUTPUT_DIR


def split_suffix(s):
    pattern = r"(?P<col_name>\w+)_(?P<col_suffix>\d+)"
    match = re.match(pattern, s)
    col_name = match.group("col_name")
    col_suffix = int(match.group("col_suffix"))
    return col_name, col_suffix


def reshape_pyarrow(f_in, f_out):
    with pyarrow.memory_map(str(f_in), "rb") as memory_mapped_file:
        table_wide = pyarrow.ipc.open_file(memory_mapped_file).read_all()

    index_cols = table_wide.column_names[:3]
    stack_cols = table_wide.column_names[3:]

    table_long_groups = []
    for stack_cols_group in more_itertools.grouper(stack_cols, 2):
        names, suffixes = zip(*(split_suffix(x) for x in stack_cols_group))
        assert len(set(suffixes)) == 1
        suffix = suffixes[0]

        index_table = table_wide.select(index_cols)
        stack_table_group = table_wide.select(stack_cols_group).rename_columns(names)
        appointment_num = pyarrow.array([suffix] * len(table_wide))

        arrays = list(
            itertools.chain(
                index_table.itercolumns(),
                stack_table_group.itercolumns(),
                [appointment_num],
            )
        )
        names = (
            index_table.column_names
            + stack_table_group.column_names
            + ["appointment_num"]
        )
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
