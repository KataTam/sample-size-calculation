# Sample Size Calculation

Clinical sample-size reasoning, power, precision and simulation for medical students, by Katalin Tamási (UMCG).

- [Read the tutorial](https://katatam.github.io/sample-size-calculation/book/)
- [Interactive tools](https://katatam.github.io/sample-size-calculation/)
- [Standalone HTML](https://katatam.github.io/sample-size-calculation/book/Sample_size_open_module.html)
- [Download the reusable source](https://katatam.github.io/sample-size-calculation/sample-size-calculation-source.zip)
- [Collaborator review files](intro_review/)
- [Teaching guide](teaching/TEACHING_GUIDE.md), [case template](cases/student_case_template.md), [assessment rubric](teaching/assessment_rubric.md)

## One maintained project

This public repository consolidates sample-size-calculation-oer and sample-size-calculation-apps. The original name is restored. The old OER repository is retained as a private archive; the old app website redirects to the matching new pages. Current sources are consolidated here with a fresh public history. External articles are referenced rather than redistributed. Randomization experiments remain a separate project.

Edit **module/Sample_size_open_module.Rmd** for the tutorial, **module/references.bib** for references, and **R/sample_size_functions.R** for shared calculations. apps/ contains the four app sources. Both HTML editions are generated from the same Rmd. No ANOVA lesson is required.

## Publish an edit

Save your source changes, commit, and push to main. The **Build and publish resource** GitHub Actions workflow checks the R code, renders both tutorial formats, exports all four browser apps, refreshes the source download and deploys GitHub Pages. A successful deployment is shown in the repository Actions tab. Knitting alone is a local preview and does not push changes.

## Build locally

Install R (tested with 4.5.1), Python 3, Pandoc (included with RStudio), and the R packages rmarkdown, bookdown, knitr, shiny and shinylive. From the repository root:

```sh
Rscript scripts/check_resource.R
Rscript scripts/render_resource.R
Rscript scripts/export_shinylive.R
python scripts/build_site.py
python -m http.server 8767 --directory _site
```

Browse http://localhost:8767 . Git ignores generated docs/ and _site/. The website is deployed as an Actions artifact, not a second editable repository. Build with network access for Shinylive dependencies.

## Reuse and provenance

Original teaching materials: CC BY 4.0. Original code: MIT. See LICENSE, LICENSE-code.md, CITATION.cff and THIRD_PARTY_NOTICES.md. Third-party dependencies and historical screenshots retain their own terms. Student contributions require review and consent for public attribution. This resource has not established learning effectiveness through a student pilot.
