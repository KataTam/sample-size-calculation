# Validate the new worked example against algebraic and symmetry checks.
source("R/sample_size_functions.R")
source("R/uncertain_planning.R")
plan <- neuropathy_uncertain_planning()
# Independent closed-form beta comparison for positive integer shapes.
beta_compare_sum <- function(a, b, c, d) {
  i <- 0:(a - 1)
  sum(exp(lbeta(c + i, b + d) - log(b + i) - lbeta(1 + i, b) - lbeta(c, d)))
}
stopifnot(abs(beta_compare_sum(35, 23, 18, 40) - plan$posterior_benefit) < 1e-9,
  max(abs(diag(plan$posterior_matrix) - .5)) < 1e-9,
  max(abs(plan$posterior_matrix + t(plan$posterior_matrix) - 1)) < 1e-9,
  abs(sum(plan$weights) - 1) < 1e-12,
  all(diff(plan$bayes_success) > 0),
  plan$bayes_success[1] < .025,
  round(100 * plan$assurance) == 74,
  round(100 * plan$bayes_assurance) == 73,
  identical(as.numeric(ceiling(qnorm((1 + c(.90,.95,.99))/2)^2 * .2*.8/.05^2)),
    c(174,246,425)))
message("Uncertainty example: posterior integration agrees with independent beta sum, exchange symmetry and probability checks pass.")
