#!/bin/bash

# If there is a permission error, run this command:
# chmod +x scripts/deleteOldBranches.sh


total_branches=0
old_branches=0

echo "Analyzing branches..."
while IFS=' ' read -r branch date; do
  ((total_branches++))
  month_ago=$(date -j -v-1m +%s)  # macOS way to get date from 1 month ago
  if [ "$branch" != "main" ] && [ "$branch" != "master" ] && [ $date -lt $month_ago ]; then
    ((old_branches++))
    display_date=$(date -j -r $date '+%Y-%m-%d')
    echo "Will delete: $branch (last updated: $display_date)"
  fi
done < <(git branch --format="%(refname:short) %(committerdate:unix)")

echo -e "\nFound $old_branches out of $total_branches branches to delete."
read -p "Do you want to proceed? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  git branch --format="%(refname:short) %(committerdate:unix)" | 
  while read branch date; do
    if [ "$branch" != "main" ] && [ "$branch" != "master" ] && [ $date -lt $month_ago ]; then
      git branch -D $branch
    fi
  done
fi