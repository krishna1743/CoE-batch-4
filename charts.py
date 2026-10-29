"""
charts.py  -  Day 5: four Matplotlib charts, each with title, axis labels, saved as PNG.
"""
from pathlib import Path
import matplotlib
import matplotlib.pyplot as plt
from analysis import PASS_MARK, grade_distribution

CHART_DIR = Path(__file__).resolve().parent / "charts"


def _finish(fig, filename, show):
    CHART_DIR.mkdir(exist_ok=True)
    fig.tight_layout()
    fig.savefig(CHART_DIR / filename, dpi=150)
    if show:
        plt.show()
    plt.close(fig)


def bar_subject_average(df, show=False):
    avg = df.groupby("subject_name")["marks"].mean().sort_values(ascending=False)
    fig, ax = plt.subplots(figsize=(9, 5))
    bars = ax.bar(avg.index, avg.values, color="#2E6FD8")
    ax.bar_label(bars, fmt="%.1f", padding=3)
    ax.set_title("Average Marks per Subject")
    ax.set_xlabel("Subject")
    ax.set_ylabel("Average marks (out of 100)")
    ax.set_ylim(0, 100)
    plt.setp(ax.get_xticklabels(), rotation=20, ha="right")
    _finish(fig, "1_avg_marks_per_subject.png", show)


def pie_grades(report, show=False):
    counts = grade_distribution(report)
    fig, ax = plt.subplots(figsize=(6.5, 6.5))
    ax.pie(counts.values, labels=counts.index, autopct="%1.0f%%", startangle=90,
           colors=plt.cm.Blues_r([i / (len(counts) + 1) for i in range(len(counts))]),
           wedgeprops={"edgecolor": "white"})
    ax.set_title("Grade Distribution of Students")
    _finish(fig, "2_grade_distribution.png", show)


def histogram_marks(df, show=False):
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.hist(df["marks"], bins=range(10, 101, 10), color="#2E6FD8", edgecolor="white")
    ax.axvline(PASS_MARK, color="red", linestyle="--", linewidth=2, label=f"Pass mark = {PASS_MARK}")
    ax.set_title("Distribution of All Marks")
    ax.set_xlabel("Marks")
    ax.set_ylabel("Number of mark entries")
    ax.legend()
    _finish(fig, "3_marks_histogram.png", show)


def box_department_percentage(report, show=False):
    groups = [g["percentage"].to_numpy() for _, g in report.groupby("dept_name")]
    labels = [name for name, _ in report.groupby("dept_name")]
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.boxplot(groups, patch_artist=True,
               boxprops={"facecolor": "#BBD3F7"}, medianprops={"color": "#C0392B"})
    ax.set_xticklabels(labels)
    ax.set_title("Percentage by Department")
    ax.set_xlabel("Department")
    ax.set_ylabel("Percentage (%)")
    _finish(fig, "4_percentage_by_department.png", show)


def make_all_charts(df, report, show=False):
    """Create and save all four charts. show=True also opens each chart window."""
    if not show:
        matplotlib.use("Agg")
    bar_subject_average(df, show)
    pie_grades(report, show)
    histogram_marks(df, show)
    box_department_percentage(report, show)
    return sorted(p.name for p in CHART_DIR.glob("*.png"))
