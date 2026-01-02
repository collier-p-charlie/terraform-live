#!/bin/bash

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
SOURCE_BRANCH=${1:-$CURRENT_BRANCH}
TARGET_BRANCH=$2

if [[ ! $SOURCE_BRANCH =~ ^(feature|bugfix|hotfix|release)/.+$ ]]; then
  echo "Branch name '$SOURCE_BRANCH' must be of the form 'feature/*', 'bugfix/*', 'hotfix/*' or 'release/*'"
  exit 1
fi

if [[ $TARGET_BRANCH ]] && [[ ! $TARGET_BRANCH == main ]]; then
  echo "Target branch must be 'main'" && exit 1
fi

echo "Branch name $SOURCE_BRANCH is valid"
