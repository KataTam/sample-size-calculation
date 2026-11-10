# Prepared teaching calculation. Runtime records from apps are saved separately.
pain_report_record <- function() {
  p_novel <- .60; p_standard <- .30; alpha <- .05; power <- .90; loss <- .05
  fit <- stats::power.prop.test(p1 = p_novel, p2 = p_standard,
    sig.level = alpha, power = power, alternative = "two.sided", strict = TRUE)
  n <- ceiling(fit$n)
  recruit <- ceiling(n / (1 - loss))
  alternative_n <- ceiling(stats::power.prop.test(p1 = .50, p2 = p_standard,
    sig.level = alpha, power = power, alternative = "two.sided", strict = TRUE)$n)
  alternative_power <- stats::power.prop.test(n = n, p1 = .50, p2 = p_standard,
    sig.level = alpha, alternative = "two.sided", strict = TRUE)$power
  revision <- system2("git", c("rev-parse", "HEAD"), stdout = TRUE)
  dirty <- length(system2("git", c("diff", "--name-only", "--", "R/pain_report_record.R"), stdout = TRUE)) > 0
  tracked <- length(system2("git", c("ls-files", "--", "R/pain_report_record.R"), stdout = TRUE)) > 0
  source_version <- paste0(revision[1], if (dirty || !tracked) " (working copy)" else "",
    "; calculation-file MD5: ", unname(tools::md5sum("R/pain_report_record.R")))
  command <- paste(c(
    "plan <- stats::power.prop.test(",
    "  p1 = 0.60, p2 = 0.30, sig.level = 0.05, power = 0.90,",
    "  alternative = \"two.sided\", strict = TRUE)",
    "analyzable_per_group <- ceiling(plan$n)",
    "recruit_per_group <- ceiling(analyzable_per_group / 0.95)"), collapse = "\n")
  list(title = "Prepared chronic pain calculation", kind = "calculation", source = "tutorial-example",
    captured = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    facts = list(outcome = "binary", study_type = "comparison", goal = "testing",
      p_treatment = p_novel, p_control = p_standard, alpha = alpha, power = power,
      raw_n = fit$n, analyzable = n, dropout = loss, recruitment = recruit,
      sensitivity_n = alternative_n, sensitivity_power = alternative_power),
    r_version = as.character(getRversion()), stats_version = as.character(utils::packageVersion("stats")),
    source_version = source_version, code = command,
    lines = c(
      "Prepared teaching example: hypothetical assumptions; R versions below belong to the tutorial build.",
      "Procedure: normal approximation for a two-sided comparison of two independent proportions; equal allocation; both rejection tails included.",
      "Inputs: standard-treatment relief 30%; novel-treatment relief 60%; target difference 30 percentage points; Type I error probability 5%; target power 90%.",
      sprintf("Analyzable sample: %.5f per group before rounding; %d per group, %d total after rounding upward.", fit$n, n, 2*n),
      sprintf("Expected unavailable primary outcomes: 5%% in each group. Recruitment: ceiling(%d / 0.95) = %d per group, %d total.", n, recruit, 2*recruit),
      sprintf("Sensitivity: 50%% versus 30%% relief requires %d analyzable patients per group for 90%% power; power with %d per group is approximately %.0f%%.", alternative_n, n, 100*alternative_power),
      paste("Software: R", getRversion(), "; stats", utils::packageVersion("stats"), "; source version:", source_version),
      paste("Reproducible R command:\n", command)))
}

write_pain_report_record <- function() {
  jsonlite::write_json(pain_report_record(), "site/assumptions_report/example-calculation.json",
    pretty = TRUE, auto_unbox = TRUE, digits = 12)
}
