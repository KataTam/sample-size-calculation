# Statistical methods

## Scope

Two independent, equally sized groups; no clustering, covariate adjustment, sequential stopping, non-inferiority or equivalence tests. Effects are signed treatment minus control. The app examples orient benefit as positive; adaptation to a harm outcome requires deliberate sign/threshold handling. All stochastic examples use synthetic data.

## Planning calculations

The two-proportion calculator and tutorial use `power.prop.test(..., strict=TRUE)`, rounding its per-group result upward before doubling; the chronic-pain example requires 56 per group. The two-mean calculator retains its normal sample-size approximation. Planning approximations are not guaranteed to achieve the desired finite-sample power. The reasoning lab searches integer n using `power.t.test(..., strict=TRUE)` or `power.prop.test(..., strict=TRUE)`. Both count both tails. Binary power remains a normal approximation. Null effects are valid for power/Type I error exploration; sample size for detecting a zero effect is undefined. An explicit guard prevents requesting such a testing design.

The known-variance normal benchmark is Phi(signal − critical) + Phi(−signal − critical), so zero signal gives alpha. Normal simulation instead estimates variance and uses the t distribution. This distinction is tested rather than hidden.

## Data generation and analysis

One normal study draws n control observations from N(0, sigma²) and n treatment observations from N(delta, sigma²). The zero control mean is a harmless location convention for a difference analysis. The pooled sample variance and 2n−2 degrees of freedom define a two-sided t test and interval, checked against `t.test(var.equal=TRUE)`.

Repeated normal studies generate their independent sufficient statistics: differences from N(delta, 2sigma²/n) and pooled variances from sigma² times chi-square(2n−2)/(2n−2). Under these assumptions this is distributionally equivalent to analyzing full patient datasets, but much more memory efficient. The single-study dataset is not the first replication of that batch.

Binary datasets use independent Bernoulli draws, or binomial counts for repeated studies. The statistic is (pT−pC)/sqrt(2*pPool*(1−pPool)/n). Its two-sided normal p-value matches `prop.test(correct=FALSE)` for two groups with nonzero pooled variance. When both groups have all failures or both all successes, use statistic zero and p=1; this makes the otherwise undefined degenerate case explicit. Finite-sample Type I error can depart from alpha, especially for sparse outcomes.

Binary intervals use Newcombe's combination of uncorrected Wilson intervals. If Wilson limits are LT, UT, LC, UC and d=pT−pC, the limits are d−sqrt((pT−LT)²+(UC−pC)²) and d+sqrt((UT−pT)²+(pC−LC)²). This is not inversion of the pooled score test; interval exclusion and test decisions can occasionally differ. The tests check finite limits at all-success/all-failure extremes and validate coverage in selected settings; they do not establish universal coverage guarantees.

## Estimation with a precision target

Estimation is the process of estimating a population quantity. Precision describes its sampling uncertainty, assessed here by interval width at a specified confidence level. Both power-based and width-based plans produce estimates and intervals; the distinction is the criterion used to select sample size.

All targets mean FULL confidence interval width at confidence 1−alpha. For normal data, expected width is 2*tCritical*sigma*sqrt(2/n)*c4(df), where c4(df)=sqrt(2/df)*Gamma((df+1)/2)/Gamma(df/2). For binary data the anticipated curve plugs assumed probabilities into the Newcombe formula. It is not exact expected width. Planning for a precision target searches this expected or plug-in width criterion. Neither is a probability-of-width guarantee; simulations report mean width and the fraction attaining the target separately.

## Reproducibility and uncertainty

The seed is set once before a batch, and the caller's random state is restored afterward. Replications use fresh draws. Results retain the complete generating specification. App downloads also retain planning assumptions, goal, dropout and method, and saved outputs are flagged when controls change. Results from a saved run are never relabeled with new inputs.

Rejection, coverage and width-attainment summaries report MCSE sqrt(p*(1−p)/B) and 95% Wilson intervals based on B independent studies. An MCSE of zero at a boundary does not establish certainty; the Wilson interval remains nonzero. Clinical assumption uncertainty is a separate sensitivity question. Changing generating parameters leaves planned n fixed; increasing B never increases per-study power.

## Recruitment

The recruitment app uses `recruitment_plan()` in `R/sample_size_functions.R`. Its optional all-or-none switching approximation sets n_adjusted = n / (1-a-b)^2, where a and b are switching fractions in the two directions and a+b < 1. It assumes comparable outcome distributions among recipients of each treatment and little variance change. When the starting calculation already incorporates switching, the app applies a multiplier of one. Binary outcomes should be replanned with the revised event probabilities in the two-proportion app.

For expected losses r1 and r0, equal recruitment is ceil(max(n_adjusted/(1-r1), n_adjusted/(1-r0))) per group. Intermediate counts remain unrounded. Equal recruitment with unequal losses yields unequal expected retained counts; the larger requirement preserves at least n_adjusted in expectation in each group. This is an allowance, with actual retention and missing-data bias requiring separate attention. A starting count of 100, switching of 10% and 5%, and shared losses of 5% gives 146 recruits per group. This avoids the extra participant produced by rounding at every intermediate step.

The report records applied inputs, intermediate results, method, assumptions, R/Shiny versions, source history and the learner's justification. The lab link carries the starting analyzable count; switching and unequal losses remain specific to this calculation. The main simulations condition on complete outcomes; the advanced missing-outcome extension explicitly models attrition.

Sources: [Wittes (2002)](https://doi.org/10.1093/epirev/24.1.39), [Shardell and El-Kamary (2009)](https://doi.org/10.1111/j.1541-0420.2008.01114.x), and [ICH E9(R1)](https://www.fda.gov/media/148473/download).

## References

See [References](references.md), especially Newcombe (1998) and the R documentation. `scripts/check_resource.R` checks independent reference results, null rejection, interval coverage, reproducibility, edge cases, calculation rounding and app server behavior. Browser checks are documented separately in the implementation validation record.

## Single-proportion precision and pilot process outcomes

The added prevalence_precision activity uses one independent binary sample. Its n is a total count, unlike the per-group n in the comparison lab. The approximate planning formula is n = ceiling(z² p(1−p)/d²), where z is the normal quantile for the chosen two-sided confidence level and d is the HALF interval width. The shared helper accepts FULL width and divides it by two. At 95% confidence, an anticipated proportion of 0.20 and full width 0.10 gives 246 analyzable observations. With unknown p, the conservative planning value 0.50 gives 385. The maximum at 0.50 concerns fixed absolute width under this approximation; it is not a general conservative choice for treatment comparisons, relative precision, diagnostic recruitment or prediction models.

This approximation is not a promise about realized Wilson interval width. The activity's single-study draw is binomial with the anticipated proportion used as a hypothetical generating truth, and the interval uses uncorrected Wilson limits. Unknown p changes the planning value, while the generating slider remains an illustrative assumption. Wilson limits remain within [0,1], including observed zero or all events. Sparse-count flags use fewer than ten anticipated events or non-events as an instructional prompt, not as a validity theorem or universal minimum. Planning p exactly 0 or 1 is rejected because its normal-approximation variance degenerates; the unknown-p option still works at those inputs in the helper. The interactive slider stays away from the boundaries, and simulation/interval helpers support boundary realizations.

The fixed-resource pilot preset estimates one retention proportion with n = 40 and anticipated retention 0.80; it does not test treatment effectiveness. Its stated full-width target is a hypothetical learner goal. Recruitment is ceiling(n/(1−loss)); simulation conditions on analyzable n and does not simulate or correct missing-data mechanisms. Complex sampling, population corrections and imperfect diagnostic measurements require an appropriate extension beyond this introductory method.

## Sampling distributions of one normal mean

The sampling_distributions activity is a separate known-SD reference model: independent observations from a normal population, one sample, SE = sigma/sqrt(n). For a greater-than test, c = mu0 + qnorm(1−alpha)×SE, alpha = P(mean > c | mu0), and power = P(mean > c | mu1). A less-than test uses the lower tail; a two-sided test divides alpha between both rejection tails. Beta is one minus power at the specified alternative. The null and alternative curves are distributions of the SAMPLE MEAN, not distributions of patient observations or probabilities assigned to the hypotheses.

The shared helper returns boundaries, SE, alpha under the null, beta and power. The blood-pressure preset uses mu0 = 120, mu1 = 125, sigma = 15, n = 25 and one-sided alpha = 0.05: SE = 3, c ≈ 124.935 and power ≈ 0.509. These are exact normal probabilities given the stated known-SD assumptions. They are distinct from the main lab's estimated-variance two-sample t analysis. A one-sided alternative in the opposite direction may yield power below alpha. The direction must be chosen before inspecting outcomes.

## Shared cases and added validation

R/teaching_cases.R supplies the tutorial and apps with one named registry of hypothetical case assumptions. Each record states its app and study structure so one-proportion and one-sample-mean activities are not applied as independent-group comparisons. Activity state is validated by a whitelist of supported inputs before being applied; changed controls do not relabel a saved illustrative sample.

scripts/check_feedback.R checks upward sample-size rounding by independently inverting the normal half-width formula, verifies Wilson intervals against uncorrected prop.test, enumerates binomial outcomes to check selected coverage and variable width attainment, checks caller RNG preservation, and integrates normal densities over rejection regions to verify power. Server checks cover fixed-resource and precision modes, shared-case routing, malformed input rejection, stale saved intervals and both test directions. These checks establish the selected examples and implementation; they do not establish universal finite-sample performance.


## Missing outcomes in repeated chronic-pain trials

The optional extension in the [repeated-trial activity](../study/?activity=pain_simulation) holds recruitment per group fixed across four scenarios: complete outcomes; 10% outcome-independent loss in both groups; outcome-independent losses of 10% standard and 20% novel; and losses with the same marginal probabilities but related to relief in the novel group. For that last scenario, the missingness probability without relief is three times the probability with relief. If p is population relief and r is the expected loss, these probabilities are r / [p + 3(1-p)] with relief and three times that without relief. The standard group's loss is independent of outcome.

The single-study simulation generates binary outcomes and missingness indicators. The batch simulation samples equivalent multinomial sufficient counts for the four observed/missing and relief/no-relief combinations. Available-case analysis uses the actual retained counts, a two-sided pooled score test without continuity correction, and a Newcombe-Wilson interval for the risk difference. No observed outcomes in either group makes the comparison unavailable; these studies are counted and excluded from the denominator of performance summaries. Bias and coverage refer to the full recruited population difference. The table reports the Monte Carlo SE of estimated bias. Downloads preserve the scenario, recruited count, group loss probabilities, missingness multiplier, population assumptions, actual retained counts, and random seed.

These hypothetical mechanisms illustrate why missingness reasons and analysis assumptions matter. They do not identify a mechanism from real data. See [Bell et al. (2013)](https://doi.org/10.1136/bmj.e8668) and [Little et al. (2012)](https://doi.org/10.1002/sim.5519).
