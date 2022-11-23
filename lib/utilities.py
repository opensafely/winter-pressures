import re
import os
from pathlib import Path

backend = os.getenv("OPENSAFELY_BACKEND", "expectations")

BASE_DIR = Path(__file__).parents[1]
OUTPUT_DIR = BASE_DIR / "output"
ANALYSIS_DIR = BASE_DIR / "analysis"

def match_wide_input_files(file: str) -> bool:
    """Checks if file name has format outputted by cohort extractor"""
    pattern = r"^input_20\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])\.csv"
    return True if re.match(pattern, file) else False

def match_long_input_files(file: str) -> bool:
    """Checks if file name has format outputted by cohort extractor"""
    pattern = r"^input_long_20\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])\.csv"
    return True if re.match(pattern, file) else False

def match_input_files_by_tag(file: str, tag: str) -> bool:
    """Checks if file name has format outputted by cohort extractor"""
    pattern = r"^input_" + tag + "_20\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])\.csv"
    return True if re.match(pattern, file) else False

def get_date_input_file(file: str) -> str:
    """Gets the date in format YYYY-MM-DD from input file name string"""
    # check format
    if not match_wide_input_files(file):
        raise Exception("Not valid input file format")

    else:
        date = result = re.search(r"input_(.*)\.csv", file)
        return date.group(1)

def validate_directory(dirpath):
    if not dirpath.is_dir():
        raise ValueError(f"Not a directory")
