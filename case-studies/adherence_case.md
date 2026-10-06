# Case: Adherence support

All values are hypothetical teaching assumptions.

Compare usual care with individual adherence support, using adequate adherence at 12 weeks as a binary primary outcome. Expect a benefit of 20 percentage points, but plan using 50% adequate adherence under usual care and 65% with support: a 15-percentage-point benefit. A separately agreed clinical threshold is 10 percentage points. The expected difference, target difference and clinical threshold are distinct; only the planning percentages enter the sample size calculation.

Use Type I error rate 5%, target power 90%, equal independent groups and 15% expected loss per arm. The recruitment cap is 240. The lab uses score-test power approximation and assesses finite-sample performance by simulation, with Newcombe-Wilson intervals. The shared definition is `adherence` in `R/teaching_cases.R`.

[Open the tutorial and app](https://katatam.github.io/sample-size-calculation/study/?activity=adherence).

1. State the absolute effect and its relative change from the baseline of 50%.
2. Predict whether the plan fits the recruitment cap after allowing for losses.
3. Hold planned n fixed and reduce the generating support percentage to 60%.
4. Compare rejection frequency with the interval's ability to distinguish small and clinically important benefits.
5. Discuss data needed to define "adequate adherence" consistently and justify the assumed probabilities.

The case assumes individual allocation and independent outcomes. Practice-level allocation, repeated medication records and confounding in an observational comparison require additional methods. Recruitment inflation cannot remove bias from missing adherence outcomes.
