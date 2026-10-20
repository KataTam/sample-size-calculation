# One question bank supplies the embedded HTML checks and printable answer keys.
render_chapter_quiz <- function(chapter = "all") {
  bank <- jsonlite::fromJSON("../site/quiz/questions.json", simplifyVector = FALSE)
  questions <- Filter(function(q) chapter == "all" || q$chapter == chapter, bank$questions)
  esc <- function(x) {
    escaped <- as.character(htmltools::htmlEscape(as.character(x), attribute = TRUE))
    # ASCII HTML entities survive Windows rendering locales without losing punctuation.
    paste(vapply(utf8ToInt(enc2utf8(escaped)), function(cp) {
      if (cp > 127L) sprintf("&#%d;", cp) else intToUtf8(cp)
    }, character(1)), collapse = "")
  }
  id <- paste0("quiz-", chapter)
  levels <- unique(vapply(questions, `[[`, character(1), "level"))
  default <- if ("core" %in% levels) "core" else "all"
  cat(sprintf('<div class="chapter-quiz" id="%s" data-default-route="%s">\n', id, default))
  if (length(levels) > 1) {
    cat(sprintf('<div class="quiz-controls"><label for="%s-route">Route</label> <select id="%s-route" class="quiz-route"><option value="core">Core</option><option value="all">Core + advanced</option></select></div>\n', id, id))
  }
  cat('<form class="embedded-quiz-form"><div class="quiz-questions">\n')
  for (i in seq_along(questions)) {
    q <- questions[[i]]
    name <- paste(id, q$id, sep = "-")
    cat(sprintf('<fieldset data-question="%s" data-level="%s" data-answer="%s" data-topic="%s"><legend><span class="quiz-number">%s</span>. %s</legend>\n', esc(q$id), q$level, q$answer, esc(bank$chapters[[q$chapter]]), i, esc(q$question)))
    if (q$level == "advanced") cat('<p class="quiz-level">Advanced</p>\n')
    for (j in seq_along(q$options)) {
      cat(sprintf('<label class="quiz-option"><input type="radio" name="%s" value="%s" required> <span>%s. %s</span></label>\n',
                  name, j - 1L, LETTERS[j], esc(q$options[[j]])))
    }
    cat('</fieldset>\n')
  }
  cat('</div><p class="quiz-progress quiz-controls" aria-live="polite"></p><button type="submit" class="quiz-controls">View results</button></form>\n')
  cat('<div class="quiz-results" hidden><p class="quiz-score" tabindex="-1"></p><div class="quiz-topics"></div><button type="button" class="quiz-retry">Retry missed questions</button> <button type="button" class="quiz-reset">Try again</button></div>\n')
  cat('<details class="quiz-answer-key"><summary>Answers and explanations</summary>\n')
  for (i in seq_along(questions)) {
    q <- questions[[i]]
    cat(sprintf('<div class="quiz-answer" data-question="%s" data-level="%s"><p class="quiz-answer-title"><span class="quiz-number">%s</span>. %s</p><p class="quiz-choice"></p><p>Correct answer: %s. %s</p><p>%s</p><a href="https://katatam.github.io/sample-size-calculation/book/%s" target="_blank" rel="noopener">Review: %s</a></div>\n',
                esc(q$id), q$level, i, esc(q$question), LETTERS[q$answer + 1L], esc(q$options[[q$answer + 1L]]), esc(q$explanation), esc(q$link), esc(q$section)))
  }
  cat('</details></div>\n')
}
