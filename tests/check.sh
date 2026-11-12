#!/bin/sh
cd "$(dirname "$0")/.." || exit 2
grep -q '^implemented-change$' src/app.txt
