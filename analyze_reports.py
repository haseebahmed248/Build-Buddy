import json
import os
from datetime import datetime
from typing import Dict, List, Optional
from dataclasses import dataclass

@dataclass
class MetricsAnalysis:
    total_files: int
    total_lines: int
    high_complexity_files: int
    avg_complexity: float
    files_by_complexity: Dict[str, int]

@dataclass
class IssueAnalysis:
    total_count: int
    issues_by_type: Dict[str, int]
    issues_by_file: Dict[str, List[str]]

class FlutterProjectAnalyzer:
    def __init__(self, json_dir: str):
        self.json_dir = json_dir
        self.metrics_file = os.path.join(json_dir, "metrics.json")
        self.antipatterns_file = os.path.join(json_dir, "antipatterns.json")
        self.smells_file = os.path.join(json_dir, "smells.json")
        self.duplications_file = os.path.join(json_dir, "duplications.json")

    def read_json_file(self, file_path: str) -> Optional[dict]:
        try:
            with open(file_path, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Error reading {file_path}: {str(e)}")
            return None

    def analyze_metrics(self) -> MetricsAnalysis:
        data = self.read_json_file(self.metrics_file)
        if not data:
            return MetricsAnalysis(0, 0, 0, 0.0, {})

        total_files = len(data)
        total_lines = sum(file.get('numberOfLines', 0) for file in data)

        # Complexity analysis
        complexity_counts = {"0-10": 0, "11-20": 0, "21-30": 0, "31+": 0}
        total_complexity = 0
        high_complexity = 0

        for file in data:
            max_complexity = max(
                (func.get('cyclomatic-complexity', 0) for func in file.get('functions', [])),
                default=0
            )
            total_complexity += max_complexity

            if max_complexity > 20:
                high_complexity += 1

            if max_complexity <= 10:
                complexity_counts["0-10"] += 1
            elif max_complexity <= 20:
                complexity_counts["11-20"] += 1
            elif max_complexity <= 30:
                complexity_counts["21-30"] += 1
            else:
                complexity_counts["31+"] += 1

        avg_complexity = total_complexity / total_files if total_files > 0 else 0

        return MetricsAnalysis(
            total_files=total_files,
            total_lines=total_lines,
            high_complexity_files=high_complexity,
            avg_complexity=avg_complexity,
            files_by_complexity=complexity_counts
        )

    def analyze_issues(self, file_path: str) -> IssueAnalysis:
        data = self.read_json_file(file_path)
        if not data:
            return IssueAnalysis(0, {}, {})

        total_count = 0
        issues_by_type = {}
        issues_by_file = {}

        for file_entry in data:
            file_name = file_entry.get('filePath', 'unknown')
            issues = file_entry.get('issues', [])
            issues_by_file[file_name] = []

            for issue in issues:
                rule_id = issue.get('ruleId', 'Unknown')
                issues_by_type[rule_id] = issues_by_type.get(rule_id, 0) + 1
                issues_by_file[file_name].append(rule_id)
                total_count += 1

        return IssueAnalysis(total_count, issues_by_type, issues_by_file)

    def analyze_duplications(self) -> Dict:
        data = self.read_json_file(self.duplications_file)
        if not data:
            return {"total_instances": 0, "total_lines": 0, "avg_length": 0}

        total_instances = len(data)
        total_lines = sum(dup.get('length', 0) for dup in data)
        avg_length = total_lines / total_instances if total_instances > 0 else 0

        return {
            "total_instances": total_instances,
            "total_lines": int(total_lines),
            "avg_length": round(avg_length, 2)
        }

    def generate_report(self) -> str:
        metrics = self.analyze_metrics()
        antipatterns = self.analyze_issues(self.antipatterns_file)
        smells = self.analyze_issues(self.smells_file)
        duplications = self.analyze_duplications()

        report = []
        report.append("# Flutter Project Analysis Summary Report")
        report.append(f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

        # Metrics Section
        report.append("## Project Metrics")
        report.append(f"- Total Files Analyzed: {metrics.total_files}")
        report.append(f"- Total Lines of Code: {metrics.total_lines}")
        report.append(f"- Average Cyclomatic Complexity: {metrics.avg_complexity:.2f}")
        report.append("\nComplexity Distribution:")
        for range_name, count in metrics.files_by_complexity.items():
            report.append(f"- {range_name}: {count} files")
        report.append("")

        # Anti-patterns Section
        report.append("## Anti-patterns Analysis")
        report.append(f"- Total Anti-patterns Found: {antipatterns.total_count}")
        report.append("\nBreakdown by Type:")
        for pattern, count in sorted(antipatterns.issues_by_type.items()):
            report.append(f"- {pattern}: {count}")
        report.append("")

        # Code Smells Section
        report.append("## Code Smells Analysis")
        report.append(f"- Total Code Smells Found: {smells.total_count}")
        report.append("\nBreakdown by Type:")
        for smell, count in sorted(smells.issues_by_type.items()):
            report.append(f"- {smell}: {count}")
        report.append("")

        # Duplications Section
        report.append("## Code Duplications")
        report.append(f"- Total Duplication Instances: {duplications['total_instances']}")
        report.append(f"- Total Duplicated Lines: {duplications['total_lines']}")
        report.append(f"- Average Duplication Length: {duplications['avg_length']} lines")

        return "\n".join(report)

    def save_report(self, output_dir: str = "reports"):
        os.makedirs(output_dir, exist_ok=True)
        report_content = self.generate_report()
        report_path = os.path.join(output_dir, "summary_report.md")

        with open(report_path, 'w') as f:
            f.write(report_content)

        print(f"Report saved to: {report_path}")

def main():
    analyzer = FlutterProjectAnalyzer("reports/json")
    analyzer.save_report()

if __name__ == "__main__":
    main()