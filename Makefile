

install:
	pip install pre-commit==3.3.3 PyGithub==1.59.0 black==23.3.0 flake8==6.0.0
	pre-commit install
	pre-commit install --hook-type commit-msg

check:
	pre-commit run --all-files
