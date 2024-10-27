#!/bin/bash

# SPDX-FileCopyrightText: 2024 Dominik Wombacher
#
# SPDX-License-Identifier: MIT

#
# Arguments:
#
# - $1 = path to ssh key
# - $2 = git remote url
#
# Requirements:
# - Caller scripts workdir is a git repository
# - Checked out branch is supposed to be mirrored
# - Passed SSH key has write permissions in remote repo
#
git_mirror () {
  export GIT_SSH_COMMAND="ssh -i $1 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
  GIT_BRANCH=$(git symbolic-ref --short HEAD)

  if [ "$#" -eq "2" ]; then
    git remote add mirror "$2"
    git push mirror "$GIT_BRANCH"
  else
    echo "Function expects two Arguments:"
    echo "1: path to ssh key"
    echo "2: git remote url"
  fi
}
