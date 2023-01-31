import time

import pandas

from analysis.utils import APPOINTMENTS_OUTPUT_DIR as OUTPUT_DIR


def main():
    path_in = OUTPUT_DIR / "dataset_long.csv"
    path_out = OUTPUT_DIR / "read_csv.log"

    with path_out.open("w", encoding="utf-8") as f_out:
        time_start = time.time()

        f_out.write(f"Reading {path_in}\n")
        dataset_long = pandas.read_csv(path_in)
        f_out.write(f"Read in {time.time() - time_start} sec\n")

        memory_usage_b = dataset_long.memory_usage(deep=True).sum()
        memory_usage_mb = memory_usage_b / 1_000**2
        f_out.write(f"Consumes {memory_usage_mb} MB of memory\n")


if __name__ == "__main__":
    main()
