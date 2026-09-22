# Adaptation Guide

This resource is designed for adaptation.

The main principle is simple: if you change the teaching context, update the examples, activities, and assessment together. The module is most useful when the learner-facing text, Shiny app interaction, and assessment task point to the same learning outcome.

## Common Adaptations

- Replace the clinical cases with examples from your own course.
- Use only one app in a shorter teaching session.
- Translate the learner-facing module.
- Adjust the learning outcomes to fit undergraduate, graduate, or continuing-professional education.
- Add local requirements for ethics committee or protocol submissions.

## Where To Edit

| If you want to change... | Edit this file or folder |
|---|---|
| Learner-facing explanation | `module/Sample_size_open_module.Rmd` |
| Font size or rendered HTML styling | `module/styles.css` |
| Sample size formulae or interpretation text | `R/sample_size_functions.R` |
| App labels, defaults, or plots | `apps/<app_name>/app.R` |
| Clinical examples | `cases/` and relevant sections of the module |
| Student case co-creation materials | `cases/student_case_template.md`, `cases/case_quality_checklist.md`, `cases/peer_review_form.md`, `cases/instructor_review_notes.md` |
| Teaching plan | `teaching/TEACHING_GUIDE.md` |
| Learning outcome/activity/assessment links | `teaching/constructive_alignment_table.md` |
| Rubric | `teaching/assessment_rubric.md` |
| Accessibility checks | `teaching/accessibility_checklist.md` |

## Adapting Clinical Cases

To replace the chronic pain example:

1. Choose a clinical context students will recognize.
2. Decide whether the primary outcome is binary or continuous.
3. State the standard-treatment result.
4. State the expected novel-treatment result or clinically relevant difference.
5. Decide alpha and power.
6. Add expected dropout if relevant.
7. Check that the required sample size is plausible enough for discussion.

For a binary outcome, use `apps/two_proportions`. For a continuous outcome, use `apps/two_means`.

Keep the case specific. A case such as "a new treatment improves recovery" is too vague. A case such as "a new discharge planning intervention is expected to increase discharge within 48 hours from 70% to 82%" is easier to calculate and discuss.

## Changing App Defaults

The app defaults should match the example students see in the module or in class.

For example, in `apps/two_proportions/app.R`, these values control the starting assumptions:

```r
value = 0.60
value = 0.30
value = 0.05
value = 0.90
```

If you change the default values, update the text and figures in the module where needed. Students should not see one set of assumptions in the module and a different unexplained set in the app.

## Using Only Part Of The Resource

For a short teaching session, it is fine to use only one section.

Possible combinations:

| Teaching need | Minimal set |
|---|---|
| Binary outcome sample size | Two-proportions section, Figure 1, `apps/two_proportions`, short rubric |
| Continuous outcome sample size | Two-means section, Figure 2, `apps/two_means`, short rubric |
| Feasibility and power | Power calculation section, Figure 3, `apps/power_explorer` |
| Dropout adjustment | Adjustments section, Figure 4, `apps/dropout_adjustment` |
| Protocol-writing practice | Build-your-own justification section, case template, assessment rubric |

If you remove a section, also remove or revise related assessment tasks.

## Adapting For Course Level

### Introductory Level

- Keep the focus on interpretation.
- Use one outcome type.
- Give students most assumptions in advance.
- Assess whether they can explain what the required sample size means.

### Intermediate Level

- Ask students to choose between binary and continuous outcome examples.
- Include dropout adjustment.
- Ask students to compare two plausible assumptions.
- Assess their written sample-size justification.

### Advanced Level

- Ask students to justify assumptions from literature or pilot data.
- Discuss alternative designs, unequal allocation, non-inferiority, clustering, or repeated measures as extensions.
- Ask students to identify when the simple formulae in this module are no longer sufficient.

## Translation

If translating the module:

- translate the learner-facing text first
- keep statistical notation consistent
- check whether terms such as alpha, beta, power, and clinically relevant difference have accepted local translations
- re-knit the module and check all figures and tables
- update license and attribution notes in the translated version

## Local Requirements

Teachers may need to add local requirements, for example:

- ethics committee expectations
- institutional protocol templates
- local minimum power requirements
- preferred software
- reporting standards for student research projects

Add these as a short local note rather than rewriting the whole module.

## Sharing An Adapted Version

Before sharing an adapted version publicly:

- remove any copyrighted figures or papers that cannot be redistributed
- check that student cases contain no identifiable patient information
- keep the CC BY 4.0 teaching-material license visible
- keep the MIT code license visible
- cite the original repository
- note what you changed
- update the date and version if appropriate

## What To Keep Aligned

When adapting the resource, check that:

- learning outcomes still match the app interactions
- assessment prompts ask students to show the intended learning
- examples use realistic assumptions
- accessibility notes are updated for new figures, videos, or apps
- license and attribution statements remain visible

## Adaptation Checklist

Use this checklist before teaching or sharing a revised version:

- [ ] The module examples match the app defaults.
- [ ] Tables and figures are still referred to correctly in the text.
- [ ] The assessment task matches the learning outcomes.
- [ ] The rubric fits the task students are asked to complete.
- [ ] New figures have captions.
- [ ] New app controls have clear labels.
- [ ] No identifiable patient/student information is included.
- [ ] License and attribution information is visible.
- [ ] The module has been rendered and checked.

## Adapting the reasoning pathway

Update the goal, effect scale, beneficial direction, clinical threshold, planning effect and generating assumptions together. The app cases use positive improvement; reversing direction for harmful outcomes requires corresponding labels and interval interpretation. Keep allocation equal unless the analysis and validation are extended. Match changes to the rubric and paired assessment. Preserve the original static activity or regenerate it with recorded seeds. Resampling and advanced designs remain optional extensions. See statistical_methods.md and ../THIRD_PARTY_NOTICES.md.
