# Evidence and design rationale

This package combines a clinical question, explicit assumptions, deterministic exploration, stochastic studies and explanation of informational value. These are teaching modes, not mutually exclusive simulation categories. Resampling can itself use Monte Carlo. No claim is made that the local package is superior to conventional teaching before evaluation.

| Source | Implemented contribution | Limits |
|---|---|---|
| [Wieringa et al. 2025](https://doi.org/10.5281/zenodo.15064177) | User-centered development, learner and teacher feedback, and preparation followed by guided discussion | Preprint describing development of an e-learning environment; not evidence of learning gains for this module |
| Lakens 2022 | Goal selection, separate effect judgments, resource constraints and sensitivity | Methodological framework, not a learning-effectiveness study |
| Sandoval et al. 2025 | Power alongside precision, intervals and clinical thresholds | Published clinical teaching comparator; classroom experience does not establish comparative efficacy |
| Thiesmeier and Orsini 2024 | Design, simulate, analyze, interpret and communicate; extended abstract task | DICE means Design, Interpret, Compute, Estimate. Viewpoint with no formal effectiveness evaluation; full activity needs substantial time |
| Orsini et al. 2024 | One versus many studies, inferential errors, preparation, small groups and optional coding | 85 attendees, 53 evaluable responses, 89% reporting better understanding; self-report without formal knowledge testing or properly paired pre/post data |
| Rudolph et al. 2021 | Controlled experiments to investigate statistical misconceptions | Pedagogical rationale; not direct evidence of local learning gains |

The initial pilot should focus on one outcome, even though both outcomes are implemented. The 90-minute plan is a proposed local adaptation. Measure conceptual reasoning with paired tasks and transfer separately from confidence and usability. The OEIF proposal's 20–25 learner pilot is intended for refinement, not a definitive comparative efficacy claim.

## Literature-informed planning narrative

The chronic-pain example now links the question, outcome and analysis to target selection, power, calculation, recruitment, sensitivity and a written recommendation. DELTA² supports importance and realism of the target difference; it does not require three different values or equate every target with the minimum clinically important difference. The tutorial explicitly evaluates smaller worthwhile differences. Fong and Wang and Ji support the question-to-analysis sequence; CONSORT supports documenting the calculation and avoiding observed-effect post hoc power.

Ying and Eldridge inform objective-specific pilot planning and progression; Lakens informs fixed-resource and existing-dataset justification. Candel informs conditional design efficiency, and Riley informs the distinction between treatment comparisons and prediction development. Pargent informs the advanced simulation workflow. The core assessment requires a sensitivity calculation and interpretation, while simulation and its Monte Carlo uncertainty remain advanced. The reading guide separates entry points, design-specific sources, methods and educator evidence.

Local summaries vary in coverage. Full methodological claims should not be attributed to sources represented only by a bibliographic record or publisher description. Clayton's exact historical notes have not been recovered; Althouse and Moyé/Tita reading notes do not establish a full-text review. The cited FDA natural-history and external-control documents are explicitly drafts. Unverified local manuscript metadata is not added as a formal learner citation. Educational design sources motivate the approach without proving learning gains.

## Supplemental code review

The DICE supplement was consulted but not copied. Its expression `2*pnorm(z)` is not a general two-sided normal p-value for positive z; the symmetric expression is `2*pnorm(-abs(z))`. A seed can be set once for a whole batch while retaining independent draws; deleting the seed is unnecessary. The new code uses its own implementation and documented methods. Normal outcomes use t rather than normal-reference p-values when variance is estimated.

## References

Full bibliographic details are in [References](references.md). Statistical implementation and provenance are documented in [statistical methods](statistical-methods.md) and [third-party notices](third-party-notices.md).

## Superpower-inspired revision

Caldwell et al. (2022), chapters 1, 11 and 15, informed the visible code/output layout and repeated-study, curve-reading and custom-simulation activities. These are original clinical adaptations; they do not add ANOVA to the learner pathway. Albers and Lakens (2018) informs pilot uncertainty; Caldwell and Vigotsky (2020) informs clinically interpretable effects; Althouse (2021) informs the distinction from observed post hoc power. These methodological sources do not establish educational effectiveness of this resource. Bibliographic records are maintained only in `module/references.bib`.
