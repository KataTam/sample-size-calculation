# Inline reading checks share their wording and printable answers with the HTML.
render_consider_check <- function(id) {
  bank <- jsonlite::fromJSON("../data/consider-checks.json", simplifyVector = FALSE)
  matches <- Filter(function(x) identical(x$id, id), bank$checks)
  if (length(matches) != 1L) stop("Unknown reading check: ", id)
  q <- matches[[1]]
  tags <- htmltools::tags
  text <- function(x) {
    points <- utf8ToInt(enc2utf8(htmltools::htmlEscape(x)))
    htmltools::HTML(paste0(ifelse(points > 127, paste0("&#", points, ";"),
      intToUtf8(points, multiple = TRUE)), collapse = ""))
  }
  answer <- if (isTRUE(q$answer)) "Yes" else "No"
  calculator <- if (!is.null(q$calculator)) tags$form(class = "consider-calculator", hidden = NA,
    tags$p(class = "consider-calculator-title", "Mini calculator"),
    tags$label(`for` = paste0(id, "-expression"), "Calculation"),
    tags$div(class = "consider-calculator-controls",
      tags$input(id = paste0(id, "-expression"), type = "text", maxlength = 160,
        value = q$calculator$expression, autocomplete = "off", spellcheck = "false",
        `aria-describedby` = paste0(id, "-calculator-help")),
      tags$button(type = "submit", "Calculate"),
      if (isTRUE(q$calculator$round_up)) tags$button(type = "button", class = "consider-round", disabled = NA, "Round up"),
      tags$button(type = "button", class = "consider-clear", "Clear")),
    tags$p(class = "consider-calculator-help", id = paste0(id, "-calculator-help"),
      "5% = 0.05. Use ^ for powers."),
    tags$output(class = "consider-calculator-result", `for` = paste0(id, "-expression"), `aria-live` = "polite"))
  widget <- tags$div(class = "activity consider-check", id = id,
    `data-correct` = tolower(answer),
    lapply(q$aliases, function(alias) tags$span(id = alias)),
    tags$p(class = "question-label", "Question to consider"),
    tags$p(class = "consider-question", id = paste0(id, "-question"), text(q$question)),
    calculator,
    tags$fieldset(class = "consider-choices", hidden = NA, `aria-labelledby` = paste0(id, "-question"),
      tags$legend(class = "consider-sr-only", "Choose Yes or No"),
      lapply(c("Yes", "No"), function(choice) tags$label(
        tags$input(type = "radio", name = paste0(id, "-choice"), value = tolower(choice)), text(choice)))),
    tags$div(class = "consider-answer", role = "status", `aria-live` = "polite", `aria-atomic` = "true",
      tags$p(class = "consider-result"),
      tags$p(class = "consider-explanation", text(paste0(answer, ". ", q$feedback))),
      if (!is.null(q$calculator)) tags$p(class = "consider-working", text(paste0("Calculation: ", q$calculator$working)))))
  cat(gsub("[\r\n]+[ ]*", "", as.character(widget)), "\n\n", sep = "")
}
