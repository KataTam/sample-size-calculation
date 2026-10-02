# Build and publish

The source and website are maintained in [KataTam/sample-size-calculation](https://github.com/KataTam/sample-size-calculation). Learners can use the published materials without installing software.

## Edit and publish

Open `sample-size-calculation.Rproj`. Edit `module/Sample_size_open_module.Rmd` for the tutorial and `module/references.bib` for references. Shared statistical functions live in `R/sample_size_functions.R`; the six app sources live in `apps/`. Matched activity settings are maintained once in `R/teaching_cases.R`. The glossary, FAQ and study-design guide in `student-materials/` are also included in the complete tutorial from those same sources.

Save, commit and push to `main`. The GitHub Actions workflow checks source encoding, runs the statistical/server checks, renders chaptered HTML, complete HTML and printable PDF, exports the browser apps, renders the supporting pages, checks local website links, refreshes the source download and deploys GitHub Pages. Check the Actions tab for successful deployment. Knitting alone updates local files and does not publish. A failed deployment leaves the previous successful site online.

## Build locally

Install the [dependencies](dependencies.md), including TinyTeX with XeLaTeX for the print edition. From the repository root:

```sh
python scripts/check_text.py
Rscript scripts/check_resource.R
Rscript scripts/render_resource.R
Rscript scripts/export_shinylive.R
python scripts/build_site.py
python -m http.server 8767 --directory _site
```

Then open http://localhost:8767/study/ . Browser apps require HTTP, not `file://`. Shinylive downloads dependencies during export, so the build needs network access. For an HTML-only development build, source `scripts/render_resource.R` into a local environment and call `render_resource(include_pdf = FALSE)`; the publication build includes the PDF.

## Sources and generated files

`documentation/`, `teaching/`, `case-studies/` and `student-materials/` contain maintained Markdown. They are rendered to readable HTML pages on the teaching website. `site/` contains the homepage and shared page styling; `site/study/` contains the two-panel lesson/app view. Its case selector reads the exported case registry, and the build resolves lesson anchors to chapter filenames. Generated output stays in the Git-ignored `docs/` and `_site/` folders; do not edit it by hand.

When moving a file, update Markdown links, script paths and compatibility aliases in `scripts/build_site.py`. Old case-study and documentation URLs are retained as aliases where possible. Deleted collaborator files are not included in the build or source download. The old separate repositories are private archives; use this repository for all current work.

## Editing references

Edit `module/Sample_size_open_module.Rmd` and `module/references.bib` together in the maintained `sample-size-calculation` project. The YAML setting `bibliography: references.bib` refers to the bibliography beside that R Markdown file. For example, add the entry with key `kunzmann2021review` there and cite it with `[@kunzmann2021review]` in the R Markdown text. Save both files before rendering.

The older `sample-size-calculation-oer` and archived `pre2026` folders are not publication sources. Bibliographies in generated website folders are output copies; editing them does not update the tutorial.

From the maintained repository root, run `Rscript scripts/render_resource.R` to rebuild the book, standalone HTML and PDF. Knitting alone does not publish changes online: commit and push the source files to GitHub, then wait for the Pages workflow to finish.
