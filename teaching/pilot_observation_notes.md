# Pilot Observation Notes

Use these notes during a small pilot or colleague review. The aim is to improve the resource before wider sharing.

## Initial pilot with about five learners

The first pilot should include learners with the statistical background of the intended audience. Approximately five participants can reveal practical problems for revision; this small usability exercise cannot establish the tutorial's learning effectiveness. Participation, institutional requirements and handling of identifiable feedback should be agreed before recruitment.

Each learner can attempt a small selection of tasks, with observation or brief think-aloud explanation. Task selections and preparation should be recorded so timings are interpretable. A later round can check whether revisions resolved the observed problems.

| Task | Evidence to observe | Time / assistance / difficulty |
|---|---|---|
| Find the Core route and open its matching activity | Can the learner locate the next relevant material and explain the activity's purpose? | |
| Begin a study plan | Can they distinguish known assumptions from missing evidence and save their answers? | |
| Predict and compare 50 versus 80 patients per group | Can they identify fixed population assumptions and changing sample estimates? | |
| Complete one discharge calculation | Are the treatment percentage, rounding, per-group count and total clear? | |
| Justify an expected loss percentage | Do they seek comparable evidence and acknowledge uncertainty? | |
| Interpret one interval and use the glossary | Can they distinguish evidence of a difference from clinically worthwhile benefit? | |
| Use quiz feedback to revise an explanation | Can they find the relevant section and explain what changed? | |

For each task, the observer should record the learner's explanation as well as task completion. Assistance, skipped steps, time spent interpreting versus navigating, keyboard/touch difficulties and use of static alternatives should be noted. A short closing question can ask which part was hardest to follow and what support would have helped.

The existing [learning-assessment form](pilot_learning_assessment.md) can assess conceptual responses separately from [usability and confidence feedback](pilot_student_feedback.md). Results should be reported descriptively with participant and response counts. Before a larger classroom session, the team should agree which issues need correction and which require another observation round.

## Optional page-time recording

Page-time recording is not currently enabled. A small pilot could use an opt-in recorder with participant codes such as P01, a session code and a CSV download at the end. The file could record the resource, visits, visible-page seconds, pauses and whether the tutorial and app were displayed together. The participant-code key and exported records should be kept in the approved study location, outside the public source repository.

The browser's [Page Visibility API](https://developer.mozilla.org/en-US/docs/Web/API/Page_Visibility_API) can distinguish visible pages from background tabs. The split-screen view needs additional checks: hiding an app panel with CSS does not trigger a visibility change inside its iframe. A shared tutorial-and-app interval should be recorded once, with both resource identifiers; it cannot establish which panel held the reader's attention. Summing overlapping tab or panel times would overstate the session duration.

Time with a visible page open is an approximate engagement measure. An optional inactivity rule would need a stated cutoff and can undercount quiet reading; visible time and idle-adjusted time should therefore remain separate. Observation notes, explanations and pre/post questions should accompany timings. [Chan et al. (2019)](https://doi.org/10.2196/11241) discusses the limits of learning analytics.

[GitHub Pages serves a static website](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages), so participant-level records need a separate collection method. For a small supervised pilot, local recording and participant CSV export are a practical first option. Automatic central collection would require an institution-approved service, agreed access and retention, and participant information before activation.

## Session Details

| Item | Notes |
|---|---|
| Date |  |
| Course or group |  |
| Number of students |  |
| Teaching format |  |
| Module sections used |  |
| Apps used |  |
| Assessment task used |  |

## Constructive Alignment

| Question | Notes |
|---|---|
| Were the intended learning outcomes clear to students? |  |
| Did the activity give students enough practice with those outcomes? |  |
| Did app interaction support the intended learning outcomes? |  |
| Did the assessment task ask for the same kind of thinking as the activity? |  |
| Did students connect calculations to feasibility or ethics? |  |

## Module And Figures

| Check | Notes |
|---|---|
| Students could follow the order of the module |  |
| Tables rendered clearly |  |
| Figures were readable |  |
| Figure references in the text were clear |  |
| Important terms were explained well enough |  |

## Apps

| Check | Notes |
|---|---|
| Apps opened without technical problems |  |
| Inputs were clear |  |
| Output text was understandable |  |
| Plots were readable |  |
| Students changed assumptions intentionally |  |
| Students recorded the assumptions behind their answer |  |

## Accessibility And Inclusion

| Check | Notes |
|---|---|
| Text size was comfortable |  |
| Students could use the resource without relying on color alone |  |
| Keyboard or navigation issues appeared |  |
| A non-interactive backup route was available |  |
| Examples felt relevant to the student group |  |

## Common Student Questions

Record repeated questions or misunderstandings.


## Revision Decisions

| Issue | Proposed change | Priority |
|---|---|---|
|  |  |  |
|  |  |  |
|  |  |  |

## Keep For Next Version

Record parts that worked well and should be preserved.



## Observe the revised sequence

Record time spent interpreting versus operating software, whether students separate differences observed in previous data, target differences and clinical thresholds, whether they confuse B and n, and whether they revise conclusions after viewing precision. Record static-route participation, missing assessment pairs and the number needing technical help. Collect no patient data.
