# Original teaching illustrations, drawn by R when the tutorial is rendered.
# These functions draw on the active graphics device and leave its settings intact.
draw_normal_multiplier <- function() {
  old <- par(no.readonly=TRUE); on.exit(par(old))
  par(mfrow=c(2,1),mar=c(3.6,3,2.8,1),oma=c(1.8,0,0,0),family="sans",fg="#26343d",bg="white")
  critical <- qnorm(.975); distance <- critical+qnorm(.90)
  x <- seq(-3.7,7,length.out=1400)
  for(i in 1:2){
    center <- if(i==1)0 else distance
    plot(x,dnorm(x,center),type="n",axes=FALSE,xlab="",ylab="",ylim=c(0,.53),
      main=if(i==1)"H0 true: no population difference" else "H0 false: population difference equals the target",cex.main=.95)
    axis(1,at=c(-2,0,2,4,6));mtext("Estimated difference / standard error",side=1,line=2.3,cex=.85)
    for(limits in list(c(-3.7,-critical),c(critical,7))){
      xx<-seq(limits[1],limits[2],length.out=200)
      polygon(c(xx[1],xx,tail(xx,1)),c(0,dnorm(xx,center),0),
        col=if(i==1)"#e8b4b0" else "#b9d7ec",border=NA)
    }
    lines(x,dnorm(x,center),lwd=2.2,col=if(i==1)"#245e90" else "#72428b")
    abline(v=c(-critical,critical),lty=2,col="#596773")
    segments(center,0,center,.41,col=if(i==1)"#245e90" else "#72428b",lty=3)
    if(i==1){
      text(c(-2.6,2.65),.12,"2.5%",cex=.9)
      text(0,.46,"No difference: 0",cex=.9)
    }else{
      text(4.1,.18,"Power: about 90%",cex=.9)
      text(.1,.16,"Type II error:\nabout 10%",cex=.85)
      text(distance,.46,"Target difference",cex=.9)
      arrows(0,.51,critical,.51,code=3,length=.06,col="#596773")
      arrows(critical,.51,distance,.51,code=3,length=.06,col="#596773")
      text(c(critical/2,(critical+distance)/2),.51,c("1.96","1.28"),pos=3,cex=.8,xpd=NA)
    }
  }
  mtext("M = (1.96 + 1.28)^2 = 10.51, using unrounded cutoffs",side=1,outer=TRUE,line=.3,cex=.85)
}

draw_prevalence_coverage <- function(){
  old<-par(no.readonly=TRUE);on.exit(par(old))
  # This reproducible illustrative batch has 19 intervals containing 20%.
  counts<-with_study_seed(2,rbinom(20,246,.2))
  ci<-wilson_interval(counts/246,246);covered<-ci[,1]<=.2 & ci[,2]>=.2
  stopifnot(sum(covered)==19)
  y<-20:1;cols<-ifelse(covered,"#18713d","#b62d32")
  par(mar=c(4.8,4.5,2.2,1),family="sans",bg="white",fg="#26343d")
  plot(NA,xlim=c(8,34),ylim=c(.5,22),axes=FALSE,xlab="Neuropathy prevalence (%)",ylab="Survey")
  abline(h=y,col="#edf0f2");segments(20,.5,20,20.7,lty=2,lwd=2,col="#26343d")
  segments(100*ci[,1],y,100*ci[,2],y,col=cols,lwd=2.5)
  points(100*counts/246,y,pch=ifelse(covered,16,4),col=cols,cex=1.1,lwd=2)
  axis(1,at=seq(10,30,5));axis(2,at=y,labels=1:20,las=1,cex.axis=.8)
  mtext("Population prevalence = 20%",side=3,line=.4,cex=.95)
  legend("top",horiz=TRUE,bty="n",cex=.85,
    legend=c("Contains 20% (19 surveys)","Misses 20% (1 survey)"),pch=c(16,4),col=c("#18713d","#b62d32"))
}

draw_pain_sensitivity <- function(probabilities,n){
  old<-par(no.readonly=TRUE);on.exit(par(old))
  diff<-100*(probabilities-.3)
  required<-vapply(probabilities,function(p)ceiling(power.prop.test(p1=p,p2=.3,sig.level=.05,power=.9,strict=TRUE)$n),numeric(1))
  achieved<-vapply(probabilities,function(p)100*power.prop.test(n=n,p1=p,p2=.3,sig.level=.05,strict=TRUE)$power,numeric(1))
  par(mfrow=c(2,1),mar=c(1.3,4.8,2.4,1),oma=c(3.6,0,0,0),family="sans",fg="#26343d",bg="white")
  plot(diff,required,type="b",pch=19,col="#245e90",lwd=2,xaxt="n",xlim=c(16,44),ylim=c(0,max(required)*1.25),xlab="",ylab="Patients per group",main="Sample required for 90% power",cex.main=1)
  abline(h=n,lty=2,col="#72428b");text(diff,required,required,pos=3,cex=.9)
  mtext(paste(n,"per group"),side=4,at=n,line=-3.5,cex=.75,col="#72428b")
  par(mar=c(2.4,4.8,2.4,1))
  plot(diff,achieved,type="b",pch=19,col="#245e90",lwd=2,xlim=c(16,44),ylim=c(0,115),xlab="",ylab="Power (%)",main=paste("Power with",n,"per group held fixed"),cex.main=1,xaxt="n",yaxt="n")
  axis(1,at=diff);axis(2,at=seq(0,100,20));abline(h=90,lty=2,col="#72428b")
  text(diff,achieved,paste0(round(achieved),"%"),pos=3,cex=.9)
  mtext("True relief difference: novel minus standard (percentage points)",side=1,outer=TRUE,line=1.2,cex=.9)
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

draw_multicenter_allocation <- function() {
  old <- par(no.readonly = TRUE)
  on.exit(par(old))
  diagram_canvas()
  for (panel in 1:2) {
    center <- c(25, 75)[panel]
    text(center, 95, c("Patients randomized within hospitals", "Whole hospitals randomized")[panel],
      cex = .92, font = 2)
    for (hospital in 1:2) {
      y <- c(69, 31)[hospital]
      rect(center-21, y-14, center+21, y+17, border = "#617584", col = "#f1f5f8", lwd = 1.5)
      text(center, y+10, paste("Hospital", hospital), cex = .9)
      groups <- if (panel == 1) c("A", "B", "A", "B") else rep(c("A", "B")[hospital], 4)
      x <- center + c(-14, -5, 5, 14)
      colors <- ifelse(groups == "A", "#17658a", "#72428b")
      points(x, rep(y-4, 4), pch = 21, bg = colors, col = colors, cex = 4.3)
      text(x, rep(y-4, 4), groups, col = "white", cex = 1.05)
    }
  }
}

draw_recruitment_funnel <- function() {
  old <- par(no.readonly = TRUE)
  on.exit(par(old))
  diagram_canvas()
  counts <- c(100, 40, 30, 15)
  labels <- c("Potentially relevant patients", "Meet eligibility criteria",
    "Available after competing studies\nand practical barriers", "Consent and enroll")
  colors <- c("#d1e9f4", "#aad5e8", "#79b6d1", "#367e9e")
  text(50, 96, "Expected recruitment each month", font = 2, cex = 1.12)
  for (i in seq_along(counts)) {
    top <- 88 - (i - 1) * 21
    # Width represents the remaining count; labels sit outside narrow stages.
    width <- 46 * counts[i] / 100
    next_width <- if (i < 4) 46 * counts[i + 1] / 100 else width
    polygon(c(27-width/2, 27+width/2, 27+next_width/2, 27-next_width/2),
      c(top, top, top-17, top-17), col = colors[i], border = "white", lwd = 2)
    text(27, top-7, counts[i], font = 2, cex = 1.2,
      col = if (i==4) "white" else "#17384b")
    text(54, top-8, labels[i], adj = 0, cex = 1)
    if (i < 4) diagram_arrow(27, top-17.5, 27, top-20)
  }
}

draw_treatment_followup <- function() {
  old <- par(no.readonly = TRUE)
  on.exit(par(old))
  diagram_canvas()
  diagram_box(23, 84, 77, 98, "Randomized to Neravixa or duloxetine",
    fill = "#e8f2f7", cex = 1.02)
  diagram_arrow(30, 84, 26, 77)
  diagram_arrow(70, 84, 74, 77)
  rect(2, 19, 50, 77, col = "#f1e8f7", border = "#72428b")
  rect(54, 19, 98, 77, col = "#e8f2f7", border = "#17658a")
  text(26, 72, "Events after assignment", font = 2, cex = 1.04)
  text(76, 72, "Outcome availability", font = 2, cex = 1.04)
  text(5, 60, paste(c("Failure to start; missed doses", "Interruptions or dose changes",
    "Permanent discontinuation", "Switching treatments", "Additional or rescue medication",
    "Death before the pain assessment"), collapse = "\n"), adj = c(0, .5), cex = .96)
  text(57, 55, "Missed assessments\nWithdrawal from follow-up\nUnusable measurements",
    adj = c(0, .5), cex = .96)
  text(26, 26, "Death makes the later pain\noutcome undefined.", cex = .94)
  diagram_arrow(26, 19, 26, 14)
  diagram_arrow(76, 19, 76, 14)
  text(26, 7, "Specify how events enter\nthe treatment comparison.", cex = .96)
  text(76, 7, "Plan follow-up, missing-data\nmethods and recruitment.", cex = .96)
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
