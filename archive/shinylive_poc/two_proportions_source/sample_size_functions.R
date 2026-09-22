# Reusable functions for sample size teaching examples.

check_probability <- function(x, name, lower = 0, upper = 1) {
  if (!is.numeric(x) || length(x) != 1 || is.na(x) || x <= lower || x >= upper) {
    stop(name, " must be a single number between ", lower, " and ", upper, ".", call. = FALSE)
  }
  invisible(TRUE)
}

check_nonnegative_probability <- function(x, name, upper = 1) {
  if (!is.numeric(x) || length(x) != 1 || is.na(x) || x < 0 || x >= upper) {
    stop(name, " must be a single number from 0 up to, but not including, ", upper, ".", call. = FALSE)
  }
  invisible(TRUE)
}

check_positive_number <- function(x, name) {
  if (!is.numeric(x) || length(x) != 1 || is.na(x) || x <= 0) {
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
  total_with_dropout <- adjust_for_dropout(total_n, dropout_rate)
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
  total_with_dropout <- adjust_for_dropout(total_n, dropout_rate)
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

power_two_proportions <- function(n_per_group, pi1, pi2, alpha = 0.05) {
  check_positive_number(n_per_group, "n_per_group")
  check_probability(pi1, "pi1")
  check_probability(pi2, "pi2")
  check_probability(alpha, "alpha")
  if (pi1 == pi2) {
    stop("pi1 and pi2 must be different.", call. = FALSE)
  }
  signal <- sqrt(n_per_group * (pi1 - pi2)^2 / (pi1 * (1 - pi1) + pi2 * (1 - pi2)))
  pnorm(signal - qnorm(1 - alpha / 2))
}

power_two_means <- function(n_per_group, delta, sd, alpha = 0.05) {
  check_positive_number(n_per_group, "n_per_group")
  check_positive_number(delta, "delta")
  check_positive_number(sd, "sd")
  check_probability(alpha, "alpha")
  signal <- sqrt(n_per_group * delta^2 / (2 * sd^2))
  pnorm(signal - qnorm(1 - alpha / 2))
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
      "The required sample size is ", result$n_per_group,
      " participants per group, or ", result$total_n,
      " participants before dropout adjustment. With ",
      format_percent(result$dropout_rate),
      " expected dropout, the recruitment target is ",
      result$total_with_dropout, " participants."
    )
  } else {
    paste0(
      "The required sample size is ", result$n_per_group,
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
