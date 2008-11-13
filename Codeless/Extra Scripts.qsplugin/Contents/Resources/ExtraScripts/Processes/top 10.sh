#!/bin/sh 

top -cd -u -F -R -l2 -n10 | tail | awk '{str = substr($0,18,6); sub(/^ +/, "", str); print str " - " substr($0,7,10)}'