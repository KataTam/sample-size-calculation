/* Original implementation for this tutorial. MIT licensed. */
(() => {
  let data, index = 0, elapsed = 0, last = 0, raf, paused = false, stale = false, generation = 0, drawnIndex = -1, frameProgress = 0;
  const el = id => document.getElementById(id);
  const ns = 'http://www.w3.org/2000/svg';
  const pct = x => `${Math.round(x * 1000) / 10}%`;
  const point = x => 45 + (x + 1) * 205;
  function node(svg, tag, attrs, text) {
    const n = document.createElementNS(ns, tag);
    Object.entries(attrs).forEach(([k,v]) => n.setAttribute(k,v));
    if (text !== undefined) n.textContent = text;
    svg.append(n); return n;
  }
  const pText = p => Number.isFinite(p) ? p<.001 ? '< 0.001' : '= '+Number(p.toPrecision(3)) : 'unavailable';
  // Red and green describe patient outcomes. Blue and amber describe trial decisions.
  const colors={pain:'#b83c46',relief:'#237747',correct:'#245e90',error:'#9b600e',
    correctFill:'#e2edf8',errorFill:'#f8e5bb',neutral:'#64748b'};
  const isNull=source=>Math.abs(source.p1-source.p0)<1e-10;
  const decisionCorrect=(source,reject)=>isNull(source)?!reject:reject;
  function decisionSummary(source,decisions) {
    const n=decisions.length,rejected=decisions.filter(Boolean).length;
    const fraction=k=>`${k}/${n} (${pct(k/n)})`;
    return isNull(source)?[
      `Falsely rejected H₀: ${fraction(rejected)} · false positives`,
      `Correctly did not reject H₀: ${fraction(n-rejected)} · true negatives`
    ]:[
      `Correctly rejected H₀: ${fraction(rejected)} · true positives`,
      `Failed to reject H₀: ${fraction(n-rejected)} · false negatives`
    ];
  }
  function interpretation(source,progress) {
    const t=source.trials[index],labels=source.labels||['Standard','Novel'];
    const truth=isNull(source);
    const first=`Trial ${index+1}: ${t.counts[0]} of ${source.n} patients achieved pain relief with ${labels[0]}, and ${t.counts[1]} of ${source.n} with ${labels[1]}. The estimated difference is ${Math.round(t.estimate*1000)/10} percentage points.`;
    if(!source.batch && source.trials.length===1)
      return first+` Its p value ${pText(t.p_value)}. `+(truth?
        (t.reject?'H₀ is falsely rejected: a false positive.':'H₀ is correctly not rejected: a true negative.'):
        (t.reject?'H₀ is correctly rejected: a true positive.':'H₀ is not rejected despite a population difference: a false negative.'));
    const trials=source.batch?source.batch.reject:source.trials.slice(0,index+1).map(t=>t.reject);
    const detected=trials.filter(Boolean).length;
    return `Across ${trials.length} trials with ${source.n} patients per group, `+
      `${detected} detect a difference (${pct(detected/trials.length)}) and ${trials.length-detected} do not (${pct(1-detected/trials.length)}). `+
      (truth?'These detections are false positives because the population relief percentages are equal.':
      'These detections are true positives. Their percentage across many trials estimates power at the selected population difference and sample size.')+
      (truth?` The planned Type I error probability is ${pct(source.alpha)}.`:` Calculated power for these assumptions is ${pct(source.expected)}.`)+
      (source.batch?' The patient figures show the first trial in this batch.':' The patient figures show the latest displayed trial.');
  }
  function draw(progress) {
    const host=el('sampling-journey');if(!host||!data)return;
    frameProgress=progress;
    host.classList.toggle('journey-comparison',!!data.comparison);
    host.replaceChildren();
    // Keep the null scenario on the left and the treatment difference on the right.
    const sources=[data,data.comparison].filter(Boolean).sort((a,b)=>Number(!isNull(a))-Number(!isNull(b)));
    for(const source of sources) {
      const panel=document.createElement('div');panel.className='journey-scenario';host.append(panel);
      drawInline(panel,progress,source);
    }
    if(el('journey-reading'))el('journey-reading').textContent=sources.map(source=>
      (data.comparison?(isNull(source)?'Equal relief probabilities. ':'Different relief probabilities. '):'')+interpretation(source,progress)).join(' ');
    drawnIndex=index;
  }
  const measureText = document.createElement('canvas').getContext('2d');
  function drawInline(host, progress, data) {
    // Native-size lettering and wrapped labels keep the chart readable in a
    // narrow chapter column. Both estimate axes always use the same scale.
    host.replaceChildren();
    const width=Math.max(250,Math.floor(Math.min(760, host.clientWidth))), t=data.trials[index];
    const labels=data.labels || ['Standard','Novel'], at=x=>38+(x+1)*(width-76)/2;
    const svg=node(host,'svg',{viewBox:`0 0 ${width} 500`,role:'img','aria-label':'Patient outcomes, estimated differences, p values and test decisions','data-population':data.p1});
    function text(text,x,y,available=width-24) {
      measureText.font='14px system-ui'; let line='';
      for(const word of text.split(' ')) {
        const next=line?line+' '+word:word;
        if(line && measureText.measureText(next).width>available) {
          node(svg,'text',{x,y,style:'font-size:14px'},line); y+=18; line=word;
        } else line=next;
      }
      node(svg,'text',{x,y,style:'font-size:14px'},line); return y;
    }
    const pain=data.event==='achieved pain relief', shown=Math.min(data.n,20);
    let y=text(isNull(data)?'H₀ true: equal population probabilities':'H₀ false: different population probabilities',12,22);
    y=text(pain?'Eligible population: all have neuropathic pain':'Eligible population before treatment',12,y+25);
    node(svg,'rect',{x:12,y:y+10,width:width-24,height:15,fill:pain?colors.pain:colors.neutral,'data-population-bar':'true'});
    y=text(pain?'100% have pain before treatment':'One outcome per participant',12,y+45);
    y=text(`Recruit ${2*data.n} patients · randomize 1:1`,12,y+24);
    node(svg,'path',{d:`M${width/2} ${y+8} v18 m-5 -6 l5 6 l5 -6`,fill:'none',stroke:colors.neutral,'stroke-width':1.5});
    y=text(`1. ${pain?'Four-week':'Patient'} outcomes · trial ${index+1} of ${data.batch ? data.batch.estimates.length : data.trials.length}`,12,y+48);
    const cols=Math.max(4,Math.min(10,Math.floor((width/2-24)/23))), rows=Math.ceil(shown/cols);
    const top=y+24;
    let groupBottom=top;
    [t.control,t.treatment].forEach((values,g)=>{
      const x=12+g*width/2;
      let groupY=text(labels[g],x,top,width/2-24);
      groupY=text(`Population: ${pct(g?data.p1:data.p0)} ${pain?'relief':'event'}`,x,groupY+20,width/2-24);
      groupY=text(`Trial: ${t.counts[g]}/${data.n} (${pct(t.counts[g]/data.n)})`,x,groupY+20,width/2-24);
      values.slice(0,shown).forEach((v,i)=>{
        const person=node(svg,'g',{transform:`translate(${x+9+(i%cols)*23} ${groupY+18+Math.floor(i/cols)*32})`,
          'data-patient':i+1,'data-group':g,'data-outcome':v?'relief':'pain',stroke:v?colors.relief:colors.pain,fill:'none','stroke-width':2.2,'stroke-linecap':'round'});
        node(person,'circle',{cx:0,cy:0,r:3.4,fill:v?colors.relief:colors.pain,stroke:'none'});
        node(person,'path',{d:`M0 3.4V17 M0 17L-5 26 M0 17L5 26 ${v?'M-6 5L0 11L6 5':'M-6 17L0 11L6 17'}`});
      });
      groupBottom=Math.max(groupBottom,groupY+18+rows*32);
    });
    y=text(`${data.n} patients per group`,12,groupBottom+10);
    y=text(pain?'Raised arms: pain relief. Arms down: no pain relief.':'Raised arms: event. Arms down: no event.',12,y+21);
    if(data.n>shown)y=text(`First ${shown} shown per group. Counts include everyone.`,12,y+21);
    node(svg,'path',{d:`M${width/2} ${y+8} v18 m-5 -6 l5 6 l5 -6`,fill:'none',stroke:'#64748b','stroke-width':2});
    y=text('2. Estimated difference in this trial',12,y+48);
    y=text(`${pct(t.counts[1]/data.n)} − ${pct(t.counts[0]/data.n)} = ${Math.round(t.estimate*1000)/10} percentage points`,12,y+22);
    const axis1=y+42;
    y=text(data.batch ? '3. Estimates across the full batch' : data.trials.length===1 ? '3. One trial contributes one estimate' : '3. Estimates from the repeated trials',12,axis1+50);
    y=text(data.batch ? `${data.batch.estimates.length} trials, each with ${data.n} patients per group` : 'Each dot is one trial. Both axes show percentage points.',12,y+22);
    const stackCounts={};
    data.trials.slice(0,index+1).forEach(t=>{const key=Math.round(t.estimate*1000000);stackCounts[key]=(stackCounts[key]||0)+1;});
    let axis2=y+Math.max(130,30+5*Math.max(...Object.values(stackCounts)));
    const bins={},positions=[];
    for(let i=0;i<=index;i++){
      const v=data.trials[i].estimate,key=Math.round(v*1000000),level=bins[key]||0;
      bins[key]=level+1;positions.push({x:at(v),y:axis2-10-level*5});
    }
    [axis1,axis2].forEach(yy=>{
      node(svg,'line',{x1:38,x2:width-38,y1:yy,y2:yy,stroke:'#64748b'});
      [-1,-.5,0,.5,1].forEach(v=>node(svg,'text',{x:at(v),y:yy+20,'text-anchor':'middle',style:'font-size:14px'},v*100));
      node(svg,'line',{x1:at(data.p1-data.p0),x2:at(data.p1-data.p0),y1:yy-(yy===axis1?8:95),y2:yy,stroke:'#17734c','stroke-dasharray':'4 3'});
    });
    const x=at(t.estimate);
    if(data.batch){
      const counts=values=>{const b=Array(40).fill(0);values.forEach(v=>b[Math.max(0,Math.min(39,Math.floor((v+1)/.05+1e-9)))]+=100/values.length);return b;};
      const current=counts(data.batch.estimates), ref=data.batch.reference;
      const previous=ref?counts(ref.estimates):null;
      const max=Math.max(...current,...(previous||[]),1)*1.1, yAt=v=>axis2-v/max*90;
      node(svg,'text',{x:12,y:axis2-110,style:'font-size:12px'},'Trials (%)');
      [0,Math.round(max/2),Math.round(max)].forEach(v=>node(svg,'text',{x:33,y:yAt(v)+4,'text-anchor':'end',style:'font-size:12px'},v));
      current.forEach((v,i)=>node(svg,'rect',{x:at(-1+i*.05),y:yAt(v),width:(width-76)/40,height:axis2-yAt(v),fill:'#b9d4f3',stroke:'#fff','data-batch-bin':i}));
      if(previous){
        let d=`M${at(-1)} ${axis2}`;
        previous.forEach((v,i)=>{d+=` L${at(-1+i*.05)} ${yAt(v)} L${at(-1+(i+1)*.05)} ${yAt(v)}`;});
        node(svg,'path',{d,fill:'none',stroke:'#725197','stroke-width':2,'stroke-dasharray':'5 3','data-reference-batch':ref.n});
      }
      node(svg,'line',{x1:at(data.p1-data.p0),x2:at(data.p1-data.p0),y1:axis2-95,y2:axis2,stroke:'#17734c','stroke-dasharray':'4 3','stroke-width':2});
      node(svg,'circle',{cx:x,cy:axis1,r:5,fill:'#b53c69'});
      node(svg,'circle',{cx:x,cy:axis2,r:5,fill:'#b53c69','data-batch-first-estimate':t.estimate});
      if(ref){
        y=text(`Blue bars: ${data.n} per group. Purple outline: ${ref.n} per group in the first batch.`,12,axis2+45);
        axis2=y;
      }
    }else{
      for(let i=0;i<index;i++)node(svg,'circle',{cx:positions[i].x,cy:positions[i].y,r:3,fill:'#546378','data-trial-estimate':i+1});
      const destination=positions[index].y;
      node(svg,'line',{x1:x,x2:x,y1:axis1,y2:destination,stroke:'#b53c69','stroke-width':2,'stroke-dasharray':'3 5',opacity:.45});
      node(svg,'path',{d:`M${x-5} ${destination-10} L${x} ${destination-3} L${x+5} ${destination-10}`,fill:'none',stroke:'#b53c69','stroke-width':2});
      [axis1,destination].forEach(yy=>node(svg,'circle',{cx:x,cy:yy,r:6,fill:'white',stroke:'#b53c69','stroke-width':2}));
      const phase=Math.max(0,Math.min(1,(progress-.35)/.5));
      const moving=el('journey-motion').checked?(progress<.85?0:1):phase*phase*(3-2*phase);
      node(svg,'circle',{cx:x,'data-moving-estimate':'true','data-motion-start':axis1,'data-motion-end':destination,cy:axis1+(destination-axis1)*moving,r:5,fill:'#b53c69',stroke:'white','stroke-width':1});
    }
    node(svg,'text',{x:Math.max(48,Math.min(width-48,x)),y:axis1-12,'text-anchor':'middle',style:'font-size:14px'},`${Math.round(t.estimate*1000)/10} points`);
    y=text(`Dashed line: assumed population difference ${Math.round((data.p1-data.p0)*1000)/10} points`,12,axis2+48);
    y=text(data.batch ? 'Pink dots: the first trial, included in this batch' : 'Pink dot: the current trial’s estimated difference',12,y+22);
    node(svg,'path',{d:`M${width/2} ${y+9} v20 m-5 -6 l5 6 l5 -6`,fill:'none',stroke:'#64748b','stroke-width':2});
    y=text('4. Does the test detect a difference?',12,y+57);
    const values=data.batch?data.batch.p_values:data.trials.slice(0,index+1).map(t=>t.p_value);
    const decisions=data.batch?data.batch.reject:data.trials.slice(0,index+1).map(t=>t.reject);
    const detected=decisions.filter(Boolean).length, px=p=>38+p*(width-76), cutoff=px(data.alpha);
    y=text(`Trial ${index+1}: p ${pText(t.p_value)}`,12,y+23);
    y=text(t.reject?'H₀ rejected: statistically significant difference':'H₀ not rejected',12,y+21);
    const pStacks={};values.forEach(p=>{const key=Math.round(p*1000);pStacks[key]=(pStacks[key]||0)+1;});
    const pAxis=y+(data.batch?150:Math.max(125,30+7*Math.max(...Object.values(pStacks))));
    node(svg,'rect',{x:38,y:pAxis-95,width:cutoff-38,height:95,fill:'#e4edf8'});
    if(data.batch) {
      const bins=Array(40).fill(0),correctBins=Array(40).fill(0);
      values.forEach((p,i)=>{if(Number.isFinite(p)){
        const bin=Math.min(39,Math.floor(p*40));bins[bin]++;
        if(decisionCorrect(data,decisions[i]))correctBins[bin]++;
      }});
      const max=Math.max(...bins,1);
      // A bin can cross the test cutoff. Its segments retain the actual decisions.
      bins.forEach((n,i)=>{
        const bar=node(svg,'g',{'data-pvalue-bin':i,'data-count':n});
        const good=correctBins[i],bad=n-good,bw=(width-76)/40;
        node(bar,'rect',{x:px(i/40),y:pAxis-good/max*80,width:bw,height:good/max*80,fill:colors.correct,stroke:'white'});
        node(bar,'rect',{x:px(i/40),y:pAxis-n/max*80,width:bw,height:bad/max*80,fill:colors.error,stroke:'white'});
      });
      text(`Highest bar: ${max} trials`,12,y+45);
    } else {
      const bins={};
      values.forEach((p,i)=>{if(!Number.isFinite(p))return;const key=Math.round(p*1000),level=bins[key]||0;bins[key]=level+1;
        node(svg,'circle',{cx:px(p),cy:pAxis-9-level*7,r:3.5,fill:decisionCorrect(data,decisions[i])?colors.correct:colors.error,'data-pvalue-trial':i+1,'data-pvalue':p});});
    }
    node(svg,'line',{x1:38,x2:width-38,y1:pAxis,y2:pAxis,stroke:'#64748b'});
    node(svg,'line',{x1:cutoff,x2:cutoff,y1:pAxis-97,y2:pAxis,stroke:'#245e90','stroke-dasharray':'4 3'});
    [0,.5,1].forEach(p=>node(svg,'text',{x:px(p),y:pAxis+19,'text-anchor':'middle',style:'font-size:14px'},p));
    y=text(`p-value cutoff: ${data.alpha}. Values below it reject the null hypothesis.`,12,pAxis+44);
    y=text(`Completed trials: ${values.length}`,12,y+24);
    for(const line of decisionSummary(data,decisions))y=text(line,12,y+23);
    y=text(isNull(data)?`Planned Type I error probability: ${pct(data.alpha)}`:`Calculated power at this sample size: ${pct(data.expected)}`,12,y+23);
    const tiles=decisions.slice(-100),tileCols=10,tileWidth=(width-24)/tileCols,tileHeight=23;
    y=text(tiles.length<decisions.length?'Latest 100 trial decisions · one tile per trial':'One tile represents one complete trial',12,y+28);
    tiles.forEach((reject,i)=>{
      const correct=decisionCorrect(data,reject),tx=12+(i%tileCols)*tileWidth,ty=y+12+Math.floor(i/tileCols)*tileHeight;
      const tile=node(svg,'g',{'data-decision-trial':decisions.length-tiles.length+i+1,'data-correct':String(correct)});
      node(tile,'rect',{x:tx,y:ty,width:tileWidth-3,height:tileHeight-3,fill:correct?colors.correctFill:colors.errorFill});
      node(tile,'text',{x:tx+(tileWidth-3)/2,y:ty+15,'text-anchor':'middle',style:`fill:${correct?colors.correct:colors.error};font-size:15px`},correct?'○':'×');
    });
    y+=12+Math.ceil(tiles.length/tileCols)*tileHeight;
    y=text('○ Correct decision     × Error',12,y+23);
    svg.setAttribute('viewBox',`0 0 ${width} ${y+14}`);
  }
  function status() {
    if(data.batch){
      el('journey-description').textContent=`The patient outcomes belong to the first of ${data.batch.estimates.length} trials in this batch. All trials used ${data.n} patients per group.`;
      el('journey-status').textContent=`${data.batch.estimates.length} trials; ${data.n} patients per group. ${stale?'Inputs changed. Run again to update.':''}`;
      return;
    }
    const t = data.trials[index];
    const labels = data.labels || ['Standard treatment', 'Novel treatment'];
    el('journey-description').textContent = `${labels[0]}: ${t.counts[0]} of ${data.n} patients (${pct(t.counts[0]/data.n)}); ${labels[1]}: ${t.counts[1]} of ${data.n} (${pct(t.counts[1]/data.n)}). The estimated between-group difference is ${Math.round(t.estimate*1000)/10} percentage points. This estimate becomes dot ${index+1} in the sampling distribution. The assumed population difference stays at ${Math.round((data.p1-data.p0)*1000)/10} percentage points.`;
    el('journey-status').textContent = `${paused?'Paused. ':''}Trial ${index+1} of ${data.trials.length}; ${data.n} patients per group. ${stale?'Inputs changed; this sequence retains its saved assumptions. Run again to update.':''}`;
  }
  const duration=()=>el('journey-motion').checked?45:el('journey-speed')?.value==='fast'?1100:3200;
  function moveEstimate(progress) {
    frameProgress=progress;
    const phase=Math.max(0,Math.min(1,(progress-.35)/.5));
    const moving=el('journey-motion').checked?(progress<.85?0:1):phase*phase*(3-2*phase);
    el('sampling-journey').querySelectorAll('[data-moving-estimate]').forEach(dot=>{
      const start=Number(dot.dataset.motionStart),end=Number(dot.dataset.motionEnd);
      dot.setAttribute('cy',start+(end-start)*moving);
    });
  }
  function tick(now,token) {
    if(!data || paused || token!==generation)return;
    if(last)elapsed+=now-last;last=now;
    if(elapsed>=duration()) {
      if(index<data.trials.length-1){index++;elapsed=0;status();}
      else {elapsed=duration();draw(1);el('journey-pause').disabled=true;el('journey-finish').disabled=true;return;}
    }
    if(drawnIndex!==index)draw(elapsed/duration());else moveEstimate(elapsed/duration());
    raf=requestAnimationFrame(now=>tick(now,token));
  }
  function stop(){generation++;cancelAnimationFrame(raf);last=0;}
  function play(){stop();drawnIndex=-1;paused=false;el('journey-finish').disabled=false;el('journey-pause').textContent='Pause';el('journey-pause').disabled=false;status();const token=generation;raf=requestAnimationFrame(now=>tick(now,token));}
  function clear(){stop();data=null;index=0;elapsed=0;paused=false;stale=false;el('sampling-journey').replaceChildren();el('sampling-journey').classList.remove('journey-comparison');el('journey-description').textContent='';el('journey-reading').textContent='Patient outcomes produce an estimated difference and a p value. Repeated trials show how often the test detects a difference.';['journey-pause','journey-replay','journey-finish'].forEach(id=>el(id).disabled=true);el('journey-pause').textContent='Pause';el('journey-status').textContent='Simulation results cleared. The population and sample settings are retained.';}
  window.addEventListener('resize',()=>{if(data)draw(data.batch?1:Math.min(1,elapsed/duration()));});
  function setup() {
    if(!window.Shiny || !el('journey-pause')) return setTimeout(setup,100);
    el('journey-motion').checked=matchMedia('(prefers-reduced-motion: reduce)').matches;
    el('journey-pause').onclick=()=>{paused=!paused;el('journey-pause').textContent=paused?'Resume':'Pause';if(paused){stop();status();}else play();};
    el('journey-replay').onclick=()=>{if(!data||data.batch)return;index=0;elapsed=0;play();};
    el('reset_trials').addEventListener('click',clear);
    const changePlayback=()=>{elapsed=frameProgress*duration();last=0;if(data)draw(data.batch?1:frameProgress);};
    el('journey-motion').onchange=changePlayback;
    el('journey-speed').onchange=changePlayback;
    el('journey-finish').onclick=()=>{if(!data || data.batch)return;stop();index=data.trials.length-1;elapsed=duration();paused=false;draw(1);status();el('journey-pause').disabled=true;el('journey-finish').disabled=true;};
    Shiny.addCustomMessageHandler('lab-report-context',payload=>{
      document.documentElement.classList.toggle('unified-sampling',payload.core);
      el('report-question-heading').textContent='Explain your decision';
      el('study-plan-guidance').hidden=payload.core;
      const field=el('justification'), label=document.querySelector('label[for="justification"]');
      const source=document.querySelector('.input-guidance-source[data-for="justification"]');
      if(label && field && source){
        label.textContent=payload.question;source.textContent=payload.help;
        window.InputGuidance?.attach(label,payload.help,field,source.dataset.model || '');
      }
    });
    Shiny.addCustomMessageHandler('lab-mode',payload=>{
      document.documentElement.classList.toggle('single-population-mode',payload.estimation);
      const title=document.querySelector('.app-title'),intro=document.querySelector('.app-intro');
      if(payload.estimation){
        if(title)title.textContent='Estimate one population';
        if(intro)intro.textContent='Choose a confidence interval width for a population mean or percentage, then explore repeated samples.';
      }else{
        if(title)title.textContent=document.documentElement.classList.contains('pain-focus')?'Pain relief: one trial and repeated trials':'Sample size reasoning lab';
        if(intro)intro.textContent='Explore how trial results vary with the sample size and population assumptions.';
      }
    });
    Shiny.addCustomMessageHandler('lab-advanced',payload=>{
      document.documentElement.classList.toggle('lab-expanded',payload.enabled);
    });
    Shiny.addCustomMessageHandler('combine-pain-panels',payload=>{
      const oneLink=document.querySelector('a[data-value="One study"]'), manyLink=document.querySelector('a[data-value="Many studies"]');
      if(!oneLink || !manyLink) return;
      document.documentElement.classList.toggle('pain-focus', payload.combine);
      const title=document.querySelector('.app-title'), intro=document.querySelector('.app-intro');
      const estimating=document.documentElement.classList.contains('single-population-mode');
      if(title) title.textContent=estimating?'Estimate one population':payload.combine?'Pain relief: one trial and repeated trials':'Sample size reasoning lab';
      if(intro) intro.textContent=estimating?'Choose a confidence interval width for a population mean or percentage, then explore repeated samples.':payload.combine
        ?'Follow patients through a simulated trial, then compare repeated trials under equal and different population relief probabilities.'
        :'You can calculate sample size or assess power and precision for two-group comparisons, then simulate trials to see how results vary.';
      document.documentElement.classList.toggle('lab-expanded', Boolean(el('show_advanced')?.checked));
      ['Explore assumptions','Compare assumptions','My study'].forEach(value=>{
        const link=document.querySelector(`a[data-value="${value}"]`);if(link)link.parentElement.classList.add('lab-secondary-view');
      });
      const picker=document.querySelector('.activity-picker');
      if(picker && !picker.closest('details')){
        const options=document.createElement('details');options.className='lab-activity-options';
        const summary=document.createElement('summary');summary.textContent='Other prepared activities';
        picker.before(options);options.append(summary,picker);
      }
      const onePanel=document.querySelector(oneLink.getAttribute('href')), manyPanel=document.querySelector(manyLink.getAttribute('href'));
      let combined=el('combined-many-studies');
      if(payload.combine && !combined){
        combined=document.createElement('details');combined.id='combined-many-studies';combined.className='activity-details';
        const summary=document.createElement('summary');summary.textContent='Results and downloads for repeated trials';
        const content=document.createElement('div');content.className='combined-content';content.append(...manyPanel.childNodes);
        combined.append(summary,content);onePanel.append(combined);
        onePanel.querySelector('.simulation-actions').append(el('run_many'));
        onePanel.querySelector('h3').textContent='One trial and repeated trials';
        const credit=el('journey-credit');if(credit)onePanel.append(credit);
      } else if(!payload.combine && combined){
        manyPanel.append(...combined.querySelector('.combined-content').childNodes);
        manyPanel.querySelector('h3').after(el('run_many'));combined.remove();
        onePanel.querySelector('h3').textContent='One simulated trial';
      }
      oneLink.textContent=payload.combine?'One trial and repeated trials':'One trial';
      manyLink.parentElement.hidden=payload.combine;
      manyLink.parentElement.style.display=payload.combine?'none':'';
      // Playback stays on its own row in both embedded and dedicated views.
      const pValues=el('p_values')?.closest('details');if(pValues)pValues.classList.add('legacy-p-values');

    });
    Shiny.addCustomMessageHandler('sampling-journey',payload=>{
      stop();
      if(payload.clear){clear();return;}
      data=payload;index=0;elapsed=0;stale=false;el('journey-finish').textContent=data.trials.length===1?'Finish trial':'Finish this batch';el('journey-replay').disabled=false;document.documentElement.classList.remove('journey-batch-view');play();
    });
    Shiny.addCustomMessageHandler('sampling-batch',payload=>{
      stop();data=payload;index=0;elapsed=0;paused=false;stale=false;
      ['journey-pause','journey-replay','journey-finish'].forEach(id=>el(id).disabled=true);
      document.documentElement.classList.add('journey-batch-view');
      draw(1);status();
      const results=el('combined-many-studies');if(results)results.open=true;
      window.dispatchEvent(new Event('resize'));
    });
    $(document).on('shiny:inputchanged', event => {
      if(data && ['pain_population','compare_populations','fixed_n','plan_p0','plan_p1','goal','target_power','alpha','reality','true_p0','true_p1','seed','outcome','width_p'].includes(event.name)){stale=true;status();}
    });
  }
  setup();
})();
