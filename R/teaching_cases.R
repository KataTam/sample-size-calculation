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
    assumptions_report = case("assumptions_report", "Record the assumptions: study-plan report",
      "Write your clinical question, justify the expected effect, planning effect and clinical threshold, and record the analysis, sample size and recruitment plan. Your entries build a report alongside the form.",
      "record-assumptions", app = "assumptions_report"),
    pain_one_many = case("pain_one_many", "Pain relief: one study and many",
      "Distinguish the expected 40-percentage-point benefit, the 30-point planning benefit and the 20-point clinical threshold. Compare 20, 50 and 80 patients per group before interpreting the rejection rate.",
      "power", list(outcome = "proportions", goal = "fixed", fixed_n = 20,
        plan_p0 = .30, plan_p1 = .60, width_p = .20, seed = 20260941, stage = "One study"),
      n_choices = c(20, 50, 80)),
    pain_curves = case("pain_curves", "Pain relief: a recruitment decision",
      "Compare the planned 30 percentage point benefit with smaller benefits. Can a recruitment limit of 200 patients support the chosen 90% power target?",
      "curves", list(outcome = "proportions", goal = "fixed", fixed_n = 90, width_p = .20, plan_p0 = .30,
        plan_p1 = .60, target_power = .90, recruit_cap = 200, dropout = .10,
        seed = 20260941)),
    pain_simulation = case("pain_simulation", "Pain relief: repeated trial simulation",
      "Generate a study with 60 patients per group, then repeat it 5,000 times. Separate rejection, interval coverage and width attainment.",
      "simulation", list(outcome = "proportions", goal = "fixed", fixed_n = 60,
        plan_p0 = .30, plan_p1 = .60, width_p = .30, seed = 20260921,
        stage = "Many studies")),
    mean_precision = case("mean_precision", "Improvement scores: plan for precision",
      "Plan a two-group score study for a full confidence interval width of 4 units. Compare that goal with testing and interpret the interval against a 2-unit clinical threshold.",
      "feasibility", list(outcome = "means", goal = "precision", plan_delta = 3,
        plan_sd = 5, threshold_m = 2, width_m = 4, target_power = .80, seed = 20260922)),
    own_study = case("own_study", "Build your own study justification",
      "Replace these illustrative assumptions with justified values for your question. Record evidence, uncertainty, feasibility and what your result could establish.",
      "own-study", list(outcome = "means", goal = "testing", target_power = .80,
        seed = 20260914, B = 1000, stage = "My study")),
    rehabilitation = case("rehabilitation", "Rehabilitation: improvement in a score",
      "A hypothetical rehabilitation programme is compared with usual care. Distinguish the expected 4-unit benefit, the 3-unit planning difference and the 2-unit clinical threshold.",
      "rehabilitation", list(outcome = "means", goal = "testing", plan_delta = 3,
        plan_sd = 5, threshold_m = 2, target_power = .90, dropout = .10,
        recruit_cap = 200, seed = 20261001)),
    discharge = case("discharge", "Discharge: an absolute probability difference",
      "The expected benefit is 18 percentage points. Plan using 80% versus 96%, a 16-point benefit, and interpret against an 8-point clinical threshold. State the absolute difference before interpreting the relative change.",
      "discharge", list(outcome = "proportions", goal = "testing", plan_p0 = .80,
        plan_p1 = .96, expected_p = .18, threshold_p = .08, target_power = .80, dropout = 0,
        width_p = .20, seed = 20261003)),
    adherence = case("adherence", "Medication support: adequate adherence",
      "The expected benefit is 20 percentage points. Plan using adherence of 50% versus 65%, a 15-point benefit, and interpret against a 10-point clinical threshold. Examine uncertainty and 15% losses.",
      "adherence", list(outcome = "proportions", goal = "testing", plan_p0 = .50,
        plan_p1 = .65, expected_p = .20, threshold_p = .10, target_power = .90, dropout = .15,
        recruit_cap = 240, width_p = .20, seed = 20261002)),
    prevalence = case("prevalence", "Prevalence: estimate disease burden",
      "A hypothetical survey anticipates a prevalence of 20%. Plan for a 95% interval with full width 10 percentage points, then compare narrower precision and unknown prevalence.",
      "prevalence", list(outcome = "single_proportion", goal = "precision",
        anticipated_p = .20, full_width = .10, confidence = .95, unknown_p = FALSE,
        fixed_n = 246, dropout = 0, seed = 20260942), app = "prevalence_precision"),
    pilot_feasibility = case("pilot_feasibility", "Pilot: retention with limited resources",
      "A hypothetical feasibility study can enrol 40 participants and anticipates 80% retention. Examine precision for that process measure before deciding whether it can inform a larger study.",
      "pilot-feasibility", list(outcome = "single_proportion", goal = "fixed",
        anticipated_p = .80, full_width = .20, confidence = .95, unknown_p = FALSE,
        fixed_n = 40, dropout = 0, seed = 20260943), app = "prevalence_precision"),
    alpha_beta = case("alpha_beta", "Blood pressure: alpha, beta and power",
      "Compare distributions of the sample mean under a null mean of 120 and a specified alternative mean of 125 mmHg. Predict how sample size changes the overlap.",
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
