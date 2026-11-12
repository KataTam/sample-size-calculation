# Precision planning and simulation for one population. Original software: MIT.
single_population_spec <- function(outcome = "means", mean = 3, sd = 5, probability = .3,
                                   confidence = .95, width = 4, seed = 20260922, B = 1000) {
  if (!outcome %in% c("means", "proportions")) stop("Choose a population mean or percentage.")
  check_scalar(mean, "Population mean"); check_positive_number(sd, "Population SD")
  check_probability(probability, "Event probability"); check_probability(confidence, "Confidence level")
  check_positive_number(width, "Full interval width")
  if (outcome == "proportions" && width > 1) stop("A percentage interval's full width cannot exceed 100 percentage points.")
  check_integer(seed, "Seed", 0, .Machine$integer.max - 1); check_integer(B, "Repetitions", 1, 10000)
  list(outcome=outcome, mean=mean, sd=sd, probability=probability, confidence=confidence,
       width=width, seed=seed, B=B)
}
single_population_width <- function(spec, n) {
  if (spec$outcome == "means") {
    # E(sample SD) under normal sampling: sigma times c4(n - 1).
    df <- n - 1
    c4 <- sqrt(2/df) * exp(lgamma((df+1)/2) - lgamma(df/2))
    2 * qt((1+spec$confidence)/2, df) * spec$sd * c4 / sqrt(n)
  } else {
    interval <- wilson_interval(spec$probability, n, 1-spec$confidence)
    interval[, "upper"] - interval[, "lower"]
  }
}
single_population_n <- function(spec, maximum=100000) {
  if (single_population_width(spec, maximum) > spec$width) stop("This width target requires more than 100,000 participants.")
  lo <- 2L; hi <- as.integer(maximum)
  while (lo < hi) {
    mid <- floor((lo+hi)/2)
    if (single_population_width(spec, mid) <= spec$width) hi <- mid else lo <- mid+1L
  }
  lo
}
single_population_simulate <- function(spec, n=single_population_n(spec), many=FALSE) {
  check_integer(n, "Participants", 2, 100000)
  with_study_seed(spec$seed + as.integer(many), {
    count <- if (many) spec$B else 1L
    observations <- NULL
    if (spec$outcome == "means") {
      if (many) {
        # The sample mean and sample variance are independent for normal data.
        estimate <- rnorm(count, spec$mean, spec$sd/sqrt(n))
        sample_sd <- spec$sd * sqrt(rchisq(count, n-1)/(n-1))
      } else {
        observations <- rnorm(n, spec$mean, spec$sd)
        estimate <- mean(observations); sample_sd <- sd(observations)
      }
      half <- qt((1+spec$confidence)/2, n-1) * sample_sd/sqrt(n)
      result <- data.frame(estimate=estimate, lower=estimate-half, upper=estimate+half)
      truth <- spec$mean
    } else {
      if (many) event_count <- rbinom(count, n, spec$probability)
      else { observations <- rbinom(n, 1, spec$probability); event_count <- sum(observations) }
      estimate <- event_count/n
      interval <- wilson_interval(estimate, n, 1-spec$confidence)
      result <- data.frame(estimate=estimate, lower=interval[,1], upper=interval[,2])
      truth <- spec$probability
    }
    result$width <- result$upper-result$lower
    result$cover <- result$lower <= truth & result$upper >= truth
    result$width_met <- result$width <= spec$width
    list(spec=spec, n=n, results=result, observations=observations)
  })
}

single_population_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    h3("Estimate one population mean or percentage"),
    p("Choose a confidence interval width, then explore the estimates and intervals from repeated samples."),
    tags$div(class="single-population-inputs well",
      selectInput(ns("outcome"), "Quantity to estimate", c("Population mean"="means", "Population percentage"="proportions")),
      conditionalPanel(sprintf("input['%s'] == 'means'", ns("outcome")),
        numericInput(ns("sd"), "Population standard deviation (outcome units)", 5, min=.01),
        numericInput(ns("width_m"), "Target full interval width (outcome units)", 4, min=.01),
        activity_help("The full width is the distance between the two confidence limits. A width of 4 units corresponds to a margin of about 2 units on each side of the mean.", for_input=ns("width_m"))),
      conditionalPanel(sprintf("input['%s'] == 'proportions'", ns("outcome")),
        percent_slider(ns("probability"), "Assumed event probability (%)", .01, .99, .3),
        percent_slider(ns("width_p"), "Target full interval width (percentage points)", .01, 1, .2, suffix=" percentage points"),
        activity_help("Use the expected percentage with the event in this one population, supported by earlier data. It determines variability for planning and supplies the probability used in the simulations.", for_input=ns("probability"))),
      percent_slider(ns("confidence"), "Confidence level (%)", .8, .99, .95),
      tags$details(tags$summary("Recruitment and simulation settings"),
        percent_slider(ns("dropout"), "Expected loss to follow-up (%)", 0, .5, .1),
        conditionalPanel(sprintf("input['%s'] == 'means'", ns("outcome")),
          numericInput(ns("mean"), "Population mean used in simulation", 3),
          activity_help("This known mean lets you check the simulated intervals. With the SD and width target fixed, changing the mean leaves the required sample size unchanged.", for_input=ns("mean"))),
        numericInput(ns("B"), "Number of simulated studies", 1000, min=100, max=10000, step=100),
        tags$details(tags$summary("Reproducibility settings"),numericInput(ns("seed"), "Random seed", 20260922, min=0, max=.Machine$integer.max - 1)))),
    tabsetPanel(id=ns("view"),
      tabPanel("Overview", uiOutput(ns("result")), plotOutput(ns("curve"),height="280px"),
        p(class="caption", "Figure. Anticipated full confidence interval width versus the total number of analyzable participants in one sample. The point marks the current plan.")),
      tabPanel("Simulations",
        actionButton(ns("run_one"), "Simulate one study",class="btn-primary"),
        actionButton(ns("run_many"), "Simulate many studies",class="btn-primary"),
        uiOutput(ns("simulation_summary")),
        plotOutput(ns("intervals"),height="310px"),
        p(class="caption", "Figure. Confidence intervals from up to 30 simulated studies. The vertical line marks the assumed population value.")),
      tabPanel("Report", uiOutput(ns("report")), activity_report_downloads(ns("download_report")),
        tags$details(tags$summary("Save work for later"), downloadButton(ns("save"), "Save work for later"),
          fileInput(ns("restore"), "Reopen saved work", accept=".json"), textOutput(ns("restore_status"))),
        tags$details(tags$summary("References"),
          p(tags$a(href="https://stat.ethz.ch/R-manual/R-release/library/stats/html/t.test.html", "R: one-sample t confidence interval"), " · ",
            tags$a(href="../book/appendix.html#tutorial-methods", "Tutorial methods and reproducibility"))))))
}

single_population_server <- function(id) shiny::moduleServer(id, function(input, output, session) {
  spec <- reactive(tryCatch(single_population_spec(input$outcome, input$mean, input$sd, input$probability,
    input$confidence, if(input$outcome=="means") input$width_m else input$width_p, input$seed, input$B),
    error=function(e) validate(need(FALSE, conditionMessage(e)))))
  n <- reactive(single_population_n(spec()))
  one <- reactiveVal(NULL); many <- reactiveVal(NULL)
  value <- function(x, s=spec()) if(s$outcome=="means") paste0(round(x,2), " units") else format_percent(x,1)
  width <- function(x, s=spec()) if(s$outcome=="means") paste0(round(x,2), " units") else paste0(round(100*x,1), " percentage points")
  current <- function(saved) !is.null(saved) && identical(saved$spec, spec()) && saved$n==n()
  observeEvent(input$run_one,one(single_population_simulate(spec(),n())),ignoreInit=TRUE)
  observeEvent(input$run_many,many(single_population_simulate(spec(),n(),TRUE)),ignoreInit=TRUE)
  output$result <- renderUI(app_primary_result(n(), "analyzable participants in total",
    paste0("One population sample · ", adjust_for_dropout(n(),input$dropout), " to recruit allowing for ",format_percent(input$dropout), " expected loss.")))
  output$curve <- renderPlot({
    s<-spec(); ns<-unique(round(seq(max(2,n()/2),n()*2,length.out=100)))
    scale<-if(s$outcome=="means")1 else 100
    app_plot_style(); plot(ns,single_population_width(s,ns)*scale,type="l",lwd=2,col="#245e90",
      xlab="Analyzable participants (total)",ylab=if(scale==1)"Full interval width (units)" else "Full interval width (percentage points)")
    abline(h=s$width*scale,lty=2,col="#a45115");app_current_point(n(),single_population_width(s,n())*scale)
  },alt="Anticipated interval width decreases as the total sample grows. The marked sample meets the chosen width target.")
  simulation_lines <- reactive({
    s<-spec(); lines<-character()
    if(current(one())){
      r<-one()$results
      lines<-c(lines,paste0("One study: estimated ",if(s$outcome=="means")"mean " else "percentage ",value(r$estimate),
        "; ",format_percent(s$confidence)," confidence interval ",value(r$lower)," to ",value(r$upper),"; full width ",width(r$width),"."))
    }else lines<-c(lines,if(is.null(one()))"One-study results appear after simulation." else "The saved study uses earlier inputs; a new run will update these results.")
    if(current(many())){
      r<-many()$results
      lines<-c(lines,paste0(nrow(r)," simulated studies, each with ",n()," participants: ",format_percent(mean(r$cover),1),
        " of intervals contain the population value and ",format_percent(mean(r$width_met),1)," meet the width target. Mean full width: ",width(mean(r$width)),"."))
    }else lines<-c(lines,if(is.null(many()))"Repeated-study results appear after simulation." else "The saved batch uses earlier inputs; a new run will update these results.")
    lines
  })
  output$simulation_summary<-renderUI(tagList(lapply(simulation_lines(),p)))
  output$intervals<-renderPlot({
    saved<-if(current(many()))many() else if(current(one()))one() else NULL
    validate(need(!is.null(saved),"Intervals appear after a simulation with the current inputs."))
    r<-head(saved$results,30);s<-saved$spec; scale<-if(s$outcome=="means")1 else 100
    truth<-if(s$outcome=="means")s$mean else s$probability;y<-seq_len(nrow(r))
    app_plot_style(c(4,4,1,1));plot(r$estimate*scale,y,xlim=range(c(r$lower,r$upper,truth))*scale,
      ylim=c(.5,nrow(r)+.5),pch=19,col="#245e90",xlab=if(scale==1)"Population mean (outcome units)" else "Population percentage (%)",ylab="Simulated study")
    segments(r$lower*scale,y,r$upper*scale,y,col="#245e90",lwd=2);abline(v=truth*scale,lty=2,col="#17734c")
  },alt="Simulated confidence intervals for one population; the text gives coverage and interval-width summaries.")
  sections<-reactive({
    s<-spec()
    list("Population and precision target"=c(paste0("One population ",if(s$outcome=="means")"mean" else "percentage",
      " is estimated with ",format_percent(s$confidence)," confidence and a target full interval width of ",width(s$width),"."),
      if(s$outcome=="means")paste0("Assumed SD: ",s$sd," units. Population mean used in simulation: ",value(s$mean),".")
      else paste0("Assumed event probability: ",format_percent(s$probability),".")),
      "Sample size"=paste0(n()," analyzable participants in one sample; ",adjust_for_dropout(n(),input$dropout),
        " participants to recruit allowing for ",format_percent(input$dropout)," expected loss. Anticipated full interval width: ",width(single_population_width(s,n())),"."),
      "Simulation results"=simulation_lines(),
      "Simulation record"=c(paste0("Planning: ",if(s$outcome=="means")"expected one-sample t-interval width under normal sampling" else "Wilson interval width at the assumed event probability",
        "; integer search for the smallest sample meeting the width target."),
        paste0("R ",getRversion(),"; stats ",utils::packageVersion("stats"),". Simulation: ",
          if(s$outcome=="means")"normal samples; t confidence intervals using the sample SD and n - 1 degrees of freedom. Repeated samples use the exact normal and chi-squared distributions of the sample mean and variance."
          else "binomial samples and Wilson confidence intervals.",
          " Seed ",s$seed," for one study and ",s$seed+1," for the repeated batch; ",s$B," repetitions.")))
  })
  output$report<-renderUI(app_report_body(sections(),heading="Single-population estimation report"))
  output$download_report<-downloadHandler(filename=function()"single-population-estimation-report.html",
    content=function(file)writeLines(app_report_document("Single-population estimation report","power_explorer",sections()),file,useBytes=TRUE))
  fields<-c("outcome","mean","sd","probability","confidence","width_m","width_p","dropout","B","seed")
  output$save<-downloadHandler(filename=function()"single-population-estimation-work.json",content=function(file){
    values<-setNames(lapply(fields,function(id)input[[id]]),fields)
    writeLines(jsonlite::toJSON(list(schema="single-population-estimation",version=1,inputs=values),auto_unbox=TRUE,pretty=TRUE),file)
  })
  restore_status<-reactiveVal("");output$restore_status<-renderText(restore_status())
  observeEvent(input$restore,{
    tryCatch({
      saved<-jsonlite::fromJSON(input$restore$datapath);v<-saved$inputs
      stopifnot(identical(saved$schema,"single-population-estimation"),all(fields %in% names(v)))
      single_population_spec(v$outcome,v$mean,v$sd,v$probability,v$confidence,if(v$outcome=="means")v$width_m else v$width_p,v$seed,v$B)
      check_nonnegative_probability(v$dropout,"Expected losses",upper=.51)
      check_positive_number(v$width_m,"Mean interval width")
      check_positive_number(v$width_p,"Percentage interval width")
      if(v$width_p > 1)stop("Percentage interval width cannot exceed 100 percentage points.")
      updateSelectInput(session,"outcome",selected=v$outcome)
      for(id in c("mean","sd","width_m","B","seed"))updateNumericInput(session,id,value=v[[id]])
      for(id in c("probability","confidence","width_p","dropout"))updateSliderInput(session,id,value=v[[id]])
      one(NULL);many(NULL);restore_status("Inputs restored. New simulations will use these settings.")
    },error=function(e)restore_status(paste("The work file could not be restored:",conditionMessage(e))))
  },ignoreInit=TRUE)
})
