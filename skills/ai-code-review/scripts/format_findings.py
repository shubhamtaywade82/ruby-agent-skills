#!/usr/bin/env python3
"""
format_findings.py — Produces findings.json and a markdown report from a JSON list of findings.

Shared across code-review, pr-diff-review, and repo-audit skills. The schema is identical
so review outputs can be aggregated, compared, and fed to CI/dashboards.

Usage:
    python format_findings.py <findings_input.json> [--output-dir <dir>] [--title "<report title>"]

Input format (findings_input.json):
    [
      {
        "id": "F-001",
        "severity": "P1",
        "classification": "authorization",
        "file": "app/controllers/api/v1/orders_controller.rb",
        "line": 14,
        "title": "Order lookup not scoped to current tenant",
        "scenario": "...",
        "impact": "...",
        "violated_contract": "...",
        "evidence": "...",
        "action": "...",
        "status": "confirmed"
      },
      ...
    ]

Output:
    <output-dir>/findings.json   — the input (validated, sorted by severity)
    <output-dir>/report.md       — markdown report following the canonical template
"""

import argparse
import json
import sys
from pathlib import Path
from datetime import datetime, timezone

VALID_SEVERITIES = ["P0", "P1", "P2", "P3", "Nit"]
VALID_STATUSES = ["confirmed", "hypothesis", "rejected"]
SEVERITY_ORDER = {"P0": 0, "P1": 1, "P2": 2, "P3": 3, "Nit": 4}
SEVERITY_LABELS = {
    "P0": "P0 — Critical",
    "P1": "P1 — High",
    "P2": "P2 — Medium",
    "P3": "P3 — Low",
    "Nit": "Nit / Suggestion",
}


def validate_finding(finding: dict, idx: int) -> list:
    """Returns list of validation errors for a single finding."""
    errors = []
    required = ["id", "severity", "classification", "title", "scenario", "impact", "evidence", "action", "status"]
    for field in required:
        if field not in finding:
            errors.append(f"Finding {idx}: missing required field '{field}'")
    if "severity" in finding and finding["severity"] not in VALID_SEVERITIES:
        errors.append(f"Finding {idx}: invalid severity '{finding['severity']}'. Must be one of {VALID_SEVERITIES}")
    if "status" in finding and finding["status"] not in VALID_STATUSES:
        errors.append(f"Finding {idx}: invalid status '{finding['status']}'. Must be one of {VALID_STATUSES}")
    return errors


def validate_findings(findings: list) -> list:
    """Validates the entire findings list. Returns list of errors."""
    errors = []
    if not isinstance(findings, list):
        return ["Input must be a JSON array of findings."]
    seen_ids = set()
    for idx, finding in enumerate(findings):
        if not isinstance(finding, dict):
            errors.append(f"Entry {idx}: not a JSON object")
            continue
        errors.extend(validate_finding(finding, idx))
        if "id" in finding:
            if finding["id"] in seen_ids:
                errors.append(f"Finding {idx}: duplicate id '{finding['id']}'")
            seen_ids.add(finding["id"])
    return errors


def sort_findings(findings: list) -> list:
    """Sort findings by severity (P0 first), then by id."""
    return sorted(findings, key=lambda f: (SEVERITY_ORDER.get(f.get("severity", "Nit"), 99), f.get("id", "")))


def severity_counts(findings: list) -> dict:
    """Count findings by severity, excluding rejected."""
    counts = {sev: 0 for sev in VALID_SEVERITIES}
    for f in findings:
        if f.get("status") == "rejected":
            continue
        sev = f.get("severity", "Nit")
        counts[sev] = counts.get(sev, 0) + 1
    return counts


def render_markdown(findings: list, title: str, metadata: dict) -> str:
    """Render the markdown report."""
    sorted_findings = sort_findings(findings)
    confirmed = [f for f in sorted_findings if f.get("status") == "confirmed"]
    hypotheses = [f for f in sorted_findings if f.get("status") == "hypothesis"]
    rejected = [f for f in sorted_findings if f.get("status") == "rejected"]
    counts = severity_counts(findings)

    lines = [f"# {title}", "", f"_Generated: {datetime.now(timezone.utc).isoformat()}_", "", "## Executive summary", ""]
    scope = metadata.get("scope", "the reviewed code")
    lines.extend([f"Reviewed: **{scope}**.", ""])
    if not confirmed and not hypotheses:
        lines.append("**No confirmed findings.** The review did not identify defects that survived adjudication. See Remaining Uncertainty for areas that could not be verified.")
    else:
        lines.append(f"**{len(confirmed)} confirmed finding(s)**, **{len(hypotheses)} hypothesis(es)** pending evidence.")
    lines.extend(["", "Findings by severity:", "", "| Severity | Count |", "| --- | --- |"])
    lines.extend(f"| {SEVERITY_LABELS[sev]} | {counts.get(sev, 0)} |" for sev in VALID_SEVERITIES)
    lines.extend(["", "## Standards assessment", "", metadata.get("standards_assessment", "_Standards assessment not provided._"), "", "## Specification assessment", "", metadata.get("specification_assessment", "_Specification assessment not provided. If no specification was found, state so explicitly._"), "", "## Findings", ""])
    if not confirmed and not hypotheses:
        lines.append("No findings survived adjudication.")
    else:
        lines.extend(["| ID | Severity | Classification | File:Line | Title | Status |", "| --- | --- | --- | --- | --- | --- |"])
        for f in confirmed + hypotheses:
            loc = f.get("file", "")
            if f.get("line"):
                loc = f"{loc}:{f['line']}"
            lines.append(f"| {f.get('id', '?')} | {f.get('severity', '?')} | {f.get('classification', '?')} | {loc or '—'} | {f.get('title', '?')} | {f.get('status', '?')} |")
        lines.append("")
        for f in confirmed + hypotheses:
            loc = f.get("file", "")
            if f.get("line"):
                loc = f"{loc}:{f['line']}"
            lines.extend([f"### {f.get('id', '?')}: {f.get('title', '?')}", "", f"- **Severity:** {SEVERITY_LABELS.get(f.get('severity', 'Nit'), f.get('severity', '?'))}", f"- **Classification:** {f.get('classification', '?')}", f"- **Location:** `{loc or '—'}`", f"- **Status:** {f.get('status', '?')}", "", f"**Scenario:** {f.get('scenario', '_not provided_')}", "", f"**Impact:** {f.get('impact', '_not provided_')}", "", f"**Violated contract:** {f.get('violated_contract', '_not provided_')}", "", f"**Evidence:** {f.get('evidence', '_not provided_')}", "", f"**Action:** {f.get('action', '_not provided_')}", ""])
    lines.extend(["## Remaining uncertainty", ""])
    uncertainty = metadata.get("remaining_uncertainty")
    if isinstance(uncertainty, list):
        lines.extend(f"- {item}" for item in uncertainty)
    elif uncertainty:
        lines.append(str(uncertainty))
    else:
        lines.append("_No remaining uncertainty reported. List checks not run, areas not inspected, and assumptions made._")
    lines.extend(["", "## Commands executed", ""])
    commands = metadata.get("commands_executed")
    if isinstance(commands, list):
        for cmd in commands:
            if isinstance(cmd, dict):
                lines.extend([f"**`{cmd.get('command', '?')}`**", "```", str(cmd.get("output", "_no output captured_")), "```", ""])
            else:
                lines.append(f"- `{cmd}`")
    elif commands:
        lines.append(str(commands))
    else:
        lines.append("_No commands executed during this review._")
    if rejected:
        lines.extend(["", "## Adjudication notes", "", "Rejected findings (investigated and refuted):", ""])
        for f in rejected:
            lines.extend([f"- **{f.get('id', '?')}** ({f.get('severity', '?')}, {f.get('classification', '?')}): {f.get('title', '?')}", f"  - Reason: {f.get('evidence', '_not provided_')}"])
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description="Validate and format review findings as JSON and Markdown.")
    parser.add_argument("findings_input", help="Path to JSON array of findings")
    parser.add_argument("--output-dir", default=".", help="Output directory for findings.json and report.md")
    parser.add_argument("--title", default="Code Review Report")
    parser.add_argument("--metadata", default=None, help="Optional JSON metadata file")
    args = parser.parse_args()
    input_path = Path(args.findings_input)
    if not input_path.is_file():
        parser.error(f"input file not found: {input_path}")
    try:
        findings = json.loads(input_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        parser.error(f"cannot read valid JSON: {exc}")
    errors = validate_findings(findings)
    if errors:
        print("Validation errors:\n" + "\n".join(f"  - {e}" for e in errors), file=sys.stderr)
        raise SystemExit(1)
    metadata = {}
    if args.metadata:
        meta_path = Path(args.metadata)
        try:
            metadata = json.loads(meta_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            parser.error(f"cannot read valid metadata JSON: {exc}")
        if not isinstance(metadata, dict):
            parser.error("metadata JSON must be an object")
    out = Path(args.output_dir)
    out.mkdir(parents=True, exist_ok=True)
    sorted_findings = sort_findings(findings)
    payload = {"title": args.title, "generated_at": datetime.now(timezone.utc).isoformat(), "findings": sorted_findings, "metadata": metadata}
    (out / "findings.json").write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    (out / "report.md").write_text(render_markdown(sorted_findings, args.title, metadata), encoding="utf-8")
    counts = severity_counts(findings)
    print(f"Wrote {out / 'findings.json'}")
    print(f"Wrote {out / 'report.md'}")
    print(f"Findings: {len(findings)} total; {sum(f.get('status') == 'confirmed' for f in findings)} confirmed, {sum(f.get('status') == 'hypothesis' for f in findings)} hypothesis, {sum(f.get('status') == 'rejected' for f in findings)} rejected")
    print(f"Severity breakdown: {counts}")


if __name__ == "__main__":
    main()
