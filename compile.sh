#!/bin/bash

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKING_DIR"

if [ "$1" = "clean" ]; then
   rm -f bin/*.js
else
  mkdir -p bin/
  coffee -o bin/ -c src/*.coffee
fi
