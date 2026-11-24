library(shiny)
source("../../R/sample_size_functions.R")
source("../../R/tutorial_helpers.R")
source("../../R/teaching_cases.R")
source("../../R/activity_bridge.R")
source("../../R/model_answers.R")
source("../../R/app_presentation.R")
source("../../R/single_population.R")

# Let the download response supply the filename. Chromium's download attribute
# can bypass the service worker serving a Shinylive download (issue 468227).
downloadButton <- function(...) {
  button <- shiny::downloadButton(...)
  button$attribs$download <- NULL
  button$attribs$target <- "_self"
  button
}

download_script <- activity_download_script()

ui <- fluidPage(
  tags$head(tags$script(src = "sampling-journey.js"), tags$link(rel = "stylesheet", href = "sampling-journey.css"), tags$script(HTML(download_script)), tags$script(HTML(activity_bridge_script()))),
  tags$p(id = "download-status", role = "status", `aria-live` = "polite"),
  tags$head(tags$style(HTML("body{font-size:17px;line-height:1.55}.well{background:#f4f7fa}table{font-size:15px}.shiny-html-output{overflow-x:auto}.shiny-output-error-validation{color:#8a3410}.caption{font-size:.9em;color:#505b64;margin:8px 0 20px}"))),
  titlePanel("Sample size reasoning lab", windowTitle = "Sample size reasoning lab"),
  uiOutput("activity_sequence"),
  tags$div(class = "activity-picker", selectInput("activity_choice", "Prepared activity", c("Choose an activity or use your own inputs" = "",
    setNames(names(teaching_cases()), vapply(teaching_cases(), function(x) x$title, character(1)))), width = "100%")),
  activity_description(uiOutput("activity_context")),
  textOutput("plan_import_status"),
  textOutput("missing_note"),
  sidebarLayout(sidebarPanel(width = 4,
    conditionalPanel("input.goal != 'precision'", textOutput("scenario_summary"),
      conditionalPanel("input.activity_choice != 'pain_curves' && input.activity_choice != 'pain_one_many'", uiOutput("simulation_target"))),
    conditionalPanel("input.goal == 'fixed'", numericInput("fixed_n", "Analyzable participants per group", 60, min = 2, max = 100000, step = 1),
      activity_help("Enter the number with analyzable outcomes in each group. The power curves and simulation use this count; expected losses are applied separately when calculating recruitment.", for_input = "fixed_n")),
    conditionalPanel("output.pain_report && !input.show_advanced",
      radioButtons("pain_population", "Population pain-relief percentages",
        c("30% standard; 60% novel: treatments differ"="difference",
          "30% standard; 30% novel: equal effects"="equal"), selected="difference"),
      checkboxInput("compare_populations", "Show both population scenarios side by side", TRUE)),
    tags$details(id="lab-settings", class="activity-details", tags$summary("Settings"),
    selectInput("goal", "Planning goal", c("Test a difference from zero" = "testing", "Estimation with a target interval width" = "precision", "Assess a fixed number of available participants" = "fixed")),
    activity_help("Testing and the fixed-sample option concern two treatment groups. Estimation uses a confidence-interval-width target for one population mean or percentage.", for_input = "goal"),
    conditionalPanel("input.goal != 'precision'",
    checkboxInput("show_advanced", "Additional settings", FALSE),
    selectInput("outcome", "Outcome", c("Continuous (numerical) outcome" = "means", "Binary (yes/no) outcome" = "proportions")),
    p("Two equally sized groups, with one outcome per participant and independent observations. Differences are treatment minus control; positive values mean benefit in these cases."),
    conditionalPanel("input.outcome == 'means'",
      conditionalPanel("input.goal != 'precision'", numericInput("expected_m", "Difference observed in previous data (outcome units)", 4, step = .5)),
      numericInput("plan_delta", "Target difference: used in the sample size calculation (outcome units)", 3, step = .5),
      numericInput("plan_sd", "Standard deviation: variation between patients (outcome units)", 5, min = .1),
      conditionalPanel("input.goal != 'precision'", activity_help("Record a difference calculated from earlier data, in the outcome units. It provides uncertain evidence for planning; the target and clinical threshold need separate justification.", for_input = "expected_m")),
      activity_help("Use a clinically worthwhile, plausible between-group difference in the outcome's units. Power is evaluated at this value.", for_input = "plan_delta"),
      activity_help("Use an SD from comparable patients on the same outcome scale. It describes variation between individuals; this calculation assumes equal SDs in both groups.", for_input = "plan_sd"),
      tagList(
      numericInput("threshold_m", "Clinically important difference (outcome units)", 2, min = .1),
      activity_help("Patient and clinical input should support this minimum worthwhile benefit. It applies to the difference between group means and informs the target chosen for the power calculation.", for_input = "threshold_m")),
      conditionalPanel("(input.show_advanced && input.activity_choice != 'pain_curves') || input.goal == 'precision'",
      numericInput("width_m", "Target full confidence interval width (outcome units)", 4, min = .1),
      activity_help("Use the distance from the lower to upper confidence limit. A width of 4 means a margin of about 2 units on each side; narrower targets need more participants.", for_input = "width_m"))),
    conditionalPanel("input.outcome == 'proportions'",
      percent_slider("expected_p", "Difference observed in previous data (percentage points)", value = .4, min = -1, max = 1, step = .01, suffix = " percentage points"),
      percent_slider("plan_p0", "Standard treatment: event probability used for planning (%)", .01, .99, .3, step = .01),
      percent_slider("plan_p1", "Novel treatment: event probability used for planning (%)", .01, .99, .6, step = .01),
      activity_help("Record a treatment-minus-control difference observed in earlier data, in percentage points. In the neuropathic pain pilot this was 40 points. Its relevance and uncertainty inform the target chosen below.", for_input = "expected_p"),
      activity_help("Use evidence for the same favorable event, population, and follow-up time. This percentage sets the baseline for the comparison.", for_input = "plan_p0"),
      activity_help("Its difference from the standard-treatment percentage sets the target difference. Both groups should use the same favorable-event definition and follow-up time.", for_input = "plan_p1"),
      tagList(
      percent_slider("threshold_p", "Clinically important difference (percentage points)", value = .2, min = .001, max = 1, step = .01, suffix = " percentage points"),
      activity_help("Patient and clinical input should support this minimum worthwhile increase in the favorable-event percentage. It informs the target chosen for the power calculation.", for_input = "threshold_p")),
      conditionalPanel("(input.show_advanced && input.activity_choice != 'pain_curves') || input.goal == 'precision'",
      percent_slider("width_p", "Target full confidence interval width (percentage points)", value = .2, min = .001, max = 2, step = .01, suffix = " percentage points"),
      activity_help("Use the distance between confidence limits, in percentage points. A full width of 20 points corresponds to a margin of about 10 points on each side.", for_input = "width_p"))),
    conditionalPanel("input.goal != 'precision'", percent_slider("alpha", tags$span(tags$a(href = "../book/Sample_size_open_module.html#alpha", target = "_blank", rel = "noopener", "Type I error probability"),
      " (%)"), .001, .1, .05, step = .001),
    activity_help("A 5% setting allows a 5% false-positive probability when population outcomes are equal. The app uses a two-sided test.", for_input = "alpha"),
    percent_slider("target_power", tags$span("Target ", tags$a(href = "../book/Sample_size_open_module.html#statistical-power", target = "_blank", rel = "noopener", "power"),
      " (%)"), .5, .99, .8, step = .01),
    activity_help("A 90% target aims to detect the specified true difference in 90% of repeated trials, leaving a 10% false-negative probability. Higher targets require more participants.", for_input = "target_power")),
    conditionalPanel("input.goal == 'precision'", percent_slider("confidence", "Confidence level (%)", .90, .999, .95, step = .001),
      activity_help("For 95% confidence, about 95% of intervals across repeated trials contain the population value under the model assumptions.", for_input = "confidence")),
    percent_slider("dropout", "Expected loss to follow-up in each group (%)", 0, .5, .1, step = .01),
    activity_help("This percentage adjusts recruitment. For a fixed analyzable sample, the curve keeps the selected count. The missing-outcome settings simulate incomplete outcomes.", for_input = "dropout"),
    tags$div(class = "lab-recruitment", numericInput("recruit_cap", "Maximum recruitment, across both groups", 200, min = 4, max = 200000, step = 2),
    activity_help("Enter total recruitment across both groups. In sample-size planning, this sets the graph's available count after expected losses. In fixed-sample mode, the graph uses the analyzable count entered above.", for_input = "recruit_cap")),
    conditionalPanel("input.show_advanced",
    h4("What if the assumptions differ?"),
    selectInput("reality", "Assumptions for the simulated trials", c("Same as planning assumptions" = "same", "No true treatment effect" = "null", "Custom effect or variability" = "custom")),
    activity_help("These choices change the populations generating the simulated data while keeping the planned sample size fixed. The null scenario assesses false positives.", for_input = "reality"),
    conditionalPanel("input.reality == 'custom' && input.outcome == 'means'",
      numericInput("true_delta", "True treatment effect assumed for simulation (outcome units; zero or negative allowed)", 1, step = .5),
      numericInput("true_sd", "Standard deviation assumed for simulation (outcome units)", 7, min = .1)),
    conditionalPanel("input.reality == 'custom' && input.outcome == 'proportions'",
      percent_slider("true_p0", "Control event probability assumed for simulation (%)", .01, .99, .3, step = .01),
      percent_slider("true_p1", "Treatment event probability assumed for simulation (%)", .01, .99, .4, step = .01)),
    conditionalPanel("input.outcome == 'proportions'",
      tags$details(id = "missing-controls", tags$summary("Explore missing outcomes"),
        p("These scenarios start with recruited participants and analyze observed outcomes. Results show detection, bias, and confidence interval coverage together."),
        selectInput("missing_mode", "Missing-outcome scenario", c(
          "Usual simulation: fixed analyzable counts" = "off",
          "Complete outcomes" = "complete", "Equal losses: 10% in each group" = "equal",
          "Unequal losses: 10% standard, 20% novel" = "differential",
          "Outcome-related losses: 10% standard, 20% novel" = "selective")),
        numericInput("missing_n", "Recruited participants per group for these scenarios", 60, min=2, max=100000, step=1),
        activity_help("Equal and unequal losses are unrelated to the event. Outcome-related losses make missingness three times as likely without the event in the novel group, while retaining 20% average loss. Standard-group losses remain unrelated to the event.", for_input = "missing_mode"),
        activity_help("Use the starting recruitment in each group. Simulations then remove outcomes according to the selected missingness scenario.", for_input = "missing_n"),
        p("One trial and Repeated trials use this recruited count while the extension is active. Planning curves retain their complete-data assumptions."),
        p(tags$a(href="../book/simulation.html#explore-missing-outcomes", target="_blank", rel="noopener", "Explanation and model answer")))),
    tags$details(tags$summary("Reproducibility settings"), numericInput("seed", "Random seed", 20260914, min = 0, max = 2147483647, step = 1)),
    numericInput("B", "Number of simulated trials (B)", 1000, min = 2, max = 10000, step = 100),
    activity_help("More repetitions stabilize estimated power and coverage. Multiplying the repetitions by four approximately halves Monte Carlo standard error. Each simulated trial keeps the selected number of participants.", for_input = "B")),
    p(tags$a(href = "../book/Sample_size_open_module.html#glossary", target = "_blank", rel = "noopener", "Key terms and assumptions"), " · ",
      tags$a(href = "../book/Sample_size_open_module.html#common-mistakes", target = "_blank", rel = "noopener", "Common mistakes and FAQ"))))),
  mainPanel(width = 8, conditionalPanel("input.goal != 'precision'", tabsetPanel(id = "stage",
    tabPanel("Overview", value = "Explore assumptions", h3("Your planned design"), uiOutput("overview_metrics"),
      textOutput("overview_text"),
      plotOutput("planning_plot", height = "430px"),
      p(class = "caption", "Figure 1. The selected planning criterion across sample sizes. Dashed lines mark the target; dots mark the current plan."),
      activity_details("Current assumptions and graph details", tableOutput("planning"),
        p(class = "caption", "Table 1. Current assumptions and sample requirements."),
        textOutput("planning_text"), textOutput("axis_note"), actionButton("fit_axis", "Fit axis to results"))),
    tabPanel("Explore assumptions", value = "Compare assumptions",
      h3("Power at the available sample"),
      radioButtons("graph_selection", "Select on the graph", c("Available sample size" = "sample", "Target power" = "power"), inline = TRUE),
      p(class = "comparison-instruction", "Click the graph to move the selected reference line. The sample-size field and target-power slider also accept keyboard input."),
      plotOutput("comparison_plot", height = "340px", click = "comparison_click"), uiOutput("comparison_key"),
      p(class = "caption", "Figure 2. Power across sample sizes for the three treatment differences. Reference lines mark target power and the available analyzable count."),
      tableOutput("comparison_table"),
      p(class = "caption", "Table 2. Power at the vertical reference line and sample size required at the horizontal target-power line."),
      textOutput("comparison_text"),
      textOutput("comparison_range"), actionButton("fit_comparison_axis", "Fit axis to results"),
      activity_details("Power across a wider range of differences",
      h4("Power across effects at the planned sample size"),
      plotOutput("effect_plot", height = "320px"),
      p(class = "caption", "Figure 3. Two-sided power across hypothetical true effects, holding the current planned sample size fixed."),
      p("Each point gives the probability of detecting the specified true difference at the selected analyzable count.")),
      h4("Sensitivity analysis: what if the assumptions differ?"), tableOutput("sensitivity"),
      textOutput("sensitivity_caption", container = function(...) tags$p(class = "caption", ...)),
      p("The table keeps the planned sample size fixed. Missing-outcome scenarios start with recruited participants. Their results appear in One trial and Repeated trials.")),
    tabPanel("One trial", value="One study", h3("One simulated trial"),
      tags$div(class = "simulation-actions",
        actionButton("run_one", "Simulate one trial", class = "btn-primary"),
        conditionalPanel("input.outcome == 'proportions' && !output.one_has_missing",
          tags$div(class="repeat-trial-controls",
            numericInput("journey_repetitions", "Number of trials", 20, min=2, max=10000, step=1),
            actionButton("run_journey", "Simulate selected trials", class="btn-primary")))),
      conditionalPanel("input.outcome == 'proportions' && !output.one_has_missing",
        tags$details(class="journey-playback", tags$summary("Display and replay options"),
        tags$div(class="playback-controls", `aria-label`="Animation playback",
          tags$button(id="journey-pause",type="button","Pause",disabled=NA),
          tags$button(id="journey-replay",type="button","Replay",disabled=NA),
          tags$button(id="journey-finish",type="button","Show all trials",disabled=NA),
          tags$label(tags$input(id="journey-motion",type="checkbox")," Reduce motion"),
          tags$label(`for`="journey-speed","Animation speed"),
          tags$select(id="journey-speed",tags$option(value="normal","Normal"),tags$option(value="fast","Fast")),
          actionButton("reset_trials","Reset results")))),
      textOutput("one_status"),
      conditionalPanel("input.outcome == 'proportions' && !output.one_has_missing",
        tags$div(id = "sampling-journey", `aria-describedby` = "journey-description"),
        tags$p(id = "journey-description", class = "sr-only"),
        tags$p(id = "journey-status", role = "status", `aria-live` = "polite", "The patient outcomes and estimated difference will appear here."),
        tags$details(id="inline-study-explanation", class="inline-study-explanation", tags$summary("Interpret the figure"),
          p(id="journey-reading", "Patient outcomes produce an estimated difference and a p value. Repeated trials show how often the test detects a difference."))),
      conditionalPanel("output.one_ready && (input.outcome == 'means' || output.one_has_missing)", textOutput("one_interpretation")),
      conditionalPanel("output.one_ready && output.intervals_visible",
        activity_details("Interval for this study", plotOutput("one_plot", height="300px"), app_interval_key(),
          p(class="caption", "Figure. The saved estimate and confidence interval, with the population difference and clinical threshold marked."))),
      tags$div(id = "journey-credit", tags$hr(), p("The animated connection between samples, estimates, and sampling distributions was inspired by Douwe Postmus’s ", tags$a(href = "https://postmus.github.io/sampling-simulator/", target = "_blank", rel = "noopener", "Statistical Concepts Lab"), "."))),
    tabPanel("Repeated trials", value="Many studies", h3("Repeated simulated trials"),
      actionButton("run_many", "Simulate 5000 trials", class = "btn-primary"),
      textOutput("many_status"),
      conditionalPanel("output.many_ready", tableOutput("many_summary"),
        p(class = "caption", "Table 6. Summary of the saved simulation batch. Additional settings add coverage, interval-width targets and simulation uncertainty."),
        textOutput("many_text"), tags$div(class="separate-many-figure", plotOutput("distribution", height = "300px")),
        uiOutput("sample_comparison"),
        p(class = "caption separate-many-figure", "Estimated treatment differences across independent trials. The dashed line marks the assumed population difference."),
        conditionalPanel("output.intervals_visible", activity_details("Intervals across studies", plotOutput("many_plot", height = "480px"), app_interval_key(),
          p(class = "caption", "Figure 5. The first 30 saved intervals and their point estimates. Lines mark zero, the clinical threshold and the assumed population difference."))),
        conditionalPanel("input.goal != 'precision'", activity_details("P values in the latest batch", plotOutput("p_values", height = "300px"),
          textOutput("p_value_interpretation"))),
        conditionalPanel("input.show_advanced", activity_details("Simulation uncertainty and interpretation",
          p("Monte Carlo uncertainty comes from simulating a limited number of studies. Coverage is the percentage of intervals containing the assumed true effect. With selective missingness, bias and coverage are essential to interpreting the significance percentage."))),
        activity_details("Download results", downloadButton("download_many", "Download replications and assumptions")))),
    tabPanel("My study", h3("Apply this to your question"),
      activity_text_input("study_question", "What is your research question and primary outcome?",
        "The example updates with the selected case and current calculation inputs.",
        lab_question_help("two_groups"), rows = 4),
      selectInput("study_design", "Study design", c("Two independent groups, equal allocation" = "two_groups",
        "Paired or repeated measurements" = "paired", "One population proportion" = "single_proportion",
        "Observational or retrospective study" = "observational", "Diagnostic or screening study" = "diagnostic",
        "Prediction or prognostic model" = "prediction", "Another design" = "other")),
      uiOutput("design_route"),
      activity_text_input("clinical_relevance", "Why would this difference or precision matter clinically?",
        "The example updates with the selected case and current calculation inputs.",
        "Which treatment decision depends on this difference or interval width? The justification should identify the harms, burden and alternatives considered, and whose judgment supports it."),
      activity_text_input("participant_burden", "What participant burden, benefits and ethical issues should you consider?",
        "The example updates with the selected case and current calculation inputs.",
        "Relevant details include visit frequency, discomfort, time, and possible harms, alongside the patient benefit expected from the knowledge gained."),
      activity_text_input("evidence_sources", "What evidence supports your inputs, and how uncertain is it?",
        "The example updates with the selected case and current calculation inputs.",
        "Could differences in patients, diagnosis or background care explain the reported advantage? Your sources should support the outcome definition and assessment time, with plausible alternatives for uncertain inputs."),
      fluidRow(column(6, numericInput("eligible_monthly", "Eligible participants per month", 20, min = 0)),
        column(6, percent_slider("consent_fraction", "Expected percentage consenting (%)", 0, 1, .7, step = .01))),
      activity_help("Your estimate should use screening records from all participating sites and count patients who meet the eligibility criteria. The app then applies the consent percentage. Slower recruitment and site-opening delays should inform your feasibility judgment.", for_input = "eligible_monthly"),
      p(class = "note", tags$a(href = "../book/calculations.html#lasagnas-law", target = "_blank", rel = "noopener", "Lasagna's law: checking recruitment forecasts")),
      activity_help("The denominator is eligible people invited to participate. Prior recruitment records can support the percentage; losses after consent are handled separately.", for_input = "consent_fraction"),
      numericInput("recruitment_months", "Months available for recruitment", 12, min = 0),
      activity_help("This is the enrollment period. Setup and final follow-up need additional time if they extend beyond recruitment.", for_input = "recruitment_months"),
      tableOutput("feasibility_table"),
      p(class = "caption", "Table 7. Expected recruitment and analyzable counts under the stated eligibility, consent and loss assumptions."),
      activity_help("These estimates depend on the eligibility, consent, recruitment-period and loss assumptions. Screening records and possible delays should inform your feasibility judgment."),
      actionButton("use_feasible_cap", "Use expected recruitment as the lab limit"),
      p(tags$a(href = "../book/appendix.html#own-study", target = "_blank", rel = "noopener", "Read the study justification guidance"))),
    tabPanel("Report", value = "Justify and communicate",
      conditionalPanel("!output.pain_report", h3(id = "report-question-heading", "Explain your decision"),
      activity_text_input("justification", "What sample size calculation report would you recommend, and why?",
        "The example updates with the selected case and current calculation inputs.",
        "Your recommendation should give analyzable and recruitment counts, supporting evidence, and the effect of plausible alternative assumptions. It should identify remaining limitations.", rows = 8),
      p(id = "study-plan-guidance", "A structured ", tags$a(href = "../assumptions_report/", "sample size calculation report"), " brings these decisions together using PICO, selected SPIRIT 2025 items and DELTA² guidance.")),
      uiOutput("report_preview"), activity_report_downloads("download_plan"),
      conditionalPanel("output.one_ready", activity_details("Participant records for the saved study",
        tableOutput("one_data"), textOutput("one_missing_data_note"),
        p(class="caption", "Up to six records per group. Binary outcomes use 1 for pain relief and 0 for no relief."),
        downloadButton("download_one", "Download study and assumptions"))),
      activity_details("Save work for later",
      downloadButton("download_plan_json", "Save work for later"),
      fileInput("upload_plan", "Reopen saved work", accept = c(".json", "application/json")),
      p("This file restores your example, settings, and written answers in this app. Simulations should be rerun after reopening. The PDF and Word downloads provide a readable report.")),
      tags$details(tags$summary("Optional reproducible R workflow"),
        p("This script reproduces the current scenario when run from the downloaded source folder containing the shared R functions."), downloadButton("download_code", "Download R script")),
      app_citation("Sample size reasoning lab", "power_explorer"),
    activity_details("Calculation details and references",
      conditionalPanel("!output.pain_report", h3("Calculation with your current values"), uiOutput("worked_method")),
      p(tags$a(href = "../book/appendix.html#tutorial-methods", target = "_blank", rel = "noopener", "Methods and reproducibility record")),
      h3("References"), tags$ul(
        tags$li(tags$a(href = "https://aaroncaldwell.us/SuperpowerBook/", "Caldwell et al. (2022). Power Analysis with Superpower, chapters 1, 11 and 15: inspiration for the clinical activities.")),
        tags$li(tags$a(href = "https://doi.org/10.1016/j.jesp.2017.09.004", "Albers and Lakens (2018). Uncertainty and bias in pilot-based planning.")),
        tags$li(tags$a(href = "https://pubmed.ncbi.nlm.nih.gov/32814615/", "Althouse (2021). Post Hoc Power: Not Empowering, Just Misleading.")),
        tags$li(tags$a(href = "https://doi.org/10.1525/collabra.33267", "Lakens (2022). Sample Size Justification.")),
        tags$li(tags$a(href = "https://doi.org/10.1111/test.12403", "Sandoval et al. (2025). Beyond statistical power.")),
        tags$li(tags$a(href = "https://doi.org/10.2196/52679", "Thiesmeier and Orsini (2024). Rolling the DICE.")),
        tags$li(tags$a(href = "https://doi.org/10.1080/26939169.2024.2394536", "Orsini et al. (2024). Teaching interaction effects.")),
        tags$li(tags$a(href = "https://doi.org/10.1093/aje/kwaa232", "Rudolph et al. (2021). Simulation for teaching epidemiologic methods."))))))),
    conditionalPanel("input.goal == 'precision'", single_population_ui("precision")))))

server <- function(input, output, session) {
  single_population_server("precision")
  safe <- function(expr) tryCatch(expr, error = function(e) validate(need(FALSE, conditionMessage(e))))
  effect_text <- function(value, outcome, digits = 2) {
    if (outcome == "proportions") paste0(round(100 * value, digits), " percentage points")
    else paste0(signif(value, digits + 2), " units")
  }
  current_activity <- reactiveVal("")
  activity_selection <- reactiveVal("")
  routed_case <- reactiveVal(NULL)
  import_status <- reactiveVal("")
  one_saved <- reactiveVal(NULL)
  journey_payload <- function(trials) {
    x <- trials[[1]]
    list(n = x$spec$n, p0 = x$spec$p_control, p1 = x$spec$p_treatment, alpha=x$spec$alpha, expected=spec_power(x$spec),
      labels = if (current_activity() %in% c("pain_one_many", "pain_curves", "pain_simulation"))
        c("duloxetine", "neravixa") else c("Standard", "Novel"),
      event = if (current_activity() %in% c("pain_one_many", "pain_curves", "pain_simulation")) "achieved pain relief" else "had the event",
      seed = x$spec$seed, trials = lapply(trials, function(t) list(
        control = as.list(head(t$data$outcome[t$data$group == "Control"], 80)),
        treatment = as.list(head(t$data$outcome[t$data$group == "Treatment"], 80)),
        counts = as.list(c(sum(t$data$outcome[t$data$group == "Control"]),
                          sum(t$data$outcome[t$data$group == "Treatment"]))),
        estimate = t$result$estimate[[1]], p_value=t$result$p_value[[1]], reject=t$result$reject[[1]])))
  }
  observeEvent(input$run_journey, {
    req(is.null(missing_settings()), input$outcome=="proportions")
    B <- input$journey_repetitions
    validate(need(is.finite(B) && B==floor(B) && B>=2 && B<=10000,
      "Choose a whole number of trials between 2 and 10000."))
    if(B>100) run_batch(B) else {
      meta <- simulation_meta(B)
      x <- simulate_trials(meta$generating)
      if(meta$compare_populations) x$population_comparison <- simulate_trials(comparison_spec(meta$generating))
      save_batch(x,meta)
      payload <- sequence_payload(x)
      if(!is.null(x$population_comparison)) payload$comparison <- sequence_payload(x$population_comparison)
      session$sendCustomMessage("sampling-journey",payload)
    }
  }, ignoreInit=TRUE)
  observeEvent(one_saved(), {
    x <- one_saved()
    if (is.null(x) || !is.null(x$missing)) session$sendCustomMessage("sampling-journey", list(clear = TRUE))
    else if (x$spec$outcome == "proportions" && !isTRUE(x$from_batch)) {
      payload <- journey_payload(list(x))
      if(!is.null(x$population_comparison)) payload$comparison <- journey_payload(list(x$population_comparison))
      session$sendCustomMessage("sampling-journey",payload)
    }
  }, ignoreNULL = FALSE)
  many_saved <- reactiveVal(NULL)
  baseline_many <- reactiveVal(NULL)
  output$activity_sequence <- renderUI({
    if (identical(current_activity(), "pain_one_many"))
      app_activity_sequence(c("Simulate one trial", "Repeat the trial", "Compare a larger sample"))
    else if (identical(current_activity(), "pain_curves"))
      app_activity_sequence(c("Select a sample size", "Compare assumptions", "Justify a plan"))
    else if (input$goal != "precision")
      app_activity_sequence(c("Set the assumptions", "Explore the results", "Explain your decision"))
  })
  output$one_ready <- reactive(!is.null(one_saved()))
  output$many_ready <- reactive(!is.null(many_saved()))
  outputOptions(output, "one_ready", suspendWhenHidden = FALSE)
  outputOptions(output, "many_ready", suspendWhenHidden = FALSE)
  output$scenario_summary <- renderText({
    x <- generating()
    if (x$outcome == "proportions") paste0("Simulation population: standard ", format_percent(x$p_control, 0), "; novel ", format_percent(x$p_treatment, 0), ".")
    else paste0("Simulation population: difference ", effect_text(x$delta, x$outcome), "; SD ", x$sd, ".")
  })
  outputOptions(output, "scenario_summary", suspendWhenHidden = FALSE)
  axis_limit <- reactiveVal(NULL)
  current_lab_inputs <- reactive({
    defaults <- lab_input_defaults()
    values <- lapply(names(defaults), function(name) if (is.null(input[[name]])) defaults[[name]] else input[[name]])
    names(values) <- names(defaults)
    safe(validate_lab_inputs(values))
  })
  expected_effect <- reactive({
    values <- current_lab_inputs()
    if (values$outcome == "means") values$expected_m else values$expected_p
  })
  study_details <- reactive({
    defaults <- study_input_defaults()
    values <- lapply(names(defaults), function(name) if (is.null(input[[name]])) defaults[[name]] else input[[name]])
    names(values) <- names(defaults)
    safe(validate_study_inputs(values))
  })
  apply_case <- function(id, reset = FALSE) {
    x <- teaching_case(id)
    session$sendCustomMessage("combine-pain-panels", list(combine = identical(id, "pain_one_many")))
    current_activity(id)
    axis_limit(NULL)
    if (x$app != "power_explorer") {
      routed_case(x)
      import_status("This activity uses a different study design. Follow its activity link below.")
      return(invisible(NULL))
    }
    routed_case(NULL)
    apply_lab_inputs(session, x$inputs[names(x$inputs) %in% names(lab_input_defaults())])
    if (isTRUE(reset)) {
      one_saved(NULL); many_saved(NULL); baseline_many(NULL)
      session$sendCustomMessage("sampling-journey", list(clear = TRUE))
      apply_study_inputs(session, study_input_defaults())
    }
    activity_selection(id)
    updateSelectInput(session, "activity_choice", selected = id)
    updateSelectInput(session, "study_design", selected = "two_groups")
    updateCheckboxInput(session, "show_advanced", value =
      id %in% c("pain_simulation", "pain_curves"))
    import_status(if (isTRUE(reset)) "Activity reset: example inputs restored and earlier simulation results cleared." else "")
    invisible(x)
  }
  handle <- function(expr) tryCatch(expr, error = function(e) import_status(conditionMessage(e)))
  observeEvent(input$activity_choice, {
    if (identical(input$activity_choice, activity_selection())) return()
    activity_selection(input$activity_choice)
    if (nzchar(input$activity_choice)) handle(apply_case(input$activity_choice))
    else { current_activity(""); routed_case(NULL) }
  }, ignoreInit = TRUE)
  observeEvent(input$activity_request, {
    # The standalone URL and the two-panel wrapper can announce the same
    # initial activity. A second announcement must preserve the reader's tab.
    if (identical(input$activity_request$activity, current_activity()) &&
        !isTRUE(input$activity_request$reset)) return()
    handle(apply_case(input$activity_request$activity, isTRUE(input$activity_request$reset)))
  }, ignoreInit = FALSE)
  observeEvent(input$state_request, {
    handle({
      state <- input$state_request$state
      if (!is.list(state)) stop("Linked study inputs must be an object.")
      case_id <- state$case_id
      if (is.null(case_id)) case_id <- ""
      if (!is.character(case_id) || length(case_id) != 1 || is.na(case_id)) stop("Invalid activity context.")
      if (nzchar(case_id) && teaching_case(case_id)$app != "power_explorer") stop("This linked case uses another activity.")
      details <- if (is.null(state$study)) NULL else validate_study_inputs(state$study)
      state$case_id <- NULL; state$study <- NULL
      values <- validate_lab_inputs(state)
      apply_lab_inputs(session, values)
      if (is.null(details)) updateSelectInput(session, "study_design", selected = "two_groups")
      else apply_study_inputs(session, details)
      activity_selection(case_id)
      updateSelectInput(session, "activity_choice", selected = case_id)
      current_activity(case_id); routed_case(NULL)
      updateCheckboxInput(session, "show_advanced", value = TRUE)
      import_status("Linked inputs loaded. The transferred sample size is held fixed for the assessment.")
    })
  }, ignoreInit = FALSE)
  observeEvent(input$bridge_error, import_status(input$bridge_error), ignoreInit = FALSE)
  output$plan_import_status <- renderText(import_status())
  output$activity_context <- renderUI({
    if (identical(input$goal,"precision")) return(p("Estimate a mean or percentage in one population. The confidence level, variability and desired interval width determine the sample size; simulations show how estimates and intervals vary."))
    if (!nzchar(current_activity())) return(p("Compare two independent groups or estimate a mean or percentage in one population. Simulations show how results vary with the sample size and assumptions."))
    x <- teaching_case(current_activity())
    tagList(p(x$prompt),
      if (!is.null(routed_case())) p(tags$a(href = paste0("../", x$app, "/?activity=", x$id),
        target = "_blank", rel = "noopener", "Open the matching activity")),
      p(tags$a(href = paste0("../", x$return_path), target = "_blank", rel = "noopener", "Return to this passage in the tutorial")))
  })
  output$design_route <- renderUI({
    design <- study_details()$study_design
    if (design == "two_groups") return(p("The lab calculations apply to two independent, equally sized groups. Check that the outcome and intended analysis match your study."))
    tagList(p("This design needs a method matched to its structure and planned analysis. The notes and feasibility calculation can be saved here."),
      if (design == "single_proportion") p(tags$a(href = "../prevalence_precision/?activity=prevalence", target = "_blank", rel = "noopener", "Open the proportion estimation activity")),
      p(tags$a(href = "../book/study-designs.html#study-designs", target = "_blank", rel = "noopener", "Choose the appropriate planning approach")))
  })
  feasibility <- reactive({
    x <- study_details()
    recruits <- floor(x$eligible_monthly * x$consent_fraction * x$recruitment_months)
    list(recruits = recruits, balanced = 2 * floor(recruits / 2),
      expected_analysable = 2 * floor(floor(recruits / 2) * (1 - input$dropout)))
  })
  output$feasibility_table <- renderTable({
    x <- feasibility()
    if (study_details()$study_design != "two_groups") return(data.frame(
      Item = "Expected recruitment: all participants", Value = x$recruits))
    required <- 2 * adjust_for_dropout(planned()$n, input$dropout)
    data.frame(Item = c("Expected recruitment: all participants", "Available under equal allocation", "Expected participants for analysis, both groups",
      "Recruitment required for the current plan", "Expected recruitment covers the current plan"),
      Value = c(x$recruits, x$balanced, x$expected_analysable, required,
        if (x$balanced >= required) "Yes" else "No"))
  })
  observeEvent(input$use_feasible_cap, handle({
    x <- feasibility()
    if (study_details()$study_design != "two_groups") stop("Choose an appropriate design-specific calculator before applying this recruitment limit.")
    if (x$balanced < 4 || x$balanced > 200000) stop("The lab recruitment limit must be between 4 and 200,000 participants in total.")
    updateNumericInput(session, "recruit_cap", value = x$balanced)
    import_status("Expected recruitment applied as a limit, without changing the planned sample size.")
  }))
  observeEvent(input$upload_plan, handle({
    req(input$upload_plan$datapath)
    if (input$upload_plan$size > 100000) stop("Choose a saved-work file smaller than 100 KB.")
    saved <- read_study_plan(paste(readLines(input$upload_plan$datapath, warn = FALSE), collapse = "\n"))
    apply_lab_inputs(session, saved$inputs)
    apply_study_inputs(session, saved$study)
    activity <- if (saved$activity %in% names(teaching_cases()) && teaching_case(saved$activity)$app == "power_explorer") saved$activity else ""
    current_activity(activity); activity_selection(activity); routed_case(NULL)
    one_saved(NULL); many_saved(NULL); baseline_many(NULL)
    updateSelectInput(session, "activity_choice", selected = activity)
    updateCheckboxInput(session, "show_advanced", value = TRUE)
    import_status("Settings and written answers restored. Simulations can now be rerun for this plan.")
  }), ignoreInit = TRUE)
  # The wrapper can display current inputs; it never receives uploaded file paths.
  observe({
    values <- tryCatch(current_lab_inputs(), error = function(e) NULL)
    details <- tryCatch(study_details(), error = function(e) NULL)
    activity <- current_activity()
    if (!is.null(values) && !is.null(details)) {
      values$case_id <- activity; values$study <- details
      session$sendCustomMessage("sample-size-state", values)
    }
  })
  planned <- reactive({
    req(input$goal != "precision")
    validate(need(is.null(routed_case()), "Open the matching activity for this study design."),
      need(study_details()$study_design == "two_groups", "This design needs another planning method. See My study for the appropriate route."))
    x <- safe(study_spec(outcome = input$outcome, n = if (input$goal == "fixed") input$fixed_n else 60,
      delta = input$plan_delta, sd = input$plan_sd, p_control = input$plan_p0, p_treatment = input$plan_p1,
      alpha = input$alpha, threshold = if (input$outcome == "means") input$threshold_m else input$threshold_p,
      width_target = if (input$outcome == "means") input$width_m else input$width_p, seed = input$seed, B = input$B))
    x$n <- safe(plan_n(x, input$goal, input$target_power)); x
  })
  calculated_n <- reactive({
    req(input$goal != "precision")
    safe(plan_n(planned(), "testing", input$target_power))
  })
  output$simulation_target <- renderUI({
    n <- calculated_n()
    tagList(p(class="simulation-target", paste0("Calculated requirement: ",n," analyzable patients per group (",2*n," total) for ",format_percent(input$target_power)," power.")),
      if(input$goal=="fixed") actionButton("use_calculated_n",paste0("Use ",n," per group in the simulation"),class="btn-default"))
  })
  observeEvent(input$use_calculated_n, updateNumericInput(session,"fixed_n",value=calculated_n()),ignoreInit=TRUE)
  generating <- reactive({
    x <- planned()
    if (input$reality == "null") { x$delta <- 0; x$p_treatment <- x$p_control }
    if (input$reality == "custom") {
      if (x$outcome == "means") { x$delta <- input$true_delta; x$sd <- input$true_sd }
      else { x$p_control <- input$true_p0; x$p_treatment <- input$true_p1 }
    }
    if(identical(current_activity(),"pain_one_many") && !isTRUE(input$show_advanced) && x$outcome=="proportions") {
      x$p_control <- .30
      x$p_treatment <- if(identical(input$pain_population,"equal")) .30 else .60
    }
    safe(do.call(study_spec, x))
  })
  missing_settings <- reactive({
    if (identical(input$goal,"precision")) return(NULL)
    v <- current_lab_inputs()
    if (v$outcome != "proportions" || v$missing_mode == "off") return(NULL)
    safe(missing_scenario(v$missing_mode, v$missing_n))
  })
  output$missing_note <- renderText({
    m <- missing_settings(); if (is.null(m)) return("")
    paste("Missing-outcome simulation active:", missing_scenario_label(m),
      ". Recruited per group:", m$n, ". Planning curves describe the complete-data plan.")
  })
  output$one_has_missing <- reactive(!is.null(missing_settings()) || (!is.null(one_saved()) && !is.null(one_saved()$missing)))
  outputOptions(output, "one_has_missing", suspendWhenHidden=FALSE)
  snapshot <- reactive({
    missing <- missing_settings(); simulated <- generating()
    if (!is.null(missing)) simulated$n <- missing$n
    list(activity = current_activity(), missing = missing,
      compare_populations=identical(current_activity(),"pain_one_many") && !isTRUE(input$show_advanced) && isTRUE(input$compare_populations) && simulated$outcome=="proportions",
      plan = planned(), generating = simulated, goal = input$goal,
      target_power = input$target_power, dropout = input$dropout,
      recruitment_cap = input$recruit_cap, expected_effect = expected_effect())
  })
  intervals_visible <- reactive(identical(input$goal, "precision") ||
    (isTRUE(input$show_advanced) && !identical(current_activity(), "pain_curves")))
  output$intervals_visible <- reactive(intervals_visible())
  outputOptions(output, "intervals_visible", suspendWhenHidden = FALSE)
  observeEvent(input$confidence, {
    if (identical(input$goal, "precision") && abs(input$alpha - (1-input$confidence)) > 1e-8)
      updateSliderInput(session, "alpha", value = 1-input$confidence)
  }, ignoreInit = TRUE)
  observeEvent(input$alpha, { updateSliderInput(session, "confidence", value = 1-input$alpha) }, ignoreInit = FALSE)
  observeEvent(input$goal, {
    session$sendCustomMessage("lab-mode", list(estimation=identical(input$goal,"precision")))
    if (input$goal == "precision") hideTab("stage", "Compare assumptions", session=session) else showTab("stage", "Compare assumptions", session=session)
  })
  observeEvent(input$show_advanced, {
    enabled <- isTRUE(input$show_advanced)
    session$sendCustomMessage("lab-advanced", list(enabled=enabled))
    if (!enabled) {
      updateSelectInput(session,"reality",selected="same")
      updateSelectInput(session,"missing_mode",selected="off")
      if (identical(current_activity(),"pain_one_many") && input$stage %in% c("Explore assumptions","Compare assumptions","My study"))
        updateTabsetPanel(session,"stage",selected="One study")
    }
  }, ignoreInit=FALSE)
  observe({
    session$sendCustomMessage("activity-question-help", list(expected_p=list(
      question=if (grepl("^pain_",current_activity())) "Difference observed in the pilot (percentage points)" else "Difference observed in previous data (percentage points)",
      help="This is a difference calculated from earlier sample data. Its relevance and uncertainty inform planning. The selected event percentages set the target used in the calculation.")))
  })
  output$larger_sample_question <- renderText(if (input$goal == "precision")
    "How does a larger sample change the estimates and interval widths?" else
    "What happens to the estimates and power with more patients per group? You can compare 20, 50 and 80 under the same population assumptions.")
  pain_report <- reactive(identical(current_activity(), "pain_one_many") &&
    !identical(input$goal,"precision") &&
    identical(input$outcome, "proportions") && study_details()$study_design == "two_groups" &&
    is.null(routed_case()) && is.null(missing_settings()))
  output$pain_report <- reactive(pain_report())
  outputOptions(output, "pain_report", suspendWhenHidden=FALSE)
  observe({
    core <- pain_report()
    session$sendCustomMessage("lab-report-context", list(core = core,
      question = if (core) "What do these simulations show about sampling variability and sample size?"
        else "What sample size calculation report would you recommend, and why?",
      help = if (core) "The model answers beside the simulations explain how the estimates vary across studies."
        else "Your recommendation should give analyzable and recruitment counts, supporting evidence, and the effect of plausible alternative assumptions. It should identify remaining limitations."))
  })
  model_answers <- reactive({
    supported <- is.null(routed_case()) && study_details()$study_design == "two_groups"
    answers <- lab_model_answers(current_lab_inputs(), study_details(), current_activity(),
      if (supported) planned() else NULL, if (supported) feasibility() else NULL,
      if (supported) many_saved() else NULL, if (supported) snapshot() else NULL)
    if (pain_report()) answers$justification <- app_sampling_explanation(generating())
    answers
  })
  activity_model_answers(session, model_answers, c("study_question", "clinical_relevance", "participant_burden", "evidence_sources", "justification"))
  observe({session$sendCustomMessage("activity-question-help", list(study_question = list(
    question = "What is your research question and primary outcome?",
    help = lab_question_help(study_details()$study_design))))})
  output$one_model_answer <- renderText({
    saved <- one_saved(); x <- if (is.null(saved)) generating() else saved$spec
    paste0(if (x$outcome == "proportions") paste0("The assumed event probabilities (control ", format_percent(x$p_control), "; treatment ", format_percent(x$p_treatment), ")")
      else paste0("The assumed population mean difference (", effect_text(x$delta, x$outcome), ") and SD (", x$sd, ")"),
      ", sample size (", x$n, " per group), and analysis stay fixed. Patients, outcomes, and the estimated difference vary between studies. ",
      if (!is.null(saved)) paste0("The displayed study estimated ", effect_text(saved$result$estimate, x$outcome), ". ",
        if (!identical(saved$meta, snapshot())) "It uses earlier inputs; a new simulation will use the current settings." else "") else "")
  })
  output$many_model_answer <- renderText({
    saved <- many_saved(); x <- if (is.null(saved)) generating() else saved$spec
    missing <- if (is.null(saved)) !is.null(missing_settings()) else !is.null(saved$missing)
    paste0("At ", x$n, if (missing) " recruited" else " analyzable", " participants per group, the assumed difference is ", effect_text(true_difference(x), x$outcome), ". ",
      if (input$goal == "precision") "Larger samples usually reduce sampling variability and produce narrower intervals. "
      else if (missing) "More patients can improve precision, while outcome-related losses can still bias estimates. Rejection percentages need assessment alongside bias and coverage. "
      else if (true_difference(x) == 0) "Larger samples improve precision; with no true difference, rejections are false positives and their nominal probability stays at the Type I error setting. "
      else "Larger samples improve precision and increase power at this nonzero difference. ",
      "More repetitions stabilize simulation summaries while leaving each trial's sample size fixed. ",
      if (!is.null(saved)) paste0("The displayed batch contains ", x$B, " trials. ",
        if (!identical(saved$meta, snapshot())) "It uses earlier inputs." else "") else "")
  })
  one <- reactive({ req(one_saved()); one_saved() })
  observeEvent(input$run_one, {
    meta <- snapshot(); x <- if (is.null(meta$missing)) simulate_one_study(meta$generating) else simulate_missing_one(meta$generating, meta$missing)
    if(meta$compare_populations) x$population_comparison <- simulate_one_study(comparison_spec(meta$generating))
    x$meta <- meta
    if(identical(current_activity(),"pain_one_many")) many_saved(NULL)
    one_saved(x)
  }, ignoreInit = TRUE)
  many <- reactive({ req(many_saved()); many_saved() })
  # Compare sample sizes only when the generating population and test are unchanged.
  same_simulation_population <- function(a, b) {
    keys <- c("outcome", "p_control", "p_treatment", "delta", "sd", "alpha")
    is.null(a$missing) && is.null(b$missing) &&
      isTRUE(all.equal(a$spec[keys], b$spec[keys]))
  }
  comparison_spec <- function(spec) {
    spec$p_control <- .30
    spec$p_treatment <- if(abs(spec$p_treatment-.30)<1e-10) .60 else .30
    spec
  }
  simulation_meta <- function(B) {
    meta <- snapshot()
    meta$plan$B <- as.numeric(B); meta$generating$B <- as.numeric(B)
    updateNumericInput(session,"B",value=B)
    meta
  }
  save_batch <- function(x,meta) {
    x$meta <- meta
    original <- baseline_many()
    if(is.null(original) || !same_simulation_population(original,x)) baseline_many(x)
    many_saved(x)
    if(identical(current_activity(),"pain_one_many") && !is.null(x$illustrated_trial)) {
      illustrated <- x$illustrated_trial; illustrated$meta <- meta; illustrated$from_batch <- TRUE
      one_saved(illustrated)
    }
  }
  batch_payload <- function(x) {
    payload <- journey_payload(list(x$illustrated_trial))
    payload$batch <- list(estimates=as.list(x$results$estimate),
      p_values=as.list(x$results$p_value),reject=as.list(x$results$reject))
    payload
  }
  sequence_payload <- function(x) {
    payload <- journey_payload(list(x$illustrated_trial))
    # The animation and histogram share the same binomial counts and analyses.
    # Additional patient arrangements are sampled conditional on those counts.
    payload$trials <- with_study_seed(x$spec$seed,lapply(seq_len(nrow(x$results)),function(i) {
      if(i==1) return(payload$trials[[1]])
      counts <- unlist(x$trial_counts[i,],use.names=FALSE)
      records <- lapply(counts,function(count) as.list(head(sample(rep(c(1,0),c(count,x$spec$n-count))),80)))
      list(control=records[[1]],treatment=records[[2]],counts=as.list(counts),
        estimate=x$results$estimate[i],p_value=x$results$p_value[i],reject=x$results$reject[i])
    }))
    payload
  }
  run_batch <- function(B) {
    meta <- simulation_meta(B)
    withProgress(message="Simulating independent trials",value=.2,{
      x <- if(is.null(meta$missing)) simulate_trials(meta$generating) else simulate_missing_trials(meta$generating,meta$missing)
      if(meta$compare_populations) x$population_comparison <- simulate_trials(comparison_spec(meta$generating))
      incProgress(.8); save_batch(x,meta)
      if(identical(current_activity(),"pain_one_many") && !is.null(x$illustrated_trial)) {
        payload <- batch_payload(x)
        reference <- baseline_many()
        if(reference$spec$n!=x$spec$n && same_simulation_population(reference,x))
          payload$batch$reference <- list(n=reference$spec$n,estimates=as.list(reference$results$estimate))
        if(!is.null(x$population_comparison)) payload$comparison <- batch_payload(x$population_comparison)
        session$sendCustomMessage("sampling-batch",payload)
      }
    })
  }
  observeEvent(input$run_many, run_batch(if(identical(current_activity(),"pain_one_many"))5000 else input$B),ignoreInit=TRUE)
  observe({updateActionButton(session,"run_many",label=paste("Simulate",
    if(identical(current_activity(),"pain_one_many"))5000 else input$B,"trials"))})
  observeEvent(input$reset_trials,{
    one_saved(NULL);many_saved(NULL);baseline_many(NULL)
    session$sendCustomMessage("sampling-journey",list(clear=TRUE))
  },ignoreInit=TRUE)
  status <- function(saved, label) {
    if (identical(current_activity(), "pain_one_many")) return(paste0(label, ": ", saved$spec$n,
      " patients per group. ", if (!identical(saved$meta, snapshot())) "Inputs changed; run again to update." else "Results match current inputs."))
    paste0(label, ": n = ", saved$spec$n,
    if (is.null(saved$missing)) " analyzable per group; " else paste0(" recruited per group; ", missing_scenario_label(saved$missing), "; "),
    "true difference assumed for simulation = ", effect_text(true_difference(saved$spec), saved$spec$outcome),
    ". ", if (!identical(saved$meta, snapshot())) "Inputs changed. These are saved results; run again to update." else "Results match current inputs.")
  }
  output$overview_metrics <- renderUI({
    x <- planned()
    app_primary_result(x$n, "analyzable per group", paste0(2*x$n, " in total", if (input$goal == "precision") paste0(" · Anticipated full interval width: ", effect_text(anticipated_width(x),x$outcome)) else paste0(" · Power at target difference: ", format_percent(spec_power(x),1)),
      if (input$dropout > 0) paste0(" · Recruit ", 2*adjust_for_dropout(x$n,input$dropout), " in total") else ""))
  })
  output$overview_text <- renderText({
    x <- planned()
    paste0("With ", x$n, " analyzable participants per group and a target difference of ",
      effect_text(true_difference(x),x$outcome), ", power is ", format_percent(spec_power(x),1),
      " at a ", format_percent(x$alpha), " Type I error probability.",
      if(intervals_visible()) paste0(" The anticipated full interval width is ",
        effect_text(anticipated_width(x),x$outcome), ".") else "")
  })
  output$worked_method <- renderUI({
    x <- planned()
    if (input$goal == "precision") return(tags$div(class="app-method",
      p(paste0("Confidence level: ", format_percent(1-x$alpha), "; desired full width: ", effect_text(x$width_target,x$outcome), ".")),
      p(paste0("The calculation gives ", x$n, " analyzable participants per group; anticipated full width: ", effect_text(anticipated_width(x),x$outcome), ".")),
      p(if (x$outcome == "means") paste0("Expected t-interval width assumes normal outcomes with common SD ",x$sd,".") else "The anticipated width uses the assumed event probabilities in the Newcombe-Wilson interval formula.")))
    tags$div(class = "app-method", p(paste0("Planning goal: ", switch(input$goal, testing = "power at the target difference", precision = "estimation with a target interval width", fixed = "assessment of an available sample"), "; Type I error probability: ", format_percent(x$alpha),
      "; target power: ", format_percent(input$target_power), "; target difference: ", effect_text(true_difference(x), x$outcome), ".")),
      p(if (x$outcome == "means") paste0("Common SD: ", x$sd, ". Power uses the noncentral t distribution for a two-sample, equal-variance t test.") else
        paste0("Assumed event probabilities: standard ", format_percent(x$p_control), ", novel ", format_percent(x$p_treatment), ". Power uses the two-sided normal approximation in stats::power.prop.test with strict = TRUE.")),
      p(paste0(if (input$goal == "fixed") "Your selected fixed sample is " else "The calculation gives ", x$n, " analyzable participants per group.", if (intervals_visible()) paste0(" Anticipated full interval width: ", effect_text(anticipated_width(x), x$outcome), ".") else "")),
      p(paste0("Recruitment per group = ceiling(", x$n, " / ", 1-input$dropout, ") = ", adjust_for_dropout(x$n, input$dropout), ".")),
      p("Simulation exports retain the generating assumptions, analysis procedure and reproducibility settings used for the saved results."))
  })
  output$planning <- renderTable({
    x <- planned(); recruit <- adjust_for_dropout(x$n, input$dropout)
    table <- data.frame(Item = c("Difference observed in previous data (sample result)", "Target difference (used in calculation)", "Clinical threshold (meaningful benefit)",
      "Participants for analysis, per group", "Participants for analysis, total", "Recruit per group", "Recruitment total", "Power at the target difference", "Expected full interval width"),
      Value = c(effect_text(expected_effect(), x$outcome), effect_text(true_difference(x), x$outcome), effect_text(x$threshold, x$outcome),
        x$n, 2*x$n, recruit, 2*recruit, format_percent(spec_power(x), 1), effect_text(anticipated_width(x), x$outcome)))
    if (input$goal == "precision") table[c(4:7,9), ] else if (!intervals_visible()) table[1:8, ] else table
  })
  output$method <- renderText(method_label(planned()$outcome))
  output$planning_text <- renderText({ if (!intervals_visible()) return("Power is evaluated under the assumed population difference and the specified test."); paste(if (planned()$outcome == "means")
    "The width curve shows the expected width of the confidence interval for the difference between the two population means. It assumes normal outcomes with equal variances." else
    "The width curve shows the approximate confidence interval width for the difference between groups, based on the assumed event percentages.",
    "Repeated trials reports the fraction of intervals that meet the width target.") })
  observeEvent(input$outcome, { axis_limit(NULL) }, ignoreInit = TRUE)
  # Initialize the sticky axis before outputs render. Changing reactive state
  # inside plot_limit() can invalidate an output while it is still rendering.
  observe({
    if (is.null(axis_limit())) axis_limit(min(100000, max(250, 2*planned()$n)))
  }, priority = 100)
  plot_limit <- reactive({ req(axis_limit()); axis_limit() })
  fit_comparison_axis <- function() {
    required <- comparison_results()[[3]]
    axis_limit(min(100000, ceiling(max(250, 1.1*required, 1.1*comparison()$cap_n, na.rm = TRUE))))
  }
  observeEvent(input$fit_axis, { fit_comparison_axis() })
  observeEvent(input$fit_comparison_axis, { fit_comparison_axis() })
  output$axis_note <- renderText({
    limit <- plot_limit(); n <- planned()$n
    paste0("The horizontal range stays at 2 to ", limit, " patients per group while you compare inputs. ",
      if (n > limit) paste0("The required ", n, " per group is outside this range. ") else "",
      "Fit the axis to results if you need a different range.")
  })
  output$planning_plot <- renderPlot({
    x <- planned(); ns <- unique(round(seq(2, plot_limit(), length.out = 100)))
    scale <- if (x$outcome == "proportions") 100 else 1
    app_plot_style(c(3.8,4.2,1,1)); par(mfrow = c(if (intervals_visible() && input$goal != "precision") 2 else 1,1))
    if (input$goal != "precision") {
    plot(ns, 100 * vapply(ns, function(n) spec_power(x, n), numeric(1)), type = "l", lwd = 2,
      ylim = c(0, 100), xlab = "Analyzable participants per group", ylab = "Power (%)")
    abline(h = 100 * input$target_power, lty = 2); points(x$n, 100 * spec_power(x), pch = 19)
    }
    if (intervals_visible()) {
    plot(ns, scale * vapply(ns, function(n) anticipated_width(x, n), numeric(1)), type = "l", lwd = 2,
      xlab = "Analyzable participants per group", ylab = if (x$outcome == "proportions") "Full CI width (points)" else "Full CI width (outcome units)")
    abline(h = scale * x$width_target, lty = 2); points(x$n, scale * anticipated_width(x), pch = 19)
    }
  }, alt = "Power and anticipated full confidence interval width versus participants per group. Current values are provided in the design table.")
  comparison <- reactive({
    x <- planned()
    cap <- input$recruit_cap
    if (is.null(cap)) cap <- 200
    safe(check_integer(cap, "Total recruitment limit", 4, 200000))
    cap_n <- if (input$goal == "fixed") x$n else floor(floor(cap / 2) * (1 - input$dropout))
    validate(need(cap_n >= 2, "The expected analyzable limit must be at least two per group."))
    effects <- true_difference(x) * c(.5, 2/3, 1)
    scenarios <- lapply(effects, function(effect) {
      y <- x
      if (y$outcome == "means") y$delta <- effect
      else y$p_treatment <- y$p_control + effect
      y
    })
    list(spec = x, cap_n = cap_n, scenarios = scenarios, effects = effects)
  })
  observeEvent(input$comparison_click, {
    point <- input$comparison_click
    if (identical(input$graph_selection, "power")) {
      req(is.finite(point$y))
      updateSliderInput(session, "target_power", value = round(max(.5, min(.99, point$y)), 2))
    } else {
      req(is.finite(point$x))
      updateSelectInput(session, "goal", selected = "fixed")
      updateNumericInput(session, "fixed_n", value = round(max(2, min(100000, point$x))))
    }
  })
  output$comparison_plot <- renderPlot({
    z <- comparison(); x <- z$spec
    ns <- unique(round(seq(2, max(250, plot_limit()), length.out = 250)))
    app_plot_style()
    plot_power_curves(power_curve_data(x, z$effects, ns), input$target_power,
      z$cap_n, outcome = x$outcome, show_legend = FALSE, required = comparison_results()[[3]], restore_par = FALSE)
  }, res = 96, alt = "Power versus analyzable participants per group, with labeled target-power and available-count reference lines. The table gives power at the available count and the required count for each difference.")
  output$comparison_key <- renderUI({
    z <- comparison()
    tags$div(class="app-plot-key", lapply(1:3, function(i) tags$span(class=c("solid","dashed","dotted")[i],
      style=paste0("--key-color:",c("#176675", "#a04a24", "#635493")[i]), effect_text(z$effects[i],z$spec$outcome,1))))
  })
  output$sensitivity_caption <- renderText(paste0("Table 3. Power",
    if (intervals_visible()) " and anticipated interval width" else "",
    " under the planning assumptions, simulated population and null hypothesis at the selected sample size."))
  comparison_results <- reactive({
    z <- comparison()
    result <- data.frame(Difference = format(signif(z$effects * if (z$spec$outcome == "proportions") 100 else 1, 3), trim = TRUE),
      Power = format_percent(vapply(z$scenarios, function(x) spec_power(x, z$cap_n), numeric(1)), 1),
      Required = vapply(z$scenarios, function(x) {
        if (abs(true_difference(x)) < 1e-12) return(NA_real_)
        plan_n(x, target_power = input$target_power)
      }, numeric(1)), check.names = FALSE)
    names(result) <- c(if (z$spec$outcome == "proportions") "Difference (percentage points)" else "Difference (outcome units)",
      paste0("Power with ", z$cap_n, " per group"),
      paste0("Per group for ", format_percent(input$target_power), " power"))
    result
  })
  output$comparison_table <- renderTable(comparison_results(), digits = 0, na = "—")
  output$comparison_range <- renderText({
    required <- comparison_results()[[3]]
    outside <- required[is.finite(required) & required > plot_limit()]
    paste0("The horizontal axis stays fixed while inputs change. ",
      if (length(outside)) paste0("Required counts outside this range: ", paste(outside, collapse = ", "),
        " per group. Fit the axis to show these target-power crossings.") else
        "Filled dots show power at the selected sample. Open circles mark the target-power crossings.")
  })
  output$comparison_text <- renderText({
    z <- comparison()
    powers <- vapply(z$scenarios, function(x) spec_power(x, z$cap_n), numeric(1))
    paste0("With ", z$cap_n, " analyzable participants per group, power is ",
      paste(paste0(format_percent(powers, 1), " at ", effect_text(z$effects, z$spec$outcome, 1)), collapse = ", "),
      ". The table's last column gives the analyzable count required for ", format_percent(input$target_power), " power.")
  })
  output$effect_plot <- renderPlot({
    x <- planned(); d <- true_difference(x)
    if (x$outcome == "means") effects <- seq(-max(abs(d)*1.5, x$sd), max(abs(d)*1.5, x$sd), length.out = 101)
    else effects <- seq(.001 - x$p_control, .999 - x$p_control, length.out = 101)
    powers <- vapply(effects, function(effect) {
      y <- x
      if (y$outcome == "means") y$delta <- effect else y$p_treatment <- y$p_control + effect
      spec_power(y)
    }, numeric(1))
    scale <- if (x$outcome == "proportions") 100 else 1
    app_plot_style(c(4.2,4.4,2,1))
    plot(scale * effects, 100 * powers, type = "l", lwd = 2, col = "#176675", ylim = c(0,100),
      xlab = if (x$outcome == "means") "Treatment minus control (outcome units)" else "Treatment minus control (points)",
      ylab = "Power (%)", main = paste(x$n, "analyzable patients per group"))
    abline(h = 100 * input$target_power, lty = 2); abline(v = 0, lty = 3)
    points(scale * d, 100 * spec_power(x), pch = 19)
  }, alt = "Two-sided power across hypothetical signed differences at fixed planned sample size. Negative differences mean harm; rejection in either direction is counted.")
  output$sensitivity <- renderTable({
    p <- planned(); g <- generating(); null <- p; null$delta <- 0; null$p_treatment <- null$p_control
    xs <- list(p, g, null)
    data.frame(Scenario = c("Plan", "Reality assumed for simulation", "Null effect"), Difference = effect_text(vapply(xs, true_difference, numeric(1)), p$outcome),
      Power = format_percent(vapply(xs, spec_power, numeric(1)), 1), Full_width = effect_text(vapply(xs, anticipated_width, numeric(1)), p$outcome))
  }, digits = 3)
  output$one_status <- renderText({ req(input$run_one > 0); status(one(), "Saved single trial") })
  output$one_retention <- renderTable({
    x <- one(); req(!is.null(x$missing))
    n <- x$spec$n; retained <- c(x$result$retained_control, x$result$retained_treatment)
    data.frame(Group=c("Standard treatment", "Novel treatment"), Recruited=n, Retained=retained, Missing=n-retained)
  })
  output$one_result <- renderTable({
    saved <- one(); x <- saved$result
    if (!is.finite(x$estimate)) return(data.frame(Result="Comparison unavailable: no observed outcome in at least one group."))
    table <- data.frame(Measure = c("Effect estimate", "CI lower limit", "CI upper limit", "Two-sided p-value",
      "Full interval width", "Reject zero", "Interval contains the true effect assumed for simulation", "Width target met"),
      Value = c(effect_text(unlist(x[1:3]), saved$spec$outcome), format(round(x$p_value, 4), nsmall = 4),
                effect_text(x$width, saved$spec$outcome),
                ifelse(unlist(x[6:8]), "Yes", "No")), row.names = NULL)
    if (input$goal == "precision") table[c(1:3,5,7:8), ] else if (!intervals_visible()) table[c(1,4,6), ] else table
  })
  output$one_interpretation <- renderText({
    x <- one(); if (!is.finite(x$result$estimate)) return("This study cannot estimate the treatment difference from the retained records.")
    if (!intervals_visible()) return(paste0("Estimated difference: ", effect_text(x$result$estimate, x$spec$outcome),
      "; p value: ", signif(x$result$p_value, 3), ". At the ", format_percent(x$spec$alpha), " Type I error probability, the test ",
      if (x$result$reject) "rejects" else "does not reject", " a zero population difference."))
    if (input$goal == "precision") return(paste0("Estimated difference: ", effect_text(x$result$estimate, x$spec$outcome),
      "; ", format_percent(1-x$spec$alpha), " confidence interval: ", effect_text(x$result$lower, x$spec$outcome), " to ",
      effect_text(x$result$upper, x$spec$outcome), ". Full width: ", effect_text(x$result$width, x$spec$outcome), "."))
    paste(interval_interpretation(x$result, x$spec), if (!is.null(x$missing)) "The available-case analysis uses observed outcomes. Selective missingness can bias its estimate of the full-population difference." else "")
  })
  output$one_plot <- renderPlot({ validate(need(is.finite(one()$result$estimate), "No estimable comparison in this trial.")); plot_trial_intervals(one()$result, one()$spec, show_legend=FALSE, show_tests=input$goal != "precision") }, alt = "One study estimate and interval; values and interpretation are stated above.")
  output$one_data <- renderTable({
    d <- one()$data
    if ("missing" %in% names(d)) d <- d[order(!d$missing), ]
    do.call(rbind, lapply(split(d, d$group), head, 6))
  }, na="Missing")
  output$one_missing_data_note <- renderText({
    req(!is.null(one()$missing))
    "Simulated outcomes are shown for teaching. Outcomes marked missing are excluded from the analysis and would be unknown in a real study. All participant records are in the download."
  })
  output$many_status <- renderText({ paste(status(many(), "Saved batch"), "B =", many()$spec$B) })
  output$many_summary <- renderTable({
    if (!is.null(many()$missing)) return(missing_outcome_summary(many()))
    if (input$goal == "precision") return(data.frame(Measure=c("Intervals containing the population difference", "Intervals meeting the width target"), Percentage=percent(c(mean(many()$results$cover),mean(many()$results$width_met)))))
    if (isTRUE(input$show_advanced)) display_simulation_summary(simulation_summary(many()))
    else data.frame(Measure = "Statistically significant simulated results", Percentage = percent(mean(many()$results$reject)), check.names = FALSE)
  })
  output$many_text <- renderText({
    x <- many(); r <- x$results
    if (!is.null(x$missing)) return(paste0("Available-case analysis; reference truth is the full recruited population difference. Performance percentages, mean estimates and widths use the ", sum(is.finite(r$estimate)), " studies with observed outcomes in both groups; ", sum(!is.finite(r$estimate)), " comparisons were unavailable. A high significance percentage can accompany biased estimates and poor coverage. The simulated truth is known only because these are generated data."))
    paste0(if (input$goal == "precision") "The simulations evaluate estimation under the selected population assumptions. " else if (abs(true_difference(x$spec)) < 1e-12) "No-difference scenario: the percentage of significant results estimates Type I error probability. " else "True-difference scenario: the percentage of significant results estimates power. ",
      if (intervals_visible()) paste0("Mean full interval width = ", effect_text(mean(r$width), x$spec$outcome), "; ") else "", "Mean estimate = ", effect_text(mean(r$estimate), x$spec$outcome),
      "; truth = ", effect_text(true_difference(x$spec), x$spec$outcome), ". ",
      if (identical(current_activity(), "pain_one_many") && !is.null(x$illustrated_trial))
        "The shared graph connects a trial's patient outcomes to the batch of estimates." else
        "The single-study draw and this batch are generated separately.")
  })
  outputOptions(output, "many_text", suspendWhenHidden=FALSE)
  outputOptions(output, "many_summary", suspendWhenHidden=FALSE)
  valid_many <- reactive({
    x <- many(); x$results <- x$results[is.finite(x$results$estimate), , drop=FALSE]
    validate(need(nrow(x$results)>0, "No estimable comparisons in this batch.")); x
  })
  sample_comparison <- reactive({
    a <- baseline_many(); b <- many_saved()
    if (is.null(a) || is.null(b) || a$spec$n == b$spec$n || !same_simulation_population(a,b)) return(NULL)
    list(original = a, current = b)
  })
  sample_comparison_text <- reactive({
    z <- sample_comparison(); if (is.null(z)) return(character())
    a <- z$original; b <- z$current
    paste0("The first batch used ", a$spec$n, " participants per group and ", nrow(a$results),
      " simulated trials. The current batch uses ", b$spec$n, " per group and ", nrow(b$results),
      " trials, with the same population and test assumptions. The SD of the estimated differences is ",
      effect_text(sd(a$results$estimate),a$spec$outcome), " in the first batch and ",
      effect_text(sd(b$results$estimate),b$spec$outcome), " in the current batch. A narrower distribution means less variation between trial estimates.")
  })
  output$sample_comparison <- renderUI({
    z <- sample_comparison(); req(z)
    tagList(tags$div(class="app-plot-key",
      tags$span(class="solid",style="--key-color:#245e90",paste0("First batch: ",z$original$spec$n," per group")),
      tags$span(class="dashed",style="--key-color:#725197",paste0("Current batch: ",z$current$spec$n," per group"))),
      p(sample_comparison_text()))
  })
  output$many_plot <- renderPlot(plot_trial_intervals(valid_many()$results, many()$spec, show_legend=FALSE, show_tests=input$goal != "precision"), alt = "First 30 study intervals; summary percentages and downloadable data provide a text alternative.")
  output$distribution <- renderPlot({
    x <- valid_many(); scale <- if (x$spec$outcome == "proportions") 100 else 1
    app_plot_style(c(4.2,4.4,2,1))
    z <- sample_comparison()
    xlab <- if (x$spec$outcome == "proportions") "Treatment minus control (points)" else "Treatment minus control (outcome units)"
    if (is.null(z)) hist(scale * x$results$estimate, breaks = 25, col = "#dbeafe", border = "white",
      main = "Sampling distribution of effects", xlab = xlab) else {
      first <- scale*z$original$results$estimate
      current <- scale*x$results$estimate
      breaks <- pretty(range(first,current), n=25)
      a <- hist(first, breaks=breaks, plot=FALSE); b <- hist(current, breaks=breaks, plot=FALSE)
      pa <- 100*a$counts/sum(a$counts); pb <- 100*b$counts/sum(b$counts)
      plot(range(breaks), c(0,max(pa,pb)*1.1),type="n",xlab=xlab,ylab="Simulated studies (%)",main="Estimates at two sample sizes")
      rect(head(breaks,-1),0,tail(breaks,-1),pa,col="#245e9033",border="#245e90",lwd=1.5)
      lines(rep(breaks,each=2),c(0,rep(pb,each=2),0),col="#725197",lwd=2.5,lty=2)
    }
    abline(v = scale * true_difference(x$spec), lty = 3, lwd = 2)
  }, alt = "Effect estimate histogram; mean estimate and the true effect assumed for simulation are provided above.")
  output$p_values <- renderPlot({
    x <- valid_many()
    app_plot_style(c(4.2,4.4,2,1))
    hist(x$results$p_value, breaks = seq(0,1,.025), col = "#d2e6e9", border = "white",
      xlab = "p value", ylab = "Number of trials", main = paste(nrow(x$results), "trials in the latest batch"))
    abline(v = x$spec$alpha, lty = 2, lwd = 2, col = "#923d20")
  }, alt = "Histogram of saved simulation p-values. The significance percentage is reported in the summary table.")
  output$p_value_interpretation <- renderText({
    x <- valid_many(); r <- x$results
    observed <- mean(r$reject)
    paste0("Each p value comes from one of the ", nrow(r), " trials in the latest batch, with ",
      x$spec$n, " participants per group. The dashed line is p = ", format(x$spec$alpha),
      ". Values below it lead to rejection of the null hypothesis of equal population outcomes. ",
      sum(r$reject), " of ", nrow(r), " trials (", format_percent(observed, 1), ") rejected the null. ",
      if (!is.null(x$missing)) "Missing outcomes can affect both the estimate and this rejection percentage. The missing-outcome summary gives bias and coverage alongside it." else
        paste0("With equal population outcomes, approximately ", format_percent(x$spec$alpha),
          " would be expected to reject: false positives. At the current true difference of ",
          effect_text(true_difference(x$spec), x$spec$outcome), ", the planning approximation gives about ",
          format_percent(spec_power(x$spec), 1), " expected rejections. For a nonzero difference, this probability is power. ",
          "Changing the true difference or sample size changes power. A 90% power target applies only when the sample size is chosen to reach it."))
  })
  outputOptions(output, "p_value_interpretation", suspendWhenHidden=FALSE)
  export_rows <- function(rows, meta) {
    for (k in names(meta$plan)) rows[[paste0("plan_", k)]] <- meta$plan[[k]]
    for (k in names(meta$generating)) rows[[paste0("generating_", k)]] <- meta$generating[[k]]
    rows$planning_goal <- meta$goal; rows$target_power <- meta$target_power
    rows$expected_difference <- meta$expected_effect
    rows$target_difference <- true_difference(meta$plan)
    rows$dropout_fraction <- meta$dropout
    if (!is.null(meta$recruitment_cap)) rows$recruitment_cap <- meta$recruitment_cap
    if (!is.null(meta$missing)) for (k in names(meta$missing)) rows[[paste0("missing_", k)]] <- meta$missing[[k]]
    rows$method <- paste(method_label(meta$plan$outcome), if (!is.null(meta$missing)) "with actual retained group sizes; available cases only" else "")
    rows
  }
  output$download_one <- downloadHandler(filename = function() "single_study.csv", content = function(file) {
    x <- one(); write.csv(export_rows(x$data, x$meta), file, row.names = FALSE)
  })
  output$download_many <- downloadHandler(filename = function() "study_replications.csv", content = function(file) {
    x <- many(); write.csv(export_rows(x$results, x$meta), file, row.names = FALSE)
  })
  outputOptions(output, "download_one", suspendWhenHidden=FALSE)
  outputOptions(output, "download_many", suspendWhenHidden=FALSE)
  report_sections <- reactive({
    details <- study_details()
    if (pain_report()) {
      sections <- app_pain_simulation_report(snapshot(), one_saved(), many_saved(), details)
      comparison_text <- sample_comparison_text()
      if (length(comparison_text) && identical(many_saved()$meta, snapshot())) {
        sections[["Comparing sample sizes"]] <- comparison_text
        first <- baseline_many()$spec
        sections[["Simulation record"]] <- c(sections[["Simulation record"]],
          paste0("Retained first batch: ", first$n, " participants per group, ", first$B,
            " repetitions, random seed ", first$seed, ". Population and test assumptions match the current batch."))
      }
      return(sections)
    }
    answer <- app_answer
    compatible <- details$study_design == "two_groups" && is.null(routed_case())
    calculation <- if (compatible) {
      x <- planned(); recruit <- adjust_for_dropout(x$n, input$dropout)
      c(paste0("Planning goal: ", switch(input$goal, testing = "power at the target difference", precision = "estimation with a target interval width", fixed = "assess an available sample"),
          ". Two independent groups with equal allocation."),
        if (input$goal != "precision") paste0("Between-group differences: observed in earlier data ", effect_text(expected_effect(), x$outcome),
          "; target ", effect_text(true_difference(x), x$outcome), "; clinical threshold ", effect_text(x$threshold, x$outcome), "."),
        if (x$outcome == "means") paste0("Common SD: ", x$sd, " units.") else
          paste0("Assumed event percentages: standard ", format_percent(x$p_control), "; novel ", format_percent(x$p_treatment), "."),
        if (input$goal != "precision") paste0("Type I error probability: ", format_percent(x$alpha), "; target power: ", format_percent(input$target_power),
          "; calculated power at the target difference: ", format_percent(spec_power(x), 1), "."),
        if (intervals_visible()) paste0(format_percent(1-x$alpha), " confidence intervals: target full width ", effect_text(x$width_target, x$outcome),
          "; anticipated full width ", effect_text(anticipated_width(x), x$outcome), "."),
        paste0("Analyzable participants: ", x$n, " per group; ", 2*x$n, " total. Expected losses: ", format_percent(input$dropout),
          ". Recruitment after upward rounding: ", recruit, " per group; ", 2*recruit, " total."),
        paste0("Planning method: ", if (input$goal == "precision") {
          if (x$outcome == "means") "expected pooled-variance t-interval width." else "plug-in Newcombe-Wilson interval width."
        } else if (x$outcome == "means") "noncentral t power for two independent means."
          else "stats::power.prop.test (two-sided, strict = TRUE)."))
    } else "This design requires a design-specific sample-size method."
    capacity <- feasibility()
    sections <- list("Study context" = c(
      paste0("Selected example: ", if (nzchar(current_activity())) teaching_case(current_activity())$title else "Custom settings", ". Values below reflect the current settings."),
      paste("Study design:", switch(details$study_design, two_groups = "Two independent groups", paired = "Paired or repeated measurements",
        single_proportion = "One population proportion", observational = "Observational study", diagnostic = "Diagnostic accuracy", prediction = "Prediction model", other = "Other design"))),
      "Your study responses" = c("Responses are reproduced as entered and should be reviewed after changing the example or settings.",
        paste("Research question and primary outcome:", answer(details$study_question)),
        paste("Clinical relevance:", answer(details$clinical_relevance)),
        paste("Participant burden and ethical considerations:", answer(details$participant_burden)),
        paste("Evidence and uncertainty:", answer(details$evidence_sources))),
      "Calculation and assumptions" = calculation,
      "Resources and feasibility" = c(paste0(details$eligible_monthly, " eligible participants per month × ", format_percent(details$consent_fraction),
        " expected consent × ", details$recruitment_months, " months gives ", capacity$recruits, " expected recruits."),
        if (compatible) paste0("Under equal allocation: ", capacity$balanced, " recruits and approximately ", capacity$expected_analysable,
          " participants available for analysis. Selected recruitment limit: ", input$recruit_cap, " in total. Required recruitment ",
          if (2*recruit > capacity$balanced) "exceeds" else "fits within", " the expected recruitment capacity and ",
          if (2*recruit > input$recruit_cap) "exceeds" else "fits within", " the selected limit.")))
    if (compatible && current_activity() == "pain_curves" && input$goal != "precision") {
      z <- comparison(); results <- comparison_results()
      sections[["Sensitivity at the available sample"]] <- c(
        paste0("Available analyzable count: ", z$cap_n, " per group. Target power: ", format_percent(input$target_power), "."),
        vapply(seq_len(nrow(results)), function(i) paste0("True difference ", effect_text(z$effects[i], z$spec$outcome),
          ": power ", results[i, 2], "; required for target power: ",
          if (is.na(results[i, 3])) "undefined for a zero difference" else paste(results[i, 3], "per group"), "."), character(1)))
    }
    if (compatible) {
      meta <- snapshot(); g <- meta$generating
      sections[["Simulation assumptions"]] <- c(
        paste0("Population assumed for simulation: ", if (g$outcome == "means") paste0("mean difference ", effect_text(g$delta, g$outcome), "; SD ", g$sd)
          else paste0("standard event percentage ", format_percent(g$p_control), "; novel event percentage ", format_percent(g$p_treatment)),
          ". Each simulated trial uses ", g$n, if (is.null(meta$missing)) " analyzable" else " recruited", " participants per group."),
        if (!is.null(meta$missing)) paste0("Missing-outcome scenario: ", missing_scenario_label(meta$missing),
          ". Complete-outcome planning values above and simulated available-case results use different sample definitions."),
        paste0("Analysis: ", if (input$goal == "precision") { if (g$outcome == "means") "pooled-variance t confidence interval" else "Newcombe-Wilson difference interval" } else method_label(g$outcome), if (!is.null(meta$missing)) "; available outcomes with their actual group sizes" else "", "."),
        paste0("Reproducibility settings: random seed ", g$seed, "; requested repetitions ", g$B, "."))
      sections[["One simulated trial"]] <- if (input$goal == "precision") app_estimation_report(one_saved(), meta) else app_simulation_report(one_saved(), meta)
      sections[["Many simulated trials"]] <- if (input$goal == "precision") app_estimation_report(many_saved(), meta, many = TRUE) else app_simulation_report(many_saved(), meta, many = TRUE)
    }
    sections[["Your recommendation and justification"]] <- answer(details$justification)
    sections[["Planning guidance"]] <- "PICO (Richardson et al., 1995), doi:10.7326/ACPJC-1995-123-3-A12; SPIRIT 2025, https://www.consort-spirit.org/; DELTA² (Cook et al., 2018), doi:10.1136/bmj.k3750."
    sections
  })
  report_paragraphs <- reactive(unlist(report_sections(), use.names = FALSE))
  report_heading <- reactive(if (pain_report()) "Pain relief: simulation report" else "Sample size reasoning lab report")
  report_intro <- reactive(if (pain_report())
    "This report records the current population assumptions and the latest matching simulations."
    else "This report records the current calculation, matching simulation results, and written justification.")
  output$report_preview <- renderUI(app_report_body(report_sections(), heading = report_heading(), intro = report_intro()))
  output$download_plan <- downloadHandler(filename = function() if (pain_report()) "pain-relief-simulation-report.html" else "sample-size-calculation-report.html",
    content = function(file) writeLines(app_report_document(report_heading(), "power_explorer", report_sections(),
      report_heading = report_heading(), report_intro = report_intro()), file, useBytes = TRUE))
  output$download_plan_json <- downloadHandler(filename = function() "sample-size-calculation-report-work.json", content = function(file) {
    plan <- list(schema = "sample-size-study-plan", version = 1, activity = current_activity(),
      inputs = current_lab_inputs(), study = study_details())
    writeLines(jsonlite::toJSON(plan, auto_unbox = TRUE, pretty = TRUE, digits = 16, null = "null"), file)
  })
  output$download_code <- downloadHandler(filename = function() "reproduce_studies.R", content = function(file) {
    x <- snapshot()
    calls <- if (is.null(x$missing)) c(
      '# Generate and analyze one trial, then the requested number of repetitions.',
      'one <- simulate_one_study(generating)', 'many <- simulate_trials(generating)',
      '# Summarize performance across the repeated trials.', 'simulation_summary(many)') else
      c('# Specify which outcomes may be missing and how they will be analyzed.',
        'settings <-', capture.output(dput(x$missing)),
        '# Apply those assumptions to one study and to repeated trials.',
        'one <- simulate_missing_one(generating, settings)', 'many <- simulate_missing_trials(generating, settings)',
        '# Summarize missingness, bias and interval performance.', 'missing_outcome_summary(many)')
    if (isTRUE(one_saved()$from_batch)) calls <- c(calls,
      '# The displayed patient records show the first trial in this batch.',
      'one <- many$illustrated_trial')
    if (isTRUE(x$compare_populations)) calls <- c(calls,
      '# Repeat the analysis for the other population shown beside the main plot.',
      'comparison <-', capture.output(dput(comparison_spec(x$generating))),
      'comparison_one <- simulate_one_study(comparison)',
      'comparison_many <- simulate_trials(comparison)',
      'simulation_summary(comparison_many)')
    writeLines(c('# Current inputs. Run from the repository root.', 'source("R/sample_size_functions.R")',
      '# Planning assumptions used to choose the sample size.',
      'plan <-', capture.output(dput(x$plan)),
      '# Assumed population values used to generate the simulated trials.',
      'generating <-', capture.output(dput(x$generating)), calls,
      '# Display the result from the single study.', 'one$result',
      '# Keep studies with an estimable difference before plotting their intervals.',
      'valid <- many$results[is.finite(many$results$estimate), , drop=FALSE]',
      'if (nrow(valid)) plot_trial_intervals(valid, many$spec)'), file)
  })
  # Linked activities change tabs and advanced controls together. Finish any
  # in-flight planning updates even when their panel becomes hidden, so WebR
  # does not discard the other values in that output batch.
  for (name in c("planning", "axis_note", "planning_text", "method",
                 "planning_plot", "comparison_plot", "comparison_table",
                 "effect_plot", "sensitivity"))
    outputOptions(output, name, suspendWhenHidden = FALSE)
}
shinyApp(ui, server)
