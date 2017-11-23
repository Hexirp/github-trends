#!/bin/bash

IN=`cat -`
curl -XPOST \
  -d "token=$1" \
  -d "channel=@hexirp" \
  -d "text=Today's GitHub trends!" \
  -d "attachments=${IN}" \
  "https://slack.com/api/chat.postMessage"
