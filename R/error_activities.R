# One source supplies the selectable passages and the printable explanations.
render_error_activity <- function(name) {
  bank <- jsonlite::fromJSON("../data/error-activities.json", simplifyVector = FALSE)
  activity <- bank[[name]]
  if (is.null(activity)) stop("Unknown error-spotting activity: ", name)
  tags <- htmltools::tags
  title_tag <- if (name %in% c("discharge", "software")) tags$h4 else tags$h3
  passages <- list(); answers <- list(); index <- 0L
  for (segment in activity$segments) {
    if (is.null(segment$error)) {
      spacer <- if (nzchar(segment$text) && !nzchar(trimws(segment$text))) htmltools::HTML("&#32;") else segment$text
      passages <- c(passages, list(spacer))
    } else {
      index <- index + 1L
      key <- paste0(activity$id, "-", index)
      passages <- c(passages, list(tags$span(class = "spot-choice", id = key,
        `data-choice` = index, `data-error` = tolower(as.character(segment$error)),
        segment$text, tags$span(class = "spot-print-marker", `aria-hidden` = "true", paste0(" [", index, "]")))))
      answers <- c(answers, list(tags$li(`data-choice` = index,
        tags$p(class = "spot-answer-quote", paste0("Passage ", index, ": ", segment$text)),
        tags$div(class = "spot-explanation", tags$p(if (segment$error) "This part needs correction." else "This part is appropriate."),
          tags$p(segment$explanation), tags$a(href = paste0("https://katatam.github.io/sample-size-calculation/book/", segment$link),
            paste0("Review: ", segment$section))))))
    }
  }
  # Emit one raw HTML block so Markdown does not parse indented nested tags.
  widget <- as.character(tags$div(class = "spot-activity", id = activity$id, `data-version` = if (is.null(activity$version)) "1" else as.character(activity$version), role = "region",
    `aria-labelledby` = paste0(activity$id, "-title"),
    title_tag(class = "spot-title", id = paste0(activity$id, "-title"), activity$title),
    tags$p(class = "spot-instructions", "Which passages need correction? Selecting a passage opens its explanation. Some passages are appropriate."),
    tags$p(class = "spot-print-instructions", "Which numbered passages need correction? Explanations follow."),
    tags$p(class = "spot-text", passages),
    tags$div(class = "spot-tools", tags$p(class = "spot-status", role = "status", `aria-live` = "polite"),
      tags$button(type = "button", class = "spot-reset", "Reset activity")),
    tags$details(class = "spot-answer-key model-answer", id = if (is.null(activity$answer_id)) paste0(activity$id, "-answers") else activity$answer_id,
      tags$summary("Answers and explanations"), tags$ol(answers))))
  cat(gsub("[\r\n]+[ ]*", "", widget), "\n\n", sep = "")
}
