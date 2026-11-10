# Activity walkthroughs

These walkthroughs connect each activity to the question it helps answer. The clinical values are hypothetical teaching assumptions. The simulations generate hypothetical patient outcomes from specified population assumptions.

Before changing an input, you can predict what the result will do and identify the quantities you will keep fixed. After exploring, your explanation should compare the result with your prediction and note what it means for the study plan.

You can drag a slider or type its value in the adjacent number field. Percentages are entered on the displayed scale, so 5 means 5%. In a narrow app panel, “Study settings” opens the inputs; closing it leaves room for the result and graph. Secondary calculation settings remain available in their expandable groups.

In the reasoning lab, planning tables and curves update when inputs change. Simulated results update only when you run the relevant simulation again and retain their saved assumptions until then. More patients change a study's information; more simulation repetitions improve the numerical precision of the estimated performance.

The difference observed in previous data records a sample result that can inform planning, with uncertainty. It can equal the target difference or clinical threshold; the three roles have no fixed numerical order and each needs justification. With “Same as planning assumptions” selected, the simulations use the target difference and planning event probabilities. A custom population scenario lets you examine another true difference without changing the original plan. All treatment differences here are between-group differences.

## Reports and saved work

“Report” previews the current calculation and any answers you have entered. In the reasoning lab, it also identifies the selected example, feasibility and simulation assumptions. Expandable example answers update with the example and parameters; only your entered responses appear as answers in the report. Your writing is preserved when settings change and should be reviewed against the new results.

The apps remember edited inputs in the same browser. After reopening an app, “Help and saved inputs” offers “Restore previous inputs.” Simulations need to be run again with the restored settings. The study-plan activity opens with empty answers and the core two-group power settings; “Resume saved plan” restores your earlier work. Editing its title or starting point also resumes the saved answers and calculations. Quizzes restore their saved attempts automatically. A downloaded work file provides a backup or lets you continue on another computer.

The reasoning lab and single-percentage app omit saved simulation results from the report when their settings or example no longer match. A message explains which simulation needs rerunning. While the app remains open, its simulation panels and CSV downloads retain the original run and its recorded assumptions until another run replaces it. A downloaded file is a snapshot; after revising your plan, you should save a new report.

| File | What it contains | How you can use it |
|---|---|---|
| Report (PDF) | Current assumptions, calculated results, matching simulated results where available, and your written responses | The default download for reading, sharing, printing or submitting. The study-plan form includes your entries and decisions still to complete. |
| Editable report (Word) | The same report in a .docx document | Open it in Word or another compatible editor to revise or combine with your assignment. Edits in Word remain in that document. |
| Saved work (JSON) | The example, settings and answers needed to resume in the reasoning lab, or entries from the study-plan form | Open “Save work for later,” then use “Reopen saved work” in the same app. The lab clears previous simulations, which should be rerun. |
| Simulation data (CSV) | The saved study or repetitions and the assumptions used to generate them | Open the file in a spreadsheet or analysis program to inspect the saved run. |
| Reproducible script (R) | Code for the reasoning lab's current simulation settings | Run it from the downloaded source folder with its shared R functions; see [Source and reuse](../documentation/reuse-and-citation.md). |

“Save work for later” is separate from the report downloads. Its JSON file can remain unopened on your computer until you reopen it in the app. The study-plan form also accepts its earlier saved HTML reports and JSON entries, and offers a plain-text report. For a class submission, your teacher can specify the report and supporting results needed.

## Develop and justify your study plan

[Open your plan](../assumptions_report/?stage=question) · [Matching explanation](../book/reporting.html#record-assumptions)

1. Your starting point can be your own study or the chronic-pain teaching example. A study title identifies the plan. Answers start empty. “Suggested structure” gives a framework for your own study. Selecting the teaching case shows its example answers; “Start the pain-relief plan” supplies the question and design when you choose it.
2. Chapters 1–3 explain the question and power, calculation, and recruitment. Chapter 4 brings together the reporting guidance, checklist and complete example. You can record decisions in the same activity throughout and review the complete report in Chapter 4.
3. Your evidence review should identify the key uncertain input and its plausible range, including relevant less favorable findings. The sensitivity answer explains how an alternative changes the plan. Each section's “Ready for review” checkbox becomes available when its applicable questions are answered.
4. In an app’s Report view, “Add this calculation to my study plan” opens a preview of the current inputs, result and method. You choose whether to attach it and whether to replace an earlier result of that type. Your written answers remain in place; affected sections are marked for another review.
5. “Review before downloading” lists unresolved decisions and compares the analyzable requirement with the starting count in an attached recruitment calculation. Values written in free text still need your review. Optional simulations can be attached as explorations.
6. The preview and PDF/Word downloads start with a concise sample size calculation report, followed by the supporting study plan, section review and attached results. Both parts update from the same answers; example hints are included only if you use them in an answer. “Save work for later” preserves the editable app state. Entries also persist in the same browser; the saved file supports another computer. The plan is complete for the core assignment when its applicable decisions and calculation have been reviewed. Advanced activities can extend it when relevant.


The [annotated report in Chapter 4](../book/reporting.html#write-a-sample-size-justification) shows the completed two-proportion calculation. The chronic pain example uses 5% expected missing primary outcomes: 56 analyzable patients and 59 recruits per group, or 118 recruits total. Selecting this example makes its prepared calculation and software record available under the software question. Attached calculator results retain their own inputs and runtime versions; example answers for calculation fields follow that selected result. Your written answers should be reviewed when the calculation changes.

## Chronic pain: one study and many studies — core

[Open activity](../study/?activity=pain_one_many) · [Matching explanation](../book/clinical-question.html#activity-1-one-study-then-many)

Purpose: see why sample estimates differ from population values, interpret the uncertainty in one trial, and relate repeated trials to power.

1. The starting population has 30% relief with standard treatment and 60% with novel treatment, with 20 analyzable patients per group and a 5% Type I error probability.
2. In “One study and many studies,” “Simulate one study” generates patient outcomes. The animation follows the patient outcomes into the estimated difference and then the sampling distribution, with the population difference marked on both axes. “Animate 20 trials” builds a short sequence; pause, replay and reduced motion support closer inspection. Each accumulated dot represents one complete trial. “Additional calculations and simulations” opens the other calculation and study-planning views when needed.
3. The 20-trial animation shows different possible trials while the population probabilities remain fixed. Patient outcomes produce each observed difference, which falls into the distribution of repeated-study estimates.
4. “Many studies and a larger sample” opens further down the same page. “Simulate many studies” generates 5,000 independent trials. The distribution shows sampling variability; the percentage of significant results estimates power for this population scenario.
5. Before repeating at 50 and 80 patients per group, you can predict how the estimates and power will change, holding the population assumptions and repetition count fixed. Larger trials usually produce less variable estimates and greater power at a nonzero population difference. “Settings” provides the other assumptions. Advanced controls start closed; coverage and Monte Carlo summaries can wait until the advanced chapter.
6. The expandable “Model answer” sections support reflection. “Report” summarizes the population assumptions, pain-relief counts in one study, and results across many studies, with an explanation of sampling variability. You can add your reflection and download a PDF or editable Word report. After changing the sample size, a new run is needed for those results to appear in the report.

## Reviewing short examples

The tutorial includes selectable passages in four review activities: [discharge calculations](../book/calculations.html#discharge-error-activity), [recruitment planning](../book/feasibility.html#recruitment-error-activity), [a sample size calculation report](../book/reporting.html#report-error-activity) and [advanced software choices](../book/appendix.html#software-error-activity).

1. You can read the proposed statement and choose a passage that may need correction. Some passages are appropriate.
2. Clicking or tapping a passage opens an explanation and a link to the relevant teaching material. With a keyboard, Tab reaches each passage and Enter or Space opens its explanation; Escape closes it.
3. Passages already checked can be revisited by hovering or selecting them again. The count records problem areas found, and Reset activity starts again. Progress is stored in the current browser.
4. The explanations can support a corrected version in your own words. The PDF and the expandable answer key provide the same explanations for offline review.

## Type I and Type II error probabilities and power — advanced

[Open activity](../study/?activity=alpha_beta) · [Matching explanation](../book/curves.html#alpha-beta)

Purpose: connect false positives, false negatives and power with the distributions that underlie repeated-study behavior. The app calculates the shaded areas from the normal distribution.

1. The example compares a null mean of 120 with an alternative mean of 125 mmHg, known population SD 15 and 25 independent observations.
2. You can drag a dotted rejection boundary in either graph and watch the shaded areas and probabilities update together. For a two-sided test, both boundaries move symmetrically. The handles support Left/Right arrow keys, and the Type I error probability slider provides the same control.
3. Under the alternative distribution, the non-rejection area represents false negatives and the rejection area represents power.
4. Increasing the sample size while keeping the means and SD fixed narrows both distributions of the sample mean. You can explain the resulting change in power without claiming that patients have become less variable.
5. Comparing one-sided and two-sided rules illustrates their consequences; the scientific question should determine the rule before data collection. This one-sample known-SD model differs from the two-arm trials elsewhere.
6. In “Report,” you can explain how sample size affects power at the current settings and save the calculation with your answer. If the specified population mean equals the null mean, rejections are false positives; the report labels the complementary probability as non-rejection under the null.

## Two-proportion calculator — reference

[Open calculator](../two_proportions/) · [Matching explanation](../book/calculations.html#two-proportions)

Purpose: reproduce the binary-outcome sample size calculation. The calculator uses a normal approximation.

1. For the chronic pain example, you can enter 60% and 30%, Type I error probability 5%, target power 90% and initially no losses.
2. The result is 56 analyzable patients per group. The total and any recruitment adjustment have different denominators and should be recorded separately.
3. Changing one input at a time shows how the required sample responds. The opening curve marks your current target difference and analyzable count per group. Adding expected losses changes the main result to recruitment per group, with the analyzable requirement retained below it.
4. The link to the lab transfers this calculated count as a fixed sample. “Many studies” then lets you estimate the performance of the planned test through simulation and compare the estimated power with the planning target.
5. “Explore assumptions” lets you compare a revised event percentage. “Report” includes both scenarios when they differ, together with their analyzable and recruitment counts and calculation method.

## Gestational-diabetes prevention trial — core

[Open activity](../study/?activity=probiotics_calculation) · [Matching explanation](../book/calculations.html#adherence)

Purpose: calculate a sample size for a binary outcome and examine its sensitivity to the target difference.

1. The favorable event is remaining free of gestational diabetes: 80% without probiotics and 90% with probiotics. The difference observed in previous data is 12 points, target difference 10 and clinical threshold 5. These are hypothetical assumptions.
2. The calculator uses 90% power and a 5% Type I error probability. Its result gives the analyzable count and recruitment after 15% expected loss.
3. “Compare two scenarios” preserves the original plan beside a calculation using 85% with probiotics. Your explanation should address why detecting the smaller target difference needs more participants.
4. Recruitment can be compared with the example's limit of 240 women. “Add this calculation to my study plan” attaches a selected result after your review.
5. The optional [advanced simulation](../study/?activity=adherence) keeps the original sample fixed while changing the probabilities that generate outcomes. This asks how the original design would perform if the true difference were smaller.


## Two-mean calculator — reference

[Open calculator](../two_means/) · [Matching explanation](../book/calculations.html#two-means)

Purpose: see how a target difference and between-patient variability determine an approximate sample size.

1. You can enter target difference 3 units, common SD 5, Type I error probability 5% and target power 90%.
2. With no losses, the normal approximation gives 59 analyzable patients per group.
3. Halving the target difference or doubling the SD approximately quadruples the required count, before rounding.
4. The lab link carries the count across as a fixed sample for simulation. Its pooled t test estimates the common variance, so its power need not exactly equal the calculator's normal-approximation target.
5. A revised target difference can be compared in “Explore assumptions.” “Report” records the main and revised scenarios, their counts and the calculation method.

## Rehabilitation: compare two means — core

[Open activity](../study/?activity=rehabilitation) · [Matching explanation](../book/calculations.html#rehabilitation)

Purpose: connect a continuous-outcome calculation with the interpretation of a possible trial result.

1. The hypothetical score has a 4-unit improvement difference observed in earlier data, target difference 3, clinical threshold 2 and common SD 5.
2. “Overview” uses a pooled two-sample t-test plan with 90% target power. You can compare recruitment after 10% losses with the limit of 200.
3. In “One study,” a run generates independent normal improvement scores using the planning difference of 3 units. The observed difference and interval vary across simulated trials.
4. You can compare the interval with zero and the 2-unit threshold. A statistically significant difference can still be too small to matter to patients.
5. “Many studies” shows how often conclusions vary across repetitions. Each patient contributes one improvement score to the comparison of two independent treatment groups.

## Chronic pain: power and recruitment — advanced

[Open activity](../study/?activity=pain_curves) · [Power curves](../book/curves.html#activity-2-can-the-feasible-study-answer-the-question) · [Available sample and feasibility](../book/curves.html#available-sample)

Purpose: assess whether the feasible study can answer the intended question under less favorable assumptions.

1. The activity fixes the analyzable sample at 90 per group: 200 recruited with 10% expected loss gives 180 expected analyzable participants.
2. “Explore assumptions” shows analytical curves for the 30-point target difference and smaller 20- and 15-point differences. You can compare their power with the 90% target.
3. With Settings open and advanced controls visible, a custom simulation scenario of control 30% and treatment 50% or 45% keeps the original sample fixed while changing the true difference.
4. “Many studies” estimates power from generated patient data for the selected scenario.
5. Your recommendation should address what the recruitment ceiling could establish and the uncertainty in the assumptions. Power for a test of zero difference depends on the true difference, sample size, and analysis.

## Repeated chronic-pain trials — advanced

[Open activity](../study/?activity=pain_simulation) · [Matching explanation](../book/simulation.html#activity-3-generate-analyze-repeat-summarize)

Purpose: extend the core simulation from power to confidence interval coverage, interval width and simulation uncertainty.

1. The activity starts in “Many studies,” with 60 analyzable patients per group, relief probabilities 30% and 60%, 5,000 repetitions and target full interval width 30 percentage points.
2. You can first visit “One study” to inspect one generated dataset, its estimated difference, interval and test result.
3. After “Simulate many studies,” you can examine the rejection percentage, coverage of the specified true difference and percentage meeting the width target. These answer different questions.
4. A custom treatment probability of 45%, with control still 30%, tests the plan under a 15-point true difference. A no-effect scenario estimates the false-positive probability.
5. You can vary the repetition count while leaving patients per group fixed. More repetitions reduce Monte Carlo uncertainty while each trial's design stays fixed. A report should retain the generating assumptions, analysis and repetition count.

Within the same activity, *Settings* and *Explore further* contain *Explore missing outcomes*:

1. You can select *Complete outcomes* and keep recruitment at 60 per group as a reference.
2. *Equal losses* removes outcomes independently of relief with 10% probability in each group. One study shows recruited and retained counts and the records excluded from analysis.
3. *Unequal losses* uses 10% expected loss in the standard group and 20% in the novel group. Recruitment and population probabilities stay fixed.
4. *Outcome-related losses* keeps those expected percentages but makes missingness three times as likely without relief in the novel group. The standard group retains outcome-independent loss.
5. Across the four scenarios, Many studies compares the mean estimate, bias, coverage, interval width, retained counts, and significance percentage. A high significance percentage can coexist with bias and poor coverage. The model answer is in the [missing-outcome explanation](../book/simulation.html#explore-missing-outcomes).
6. The report identifies recruited versus analyzable counts and, for matching simulations, retained counts, bias and coverage. Saved simulation CSV files retain the settings used when they were generated; the R script reproduces the current scenario. *Usual simulation* restores the original analysis with fixed analyzable counts.

The simulation above uses one final analysis. For a design with interim stopping or sample-size adaptation, the [advanced simulation discussion](../book/simulation.html#simulating-decision-rules) explains the additional decisions that a design-specific simulation must reproduce.

## Recruitment adjustment — core

[Open calculator](../dropout_adjustment/) · [Matching explanation](../book/feasibility.html#account-for-expected-losses)

Purpose: connect the analyzable requirement to anticipated outcome losses and treatment changes. This activity calculates recruitment requirements without generating patients.

1. For the chronic-pain example, the starting analyzable requirement is 56 patients per group.
2. At 10% expected loss, the result is 63 recruits per group, or 126 total. Comparing 0%, 10% and 20% losses keeps the starting requirement fixed.
3. With different losses of 20% in the novel group and 10% in the standard group, equal recruitment uses 70 per group (140 total). This gives expected retained counts of 56 and 63. The tables explain why the recruitment counts remain equal.
4. Your interpretation should consider actual retention and the reasons for missing outcomes. The collapsed activity question in “Report” provides space for your explanation, with an expandable example answer that follows the current inputs.
5. For the optional advanced example, a starting count of 100 per group is assumed to require full adherence. With switching of 10% from novel to standard and 5% in the other direction, and 5% missing outcomes in each group, the approximate recruitment target is 146 per group. The intermediate values remain unrounded.
6. Choosing “Expected switching is already included” applies no additional switching multiplier. For binary outcomes, you should use the revised event percentages in the [two-proportion app](../two_proportions/); the [tutorial's sensitivity example](../book/feasibility.html#treatment-switching) gives 57% and 31.5%.
7. “Methods and references” explains the approximation using the current values. “Report” records the applied adjustments, whether switching is already included, expected retained counts and your explanation. The lab link carries the starting analyzable sample into a complete-outcome scenario; switching and unequal losses remain specific to this recruitment calculation.

## Estimate a mean difference with a precision target — advanced

[Open activity](../study/?activity=mean_precision) · [Matching explanation](../book/estimation-planning.html#plan-for-precision)

Purpose: plan a useful confidence-interval width for a mean difference and examine its performance across repeated samples.

1. The estimation activity uses SD 5, 95% confidence and a target full interval width of 4 units. A population difference of 3 units supplies a known value for evaluating the simulations.
2. “Overview” shows the sample for the interval-width goal. A narrower target or larger SD increases the required count.
3. “One study” generates a realized interval. Realized interval widths vary.
4. “Many studies” estimates the percentage meeting the full-width target. A full width of 4 corresponds to a margin of about 2 for a symmetric interval.
5. Your justification should explain why this interval width would support a useful interpretation and which evidence supports the assumed SD.

## Estimate a population percentage — advanced

[Open activity](../study/?activity=prevalence) · [Matching explanation](../book/estimation-planning.html#prevalence)

Purpose: connect the precision needed for a descriptive decision with survey size and a possible realized estimate.

1. The example anticipates 20% prevalence and a 95% interval with full width 10 percentage points, equivalent to a margin of 5 points.
2. The formula gives 246 completed observations. Reducing full width to 5 points, a margin of 2.5, requires about four times as many.
3. The 50% conservative-planning option changes the probability used for sample size planning. The anticipated percentage remains the generating probability for the illustrative simulation.
4. In “Explore assumptions,” “Draw one illustrative sample” generates a binomial count and a Wilson interval. The realized interval width varies with the observed count.
5. Your explanation should distinguish interval precision from representativeness. Here, n is the total number of participants in the sample.
6. In “Report,” your explanation accompanies the confidence level, planning percentage, width target, sample size and recruitment allowance. The simulated interval is included when it matches the current example and settings; otherwise, you should draw another sample.

## Pilot study: retention — advanced

[Open activity](../study/?activity=pilot_feasibility) · [Matching explanation](../book/estimation-planning.html#pilot-feasibility)

Purpose: assess whether a limited pilot provides useful information for a feasibility decision.

1. The starting goal is to assess a fixed sample of 40 participants with anticipated retention of 80%.
2. In “Explore assumptions,” “Draw one illustrative sample” generates a possible retained count and its Wilson interval. The simulated retention count varies around its expected value of 32.
3. You can compare the illustrative result with a fixed sample of 80. More participants generally provide more information about retention, but obtaining them requires a feasible plan.
4. Retained and non-retained participants both belong in the denominator when their status is known. Loss adjustment is appropriate only for participants whose outcome status itself cannot be established.
5. In “Report,” your explanation should relate the interval and its uncertainty to the prespecified feasibility decision. After changing the sample size or confidence level, a new illustrative sample is needed before the report can include its interval.

## Discharge percentages — core calculation, optional simulation extension

[Open activity](../study/?activity=discharge) · [Matching explanation](../book/calculations.html#discharge)

Purpose: compare three sample size plans for a hypothetical trial of discharge within seven days, distinguishing relative changes from percentage-point differences.

1. The standard-care percentage stays at 80%. The difference observed in previous data stays at 18 percentage points and the clinical threshold at 8. All three plans use a two-sided test, a 5% Type I error probability and no loss allowance.
2. For Plan A, the 20% relative increase gives 96% discharge with the new program (80% × 1.20), a 16-point target difference. In “Settings,” the two planning percentages should be 80% and 96%, with target power 80%. “Overview” shows the analyzable counts per group and in total.
3. For Plan B, the novel-treatment percentage becomes 90%, giving a 10-point target difference; power stays at 80%. How does the required sample compare with Plan A?
4. For Plan C, the novel-treatment percentage returns to 96%, and power increases to 90%. How does the required sample compare with Plan A?
5. Your explanation should compare A with B to discuss the target difference, and A with C to discuss power. The worked answer in the tutorial shows all three calculations.

For optional simulation exploration, “One study” shows possible discharge counts and “Many studies” estimates the test's power under the selected assumptions. A no-effect scenario examines false positives. The [discharge simulation](../book/simulation.html#discharge-simulation) explains how simulation can assess the planning approximation near 100%.

## Build your own study calculation — advanced application

[Open activity](../study/?activity=own_study) · [Matching explanation](../book/appendix.html#own-study)

Purpose: bring together the clinical question, numerical requirements and practical constraints.

1. In “My study,” you can describe the question, design, evidence, participant burden and resources. The numerical model supports two independent, equally sized groups. Other designs require calculations matched to their structure and analysis.
2. For a supported design, you can select testing, interval-width planning or a fixed available sample and enter justified assumptions in “Settings.” Other designs require an appropriate external calculation.
3. The eligible-participant, consent and recruitment-period inputs help assess recruitment feasibility. Actual recruitment and retention can vary from these expectations.
4. For a supported design, “One study” and “Many studies” can examine possible results and performance. Sensitivity scenarios should change the assumed population while retaining the original plan when that is the question.
5. “Report” combines your study responses and recommendation with the current calculations, feasibility and matching simulations. Your written answers should reflect the selected example and settings. Unsupported designs receive a note about the need for a design-specific method.
6. “Download report (PDF)” saves the summary; “Download editable report (Word)” provides an editable copy. The separate “Save work for later” controls save and reopen your settings and answers. The [file guide above](#reports-and-saved-work) explains backups, simulation data and the optional R script. Findings and their justification can be entered in the separate study-plan activity.

## Choosing a study design — advanced

[Open questionnaire](../study/?activity=design_questionnaire) · [Matching explanation](../book/study-designs.html#design-questionnaire)

Purpose: identify a suitable design family and the decisions that determine its planning method.

1. The main aim determines which follow-up questions appear. The data, outcome and relationships between observations describe the study setting.
2. Treatment questions address allocation, comparisons and the intended claim. Observational, diagnostic and prediction questions use their own follow-ups.
3. “Show design suggestions” presents a candidate design, the reasoning, unresolved choices and sample-size implications.
4. The resource links provide a relevant activity or specialist guidance. Changing an answer clears the previous suggestion until you request an update. “Start again” clears the form.

After identifying a design family, a plan with several outcomes or comparisons should also specify its [testing strategy](../book/study-designs.html#multiple-outcomes-comparisons). Planned [interim analyses](../book/study-designs.html#interim-analyses-stopping) or [sample-size re-estimation](../book/study-designs.html#sample-size-re-estimation) need specialist planning and the [additional reporting record](../book/reporting.html#complex-design-record).

Teaching text: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Original software code: [MIT](https://opensource.org/license/mit). Third-party attributions and exceptions remain applicable.

## Rehabilitation calculation — core

[Open activity](../study/?activity=rehabilitation_calculation). A 3-unit target difference, SD 5, 90% power and a 5% Type I error probability give 59 analyzable patients per group with the introductory normal approximation. You can compare a 1.5-unit target difference or an SD of 7 while holding the other assumptions fixed. Expected losses change recruitment. The Report view lets you attach the selected calculation to your developing study plan. The [t-test simulation extension](../study/?activity=rehabilitation) is optional advanced exploration.
