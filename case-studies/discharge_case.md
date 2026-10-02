# Case: Discharge pathways

All values are hypothetical teaching assumptions.

Compare two individually allocated care pathways using discharge by a specified day as a binary outcome. Standard care has an anticipated probability of 0.80. A 20% relative increase gives 0.80 x 1.20 = 0.96, an absolute increase of 16 percentage points. A 10-percentage-point absolute increase instead gives 0.90.

The starting app scenario is 0.80 versus 0.96, alpha 0.05, target power 0.80, clinical threshold 0.10, equal groups and no assumed dropout. The shared definition is `discharge` in `R/teaching_cases.R`.

[Open the tutorial and app](https://katatam.github.io/sample-size-calculation/study/?activity=discharge).

1. Predict which comparison requires more participants: 0.80 versus 0.96, or 0.80 versus 0.90.
2. Compare the introductory formula with score-test planning and simulated performance.
3. Explain why probabilities close to one deserve attention to expected non-events and finite-sample approximation.
4. Compare a 90% power target with 80%, holding the probabilities fixed.

The complete discharge exercise is in the tutorial. An outcome of actual time until discharge requires time-to-event planning. Allocating wards rather than individual patients requires cluster planning.
