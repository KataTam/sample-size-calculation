# Teaching guide

The [activity walkthroughs](../student-materials/activity-walkthroughs.html) describe each activity's purpose, steps and connection to the narrative, distinguishing analytical calculations from simulated patient outcomes.


The module teaches sample size as a justified research-design decision. Activities combine predictions, app-based exploration and interpretation of results. A session can begin with a clinical question and end with an explanation of what the planned study could establish. The guided group activities below are optional teaching arrangements; independent learners can use the tutorial and its chapter quizzes on their own.

The chronic pain case compares fictional Neravixa with duloxetine for painful diabetic peripheral neuropathy. Each patient contributes one four-week outcome: achieved pain relief or did not achieve pain relief. The pilot remains 7 of 10 versus 3 of 10; the calculation uses population assumptions of 60% versus 30%. Selecting a calculator or simulation preview opens the app within the chapter, with its main controls above the figure and a link to its own page underneath. Closing and reopening the embedded app preserves its inputs during that page visit.

## Preparation and access

The embedded [report review](../book/reporting.html#report-error-activity), [discharge review](../book/exercises.html#discharge-error-activity), [recruitment review](../book/simulation.html#recruitment-error-activity) and advanced [software review](../book/appendix.html#software-error-activity) ask learners to identify questionable passages. Some passages are appropriate. Learners can first give a reason for their choice, then open the explanation and draft a correction. A partner can check whether the revision preserves the intended study question and matches the calculation. The PDF provides the same passages and answer key. A count of passages opened measures participation in this exercise; an independently written correction gives stronger evidence of understanding.

For a pilot, the [observation notes](pilot_observation_notes.html#optional-page-time-recording) describe a possible opt-in page-time recorder, how to handle split-screen use and the limits of timing data. Recording is not currently enabled.

Learners should know sample versus population, binary versus continuous outcomes, and the basic purpose of a statistical test. The estimation chapter introduces confidence intervals. Send the case, short concept notes and access link in advance. Provide the complete tutorial HTML/PDF and `static_activity.md` with prepared outputs as alternatives to live apps. Formulas and formatted results remain visible; expandable R code and output support reproducibility and further learning.

The apps keep the main result visible while secondary settings can remain closed. Learners can drag sliders or type values on the displayed scale; percentage fields use 5 for 5%. Calculated results update with the inputs. Simulated results update when learners run another simulation and retain the assumptions used for that run. The introductory pain activity brings one study and many studies together, with a separate report view and optional further calculations. For independent practice, the flashcard table can hide answers until requested. The study-plan form shows completion counts and a live report beside the questions when the screen is wide enough.

Before a larger classroom session, an initial usability pilot with about five learners can identify unclear tasks and navigation problems. The [pilot observation notes](pilot_observation_notes.md) provide a task-based protocol. After revision, a class of 20–25 can work in pairs or groups of 3–4, rotating the roles of explaining, checking assumptions and recording. The teacher should check the deployment environment and keyboard access, supply readable static alternatives and identify invented case values as hypothetical.

## Selecting a learning route

Chapters 1–3 form the core sequence, and Chapters 4–8 provide optional advanced branches. The glossary and common questions support either route. The [core route](../book/index.html#core-route) covers clinical assumptions, power, a simple one-study/many-studies simulation, two-group calculations, expected losses, recruitment feasibility and a complete calculation report. The [advanced route](../book/index.html#advanced-route) starts with estimation and confidence intervals in Chapter 4, then covers power curves, repeated-study simulation and other designs. Chapter headings and learning-outcome boxes use blue for core material and purple for advanced material. The [reasoning lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) starts with basic controls; clinical importance remains visible. Select Explore further for advanced controls and methods.

The chronic-pain case provides the narrative thread: question, evidence, target difference, power, calculation, recruitment, sensitivity and recommendation. Students progressively develop one assumptions report as they work through the tutorial. Later sections change the question while retaining this planning logic: describe a symptom percentage, reuse the trial's baseline data, or plan a pilot's retention estimate. Extensions should serve the session's aim; the core route includes interpreting one simulated trial and many trials in the app or prepared results; constructing simulations and analyzing Monte Carlo uncertainty remain advanced. Binary and continuous outcomes can be compared in a later session if time permits.

### Four core activities

| Chapter | Core activity | Contribution to the continuing report |
|---|---|---|
| 1. Research question and power | [Chronic pain: one study and many studies](../study/?activity=pain_one_many) | Question, assumptions and interpretation of power |
| 2. Calculating sample size | [Calculate a sample size: probiotics](../book/calculations.html#calculate-sample-size) | Inputs, procedure, software and analyzable counts |
| 3. Recruitment and feasibility | [Adjust recruitment](../study/?activity=recruitment) using one shared loss percentage | Recruitment per group and in total, with a short justification |
| 4. The sample size calculation report | [Review and complete a report](../book/reporting.html#check-reporting) | Four-error review followed by a consistency check of the learner's report |

The report builder is a continuing workspace for these activities. Its core view has 12 prompts for a two-group power calculation. Learners can use a supplied case and short explanations. The binary calculation is the core activity; rehabilitation offers optional mean-score practice. The Chapter 3 report review replaces that chapter's multiple-choice check. Chapters 1–2 retain short quizzes. The optional cumulative quiz uses different questions and shuffles their order for each new attempt. The estimation chapter offers a neuropathy prevalence example, a completed report and an error-spotting review for further practice.

The [additional discharge practice](../book/exercises.html#discharge) reinforces introductory calculations. Advanced extensions cover [unequal losses and treatment switching](../book/simulation.html#recruitment-extensions), independent evidence appraisal, plausible ranges, several sensitivity scenarios, and a fuller supporting study plan. In the report builder, opening “Advanced study plan” reveals these additional prompts while retaining the same answers. Full independent planning should be assigned only when it serves the course objectives.

## Session formats

The session plans select activities from the tutorial. They allow for prior preparation and should be adjusted after observing the group. Completing the entire Core route, writing a justification and receiving feedback requires additional time.

| Format | Preparation | In-session focus | Expected product |
|---|---|---|---|
| 30-minute introduction | Teacher supplies the pain case and three simulated trials | 5 minutes on the question; 5 on assumptions; 10 on sample variability and power; 10 on explanation and discussion | An explanation of what stays fixed and what varies, with one uncertain assumption |
| 60-minute core workshop | Learners read Chapters 1–2 and attempt their chapter checks; teacher selects one calculation | 10 minutes on the question and supplied assumptions; 10 on simulation; 15 on one calculation; 10 on recruitment; 15 on report review and paired feedback | A partially completed report and one justified revision |
| 90-minute workshop | Core preparation plus one selected advanced reading | The 60-minute workshop plus 30 minutes on fixed resources, simulation or precision, matched to the group's question | A report with one advanced extension |
| Extended practical or homework | Relevant core chapters and a chosen clinical question | Calculation, evidence search, sensitivity analysis, a 300–600-word justification and peer review across separate stages | A revised report with sources and a response to feedback |

These are proposed teaching allocations. The pilot should establish how much preparation and support the intended learners need. Formal pre/post assessments need time outside these allocations or a reduction in activity scope.

## A study plan developed across chapters

The [study-plan activity](https://katatam.github.io/sample-size-calculation/study/?activity=assumptions_report) can be opened from the first session. Its report downloads as PDF by default, with an editable Word alternative. “Save work for later” stores entries for reopening in the activity. The [case template](../case-studies/student_case_template.md) provides prompts for an offline document. The activity starts with empty answers and the core two-group power settings. Students can choose “Resume saved plan” or explicitly start the teaching example. Early entries may remain provisional, with missing evidence identified.

| Stage | Report entries | Teacher's review question |
|---|---|---|
| Chapter 1: research question and power | PICO, observed earlier data, target difference, clinical threshold, error probabilities and power | How does the evidence support the planning assumptions? |
| Chapter 2: calculating sample size | Inputs, procedure, software and analyzable counts | Does the calculation match the intended comparison? |
| Chapter 2: recruitment planning | One shared loss assumption and recruitment counts | Are the per-group and total counts consistent with the selected calculation? |
| Chapter 3: the sample size calculation report | Concise calculation report followed by the supporting study plan | Could another researcher reproduce the calculation and assess its justification? |

The seven planning questions in Chapter 1 can guide short individual decisions within this report. A learner may initially write “evidence needed” for a field and revise it after a relevant chapter. The teacher should assess the reasoning behind revisions.

## App reports and saved work

The calculation apps' “Report” view brings together the current assumptions, results and any written responses. The reasoning lab also identifies the selected example, recruitment feasibility and simulation assumptions. Its five writing prompts cover the research question, clinical relevance, participant burden, evidence and final recommendation. For an unsupported study design, the report retains the study notes and resource assessment and indicates that a design-specific calculation is needed.

Reports include simulated results only when they match the current example and settings. After a change, an earlier result may remain visible in a simulation panel with its original assumptions, while the report explains that it has been omitted. Learners should rerun the relevant simulation before submitting a report that discusses its results. In the two-group calculators, the report also records the revised comparison scenario when its inputs are valid and differ from the main plan.

Gray model answers illustrate responses using the selected example and current parameters; they are excluded from reports and backups. Question help explains what to enter or interpret. Students' written responses remain as entered when settings change, so you should check that their explanation still matches the reported calculation. The one-study and many-studies reflection questions have expandable model answers; you can collect learners' explanations orally or in their study plan.

For assessment, you can request the PDF report or editable Word document. The separate “Save work for later” controls in the reasoning lab and study-plan form save a JSON file; “Reopen saved work” restores it in the same app. Lab simulations are cleared on reopening and should be rerun. Editing a Word report changes that document only. The [download guide in the walkthroughs](../student-materials/activity-walkthroughs.html#reports-and-saved-work) explains reports, saved work, simulation data and reproducible R scripts.

## Prediction, discussion and revision

For a selected activity, learners should have a chance to formulate an individual prediction before discussing it. The following 15-minute cycle can fit within a workshop; teachers can extend the discussion when explanations reveal uncertainty.

| Phase | Approximate time | Prompt | What the teacher should listen for |
|---|---|---|---|
| Individual prediction | 2 minutes | What would change if this one input changed? Which quantities stay fixed? | A stated assumption and a directional prediction |
| App or prepared-result exploration | 4 minutes | How does the result compare with your prediction? | Use of the current inputs, with population assumptions distinguished from sampled outcomes |
| Paired explanation | 4 minutes | Where do your interpretations agree or differ? What evidence supports each? | Reasons for disagreement; distinction between one study and repeated-study performance |
| Report revision | 3 minutes | What would you now change in the plan, and why? | A justified decision and remaining uncertainty |
| Brief debrief | 2 minutes | Which point still needs clarification? | A specific learning need for follow-up |

In [the one-study and many-studies activity](https://katatam.github.io/sample-size-calculation/study/?activity=pain_one_many), a useful comparison increases patients per group while holding the population probabilities and analysis fixed. Sample percentages and observed differences vary across trials; larger samples generally reduce this variability and increase power at a specified nonzero difference. More simulation repetitions make estimated power more stable while each trial retains the same design.

In the [two-proportion calculator](https://katatam.github.io/sample-size-calculation/two_proportions/) or [two-mean calculator](https://katatam.github.io/sample-size-calculation/two_means/), learners can predict the sample-size consequence of changing one input and then explain the result. For two means, a larger SD at a fixed target difference usually requires more patients. For binary outcomes, both event probabilities matter. The report should record the chosen inputs and why they are plausible.

## Open-ended prompts and learners' own research

The chapter quizzes supply individual knowledge checks. A teacher can select one additional discussion prompt when deeper justification is a learning objective:

- A colleague proposes a 30-percentage-point target because planning for 20 points requires too many patients. What evidence, patient priorities and intended conclusion would be needed to defend the choice? A strong explanation addresses realism, clinical importance and the lower power at the smaller worthwhile effect.
- In your own research question, what would a false positive or false negative mean in practice? A strong explanation states what is assumed true and distinguishes the statistical conclusion from a subsequent clinical decision.
- Two groups recommend different sample sizes. What inputs and methods should be compared first? A strong explanation checks outcome, effect scale, analysis, error probabilities, allocation, loss assumptions and rounding.

Learners can use a hypothetical case when their own project has an unsuitable design or insufficient public evidence. [Study designs and testing strategies](../book/study-designs.html) helps identify an appropriate route. Assessment should follow the chosen research objective and the [rubric](assessment_rubric.md).

## Optional discussion of complex trial plans

Chapter 7, [Study designs and testing strategies](../book/study-designs.html), brings together dependent observations, multiple outcomes and decisions during a trial. Learners can select the branch relevant to their question. The core calculation activities assume a final analysis of a simple design.

For an advanced discussion, a pair of learners could extend the chronic pain plan with a sleep outcome and compare three success rules: benefit on either outcome, benefit on both, or pain relief followed by sleep improvement in a fixed sequence. Their explanation should identify the claims and the corresponding error-control and power questions. A second discussion could consider a proposed interim analysis: what decision would it inform, what would trigger stopping, and which assumptions determine the maximum and expected recruitment?

The [chapter check](../book/study-designs.html#check-study-designs) assesses these distinctions. Chapter 6 explains [simulation of the complete decision procedure](../book/simulation.html#simulating-decision-rules), and the reproducibility chapter provides the [additional reporting checklist](../book/appendix.html#complex-design-record). Assessment can focus on recognizing and documenting the required decisions; implementing a new adaptive-design calculation requires specialist methods. The advanced flashcards provide short reminders.

## Optional learner-created dilemmas

A short contribution can contain a PICO question, one uncertain planning assumption, a decision for a peer to consider, a worked explanation and source links. Invented values should be identified. Learners should be able to complete this as a course exercise without consenting to public reuse.

The author first drafts the dilemma, a peer identifies one assumption needing evidence and one useful next comparison, and the author revises the explanation. The [peer-review form](../case-studies/peer_review_form.md) records this exchange; the [case-quality checklist](../case-studies/case_quality_checklist.md) supports teacher review. A future gallery should follow successful classroom use, explicit permission and editorial review. Consent records and identifiable assessment data belong outside the public repository.

## Discussion prompts

- Why is a difference observed in a small pilot an uncertain guide to the population difference?
- Is the target difference the same as the clinically important threshold, and why?
- Can a well-powered design yield an inconclusive study?
- Does exclusion of zero establish clinical importance?
- What changes when you increase participants? What changes when you increase replications?
- What information can a resource-limited study provide for its actual aim?

## Methods to make explicit

The two-group designs have equal independent groups. The two-proportion calculator uses a normal approximation; the two-means calculator and reasoning lab both plan a pooled two-sample t test. The normal formula in Chapter 2 explains the mean calculation, followed by a brief transition to the t-test result used in apps and reports. Rehabilitation is collapsed additional practice. Learning outcomes use observable verbs from [Bloom’s revised taxonomy](https://teaching.uic.edu/blooms-taxonomy-of-educational-objectives/): explain, calculate, interpret, and identify. Both apps use the same methods as the [reasoning lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study). In advanced work, the binary confidence interval uses Newcombe-Wilson; the methods record explains possible disagreement with the score test near the significance boundary. Never describe the binary power approximation as exact. The single-proportion app plans estimation using an approximate interval-width criterion and illustrates Wilson intervals. The Type I error probability/Type II error probability app uses a known-SD normal mean example. Read the [statistical methods](../documentation/statistical-methods.md) before teaching.

The [lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study)'s width target is FULL width. The normal width curve is an expectation, while the binary curve is a plug-in anticipation. Neither guarantees each interval meets the target. The simulation separately reports the fraction meeting it. Dropout inflation preserves expected analyzable counts; it does not resolve missing-data bias.

## Assessment and co-creation

Our account in Wieringa et al. (2025) describes a user-centered development process for epidemiology and medical statistics e-learning, including stakeholder needs and online preparation with face-to-face teaching. Use this as a design reference: ask learners and teachers to review navigation, explanations and activities, then revise the material using their feedback. It does not establish learning gains for this module. See the [publication](https://doi.org/10.5281/zenodo.15064177) and the full entry in the tutorial bibliography.

The [alignment table](constructive_alignment_table.md), [assessment rubric](assessment_rubric.md) and [case template](../case-studies/student_case_template.md) should be used together. Collect pseudonymously paired conceptual responses using `pilot_learning_assessment.md`; collect usability/confidence feedback separately. Include an unfamiliar transfer case and an optional delayed assessment. Record participant and response counts and report descriptive changes without claiming causal superiority from an uncontrolled pilot.

Students can adapt cases, challenge unclear assumptions and suggest explanations. The [case-quality checklist](../case-studies/case_quality_checklist.md) and [peer-review form](../case-studies/peer_review_form.md) support teacher approval. Keep consent records outside the public repository and do not make public contribution consent a condition of participation.

Assessment should follow the selected route. Core learners submit one concise calculation report developed through the four activities. Independent evidence appraisal and sensitivity scenarios are advanced extensions, as are precision planning and simulation uncertainty. The learning-assessment form provides separate core and simulation versions of item 4. For an estimation or pilot project, the assessment should cover the target quantity, denominator, useful precision and decision criteria. Prepared outputs can support the same interpretation tasks. Orsini's workshop feedback and the simulation teaching papers motivate these activities; their effectiveness in this tutorial still needs evaluation.

The review by [Chan, Botelho, and Lam (2019)](https://doi.org/10.2196/11241) highlights why resource access and time online should not stand in for learning. For this module, a useful evaluation would compare whether learners can justify their target difference, identify a relevant SD or event-probability source, and explain how an uncertain assumption affects the plan. The unfamiliar transfer case and delayed assessment can revisit those decisions. Activity completion and satisfaction should be reported separately; no additional tracking dashboard is needed for these assessments.

## References

See [References](../documentation/references.md) and [evidence and design rationale](../documentation/evidence-and-design-rationale.md) for source contributions and limitations. Learning effectiveness of this local module remains to be evaluated.

## Consolidated book and app route

The single learner source is `module/Sample_size_open_module.Rmd`. Short sessions can select relevant parts of this book. R code and raw output are available in expandable sections; the suggested assessment focuses on interpretation.

| Route | Book chapters and evidence |
|---|---|
| Core | Four core activities and one concise report: simulation, one selected calculation, shared-loss adjustment and report review |
| Simulation extension | power curves, confidence interval coverage, missing-outcome scenarios and Monte Carlo uncertainty; use prepared results if needed |
| Estimation or feasibility extension | Prevalence, pilot retention or existing-dataset reuse, with useful precision and justified conclusions |
| Own project | Check the design first; use an appropriate planning method and adapt the assessment criteria to the goal |

[Activity: Chronic pain: one study and many studies](https://katatam.github.io/sample-size-calculation/study/?activity=pain_one_many): distinguish one result, power and Type I error probability; Monte Carlo uncertainty belongs to the advanced extension. [Activity: Chronic pain: explore power and recruitment](https://katatam.github.io/sample-size-calculation/study/?activity=pain_curves): read several curves and distinguish recruitment from expected analyzable counts. [Activity: Simulate repeated chronic-pain trials](https://katatam.github.io/sample-size-calculation/study/?activity=pain_simulation): identify generation, analysis, repetition and summary. Collect a prediction and a written explanation where they help the chosen activity. No ANOVA lesson is required.

In the [two-panel study view](https://katatam.github.io/sample-size-calculation/study/), the activity selector loads matched case assumptions. You can drag the separator to adjust panel widths, or focus it and use Left/Right arrow keys; Home and End reach the width limits. Chapter navigation leaves the app session open. “Close app panel” gives the tutorial the full width, and “Tutorial + activity” restores the app while the page remains open. On narrow screens, “Tutorial” and “Activity” show either panel alone. Before resetting or changing an activity, learners should save work they want to retain using the appropriate format above.

Use the [glossary](../student-materials/glossary.md), [FAQ](../student-materials/common-mistakes.md) and [study-design guide](../student-materials/study-design-guide.md) as needed. Formulas remain visible; code and raw output can be expanded.

For an own-study exercise, students can complete the [lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study)'s “My study” and “Report” views. You should review their evidence, clinical threshold, participant burden and recruitment assumptions against the intended design. The [software validation guide](../documentation/software-validation.md) provides optional teacher checks.

The continuing [study-plan workspace](https://katatam.github.io/sample-size-calculation/study/?activity=assumptions_report) records sources, their relevance, uncertain assumptions and the resulting recommendation. It also supports single-population estimation, fixed data and pilot objectives. It does not compute or validate a new sample size. Students should distinguish the default fixed-sample pain illustration from the sample selected to meet 90% target power in the tutorial.


## Extended sample size justification



For an extended assignment, a 300–600-word justification should cover the clinical question, primary outcome, evidence for assumptions, clinical threshold, target difference, planned analysis, [Type I error probability](https://katatam.github.io/sample-size-calculation/book/glossary.html#alpha), target power, per-group counts, recruitment inflation and feasibility. It should include a sensitivity table or curve and explain the consequences of uncertain assumptions. Advanced work can add a simulation.

You can use the chronic pain report you have developed through the tutorial, or a justified two-arm case of your own. Your explanation should justify the target difference's importance and realism using relevant evidence. The report should identify the calculation method and distinguish required analyzable counts from recruitment. These elements follow [Cook et al. (2018)](https://katatam.github.io/sample-size-calculation/book/references.html#ref-cook2018delta2) and [CONSORT's sample size reporting guidance (2025)](https://katatam.github.io/sample-size-calculation/book/references.html#ref-consortee2025).

You can complete and save your text in [Activity: Develop and justify your study plan](https://katatam.github.io/sample-size-calculation/study/?activity=assumptions_report). The [case template](https://katatam.github.io/sample-size-calculation/case-studies/student_case_template.html) provides the same planning prompts for an offline document. The [assessment rubric](https://katatam.github.io/sample-size-calculation/teaching/assessment_rubric.html) explains how to review your justification. A brief final note should identify an assumption you revised and the evidence or reasoning that changed it. For an advanced estimation, feasibility or fixed-dataset project, replace the treatment-power requirement with its relevant information target and denominator.

You can discuss these review questions with a collaborator:

- Are the assumptions supported and distinguished from clinical judgments?
- Does the calculation match the planned analysis?
- Are per-group, total and recruitment counts unambiguous?
- Does the [sensitivity analysis](https://katatam.github.io/sample-size-calculation/book/glossary.html#sensitivity-analysis) keep the appropriate quantities fixed?
- Does the interpretation acknowledge what an inconclusive result could mean?

Teaching text: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Original software code: [MIT](https://opensource.org/license/mit). Third-party attributions and exceptions remain applicable.

## One developing study-plan assignment

Chapter 3's [annotated sample size calculation report](https://katatam.github.io/sample-size-calculation/book/reporting.html#write-a-sample-size-justification) provides a completed calculation and a deliberately flawed paragraph for review. Partners can identify incorrect claims and missing information, then compare their revisions with the collapsed model answer. The example follows the activity's four report groups and uses 5% expected loss: 56 analyzable patients and 59 recruits per group (118 recruits total). The report demonstrates how pilot evidence and explicit clinical judgments inform numerical inputs. Students can distinguish evidence-supported inputs from judgments needing further support in their own plans. The accompanying R code reproduces both the analyzable count and recruitment target; supporting sensitivity analyses belong in the protocol or an accompanying table.

The activity shows the prepared example's calculation date, R and stats versions, command and source version. A transferred result retains the calculator's actual runtime information. Students' written answers remain separate and should be checked against the selected calculation. The reporting elements also draw on section 4.1 of the [UMCG SAP template](https://umcg.zenya.work/document/2f52710d-3ebc-495e-a4dc-6dee95742c78), available to UMCG students and researchers.

Students choose one study and maintain one set of answers across the three core chapters. Teaching examples in other activities provide practice; students select which results belong in their own plan. Chapters 1–2 introduce the question and power, calculation, and recruitment. Chapter 3 gathers the reporting instructions and complete example. Students can record decisions as they read, then review the report and supporting evidence together. Sensitivity analyses can be documented alongside the principal calculation. Advanced extensions depend on the chosen question.

A provisional answer is a useful starting point. Students can mark each section ready for review; edits to key assumptions flag the affected sections for another review. The advanced view supports a fuller evidence review, plausible ranges and several sensitivity scenarios. The report's automated checks compare structured saved results; evidence credibility and numbers embedded in prose need review.

For paired review, one learner explains the evidence and plausible range for a key input. Their partner checks comparability and asks whether less favorable or conflicting findings were considered. Together they examine one alternative using an existing calculation or the [sample size reasoning app](https://katatam.github.io/sample-size-calculation/study/?activity=pain_curves). The learner then revises the same report answer, or explains why it stands. Assessment should credit recognition of uncertainty and justified decisions. The [evidence and uncertainty discussion](https://katatam.github.io/sample-size-calculation/book/curves.html#planning-uncertainty) supplies empirical examples for the debrief.

The final submission can be the complete PDF or editable Word study plan. It begins with the concise sample size calculation report and then includes the supporting answers, review notes and selected calculation records. The same entered answers generate both parts, so students can revise their reasoning without maintaining two separate documents. Quality depends on the reasoning and evidence, as well as completion. Differences observed in previous data, target differences and clinical thresholds can coincide or follow different orders; assessment should distinguish their roles and justification. The [evidence and uncertainty discussion](https://katatam.github.io/sample-size-calculation/book/curves.html#st01-expectations) supports four review questions: whether the comparator outcomes apply to these patients, what else could explain a reported benefit, which harms and burdens justify the clinical threshold, and how plausible alternatives affect the recommendation. In the chronic pain case, one extra patient with relief per five treated expresses the threshold; the judgment about four additional safety-monitoring visits and short-lived dizziness explains its selection. A conclusion that the proposed study is infeasible can be well justified. Quizzes and practice examples support learning without becoming compulsory report attachments.

The three core chapters retain four activities. Chapter 2 combines calculation and recruitment: learners can explain the conditional steps in the 100 → 40 → 30 → 15 monthly recruitment funnel before completing their recruitment allowance. Detailed treatment changes belong to the advanced design chapter; sensitivity analysis and options for increasing power belong to the advanced power chapter. The report chapter focuses on the checklist, worked report and review. Protocol amendments and complex-design records are covered in the reproducibility chapter.
