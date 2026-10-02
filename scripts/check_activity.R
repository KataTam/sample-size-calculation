check_activity <- function() {
  source("R/activity_bridge.R", local = TRUE)
  source("R/teaching_cases.R", local = TRUE)
  expect_error <- function(code) stopifnot(inherits(tryCatch({ force(code); NULL }, error = identity), "error"))
  defaults <- lab_input_defaults()
  stopifnot(identical(validate_lab_inputs(defaults), defaults))
  expect_error(validate_lab_inputs(list(fixed_n = 12.5)))
  expect_error(validate_lab_inputs(list(outcome = "paired")))
  expect_error(validate_lab_inputs(list(goal = "observed_power")))
  expect_error(validate_lab_inputs(list(alpha = Inf)))
  expect_error(validate_lab_inputs(list(expected_p = 1.1)))
  expect_error(validate_lab_inputs(list(expected_m = NA_real_)))
  expect_error(validate_lab_inputs(list(unrecognised = 1)))
  expect_error(validate_study_inputs(list(consent_fraction = 1.5)))
  expect_error(validate_study_inputs(list(cost_per_patient = -1)))
  for (x in teaching_cases()) if (x$app == "power_explorer") {
    values <- x$inputs[names(x$inputs) %in% names(defaults)]
    stopifnot(validate_lab_inputs(values)$outcome %in% c("means", "proportions"))
    roles <- if (values$outcome == "means") c(values$expected_m, values$plan_delta, values$threshold_m)
      else c(values$expected_p, values$plan_p1 - values$plan_p0, values$threshold_p)
    stopifnot(length(unique(round(roles, 10))) == 3L, all(diff(roles) < 0))
  }
  transferred <- list(outcome = "proportions", goal = "fixed", fixed_n = 37,
    expected_p = .18, plan_p0 = .8, plan_p1 = .9, threshold_p = .08, dropout = .15, target_power = .9)
  linked <- jsonlite::fromJSON(utils::URLdecode(sub(".*\\?state=", "", lab_state_url(transferred))), simplifyVector = FALSE)
  stopifnot(linked$goal == "fixed", linked$fixed_n == 37, linked$plan_p0 == .8,
    linked$plan_p1 == .9, linked$expected_p == .18, linked$threshold_p == .08, linked$dropout == .15)
  document <- list(schema = "sample-size-study-plan", version = 1, activity = "rehabilitation",
    inputs = validate_lab_inputs(transferred), study = study_input_defaults())
  document$study$study_question <- "A learner's clinical question"
  document$study$justification <- "Evidence and uncertainty\nA recruitment decision"
  text <- jsonlite::toJSON(document, auto_unbox = TRUE, digits = 16)
  restored <- read_study_plan(text)
  stopifnot(restored$inputs$fixed_n == 37, restored$inputs$goal == "fixed",
    restored$inputs$expected_p == .18,
    identical(restored$study$justification, document$study$justification))
  # Plans saved before the expected-effect fields were introduced still load.
  older <- document; older$inputs$expected_m <- NULL; older$inputs$expected_p <- NULL
  migrated <- read_study_plan(jsonlite::toJSON(older, auto_unbox = TRUE, digits = 16))
  stopifnot(migrated$inputs$expected_m == defaults$expected_m,
    migrated$inputs$expected_p == defaults$expected_p, migrated$inputs$fixed_n == 37)
  expect_error(read_study_plan('{"schema":"another-tool","version":1}'))
  document$inputs$B <- 1e7
  expect_error(read_study_plan(jsonlite::toJSON(document, auto_unbox = TRUE)))

  old <- getwd(); on.exit(setwd(old)); setwd("apps/power_explorer")
  app <- new.env(parent = globalenv()); sys.source("app.R", envir = app)
  shiny::testServer(app$server, {
    messages <- new.env(parent = emptyenv())
    session$sendInputMessage <- function(inputId, message) assign(inputId, message, envir = messages)
    values <- c(lab_input_defaults(), study_input_defaults(), list(run_one = 0, run_many = 0))
    do.call(session$setInputs, values)
    session$setInputs(activity_request = list(activity = "pain_one_many", nonce = 1))
    stopifnot(current_activity() == "pain_one_many", is.null(routed_case()),
      get("fixed_n", messages)$value == 20, get("goal", messages)$value == "fixed",
      get("expected_p", messages)$value == .4, get("threshold_p", messages)$value == .2,
      identical(get("show_advanced", messages)$value, FALSE))
    session$setInputs(activity_request = list(activity = "pilot_feasibility", nonce = 2))
    stopifnot(routed_case()$app == "prevalence_precision")
    session$setInputs(state_request = list(state = list(outcome = "means", goal = "fixed",
      fixed_n = 31, plan_delta = 2, plan_sd = 5, reality = "custom", true_delta = 1, true_sd = 7), nonce = 3))
    stopifnot(is.null(routed_case()), current_activity() == "",
      get("fixed_n", messages)$value == 31, get("true_delta", messages)$value == 1)
    session$setInputs(state_request = list(state = list(fixed_n = 1.5), nonce = 4))
    stopifnot(grepl("Invalid fixed_n", import_status()), get("fixed_n", messages)$value == 31)
    session$setInputs(activity_request = list(activity = "not-a-case", nonce = 5))
    stopifnot(grepl("Unknown teaching case", import_status()))
    session$setInputs(goal = "fixed", fixed_n = 31, reality = "custom", true_delta = 1,
      true_sd = 7, run_one = 1, eligible_monthly = 20, consent_fraction = .5,
      recruitment_months = 10, cost_base = 1000, cost_per_patient = 50)
    before <- one()
    stopifnot(planned()$n == 31, planned()$delta == 3, generating()$delta == 1,
      feasibility()$recruits == 100, feasibility()$budget == 6000)
    session$setInputs(fixed_n = 40)
    stopifnot(identical(before, one()), grepl("Inputs changed", output$one_status))
    session$setInputs(study_design = "paired")
    stopifnot(inherits(tryCatch(planned(), error = identity), "error"),
      !is.null(output$design_route))
  })
  message("Activity routing, validated state links, study-plan round trip, feasibility and saved-result checks passed.")
  invisible(TRUE)
}

if (identical(environment(), globalenv())) check_activity()
