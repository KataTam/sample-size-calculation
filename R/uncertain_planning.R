# Original worked examples for uncertainty in sample size planning.
# Counts are enumerated exactly, so these results have no Monte Carlo error.
beta_greater_probability <- function(a_novel, b_novel, a_standard, b_standard) {
  # Integrate over the novel-treatment probability. pbeta() gives the chance
  # that the standard-treatment probability is below each candidate value.
  integrate(function(p) dbeta(p, a_novel, b_novel) *
    pbeta(p, a_standard, b_standard), 0, 1,
    rel.tol = 1e-10, subdivisions = 200L)$value
}

neuropathy_uncertain_planning <- function(n = 56L) {
  stopifnot(length(n) == 1L, is.finite(n), n >= 34, n == as.integer(n))
  p_standard <- .30
  p_novel <- c(.30, .50, .60, .70)
  weights <- c(.10, .30, .40, .20)
  counts <- 0:n
  # Uniform Beta(1,1) analysis priors become Beta(1 + successes,
  # 1 + failures) after observing a binomial count in each group.
  posterior <- outer(counts, counts, Vectorize(function(x, y)
    beta_greater_probability(x + 1, n - x + 1, y + 1, n - y + 1)))
  success <- posterior > .975
  bayes_success <- vapply(p_novel, function(p) {
    # Each matrix entry is the probability of one possible pair of counts.
    sum(outer(dbinom(counts, n, p), dbinom(counts, n, p_standard)) * success)
  }, numeric(1))
  # The earlier planning calculation uses this same normal approximation.
  fixed_power <- vapply(p_novel, function(p)
    power_two_proportions(n, p, p_standard), numeric(1))
  list(n = n, p_novel = p_novel, weights = weights,
    fixed_power = fixed_power, assurance = sum(weights * fixed_power),
    bayes_success = bayes_success, bayes_assurance = sum(weights * bayes_success),
    observed_novel = 34L, observed_standard = 17L,
    posterior_benefit = posterior[35, 18], posterior_matrix = posterior)
}

draw_diagnostic_update <- function() {
  old <- par(no.readonly = TRUE); on.exit(par(old))
  par(mar = rep(.3, 4), family = "sans", fg = "#26343d", bg = "white")
  plot.new(); plot.window(c(0, 100), c(0, 100), xaxs = "i", yaxs = "i")
  box <- function(x, y, label, fill = "#e2edf8") {
    rect(x - 21, y - 9, x + 21, y + 9, col = fill, border = "#64778a")
    text(x, y, label, cex = .95)
  }
  box(50, 88, "100 clinic patients\nBefore testing: 20% have neuropathy")
  arrows(c(40, 60), 78, c(25, 75), 67, length = .08, col = "#64778a")
  box(25, 57, "20 with neuropathy")
  box(75, 57, "80 without neuropathy")
  arrows(c(25, 75), 47, c(25, 75), 35, length = .08, col = "#64778a")
  rect(c(9, 59), 37, c(41, 91), 43, col = "white", border = NA)
  text(c(25, 75), 40, c("90% test positive", "10% test positive"), cex = .88)
  box(25, 24, "18 positive results\n2 negative results", "#e8dff2")
  box(75, 24, "8 positive results\n72 negative results", "#e8dff2")
  text(50, 4, "After a positive result: 18 of 26 have neuropathy, about 69%", cex = 1)
}

draw_bayesian_update <- function(n = 56L, x_novel = 34L, x_standard = 17L) {
  old <- par(no.readonly = TRUE); on.exit(par(old))
  delta <- seq(-1, 1, length.out = 401)
  # The difference of two independent uniform probabilities has a triangular
  # density. For the posterior, integrate over compatible arm probabilities.
  density <- vapply(delta, function(d) {
    lo <- max(0, -d); hi <- min(1, 1 - d)
    if (lo >= hi) return(0)
    integrate(function(p) dbeta(p + d, x_novel + 1, n - x_novel + 1) *
      dbeta(p, x_standard + 1, n - x_standard + 1), lo, hi,
      rel.tol = 1e-8)$value
  }, numeric(1))
  par(mar = c(4.6, 4.2, 2.5, 1), family = "sans", fg = "#26343d", bg = "white")
  # Divide by 100 because the horizontal scale uses percentage points.
  plot(100 * delta, density / 100, type = "l", lwd = 2.3, col = "#72428b",
    xlab = "Population relief difference: novel minus standard (percentage points)",
    ylab = "Probability density", ylim = c(0, max(density) * 1.15 / 100))
  lines(100 * delta, (1 - abs(delta)) / 100, lwd = 2, lty = 2, col = "#245e90")
  abline(v = 0, col = "#64778a", lty = 3)
  legend("topleft", bty = "n", cex = .9, lty = c(2, 1), lwd = 2,
    col = c("#245e90", "#72428b"), legend = c("Before trial data: analysis prior", "After 34/56 versus 17/56: posterior"))
  mtext("Area to the right of zero = probability of a positive treatment difference", side = 3, line = .5, cex = .86)
}
