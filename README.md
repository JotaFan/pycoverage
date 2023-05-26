# pycoverage

his GitHub action runs python tests using `pytest` and creates a comment for PR with a coverage table.
It supports projects with the most popular python package managers (`pip`, `poetry`, `pipenv`)

[![made-with-python](https://img.shields.io/badge/Made%20with-Python-1f425f.svg)](https://www.python.org)

## Python Packages Used

- [`pytest`](https://pypi.org/project/pytest/)
- [`coverage`](https://pypi.org/project/coverage/)

## Optional Inputs

- `requirements-file`
  - requirements filepath for project
  - if left empty will default to `requirements.txt`
  - necessary if you use `pip` python package manager

- `pytest-root-dir`
  - root directory to recursively search for .py files

- `pytest-tests-dir`
  - directory with pytest tests
  - if left empty will identify test(s) dir by default

- `cov-omit-list`
  - list of directories and/or files to ignore

- `cov-threshold-single`
  - fail if any single file coverage is less than threshold

- `cov-threshold-total`
  - fail if the total coverage is less than threshold

- `async-tests`
  - Add support for async tests

- `poetry-version`
  - Poetry version to be used. The latest version is used by default

- `poetry-groups`
  - Poetry group names with the dependencies for the tests

- `package-extras`
  - Package extras with the dependencies for the tests, or dev-requirement file if pip

## Template workflow file

```yaml
name: pycoverage workflow

on: [pull_request]

jobs:
  tests:
    runs-on: ubuntu-latest
    name: Unit tests
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
        with:
          python-version: '3.9.6' # Define your project python version
      - id: run-tests
        uses: JotaFan/pycoverage@v1.0.0
        with:
          cov-omit-list: tests/*
          cov-threshold-single: 85
          cov-threshold-total: 90
          async-tests: true
          poetry-version: 1.4.2
          package-extras: dev,tests
```
Add the badge to your README.md

    <!-- README.md -->
    + [![cov](https://<you>.github.io/<repo>/badges/coverage.svg)](https://github.com/<you>/<repo>/actions)

Replace the `<you>` and `<repo>` above, like:

If you feel generous and want to show some extra appreciation:

Support this project with a :star:

[buymeacoffee-shield]: https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png
[!["Buy Me A Coffee"](https://user-images.githubusercontent.com/1376749/120938564-50c59780-c6e1-11eb-814f-22a0399623c5.png)](https://www.buymeacoffee.com/jotaflamev)
 [![Support via PayPal](https://cdn.jsdelivr.net/gh/twolfson/paypal-github-button@1.0.0/dist/button.svg)](https://www.paypal.me/joaopps)