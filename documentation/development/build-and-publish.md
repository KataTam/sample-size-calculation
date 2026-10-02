# Build and publish

The source and website are maintained in [KataTam/sample-size-calculation](https://github.com/KataTam/sample-size-calculation). Learners can use the published materials without installing software.

## Edit and publish

Open `sample-size-calculation.Rproj`. Edit `module/Sample_size_open_module.Rmd` for the tutorial and `module/references.bib` for references. Shared statistical functions live in `R/sample_size_functions.R`; the six app sources live in `apps/`. Matched activity settings are maintained once in `R/teaching_cases.R`. The glossary, FAQ and study-design guide in `student-materials/` are also included in the complete tutorial from those same sources.

Save, commit and push to `main`. The GitHub Actions workflow checks source encoding, runs the statistical/server checks, renders chaptered and complete HTML, exports the browser apps, renders the supporting pages, checks local website links, refreshes the source download and deploys GitHub Pages. Ordinary publications retain the last published PDF without rebuilding it. Check the Actions tab for successful deployment. Knitting alone updates local files and does not publish. A failed deployment leaves the previous successful site online.

To update the printable edition, open the workflow in the GitHub Actions tab, choose **Run workflow**, and select **Rebuild the printable PDF as well as the website**. That manual publication builds the PDF from the current tutorial. Between PDF updates, the online tutorial can be newer than the downloadable PDF.

## Build locally

Install the [dependencies](dependencies.md). TinyTeX with XeLaTeX is needed only when rebuilding the print edition. From the repository root:

```sh
python scripts/check_text.py
Rscript scripts/check_resource.R
Rscript scripts/render_resource.R
Rscript scripts/export_shinylive.R
python scripts/build_site.py
python -m http.server 8767 --directory _site
```

Then open http://localhost:8767/study/ . Browser apps require HTTP, not `file://`. Shinylive downloads dependencies during export, so the build needs network access. The tutorial render builds HTML by default and leaves any existing PDF unchanged. On a fresh checkout, download the last published PDF into `docs/book/Sample_size_open_module.pdf` before assembling the complete website, or explicitly rebuild it.

To rebuild HTML and the PDF locally, run:

```sh
Rscript scripts/render_resource.R --pdf
```

`BUILD_PDF=true` also enables the PDF when running the render script; the publication workflow sets this only for an explicitly requested PDF rebuild. When calling the renderer from R, use `render_resource(include_pdf = TRUE)` for a PDF update.

## Sources and generated files

`documentation/`, `teaching/`, `case-studies/` and `student-materials/` contain maintained Markdown. They are rendered to readable HTML pages on the teaching website. `site/` contains the homepage and shared page styling; `site/study/` contains the two-panel lesson/app view. Its case selector reads the exported case registry, and the build resolves lesson anchors to chapter filenames. Generated output stays in the Git-ignored `docs/` and `_site/` folders; do not edit it by hand.

When moving a file, update Markdown links, script paths and compatibility aliases in `scripts/build_site.py`. Old case-study and documentation URLs are retained as aliases where possible. Deleted collaborator files are not included in the build or source download. The old separate repositories are private archives; use this repository for all current work.

## Editing generated tutorial text

The main tutorial narrative is in `module/Sample_size_open_module.Rmd`. Some sections are inserted by R code during rendering: edit the mind-map question labels and explanations in `data/question-map.json`, and its surrounding layout or instructions in `R/question_map.R`. This is why the paragraph explaining how to use the map appeared online but was absent from the R Markdown file. Edit these maintained sources and render the tutorial to see the result; generated HTML in `docs/` and `_site/` is replaced during the next build.

## Editing references

Edit `module/Sample_size_open_module.Rmd` and `module/references.bib` together in the maintained `sample-size-calculation` project. The YAML setting `bibliography: references.bib` refers to the bibliography beside that R Markdown file. For example, add the entry with key `kunzmann2021review` there and cite it with `[@kunzmann2021review]` in the R Markdown text. Save both files before rendering.

The older `sample-size-calculation-oer` and archived `pre2026` folders are not publication sources. Bibliographies in generated website folders are output copies; editing them does not update the tutorial.

From the maintained repository root, run `Rscript scripts/render_resource.R` to rebuild the book and standalone HTML. Add `--pdf` when you also want to update the printable edition. Knitting alone does not publish changes online: commit and push the source files to GitHub, then wait for the Pages workflow to finish.
