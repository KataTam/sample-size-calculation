# Contributing

This project welcomes contributions from teachers, students, and collaborators. Contributions can be small: a clearer explanation, a corrected typo, a better app label, a revised case template, or feedback from using the module in class.

## Ways To Contribute

- suggest improvements to the learner module
- report confusing sections or unclear app labels
- propose a student-generated clinical case
- improve teaching documentation
- improve accessibility
- improve or test Shiny apps
- report calculation errors or unclear assumptions

## Student-Generated Cases

Student cases are welcome, but they need review before reuse.

Before submitting a case:

- use `case-studies/student_case_template.md`
- check it with `case-studies/case_quality_checklist.md`
- remove identifiable patient, student, or local project information
- state whether the case is fictional, adapted, or based on a general clinical topic
- include assumptions clearly enough that someone else can repeat the calculation

If a student case may be reused publicly, explicit consent is required. See `case-studies/instructor_review_notes.md`.

## Teaching Changes

If you change a teaching activity, also check:

- `teaching/constructive_alignment_table.md`
- `teaching/assessment_rubric.md`
- `teaching/TEACHING_GUIDE.md`

The learning outcome, activity, app or figure, and assessment should still match.

## Code Changes

For changes to R functions or Shiny apps:

- keep formulas in `R/sample_size_functions.R` where possible
- let apps call shared functions rather than duplicating calculations
- keep app labels clear to students
- include text output as well as plots
- avoid adding new package dependencies unless they are clearly needed

Before sharing a code change, run:

```r
files <- list.files(pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
for (f in files) parse(f)
```

## Accessibility

When adding or changing content:

- add captions and alt text for informative figures
- avoid color-only interpretation
- keep table headings clear
- make app labels explicit
- provide a non-interactive route when possible

See `teaching/accessibility_checklist.md`.

## What Not To Add

Do not add:

- identifiable patient information
- identifiable student information without consent
- copyrighted PDFs or articles that cannot be redistributed
- private course data
- generated render folders such as `*_files/`
- local RStudio settings

## Attribution

Contributors should be acknowledged in a way that matches their preference and the nature of the contribution. Student cases should only be publicly attributed with consent.

