# Activity walkthroughs

These walkthroughs connect each activity to the question it helps answer. The clinical values are hypothetical teaching assumptions. The simulations generate hypothetical patient outcomes from specified population assumptions.

In the reasoning lab, planning tables and curves update when inputs change. Simulated results update only when you run the relevant simulation again and retain their saved assumptions until then. The same inputs and random seed reproduce the same result; a different seed gives another possible result. More patients change a study's information; more simulation repetitions improve the numerical precision of the estimated performance.

The expected difference records your best expectation. With “Same as planning assumptions” selected, the simulations use the target difference and planning event probabilities. A custom population scenario lets you examine another true difference without changing the original plan. All treatment differences here are between-group differences.

## Develop and justify your study plan

[Open activity](../study/?activity=assumptions_report) · [Matching explanation](../book/clinical-question.html#record-assumptions)

Purpose: connect the calculation to a clinical question, evidence and a defensible recommendation.

1. You can select the study structure, outcome and planning goal, then describe the question and why it matters.
2. Your assumptions should include their sources and uncertainty. For a treatment comparison, the expected difference, target difference and clinical threshold have separate roles.
3. After using an appropriate calculator, you can enter its method, analyzable sample and recruitment allowance. A simulation result should include its generating assumptions and repetition count.
4. The report on the right assembles your entries. You should review it for missing information and distinguish a numerical result from your interpretation.
5. “Save entries” preserves an editable file; “Download report” saves the written report. The pain-relief example illustrates a completed starting point and does not verify your own plan.

## Chronic pain: one study and many studies — core

[Open activity](../study/?activity=pain_one_many) · [Matching explanation](../book/power.html#activity-1-one-study-then-many)

Purpose: see why sample estimates differ from population values, and why one trial cannot display a design's power.

1. The starting population has 30% relief with standard treatment and 60% with novel treatment, with 20 analyzable patients per group and a 5% Type I error probability.
2. In “One study,” “Simulate one study” generates patient outcomes. You can compare the observed percentages, difference and interval with the specified population values.
3. After changing only the random seed, another run shows another possible trial. The population probabilities have not changed.
4. In “Many studies,” “Simulate many studies” generates 5,000 independent trials. The distribution shows sampling variability; the percentage of significant results estimates power for this population scenario.
5. You can repeat at 50 and 80 patients per group while holding the population assumptions and repetition count fixed. Larger trials usually give narrower intervals and greater power. Coverage and Monte Carlo summaries can wait until the advanced chapter.

## Type I and Type II error probabilities and power — advanced

[Open activity](../study/?activity=alpha_beta) · [Matching explanation](../book/power.html#alpha-beta)

Purpose: connect false positives, false negatives and power with the distributions that underlie repeated-study behavior. The tool calculates the shaded areas from the normal distribution.

1. The example compares a null mean of 120 with an alternative mean of 125 mmHg, known population SD 15 and 25 independent observations.
2. You can locate the rejection boundary and the shaded false-positive area under the null distribution.
3. Under the alternative distribution, the non-rejection area represents false negatives and the rejection area represents power.
4. Increasing the sample size while keeping the means and SD fixed narrows both distributions of the sample mean. You can explain the resulting change in power without claiming that patients have become less variable.
5. Comparing one-sided and two-sided rules illustrates their consequences; the scientific question should determine the rule before data collection. This one-sample known-SD model differs from the two-arm trials elsewhere.

## Two-proportion calculator — core

[Open calculator](../two_proportions/) · [Matching explanation](../book/calculations.html#two-proportions)

Purpose: reproduce the binary-outcome sample size calculation. The calculator uses a normal approximation.

1. For the chronic pain example, you can enter 60% and 30%, Type I error probability 5%, target power 90% and initially no losses.
2. The result is 56 analyzable patients per group. The total and any recruitment adjustment have different denominators and should be recorded separately.
3. Changing one input at a time shows how the required sample responds. The calculation uses the event percentage in each group.
4. The link to the lab transfers this calculated count as a fixed sample. “Many studies” then lets you estimate the performance of the planned test through simulation and compare the estimated power with the planning target.

## Gestational-diabetes prevention trial — core

[Open activity](../study/?activity=adherence) · [Matching explanation](../book/calculations.html#adherence)

Purpose: connect a preventive treatment question to event coding, recruitment feasibility and uncertain treatment benefit.

1. The favorable event is remaining free of gestational diabetes: 80% without probiotics and 90% with probiotics. These correspond to disease percentages of 20% and 10%. The expected difference is 12 percentage points, target difference 10 and clinical threshold 5.
2. In “Explore assumptions,” you can compare the planned count and 15% loss allowance with the recruitment limit of 240.
3. With advanced controls visible, “Custom effect or variability” lets you keep control at 80% but change the simulation's treatment probability to 85%. The original planning probabilities stay at 80% and 90%.
4. “One study” gives a possible result; “Many studies” estimates power under the smaller 5-point true benefit at the original sample size. You should rerun after changing assumptions.
5. Your explanation should distinguish a less favorable true population from a newly calculated study plan. These scenarios are not evidence that probiotics prevent gestational diabetes.

## Two-mean calculator — core

[Open calculator](../two_means/) · [Matching explanation](../book/calculations.html#two-means)

Purpose: see how a target difference and between-patient variability determine an approximate sample size.

1. You can enter target difference 3 units, common SD 5, Type I error probability 5% and target power 90%.
2. With no losses, the normal approximation gives 59 analyzable patients per group.
3. Halving the target difference or doubling the SD approximately quadruples the required count, before rounding.
4. The lab link carries the count across as a fixed sample for simulation. Its pooled t test estimates the common variance, so its power need not exactly equal the calculator's normal-approximation target.

## Rehabilitation: compare two means — core

[Open activity](../study/?activity=rehabilitation) · [Matching explanation](../book/calculations.html#rehabilitation)

Purpose: connect a continuous-outcome calculation with the interpretation of a possible trial result.

1. The hypothetical score has expected between-group improvement difference 4 units, target difference 3, clinical threshold 2 and common SD 5.
2. “Explore assumptions” uses a pooled two-sample t-test plan with 90% target power. You can compare recruitment after 10% losses with the limit of 200.
3. In “One study,” a run generates independent normal improvement scores using the planning difference of 3 units. The observed difference and interval vary across seeds.
4. You can compare the interval with zero and the 2-unit threshold. A significant result does not necessarily establish a benefit above that threshold.
5. “Many studies” shows how often conclusions vary across repetitions. Each patient contributes one improvement score to the comparison of two independent treatment groups.

## Chronic pain: power and recruitment — advanced

[Open activity](../study/?activity=pain_curves) · [Matching explanation](../book/curves.html#activity-2-can-the-feasible-study-answer-the-question)

Purpose: assess whether the feasible study can answer the intended question under less favorable assumptions.

1. The activity fixes the analyzable sample at 90 per group: 200 recruited with 10% expected loss gives 180 expected analyzable participants.
2. “Explore assumptions” shows analytical curves for the 30-point target difference and smaller 20- and 15-point differences. You can compare their power with the 90% target.
3. With advanced controls visible, a custom simulation scenario of control 30% and treatment 50% or 45% keeps the original sample fixed while changing the true difference.
4. “Many studies” estimates power from generated patient data for the selected scenario.
5. Your recommendation should address what the recruitment ceiling could establish and the uncertainty in the assumptions. Changing the clinical threshold alone does not change power for a test of zero difference.

## Repeated chronic-pain trials — advanced

[Open activity](../study/?activity=pain_simulation) · [Matching explanation](../book/simulation.html#activity-3-generate-analyze-repeat-summarize)

Purpose: extend the core simulation from power to confidence interval coverage, interval width and simulation uncertainty.

1. The activity starts in “Many studies,” with 60 analyzable patients per group, relief probabilities 30% and 60%, 5,000 repetitions and target full interval width 30 percentage points.
2. You can first visit “One study” to inspect one generated dataset, its estimated difference, interval and test result.
3. After “Simulate many studies,” you can examine the rejection percentage, coverage of the specified true difference and percentage meeting the width target. These answer different questions.
4. A custom treatment probability of 45%, with control still 30%, tests the plan under a 15-point true difference. A no-effect scenario estimates the false-positive probability.
5. You can vary the repetition count while leaving patients per group fixed. More repetitions reduce Monte Carlo uncertainty while each trial's design stays fixed. A report should retain the seed, generating assumptions, analysis and repetition count.

## Recruitment adjustment — core

[Open calculator](../dropout_adjustment/) · [Matching explanation](../book/feasibility.html#account-for-expected-losses)

Purpose: translate an analyzable requirement into a recruitment allowance.

1. For the chronic-pain example, the analyzable requirement is 56 patients per group.
2. At 10% expected loss, the result is 63 recruits per group, or 126 total, after rounding upward within each group.
3. Comparing 0%, 10% and 20% losses shows how recruitment changes while the analyzable requirement stays fixed.
4. Your interpretation should acknowledge that actual retention varies and that recruiting more participants does not remove missing-data bias. The lab link transfers the analyzable count per group.

## Estimate a mean difference with a precision target — advanced

[Open activity](../study/?activity=mean_precision) · [Matching explanation](../book/feasibility.html#plan-for-precision)

Purpose: distinguish a goal of detecting a difference from a goal of estimating it precisely.

1. The activity uses expected difference 4 units, target difference 3, common SD 5, clinical threshold 2 and target full interval width 4 units.
2. “Explore assumptions” calculates the sample for the interval-width goal. You can compare it with the count for 80% target power by switching the planning goal.
3. Returning to the precision goal, “One study” generates a realized interval. Its width need not equal the anticipated width.
4. “Many studies” estimates the percentage meeting the full-width target. A full width of 4 corresponds to a margin of about 2 for a symmetric interval.
5. Your justification should explain which interval widths would be useful and whether both power and precision requirements matter for the question.

## Estimate a population percentage — advanced

[Open activity](../study/?activity=prevalence) · [Matching explanation](../book/feasibility.html#prevalence)

Purpose: connect the precision needed for a descriptive decision with survey size and a possible realized estimate.

1. The example anticipates 20% prevalence and a 95% interval with full width 10 percentage points, equivalent to a margin of 5 points.
2. The formula gives 246 completed observations. Reducing full width to 5 points, a margin of 2.5, requires about four times as many.
3. The 50% conservative-planning option changes the probability used for sample size planning. The anticipated percentage remains the generating probability for the illustrative simulation.
4. “Draw one illustrative sample” generates a binomial count and a Wilson interval. A different seed gives another sample; the realized interval need not meet the planning width.
5. Your explanation should distinguish interval precision from representativeness. Here, n is the total number of participants in the sample.

## Pilot study: retention — advanced

[Open activity](../study/?activity=pilot_feasibility) · [Matching explanation](../book/feasibility.html#pilot-feasibility)

Purpose: assess whether a limited pilot provides useful information for a feasibility decision.

1. The starting goal is to assess a fixed sample of 40 participants with anticipated retention of 80%.
2. “Draw one illustrative sample” generates a possible retained count and its Wilson interval. The simulated retention count varies around its expected value of 32.
3. You can compare another seed and then a fixed sample of 80. More participants generally provide more information about retention, but obtaining them requires a feasible plan.
4. Retained and non-retained participants both belong in the denominator when their status is known. Loss adjustment is appropriate only for participants whose outcome status itself cannot be established.
5. Your report should relate the interval and its uncertainty to the prespecified feasibility decision.

## Discharge percentages — core calculation, optional simulation extension

[Open activity](../study/?activity=discharge) · [Matching explanation](../book/exercises.html#discharge)

Purpose: distinguish relative changes from percentage-point differences and investigate planning close to 100%.

1. The planning probabilities are 80% and 96% discharge: a 16-percentage-point target difference and a 20% relative increase. The separate expected difference is 18 points and clinical threshold 8.
2. “Explore assumptions” calculates the sample for 80% power at a 5% Type I error probability, with no loss allowance in the prepared case.
3. “One study” shows possible discharge counts; “Many studies” estimates the planned test's power when one event probability is near 100%.
4. A no-effect generating scenario checks false positives without changing the original sample size. Comparing simulation and planning results helps assess the approximation under these assumptions.
5. Your explanation should identify the event, baseline and absolute difference. A time-to-discharge outcome would need a different method.

## Build your own study calculation — advanced application

[Open activity](../study/?activity=own_study) · [Matching explanation](../book/exercises.html#own-study)

Purpose: bring together the clinical question, numerical requirements and practical constraints.

1. In “My study,” you can describe the question, design, evidence, participant burden and resources. The numerical model supports two independent, equally sized groups; selecting another design does not make this model suitable for it.
2. For a supported design, you can select testing, interval-width planning or a fixed available sample and enter justified assumptions in “Explore assumptions.” Other designs require an appropriate external calculation.
3. The recruitment and cost inputs help assess feasibility. Using expected recruitment as the lab limit does not make the resulting count guaranteed.
4. For a supported design, “One study” and “Many studies” can examine possible results and performance. Sensitivity scenarios should change the assumed population while retaining the original plan when that is the question.
5. In “Justify and communicate,” you can save inputs and explanations, download reproducible code or simulation results, and transfer the relevant findings into the assumptions report. A saved plan is distinct from saved simulation output.

Teaching text: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Original software code: [MIT](https://opensource.org/license/mit). Third-party attributions and exceptions remain applicable.
