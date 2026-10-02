# Statistical methods

## Scope

Two independent, equally sized groups; no clustering, covariate adjustment, sequential stopping, non-inferiority or equivalence tests. Effects are signed treatment minus control. The app examples orient benefit as positive; adaptation to a harm outcome requires deliberate sign/threshold handling. All stochastic examples use synthetic data.

## Planning calculations

The simple means/proportions apps retain transparent normal sample-size approximations, rounding per group before doubling. These are labelled approximate and are not guaranteed to achieve the desired finite-sample power. The reasoning lab searches integer n using `power.t.test(..., strict=TRUE)` or `power.prop.test(..., strict=TRUE)`. Both count both tails. Binary power remains a normal approximation. Null effects are valid for power/Type I error exploration; sample size for detecting a zero effect is undefined. An explicit guard prevents requesting such a testing design.

The known-variance normal benchmark is Phi(signal − critical) + Phi(−signal − critical), so zero signal gives alpha. Normal simulation instead estimates variance and uses the t distribution. This distinction is tested rather than hidden.

## Data generation and analysis

One normal study draws n control observations from N(0, sigma²) and n treatment observations from N(delta, sigma²). The zero control mean is a harmless location convention for a difference analysis. The pooled sample variance and 2n−2 degrees of freedom define a two-sided t test and interval, checked against `t.test(var.equal=TRUE)`.

Repeated normal studies generate their independent sufficient statistics: differences from N(delta, 2sigma²/n) and pooled variances from sigma² times chi-square(2n−2)/(2n−2). Under these assumptions this is distributionally equivalent to analysing full patient datasets, but much more memory efficient. The single-study dataset is not the first replication of that batch.

Binary datasets use independent Bernoulli draws, or binomial counts for repeated studies. The statistic is (pT−pC)/sqrt(2*pPool*(1−pPool)/n). Its two-sided normal p-value matches `prop.test(correct=FALSE)` for two groups with nonzero pooled variance. When both groups have all failures or both all successes, use statistic zero and p=1; this makes the otherwise undefined degenerate case explicit. Finite-sample Type I error can depart from alpha, especially for sparse outcomes.

Binary intervals use Newcombe's combination of uncorrected Wilson intervals. If Wilson limits are LT, UT, LC, UC and d=pT−pC, the limits are d−sqrt((pT−LT)²+(UC−pC)²) and d+sqrt((UT−pT)²+(pC−LC)²). This is not inversion of the pooled score test; interval exclusion and test decisions can occasionally differ. The tests check finite limits at all-success/all-failure extremes and validate coverage in selected settings; they do not establish universal coverage guarantees.

## Precision

All targets mean FULL confidence interval width at confidence 1−alpha. For normal data, expected width is 2*tCritical*sigma*sqrt(2/n)*c4(df), where c4(df)=sqrt(2/df)*Gamma((df+1)/2)/Gamma(df/2). For binary data the anticipated curve plugs assumed probabilities into the Newcombe formula. It is not exact expected width. Estimation planning searches this expected or plug-in criterion. Neither is a probability-of-width guarantee; simulations report mean width and the fraction attaining the target separately.

## Reproducibility and uncertainty

The seed is set once before a batch, and the caller's random state is restored afterward. Replications use fresh draws. Results retain the complete generating specification. App downloads also retain planning assumptions, goal, dropout and method, and saved outputs are flagged when controls change. Results from a saved run are never relabelled with new inputs.

Rejection, coverage and width-attainment summaries report MCSE sqrt(p*(1−p)/B) and 95% Wilson intervals based on B independent studies. An MCSE of zero at a boundary does not establish certainty; the Wilson interval remains nonzero. Clinical assumption uncertainty is a separate sensitivity question. Changing generating parameters leaves planned n fixed; increasing B never increases per-study power.

## Recruitment

Recruit ceil(n/(1−dropout)) in each arm, then double. Inflation changes expected counts, not missing-data bias. Simulations condition on analysable n and do not model attrition or non-adherence. The standalone dropout app also uses per-group counts so equal allocation is retained.

## References

See [References](references.md), especially Newcombe (1998) and the R documentation. `scripts/check_resource.R` checks independent reference results, null rejection, interval coverage, reproducibility, edge cases, calculation rounding and app server behaviour. Browser checks are documented separately in the implementation validation record.

## Single-proportion precision and pilot process outcomes

The added prevalence_precision activity uses one independent binary sample. Its n is a total count, unlike the per-group n in the comparison lab. The approximate planning formula is n = ceiling(z² p(1−p)/d²), where z is the normal quantile for the chosen two-sided confidence level and d is the HALF interval width. The shared helper accepts FULL width and divides it by two. At 95% confidence, an anticipated proportion of 0.20 and full width 0.10 gives 246 analysable observations. With unknown p, the conservative planning value 0.50 gives 385. The maximum at 0.50 concerns fixed absolute width under this approximation; it is not a general conservative choice for treatment comparisons, relative precision, diagnostic recruitment or prediction models.

This approximation is not a promise about realised Wilson interval width. The activity's single-study draw is binomial with the anticipated proportion used as a hypothetical generating truth, and the interval uses uncorrected Wilson limits. Unknown p changes the planning value, while the generating slider remains an illustrative assumption. Wilson limits remain within [0,1], including observed zero or all events. Sparse-count flags use fewer than ten anticipated events or non-events as an instructional prompt, not as a validity theorem or universal minimum. Planning p exactly 0 or 1 is rejected because its normal-approximation variance degenerates; the unknown-p option still works at those inputs in the helper. The interactive slider stays away from the boundaries, and simulation/interval helpers support boundary realisations.

The fixed-resource pilot preset estimates one retention proportion with n = 40 and anticipated retention 0.80; it does not test treatment effectiveness. Its stated full-width target is a hypothetical learner goal. Recruitment is ceiling(n/(1−loss)); simulation conditions on analysable n and does not simulate or correct missing-data mechanisms. Complex sampling, population corrections and imperfect diagnostic measurements require an appropriate extension beyond this introductory method.

## Sampling distributions of one normal mean

The sampling_distributions activity is a separate known-SD reference model: independent observations from a normal population, one sample, SE = sigma/sqrt(n). For a greater-than test, c = mu0 + qnorm(1−alpha)×SE, alpha = P(mean > c | mu0), and power = P(mean > c | mu1). A less-than test uses the lower tail; a two-sided test divides alpha between both rejection tails. Beta is one minus power at the specified alternative. The null and alternative curves are distributions of the SAMPLE MEAN, not distributions of patient observations or probabilities assigned to the hypotheses.

The shared helper returns boundaries, SE, alpha under the null, beta and power. The blood-pressure preset uses mu0 = 120, mu1 = 125, sigma = 15, n = 25 and one-sided alpha = 0.05: SE = 3, c ≈ 124.935 and power ≈ 0.509. These are exact normal probabilities given the stated known-SD assumptions. They are distinct from the main lab's estimated-variance two-sample t analysis. A one-sided alternative in the opposite direction may yield power below alpha. The direction must be chosen before inspecting outcomes.

## Shared cases and added validation

R/teaching_cases.R supplies the tutorial and apps with one named registry of hypothetical case assumptions. Each record states its app and study structure so one-proportion and one-sample-mean activities are not applied as independent-group comparisons. Activity state is validated by a whitelist of supported inputs before being applied; changed controls do not relabel a saved illustrative sample.

scripts/check_feedback.R checks upward sample-size rounding by independently inverting the normal half-width formula, verifies Wilson intervals against uncorrected prop.test, enumerates binomial outcomes to check selected coverage and variable width attainment, checks caller RNG preservation, and integrates normal densities over rejection regions to verify power. Server checks cover fixed-resource and precision modes, shared-case routing, malformed input rejection, stale saved intervals and both test directions. These checks establish the selected examples and implementation; they do not establish universal finite-sample performance.
