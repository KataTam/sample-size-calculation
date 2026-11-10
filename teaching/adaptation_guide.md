# Adaptation Guide

This resource is designed for adaptation.

The main principle is simple: if you change the teaching context, update the examples, activities, and assessment together. The module is most useful when the learner-facing text, Shiny app interaction, and assessment task point to the same learning outcome.

## Common Adaptations

- Replace the clinical cases with examples from your own course.
- Use only one app in a shorter teaching session.
- Translate the learner-facing module.
- Adjust the learning outcomes to fit undergraduate, graduate, or continuing-professional education.
- Add local requirements for ethics committee or protocol submissions.

## Where To Edit

| If you want to change... | Edit this file or folder |
|---|---|
| Learner-facing explanation | `module/Sample_size_open_module.Rmd` |
| Chapter 7 design and testing-strategy guidance | `student-materials/study-design-guide.md`; included in the main R Markdown source |
| Chapter checks and cumulative quiz | `site/quiz/questions.json`; the same bank supplies both versions |
| Flashcards and short glossary explanations | `data/flashcards.json`, `data/glossary-terms.json`, and `student-materials/glossary.md` |
| Font size or rendered HTML styling | `module/styles.css` |
| Sample size formulas or statistical methods | `R/sample_size_functions.R` |
| Shared two-group calculator labels, defaults, comparisons and reports | `R/basic_calculator.R`; called by `apps/two_means/app.R` and `apps/two_proportions/app.R` |
| Other Shiny app controls, plots and report content | `apps/<app_name>/app.R` |
| Matched activity examples | `R/teaching_cases.R`, with the corresponding module narrative and prepared results |
| Expandable example answers in Shiny apps | `R/model_answers.R`; collapsed simulation explanations are in `apps/power_explorer/app.R` |
| Shared report layout and saved-simulation summaries | `R/app_presentation.R` |
| Reasoning-lab state validation and JSON restoration | `R/activity_bridge.R` and `apps/power_explorer/app.R` |
| Written study-plan questions, examples, report and file restoration | `site/assumptions_report/report.js`, `index.html` and `report.css` |
| Question help and shared app styling | `site/input-guidance.js`, `site/input-guidance.css` and `site/app-layout.css` |
| Case-development worksheets | `case-studies/` |
| Student case co-creation materials | `case-studies/student_case_template.md`, `case-studies/case_quality_checklist.md`, `case-studies/peer_review_form.md`, `case-studies/instructor_review_notes.md` |
| Teaching plan | `teaching/TEACHING_GUIDE.md` |
| Learning outcome/activity/assessment links | `teaching/constructive_alignment_table.md` |
| Rubric | `teaching/assessment_rubric.md` |
| Accessibility checks | `teaching/accessibility_checklist.md` |

## Adapting Clinical Cases

To replace the chronic pain example:

1. Choose a clinical context students will recognize.
2. Decide whether the primary outcome is binary or continuous.
3. State the standard-treatment result.
4. Distinguish the expected difference, target difference and smallest clinically important difference; justify importance, realism and any gap between them.
5. Specify the analysis, Type I error probability and power, or useful precision if the aim is estimation.
6. Record evidence sources, uncertain ranges and anticipated missing outcomes; assess recruitment separately.
7. Compare plausible assumptions and the information available. Do not choose a larger unsupported target simply to make the number affordable.

For a binary outcome, use `apps/two_proportions`. For a continuous outcome, use `apps/two_means`.

Keep the case specific. A case such as "a new treatment improves recovery" is too vague. A case such as "a new discharge planning intervention is expected to increase discharge within 48 hours from 70% to 82%" is easier to calculate and discuss.

## Changing App Defaults

The app defaults should match the example students see in the module or in class. Matched activities are maintained in `R/teaching_cases.R`; their narrative and prepared outputs should be updated together. The written report activity reads this registry when loading the pain-relief example. The main tutorial remains in `module/Sample_size_open_module.Rmd`.

The standalone two-group calculators use `basic_calculator_ui()` in `R/basic_calculator.R`. For the binary calculator, `pi2` starts at 0.30 for standard treatment, `pi1` at 0.60 for novel treatment, `alpha` at 0.05 and `power` at 0.90. The controls display these probabilities as percentages. Changing a matched lab activity requires editing its case record as well as any corresponding narrative or prepared figures.

## Model answers, reports and saved files

Model answers should respond directly to the question and use the selected example and current valid calculation inputs. Question help should explain what to enter or interpret. Example answers should stay out of reports, completion counts and saved responses; learners' own text should survive parameter changes. The written study-plan activity offers bracketed structures as soon as “My own study” is selected. Selected teaching examples remain available as the learner writes. Fresh pages use core settings and blank responses; saved work is restored explicitly. Question, help, and suggested response should cover the same decisions, with observation dependence and evidence requirements made explicit.

Each report should distinguish the current plan, simulation assumptions and the learner's responses. Saved simulations are included only when their metadata match the current example and settings. Earlier results remain available in their simulation panels and CSV exports with their original assumptions. A report should explain an omission and how to obtain a current result. For missing-outcome scenarios, the report should identify recruited and retained counts and preserve the interpretation of bias and coverage. Unsupported designs should receive design-specific guidance without carrying over the independent-group calculation.

All report downloads offer PDF first and editable Word (.docx) alongside it. “Save work for later” is separate: the reasoning lab restores its JSON example, inputs and written answers and clears previous simulations; the study-plan form restores its own JSON entries and still accepts its earlier HTML reports. Saved work belongs to its respective app. Word edits remain in the downloaded document. The [walkthroughs](../student-materials/activity-walkthroughs.html#reports-and-saved-work) explain the learner workflow.

After adaptation, `Rscript scripts/check_resource.R` checks calculations, model answers, reports and state handling. With the rebuilt site served locally, `node scripts/check_app_reports.cjs` checks the six app downloads against their previews, parameter changes and the lab's backup round trip; `node scripts/check_assumptions_report.cjs` checks the written report's save/reopen behavior. The [build guide](../documentation/development/build-and-publish.md) gives the required environment and publication steps.

## Using Only Part Of The Resource

For a short teaching session, it is fine to use only one section.

Possible combinations:

| Teaching need | Minimal set |
|---|---|
| Binary outcome sample size | [Two-proportions section](../book/calculations.html#two-proportions), [calculator](../two_proportions/), short rubric |
| Continuous outcome sample size | [Two-means section](../book/calculations.html#two-means), [calculator](../two_means/), short rubric |
| Feasibility and power | [Power curves](../book/curves.html), [reasoning-lab activity](../study/?activity=pain_curves) |
| Recruitment adjustment | Recruitment and reporting; shared or different losses and the optional treatment-switching approximation in `apps/dropout_adjustment` |
| Protocol-writing practice | Build-your-own justification section, case template, assessment rubric |

If you remove a section, also remove or revise related assessment tasks.

## Adapting For Course Level

### Introductory Level

- Keep the focus on interpretation.
- Use one outcome type.
- Give students most assumptions in advance.
- Assess whether they can explain what the required sample size means.

### Intermediate Level

- Ask students to choose between binary and continuous outcome examples.
- Include dropout adjustment.
- Ask students to compare two plausible assumptions.
- Assess their written sample-size justification.

### Advanced Level

- Ask students to justify assumptions from literature or pilot data.
- Discuss alternative designs, unequal allocation, non-inferiority, clustering, or repeated measures as extensions.
- Ask students to identify when the simple formulas in this module are no longer sufficient.

## Translation

If translating the module:

- translate the learner-facing text first
- keep statistical notation consistent
- check whether terms such as Type I error probability, Type II error probability, power, and clinically relevant difference have accepted local translations
- re-knit the module and check all figures and tables
- update license and attribution notes in the translated version

## Local Requirements

Teachers may need to add local requirements, for example:

- ethics committee expectations
- institutional protocol templates
- local minimum power requirements
- preferred software
- reporting standards for student research projects

Local requirements can be summarized in a short course-specific note.

## Sharing An Adapted Version

Editable source, dependency instructions, reviewed changes and rendered outputs should be kept together. Bothmann et al.'s [open-source educational-resource manuscript](https://arxiv.org/abs/2107.14330) supports this development approach. The [current source and reuse page](../documentation/reuse-and-citation.md) links the public repository, source download and licensing guidance.

Before sharing an adapted version publicly:

- remove any copyrighted figures or papers that cannot be redistributed
- check that student cases contain no identifiable patient information
- keep the [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) teaching-material license visible
- keep the [MIT](https://opensource.org/license/mit) code license visible
- cite the original repository
- note what you changed
- update the date and version if appropriate

## What To Keep Aligned

When adapting the resource, check that:

- learning outcomes still match the app interactions
- assessment prompts ask students to show the intended learning
- examples use realistic assumptions
- accessibility notes are updated for new figures, videos, or apps
- license and attribution statements remain visible

## Adaptation Checklist

Use this checklist before teaching or sharing a revised version:

- [ ] The module examples match the app defaults.
- [ ] Model answers and reports follow the selected example and changed parameters.
- [ ] Students' entries are preserved and model answers remain excluded from saved responses.
- [ ] Reports omit earlier simulation results when settings change; CSV exports retain their recorded assumptions.
- [ ] PDF and Word reports match their previews, preserve readable text and links, and supported saved-work files restore correctly.
- [ ] Tables and figures are still referred to correctly in the text.
- [ ] The assessment task matches the learning outcomes.
- [ ] The rubric fits the task students are asked to complete.
- [ ] New figures have captions.
- [ ] New app controls have clear labels.
- [ ] No identifiable patient/student information is included.
- [ ] License and attribution information is visible.
- [ ] The module has been rendered and checked.

## Adapting the reasoning pathway

The goal, effect scale, beneficial direction, clinical threshold, target difference and generating assumptions should be updated together. The app cases use positive improvement; reversing direction for harmful outcomes requires corresponding labels and interval interpretation. Equal allocation remains an assumption unless the analysis and validation are extended. Changes should also be reflected in the rubric and paired assessment. Prepared outputs can be regenerated with recorded simulation settings. See [statistical methods](../documentation/statistical-methods.md) and [third-party notices](../documentation/third-party-notices.md).

Chapter contributions and calculation transfer are maintained in `site/assumptions_report/plan-workflow.js` and `site/plan-transfer.js`. The report stores selected snapshots, including inputs, methods and versions. Changes to these records should preserve older saved work, student prose, and the review step before replacing attachments. `module/activity-contents.json` controls route labels and activity navigation. The four core chapter links use the same developing report with a chapter-specific stage.
