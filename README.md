# Student Performance Analytics System

coe batch 4  Project - **Python, NumPy, Pandas, Matplotlib, MySQL**

A college database of students, departments, subjects and marks.
**Part A** designs and queries it in MySQL. **Part B** analyses the same data from CSV files with
NumPy and Pandas, draws Matplotlib charts, and wraps everything in a menu-driven program.
Python never connects to MySQL - data moves between them through CSV files.

## Project structure

```
project.sql                 Part A: schema, data, stored functions, JOIN queries, constraint tests
departments.csv  students.csv  subjects.csv  marks.csv     data exported from MySQL
main.py                     Part B: menu-driven program (entry point)
data_handler.py             load_data(), save_marks(), pd.merge of the 4 tables
analysis.py                 cleaning, NumPy stats, pivot, grade, rank, groupby
charts.py                   4 Matplotlib charts
charts/                     the 4 PNG charts
student_report.csv          exported student report
Report.pdf                  project report
Presentation.pptx           demo slides
docs/ER_diagram.png         ER diagram
docs/Viva_QA.md             likely viva questions with answers
tools/                      helper scripts (data generator, ER diagram, report/slide builders)
```

## How to run

### 1. MySQL (Part A) - needs MySQL 8.0.16 or newer
```bash
mysql -u root -p < project.sql
```
(or open `project.sql` in MySQL Workbench and run all). It creates the database `student_analytics`,
inserts 5 departments, 6 subjects, 30 students and 180 marks, creates the functions
`get_grade`, `get_percentage`, `get_result`, and runs the five JOIN queries.
The constraint tests at the end are commented out - run them one at a time.

### 2. Export the CSVs (optional)
The four CSV files are already included. To re-export: in Workbench run `SELECT * FROM <table>`,
then *Result Grid -> Export*, and save as `departments.csv`, `students.csv`, `subjects.csv`, `marks.csv`
next to `main.py`.

### 3. Python (Part B) - Python 3.9+
```bash
pip install -r requirements.txt
python main.py            # menu program
python main.py --batch    # no menu: regenerate charts/ and student_report.csv
```

Menu: 1 Add/update marks - 2 View student report - 3 Topper list - 4 Analysis - 5 Charts - 6 Export report - 0 Exit

## Design notes
- **Grades:** A+ >= 90, A >= 80, B+ >= 70, B >= 60, C >= 50, D >= 40, F < 40 (same scale in SQL and Python).
- **PASS/FAIL:** a student passes only if every subject is >= 40.
- **Check:** Pandas department averages equal SQL query (e): CSE 68.96, Electronics 66.31, Civil 65.19,
  Mechanical 64.07. Biotechnology has no students, so the LEFT JOIN shows NULL (NaN in Pandas).
- `tools/generate_data.py` (seed fixed) creates the CSVs and the INSERT statements together, so both parts always agree.
