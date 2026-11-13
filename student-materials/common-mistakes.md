# Common misconceptions and questions {#common-mistakes .unnumbered .reference-heading}

These optional explanations support both routes. Each question links to a difficulty that may arise while reading or planning a study.

<details class="misconception" id="does-20-better-mean-20-percentage-points">
<summary>Does "20% better" mean 20 percentage points?</summary>

The meaning depends on the starting percentage and whether the change is relative or absolute. From a baseline of 80%, a 20% relative increase gives 96%; an absolute increase of 20 percentage points gives 100%. The two-proportion calculator needs the event percentage in each group. R code represents these percentages as probabilities between zero and one, such as 0.80 for 80%. The [discharge example](#discharge) lets you compare these interpretations.

</details>

<details class="misconception" id="can-i-put-a-clinically-important-difference-directly-into-the-alternative-hypothesis">
<summary>Can I put a clinically important difference directly into the alternative hypothesis?</summary>

For the ordinary two-sided superiority test, the alternative is any nonzero population difference. Power is evaluated at the specified target difference. The [hypotheses section](#power) explains this distinction; the [interval examples](#interpret-a-confidence-interval-clinically) show how to assess clinical importance.

</details>

<details class="misconception" id="does-planning-for-90-power-cover-every-clinically-worthwhile-difference">
<summary>Does planning for 90% power cover every clinically worthwhile difference?</summary>

Power is evaluated at the specified target difference. With the same baseline probability, sample and test, power is lower at a smaller true difference, even when it matters clinically. The [planning example](#what-do-we-expect-what-will-we-plan-for-and-what-matters-clinically) explains this choice; [power curves](#activity-2-can-the-feasible-study-answer-the-question) show its consequences.

</details>

<details class="misconception" id="does-a-non-significant-result-establish-that-treatments-are-the-same">
<summary>Does a non-significant result establish that treatments are the same?</summary>

A nonsignificant result can be compatible with both negligible and important differences. The [confidence-interval examples](#interpret-a-confidence-interval-clinically) help interpret that uncertainty. [Equivalence and noninferiority](#noninferiority-equivalence) require their own margins, hypotheses and calculations.

</details>

<details class="misconception" id="do-error-probabilities-tell-me-whether-a-hypothesis-is-true">
<summary>Do error probabilities tell me whether a hypothesis is true?</summary>

No. The [Type I error probability](#alpha) is the probability of falsely rejecting the null: a false positive when no population difference exists. The [Type II error probability](#beta) is the probability of missing a specified true difference: a false negative. These probabilities describe how the test performs when you assume what is true in the population. The [sampling-distribution example](#alpha-beta) illustrates the distinction.

</details>

<details class="misconception" id="does-90-power-guarantee-a-useful-result">
<summary>Does 90% power guarantee a useful result?</summary>

No. With [90% power](#statistical-power), about 90% of hypothetical independent studies under the specified effect, design and analysis would reject the null hypothesis. An individual study can be inconclusive, and a significant study can have an interval too wide for a clinical decision. Power, anticipated precision and the observed confidence interval provide complementary information.

</details>

<details class="misconception" id="can-i-use-my-small-pilots-effect-estimate-without-qualification">
<summary>Can I use my small pilot's effect estimate without qualification?</summary>

Your planning assumptions should reflect its uncertainty and the wider evidence. Small pilots can give unstable treatment estimates; selecting only promising pilots can introduce further bias. Pilot planning should follow feasibility objectives and useful precision for those objectives. See the [practical pilot case](#pilot-feasibility) and [Albers and Lakens (2018)](https://doi.org/10.1016/j.jesp.2017.09.004).

</details>

<details class="misconception" id="is-50-a-safe-default-when-the-event-probability-is-unknown">
<summary>Is 50% a safe default when the event probability is unknown?</summary>

For the single-proportion normal approximation at fixed absolute precision, 50% maximizes $p(1-p)$ and gives the largest requirement. The [prevalence example](#prevalence) shows this relationship. For a two-group power calculation, both event percentages need evidence and [sensitivity analysis](#stress-test-the-study-plan).

</details>

<details class="misconception" id="my-study-is-retrospective-should-i-calculate-observed-power-instead-of-sample-size">
<summary>My study is retrospective: should I calculate observed power instead of sample size?</summary>

With an existing dataset, your report should explain the available sample, the attainable precision and the limits of the new question. Observed-effect post hoc power adds no evidence about the same result. The [dataset-reuse example](#dataset-reuse) shows an appropriate assessment [@althouse2021; @lakens2022].

</details>

<details class="misconception" id="why-do-the-hand-formula-r-and-another-calculator-give-different-numbers">
<summary>Why do the hand formula, R and another calculator give different numbers?</summary>

The methods, assumptions, sidedness, corrections and rounding should match before results are compared. The [software example](#gpower-assumptions) shows why input definitions matter; the [simulation benchmark](#compare-simulation-with-a-planning-approximation) examines approximation differences.

</details>

<details class="misconception" id="can-i-count-two-visits-two-eyes-or-patients-in-one-allocated-ward-as-independent-observations">
<summary>Can I count two visits, two eyes or patients in one allocated ward as independent observations?</summary>

Usually not. The appropriate calculation depends on what receives the intervention and how measurements are related. A paired design uses within-pair information; cluster allocation requires accounting for within-cluster correlation. The [study-design guide](#study-designs) can help you choose a suitable approach; entering every record as an independent patient would overstate the available information.

</details>

<details class="misconception" id="should-i-add-10-for-expected-10-dropout">
<summary>Should I add 10% for expected 10% dropout?</summary>

With 10% expected loss, the recruitment requirement is the analyzable count divided by 0.90, rounded upward within each group: about 11.1% extra before rounding. The [recruitment calculation](#account-for-expected-losses) illustrates the arithmetic.

</details>

<details class="misconception" id="is-more-simulation-the-same-as-a-larger-study">
<summary>Is more simulation the same as a larger study?</summary>

More simulation repetitions give a more precise estimate of performance. More patients change the information, power and precision of each trial. The [simulation-precision section](#precision-of-a-simulation) distinguishes these two counts.

</details>

<details class="misconception" id="will-a-larger-sample-solve-bias">
<summary>Will a larger sample solve bias?</summary>

A larger sample reduces sampling variability. Selection, confounding and missing-data bias require appropriate design and analysis. In the [missing-outcome simulation](#explore-missing-outcomes), extra recruitment leaves bias caused by selective missingness in place.

</details>

<details class="misconception" id="is-a-reporting-checklist-a-sample-size-method">
<summary>Is a reporting checklist a sample-size method?</summary>

No. CONSORT, STROBE, STARD, ARRIVE and TRIPOD help document different studies. They prompt you to report how sample size was chosen. The [study-design guide](#study-designs) separates reporting resources from planning methods.

</details>
