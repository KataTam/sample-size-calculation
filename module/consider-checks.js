/* Original teaching software, MIT. Arithmetic is parsed without executing code. */
(() => {
  function arithmetic(expression) {
    const source = expression.replace(/\u2212/g, '-').replace(/[\u00d7\u00b7]/g, '*').replace(/\u00f7/g, '/').replace(/\s+/g, '');
    if (!source || source.length > 160) throw Error('Enter a calculation using numbers and arithmetic signs.');
    const tokens = source.match(/(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?|[()+*/^%\-]/g) || [];
    if (tokens.join('') !== source || tokens.length > 100) throw Error('Use numbers, +, −, ×, ÷, ^, % and parentheses.');
    let position = 0, depth = 0;
    function primary() {
      if (++depth > 30) throw Error('Use fewer nested parentheses.');
      let value;
      if (tokens[position] === '(') {
        position++; value = sum();
        if (tokens[position++] !== ')') throw Error('Check the parentheses.');
      } else {
        const token = tokens[position++];
        if (!token || !/^[\d.]/.test(token)) throw Error('Check the numbers and arithmetic signs.');
        value = Number(token);
      }
      while (tokens[position] === '%') { position++; value /= 100; }
      depth--; return value;
    }
    function power() { const value = primary(); if (tokens[position] === '^') {position++; return value ** unary();} return value; }
    function unary() { if (tokens[position] === '+') {position++; return unary();} if (tokens[position] === '-') {position++; return -unary();} return power(); }
    function product() { let value = unary(); while (['*', '/'].includes(tokens[position])) {const op = tokens[position++], next = unary(); value = op === '*' ? value * next : value / next;} return value; }
    function sum() { let value = product(); while (['+', '-'].includes(tokens[position])) {const op = tokens[position++], next = product(); value = op === '+' ? value + next : value - next;} return value; }
    const value = sum();
    if (position !== tokens.length || !Number.isFinite(value)) throw Error('Check the calculation. Division by zero has no finite result.');
    return value;
  }
  function initialize() {
    document.querySelectorAll('.consider-check:not([data-consider-ready])').forEach(root => {
      root.dataset.considerReady = 'true';
      const feedback = root.querySelector('.consider-answer');
      feedback.hidden = true;
      root.querySelector('.consider-choices').hidden = false;
      root.querySelectorAll('input[type=radio]').forEach(input => {
        input.checked = false;
        input.addEventListener('change', () => {
          const correct = input.value === root.dataset.correct;
          root.dataset.result = correct ? 'correct' : 'incorrect';
          root.querySelector('.consider-result').textContent = correct ? 'Correct.' : 'Incorrect.';
          feedback.hidden = false;
        });
      });
      const calculator = root.querySelector('.consider-calculator');
      if (!calculator) return;
      calculator.hidden = false;
      const input = calculator.querySelector('input'), result = calculator.querySelector('output'), round = calculator.querySelector('.consider-round');
      let last = null;
      const format = value => Number(value.toPrecision(14)).toString();
      function clearResult() { last = null; result.textContent = ''; input.removeAttribute('aria-invalid'); if (round) round.disabled = true; }
      input.addEventListener('input', clearResult);
      calculator.addEventListener('submit', event => {
        event.preventDefault(); clearResult();
        try { last = arithmetic(input.value); result.textContent = input.value + ' = ' + format(last); if (round) round.disabled = false; }
        catch (error) { input.setAttribute('aria-invalid', 'true'); result.textContent = error.message; }
      });
      round?.addEventListener('click', () => {
        if (last === null) return;
        // Ignore machine rounding at an integer, such as 0.07 * 100.
        const nearest = Math.round(last), tolerance = 4 * Number.EPSILON * Math.max(1, Math.abs(last));
        last = Math.abs(last - nearest) <= tolerance ? nearest : Math.ceil(last);
        input.value = String(last); result.textContent = 'Rounded upward: ' + format(last);
      });
      calculator.querySelector('.consider-clear').addEventListener('click', () => {input.value = ''; clearResult(); input.focus();});
    });
  }
  initialize();
  if (window.gitbook) window.gitbook.events.bind('page.change', initialize);
  window.addEventListener('load', initialize);
})();
