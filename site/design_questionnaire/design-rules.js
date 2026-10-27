/* Original teaching decision aid; software licensed under MIT. */
(function(root){
'use strict';
const fields = [
 ['aim','What is the main purpose of your study?',[
  ['treatment','Compare the effects of treatments or interventions'],['association','Study an association between an exposure and an outcome'],
  ['prevalence','Estimate how common a condition is at a defined time'],['incidence','Estimate new events or risk over time'],
  ['diagnostic','Evaluate a diagnostic test against a reference standard'],['prediction','Develop or evaluate predictions for individual patients'],
  ['feasibility','Assess whether a future study is feasible'],['qualitative','Understand experiences or processes'],['synthesis','Combine results from existing studies'],['unsure','I am still defining the question']]],
 ['data','Which data could you use?',[['new','Collect new data'],['existing','Use an existing dataset'],['mixed','Combine existing and new data'],['unsure','Not yet decided']]],
 ['structure','How are the observations related?',[['independent','One outcome per independent participant or unit'],['paired','Repeated or paired observations from the same people'],['clustered','People or units grouped within practices, wards, schools or cages'],['both','Repeated observations within clusters'],['unsure','Not yet clear']]],
 ['outcome','What is the primary outcome?',[['binary','An event: yes or no'],['continuous','A numerical measurement or score'],['time','Time until an event'],['count','Number of events'],['qualitative','Interview or other qualitative material'],['unsure','Not yet decided']]],
 ['allocation','Could researchers allocate the intervention?',[
  ['individual','Yes, randomize individual participants or independent units'],['cluster','Yes, randomize whole clusters'],['nonrandom','Yes, but allocation would not be randomized'],['observed','No, treatment or exposure is determined outside the study'],['unsure','Not yet decided']],['treatment']],
 ['comparison','How would treatments be compared?',[
  ['parallel','Different groups receive different treatments'],['crossover','The same people receive both treatments in successive periods'],['beforeafter','Measurements before and after one intervention'],['unsure','Not yet decided']],['treatment']],
 ['claim','What conclusion should the comparison support?',[
  ['superiority','Whether treatments differ (superiority)'],['noninferiority','Whether the new treatment is not worse by more than a justified margin'],['equivalence','Whether the difference lies within justified equivalence margins'],['unsure','Not yet decided']],['treatment']],
 ['crossover','Are the condition and effects suitable for a crossover comparison?',[
  ['yes','The condition is sufficiently stable, effects are reversible, and carryover can be controlled'],['no','One or more of these conditions is not met'],['unsure','This needs assessment']],['crossover']],
 ['sampling','How would participants be selected and outcomes assessed?',[
  ['cohort','Identify an eligible population and assess subsequent outcomes'],['casecontrol','Select people with and without the outcome, then assess earlier exposure'],['snapshot','Assess exposure and outcome at a defined time'],['unsure','Not yet decided']],['association']],
 ['reference','Is there a suitable reference standard for the target condition?',[
  ['yes','Yes, it can be applied appropriately to the study participants'],['no','No suitable reference standard is available'],['unsure','This needs assessment']],['diagnostic']],
 ['prediction','What will you do with the prediction model?',[
  ['develop','Develop a new model or update an existing model'],['validate','Evaluate an existing model in new patients'],['compare','Compare the predictive performance of different models or features'],['unsure','Not yet decided']],['prediction']]
];
function relevant(field,a){
 const scope=field[3];
 if(!scope) return !['qualitative','synthesis','unsure'].includes(a.aim) || ['aim','data'].includes(field[0]);
 if(field[0]==='sampling'&&a.aim==='treatment'&&a.allocation==='observed')return true;
 if(scope[0]==='crossover')return a.aim==='treatment'&&a.comparison==='crossover';
 return scope.includes(a.aim);
}
const links={
 chapter:['Chapter 8: design and planning guidance','../book/study-designs.html'],
 report:['Develop and justify your study plan','../study/?activity=assumptions_report'],
 binary:['Two independent groups: binary outcome','../two_proportions/'],
 means:['Two independent groups: continuous outcome','../two_means/'],
 prevalence:['Estimate a population percentage','../study/?activity=prevalence'],
 pilot:['Pilot retention and precision','../study/?activity=pilot_feasibility'],
 cdc:['CDC: cohort and case-control design considerations','https://www.cdc.gov/field-epi-manual/php/chapters/design-conduct-analyze-field-studies.html'],
 consort:['SPIRIT–CONSORT: trial protocol and reporting guidance','https://www.consort-spirit.org/'],
 strobe:['STROBE: observational reporting guidance','https://www.strobe-statement.org/'],
 stard:['Bossuyt et al. (2015): STARD diagnostic-accuracy reporting','https://www.bmj.com/content/351/bmj.h5527'],
 riley:['Riley et al. (2020): prediction-model development sample size','https://www.bmj.com/content/368/bmj.m441'],
 tripod:['TRIPOD+AI: prediction-model reporting guidance','https://www.tripod-statement.org/'],
 paired:['Candel and van Breukelen (2023): trial designs and efficient planning','https://doi.org/10.1016/j.ajcnut.2023.02.013'],
 cluster:['Hayes and Bennett (1999): cluster-randomized trial sample size','https://doi.org/10.1093/ije/28.2.319']
};
function recommend(a){
 a=Object.fromEntries(fields.filter(f=>relevant(f,a)).map(f=>[f[0],a[f[0]]]));
 const r={title:'A more specific research question would help',why:[],decisions:[],planning:[],resources:['chapter','report']};
 const clustered=['clustered','both'].includes(a.structure),paired=['paired','both'].includes(a.structure);
 const observational=()=>{
  const types={cohort:['Cohort study','You would identify a population and assess subsequent outcomes. Existing records can support a retrospective cohort when they establish this sequence.'],casecontrol:['Case-control study','Selection starts with outcome status, followed by assessment of earlier exposure. Controls should represent the population that produced the cases.'],snapshot:['Cross-sectional study','Exposure and outcome are assessed at a defined time. Establishing which came first may be difficult.']};
  if(types[a.sampling]){[r.title]=types[a.sampling];r.why.push(types[a.sampling][1]);}
  else {r.title='An observational comparison';r.decisions.push('A cohort follows an eligible population over time; a case-control study samples by outcome status; a cross-sectional study assesses a defined time. The sampling strategy should follow your question and available data.');}
  r.planning.push('Planning should match the association measure, event and exposure frequencies, confounder adjustment and intended analysis.');
  r.resources.push('cdc','strobe');
 };
 switch(a.aim){
 case 'treatment':
  if(a.allocation==='observed'){
   observational();r.title='Observational treatment comparison: '+r.title.toLowerCase();r.why.push('Treatment is determined outside the study. A cohort approach may suit a question about subsequent outcomes; eligibility and time zero should be comparable across groups.');
   r.decisions.push('Treatment selection and confounding need an explicit strategy. The sampling structure and timing determine the specific observational design.');r.resources.push('cdc','strobe');
  }else if(a.allocation==='nonrandom'){
   r.title='Nonrandomized intervention study';r.why.push('Researchers allocate the intervention without randomization.');r.decisions.push('A suitable concurrent comparison, controlled before–after design or interrupted time series may strengthen the design. The choice depends on the intervention, timing and available comparison data.');
  }else if(['individual','cluster'].includes(a.allocation)){
   r.title=a.allocation==='cluster'?'Cluster-randomized trial':'Individually randomized parallel-group trial';
   r.why.push(a.allocation==='cluster'?'Whole clusters would be randomized. Planning needs enough independent clusters.':'Random allocation can support a treatment-effect comparison when feasible, ethical and consistent with the intended question.');
   if(a.comparison==='crossover'){
    if(a.crossover==='yes'){r.title=a.allocation==='cluster'?'Cluster-randomized crossover trial':'Randomized crossover trial';r.why.push('The same participants or clusters receive treatments in successive periods. Treatment order should be randomized and period and carryover effects addressed.');}
    else {r.title='A parallel-group randomized trial may be more suitable';r.decisions.push('A crossover recommendation needs a sufficiently stable condition, reversible effects and adequate control of carryover. These requirements remain unresolved or are not met.');}
   }
   if(a.comparison==='beforeafter'){
    r.title='The proposed comparison and randomization need clarification';r.decisions.push('Before and after measurements alone do not define a randomized comparison. A concurrent randomized control group can help separate treatment effects from changes over time.');
   }
   r.resources.push('consort');
  }else {r.title='Treatment-comparison design still to be decided';r.decisions.push('Whether intervention allocation is feasible and ethical is the first decision. Randomization, observational comparison and nonrandomized intervention studies require different approaches to bias.');}
  if(['noninferiority','equivalence'].includes(a.claim)){r.planning.push(`${a.claim==='equivalence'?'Equivalence':'Noninferiority'} requires justified margins and a method matched to that hypothesis. The planned analysis should evaluate the specified margin directly.`);}
  else if(a.claim==='superiority')r.planning.push('A superiority comparison needs a justified target difference, outcome variability or event probabilities, and a planned analysis.');
  else r.decisions.push('The intended superiority, noninferiority or equivalence claim should be decided before selecting a calculation.');
  if(a.allocation==='individual'&&a.comparison==='parallel'&&a.structure==='independent'&&a.claim==='superiority'&&['binary','continuous'].includes(a.outcome)){
   r.planning.push('For exactly two independent groups with equal allocation, the corresponding core calculator offers a starting point under its stated analysis assumptions.');r.resources.push(a.outcome==='binary'?'binary':'means');
  }
  break;
 case 'association': observational();break;
 case 'prevalence':r.title='Cross-sectional prevalence study';r.why.push('The aim is to estimate the percentage with a condition at a defined time in a specified population.');r.decisions.push('Sampling and case definitions should support a representative estimate. Outcome-based case-control sampling does not directly estimate population prevalence.');r.planning.push('A desired confidence-interval width can guide sample size.');r.resources.push('strobe');if(a.structure==='independent'&&a.outcome==='binary')r.resources.push('prevalence');break;
 case 'incidence':r.title='Cohort study of incidence or risk';r.why.push('New events require an at-risk population and an observation period. A cohort can be assembled prospectively or from suitable existing records.');r.planning.push('Planning should account for event frequency, follow-up, censoring and the chosen measure: cumulative risk, incidence rate or time to event.');r.resources.push('cdc','strobe');break;
 case 'diagnostic':r.title='Diagnostic-accuracy study';r.why.push('The index test is compared with a reference assessment of the target condition in an appropriate clinical population.');if(a.reference!=='yes')r.decisions.push('The reference standard needs resolution before this design can provide interpretable sensitivity and specificity.');r.planning.push('Sensitivity requires enough reference-positive participants and specificity enough reference-negative participants. Sampling, verification and desired precision affect recruitment.');r.resources.push('stard');break;
 case 'prediction':r.title={develop:'Prediction-model development or updating study',validate:'External evaluation of a prediction model',compare:'Comparative prediction-model study'}[a.prediction]||'Prediction-model study';r.why.push('The aim concerns predictions for individuals. The target outcome, prediction time and intended population determine how data should be collected.');r.decisions.push('Predictors must be available at the intended prediction time. Development and evaluation data should avoid patient overlap; repeated recordings from one patient should stay together.');r.planning.push(a.prediction==='develop'?'Planning depends on candidate predictor parameters, outcome frequency, expected performance and overfitting.':'Planning should target precision of the intended performance measures; model comparisons on the same patients are paired.');r.resources.push('tripod');if(a.prediction==='develop')r.resources.push('riley');break;
 case 'feasibility':r.title='Pilot or feasibility study';r.why.push('Recruitment, retention, acceptability or another process is the primary objective. Randomization is useful when feasibility of trial procedures is part of the question.');r.planning.push('Prespecified feasibility outcomes, progression criteria and useful precision should guide the sample size.');r.resources.push('pilot');break;
 case 'qualitative':r.title='Qualitative study or mixed-methods component';r.why.push('Experiences and processes can be investigated through interviews, observations or other qualitative approaches.');r.planning.push('Sampling should fit the methodology, diversity of perspectives and information needed.');break;
 case 'synthesis':r.title='Evidence synthesis';r.why.push('A systematic review can organize existing evidence; meta-analysis is appropriate when studies and effect estimates can be combined meaningfully.');r.planning.push('The eligible evidence, heterogeneity, dependence between estimates and intended synthesis method determine what can be learned.');break;
 default:r.decisions.push('A clear population, question and intended outcome would allow a more informative design suggestion. PICO can help formulate a treatment-comparison question.');
 }
 if(a.data==='existing'||a.data==='mixed')r.decisions.push('Existing data should be checked for selection, relevant variables, timing, missingness and permission for the intended use. A fixed sample can be assessed for attainable precision.');
 if(clustered||a.allocation==='cluster') {r.planning.push('Cluster dependence should enter both analysis and sample size planning through the number and sizes of clusters and their within-cluster correlation.');r.resources.push('cluster');}
 if(paired||a.comparison==='crossover') {r.planning.push('Paired or repeated observations require their correlation to be reflected in the analysis and planning. The number of measurements differs from the number of independent participants.');r.resources.push('paired');}
 if(a.outcome==='qualitative'&&!['qualitative','synthesis','unsure'].includes(a.aim))r.decisions.push('Qualitative material may complement this study, but the quantitative outcome and intended comparison still need definition.');
 if(a.structure==='unsure')r.decisions.push('The independent unit and any paired or clustered observations still need to be identified.');
 if(['time','count'].includes(a.outcome))r.planning.push('The calculation should match the time-to-event or count analysis, follow-up and distributional assumptions.');
 if(['prevalence','incidence','diagnostic'].includes(a.aim)&&['continuous','qualitative'].includes(a.outcome))r.decisions.push('The stated aim needs a defined event or condition. Clarify whether the primary outcome should instead be a continuous measurement or a qualitative question.');
 r.resources=[...new Set(r.resources)];return r;
}
const api={fields,relevant,recommend,links};
if(typeof module!=='undefined'&&module.exports)module.exports=api;
else root.DesignQuestionnaire=api;
})(typeof window!=='undefined'?window:globalThis);
