# Teaching guide

The module teaches sample size as a justified research-design decision. The app is a tool for testing predictions, not the activity by itself. Begin with a clinical question and end with an explanation of what the planned study could establish.

## Preparation and access

Learners should know sample versus population, binary versus continuous outcomes, and the basic purpose of a test and confidence interval. No programming is required for the core route. Send the case, short concept notes and access link in advance. Provide the rendered module and `static_activity.md` with its saved outputs as an offline alternative. Optional visible R code supports reproducibility and further learning.

Check the actual deployment environment before class. The proposed 20â€“25 student pilot can work in groups of 3â€“4 with a facilitator. Let students divide interpretation, assumption checking and recording, and rotate roles; do not let coding dominate participation. Clearly identify all case values as hypothetical. Review accessibility with keyboard and readable text/table alternatives.

## Learning pathway

Choose a goal; complete the assumption map; predict a consequence; explore formulas; generate one study; repeat studies; compare precision; stress-test assumptions at fixed n; communicate a recommendation. Use one outcome in a first session. The lab supports a continuous improvement score and a binary chronic-pain case; compare outcomes in a later session if time permits.

## Session formats

| Duration | Recommended scope |
|---|---|
| 30 minutes | One prepared case, assumption prediction, three interval interpretations and two-sentence justification; use static outputs |
| 60 minutes | Prepared case plus a guided one-study/many-studies demonstration and short worksheet; omit student coding |
| 90 minutes | 10 question; 15 assumptions/predictions; 15 one study; 20 repeated studies; 15 precision/feasibility; 15 justification/feedback |
| Extended practical or homework | Students design a hypothetical investigation, simulate, analyse and write a 200â€“250 word abstract, followed by peer discussion |

These timings are proposed adaptations to pilot, not schedules validated by the publications. Full DICE investigations require substantial design and interpretation time. Allocate the separate pre-assessment before teaching and the post/transfer assessment after it, or reduce activity scope to accommodate them.

## Discussion prompts

- Why is the effect expected from a small pilot uncertain?
- Is the planning effect the same as the clinically important threshold, and why?
- Can a well-powered design yield an inconclusive study?
- Does exclusion of zero establish clinical importance?
- What changes when you increase participants? What changes when you increase replications?
- What information can a resource-limited study provide for its actual aim?

## Methods to make explicit

All core designs have equal independent groups. The simple calculator apps use labelled normal approximations. The reasoning lab uses two-sided pooled-variance t-test power for normal outcomes, and a score-test power approximation for binary outcomes. The binary confidence interval uses Newcombe-Wilson rather than inversion of that score test; explain occasional test/CI disagreement. Never describe the binary power approximation as exact. Read `statistical_methods.md` before teaching.

The lab's width target is FULL width. The normal width curve is an expectation, while the binary curve is a plug-in anticipation. Neither guarantees each interval meets the target. The simulation separately reports the fraction meeting it. Dropout inflation preserves expected analysable counts; it does not resolve missing-data bias.

## Assessment and co-creation

Use `constructive_alignment_table.md`, `assessment_rubric.md` and the case template together. Collect pseudonymously paired conceptual responses using `pilot_learning_assessment.md`; collect usability/confidence feedback separately. Include an unfamiliar transfer case and an optional delayed assessment. Record participant and response counts and report descriptive changes without claiming causal superiority from an uncontrolled pilot.

Students can adapt cases, challenge unclear assumptions and suggest explanations. Use `case_quality_checklist.md` and `peer_review_form.md` before teacher approval. Keep consent records outside the public repository and do not make public contribution consent a condition of participation.

## References

See [References](../REFERENCES.md) and [evidence and design rationale](evidence_and_design_rationale.md) for source contributions and limitations. Learning effectiveness of this local module remains to be evaluated.

## Consolidated book route (22 September 2026)

Use the single learner source in `module/Sample_size_open_module.Rmd`. Short sessions select from this book; do not create an independently maintained short tutorial. Short R examples are visible by default, but students are assessed on interpretation, not code.

| Route | Book chapters and evidence |
|---|---|
| 30 minutes | Clinical question (1), prepared repeated-study results (2), interval interpretation (6), short justification (7) |
| 60 minutes | Above plus power-curve activity (4), using prepared trial results if time is short |
| 90 minutes | 10 min question/assumptions; 15 min Activity 1 (chapter 2); 15 min worked calculation (3); 15 min Activity 2 (4); 15 min Activity 3 (5); 10 min precision (6); 10 min justification/review (7) |
| Extended | Compare estimation/testing goals (6), alter a clinical case and justify the result using the full rubric |

Activity 1: distinguish one result, power, Type I error and Monte Carlo uncertainty. Activity 2: read several curves and distinguish recruitment from expected analysable counts. Activity 3: identify generation, analysis, repetition and summary. For each, collect a prediction and a written explanation. All core examples are two-group clinical studies; no ANOVA lesson is required.
