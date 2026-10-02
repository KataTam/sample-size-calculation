# Seven-question map: source and presentation

The map follows the seven-question structure, radial layout and pastel circles of the author-supplied `mind_map.png`, retained locally in the 2 October 2026 tutorial-draft archive. Its seven questions match **Katalin Tamási, How many patients do you need for your study? Sample size calculation tutorial, 14 May 2021**.

The explanations are copied directly from the supplied original `Sample_size_tutorial_Tamasi.Rmd`. They are stored once in `data/question-map.json`, with the original source file's SHA256, and rendered by `R/question_map.R` in both the online and print editions.

| Question | Original source location | Selection |
|---|---|---|
| Main outcome | Line 59, minimum sample size questions | Complete paragraph |
| Standard treatment | Line 63, minimum sample size questions | Complete paragraph |
| Novel treatment | Line 67, minimum sample size questions | Complete paragraph |
| Clinically relevant difference | Line 71, minimum sample size questions | Complete paragraph, including original emphasis |
| Hypotheses | Line 75, minimum sample size questions | Complete paragraph |
| Type I error | Line 114, key parameters | First two sentences |
| Type II error and power | Line 116 and selected sentences from line 120, key parameters | Original beta definition and the complementary power / 90% example |

Excerpts retain the original wording. Later planning clarifications appear separately and are not presented as quotations. The Type II map question now refers to failing to detect a difference at a specified true effect, because non-rejection does not establish equality. The excerpt selection omits the old blanket METc power requirement and assertions that non-rejection establishes no difference or population enumeration eliminates all false-positive risk.

The original acknowledges inspiration from Clayton's lecture notes. Local evidence does not establish that these selected author-provided passages were copied from those notes; no lecture-note assets are included.

## Accessible and printable use

The SVG's information links open the corresponding question disclosures. Keyboard users can follow a map link or open a disclosure with its summary. The text list provides the same content independently of the diagram. The complete HTML includes the interaction script; the print edition includes the seven-question figure and every explanation in full. The SVG/PNG are generated together by `scripts/draw_question_map.py`.
