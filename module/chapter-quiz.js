(() => {
  function initialize() {
    document.querySelectorAll('.chapter-quiz:not([data-quiz-ready])').forEach(root => {
      root.dataset.quizReady = 'true';
      const form = root.querySelector('form'), results = root.querySelector('.quiz-results');
      const key = root.querySelector('.quiz-answer-key'), route = root.querySelector('.quiz-route');
      const questions = [...form.querySelectorAll('fieldset')], answers = [...key.querySelectorAll('.quiz-answer')];
      let active = [], missed = [];
      function updateProgress() {
        root.querySelector('.quiz-progress').textContent = `${active.filter(q => q.querySelector('input:checked')).length} of ${active.length} answered`;
      }
      function begin(subset) {
        active = subset;
        form.reset(); form.hidden = false; results.hidden = true; key.hidden = true; key.open = false;
        questions.forEach(q => {
          const selected = active.includes(q); q.hidden = !selected;
          q.querySelectorAll('input').forEach(input => { input.disabled = !selected; });
          if (selected) q.querySelector('.quiz-number').textContent = active.indexOf(q) + 1;
        });
        answers.forEach(answer => { answer.hidden = true; answer.querySelector('.quiz-choice').textContent = ''; });
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
          answer.hidden = false; answer.classList.toggle('quiz-incorrect', !correct);
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
          const list = document.createElement('ul');
          topics.forEach(item => { const li = document.createElement('li'); li.textContent = `${item.label}: ${item.correct} / ${item.total}`; list.append(li); });
          breakdown.append(list);
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
