# Case: Discharge pathways

All values are hypothetical teaching assumptions.

Compare two individually allocated care pathways using discharge by a specified day as a binary outcome. Standard care has an anticipated discharge percentage of 80%. A 20% relative increase gives 96%, an absolute increase of 16 percentage points. A 10-percentage-point absolute increase instead gives 90%. The expected benefit is 18 percentage points, the main planning benefit is 16 percentage points and the clinical threshold is 8 percentage points. The secondary planning benefit of 10 percentage points also exceeds this threshold.

The starting app scenario plans using 80% versus 96%, Type I error rate 5%, target power 80%, equal groups and no assumed dropout. The expected 18-percentage-point benefit and 8-point clinical threshold are recorded separately from the planning calculation. The shared definition is `discharge` in `R/teaching_cases.R`.

[Open the tutorial and app](https://katatam.github.io/sample-size-calculation/study/?activity=discharge).

1. Predict which comparison requires more participants: 80% versus 96%, or 80% versus 90%.
2. Compare the introductory formula with score-test planning and simulated performance.
3. Explain why probabilities close to one deserve attention to expected non-events and finite-sample approximation.
4. Compare a 90% power target with 80%, holding the probabilities fixed.

The complete discharge exercise is in the tutorial. An outcome of actual time until discharge requires time-to-event planning. Allocating wards rather than individual patients requires cluster planning.
