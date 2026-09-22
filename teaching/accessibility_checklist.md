# Accessibility Checklist

Use this checklist when editing, adapting, or sharing the module.

## Structure And Navigation

- [ ] Use descriptive headings in a logical order.
- [ ] Keep section titles short and specific.
- [ ] Avoid skipping heading levels when adding new sections.
- [ ] Make sure links have meaningful text, not only "click here".
- [ ] Keep the table of contents enabled for long HTML outputs.

## Text And Notation

- [ ] Use plain-language explanations before or after statistical notation.
- [ ] Define symbols such as alpha, beta, power, delta, and sigma where they first appear.
- [ ] Avoid very long paragraphs when adding new material.
- [ ] Keep instructions direct and specific.
- [ ] State whether sample size is per group, total, or a recruitment target.

## Figures And Plots

- [ ] Provide alt text for all informative figures.
- [ ] Use informative captions that explain the purpose of the figure.
- [ ] Do not rely on color alone to communicate meaning.
- [ ] Use line type, labels, or text annotations where reference lines are important.
- [ ] Keep axis labels clear and readable.
- [ ] Make static figures understandable without opening the Shiny apps.

## Tables

- [ ] Keep tables readable and avoid unnecessary merged cells.
- [ ] Use clear column headings.
- [ ] Refer to tables by number or name in the surrounding text.
- [ ] Avoid using tables for long prose.
- [ ] Check wide tables on a narrow screen.

## Shiny Apps

- [ ] Make app labels explicit and interpretable.
- [ ] Summarize interactive outputs in text, not only in a plot.
- [ ] Avoid color-only feedback in plots.
- [ ] Keep defaults aligned with the module examples.
- [ ] Give students a non-interactive option, such as R code or a worked example.

## Reuse And Sharing

- [ ] Check that examples can be completed without proprietary software.
- [ ] Remove identifiable patient or student information.
- [ ] Keep license and attribution information visible.
- [ ] If student cases are reused, check consent and attribution preferences.
- [ ] Re-knit or re-render the module after editing and visually check figures, tables, and app instructions.

## Current Module Notes

- Figures 1-4 include captions and alt text in the R Markdown source.
- The module includes text summaries before the interactive app calls.
- The Shiny apps include text output alongside plots.
- The app plots use high-contrast lines and point markers rather than color-only interpretation.

## New lab and static route

- [ ] All controls are keyboard reachable and have meaningful labels.
- [ ] Run status and stale-output messages are readable.
- [ ] Intervals distinguish features by line style and points, not colour alone.
- [ ] Tables, interpretations and CSV downloads accompany plots.
- [ ] The static module/activity is available if live interaction fails.
- [ ] Optional code remains optional for the assessed concepts.
