# Case: Chronic Pain Painkiller Study

This example compares a novel painkiller with standard treatment in patients with chronic pain.

## Outcome

Binary outcome: patient reports whether the painkiller was effective.

## Initial Assumptions

- Expected difference: 40 percentage points (70% versus 30%), informed by a hypothetical pilot with proportions 7/10 and 3/10
- Planning event percentages: standard treatment 30%, novel treatment 60%
- Target difference: 30 percentage points
- Clinical threshold: 20 percentage points
- Type I error probability: 5%
- Target power: 90%
- Expected loss to follow-up: 10% for recruitment planning; simulations use fixed analyzable counts

## Teaching Use

This case distinguishes the clinical threshold from the target difference used to calculate sample size. You can examine power at each hypothetical true difference without changing the clinical threshold.


## Revised teaching specification

Treat binary pain relief as assessed at four weeks. The expected difference of 40 percentage points, target difference of 30 percentage points and clinical threshold of 20 percentage points are distinct hypothetical judgments. Only the planning percentages of 30% and 60% enter the sample size calculation. Use the updated student case template and [lab](https://katatam.github.io/sample-size-calculation/study/?activity=pain_one_many); compare a generating treatment percentage of 40% at unchanged planned n. The small pilot provides uncertain estimates of the population treatment probabilities.
