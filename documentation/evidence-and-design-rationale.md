# Evidence and design rationale

This package combines a clinical question, explicit assumptions, deterministic exploration, stochastic studies and explanation of informational value. These are teaching modes, not mutually exclusive simulation categories. Resampling can itself use Monte Carlo. No claim is made that the local package is superior to conventional teaching before evaluation.

| Source | Implemented contribution | Limits |
|---|---|---|
| Lakens 2022 | Goal selection, separate effect judgements, resource constraints and sensitivity | Methodological framework, not a learning-effectiveness study |
| Sandoval et al. 2025 | Power alongside precision, intervals and clinical thresholds | Published clinical teaching comparator; classroom experience does not establish comparative efficacy |
| Thiesmeier and Orsini 2024 | Design, simulate, analyse, interpret and communicate; extended abstract task | DICE means Design, Interpret, Compute, Estimate. Viewpoint with no formal effectiveness evaluation; full activity needs substantial time |
| Orsini et al. 2024 | One versus many studies, inferential errors, preparation, small groups and optional coding | 85 attendees, 53 evaluable responses, 89% reporting better understanding; self-report without formal knowledge testing or properly paired pre/post data |
| Rudolph et al. 2021 | Controlled experiments to investigate statistical misconceptions | Pedagogical rationale; not direct evidence of local learning gains |

The initial pilot should focus on one outcome, even though both outcomes are implemented. The 90-minute plan is a proposed local adaptation. Measure conceptual reasoning with paired tasks and transfer separately from confidence and usability. The OEIF proposal's 20–25 learner pilot is intended for refinement, not a definitive comparative efficacy claim.

## Supplemental code review

The DICE supplement was consulted but not copied. Its expression `2*pnorm(z)` is not a general two-sided normal p-value for positive z; the symmetric expression is `2*pnorm(-abs(z))`. A seed can be set once for a whole batch while retaining independent draws; deleting the seed is unnecessary. The new code uses its own implementation and documented methods. Normal outcomes use t rather than normal-reference p-values when variance is estimated.

## References

Full bibliographic details are in [References](references.md). Statistical implementation and provenance are documented in [statistical methods](statistical-methods.md) and [third-party notices](third-party-notices.md).

## Superpower-inspired revision

Caldwell et al. (2022), chapters 1, 11 and 15, informed the visible code/output layout and repeated-study, curve-reading and custom-simulation activities. These are original clinical adaptations; they do not add ANOVA to the learner pathway. Albers and Lakens (2018) informs pilot uncertainty; Caldwell and Vigotsky (2020) informs clinically interpretable effects; Althouse (2021) informs the distinction from observed post hoc power. These methodological sources do not establish educational effectiveness of this resource. Bibliographic records are maintained only in `module/references.bib`.
