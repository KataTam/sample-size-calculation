"""Check maintained page targets, fragments and activity IDs; optionally probe external links."""
from concurrent.futures import ThreadPoolExecutor
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urljoin, urlsplit, unquote
from urllib.request import Request, urlopen
from urllib.error import HTTPError
import argparse
import json
import re

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "_site"
RUNTIMES = {"shinylive", "two_means", "two_proportions", "power_explorer", "dropout_adjustment", "prevalence_precision", "sampling_distributions"}
BASE = "http://127.0.0.1:8769/"

class Page(HTMLParser):
    def __init__(self, path):
        super().__init__()
        self.ids, self.links = set(), []
        self.feed(path.read_text(encoding="utf-8"))
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        self.ids.update(value for key, value in attrs.items() if key in {"id", "name"} and value)
        self.links.extend((tag, key, value) for key, value in attrs.items()
            if key in {"href", "src"} and value)

def internal_check():
    pages = {path: Page(path) for path in SITE.rglob("*.html")
        if path.relative_to(SITE).parts[0] not in RUNTIMES and "libs" not in path.relative_to(SITE).parts}
    # Shiny builds these learner-facing links at runtime from maintained R source.
    for app in (ROOT / "apps").glob("*/app.R"):
        page = Page.__new__(Page)
        page.ids = set()
        page.links = [("a", "href", value) for value in re.findall(r'''href\s*=\s*["']([^"']+)["']''', app.read_text(encoding="utf-8"))]
        pages[SITE / app.parent.name / "index.html"] = page
    errors, external, checked = [], set(), 0
    cases = json.loads((SITE / "teaching-cases.json").read_text(encoding="utf-8"))
    for path, page in list(pages.items()):
        for tag, key, value in page.links:
            url = urlsplit(urljoin(BASE + path.relative_to(SITE).as_posix(), value))
            if url.scheme not in {"http", "https"}:
                continue
            if url.hostname == "katatam.github.io" and url.path.startswith("/sample-size-calculation/"):
                url = urlsplit(BASE + url.path.removeprefix("/sample-size-calculation/") + ("?" + url.query if url.query else "") + ("#" + url.fragment if url.fragment else ""))
            if url.hostname not in {"127.0.0.1", "localhost"}:
                if tag == "a": external.add(url._replace(fragment="").geturl())
                continue
            checked += 1
            target = (SITE / unquote(url.path.lstrip("/"))).resolve()
            if target.is_dir(): target /= "index.html"
            issue = None
            if not target.is_file(): issue = "missing target"
            elif url.fragment and target.suffix == ".html" and target.relative_to(SITE).parts[0] not in RUNTIMES:
                if target not in pages: pages[target] = Page(target)
                if unquote(url.fragment) not in pages[target].ids: issue = "missing fragment"
            if url.path.rstrip("/") == "/study":
                from urllib.parse import parse_qs
                activity = parse_qs(url.query).get("activity", [None])[0]
                if activity and activity not in cases: issue = "unknown activity"
            if issue: errors.append({"page":str(path.relative_to(SITE)), "link":value, "issue":issue})
    return {"pages":len(pages), "internal_links_checked":checked,
        "errors":errors, "external_urls":sorted(external)}

def probe(url):
    headers = {"User-Agent":"Mozilla/5.0 (compatible; teaching-resource-link-check/1.0)"}
    for method in ["HEAD", "GET"]:
        try:
            with urlopen(Request(url, headers=headers, method=method), timeout=12) as response:
                return {"url":url, "status":response.status, "resolved_url":response.url}
        except HTTPError as error:
            if method == "HEAD": continue
            return {"url":url, "status":error.code, "resolved_url":error.url}
        except Exception as error:
            if method == "HEAD": continue
            return {"url":url, "status":None, "error":str(error)}

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--external", action="store_true")
    args = parser.parse_args()
    report = internal_check()
    if args.external:
        with ThreadPoolExecutor(max_workers=8) as pool:
            report["external_results"] = list(pool.map(probe, report["external_urls"]))
    (ROOT / "build").mkdir(exist_ok=True)
    (ROOT / "build/link-audit.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(f"Checked {report['internal_links_checked']} local links/assets across {report['pages']} pages; {len(report['errors'])} errors.")
    for error in report["errors"]: print(error)
    if args.external:
        results = report["external_results"]
        print(f"Probed {len(results)} external URLs; {sum(x['status'] is not None and x['status'] < 400 for x in results)} responded successfully.")
        for result in results:
            if result["status"] is None or result["status"] >= 400: print(result)
    if report["errors"]: raise SystemExit(1)
