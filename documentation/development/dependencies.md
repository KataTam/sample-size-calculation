# Dependencies

Students and reviewers using the website need a browser, not R or RStudio.

## Build and adapt

Use R 4.5.1, Python 3.10 or later, and Pandoc (available separately or with RStudio). Python uses only its standard library. R Markdown rendering uses rmarkdown, bookdown and knitr; the apps use shiny; browser export uses shinylive. Exact R package versions and their dependencies are recorded in the root renv.lock.

From the project root, install renv if needed, then activate and restore the environment:

```r
install.packages("renv") # only if renv is not installed
renv::activate()
renv::restore(prompt = FALSE)
```

Restart R after activation. Open sample-size-calculation.Rproj for editing. Then follow [build and publish](build-and-publish.md). The GitHub Actions build uses the same lockfile through r-lib/actions/setup-renv.

Keep the lockfile under version control. Update dependencies deliberately, run the checks and both render/export steps, and verify the browser apps before publishing an updated lockfile. Record the tested release in the validation record. Local renv/library and cache files are not committed.

The lockfile pins R packages; it does not freeze the browser, operating system, Pandoc or downloaded webR/Shinylive runtime assets. Check browser behaviour separately after rebuilding.
