# Run from repository root. Keep the complete PDF aligned with the HTML by default.
render_resource <- function(include_pdf = TRUE) {
  if (capabilities("cairo")) options(bitmapType = "cairo")
  root <- normalizePath(".", winslash = "/", mustWork = TRUE)
  stopifnot(file.exists("module/Sample_size_open_module.Rmd"))
  source("R/draw_learning_figures.R")
  draw_learning_figures()
  on.exit(setwd(root), add = TRUE)
  glossary_json <- paste(readLines("data/glossary-terms.json", encoding = "UTF-8"), collapse = "\n")
  glossary_js <- paste(readLines("module/glossary-tooltips.js", encoding = "UTF-8"), collapse = "\n")
  writeLines(paste0('<script type="application/json" id="glossary-definitions">', glossary_json,
    '</script>\n<script>', glossary_js, '</script>'), "module/glossary-support.html", useBytes = TRUE)
  menu_json <- paste(readLines("module/activity-contents.json", encoding = "UTF-8"), collapse = "\n")
  moved_json <- paste(readLines("module/moved-sections.json", encoding = "UTF-8"), collapse = "\n")
  reading_js <- paste(readLines("module/reading-support.js", encoding = "UTF-8"), collapse = "\n")
  cat(paste0('<script type="application/json" id="moved-section-data">', moved_json,
    '</script>\n<script type="application/json" id="activity-menu-data">', menu_json,
    '</script>\n<script>', reading_js, '</script>'), file = "module/glossary-support.html", append = TRUE)
  quiz_js <- paste(readLines("module/chapter-quiz.js", encoding = "UTF-8"), collapse = "\n")
  cat(paste0('<script>', quiz_js, '</script>'), file = "module/glossary-support.html", append = TRUE)
  accessibility_js <- paste(readLines("module/accessibility.js", encoding = "UTF-8"), collapse = "\n")
  cat(paste0('<script>', accessibility_js, '</script>'), file = "module/glossary-support.html", append = TRUE)
  setwd("module")
  input <- "Sample_size_open_module.Rmd"
  rmarkdown::render(input, output_format = bookdown::html_document2(
    toc = TRUE, toc_float = TRUE, number_sections = TRUE,
    self_contained = TRUE, css = "styles.css", highlight = "pygments",
    code_folding = "none", includes = rmarkdown::includes(after_body = c("toolbar-help.html", "glossary-support.html"))),
    output_file = "Sample_size_open_module.html", quiet = TRUE,
    envir = new.env(parent = globalenv()))
  file.copy(input, "index.Rmd", overwrite = TRUE)
  on.exit(unlink(file.path(root, "module/index.Rmd")), add = TRUE)
  bookdown::render_book("index.Rmd", output_format = "bookdown::gitbook",
    quiet = TRUE, envir = new.env(parent = globalenv()))
  file.copy("Sample_size_open_module.html", "../docs/book", overwrite = TRUE)
  if (isTRUE(include_pdf)) {
    # Release the HTML render's working environment before compiling the PDF.
    knitr::knit_global(new.env(parent = globalenv()))
    invisible(gc())
    if (!nzchar(Sys.which("xelatex"))) {
      stop("The print edition requires XeLaTeX. Install TinyTeX or render_resource(include_pdf = FALSE) for HTML only.")
    }
    rmarkdown::render(input, output_format = bookdown::pdf_document2(
      toc = TRUE, toc_depth = 2, number_sections = TRUE,
      latex_engine = "xelatex", keep_tex = FALSE, fig_caption = TRUE, fig_crop = FALSE,
      includes = rmarkdown::includes(in_header = "pdf-header.tex"),
      pandoc_args = c("-V", "geometry:margin=22mm", "-V", "fontsize:11pt")),
      output_file = "Sample_size_open_module.pdf", quiet = TRUE,
      envir = new.env(parent = globalenv()))
    file.copy("Sample_size_open_module.pdf", "../docs/book", overwrite = TRUE)
  }
  setwd(root)
  message("Built chaptered and standalone HTML", if (include_pdf) " and printable PDF" else "")
}
if (identical(environment(), globalenv())) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(setdiff(args, c("--pdf", "--html"))) || all(c("--pdf", "--html") %in% args)) {
    stop("Usage: Rscript scripts/render_resource.R [--pdf | --html]")
  }
  include_pdf <- !"--html" %in% args &&
    ("--pdf" %in% args || !identical(tolower(Sys.getenv("BUILD_PDF", "true")), "false"))
  render_resource(include_pdf = include_pdf)
}
