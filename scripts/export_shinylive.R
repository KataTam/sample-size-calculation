export_shinylive_apps <- function(
  apps = c("two_proportions", "two_means", "power_explorer", "dropout_adjustment"),
  output_dir = "docs/apps",
  staging_dir = file.path("build", "shinylive_staging"),
  clean = TRUE
) {
  if (!requireNamespace("shinylive", quietly = TRUE)) {
    stop(
      "Package 'shinylive' is needed. Install it with install.packages('shinylive').",
      call. = FALSE
    )
  }

  root <- normalizePath(".", winslash = "/", mustWork = TRUE)
  helper_file <- file.path(root, "R", "sample_size_functions.R")

  if (!file.exists(helper_file)) {
    stop("Cannot find R/sample_size_functions.R.", call. = FALSE)
  }

  output_path <- file.path(root, output_dir)
  staging_path <- file.path(root, staging_dir)

  # Resolve before any recursive cleanup. Both paths must stay below the repo.
  for (path in c(output_path, staging_path)) {
    resolved <- normalizePath(path, winslash = "/", mustWork = FALSE)
    parent <- normalizePath(dirname(path), winslash = "/", mustWork = FALSE)
    if (grepl("(^|[/\\\\])\\.\\.([/\\\\]|$)", path) ||
        !startsWith(tolower(resolved), paste0(tolower(root), "/")) ||
        tolower(resolved) == tolower(root) ||
        grepl("/\\.git(/|$)", resolved)) stop("Unsafe export cleanup path.")
  }
  if (isTRUE(clean)) {
    unlink(output_path, recursive = TRUE, force = TRUE)
    unlink(staging_path, recursive = TRUE, force = TRUE)
  }

  dir.create(output_path, recursive = TRUE, showWarnings = FALSE)
  dir.create(staging_path, recursive = TRUE, showWarnings = FALSE)

  for (app in apps) {
    app_dir <- file.path(root, "apps", app)
    source_app <- file.path(app_dir, "app.R")

    if (!file.exists(source_app)) {
      stop(sprintf("Cannot find app file for '%s'.", app), call. = FALSE)
    }

    staged_app <- file.path(staging_path, app)
    dir.create(staged_app, recursive = TRUE, showWarnings = FALSE)

    app_lines <- readLines(source_app, warn = FALSE)
    app_lines <- gsub(
      'source\\("\\.\\./\\.\\./R/sample_size_functions\\.R"\\)',
      'source("sample_size_functions.R")',
      app_lines
    )

    writeLines(app_lines, file.path(staged_app, "app.R"), useBytes = TRUE)
    file.copy(helper_file, file.path(staged_app, "sample_size_functions.R"), overwrite = TRUE)

    message(sprintf("Exporting %s to %s", app, file.path(output_dir, app)))
    shinylive::export(
      appdir = staged_app,
      destdir = output_path,
      subdir = app
    )
  }

  index_path <- file.path(output_path, "index.html")
  index_lines <- c(
    "<!doctype html>",
    "<html lang=\"en\">",
    "<head>",
    "  <meta charset=\"utf-8\">",
    "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
    "  <title>Sample Size Calculation Apps</title>",
    "  <style>",
    "    body { font-family: system-ui, sans-serif; max-width: 760px; margin: 2rem auto; padding: 0 1rem; line-height: 1.5; }",
    "    li { margin: 0.4rem 0; }",
    "  </style>",
    "</head>",
    "<body>",
    "  <h1>Sample Size Calculation Apps</h1>",
    "  <p><a href=\"book/\">Read the sample size tutorial</a> · <a href=\"book/Sample_size_open_module.html\">Standalone HTML</a> · <a href=\"sample-size-oer-source.zip\">Reusable source package</a></p>",
    "  <p>These browser-based apps were exported with Shinylive.</p>",
    "  <ul>",
    sprintf("    <li><a href=\"%s/\" target=\"_blank\" rel=\"noopener\">%s</a></li>", apps, app_labels(apps)),
    "  </ul>",
    "</body>",
    "</html>"
  )
  writeLines(index_lines, index_path, useBytes = TRUE)

  message(sprintf("Done. Open %s to view the app index.", file.path(output_dir, "index.html")))
  invisible(output_path)
}

app_labels <- function(apps) {
  labels <- c(
    two_proportions = "Two Proportions",
    two_means = "Two Means",
    power_explorer = "Sample size reasoning lab",
    dropout_adjustment = "Dropout Adjustment"
  )
  unname(ifelse(apps %in% names(labels), labels[apps], apps))
}

if (identical(environment(), globalenv())) {
  export_shinylive_apps()
}
