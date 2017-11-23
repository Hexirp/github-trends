#!/bin/bash

curl -XPOST \
  -d "token=$1" \
  -d "channel=@hexirp" \
  -d "text=Today's GitHub trends!" \
  -d "attachments=$(stack exec github-trends)" \
  "https://slack.com/api/chat.postMessage"
