const assert=require('node:assert/strict');
const {recommend,relevant,fields}=require('../site/design_questionnaire/design-rules.js');
const base={aim:'treatment',data:'new',structure:'independent',outcome:'binary',allocation:'individual',comparison:'parallel',claim:'superiority'};
const get=extra=>recommend({...base,...extra});
assert.match(get({}).title,/parallel-group/);assert(get({}).resources.includes('binary'));
assert(!get({claim:'noninferiority'}).resources.includes('binary'));
assert.match(get({allocation:'cluster',structure:'clustered'}).title,/Cluster/);
assert(!get({structure:'paired'}).resources.includes('binary'));
assert.match(get({comparison:'crossover',crossover:'yes',structure:'paired'}).title,/crossover/);
assert.match(get({comparison:'crossover',crossover:'no'}).title,/parallel-group/);
assert.match(get({comparison:'beforeafter'}).title,/clarification/);
for(const sampling of ['cohort','casecontrol','snapshot']){
 const r=get({aim:'association',sampling,data:'existing'});assert(r.resources.includes('cdc'));assert(!r.resources.includes('binary'));assert(!r.resources.includes('consort'));
}
assert.match(get({allocation:'observed',sampling:'casecontrol'}).title,/case-control/);
assert(get({aim:'diagnostic',reference:'no'}).decisions.some(x=>x.includes('reference standard')));
assert(get({aim:'prediction',prediction:'develop'}).resources.includes('riley'));
assert(!get({aim:'prediction',prediction:'validate'}).resources.includes('riley'));
assert(get({aim:'prevalence'}).resources.includes('prevalence'));
assert(!get({aim:'prevalence',structure:'clustered'}).resources.includes('prevalence'));
assert.match(get({aim:'incidence'}).title,/Cohort/);
assert.match(get({aim:'feasibility'}).title,/feasibility/);
assert.match(get({aim:'qualitative'}).title,/Qualitative/);
assert(!get({aim:'qualitative',comparison:'crossover',allocation:'cluster'}).resources.includes('cluster'));
assert.match(get({aim:'synthesis'}).title,/synthesis/);
assert(get({aim:'unsure'}).decisions.length);
assert(!relevant(fields.find(f=>f[0]==='crossover'),base));
console.log('Design rules passed: trial and observational branches, dependence, unresolved choices, tool eligibility, and hidden-answer exclusion.');
