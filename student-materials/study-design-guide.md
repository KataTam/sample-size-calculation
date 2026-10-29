# Other study goals and designs {#study-designs .advanced-heading}

::: {.learning-goals .advanced-outcomes}
After this chapter, you should be able to:

- Use the study-design questionnaire to identify suitable design families and unresolved decisions.
- Match the planning goal to the question: treatment comparison, estimation or feasibility.
- Plan for useful precision in a mean difference or a prevalence estimate.
- Assess existing datasets, pilot studies and restricted recruitment populations.
- Recognize how paired and clustered observations affect planning and analysis.

:::

The study design and planning method should follow the research question, outcome, sampling structure and intended analysis. "Clinical," "retrospective," "diagnostic" and "within-subject" describe different aspects of a study and can apply together. A diagnostic study can be clinical and retrospective, and a preclinical experiment can have repeated measurements.

This chapter offers optional branches for questions beyond the basic two-independent-group calculation. The questionnaire provides a starting point; the sections cover dependent observations, precision-based planning, existing data, pilot studies and rare-disease constraints. You can consult the branch relevant to your study.

## Activity: Which study design fits your question? {#design-questionnaire .advanced-heading}

[Open the study-design questionnaire with this chapter](https://katatam.github.io/sample-size-calculation/study/?activity=design_questionnaire).

Your answers cover the study aim, available data, outcome and relationships between observations. Follow-up questions address intervention allocation, treatment comparisons, observational sampling, diagnostic reference standards or prediction models as appropriate. The questionnaire app suggests a design family, explains why it fits, and identifies decisions still needed before sample size planning. Existing data can support different designs depending on how participants were selected and when measurements were made.

Several designs may be reasonable for the same question. The suggestion should support discussion of feasibility, ethics and the intended analysis. Links lead to a matching calculation activity when its assumptions fit, or to design-specific resources. The questionnaire uses the distinctions explained in this chapter.

The [CDC Field Epidemiology Manual](https://www.cdc.gov/field-epi-manual/php/chapters/design-conduct-analyze-field-studies.html) discusses cohort and case-control design considerations [@jackson2024]. The reporting and sample-size sources below support the other routes.

## Describe these dimensions first {.advanced-heading}

| Dimension | Examples | Why it matters for planning |
|:--|:--|:--|
| Setting | Preclinical laboratory, clinical care, population health | Identifies the target population, experimental unit and practical/ethical constraints |
| Assignment | Intervention allocated by researchers, observational exposure | Determines what comparisons and causal conclusions the design can support |
| Timing/data availability | Prospective collection, existing retrospective records | Determines whether recruitment can be chosen or the available sample must be assessed |
| Dependency | Independent people, paired measurements, repeated visits, practices/wards | Determines how much independent information the observations supply |
| Aim | Describe a prevalence, compare effects, assess diagnostic accuracy, study a risk factor, predict individual outcomes | Determines the target quantity and whether power, precision or predictive performance drives planning |
| Outcome/analysis | Continuous, binary, time-to-event, counts; adjusted model or simple comparison | Determines the required distributional and modeling assumptions |

Table: Design dimensions that determine the appropriate planning method.

## Units of randomization, measurement, and analysis {#units-of-analysis .advanced-heading}

The number of measurements in a study does not necessarily equal the number of independent observations. Before choosing a sample size calculation, you should distinguish:

- The [unit of randomization](#unit-of-randomization): what is assigned to a treatment, such as a participant, hospital, or body site.
- The [unit of measurement](#unit-of-measurement): what an outcome is recorded for, such as a participant, lesion, or measurement occasion.
- The [unit of analysis](#unit-of-analysis): the entity represented in the analysis, with dependence among entities accounted for by the model.

These units may coincide, as in a trial where participants are individually randomized and each contributes one outcome. They can also differ. An analysis may use individual measurements while accounting for their grouping within hospitals or participants.

### Treatment assigned to groups {.advanced-heading}

In a cluster-randomized trial, treatment is assigned to whole groups, such as hospitals or schools. This can be useful when an intervention changes clinic practice or when individual allocation could lead to contamination between treatment groups. Outcomes may still be measured in individual participants, but participants in the same cluster often have more similar outcomes than participants in different clusters. The analysis and sample size calculation should account for this dependence [@campbell2012consort].

With positive within-cluster correlation, a study provides less information than an individually randomized trial with the same total number of participants. Consequently, both the number of clusters and the number of participants per cluster matter. Recruiting more participants within a few hospitals cannot fully compensate for having very few randomized hospitals.

For a simple design with approximately equal cluster sizes, an approximate inflation factor is the [design effect](#design-effect) [@campbell2012consort]:

$$
\text{Design effect}=1+(m-1)\rho,
$$

where $m$ is the number of participants per cluster and $\rho$ is the [intracluster correlation coefficient (ICC)](#intracluster-correlation). For example, with 20 participants per cluster and an ICC of 0.05, the design effect is $1.95$. An initial calculation based on independent participants would therefore be multiplied by approximately 1.95. This is a starting approximation; the final calculation should also account for the number of clusters, unequal cluster sizes, and the planned analysis [@hayes1999].

### Treatment assigned within participants {.advanced-heading}

Randomization can also occur within a participant. For example, one leg may receive treatment A and the other treatment B. Such designs are suitable when treatment effects are local and treatment at one site does not materially affect the outcome at another site [@pandis2017withinperson].

Here, the treatment comparison is made within participants. When paired outcomes are positively correlated, the within-person difference can be estimated more precisely than a difference between independent groups with the same outcome variability. Sample size planning therefore depends on the variability of the paired differences, or equivalent information about the variability and correlation of the two measurements [@pandis2017withinperson].

A study with 30 participants and two treated sites per participant provides 30 participant-level pairs. Its sample size should be planned using a method for [paired observations](#paired-observations). Designs with several sites or lesions per participant may require a more detailed model of the dependence among measurements.

### What this means for sample size planning {.advanced-heading}

Correlation has different consequences depending on where treatments are assigned. In a cluster-randomized trial, members of the same cluster receive the same treatment, so their correlated outcomes contribute partly overlapping information to the comparison between treatments. In a paired-site trial, the two treatments are compared within the same participant, allowing shared participant characteristics to cancel out in the difference.

The sample size calculation should therefore match the allocation structure and the planned analysis. Your [reproducibility record](#reproducibility-record) should specify what is randomized, what is measured, how many independent units are available, and how dependence among measurements will be handled.

## Estimation with a precision target {#plan-for-precision .advanced-heading}

The rehabilitation comparison can also be planned around how precisely it should estimate the population mean difference. Estimation identifies the quantity of interest; precision concerns the uncertainty around its estimate. A useful confidence level and interval width can therefore guide sample size planning alongside the power criterion in [Calculating sample size](#calculations) [@wang2020; @lakens2022].

The [lab](https://katatam.github.io/sample-size-calculation/study/?activity=mean_precision) offers *Estimation with a target interval width* alongside testing and fixed-resource goals. Your plan should specify the [full width](#full-width), in the outcome's original units. For the rehabilitation improvement score, the expected difference remains 4 units, the target difference 3 units and the clinical threshold 2 units. You can use SD 5 and a target full width of 4 units:

```{r precision-plan}
precision_spec <- study_spec(outcome = "means", delta = 3, sd = 5,
  threshold = 2, width_target = 4, B = 5000, seed = 20260922)
precision_spec$n <- plan_n(precision_spec, goal = "precision")
c(per_group = precision_spec$n,
  expected_full_width = anticipated_width(precision_spec),
  power_at_planning_effect = spec_power(precision_spec))
precision_batch <- simulate_trials(precision_spec)
knitr::kable(display_simulation_summary(simulation_summary(precision_batch)),
  caption = "Simulated performance of a study planned for estimation with a specified interval-width target.")
```

```{r precision-plan-formatted, echo=FALSE}
knitr::kable(data.frame(`Analyzable per group`=precision_spec$n, `Anticipated full interval width`=round(anticipated_width(precision_spec),2), `Power at the target difference`=percent(spec_power(precision_spec)),check.names=FALSE), caption="Sample size, anticipated precision and power for the improvement-score comparison.")
```

For normal data, the curve gives expected full t-interval width. For binary outcomes, the planning width is calculated by inserting the assumed probabilities into the Newcombe-Wilson interval formula. It approximates the width anticipated before observing data. Realized interval widths vary; the simulation reports the fraction that meets the target separately [@sandoval2025; @newcombe1998].

::: {.activity}
You can compare planning goals in [Activity: Estimate a mean difference with a precision target](https://katatam.github.io/sample-size-calculation/study/?activity=mean_precision). In the [lab](https://katatam.github.io/sample-size-calculation/study/?activity=mean_precision), you can choose *Continuous outcome*, expected difference 4, target difference 3, SD 5, clinical threshold 2, [Type I error probability](#alpha) 5% and full width 4. The outcome here is an improvement score. You can compare the sample selected for the specified interval-width target with the sample selected for 80% power. Your explanation should address why the same research question might require considering both criteria.

The motivation is that detecting a difference and estimating it precisely need not require the same sample size. The planning curve calculates anticipated interval width. *One study* generates a realized interval, and *Many studies* estimates how often intervals meet the requested full width. A full width of 4 units corresponds to a margin of approximately 2 units on either side for a symmetric interval.

<details class="model-answer" id="model-answer-precision-versus-power">
<summary>Model answer</summary>

With SD 5 and the same two-group analysis, the expected full-width target of 4 units requires `r precision_spec$n` analyzable patients per group; the 80% power target at a 3-unit difference requires `r plan_n(precision_spec, goal = "testing", target_power = .80)` per group. Both plans allow estimation of the difference. The precision criterion concerns how narrow its confidence interval is expected to be; the power criterion concerns how often the test rejects zero at the specified true difference. Your study question may require both a useful interval width and an adequate probability of detecting a worthwhile effect. If both are requirements, the plan should satisfy both under justified assumptions.

</details>

:::

## Estimate one proportion: a prevalence survey {#prevalence .advanced-heading}






The design dimensions above also explain why some questions need a different calculation. A prevalence survey estimates one population proportion at a defined time. Each participant contributes a binary outcome to one sample; you choose its size for a useful [margin of error](#margin-of-error).

Such estimates can inform service planning or recruitment and retention assumptions for a future trial. The planning question is how precisely the study should estimate the population percentage [@pourhoseingholi2013; @ying2025].

Suppose a service wants to estimate the percentage of eligible patients reporting a symptom. It wants a 95% confidence interval with an approximate margin of error of 5 [percentage points](#percentage-points): half-width $d=0.05$, or a full width of 10 percentage points. This is a simple independent-sample prevalence example. Here, n is the total number of participants in a single sample.

For an anticipated population proportion $p_0$, the normal approximation gives:

\begin{equation}
n\approx\frac{z_{1-\alpha/2}^{2}p_0(1-p_0)}{d^2}.
(\#eq:single-proportion)
\end{equation}

Here $p_0$ is the anticipated population proportion used to plan the study. If comparable evidence suggests a prevalence of 20% ($p_0=0.20$), the approximate requirement is 246 completed observations. If there is no useful prior estimate, 50% ($p_0=0.50$) gives the largest value of $p_0(1-p_0)$ and an approximate requirement of 385.

```{r single-proportion-precision}
prevalence_known <- proportion_precision_plan(p = .20,
  full_width = .10, confidence = .95)
prevalence_unknown <- proportion_precision_plan(p = .20,
  full_width = .10, confidence = .95, unknown_p = TRUE)
knitr::kable(data.frame(
  Scenario = c("Prior estimate 20%", "Unknown: use 50% for planning"),
  `Assumed population percentage` = percent(c(prevalence_known$planning_p,
    prevalence_unknown$planning_p)),
  `Completed observations` = c(prevalence_known$n, prevalence_unknown$n),
  check.names = FALSE),
  caption = "Approximate prevalence sample sizes for a 95% interval with a 5-percentage-point margin of error.")
```

The conservative 50% choice concerns absolute precision for one proportion under this approximation. It is not a general substitute for unknown control and treatment percentages in a power calculation. For a rare outcome, an absolute margin of five percentage points might be unhelpfully wide; event counts and the chosen interval method also matter.

[Activity: Estimate a percentage with useful precision](https://katatam.github.io/sample-size-calculation/study/?activity=prevalence). You can compare margins of error of 5 and 2.5 percentage points. The latter requires about four times as many completed observations under the formula. The app shows a Wilson interval for an illustrative realized sample; its width can differ from the planning approximation. No formula here guarantees that every realized interval meets the target. Representative recruitment matters as well: a larger convenience sample does not automatically remove selection bias [@whitley2002; @wang2020].




The worked survey illustrates one planning method. The table below places it alongside treatment comparisons and other research objectives.

## Reuse an existing dataset for a different question {#dataset-reuse .advanced-heading}

An existing dataset is another fixed-resource setting, common in bachelor projects. Suppose a completed chronic pain trial included 200 patients and also recorded sleep difficulty before treatment. Your new question is: what percentage of these trial participants reported sleep difficulty at baseline? This differs from the trial's original question about treatment effectiveness.

Baseline sleep information is available for 180 participants; 72 reported difficulty. The observed percentage is 72/180 = 40%. With the sample already fixed, the planning task is to assess the precision the available data can provide.

```{r reused-dataset}
sleep_result <- single_proportion_interval(events = 72, n = 180,
  confidence = .95)
sleep_result
```

```{r reused-dataset-summary, echo=FALSE}
sleep_limits <- wilson_interval(.40, 180)
knitr::kable(data.frame(
  Measure = c("Patients in the dataset", "With baseline sleep information",
    "Reporting sleep difficulty", "Observed percentage", "95% Wilson confidence interval"),
  Result = c("200", "180", "72", "40.0%",
    paste(percent(sleep_limits[1, 1]), "to", percent(sleep_limits[1, 2])))),
  caption = "A new descriptive question answered using an existing chronic-pain trial dataset.")
```

The interval describes sampling uncertainty under the model. Possible differences between the 20 patients with missing information and those who answered require separate assessment. The trial's eligibility criteria also restrict whom these results describe: its participants may not represent all patients with chronic pain. Random allocation supports the original treatment comparison.

The new question needs its own assessment of adequacy. You should check that the required variables and time points are available, that reuse is permitted, and that the analysis fits the new objective. For a new association question, you would also need to consider confounding and the relevant model. The estimate, interval and limitations should guide interpretation; observed post hoc power adds no evidence about the same result [@lakens2022; @consortee2025].

Before examining the new results, your report should document why the sample is fixed and what precision would be useful. The available sample sets the resource limit. Its adequacy depends on the precision required for the new question. For a comparison, you can evaluate independently justified differences at that fixed sample size; for this descriptive question, you can examine the attainable interval width. If it is too wide for the intended decision, you should narrow the claim or explain that more data would be needed. Your report should identify analyses developed after examining the data as exploratory.

::: {.activity}
For your adapted research question, your plan should identify the new outcome, target population, available sample and missing observations. Would an interval of this width answer your project question? Your report should record these decisions in the [Activity: Develop and justify your study plan](https://katatam.github.io/sample-size-calculation/study/?activity=assumptions_report), using a fixed-resource estimation goal.

<details class="model-answer" id="model-answer-existing-data">
<summary>Model answer</summary>

The new outcome is baseline sleep difficulty. The results directly describe the population defined by the original trial's eligibility criteria. The dataset contains 200 patients, with sleep information for 180 and missing information for 20. Among those with information, 72/180 = 40% reported difficulty; the 95% Wilson interval is `r percent(sleep_limits[1, 1])` to `r percent(sleep_limits[1, 2])`.

Whether this precision is useful depends on a decision specified for the project. It may support a broad descriptive estimate, but would not support a requirement to estimate the percentage within 2 percentage points. The report should explain the fixed sample, missing information and restricted population. Adequacy here depends on precision for the descriptive objective.

</details>

:::

## Planning a pilot or feasibility study {#pilot-feasibility .advanced-heading}

So far, feasibility has meant whether you can carry out an informative main study. A preliminary pilot or feasibility study has its own research objectives: investigating whether recruitment, retention, delivery, or other procedures will work. Its sample size should support those decisions.

Suppose a team wants to test a new rehabilitation pathway and needs evidence about recruitment and follow-up. It can recruit 40 patients over three months to investigate these procedures.

You can start with systematic reviews, relevant previous studies, routine service data and clinical expertise. Your report should record the population, outcome, time point and uncertainty of each source. You should agree the main trial's clinically meaningful outcome with patients and clinicians. The pilot can investigate recruitment and retention, measurement procedures, acceptability and variability. Planning the definitive trial should combine these findings with relevant external evidence [@albers2018].

For the pilot, your plan should connect the available resources with the precision needed for these feasibility decisions. The [single-proportion example](#prevalence) explains the corresponding interval-width calculation. Here the hypothetical cap is 40 participants, and expected completion of follow-up is 80%. If 32 of 40 complete follow-up, what would that tell the team about retention?

```{r pilot-retention}
pilot_retention <- single_proportion_interval(events = 32, n = 40,
  confidence = .95)
pilot_retention
```

```{r pilot-retention-formatted, echo=FALSE}
knitr::kable(data.frame(`Completed follow-up`="32/40 (80%)", `95% Wilson confidence interval`=paste(percent(pilot_retention$lower), "to", percent(pilot_retention$upper)), check.names=FALSE), caption="Retention and its uncertainty in a 40-participant feasibility study.")
```

The observed 80% retention still has a wide interval. You can compare it with a prospectively agreed progression criterion and consider reasons for missing outcomes. A point estimate of 80% alone cannot establish that the main trial will retain at least 80%.

Your pilot size should reflect the decision it must support. Ying and colleagues distinguish estimating feasibility with useful precision, assessing progression criteria, detecting practical problems and informing variability for the main trial [@ying2025]. You should specify each outcome's denominator: retention concerns participants enrolled, while a recruitment percentage may concern eligible people approached. Forty enrolled patients do not supply forty observations for every feasibility outcome.

::: {.activity}
Before seeing retention results, your feasibility plan should specify an unacceptable level, a desirable level and what would lead to proceeding, amending or stopping. You can compare the intervals for 40 and 80 participants. Your explanation should address whether either sample supplies useful information for those decisions, alongside acceptability and reasons for missing follow-up. The progression criteria should have a clinical and operational justification.

<details class="model-answer" id="model-answer-pilot-progression">
<summary>Model answer</summary>

One possible set of prospectively specified criteria would treat retention below 70% as unacceptable and 80% as desirable. A team could proceed if the estimate is at least 80%, the lower 95% confidence limit exceeds 70%, and delivery and acceptability are satisfactory; amend the pathway if the interval still includes unacceptable retention; and stop or substantially redesign it if the interval lies below 70%. These illustrative thresholds and rules need clinical and operational justification before the results are seen.

For 32/40 retained participants, the 95% Wilson interval is `r percent(wilson_interval(.80, 40)[1, 1])` to `r percent(wilson_interval(.80, 40)[1, 2])`; for 64/80 it is `r percent(wilson_interval(.80, 80)[1, 1])` to `r percent(wilson_interval(.80, 80)[1, 2])`. The 40-person result would lead to amendment or further investigation under these illustrative rules. The 80-person result just meets the numerical progression rule using the unrounded lower limit, but the reasons for missing follow-up and acceptability would still matter. Neither result establishes that true retention is at least 80%. Recruiting 80 would also need its own feasible time and resource plan.

</details>

:::

For another objective, suppose a practical problem independently affects 10% of participants. The probability of observing at least one problem in $n$ participants is $1-(1-0.10)^n$; 29 give at least a 95% probability. Much rarer problems require larger samples for reliable detection. A problem can remain undetected in a small pilot [@ying2025]. Different pilot objectives can therefore imply different numbers.

<details class="misconception" id="misconception-pilot-goal">
<summary>Common misconception: every pilot needs a treatment-effect power calculation</summary>

A pilot may primarily investigate recruitment, retention or whether procedures are workable. The sample size should support the feasibility questions and provide useful precision for the intended decisions. Planning the definitive trial should combine the pilot findings with relevant external evidence [@albers2018].

</details>

[Activity: Pilot study: estimate retention](https://katatam.github.io/sample-size-calculation/study/?activity=pilot_feasibility). It starts with a fixed total of 40 and anticipated retention of 80%. You can compare illustrative intervals at 40 and 80 observations; make clear whether another recruitment period or collaboration could obtain the larger sample.

The app can generate one hypothetical retention count from the assumed 80% probability. It will not necessarily produce exactly 32 of 40. Both retained and non-retained participants contribute to the retention estimate when their status is known.

Before writing the protocol, you should check relevant guidance and the current funder's requirements. For examples, [NIHR HTA guidance on feasibility and pilot studies](https://njl-admin.nihr.ac.uk/document/download/2023130) distinguishes feasibility questions from definitive efficacy questions; this is an archived guidance example. The [CONSORT extension for randomized pilot and feasibility trials](https://www.bmj.com/content/355/bmj.i5239) asks for a rationale for pilot numbers and criteria for progression [@nihrfeasibility; @eldridge2016]. Reporting guidance helps you document the design. The sample size method should match the study question and planned analysis.

## What if the disease is rare? {#rare-diseases .advanced-heading}

For a rare disease, the number of eligible patients may limit recruitment. Your plan should document how many patients could realistically participate, over what period and across which centers, and what that sample could establish.

This is the same feasibility problem as the chronic pain plan, with a more restrictive recruitment ceiling. The aim is to obtain useful, valid information within the recruitment limit.

1. You should establish the recruitment ceiling. You can work with specialist centers, registries and patient organizations. You can consider collaboration across countries, eligibility criteria and ways to reduce travel and follow-up burden. Your explanation should distinguish the number of people with the disease from the number eligible and willing to participate [@fdarare2023].
2. You can use knowledge of the disease's natural course. Previous studies and registries can inform progression, variability, suitable assessment times and meaningful outcomes. You should check whether these data describe the population you intend to study. If this knowledge is insufficient, a natural-history study may be a useful research objective in its own right [@fdanaturalhistory2019].
3. You can obtain useful information from each participant. You can use reliable, clinically meaningful measurements and minimize missing outcomes. Where clinically appropriate, retaining the continuous outcome can preserve information. Adjustment for informative baseline measurements should be prespecified. These choices require a matching analysis and sample size method [@emasmall2006].
4. You can consider another design when appropriate. Crossover or n-of-1 designs may suit stable conditions with reversible treatment effects and manageable carryover. They generally do not suit irreversible treatments or rapidly progressing disease. Prespecified adaptive or Bayesian approaches may also help, but require specialist planning; they do not guarantee that fewer patients will suffice [@emasmall2006; @fdarare2023].
5. Your plan should preserve a credible comparison. Randomization remains valuable. Registry or historical controls can sometimes help, but differences in patient severity, treatment era and outcome measurement can bias the comparison. They are not an automatic replacement for a concurrent control group [@fdaexternal2023].
6. Your explanation should address the remaining uncertainty. Evaluate attainable power across plausible effects and the anticipated confidence interval width. A small randomized study may still be informative, although inconclusive results remain possible. Your explanation should address what it could establish and what would require further evidence [@emasmall2006].

These recommendations draw on the EMA guideline on clinical trials in small populations (2006) and FDA rare-disease guidance (final, 2023). The FDA natural-history (2019) and external-control (2023) documents cited here are draft guidance. These sources concern medicinal-product development; use the principles that fit your own study's purpose and discuss alternative designs with a methodological collaborator.

<details class="misconception" id="misconception-rare-disease-threshold">
<summary>Common misconception: rare diseases require a different significance threshold</summary>

In rare-disease studies, the Type I error probability and any alternative design need prospective justification [@emasmall2006].

</details>

## Match the question to a method and resource {.advanced-heading}

| Example question | Planning focus | Route |
|:--|:--|:--|
| Do two individually allocated rehabilitation programs differ on a continuous improvement score? | Difference, common SD, analysis, Type I error probability/power or interval width | [Rehabilitation case](#rehabilitation); the core equal-independent-group [lab](https://katatam.github.io/sample-size-calculation/study/?activity=rehabilitation) applies under its assumptions |
| Does probiotic supplementation reduce gestational diabetes in pregnant women with overweight or obesity? | Two event probabilities, allocation or observational exposure, diagnostic criteria, assessment time and effect scale | [Prevention trial](#adherence); the binary [core lab](https://katatam.github.io/sample-size-calculation/study/?activity=adherence) applies to an individually randomized, independent-group comparison under its assumptions |
| What proportion of eligible patients has a symptom? | Representative sample, confidence level and useful absolute margin of error | [Single-proportion precision activity](#prevalence); a simple independent sample |
| Can a pathway recruit and retain enough patients for a future trial? | Feasibility outcomes, progression criteria and their precision | [Pilot case](#pilot-feasibility); [CONSORT pilot extension](https://www.bmj.com/content/355/bmj.i5239) for randomized pilots |
| How accurately does a screening test identify disease? | Precision of sensitivity/specificity and enough reference-positive/reference-negative participants | [STARD 2015](https://www.bmj.com/content/351/bmj.h5527) for reporting; obtain diagnostic-accuracy planning methods |
| Do speech measurements differ between the same Parkinson patient's OFF and ON medication states? | Within-person differences, repeated-measures analysis and correlation | Use a paired/repeated-measures method for this change question; both recordings belong to the same participant |
| Does an intervention allocated to wards improve outcomes? | Number/size of clusters, within-cluster correlation and analysis | Use cluster planning; see [Hayes and Bennett (1999)](https://doi.org/10.1093/ije/28.2.319) |
| Is a treatment sufficiently similar to an established treatment, or not worse by more than an acceptable margin? | Equivalence or noninferiority hypotheses, justified margin, analysis and error control | The hypotheses should assess the prespecified equivalence or noninferiority margin. See Julious (2023) in the tutorial references |
| What can a trial establish when a rare disease limits recruitment? | Recruitment ceiling, meaningful outcomes, valid comparison and attainable information | [Rare-disease planning](#rare-diseases); the sample size should follow the study objectives, recruitment ceiling and design-specific guidance |
| Is a risk factor associated with an outcome in a cohort or case-control study? | Association scale, event frequency, exposure frequency, confounder adjustment and missingness | Obtain analysis-specific regression/association planning; [STROBE](https://www.strobe-statement.org/) supports reporting |
| Do semantic speech features predict Parkinson's medication state more accurately than syntactic features? | Paired ON/OFF recordings, paired comparison of model performance, number of patients and predictor parameters, and evaluation without patient overlap | [Riley et al. (2020)](https://www.bmj.com/content/368/bmj.m441) gives general model-development planning guidance; the paired comparison needs additional methods. [TRIPOD+AI](https://www.tripod-statement.org/) supports reporting |
| How informative is an existing retrospective dataset? | Available analyzable n, selection, missingness, intended model and achievable precision | Assess fixed resources at independently justified scenarios; avoid observed-effect post-hoc power |
| How many units does an animal or laboratory experiment need? | Experimental unit, replication, allocation, outcome, variability and animal burden | [ARRIVE 2.0 sample-size guidance](https://arriveguidelines.org/arrive-guidelines/sample-size) and design-specific planning; the calculation should reflect dependence among repeated wells or measurements |

Table: Planning questions and resources for different study designs.

A sensitivity estimate uses participants with the target condition as its denominator; specificity uses participants without it. Total recruitment also depends on how these groups are obtained. A precision calculation for a single prevalence cannot by itself plan an entire diagnostic comparison.

These diagnostic, prediction and preclinical routes draw on the reporting and planning sources linked above: Bossuyt and colleagues (2015), Riley and colleagues (2020), and Percie du Sert and colleagues (2020).

Consider the speech question in the table: patients with Parkinson's disease aged 18 to 75 are interviewed in both OFF and ON medication states. The outcome is prediction of ON/OFF medication state. The study compares the predictive performance of semantic features, such as similarity between consecutive sentences, with that of syntactic features.

Prespecify ON/OFF timing, feature sets, prediction methods and a performance measure. Account for paired recordings and predictions, and keep each patient's recordings together when partitioning development and evaluation data to prevent information leakage. Counting participants alone is insufficient: outcome frequency, predictor parameters, overfitting and useful precision matter. Developing a model and evaluating it in new patients are different planning tasks. A blanket "ten events per variable" rule is not a substitute for a suitable calculation. Riley's general model-development guidance does not by itself solve this paired comparison; obtain methods matched to the intended analysis.

For paired, crossover and cluster designs, the relevant correlation and independent units matter. Candel and van Breukelen (2023) discuss efficient allocation, baseline adjustment and dependency for common continuous-outcome trial designs. These methods use the dependence structure to improve information when appropriate. [Their paper](https://doi.org/10.1016/j.ajcnut.2023.02.013) and the [advanced planning discussion](#further-planning-approaches) provide routes beyond the basic calculators.

Observational research may use the same outcome types as a trial, but an unadjusted two-group calculation does not account for confounding, covariate adjustment or causal identification. In a preclinical study, identify the allocated experimental unit before counting animals, cages, cultures or measurements.

Two further examples illustrate the need for specialized planning. In a sequential multiple assignment randomized trial (SMART), treatment can be randomized again at a later stage according to response; [Dey et al. (2026)](https://doi.org/10.1177/09622802261485814) develops calculations for skewed outcomes in this setting. Sequential treatment assignment does not itself mean that the total sample size adapts during recruitment. For a meta-analysis containing several related effect estimates from each study, [Vembye et al. (2024)](https://doi.org/10.1002/jrsm.1752) provides power guidance and the POMADE R package. Neither task is covered by the basic two-group calculators.

## Use guidance for its stated purpose {.advanced-heading}

[SPIRIT 2025 and CONSORT 2025](https://www.consort-spirit.org/) address trial protocol and results reporting. STROBE addresses observational reporting; STARD diagnostic-accuracy reporting; ARRIVE animal experiments; TRIPOD+AI prediction-model reporting. These resources help you document assumptions and decisions.

Your plan should follow the current funding program's requirements. [NIHR funding opportunities](https://www.nihr.ac.uk/funding-opportunities) is one starting point. The archived [NIHR HTA feasibility/pilot guidance](https://njl-admin.nihr.ac.uk/document/download/2023130) illustrates why a pilot's sample size can be justified by the precision needed for its feasibility outcomes.

For an unsupported design, take the question, assumptions, desired conclusion and analysis plan to a methodological collaborator before choosing a calculator. The [own-study guide](#own-study) and case template organize that information. The numerical examples use hypothetical assumptions for teaching. An actual study requires evidence appropriate to its population, outcome and design.

## Further planning approaches {#further-planning-approaches .advanced-heading}

The core calculations evaluate power at specified values. More specialized approaches account for additional uncertainty or a different research objective:

- Safeguard power uses uncertainty in a previous difference estimate when planning. It can imply a much larger sample when the evidence is weak [@perugini2014].
- Bayesian and hybrid approaches can average performance over a justified distribution of plausible parameter values. Assurance or expected power answers a different question from power at one fixed difference; the distribution and decision rule need justification [@kunzmann2021review; @pezeshk2003].
- Mixed-model simulation can represent clustered or repeated observations and the intended analysis, but needs credible dependency assumptions, convergence checks and [sensitivity analysis](#sensitivity-analysis) [@pargent2024].
- Multiple outcomes or treatment comparisons need a prespecified success rule and appropriate error control. Power for each comparison separately does not establish the probability that all required comparisons succeed [@fong2026].

These extensions require design-specific planning with a methodological collaborator. [Other study goals and designs](#study-designs) and the references below provide routes to design-specific methods.

A review of Bayesian randomized trials found that hybrid sample-size methods were common and fully Bayesian methods were rarely used [@marks2026]. A Bayesian analysis does not automatically imply a fully Bayesian sample-size calculation or an adaptive design. Bayesian trials can have a fixed sample size; adaptive designs also require prespecified rules and evaluation of their operating characteristics.


<div class="chapter-recap">

### Take-home points {.unnumbered}

- The design and planned analysis determine which sample size method applies.
- Paired measurements, clusters, and prediction models require appropriate methods.
- For prevalence estimation, the confidence level, anticipated percentage, and useful margin of error determine the simple independent-sample calculation.
- Reporting guidance helps document decisions. The calculation should match the study question and planned analysis.

</div>
