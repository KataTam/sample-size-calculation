# Case: A prevalence survey

All values are hypothetical teaching assumptions.

A service wants to estimate the proportion of eligible patients with a symptom. Anticipated prevalence is 0.20. It wants a 95% confidence interval with an approximate margin of error of five percentage points: half-width 0.05, full width 0.10. This is one independent sample with one total n, not a treatment comparison.

The normal planning approximation gives 246 completed observations. With no useful prior estimate, using 0.50 for planning gives 385. The shared definition is `prevalence` in `R/teaching_cases.R`.

[Open the tutorial and app](https://katatam.github.io/sample-size-calculation/study/?activity=prevalence).

1. Explain why 0.50 is conservative for this absolute-precision formula.
2. Halve the margin of error and predict how n changes.
3. Compare the planning width with the Wilson interval from an illustrative realised sample.
4. Explain how representative sampling, nonresponse and outcome definition affect what the estimate means.

The 0.50 choice is not a universal default for two-group power, relative precision or rare events. The displayed planning criterion does not guarantee every realised interval meets it. Diagnostic accuracy, finite-population sampling, weighted surveys and clustering need appropriate additional methods.
