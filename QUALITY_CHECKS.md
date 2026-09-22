# Quality Checks

Use these checks before a pilot, course use, or public release. They complement the release checklist by focusing on whether the module and apps still work as teaching materials.

## Quick Automated Check

From the repository root, run:

```r
source("scripts/check_resource.R")
```

This checks:

- R syntax in the shared function file and app files
- R code chunks in the learner module
- a few expected outputs from the sample-size functions
- whether key documentation files are present

The check does not replace reading the rendered module. It is meant to catch simple breakages early.

## Optional Render Check

To render the learner module as part of the check, run:

```r
source("scripts/check_resource.R")
check_resource(render_module = TRUE)
```

Use the render check before a release, after changing figures or tables, and after changing R Markdown setup options.

## Manual Module Check

After rendering `module/Sample_size_open_module.Rmd`, check:

- main text is large enough in RStudio Viewer and in a browser
- Tables 1-3 appear as tables, not as broken plain text
- Figures 1-4 are readable on a laptop screen
- figure captions and surrounding text refer to the correct figure numbers
- app descriptions match the current app defaults
- links to teaching files, cases, licenses, and the repository work
- the closing section gives enough information for reuse and citation

## Manual App Check

For each app:

- start the app from RStudio or with `shiny::runApp()`
- check the default result
- change one input at a time and check that the result changes in the expected direction
- check that warnings or validation messages are understandable
- check that plots have readable axis labels
- check that the text output explains "per group", "total", or "recruitment target" where relevant
- check that keyboard tab order is usable enough for the intended setting

## Teaching Check

Before using the resource in class:

- choose the teaching format: 30, 60, or 90 minutes
- choose which app or apps students will use
- choose the assessment route: short answer, assumptions table, or sample-size justification
- check that the rubric matches the assessment task
- decide whether students will use the chronic pain case or create their own cases
- prepare a backup route if Shiny is unavailable

## Accessibility Check

Use `teaching/accessibility_checklist.md` after any substantive change to:

- figures
- app outputs
- tables
- headings
- links
- instructions for student-generated cases

Small accessibility problems are easiest to fix while the resource is still modular.

## Public Sharing Check

Before publishing or archiving:

- check that downloaded references and copyrighted PDFs are not committed
- check that no local student, patient, or project details are included
- check `OER_METADATA.md`
- check `REUSE_AND_CITATION.md`
- check `PUBLICATION_AND_HOSTING.md`
- update `NEWS.md`
- tag the release when the version is ready

## Simulation and learning checks

Run `Rscript scripts/check_resource.R` and `Rscript scripts/build_static_activity.R`, then render the module. Verify both outcome types, all three goals, null and custom scenarios, one/many Run controls, stale-result warnings and all downloads in the actual deployed browser. Check keyboard navigation, narrow screens, textual output and invalid/zero inputs. Statistical tests include both tails, independent reference analyses, null rejection, coverage, seeds and per-arm rounding. Review the matched learning forms separately from satisfaction feedback.
