# Example explanations use the same calculated objects as the visible results.
# Original software: MIT. Teaching text: CC BY-SA 4.0.
model_number <- function(x) format(signif(x, 4), trim = TRUE, scientific = FALSE)
model_effect <- function(x, outcome) paste(model_number(if (outcome == "proportions") 100*x else x),
  if (outcome == "proportions") "percentage points" else "units")

recruitment_model_answer <- function(x, switching, already_included) {
  paste0("Starting with ", x$starting, " participants per group for analysis, ",
    if (switching) paste0("the switching assumptions give a multiplier of ", round(x$multiplier, 3),
      " and an unrounded requirement of ", round(x$after_switching, 2), " per group. ")
    else if (already_included) "the starting requirement already includes expected switching. The switching allowance is applied once. "
    else "the current plan applies a switching multiplier of 1. ",
    "Expected losses are ", format_percent(x$losses[1]), " in the novel-treatment group and ",
    format_percent(x$losses[2]), " in the standard-treatment group. Equal recruitment uses the larger requirement: ",
    x$per_group, " per group (", x$total, " total), rounded upward after the adjustments. ",
    "The expected retained counts are ", round(x$expected_retained[1], 1), " and ", round(x$expected_retained[2], 1),
    ". Actual retention varies. Evidence should support the loss and switching assumptions, with missing outcomes addressed in the analysis plan.")
}

sampling_model_answer <- function(x) {
  null <- x$mu1 == x$mu0
  wrong <- (x$sidedness == "greater" && x$mu1 < x$mu0) || (x$sidedness == "less" && x$mu1 > x$mu0)
  paste0("With ", x$n, " observations, null mean ", x$mu0, ", specified population mean ", x$mu1,
    " and population SD ", x$sigma, ", the standard error is ", round(x$se, 4), ". The ",
    switch(x$sidedness, greater = "greater-than", less = "less-than", two.sided = "two-sided"),
    " test has a rejection probability of ", format_percent(x$power, 2),
    if (null) " under the null. This is its false-positive probability. Increasing sample size keeps this probability at the chosen Type I error probability. "
    else paste0(" at this population mean, and a Type II error probability of ", format_percent(x$beta, 2), ". ",
      if (wrong) "The population difference is opposite to the test's chosen direction. Increasing sample size concentrates sample means away from the rejection region and reduces power. "
      else "Increasing sample size while holding the population means and SD fixed narrows the distribution of sample means and increases power. "),
    "The chosen Type I error probability is ", format_percent(x$type1, 2), ".")
}

precision_model_answer <- function(x, p, n, case_id, saved = NULL) {
  width <- 2 * qnorm((1+x$confidence)/2) * sqrt(p$planning_p * (1-p$planning_p) / n)
  text <- paste0(if (case_id == "pilot_feasibility") "For the retention pilot, " else "For the prevalence estimate, ",
    "the requested full width is ", model_number(100*x$full_width), " percentage points (margin about ",
    model_number(50*x$full_width), " points) at ", format_percent(x$confidence), " confidence. ",
    if (x$unknown_p) paste0("Conservative planning uses 50%; the simulation assumes ", format_percent(x$anticipated_p), ". ")
    else paste0("The assumed population percentage is ", format_percent(x$anticipated_p), ". "),
    if (x$goal == "fixed") paste0("The available sample is fixed at ", n, ". ")
    else paste0("The normal approximation requires ", n, " participants for analysis. "),
    "Its approximate full width is ", round(100*width, 1), " percentage points, ",
    if (width <= x$full_width) "meeting" else "exceeding", " the target. With ", format_percent(x$dropout),
    " expected losses, the recruitment target is ", adjust_for_dropout(n, x$dropout), ". ",
    if (case_id == "pilot_feasibility") "The width should support the prespecified decision to proceed, amend or stop. "
    else "The width should be useful for the population or service-planning decision. ")
  if (!is.null(saved)) {
    r <- saved$result
    text <- paste0(text, "The saved sample has ", r$events, " events among ", r$n, " participants: ",
      format_percent(r$estimate, 1), ", with a ", format_percent(saved$confidence), " interval from ",
      format_percent(r$lower, 1), " to ", format_percent(r$upper, 1), ". Its full width is ",
      round(100*r$full_width, 1), " percentage points. ",
      if (!identical(saved$inputs, x)) "This sample uses earlier inputs; drawing again will update the interval. " else "",
      "Realized interval widths vary between samples.")
  }
  text
}

lab_model_context <- function(id, outcome, design) {
  if (design != "two_groups") return(list(
    question = switch(design,
      paired = "How does the outcome differ between paired observations or repeated measurements within participants? The outcome and assessment times should be specified.",
      single_proportion = "What percentage of the defined population has the specified outcome at the chosen assessment time?",
      observational = "How is the specified exposure associated with the outcome in the target population, accounting for relevant confounding?",
      diagnostic = "How accurately does the index test identify the condition against the specified reference standard?",
      prediction = "How well does the prediction model perform for the specified outcome and prediction horizon in the target population?",
      "What question will this design answer, in which population and at what assessment time?"),
    burden = "The consent, data access, assessment burden and potential harms should be evaluated for this study design.",
    evidence = "Comparable studies should inform the design-specific assumptions, dependence between observations and the planned analysis."))
  if (id == "rehabilitation" && outcome == "means") return(list(
    question = "Does a rehabilitation program improve the mean mobility score at six weeks compared with usual care?",
    burden = "Rehabilitation sessions, assessments and follow-up require participant time. Expected benefits, potential harms and access to care should justify this burden.",
    evidence = "The rehabilitation values are teaching assumptions. Evidence should come from comparable mobility scores, patients and six-week follow-up."))
  if (id == "adherence" && outcome == "proportions") return(list(
    question = "Does probiotic supplementation increase the percentage of pregnant women with overweight or obesity who remain free of gestational diabetes at the prespecified assessment, compared with no supplementation?",
    burden = "Supplementation, adherence monitoring and glucose assessments add burden. Maternal and fetal safety, consent and possible harms require justification.",
    evidence = "The probiotics event percentages are hypothetical teaching inputs. Relevant trials should support the target difference, assessment time and anticipated losses."))
  if (id == "discharge" && outcome == "proportions") return(list(
    question = "Does the new care pathway increase the percentage of patients discharged by the prespecified day compared with standard care?",
    burden = "Changes to care and discharge follow-up should be assessed for safety, participant burden and possible readmission.",
    evidence = "The discharge percentages are hypothetical teaching inputs. Comparable pathways, eligibility criteria and discharge time points should support the assumptions."))
  if (grepl("^pain_", id) && outcome == "proportions") return(list(
    question = "Does the novel treatment increase the percentage of adults with chronic pain reporting relief at four weeks compared with standard treatment?",
    burden = "Treatment and four-week follow-up add visits and assessments. Expected benefits, possible harms and participant time should be considered.",
    evidence = "The chronic-pain pilot illustrates uncertainty in small samples. Evidence should support the currently selected event percentages, target difference and follow-up assumptions."))
  list(question = if (outcome == "means") "Does the intervention improve the mean outcome compared with the control condition in the specified population at the chosen assessment time?"
      else "Does the intervention improve the percentage with the favorable outcome compared with the control condition in the specified population at the chosen assessment time?",
    burden = "Visits, assessments, participant time, possible harms and consent requirements should be justified for the intervention and population.",
    evidence = "Comparable studies should support the currently selected population, outcome, assessment time and numerical assumptions; their uncertainty should inform sensitivity analyses.")
}

lab_model_answers <- function(v, details, case_id, x = NULL, capacity = NULL, saved = NULL, current = NULL) {
  context <- lab_model_context(case_id, v$outcome, details$study_design)
  if (is.null(x)) return(list(study_question = context$question, participant_burden = context$burden,
    evidence_sources = context$evidence,
    clinical_relevance = "The clinically useful comparison or precision target should be defined for this design and supported by patient and clinical input.",
    justification = "The selected design needs a matching planning method. The study report should state its assumptions, independent units, resulting sample size and recruitment feasibility."))
  effect <- function(z) model_effect(z, x$outcome)
  recruit <- adjust_for_dropout(x$n, v$dropout)
  actual_power <- spec_power(x); width <- anticipated_width(x)
  justification <- paste0(switch(v$goal,
    testing = paste0("For ", format_percent(v$target_power), " target power at a difference of ", effect(true_difference(x)), ", "),
    precision = paste0("For a target full confidence interval width of ", effect(x$width_target), ", "),
    fixed = "With the available analyzable sample held fixed, "),
    "the current plan uses ", x$n, " participants per group (", 2*x$n, " total). ",
    "At ", format_percent(x$alpha), " Type I error probability, calculated power at the target difference is ",
    format_percent(actual_power, 1), "; anticipated full interval width is ", effect(width),
    " at ", format_percent(1-x$alpha), " confidence. ",
    "Allowing for ", format_percent(v$dropout), " expected losses gives ", recruit, " recruits per group (", 2*recruit,
    " total). This ", if (2*recruit <= v$recruit_cap) "fits within" else "exceeds", " the recruitment cap of ", v$recruit_cap,
    ". The eligibility, consent and time assumptions imply ", capacity$recruits, " expected recruits, ",
    if (capacity$balanced >= 2*recruit) "enough" else "too few", " for the current plan under equal allocation. ",
    "The recommendation depends on evidence for these assumptions and sensitivity to plausible alternatives.")
  if (!is.null(saved)) {
    valid <- is.finite(saved$results$estimate)
    rate <- if (any(valid)) format_percent(mean(saved$results$reject[valid]), 1) else "unavailable"
    justification <- paste0(justification, " The saved batch of ", saved$spec$B, " studies reports a rejection percentage of ", rate,
      " at a simulated population difference of ", model_effect(true_difference(saved$spec), saved$spec$outcome), ". ",
      if (!identical(saved$meta, current)) "This batch uses earlier inputs; rerunning will update its results. " else "",
      if (!is.null(saved$missing)) "Its available-case results also require assessment of bias and coverage under the chosen missing-outcome assumptions." else "")
  }
  list(study_question = context$question, participant_burden = context$burden,
    clinical_relevance = paste0("The current between-group clinical threshold is ", effect(x$threshold),
      ". The desired full interval width is ", effect(x$width_target), ". Patient and clinical input should justify their usefulness for the decision, considering burden, harms and cost."),
    evidence_sources = paste0(context$evidence, " Current assumptions: expected difference ", effect(if (x$outcome == "means") v$expected_m else v$expected_p),
      "; target difference ", effect(true_difference(x)), "; ",
      if (x$outcome == "means") paste0("common SD ", model_number(x$sd), " units.")
      else paste0("event percentages ", format_percent(x$p_control), " with control and ", format_percent(x$p_treatment), " with treatment.")),
    justification = justification)
}
