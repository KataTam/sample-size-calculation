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
  check_scalar(delta, "Generating difference"); check_positive_number(sd, "Generating SD")
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
  centre <- (p + z^2 / (2 * n)) / (1 + z^2 / n)
  half <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / (1 + z^2 / n)
  cbind(lower = pmax(0, centre - half), upper = pmin(1, centre + half))
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
  # Normal sufficient statistics have the same distribution as analysing B full
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
    stop("A zero planning effect cannot define a sample size for detecting a difference.", call. = FALSE)
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
  clinical <- spec$threshold * spec$benefit_direction
  limits <- range(c(x$lower, x$upper, 0, clinical, true_difference(spec)))
  plot(x$estimate, y, xlim = limits, ylim = c(.5, nrow(x) + .5),
       pch = ifelse(x$reject, 19, 1), xlab = "Treatment minus control", ylab = "Study",
       main = "Intervals from individual studies")
  segments(x$lower, y, x$upper, y)
  abline(v = 0, lty = 1, col = "grey40")
  abline(v = clinical, lty = 2, col = "#9a3412")
  abline(v = true_difference(spec), lty = 3, col = "#075985")
  legend("topright", c("Zero", "Clinical threshold", "Generating truth"),
         lty = 1:3, col = c("grey40", "#9a3412", "#075985"), cex = .75, bg = "white")
}
