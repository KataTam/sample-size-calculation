# Original teaching illustrations, drawn by R when the tutorial is rendered.
# These functions draw on the active graphics device and leave its settings intact.
draw_normal_multiplier <- function() {
  old <- par(no.readonly = TRUE)
  on.exit(par(old))
  par(mfrow = c(2, 1), mar = c(3.5, 2, 2.2, 1), oma = c(1.8, 0, 0, 0),
      family = "sans", fg = "#26343d", bg = "white")
  z <- seq(-3.7, 3.7, length.out = 1000)
  shade <- function(lo, hi, color) {
    xx <- seq(lo, hi, length.out = 250)
    polygon(c(lo, xx, hi), c(0, dnorm(xx), 0), col = color, border = NA)
  }
  curve_panel <- function(title) {
    plot(z, dnorm(z), type = "n", axes = FALSE, xlab = "", ylab = "",
         ylim = c(0, .48), main = title, cex.main = 1)
    axis(1, at = -3:3)
    mtext("z-value (standard deviations from the center)", side = 1, line = 2.2, cex = .8)
  }
  critical <- qnorm(.975)
  curve_panel("1. Type I error probability: 5% split between two tails")
  shade(-3.7, -critical, "#e8b4b0"); shade(critical, 3.7, "#e8b4b0")
  lines(z, dnorm(z), lwd = 2, col = "#245e90")
  segments(c(-critical, critical), 0, c(-critical, critical), dnorm(critical), lty = 2)
  text(c(-2.65, 2.65), .13, "2.5%", cex = .9)
  text(c(-critical, critical), .22, c("-1.96", "+1.96"), cex = .9)
  text(0, .43, "95% between the cutoffs", cex = .9)
  cut <- qnorm(.90)
  curve_panel("2. Target power: the 90th percentile")
  shade(-3.7, cut, "#b9d7ec"); shade(cut, 3.7, "#e6e9ec")
  lines(z, dnorm(z), lwd = 2, col = "#245e90")
  segments(cut, 0, cut, dnorm(cut), lty = 2)
  text(-.5, .20, "90% to the left", cex = .9)
  text(2.35, .13, "10%", cex = .9)
  text(cut, .31, "+1.28", cex = .9)
  mtext("Multiplier M = (1.96 + 1.28)^2 = 10.51, using unrounded cutoffs", side = 1,
        outer = TRUE, line = .3, cex = .85)
}

diagram_canvas <- function() {
  par(mar = rep(0, 4), bg = "white", fg = "#26343d", family = "sans",
    xaxs = "i", yaxs = "i")
  plot.new()
  plot.window(c(0, 100), c(0, 100))
}

diagram_box <- function(x0, y0, x1, y1, label, fill = "#edf4f7",
    border = "#17658a", cex = 1) {
  rect(x0, y0, x1, y1, col = fill, border = border, lwd = 1.4)
  text((x0 + x1) / 2, (y0 + y1) / 2, label, cex = cex)
}

diagram_arrow <- function(x0, y0, x1, y1, ...) {
  arrows(x0, y0, x1, y1, length = .08, lwd = 1.5,
    col = "#596773", ...)
}

draw_pain_pilot_patients <- function() {
  old <- par(no.readonly = TRUE)
  on.exit(par(old))
  diagram_canvas()
  pain <- "#b43c36"
  relief <- "#21834a"
  person <- function(x, y, improved = FALSE) {
    color <- if (improved) relief else pain
    segments(x, y + 4, x, y - 3, col = color, lwd = 2.2)
    points(x, y + 4, pch = 16, cex = 1.15, col = color)
    segments(x, y + 1, x + c(-1.25, 1.25),
      y + if (improved) 3.2 else -1.5, col = color, lwd = 2.2)
    segments(x, y - 3, x + c(-1.2, 1.2), y - 6.5,
      col = color, lwd = 2.2)
  }
  centers <- c(25, 75)
  responders <- c(3L, 7L)
  text(centers, 96, c("Duloxetine (standard)", "Neravixa (novel)"),
    font = 2, cex = 1.12)
  text(50, 86, "Before treatment: all 10 patients in each group have pain", cex = 1)
  segments(50, 23, 50, 79, col = "#e0e5e9")
  for (group in 1:2) {
    positions <- centers[group] + seq(-20, 20, length.out = 10)
    for (i in 1:10) {
      person(positions[i], 72)
      person(positions[i], 33, improved = i <= responders[group])
    }
    diagram_arrow(centers[group], 61, centers[group], 47)
  }
  # Arm position and printed counts supplement the red/green color coding.
  rect(43, 50, 57, 58, col = "white", border = NA)
  text(50, 54, "4 weeks", cex = 1.02)
  text(centers, 19, sprintf("%d of 10 (%d%%) achieved pain relief",
    responders, 10L * responders), cex = 1)
  points(c(15, 57), c(6, 6), pch = 16, cex = 1, col = c(pain, relief))
  text(c(18, 60), c(6, 6), c("Did not achieve pain relief", "Achieved pain relief"),
    adj = 0, cex = .92)
}

# The same simulated patient records feed the chapter table and this figure.
draw_three_pain_trials <- function(trials) {
  old <- par(no.readonly = TRUE)
  on.exit(par(old))
  par(mar = c(2.8, .6, .5, .6), bg = "white", family = "sans",
    fg = "#26343d", xaxs = "i", yaxs = "i")
  plot.new(); plot.window(c(0, 100), c(-18, 100))
  text(c(29, 52, 83), 96, c("Duloxetine", "Neravixa", "Observed difference"),
    font = 2, cex = .94)
  text(c(29, 52), 90, c("Population: 30% relief", "Population: 60% relief"), cex = .82)
  xs <- function(points) 69 + points / 60 * 28
  segments(xs(30), 13, xs(30), 84, lty = 2, col = "#72428b", lwd = 1.5)
  for (i in seq_along(trials)) {
    y <- 73 - (i - 1) * 25
    trial <- trials[[i]]
    text(8, y - 3, paste("Trial", i), cex = .98)
    for (g in 1:2) {
      values <- trial$data$outcome[trial$data$group == c("Control", "Treatment")[g]]
      center <- c(29, 52)[g]; color <- c("#19738c", "#984b87")[g]
      # Filled/open symbols provide a distinction independent of color.
      for (j in seq_along(values)) points(center - 9 + ((j - 1) %% 10) * 2,
        y + 3 - ((j - 1) %/% 10) * 5, pch = 21, cex = .9,
        col = color, bg = if (values[j] == 1) color else "white", lwd = 1.1)
      text(center, y - 10, sprintf("%d of %d (%d%%)", sum(values), length(values),
        round(100 * mean(values))), cex = .87)
    }
    delta <- 100 * trial$result$estimate
    arrows(64, y - 2, xs(delta) - 1.6, y - 2, length = .07, col = "#687985", lwd = 1.2)
    points(xs(delta), y - 2, pch = 21, bg = "#984b87", col = "white", cex = 1.7)
    text(xs(delta), y - 9, paste0(round(delta), " points"), cex = .83)
  }
  axis(1, at = xs(seq(0, 60, 10)), labels = seq(0, 60, 10), pos = 8, cex.axis = .8)
  text(83, -10, "Neravixa minus duloxetine\n(percentage points)", cex = .8)
  points(c(10, 31), c(-10, -10), pch = 21, bg = c("#19738c", "white"), col = "#19738c", cex = .9)
  text(c(12, 33), c(-10, -10), c("Achieved relief", "Did not achieve relief"), adj = 0, cex = .78)
}

draw_planning_differences <- function() {
  old <- par(no.readonly = TRUE)
  on.exit(par(old))
  par(mar = c(4.4, 10.2, .7, .8), las = 1, bg = "white",
    fg = "#26343d", col.axis = "#26343d", col.lab = "#26343d",
    family = "sans")
  values <- c(40, 30, 20)
  rows <- 3:1
  colors <- c("#17658a", "#72428b", "#a66510")
  plot(NA, xlim = c(0, 50), ylim = c(.5, 3.5),
    xaxs = "i", yaxs = "i", axes = FALSE, xlab = "", ylab = "")
  abline(h = rows, col = "#e5e9ec", lwd = 1)
  abline(v = 0, col = "#4b5560", lwd = 1.5)
  segments(0, rows, values, rows, col = colors, lwd = 3, lend = "butt")
  points(values, rows, pch = c(17, 15, 18), cex = 1.25, col = colors)
  text(values + 1.6, rows, values, adj = 0, cex = .95, col = colors)
  text(-2, rows + .13, c("Observed in the pilot", "Target difference", "Clinical threshold"),
    adj = 1, cex = .95, xpd = NA)
  text(-2, rows - .22, c("Result in the pilot sample", "Used to evaluate power",
    "Smallest worthwhile benefit"), adj = 1, cex = .78, xpd = NA)
  axis(1, at = seq(0, 50, 10), cex.axis = .9)
  mtext("Difference in pain-relief percentages", side = 1, line = 2.1, cex = .95)
  mtext("Novel minus standard treatment (percentage points)", side = 1,
    line = 3.2, cex = .8)
}

draw_discharge_grids <- function() {
  old <- par(no.readonly = TRUE)
  on.exit(par(old))
  diagram_canvas()
  baseline <- 80L
  totals <- c(baseline, as.integer(baseline * 1.20), baseline + 10L)
  centers <- c(17, 50, 83)
  titles <- c("Standard care", "20% relative increase", "10 percentage points")
  for (j in seq_along(totals)) {
    text(centers[j], 96, titles[j], cex = .97, font = 2)
    text(centers[j], 88, sprintf("%d of 100 (%d%%)", totals[j], totals[j]), cex = 1.05)
    for (i in 1:100) {
      x <- centers[j] - 12.15 + ((i - 1) %% 10) * 2.7
      y <- 77 - ((i - 1) %/% 10) * 4.5
      fill <- if (i <= baseline) "#17658a" else if (i <= totals[j]) "#bd791a" else "white"
      rect(x - 1.08, y - 1.8, x + 1.08, y + 1.8,
        col = fill, border = if (i <= totals[j]) fill else "#7c8992")
    }
  }
  text(centers, 27, c("Baseline", "80% x 1.20 = 96%", "80% + 10 points = 90%"), cex = .94)
  rect(4, 15, 6, 18, col = "#17658a", border = NA)
  text(8, 16.5, "Baseline discharges", adj = 0, cex = .83)
  rect(36, 15, 38, 18, col = "#bd791a", border = NA)
  text(40, 16.5, "Additional discharges", adj = 0, cex = .83)
  rect(72, 15, 74, 18, col = "white", border = "#7c8992")
  text(76, 16.5, "Not discharged", adj = 0, cex = .83)
  text(50, 6, "Each square represents one of 100 hypothetical patients.", cex = .94)
}

draw_treatment_followup <- function() {
  old <- par(no.readonly = TRUE)
  on.exit(par(old))
  diagram_canvas()
  text(c(16, 50, 85), 95,
    c("1. Randomized\ngroup", "2. Treatment\nreceived", "3. Four-week\noutcome"), font = 2, cex = .97)
  for (i in 1:2) {
    y <- c(70, 30)[i]
    border <- c("#17658a", "#72428b")[i]
    fill <- c("#eef5f8", "#f4f0f8")[i]
    rect(2, y - 19, 98, y + 19, col = fill, border = NA)
    diagram_box(4, y - 9, 28, y + 9,
      c("Assigned novel\ntreatment", "Assigned standard\ntreatment")[i],
      fill = "white", border = border, cex = .95)
    diagram_box(38, y + 3, 63, y + 14,
      c("Novel treatment", "Standard treatment")[i],
      fill = "white", border = border, cex = .91)
    diagram_box(38, y - 15, 63, y - 2,
      c("Standard treatment\n(switched)", "Novel treatment\n(switched)")[i],
      fill = "white", border = border, cex = .91)
    segments(28, y, 33, y, col = "#596773", lwd = 1.5)
    segments(33, y - 8.5, 33, y + 8.5, col = "#596773", lwd = 1.5)
    diagram_arrow(33, y + 8.5, 38, y + 8.5)
    diagram_arrow(33, y - 8.5, 38, y - 8.5)
    segments(63, y + c(-8.5, 8.5), 69, y + c(-8.5, 8.5), col = "#596773", lwd = 1.5)
    segments(69, y - 8.5, 69, y + 8.5, col = "#596773", lwd = 1.5)
    diagram_arrow(69, y, 74, y)
    diagram_box(74, y - 15, 96, y + 14,
      "Outcome recorded\nor\nOutcome missing", fill = "white", border = border, cex = .92)
  }
  text(50, 4, "Follow-up should continue after treatment changes.", cex = 1)
}

draw_simulation_loop <- function() {
  old <- par(no.readonly = TRUE)
  on.exit(par(old))
  diagram_canvas()
  text(50, 95, "Assumed pain-relief probabilities: standard 30%, novel 60%", cex = 1.04)
  diagram_box(10, 52, 46, 80,
    "1  Generate one trial\n60 patients per group\n120 patients in total", cex = 1.04)
  diagram_box(56, 52, 91, 80,
    "2  Analyze this trial\nDifference, confidence\ninterval and p-value", cex = 1.04)
  diagram_arrow(46, 66, 56, 66)
  lines(c(91, 96, 96, 4, 4), c(66, 66, 43, 43, 66),
    col = "#72428b", lwd = 1.7, lty = 2)
  diagram_arrow(4, 66, 10, 66, lty = 2)
  text(50, 36, "3  Repeat for 5,000 independent trials", cex = 1.04)
  diagram_arrow(50, 31, 50, 24)
  diagram_box(14, 3, 86, 24,
    "4  Summarize across trials\nPower, confidence interval coverage and width",
    fill = "#f4f0f8", border = "#72428b", cex = 1.04)
  text(50, 86, "Patients per group: n = 60", cex = .93)
}

diagram_person <- function(x, y, treatment) {
  color <- if (treatment == "A") "#17658a" else "#72428b"
  points(x, y + 3, pch = 21, bg = color, col = color, cex = 1.1)
  segments(x, y + 1, x, y - 3, col = color, lwd = 2)
  segments(x - 1.5, y, x + 1.5, y, col = color, lwd = 2)
  segments(x, y - 3, x + c(-1.2, 1.2), y - 5, col = color, lwd = 2)
  text(x, y - 8, treatment, col = color, cex = .8)
}

draw_allocation_units <- function() {
  old <- par(no.readonly = TRUE)
  on.exit(par(old))
  diagram_canvas()
  text(c(14, 51, 87), 97,
    c("Randomization", "Assignment and measurements", "Analysis accounts for"),
    font = 2, cex = .89)
  segments(2, c(64, 33), 98, c(64, 33), col = "#d9dfe4")
  text(3, 81, "Individual\nparticipants", adj = 0, cex = 1.06)
  for (i in 1:6) diagram_person(32 + (i - 1) * 7.4, 84,
    c("A", "B", "A", "B", "B", "A")[i])
  text(87, 81, "Independent\nparticipants", cex = .98)
  text(3, 49, "Whole hospitals\n(clusters)", adj = 0, cex = 1.06)
  for (i in 1:2) {
    left <- c(29, 53)[i]
    rect(left, 37, left + 21, 61, col = "#f4f6f7", border = "#7c8992")
    text(left + 10.5, 58, paste("Hospital", i), cex = .9)
    for (x in left + c(4, 10.5, 17)) diagram_person(x, 49, c("A", "B")[i])
  }
  text(87, 49, "Dependence\nwithin hospitals", cex = .98)
  text(3, 18, "Sites within\nparticipants", adj = 0, cex = 1.06)
  for (i in 1:2) {
    left <- c(29, 53)[i]
    rect(left, 7, left + 21, 30, col = "#f4f6f7", border = "#7c8992")
    text(left + 10.5, 26, paste("Participant", i), cex = .89)
    diagram_box(left + 1.5, 12, left + 10, 21, "Site\nA", cex = .83)
    diagram_box(left + 11, 12, left + 19.5, 21, "Site\nB",
      fill = "#f4f0f8", border = "#72428b", cex = .83)
  }
  text(87, 18, "Within-person\ndifferences", cex = .98)
  text(50, 1.5, "A and B denote treatments. Boxes show the grouping of measurements.", cex = .89)
}
