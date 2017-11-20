#!/bin/bash

stack exec github-trends | while IFS= read -r ln; do
 sleep 10
 curl -XPOST \
  -d "token=$1" \
  -d "channel=@hexirp" \
  -d "text=${ln}" \
  "https://slack.com/api/chat.postMessage"
done
