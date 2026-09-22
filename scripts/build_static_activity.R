source("R/sample_size_functions.R")
dir.create("data/static_activity", recursive = TRUE, showWarnings = FALSE)
dir.create("figures/static_activity", recursive = TRUE, showWarnings = FALSE)
scenarios <- list(
  planned = study_spec(n = 45, delta = 3, threshold = 2, width_target = 4),
  null = study_spec(n = 45, delta = 0, threshold = 2, width_target = 4),
  smaller_effect = study_spec(n = 45, delta = 1, threshold = 2, width_target = 4),
  higher_variability = study_spec(n = 45, delta = 3, sd = 7, threshold = 2, width_target = 4),
  binary = study_spec(outcome = "proportions", n = 60, p_control = .3,
                     p_treatment = .6, threshold = .3, width_target = .2))
lines <- c("# Static sample size activity", "",
  "Use these prepared synthetic results when the live app is unavailable. No code is required. All studies use equal allocation and a two-sided alpha of .05. Full reproducible results and assumptions accompany the activity.", "",
  "## Before viewing the results", "",
  "1. Predict how a smaller effect or larger SD changes power at 45 per group.",
  "2. Explain the difference between the 3-unit planning effect and 2-unit clinical threshold.",
  "3. Predict what changes if replications increase while participants per study remain fixed.", "")
for (name in names(scenarios)) {
  spec <- scenarios[[name]]; one <- simulate_one_study(spec); many <- simulate_trials(spec)
  metadata <- as.data.frame(spec); metadata$method <- method_label(spec$outcome)
  write.csv(metadata, paste0("data/static_activity/", name, "_assumptions.csv"), row.names = FALSE)
  write.csv(one$data, paste0("data/static_activity/", name, "_one_data.csv"), row.names = FALSE)
  write.csv(one$result, paste0("data/static_activity/", name, "_one_result.csv"), row.names = FALSE)
  write.csv(many$results, paste0("data/static_activity/", name, "_replications.csv"), row.names = FALSE)
  png(paste0("figures/static_activity/", name, ".png"), width = 1000, height = 700, res = 120)
  plot_trial_intervals(many$results, spec); dev.off()
  lines <- c(lines, paste0("## ", gsub("_", " ", name)), "",
    paste0("Participants per group: ", spec$n, "; generating difference: ", true_difference(spec),
      "; SD (normal outcome): ", spec$sd, "; B: ", spec$B, "; seed: ", spec$seed, "."), "",
    "### One study", "", knitr::kable(one$result, format = "pipe", digits = 4), "",
    interval_interpretation(one$result, spec), "", "### Repeated studies", "",
    knitr::kable(simulation_summary(many), format = "pipe", digits = 4), "",
    paste0("Mean FULL interval width: ", signif(mean(many$results$width), 4), "."), "",
    paste0("![First 30 study intervals with zero, clinical threshold and generating truth. Numerical summaries above.](../figures/static_activity/", name, ".png)"), "",
    paste0("[Assumptions](../data/static_activity/", name, "_assumptions.csv) | [All replications](../data/static_activity/", name, "_replications.csv)"), "")
}
lines <- c(lines, "## Interpretation and communication", "",
  "Use the case template to justify the goal and assumptions. Explain one inconclusive result, interpret intervals against the clinical threshold, and compare performance while n stays fixed. Report Monte Carlo uncertainty separately from clinical uncertainty.", "",
  "The normal batch uses equivalent sufficient-statistic sampling; the single dataset is a separate realisation, not the batch's first row. These displays include test/CI differences for binary data described in statistical_methods.md.", "",
  "## References", "", "See [References](../REFERENCES.md) for the pedagogical and statistical sources.")
writeLines(lines, "teaching/static_activity.md")
message("Static activity, figures, synthetic datasets and assumptions generated.")
