# Where does my study fit? {#study-designs .advanced-heading}

::: {.learning-goals .advanced-outcomes}
Learning outcomes. After this section, you should be able to:

- Use the study-design questionnaire to identify suitable design families and unresolved decisions.
- Choose a planning method from the research question, outcome and dependency between observations.
- Recognize designs that need methods beyond the two-independent-group examples.
:::

The study design and planning method should follow the research question, outcome, sampling structure and intended analysis. "Clinical," "retrospective," "diagnostic" and "within-subject" describe different aspects of a study and can apply together. A diagnostic study can be clinical and retrospective, and a preclinical experiment can have repeated measurements.

The questionnaire below provides a starting point. The rest of this chapter explains the design dimensions and planning resources behind its suggestions.

## Activity: Which study design fits your question? {#design-questionnaire .advanced-heading}

[Open the study-design questionnaire with this chapter](https://katatam.github.io/sample-size-calculation/study/?activity=design_questionnaire).

Your answers cover the study aim, available data, outcome and relationships between observations. Follow-up questions address intervention allocation, treatment comparisons, observational sampling, diagnostic reference standards or prediction models as appropriate. The tool suggests a design family, explains why it fits, and identifies decisions still needed before sample size planning. Existing data can support different designs depending on how participants were selected and when measurements were made.

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

<div class="chapter-recap">

### Take-home points {.unnumbered}

- The design and planned analysis determine which sample size method applies.
- Paired measurements, clusters, and prediction models require appropriate methods.
- Reporting guidance helps document decisions. The calculation should match the study question and planned analysis.

### Check your understanding {.unnumbered}

1. Do 100 measurements from 50 patients provide the same information as 100 independent patients?

<details class="model-answer">
<summary>Model answer</summary>

Not generally. Measurements within a patient are related, and the analysis and planning method should account for that relationship.

</details>

2. Is following CONSORT sufficient to determine a trial's sample size?

<details class="model-answer">
<summary>Model answer</summary>

No. CONSORT identifies information to report. The calculation still needs a suitable method, a planned analysis, and justified numerical assumptions.

</details>

</div>
