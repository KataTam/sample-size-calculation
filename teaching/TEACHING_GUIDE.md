# Teaching guide

The module teaches sample size as a justified research-design decision. The app is a tool for testing predictions, not the activity by itself. Begin with a clinical question and end with an explanation of what the planned study could establish.

## Preparation and access

Learners should know sample versus population, binary versus continuous outcomes, and the basic purpose of a test and confidence interval. Send the case, short concept notes and access link in advance. Provide the complete tutorial HTML/PDF and `static_activity.md` with prepared outputs as alternatives to live apps. Formulas and formatted results remain visible; expandable R code and output support reproducibility and further learning.

Check the actual deployment environment before class. The proposed 20–25 student pilot can work in groups of 3–4 with a facilitator. Let students divide interpretation, assumption checking and recording, and rotate roles; do not let coding dominate participation. Clearly identify all case values as hypothetical. Review accessibility with keyboard and readable text/table alternatives.

## Selecting a learning route

The [core route](../book/index.html#core-route) covers clinical assumptions, power, a simple one-study/many-studies simulation, two-group calculations, expected losses, interpretation, a short sensitivity analysis and a written justification. The [advanced route](../book/index.html#advanced-route) adds sampling distributions, power curves, repeated-study simulation, precision planning and other designs. Chapter headings and learning-outcome boxes use blue for core material and purple for advanced material. The [reasoning lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) starts with basic controls; clinical importance remains visible. Select Explore further for advanced controls and methods.

Keep the chronic-pain case as the narrative thread: question, evidence, target difference, power, calculation, recruitment, sensitivity and recommendation. Students progressively complete one assumptions report rather than repeatedly start new tasks. Later sections change the question while retaining this planning logic: describe a symptom percentage, reuse the trial's baseline data, or plan a pilot's retention estimate. Select extensions that serve the session's aim; the core route includes interpreting one simulated trial and many trials in the app or prepared results; constructing simulations and analyzing Monte Carlo uncertainty remain advanced. Compare binary and continuous outcomes in a later session if time permits.

## Session formats

| Duration | Recommended scope |
|---|---|
| 30 minutes | One prepared case, assumption prediction, three interval interpretations and two-sentence justification; use static outputs |
| 60 minutes: core | 10 question and evidence; 10 target difference, power and simple simulation; 15 calculation and recruitment; 10 sensitivity; 15 report and peer feedback |
| 90 minutes: core plus selected extension | The core plan above, plus 30 minutes on either simulation, estimation, feasibility or existing-data reuse |
| Extended practical or homework | Students design a hypothetical investigation, simulate, analyze and write a 200–250 word abstract, followed by peer discussion |

These timings are proposed adaptations to pilot, not schedules validated by the publications. Full DICE investigations require substantial design and interpretation time. Allocate the separate pre-assessment before teaching and the post/transfer assessment after it, or reduce activity scope to accommodate them.

## Discussion prompts

- Why is the effect expected from a small pilot uncertain?
- Is the target difference the same as the clinically important threshold, and why?
- Can a well-powered design yield an inconclusive study?
- Does exclusion of zero establish clinical importance?
- What changes when you increase participants? What changes when you increase replications?
- What information can a resource-limited study provide for its actual aim?

## Methods to make explicit

The two-group designs have equal independent groups. The simple calculator apps use labeled normal approximations. The [reasoning lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) uses two-sided pooled-variance t-test power for normal outcomes, and a score-test power approximation for binary outcomes. The binary confidence interval uses Newcombe-Wilson rather than inversion of that score test; explain occasional test/CI disagreement. Never describe the binary power approximation as exact. The single-proportion app uses an approximate precision plan and illustrates Wilson intervals. The Type I error rate/Type II error rate app uses a known-SD normal mean example. Read the [statistical methods](../documentation/statistical-methods.md) before teaching.

The [lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study)'s width target is FULL width. The normal width curve is an expectation, while the binary curve is a plug-in anticipation. Neither guarantees each interval meets the target. The simulation separately reports the fraction meeting it. Dropout inflation preserves expected analyzable counts; it does not resolve missing-data bias.

## Assessment and co-creation

Our account in Wieringa et al. (2025) describes a user-centered development process for epidemiology and medical statistics e-learning, including stakeholder needs and online preparation with face-to-face teaching. Use this as a design reference: ask learners and teachers to review navigation, explanations and activities, then revise the material using their feedback. It does not establish learning gains for this module. See the [publication](https://doi.org/10.5281/zenodo.15064177) and the full entry in the tutorial bibliography.

Use `constructive_alignment_table.md`, `assessment_rubric.md` and the case template together. Collect pseudonymously paired conceptual responses using `pilot_learning_assessment.md`; collect usability/confidence feedback separately. Include an unfamiliar transfer case and an optional delayed assessment. Record participant and response counts and report descriptive changes without claiming causal superiority from an uncontrolled pilot.

Students can adapt cases, challenge unclear assumptions and suggest explanations. Use `case_quality_checklist.md` and `peer_review_form.md` before teacher approval. Keep consent records outside the public repository and do not make public contribution consent a condition of participation.

Assess only what the selected route teaches. Core learners submit a justified calculation and sensitivity analysis; criterion 9 of the rubric is an optional advanced simulation extension. The learning-assessment form provides separate core and simulation versions of item 4. For an estimation or pilot project, assess the target quantity, denominator, useful precision and decision criteria rather than requiring a treatment hypothesis. Prepared outputs can support the same interpretation tasks. Orsini's workshop feedback and the simulation teaching papers motivate these activities, but do not establish their effectiveness here.

## References

See [References](../documentation/references.md) and [evidence and design rationale](../documentation/evidence-and-design-rationale.md) for source contributions and limitations. Learning effectiveness of this local module remains to be evaluated.

## Consolidated book and app route

Use the single learner source in `module/Sample_size_open_module.Rmd`. Short sessions select from this book; do not create an independently maintained short tutorial. R code and raw output are available in expandable sections, but students are assessed on interpretation, not code.

| Route | Book chapters and evidence |
|---|---|
| Core | Chronic-pain assumptions report, power interpretation, worked calculation, recruitment, sensitivity table and clinical interval interpretation |
| Simulation extension | the one-study, power-curve and repeated-trial activities with generating assumptions, analysis and Monte Carlo uncertainty; use prepared results if needed |
| Estimation or feasibility extension | Prevalence, pilot retention or existing-dataset reuse, with useful precision and justified conclusions |
| Own project | Check the design first; use an appropriate planning method and adapt the assessment criteria to the goal |

[Activity: Chronic pain: one study and many studies](https://katatam.github.io/sample-size-calculation/study/?activity=pain_one_many): distinguish one result, power, Type I error and Monte Carlo uncertainty. [Activity: Chronic pain: explore power and recruitment](https://katatam.github.io/sample-size-calculation/study/?activity=pain_curves): read several curves and distinguish recruitment from expected analyzable counts. [Activity: Simulate repeated chronic-pain trials](https://katatam.github.io/sample-size-calculation/study/?activity=pain_simulation): identify generation, analysis, repetition and summary. Collect a prediction and a written explanation where they help the chosen activity. No ANOVA lesson is required.

Open the [two-panel study view](https://katatam.github.io/sample-size-calculation/study/). The activity selector loads matched case assumptions. Drag the separator to adjust panel widths, or focus it and use Left/Right arrow keys; Home and End reach the width limits. Chapter navigation leaves the app session open; choosing or resetting an activity applies that preset. Content links open in a new tab. On narrow screens, Both stacks the panels, while Lesson and App show either panel alone. Students can also open either panel separately.

Use the [glossary](../student-materials/glossary.md), [FAQ](../student-materials/common-mistakes.md) and [study-design guide](../student-materials/study-design-guide.md) as needed. Formulas remain visible; code and raw output can be expanded.

For an own-study exercise, students can complete the [lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study)'s My study tab, save the plan, and download a draft justification. Check their evidence, clinical threshold, participant burden and recruitment assumptions. A draft needs review against the intended design. The [software validation guide](../documentation/software-validation.md) is optional teacher material.

The separate [assumptions report activity](https://katatam.github.io/sample-size-calculation/study/?activity=assumptions_report) records sources, their relevance, uncertain assumptions and the resulting recommendation. It also supports single-population estimation, fixed data and pilot objectives. It does not compute or validate a new sample size. Students should distinguish the default fixed-sample pain illustration from the sample selected to meet 90% target power in the tutorial.
