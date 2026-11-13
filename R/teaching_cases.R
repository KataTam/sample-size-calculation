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
      "Your answers identify suitable study designs and their implications for sample-size planning. Unresolved choices can remain undecided; updating your answers lets you compare the suggestions.",
      "design-questionnaire", app = "design_questionnaire"),
    assumptions_report = case("assumptions_report", "Develop and justify your study plan",
      "Your answers develop into a concise sample size calculation report followed by its supporting study plan. You can use your own study, load the chronic pain example, or resume saved work. PDF and Word downloads share the report; Save work for later stores a file you can reopen.",
      "record-assumptions", app = "assumptions_report"),
    probiotics_calculation = case("probiotics_calculation", "Probiotics: calculate a binary-outcome sample size",
      "This core calculation activity uses the proportions example. The event is remaining free of gestational diabetes: 80% without probiotics and 90% with probiotics. Your record should identify the inputs, method and analyzable counts. The Report view can add the selected calculation to your study plan.",
      "adherence", list(outcome = "proportions", plan_p0 = .80, plan_p1 = .90, target_power = .90, dropout = 0), app = "two_proportions"),
    rehabilitation_calculation = case("rehabilitation_calculation", "Rehabilitation: calculate a mean-difference sample size",
      "This additional practice uses the pooled two-sample t-test calculation. The target improvement difference is 3 units with SD 5. Your record should identify the inputs, method and analyzable counts. The Report view can add the selected calculation to your study plan.",
      "rehabilitation", list(plan_delta = 3, plan_sd = 5, target_power = .90, dropout = 0), app = "two_means"),
    recruitment = case("recruitment", "Adjust recruitment",
      "Your starting count is the analyzable requirement from the calculation you chose. Applying one expected loss percentage to both groups gives recruitment per group and in total, rounded upward. You can add this adjustment and a short justification to your continuing report.",
      "account-for-expected-losses", app = "dropout_adjustment"),
    recruitment_advanced = case("recruitment_advanced", "Recruitment: unequal losses and treatment switching",
      "Starting with your analyzable requirement, you can examine separate loss percentages and treatment switching, then justify the resulting recruitment plan.",
      "recruitment-extensions", app = "dropout_adjustment"),
    pain_one_many = case("pain_one_many", "Pain relief: one study and many",
      "This activity simulates Neravixa versus duloxetine for painful diabetic peripheral neuropathy. Each patient either achieves pain relief or does not. One trial and repeated trials use the same population assumptions. Comparing sample sizes shows how estimates vary and how often the test detects the specified difference. The animation connects individual outcomes to each trial estimate and the distribution across trials.",
      "activity-1-one-study-then-many", list(outcome = "proportions", goal = "fixed", fixed_n = 20,
        plan_p0 = .30, plan_p1 = .60, width_p = .20, seed = 20260941, stage = "One study"),
      n_choices = c(20, 50, 80)),
    pain_curves = case("pain_curves", "Pain relief: a recruitment decision",
      "With 100 analyzable patients per group, compare power for true relief differences of 15, 20 and 30 percentage points in the Neravixa-versus-duloxetine trial. The vertical line shows the available count; the horizontal line shows 90% target power. The table gives power at that count and the sample required for each difference. Changing the available count updates both. For another population scenario, Settings > Assumptions for the simulated studies > Custom effect or variability keeps the sample fixed; the sensitivity table updates immediately and Simulate many studies generates new trials under those assumptions.",
      "activity-2-can-the-feasible-study-answer-the-question", list(outcome = "proportions", goal = "fixed", fixed_n = 100, width_p = .20, plan_p0 = .30,
        plan_p1 = .60, target_power = .90, recruit_cap = 224, dropout = .10,
        seed = 20260941, stage = "Compare assumptions")),
    pain_simulation = case("pain_simulation", "Pain relief: repeated trial simulation",
      "Repeated Neravixa-versus-duloxetine trials connect generating patient outcomes, analyzing each trial and summarizing its results. You can change the assumed true difference or explore missing outcomes, then compare detection, interval coverage and bias. Saved results retain the assumptions used to generate them.",
      "activity-3-generate-analyze-repeat-summarize", list(outcome = "proportions", goal = "fixed", fixed_n = 60,
        plan_p0 = .30, plan_p1 = .60, width_p = .30, seed = 20260921,
        stage = "Many studies")),
    mean_precision = case("mean_precision", "Mean improvement: estimation with a precision target",
      "Estimate the mean improvement in one patient population. Choose a confidence interval width, calculate the total sample size, and simulate studies to see how estimates and intervals vary.",
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
      "This trial of discharge within seven days connects relative and absolute increases to event percentages. You can compare requirements at 80% and 90% power and use simulations to examine performance near the 100% boundary.",
      "discharge", list(outcome = "proportions", goal = "testing", plan_p0 = .80,
        plan_p1 = .96, expected_p = .18, threshold_p = .08, target_power = .80, dropout = 0,
        width_p = .20, seed = 20261003)),
    adherence = case("adherence", "Probiotics: preventing gestational diabetes",
      "This hypothetical trial compares gestational-diabetes prevention with and without probiotics. You can assess sample size and recruitment needs, counting remaining free of diabetes as the favorable outcome.",
      "adherence", list(outcome = "proportions", goal = "testing", plan_p0 = .80,
        plan_p1 = .90, expected_p = .12, threshold_p = .05, target_power = .90, dropout = .15,
        recruit_cap = 240, width_p = .20, seed = 20261002)),
    prevalence = case("prevalence", "Prevalence: estimate disease burden",
      "A diabetes clinic needs to estimate neuropathy prevalence for service planning. Starting with 20% anticipated prevalence, 95% confidence and a five-percentage-point margin of error, calculate the required assessments and recruitment, then simulate intervals to see how estimates vary.",
      "prevalence", list(outcome = "single_proportion", goal = "precision",
        anticipated_p = .20, full_width = .10, confidence = .95, unknown_p = FALSE,
        fixed_n = 246, dropout = .05, seed = 20260942), app = "prevalence_precision"),
    pilot_feasibility = case("pilot_feasibility", "Pilot: retention with limited resources",
      "An available sample can estimate retention in a future study. You can examine the anticipated interval width and simulate intervals, then explain what the uncertainty means for a decision to proceed, amend or stop.",
      "pilot-feasibility", list(outcome = "single_proportion", goal = "fixed",
        anticipated_p = .80, full_width = .20, confidence = .95, unknown_p = FALSE,
        fixed_n = 40, dropout = 0, seed = 20260943), app = "prevalence_precision"),
    alpha_beta = case("alpha_beta", "Blood pressure: Type I error probability, Type II error probability and power",
      "The graphs show false positives, false negatives and power for one population mean with a known SD. You can drag a rejection boundary to change the shaded areas, then explore sample size and one-sided or two-sided rules. The areas are calculated from the normal model.",
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
