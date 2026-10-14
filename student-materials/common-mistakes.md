# Common misconceptions and questions {#common-mistakes .core-heading}

::: {.learning-goals .core-outcomes}
Learning outcomes. After this section, you should be able to:

- Distinguish probabilities, observed percentages and percentage-point differences in study reports.
- Explain what statistical significance, power and confidence intervals can and cannot establish.
- Recognize when pilot evidence, a fixed dataset, missing outcomes or dependent observations require a different planning approach.
- Explain why larger samples, more simulations and different calculation methods address different sources of uncertainty.
:::



## Does "20% better" mean 20 percentage points? {.core-heading}

The meaning depends on the starting percentage and whether the change is relative or absolute. From a baseline of 80%, a 20% relative increase gives 96%; an absolute increase of 20 percentage points gives 100%. The two-proportion calculator needs the event percentage in each group. R code represents these percentages as probabilities between zero and one, such as 0.80 for 80%. The [discharge example](#discharge) lets you compare these interpretations.

## Can I put a clinically important difference directly into the alternative hypothesis? {.core-heading}

For the ordinary two-sided superiority test, the alternative is any nonzero difference. Power is evaluated at a particular planned effect. Rejecting zero does not show that the true benefit exceeds the clinical threshold. You should interpret the effect estimate and confidence interval in relation to both zero and the clinical threshold.

## Does planning for 90% power cover every clinically worthwhile difference? {.core-heading}

No. Power is evaluated at the specified target difference. If that target exceeds the smallest clinically important difference, power will generally be lower at some worthwhile benefits. Your justification should explain why the target is important and realistic, including how the study would perform at the clinical threshold. The expected difference, target difference and clinical threshold may coincide, but each has a different role.

## Does a non-significant result establish that treatments are the same? {.core-heading}

No. An interval might include both negligible and important effects. Your interpretation should consider the whole interval and the design's limitations. Equivalence and non-inferiority ask different questions and require their own margins, hypotheses and planning methods.

## Do error probabilities tell me whether a hypothesis is true? {.core-heading}

No. The [Type I error probability](#alpha) is the probability of falsely rejecting the null: a false positive when no population difference exists. The [Type II error probability](#beta) is the probability of missing a specified true difference: a false negative. These probabilities describe how the test performs when you assume what is true in the population. They do not tell you the probability that a hypothesis is true after seeing your result. The [sampling-distribution example](#alpha-beta) illustrates the distinction.

## Does 90% power guarantee a useful result? {.core-heading}

No. With [90% power](#statistical-power), about 90% of hypothetical independent studies under the specified effect, design and analysis would reject the null hypothesis. An individual study can be inconclusive, and a significant study can have an interval too wide for a clinical decision. Power, anticipated precision and the observed confidence interval provide complementary information.

## Can I use my small pilot's effect estimate without qualification? {.core-heading}

Your planning assumptions should reflect its uncertainty and the wider evidence. Small pilots can give unstable treatment estimates; selecting only promising pilots can introduce further bias. Pilot planning should follow feasibility objectives and useful precision for those objectives. See the [practical pilot case](#pilot-feasibility) and [Albers and Lakens (2018)](https://doi.org/10.1016/j.jesp.2017.09.004).

## Is 50% a safe default when the event probability is unknown? {.core-heading}

Its conservative role here is limited to absolute precision for one proportion under the displayed normal approximation: it maximizes p(1-p). It is not a general fallback for unknown treatment/control probabilities, prediction-model planning, relative precision or rare-event questions. See the [single-proportion example](#prevalence).

## My study is retrospective: should I calculate observed power instead of sample size? {.core-heading}

If the records already exist, your report should explain why that sample is available and present the estimate, confidence interval and limitations. Using the same data's observed effect in a power calculation adds no evidence about that result. At independently justified effects, sensitivity analysis can describe the fixed design's performance. For example, 200 existing records may be useful for estimating a prevalence even when they do not support a precise adjusted treatment effect. "Retrospective" describes timing; it does not by itself select a statistical test. See [Althouse (2021)](https://pubmed.ncbi.nlm.nih.gov/32814615/) and [Lakens (2022)](https://doi.org/10.1525/collabra.33267).

## Why do the hand formula, R and another calculator give different numbers? {.core-heading}

Differences can arise from the outcome, allocation, whether the test is one-sided or two-sided, effect scale, Type I error probability, target power, test assumptions, continuity correction or rounding. These settings should match before you compare calculator results. The simple mean calculator uses a normal approximation; the [lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) plans for a pooled t test. Binary analytical power remains an approximation and can differ from finite-sample simulation. A numerical difference is not automatically a software error.

## Can I count two visits, two eyes or patients in one allocated ward as independent observations? {.core-heading}

Usually not. The appropriate calculation depends on what receives the intervention and how measurements are related. A paired design uses within-pair information; cluster allocation requires accounting for within-cluster correlation. The [study-design guide](#study-designs) can help you choose a suitable approach; entering every record as an independent patient would overstate the available information.

## Should I add 10% for expected 10% dropout? {.core-heading}

With 10% expected loss, you should divide the required analyzable count by 1 - 0.10, then round upward within each arm. This is about 11.1% extra before rounding. The actual number retained can differ from expectation, and missing outcomes can bias results even after recruitment inflation.

## Is more simulation the same as a larger study? {.core-heading}

Increasing B, the number of simulated studies, estimates power, interval coverage and other performance measures more precisely. Increasing n, the patients per study, changes the amount of patient information in each study and therefore changes its power and precision. Your report should distinguish these quantities and include both, along with the random seed.

## Will a larger sample solve bias? {.core-heading}

A larger sample reduces sampling variation under the model. It does not automatically repair selection bias, confounding, unreliable measurements, missing-data bias or an inappropriate analysis. A defensible design is necessary before a sample size calculation can be useful.

## Is a reporting checklist a sample-size method? {.core-heading}

No. CONSORT, STROBE, STARD, ARRIVE and TRIPOD help document different studies. They prompt you to report how sample size was chosen, but do not provide one universal formula. The [study-design guide](#study-designs) separates reporting resources from planning methods.

<div class="chapter-recap">

### Take-home points {.unnumbered}

- Statistical significance, clinical importance, and precision answer different questions.
- Power concerns a design under specified assumptions; it does not establish that those assumptions are true.
- More patients cannot automatically remove bias or repair an inappropriate analysis.

### Check your understanding {.unnumbered}

1. Does a non-significant treatment comparison establish equivalence?

<details class="model-answer">
<summary>Model answer</summary>

No. The study may be inconclusive. Equivalence needs an appropriate design and analysis with justified equivalence margins.

</details>

2. If a large study detects a very small difference, what else matters for interpretation?

<details class="model-answer">
<summary>Model answer</summary>

The size and uncertainty of the difference, its clinical importance, harms and burden, and the credibility of the design and analysis.

</details>

</div>
