"""
main.py  -  Day 6: menu-driven Student Performance Analytics program.

Run:   python main.py            (interactive menu)
       python main.py --batch    (no menu: makes charts/ and student_report.csv, for testing)
Works only on the CSV files (no database connection needed).
"""
import sys
import pandas as pd

import analysis as an
import charts
import data_handler as dh

REPORT_FILE = dh.BASE_DIR / "student_report.csv"


# ----------------------------------------------------------------- input helpers
def read_int(prompt, low=None, high=None):
    """Keep asking until the user types a whole number inside [low, high]."""
    while True:
        text = input(prompt).strip()
        try:
            value = int(text)
        except ValueError:
            print("  Please enter numbers only.")
            continue
        if (low is not None and value < low) or (high is not None and value > high):
            print(f"  Value must be between {low} and {high}.")
            continue
        return value


def read_marks(prompt):
    """Marks must be a number from 0 to 100 (decimals allowed)."""
    while True:
        try:
            value = float(input(prompt).strip())
        except ValueError:
            print("  Please enter a number.")
            continue
        if 0 <= value <= 100:
            return value
        print("  Marks must be between 0 and 100.")


def read_existing_id(prompt, table, column, label):
    """Ask for an id and make sure it exists in the given table."""
    while True:
        value = read_int(prompt)
        if value in table[column].values:
            return value
        print(f"  {label} {value} does not exist. Try again.")


# ----------------------------------------------------------------- state
def refresh(state):
    """(Re)load CSVs and rebuild the cleaned data + report after any change."""
    merged, tables = dh.load_data()
    state["tables"] = tables
    state["df"] = an.clean_data(merged)
    state["report"] = an.build_student_report(state["df"])


# ----------------------------------------------------------------- menu actions
def add_or_update_marks(state):
    tables = state["tables"]
    print(tables["students"][["student_id", "roll_no", "name"]].to_string(index=False))
    student_id = read_existing_id("Student ID: ", tables["students"], "student_id", "Student")
    print(tables["subjects"][["subject_id", "subject_name"]].to_string(index=False))
    subject_id = read_existing_id("Subject ID: ", tables["subjects"], "subject_id", "Subject")
    value = read_marks("Marks (0-100): ")

    marks = tables["marks"].copy()
    row = (marks["student_id"] == student_id) & (marks["subject_id"] == subject_id)
    if row.any():
        marks.loc[row, "marks"] = value
        print("Existing entry updated.")
    else:
        new_id = int(marks["mark_id"].max()) + 1 if len(marks) else 1
        marks.loc[len(marks)] = [new_id, student_id, subject_id, value]
        print("New entry added.")
    dh.save_marks(marks)
    refresh(state)


def view_student_report(state):
    report = state["report"]
    student_id = read_existing_id("Student ID: ", state["tables"]["students"], "student_id", "Student")
    row = report[report["student_id"] == student_id].iloc[0]
    print(f"\n{row['name']} ({row['roll_no']}) - {row['dept_name']}, Semester {row['semester']}")
    marks = state["df"][state["df"]["student_id"] == student_id][["subject_name", "marks"]]
    print(marks.to_string(index=False))
    print(f"Total: {row['total']:.0f}   Percentage: {row['percentage']}%   "
          f"Grade: {row['grade']}   Result: {row['status']}   Rank: {row['rank']}")


def show_toppers(state):
    print("\nTop 5 students overall:")
    print(an.top_students(state["report"]).to_string(index=False))
    print("\nDepartment-wise toppers:")
    print(an.department_toppers(state["report"]).to_string(index=False))


def show_analysis(state):
    df, report = state["df"], state["report"]
    print("\nSubject statistics (NumPy):")
    print(an.subject_stats_numpy(df).to_string(index=False))
    print("\nPass / Fail count:")
    print(an.pass_fail_counts(report).to_string())
    print("\nDepartment-wise average (same as SQL query e):")
    print(an.department_average(df, state["tables"]["departments"]).to_string(index=False))
    risk = an.at_risk_students(report)
    print(f"\nAt-risk students (below 50% or failed a subject): {len(risk)}")
    print(risk.to_string(index=False))


def show_charts(state):
    try:
        files = charts.make_all_charts(state["df"], state["report"], show=True)
        print("Charts saved in the charts/ folder:", ", ".join(files))
    except Exception as err:  # e.g. no display available
        print(f"Could not open chart windows ({err}). Saving PNG files only.")
        charts.make_all_charts(state["df"], state["report"], show=False)


def export_report(state):
    try:
        state["report"].to_csv(REPORT_FILE, index=False)
        print(f"Report exported to {REPORT_FILE.name}")
    except PermissionError:
        print("Cannot write the file. Close it in Excel and try again.")


MENU = """
===== Student Performance Analytics =====
1) Add / update marks
2) View student report
3) Show topper list
4) Show analysis
5) Show charts
6) Export report to CSV
0) Exit"""

ACTIONS = {1: add_or_update_marks, 2: view_student_report, 3: show_toppers,
           4: show_analysis, 5: show_charts, 6: export_report}


def main():
    state = {}
    try:
        refresh(state)
    except FileNotFoundError as err:
        print(err)
        print("Run the SQL file, export the four CSV files and keep them next to main.py.")
        return
    except (pd.errors.EmptyDataError, pd.errors.ParserError, KeyError) as err:
        print(f"A CSV file is empty or damaged: {err}")
        return

    if "--batch" in sys.argv:
        print("Charts:", charts.make_all_charts(state["df"], state["report"]))
        export_report(state)
        return

    while True:
        print(MENU)
        choice = read_int("Choose an option: ", 0, 6)
        if choice == 0:
            print("Goodbye!")
            break
        try:
            ACTIONS[choice](state)
        except FileNotFoundError as err:
            print(f"File problem: {err}")
        except PermissionError:
            print("File is open in another program. Close it and try again.")


if __name__ == "__main__":
    main()
