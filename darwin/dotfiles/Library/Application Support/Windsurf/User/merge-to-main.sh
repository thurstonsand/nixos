#!/usr/bin/env bash
set -e

branch_to_merge="$1"

# Ensure we have a branch to merge
if [ -z "$branch_to_merge" ]; then
  echo "Error: No branch specified to merge"
  exit 1
fi

# Main workflow
git checkout main
git pull
git merge "$branch_to_merge"
git push

# Clean up merged branches using git-trim
# merged:origin     - delete merged tracking branches and their upstreams from origin
# merged-local      - delete merged tracking local branches
# stray             - delete tracking local branches whose upstream is gone
# local             - delete non-tracking merged local branches
git trim -d merged:origin -d merged-local -d stray -d local
