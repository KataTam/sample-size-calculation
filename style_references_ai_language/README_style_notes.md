# Style References: Avoiding AI-Sounding Language

This folder supports the writing style for the learner-facing sample size module. The aim is not to "beat detectors"; the aim is to preserve the author's original teaching voice and avoid generic, over-smoothed prose.

## References

1. `Geng_Trotta_2024_ChatGPT_academic_writing_style.pdf`
   - Source: https://arxiv.org/abs/2404.08627
   - Shows that LLM-assisted writing can shift academic word frequencies and produce a recognizable abstract style.
   - Practical implication for this module: avoid sudden shifts into generic academic phrasing, inflated transitions, and abstract summary language that was not present in the source tutorial.

2. `Georgiou_2024_linguistic_features_AI_generated_text.pdf`
   - Source: https://arxiv.org/abs/2407.03646
   - Compares human-written and AI-generated texts across linguistic features.
   - Practical implication for this module: preserve natural variation in sentence length, ordinary verbs, and the author's original explanatory rhythm.

3. `Sadasivan_2023_reliability_AI_generated_text_detection.pdf`
   - Source: https://arxiv.org/abs/2303.11156
   - Discusses limits of detecting AI-generated text reliably.
   - Practical implication for this module: do not optimize for detector scores. Focus on transparent authorship, careful editing, and discipline-specific clarity.

Note: the PDFs are useful local reading copies. The repository currently ignores `*.pdf`, so the stable source links above should be kept even if the PDFs are not committed to GitHub.

## Working Style Rules For This Project

- Preserve the wording and teaching voice of the existing tutorial wherever it still fits.
- Prefer concrete statistical and clinical wording over broad educational slogans.
- Avoid stock contrastive constructions such as "not X, but Y" unless they appear in the source or are genuinely needed.
- Avoid generic signposting such as "In today's rapidly evolving landscape", "it is important to note", "this underscores", "delve into", "robust", "seamless", "transformative", and similar filler.
- Keep the old tutorial's direct explanatory style: short setup, formula, example, interpretation.
- Use open-education language mainly in front matter, teaching notes, and reflection prompts, not as a layer of abstract rhetoric over every statistical section.
- Let occasional plain repetition remain when it helps teaching. Do not over-polish every sentence into the same cadence.
- Prefer active, local instructions: "Try changing power from 80% to 90%" rather than "Learners are empowered to explore parameter sensitivity".
- Keep clinical examples specific: painkillers, chronic pain, event rates, standard treatment, novel treatment.
- When adding new material, write it as a teacher giving instructions to students, not as promotional copy for the resource.
