"""
data_handler.py  -  Day 3: loading, merging and saving the CSV files.

pd.merge() is the Pandas version of a SQL JOIN:
    SQL  : marks JOIN students ON marks.student_id = students.student_id
    Pandas: pd.merge(marks, students, on="student_id", how="inner")
"""
from pathlib import Path
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent
FILES = {
    "departments": "departments.csv",
    "students": "students.csv",
    "subjects": "subjects.csv",
    "marks": "marks.csv",
}


def load_tables(base_dir=BASE_DIR):
    """Read the four CSV files into a dict of DataFrames.
    Raises FileNotFoundError (with the file name) if a file is missing."""
    tables = {}
    for name, filename in FILES.items():
        path = Path(base_dir) / filename
        if not path.exists():
            raise FileNotFoundError(f"Required file not found: {path}")
        tables[name] = pd.read_csv(path)
    return tables


def merge_tables(tables):
    """marks + students + departments + subjects  ==  SQL query (a)."""
    merged = (
        tables["marks"]
        .merge(tables["students"], on="student_id", how="inner")
        .merge(tables["departments"], on="dept_id", how="inner")
        .merge(tables["subjects"], on="subject_id", how="inner")
    )
    columns = ["mark_id", "student_id", "roll_no", "name", "dept_id", "dept_name",
               "semester", "subject_id", "subject_name", "marks"]
    return merged[columns]


def load_data(base_dir=BASE_DIR):
    """Read all CSV files and return (merged_dataframe, tables_dict)."""
    tables = load_tables(base_dir)
    return merge_tables(tables), tables


def save_marks(marks_df, base_dir=BASE_DIR):
    """Write the marks table back to marks.csv."""
    marks_df.to_csv(Path(base_dir) / FILES["marks"], index=False)


def show_overview(tables):
    """Print head(), info() and describe() for each table (Day 3 requirement)."""
    for name, df in tables.items():
        print(f"\n===== {name}.csv =====")
        print(df.head())
        df.info()
        print(df.describe())
