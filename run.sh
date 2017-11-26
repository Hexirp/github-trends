#!/bin/bash

TRENDS=$(stack exec github-trends)
curl -XPOST \
  -d "token=$1" \
  -d "channel=@hexirp" \
  -d "as_user=false" \
  -d "username=GitHub Trends" \
  -d "text=Today's GitHub trends!" \
  -d "attachments=${TRENDS}" \
  "https://slack.com/api/chat.postMessage" \
    &> /dev/null
