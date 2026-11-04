# Shared interface and readable report components. Original software: MIT.
app_input_group <- function(title, ..., advanced = FALSE, collapsed = FALSE) {
  if (collapsed) shiny::tags$details(class = paste("app-input-group", if (advanced) "app-advanced"), shiny::tags$summary(title), ...)
  else shiny::tags$section(class = "app-input-group", shiny::tags$h3(title), ...)
}
app_metrics <- function(values) shiny::tags$div(class = "app-metrics",
  lapply(names(values), function(label) shiny::tags$div(class = "app-metric",
    shiny::tags$span(class = "app-value", values[[label]]), shiny::tags$span(class = "app-label", label))))
app_overview <- function(visual, explanation) shiny::tags$div(class = "app-overview",
  shiny::tags$div(visual), shiny::tags$aside(class = "app-interpretation", shiny::tags$h3("What this means"), explanation))
app_table <- function(data, caption = NULL) shiny::tags$table(class = "app-table",
  if (!is.null(caption)) shiny::tags$caption(caption),
  shiny::tags$thead(shiny::tags$tr(lapply(names(data), function(x) shiny::tags$th(scope = "col", x)))),
  shiny::tags$tbody(lapply(seq_len(nrow(data)), function(i) shiny::tags$tr(lapply(data[i, , drop = FALSE], shiny::tags$td)))))
app_citation <- function(title, slug) shiny::tags$footer(class = "app-footer",
  shiny::tags$p(paste0("Tamási K. ", title, ". University Medical Center Groningen; 2026. Shiny application. "),
    shiny::tags$a(href = paste0("https://katatam.github.io/sample-size-calculation/", slug, "/"), target = "_blank", rel = "noopener", "App"), " · ",
    shiny::tags$a(href = paste0("https://github.com/KataTam/sample-size-calculation/commits/main/apps/", slug, "/app.R"), target = "_blank", rel = "noopener", "Source and version history")),
  shiny::tags$p("Teaching materials: ", shiny::tags$a(href = "https://creativecommons.org/licenses/by-sa/4.0/", target = "_blank", rel = "noopener", "CC BY-SA 4.0"),
    " · Software: ", shiny::tags$a(href = "https://opensource.org/license/mit", target = "_blank", rel = "noopener", "MIT")))
app_report_body <- function(paragraphs, data = NULL) shiny::tags$div(class = "app-report",
  shiny::tags$h3("Current report"),
  if (is.list(paragraphs)) lapply(names(paragraphs), function(title)
    shiny::tags$section(shiny::tags$h4(title), lapply(paragraphs[[title]][nzchar(paragraphs[[title]])], shiny::tags$p)))
  else lapply(paragraphs[nzchar(paragraphs)], shiny::tags$p),
  if (!is.null(data)) app_table(data, "Inputs and calculated quantities"))
app_report_document <- function(title, slug, paragraphs, data = NULL) {
  # Render head contents explicitly: Shiny otherwise collects tags$head outside
  # as.character()'s body fragment, dropping downloaded styles and metadata.
  head <- as.character(shiny::tagList(shiny::tags$meta(charset = "utf-8"),
    shiny::tags$meta(name = "viewport", content = "width=device-width,initial-scale=1"),
    shiny::tags$title(title), shiny::tags$style("body{max-width:900px;margin:2rem auto;padding:0 1rem;font:17px/1.6 system-ui,sans-serif;color:#20343e}h1{font-size:1.7rem}h3{font-size:1.2rem}p{overflow-wrap:anywhere}.app-report p{white-space:pre-wrap}table{border-collapse:collapse;width:100%}th,td{padding:8px;text-align:left;border-bottom:1px solid #b8cbd4;font-weight:400}caption{text-align:left}footer{border-top:1px solid #b8cbd4;margin-top:2rem;font-size:.9em}a{color:#17547b}@media print{body{font-size:11pt;margin:0}h1,h3,h4{break-after:avoid}}")))
  body <- as.character(shiny::tags$body(shiny::tags$h1(title), shiny::tags$p(paste("Generated", Sys.Date())),
    app_report_body(paragraphs, data),
    shiny::tags$p(paste("Software: R", getRversion(), "; Shiny", utils::packageVersion("shiny"))),
    shiny::tags$p(shiny::tags$a(href = "https://katatam.github.io/sample-size-calculation/book/appendix.html#tutorial-methods", "Methods and reproducibility record")),
    app_citation(title, slug)))
  paste0('<!doctype html><html lang="en"><head>', head, '</head>', body, '</html>')
}

app_answer <- function(x) if (is.null(x) || !nzchar(trimws(x))) "Not yet specified." else x

# Reports include only simulations from the current example and assumptions.
app_simulation_report <- function(saved, current, many = FALSE) {
  label <- if (many) "many-study simulation" else "single-study simulation"
  if (is.null(saved)) return(paste0("No ", label, " has been run."))
  if (!identical(saved$meta, current)) return(paste0("The saved ", label,
    " uses earlier settings or a different example and is omitted. Rerunning it will include current results."))
  x <- saved$spec
  effect <- function(v) paste0(round(v * if (x$outcome == "proportions") 100 else 1, 2),
    if (x$outcome == "proportions") " percentage points" else " units")
  r <- if (many) saved$results else saved$result
  valid <- is.finite(r$estimate)
  if (!any(valid)) return("The simulation produced no estimable comparisons; the retained sample was insufficient.")
  if (many) c(paste0(nrow(r), " simulated studies; ", sum(valid), " estimable comparisons. Significant results: ",
    format_percent(mean(r$reject[valid]), 1), "; intervals containing the true difference: ", format_percent(mean(r$cover[valid]), 1),
    "; intervals meeting the width target: ", format_percent(mean(r$width_met[valid]), 1), "."),
    paste0("Mean estimated difference: ", effect(mean(r$estimate[valid])), "; mean full interval width: ", effect(mean(r$width[valid])), "."),
    if (!is.null(saved$missing)) paste0("Mean retained per group, standard / novel: ",
      paste(round(c(mean(r$retained_control), mean(r$retained_treatment)), 1), collapse = " / "),
      ". Estimated bias: ", effect(mean(r$estimate[valid]) - true_difference(x)),
      ". Rejection percentages should be interpreted alongside bias and interval coverage."))
  else c(paste0("Estimated difference: ", effect(r$estimate), "; ", format_percent(1-x$alpha), " confidence interval: ",
    effect(r$lower), " to ", effect(r$upper), "; p = ", format.pval(r$p_value, digits = 3), "."),
    if (!is.null(saved$missing)) paste0("Participants with observed outcomes, standard / novel: ",
      sum(saved$data$group == "Control" & !is.na(saved$data$outcome)), " / ",
      sum(saved$data$group == "Treatment" & !is.na(saved$data$outcome)), "."))
}
