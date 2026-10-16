/* Original implementation for this tutorial. MIT licensed. */
(() => {
  let data, index = 0, elapsed = 0, last = 0, raf, paused = false, stale = false;
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
  function draw(progress) {
    const host = el('sampling-journey'); if (!host || !data) return;
    host.replaceChildren();
    const svg = node(host,'svg',{viewBox:'0 0 500 490',role:'img','aria-label':'Patient outcomes, estimated difference and accumulated trial estimates'});
    const t = data.trials[index], reduced = el('journey-motion').checked;
    const counts = t.counts;
    node(svg,'text',{x:15,y:23},`Assumed population: standard ${pct(data.p0)}; novel ${pct(data.p1)}`);
    node(svg,'text',{x:15,y:47},`Trial ${index+1} of ${data.trials.length} · ${data.n} patients per group`);
    [t.control,t.treatment].forEach((values,g) => {
      const x0 = 20 + g*245, color = g ? '#984b87' : '#19738c';
      node(svg,'text',{x:x0,y:73},`${g?'Novel':'Standard'}: ${counts[g]}/${data.n} (${pct(counts[g]/data.n)})`);
      values.slice(0,80).forEach((v,i) => node(svg,'circle',{
        cx:x0+7+(i%16)*13,cy:94+Math.floor(i/16)*16,r:4.5,
        fill:v?color:'white',stroke:color,'stroke-width':1.5}));
    });
    if(data.n>80) node(svg,'text',{x:15,y:180},'First 80 patient outcomes shown per group; counts include everyone.');
    node(svg,'text',{x:15,y:207},`Estimated difference: ${pct(counts[1]/data.n)} − ${pct(counts[0]/data.n)}`);
    node(svg,'text',{x:15,y:230},`= ${Math.round(t.estimate*1000)/10} percentage points (novel − standard)`);
    [270,435].forEach(y => {
      node(svg,'line',{x1:45,x2:455,y1:y,y2:y,stroke:'#64748b'});
      [-1,-.5,0,.5,1].forEach(v => node(svg,'text',{x:point(v),y:y+19,'text-anchor':'middle'},v*100));
    });
    node(svg,'text',{x:15,y:315},'Distribution of estimated differences across these trials');
    const bins = {}, positions=[];
    for(let i=0;i<=index;i++) {
      const v=data.trials[i].estimate, key=Math.round(v*1000000);
      const level=bins[key]||0;bins[key]=level+1;
      positions.push({x:point(v),y:425-level*5});
    }
    for(let i=0;i<index;i++) node(svg,'circle',{cx:positions[i].x,cy:positions[i].y,r:3,fill:'#546378'});
    const truth=point(data.p1-data.p0);
    node(svg,'line',{x1:truth,x2:truth,y1:325,y2:435,stroke:'#17734c','stroke-dasharray':'4 3'});
    node(svg,'text',{x:15,y:480},`Dashed line: assumed population difference ${Math.round((data.p1-data.p0)*1000)/10} points`);
    const phase = Math.max(0,Math.min(1,(progress-.35)/.5));
    const moving = reduced ? (progress<.85?0:1) : phase*phase*(3-2*phase);
    node(svg,'circle',{cx:point(t.estimate),cy:270+(positions[index].y-270)*moving,r:5,fill:'#b53c69',stroke:'#fff','stroke-width':1});
  }
  function status() {
    el('journey-status').textContent = `${paused?'Paused. ':''}Trial ${index+1} of ${data.trials.length}; seed ${data.seed}; ${data.n} patients per group. ${stale?'Inputs changed; this sequence retains its saved assumptions. Run again to update.':''}`;
  }
  function tick(now) {
    if(!data || paused) return;
    if(last) elapsed+=now-last;last=now;
    if(elapsed>=2400) {
      if(index<data.trials.length-1){index++;elapsed=0;status();}
      else {draw(1);el('journey-pause').disabled=true;return;}
    }
    draw(elapsed/2400);raf=requestAnimationFrame(tick);
  }
  function play(){cancelAnimationFrame(raf);last=0;paused=false;el('journey-pause').textContent='Pause';el('journey-pause').disabled=false;status();raf=requestAnimationFrame(tick);}
  function setup() {
    if(!window.Shiny || !el('journey-pause')) return setTimeout(setup,100);
    el('journey-motion').checked=matchMedia('(prefers-reduced-motion: reduce)').matches;
    el('journey-pause').onclick=()=>{paused=!paused;el('journey-pause').textContent=paused?'Resume':'Pause';if(paused){cancelAnimationFrame(raf);status();}else play();};
    el('journey-replay').onclick=()=>{index=0;elapsed=0;play();};
    el('journey-motion').onchange=()=>{if(data)draw(elapsed/2400);};
    Shiny.addCustomMessageHandler('sampling-journey',payload=>{
      cancelAnimationFrame(raf);
      if(payload.clear){data=null;el('sampling-journey').replaceChildren();el('journey-pause').disabled=true;el('journey-replay').disabled=true;el('journey-status').textContent='A single study or 20-trial sequence will appear here after simulation.';return;}
      data=payload;index=0;elapsed=0;stale=false;el('journey-replay').disabled=false;play();
    });
    $(document).on('shiny:inputchanged', event => {
      if(data && ['fixed_n','plan_p0','plan_p1','goal','target_power','alpha','reality','true_p0','true_p1','seed','outcome','width_p'].includes(event.name)){stale=true;status();}
    });
  }
  setup();
})();
