# Run from repository root. Both editions derive from the same R Markdown.
render_resource <- function() {
  root <- normalizePath(".", winslash = "/", mustWork = TRUE)
  stopifnot(file.exists("module/Sample_size_open_module.Rmd"))
  on.exit(setwd(root), add = TRUE)
  setwd("module")
  input <- "Sample_size_open_module.Rmd"
  rmarkdown::render(input, output_format = bookdown::html_document2(
    toc = TRUE, toc_float = TRUE, number_sections = TRUE,
    self_contained = TRUE, css = "styles.css", highlight = "pygments"),
    output_file = "Sample_size_open_module.html", quiet = TRUE,
    envir = new.env(parent = globalenv()))
  file.copy(input, "index.Rmd", overwrite = TRUE)
  on.exit(unlink(file.path(root, "module/index.Rmd")), add = TRUE)
  bookdown::render_book("index.Rmd", output_format = "bookdown::gitbook",
    quiet = TRUE, envir = new.env(parent = globalenv()))
  file.copy("Sample_size_open_module.html", "../docs/book", overwrite = TRUE)
  setwd(root)
  for (folder in c("teaching", "cases")) {
    target <- file.path("docs", folder)
    dir.create(target, recursive = TRUE, showWarnings = FALSE)
    files <- list.files(folder, full.names = TRUE)
    file.copy(files, target, overwrite = TRUE)
  }
  file.copy(c("LICENSE", "LICENSE-code.md", "CITATION.cff", "THIRD_PARTY_NOTICES.md"),
    "docs", overwrite = TRUE)
  message("Built docs/book/index.html and module/Sample_size_open_module.html")
}
if (identical(environment(), globalenv())) render_resource()
