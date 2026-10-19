# Glossary {#glossary .core-heading}

This glossary provides reminders of terms used in the tutorial and apps. The main tutorial includes formulas and expandable R code blocks.

## Probability, percentages and rates {.core-heading}

A probability describes how likely an event is under stated assumptions. It lies between zero and one and can be expressed as a percentage: a probability of 0.60 is 60%. An observed proportion describes the fraction of observations with an outcome, such as 6 of 10 patients reporting relief; the observed percentage is 60%. That percentage estimates the population probability but need not equal it.

In this tutorial, Type I and Type II error probabilities and power describe how the planned test behaves under specified population assumptions. Simulation estimates these probabilities using the percentage of repeated studies with each result. A time-based rate has a different denominator, such as new cases per 1,000 person-years or patients recruited per month. The binary-outcome calculators use the probability of an event by a specified follow-up time.

## Population, sample and planning values {.core-heading}

<span id="population-parameter"></span>A population parameter is a feature of the population you want to learn about, such as its mean, proportion, or treatment difference. <span id="sample-estimate"></span>A sample estimate is calculated from the observations you obtained. In the pain pilot, 7/10 is a sample proportion, expressed as 70%. The treatment probability of 60% used in the sample size calculation is a planning assumption whose justification should draw on evidence and sensitivity analysis. A proportion such as 7/10 can also be written as 0.70 or expressed as a percentage, 70%.

<span id="expected-difference"></span>The [expected difference](#between-group-differences) is the anticipated between-group population difference based on current evidence, with uncertainty. An observed difference is calculated from a particular sample, such as the pilot. <span id="target-difference"></span>The [target difference](#between-group-differences) is the between-group difference used in the sample size calculation, at which you calculate [power](#statistical-power). <span id="clinical-threshold"></span>The [clinical threshold](#between-group-differences) is the smallest between-group benefit judged worthwhile, considering the treatment's burdens, risks, costs, and alternatives. These judgments may coincide in practice, but the worked examples use distinct values to show their different roles. For the pain trial, they are 40, 30, and 20 percentage points, respectively.

The target difference should be justified as realistic and important. Planning for a difference larger than the clinical threshold generally gives lower power at some worthwhile differences. See [the target-difference discussion](#what-do-we-expect-what-will-we-plan-for-and-what-matters-clinically) and [DELTA2 guidance (Cook et al., 2018)](https://doi.org/10.1136/bmj.k3750).

## Between-group differences and individual benefit {#between-group-differences .core-heading}

A between-group difference compares outcomes under two treatments in a specified population. For a binary outcome, it can be expressed as a difference in the percentages experiencing the outcome. For a continuous outcome, it may be a difference in mean scores. The expected difference, target difference, and clinical threshold in this tutorial all concern these between-group comparisons.

If 60% of patients experience pain relief with the novel treatment and 30% with standard treatment, the difference is 30 percentage points: approximately 30 more patients per 100 would experience relief with the novel treatment under these assumptions. This does not mean that each patient experiences 30% more pain relief. Similarly, a 3-point difference between group means does not mean that every patient gains 3 additional points. Group summaries do not describe how treatment effects vary between individuals; in a parallel-group trial, you cannot observe the same patient's outcome under both treatments.

A threshold for meaningful improvement within an individual patient is therefore not automatically a suitable clinical threshold for a between-group comparison. An individual improvement threshold might define who counts as experiencing pain relief. A separate judgment is then needed about what difference between groups in the percentage experiencing relief would make the treatment worthwhile. Before adopting a published "minimum clinically important difference," you should check which comparison it describes and whether its population, outcome, and follow-up match your study ([Cook et al., 2019](https://doi.org/10.3310/hta23600)).

## Effect scale and direction {.core-heading}

<span id="percentage-points"></span>An absolute difference between two percentages is expressed in percentage points: 60% - 30% = 30 percentage points. A relative increase divides the change by the baseline: (60 - 30)/30 = 1, or 100%. An increase from 80% to 96% is 16 percentage points and a 20% relative increase. Your report should make clear which scale you mean. Formulas and R inputs represent these probabilities as proportions between zero and one, such as 0.60 and 0.30.

<span id="mean-difference"></span>A mean difference is in the outcome's own units, such as mmHg or score units. The [lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) uses treatment minus control. Positive is beneficial in the prepared improvement/relief cases; an outcome such as pain severity or mortality needs an explicit decision about beneficial direction.

A standardized difference, often called Cohen's d for a mean comparison, expresses the difference in SD units. A difference of 3 with SD 5 gives 3/5 = 0.60. This can help translate between software inputs; a conventional label such as "medium" does not establish clinical relevance.

## Variation and uncertainty {.core-heading}

<span id="standard-deviation"></span>Standard deviation (SD) describes how much individual patients differ, in the outcome's units. For example, an SD of 15 mmHg describes the spread of individual blood pressures. The common SD assumption in the two-means example means the populations in both groups have the same SD.

<span id="standard-error"></span>Standard error (SE) describes how much an estimate would vary if you repeated the study with new patients. For one mean, SE = SD/sqrt(n). If the population SD is 15 mmHg, 25 independent patients give an SE of 3 mmHg; 100 patients give 1.5 mmHg. Increasing the sample size reduces the standard error of the mean while the population SD remains fixed. If the population SD is unknown, the sample SD is used to estimate the SE.

<span id="confidence-interval"></span>A confidence interval shows uncertainty around an estimate under the analysis assumptions. At the same confidence level, a narrower interval indicates greater precision. For a treatment difference, you should compare its limits with zero and the clinical threshold. The 95% refers to the method: across repeated studies, about 95% of intervals calculated this way would contain the true population value, if the assumptions hold. It is not a 95% probability assigned to the particular interval you observed, nor a range of individual patients' benefits.

<span id="full-width"></span>Full width is the upper confidence limit minus the lower. For a symmetric interval its half-width, or margin of error, is half the full width. <span id="margin-of-error"></span>A margin of five percentage points means a full width of ten percentage points. For asymmetric intervals, the two distances from the estimate to the limits need not be equal.

## Estimation, precision, sampling variability and bias {.core-heading}

### Estimation {#estimation .core-heading}

Estimation uses sample data to learn about a population quantity, such as a mean, a prevalence, or a between-group difference. A point estimate gives a single value; an interval estimate expresses uncertainty around it. Precision describes how much an estimate varies across repeated samples. For example, estimating prevalence is the task; seeking a 95% confidence interval with a margin of error of 5 percentage points sets a precision target. A study planned for hypothesis testing can also provide estimates and confidence intervals.

### Precision {#precision .core-heading}

Precision describes how little an estimate varies across repeated samples; estimation is the process that produces the estimate. You can assess it using the standard error or, at a specified confidence level, the confidence-interval width. A smaller standard error or narrower interval indicates greater precision. A larger independent sample generally improves precision, but does not guarantee that an estimate is close to the truth if the study is biased. Precision is also distinct from power, which concerns how often a specified test rejects the null under an assumed effect.

### Sampling variability {#sampling-variability .core-heading}

Sampling variability is the variation between estimates from repeated samples drawn under the same population assumptions. In the chronic pain example, the population relief probabilities stay fixed while the observed percentages and their difference vary between trials. This differs from variability between individual patients, measured by quantities such as the standard deviation.

### Bias {#bias .core-heading}

Bias is a systematic deviation of an estimation procedure from the population quantity it aims to estimate. For example, selection processes or missing outcomes can distort a treatment comparison. A large sample can produce a precise but biased estimate; increasing sample size does not automatically correct problems in the design, measurement or analysis.

### Effect size {#effect-size .core-heading}

An effect size describes the magnitude of a difference or association on a stated scale. Examples include a difference in event percentages or group means. A standardized mean difference expresses a difference in standard-deviation units. The term does not itself establish clinical importance or identify an individual patient's benefit.

### Estimand {#estimand .advanced-heading}

An estimand is the precisely defined population quantity the study aims to estimate. Its definition identifies the treatments, population, outcome, summary measure, and how events such as treatment discontinuation are handled. This makes the intended question clear before choosing an analysis or sample size method. See [ICH E9(R1)](https://database.ich.org/sites/default/files/E9-R1_Step4_Guideline_2019_1203.pdf).

### Sensitivity analysis {#sensitivity-analysis .core-heading}

In sample size planning, a sensitivity analysis examines plausible alternative assumptions. Before choosing a sample size, you can recalculate how many patients would be needed under each assumption. After choosing a sample size, you can keep it fixed and ask how the same study would perform if the true difference were smaller or variability were greater. These answer different questions. Sensitivity analyses can also examine how a completed study's conclusions depend on assumptions, for example about missing data.

## Hypotheses, Type I error probability, Type II error probability and power {.core-heading}

<span id="null-hypothesis"></span>The null hypothesis in these treatment comparisons says that the population outcomes are equal: the between-group difference is zero. Rejecting it means that the chosen test provides sufficient statistical evidence of a difference. When the test does not reject the null hypothesis, the evidence is insufficient to establish a difference. The confidence interval shows which treatment differences remain compatible with the data. <span id="alternative-hypothesis"></span>The two-sided alternative hypothesis allows a difference in either direction. The target difference specifies the population effect at which power is calculated. Statistical significance is assessed against the null hypothesis.

### True and false positives and negatives {#testing-outcomes .core-heading}

 A positive result means a statistically significant difference; a negative result means no statistically significant difference.

- <span id="false-positive"></span>False positive (Type I error): the test finds a difference when the population outcomes are equal.
- <span id="false-negative"></span>False negative (Type II error): the test misses a difference that exists in the population.
- <span id="true-positive"></span>True positive: the test detects a difference that exists in the population. Its probability at the specified difference is power.
- <span id="true-negative"></span>True negative: the test does not find a difference when the population outcomes are equal. Its probability is 1 minus the Type I error probability. However, after a real study, a non-significant result alone cannot tell you whether it is a true negative or a false negative.

### Type I error probability {#alpha .core-heading}

Type I error probability ($\alpha$) is the probability of falsely rejecting the null hypothesis: the [false-positive probability](#false-positive). Here, that means finding a statistically significant treatment difference when the population outcomes are actually equal. A 5% probability means about 5 false positives per 100 repeated studies when there is no true difference, under the test's assumptions. It does not mean that 5% of all significant findings are false positives.

### Type II error probability {#beta .core-heading}

Type II error probability ($\beta$) is the probability of failing to reject a false null hypothesis: the [false-negative probability](#false-negative). Here, that means missing a specified true treatment difference. For example, a 10% Type II error probability at a true 30-percentage-point difference means about 10 missed differences per 100 repetitions of that trial. This probability depends on the true difference, sample size and analysis; it is not the same for every possible effect.

### Statistical power {#statistical-power .core-heading}

Power is the probability of detecting a specified true treatment difference with the planned test: the [true-positive probability](#true-positive). It equals $1-\beta$, or 1 minus the Type II error probability. With 90% power, about 90 of 100 repetitions of the planned trial would detect that difference and 10 would miss it. Each repetition involves new patients. Power is not the probability that the treatment works, and a non-significant result does not establish equivalence.

### P-value {#p-value .core-heading}

A p-value is the probability, assuming the null hypothesis and statistical model are correct, of a test result at least as extreme as the observed result. In the two-sided pain comparison, it asks how likely a result at least as far from equal relief probabilities would be, in either direction, if the population probabilities were equal. A small p-value provides evidence against equality; it does not measure clinical benefit or give the probability that a hypothesis is true.

## Normal distribution and z-values {.core-heading}

<span id="z-value"></span>The standard normal distribution is a bell-shaped curve with a mean of zero and a standard deviation of one. A z-value gives a position on that curve in standard-deviation units. For example, 1.96 is 1.96 standard deviations above its center.

<span id="quantile"></span>A quantile is a cutoff below which a stated proportion of a distribution lies. For the standard normal distribution, $z_{0.975}=1.96$ means that 97.5% lies below 1.96. The sample size multiplier uses these cutoffs to translate the Type I error probability and target power into numbers for the formula. You can use the tutorial's multiplier table without calculating the cutoffs yourself.

## Tests and designs {.core-heading}

<span id="two-sided-test"></span>A two-sided test can reject for sufficiently strong differences in either direction. A one-sided test has a directional rejection rule. Decide sidedness before seeing the results; the known-SD diagram is an illustrative one-sided example, while the [core lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) uses two-sided comparisons.

A normal approximation uses the bell-shaped normal distribution to simplify a calculation. A t-test calculation also accounts for estimating variability from the study's patients. The simple calculators use labeled normal sample-size approximations; the [lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study)'s mean planning uses pooled two-sample t-test power. See the [statistical methods](../documentation/statistical-methods.md) for exact implementation details.

<span id="independent-groups"></span>In the core examples, different patients belong to the two groups, with each patient contributing one outcome. The analysis assumes that one patient's outcome does not provide information about another patient's outcome beyond what the model accounts for. Different participants are not sufficient to establish independence: outcomes may still be related within clinics or families. Paired/within-subject data include linked measurements, such as both eyes or before/after observations from the same person. Clustered data include participants linked within allocated practices or wards. Correlation affects information and therefore planning; counting every measurement as independent can overstate the information available.

## Counts, losses and simulation {.core-heading}

<span id="analyzable-sample-size"></span>Analyzable sample size (n) means the number of participants included in the stated analysis; app labels use "participants for analysis". In the [two-group lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) it is per group; the total is 2n. Recruitment n is inflated for anticipated losses, rounding within each arm. With expected dropout of 10%, divide by the retention proportion 0.90, rather than multiplying by 1.10. Inflation does not correct missing-data bias.

The planning scenario contains the assumptions used to choose the sample size. A generating scenario contains the population values assumed to be true when simulating studies. Keeping the planned sample size fixed while changing those population values shows how the same study could perform if reality differed from the plan. Recalculating the sample size each time instead asks how the plan would need to change.

B counts independent simulated studies; n gives the number of patients in each study or group.

### Monte Carlo error {#monte-carlo-error .advanced-heading}

Monte Carlo error is the random difference between a result estimated from a finite simulation and the value you would obtain from indefinitely many repetitions under the same assumptions. For example, one batch of 1,000 simulated trials might estimate power at 80%, while another gives 79% or 81%, even though the population assumptions, sample size and analysis stay the same. This variation between batches is Monte Carlo uncertainty.

The Monte Carlo standard error (MCSE) describes how much the simulation estimate varies between independent batches. For an observed proportion of statistically significant simulated results $\hat p$ from $B$ independent simulated trials, $\mathrm{MCSE}=\sqrt{\hat p(1-\hat p)/B}$. At estimated power of 80% with 1,000 trials, the MCSE is about 1.3 percentage points. A Monte Carlo interval describes uncertainty in an estimated simulation result, such as power.

Increasing the number of simulations reduces Monte Carlo error; quadrupling the repetitions approximately halves the MCSE. It does not increase the power of each trial, remove error from an analytical approximation, or establish that the assumed population probabilities fit a real study. You should distinguish simulation uncertainty from sampling uncertainty within a trial and uncertainty about the clinical assumptions. The [simulation-precision section](#precision-of-a-simulation) provides a worked example.

For more detail, return to the [power chapter](#power), [sampling-distribution illustration](#alpha-beta), [precision examples](#feasibility), or [common mistakes](#common-mistakes). Methodological sources include Kirkwood and Sterne (2003), Whitley and Ball (2002), and the R documentation cited in the tutorial.

## Research ethics review

### Research ethics committee (REC) {#research-ethics-committee}

An independent committee that reviews research involving human participants, including its scientific justification and protection of participants. Names and legal responsibilities vary by country. The [Declaration of Helsinki](https://www.wma.net/policies-post/wma-declaration-of-helsinki/) describes the international ethical principles; applicable national requirements determine the review process.

### Institutional review board (IRB) {#institutional-review-board}

The usual US term for a committee that reviews research involving human participants. Applicable FDA or HHS rules define its responsibilities and the studies requiring review. See the [FDA guidance](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/institutional-review-boards-frequently-asked-questions) and [HHS overview](https://www.hhs.gov/ohrp/regulations-and-policy/guidance/faq/45-cfr-46/index.html).

The following three terms describe the Netherlands specifically.

### WMO {#wmo}

The Medical Research Involving Human Subjects Act is Dutch legislation governing research within its scope. Such research needs prior ethical review. The applicable framework depends on the study; the [CCMO guidance](https://english.ccmo.nl/investigators) explains the review routes.

### METC {#metc}

An accredited medical research ethics committee, or MREC in English, reviews most WMO research. Review considers scientific value, participant protection, and the balance of risks and potential benefits.

### CCMO {#ccmo}

The Central Committee on Research Involving Human Subjects directly reviews specified categories of research and has national oversight responsibilities. The [official review guidance](https://english.ccmo.nl/investigators/primary-submission-to-the-review-committee) specifies which studies are reviewed by the CCMO and which by an accredited METC.
