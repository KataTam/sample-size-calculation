# Run from repository root. The PDF is rebuilt only when explicitly requested.
render_resource <- function(include_pdf = FALSE) {
  if (capabilities("cairo")) options(bitmapType = "cairo")
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
  if (length(setdiff(args, "--pdf"))) stop("Usage: Rscript scripts/render_resource.R [--pdf]")
  include_pdf <- "--pdf" %in% args || identical(tolower(Sys.getenv("BUILD_PDF", "false")), "true")
  render_resource(include_pdf = include_pdf)
}
