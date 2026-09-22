# Pilot And Release Checklist

Use this checklist before sharing the resource with students, colleagues, or an open repository.

## Before A Small Pilot

- [ ] Render `module/Sample_size_open_module.Rmd` in RStudio or with `rmarkdown::render()`.
- [ ] Run `source("scripts/check_resource.R")`.
- [ ] Check that Tables 1-3 render correctly.
- [ ] Check that Figures 1-4 render and are readable.
- [ ] Run each Shiny app from RStudio or with `shiny::runApp()`.
- [ ] Confirm that app defaults match the examples used in the module.
- [ ] Check that the larger font size is comfortable in the rendered HTML.
- [ ] Ask one colleague or student assistant to complete the module and note confusing points.
- [ ] Prepare `teaching/pilot_student_feedback.md` or `teaching/pilot_observation_notes.md`.
- [ ] Decide which teaching format will be used: 30, 60, or 90 minutes.
- [ ] Select the assessment route: short answer, assumptions table, or sample-size justification.

## Before A Course Use

- [ ] Confirm whether students need local R/RStudio access or a hosted app link.
- [ ] If using Shinylive, export and test the apps with `source("scripts/export_shinylive.R")`.
- [ ] Prepare a non-interactive route for students who cannot run Shiny.
- [ ] Decide whether students will use the chronic pain case or create their own case.
- [ ] Provide the student case template and peer review form if using co-creation.
- [ ] Explain how student cases may or may not be reused.
- [ ] Review pilot feedback and decide which revisions are needed before wider use.
- [ ] Check accessibility needs for the specific student group.
- [ ] Update any local course, ethics committee, or protocol-writing requirements.

## Before Public Sharing

- [ ] Remove any copyrighted PDFs, articles, screenshots, or third-party assets that cannot be redistributed.
- [ ] Check that no student, patient, or local project information is identifiable.
- [ ] Confirm that teaching materials are covered by CC BY 4.0.
- [ ] Confirm that R/Shiny code is covered by the MIT License.
- [ ] Check `CITATION.cff`.
- [ ] Check `REUSE_AND_CITATION.md`.
- [ ] Check `PUBLICATION_AND_HOSTING.md`.
- [ ] Check `QUALITY_CHECKS.md`.
- [ ] Update `NEWS.md`.
- [ ] Create a version tag or GitHub release.
- [ ] Consider archiving the release with Zenodo or another DOI-providing service.
- [ ] Add hosted Shiny app links if available.
- [ ] Add Shinylive app links if using GitHub Pages or another static host.
- [ ] Add links or metadata needed for SURFsharekit, MedischOnderwijs.nl, or another OER platform.

## Suggested Release Labels

- `v0.1.0`: internal prototype
- `v0.2.0`: pilot-ready version
- `v1.0.0`: public reviewed version

## Known Items To Check Manually

- RStudio-rendered HTML appearance
- app behavior in the intended browser
- figure readability on projector and laptop screens
- whether students understand "per group", "total", and "recruitment target"
- whether the assessment rubric fits the local course task

## Revised reasoning module

- [ ] Review full-width targets, assumptions and explicit methods.
- [ ] Run the statistical and Shiny server checks and render the static module.
- [ ] Test new buttons and downloads in the intended browser host.
- [ ] Pilot one outcome and review paired learning/transfer evidence.
- [ ] Resolve any rights issues in historical lecture-note-derived versions before publishing history; see THIRD_PARTY_NOTICES.md.
- [ ] Include REFERENCES.md, methods, case map and offline activity in the distributed teaching package.
