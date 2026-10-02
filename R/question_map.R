# The map and print edition share the same author-provided original excerpts.
render_question_map <- function() {
  content <- jsonlite::fromJSON("../data/question-map.json", simplifyVector = FALSE)
  is_html <- knitr::is_html_output()
  parts <- character()
  if (is_html) {
    svg <- paste(readLines("../figures/study_questions.svg", warn = FALSE, encoding = "UTF-8"), collapse = "\n")
    svg <- sub("^<\\?xml[^>]*>\\s*", "", svg)
    parts <- c(parts, '<div class="question-map" aria-label="Seven questions for planning sample size">',
      svg, '\n</div>\n')
  } else {
    parts <- c(parts, '![Seven questions for determining the minimum required sample size. The explanations follow below.](../figures/study_questions.png){width=100%}')
  }
  for (i in seq_along(content$questions)) {
    question <- content$questions[[i]]
    id <- paste0("sample-size-question-", question$id)
    if (is_html) {
      parts <- c(parts, sprintf('<details class="question-map-info" id="%s">\n<summary><span class="question-map-info-icon" aria-hidden="true">i</span> %s. %s</summary>\n', id, i, question$question))
    } else {
      parts <- c(parts, sprintf("\n### %s. %s {.unnumbered}\n", i, question$question))
    }
    paragraphs <- strsplit(question$original_excerpt, "\n\n", fixed = TRUE)[[1]]
    parts <- c(parts, paste0("\n", paste(paste0("> ", paragraphs), collapse = "\n>\n"), "\n"))
    if (!is.null(question$clarification)) {
      parts <- c(parts, paste0("\n**Planning clarification.** ", question$clarification, "\n"))
    }
    if (is_html) parts <- c(parts, "\n</details>\n")
  }
  if (is_html) {
    parts <- c(parts, paste(readLines("question-map-script.html", warn = FALSE, encoding = "UTF-8"), collapse = "\n"))
  }
  paste(parts, collapse = "\n")
}
