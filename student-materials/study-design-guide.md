# Study designs and testing strategies {#study-designs .advanced-heading}

::: {.learning-goals .advanced-outcomes}
After this chapter, you should be able to:

- Match a research question to a design, planning goal and suitable methodological resource.
- Identify design-specific requirements for dependence, restricted recruitment and testing strategies.
- Explain how paired and clustered observations affect sample size and analysis.
- Distinguish success on any primary outcome, success on all [co-primary outcomes](#co-primary-outcomes) and hierarchical testing.
- Recognize when interim analyses, stopping guidelines or sample-size re-estimation require additional planning.

:::

The study design and planning method should follow the research question, outcome, sampling structure and intended analysis. "Clinical," "retrospective," "diagnostic" and "within-subject" describe different aspects of a study and can apply together. A diagnostic study can be clinical and retrospective, and a preclinical experiment can have repeated measurements.

This chapter offers optional branches beyond the basic two-independent-group calculation. The [questionnaire](#design-questionnaire) helps identify the study design. The following sections consider dependence between observations, recruitment constraints and design-specific calculations. The [testing strategies](#multiple-outcomes-comparisons) then explain how the definition of study success and decisions during recruitment affect planning. The [resource table](#match-the-question-to-a-method-and-resource) helps you choose further guidance for your own question.

## Activity: Choosing a study design {#design-questionnaire .advanced-heading}

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

- The [unit of randomization](#unit-of-randomization){.no-glossary-tooltip}: what is assigned to a treatment, such as a participant, hospital, or body site.
- The [unit of measurement](#unit-of-measurement){.no-glossary-tooltip}: what an outcome is recorded for, such as a participant, lesion, or measurement occasion.
- The [unit of analysis](#unit-of-analysis){.no-glossary-tooltip}: the entity represented in the analysis, with dependence among entities accounted for by the model.

These units may coincide, as in a trial where participants are individually randomized and each contributes one outcome. They can also differ. An analysis may use individual measurements while accounting for their grouping within hospitals or participants.

Figure \@ref(fig:allocation-units) compares three allocation structures. The group boundaries show which measurements share a hospital or participant, and where the treatment comparison is made.

```{r allocation-units, echo=FALSE, fig.width=8, fig.height=6.2, fig.cap="Individual, cluster and within-person randomization. Treatments A and B are assigned to individual participants, whole hospitals, or sites within participants. The analysis and sample size calculation should reflect this allocation structure and dependence among measurements. The symbols are schematic; actual sample sizes require a design-specific calculation.", fig.alt="Three designs. In individual randomization, separate participants receive A or B and contribute independent outcomes. In cluster randomization, all illustrated participants in hospital 1 receive A and those in hospital 2 receive B; analysis accounts for dependence within hospitals. In within-person randomization, each participant has one site receiving A and another receiving B; the analysis compares outcomes within participant pairs."}
draw_allocation_units()
```

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

## What if the disease is rare? {#rare-diseases .advanced-heading}

For a rare disease, the number of eligible patients may limit recruitment. Your plan should document how many patients could realistically participate, over what period and across which centers, and what that sample could establish.

This is the same feasibility problem as the plan for the chronic pain trial, with a more restrictive recruitment ceiling. The aim is to obtain useful, valid information within the recruitment limit.

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

## Noninferiority and equivalence trials {#noninferiority-equivalence .advanced-heading}

The earlier treatment comparisons asked whether a novel treatment improves outcomes. A new treatment may also offer easier administration or fewer adverse effects. You may then want to establish whether it retains sufficient efficacy to be an acceptable alternative to an established treatment. This can motivate a noninferiority trial. An equivalence trial assesses whether the treatments differ only within prespecified, clinically acceptable limits [@schumi2011lookingglass].

The margin defines the boundary used to assess the treatment difference. For noninferiority, it represents the largest acceptable loss of efficacy. Equivalence uses lower and upper boundaries. These margins concern the population-level difference between treatment groups. Their justification should reflect the outcome, follow-up period, clinical consequences, and evidence about the established treatment's benefit. The 20-percentage-point clinical threshold in the chronic pain trial describes a worthwhile improvement; an acceptable loss requires a separate justification [@fda2016noninferiority].

For an outcome such as pain relief, where higher percentages are better and the difference is novel minus standard treatment, noninferiority requires the lower confidence limit to lie above the prespecified lower boundary. Equivalence requires the entire confidence interval to lie within the two equivalence boundaries. The confidence level should match the planned test and Type I error probability. A nonsignificant superiority result alone cannot establish either conclusion [@piaggio2012consortni].

Sample-size planning should specify both the margin and the assumed true between-group difference at which power is evaluated. The calculation also depends on outcome variability or event probabilities, allocation, Type I error probability, and target power. With other assumptions fixed, narrower margins generally require larger samples. The margin should be justified before calculating the sample size. Careful trial conduct is particularly important because problems that make the groups appear more similar can favor a misleading noninferiority conclusion [@fda2016noninferiority].

*Further resource: Katalin Tam&aacute;si's tutorial and interactive apps on noninferiority and equivalence trials [link to be added].*

## Multiple outcomes and comparisons {#multiple-outcomes-comparisons .advanced-heading}

The chronic pain calculation assumes one primary comparison at one final assessment. Suppose the study also measures sleep quality and physical function. Before calculating a sample size, your plan should specify which findings would support its main conclusion. [Multiplicity](#multiplicity){.no-glossary-tooltip} concerns the opportunities to make false-positive claims across the planned tests. The success rule determines both error control and the relevant definition of power [@iche91998; @fong2026].

| Intended conclusion | Testing strategy | What sample size planning should address |
|:--|:--|:--|
| Benefit on at least one primary outcome is sufficient | A multiple-testing procedure controls the probability of any false-positive claim in the specified family of tests | Outcome-specific assumptions, the procedure and power for the intended claims |
| Benefit on every co-primary outcome is required | Each required test must succeed | Joint power: the probability that all tests succeed, including dependence between outcomes |
| Claims follow a prespecified order, such as pain relief followed by sleep improvement | In a simple fixed sequence, confirmatory testing proceeds only after the preceding test succeeds | Power for reaching and passing the relevant tests; justified ordering of primary and key secondary outcomes |
| One composite outcome combines several events | One prespecified endpoint, such as the first occurrence of hospitalization or death, is analyzed | Component frequencies, their relationship and the effect on the combined endpoint |

Table: Success rules and their implications for planning several outcomes. Further treatment groups, doses, assessment times and subgroup claims can also create multiple testing opportunities.

For an illustration with two independent co-primary tests, each with 90% power, the probability that both succeed is $0.90 \times 0.90 = 0.81$, or 81%. Correlated outcomes require a joint calculation using plausible dependence assumptions. When every co-primary test must succeed to support one joint claim, splitting the Type I error probability between them is not automatically required. Separate claims about individual outcomes need their own error-control strategy [@fdamultiple2022].

The [FDA multiple-endpoints guidance](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/multiple-endpoints-clinical-trials) describes these distinctions and methods such as Bonferroni, Holm, fixed-sequence testing and gatekeeping. Gatekeeping specifies which earlier tests or families must succeed before later claims can be evaluated. The procedure should be chosen with a statistician before fixing the sample size [@fdamultiple2022].

## Interim analyses and stopping guidelines {#interim-analyses-stopping .advanced-heading}

An [interim analysis](#interim-analysis){.no-glossary-tooltip} examines accumulating results before the planned final analysis. A trial may have prespecified opportunities to stop for convincing benefit, [futility](#futility){.no-glossary-tooltip} (a low prospect of demonstrating the planned benefit), or safety concerns. Repeated efficacy tests at the usual 5% threshold can increase the overall false-positive probability. A [group-sequential design](#group-sequential-design){.no-glossary-tooltip} accounts for the planned analyses and stopping opportunities [@iche91998].

For the chronic pain trial, an interim efficacy analysis after some participants complete four-week follow-up would change the design used for the original calculation. The plan should identify when analyses occur, which results could trigger a recommendation to stop, and who reviews the unblinded results. Timing may use an information fraction, meaning the share of the planned statistical information available. For time-to-event outcomes, this often depends on observed events. A statistician can specify suitable boundaries, for example using an alpha-spending approach that allocates the overall Type I error probability across analyses [@iche91998; @fdaadaptive2019].

Recruitment planning should distinguish the maximum sample size from the expected sample size under different population scenarios. Early stopping may reduce expected recruitment; the maximum required sample can exceed that of a comparable design with only a final analysis. Safety monitoring also requires clinical judgment, and stopping guidelines should support the agreed review process. An independent data monitoring committee may review unblinded evidence while protecting trial conduct [@iche91998].

The [pilot progression criteria](#pilot-feasibility) address whether a future study is feasible. Interim efficacy and futility guidelines address decisions within the ongoing trial. The [reproducibility record](#complex-design-record) lists what should be documented for those decisions.

## Sample-size re-estimation {#sample-size-re-estimation .advanced-heading}

A trial can prespecify an opportunity to revise its sample size using accumulating information. For example, uncertainty about the SD in the rehabilitation case could motivate a planned reassessment of outcome variability. The method depends on which information is used [@fdaadaptive2019]:

- Blinded re-estimation uses information without treatment-group comparisons, such as a pooled estimate of variability. Its effect on the false-positive probability depends on the procedure and design.
- Unblinded re-estimation can use an interim treatment difference. The final testing and estimation procedures must account for this data-dependent adaptation.

Your plan should specify the reason for re-estimation, its timing, the calculation and decision rule, sample-size limits and the final analysis. A suitable evaluation considers power, the probability of false-positive conclusions and the sample sizes produced under plausible scenarios. A design-specific method and statistical advice are needed before introducing this option [@iche91998; @fdaadaptive2019].

Re-estimation is one form of [adaptive design](#adaptive-design){.no-glossary-tooltip}, in which prespecified changes depend on accumulating trial data. Other possibilities include selecting treatment arms or a target population. The [FDA adaptive-design guidance](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/adaptive-design-clinical-trials-drugs-and-biologics-guidance-industry) provides further guidance. The [simulation chapter](#simulating-decision-rules) explains how evaluating such a design extends the generate-analyze-repeat workflow.

## Planning under uncertainty {#further-planning-approaches .advanced-heading}

The core calculations evaluate power at specified values. Differences observed in previous data, target differences and clinical thresholds can coincide or follow different orders; their evidence and purpose determine the choices. The [ST01 example](#st01-expectations) shows why expectations and clinical judgments should be assessed separately. More specialized approaches account for additional uncertainty or a different research objective:

- Safeguard power uses uncertainty in a previous difference estimate when planning. It can imply a much larger sample when the evidence is weak [@perugini2014].
- Bayesian and hybrid approaches can average performance over a justified distribution of plausible parameter values. Assurance or expected power answers a different question from power at one fixed difference; the distribution and decision rule need justification [@kunzmann2021review; @pezeshk2003].
- Mixed-model simulation can represent clustered or repeated observations and the intended analysis, but needs credible dependency assumptions, convergence checks and [sensitivity analysis](#sensitivity-analysis) [@pargent2024].

These extensions require design-specific planning with a methodological collaborator. The [resource table](#match-the-question-to-a-method-and-resource) provides starting points for other analyses.

A review of Bayesian randomized trials found that hybrid sample-size methods were common and fully Bayesian methods were rarely used [@marks2026]. A Bayesian trial can use a fixed sample size or prespecified adaptations. Its planning method should reflect the chosen decision rule; the [adaptive-design discussion](#sample-size-re-estimation) explains the additional decisions to document.

## Match the question to a method and resource {.advanced-heading}

| Example question | Planning focus | Route |
|:--|:--|:--|
| Do two individually allocated rehabilitation programs differ on a continuous improvement score? | Difference, common SD, analysis, Type I error probability/power or interval width | [Rehabilitation case](#rehabilitation); the core equal-independent-group [lab](https://katatam.github.io/sample-size-calculation/study/?activity=rehabilitation) applies under its assumptions |
| Does probiotic supplementation reduce gestational diabetes in pregnant women with overweight or obesity? | Two event probabilities, allocation or observational exposure, diagnostic criteria, assessment time and effect scale | [Prevention trial](#adherence); the binary [core lab](https://katatam.github.io/sample-size-calculation/study/?activity=adherence) applies to an individually randomized, independent-group comparison under its assumptions |
| What proportion of eligible patients has a symptom? | Representative sample, confidence level and useful absolute margin of error | [Single-proportion precision activity](#prevalence); a simple independent sample |
| Can a pathway recruit and retain enough patients for a future trial? | Feasibility outcomes, progression criteria and their precision | [Pilot case](#pilot-feasibility); [CONSORT pilot extension](https://www.bmj.com/content/355/bmj.i5239) for randomized pilots |
| How accurately does a screening test identify disease? | Precision of sensitivity/specificity and enough reference-positive/reference-negative participants | [STARD 2015](https://www.bmj.com/content/351/bmj.h5527) for reporting; obtain diagnostic-accuracy planning methods |
| Do speech measurements differ between the same Parkinson patient's OFF and ON medication states? | Within-person differences, repeated-measures analysis and correlation | [Units and dependence](#units-of-analysis); both recordings belong to the same participant. For several visits, mixed-model simulation can represent the planned analysis [@pargent2024] |
| Does an intervention allocated to wards improve outcomes? | Number/size of clusters, within-cluster correlation and analysis | [Cluster planning](#treatment-assigned-to-groups); see [Hayes and Bennett (1999)](https://doi.org/10.1093/ije/28.2.319) |
| Is a treatment sufficiently similar to an established treatment, or not worse by more than an acceptable margin? | Equivalence or noninferiority hypotheses, justified margin, analysis and error control | [Noninferiority and equivalence trials](#noninferiority-equivalence) explains the margins and planning assumptions. See Julious (2023) in the tutorial references |
| What can a trial establish when a rare disease limits recruitment? | Recruitment ceiling, meaningful outcomes, valid comparison and attainable information | [Rare-disease planning](#rare-diseases); the sample size should follow the study objectives, recruitment ceiling and design-specific guidance |
| Is a risk factor associated with an outcome in a cohort or case-control study? | Association scale, event frequency, exposure frequency, confounder adjustment and missingness | Obtain analysis-specific regression/association planning; [STROBE](https://www.strobe-statement.org/) supports reporting |
| Do semantic speech features predict Parkinson's medication state more accurately than syntactic features? | Paired ON/OFF recordings, paired comparison of model performance, number of patients and predictor parameters, and evaluation without patient overlap | [Riley et al. (2020)](https://www.bmj.com/content/368/bmj.m441) gives general model-development planning guidance; the paired comparison needs additional methods. [TRIPOD+AI](https://www.tripod-statement.org/) supports reporting |
| How informative is an existing retrospective dataset? | Available analyzable n, selection, missingness, intended model and achievable precision | Assess fixed resources at independently justified scenarios; avoid observed-effect post-hoc power |
| How many units does an animal or laboratory experiment need? | Experimental unit, replication, allocation, outcome, variability and animal burden | [ARRIVE 2.0 sample-size guidance](https://arriveguidelines.org/arrive-guidelines/sample-size) and design-specific planning; the calculation should reflect dependence among repeated wells or measurements |
| Does treatment delay an event such as relapse? | Required events, effect over time, recruitment duration, follow-up and censoring | Time-to-event methods in @julious2023; participant recruitment depends on how many events can be observed |
| Does one treatment's effect depend on another treatment or on a patient characteristic? | The interaction to estimate, cell or subgroup sizes and planned model | Factorial-design examples in [Superpower](https://aaroncaldwell.us/SuperpowerBook/) [@superpowerbook2022]; subgroup and interaction principles in ICH E9, Section 5.7 [@iche91998] |
| Which outcomes or treatment comparisons must succeed? | Success rule, testing family, ordering and dependence | [Multiple outcomes and comparisons](#multiple-outcomes-comparisons) |
| Can the trial stop early or revise its sample size? | Analysis timing, stopping boundaries, adaptation rules and final analysis | [Interim analyses](#interim-analyses-stopping), [re-estimation](#sample-size-re-estimation) and [simulation of decision rules](#simulating-decision-rules) |

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

<div class="chapter-recap">

### Take-home points {.unnumbered}

- The research goal, allocation structure and planned analysis determine which sample size method applies.
- Restricted recruitment in rare diseases calls for a justified objective, efficient design and appropriate specialist guidance.
- Paired and clustered observations require assumptions about dependence and the independent units available.
- With several outcomes or comparisons, the success rule determines the relevant power and error control.
- Interim analyses and sample-size adaptations require prespecified decisions and design-specific evaluation.
- The resource table and reproducibility checklist help you prepare a plan for discussion with a statistician.

</div>
