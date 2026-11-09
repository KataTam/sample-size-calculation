(() => {
  'use strict';
  const $ = id => document.getElementById(id);
  let bank, current = [], missed = [], orders={}, restoring=false, submitted=false;
  const storageKey='sample-size-cumulative-quiz-v2';
  const shuffle=values=>{for(let i=values.length-1;i>0;i--){const j=Math.floor(Math.random()*(i+1));[values[i],values[j]]=[values[j],values[i]]}return values;};
  function save(){if(restoring||!bank||!current.length)return;try{localStorage.setItem(storageKey,JSON.stringify({version:JSON.stringify(bank),chapter:chapter.value,route:route.value,ids:current.map(q=>q.id),orders,answers:Object.fromEntries(new FormData($('quiz'))),submitted}));}catch(_) {}}

  const chapter = $('chapter'), route = $('route');
  const selected = () => bank.questions.filter(q => (chapter.value === 'all' || q.chapter === chapter.value) && (route.value === 'all' || q.level === 'core'));
  function describe() {
    const questions = selected();
    $('start').disabled = questions.length === 0;
    $('coverage').textContent = questions.length
      ? `${questions.length} questions · ${route.options[route.selectedIndex].text}`
      : 'This chapter contains advanced questions. The Core + advanced route includes its chapter check.';
    $('coverage-topics').replaceChildren(...[...new Set(questions.map(q=>bank.chapters[q.chapter]))].map(text=>element('li',text)));

  }
  function element(tag, text, className) {
    const node = document.createElement(tag);
    if (text !== undefined) node.textContent = text;
    if (className) node.className = className;
    return node;
  }
  function start(questions, retry = false, saved = null) {
    current = questions; missed = []; submitted=false;orders=saved?.orders||{};
    $('setup').hidden = true; $('results').hidden = true; $('quiz').hidden = false;
    $('status').textContent = '';
    $('quiz-title').textContent = retry ? 'Retry missed questions' : chapter.value === 'all' ? `Cumulative quiz: ${route.options[route.selectedIndex].text}` : bank.chapters[chapter.value];
    $('questions').replaceChildren();
    questions.forEach((q, index) => {
      const box = element('fieldset',undefined,'quiz-question'); box.dataset.question = q.id;
      box.append(element('legend', `${index + 1}. ${q.question}`), element('p', `${bank.chapters[q.chapter]} · ${q.level === 'core' ? 'Core' : 'Advanced'}`, 'quiz-level ' + q.level));
      if (q.figure) {
        const figure=element('figure',undefined,'quiz-figure'), img=element('img');
        img.src='figures/'+q.figure.file;img.alt=q.figure.alt;
        figure.append(img,element('figcaption',q.figure.caption));box.append(figure);
      }
      orders[q.id] ||= shuffle(q.options.map((_,i)=>i));
      orders[q.id].forEach((option,position) => {
        const text=q.options[option];
        const label = element('label', undefined, 'quiz-option');
        const radio = element('input'); radio.type = 'radio'; radio.name = q.id; radio.value = option; radio.required = true;radio.checked=String(saved?.answers?.[q.id])===String(option);
        label.append(radio, element('span', `${String.fromCharCode(65+position)}. ${text}`)); box.append(label);
      });
      $('questions').append(box);
    });
    progress(); save(); $('quiz-title').focus();
  }
  function progress() {
    const answered=$('quiz').querySelectorAll('input:checked').length;
    $('progress').textContent = `${answered} of ${current.length} answered.`;
    $('quiz-progress-bar').max=current.length;$('quiz-progress-bar').value=answered;
  }
  $('quiz').addEventListener('change',()=>{progress();save();});
  const restart=element('button','Restart quiz');restart.type='button';restart.className='secondary';restart.addEventListener('click',()=>{if(confirm('Restart this quiz and clear its answers?'))start(selected());});$('quiz').append(restart);
  $('quiz').addEventListener('submit', event => {
    event.preventDefault();
    if(!$('quiz').reportValidity())return;
    const answers = new FormData($('quiz')), topics = {};
    let correct = 0;
    $('review').replaceChildren(); $('topics').replaceChildren(); missed = [];
    current.forEach((q, index) => {
      const choice = Number(answers.get(q.id)), right = choice === q.answer;
      if (right) correct++; else missed.push(q);
      topics[q.chapter] ||= {correct:0, total:0};
      topics[q.chapter].total++; topics[q.chapter].correct += Number(right);
      const item = element('details', undefined, 'quiz-answer' + (right ? '' : ' quiz-incorrect'));item.open=!right;
      const summary=element('summary',`${index+1}. ${q.question}`);summary.append(element('span',right?'Correct':'Needs review','quiz-answer-status'));item.append(summary);
      item.append(
        element('p', `${right ? 'Correct' : 'Incorrect'}. Your answer: ${q.options[choice]}`),
        element('p', `Correct answer: ${q.options[q.answer]}`), element('p', q.explanation));
      if(q.feedback){if(!right)item.append(element('p',q.feedback[choice]));const detail=element('details');detail.append(element('summary','Other answer options'));q.options.forEach((text,i)=>{if(i!==q.answer&&i!==choice)detail.append(element('p',text+': '+q.feedback[i]));});item.append(detail);}
      const link = element('a', `Review: ${q.section}`); link.href = '../book/' + q.link; link.target = '_blank'; link.rel = 'noopener';
      item.append(link); $('review').append(item);
    });
    for (const [key, result] of Object.entries(topics)) {
      const row = element('tr'); row.append(element('th', bank.chapters[key]), element('td', `${result.correct} / ${result.total}`)); row.firstChild.scope = 'row'; $('topics').append(row);
    }
    $('score').textContent = `${correct} of ${current.length} correct (${Math.round(100 * correct / current.length)}%).`;
    $('retry').hidden = missed.length === 0;
    $('quiz').hidden = true; $('results').hidden = false; $('results-title').focus();submitted=true;save();
  });
  $('start').addEventListener('click', () => start(selected()));
  $('retry').addEventListener('click', () => start([...missed], true));
  $('again').addEventListener('click', () => {
    $('results').hidden = true; $('setup').hidden = false; describe(); chapter.focus();
  });
  chapter.addEventListener('change', () => {
    if (chapter.value !== 'all' && !bank.questions.some(q => q.chapter === chapter.value && q.level === 'core')) route.value = 'all';
    describe();
  });
  route.addEventListener('change', describe);
  fetch('questions.json').then(r => {
    if (!r.ok) throw Error('Question bank unavailable');
    return r.json();
  }).then(data => {
    bank = data;
    for (const [value, text] of Object.entries(bank.chapters)) {
      const option = element('option', text); option.value = value; chapter.append(option);
    }
    const requested = new URLSearchParams(location.search).get('chapter');
    if (requested && bank.chapters[requested]) chapter.value = requested;
    if (chapter.value !== 'all' && !bank.questions.some(q => q.chapter === chapter.value && q.level === 'core')) route.value = 'all';
    $('status').textContent = ''; describe();
    try {
      const saved=JSON.parse(localStorage.getItem(storageKey)||'null');
      if(saved && saved.version===JSON.stringify(bank) && (!requested||requested===saved.chapter)){
        const qs=saved.ids.map(id=>bank.questions.find(q=>q.id===id));
        if(qs.length&&qs.every(q=>q&&Array.isArray(saved.orders[q.id])&&saved.orders[q.id].length===q.options.length&&new Set(saved.orders[q.id]).size===q.options.length&&saved.orders[q.id].every(i=>Number.isInteger(i)&&i>=0&&i<q.options.length))){
          restoring=true;chapter.value=saved.chapter;route.value=saved.route;start(qs,false,saved);
          if(saved.submitted)$('quiz').dispatchEvent(new Event('submit',{cancelable:true}));
          restoring=false;$('status').textContent='Your previous attempt has been restored. Restart quiz begins a new attempt.';
        }
      }
    }catch(_){restoring=false;}

  }).catch(() => { $('status').textContent = 'The questions could not load. Please reload the page to try again.'; });
})();
