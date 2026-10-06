# Where does my study fit? {#study-designs}

::: {.learning-goals}
Learning outcomes. After this section, you should be able to:

- Choose a planning method from the research question, outcome and dependency between observations.
- Recognize designs that need methods beyond the two-independent-group examples.
:::

Choose a method from the research question, outcome, sampling structure and intended analysis. "Clinical," "retrospective," "diagnostic" and "within-subject" describe different dimensions; they are not mutually exclusive study categories. A diagnostic study can be clinical and retrospective, and a preclinical experiment can have repeated measurements.

## Describe these dimensions first

| Dimension | Examples | Why it matters for planning |
|:--|:--|:--|
| Setting | Preclinical laboratory, clinical care, population health | Identifies the target population, experimental unit and practical/ethical constraints |
| Assignment | Intervention allocated by researchers, observational exposure | Determines what comparisons and causal conclusions the design can support |
| Timing/data availability | Prospective collection, existing retrospective records | Determines whether recruitment can be chosen or the available sample must be assessed |
| Dependency | Independent people, paired measurements, repeated visits, practices/wards | Determines how much independent information the observations supply |
| Aim | Describe a prevalence, compare effects, assess diagnostic accuracy, study a risk factor, predict individual outcomes | Determines the target quantity and whether power, precision or predictive performance drives planning |
| Outcome/analysis | Continuous, binary, time-to-event, counts; adjusted model or simple comparison | Determines the required distributional and modeling assumptions |

Table: Design dimensions that determine the appropriate planning method.

## Match the question to a method and resource

| Example question | Planning focus | Route |
|:--|:--|:--|
| Do two individually allocated rehabilitation programs differ on a continuous improvement score? | Difference, common SD, analysis, Type I error rate/power or interval width | [Rehabilitation case](#rehabilitation); the core equal-independent-group lab applies under its assumptions |
| Does probiotic supplementation reduce gestational diabetes in pregnant women with overweight or obesity? | Two event rates, allocation or observational exposure, diagnostic criteria, assessment time and effect scale | [Student probiotics project](#student-probiotics); the binary core lab applies to an individually randomized, independent-group comparison under its assumptions |
| What proportion of eligible patients has a symptom? | Representative sample, confidence level and useful absolute margin of error | [Single-proportion precision activity](#prevalence); a simple independent sample |
| Can a pathway recruit and retain enough patients for a future trial? | Feasibility outcomes, progression criteria and their precision | [Pilot case](#pilot-feasibility); [CONSORT pilot extension](https://www.bmj.com/content/355/bmj.i5239) for randomized pilots |
| How accurately does a screening test identify disease? | Precision of sensitivity/specificity and enough reference-positive/reference-negative participants | [STARD 2015](https://www.bmj.com/content/351/bmj.h5527) for reporting; obtain diagnostic-accuracy planning methods |
| Does the same patient's outcome change after an intervention? | Within-person differences or repeated-measures analysis and correlation | Use a paired/repeated-measures planning method; the independent-group formula is inappropriate |
| Does an intervention allocated to wards improve outcomes? | Number/size of clusters, within-cluster correlation and analysis | Use cluster planning; see [Hayes and Bennett (1999)](https://doi.org/10.1093/ije/28.2.319) |
| Is a risk factor associated with an outcome in a cohort or case-control study? | Association scale, event frequency, exposure frequency, confounder adjustment and missingness | Obtain analysis-specific regression/association planning; [STROBE](https://www.strobe-statement.org/) supports reporting |
| Do semantic speech features predict Parkinson's medication state more accurately than syntactic features? | Paired ON/OFF recordings, paired comparison of model performance, number of patients and predictor parameters, and evaluation without patient overlap | [Student speech project](#student-parkinson-speech); [Riley et al. (2020)](https://www.bmj.com/content/368/bmj.m441) gives general model-development planning guidance, but this comparison also needs methods for its repeated measurements; [TRIPOD+AI](https://www.tripod-statement.org/) supports reporting |
| How informative is an existing retrospective dataset? | Available analyzable n, selection, missingness, intended model and achievable precision | Assess fixed resources at independently justified scenarios; avoid observed-effect post-hoc power |
| How many units does an animal or laboratory experiment need? | Experimental unit, replication, allocation, outcome, variability and animal burden | [ARRIVE 2.0 sample-size guidance](https://arriveguidelines.org/arrive-guidelines/sample-size) and design-specific planning; repeated wells or measurements are not automatically independent units |

Table: Planning questions and resources for different study designs.

A sensitivity estimate uses participants with the target condition as its denominator; specificity uses participants without it. Total recruitment also depends on how these groups are obtained. A precision calculation for a single prevalence cannot by itself plan an entire diagnostic comparison.

These diagnostic, prediction and preclinical routes draw on the reporting and planning sources linked above: Bossuyt and colleagues (2015), Riley and colleagues (2020), and Percie du Sert and colleagues (2020).

For prediction, counting participants alone is insufficient: the number of events, predictor parameters and desired performance matter. Planning model development and planning its external evaluation are different tasks. A blanket "ten events per variable" rule is not a substitute for an appropriate calculation.

Observational research may use the same outcome types as a trial, but an unadjusted two-group calculation does not account for confounding, covariate adjustment or causal identification. In a preclinical study, identify the allocated experimental unit before counting animals, cages, cultures or measurements.

## Use guidance for its stated purpose

[SPIRIT 2025 and CONSORT 2025](https://www.consort-spirit.org/) address trial protocol and results reporting. STROBE addresses observational reporting; STARD diagnostic-accuracy reporting; ARRIVE animal experiments; TRIPOD+AI prediction-model reporting. These resources help you document assumptions and decisions. They are not interchangeable sample-size calculators or universal minimum-n rules.

If funding guidance applies, read the current program/call rather than assuming an old example is a current requirement. [NIHR funding opportunities](https://www.nihr.ac.uk/funding-opportunities) is one starting point. The archived [NIHR HTA feasibility/pilot guidance](https://njl-admin.nihr.ac.uk/document/download/2023130) illustrates why a pilot's numbers can be justified by precision for feasibility parameters rather than efficacy-test power.

For an unsupported design, take the question, assumptions, desired conclusion and analysis plan to a methodological collaborator before choosing a calculator. The [own-study guide](#own-study) and case template organize that information. All numerical cases in this teaching resource are hypothetical; their inputs are not clinical recommendations.
