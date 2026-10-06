# Seven-question map: source and presentation

The map follows the seven-question structure, radial layout and pastel circles of the author-supplied `mind_map.png`, retained locally in the 2 October 2026 tutorial-draft archive. Its seven questions match Katalin Tamási, How many patients do you need for your study? Sample size calculation tutorial, 14 May 2021.

The original excerpts were copied from the supplied `Sample_size_tutorial_Tamasi.Rmd` and remain in the `original_excerpt` fields of `data/question-map.json`, together with source lines and the source file's SHA256. The learner-facing `explanation` fields now consolidate each excerpt with its later planning clarification. `R/question_map.R` renders those integrated explanations in both the online and print editions; the source quotations are retained for provenance rather than shown as separate blockquotes.

| Question | Original source location | Selection |
|---|---|---|
| Main outcome | Line 59, minimum sample size questions | Complete paragraph |
| Standard treatment | Line 63, minimum sample size questions | Complete paragraph |
| Novel treatment | Line 67, minimum sample size questions | Complete paragraph |
| Clinically relevant difference | Line 71, minimum sample size questions | Complete paragraph, including original emphasis |
| Hypotheses | Line 75, minimum sample size questions | Complete paragraph |
| Type I error | Line 114, key parameters | First two sentences |
| Type II error and power | Line 116 and selected sentences from line 120, key parameters | Original beta definition and the complementary power / 90% example |

The archived excerpts retain the original wording. The integrated explanations avoid repetition and clarify the distinct roles of expected differences, target differences and clinical thresholds; the worked examples deliberately use different values for all three. The hypotheses explanation no longer implies that defining a clinical threshold changes the null hypothesis. Alpha, beta and power link to separate glossary definitions. The Type II explanation refers to failing to detect a difference at a specified true effect, because non-rejection does not establish equality. The excerpt selection omits the old blanket METc power requirement and assertions that non-rejection establishes no difference or population enumeration eliminates all false-positive risk.

The numbered map caption credits Sieben Medical Art, using the author's requested wording, “Based on illustration by Sieben Medical Art.” The supplied static map remains unchanged in the local archive; the interactive SVG and its print PNG are code-generated adaptations of its layout.

The original acknowledges inspiration from Clayton's lecture notes. Local evidence does not establish that these selected author-provided passages were copied from those notes; no lecture-note assets are included.

## Accessible and printable use

The SVG's information links open the corresponding question disclosures. Keyboard users can follow a map link or open a disclosure with its summary. The text list provides the same content independently of the diagram. The complete HTML includes the interaction script; the print edition includes the seven-question figure and every explanation in full. The SVG/PNG are generated together by `scripts/draw_question_map.py`.
