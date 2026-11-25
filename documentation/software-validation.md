# Software and numerical validation

The student resource uses reproducible R calculations and browser apps. The tutorial and apps share the functions in `R/sample_size_functions.R`; the exported browser apps run those calculations through Shinylive/webR.

## What agreement establishes

The same inputs should produce consistent results across the tutorial and matching app. Their shared code makes this a consistency check. Independent validation requires a separate implementation or reference calculation. Statistical checks use separate reference analyses and simulated operating characteristics.

Two answers should only be compared after matching the intended hypothesis, test, allocation, variance assumptions, sidedness, significance level, target power, continuity correction, interval method and rounding. A different procedure may legitimately give a different answer.

## Methods used here

| Activity | Planning and analysis |
|---|---|
| Reasoning lab: two means | Two independent groups with equal allocation; common normal SD; pooled-variance two-sided t test and t interval. Analytical power uses `stats::power.t.test(..., strict = TRUE)`. |
| Reasoning lab: estimation | One population mean or percentage; total sample size selected for expected t-interval width or plug-in Wilson width. Independent interval checks, simulation coverage, current-input reports and saved-work restoration are in `scripts/check_single_population.R`. |
| Reasoning lab: two proportions | Equal allocation; normal-approximation planning through `stats::power.prop.test(..., strict = TRUE)`; simulations use a pooled score test without continuity correction and a Newcombe-Wilson interval for the difference. Approximate analytical power need not equal finite-sample rejection probability. |
| Small two-means/two-proportions calculators | Two-means planning uses `stats::power.t.test(..., type="two.sample", alternative="two.sided", strict=TRUE)`; two-proportion planning uses `stats::power.prop.test(..., strict=TRUE)`. Each result is rounded upward per group. Transfers preserve this count as a fixed sample for simulation in the lab. |
| Recruitment adjustment | The optional complete-switching approximation multiplies the starting requirement by 1/(1-a-b)^2. Each group has its own retained fraction; the larger recruitment requirement is rounded upward once and doubled for equal allocation. Expected retained counts, missing-data assumptions and approximation limits are reported separately. |
| Single-proportion precision / pilot retention | One population proportion; normal-approximation planning using full width twice the margin of error. The no-estimate option uses .50 for planning. Realized binomial samples are displayed with Wilson intervals; the planning width is not a guarantee of realized interval width. A fixed-resource pilot is assessed at its given count. |
| Alpha, beta and sampling distributions | One-sample normal mean with independent observations and known population SD. Normal tail areas give Type I error, beta and power at the specified alternative. The distributions shown are distributions of sample means; this is a teaching model rather than an unknown-SD t-test calculation. |

See the [statistical methods](statistical-methods.md) for assumptions and precision definitions. In R's two-sided power functions, `strict = TRUE` counts rejection in either direction, including under a zero true effect. [R t-test power documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/power.t.test.html), [R proportion power documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/power.prop.test.html)

## Reproducible checks

`scripts/check_simulation.R` checks normal-study p-values and intervals against `stats::t.test(..., var.equal = TRUE)`, and binary p-values against `stats::prop.test(..., correct = FALSE)`. It also compares small-sample binary simulation results with enumeration of every possible pair of event counts, weighted by their binomial probabilities. Repeated-study checks examine rejection probability, interval coverage, anticipated width, null scenarios, rounding, seeds and boundary event counts.

These checks assess the stated methods under the stated generating models. They do not establish applicability to every medical study design or robustness to departures from those models. Monte Carlo comparisons allow for finite-replication error; analytical approximations should not be required to match simulated rates to arbitrary decimal precision.

`scripts/check_activity.R` additionally checks activity routing, validated state transfer, portable study-plan files, feasibility calculations and preservation of saved-result assumptions. Restoring a plan does not restore or regenerate its simulation results.

`scripts/check_feedback.R` checks the single-proportion planning inversion and Wilson intervals against R reference intervals, including zero/all-event samples, and compares known-SD normal error probabilities with numerical density integration. It also checks the specialist activity servers. Enumeration of binomial outcomes illustrates that nominal planning width and realized Wilson width attainment are different quantities.

## Direct checks in G*Power and PASS 2022

The following calculations were run on 25 November 2026 in G*Power 3.1.9.7 and PASS 2022 version 22.0.8. The recorded values are outputs observed in those applications. All counts below refer to analyzable participants. The separate dropout fields in PASS were excluded from this comparison.

The two-group checks used equal allocation, two-sided tests, Type I error probability 0.05 and target power 0.90. G*Power used “A priori: Compute required sample size”. PASS solved for sample size.

| Example | Software and exact procedure | Additional settings | Observed result |
|---|---|---|---|
| Two percentages | G*Power, z tests, Proportions: Difference between two independent proportions | p1 = 0.30, p2 = 0.60, allocation ratio 1, continuity correction off, arcsine transform off | 56 per group, 112 total. Power 0.9016504. |
| Two percentages | PASS, Tests for Two Proportions | P1 = 0.60, P2 = 0.30, Normal Approximation, Z-Test (Pooled) | 56 per group, 112 total. Power 0.90165. |
| Continuity correction sensitivity check | G*Power, same z-test procedure | Same inputs, continuity correction on, arcsine transform off | 62 per group, 124 total. |
| Two means | G*Power, t tests, Means: Difference between two independent means (two groups) | Cohen's d = 3/5 = 0.60, allocation ratio 1 | 60 per group, 120 total. Power 0.9031154. |
| Two means | PASS, Two-Sample T-Tests Assuming Equal Variance | Means 3 and 0, common SD 5 | 60 per group, 120 total. Power 0.90312. |
| One percentage | PASS, Confidence Intervals for One Proportion | Simple Asymptotic, Two-Sided, confidence 0.95, P = 0.20, full width 0.10 | 246 total. Width 0.09997, limits 0.15001 to 0.24999. |
| One mean | PASS, Confidence Intervals for One Mean | Two-Sided, infinite population, confidence 0.95, distance to limits 2, SD 5, known SD unchecked | 27 total. Half-width 1.97793, full width 3.95586. |

The G*Power precision procedures were not compared. PASS supplies dedicated confidence interval procedures for these checks. The recorded outputs are also retained in [a machine-readable validation record](../data/software-validation.json).

### How the results compare with R

The tutorial's independent-proportion normal approximation gives 56 per group and power 0.9016504 at that rounded count. The pooled t-test calculation gives 60 per group and power 0.9031154. Both agree with the matched external procedures. The teaching normal approximation for two means gives 59 per group because it uses a normal critical value in place of the t-test calculation that accounts for estimating the SD.

The normal calculation for one percentage gives 246 total, agreeing with PASS. This check concerns the planning approximation. The app's intervals around observed percentages use Wilson's method.

For one mean, three width criteria explain the three counts:

| Method | Count | Width criterion |
|---|---|---|
| Teaching normal formula | 25 | A fixed SD of 5 and the normal critical value 1.96 give an unrounded requirement of 24.01. |
| Tutorial app, expected t-interval width | 26 | Full width averaged over normally distributed samples is 3.99891 units. The calculation includes the sampling distribution of the sample SD. |
| PASS unknown-SD procedure | 27 | The t critical value is used with the entered sample SD held at 5. The resulting full width is 3.95586 units. |

At 26 observations, holding the sample SD at 5 gives a full t-interval width slightly above four. Averaging over its sampling distribution gives a slightly smaller width because the mean sample SD is below the population SD. The chosen width criterion should therefore be recorded with the result.

Selecting a continuity correction in G*Power raises the two-percentage requirement from 56 to 62 per group. That is a different planning procedure. A comparison should preserve this setting alongside sidedness, allocation, input scale, approximation and rounding.

### Keeping the checks reproducible

`scripts/check_calculation_validation.R` compares the tutorial functions with the recorded external counts and rounded powers. It also checks the two distinct mean-width criteria, the normal planning count and the Wilson intervals shown in the glossary against R's independent score-test implementation. It is run by `scripts/check_resource.R`, so changes to the numerical functions are checked against these saved benchmarks.

A new software version or changed method should be checked with matching inputs and the original output retained. For a method without a suitable independent calculator, a published worked example, direct derivation or simulation of the planned analysis can supply a benchmark. The [tutorial's validation section](../book/appendix.html#validating-calculations) explains the design and directional checks that accompany numerical agreement.

Procedure documentation: [G*Power manual](https://www.psychologie.hhu.de/fileadmin/redaktion/Fakultaeten/Mathematisch-Naturwissenschaftliche_Fakultaet/Psychologie/AAP/gpower/GPowerManual.pdf), [PASS two proportions](https://www.ncss.com/wp-content/themes/ncss/pdf/Procedures/PASS/Tests_for_Two_Proportions.pdf), [PASS one-proportion intervals](https://www.ncss.com/wp-content/themes/ncss/pdf/Procedures/PASS/Confidence_Intervals_for_One_Proportion.pdf), [PASS one-mean intervals](https://www.ncss.com/wp-content/themes/ncss/pdf/Procedures/PASS/Confidence_Intervals_for_One_Mean.pdf).

The tutorial's worked example, [Beware of your assumptions in every calculation tool or software you use](../book/appendix.html#gpower-assumptions), uses the existing 3-unit target difference and SD 5 to distinguish Cohen's d = 0.60 from Cohen's f = 0.30. Its counts and power are reproduced in R with noncentral t and F distributions for two independent, equally sized groups, a common SD and no covariate adjustment. The example also records the matching G*Power procedures. The software's manual, introductory tutorial and methodological publications provide further details. [Official G*Power documentation and terms](https://www.psychologie.hhu.de/arbeitsgruppen/allgemeine-psychologie-und-arbeitspsychologie/gpower)

## Recording the calculation

The sample size calculation report should record the clinical question, primary outcome and planned analysis; target difference and variability or event probabilities; evidence and sensitivity scenarios; Type I error probability, power or full interval-width target; allocation; analyzable and recruitment counts; expected losses; recruitment feasibility; software/functions and versions; and the limits of the intended conclusion. Your written justification should explain these choices.

The lab's PDF and Word reports record the selected example, current calculation, written answers and matching simulation results. Earlier simulation results are omitted with a rerun notice. The optional JSON backup restores settings and answers and clears previous simulations; CSV exports preserve the assumptions of their saved run, while the R script uses the current simulation settings. The [walkthrough download guide](../student-materials/activity-walkthroughs.html#reports-and-saved-work) explains which file serves each purpose.

`scripts/check_app_reports.R` and `scripts/check_app_reports.cjs` check current values, case changes, preserved answers, exclusion of older simulations and correspondence between preview and HTML download. Written explanations should also be reviewed against the current settings because the apps preserve students' wording. Submission through a course's learning platform remains a separate teaching arrangement.
