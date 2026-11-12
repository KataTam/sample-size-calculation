# Activity walkthroughs

These walkthroughs connect each activity to the question it helps answer. The clinical values are hypothetical teaching assumptions. The simulations generate hypothetical patient outcomes from specified population assumptions.

Before changing an input, you can predict what the result will do and identify the quantities you will keep fixed. After exploring, your explanation should compare the result with your prediction and note what it means for the study plan.

You can drag a slider or type its value in the adjacent number field. Percentages are entered on the displayed scale, so 5 means 5%. In a narrow app panel, “Study settings” opens the inputs; closing it leaves room for the result and graph. Secondary calculation settings remain available in their expandable groups.

In the reasoning lab, planning tables and curves update when inputs change. Simulated results update only when you run the relevant simulation again and retain their saved assumptions until then. More patients change a study's information; more simulation repetitions improve the numerical precision of the estimated performance.

The difference observed in previous data records a sample result that can inform planning, with uncertainty. It can equal the target difference or clinical threshold; the three roles have no fixed numerical order and each needs justification. With “Same as planning assumptions” selected, the simulations use the target difference and planning event probabilities. A custom population scenario lets you examine another true difference without changing the original plan. All treatment differences here are between-group differences.

The chronic pain case compares fictional Neravixa with duloxetine for painful diabetic peripheral neuropathy. Each patient contributes one four-week outcome: achieved pain relief or did not achieve pain relief. The pilot remains 7 of 10 versus 3 of 10; the calculation uses population assumptions of 60% versus 30%. Selecting a calculator or simulation preview opens the app within the chapter. Its main controls sit above the figure, and the result text updates with the calculation. A link underneath opens the app on its own page. Closing and reopening an embedded app preserves its inputs during that page visit.

## The four-activity core route

| Chapter | Core activity | Contribution to the continuing report |
|---|---|---|
| 1. Research question and power | [Chronic pain: one study and many studies](../study/?activity=pain_one_many) | Question, assumptions and interpretation of power |
| 2. Calculating sample size | [Calculate a sample size: probiotics](../book/calculations.html#calculate-sample-size) | Inputs, procedure, software and analyzable counts |
| 3. Recruitment and feasibility | [Adjust recruitment](../study/?activity=recruitment) using one shared loss percentage | Recruitment per group and in total, with a short justification |
| 4. The sample size calculation report | [Review and complete a report](../book/reporting.html#check-reporting) | Four-error review followed by a consistency check of the learner's report |

One calculation example is sufficient. Your report develops through these four activities in the same [study-plan workspace](../assumptions_report/). The default core view asks for the essentials; “Advanced study plan” adds detailed supporting prompts to the same answers. Additional discharge practice is optional basic practice. The later simulations and independent planning are advanced extensions.

Your report should use one consistent study question, calculation and recruitment plan. If you choose the probiotics or rehabilitation calculation, your report should describe that case. The chronic pain simulation and annotated report provide worked examples for learning the concepts.

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
2. Chapters 1–2 explain the question and power, calculation, and recruitment. Chapter 3 brings together the reporting guidance, checklist and complete example. You can record decisions in the same activity throughout and review the complete report in Chapter 3.
3. In the core view, short explanations of the supplied assumptions are sufficient. Each section's “Ready for review” checkbox becomes available when its visible questions are answered. The advanced view adds evidence appraisal, plausible ranges, sensitivity scenarios and feasibility details; its completion checks include those extra prompts.
4. In an app’s Report view, “Add this calculation to my study plan” opens a preview of the current inputs, result and method. You choose whether to attach it and whether to replace an earlier result of that type. Your written answers remain in place; affected sections are marked for another review.
5. “Review before downloading” lists unresolved decisions and compares the analyzable requirement with the starting count in an attached recruitment calculation. Values written in free text still need your review. Optional simulations can be attached as explorations.
6. The preview and PDF/Word downloads start with a concise sample size calculation report, followed by the supporting study plan, section review and attached results. Both parts update from the same answers; example hints are included only if you use them in an answer. “Save work for later” preserves the editable app state. Entries also persist in the same browser; the saved file supports another computer. The plan is complete for the core assignment when its applicable decisions and calculation have been reviewed. Advanced activities can extend it when relevant.


The [annotated report in Chapter 3](../book/reporting.html#write-a-sample-size-justification) shows the completed two-proportion calculation. The chronic pain example uses 5% expected missing primary outcomes: 56 analyzable patients and 59 recruits per group, or 118 recruits total. Selecting this example makes its prepared calculation and software record available under the software question. Attached calculator results retain their own inputs and runtime versions; example answers for calculation fields follow that selected result. Your written answers should be reviewed when the calculation changes.

## Chronic pain: one study and many studies — core

[Open activity](../study/?activity=pain_one_many) · [Matching explanation](../book/clinical-question.html#activity-1-one-study-then-many)

Purpose: see why sample estimates differ from population values, interpret the uncertainty in one trial, and relate repeated trials to power.

1. The starting population has 30% relief with standard treatment and 60% with novel treatment, with 20 analyzable patients per group and a 5% Type I error probability.
2. In “One study and many studies,” “Simulate one study” generates patient outcomes. The animation follows the patient outcomes into the estimated difference and then the sampling distribution, with the population difference marked on both axes. “Animate 20 trials” builds a short sequence; pause, replay and reduced motion support closer inspection. Each accumulated dot represents one complete trial. “Additional calculations and simulations” opens the other calculation and study-planning views when needed.
3. The 20-trial animation shows different possible trials while the population probabilities remain fixed. Patient outcomes produce each observed difference, which falls into the distribution of repeated-study estimates.
4. “Many studies and a larger sample” opens further down the same page. “Simulate many studies” generates 5,000 independent trials. The distribution shows sampling variability; the percentage of significant results estimates power for this population scenario.
5. The calculated requirement appears alongside the starting count: 56 analyzable patients per group for 90% power with the default assumptions. “Use 56 per group in the simulation” applies that count to subsequent runs. Larger samples improve precision and increase power at a nonzero population difference. “Settings” provides the other assumptions. Advanced controls start closed; coverage and Monte Carlo summaries appear when selected.
6. “Interpret the animation” describes the counts and difference currently displayed. “Report” records the population assumptions, pain-relief counts in one study, results across many studies, and reproducibility details. Participant records are available there after a single study has been simulated. The report can be downloaded as PDF or editable Word. After changing the sample size, a new run is needed for those results to appear in the report.

## Reviewing short examples

The tutorial includes selectable passages in five review activities: [discharge calculations](../book/exercises.html#discharge-error-activity), [recruitment planning](../book/simulation.html#recruitment-error-activity), [a sample size calculation report](../book/reporting.html#report-error-activity), [an estimation sample size calculation report](../book/estimation-planning.html#estimation-report-error-activity) and [advanced software choices](../book/appendix.html#software-error-activity).

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

## Calculate a sample size: probiotics

[Open activity](../study/?activity=probiotics_calculation) · [Matching explanation](../book/calculations.html#adherence)

Purpose: calculate a sample size for a binary outcome and examine its sensitivity to the target difference.

1. The favorable event is remaining free of gestational diabetes: 80% without probiotics and 90% with probiotics. The difference observed in previous data is 12 points, target difference 10 and clinical threshold 5. These are hypothetical assumptions.
2. The calculator uses 90% power and a 5% Type I error probability. Expected loss starts at zero so this step gives the analyzable requirement. The following recruitment activity applies the chosen loss allowance.
3. Your record should identify both event percentages, the 10-point target difference, error probability, power, method, software and analyzable count per group and in total. The optional comparison with 85% illustrates a smaller target difference.
4. “Add this calculation to my study plan” attaches the selected result after your review. Its analyzable count is the starting point for the recruitment activity. Comparing several scenarios is an advanced extension.
5. The optional [advanced simulation](../study/?activity=adherence) keeps the original sample fixed while changing the probabilities that generate outcomes. This asks how the original design would perform if the true difference were smaller.


## Two-mean calculator — reference

[Open calculator](../two_means/) · [Matching explanation](../book/calculations.html#two-means)

Purpose: see how a target difference and between-patient variability determine an approximate sample size.

1. You can enter target difference 3 units, common SD 5, Type I error probability 5% and target power 90%.
2. With no losses, the pooled two-sample t-test calculation gives 60 analyzable patients per group (120 total).
3. Halving the target difference or doubling the SD approximately quadruples the required count, before rounding.
4. The lab link carries the count across as a fixed sample for simulation. It uses the same pooled t-test planning method. Rounding upward gives power slightly above the target.
5. A revised target difference can be compared in “Explore assumptions.” “Report” records the main and revised scenarios, their counts and the calculation method.

## Additional practice: rehabilitation

[Open activity](../study/?activity=rehabilitation_calculation) · [Matching explanation](../book/calculations.html#rehabilitation)

1. The target mean difference is 3 units and the common SD is 5. The two-sided Type I error probability is 5% and target power is 90%.
2. With expected loss left at zero, the pooled two-sample t-test calculation gives 60 analyzable participants per group, or 120 total.
3. Your record should identify these inputs, the method and software, and both counts. “Add this calculation to my study plan” attaches the result after your review. The recruitment activity starts with this analyzable requirement.

The [advanced rehabilitation simulation](../study/?activity=rehabilitation) uses a t-test method and generated outcomes. It can examine confidence intervals and repeated-study performance after the core calculation.

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

Within the same activity, *Settings* → *Show advanced settings and results* reveals *Explore missing outcomes*:

1. You can select *Complete outcomes* and keep recruitment at 60 per group as a reference.
2. *Equal losses* removes outcomes independently of relief with 10% probability in each group. One study shows recruited and retained counts and the records excluded from analysis.
3. *Unequal losses* uses 10% expected loss in the standard group and 20% in the novel group. Recruitment and population probabilities stay fixed.
4. *Outcome-related losses* keeps those expected percentages but makes missingness three times as likely without relief in the novel group. The standard group retains outcome-independent loss.
5. Across the four scenarios, Many studies compares the mean estimate, bias, coverage, interval width, retained counts, and significance percentage. A high significance percentage can coexist with bias and poor coverage. The model answer is in the [missing-outcome explanation](../book/simulation.html#explore-missing-outcomes).
6. The report identifies recruited versus analyzable counts and, for matching simulations, retained counts, bias and coverage. Saved simulation CSV files retain the settings used when they were generated; the R script reproduces the current scenario. *Usual simulation* restores the original analysis with fixed analyzable counts.

The simulation above uses one final analysis. For a design with interim stopping or sample-size adaptation, the [advanced simulation discussion](../book/simulation.html#simulating-decision-rules) explains the additional decisions that a design-specific simulation must reproduce.

## Recruitment adjustment — core

[Open activity](../study/?activity=recruitment) · [Matching explanation](../book/calculations.html#account-for-expected-losses)

1. The starting count should be the analyzable requirement per group from your chosen calculation. The app opens with the chronic pain example of 56 per group; you can replace that count with your selected result.
2. One expected loss percentage applies to both groups. For the chronic pain example, 5% expected loss gives 56 / 0.95, rounded upward to 59 recruits per group and 118 total.
3. Your explanation should identify the starting count, expected retained percentage, recruitment count and basis for the loss assumption. Actual retention can vary, and missing outcomes also need prevention and an appropriate analysis.
4. In “Report,” the calculation and your explanation can be added to the continuing study plan. Its review checks compare the starting count with the attached sample size calculation.

## Review and complete a report — core

[Open activity](../book/reporting.html#check-reporting) · [Your continuing report](../assumptions_report/?stage=review)

1. The short example contains four problem areas: calculation inputs, the interpretation of power, per-group versus total counts, and the loss adjustment. Selecting a passage opens an explanation; the PDF includes the same answer key.
2. After correcting these problems, you can check the corresponding entries in your own report against its attached calculations and the annotated example.
3. A PDF or editable Word download contains the concise calculation report followed by the supporting study plan. This review serves as Chapter 3's check. The cumulative quiz offers optional further review.

## Unequal losses and treatment switching — advanced

[Open extension](../study/?activity=recruitment_advanced) · [Matching explanation and review](../book/simulation.html#recruitment-extensions)

1. With 56 analyzable patients per group and expected losses of 20% with novel treatment and 10% with standard treatment, equal recruitment uses the larger requirement: 70 per group, or 140 total. Expected retained counts are 56 and 63.
2. The switching approximation starts with a requirement assuming full adherence. Starting with 100 per group, switching of 10% from novel to standard and 5% in the other direction, followed by 5% missing outcomes, gives approximately 146 recruits per group. Intermediate values remain unrounded.
3. “Expected switching is already included” prevents applying that allowance twice. For binary outcomes, the [two-proportion app](../two_proportions/) can recalculate using the revised event percentages in the [worked example](../book/simulation.html#treatment-switching).
4. The report records the applied adjustments and your explanation. The [recruitment review](../book/simulation.html#recruitment-error-activity) checks their interpretation; the [missing-outcome simulation](../book/simulation.html#explore-missing-outcomes) examines information loss and bias.

## Estimate a population mean with a precision target — advanced

[Open activity](../study/?activity=mean_precision) · [Matching explanation](../book/estimation-planning.html#plan-for-precision)

Purpose: plan a useful confidence-interval width for one population mean and examine its performance across repeated samples.

1. The estimation activity uses SD 5, 95% confidence and a target full interval width of 4 units. A population mean of 3 units supplies a known value for evaluating the simulations.
2. “Overview” shows the total sample for the interval-width goal. A narrower target or larger SD increases the required count.
3. In “Simulations,” a single study produces an estimate and confidence interval.
4. Repeated studies show the percentage of intervals containing the population mean and meeting the width target. A full width of 4 corresponds to a margin of about 2 for a symmetric interval.
5. “Report” records the current assumptions, total sample size, simulations, and methods. PDF and editable Word downloads are available; “Save work for later” preserves the inputs for reopening.

## Estimate a population percentage — advanced

[Open activity](../study/?activity=prevalence) · [Matching explanation](../book/estimation-planning.html#prevalence)

Purpose: connect the precision needed for a descriptive decision with survey size and a possible realized estimate.

1. The example anticipates 20% prevalence and a 95% interval with full width 10 percentage points, equivalent to a margin of 5 points.
2. The formula gives 246 completed neuropathy assessments. Allowing for 5% nonresponse gives 259 patients to approach. Reducing full width to 5 points, a margin of 2.5, requires about four times as many completed assessments.
3. The 50% conservative-planning option changes the probability used for sample size planning. The anticipated percentage remains the generating probability for the illustrative simulation.
4. In “Explore assumptions,” “Draw one illustrative sample” generates a binomial count and a Wilson interval. The realized interval width varies with the observed count.
5. Your explanation should distinguish interval precision from representativeness. Here, n is the total number of participants in the sample.
6. In “Report,” your explanation accompanies the confidence level, planning percentage, width target, sample size and recruitment allowance. The simulated interval is included when it matches the current example and settings; otherwise, you should draw another sample.

## Pilot study: retention — advanced

[Open activity](../study/?activity=pilot_feasibility) · [Matching explanation](../book/estimation-planning.html#pilot-feasibility)

Purpose: assess whether a limited pilot provides useful information for a feasibility decision.

1. The starting goal is to assess a fixed sample of 40 participants with anticipated retention of 80%.
2. In “Explore assumptions,” “Draw one illustrative sample” generates a possible retained count and its Wilson interval. The simulated retention count varies around its expected value of 32.
3. Comparing 40 with 100 participants connects the app to the chapter's progression-rule example. At 80% observed retention, the lower 95% Wilson limit is about 65% with 40 participants and 71% with 100; only the larger sample meets the example's requirement for a lower limit above 70%.
4. Retained and non-retained participants both belong in the denominator when their status is known. Loss adjustment is appropriate only for participants whose outcome status itself cannot be established.
5. In “Report,” your explanation should relate the interval and its uncertainty to the prespecified feasibility decision. After changing the sample size or confidence level, a new illustrative sample is needed before the report can include its interval.

## Discharge percentages — additional basic practice

[Open activity](../study/?activity=discharge) · [Matching explanation](../book/exercises.html#discharge)

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

After identifying a design family, a plan with several outcomes or comparisons should also specify its [testing strategy](../book/study-designs.html#multiple-outcomes-comparisons). Planned [interim analyses](../book/study-designs.html#interim-analyses-stopping) or [sample-size re-estimation](../book/study-designs.html#sample-size-re-estimation) need specialist planning and the [additional reporting record](../book/appendix.html#complex-design-record).

Teaching text: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Original software code: [MIT](https://opensource.org/license/mit). Third-party attributions and exceptions remain applicable.

## Rehabilitation calculation — core

[Open activity](../study/?activity=rehabilitation_calculation). A 3-unit target difference, SD 5, 90% power and a 5% Type I error probability give 60 analyzable patients per group with the pooled two-sample t-test calculation. You can compare a 1.5-unit target difference or an SD of 7 while holding the other assumptions fixed. Expected losses change recruitment. The Report view lets you attach the selected calculation to your developing study plan. The [t-test simulation extension](../study/?activity=rehabilitation) is optional advanced exploration.
