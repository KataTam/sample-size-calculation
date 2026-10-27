# Study designs and planning methods {#study-designs .advanced-heading}

::: {.learning-goals .advanced-outcomes}
Learning outcomes. After this section, you should be able to:

- Use the study-design questionnaire to identify suitable design families and unresolved decisions.
- Choose a planning method from the research question, outcome and dependency between observations.
- Plan an independent prevalence sample for a stated confidence level and margin of error.
- Recognize designs that need methods beyond the two-independent-group examples.
- Distinguish units of randomization, measurement, and analysis, and explain how dependence affects sample size planning.
:::

The study design and planning method should follow the research question, outcome, sampling structure and intended analysis. "Clinical," "retrospective," "diagnostic" and "within-subject" describe different aspects of a study and can apply together. A diagnostic study can be clinical and retrospective, and a preclinical experiment can have repeated measurements.

The questionnaire below provides a starting point. The rest of this chapter explains the design dimensions behind its suggestions, works through prevalence estimation, and links to methods for other designs.

## Activity: Which study design fits your question? {#design-questionnaire .advanced-heading}

[Open the study-design questionnaire with this chapter](https://katatam.github.io/sample-size-calculation/study/?activity=design_questionnaire).

Your answers cover the study aim, available data, outcome and relationships between observations. Follow-up questions address intervention allocation, treatment comparisons, observational sampling, diagnostic reference standards or prediction models as appropriate. The questionnaire app suggests a design family, explains why it fits, and identifies decisions still needed before sample size planning. Existing data can support different designs depending on how participants were selected and when measurements were made.

Several designs may be reasonable for the same question. The suggestion should support discussion of feasibility, ethics and the intended analysis. Links lead to a matching calculation activity when its assumptions fit, or to design-specific resources. The questionnaire uses the distinctions explained in this chapter; it does not rank designs by a score.

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

These units may coincide, as in a trial where participants are individually randomized and each contributes one outcome. They can also differ. An analysis may use individual measurements while accounting for their grouping within hospitals or participants; it does not always require reducing each group to a single observation.

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

## Match the question to a method and resource {.advanced-heading}

| Example question | Planning focus | Route |
|:--|:--|:--|
| Do two individually allocated rehabilitation programs differ on a continuous improvement score? | Difference, common SD, analysis, Type I error probability/power or interval width | [Rehabilitation case](#rehabilitation); the core equal-independent-group [lab](https://katatam.github.io/sample-size-calculation/study/?activity=rehabilitation) applies under its assumptions |
| Does probiotic supplementation reduce gestational diabetes in pregnant women with overweight or obesity? | Two event probabilities, allocation or observational exposure, diagnostic criteria, assessment time and effect scale | [Prevention trial](#adherence); the binary [core lab](https://katatam.github.io/sample-size-calculation/study/?activity=adherence) applies to an individually randomized, independent-group comparison under its assumptions |
| What proportion of eligible patients has a symptom? | Representative sample, confidence level and useful absolute margin of error | [Single-proportion precision activity](#prevalence); a simple independent sample |
| Can a pathway recruit and retain enough patients for a future trial? | Feasibility outcomes, progression criteria and their precision | [Pilot case](#pilot-feasibility); [CONSORT pilot extension](https://www.bmj.com/content/355/bmj.i5239) for randomized pilots |
| How accurately does a screening test identify disease? | Precision of sensitivity/specificity and enough reference-positive/reference-negative participants | [STARD 2015](https://www.bmj.com/content/351/bmj.h5527) for reporting; obtain diagnostic-accuracy planning methods |
| Do speech measurements differ between the same Parkinson patient's OFF and ON medication states? | Within-person differences, repeated-measures analysis and correlation | Use a paired/repeated-measures method for this change question; two recordings do not constitute two independent patients |
| Does an intervention allocated to wards improve outcomes? | Number/size of clusters, within-cluster correlation and analysis | Use cluster planning; see [Hayes and Bennett (1999)](https://doi.org/10.1093/ije/28.2.319) |
| Is a treatment sufficiently similar to an established treatment, or not worse by more than an acceptable margin? | Equivalence or noninferiority hypotheses, justified margin, analysis and error control | The hypotheses should assess the prespecified equivalence or noninferiority margin. See Julious (2023) in the tutorial references |
| What can a trial establish when a rare disease limits recruitment? | Recruitment ceiling, meaningful outcomes, valid comparison and attainable information | [Rare-disease planning](#rare-diseases); the sample size should follow the study objectives, recruitment ceiling and design-specific guidance |
| Is a risk factor associated with an outcome in a cohort or case-control study? | Association scale, event frequency, exposure frequency, confounder adjustment and missingness | Obtain analysis-specific regression/association planning; [STROBE](https://www.strobe-statement.org/) supports reporting |
| Do semantic speech features predict Parkinson's medication state more accurately than syntactic features? | Paired ON/OFF recordings, paired comparison of model performance, number of patients and predictor parameters, and evaluation without patient overlap | [Riley et al. (2020)](https://www.bmj.com/content/368/bmj.m441) gives general model-development planning guidance; the paired comparison needs additional methods. [TRIPOD+AI](https://www.tripod-statement.org/) supports reporting |
| How informative is an existing retrospective dataset? | Available analyzable n, selection, missingness, intended model and achievable precision | Assess fixed resources at independently justified scenarios; avoid observed-effect post-hoc power |
| How many units does an animal or laboratory experiment need? | Experimental unit, replication, allocation, outcome, variability and animal burden | [ARRIVE 2.0 sample-size guidance](https://arriveguidelines.org/arrive-guidelines/sample-size) and design-specific planning; repeated wells or measurements are not automatically independent units |

Table: Planning questions and resources for different study designs.

A sensitivity estimate uses participants with the target condition as its denominator; specificity uses participants without it. Total recruitment also depends on how these groups are obtained. A precision calculation for a single prevalence cannot by itself plan an entire diagnostic comparison.

These diagnostic, prediction and preclinical routes draw on the reporting and planning sources linked above: Bossuyt and colleagues (2015), Riley and colleagues (2020), and Percie du Sert and colleagues (2020).

Consider the speech question in the table: patients with Parkinson's disease aged 18 to 75 are interviewed in both OFF and ON medication states. The outcome is prediction of ON/OFF medication state. The study compares the predictive performance of semantic features, such as similarity between consecutive sentences, with that of syntactic features.

Prespecify ON/OFF timing, feature sets, prediction methods and a performance measure. Account for paired recordings and predictions, and keep each patient's recordings together when partitioning development and evaluation data to prevent information leakage. Counting participants alone is insufficient: outcome frequency, predictor parameters, overfitting and useful precision matter. Developing a model and evaluating it in new patients are different planning tasks. A blanket "ten events per variable" rule is not a substitute for a suitable calculation. Riley's general model-development guidance does not by itself solve this paired comparison; obtain methods matched to the intended analysis.

For paired, crossover and cluster designs, the relevant correlation and independent units matter. Candel and van Breukelen (2023) discuss efficient allocation, baseline adjustment and dependency for common continuous-outcome trial designs. These methods can improve information when appropriate, but do not make every extra visit an independent participant. [Their paper](https://doi.org/10.1016/j.ajcnut.2023.02.013) and the [advanced planning discussion](#further-planning-approaches) provide routes beyond the basic calculators.

Observational research may use the same outcome types as a trial, but an unadjusted two-group calculation does not account for confounding, covariate adjustment or causal identification. In a preclinical study, identify the allocated experimental unit before counting animals, cages, cultures or measurements.

Two further examples illustrate the need for specialized planning. In a sequential multiple assignment randomized trial (SMART), treatment can be randomized again at a later stage according to response; [Dey et al. (2026)](https://doi.org/10.1177/09622802261485814) develops calculations for skewed outcomes in this setting. Sequential treatment assignment does not itself mean that the total sample size adapts during recruitment. For a meta-analysis containing several related effect estimates from each study, [Vembye et al. (2024)](https://doi.org/10.1002/jrsm.1752) provides power guidance and the POMADE R package. Neither task is covered by the basic two-group calculators.

## Use guidance for its stated purpose {.advanced-heading}

[SPIRIT 2025 and CONSORT 2025](https://www.consort-spirit.org/) address trial protocol and results reporting. STROBE addresses observational reporting; STARD diagnostic-accuracy reporting; ARRIVE animal experiments; TRIPOD+AI prediction-model reporting. These resources help you document assumptions and decisions. They are not interchangeable sample-size calculators or universal minimum-n rules.

Your plan should follow the current funding program's requirements. [NIHR funding opportunities](https://www.nihr.ac.uk/funding-opportunities) is one starting point. The archived [NIHR HTA feasibility/pilot guidance](https://njl-admin.nihr.ac.uk/document/download/2023130) illustrates why a pilot's sample size can be justified by the precision needed for its feasibility outcomes.

For an unsupported design, take the question, assumptions, desired conclusion and analysis plan to a methodological collaborator before choosing a calculator. The [own-study guide](#own-study) and case template organize that information. The numerical examples use hypothetical assumptions for teaching. An actual study requires evidence appropriate to its population, outcome and design.

## Further planning approaches {#further-planning-approaches .advanced-heading}

The core calculations evaluate power at specified values. More specialized approaches account for additional uncertainty or a different research objective:

- Safeguard power uses uncertainty in a previous difference estimate when planning. It can imply a much larger sample when the evidence is weak; it does not establish clinical importance [@perugini2014].
- Bayesian and hybrid approaches can average performance over a justified distribution of plausible parameter values. Assurance or expected power answers a different question from power at one fixed difference; the distribution and decision rule need justification [@kunzmann2021review; @pezeshk2003].
- Mixed-model simulation can represent clustered or repeated observations and the intended analysis, but needs credible dependency assumptions, convergence checks and [sensitivity analysis](#sensitivity-analysis) [@pargent2024].
- Multiple outcomes or treatment comparisons need a prespecified success rule and appropriate error control. Power for each comparison separately does not establish the probability that all required comparisons succeed [@fong2026].

These extensions require design-specific planning with a methodological collaborator. [Study designs and planning methods](#study-designs) and the references below provide routes to design-specific methods.

A review of Bayesian randomized trials found that hybrid sample-size methods were common and fully Bayesian methods were rarely used [@marks2026]. A Bayesian analysis does not automatically imply a fully Bayesian sample-size calculation or an adaptive design. Bayesian trials can have a fixed sample size; adaptive designs also require prespecified rules and evaluation of their operating characteristics.


<div class="chapter-recap">

### Take-home points {.unnumbered}

- The design and planned analysis determine which sample size method applies.
- Paired measurements, clusters, and prediction models require appropriate methods.
- For prevalence estimation, the confidence level, anticipated percentage, and useful margin of error determine the simple independent-sample calculation.
- Reporting guidance helps document decisions. The calculation should match the study question and planned analysis.

</div>
