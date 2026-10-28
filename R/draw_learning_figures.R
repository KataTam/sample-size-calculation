# Original figures for the glossary and FAQ. Rebuilt with the tutorial.
draw_learning_figures <- function(folder = "figures") {
  dir.create(folder, showWarnings = FALSE, recursive = TRUE)
  png(file.path(folder, "standardized-difference.png"), width = 1500, height = 800, res = 170)
  par(mar = c(4.4, 4.5, 2, 1), las = 1)
  x <- seq(-16, 19, length.out = 601)
  plot(x, dnorm(x, 0, 5), type = "l", lwd = 3, col = "#17658a",
       ylim = c(0, .12), xlab = "Individual improvement score (score units)",
       ylab = "Probability density", bty = "l")
  lines(x, dnorm(x, 3, 5), col = "#72428b", lwd = 3, lty = 2)
  segments(c(0, 3), 0, c(0, 3), .087, lty = 3, col = "#555555")
  arrows(0, .09, 3, .09, code = 3, angle = 90, length = .06)
  text(1.5, .099, "Mean difference = 3", cex = .9)
  arrows(3, .064, 8, .064, code = 3, angle = 90, length = .06)
  text(8.8, .066, "SD = 5", adj = 0, cex = .9)
  legend("topleft", c("Standard: mean 0", "Novel: mean 3"),
         col = c("#17658a", "#72428b"), lty = c(1, 2), lwd = 3, bty = "n", cex = .85)
  text(15, .108, "d = 3/5 = 0.60", cex = 1)
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
}
