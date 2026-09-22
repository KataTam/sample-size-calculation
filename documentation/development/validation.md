# Implementation validation

Validated 16 September 2026 before applying the literature-informed revision.

- `Rscript scripts/check_resource.R`: passed, including numerical checks, module code parsing and the simulation/Shiny server suite.
- Simulation checks covered continuous and binary outcomes, null and alternative scenarios, confidence interval coverage, Monte Carlo uncertainty, sparse binary data, reproducibility and random-state restoration. Tests compared results with R reference methods and exact enumeration where appropriate.
- Shiny server checks covered both outcomes, all three planning goals, single and repeated studies, stale-result handling, validation and export metadata.
- `scripts/build_static_activity.R`: generated five reproducible offline scenarios, synthetic datasets, replication results, assumptions and figures.
- The learner Rmd rendered successfully to self-contained HTML. Pandoc emitted a non-fatal deprecation warning about syntax highlighting.
- Local R-backed browser smoke test: single-study results and interpretation displayed; repeated-study table and plots displayed; replication CSV download completed.

## Remaining deployment and teaching checks

The earlier Shinylive export failure was resolved on 16 September 2026 by running with network access for dependency resolution. All four apps exported successfully with shinylive 0.5.0; generated assets are in the local, Git-ignored `docs/apps/` directory. These were subsequently published through the separate public deployment repository.

## Shinylive browser checks

- Served the generated assets over local HTTP using `httpuv::runStaticServer`; computations ran in browser WebAssembly, without an R Shiny server.
- All four apps loaded and displayed numerical outputs and plots. Defaults: two proportions 53 per group; two means 59 per group; dropout 112 per group and 224 total.
- Reasoning lab: continuous planning gave 45 per group; one-study estimate 2.3097, p = 0.0454; 1,000-study rejection rate 0.7980 and coverage 0.9410, matching the local R run. Binary one-study generation also worked (42 per group, estimate 0.2857).
- Detected Chromium's service-worker download issue. Removed the download attribute from Shiny's buttons and added client fetch-to-Blob handling with accessible success/error feedback.
- The browser successfully fetched and prepared both CSV exports, the justification text and the reproducible R script, with the correct attachment filenames. The automation interface did not report the final browser save event, so saving to the user's Downloads folder is not independently verified. Check one saved file in the intended teaching browser before release.
- R numerical and server checks were rerun after the download changes, including a regression check for the button attributes.

No student pilot or formal accessibility audit was performed. Use the pilot assessment, accessibility checklist and release checklist for those human review steps. The source revision is maintained on GitHub; generated Shinylive assets remain separate from source control.


## Consolidation checks — 22 September 2026

The R calculation and Shiny-server checks passed. Both HTML editions rendered successfully. Browser checks found all 26 bibliography entries, no missing images, no unresolved citations and no broken local book targets. Desktop and narrow mobile views were inspected. All four exported apps loaded over HTTP without Shiny output errors; the reasoning lab ran normal and binary single/repeated studies, displayed the new p-value plot, and emitted CSV download events for both outcomes. These checks do not establish educational effectiveness.
