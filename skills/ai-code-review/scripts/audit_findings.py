#!/usr/bin/env python3
"""Validate and aggregate repository-audit findings into findings.json and report.md."""

import argparse
import json
import sys
from pathlib import Path
from datetime import datetime, timezone

sys.path.insert(0, str(Path(__file__).resolve().parent))
from format_findings import (  # noqa: E402
    VALID_SEVERITIES,
    VALID_STATUSES,
    SEVERITY_ORDER,
    SEVERITY_LABELS,
    validate_finding,
    sort_findings,
    severity_counts,
)

def validate_audit_finding(item, index):
    errors = validate_finding(item, index)
    if "zone" not in item or not isinstance(item.get("zone"), str) or not item["zone"].strip():
        errors.append(f"Finding {index}: non-empty 'zone' is required")
    if "systemic" in item and not isinstance(item["systemic"], bool):
        errors.append(f"Finding {index}: 'systemic' must be boolean")
    if "instances" in item and not isinstance(item["instances"], list):
        errors.append(f"Finding {index}: 'instances' must be a list")
    if item.get("systemic") is True and len(item.get("instances", [])) < 3:
        errors.append(f"Finding {index}: systemic findings require at least three concrete instances")
    return errors

def render_report(findings, title, metadata):
    confirmed = [f for f in findings if f.get("status") == "confirmed"]
    hypotheses = [f for f in findings if f.get("status") == "hypothesis"]
    rejected = [f for f in findings if f.get("status") == "rejected"]
    counts = severity_counts(findings)
    lines = [f"# {title}", "", f"_Generated: {datetime.now(timezone.utc).isoformat()}_", "",
             "## Executive summary", "",
             f"Confirmed findings: **{len(confirmed)}**; hypotheses: **{len(hypotheses)}**.", "",
             "## Risk-zone coverage", ""]
    for zone in metadata.get("zones_audited", []):
        lines.append(f"- {zone}")
    lines.extend(["", "## Findings by zone", ""])
    zones = sorted({str(f.get("zone", "Uncategorized")) for f in findings})
    for zone in zones:
        lines.extend([f"### {zone}", ""])
        for f in findings:
            if f.get("zone") != zone or f.get("status") == "rejected":
                continue
            instances = f.get("instances", [])
            lines.extend([
                f"#### {f.get('id', '?')} [{f.get('severity', '?')}] {f.get('title', '?')}", "",
                f"- Status: {f.get('status', '?')}",
                f"- Systemic: {'yes' if f.get('systemic') else 'no'}",
                f"- Instances: {', '.join(str(x) for x in instances) if instances else 'not provided'}",
                f"- Scenario: {f.get('scenario', '_not provided_')}",
                f"- Impact: {f.get('impact', '_not provided_')}",
                f"- Evidence: {f.get('evidence', '_not provided_')}",
                f"- Action: {f.get('action', '_not provided_')}", ""
            ])
    lines.extend(["## Cross-cutting concerns", ""])
    concerns = metadata.get("cross_cutting_concerns", [])
    lines.extend([f"- {x}" for x in concerns] if isinstance(concerns, list) else [str(concerns)])
    lines.extend(["", "## Prioritized remediation", ""])
    for f in confirmed:
        suffix = f" ({len(f.get('instances', []))} instances)" if f.get("systemic") else ""
        lines.append(f"- **{f.get('id', '?')} [{f.get('severity', '?')}]** {f.get('title', '?')}{suffix}")
    lines.extend(["", "## Severity counts", ""])
    lines.extend(f"- {SEVERITY_LABELS[sev]}: {counts.get(sev, 0)}" for sev in VALID_SEVERITIES)
    lines.extend(["", "## Remaining uncertainty", ""])
    uncertainty = metadata.get("remaining_uncertainty", [])
    lines.extend([f"- {x}" for x in uncertainty] if isinstance(uncertainty, list) else [str(uncertainty or "Not reported.")])
    lines.extend(["", "## Commands executed", ""])
    commands = metadata.get("commands_executed", [])
    lines.extend([f"- {x}" for x in commands] if isinstance(commands, list) else [str(commands or "Not reported.")])
    if rejected:
        lines.extend(["", "## Rejected candidates", ""])
        lines.extend(f"- {f.get('id', '?')}: {f.get('title', '?')} — {f.get('evidence', 'reason not provided')}" for f in rejected)
    return "\n".join(lines) + "\n"

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("findings_input", help="JSON array of audit findings")
    parser.add_argument("--output-dir", default=".")
    parser.add_argument("--title", default="Repository Audit Report")
    parser.add_argument("--metadata", default=None, help="Optional JSON metadata")
    parser.add_argument("--inventory", default=None, help="Optional repository inventory text file")
    args = parser.parse_args()
    source = Path(args.findings_input)
    try:
        findings = json.loads(source.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        parser.error(f"cannot read valid findings JSON: {exc}")
    if not isinstance(findings, list):
        parser.error("findings input must be a JSON array")
    errors = []
    seen = set()
    for i, item in enumerate(findings):
        if not isinstance(item, dict):
            errors.append(f"Finding {i}: must be an object")
            continue
        errors.extend(validate_audit_finding(item, i))
        if item.get("id") in seen:
            errors.append(f"Finding {i}: duplicate id {item.get('id')}")
        seen.add(item.get("id"))
    if errors:
        print("Validation errors:\n" + "\n".join(f"  - {e}" for e in errors), file=sys.stderr)
        raise SystemExit(1)
    metadata = {}
    for key, value in (("metadata", args.metadata), ("inventory", args.inventory)):
        if value:
            try:
                metadata[key] = json.loads(Path(value).read_text(encoding="utf-8")) if key == "metadata" else Path(value).read_text(encoding="utf-8")
            except (OSError, json.JSONDecodeError) as exc:
                parser.error(f"cannot read {key}: {exc}")
    ordered = sort_findings(findings)
    out = Path(args.output_dir)
    out.mkdir(parents=True, exist_ok=True)
    payload = {"title": args.title, "generated_at": datetime.now(timezone.utc).isoformat(), "findings": ordered, "metadata": metadata}
    (out / "findings.json").write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    (out / "report.md").write_text(render_report(ordered, args.title, metadata), encoding="utf-8")
    print(f"Wrote {out / 'findings.json'} and {out / 'report.md'}; {len(findings)} findings validated.")

if __name__ == "__main__":
    main()
