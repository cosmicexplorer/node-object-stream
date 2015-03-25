#!/bin/bash

if [ "$1" = "clean" ]; then
   rm -f bin/*.js
else
  coffee -o bin/ -c *.coffee
fi
