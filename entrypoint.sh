#!/bin/bash

# $1: requirements file if pip is a package-manager
# $2: pytest-root-dir
# $3: tests dir
# $4: cov-omit-list
# $5: cov-threshold-single
# $6: cov-threshold-total
# $7: async-tests
# $8: poetry-groups
# $9: package-extras
# $10: badge-output
# $11: overwrite
# $12: poetry-version

COV_CONFIG_FILE=.coveragerc


COV_THRESHOLD_SINGLE_FAIL=false
COV_THRESHOLD_TOTAL_FAIL=false

TESTING_TOOLS="pytest pytest-mock coverage pytest-cov"

if [ $7 == true ]
then
  TESTING_TOOLS="$TESTING_TOOLS pytest-asyncio"
fi

package_extras=$9

# Case insensitive comparing and installing of package-manager
if [ -f "./pyproject.toml" ] && [ -f "./poetry.lock" ]
then
  poetry_version=${12}
  if [ $poetry_version ]
  then
    echo "Poetry version $poetry_version provided"
    python -m pip install poetry==$poetry_version
  else
    echo "Poetry version is not provided. Installing latest version"
    python -m pip install poetry
  fi
  python -m poetry config virtualenvs.create false
  poetry_groups=$8
  if [ $package_extras ]
  then
    arguments_groups=''
    for i in ${package_extras//,/ }
    do
        arguments_groups+=" --extras ${i}"
    done
    python -m poetry install $arguments_groups
  fi
  if [ $poetry_groups ] 
  then
    arguments_groups=''
    for i in ${poetry_groups//,/ }
    do
        arguments_groups+=" --with ${i}"
    done

    python -m poetry install $arguments_groups
  else
    python -m poetry add $TESTING_TOOLS
    python -m poetry install
  fi
  python -m poetry shell
elif [ -f "./Pipfile" ] && [ -f "./Pipfile.lock" ];
then
  python -m pip install pipenv
  pipenv install --dev $TESTING_TOOLS
  pipenv install --dev --system
  pipenv --rm
elif [ -f "$1" ];
then
  python -m pip install -r "$1" --no-cache-dir --user
  if [ $package_extras ]
  then
    python -m pip install -r $package_extras
  else
    python -m pip install $TESTING_TOOLS
  fi
else
  echo "Can not detect your package manager :("
  exit 1
fi 


# write omit str list to coverage file
if [ -n "$4" ] && [ -f "./${COV_CONFIG_FILE}" ]; then
  >&2 echo "Cannot support both user-provided '$COV_CONFIG_FILE' file along with cov-omit-list configuration."
  exit 1
elif [ -n "$4" ]; then
  cat << EOF > "$COV_CONFIG_FILE"
[run]
omit = $4
EOF
fi

if [ -f "./pyproject.toml" ] && [ -f "./poetry.lock" ]
then
  poetry run coverage run --source="$2" --rcfile=.coveragerc  -m pytest "$3" --cov-report term-missing
  poetry run coverage json -o coverage.json
else
  pip install -U $TESTING_TOOLS
  # Run pytest
  coverage run --source="$2" --rcfile=.coveragerc  -m pytest "$3" --cov-report term-missing
  coverage json -o coverage.json
fi
if [ $? == 1 ]
then
  echo "Unit tests failed"
  exit 1
fi


export COVERAGE_SINGLE_THRESHOLD="$5"
export COVERAGE_TOTAL_THRESHOLD="$6"
export COV_BADGE_FILE_PATH="${10}"

TABLE=$(python coverage_handler)

COVERAGE_STATUS_CODE=$?

if [ $COVERAGE_STATUS_CODE == 101 ]
then
  COV_THRESHOLD_SINGLE_FAIL=true
elif [ $COVERAGE_STATUS_CODE == 102 ]
then
  COV_THRESHOLD_TOTAL_FAIL=true
elif [ $COVERAGE_STATUS_CODE != 0 ];
then
    echo "Something went wrong!"
    exit 1
fi


# set output variables to be used in workflow file
echo "output-table<<EOF" >> $GITHUB_OUTPUT
echo "$TABLE" >> $GITHUB_OUTPUT
echo "EOF" >> $GITHUB_OUTPUT
echo "cov-threshold-single-fail=$COV_THRESHOLD_SINGLE_FAIL" >> $GITHUB_OUTPUT
echo "cov-threshold-total-fail=$COV_THRESHOLD_TOTAL_FAIL" >> $GITHUB_OUTPUT


pip install -U coverage-badge
EXTRA_ARGS=""
if [[ ${11} == 'true'  ]]; then
  EXTRA_ARGS+="-f"
fi
coverage-badge $EXTRA_ARGS -o ${10}
