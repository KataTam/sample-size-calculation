# Build and publication

The source and website are maintained in one public repository: [KataTam/sample-size-calculation](https://github.com/KataTam/sample-size-calculation).

Push source changes to main to trigger .github/workflows/publish.yml. The workflow runs the numerical/server checks, renders both HTML editions, exports the four Shinylive apps, assembles _site/ with scripts/build_site.py and deploys it using GitHub Pages. No cross-repository token or manual copying is needed.

For local preview, follow README.md. Browser apps must be served over HTTP; file:// is insufficient for WebAssembly/service workers. Generated docs/ and _site/ are ignored. A failed build leaves the last successful site online. Review the Actions logs before retrying.

The former sample-size-calculation-apps repository is a private archive and its Pages address is retired. Share the new sample-size-calculation URLs. The original source repository is a private historical archive; its README points to this public project. Contributor edits belong here.
