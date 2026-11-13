# Example explanations use the same calculated objects as the visible results.
# Original software: MIT. Teaching text: CC BY-SA 4.0.
model_number <- function(x) format(signif(x, 4), trim = TRUE, scientific = FALSE)
model_effect <- function(x, outcome) paste(model_number(if (outcome == "proportions") 100*x else x),
  if (outcome == "proportions") "percentage points" else "units")

recruitment_model_answer <- function(x, switching, already_included) {
  paste0("I would recruit ", x$per_group, " per group (", x$total, " total), starting from ",
    x$starting, " analyzable participants per group. ",
    if (switching) paste0("Switching multiplies that requirement by ", round(x$multiplier, 3), ". ")
    else if (already_included) "The starting requirement already includes switching. " else "",
    if (x$losses[1] == x$losses[2]) paste0("This allows for ", format_percent(x$losses[1]), " loss in each group. ")
    else paste0("This allows for ", format_percent(x$losses[1]), " novel-group and ", format_percent(x$losses[2]), " standard-group losses, using the larger requirement for both. "),
    "The ", if (switching || already_included) "loss and switching assumptions need" else "loss assumption needs",
    " support from [comparable follow-up evidence]. Missing outcomes will be handled using [analysis plan].")
}

sampling_model_answer <- function(x) {
  null <- x$mu1 == x$mu0
  wrong <- (x$sidedness == "greater" && x$mu1 < x$mu0) || (x$sidedness == "less" && x$mu1 > x$mu0)
  paste0("With ", x$n, " observations, ",
    if (null) paste0("rejection under the null is ", format_percent(x$power, 2), ". This false-positive probability stays at the chosen Type I error probability as sample size increases.")
    else paste0("power is ", format_percent(x$power, 2), " when the population mean is ", model_number(x$mu1), " mmHg (null reference ", model_number(x$mu0), " mmHg). ",
      if (wrong) "A larger sample reduces power because the true difference is opposite to the chosen one-sided direction."
      else "A larger sample increases power by narrowing the distribution of sample means, with the population means, SD, and test settings held fixed."),
    " The shaded detection area represents this probability.")
}

precision_model_answer <- function(x, p, n, case_id, saved = NULL) {
  width <- 2 * qnorm((1+x$confidence)/2) * sqrt(p$planning_p * (1-p$planning_p) / n)
  text <- paste0(if (case_id == "pilot_feasibility") "For the retention pilot, " else "For the prevalence estimate, ",
    "I would accept a margin of about ", model_number(50*x$full_width), " percentage points only if it supports ",
    if (case_id == "pilot_feasibility") "the agreed progression decision. " else "the service-planning decision. ",
    "At ", format_percent(x$confidence), " confidence, ", n, " participants give an approximate full width of ",
    round(100*width, 1), " points, ", if (width <= x$full_width) "meeting" else "exceeding",
    " the ", model_number(100*x$full_width), "-point target. ",
    if (x$goal == "fixed") paste0("The available sample is fixed at ", n, ". ") else "",
    if (x$unknown_p) paste0("Conservative planning uses 50%; simulation assumes ", format_percent(x$anticipated_p), ". ") else "",
    if (x$dropout > 0) paste0("With ", format_percent(x$dropout), if (case_id == "pilot_feasibility") " unknown retention status" else " unavailable outcome status", ", the recruitment target is ", adjust_for_dropout(n, x$dropout), ".") else "")
  if (!is.null(saved)) {
    r <- saved$result
    text <- paste0(trimws(text), " The saved sample has a ", format_percent(saved$confidence),
      " interval width of ", round(100*r$full_width, 1), " points. ",
      if (!identical(saved$inputs, x)) "It uses earlier inputs; a new draw will use the current settings." else "Widths vary between samples.")
  }
  paste0(trimws(text), " The interval should distinguish [values leading to different decisions], supported by [clinical or service-planning evidence]. Recruitment is feasible if [available participants, time, and resources] can support the required count.")
}

lab_question_help <- function(design) switch(design,
  two_groups = "Your question should identify the population, intervention or exposure, comparator, outcome, and assessment time (PICO). Each participant contributes one outcome; this calculation assumes independent observations and equal allocation.",
  paired = "Your question should identify the population, the conditions or times being compared, and the outcome. Paired measurements come from the same participants; their correlation matters for planning.",
  single_proportion = "Your question should identify the population, event definition, denominator, and assessment time. A single-population estimate needs a sampling method and a useful precision target.",
  observational = "Your question should identify the population, exposure, comparison, outcome, and assessment time. Relevant confounding and selection should be considered.",
  diagnostic = "Your question should identify the population, index test, reference standard, target condition, and assessment time. The intended accuracy measures guide planning.",
  prediction = "Your question should identify the population, predicted outcome, prediction horizon, and whether the aim is model development, evaluation, or comparison. Predictors must be available when predictions are made.",
  "Your question should identify the population, outcome, assessment time, and intended conclusion. The planning method should reflect the independent units and any paired or clustered observations.")

lab_model_context <- function(id, outcome, design) {
  if (design != "two_groups") return(list(
    question = switch(design,
      paired = "How does the outcome differ between paired observations or repeated measurements within participants? The outcome and assessment times should be specified.",
      single_proportion = "What percentage of the defined population has the specified outcome at the chosen assessment time?",
      observational = "How is the specified exposure associated with the outcome in the target population, accounting for relevant confounding?",
      diagnostic = "How accurately does the index test identify the condition against the specified reference standard?",
      prediction = "How well does the prediction model perform for the specified outcome and prediction horizon in the target population?",
      "What question will this design answer, in which population and at what assessment time?"),
    burden = "I would weigh assessment burden and possible harms against the value of the findings, with appropriate consent and data access.",
    evidence = "I need evidence for this design's outcome, dependence between observations, and analysis assumptions."))
  if (id == "rehabilitation" && outcome == "means") return(list(
    question = "Does a rehabilitation program improve the mean mobility score at six weeks compared with usual care?",
    burden = "Rehabilitation sessions and six-week assessments take participant time. I would consider discomfort, access to care, and possible mobility benefits.",
    evidence = "These are teaching assumptions; comparable rehabilitation studies with six-week mobility outcomes are needed to justify them."))
  if (id == "adherence" && outcome == "proportions") return(list(
    question = "Does probiotic supplementation increase the percentage of pregnant women with overweight or obesity who remain free of gestational diabetes at the prespecified assessment, compared with no supplementation?",
    burden = "Supplementation and glucose assessments add burden. I would consider maternal and fetal safety alongside possible prevention of gestational diabetes.",
    evidence = "These are hypothetical inputs; comparable probiotic trials are needed to justify the event percentages and follow-up assumptions."))
  if (id == "discharge" && outcome == "proportions") return(list(
    question = "Does the new care pathway increase the percentage of patients discharged by the prespecified day compared with standard care?",
    burden = "I would consider follow-up burden and readmission risk alongside the possible benefit of earlier discharge.",
    evidence = "These are hypothetical inputs; comparable care pathways with the same discharge deadline are needed to justify them."))
  if (grepl("^pain_", id) && outcome == "proportions") return(list(
    question = "Does Neravixa increase the percentage achieving pain relief at four weeks compared with duloxetine in adults with painful diabetic peripheral neuropathy?",
    burden = "The novel treatment adds four clinic visits and a risk of short-lived dizziness. Patient and clinical judgments should weigh these against additional four-week pain relief.",
    evidence = "The small Neravixa-versus-duloxetine pilot leaves relief percentages uncertain. Differences in pain severity, background medication or relief definitions could limit how other four-week studies apply."))
  list(question = if (outcome == "means") "Does the intervention improve the mean outcome compared with the control condition in the specified population at the chosen assessment time?"
      else "Does the intervention improve the percentage with the favorable outcome compared with the control condition in the specified population at the chosen assessment time?",
    burden = "I would weigh visits, assessments, and possible harms against the expected patient benefit, with appropriate consent.",
    evidence = "These illustrative inputs need evidence from comparable populations, outcomes, and assessment times, including uncertainty in the estimates.")
}

lab_model_answers <- function(v, details, case_id, x = NULL, capacity = NULL, saved = NULL, current = NULL) {
  context <- lab_model_context(case_id, v$outcome, details$study_design)
  if (is.null(x)) return(list(study_question = context$question, participant_burden = context$burden,
    evidence_sources = paste(context$evidence, "[Source] reports [population, outcome, and assessment time], with uncertainty of [range]. Plausible alternatives are [values]."),
    clinical_relevance = "The result would inform [clinical or scientific decision]. A useful effect or precision target needs support from [patients, clinicians, or relevant evidence].",
    justification = "I would use a matching planning method for the selected design, accounting for its independent units and dependence between observations. [Evidence] supports [inputs]; [alternative assumptions] give [results], with [remaining limitations]."))
  effect <- function(z) model_effect(z, x$outcome)
  recruit <- adjust_for_dropout(x$n, v$dropout)
  actual_power <- spec_power(x); width <- anticipated_width(x)
  feasible <- 2*recruit <= v$recruit_cap && capacity$balanced >= 2*recruit
  missed <- if (v$goal == "fixed") c(if (actual_power < v$target_power) "power", if (width > x$width_target) "interval-width") else character()
  justification <- paste0("The plan uses ", x$n, " participants per group (", 2*x$n, " total) and ",
    recruit, " recruits per group (", 2*recruit, " total) allowing for ", format_percent(v$dropout), " loss. ",
    if (v$goal == "precision") paste0("The anticipated ", format_percent(1-x$alpha), " interval width is ", effect(width),
      " (target ", effect(x$width_target), "). ")
    else paste0("Power at ", effect(true_difference(x)), " is ", format_percent(actual_power, 1),
      if (v$goal == "testing") paste0(" (target ", format_percent(v$target_power), ")") else "", ". "),
    if (v$goal == "fixed") paste0("The anticipated ", format_percent(1-x$alpha), " interval width is ", effect(width), ". ") else "",
    "Recruitment ", if (2*recruit <= v$recruit_cap) "fits" else "exceeds", " the cap of ", v$recruit_cap,
    "; expected capacity is ", capacity$recruits, ". ",
    if (length(missed)) paste0("The fixed sample misses the ", paste(missed, collapse = " and "),
      " target", if (length(missed) > 1) "s" else "", ". I would reconsider the question or available sample.")
    else if (feasible) "I would check plausible alternative assumptions before adopting this plan."
    else "I would resolve the recruitment shortfall before adopting this plan.",
    " [Source] supports the selected assumptions; [plausible alternatives] give [sensitivity results]. [Remaining limitations] affect the recommendation.")
  if (case_id == "pain_curves" && v$goal == "fixed") {
    effects <- true_difference(x) * c(.5, 2/3, 1)
    alternatives <- lapply(effects, function(difference) {
      z <- x
      if (z$outcome == "means") z$delta <- difference else z$p_treatment <- z$p_control + difference
      z
    })
    powers <- vapply(alternatives, spec_power, numeric(1))
    counts <- vapply(alternatives, function(z) {
      if (abs(true_difference(z)) < 1e-12) return(NA_real_)
      plan_n(z, target_power = v$target_power)
    }, numeric(1))
    justification <- paste0("With ", x$n, " analyzable patients per group, power is ",
      paste(paste0(format_percent(powers, 1), " at ", effect(effects)), collapse = "; "),
      ". For ", format_percent(v$target_power), " power, the corresponding requirements are ",
      paste(ifelse(is.na(counts), "undefined for a zero difference", counts), collapse = ", "),
      " per group. [Evidence] should justify the plausible differences used for the recruitment or design decision.")
  }
  if (!is.null(saved)) {
    valid <- is.finite(saved$results$estimate)
    rate <- if (any(valid)) format_percent(mean(if (v$goal == "precision") saved$results$cover[valid] else saved$results$reject[valid]), 1) else "unavailable"
    justification <- paste0(justification, " The saved batch of ", saved$spec$B, " studies (", saved$spec$n,
      if (is.null(saved$missing)) " analyzable" else " recruited", " per group) gives ", rate,
      if (v$goal == "precision") " interval coverage at " else " rejection at ", model_effect(true_difference(saved$spec), saved$spec$outcome), ". ",
      if (!identical(saved$meta, current)) "It uses earlier inputs. " else "",
      if (!is.null(saved$missing)) "Missing-outcome bias and interval coverage also inform the decision." else "")
  }
  list(study_question = context$question, participant_burden = context$burden,
    clinical_relevance = if (v$goal == "precision") paste0("A full interval width of ", effect(x$width_target),
      " should distinguish [values leading to different decisions] around the ", effect(x$threshold), " between-group clinical threshold. [Patient or clinical input] should justify that choice.")
      else paste0("The selected minimum worthwhile between-group benefit is ", effect(x$threshold), ". [Patient or clinical input] should justify this benefit in relation to treatment harms, burden and alternatives. The clinical threshold should inform the chosen target difference."),
    evidence_sources = paste0(context$evidence, " Earlier observed difference: ", effect(if (x$outcome == "means") v$expected_m else v$expected_p),
      if (v$goal == "precision") "; simulation population difference " else "; target ", effect(true_difference(x)), "; ",
      if (x$outcome == "means") paste0("SD ", model_number(x$sd), ".")
      else paste0("control ", format_percent(x$p_control), ", treatment ", format_percent(x$p_treatment), "."),
      " [Source] reports [comparable population, outcome, and assessment time], with uncertainty of [range]. I would examine [plausible alternative inputs]."),
    justification = trimws(justification))
}
