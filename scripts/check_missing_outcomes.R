check_missing_outcomes <- function() {
  source("R/sample_size_functions.R", local=TRUE)
  s <- study_spec(outcome="proportions", n=60, B=40000, seed=8128)
  q <- missing_probabilities(.6, .2, 3)
  stopifnot(abs(.6*q[2]+.4*q[1]-.2)<1e-12, abs(q[1]/q[2]-3)<1e-12)
  a <- analyse_binary_unequal(32, 18, 48, 54, .05)
  stopifnot(abs(a$p_value-prop.test(c(32,18),c(48,54),correct=FALSE)$p.value)<1e-12)
  stopifnot(is.na(analyse_binary_unequal(0,1,0,5,.05)$estimate))
  for (mode in c("complete","equal","differential","selective")) {
    settings <- missing_scenario(mode, 60)
    b <- simulate_missing_trials(s, settings)
    target <- if(mode=="selective") .6*(1-q[2])/.8-.3 else .3
    stopifnot(abs(mean(b$results$estimate)-target)<.003,
      abs(mean(b$results$retained_control)-60*(1-settings$loss_control))<.1,
      abs(mean(b$results$retained_treatment)-60*(1-settings$loss_treatment))<.1)
    one <- simulate_missing_one(s,settings)
    stopifnot(nrow(one$data)==120, sum(is.na(one$data$outcome))==sum(one$data$missing),
      sum(!one$data$missing[one$data$group=="Treatment"])==one$result$retained_treatment)
    if(mode=="complete") stopifnot(abs(mean(b$results$reject)-spec_power(s))<.015)
    cat(mode, "mean estimate:",mean(b$results$estimate),"coverage:",mean(b$results$cover),"\n")
  }
  set.seed(81); before <- .Random.seed
  a <- simulate_missing_trials(s,missing_scenario("selective"))
  stopifnot(identical(before,.Random.seed), identical(a,simulate_missing_trials(s,missing_scenario("selective"))))
  tiny <- simulate_missing_trials(s,missing_scenario("selective",2))
  stopifnot(anyNA(tiny$results$estimate), nrow(missing_outcome_summary(tiny))>0)
  old <- getwd(); on.exit(setwd(old)); setwd("apps/power_explorer")
  app <- new.env(parent=globalenv()); sys.source("app.R",envir=app)
  shiny::testServer(app$server, {
    inputs <- lab_input_defaults(); inputs$outcome <- "proportions"; inputs$goal <- "fixed"; inputs$B <- 1000
    inputs$missing_mode <- "selective"; inputs$missing_n <- 80
    do.call(session$setInputs,inputs)
    session$setInputs(run_one=1,run_many=1)
    stopifnot(one()$spec$n==80, many()$spec$n==80, nrow(one()$data)==160,
      many()$meta$missing$mode=="selective", !is.null(output$many_summary), !is.null(output$one_retention),
      !is.null(output$one_result), !is.null(output$one_data), !is.null(output$one_plot), !is.null(output$many_plot),
      !is.null(output$distribution), !is.null(output$p_values))
    exported <- export_rows(many()$results,many()$meta)
    stopifnot(all(exported$missing_failure_multiplier==3), all(exported$missing_n==80), all(exported$generating_n==80))
    downloaded <- read.csv(output$download_many)
    stopifnot(nrow(downloaded)==1000, all(downloaded$missing_n==80), all(downloaded$generating_n==80))
    saved <- many(); session$setInputs(missing_mode="equal")
    stopifnot(identical(saved,many()),grepl("Inputs changed",output$many_status))
    session$setInputs(run_many=2); stopifnot(many()$missing$mode=="equal")
    session$setInputs(missing_mode="off",run_many=3)
    stopifnot(is.null(many()$missing),many()$spec$n==60)
    restored <- validate_lab_inputs(list(missing_mode="selective",missing_n=80))
    stopifnot(restored$missing_n==80,restored$missing_mode=="selective")
    apply_case("pain_simulation",reset=TRUE)
    stopifnot(is.null(one_saved()),is.null(many_saved()))
  })
  message("Missing outcomes: calibration, unequal-size analysis, expected bias, incomplete comparisons, reproducibility, saved results and exports passed.")
}
