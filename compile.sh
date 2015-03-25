#!/bin/bash

if [ "$1" = "clean" ]; then
   rm -f *.js
else
  coffee -o bin/ -c *.coffee
fi
