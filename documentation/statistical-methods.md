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
