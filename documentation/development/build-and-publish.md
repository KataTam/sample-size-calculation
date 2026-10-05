# Build and publish

The source is maintained in [KataTam/sample-size-calculation](https://github.com/KataTam/sample-size-calculation).

**Current status: private working edition (5 October 2026).** At the author's request, the repository is private, GitHub Pages is unpublished and the publishing workflow is disabled. Commit and push to save work privately; preview the website locally. Do not change repository visibility, enable Pages or re-enable deployment unless the author explicitly asks to publish again. The publication procedure below applies after that decision.

## Edit and publish

Open `sample-size-calculation.Rproj`. Edit `module/Sample_size_open_module.Rmd` for the tutorial and `module/references.bib` for references. Shared statistical functions live in `R/sample_size_functions.R`; the six app sources live in `apps/`. Matched activity settings are maintained once in `R/teaching_cases.R`. The glossary, FAQ and study-design guide in `student-materials/` are also included in the complete tutorial from those same sources.

Save, commit and push to `main` to save work privately while publication is disabled. When publication is authorized again, the GitHub Actions workflow checks source encoding, runs the statistical/server checks, renders chaptered and complete HTML and the complete PDF, exports the browser apps, renders the supporting pages, checks local website links, refreshes the source download and deploys GitHub Pages. Knitting alone updates local files and does not publish. A failed deployment leaves the previous successful site online.

**PDF update policy (5 October 2026):** after tutorial changes, refresh the complete tutorial HTML and PDF downloads. Check their content and rendered layout before delivery. The complete PDF keeps formatted tables and figures while omitting R code and raw console output.

## Build locally

Install the [dependencies](dependencies.md). TinyTeX with XeLaTeX is needed only when rebuilding the print edition. From the repository root:

```sh
python scripts/check_text.py
Rscript scripts/check_resource.R
Rscript scripts/render_resource.R
Rscript scripts/export_shinylive.R
python scripts/build_site.py
python -m http.server 8769 --bind 127.0.0.1 --directory _site
```

Then open http://127.0.0.1:8769/study/ . Binding to 127.0.0.1 keeps the preview on this computer. Activity links in the R Markdown source use this full local address so they also work from an RStudio preview under `/rmd_output/`. Keep this server running while testing those links. The website build converts same-project links to relative paths for the complete site. Browser apps require HTTP, not `file://`. Shinylive downloads dependencies during export, so the build needs network access. The tutorial render builds HTML and the complete PDF by default. Refresh the complete tutorial downloads after the site build.

To rebuild HTML and the PDF locally, run:

```sh
Rscript scripts/render_resource.R --pdf
```

PDF generation remains required after tutorial changes. Render HTML with `Rscript scripts/render_resource.R --html`, assemble the site and start the loopback preview, then run `node scripts/export_tutorial.cjs`. The exporter combines all chapters into one self-contained HTML and one browser-printed PDF, retaining formatted results, figures and equations. HTML keeps code and output expandable; PDF hides them. It writes complete downloads to `module/`, `docs/book/`, `_site/book/`, and the PDF to `output/pdf/`. No chapter downloads are generated. Use the browser export as the final print edition; the optional LaTeX render is an intermediate alternative.

## Sources and generated files

`documentation/`, `teaching/`, `case-studies/` and `student-materials/` contain maintained Markdown. They are rendered to readable HTML pages on the teaching website. `site/` contains the homepage and shared page styling; `site/study/` contains the two-panel lesson/app view. Its case selector reads the exported case registry, and the build resolves lesson anchors to chapter filenames. Generated output stays in the Git-ignored `docs/` and `_site/` folders; do not edit it by hand.

When moving a file, update Markdown links, script paths and compatibility aliases in `scripts/build_site.py`. Old case-study and documentation URLs are retained as aliases where possible. Deleted collaborator files are not included in the build or source download. The old separate repositories are private archives; use this repository for all current work.

## Editing generated tutorial text

The main tutorial narrative is in `module/Sample_size_open_module.Rmd`. Some sections are inserted by R code during rendering: edit the mind-map question labels and explanations in `data/question-map.json`, and its surrounding layout or instructions in `R/question_map.R`. This is why the paragraph explaining how to use the map appeared online but was absent from the R Markdown file. Edit these maintained sources and render the tutorial to see the result; generated HTML in `docs/` and `_site/` is replaced during the next build.

## Assumptions report activity

The written study-plan activity lives in `site/assumptions_report/`. Its labels and report prompts use the tutorial's terminology. The hypothetical pain-relief example reads the shared case registry; it does not calculate a new sample size. Students record calculator results and their interpretation. Entries persist in browser storage and can be saved and reopened as JSON; the report downloads as plain text. The activity is available through the same two-panel study view as the calculation apps.

The writing-style notes are kept outside the public repository, in the project's local `working/` folder. They are excluded from the website and downloadable source package.

## Editing references

Edit `module/Sample_size_open_module.Rmd` and `module/references.bib` together in the maintained `sample-size-calculation` project. The YAML setting `bibliography: references.bib` refers to the bibliography beside that R Markdown file. For example, add the entry with key `kunzmann2021review` there and cite it with `[@kunzmann2021review]` in the R Markdown text. Save both files before rendering.

The older `sample-size-calculation-oer` and archived `pre2026` folders are not publication sources. Bibliographies in generated website folders are output copies; editing them does not update the tutorial.

From the maintained repository root, run `Rscript scripts/render_resource.R` to rebuild the book and standalone HTML. Add `--pdf` when you also want to update the printable edition. Commit and push to save changes in the private repository. Public deployment remains disabled until the author explicitly asks to publish again.

## Complete tutorial downloads

Only the Welcome page offers the complete HTML/PDF download pair. The chapter-based website navigation remains available. Run `node scripts/export_tutorial.cjs` after each finished tutorial update. The exporter uses Microsoft Edge on Windows and Playwright Chromium elsewhere, and removes the known generated chapter download files and manifest. Generated files are ignored by Git.
