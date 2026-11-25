# Recorded native G*Power/PASS outputs provide independent regression benchmarks.
check_calculation_validation <- function() {
  source("R/sample_size_functions.R", local = TRUE)
  source("R/single_population.R", local = TRUE)
  record <- jsonlite::fromJSON("data/software-validation.json")
  settings <- record$comparison_settings
  p <- record$two_proportions
  n <- sample_size_two_proportions(p$p_treatment, p$p_standard,
    alpha = settings$alpha, power = settings$power)
  power <- power_two_proportions(n, p$p_treatment, p$p_standard, settings$alpha)
  stopifnot(n == p$gpower_n_per_group, n == p$pass_n_per_group,
    abs(power - p$gpower_power) < 5e-8, abs(power - p$pass_power) < 5e-6)

  m <- record$two_means
  n <- sample_size_two_means(m$difference, m$sd, settings$alpha, settings$power)
  power <- power_two_means(n, m$difference, m$sd, settings$alpha)
  stopifnot(n == m$gpower_n_per_group, n == m$pass_n_per_group,
    abs(power - m$gpower_power) < 5e-8, abs(power - m$pass_power) < 5e-6)

  p <- record$one_proportion
  plan <- proportion_precision_plan(p$p, p$full_width, p$confidence)
  width <- 2 * qnorm((1 + p$confidence)/2) * sqrt(p$p*(1-p$p)/plan$n)
  stopifnot(plan$n == p$pass_n, abs(width - p$pass_full_width) < 5e-6)

  # PASS holds the entered sample SD fixed. The app averages over sample SDs.
  m <- record$one_mean
  candidates <- 2:100
  fixed_width <- 2 * qt((1+m$confidence)/2, candidates-1) * m$sd/sqrt(candidates)
  pass_n <- candidates[which(fixed_width <= m$full_width)[1]]
  spec <- single_population_spec(outcome = "means", sd = m$sd,
    confidence = m$confidence, width = m$full_width)
  app_n <- single_population_n(spec)
  stopifnot(pass_n == m$pass_n,
    # PASS displayed the half-width to five decimals, then it was doubled.
    abs(fixed_width[match(pass_n, candidates)] - m$pass_full_width) < 1e-5,
    app_n == m$app_expected_width_n,
    abs(single_population_width(spec, app_n) - m$app_expected_full_width) < 5e-7)

  # Independently check the glossary's plotted Wilson limits at central and
  # sparse counts, including zero events, against the R score-test interval.
  for (row in list(c(50,100), c(1,20), c(0,20))) {
    interval <- wilson_interval(row[1]/row[2], row[2])
    reference <- suppressWarnings(prop.test(row[1], row[2], correct = FALSE)$conf.int)
    stopifnot(max(abs(as.numeric(interval) - reference)) < 1e-12)
  }
  message("Recorded G*Power/PASS benchmarks and glossary intervals checked.")
}
