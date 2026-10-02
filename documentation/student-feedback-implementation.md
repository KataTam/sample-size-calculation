# Student-feedback implementation

This revision implements the ideas in `ideas_student_feedback.md`, with the author's corrections to items 4 and 5. The maintained learner source is `module/Sample_size_open_module.Rmd`. Original wording and the planning flow from *How many patients do you need for your study? Sample size calculation tutorial*, Katalin Tamási, 14 May 2021, are retained where compatible with the added structure and statistical corrections.

| Item | Implementation |
|---|---|
| 1. Broader study settings and designs | Study-design guide distinguishes the study setting from the analysis design and routes paired, diagnostic, prediction, observational and preclinical work to appropriate methods. |
| 2. Practical pilot planning | Dedicated feasibility discussion and fixed-size retention example; evidence review, progression criteria and funding guidance. |
| 3. Navigation and complete downloads | Chaptered book, complete HTML and printable PDF from one learner source. |
| 4. Mathematics and code | Existing code and formulas remain visible; explanatory interpretation is added. No removal or relocation into optional blocks. |
| 5. Section structure | Original tutorial prose and planning questions are retained; navigation and contextual activities are added without imposing an identical sequence on every section. |
| 6. Prerequisites | Glossary and short refreshers, available separately and within the complete tutorial. |
| 7. Misconceptions | FAQ covers absolute/relative effects, alpha/beta, retrospective planning, design mismatch, statistical/clinical meaning, variability and sample/population. |
| 8. Estimation | Worked prevalence example, existing two-group precision examples and a dedicated single-proportion app. |
| 9. Unknown proportion | Conservative p = 0.5 option is restricted to absolute precision planning for one proportion, with its limits explained. |
| 10. Alpha and beta | Sampling-distribution app and static figure distinguish patient variability, standard error, rejection regions, beta and power. |
| 11. Matched activities | One named case registry supplies tutorial/app settings, including seed, replications and input units. |
| 12. R and reproducibility | Shared R calculations, visible worked code, saved plans, simulated-data downloads and explicit methods. |
| 13. Other software | Student walkthroughs are omitted; an optional teacher validation guide describes comparisons and records unperformed proprietary-software checks accurately. |
| 14. Post-hoc power | FAQ and curves discussion explain why observed power adds no evidence and distinguish prospective fixed-N sensitivity. |
| 15. Parameters | Contextual help explains assumptions, units, per-arm counts, confidence width, power, dropout and recruitment. |
| 16. Plots | Existing power, precision, simulation and dropout plots retained; new sampling-distribution and single-proportion plots added. |
| 17. Own study | My study fields cover question, outcome, evidence, clinical value, burden, eligible patients, consent, time and costs; downloadable justification. |
| 18. Lesson/app integration | Persistent two-panel study view, activity presets, separate-page links and narrow-screen switching. |
| 19. Core medical examples | Rehabilitation, discharge and adherence cases complement the original pain example. |
| 20. Introductory mindmap | Four original question families recreated in an accessible diagram, with text interpretation and links. |

## Maintenance

Edit matched activity defaults in `R/teaching_cases.R` and check the corresponding tutorial text. Edit glossary, FAQ and design routing in `student-materials/`; the book includes those sources rather than maintaining duplicate copies. The study view resolves anchors to generated chapter filenames during the site build.

Run the checks and build documented in [Build and publish](development/build-and-publish.md). The R checks cover calculations, server behavior, preset routing and study-plan validation. Browser checks are also needed for nested Shinylive frames, persistence during lesson navigation, links, downloads and narrow screens. A local build does not publish the revision.
