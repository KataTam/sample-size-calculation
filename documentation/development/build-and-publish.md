# Build and publish

The source and website are maintained in [KataTam/sample-size-calculation](https://github.com/KataTam/sample-size-calculation). Learners can use the published materials without installing software.

## Edit and publish

Open `sample-size-calculation.Rproj`. Edit `module/Sample_size_open_module.Rmd` for the tutorial and `module/references.bib` for references. Shared statistical functions live in `R/sample_size_functions.R`; the four app sources live in `apps/`.

Save, commit and push to `main`. The GitHub Actions workflow checks source encoding, runs the statistical/server checks, renders both tutorial editions, exports the browser apps, renders the supporting pages, checks local website links, refreshes the source download and deploys GitHub Pages. Check the Actions tab for successful deployment. Knitting alone updates local files and does not publish. A failed deployment leaves the previous successful site online.

## Build locally

Install the [dependencies](dependencies.md). From the repository root:

```sh
python scripts/check_text.py
Rscript scripts/check_resource.R
Rscript scripts/render_resource.R
Rscript scripts/export_shinylive.R
python scripts/build_site.py
python -m http.server 8767 --directory _site
```

Then open http://localhost:8767 . Browser apps require HTTP, not `file://`. Shinylive downloads dependencies during export, so the build needs network access.

## Sources and generated files

`documentation/`, `teaching/`, `case-studies/` and `student-materials/` contain maintained Markdown. They are rendered to readable HTML pages on the teaching website. `site/` contains the homepage and shared page styling. Generated output stays in the Git-ignored `docs/` and `_site/` folders; do not edit it by hand.

When moving a file, update Markdown links, script paths and compatibility aliases in `scripts/build_site.py`. Old case-study and documentation URLs are retained as aliases where possible. Deleted collaborator files are not included in the build or source download. The old separate repositories are private archives; use this repository for all current work.
