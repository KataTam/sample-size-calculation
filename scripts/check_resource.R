check_resource <- function(render_module = FALSE) {
  root <- normalizePath(".", winslash = "/", mustWork = TRUE)
  say <- function(...) message(sprintf(...))

  required_files <- c(
    "README.md",
    "documentation/references.md",
    "documentation/third-party-notices.md",
    "documentation/evidence-and-design-rationale.md",
    "documentation/statistical-methods.md",
    "teaching/pilot_learning_assessment.md",
    "LICENSE",
    "LICENSE-code.md",
    "CITATION.cff",
    "documentation/oer-metadata.md",
    "documentation/reuse-and-citation.md",
    "documentation/development/build-and-publish.md",
    "documentation/development/quality-checks.md",
    "module/Sample_size_open_module.Rmd",
    "module/styles.css",
    "R/sample_size_functions.R",
    "teaching/TEACHING_GUIDE.md",
    "teaching/constructive_alignment_table.md",
    "teaching/assessment_rubric.md",
    "teaching/accessibility_checklist.md",
    "teaching/pilot_student_feedback.md",
    "teaching/pilot_observation_notes.md",
    "case-studies/student_case_template.md",
    "scripts/export_shinylive.R"
  )

  missing_files <- required_files[!file.exists(file.path(root, required_files))]
  if (length(missing_files)) {
    stop(
      "Missing required files:\n",
      paste(sprintf("- %s", missing_files), collapse = "\n"),
      call. = FALSE
    )
  }
  say("Found required documentation and module files.")

  r_files <- c(
    "R/sample_size_functions.R",
    "scripts/export_shinylive.R",
    "apps/two_proportions/app.R",
    "apps/two_means/app.R",
    "apps/power_explorer/app.R",
    "apps/dropout_adjustment/app.R"
  )

  for (file in r_files) {
    parse(file.path(root, file))
  }
  say("R files parse cleanly.")

  source(file.path(root, "R/sample_size_functions.R"), local = TRUE)

  prop_result <- sample_size_two_proportions_details(
    pi1 = 0.50,
    pi2 = 0.35,
    alpha = 0.05,
    power = 0.80
  )
  stopifnot(prop_result$n_per_group == 167)
  stopifnot(prop_result$total_n == 334)

  mean_result <- sample_size_two_means_details(
    sd = 20,
    delta = 10,
    alpha = 0.05,
    power = 0.80
  )
  stopifnot(mean_result$n_per_group == 63)
  stopifnot(mean_result$total_n == 126)

  dropout_result <- adjust_for_dropout(
    n = 126,
    dropout_rate = 0.15
  )
  stopifnot(dropout_result == 149)

  power_result <- power_two_proportions(
    n_per_group = 170,
    pi1 = 0.50,
    pi2 = 0.35,
    alpha = 0.05
  )
  stopifnot(power_result > 0.79, power_result < 0.83)
  say("Core sample-size calculations match expected results.")

  if (!requireNamespace("knitr", quietly = TRUE)) {
    stop("Package 'knitr' is needed to check R Markdown chunks.", call. = FALSE)
  }

  tmp_r <- tempfile(fileext = ".R")
  knitr::purl(
    input = file.path(root, "module/Sample_size_open_module.Rmd"),
    output = tmp_r,
    quiet = TRUE,
    documentation = 0
  )
  parse(tmp_r)
  unlink(tmp_r)
  say("R code chunks in the learner module parse cleanly.")

  if (isTRUE(render_module)) {
    if (!requireNamespace("rmarkdown", quietly = TRUE)) {
      stop("Package 'rmarkdown' is needed to render the module.", call. = FALSE)
    }

    source("scripts/render_resource.R", local = TRUE)
    render_resource()
    say("Learner module rendered successfully.")
  }

  source("scripts/check_simulation.R", local = TRUE)
  check_simulation()
  check_lab_server()
  say("All checks passed.")
  invisible(TRUE)
}

if (identical(environment(), globalenv())) {
  check_resource()
}
