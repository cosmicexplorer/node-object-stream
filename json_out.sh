#!/bin/bash

while true; do
  # echo "{ \"a\": \"str\", \"b\": null, \"c\": 2.2, \"d\": [ false, true ] }"
  node -e "console.log(JSON.stringify(require('http')));"
  echo
done
