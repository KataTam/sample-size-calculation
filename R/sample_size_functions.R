# Reusable functions for sample size teaching examples.

check_probability <- function(x, name, lower = 0, upper = 1) {
  if (!is.numeric(x) || length(x) != 1 || !is.finite(x) || x <= lower || x >= upper) {
    stop(name, " must be a single number between ", lower, " and ", upper, ".", call. = FALSE)
  }
  invisible(TRUE)
}

check_nonnegative_probability <- function(x, name, upper = 1) {
  if (!is.numeric(x) || length(x) != 1 || !is.finite(x) || x < 0 || x >= upper) {
    stop(name, " must be a single number from 0 up to, but not including, ", upper, ".", call. = FALSE)
  }
  invisible(TRUE)
}

check_positive_number <- function(x, name) {
  if (!is.numeric(x) || length(x) != 1 || !is.finite(x) || x <= 0) {
    stop(name, " must be a single positive number.", call. = FALSE)
  }
  invisible(TRUE)
}

multiplier_alpha_power <- function(alpha = 0.05, power = 0.90) {
  check_probability(alpha, "alpha")
  check_probability(power, "power")
  beta <- 1 - power
  (qnorm(1 - alpha / 2) + qnorm(1 - beta))^2
}

sample_size_two_proportions_raw <- function(pi1, pi2, alpha = 0.05, power = 0.90) {
  check_probability(pi1, "pi1")
  check_probability(pi2, "pi2")
  if (pi1 == pi2) {
    stop("pi1 and pi2 must be different.", call. = FALSE)
  }
  f_ab <- multiplier_alpha_power(alpha, power)
  f_ab * (pi1 * (1 - pi1) + pi2 * (1 - pi2)) / (pi1 - pi2)^2
}

sample_size_two_proportions <- function(pi1, pi2, alpha = 0.05, power = 0.90) {
  ceiling(sample_size_two_proportions_raw(pi1, pi2, alpha, power))
}

sample_size_two_proportions_details <- function(pi1, pi2, alpha = 0.05, power = 0.90,
                                                dropout_rate = 0) {
  check_nonnegative_probability(dropout_rate, "dropout_rate")
  raw_n <- sample_size_two_proportions_raw(pi1, pi2, alpha, power)
  n_per_group <- ceiling(raw_n)
  total_n <- 2 * n_per_group
  total_with_dropout <- 2 * adjust_for_dropout(n_per_group, dropout_rate)
  list(
    outcome_type = "two proportions",
    pi1 = pi1,
    pi2 = pi2,
    difference = abs(pi1 - pi2),
    alpha = alpha,
    power = power,
    multiplier = multiplier_alpha_power(alpha, power),
    raw_n_per_group = raw_n,
    n_per_group = n_per_group,
    total_n = total_n,
    dropout_rate = dropout_rate,
    total_with_dropout = total_with_dropout
  )
}

sample_size_two_means_raw <- function(delta, sd, alpha = 0.05, power = 0.90) {
  check_positive_number(delta, "delta")
  check_positive_number(sd, "sd")
  f_ab <- multiplier_alpha_power(alpha, power)
  2 * f_ab * sd^2 / delta^2
}

sample_size_two_means <- function(delta, sd, alpha = 0.05, power = 0.90) {
  ceiling(sample_size_two_means_raw(delta, sd, alpha, power))
}

sample_size_two_means_details <- function(delta, sd, alpha = 0.05, power = 0.90,
                                          dropout_rate = 0) {
  check_nonnegative_probability(dropout_rate, "dropout_rate")
  raw_n <- sample_size_two_means_raw(delta, sd, alpha, power)
  n_per_group <- ceiling(raw_n)
  total_n <- 2 * n_per_group
  total_with_dropout <- 2 * adjust_for_dropout(n_per_group, dropout_rate)
  list(
    outcome_type = "two means",
    delta = delta,
    sd = sd,
    alpha = alpha,
    power = power,
    multiplier = multiplier_alpha_power(alpha, power),
    raw_n_per_group = raw_n,
    n_per_group = n_per_group,
    total_n = total_n,
    dropout_rate = dropout_rate,
    total_with_dropout = total_with_dropout
  )
}

# Both rejection tails are counted. These methods differ from the simple
# normal sample-size approximations above; see teaching/statistical_methods.md.
power_two_proportions <- function(n_per_group, pi1, pi2, alpha = 0.05) {
  check_integer(n_per_group, "n_per_group", 2)
  check_probability(pi1, "pi1")
  check_probability(pi2, "pi2")
  check_probability(alpha, "alpha")
  stats::power.prop.test(n = n_per_group, p1 = pi1, p2 = pi2,
    sig.level = alpha, alternative = "two.sided", strict = TRUE)$power
}

power_two_means <- function(n_per_group, delta, sd, alpha = 0.05) {
  check_integer(n_per_group, "n_per_group", 2)
  check_scalar(delta, "delta")
  check_positive_number(sd, "sd")
  check_probability(alpha, "alpha")
  stats::power.t.test(n = n_per_group, delta = abs(delta), sd = sd,
    sig.level = alpha, type = "two.sample", alternative = "two.sided",
    strict = TRUE)$power
}

adjust_for_dropout <- function(n, dropout_rate) {
  check_positive_number(n, "n")
  check_nonnegative_probability(dropout_rate, "dropout_rate")
  ceiling(n / (1 - dropout_rate))
}

format_percent <- function(x, digits = 0) {
  paste0(round(100 * x, digits), "%")
}

sample_size_interpretation <- function(result) {
  if (result$dropout_rate > 0) {
    paste0(
      "The approximate planning sample size is ", result$n_per_group,
      " participants per group, or ", result$total_n,
      " participants before dropout adjustment. With ",
      format_percent(result$dropout_rate),
      " expected dropout, the recruitment target is ",
      result$total_with_dropout, " participants."
    )
  } else {
    paste0(
      "The approximate planning sample size is ", result$n_per_group,
      " participants per group, or ", result$total_n,
      " participants in total."
    )
  }
}

parameter_grid_two_proportions <- function(pi1_values, pi2, alpha = 0.05, power = 0.90) {
  data.frame(
    pi1 = pi1_values,
    pi2 = pi2,
    alpha = alpha,
    power = power,
    n_per_group = vapply(
      pi1_values,
      sample_size_two_proportions,
      numeric(1),
      pi2 = pi2,
      alpha = alpha,
      power = power
    )
  )
}

parameter_grid_two_means <- function(delta_values, sd, alpha = 0.05, power = 0.90) {
  data.frame(
    delta = delta_values,
    sd = sd,
    alpha = alpha,
    power = power,
    n_per_group = vapply(
      delta_values,
      sample_size_two_means,
      numeric(1),
      sd = sd,
      alpha = alpha,
      power = power
    )
  )
}


check_scalar <- function(x, name) {
  if (!is.numeric(x) || length(x) != 1 || !is.finite(x))
    stop(name, " must be a finite number.", call. = FALSE)
  invisible(TRUE)
}

check_integer <- function(x, name, minimum = 1, maximum = 1e7) {
  check_scalar(x, name)
  if (x != floor(x) || x < minimum || x > maximum)
    stop(name, " must be an integer from ", minimum, " to ", maximum, ".", call. = FALSE)
  invisible(TRUE)
}

# Closed-form benchmark for known-variance, two-sided normal testing.
power_normal_known <- function(n, delta, sd, alpha = .05) {
  check_integer(n, "n", 2); check_scalar(delta, "delta")
  check_positive_number(sd, "sd"); check_probability(alpha, "alpha")
  signal <- abs(delta) / (sd * sqrt(2 / n))
  critical <- qnorm(1 - alpha / 2)
  pnorm(signal - critical) + pnorm(-signal - critical)
}

study_spec <- function(outcome = "means", n = 60, delta = 3, sd = 5,
                       p_control = .3, p_treatment = .6, alpha = .05,
                       threshold = 2, width_target = 4, seed = 20260914,
                       B = 1000, benefit_direction = 1) {
  if (!outcome %in% c("means", "proportions")) stop("Unknown outcome.")
  check_integer(n, "Participants per group", 2, 100000)
  check_integer(B, "Replications", 1, 100000)
  check_integer(seed, "Seed", 0, .Machine$integer.max)
  check_scalar(delta, "True difference assumed for simulation"); check_positive_number(sd, "Standard deviation assumed for simulation")
  check_probability(alpha, "alpha"); check_probability(p_control, "Control probability")
  check_probability(p_treatment, "Treatment probability")
  check_positive_number(threshold, "Clinical threshold magnitude")
  check_positive_number(width_target, "Full interval width target")
  if (!benefit_direction %in% c(-1, 1)) stop("Benefit direction must be -1 or 1.")
  list(outcome = outcome, n = n, delta = delta, sd = sd, p_control = p_control,
       p_treatment = p_treatment, alpha = alpha, threshold = threshold,
       width_target = width_target, seed = seed, B = B, benefit_direction = benefit_direction)
}

method_label <- function(outcome) {
  if (outcome == "means") "Two-sided pooled-variance t test; t confidence interval"
  else "Two-sided pooled score test without continuity correction; Newcombe-Wilson difference interval"
}

true_difference <- function(spec) {
  if (spec$outcome == "means") spec$delta else spec$p_treatment - spec$p_control
}

with_study_seed <- function(seed, code) {
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) old <- get(".Random.seed", envir = .GlobalEnv)
  on.exit(if (had_seed) assign(".Random.seed", old, envir = .GlobalEnv)
          else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
            rm(".Random.seed", envir = .GlobalEnv))
  set.seed(seed)
  force(code)
}

wilson_interval <- function(p, n, alpha = .05) {
  z <- qnorm(1 - alpha / 2)
  center <- (p + z^2 / (2 * n)) / (1 + z^2 / n)
  half <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / (1 + z^2 / n)
  cbind(lower = pmax(0, center - half), upper = pmin(1, center + half))
}

analyse_binary <- function(treatment_count, control_count, n, alpha) {
  p1 <- treatment_count / n; p0 <- control_count / n
  estimate <- p1 - p0; pooled <- (p1 + p0) / 2
  se_null <- sqrt(2 * pooled * (1 - pooled) / n)
  z <- ifelse(se_null > 0, estimate / se_null, 0)
  w1 <- wilson_interval(p1, n, alpha); w0 <- wilson_interval(p0, n, alpha)
  lower <- estimate - sqrt((p1 - w1[, "lower"])^2 + (w0[, "upper"] - p0)^2)
  upper <- estimate + sqrt((w1[, "upper"] - p1)^2 + (p0 - w0[, "lower"])^2)
  data.frame(estimate = estimate, lower = pmax(-1, lower), upper = pmin(1, upper),
             p_value = 2 * pnorm(-abs(z)))
}

analyse_normal <- function(estimate, pooled_sd, n, alpha) {
  se <- pooled_sd * sqrt(2 / n); df <- 2 * n - 2
  half <- qt(1 - alpha / 2, df) * se
  data.frame(estimate = estimate, lower = estimate - half, upper = estimate + half,
             p_value = 2 * pt(-abs(estimate / se), df))
}

add_operating_results <- function(results, spec) {
  results$width <- results$upper - results$lower
  results$reject <- results$p_value < spec$alpha
  truth <- true_difference(spec)
  results$cover <- results$lower <= truth & results$upper >= truth
  results$width_met <- results$width <= spec$width_target
  results
}

simulate_one_study <- function(spec) {
  with_study_seed(spec$seed, {
    n <- spec$n
    if (spec$outcome == "means") {
      control <- rnorm(n, 0, spec$sd); treatment <- rnorm(n, spec$delta, spec$sd)
      result <- analyse_normal(mean(treatment) - mean(control),
        sqrt((var(treatment) + var(control)) / 2), n, spec$alpha)
    } else {
      control <- rbinom(n, 1, spec$p_control); treatment <- rbinom(n, 1, spec$p_treatment)
      result <- analyse_binary(sum(treatment), sum(control), n, spec$alpha)
    }
    list(data = data.frame(group = rep(c("Control", "Treatment"), each = n),
                          outcome = c(control, treatment)),
         result = add_operating_results(result, spec), spec = spec)
  })
}

simulate_trials <- function(spec) {
  # Normal sufficient statistics have the same distribution as analyzing B full
  # independent normal datasets. This avoids storing B * 2n patient records.
  with_study_seed(spec$seed, {
    n <- spec$n; B <- spec$B
    if (spec$outcome == "means") {
      estimates <- rnorm(B, spec$delta, spec$sd * sqrt(2 / n))
      pooled_sd <- spec$sd * sqrt(rchisq(B, 2 * n - 2) / (2 * n - 2))
      results <- analyse_normal(estimates, pooled_sd, n, spec$alpha)
    } else {
      results <- analyse_binary(rbinom(B, n, spec$p_treatment),
                                rbinom(B, n, spec$p_control), n, spec$alpha)
    }
    list(results = add_operating_results(results, spec), spec = spec)
  })
}

simulation_summary <- function(batch) {
  x <- batch$results; B <- nrow(x)
  rates <- c(mean(x$reject), mean(x$cover), mean(x$width_met))
  intervals <- wilson_interval(rates, B)
  data.frame(measure = c("Rejection rate", "CI coverage", "Full width target met"),
    estimate = rates, MCSE = sqrt(rates * (1 - rates) / B),
    MC_lower_95 = intervals[, 1], MC_upper_95 = intervals[, 2])
}

anticipated_width <- function(spec, n = spec$n) {
  if (spec$outcome == "means") {
    # Expected pooled SD = sigma * c4(df); this gives the expected t CI width.
    df <- 2 * n - 2
    c4 <- sqrt(2 / df) * exp(lgamma((df + 1) / 2) - lgamma(df / 2))
    2 * qt(1 - spec$alpha / 2, df) * spec$sd * sqrt(2 / n) * c4
  } else {
    # Plug-in anticipated width at assumed proportions, not expected width.
    x <- analyse_binary(spec$p_treatment * n, spec$p_control * n, n, spec$alpha)
    x$upper - x$lower
  }
}

spec_power <- function(spec, n = spec$n) {
  if (spec$outcome == "means") power_two_means(n, spec$delta, spec$sd, spec$alpha)
  else power_two_proportions(n, spec$p_treatment, spec$p_control, spec$alpha)
}

plan_n <- function(spec, goal = "testing", target_power = .8, maximum = 100000) {
  if (goal == "fixed") return(spec$n)
  check_probability(target_power, "Target power")
  if (goal == "testing" && abs(true_difference(spec)) < 1e-12)
    stop("A zero target difference cannot define a sample size for detecting a difference.", call. = FALSE)
  if (!goal %in% c("testing", "precision")) stop("Unknown planning goal.")
  meets <- function(n) if (goal == "testing") spec_power(spec, n) >= target_power
                       else anticipated_width(spec, n) <= spec$width_target
  if (!meets(maximum)) stop("This goal needs more than 100,000 participants per group; reconsider the plan.", call. = FALSE)
  lo <- 2; hi <- maximum
  while (lo < hi) {
    mid <- floor((lo + hi) / 2)
    if (meets(mid)) hi <- mid else lo <- mid + 1
  }
  lo
}

interval_interpretation <- function(result, spec) {
  if (spec$benefit_direction == 1) { low <- result$lower; high <- result$upper }
  else { low <- -result$upper; high <- -result$lower }
  test <- if (result$p_value < spec$alpha) "The test rejects a zero difference. "
          else "The test does not reject a zero difference; this does not establish no effect. "
  clinical <- if (low > spec$threshold) "The interval lies beyond the beneficial clinical threshold."
    else if (low > 0) "The interval excludes zero in the beneficial direction, but includes benefits below the clinical threshold."
    else if (high >= spec$threshold) "The interval includes both zero or harm and clinically important benefit."
    else "The interval does not extend to the specified beneficial threshold; consider the full interval, including possible harm."
  paste0(test, clinical, " Interpret uncertainty in context; this is not a prespecified equivalence or non-inferiority test.")
}

plot_trial_intervals <- function(results, spec, max_display = 30) {
  x <- head(results, max_display); y <- seq_len(nrow(x))
  # Rescale the display only; methods, input values and returned data stay unchanged.
  scale <- if (spec$outcome == "proportions") 100 else 1
  clinical <- scale * spec$threshold * spec$benefit_direction
  truth <- scale * true_difference(spec)
  limits <- range(c(scale * x$lower, scale * x$upper, 0, clinical, truth))
  plot(scale * x$estimate, y, xlim = limits, ylim = c(.5, nrow(x) + .5),
       pch = ifelse(x$reject, 19, 1),
       xlab = if (spec$outcome == "proportions") "Treatment minus control (percentage points)" else "Treatment minus control (outcome units)", ylab = "Study",
       main = "Intervals from individual studies")
  segments(scale * x$lower, y, scale * x$upper, y)
  abline(v = 0, lty = 1, col = "grey40")
  abline(v = clinical, lty = 2, col = "#9a3412")
  abline(v = truth, lty = 3, col = "#075985")
  legend("topright", c("Zero", "Clinical threshold", "Assumed true effect"),
         lty = 1:3, col = c("grey40", "#9a3412", "#075985"), cex = .75, bg = "white")
}

# Single-proportion precision: the requested target is always FULL CI width.
# This is the usual normal approximation for an independently sampled proportion,
# not a guarantee for the realized Wilson width or coverage under biased sampling.
check_unit_probability <- function(x, name) {
  check_scalar(x, name)
  if (x < 0 || x > 1) stop(name, " must be between 0 and 1 inclusive.", call. = FALSE)
  invisible(TRUE)
}

proportion_precision_plan <- function(p = .20, full_width = .10, confidence = .95,
                                      unknown_p = FALSE, dropout_rate = 0) {
  check_unit_probability(p, "Anticipated proportion")
  check_positive_number(full_width, "Full interval width")
  if (full_width > 1) stop("Full interval width cannot exceed 1.", call. = FALSE)
  check_probability(confidence, "Confidence level")
  check_nonnegative_probability(dropout_rate, "Expected loss fraction")
  if (!is.logical(unknown_p) || length(unknown_p) != 1 || is.na(unknown_p))
    stop("Unknown-proportion choice must be TRUE or FALSE.", call. = FALSE)
  planning_p <- if (unknown_p) .5 else p
  if (planning_p %in% c(0, 1)) stop(
    "A planning proportion of 0 or 1 gives a degenerate normal approximation. Use a justified non-boundary range or the unknown-proportion option.",
    call. = FALSE)
  half_width <- full_width / 2
  raw_n <- qnorm((1 + confidence) / 2)^2 * planning_p * (1 - planning_p) / half_width^2
  n <- ceiling(raw_n)
  check_integer(n, "Calculated analyzable sample size", 1, 1e7)
  list(anticipated_p = p, planning_p = planning_p, unknown_p = unknown_p,
    full_width = full_width, half_width = half_width, confidence = confidence,
    raw_n = raw_n, n = n, dropout_rate = dropout_rate,
    recruitment_n = adjust_for_dropout(n, dropout_rate),
    expected_events = n * planning_p, expected_nonevents = n * (1 - planning_p),
    sparse = min(n * planning_p, n * (1 - planning_p)) < 10,
    method = "Normal approximation for single-proportion precision; rounded upward")
}

single_proportion_interval <- function(events, n, confidence = .95) {
  check_integer(n, "Analyzable sample size", 1, 1e7)
  check_integer(events, "Observed event count", 0, n)
  check_probability(confidence, "Confidence level")
  estimate <- events / n
  limits <- wilson_interval(estimate, n, alpha = 1 - confidence)
  data.frame(events = events, n = n, estimate = estimate,
    lower = limits[1, "lower"], upper = limits[1, "upper"],
    full_width = limits[1, "upper"] - limits[1, "lower"])
}

simulate_proportion_study <- function(n, p, confidence = .95, seed = 20260942) {
  check_integer(n, "Analyzable sample size", 1, 1e7)
  check_unit_probability(p, "Event rate assumed for simulation")
  check_probability(confidence, "Confidence level")
  check_integer(seed, "Seed", 0, .Machine$integer.max)
  result <- with_study_seed(seed, {
    single_proportion_interval(rbinom(1, n, p), n, confidence)
  })
  list(result = result, n = n, p = p, confidence = confidence, seed = seed,
       method = "Uncorrected Wilson confidence interval for one binomial proportion")
}

# Exact operating characteristics for a sample mean from independent normal
# observations with KNOWN population SD. This is distinct from the lab's t test.
normal_sampling_operating_characteristics <- function(mu0 = 120, mu1 = 125,
    sigma = 15, n = 25, alpha = .05, sidedness = "greater") {
  check_scalar(mu0, "Null mean"); check_scalar(mu1, "Alternative mean")
  check_positive_number(sigma, "Known population SD")
  check_integer(n, "Sample size", 1, 1e7)
  check_probability(alpha, "alpha")
  if (!is.character(sidedness) || length(sidedness) != 1 ||
      !sidedness %in% c("greater", "less", "two.sided"))
    stop("Sidedness must be greater, less or two.sided.", call. = FALSE)
  se <- sigma / sqrt(n)
  z <- qnorm(1 - alpha / if (sidedness == "two.sided") 2 else 1)
  lower <- if (sidedness %in% c("less", "two.sided")) mu0 - z * se else -Inf
  upper <- if (sidedness %in% c("greater", "two.sided")) mu0 + z * se else Inf
  # pnorm's lower.tail=FALSE avoids cancellation when upper-tail power is tiny.
  power <- pnorm(lower, mu1, se) + pnorm(upper, mu1, se, lower.tail = FALSE)
  actual_alpha <- pnorm(lower, mu0, se) + pnorm(upper, mu0, se, lower.tail = FALSE)
  critical <- if (sidedness == "greater") upper else if (sidedness == "less") lower
              else c(lower, upper)
  list(mu0 = mu0, mu1 = mu1, effect = mu1 - mu0, sigma = sigma, n = n,
    alpha = alpha, type1 = actual_alpha, beta = 1 - power, power = power,
    se = se, SE = se, lower = lower, upper = upper, critical = critical,
    standardized_critical = z, sidedness = sidedness,
    method = "Normal sample mean; independent observations; known population SD")
}

plot_sample_mean_distributions <- function(x) {
  limits <- range(c(x$mu0, x$mu1, x$critical)) + c(-4.5, 4.5) * x$se
  grid <- seq(limits[1], limits[2], length.out = 1200)
  null_density <- dnorm(grid, x$mu0, x$se)
  alt_density <- dnorm(grid, x$mu1, x$se)
  ymax <- max(null_density, alt_density) * 1.17
  plot(grid, null_density, type = "n", ylim = c(0, ymax),
    xlab = "Sample mean (not individual observations)", ylab = "Density",
    main = paste0("Sampling distributions of the mean: n = ", x$n))
  shade <- function(from, to, mean, color) {
    left <- max(from, limits[1]); right <- min(to, limits[2])
    if (left >= right) return(invisible(NULL))
    g <- seq(left, right, length.out = 400)
    polygon(c(left, g, right), c(0, dnorm(g, mean, x$se), 0),
      col = color, border = NA)
  }
  shade(-Inf, x$lower, x$mu0, adjustcolor("#a34724", alpha.f = .38))
  shade(x$upper, Inf, x$mu0, adjustcolor("#a34724", alpha.f = .38))
  shade(x$lower, x$upper, x$mu1, adjustcolor("#176675", alpha.f = .32))
  lines(grid, null_density, col = "#a34724", lwd = 2, lty = 1)
  lines(grid, alt_density, col = "#176675", lwd = 2, lty = 2)
  abline(v = x$critical, col = "#555555", lty = 3)
  legend("topright", c("Null distribution", "Specified alternative", "Type I error: reject under null",
    "Type II error: do not reject under alternative", "Rejection boundary"),
    col = c("#a34724", "#176675", "#a34724", "#176675", "#555555"),
    lty = c(1, 2, NA, NA, 3), pch = c(NA, NA, 15, 15, NA),
    lwd = c(2, 2, NA, NA, 1), cex = .75, bg = "white")
}
