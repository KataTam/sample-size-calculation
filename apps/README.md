# Shiny Apps

Each app has one teaching purpose and can be run independently from its own folder or called from the learner module.

## Apps

- `two_proportions`: sample size for a binary outcome comparing two event rates.
- `two_means`: sample size for a continuous outcome comparing two means.
- `power_explorer`: approximate achievable power for a fixed sample size.
- `dropout_adjustment`: recruitment target after expected dropout or loss to follow-up.

## Teaching Use

Ask students to change one assumption at a time and write down what changed in the required sample size or achievable power. The aim is to connect the calculation to the study design decision.

## Hosting

The apps can be used locally from RStudio or hosted separately. If hosted links are added, keep the local app folders in the repository so teachers can inspect, adapt, and run the code themselves.

See `../PUBLICATION_AND_HOSTING.md` for publication and hosting notes.

## Sample size reasoning lab

`power_explorer` now contains goal selection, one-study and repeated-study simulation, precision, sensitivity, saved outputs and reproducible downloads. It supports normal continuous and binary outcomes with equal groups. The standalone calculators remain introductory approximations; methods and answers can differ from the lab. See ../teaching/statistical_methods.md.
