source("R/sample_size_functions.R")
source("R/tutorial_helpers.R")
dir.create("data/static_activity", recursive = TRUE, showWarnings = FALSE)
dir.create("figures/static_activity", recursive = TRUE, showWarnings = FALSE)
scenarios <- list(
  planned = study_spec(n = 45, delta = 3, threshold = 2, width_target = 4),
  null = study_spec(n = 45, delta = 0, threshold = 2, width_target = 4),
  smaller_effect = study_spec(n = 45, delta = 1, threshold = 2, width_target = 4),
  higher_variability = study_spec(n = 45, delta = 3, sd = 7, threshold = 2, width_target = 4),
  binary = study_spec(outcome = "proportions", n = 60, p_control = .3,
                     p_treatment = .6, threshold = .2, width_target = .2))
effect_text <- function(value, outcome) {
  if (outcome == "proportions") paste0(round(100 * value, 2), " percentage points")
  else paste0(signif(value, 4), " units")
}
lines <- c("# Static sample size activity", "",
  "Use these prepared synthetic results when the live app is unavailable. No code is required. All studies use equal allocation and a two-sided alpha of 5%. Full reproducible results and assumptions accompany the activity.", "",
  "## Before viewing the results", "",
  "1. Predict how a smaller effect or larger SD changes power at 45 per group.",
  "2. Explain the distinct roles of the expected 4-unit benefit, 3-unit planning effect and 2-unit clinical threshold. For the binary trial, these values are 40, 30 and 20 percentage points respectively.",
  "3. Predict what changes if replications increase while participants per study remain fixed.", "")
for (index in seq_along(scenarios)) {
  name <- names(scenarios)[index]
  spec <- scenarios[[name]]; one <- simulate_one_study(spec); many <- simulate_trials(spec)
  metadata <- as.data.frame(spec); metadata$method <- method_label(spec$outcome)
  metadata$expected_effect <- if (spec$outcome == "means") 4 else .40
  metadata$planning_effect <- if (spec$outcome == "means") 3 else .30
  write.csv(metadata, paste0("data/static_activity/", name, "_assumptions.csv"), row.names = FALSE)
  write.csv(one$data, paste0("data/static_activity/", name, "_one_data.csv"), row.names = FALSE)
  write.csv(one$result, paste0("data/static_activity/", name, "_one_result.csv"), row.names = FALSE)
  write.csv(many$results, paste0("data/static_activity/", name, "_replications.csv"), row.names = FALSE)
  png(paste0("figures/static_activity/", name, ".png"), width = 1000, height = 700, res = 120)
  plot_trial_intervals(many$results, spec); dev.off()
  one_display <- one$result
  if (spec$outcome == "proportions") one_display <- display_probabilities(one_display,
    points = c("estimate", "lower", "upper", "width"))
  title <- gsub("_", " ", name)
  lines <- c(lines, paste0("## ", title), "",
    paste0("Expected benefit: ", effect_text(metadata$expected_effect, spec$outcome),
      "; original planning benefit: ", effect_text(metadata$planning_effect, spec$outcome),
      "; clinical threshold: ", effect_text(spec$threshold, spec$outcome), "."), "",
    paste0("Participants per group: ", spec$n, "; generating difference: ", effect_text(true_difference(spec), spec$outcome),
      if (spec$outcome == "means") paste0("; SD: ", spec$sd) else paste0("; control ", percent(spec$p_control), ", treatment ", percent(spec$p_treatment)),
      "; B: ", spec$B, "; seed: ", spec$seed, "."), "",
    "### One study", "", paste0("**Table ", 2 * index - 1, ".** Estimate, confidence interval and decisions from one simulated study under the ", title, " scenario."), "",
    knitr::kable(one_display, format = "pipe", digits = 4), "",
    interval_interpretation(one$result, spec), "", "### Repeated studies", "",
    paste0("**Table ", 2 * index, ".** Rejection, confidence interval coverage and full-width attainment across ", spec$B, " independent studies under the ", title, " scenario. Monte Carlo intervals describe simulation uncertainty."), "",
    knitr::kable(display_simulation_summary(simulation_summary(many)), format = "pipe"), "",
    paste0("Mean FULL interval width: ", effect_text(mean(many$results$width), spec$outcome), "."), "",
    paste0("![First 30 study intervals with zero, clinical threshold and generating truth. Numerical summaries above.](../figures/static_activity/", name, ".png)"), "",
    paste0("**Figure ", index, ".** First 30 simulated intervals under the ", title, " scenario. Filled points reject zero; the separate lines mark zero, the clinical threshold and the generating truth. ",
      if (spec$outcome == "proportions") "The horizontal scale is percentage points." else "The horizontal scale is outcome units."), "",
    paste0("[Assumptions](../data/static_activity/", name, "_assumptions.csv) | [All replications](../data/static_activity/", name, "_replications.csv)"), "")
}
lines <- c(lines, "## Interpretation and communication", "",
  "Use the case template to justify the goal and assumptions. Explain one inconclusive result, interpret intervals against the clinical threshold, and compare performance while n stays fixed. Report Monte Carlo uncertainty separately from clinical uncertainty.", "",
  "The normal batch uses equivalent sufficient-statistic sampling; the single dataset is a separate realisation, not the batch's first row. These displays include test/CI differences for binary data described in statistical_methods.md.", "",
  "## References", "", "See [References](../documentation/references.md) for the pedagogical and statistical sources.")
writeLines(lines, "teaching/static_activity.md")
message("Static activity, figures, synthetic datasets and assumptions generated.")
