/* References for the report format. Original software: MIT. */
(() => {
  'use strict';
  const references = [
    ['Cook, J. A., Julious, S. A., Sones, W., Hampson, L. V., Hewitt, C., Berlin, J. A., Ashby, D., Emsley, R., Fergusson, D. A., Walters, S. J., Wilson, E. C. F., MacLennan, G., Stallard, N., Rothwell, J. C., Bland, M., Brown, L., Ramsay, C. R., Altman, D. G., & Vale, L. D. (2018). DELTA² guidance on choosing the target difference and undertaking and reporting the sample size calculation for a randomised controlled trial. BMJ, 363, k3750.', 'https://doi.org/10.1136/bmj.k3750'],
    ['Richardson, W. S., Wilson, M. C., Nishikawa, J., & Hayward, R. S. A. (1995). The well-built clinical question: A key to evidence-based decisions. ACP Journal Club, 123(3), A12–A13.', 'https://doi.org/10.7326/ACPJC-1995-123-3-A12'],
    ['SPIRIT–CONSORT Group. (2025). SPIRIT 2025 and CONSORT 2025 statements.', 'https://www.consort-spirit.org/'],
    ['Tamasi, K. (2026). Sample size calculation OER [Teaching materials and software]. GitHub.', 'https://github.com/KataTam/sample-size-calculation'],
    ['University Medical Center Groningen. (n.d.). Statistical analysis plan: Template 8A.35851 (Version 3), section 4.1.', 'https://umcg.zenya.work/document/2f52710d-3ebc-495e-a4dc-6dee95742c78']
  ];
  function append(article, supplied) {
    const section = document.createElement('section'); section.id = 'report-references';
    const heading = document.createElement('h3'); heading.textContent = 'References'; section.append(heading);
    const credit = document.createElement('p');
    credit.textContent = 'Prepared using the report app in Tamasi (2026). The reporting structure draws on Richardson et al. (1995), Cook et al. (2018), the SPIRIT–CONSORT Group (2025), and the University Medical Center Groningen (n.d.).';
    section.append(credit);
    const entries = [...references, ...(supplied || '').split(/\n\s*\n|\n(?=\S)/).map(s => s.trim()).filter(Boolean).map(text => [text, ''])];
    entries.sort((a,b) => a[0].localeCompare(b[0], 'en', {sensitivity:'base'}));
    const seen = new Set();
    for (const [text, url] of entries) {
      if(seen.has(text)) continue;
      seen.add(text);
      const p = document.createElement('p'), link = document.createElement('a');
      p.append(document.createTextNode(text));
      if(url) {link.href=url;link.textContent=url;link.target='_blank';link.rel='noopener';p.append(document.createTextNode(' '),link);}
      section.append(p);
    }
    article.append(section);
  }
  window.ReportReferences = {append};
})();
