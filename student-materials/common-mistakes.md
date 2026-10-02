# Common mistakes and questions {#common-mistakes}

::: {.learning-goals}
**Learning goals.** After this section, you should be able to identify and correct common misinterpretations of percentage changes, statistical significance, clinical importance and power, and explain the limits of pilot estimates and fixed samples.
:::

## Does "20% better" mean 20 percentage points?

State the baseline and scale. From a baseline of 80%, a 20% relative increase gives 96%; an absolute increase of 20 percentage points gives 100%. The two-proportion calculator needs the probabilities in each group, entered as proportions between zero and one. The [discharge example](#discharge) lets you compare these interpretations.

## Can I put a clinically important difference directly into the alternative hypothesis?

For the ordinary two-sided superiority test, the alternative is any nonzero difference. Power is evaluated at a particular planned effect. Rejecting zero does not show that the true benefit exceeds the clinical threshold. Interpret the effect estimate and confidence interval against both zero and the threshold.

## Does a non-significant result establish that treatments are the same?

No. An interval might include both negligible and important effects. Assess the range and the design's limitations. Equivalence and non-inferiority ask different questions and require their own margins, hypotheses and planning methods.

## Are alpha and beta probabilities that the hypotheses are true?

No. [Alpha](#alpha) concerns rejection when the null is true. [Beta](#beta) concerns failure to reject at a specified true alternative. Both condition on a population scenario and a procedure. They are not posterior probabilities after observing the data. The [sampling distributions](#alpha-beta) and simulated independent studies illustrate this conditioning.

## Does 90% power guarantee a useful result?

No. With [90% power](#statistical-power), about 90% of hypothetical independent studies under the specified effect, design and analysis would reject the null hypothesis. An individual study can be inconclusive, and a significant study can have an interval too wide for a clinical decision. Compare power, anticipated precision and realised interval performance.

## Can I use my small pilot's effect estimate without qualification?

Record its uncertainty and compare it with wider evidence. Small pilots can give unstable treatment estimates; selecting only promising pilots can introduce further bias. Pilot planning should follow feasibility objectives and useful precision for those objectives. See the [practical pilot case](#pilot-feasibility) and [Albers and Lakens (2018)](https://doi.org/10.1016/j.jesp.2017.09.004).

## Is a 50% event probability a safe default whenever I do not know the event rate?

Its conservative role here is limited to **absolute precision for one proportion under the displayed normal approximation**: it maximizes p(1-p). It is not a general fallback for unknown treatment/control rates, prediction-model planning, relative precision or rare-event questions. See the [single-proportion example](#prevalence).

## My study is retrospective: should I calculate observed power instead of sample size?

If the records already exist, explain why that sample is available and report the estimate, confidence interval and limitations. Do not use the same data's observed effect in a power calculation to create evidence for that result. At independently justified effects, sensitivity analysis can describe the fixed design's performance. For example, 200 existing records may be useful for estimating a prevalence even when they do not support a precise adjusted treatment effect. "Retrospective" describes timing; it does not by itself select a statistical test. See [Althouse (2021)](https://pubmed.ncbi.nlm.nih.gov/32814615/) and [Lakens (2022)](https://doi.org/10.1525/collabra.33267).

## Why do the hand formula, R and another calculator give different numbers?

Check outcome, allocation, sidedness, effect scale, alpha, target power, test assumptions, continuity correction and rounding. The simple mean calculator uses a normal approximation; the lab plans for a pooled t test. Binary analytical power remains an approximation and can differ from finite-sample simulation. A numerical difference is not automatically a software error.

## Can I count two visits, two eyes or patients in one allocated ward as independent observations?

Usually not. Identify the experimental unit and dependency before selecting the calculation. A paired design uses within-pair information; cluster allocation requires accounting for within-cluster correlation. Use the [study-design guide](#study-designs) rather than entering every record into the independent-group app.

## Should I add 10% for expected 10% dropout?

Divide the required analysable count by 1 - 0.10, then round up within each arm. This is about 11.1% extra before rounding. The actual number retained can differ from expectation, and missing outcomes can bias results even after recruitment inflation.

## Is more simulation the same as a larger study?

Increasing B estimates the rejection rate, interval coverage and other simulation results more precisely. Increasing n changes the amount of patient information in each study and therefore changes its power and precision. Keep these two quantities separate, and report both with the seed.

## Will a larger sample solve bias?

A larger sample reduces sampling variation under the model. It does not automatically repair selection bias, confounding, unreliable measurements, missing-data bias or an inappropriate analysis. Choose a defensible design before fine-tuning its sample size.

## Is a reporting checklist a sample-size method?

No. CONSORT, STROBE, STARD, ARRIVE and TRIPOD help document different studies. They prompt you to report how sample size was chosen, but do not provide one universal formula. The [study-design guide](#study-designs) separates reporting resources from planning methods.
