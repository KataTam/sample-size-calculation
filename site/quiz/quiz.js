(() => {
  'use strict';
  const $ = id => document.getElementById(id);
  let bank, current = [], missed = [];
  const chapter = $('chapter'), route = $('route');
  const selected = () => bank.questions.filter(q => (chapter.value === 'all' || q.chapter === chapter.value) && (route.value === 'all' || q.level === 'core'));
  function describe() {
    const questions = selected();
    $('start').disabled = questions.length === 0;
    $('coverage').textContent = questions.length
      ? `${questions.length} questions. Covers ${[...new Set(questions.map(q => bank.chapters[q.chapter]))].join('; ')}.`
      : 'This chapter contains advanced questions. The Core + advanced route includes its chapter check.';
  }
  function element(tag, text, className) {
    const node = document.createElement(tag);
    if (text !== undefined) node.textContent = text;
    if (className) node.className = className;
    return node;
  }
  function start(questions, retry = false) {
    current = questions; missed = [];
    $('setup').hidden = true; $('results').hidden = true; $('quiz').hidden = false;
    $('status').textContent = '';
    $('quiz-title').textContent = retry ? 'Retry missed questions' : chapter.value === 'all' ? `Cumulative quiz: ${route.options[route.selectedIndex].text}` : bank.chapters[chapter.value];
    $('questions').replaceChildren();
    questions.forEach((q, index) => {
      const box = element('fieldset'); box.dataset.question = q.id;
      box.append(element('legend', `${index + 1}. ${q.question}`), element('p', `${bank.chapters[q.chapter]} · ${q.level === 'core' ? 'Core' : 'Advanced'}`, 'route-label ' + q.level));
      q.options.forEach((text, option) => {
        const label = element('label', undefined, 'option');
        const radio = element('input'); radio.type = 'radio'; radio.name = q.id; radio.value = option; radio.required = true;
        label.append(radio, element('span', text)); box.append(label);
      });
      $('questions').append(box);
    });
    progress(); $('quiz-title').focus();
  }
  function progress() {
    $('progress').textContent = `${$('quiz').querySelectorAll('input:checked').length} of ${current.length} answered.`;
  }
  $('quiz').addEventListener('change', progress);
  $('quiz').addEventListener('submit', event => {
    event.preventDefault();
    const answers = new FormData($('quiz')), topics = {};
    let correct = 0;
    $('review').replaceChildren(); $('topics').replaceChildren(); missed = [];
    current.forEach((q, index) => {
      const choice = Number(answers.get(q.id)), right = choice === q.answer;
      if (right) correct++; else missed.push(q);
      topics[q.chapter] ||= {correct:0, total:0};
      topics[q.chapter].total++; topics[q.chapter].correct += Number(right);
      const item = element('article', undefined, 'review-item' + (right ? '' : ' incorrect'));
      item.append(element('h3', `${index + 1}. ${q.question}`),
        element('p', `${right ? 'Correct' : 'Incorrect'}. Your answer: ${q.options[choice]}`),
        element('p', `Correct answer: ${q.options[q.answer]}`), element('p', q.explanation));
      const link = element('a', `Review: ${q.section}`); link.href = '../book/' + q.link; link.target = '_blank'; link.rel = 'noopener';
      item.append(link); $('review').append(item);
    });
    for (const [key, result] of Object.entries(topics)) {
      const row = element('tr'); row.append(element('th', bank.chapters[key]), element('td', `${result.correct} / ${result.total}`)); row.firstChild.scope = 'row'; $('topics').append(row);
    }
    $('score').textContent = `${correct} of ${current.length} correct (${Math.round(100 * correct / current.length)}%). All ${current.length} questions answered.`;
    $('retry').hidden = missed.length === 0;
    $('quiz').hidden = true; $('results').hidden = false; $('results-title').focus();
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
  }).catch(() => { $('status').textContent = 'The questions could not load. Please reload the page to try again.'; });
})();
