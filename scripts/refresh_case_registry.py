"""Refresh case text/values in existing Shinylive bundles without changing dependencies.

Use a full export when application code or package dependencies change.
This refresh packages the maintained R case registry, not hand-edited output.
"""
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
source = (root / "R/teaching_cases.R").read_text(encoding="utf-8")
bundles = list((root / "docs/apps").glob("*/app.json"))
if not bundles:
    raise SystemExit("Export the browser apps first.")
updated = 0
for bundle in bundles:
    entries = json.loads(bundle.read_text(encoding="utf-8"))
    registry = [entry for entry in entries if entry.get("name") == "teaching_cases.R"]
    if not registry:
        continue
    if len(registry) != 1 or registry[0].get("type") != "text":
        raise SystemExit(f"Unexpected case registry in {bundle}")
    registry[0]["content"] = source
    bundle.write_text(json.dumps(entries, ensure_ascii=False), encoding="utf-8")
    saved = json.loads(bundle.read_text(encoding="utf-8"))
    assert next(entry["content"] for entry in saved
                if entry.get("name") == "teaching_cases.R") == source
    updated += 1
if updated == 0:
    raise SystemExit("No case registry found in the existing browser bundles.")
print(f"Refreshed and verified the maintained case registry in {updated} browser apps.")
