# Shared hypothetical cases for the tutorial, activity wrapper and Shiny apps.
# Keep assumptions here so a lesson and its activity start from the same plan.

teaching_cases <- function() {
  defaults <- list(outcome = "means", goal = "testing", expected_m = 4, expected_p = .40, plan_delta = 3,
    plan_sd = 5, plan_p0 = .30, plan_p1 = .60, threshold_m = 2,
    threshold_p = .20, width_m = 4, width_p = .20, alpha = .05,
    target_power = .90, fixed_n = 60, dropout = .10, recruit_cap = 200,
    reality = "same", seed = 20260914, B = 5000, stage = "Explore assumptions")
  case <- function(id, title, prompt, anchor, inputs = list(), app = "power_explorer",
                   outcome = NULL, goal = NULL, ...) {
    values <- utils::modifyList(defaults, inputs)
    list(id = id, title = title, prompt = prompt,
      return_path = paste0("book/Sample_size_open_module.html#", anchor), app = app,
      outcome = if (is.null(outcome)) values$outcome else outcome,
      goal = if (is.null(goal)) values$goal else goal, inputs = values, ...)
  }
  list(
    design_questionnaire = case("design_questionnaire", "Choosing a study design",
      "Which study design suits your question and available data?",
      "design-questionnaire", app = "design_questionnaire"),
    assumptions_report = case("assumptions_report", "Develop and justify your study plan",
      "What evidence supports your study design, sample-size assumptions, and recruitment target?",
      "record-assumptions", app = "assumptions_report"),
    pain_one_many = case("pain_one_many", "Pain relief: one study and many",
      "Simulated pain-relief trials show how estimated treatment differences vary between studies and how that variation changes with the number of patients.",
      "activity-1-one-study-then-many", list(outcome = "proportions", goal = "fixed", fixed_n = 20,
        plan_p0 = .30, plan_p1 = .60, width_p = .20, seed = 20260941, stage = "One study"),
      n_choices = c(20, 50, 80)),
    pain_curves = case("pain_curves", "Pain relief: a recruitment decision",
      "Can the recruitment limit support the target power? Power curves show how the answer changes when the true treatment difference is smaller than planned.",
      "activity-2-can-the-feasible-study-answer-the-question", list(outcome = "proportions", goal = "fixed", fixed_n = 90, width_p = .20, plan_p0 = .30,
        plan_p1 = .60, target_power = .90, recruit_cap = 200, dropout = .10,
        seed = 20260941)),
    pain_simulation = case("pain_simulation", "Pain relief: repeated trial simulation",
      "Repeated trial simulations show how often the analysis detects a difference and how estimates change when assumptions differ or outcomes are missing.",
      "activity-3-generate-analyze-repeat-summarize", list(outcome = "proportions", goal = "fixed", fixed_n = 60,
        plan_p0 = .30, plan_p1 = .60, width_p = .30, seed = 20260921,
        stage = "Many studies")),
    mean_precision = case("mean_precision", "Improvement scores: estimation with a precision target",
      "How many participants are needed for the chosen confidence interval width? You can compare that requirement with the sample size needed for target power.",
      "plan-for-precision", list(outcome = "means", goal = "precision", plan_delta = 3,
        plan_sd = 5, threshold_m = 2, width_m = 4, target_power = .80, seed = 20260922)),
    own_study = case("own_study", "Build your own study justification",
      "You can apply the calculations to your own research question and document the evidence, uncertainty, and recruitment constraints behind your sample-size choice.",
      "own-study", list(outcome = "means", goal = "testing", target_power = .80,
        seed = 20260914, B = 1000, stage = "My study")),
    rehabilitation = case("rehabilitation", "Rehabilitation: improvement in a score",
      "How does the target difference or variation in improvement scores affect the sample size needed to compare rehabilitation with usual care?",
      "rehabilitation", list(outcome = "means", goal = "testing", plan_delta = 3,
        plan_sd = 5, threshold_m = 2, target_power = .90, dropout = .10,
        recruit_cap = 200, seed = 20261001)),
    discharge = case("discharge", "Discharge: an absolute probability difference",
      "How does the baseline probability of discharge affect sample size for a target difference in percentage points? The example distinguishes absolute and relative changes.",
      "discharge", list(outcome = "proportions", goal = "testing", plan_p0 = .80,
        plan_p1 = .96, expected_p = .18, threshold_p = .08, target_power = .80, dropout = 0,
        width_p = .20, seed = 20261003)),
    adherence = case("adherence", "Probiotics: preventing gestational diabetes",
      "This hypothetical trial compares gestational-diabetes prevention with and without probiotics. You can assess sample size and recruitment needs, counting remaining free of diabetes as the favorable outcome.",
      "adherence", list(outcome = "proportions", goal = "testing", plan_p0 = .80,
        plan_p1 = .90, expected_p = .12, threshold_p = .05, target_power = .90, dropout = .15,
        recruit_cap = 240, width_p = .20, seed = 20261002)),
    prevalence = case("prevalence", "Prevalence: estimate disease burden",
      "How does the required sample change when you need a narrower confidence interval?",
      "prevalence", list(outcome = "single_proportion", goal = "precision",
        anticipated_p = .20, full_width = .10, confidence = .95, unknown_p = FALSE,
        fixed_n = 246, dropout = 0, seed = 20260942), app = "prevalence_precision"),
    pilot_feasibility = case("pilot_feasibility", "Pilot: retention with limited resources",
      "What can 40 participants tell you about retention in a future study?",
      "pilot-feasibility", list(outcome = "single_proportion", goal = "fixed",
        anticipated_p = .80, full_width = .20, confidence = .95, unknown_p = FALSE,
        fixed_n = 40, dropout = 0, seed = 20260943), app = "prevalence_precision"),
    alpha_beta = case("alpha_beta", "Blood pressure: Type I error probability, Type II error probability and power",
      "How does sample size affect the probability of detecting a specified blood-pressure difference? The graphs distinguish false positives, false negatives, and power.",
      "alpha-beta", list(outcome = "mean_one_sample", goal = "testing", mu0 = 120,
        mu1 = 125, sigma = 15, n = 25, alpha = .05, sidedness = "greater"),
      app = "sampling_distributions")
  )
}

teaching_case <- function(id) {
  if (!is.character(id) || length(id) != 1 || is.na(id))
    stop("Choose one teaching case ID.", call. = FALSE)
  cases <- teaching_cases()
  if (!id %in% names(cases)) stop("Unknown teaching case: ", id, call. = FALSE)
  cases[[id]]
}

# Turn a shared two-group case into the existing simulation specification.
teaching_case_spec <- function(id) {
  x <- teaching_case(id)
  if (x$app != "power_explorer")
    stop("This case uses a different study design and activity.", call. = FALSE)
  v <- x$inputs
  study_spec(outcome = v$outcome, n = v$fixed_n, delta = v$plan_delta,
    sd = v$plan_sd, p_control = v$plan_p0, p_treatment = v$plan_p1,
    alpha = v$alpha, threshold = if (v$outcome == "means") v$threshold_m else v$threshold_p,
    width_target = if (v$outcome == "means") v$width_m else v$width_p,
    seed = v$seed, B = v$B)
}
