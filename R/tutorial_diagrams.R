# Original teaching illustrations, drawn by R when the tutorial is rendered.
# These functions draw on the active graphics device and leave its settings intact.
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
    points(x, y + 5, pch = 16, cex = 1.15, col = color)
    segments(x, y + 2.5, x, y - 3, col = color, lwd = 2.2)
    segments(x, y + 1, x + c(-1.25, 1.25),
      y + if (improved) 3.2 else -1.5, col = color, lwd = 2.2)
    segments(x, y - 3, x + c(-1.2, 1.2), y - 6.5,
      col = color, lwd = 2.2)
  }
  centers <- c(25, 75)
  responders <- c(7L, 3L)
  text(centers, 96, c("Novel treatment", "Standard treatment"),
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
  text(centers, 19, sprintf("%d of 10 (%d%%) report pain relief",
    responders, 10L * responders), cex = 1)
  points(c(15, 57), c(6, 6), pch = 16, cex = 1, col = c(pain, relief))
  text(c(18, 60), c(6, 6), c("Pain / no reported relief", "Reported pain relief"),
    adj = 0, cex = .92)
}

draw_planning_differences <- function() {
  old <- par(no.readonly = TRUE)
  on.exit(par(old))
  diagram_canvas()
  text(50, 95, "Chronic pain: three planning quantities", font = 2, cex = 1.12)
  values <- c(40, 30, 20)
  rows <- c(77, 53, 29)
  colors <- c("#17658a", "#72428b", "#a66510")
  x <- function(value) 41 + value
  for (i in seq_along(values)) {
    segments(x(0), rows[i], x(50), rows[i], col = "#e0e5e9")
    points(x(values[i]), rows[i], pch = c(17, 15, 18)[i], cex = 1.7,
      col = colors[i])
    text(x(values[i]), rows[i] + 7, values[i], col = colors[i], cex = 1.1)
  }
  text(3, rows + 3, c("Expected difference", "Target difference", "Clinical threshold"),
    adj = 0, cex = 1)
  text(3, rows - 5, c("Best current expectation", "Used to evaluate power",
    "Smallest worthwhile benefit"), adj = 0, cex = .85)
  segments(x(0), 16, x(50), 16)
  for (tick in seq(0, 50, 10)) {
    segments(x(tick), 16, x(tick), 14)
    text(x(tick), 10, tick, cex = .85)
  }
  text(50, 2, "Novel minus standard: difference in pain relief (percentage points)", cex = .94)
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
  text(c(16, 50, 85), 96,
    c("Randomized group", "Treatment received", "Final assessment"), font = 2, cex = .97)
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
