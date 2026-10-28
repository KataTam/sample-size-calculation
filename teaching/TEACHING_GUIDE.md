# Teaching guide

The [activity walkthroughs](../student-materials/activity-walkthroughs.html) describe each activity's purpose, steps and connection to the narrative, distinguishing analytical calculations from simulated patient outcomes.


The module teaches sample size as a justified research-design decision. Activities combine predictions, app-based exploration and interpretation of results. A session can begin with a clinical question and end with an explanation of what the planned study could establish. The guided group activities below are optional teaching arrangements; independent learners can use the tutorial and its chapter quizzes on their own.

## Preparation and access

Learners should know sample versus population, binary versus continuous outcomes, and the basic purpose of a test and confidence interval. Send the case, short concept notes and access link in advance. Provide the complete tutorial HTML/PDF and `static_activity.md` with prepared outputs as alternatives to live apps. Formulas and formatted results remain visible; expandable R code and output support reproducibility and further learning.

Before a larger classroom session, an initial usability pilot with about five learners can identify unclear tasks and navigation problems. The [pilot observation notes](pilot_observation_notes.md) provide a task-based protocol. After revision, a class of 20–25 can work in pairs or groups of 3–4, rotating the roles of explaining, checking assumptions and recording. The teacher should check the deployment environment and keyboard access, supply readable static alternatives and identify invented case values as hypothetical.

## Selecting a learning route

The [core route](../book/index.html#core-route) covers clinical assumptions, power, a simple one-study/many-studies simulation, two-group calculations, expected losses, interpretation, a short sensitivity analysis and a written justification. The [advanced route](../book/index.html#advanced-route) adds sampling distributions, power curves, repeated-study simulation, estimation with a precision target and other designs. Chapter headings and learning-outcome boxes use blue for core material and purple for advanced material. The [reasoning lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) starts with basic controls; clinical importance remains visible. Select Explore further for advanced controls and methods.

Keep the chronic-pain case as the narrative thread: question, evidence, target difference, power, calculation, recruitment, sensitivity and recommendation. Students progressively complete one assumptions report rather than repeatedly start new tasks. Later sections change the question while retaining this planning logic: describe a symptom percentage, reuse the trial's baseline data, or plan a pilot's retention estimate. Select extensions that serve the session's aim; the core route includes interpreting one simulated trial and many trials in the app or prepared results; constructing simulations and analyzing Monte Carlo uncertainty remain advanced. Compare binary and continuous outcomes in a later session if time permits.

## Session formats

The session plans select activities from the tutorial. They allow for prior preparation and should be adjusted after observing the group. Completing the entire Core route, writing a justification and receiving feedback requires additional time.

| Format | Preparation | In-session focus | Expected product |
|---|---|---|---|
| 30-minute introduction | Teacher supplies the pain case and three interval examples | 5 minutes on the question; 5 on assumptions; 10 on interval interpretation; 10 on explanation and discussion | A short interpretation with one uncertain assumption |
| 60-minute core workshop | Learners read Chapters 1–3 and attempt their chapter checks; teacher selects one calculation | 10 minutes reviewing assumptions; 10 predicting and exploring simulations; 15 calculation and recruitment; 10 sensitivity; 15 report revision and paired feedback | A partially completed report and one justified revision |
| 90-minute workshop | Core preparation plus one selected advanced reading | The 60-minute workshop plus 30 minutes on fixed resources, simulation or precision, matched to the group's question | A report with one advanced extension |
| Extended practical or homework | Relevant core chapters and a chosen clinical question | Calculation, evidence search, sensitivity analysis, a 300–600-word justification and peer review across separate stages | A revised report with sources and a response to feedback |

These are proposed teaching allocations. The pilot should establish how much preparation and support the intended learners need. Formal pre/post assessments need time outside these allocations or a reduction in activity scope.

## A study plan developed across chapters

The [editable report activity](https://katatam.github.io/sample-size-calculation/study/?activity=assumptions_report) can be opened from the first session. Learners can save their entries and return to them. The [case template](../case-studies/student_case_template.md) provides prompts for an offline document. Early entries may remain provisional, with missing evidence identified.

| Stage | Report entries | Teacher's review question |
|---|---|---|
| Chapter 1: question and planning decisions | Population, intervention, comparator, outcome/time; scale; expected and target differences; clinical threshold | Which values are evidence-based, hypothetical or judgments about importance? |
| Chapter 2: possible study results | Error probabilities and power; an example interval and its interpretation | What changes across studies and what stays fixed? |
| Chapter 3: calculation | Inputs, method, per-group and total counts | Does the calculation match the intended comparison and analysis? |
| Chapter 6: recruitment and feasibility | Evidence for expected losses, recruitment counts, sensitivity and resource limits | Which uncertain assumption most affects the recommendation? |
| Chapter 7: justification | A coherent recommendation and a short revision note | What changed in the plan, and what evidence or reasoning led to that change? |

The seven planning questions in Chapter 1 can guide short individual decisions within this report. A learner may initially write “evidence needed” for a field and revise it after a relevant chapter. The teacher should assess the reasoning behind revisions.

## Prediction, discussion and revision

For a selected activity, learners should have a chance to formulate an individual prediction before discussing it. The following 15-minute cycle can fit within a workshop; teachers can extend the discussion when explanations reveal uncertainty.

| Phase | Approximate time | Prompt | What the teacher should listen for |
|---|---|---|---|
| Individual prediction | 2 minutes | What would change if this one input changed? Which quantities stay fixed? | A stated assumption and a directional prediction |
| App or prepared-result exploration | 4 minutes | How does the result compare with your prediction? | Use of the current inputs, with population assumptions distinguished from sampled outcomes |
| Paired explanation | 4 minutes | Where do your interpretations agree or differ? What evidence supports each? | Reasons for disagreement; distinction between one study and repeated-study performance |
| Report revision | 3 minutes | What would you now change in the plan, and why? | A justified decision and remaining uncertainty |
| Brief debrief | 2 minutes | Which point still needs clarification? | A specific learning need for follow-up |

In [the one-study and many-studies activity](https://katatam.github.io/sample-size-calculation/study/?activity=pain_one_many), a useful comparison increases patients per group while holding the population probabilities and analysis fixed. Sample percentages and intervals vary across trials; larger samples generally improve precision and power at the specified difference. More simulation repetitions make estimated power more stable while each trial retains the same design.

In the [two-proportion calculator](https://katatam.github.io/sample-size-calculation/two_proportions/) or [two-mean calculator](https://katatam.github.io/sample-size-calculation/two_means/), learners can predict the sample-size consequence of changing one input and then explain the result. For two means, a larger SD at a fixed target difference usually requires more patients. For binary outcomes, both event probabilities matter. The report should record the chosen inputs and why they are plausible.

## Open-ended prompts and learners' own research

The chapter quizzes supply individual knowledge checks. A teacher can select one additional discussion prompt when deeper justification is a learning objective:

- A colleague proposes a 30-percentage-point target because planning for 20 points requires too many patients. What evidence, patient priorities and intended conclusion would be needed to defend the choice? A strong explanation addresses realism, clinical importance and the lower power at the smaller worthwhile effect.
- In your own research question, what would a false positive or false negative mean in practice? A strong explanation states what is assumed true and distinguishes the statistical conclusion from a subsequent clinical decision.
- Two groups recommend different sample sizes. What inputs and methods should be compared first? A strong explanation checks outcome, effect scale, analysis, error probabilities, allocation, loss assumptions and rounding.

Learners can use a hypothetical case when their own project has an unsuitable design or insufficient public evidence. [Study designs and planning methods](../book/study-designs.html) helps identify an appropriate route. Assessment should follow the chosen research objective and the [rubric](assessment_rubric.md).

## Optional learner-created dilemmas

A short contribution can contain a PICO question, one uncertain planning assumption, a decision for a peer to consider, a worked explanation and source links. Invented values should be identified. Learners should be able to complete this as a course exercise without consenting to public reuse.

The author first drafts the dilemma, a peer identifies one assumption needing evidence and one useful next comparison, and the author revises the explanation. The [peer-review form](../case-studies/peer_review_form.md) records this exchange; the [case-quality checklist](../case-studies/case_quality_checklist.md) supports teacher review. A future gallery should follow successful classroom use, explicit permission and editorial review. Consent records and identifiable assessment data belong outside the public repository.

## Discussion prompts

- Why is the effect expected from a small pilot uncertain?
- Is the target difference the same as the clinically important threshold, and why?
- Can a well-powered design yield an inconclusive study?
- Does exclusion of zero establish clinical importance?
- What changes when you increase participants? What changes when you increase replications?
- What information can a resource-limited study provide for its actual aim?

## Methods to make explicit

The two-group designs have equal independent groups. The simple calculator apps use labeled normal approximations. The [reasoning lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) uses two-sided pooled-variance t-test power for normal outcomes, and a score-test power approximation for binary outcomes. The binary confidence interval uses Newcombe-Wilson rather than inversion of that score test; explain occasional test/CI disagreement. Never describe the binary power approximation as exact. The single-proportion app plans estimation using an approximate interval-width criterion and illustrates Wilson intervals. The Type I error probability/Type II error probability app uses a known-SD normal mean example. Read the [statistical methods](../documentation/statistical-methods.md) before teaching.

The [lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study)'s width target is FULL width. The normal width curve is an expectation, while the binary curve is a plug-in anticipation. Neither guarantees each interval meets the target. The simulation separately reports the fraction meeting it. Dropout inflation preserves expected analyzable counts; it does not resolve missing-data bias.

## Assessment and co-creation

Our account in Wieringa et al. (2025) describes a user-centered development process for epidemiology and medical statistics e-learning, including stakeholder needs and online preparation with face-to-face teaching. Use this as a design reference: ask learners and teachers to review navigation, explanations and activities, then revise the material using their feedback. It does not establish learning gains for this module. See the [publication](https://doi.org/10.5281/zenodo.15064177) and the full entry in the tutorial bibliography.

The [alignment table](constructive_alignment_table.md), [assessment rubric](assessment_rubric.md) and [case template](../case-studies/student_case_template.md) should be used together. Collect pseudonymously paired conceptual responses using `pilot_learning_assessment.md`; collect usability/confidence feedback separately. Include an unfamiliar transfer case and an optional delayed assessment. Record participant and response counts and report descriptive changes without claiming causal superiority from an uncontrolled pilot.

Students can adapt cases, challenge unclear assumptions and suggest explanations. The [case-quality checklist](../case-studies/case_quality_checklist.md) and [peer-review form](../case-studies/peer_review_form.md) support teacher approval. Keep consent records outside the public repository and do not make public contribution consent a condition of participation.

Assess only what the selected route teaches. Core learners submit a justified calculation and sensitivity analysis; criterion 9 of the rubric is an optional advanced simulation extension. The learning-assessment form provides separate core and simulation versions of item 4. For an estimation or pilot project, assess the target quantity, denominator, useful precision and decision criteria rather than requiring a treatment hypothesis. Prepared outputs can support the same interpretation tasks. Orsini's workshop feedback and the simulation teaching papers motivate these activities, but do not establish their effectiveness here.

The review by [Chan, Botelho, and Lam (2019)](https://doi.org/10.2196/11241) highlights why resource access and time online should not stand in for learning. For this module, a useful evaluation would compare whether learners can justify their target difference, identify a relevant SD or event-probability source, and explain how an uncertain assumption affects the plan. The unfamiliar transfer case and delayed assessment can revisit those decisions. Activity completion and satisfaction should be reported separately; no additional tracking dashboard is needed for these assessments.

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

[Activity: Chronic pain: one study and many studies](https://katatam.github.io/sample-size-calculation/study/?activity=pain_one_many): distinguish one result, power and Type I error probability; Monte Carlo uncertainty belongs to the advanced extension. [Activity: Chronic pain: explore power and recruitment](https://katatam.github.io/sample-size-calculation/study/?activity=pain_curves): read several curves and distinguish recruitment from expected analyzable counts. [Activity: Simulate repeated chronic-pain trials](https://katatam.github.io/sample-size-calculation/study/?activity=pain_simulation): identify generation, analysis, repetition and summary. Collect a prediction and a written explanation where they help the chosen activity. No ANOVA lesson is required.

Open the [two-panel study view](https://katatam.github.io/sample-size-calculation/study/). The activity selector loads matched case assumptions. Drag the separator to adjust panel widths, or focus it and use Left/Right arrow keys; Home and End reach the width limits. Chapter navigation leaves the app session open; choosing or resetting an activity applies that preset. Content links open in a new tab. On narrow screens, Both stacks the panels, while Lesson and App show either panel alone. Students can also open either panel separately.

Use the [glossary](../student-materials/glossary.md), [FAQ](../student-materials/common-mistakes.md) and [study-design guide](../student-materials/study-design-guide.md) as needed. Formulas remain visible; code and raw output can be expanded.

For an own-study exercise, students can complete the [lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study)'s My study tab, save the plan, and download a draft justification. Check their evidence, clinical threshold, participant burden and recruitment assumptions. A draft needs review against the intended design. The [software validation guide](../documentation/software-validation.md) is optional teacher material.

The separate [assumptions report activity](https://katatam.github.io/sample-size-calculation/study/?activity=assumptions_report) records sources, their relevance, uncertain assumptions and the resulting recommendation. It also supports single-population estimation, fixed data and pilot objectives. It does not compute or validate a new sample size. Students should distinguish the default fixed-sample pain illustration from the sample selected to meet 90% target power in the tutorial.
