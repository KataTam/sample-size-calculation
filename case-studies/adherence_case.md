# Case: Preventing gestational diabetes

All values are hypothetical teaching assumptions.

Compare probiotic supplementation with no supplementation in pregnant women with overweight or obesity (BMI at least 25 kg/m²), with otherwise comparable care. The primary outcome is gestational diabetes diagnosed using a 75 g OGTT at a prespecified assessment time. Specify the supplement, diagnostic criteria and time point; an assessment at 20–24 weeks needs justification against applicable clinical guidance. The question is whether supplementation prevents disease, not whether its benefit is already established.

For calculation practice, assume disease occurs in 20% without probiotics, an expected 8% with probiotics and a target of 10% with probiotics. The expected reduction is 12 percentage points, the target reduction is 10 points and the clinical threshold is 5 points. These are invented teaching values, not evidence of effectiveness or established thresholds.

The [lab](https://katatam.github.io/sample-size-calculation/study/?activity=adherence) uses a positive difference for benefit. Enter remaining free of gestational diabetes as the favorable event: 80% without probiotics versus 90% with probiotics. The resulting 10-point increase equals the 10-point reduction in disease. Specify the event and direction in the report.

Use Type I error rate 5%, target power 90%, equal independent groups and 15% expected loss per arm. The recruitment cap is 240. The [lab](https://katatam.github.io/sample-size-calculation/study/?activity=adherence) uses score-test power approximation and assesses finite-sample performance by simulation, with Newcombe-Wilson intervals. The shared definition is `adherence` in `R/teaching_cases.R`.

[Open the tutorial and app](https://katatam.github.io/sample-size-calculation/study/?activity=adherence).

1. Express the target as a disease reduction and as an increase in the percentage remaining disease-free.
2. Predict whether the plan fits the recruitment cap after allowing for losses.
3. Hold planned n fixed and reduce the percentage remaining disease-free with probiotics from 90% to 85%, with 80% in the comparison group.
4. Compare rejection frequency with the interval's ability to distinguish small and clinically important benefits.
5. Discuss the evidence needed to justify event rates, clinical importance, diagnostic criteria and assessment time.

The case assumes individual randomization and independent outcomes. Observed supplementation rather than allocated treatment requires attention to confounding and different planning methods. Recruitment inflation cannot remove bias from missing diagnostic outcomes.
