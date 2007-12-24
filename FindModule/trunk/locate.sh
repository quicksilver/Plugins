#!/bin/sh

/usr/bin/locate "$1*/$2" | /usr/bin/grep -F "$1" 2>/dev/null
