check_single_population <- function() {
  source("R/sample_size_functions.R", local=TRUE)
  source("R/activity_bridge.R", local=TRUE)
  source("R/app_presentation.R", local=TRUE)
  source("R/single_population.R", local=TRUE)
  for (outcome in c("means","proportions")) {
    s <- single_population_spec(outcome=outcome,width=if(outcome=="means")4 else .2,B=10000)
    n <- single_population_n(s)
    stopifnot(single_population_width(s,n) <= s$width, single_population_width(s,n-1) > s$width)
    one <- single_population_simulate(s,n)
    reference <- if(outcome=="means") stats::t.test(one$observations,conf.level=s$confidence)$conf.int else
      stats::prop.test(sum(one$observations),n,conf.level=s$confidence,correct=FALSE)$conf.int
    stopifnot(max(abs(unlist(one$results[c("lower","upper")])-as.numeric(reference))) < 1e-10,
      identical(one,single_population_simulate(s,n)),length(one$observations)==n)
    many <- single_population_simulate(s,n,TRUE)
    stopifnot(nrow(many$results)==10000,mean(many$results$cover)>.92,mean(many$results$cover)<.98,
      !any(c("reject","p_value","difference") %in% names(many$results)))
    if(outcome=="means")stopifnot(abs(mean(many$results$width)-single_population_width(s,n))<.04)
  }
  stopifnot(single_population_n(single_population_spec(mean=3)) == single_population_n(single_population_spec(mean=100)),
    inherits(tryCatch(single_population_spec(sd=0),error=identity),"error"),
    inherits(tryCatch(single_population_spec(seed=.Machine$integer.max),error=identity),"error"))
  # Exercise the report against current inputs and invalidate older simulation results.
  shiny::testServer(single_population_server, args=list(id="precision"), {
    session$setInputs(outcome="means",mean=3,sd=5,probability=.3,confidence=.95,
      width_m=4,width_p=.2,dropout=.1,B=100,seed=20260922,run_one=0,run_many=0)
    text <- function() paste(unlist(sections()),collapse=" ")
    stopifnot(grepl("participants in one sample",text()),!grepl("per group|power|Type I|reflection",text()))
    session$setInputs(run_one=1,run_many=1)
    stopifnot(grepl("100 simulated studies",text()),grepl("confidence interval",text()))
    session$setInputs(sd=6)
    stopifnot(grepl("earlier inputs",text()),!grepl("100 simulated studies",text()))
    session$setInputs(outcome="proportions",probability=.4,run_one=2,run_many=2)
    stopifnot(grepl("40%",text()),grepl("Wilson",text()),!grepl("per group|difference",text()))
    path<-tempfile(fileext=".json")
    v<-list(outcome="means",mean=3,sd=5,probability=.3,confidence=.95,width_m=4,width_p=.2,dropout=.1,B=100,seed=20260922)
    writeLines(jsonlite::toJSON(list(schema="single-population-estimation",version=1,inputs=v),auto_unbox=TRUE),path)
    session$setInputs(restore=data.frame(datapath=path))
    stopifnot(is.null(one()),is.null(many()),grepl("Inputs restored",restore_status()))
  })
  message("One-population precision, independent t/Wilson intervals, simulations and report checks passed.")
}
