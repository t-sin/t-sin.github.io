#!/bin/sh

cp -r docs/* .
git add .
git commit -m "Publish: $(date --iso)"
