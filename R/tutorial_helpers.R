# Presentation helpers; statistical methods live in sample_size_functions.R.
render_app_preview <- function(ids, description, image = NULL) {
  # These two pilot apps start in place on demand. Other screenshots retain
  # the side-panel workflow; print and offline readers keep a working link.
  cases <- lapply(ids, teaching_case)
  previews <- lapply(cases, function(case) {
    engine <- list(pain_one_many = "power_explorer", probiotics_calculation = "two_proportions")[[case$id]]
    if (!is.null(engine)) {
      url <- paste0("https://katatam.github.io/sample-size-calculation/", engine, "/?activity=", case$id)
      return(htmltools::tags$aside(class = "app-preview inline-activity", `data-inline-app` = engine,
        `data-activity` = case$id, `aria-label` = case$title,
        htmltools::tags$p(class = "app-preview-title", paste0("Activity: ", case$title)),
        htmltools::tags$a(href = url, `data-inline-start` = "", `data-link-navigation` = "same-tab",
          `aria-label` = paste0("Start ", case$title, " here"),
          htmltools::tags$img(class = "app-preview-image",
            src = paste0("../figures/app-previews/", case$id, ".png"),
            alt = paste0("App preview: ", case$title, ". Select to use it here."),
            loading = "lazy", width = 1120, height = 760)),
        htmltools::tags$p(class = "inline-app-link", htmltools::tags$a(href = url,
          `data-inline-dedicated` = "", target = "_blank", rel = "noopener",
          `aria-label` = paste0("Open ", case$title, " on its own page"),
          "Open the app on its own page"))))
    }
    htmltools::tags$aside(
    class = "app-preview", `aria-label` = "App preview",
    htmltools::tags$p(class = "app-preview-title", paste0("Activity: ", case$title)),
    htmltools::tags$a(href = paste0("https://katatam.github.io/sample-size-calculation/study/?activity=", case$id),
      `data-preview-open` = case$id, `data-link-navigation` = "same-tab",
      `aria-label` = paste0("Open ", case$title, " beside the tutorial"),
      htmltools::tags$img(class = "app-preview-image",
        src = paste0("../figures/app-previews/", case$id, ".png"),
        alt = paste0("Screenshot of ", case$title, ": inputs and current app view"),
        loading = "lazy", width = 1120, height = 760)))
  })
  markup <- as.character(htmltools::tagList(previews))
  # Pandoc interprets four-space HTML indentation as a code block in R Markdown.
  cat(gsub("\n[ \t]+", "\n", markup), "\n")
}

percent <- function(x, digits = 1) {
  paste0(formatC(100 * x, format = "f", digits = digits), "%")
}

display_probabilities <- function(x, probabilities = character(), points = character()) {
  stopifnot(all(c(probabilities, points) %in% names(x)))
  for (column in probabilities) x[[column]] <- percent(x[[column]])
  for (column in points) x[[column]] <- paste0(formatC(100 * x[[column]],
    format = "f", digits = 1), " percentage points")
  names(x)[names(x) == "alpha"] <- "Type I error probability"
  names(x)[names(x) == "beta"] <- "Type II error probability"
  names(x) <- gsub("_", " ", names(x), fixed = TRUE)
  x
}

display_simulation_summary <- function(x) {
  data.frame(Measure = c("Statistically significant simulated results", "Intervals containing the true effect (coverage)", "Intervals meeting the target width"), Percentage = percent(x$estimate),
    `Simulation uncertainty: Monte Carlo SE (percentage points)` = formatC(100 * x$MCSE,
      format = "f", digits = 2),
    `95% lower limit` = percent(x$MC_lower_95),
    `95% upper limit` = percent(x$MC_upper_95), check.names = FALSE)
}

power_row <- function(batch) {
  p <- mean(batch$results$reject)
  B <- nrow(batch$results)
  interval <- wilson_interval(p, B)
  data.frame(n_per_group = batch$spec$n, total = 2 * batch$spec$n,
    replications = B, simulated_power = p,
    MC_lower_95 = interval[1, 1], MC_upper_95 = interval[1, 2])
}

plot_p_values <- function(batch) {
  values <- batch$results$p_value
  hist(values, breaks = seq(0, 1, .025), col = "#d2e6e9", border = "white",
    main = sprintf("%s per group; statistically significant results %.1f%%",
      batch$spec$n, 100 * mean(batch$results$reject)),
    xlab = "p-value", ylab = "Number of studies", xlim = c(0, 1))
  abline(v = batch$spec$alpha, lty = 2, lwd = 2, col = "#923d20")
}

power_curve_data <- function(spec, effects, ns) {
  do.call(rbind, lapply(effects, function(effect) {
    x <- spec
    if (x$outcome == "means") x$delta <- effect
    else x$p_treatment <- x$p_control + effect
    x <- do.call(study_spec, x)
    data.frame(effect = effect, n = ns,
      power = vapply(ns, function(n) spec_power(x, n), numeric(1)))
  }))
}

plot_power_curves <- function(data, target = .90, cap = 90) {
  effects <- unique(data$effect)
  colors <- c("#176675", "#a04a24", "#635493")
  plot(range(data$n), c(0, 1), type = "n", xlab = "Participants for analysis, per group",
    ylab = "Power (%)", yaxt = "n")
  axis(2, at = seq(0, 1, .2), labels = paste0(seq(0, 100, 20), "%"))
  for (i in seq_along(effects)) {
    rows <- data[data$effect == effects[i], ]
    lines(rows$n, rows$power, lwd = 2, col = colors[i], lty = i)
  }
  abline(h = target, lty = 2, col = "#555555")
  abline(v = cap, lty = 3, col = "#555555")
  legend("bottomright", legend = paste(100 * effects, "percentage points"),
    col = colors[seq_along(effects)], lty = seq_along(effects), lwd = 2,
    bty = "n", cex = .9)
}
