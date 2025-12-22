# Mkdocs template

This template uses mkdocs with the material theme. This is specifically a support template that should be used with one of the other templates, as it's meant to be embedded in an existing repo. If you plan to use it standalone, you need to set up the rest of the repo infrastructure on your own.

To properly run this template, you need:

```bash
# Optional (but recommended):
python3 -m venv env 
source ./bin/env/activate
# Actual install steps:
pip3 install mkdocs mkdocs-material
mkdocs serve
```

* https://github.com/mkdocs/mkdocs/
* https://github.com/squidfunk/mkdocs-material

## Next steps

* The template includes a GitHub Actions workflow. If you plan to use it, verify that the branch names are correct.
    * Additionally, you must set the GitHub Pages source to GitHub Actions in repository settings, or the action will fail.
* Delete this file and add the instructions to your README, CONTRIBUTING.md, or other file that makes sense in your project.
