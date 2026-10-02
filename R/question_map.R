# The online map and print edition share the same learner-facing explanations.
render_question_map <- function() {
  content <- jsonlite::fromJSON("../data/question-map.json", simplifyVector = FALSE)
  is_html <- knitr::is_html_output()
  parts <- character()
  if (is_html) {
    svg <- paste(readLines("../figures/study_questions.svg", warn = FALSE, encoding = "UTF-8"), collapse = "\n")
    svg <- sub("^<\\?xml[^>]*>\\s*", "", svg)
    parts <- c(parts, '<div class="figure question-map" role="figure" aria-label="Seven questions for planning a two-arm clinical trial">',
      svg, '\n<p class="caption">(#fig:study-questions-map) Seven questions for planning the sample size of a two-arm clinical trial. Based on illustration by Sieben Medical Art.</p>\n</div>\n')
  } else {
    parts <- c(parts, '![Seven questions for planning the sample size of a two-arm clinical trial. Based on illustration by Sieben Medical Art. (\\#fig:study-questions-map)](../figures/study_questions.png){width=100%}')
  }
  for (i in seq_along(content$questions)) {
    question <- content$questions[[i]]
    id <- paste0("sample-size-question-", question$id)
    if (is_html) {
      parts <- c(parts, sprintf('<details class="question-map-info" id="%s">\n<summary><span class="question-map-info-icon" aria-hidden="true">i</span> %s. %s</summary>\n', id, i, question$question))
    } else {
      parts <- c(parts, sprintf("\n### %s. %s {.unnumbered}\n", i, question$question))
    }
    parts <- c(parts, paste0("\n", question$explanation, "\n"))
    if (is_html) parts <- c(parts, "\n</details>\n")
  }
  if (is_html) {
    parts <- c(parts, paste(readLines("question-map-script.html", warn = FALSE, encoding = "UTF-8"), collapse = "\n"))
  }
  paste(parts, collapse = "\n")
}
