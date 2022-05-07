#!/bin/bash

INPUT_CONFIG_PATH="$CONFIG_PATH"
INPUT_LOG_OPTS="$LOG_OPTS"
CONFIG=""

if [ "$INPUT_LOG_OPTS" -ne "" ]; then
  CONFIG=" --log-opts=$INPUT_LOG_OPTS"
fi

# check if a custom config have been provided
if [ -f "$GITHUB_WORKSPACE/$INPUT_CONFIG_PATH" ]; then
  CONFIG=" --config-path=$GITHUB_WORKSPACE/$INPUT_CONFIG_PATH $CONFIG"
fi

echo running gitleaks "$(gitleaks --version) with the following command👇"

DONATE_MSG="👋 Testing Faire modification"

if [ "$GITHUB_EVENT_NAME" = "push" ]
then
  echo gitleaks detect --source=$GITHUB_WORKSPACE --verbose --redact $CONFIG
  CAPTURE_OUTPUT=$(gitleaks detect --source=$GITHUB_WORKSPACE --verbose --redact $CONFIG)
elif [ "$GITHUB_EVENT_NAME" = "pull_request" ]
then 
  echo gitleaks detect --source=$GITHUB_WORKSPACE --verbose --redact $CONFIG
  CAPTURE_OUTPUT=$(gitleaks detect --source=$GITHUB_WORKSPACE --verbose --redact $CONFIG)
fi

if [ $? -eq 1 ]
then
  GITLEAKS_RESULT=$(echo -e "\e[31m🛑 STOP! Gitleaks encountered leaks")
  echo "$GITLEAKS_RESULT"
  echo "::set-output name=exitcode::$GITLEAKS_RESULT"
  echo "----------------------------------"
  echo "$CAPTURE_OUTPUT"
  echo "::set-output name=result::$CAPTURE_OUTPUT"
  echo "----------------------------------"
  echo -e $DONATE_MSG
  exit 1
else
  GITLEAKS_RESULT=$(echo -e "\e[32m✅ SUCCESS! Your code is good to go!")
  echo "$GITLEAKS_RESULT"
  echo "::set-output name=exitcode::$GITLEAKS_RESULT"
  echo "------------------------------------"
  echo -e $DONATE_MSG
fi
