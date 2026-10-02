# Case: Adherence support

All values are hypothetical teaching assumptions.

Compare usual care with individual adherence support, using adequate adherence at 12 weeks as a binary primary outcome. Anticipated probabilities are 0.50 under usual care and 0.65 with support. The planning effect is a 15-percentage-point absolute benefit. A separately agreed clinical threshold is 10 percentage points.

Use alpha 0.05, target power 0.90, equal independent groups and 15% expected loss per arm. The recruitment cap is 240. The lab uses score-test power approximation and assesses finite-sample performance by simulation, with Newcombe-Wilson intervals. The shared definition is `adherence` in `R/teaching_cases.R`.

[Open the tutorial and app](https://katatam.github.io/sample-size-calculation/study/?activity=adherence).

1. State the absolute effect and its relative change from the baseline of 0.50.
2. Predict whether the plan fits the recruitment cap after allowing for losses.
3. Hold planned n fixed and reduce the generating support probability to 0.60.
4. Compare rejection frequency with the interval's ability to distinguish small and clinically important benefits.
5. Discuss data needed to define "adequate adherence" consistently and justify the assumed probabilities.

The case assumes individual allocation and independent outcomes. Practice-level allocation, repeated medication records and confounding in an observational comparison require additional methods. Recruitment inflation cannot remove bias from missing adherence outcomes.
