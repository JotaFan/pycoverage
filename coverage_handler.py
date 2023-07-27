import json
from pathlib import Path
import os
import sys
from typing import List

COVERAGE_FILE_PATH = "./coverage.json"
COVERAGE_SINGLE_THRESHOLD = float(os.environ.get("COVERAGE_SINGLE_THRESHOLD", 0))
COVERAGE_TOTAL_THRESHOLD = float(os.environ.get("COVERAGE_TOTAL_THRESHOLD", 0))
COV_THRESHOLD_SINGLE_FAIL = False
COV_THRESHOLD_TOTAL_FAIL = False
COV_BADGE_FILE_PATH = os.environ.get("COV_BADGE_FILE_PATH", "docs/badges/coverage.svg")


def sort_lines_not_covered(lines_not_covered: List[int]) -> str:
    if not lines_not_covered:  # handle empty list
        return ""
    lines: List[int] = []
    lines_str = ""
    for i in range(len(lines_not_covered)):
        if lines and lines[-1] != lines_not_covered[i] - 1:
            lines_str += f"{lines[0]}-{lines[-1]} " if lines[0] != lines[-1] else f"{lines[0]} "
            lines = []
        lines.append(lines_not_covered[i])
    # handle the last range or number
    lines_str += f"{lines[0]}-{lines[-1]} " if lines[0] != lines[-1] else f"{lines[0]} "
    return lines_str.strip()


def main():
    global COV_THRESHOLD_SINGLE_FAIL, COV_THRESHOLD_TOTAL_FAIL

    os.makedirs(os.path.dirname(COV_BADGE_FILE_PATH), exist_ok=True)

    coverage_file = Path(COVERAGE_FILE_PATH)
    with coverage_file.open("r") as file:
        data = json.load(file)
    output = list()

    total_coverage = round(data["totals"]["percent_covered"], 2)
    color = "red"

    if 50 >= total_coverage > 20:
        color = "orange"
    elif 70 >= total_coverage > 50:
        color = "yellow"
    elif 90 >= total_coverage > 70:
        color = "green"
    elif 100 >= total_coverage > 90:
        color = "brightgreen"

    output.append(
        f"![pycoverage](https://img.shields.io/static/v1?"
        f"label=pycoverage🛡️&message={total_coverage}%&color={color})"
    )
    output.append("|Name|Stmts|Miss|Cover|Missing|")
    output.append("| ------ | ------ | ------ | ------ |------ |")

    for file_path, file_data in data.get("files", dict()).items():
        file_summary = file_data["summary"]
        num_statements = file_summary["num_statements"]
        missing_lines = file_summary["missing_lines"]
        lines_not_covered = file_data["missing_lines"]
        if isinstance(lines_not_covered, list):
            lines_not_covered = sort_lines_not_covered(lines_not_covered)
        percent_covered = round(file_summary["percent_covered"], 2)
        if percent_covered < COVERAGE_SINGLE_THRESHOLD:
            COV_THRESHOLD_SINGLE_FAIL = True
        output.append(
            f"|{file_path}|{num_statements}|{missing_lines}|{percent_covered}%|{lines_not_covered}"
        )

    totals = data["totals"]

    output.append(f'|TOTAL|{totals["num_statements"]}|{totals["missing_lines"]}|{total_coverage}%|')

    print(*output, sep="\n")

    if round(totals["percent_covered"], 2) < COVERAGE_TOTAL_THRESHOLD:
        COV_THRESHOLD_TOTAL_FAIL = True

    if COV_THRESHOLD_SINGLE_FAIL:
        sys.exit(101)
    if COV_THRESHOLD_TOTAL_FAIL:
        sys.exit(102)


if __name__ == "__main__":
    main()
