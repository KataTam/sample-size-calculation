# Source and reuse

This repository contains both teaching materials and code.

[Download the source package](../sample-size-oer-source.zip) or [browse the GitHub source](https://github.com/KataTam/sample-size-calculation). The guidance below explains attribution, licensing and adaptation.

## Choosing a download

| Your purpose | Resource |
|---|---|
| Read or teach from the complete tutorial | [Standalone HTML](../book/Sample_size_open_module.html) or [PDF](../book/Sample_size_open_module.pdf) |
| Adapt the tutorial, apps or supporting materials | [Source package](../sample-size-oer-source.zip), with the [adaptation guide](../teaching/adaptation_guide.md) |
| Save or submit work completed in an app | The app's HTML report; the [walkthroughs](../student-materials/activity-walkthroughs.html#reports-and-saved-work) explain readable reports, optional JSON backups and simulation downloads |

The source package contains the maintained teaching files, software and build instructions. A reasoning-lab JSON backup contains one learner's selected example, settings and answers for restoration in that lab. App reports and backups are created when you download them from an app.

## Adapting apps and reports

The [adaptation guide](../teaching/adaptation_guide.md#where-to-edit) identifies the files for cases, interfaces, model answers and reports. When changing an example, its narrative, calculation inputs, model answers and generated report should be checked together. Reports should use the current calculation objects and include saved simulation results only when their example and settings still match. Learners' written responses should remain intact and be clearly identified as their own entries.

The [build guide](development/build-and-publish.md#app-reports-and-backups) describes report checks and file compatibility. A revised version should retain readable HTML exports, clear restoration instructions and support for existing saved files where applicable. Rebuilding the site refreshes the published pages, apps and source package; the complete tutorial HTML/PDF should also be refreshed before release.

## Teaching Materials

The teaching materials are licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). This includes:

- learner-facing module text
- teaching guide
- constructive alignment table
- assessment rubric
- adaptation guide
- accessibility checklist
- case templates and case review materials

You may share and adapt these materials if you give appropriate credit, link to the license, and indicate whether changes were made. When sharing an adaptation, you must license your contributions under CC BY-SA 4.0 or a compatible license. You may not impose additional legal or technological restrictions on uses the license permits. Commercial use is allowed.

Suggested attribution:

> Adapted from "Sample Size Calculation OER" by Katalin Tamasi, licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

## Code

The original software code is licensed under the [MIT License](https://opensource.org/license/mit). This includes:

- functions in `R/`
- Shiny apps in `apps/`
- original JavaScript for the report activity and shared interfaces in `site/`
- code chunks used to generate examples and figures

The full project-specific notice is in [LICENSE-code.md](../LICENSE-code.md).

## Citation

Citation metadata is provided in `CITATION.cff`. Until a DOI is added, cite the GitHub repository:

> Tamasi, K. (2026). *Sample size calculation OER* [Teaching materials and software]. GitHub. https://github.com/KataTam/sample-size-calculation

If you cite a specific version, use the release tag once releases are created.

## Student-Generated Cases

Student-generated cases should not be reused publicly without review and consent.

Before public reuse:

- remove identifiable patient, student, or local project information
- check the calculation independently
- ask for explicit student consent
- ask whether the student wants named, anonymous, or group attribution
- keep consent records outside the public repository

Suggested wording:

> Includes an adapted student-generated case developed in [course name], [year], reused with permission.

## Changes

If you adapt the resource, briefly describe what you changed. This can be done in your README, course notes, or local teaching documentation.


## External sources

See [third-party notices](third-party-notices.md) before importing external figures or code, or releasing historical revisions. The separate [References](references.md) section records conceptual and statistical sources without relicensing their material.


## Building an adapted version

See the [build and publish guide](development/build-and-publish.md) for the build procedure and the local preview. Both HTML editions derive from `module/Sample_size_open_module.Rmd` and share `module/references.bib`.
