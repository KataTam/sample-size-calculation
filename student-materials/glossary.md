# Key parameters and prerequisites {#glossary .core-heading}

::: {.learning-goals .core-outcomes}
Learning outcomes. After this section, you should be able to:

- Interpret the effect scale.
- Distinguish individual variability from uncertainty in an estimate.
- Explain the error rates, precision targets and participant counts used in planning.
:::

Use this section when a term in the tutorial or app needs a reminder. The main tutorial includes formulas and expandable R code blocks.

## Population, sample and planning values {.core-heading}

<span id="population-parameter"></span>A population parameter is a feature of the population you want to learn about, such as its mean, proportion, or treatment difference. <span id="sample-estimate"></span>A sample estimate is calculated from the observations you obtained. In the pain pilot, 7/10 is a sample proportion, expressed as 70%. The treatment probability of 60% used in the sample size calculation is a planning assumption supported with evidence and sensitivity analysis, rather than a known truth. Use proportion for a fraction such as 7/10 and percentage for its expression as 70%.

<span id="expected-difference"></span>The [expected difference](#between-group-differences) is the anticipated between-group population difference based on current evidence, with uncertainty. An observed difference is calculated from a particular sample, such as the pilot. <span id="target-difference"></span>The [target difference](#between-group-differences) is the between-group difference used in the sample size calculation, at which you calculate [power](#statistical-power); it is not a result the study must achieve. <span id="clinical-threshold"></span>The [clinical threshold](#between-group-differences) is the smallest between-group benefit judged worthwhile, considering the treatment's burdens, risks, costs, and alternatives. These judgments may coincide in practice, but the worked examples use distinct values to show their different roles. For the pain trial, they are 40, 30, and 20 percentage points, respectively.

The target difference should be justified as realistic and important. Planning for a difference larger than the clinical threshold generally gives lower power at some worthwhile differences. See [the target-difference discussion](#what-do-we-expect-what-will-we-plan-for-and-what-matters-clinically) and [DELTA2 guidance (Cook et al., 2018)](https://doi.org/10.1136/bmj.k3750).

## Between-group differences and individual benefit {#between-group-differences .core-heading}

A between-group difference compares outcomes under two treatments in a specified population. For a binary outcome, it can be expressed as a difference in the percentages experiencing the outcome. For a continuous outcome, it may be a difference in mean scores. The expected difference, target difference, and clinical threshold in this tutorial all concern these between-group comparisons.

If 60% of patients experience pain relief with the novel treatment and 30% with standard treatment, the difference is 30 percentage points: approximately 30 more patients per 100 would experience relief with the novel treatment under these assumptions. This does not mean that each patient experiences 30% more pain relief. Similarly, a 3-point difference between group means does not mean that every patient gains 3 additional points. Group summaries do not describe how treatment effects vary between individuals; in a parallel-group trial, you cannot observe the same patient's outcome under both treatments.

A threshold for meaningful improvement within an individual patient is therefore not automatically a suitable clinical threshold for a between-group comparison. An individual improvement threshold might define who counts as experiencing pain relief. A separate judgment is then needed about what difference between groups in the percentage experiencing relief would make the treatment worthwhile. Before adopting a published "minimum clinically important difference," you should check which comparison it describes and whether its population, outcome, and follow-up match your study ([Cook et al., 2019](https://doi.org/10.3310/hta23600)).

## Effect scale and direction {.core-heading}

<span id="percentage-points"></span>An absolute difference between two percentages is expressed in percentage points: 60% - 30% = 30 percentage points. A relative increase divides the change by the baseline: (60 - 30)/30 = 1, or 100%. An increase from 80% to 96% is 16 percentage points and a 20% relative increase. State which scale you mean. Formulas and R inputs represent these probabilities as proportions between zero and one, such as 0.60 and 0.30.

<span id="mean-difference"></span>A mean difference is in the outcome's own units, such as mmHg or score units. The [lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) uses treatment minus control. Positive is beneficial in the prepared improvement/relief cases; an outcome such as pain severity or mortality needs an explicit decision about beneficial direction.

A standardized difference, often called Cohen's d for a mean comparison, expresses the difference in SD units. A difference of 3 with SD 5 gives 3/5 = 0.60. This can help translate between software inputs; a conventional label such as "medium" does not establish clinical relevance.

## Variation and uncertainty {.core-heading}

<span id="standard-deviation"></span>Standard deviation (SD) describes variability between individuals. The common SD assumption in the simple two-means example means the populations in the two groups have the same SD.

<span id="standard-error"></span>Standard error (SE) describes variability of an estimate across repetitions. For one mean with known population SD, SE = SD/sqrt(n). More independent observations reduce SE; they do not make the population's individual values less variable. The sampling-distribution illustration uses SE, not SD, as the width of the sample-mean curves.

<span id="confidence-interval"></span>A confidence interval describes uncertainty about an estimate using a procedure with stated long-run coverage (the percentage of intervals containing the population value across repeated studies). Under its assumptions, a 95% procedure contains the fixed population value in about 95% of repetitions. An observed interval does not give the fixed truth a 95% probability of lying inside it. Interpret the range of compatible effects against zero and a clinically important threshold.

<span id="full-width"></span>Full width is the upper confidence limit minus the lower. For a symmetric interval its half-width, or margin of error, is half the full width. <span id="margin-of-error"></span>A margin of five percentage points means a full width of ten percentage points. For asymmetric intervals, the two distances from the estimate to the limits need not be equal.

## Precision, sampling variability and bias {.core-heading}

### Precision {#precision .core-heading}

Precision describes how little an estimate varies across repeated samples. You can assess it using the standard error or, at a specified confidence level, the confidence-interval width. A smaller standard error or narrower interval indicates greater precision. A larger independent sample generally improves precision, but does not guarantee that an estimate is close to the truth if the study is biased. Precision is also distinct from power, which concerns how often a specified test rejects the null under an assumed effect.

### Sampling variability {#sampling-variability .core-heading}

Sampling variability is the variation between estimates from repeated samples drawn under the same population assumptions. In the chronic pain example, the population relief probabilities stay fixed while the observed percentages and their difference vary between trials. This differs from variability between individual patients, measured by quantities such as the standard deviation.

### Bias {#bias .core-heading}

Bias is a systematic deviation of an estimation procedure from the population quantity it aims to estimate. For example, selection processes or missing outcomes can distort a treatment comparison. A large sample can produce a precise but biased estimate; increasing sample size does not automatically correct problems in the design, measurement or analysis.

### Effect size {#effect-size .core-heading}

An effect size describes the magnitude of a difference or association on a stated scale. Examples include a difference in event percentages or group means. A standardized mean difference expresses a difference in standard-deviation units. The term does not itself establish clinical importance or identify an individual patient's benefit.

### Estimand {#estimand .advanced-heading}

An estimand is the precisely defined population quantity the study aims to estimate. Its definition identifies the treatments, population, outcome, summary measure, and how events such as treatment discontinuation are handled. This makes the intended question clear before choosing an analysis or sample size method. See [ICH E9(R1)](https://database.ich.org/sites/default/files/E9-R1_Step4_Guideline_2019_1203.pdf).

### Sensitivity analysis {#sensitivity-analysis .core-heading}

In sample size planning, a sensitivity analysis examines how results change under plausible alternative assumptions. Recalculating the required sample under different assumptions asks how the plan would change. Holding the sample size fixed and changing the generating effect asks how that chosen design would perform. A statistical analysis may also use sensitivity analyses to examine robustness to assumptions about matters such as missing data.

## Hypotheses, Type I error rate, Type II error rate and power {.core-heading}

<span id="null-hypothesis"></span>The null hypothesis in the ordinary superiority examples is a zero population difference. <span id="alternative-hypothesis"></span>A two-sided alternative hypothesis allows a difference in either direction. The alternative does not become "at least the clinical threshold" because that threshold was used for planning.

### Type I error rate {#alpha .core-heading}

Type I error rate ($\alpha$) is the planned probability of rejecting a true null under the test's assumptions: the Type I error probability. It is not the probability that the null is true after observing the data. Approximate procedures can have finite-sample error rates that depart from their nominal Type I error rate.

### Type II error rate {#beta .core-heading}

Type II error rate ($\beta$) is the probability of failing to reject the null at a specified true alternative, with the design and analysis held fixed: the Type II error probability. It depends on the assumed true effect, rather than applying to every possible treatment difference.

### Statistical power {#statistical-power .core-heading}

Power is $1-\beta$: the probability of rejecting the null hypothesis at the specified true effect, using the planned design and analysis. With 90% power, about 90% of hypothetical independent repetitions under those assumptions would reject the null and about 10% would not. This describes how the procedure behaves across studies; it does not involve repeatedly measuring the same patients. An individual study can still produce a non-significant result, and non-rejection does not establish equivalence.

### P-value {#p-value .core-heading}

A p-value describes how incompatible the data are with the null under the stated model/test. It is not a measure of effect size, clinical benefit, or the probability that a hypothesis is true.

## Tests and designs {.core-heading}

<span id="two-sided-test"></span>A two-sided test can reject for sufficiently strong differences in either direction. A one-sided test has a directional rejection rule. Decide sidedness before seeing the results; the known-SD diagram is an illustrative one-sided example, while the [core lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) uses two-sided comparisons.

A z calculation uses the standard normal distribution, often as an approximation. A t test accounts for estimating normal-outcome variance. The simple calculators use labeled normal sample-size approximations; the [lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study)'s mean planning uses pooled two-sample t-test power. See the [statistical methods](../documentation/statistical-methods.md) for exact implementation details.

<span id="independent-groups"></span>Independent groups contain different independent experimental units in the two groups. Paired/within-subject data include linked measurements, such as both eyes or before/after observations from the same person. Clustered data include participants linked within allocated practices or wards. Correlation affects information and therefore planning; counting every measurement as independent can overstate the sample size.

## Counts, losses and simulation {.core-heading}

<span id="analyzable-sample-size"></span>Analyzable sample size (n) means the number of participants included in the stated analysis; app labels use "participants for analysis". In the [two-group lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) it is per group; the total is 2n. Recruitment n is inflated for anticipated losses, rounding within each arm. With expected dropout of 10%, divide by the retention proportion 0.90, rather than multiplying by 1.10. Inflation does not correct missing-data bias.

The planning scenario selects the design. A generating scenario specifies what could actually happen in repeated hypothetical studies. Changing generating assumptions while holding the planned n fixed is a sensitivity analysis; recalculating n each time answers a different question.

B is the number of independent simulated studies, not the number of patients per study. A seed makes a specified simulation reproducible.

### Monte Carlo error {#monte-carlo-error .advanced-heading}

Monte Carlo error is the random difference between a result estimated from a finite simulation and the value you would obtain from indefinitely many repetitions under the same assumptions. For example, one batch of 1,000 simulated trials might estimate power at 80%, while another gives 79% or 81%, even though the population assumptions, sample size and analysis stay the same. This variation between batches is Monte Carlo uncertainty.

The Monte Carlo standard error (MCSE) describes how much the simulation estimate varies between independent batches. For an estimated rejection fraction $\hat p$ from $B$ independent simulated trials, $\mathrm{MCSE}=\sqrt{\hat p(1-\hat p)/B}$. At estimated power of 80% with 1,000 trials, the MCSE is about 1.3 percentage points. Monte Carlo intervals describe uncertainty in the simulation estimate, rather than a treatment-effect confidence interval from one clinical trial.

Increasing the number of simulations reduces Monte Carlo error; quadrupling the repetitions approximately halves the MCSE. It does not increase the power of each trial, remove error from an analytical approximation, or establish that the assumed population rates fit a real study. You should distinguish simulation uncertainty from sampling uncertainty within a trial and uncertainty about the clinical assumptions. The [simulation-precision section](#precision-of-a-simulation) provides a worked example.

For more detail, return to the [power chapter](#power), [sampling-distribution illustration](#alpha-beta), [precision examples](#feasibility), or [common mistakes](#common-mistakes). Methodological sources include Kirkwood and Sterne (2003), Whitley and Ball (2002), and the R documentation cited in the tutorial.
