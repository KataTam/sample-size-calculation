# Key parameters and prerequisites {#glossary}

Use this section when a term in the tutorial or app needs a reminder. The formulas and R code remain visible in the main tutorial; you can interpret the tables and graphs without running them yourself.

## Population, sample and planning values

A **population parameter** is a feature of the population you want to learn about, such as its mean, proportion, or treatment difference. A **sample estimate** is calculated from the observations you obtained. In the pain example, 7/10 is a sample proportion; 0.60 is an anticipated population probability used for planning. The latter is an assumption supported with evidence and sensitivity analysis, not a known truth.

The **expected effect**, **planning effect** and **clinical threshold** answer different questions. The expected effect is your best current expectation. The planning effect is the particular population effect at which you calculate power. The clinical threshold is the smallest benefit that matters to patients, based on a stated judgement. They may coincide, but should not be treated as interchangeable.

## Effect scale and direction

An **absolute proportion difference** subtracts two probabilities: 0.60 - 0.30 = 0.30, or 30 percentage points. A **relative increase** divides by the baseline: (0.60 - 0.30)/0.30 = 1, or 100%. An increase from 0.80 to 0.96 is 16 percentage points and a 20% relative increase. State which scale you mean.

A **mean difference** is in the outcome's own units, such as mmHg or score units. The lab uses treatment minus control. Positive is beneficial in the prepared improvement/relief cases; an outcome such as pain severity or mortality needs an explicit decision about beneficial direction.

A **standardized difference**, often called Cohen's d for a mean comparison, expresses the difference in SD units. A difference of 3 with SD 5 gives 3/5 = 0.60. This can help translate between software inputs; a conventional label such as "medium" does not establish clinical relevance.

## Variation and uncertainty

**Standard deviation (SD)** describes variability between individuals. The common SD assumption in the simple two-means example means the populations in the two groups have the same SD.

**Standard error (SE)** describes variability of an estimate across repetitions. For one mean with known population SD, SE = SD/sqrt(n). More independent observations reduce SE; they do not make the population's individual values less variable. The sampling-distribution illustration uses SE, not SD, as the width of the sample-mean curves.

A **confidence interval** describes uncertainty about an estimate using a procedure with stated long-run coverage. Under its assumptions, a 95% procedure contains the fixed population value in about 95% of repetitions. An observed interval does not give the fixed truth a 95% probability of lying inside it. Interpret the range of compatible effects against zero and a clinically important threshold.

**Full width** is the upper confidence limit minus the lower. For a symmetric interval its **half-width**, or margin of error, is half the full width. A margin of five percentage points means a full width of ten percentage points. For asymmetric intervals, the two distances from the estimate to the limits need not be equal.

## Hypotheses, alpha, beta and power

The **null hypothesis** in the ordinary superiority examples is a zero population difference. A two-sided **alternative hypothesis** allows a difference in either direction. The alternative does not become "at least the clinical threshold" because that threshold was used for planning.

**Alpha** is the planned probability of rejecting a true null under the test's assumptions. It is not the probability that the null is true after observing the data. Approximate procedures can have finite-sample error rates that depart from their nominal alpha.

**Beta** is the probability of non-rejection at a specified alternative, with the design and analysis held fixed. **Power** is 1 - beta: the probability of rejection at that specified effect. A study with 90% power can still produce a non-significant result. Non-rejection does not establish equivalence.

A **p-value** describes how incompatible the data are with the null under the stated model/test. It is not a measure of effect size, clinical benefit, or the probability that a hypothesis is true.

## Tests and designs

A **two-sided test** can reject for sufficiently strong differences in either direction. A **one-sided test** has a directional rejection rule. Decide sidedness before seeing the results; the known-SD diagram is an illustrative one-sided example, while the core lab uses two-sided comparisons.

A **z calculation** uses the standard normal distribution, often as an approximation. A **t test** accounts for estimating normal-outcome variance. The simple calculators use labelled normal sample-size approximations; the lab's mean planning uses pooled two-sample t-test power. See the [statistical methods](../documentation/statistical-methods.md) for exact implementation details.

**Independent groups** contain different independent experimental units in the two groups. **Paired/within-subject data** include linked measurements, such as both eyes or before/after observations from the same person. **Clustered data** include participants linked within allocated practices or wards. Correlation affects information and therefore planning; counting every measurement as independent can overstate the sample size.

## Counts, losses and simulation

**Analysable n** is the number contributing to the stated analysis. In the two-group lab it is per group; the total is 2n. **Recruitment n** is inflated for anticipated losses, rounding within each arm. Expected dropout of 10% requires division by 0.90, not multiplication by 1.10. Inflation does not correct missing-data bias.

The **planning scenario** selects the design. A **generating scenario** specifies what could actually happen in repeated hypothetical studies. Changing generating assumptions while holding the planned n fixed is a sensitivity analysis; recalculating n each time answers a different question.

**B** is the number of independent simulated studies, not the number of patients per study. **Monte Carlo uncertainty** describes numerical uncertainty from a finite B. Increasing B estimates the design's performance more precisely; it does not increase each study's power or resolve uncertainty about clinical assumptions. A **seed** makes a specified simulation reproducible.

For more detail, return to the [power chapter](#power), [sampling-distribution illustration](#alpha-beta), [precision examples](#feasibility), or [common mistakes](#common-mistakes). Methodological sources include Kirkwood and Sterne (2003), Whitley and Ball (2002), and the R documentation cited in the tutorial.
