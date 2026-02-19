#!/bin/bash
echo "enter commit"
read commit
git add .
git commit -m "$commit"
git push
