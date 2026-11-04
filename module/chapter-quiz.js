(() => {
  function initialize() {
    document.querySelectorAll('.chapter-quiz:not([data-quiz-ready])').forEach(root => {
      root.dataset.quizReady = 'true';
      if (!root.closest('.quiz-disclosure')) {
        const heading = root.previousElementSibling;
        if (heading?.matches('h2')) {
          heading.querySelectorAll('.anchor-section').forEach(a => a.remove());
          const disclosure = document.createElement('details'); disclosure.className = 'quiz-disclosure';
          const summary = document.createElement('summary');
          heading.before(disclosure); summary.append(heading); disclosure.append(summary, root);
        }
      }
      const form = root.querySelector('form'), results = root.querySelector('.quiz-results');
      const key = root.querySelector('.quiz-answer-key'), route = root.querySelector('.quiz-route');
      const questions = [...form.querySelectorAll('fieldset')], answers = [...key.querySelectorAll('.quiz-answer')];
      let active = [], missed = [];
      function updateProgress() {
        const answered=active.filter(q => q.querySelector('input:checked')).length;
        root.querySelector('.quiz-progress').textContent = `${answered} of ${active.length} answered`;
        const bar=root.querySelector('.quiz-progress-bar');bar.max=active.length;bar.value=answered;
      }
      function begin(subset) {
        active = subset;
        form.reset(); form.hidden = false; results.hidden = true; key.hidden = true; key.open = false;
        questions.forEach(q => {
          const selected = active.includes(q); q.hidden = !selected;
          q.querySelectorAll('input').forEach(input => { input.disabled = !selected; });
          if (selected) q.querySelector('.quiz-number').textContent = active.indexOf(q) + 1;
        });
        answers.forEach(answer => { answer.hidden = true; answer.open=false;answer.querySelector('.quiz-choice').textContent = '';answer.querySelector('.quiz-answer-status').textContent=''; });
        updateProgress();
      }
      function reset() {
        const selected = route?.value || root.dataset.defaultRoute;
        begin(questions.filter(q => selected === 'all' || q.dataset.level === 'core'));
      }
      form.addEventListener('change', updateProgress);
      route?.addEventListener('change', reset);
      form.addEventListener('submit', event => {
        event.preventDefault();
        if (!form.reportValidity()) return;
        missed = []; const topics = new Map();
        active.forEach((q, i) => {
          const chosen = q.querySelector('input:checked'), correct = chosen.value === q.dataset.answer;
          if (!correct) missed.push(q);
          const answer = answers.find(a => a.dataset.question === q.dataset.question);
          answer.hidden = false; answer.open=!correct;answer.classList.toggle('quiz-incorrect', !correct);
          answer.querySelector('.quiz-answer-status').textContent=correct?'Correct':'Needs review';
          answer.querySelector('.quiz-number').textContent = i + 1;
          answer.querySelector('.quiz-choice').textContent = `${correct ? 'Correct' : 'Incorrect'}. Your answer: ${chosen.nextElementSibling.textContent}`;
          const topic = q.dataset.topic;
          const entry = topics.get(topic) || {label:topic, total:0, correct:0};
          entry.total++; entry.correct += Number(correct); topics.set(topic, entry);
        });
        form.hidden = true; results.hidden = false; key.hidden = false; key.open = true;
        const score = root.querySelector('.quiz-score');
        score.textContent = `${active.length - missed.length} of ${active.length} correct (${Math.round(100 * (active.length - missed.length) / active.length)}%)`;
        root.querySelector('.quiz-retry').hidden = missed.length === 0;
        const breakdown = root.querySelector('.quiz-topics'); breakdown.replaceChildren();
        if (root.id === 'quiz-all') {
          const table=document.createElement('table'),caption=document.createElement('caption');caption.textContent='Results by topic';table.append(caption);
          const head=document.createElement('thead'),row=document.createElement('tr');
          for(const text of ['Topic','Correct']){const cell=document.createElement('th');cell.scope='col';cell.textContent=text;row.append(cell)}head.append(row);table.append(head);
          const body=document.createElement('tbody');
          topics.forEach(item=>{const row=document.createElement('tr'),topic=document.createElement('th'),score=document.createElement('td');topic.scope='row';topic.textContent=item.label;score.textContent=`${item.correct} / ${item.total}`;row.append(topic,score);body.append(row)});
          table.append(body);breakdown.append(table);
        }
        score.focus();
      });
      root.querySelector('.quiz-retry').addEventListener('click', () => { begin([...missed]); active[0]?.querySelector('input').focus(); });
      root.querySelector('.quiz-reset').addEventListener('click', () => { reset(); active[0]?.querySelector('input').focus(); });
      reset();
    });
  }
  initialize();
  if (window.gitbook) window.gitbook.events.bind('page.change', initialize);
  window.addEventListener('load', initialize);
})();
