# OER Metadata

Use this file when registering or sharing the resource through GitHub, SURFsharekit, MedischOnderwijs.nl, Zenodo, or another educational repository.

## Basic Information

| Field | Suggested entry |
|---|---|
| Title | Sample Size Calculation OER |
| Subtitle | How many patients do you need for your study? |
| Author | Katalin Tamasi |
| Institution | UMCG |
| Resource type | Open educational resource; interactive module; teaching package |
| Version | 0.3.0 (22 September 2026) |
| Language | English |
| License for teaching materials | CC BY 4.0 |
| License for code | MIT License |
| Repository | https://github.com/KataTam/sample-size-calculation |
| DOI | To be added after archival release |

## Short Description

An open educational resource for teaching sample size calculation in clinical research and medical statistics. The resource includes a learner-facing R Markdown module, Shiny apps, reusable R functions, clinical case templates, student co-creation materials, and educator documentation.

## Long Description

This modular teaching package helps students understand sample size calculation as part of research design. Students work with clinical scenarios, R code, static figures, and Shiny apps to explore how assumptions about event rates, clinically relevant differences, standard deviation, alpha, power, and dropout affect required sample size and achievable power. The resource includes teaching documentation for constructive alignment between learning outcomes, tool interaction, and assessment.

## Keywords

- sample size calculation
- medical statistics
- clinical trials
- research methods
- power
- R Markdown
- Shiny
- open educational resources
- open pedagogy
- student co-creation
- constructive alignment

## Target Audience

- medical students
- clinical trial students
- health sciences students
- students preparing research proposals
- teachers of medical statistics, epidemiology, or clinical research methods

## Educational Level

- undergraduate medical education
- graduate health sciences education
- introductory/intermediate clinical research methods

## Learning Outcomes

After completing the module, learners should be able to:

- explain why sample size calculation is part of study design
- identify the assumptions needed for a sample size calculation
- calculate sample size for two proportions and two means
- explain how alpha, power, effect size, standard deviation, and dropout affect required sample size
- adjust a required sample size for expected loss to follow-up
- interpret when a study is likely to be underpowered
- write a short sample-size justification for a clinical research scenario

## Technical Requirements

- R
- RStudio or another R environment
- R packages: `rmarkdown`, `bookdown`, `knitr`, `shiny`; `shinylive` for browser exports
- Pandoc, included with recent RStudio installations

The learner module can be rendered to HTML. The Shiny apps can be run locally or hosted separately.

## Accessibility Notes

- The learner module uses larger HTML text through `module/styles.css`.
- Static figures include captions and alt text.
- App outputs include text summaries as well as plots.
- App plots use labels and reference lines rather than relying only on color.
- A non-interactive route is possible through the R code chunks in the learner module.

## Reuse Notes

Teachers may adapt examples, app defaults, cases, and assessment tasks. The repository includes:

- teaching guide
- constructive alignment table
- assessment rubric
- adaptation guide
- accessibility checklist
- student case template
- case quality checklist
- peer review form
- instructor review notes

Student-generated cases should be reviewed and reused publicly only with consent.

## Suggested Citation

Tamasi, K. (2026). *Sample Size Calculation OER*. GitHub. https://github.com/KataTam/sample-size-calculation


## Revised learning scope

Keywords: sample size justification; precision; simulation; Monte Carlo uncertainty; clinical research; open education. Learning routes include testing, estimation and fixed resources. No coding is required for core activities. Supplementary components include paired concept/transfer assessment, offline activities and a separate references bibliography. Local learning effectiveness remains to be evaluated.

## Browser app access

- App menu: https://katatam.github.io/sample-size-calculation/
- Reasoning lab: https://katatam.github.io/sample-size-calculation/power_explorer/
- Hosting: GitHub Pages, built from the same public source repository using GitHub Actions.
