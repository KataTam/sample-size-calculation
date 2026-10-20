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
- [ ] Define symbols such as Type I error probability, Type II error probability, power, delta, and sigma where they first appear.
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

- Figures include captions and alt text in the R Markdown source.
- The module includes text summaries before the interactive app calls.
- The Shiny apps include text output alongside plots.
- The app plots use high-contrast lines and point markers rather than color-only interpretation.

## New [lab](https://katatam.github.io/sample-size-calculation/study/?activity=own_study) and static route

- [ ] All controls are keyboard reachable and have meaningful labels.
- [ ] Run status and stale-output messages are readable.
- [ ] Intervals distinguish features by line style and points, not color alone.
- [ ] Tables, interpretations and CSV downloads accompany plots.
- [ ] The static module/activity is available if live interaction fails.
- [ ] Optional code remains optional for the assessed concepts.

## Tutorial and app together

- [ ] The activity selector, view buttons and panel separator have labels and visible keyboard focus.
- [ ] The separator adjusts widths by dragging and by Left/Right arrow keys; Home and End reach the bounds.
- [ ] Each iframe has a meaningful title and a separate-page alternative.
- [ ] Activity readiness appears as text in a live status region.
- [ ] Lesson navigation preserves app inputs and completed simulations.
- [ ] Narrow screens stack both panels without horizontal overflow; labeled view buttons also show either panel alone.
- [ ] Check keyboard movement into and out of both frames in the teaching browser.
- [ ] Check the complete HTML and PDF as alternatives; app interaction still requires a browser connection on first load.

## Accessibility review: 20 October 2026

Target: WCAG 2.2 AA. This is a scoped accessibility review, not a conformance certification.

### Scope and changes

- Automated axe-core checks cover Introduction, Power, and Calculations, including expanded quizzes and code, in day, sepia, and night themes, plus the two-panel study shell.
- A separate audit exercised the loaded power-explorer app, its animation, controls, and results.
- Shared fixes improve text/link/syntax/slider contrast, underline prose links, remove empty generated code links, identify the app language, label table headers, and provide a keyboard skip link.
- Core/Advanced text accompanies chapter colors. New-tab links receive accessible descriptions. Existing native disclosure controls and keyboard-enabled panel resizing remain available.
- Wide tables have keyboard-focusable scrolling regions, so they do not widen the whole reading page at 320 CSS pixels.
- The animation supplies a text description of the current trial's counts and estimated difference. Existing reduced-motion, pause, replay, and reset behaviors are retained.
- PDF assembly preserves the browser-generated structure tree and sets the document language to US English. The publishing check detects loss of these tags.
- Automated accessibility checks now run during publication. Run `node scripts/check_accessibility.cjs` against a built local site; install `axe-core` and `playwright` or set `AXE_PATH` to an axe-core script.

### Remaining manual evaluation

- A screen-reader user should review the tutorial, dynamic app results, mathematical notation, and full keyboard journey with NVDA or another supported reader. Browser DOM/keyboard checks do not substitute for this.
- The generated PDF title/contents pages are not fully tagged; PDF mathematical reading order, table associations, and figure alternatives need a dedicated PDF accessibility review. Preserving tags does not establish PDF/UA conformance. The HTML remains the more accessible primary format.
- Check further app states, all remaining apps and downloads, browser/assistive-technology combinations, and users' own text-spacing settings before making any site-wide WCAG conformance claim.
- Review new graphs for meaningful descriptions and non-color cues. Existing tutorial figures already supply explanatory alt text; interactive plots also provide text summaries or tables.

Reference: [WCAG 2.2](https://www.w3.org/TR/WCAG22/) and [WAI evaluation guidance](https://www.w3.org/WAI/test-evaluate/).

### Verified outcomes

The representative chapter/theme combinations and study shell had no automated WCAG A/AA violations in the final axe-core 4.10.3 run. The loaded simulation app's final audit also reported none. Keyboard skip/focus, 320-pixel reflow, panel resizing, glossary popups, and reduced-motion/pause/replay/reset checks passed. The PDF structure/language, contents links, expanded disclosures, and code-clipping checks passed. These results apply to the tested states and do not remove the manual evaluation items above.
