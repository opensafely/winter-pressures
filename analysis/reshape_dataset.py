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
        stack_cols_group = list(stack_cols_group)
        arrays = list(table_wide.select(index_cols + stack_cols_group))
        names = index_cols + [split_suffix(x)[0] for x in stack_cols_group]
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
