#!/bin/bash

INPUT_CONFIG_PATH="$1"
INPUT_LOG_OPTS="$2"
CONFIG=""

CONFIG=" --log-opts=$INPUT_LOG_OPTS"

# check if a custom config have been provided
if [ -f "$GITHUB_WORKSPACE/$INPUT_CONFIG_PATH" ]; then
  CONFIG=" --config-path=$GITHUB_WORKSPACE/$INPUT_CONFIG_PATH $CONFIG"
fi

# Assume the $GITHUB_WORKSPACE is a safe directory
# https://github.blog/2022-04-12-git-security-vulnerability-announced/
git config --global --add safe.directory "$GITHUB_WORKSPACE"

echo running gitleaks "$(gitleaks --version) with the following command👇"

DONATE_MSG="👋 maintaining gitleaks takes a lot of work so consider sponsoring me or donating a little something\n\e[36mhttps://github.com/sponsors/zricethezav\n\e[36mhttps://www.paypal.me/zricethezav\n"

if [ "$GITHUB_EVENT_NAME" = "push" ]
then
  echo gitleaks detect --source=$GITHUB_WORKSPACE --verbose --redact $CONFIG
  CAPTURE_OUTPUT=$(gitleaks detect --source=$GITHUB_WORKSPACE --verbose --redact $CONFIG)
elif [ "$GITHUB_EVENT_NAME" = "pull_request" ]
then 
  echo gitleaks detect --source=$GITHUB_WORKSPACE --verbose --redact $CONFIG
  CAPTURE_OUTPUT=$(gitleaks detect --source=$GITHUB_WORKSPACE --verbose --redact $CONFIG)
fi

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
