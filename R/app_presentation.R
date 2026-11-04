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
  shiny::tags$h3("Current report"), lapply(paragraphs[nzchar(paragraphs)], shiny::tags$p),
  if (!is.null(data)) app_table(data, "Inputs and calculated quantities"))
app_report_document <- function(title, slug, paragraphs, data = NULL) {
  # Render head contents explicitly: Shiny otherwise collects tags$head outside
  # as.character()'s body fragment, dropping downloaded styles and metadata.
  head <- as.character(shiny::tagList(shiny::tags$meta(charset = "utf-8"),
    shiny::tags$meta(name = "viewport", content = "width=device-width,initial-scale=1"),
    shiny::tags$title(title), shiny::tags$style("body{max-width:900px;margin:2rem auto;padding:0 1rem;font:17px/1.6 system-ui,sans-serif;color:#20343e}h1{font-size:1.7rem}h3{font-size:1.2rem}p{white-space:pre-wrap;overflow-wrap:anywhere}table{border-collapse:collapse;width:100%}th,td{padding:8px;text-align:left;border-bottom:1px solid #b8cbd4;font-weight:400}caption{text-align:left}footer{border-top:1px solid #b8cbd4;margin-top:2rem;font-size:.9em}a{color:#17547b}@media print{body{font-size:11pt;margin:0}h1,h3{break-after:avoid}}")))
  body <- as.character(shiny::tags$body(shiny::tags$h1(title), shiny::tags$p(paste("Generated", Sys.Date())),
    app_report_body(paragraphs, data),
    shiny::tags$p(paste("Software: R", getRversion(), "; Shiny", utils::packageVersion("shiny"))),
    shiny::tags$p(shiny::tags$a(href = "https://katatam.github.io/sample-size-calculation/book/appendix.html#tutorial-methods", "Methods and reproducibility record")),
    app_citation(title, slug)))
  paste0('<!doctype html><html lang="en"><head>', head, '</head>', body, '</html>')
}

app_answer <- function(x) if (is.null(x) || !nzchar(trimws(x))) "Not yet specified." else x
