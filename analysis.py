"""
analysis.py  -  Day 4: cleaning and analysis with Pandas and NumPy.
"""
import numpy as np
import pandas as pd

PASS_MARK = 40
GRADE_ORDER = ["A+", "A", "B+", "B", "C", "D", "F"]


def clean_data(df):
    """Remove duplicates, convert marks to numbers, fill missing marks with the subject mean."""
    df = df.drop_duplicates(subset=["student_id", "subject_id"]).copy()
    df["marks"] = pd.to_numeric(df["marks"], errors="coerce")
    df["marks"] = df["marks"].fillna(df.groupby("subject_name")["marks"].transform("mean"))
    return df


def subject_stats_numpy(df):
    """Mean, median and standard deviation of marks per subject, computed with NumPy."""
    rows = []
    for subject, group in df.groupby("subject_name"):
        arr = group["marks"].to_numpy()
        rows.append({
            "subject": subject,
            "mean": round(float(np.mean(arr)), 2),
            "median": round(float(np.median(arr)), 2),
            "std_dev": round(float(np.std(arr)), 2),
        })
    return pd.DataFrame(rows).sort_values("mean", ascending=False).reset_index(drop=True)


def make_pivot(df):
    """One row per student, one column per subject."""
    return df.pivot_table(index="student_id", columns="subject_name", values="marks")


def assign_grade(percentage):
    """Vectorised grade (same scale as the MySQL get_grade function)."""
    conditions = [percentage >= 90, percentage >= 80, percentage >= 70,
                  percentage >= 60, percentage >= 50, percentage >= PASS_MARK]
    return np.select(conditions, ["A+", "A", "B+", "B", "C", "D"], default="F")


def build_student_report(df):
    """Total, percentage, grade, PASS/FAIL and rank for every student."""
    pivot = make_pivot(df)
    subject_cols = list(pivot.columns)
    info = df[["student_id", "roll_no", "name", "dept_name", "semester"]].drop_duplicates("student_id")
    report = info.set_index("student_id").join(pivot)
    report["total"] = report[subject_cols].sum(axis=1)
    report["percentage"] = (report["total"] / (len(subject_cols) * 100) * 100).round(2)
    report["grade"] = assign_grade(report["percentage"].to_numpy())
    # PASS only if no subject is below the pass mark (same rule as get_result in SQL)
    report["status"] = np.where((report[subject_cols] < PASS_MARK).any(axis=1), "FAIL", "PASS")
    report["rank"] = report["total"].rank(method="min", ascending=False).astype(int)
    return report.sort_values("rank").reset_index()


def top_students(report, n=5):
    return report.head(n)[["rank", "roll_no", "name", "dept_name", "total", "percentage", "grade"]]


def pass_fail_counts(report):
    return report["status"].value_counts()


def department_average(df, departments):
    """Department-wise average with groupby.
    The LEFT merge keeps departments without students (NaN), exactly like SQL query (e)."""
    avg = df.groupby("dept_id")["marks"].mean().round(2).rename("avg_marks")
    counts = df.groupby("dept_id")["student_id"].nunique().rename("students")
    out = departments[["dept_id", "dept_name"]].merge(avg, on="dept_id", how="left") \
                                              .merge(counts, on="dept_id", how="left")
    out["students"] = out["students"].fillna(0).astype(int)
    return out.sort_values("avg_marks", ascending=False).drop(columns="dept_id").reset_index(drop=True)


def department_toppers(report):
    idx = report.groupby("dept_name")["total"].idxmax()
    return report.loc[idx, ["dept_name", "name", "total"]].sort_values("dept_name").reset_index(drop=True)


def at_risk_students(report):
    """Bonus: below 50% OR failed in at least one subject."""
    mask = (report["percentage"] < 50) | (report["status"] == "FAIL")
    return report.loc[mask, ["roll_no", "name", "dept_name", "percentage", "status"]]


def grade_distribution(report):
    return report["grade"].value_counts().reindex(GRADE_ORDER).dropna().astype(int)
