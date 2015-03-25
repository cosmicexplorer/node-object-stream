#!/bin/bash

if [ "$1" = "clean" ]; then
   rm -f bin/*.js
else
  mkdir -p bin/
  coffee -o bin/ -c src/*.coffee
fi
