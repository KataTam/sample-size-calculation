# Software and numerical validation

The student resource uses reproducible R calculations and browser apps. The tutorial and apps share the functions in `R/sample_size_functions.R`; the exported browser apps run those calculations through Shinylive/webR.

## What agreement does and does not establish

The same inputs should produce consistent results across the tutorial and matching app. Because they share code, this agreement is a consistency check rather than independent validation of the statistical method. Statistical checks use separate reference analyses and simulated operating characteristics.

Two answers should only be compared after matching the intended hypothesis, test, allocation, variance assumptions, sidedness, significance level, target power, continuity correction, interval method and rounding. A different procedure may legitimately give a different answer.

## Methods used here

| Activity | Planning and analysis |
|---|---|
| Reasoning lab: two means | Two independent groups with equal allocation; common normal SD; pooled-variance two-sided t test and t interval. Analytical power uses `stats::power.t.test(..., strict = TRUE)`. |
| Reasoning lab: two proportions | Equal allocation; normal-approximation planning through `stats::power.prop.test(..., strict = TRUE)`; simulations use a pooled score test without continuity correction and a Newcombe-Wilson interval for the difference. Approximate analytical power need not equal finite-sample rejection probability. |
| Small two-means/two-proportions calculators | Introductory normal sample-size approximations. Their results can be transferred to the lab as a fixed analysable sample size; the lab then evaluates its stated test rather than silently selecting a new sample. |
| Dropout adjustment | Divide the required analysable count in each group by its expected retention fraction, round up per group, then double. This does not remove missing-data bias or guarantee the realised count. |
| Single-proportion precision / pilot retention | One population proportion; normal-approximation planning using full width twice the margin of error. The no-estimate option uses .50 for planning. Realised binomial samples are displayed with Wilson intervals; the planning width is not a guarantee of realised interval width. A fixed-resource pilot is assessed at its given count. |
| Alpha, beta and sampling distributions | One-sample normal mean with independent observations and known population SD. Normal tail areas give Type I error, beta and power at the specified alternative. The distributions shown are distributions of sample means; this is a teaching model rather than an unknown-SD t-test calculation. |

See the [statistical methods](statistical-methods.md) for assumptions and precision definitions. In R's two-sided power functions, `strict = TRUE` counts rejection in either direction, including under a zero true effect. [R t-test power documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/power.t.test.html), [R proportion power documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/power.prop.test.html)

## Reproducible checks

`scripts/check_simulation.R` checks normal-study p-values and intervals against `stats::t.test(..., var.equal = TRUE)`, and binary p-values against `stats::prop.test(..., correct = FALSE)`. It also compares small-sample binary simulation results with enumeration of every possible pair of event counts, weighted by their binomial probabilities. Repeated-study checks examine rejection probability, interval coverage, anticipated width, null scenarios, rounding, seeds and boundary event counts.

These checks assess the stated methods under the stated generating models. They do not establish applicability to every medical study design or robustness to departures from those models. Monte Carlo comparisons allow for finite-replication error; analytical approximations should not be required to match simulated rates to arbitrary decimal precision.

`scripts/check_activity.R` additionally checks activity routing, validated state transfer, portable study-plan files, feasibility calculations and preservation of saved-result assumptions. Restoring a plan does not restore or regenerate its simulation results.

`scripts/check_feedback.R` checks the single-proportion planning inversion and Wilson intervals against R reference intervals, including zero/all-event samples, and compares known-SD normal error probabilities with numerical density integration. It also checks the specialist activity servers. Enumeration of binomial outcomes illustrates that nominal planning width and realised Wilson width attainment are different quantities.

## Optional external software comparisons

PASS 2022 can provide an additional reference if it is already available to the teacher. It is not a dependency for students or for rebuilding the resource. A comparison must record the exact PASS procedure and settings rather than treating the product name as a statistical method. PASS supplies integrated method documentation and reports. [Official PASS information](https://www.ncss.com/software/pass/)

**PASS 2022 comparison status: NOT RUN.** No external PASS result is claimed in this resource. This table is a recording template for a future check:

| Scenario | R method to match | Settings to record | PASS result/status |
|---|---|---|---|
| Score difference: 3; SD: 5; two-sided alpha: .05; power: .80 | Equal-size pooled t test | Procedure, variance assumptions, allocation and whether both rejection tails are counted | NOT RUN |
| Event probabilities: .30 and .60; alpha: .05; power: .90 | Approximate independent-proportion test | Exact/approximate procedure, pooled/nonpooled variance, continuity correction and allocation | NOT RUN |
| Fixed sample: 60 per group, same event probabilities | Score-test finite-sample rejection rate | Compare the stated test with its simulation/enumeration, allowing for Monte Carlo uncertainty | NOT RUN |

For each external check, save the software version, procedure, inputs, unrounded sample size where available, rounded analysable counts per group, recruitment adjustment, output/report and reason for any discrepancy. Do not require agreement between different tests merely because both compare proportions.

G*Power is also a possible reference for methods it supports. It has a statistical manual, a short tutorial and methodological publications; excluding a walkthrough from the core module is a teaching choice, not a lack of documentation. G*Power is free to use, though that is different from providing open reusable source code. [Official G*Power documentation and terms](https://www.psychologie.hhu.de/arbeitsgruppen/allgemeine-psychologie-und-arbeitspsychologie/gpower)

## Reporting a study plan

State the clinical question, primary outcome and planned analysis; planning effect and variability or probabilities; evidence and sensitivity scenarios; alpha, power or full interval-width target; allocation; analysable and recruitment counts; expected losses; feasibility and cost assumptions; software/functions and versions; and the limits of what the proposed study could establish. Preserve the written justification as well as the calculation.

The lab's JSON download stores inputs and notes locally so the plan can be reloaded. The text and R-script downloads support communication and reproduction. Files are not a shared learner record or a central submission system.
