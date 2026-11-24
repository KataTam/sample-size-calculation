/* Shared teaching answers for the app and Example 3.1. CC BY-SA 4.0. */
window.PainReportExample = {
  "sections": [
    [
      "Question and design",
      [
        [
          "question",
          "Research question"
        ],
        [
          "population",
          "Population"
        ],
        [
          "intervention",
          "Intervention or exposure"
        ],
        [
          "comparator",
          "Comparator"
        ],
        [
          "outcome_detail",
          "Primary outcome and time point"
        ],
        [
          "design",
          "Design, sampling and allocation"
        ]
      ]
    ],
    [
      "Assumptions and evidence",
      [
        [
          "scale",
          "Effect scale and direction of benefit"
        ],
        [
          "expected",
          "Difference observed in previous data"
        ],
        [
          "clinical",
          "Clinically important difference (clinical threshold)"
        ],
        [
          "planning",
          "Target difference: used in the calculation"
        ],
        [
          "variation",
          "Variation or event probabilities"
        ],
        [
          "evidence_review",
          "Evidence relevance and uncertainty"
        ],
        [
          "sensitivity",
          "Sensitivity analysis: alternative assumptions"
        ]
      ]
    ],
    [
      "Calculation",
      [
        [
          "analysis",
          "Planned analysis"
        ],
        [
          "software",
          "Calculation procedure and software"
        ],
        [
          "power",
          "Type I error probability and target power"
        ],
        [
          "counts",
          "Sample size needed or available for analysis"
        ]
      ]
    ],
    [
      "Recruitment and conclusion",
      [
        [
          "recruitment",
          "Losses, missing data and recruitment"
        ],
        [
          "resources",
          "Feasibility and resources"
        ],
        [
          "conclusion",
          "Intended conclusion and limitations"
        ]
      ]
    ]
  ],
  "answers": {
    "question": "Does neravixa increase the percentage achieving pain relief at four weeks compared with duloxetine in adults with painful diabetic peripheral neuropathy?",
    "population": "Adults with type 1 or type 2 diabetes mellitus, bilateral lower-extremity pain due to diabetic peripheral neuropathy for at least one year, and BMI at least 18 and below 40 kg/m².",
    "intervention": "neravixa, the fictional novel treatment in this teaching case, requires four additional safety-monitoring visits and carries a risk of short-lived dizziness. The protocol should specify its regimen and permitted background care.",
    "comparator": "Duloxetine, the standard treatment, over four weeks. The protocol should specify its regimen and the background care permitted in both groups.",
    "outcome_detail": "Achieved measurable pain relief at four weeks: yes or no, assessed in the same way in both groups and summarized as the percentage achieving pain relief.",
    "design": "Eligible adults will be recruited from participating clinics using [selection method] and individually randomized 1:1 to neravixa or duloxetine. Each participant contributes one four-week outcome. Outcomes from different participants are assumed independent.",
    "scale": "The difference in pain-relief percentages, neravixa minus duloxetine, in percentage points. A positive difference favors neravixa.",
    "expected": "40 percentage points: the pilot observed relief in 7 of 10 patients (70%) versus 3 of 10 (30%). The small groups make this estimate uncertain.",
    "clinical": "20 percentage points: one additional patient with relief per five treated. In this teaching case, patient and clinical advisers judge this the minimum benefit to justify four additional safety-monitoring visits and the risk of short-lived dizziness.",
    "planning": "30 percentage points, selected as a clinically worthwhile difference below the 40-point pilot estimate to allow for uncertainty in that small study.",
    "variation": "30% pain relief with duloxetine and 60% with neravixa.",
    "evidence_review": "The small pilot leaves both relief percentages uncertain. Evidence appraisal should compare pain severity, background medication and relief definitions across four-week studies, including less favorable findings.",
    "sensitivity": "Sensitivity analysis will assess power at 20-, 30-, and 40-point benefits with the sample fixed, then vary standard-treatment relief over an evidence-supported range.",
    "progression": "Retention at four weeks would inform feasibility. The proceed, amend, and stop thresholds remain to be agreed before data collection.",
    "analysis": "A two-sided pooled score test for independent proportions without continuity correction.",
    "software": "The normal approximation in stats::power.prop.test(), with a two-sided test and strict = TRUE. Software versions are recorded with the calculation.",
    "power": "A 5% Type I error probability and 90% target power at the stated target difference.",
    "precision": "A 95% interval with full width 20 percentage points gives a margin of about 10 points. Its clinical usefulness remains to be justified.",
    "counts": "The calculated 55.68382 patients per group is rounded upward to 56, giving 112 analyzable patients in total.",
    "recruitment": "With illustrative 5% unavailable primary outcomes, 56 / 0.95 rounds up to 59 per group (118 total). The loss assumption needs evidence, and the analysis plan should address missing outcomes and treatment changes.",
    "resources": "Screening records suggest 100 potentially relevant patients per month: 40 eligible, 30 available after competing studies and practical barriers, and half consenting. At 15 recruits per month, 118 recruits require about eight months. The plan also allows for site-opening delays.",
    "conclusion": "The planned test evaluates whether pain-relief percentages differ between treatments. Power is lower if the true difference is smaller than the target difference, including at the clinical threshold."
  }
};
