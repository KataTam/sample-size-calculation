# Presentation helpers; statistical methods live in sample_size_functions.R.
render_app_preview <- function(ids, description, image = NULL) {
  # Calculation and simulation apps start in place on demand. Written planning
  # keeps the study workspace; print and offline readers keep working links.
  cases <- lapply(ids, teaching_case)
  previews <- lapply(cases, function(case) {
    engine <- if (case$app %in% c("two_proportions", "two_means", "power_explorer",
      "dropout_adjustment", "prevalence_precision", "sampling_distributions")) case$app else NULL
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

plot_power_curves <- function(data, target = .90, cap = 100,
                             outcome = "proportions", show_legend = TRUE) {
  old <- par(no.readonly = TRUE)
  on.exit(par(old))
  par(mar = c(4.3, 4.4, 2.8, 1))
  effects <- unique(data$effect)
  colors <- c("#176675", "#a04a24", "#635493")
  plot(range(data$n), c(0, 1), type = "n", xlab = "Analyzable patients per group",
    ylab = "Power (%)", yaxt = "n")
  axis(2, at = seq(0, 1, .2), labels = paste0(seq(0, 100, 20), "%"))
  for (i in seq_along(effects)) {
    rows <- data[data$effect == effects[i], ]
    lines(rows$n, rows$power, lwd = 2, col = colors[i], lty = i)
  }
  abline(h = target, lty = 2, col = "#555555")
  abline(v = cap, lty = 3, col = "#555555")
  text(max(data$n), target - .04, paste0("Target power: ", 100 * target, "%"),
    adj = c(1, 1), cex = .86, col = "#26343d")
  if (cap <= max(data$n)) text(cap, 1.055,
    paste0("Available: ", cap, " per group"), xpd = NA, cex = .86, col = "#26343d")
  for (i in seq_along(effects)) {
    rows <- data[data$effect == effects[i], ]
    if (cap <= max(rows$n)) points(cap, approx(rows$n, rows$power, cap)$y,
      pch = 16, col = colors[i])
    crossing <- which(rows$power >= target)[1]
    if (!is.na(crossing)) points(rows$n[crossing], target, pch = 1, col = colors[i])
  }
  labels <- if (outcome == "proportions") paste(100 * effects, "percentage points") else
    paste(signif(effects, 3), "outcome units")
  if (show_legend) legend("bottomright", legend = labels,
    col = colors[seq_along(effects)], lty = seq_along(effects), lwd = 2,
    bty = "n", cex = .9)
}

draw_assumption_sensitivity <- function(binary, continuous, target = .9) {
  old <- par(no.readonly = TRUE)
  on.exit(par(old))
  par(mfrow = c(1, 2), mar = c(4.3, 4.2, 2.6, .8))
  baseline <- seq(.1, .6, .01)
  difference <- true_difference(binary)
  powers <- vapply(baseline, function(p) {
    x <- binary; x$p_control <- p; x$p_treatment <- p + difference
    spec_power(x)
  }, numeric(1))
  plot(100 * baseline, 100 * powers, type = "l", lwd = 2, col = "#176675",
    ylim = c(0, 100), xlab = "Standard-treatment relief (%)", ylab = "Power (%)",
    main = paste("Fixed difference:", 100 * difference, "points"), cex.main = .95)
  abline(h = 100 * target, lty = 2, col = "#555555")
  points(100 * binary$p_control, 100 * spec_power(binary), pch = 16)
  sds <- seq(4, 9, .1)
  powers <- vapply(sds, function(sd) {
    x <- continuous; x$sd <- sd; spec_power(x)
  }, numeric(1))
  plot(sds, 100 * powers, type = "l", lwd = 2, col = "#635493",
    ylim = c(0, 100), xlab = "Common standard deviation (units)", ylab = "Power (%)",
    main = "Fixed mean difference: 3 units", cex.main = .95)
  abline(h = 100 * target, lty = 2, col = "#555555")
  points(continuous$sd, 100 * spec_power(continuous), pch = 16)
}
