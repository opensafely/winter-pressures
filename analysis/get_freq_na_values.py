import pandas

from analysis.utils import OUTPUT_DIR


def read_cols(f_path, prefix):
    """
    Reads columns with the given prefix from the data frame at the given file path.
    """
    dataframe = pandas.read_feather(f_path)
    dataframe = dataframe.loc[:, (x for x in dataframe.columns if x.startswith(prefix))]
    return dataframe


def get_freq_na_values(dataframe, normalize=False):
    """
    Gets the frequency distribution of the count of NA values per row in the given data
    frame.
    """
    freq = dataframe.isna().sum(axis=1).value_counts(normalize=normalize, sort=False)
    freq.name = "freq_na_values"
    freq.index.name = "count"
    return freq


def write(dataframe, f_path):
    """
    Writes the given data frame to the given file path.
    """
    dataframe.to_csv(f_path)


def main():
    booked_dates = read_cols(OUTPUT_DIR / "dataset_wide.arrow", "booked_date_")
    freq_na_values = get_freq_na_values(booked_dates)
    write(freq_na_values, OUTPUT_DIR / "freq_na_values.csv")


if __name__ == "__main__":
    main()
