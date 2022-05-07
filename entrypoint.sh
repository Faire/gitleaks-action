#!/bin/bash

INPUT_CONFIG_PATH="$1"
CONFIG=""
LOG_OPTS=""

if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
  LOG_OPTS=" --log-opts=\"--full-history --simplify-merges --show-pulls --all $GITHUB_BASE_REF..$GITHUB_REF\""
fi

# check if a custom config have been provided
if [ -f "$GITHUB_WORKSPACE/$INPUT_CONFIG_PATH" ]; then
  CONFIG=" --config=$GITHUB_WORKSPACE/$INPUT_CONFIG_PATH"
fi

# Assume the $GITHUB_WORKSPACE is a safe directory
# https://github.blog/2022-04-12-git-security-vulnerability-announced/
git config --global --add safe.directory "$GITHUB_WORKSPACE"

echo running gitleaks "$(gitleaks version) with the following command👇"
echo gitleaks detect --source=$GITHUB_WORKSPACE --verbose --redact $CONFIG $LOG_OPTS
echo "\n\n\n"

DONATE_MSG="👋 maintaining gitleaks takes a lot of work so consider sponsoring me or donating a little something\n\e[36mhttps://github.com/sponsors/zricethezav\n\e[36mhttps://www.paypal.me/zricethezav\n"

CAPTURE_OUTPUT=$(gitleaks detect --source=$GITHUB_WORKSPACE --verbose --redact $CONFIG $LOG_OPTS)

EXIT_CODE=$?

if [ $? -eq 1 ]
then
  GITLEAKS_RESULT=$(echo -e "\e[31m🛑 STOP! Gitleaks encountered leaks")
  echo "$GITLEAKS_RESULT"
  echo "::set-output name=exitcode::$EXIT_CODE"
  echo "----------------------------------"
  echo "$CAPTURE_OUTPUT"
  echo "::set-output name=result::$CAPTURE_OUTPUT"
  echo "----------------------------------"
  echo -e $DONATE_MSG
  exit 1
else
  GITLEAKS_RESULT=$(echo -e "\e[32m✅ SUCCESS! Your code is good to go!")
  echo "$GITLEAKS_RESULT"
  echo "::set-output name=exitcode::$EXIT_CODE"
  echo "------------------------------------"
  echo -e $DONATE_MSG
fi
