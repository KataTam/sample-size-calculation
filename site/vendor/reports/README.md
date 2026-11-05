# Report export dependencies

These files are served locally and loaded only when a report is downloaded. Report contents remain in the browser.

- PDFKit 0.20.2: `js/pdfkit.standalone.js` from the [published npm package](https://registry.npmjs.org/pdfkit/-/pdfkit-0.20.2.tgz). MIT; license retained in LICENSE-pdfkit.txt.
- docx 9.6.1: `dist/index.iife.js` from the [docx package](https://www.npmjs.com/package/docx/v/9.6.1). MIT; license retained in LICENSE-docx.txt.
- DejaVu Sans: embedded font from the bundled Poppler runtime; [DejaVu font license](https://github.com/dejavu-fonts/dejavu-fonts/blob/master/LICENSE) retained in LICENSE-DejaVu.txt.

The project code in `site/report-exports.js` converts the existing report content into selectable, tagged PDF text and editable Word paragraphs and tables. Native table and heading structure, hyperlinks, language metadata, and PDF page numbers are preserved. Automated checks cover structure and extracted content; they are not a certification of PDF/UA conformance.
