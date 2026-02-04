#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage: $0 <file>"
	exit 1
fi

if [ ! -f "$1" ]; then
	echo "Error: File "$1" not found."
	exit 1
fi

cat "$1" | sed 's/+/ /g;s/%\([0-9a-fA-F][0-9a-fA-F]\)/\\x\1/g' | xargs -0 printf %b
