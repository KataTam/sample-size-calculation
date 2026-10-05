# Presentation helpers; statistical methods live in sample_size_functions.R.
percent <- function(x, digits = 1) {
  paste0(formatC(100 * x, format = "f", digits = digits), "%")
}

display_probabilities <- function(x, probabilities = character(), points = character()) {
  stopifnot(all(c(probabilities, points) %in% names(x)))
  for (column in probabilities) x[[column]] <- percent(x[[column]])
  for (column in points) x[[column]] <- paste0(formatC(100 * x[[column]],
    format = "f", digits = 1), " percentage points")
  names(x)[names(x) == "alpha"] <- "Type I error rate"
  names(x)[names(x) == "beta"] <- "Type II error rate"
  names(x) <- gsub("_", " ", names(x), fixed = TRUE)
  x
}

display_simulation_summary <- function(x) {
  data.frame(Measure = x$measure, Rate = percent(x$estimate),
    `Monte Carlo SE (percentage points)` = formatC(100 * x$MCSE,
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
    main = sprintf("%s per group; rejection fraction %.1f%%",
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
  colours <- c("#176675", "#a04a24", "#635493")
  plot(range(data$n), c(0, 1), type = "n", xlab = "Analysable patients per group",
    ylab = "Power (%)", yaxt = "n")
  axis(2, at = seq(0, 1, .2), labels = paste0(seq(0, 100, 20), "%"))
  for (i in seq_along(effects)) {
    rows <- data[data$effect == effects[i], ]
    lines(rows$n, rows$power, lwd = 2, col = colours[i], lty = i)
  }
  abline(h = target, lty = 2, col = "#555555")
  abline(v = cap, lty = 3, col = "#555555")
  legend("bottomright", legend = paste(100 * effects, "percentage points"),
    col = colours[seq_along(effects)], lty = seq_along(effects), lwd = 2,
    bty = "n", cex = .9)
}
