#!/bin/bash

INPUT_CONFIG_PATH="$1"
INPUT_LOG_OPTS="$2"
INPUT_WORKING_DIRECTORY="$3"
CONFIG=""
LOG_OPTS=""

WORKING_DIRECTORY="$GITHUB_WORKSPACE/$INPUT_WORKING_DIRECTORY"

echo log opts: $INPUT_LOG_OPTS
echo config path: $INPUT_CONFIG_PATH

if [ "$GITHUB_EVENT_NAME" = "pull_request" ] && [ ! -z "$INPUT_LOG_OPTS" ]; then
  LOG_OPTS=" --log-opts=\"--simplify-merges $INPUT_LOG_OPTS\""
fi

# check if a custom config have been provided 
if [ -f "$WORKING_DIRECTORY/$INPUT_CONFIG_PATH" ]; then
  CONFIG=" --config=$WORKING_DIRECTORY/$INPUT_CONFIG_PATH"
fi

# Assume the $GITHUB_WORKSPACE is a safe directory
# https://github.blog/2022-04-12-git-security-vulnerability-announced/
git config --global --add safe.directory "$WORKING_DIRECTORY"
git config --global --add safe.directory "$GITHUB_WORKSPACE"

echo running gitleaks "$(gitleaks version) with the following command👇"
echo gitleaks detect --source=$WORKING_DIRECTORY --verbose --redact $CONFIG $LOG_OPTS

DONATE_MSG="👋 maintaining gitleaks takes a lot of work so consider sponsoring me or donating a little something\n\e[36mhttps://github.com/sponsors/zricethezav\n\e[36mhttps://www.paypal.me/zricethezav\n"

CAPTURE_OUTPUT=$(gitleaks detect --source=$WORKING_DIRECTORY --verbose --redact $CONFIG $LOG_OPTS)

EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]
then
  GITLEAKS_RESULT=$(echo -e "\e[31m🛑 STOP! Gitleaks encountered leaks")
  echo "$GITLEAKS_RESULT"
  echo "::set-output name=exitcode::$EXIT_CODE"
  echo "----------------------------------"
  echo "$CAPTURE_OUTPUT"
  echo "::set-output name=result::$CAPTURE_OUTPUT"
  echo "GITLEAKS_RESULT<<EOF" >> $GITHUB_ENV
  echo "$CAPTURE_OUTPUT" >> $GITHUB_ENV
  echo "EOF" >> $GITHUB_ENV
  echo "----------------------------------"
  echo -e $DONATE_MSG
  exit $EXIT_CODE
else
  GITLEAKS_RESULT=$(echo -e "\e[32m✅ SUCCESS! Your code is good to go!")
  echo "$GITLEAKS_RESULT"
  echo "::set-output name=exitcode::$EXIT_CODE"
  echo "------------------------------------"
  echo -e $DONATE_MSG
fi
