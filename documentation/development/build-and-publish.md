# Build and publish

The source is maintained in [KataTam/sample-size-calculation](https://github.com/KataTam/sample-size-calculation).

The repository is public again at the author's request (8 October 2026). Website deployment is configured separately through GitHub Pages and the publishing workflow.

## Edit and publish

Open `sample-size-calculation.Rproj`. Edit `module/Sample_size_open_module.Rmd` for the tutorial and `module/references.bib` for references. Shared statistical functions live in `R/sample_size_functions.R`; the six app sources live in `apps/`. Matched activity settings are maintained once in `R/teaching_cases.R`. The glossary, FAQ and study-design guide in `student-materials/` are also included in the complete tutorial from those same sources.

Save, commit and push to `main` to update the public source. When enabled, the GitHub Actions workflow checks source encoding, runs the statistical/server checks, renders chaptered and complete HTML and the complete PDF, exports the browser apps, renders the supporting pages, checks local website links, refreshes the source download and deploys GitHub Pages. Knitting alone updates local files and does not publish. A failed deployment leaves the previous successful site online.

The build uses Ubuntu 24.04 and R 4.5.1 with the package lockfile. The runner is pinned because `later` 1.4.4 fails to compile against the Ubuntu 26 system headers; an environment upgrade should be validated separately.

PDF update policy (5 October 2026): after tutorial changes, refresh the complete tutorial HTML and PDF downloads. Check their content and rendered layout before delivery. The complete PDF expands all disclosure boxes, including model answers, R code and raw output, alongside formatted tables and figures.

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

Then open http://127.0.0.1:8769/study/ . Binding to 127.0.0.1 keeps the preview on this computer. Activity links in the R Markdown source use the published website address. The assembled local site keeps navigation local; keep this server running while testing it. The website build converts same-project links to relative paths for the complete site. Browser apps require HTTP, not `file://`. Shinylive downloads dependencies during export, so the build needs network access. The tutorial render builds HTML and the complete PDF by default. Refresh the complete tutorial downloads after the site build.

To rebuild HTML and the PDF locally, run:

```sh
Rscript scripts/render_resource.R --pdf
```

PDF generation remains required after tutorial changes. Render HTML with `Rscript scripts/render_resource.R --html`, assemble the site and start the loopback preview, then run `node scripts/export_tutorial.cjs`. The exporter combines all chapters into one self-contained HTML and one browser-printed PDF, retaining formatted results, figures and equations. HTML keeps boxes collapsible; PDF expands all boxes, including code, output and model answers. It writes complete downloads to `module/`, `docs/book/`, `_site/book/`, and the PDF to `output/pdf/`. No chapter downloads are generated. Use the browser export as the final print edition; the optional LaTeX render is an intermediate alternative.

## Sources and generated files

Flashcards are maintained in `data/flashcards.json`, using stable card IDs. Install `scripts/flashcard-requirements.txt` for the Python interpreter used to assemble the site. Site assembly runs `scripts/build_flashcards.py`, which validates explanation links against the rendered book and generates the Anki packages, Quizlet tab-separated imports, and readable card preview in `student-materials/flashcards/`. The generated files are Git-ignored and rebuilt in CI. Preserve IDs when revising existing cards so Anki recognizes them. The two Anki packages share the same Core subdeck and note identifiers; the combined package adds Advanced. After changes, check the deck counts in the maintained import guide.

`documentation/`, `teaching/`, `case-studies/` and `student-materials/` contain maintained Markdown. They are rendered to readable HTML pages on the teaching website. `site/` contains the homepage and shared page styling; `site/study/` contains the two-panel lesson/app view. Its case selector reads the exported case registry, and the build resolves lesson anchors to chapter filenames. Generated output stays in the Git-ignored `docs/` and `_site/` folders; do not edit it by hand.

When moving a file, update Markdown links, script paths and compatibility aliases in `scripts/build_site.py`. Old case-study and documentation URLs are retained as aliases where possible. Deleted collaborator files are not included in the build or source download. The old separate repositories are private archives; use this repository for all current work.

## Editing generated tutorial text

The main tutorial narrative is in `module/Sample_size_open_module.Rmd`. Some sections are inserted by R code during rendering: edit the mind-map question labels and explanations in `data/question-map.json`, and its surrounding layout or instructions in `R/question_map.R`. This is why the paragraph explaining how to use the map appeared online but was absent from the R Markdown file. Edit these maintained sources and render the tutorial to see the result; generated HTML in `docs/` and `_site/` is replaced during the next build.

## Assumptions report activity

The written study-plan activity lives in `site/assumptions_report/`. Its questions draw on PICO, selected SPIRIT 2025 protocol items and DELTA², with credit in the app and downloads. The hypothetical pain-relief example reads the shared case registry. Students record calculator results and their interpretation. Entries persist in browser storage. The default PDF report and editable Word alternative use the same current content. A separate “Save work for later” download stores a version-2 JSON file for reopening; a plain-text report is also available. Earlier saved HTML reports and version-1 JSON files remain supported. Imported text is validated and rendered as text. Gray model answers are placeholders and never contribute to saved responses or completion counts.

Question help is shared through `site/input-guidance.js` and `site/input-guidance.css`, embedded into exported Shiny apps by `R/activity_bridge.R`. It supports hover, focus, tap and Escape dismissal and explains what to enter or interpret. Gray model answers appear in empty response fields; the one-study and many-studies reflections have separate expandable model answers. The activity is available through the same two-panel study view as the calculation apps. `node scripts/check_assumptions_report.cjs` checks the readable export, old/new restoration, PICO visibility, input safety and help interactions.

`site/app-layout.js` supplies editable numeric companions to sliders, compact settings below 900 pixels and expanding text areas. Percentage companions use the visible 0–100 scale while the original Shiny inputs retain probabilities. The study-plan form shows a live preview on wide screens and counts only entered answers to currently applicable prompts. `scripts/check_app_usability.cjs` exercises input conversion, current results and wide, split-panel and mobile layouts. The flashcard preview can hide and reveal answers without changing the import decks. Two quiz questions have explanatory graphics maintained under `site/quiz/figures/`; the same graphics are included in chapter checks and the complete tutorial downloads.

`R/model_answers.R` generates model answers from each app's current calculation objects, case context and saved simulation metadata. The shared message handler updates placeholders without changing learner entries. Invalid calculation inputs replace numerical examples with a validity prompt. The written report follows its design and goal selections; unanswered custom-study fields receive bracketed prompts instead of values inferred from free text. `scripts/check_model_answers.R` and `scripts/check_dynamic_answers.cjs` check numeric consistency, case changes and preservation of written answers.

The report also supports a single-population estimate, existing data and pilot feasibility. Study structure and goal control the relevant prompts; single-population estimation omits treatment thresholds and power fields, while feasibility adds objectives, denominators and progression criteria. Earlier version-1 saved entries remain supported and default to a two-group comparison when the structure is absent. Calculations for another design must come from an appropriate external method.

The writing-style notes are kept outside the public repository, in the project's local `working/` folder. They are excluded from the website and downloadable source package.

## App reports and backups

`R/app_presentation.R` supplies the shared HTML report layout and simulation summaries. The two-group calculators assemble their reports in `R/basic_calculator.R`; the remaining Shiny apps assemble theirs in `apps/<app_name>/app.R`. Preview and downloads use the same report content. `site/report-exports.js` converts that internal HTML to a tagged PDF with selectable text or an editable .docx in the browser. PDFKit, docx and a Unicode font are pinned under `site/vendor/reports/` with their original licenses. These assets are served locally; export sends no report contents to a conversion service. `R/activity_bridge.R` supplies the paired download controls and locates the assets for native Shiny and Shinylive; the study-plan form uses the same exporter. Student responses are escaped as text, model-answer placeholders are excluded, and the downloads include software versions, methods links and license notices.

The reasoning lab's report separates study responses, calculation, feasibility and simulation. It compares each saved simulation's metadata, including the activity, with the current snapshot. The single-percentage app checks both the saved inputs and case ID. A mismatch produces an omission notice in the report; the original result remains in its simulation panel and CSV export. Reports for unsupported designs omit the independent-group numerical calculation. Student prose stays as entered and carries a reminder to review it after changing settings.

The lab's `sample-size-study-plan` JSON backup stores the activity, validated inputs and study responses. “Reopen saved work” reads it through `read_study_plan()` in `R/activity_bridge.R` and clears previous simulations. The written report activity has its own `sample-size-assumptions-report` JSON format; its earlier HTML reports with embedded entries and older JSON entries remain supported. The formats are specific to their apps. The learner-facing [download guide](../../student-materials/activity-walkthroughs.html#reports-and-saved-work) explains their use.

`scripts/check_app_reports.R`, included in `scripts/check_resource.R`, checks current calculations, selected cases, saved-result exclusions, missing-outcome summaries, written responses and backup restoration. After rebuilding and serving `_site`, `node scripts/check_app_reports.cjs` checks all six Shiny app downloads against their previews and exercises the lab's JSON round trip. `node scripts/check_assumptions_report.cjs` checks the separate written report. `node scripts/check_report_exports.cjs` exercises Unicode, tables, hyperlinks and long answers; `python scripts/check_report_files.py` compares PDF/Word contents with the export source and checks document structure and license links. Visual review also checks pagination and layout. These checks do not establish formal PDF/UA conformance. Changes to shared R helpers require re-exporting all affected Shiny apps; changing only a generated copy in `_site` will be overwritten by the next build.

## Editing references

APA 7 formatting is set by `csl: apa.csl` in the tutorial YAML. Keep `module/apa.csl` beside the tutorial; citations use author and year, and the reference list is alphabetized automatically. Supporting-page links in the R Markdown use the local preview server's HTML addresses so they work from RStudio's temporary `/rmd_output/` location. Site assembly makes these links relative for the complete website.

Edit `module/Sample_size_open_module.Rmd` and `module/references.bib` together in the maintained `sample-size-calculation` project. The YAML setting `bibliography: references.bib` refers to the bibliography beside that R Markdown file. For example, add the entry with key `kunzmann2021review` there and cite it with `[@kunzmann2021review]` in the R Markdown text. Save both files before rendering.

The older `sample-size-calculation-oer` and archived `pre2026` folders are not publication sources. Bibliographies in generated website folders are output copies; editing them does not update the tutorial.

From the maintained repository root, run `Rscript scripts/render_resource.R` to rebuild the book and standalone HTML. Add `--pdf` when you also want to update the printable edition. Commit and push to `main` to publish through GitHub Pages. From 14 October 2026, the author has requested publication of completed, checked tutorial and resource updates by default. Monitor the workflow and verify the live site before reporting publication complete.

## Complete tutorial downloads

Only the Welcome page offers the complete HTML/PDF download pair. The chapter-based website navigation remains available. Run `node scripts/export_tutorial.cjs` after each finished tutorial update. The exporter uses Microsoft Edge on Windows and Playwright Chromium elsewhere, and removes the known generated chapter download files and manifest. Generated files are ignored by Git.

The complete PDF uses a serif print layout with a separate title page, a linked chapter/section contents list with page numbers, and PDF bookmarks. Install its Python dependencies with `python -m pip install -r scripts/pdf-requirements.txt`. `scripts/assemble_book_pdf.py` derives contents destinations from the browser-rendered PDF outline, so pagination is recalculated on each build. Front matter uses Roman page labels and the tutorial body starts at page 1. Set `PYTHON` to a specific interpreter when needed.

The YAML date is evaluated during rendering, not on page visits. Rebuild and publish after edits; refresh an older browser tab if its date differs from the current build. The PDF cover uses the same rendered date. Glossary hover summaries are maintained in `data/glossary-terms.json`, with full definitions and stable anchors in `student-materials/glossary.md`. `scripts/render_resource.R` embeds the summaries and `module/glossary-tooltips.js` in both HTML editions; `node scripts/check_glossary_tools.cjs` checks hover, keyboard focus, dismissal and standalone behavior.
