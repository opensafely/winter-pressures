from analysis.utils import *

args = parse_args()
input_files = args.input_files
output_dir = args.output_dir
config = args.config

for measure_table in get_measure_tables(input_files):
    measure_table = drop_zero_denominator_rows(measure_table)
    id_ = measure_table.attrs["id"]
    if config["tables"]["output"]:
        deciles_table = get_deciles_table(measure_table, config)
        fname = f"deciles_table_{id_}.csv"
        write_deciles_table(deciles_table, output_dir, fname)

    if config["charts"]["output"]:
        chart = get_deciles_chart(measure_table, config)
        fname = f"deciles_chart_{id_}.png"
        write_deciles_chart(chart, output_dir, fname)