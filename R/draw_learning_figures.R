# Original figures for the glossary and FAQ. Rebuilt with the tutorial.
draw_learning_figures <- function(folder = "figures") {
  dir.create(folder, showWarnings = FALSE, recursive = TRUE)
  png(file.path(folder, "standardized-difference.png"), width = 1500, height = 800, res = 170)
  par(mar = c(4.4, 4.5, 2, 1), las = 1)
  x <- seq(-16, 19, length.out = 601)
  plot(x, dnorm(x, 0, 5), type = "l", lwd = 3, col = "#17658a",
       ylim = c(0, .15), xlab = "Individual improvement score (score units)",
       ylab = "Probability density", bty = "l")
  lines(x, dnorm(x, 3, 5), col = "#72428b", lwd = 3, lty = 2)
  segments(c(0, 3), 0, c(0, 3), .12, lty = 3, col = "#555555")
  arrows(0, .123, 3, .123, code = 3, angle = 90, length = .06)
  text(1.5, .135, "Mean difference = 3", cex = .9)
  # One SD is a horizontal distance on the score scale. Its bracket and
  # endpoint labels sit above the density curves to keep both meanings clear.
  arrows(3, .1, 8, .1, code = 3, angle = 90, length = .06, col = "#72428b")
  text(5.5, .112, "1 SD = 5", cex = .9, col = "#72428b")
  text(c(3, 8), .09, c("3", "8"), cex = .8, col = "#72428b")
  legend("topleft", c("Standard: mean 0", "Novel: mean 3"),
         col = c("#17658a", "#72428b"), lty = c(1, 2), lwd = 3, bty = "n", cex = .85)
  text(15, .135, "d = 3/5 = 0.60", cex = 1)
  dev.off()
  png(file.path(folder, "single-proportion-planning.png"), width = 1500, height = 800, res = 170)
  par(mar = c(4.4, 4.5, 2, 1), las = 1)
  p <- seq(.001, .999, length.out = 999)
  n <- ceiling(qnorm(.975)^2 * p * (1-p) / .05^2)
  plot(100*p, n, type = "l", lwd = 3, col = "#17658a", ylim = c(0, 445),
       xlab = "Anticipated event percentage (%)", ylab = "Required participants", bty = "l")
  segments(50, 0, 50, max(n), lty = 2, col = "#72428b")
  points(50, max(n), pch = 19, cex = 1.3, col = "#72428b")
  text(50, 422, paste("50%: maximum", max(n), "participants"))
  dev.off()
  # Compare intervals calculated from the same counts. The normal (Wald)
  # interval uses the observed percentage in its standard error. Wilson checks
  # candidate population percentages and retains those compatible with the count.
  observed <- c(50, 1, 0)
  total <- c(100, 20, 20)
  p <- observed / total
  z <- qnorm(.975)
  wald <- cbind(p - z * sqrt(p * (1-p) / total),
                p + z * sqrt(p * (1-p) / total))
  center <- (p + z^2 / (2 * total)) / (1 + z^2 / total)
  margin <- z * sqrt(p * (1-p) / total + z^2 / (4 * total^2)) / (1 + z^2 / total)
  wilson <- cbind(center - margin, center + margin)
  png(file.path(folder, "wald-wilson-intervals.png"), width = 1700, height = 1050, res = 190)
  par(mar = c(4.6, 8.7, 2.1, 1.2), las = 1, fg = "#26343d",
      col.axis = "#26343d", col.lab = "#26343d")
  plot(NA, xlim = c(-11, 81), ylim = c(.2, 7.2), axes = FALSE,
    xlab = "Population percentage compatible with the observed count (%)", ylab = "")
  rect(-11, .2, 0, 7.2, col = "#f0f0f0", border = NA)
  abline(v = 0, lty = 3, col = "#727d86")
  axis(1, at = seq(-10, 70, 10))
  legend("topright", c("Normal (Wald)", "Wilson"), col = c("#17658a", "#72428b"),
    lty = c(2, 1), lwd = 3, bty = "n", cex = .9)
  for (i in seq_along(p)) {
    y <- 6.1 - (i-1) * 2.1
    text(-12, y-.3, paste0(observed[i], " of ", total[i], " patients\n", 100*p[i], "% observed"),
      adj = 1, xpd = NA, cex = .95)
    for (j in 1:2) {
      limits <- 100 * if (j == 1) wald[i, ] else wilson[i, ]
      limits[abs(limits) < 1e-10] <- 0
      yy <- y - (j-1)*.6
      color <- c("#17658a", "#72428b")[j]
      segments(limits[1], yy, limits[2], yy, col = color, lwd = 3, lty = c(2,1)[j])
      segments(limits, yy-.09, limits, yy+.09, col = color, lwd = 2)
      points(100*p[i], yy, pch = 19, col = color, cex = .85)
      text(80, yy, sprintf("%.1f%% to %.1f%%", limits[1], limits[2]), adj = 1, cex = .9, col = color)
    }
  }
  dev.off()
}
