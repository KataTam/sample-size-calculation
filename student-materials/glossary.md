# Glossary {#glossary .unnumbered .reference-heading}

These definitions support both routes and link to the explanations and examples in the tutorial. Advanced terms are identified individually.

## Research question and study plan {.core-heading .unnumbered}

<span id="pico">PICO</span>
: Population, Intervention, Comparator, and Outcome. These four elements help define a treatment-comparison question [@richardson1995]. The outcome should include the assessment time. In the chronic pain trial, they are patients with chronic pain, the novel treatment, standard treatment, and pain relief at four weeks.

<span id="primary-outcome">Primary outcome</span>
: The main outcome chosen to answer the study's principal question. In the basic examples, it guides the sample size calculation. Its definition should specify what is measured, how it is measured, and when it is assessed. The chronic pain trial uses reported pain relief at four weeks.

<span id="binary-outcome">Binary outcome</span>
: An outcome with two categories, such as pain relief: yes or no. Each group's outcome can be summarized as a count and a percentage, such as 6 of 10 patients (60%) reporting relief.

<span id="pilot-study">Pilot study</span>
: A preliminary study used to assess whether and how a larger study can be carried out. It can inform recruitment, procedures, and outcome collection. Treatment differences estimated from a small pilot are uncertain; the [pilot and feasibility discussion](#pilot-feasibility) explains appropriate planning goals [@eldridge2016].

<span id="study-protocol">Study protocol</span>
: The written plan for a study, prepared before it starts. It describes the question, design, participants, interventions, outcomes, sample size justification and analysis. Relevant reporting guidance helps identify what should be documented [@spiritconsort2025].

## Probability, percentages and rates {.core-heading .unnumbered}

<span id="event-probability"></span>A probability describes how likely an event is under stated assumptions. It lies between zero and one and can be expressed as a percentage: a probability of 0.60 is 60%. An observed proportion describes the fraction of observations with an outcome, such as 6 of 10 patients reporting relief; the observed percentage is 60%. That percentage estimates the population probability but need not equal it.

In this tutorial, Type I and Type II error probabilities and power describe how the planned test behaves under specified population assumptions. Simulation estimates these probabilities using the percentage of repeated studies with each result. A time-based rate has a different denominator, such as new cases per 1,000 person-years or patients recruited per month. The binary-outcome calculators use the probability of an event by a specified follow-up time.

## Population, sample and planning values {.core-heading .unnumbered}

The [chronic pain trial](#clinical-question) distinguishes the pilot estimates from the assumptions used for planning.

<span id="population-parameter">Population parameter</span>
: A population parameter is a feature of the population you want to learn about, such as its mean, proportion, or treatment difference.

<span id="sample-estimate">Sample estimate</span>
: A sample estimate is calculated from the observations you obtained. In the pain pilot, 7/10 is a sample proportion, expressed as 70%. The treatment probability of 60% used in the sample size calculation is a planning assumption whose justification should draw on evidence and sensitivity analysis. A proportion such as 7/10 can also be written as 0.70 or expressed as a percentage, 70%.

<span id="expected-difference">Difference observed in previous data</span>
: The between-group difference calculated from an earlier sample, such as a pilot. It provides evidence for planning, with uncertainty. In the chronic pain pilot, 70% minus 30% gives an observed difference of 40 percentage points.

<span id="target-difference">Target difference</span>
: The [target difference](#between-group-differences){.no-glossary-tooltip} is the between-group difference used in the sample size calculation, at which you calculate [power](#statistical-power).

<span id="clinical-threshold">Clinical threshold</span>
: The smallest between-group benefit judged worthwhile, considering treatment burdens, risks and alternatives. It may coincide with the target difference or difference observed in earlier data; these quantities have no fixed numerical order. The [planning example](#what-do-we-expect-what-will-we-plan-for-and-what-matters-clinically) explains their roles [@cook2018delta2].

## Between-group differences and individual benefit {#between-group-differences .core-heading .unnumbered}

A between-group difference compares population percentages or means under two treatments. The observed difference, target difference and clinical threshold in this tutorial all concern such comparisons.

Relief probabilities of 60% and 30% imply 30 additional patients achieving relief per 100 treated with the novel treatment. They do not describe 30% more relief for each individual. Likewise, a 3-point difference between group means describes an average contrast. In a parallel-group trial, each patient receives one treatment, so their outcome under the other treatment is unobserved.

A threshold for improvement within a patient can define who counts as achieving relief. A separate judgment determines what between-group difference in that percentage is worthwhile. A published minimum clinically important difference should be checked for the comparison, population, outcome and follow-up it describes [@cook2019delta2]. The [clinical interpretation examples](#interpret-a-confidence-interval-clinically) apply this distinction.

## Effect scale and direction {.core-heading .unnumbered}

<span id="percentage-points">Percentage points</span>
: An absolute difference between two percentages is expressed in percentage points: 60% - 30% = 30 percentage points. A relative increase divides the change by the baseline: (60 - 30)/30 = 1, or 100%. An increase from 80% to 96% is 16 percentage points and a [20% relative increase](#relative-increase): (96 - 80)/80 = 0.20. <span id="relative-increase"></span>The relative increase uses the starting percentage as its denominator. The [discharge exercise](#discharge) compares these scales. Your report should make clear which scale you mean. Formulas and R inputs represent these probabilities as proportions between zero and one, such as 0.60 and 0.30.

<span id="mean-difference">Mean difference</span>
: A mean difference is in the outcome's own units, such as mmHg or score units. The [lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) uses treatment minus control. Positive is beneficial in the prepared improvement/relief cases; an outcome such as pain severity or mortality needs an explicit decision about beneficial direction.

<span id="standardized-mean-difference">Standardized mean difference (Cohen's d)</span>
: A difference between group means expressed in within-group standard-deviation units. In the two-independent-group example, SD describes the spread of individual outcomes within each population, assumed equal across groups. A pooled within-group sample SD estimates that common SD from observed data. A difference of 3 score units with SD 5 gives d = 3/5 = 0.60. The [two-means calculation](#two-means) uses these quantities. Clinical relevance depends on the outcome and study context.

![Two hypothetical distributions of individual improvement scores with means 0 and 3 and a common within-group SD of 5. The 3-unit distance between means is 0.60 SD. Greater improvement is favorable.](../figures/standardized-difference.png)


### Standardized treatment effect {#standardized-treatment-effect .core-heading .unnumbered}

A treatment effect expressed on a scale without the original measurement units. For a difference between means, a common measure is [Cohen's d](#standardized-mean-difference), defined above. The appropriate standardization depends on the outcome and method; clinical importance is judged in the study's outcome and clinical context [@rothwell2018targets].

### Effect size {#effect-size .core-heading .unnumbered}

An effect size describes the magnitude of a difference or association on a stated scale. Examples include a difference in event percentages or group means. A standardized mean difference expresses a difference in standard-deviation units. Clinical importance requires a judgment about the outcome, comparison and study context.

## Variation and uncertainty {.core-heading .unnumbered}

The [two-means example](#two-means) illustrates individual variability; the [one-study and many-studies activity](#activity-1-one-study-then-many) illustrates uncertainty in estimates.

<span id="standard-deviation">Standard deviation (SD)</span>
: Standard deviation (SD) describes how much individual patients differ, in the outcome's units. For example, an SD of 15 mmHg describes the spread of individual blood pressures. The common SD assumption in the two-means example means the populations in both groups have the same SD.

<span id="standard-error">Standard error (SE)</span>
: Standard error (SE) describes how much an estimate would vary if you repeated the study with new patients. For one mean, SE = SD/sqrt(n). If the population SD is 15 mmHg, 25 independent patients give an SE of 3 mmHg; 100 patients give 1.5 mmHg. Increasing the sample size reduces the standard error of the mean while the population SD remains fixed. If the population SD is unknown, the sample SD is used to estimate the SE.

<span id="confidence-interval">Confidence interval</span>
: A confidence interval is a range of values compatible with the study data under the analysis assumptions. It shows uncertainty around an estimate. At the same confidence level, a narrower interval indicates greater precision. For a treatment difference, its position relative to zero and the clinical threshold helps you interpret the result; the [clinical interval examples](#interpret-a-confidence-interval-clinically) illustrate this.

The 95% refers to the method: across repeated studies, about 95% of intervals calculated this way would contain the true population value, if the assumptions hold. Each study produces its own interval. The [methods record](#tutorial-methods) provides details of the interval calculations used in the apps.

<span id="full-width">Full interval width</span>
: Full width is the upper confidence limit minus the lower. For a symmetric interval its half-width, or margin of error, is half the full width.

<span id="margin-of-error">Margin of error</span>
: A margin of five percentage points means a full width of ten percentage points. For asymmetric intervals, the two distances from the estimate to the limits need not be equal.

## Estimation, precision, sampling variability and bias {.core-heading .unnumbered}

### Estimation {#estimation .core-heading .unnumbered}

Estimation uses sample data to learn about a population quantity, such as a mean, a prevalence, or a between-group difference. A point estimate gives a single value; an interval estimate expresses uncertainty around it. Precision describes how much an estimate varies across repeated samples. For example, estimating prevalence is the task; seeking a 95% confidence interval with a margin of error of 5 percentage points sets a precision target. A study planned for hypothesis testing can also provide estimates and confidence intervals.

### Precision {#precision .core-heading .unnumbered}

Precision describes how little an estimate varies across repeated samples; estimation is the process that produces the estimate. You can assess it using the standard error or, at a specified confidence level, the confidence-interval width. A smaller standard error or narrower interval indicates greater precision. A larger independent sample generally improves precision. Bias can still shift the estimate systematically away from the population value. Precision is also distinct from power, which concerns how often a specified test rejects the null under an assumed effect.

### Sampling variability {#sampling-variability .core-heading .unnumbered}

Sampling variability is the variation between estimates from repeated samples drawn under the same population assumptions. In the chronic pain trial, the population relief probabilities stay fixed while the observed percentages and their difference vary between trials. This differs from variability between individual patients, measured by quantities such as the standard deviation.

### Bias {#bias .core-heading .unnumbered}

Bias is a systematic deviation of an estimation procedure from the population quantity it aims to estimate. For example, knowledge of allocation might influence which patients are enrolled (selection bias); patients with poor relief might disproportionately miss follow-up (attrition bias); or additional care might differ between groups in ways that distort the intended comparison (performance bias). A large sample can produce a precise but biased estimate. The [missing-outcome discussion](#account-for-expected-losses) explains why prevention, design and analysis matter.

### Estimand (advanced) {#estimand .advanced-heading .unnumbered}

An estimand is the precisely defined population quantity the study aims to estimate. Its definition identifies the treatments, population, outcome, summary measure, and how events such as treatment discontinuation are handled. This makes the intended question clear before choosing an analysis or sample size method. See [ICH E9(R1)](https://database.ich.org/sites/default/files/E9-R1_Step4_Guideline_2019_1203.pdf).

### Sensitivity analysis {#sensitivity-analysis .core-heading .unnumbered}

A sensitivity analysis examines how results or conclusions change under plausible alternative assumptions. In sample size planning, you can either recalculate the required sample for each assumption or keep a chosen sample fixed and evaluate its performance. For example, you might vary the treatment difference, variability, or expected loss to follow-up. For a completed study, sensitivity analyses can examine assumptions about missing outcomes. The [Sensitivity to planning assumptions](#stress-test-the-study-plan) section explains the planning questions, and the [missing-outcome activity](https://katatam.github.io/sample-size-calculation/study/?activity=pain_simulation) illustrates how different missingness mechanisms affect an analysis. These comparisons assess robustness to assumptions.

## Hypotheses, Type I error probability, Type II error probability and power {.core-heading .unnumbered}

The [hypotheses and power section](#power) connects these terms to repeated hypothetical studies.

<span id="frequentist-methods">Frequentist methods</span>
: Statistical methods interpreted through their performance across hypothetical repetitions of the same study. For example, power describes how often a test detects a specified true difference, and a confidence level describes how often the interval method captures the population value.

<span id="statistical-significance">Statistical significance</span>
: A result that meets the prespecified threshold for evidence against the null hypothesis. Here, this means a p-value below the chosen Type I error probability. The estimated difference and confidence interval are also needed to assess the size and clinical importance of a treatment benefit.

<span id="null-hypothesis">Null hypothesis</span>
: The null hypothesis in these treatment comparisons says that the population outcomes are equal: the between-group difference is zero. Rejecting it means that the chosen test provides sufficient statistical evidence of a difference. When the test does not reject the null hypothesis, the evidence is insufficient to establish a difference. The confidence interval shows which treatment differences remain compatible with the data.

<span id="alternative-hypothesis">Alternative hypothesis</span>
: The two-sided alternative hypothesis allows a difference in either direction. The target difference specifies the population effect at which power is calculated. Statistical significance is assessed against the null hypothesis.

### True and false positives and negatives {#testing-outcomes .core-heading .unnumbered}

 A positive result means a statistically significant difference; a negative result means no statistically significant difference.

- <span id="false-positive"></span>False positive (Type I error): the test finds a difference when the population outcomes are equal.
- <span id="false-negative"></span>False negative (Type II error): the test misses a difference that exists in the population.
- <span id="true-positive"></span>True positive: the test detects a difference that exists in the population. Its probability at the specified difference is power.
- <span id="true-negative"></span>True negative: the test does not find a difference when the population outcomes are equal. Its probability is 1 minus the Type I error probability. In a real study, a non-significant result can be either a true negative or a false negative.

### Type I error probability {#alpha .core-heading .unnumbered}

Type I error probability ($\alpha$) is the probability of falsely rejecting the null hypothesis: the [false-positive probability](#false-positive){.no-glossary-tooltip}. Here, that means finding a statistically significant treatment difference when the population outcomes are actually equal. A 5% probability means about 5 false positives per 100 repeated studies when there is no true difference, under the test's assumptions. It does not mean that 5% of all significant findings are false positives.

### Type II error probability {#beta .core-heading .unnumbered}

Type II error probability ($\beta$) is the probability of failing to reject a false null hypothesis: the [false-negative probability](#false-negative){.no-glossary-tooltip}. Here, that means missing a specified true treatment difference. For example, a 10% Type II error probability at a true 30-percentage-point difference means about 10 missed differences per 100 repetitions of that trial. This probability depends on the true difference, sample size and analysis.

### Statistical power {#statistical-power .core-heading .unnumbered}

Power is the probability of detecting a specified true treatment difference with the planned test: the [true-positive probability](#true-positive){.no-glossary-tooltip}. It equals $1-\beta$, or 1 minus the Type II error probability. With 90% power, about 90 of 100 repetitions of the planned trial would detect that difference and 10 would miss it. Each repetition involves new patients. A non-significant result can remain compatible with both no effect and a worthwhile benefit.

### P-value {#p-value .core-heading .unnumbered}

A p-value is the probability, assuming the null hypothesis and statistical model are correct, of a test result at least as extreme as the observed result. In the two-sided pain comparison, it asks how likely a result at least as far from equal relief probabilities would be, in either direction, if the population probabilities were equal. A small p-value provides evidence against equality.

## Normal distribution and z-values {.core-heading .unnumbered}

The [multiplier explanation](#how-error-rates-and-power-affect-sample-size) shows how these values enter a sample size calculation.

<span id="z-value">Z-value</span>
: The standard normal distribution is a bell-shaped curve with a mean of zero and a standard deviation of one. A z-value gives a position on that curve in standard-deviation units. For example, 1.96 is 1.96 standard deviations above its center.

<span id="quantile">Quantile</span>
: A quantile is a cutoff below which a stated proportion of a distribution lies. For the standard normal distribution, $z_{0.975}=1.96$ means that 97.5% lies below 1.96. The sample size multiplier uses these cutoffs to translate the Type I error probability and target power into numbers for the formula. You can use the tutorial's multiplier table without calculating the cutoffs yourself.

## Tests and designs {.core-heading .unnumbered}

<span id="two-sided-test">One-sided and two-sided tests</span>
: A two-sided test can reject for sufficiently strong differences in either direction. A one-sided test has a directional rejection rule. For treatment minus control, the two-sided alternative includes any nonzero population difference. A one-sided alternative may specify a positive population difference; its null then includes zero and negative differences. Sidedness needs justification before results are examined. The [sampling-distribution illustration](#alpha-beta) assumes a known population SD and illustrates a one-sided test, while the [reasoning lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) uses two-sided comparisons.

A normal approximation uses the bell-shaped normal distribution to simplify a calculation. A t-test calculation also accounts for estimating variability from the study's patients. The two-means calculator and [lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) both use pooled two-sample t-test power. The normal formula in Chapter 2 explains how the inputs affect sample size. See the [statistical methods](../documentation/statistical-methods.md) for exact implementation details.

<span id="independent-groups">Independent, paired and clustered observations</span>
: In the core examples, different patients belong to the two groups, with each patient contributing one outcome. The analysis assumes that one patient's outcome does not provide information about another patient's outcome beyond what the model accounts for. Different participants are not sufficient to establish independence: outcomes may still be related within clinics or families. Paired/within-subject data include linked measurements, such as both eyes or before/after observations from the same person. Clustered data include participants linked within allocated practices or wards. Correlation affects information and therefore planning; counting every measurement as independent can overstate the information available.

## Advanced analysis terms {.advanced-heading .unnumbered}

<span id="covariate-adjustment">Covariate adjustment</span>
: A prespecified analysis can use prognostic baseline characteristics, such as baseline pain, to improve precision in a randomized treatment comparison. For a continuous outcome this may use analysis of covariance (ANCOVA). Its precision gain and sample size planning depend on the model and predictive value of those characteristics. Investigating whether treatment effects vary with a characteristic requires a treatment-by-characteristic comparison and its own justification. See the [design and analysis discussion](#increase-power) and [FDA guidance](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/adjusting-covariates-randomized-clinical-trials-drugs-and-biological-products) [@fda2023covariates].

## Advanced units and dependence {.advanced-heading .unnumbered}

### Unit of randomization {#unit-of-randomization .advanced-heading .unnumbered}

The entity assigned to a treatment, such as a participant, hospital, or body site. The allocation structure determines where independent treatment assignments occur.

### Unit of measurement {#unit-of-measurement .advanced-heading .unnumbered}

The entity or occasion for which an outcome is recorded, such as a participant, lesion, or visit. Several measurements can come from the same participant.

### Unit of analysis {#unit-of-analysis .advanced-heading .unnumbered}

The entity represented in the analysis. Individual measurements can be analyzed with a model that accounts for dependence within participants or clusters.

### Paired observations {#paired-observations .advanced-heading .unnumbered}

Two linked observations, such as outcomes from two treated sites in one participant. A paired analysis uses the within-pair comparison and accounts for the relationship between the observations.

### Intracluster correlation coefficient (ICC) {#intracluster-correlation .advanced-heading .unnumbered}

A measure of similarity between outcomes within the same cluster. In a simple random-intercept model, it is the proportion of total outcome variance attributable to differences between clusters.

### Design effect {#design-effect .advanced-heading .unnumbered}

The ratio of the variance of an estimate under a specified design to that under a comparable independent-observation design. For a simple cluster design with equal cluster size m and ICC rho, it is approximately 1 + (m - 1)rho; this can guide an initial sample size inflation.

The [advanced explanation of units and dependence](#units-of-analysis) compares cluster-randomized and within-person designs [@campbell2012consort; @pandis2017withinperson].

## Counts and losses {.core-heading .unnumbered}

<span id="analyzable-sample-size">Analyzable and recruitment counts</span>
: Analyzable sample size (n) means the number of participants included in the stated analysis; app labels use "participants for analysis". In the [two-group lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) it is per group; the total is 2n. Recruitment n is inflated for anticipated losses, rounding within each arm. With expected dropout of 10%, divide by the retention proportion 0.90, rather than multiplying by 1.10. Missing-data bias requires attention to prevention and analysis.

<span id="retention">Retention</span>
: The percentage or proportion of enrolled participants who contribute the required outcome at the specified time. If 20 of 200 enrolled participants lack that outcome, 180/200 = 90% are retained and 10% are lost. The [recruitment calculation](#account-for-expected-losses) uses anticipated retention, with uncertainty and potentially different percentages across arms.

<span id="treatment-crossover">Treatment crossover (switching)</span>
: Receipt of the other treatment after randomization. In an analysis of treatment assignment, participants remain in their randomized groups. Switching may reduce the between-group difference. A [crossover trial](#crossover-trial) assigns treatment sequences by design. See [Allowing for treatment switching](#treatment-switching).

<span id="treatment-contamination">Treatment contamination</span>
: Receipt of some or all of the intervention by participants assigned to the comparator. This can make the randomized groups' outcomes more similar and affect power. Planning should reflect the expected extent and consequences of contamination. See [Treatment changes](#treatment-changes).

### Crossover trial {#crossover-trial .advanced-heading .unnumbered}

A trial in which participants receive treatments in successive periods, with the treatment sequence randomized. For example, one sequence receives A then B, and another B then A. The analysis compares outcomes within the same participant and accounts for their dependence. Sample size planning uses the variability of those within-person comparisons [@dwan2019crossover].

A carryover effect occurs when an earlier treatment affects outcomes in a later period. Suitable crossover trials require a sufficiently stable condition, reversible treatment effects and control of carryover, sometimes through a washout period. [Treatment switching](#treatment-crossover) describes a change in treatment after assignment within another design.

## Advanced testing and adaptation terms {.advanced-heading .unnumbered}

<span id="multiplicity">Multiplicity</span>
: Multiple opportunities to make false-positive claims across a specified set of tests, such as several outcomes, treatment comparisons or interim analyses. The intended claims and success rule determine the appropriate error control. See [multiple outcomes and comparisons](#multiple-outcomes-comparisons).

<span id="co-primary-outcomes">Co-primary outcomes</span>
: Two or more primary outcomes for which every required test must succeed to support the intended joint claim. Planning concerns the probability that all tests succeed, with their dependence taken into account. See [testing strategies](#multiple-outcomes-comparisons).

<span id="interim-analysis">Interim analysis</span>
: An analysis of accumulating trial results before the planned final analysis. Its purpose, timing and possible consequences should be specified in advance. See [interim analyses and stopping guidelines](#interim-analyses-stopping).

<span id="futility">Futility</span>
: A low prospect of demonstrating the planned benefit under a specified decision rule and assumptions. A futility guideline can support stopping a trial early; the conclusion concerns that design's prospects of success. See [stopping guidelines](#interim-analyses-stopping).

<span id="group-sequential-design">Group-sequential design</span>
: A trial design with planned analyses of accumulating data and prespecified opportunities to stop. Its testing procedure accounts for the repeated analyses to control the overall Type I error probability. See [interim analyses](#interim-analyses-stopping).

<span id="adaptive-design">Adaptive design</span>
: A design allowing prespecified changes in response to accumulating trial data, such as revising sample size or selecting treatment arms. The decision rules and final analysis are planned and evaluated together. See [sample-size re-estimation](#sample-size-re-estimation).

## Advanced simulation terms {.advanced-heading .unnumbered}

Planning and generating scenarios
: The planning scenario contains the assumptions used to choose the sample size. A generating scenario contains the population values assumed to be true when simulating studies. Keeping the planned sample size fixed while changing those population values shows how the same study could perform if reality differed from the plan. Recalculating the sample size each time instead asks how the plan would need to change.

Simulation repetitions (B)
: B counts independent simulated studies; n gives the number of patients in each study or group. The [simulation walkthrough](#simulation) shows how studies are generated, analyzed and summarized.

### Monte Carlo error {#monte-carlo-error .advanced-heading .unnumbered}

Monte Carlo error is the random difference between a finite simulation estimate and the value approached with indefinitely many repetitions under the same assumptions. Two batches might estimate power at 79% and 81% even though the trial design and population are unchanged.

The Monte Carlo standard error (MCSE) describes variation between independent batches. For a simulated rejection fraction $\hat p$ from $B$ independent trials, $\mathrm{MCSE}=\sqrt{\hat p(1-\hat p)/B}$. More repetitions reduce this uncertainty while each trial retains its original power. The [simulation-precision section](#precision-of-a-simulation) gives a worked example and distinguishes this uncertainty from sampling variability within a trial.

## Research ethics review {.unnumbered}

### Research ethics committee (REC) {#research-ethics-committee .unnumbered}

An independent committee that reviews research involving human participants, including its scientific justification and protection of participants. Names and legal responsibilities vary by country. The [Declaration of Helsinki](https://www.wma.net/policies-post/wma-declaration-of-helsinki/) describes the international ethical principles; applicable national requirements determine the review process.

### Institutional review board (IRB) {#institutional-review-board .unnumbered}

The usual US term for a committee that reviews research involving human participants. Applicable Food and Drug Administration (FDA) or Department of Health and Human Services (HHS) rules define its responsibilities and the studies requiring review. See the [FDA guidance](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/institutional-review-boards-frequently-asked-questions) and [HHS overview](https://www.hhs.gov/ohrp/regulations-and-policy/guidance/faq/45-cfr-46/index.html).

The following three terms describe the Netherlands specifically.

### WMO {#wmo .unnumbered}

The Medical Research Involving Human Subjects Act is Dutch legislation governing research within its scope. Such research needs prior ethical review. The applicable framework depends on the study; the [CCMO guidance](https://english.ccmo.nl/investigators) explains the review routes.

### METC {#metc .unnumbered}

An accredited medical research ethics committee, or MREC in English, reviews most WMO research. Review considers scientific value, participant protection, and the balance of risks and potential benefits.

### CCMO {#ccmo .unnumbered}

The Central Committee on Research Involving Human Subjects directly reviews specified categories of research and has national oversight responsibilities. The [official review guidance](https://english.ccmo.nl/investigators/primary-submission-to-the-review-committee) specifies which studies are reviewed by the CCMO and which by an accredited METC.

## Statistical and reporting guidance {.unnumbered}

<span id="ich-e9">ICH E9</span>
: The statistical principles guideline of the International Council for Harmonisation of Technical Requirements for Pharmaceuticals for Human Use (ICH). It provides internationally used guidance for the design, analysis and reporting of clinical trials of medicines, including sample size justification [@iche91998].

<span id="spirit">SPIRIT</span>
: Standard Protocol Items: Recommendations for Interventional Trials. It identifies information to include in a randomized trial protocol, including participants, interventions, outcomes, sample size and analysis [@spiritconsort2025].

<span id="consort">CONSORT</span>
: Consolidated Standards of Reporting Trials. It identifies information to report about a randomized trial and its results, including how sample size was determined. Relevant extensions address particular designs [@consortee2025].

<span id="strobe">STROBE</span>
: Strengthening the Reporting of Observational Studies in Epidemiology. It covers reporting of cohort, case-control and cross-sectional studies. The [STROBE statement](https://www.strobe-statement.org/) provides the checklists and explanations.

<span id="stard">STARD</span>
: Standards for Reporting Diagnostic Accuracy Studies. It covers reporting of studies that assess how well a test identifies a target condition. The [STARD checklist](https://www.equator-network.org/reporting-guidelines/stard/) explains the items.

<span id="delta2">DELTA&sup2;</span>
: Difference ELicitation in TriAls, second guidance project. The guidance explains how to choose and justify a target difference for a randomized trial, drawing on evidence about plausible differences and judgments about clinical importance [@cook2018delta2; @cook2019delta2].
