#!/bin/bash

# SPDX-FileCopyrightText: 2025 Dominik Wombacher
#
# SPDX-License-Identifier: MIT

source _global.sh

# Configure SSH known hosts file
set_ssh_git_known_hosts

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
# shellcheck disable=SC2317  # Don't warn about unreachable commands in this function
git_mirror () {
  if [ "$#" -eq "2" ]; then
    export GIT_SSH_COMMAND="ssh -i $1 -o UserKnownHostsFile=$SSH_GIT_KNOWN_HOSTS_FILE"

    GIT_SHA=$(git rev-parse --short HEAD)
    # Looks hacky but was the most reliable approach so far...
    GIT_BRANCH=$(git branch --points-at="$GIT_SHA" | tail -n1 | tr -d '* ')

    # Cleanup, ensure no 'mirror' remote exists from previous run
    git remote remove mirror || true

    git remote add mirror "$2" \
      && git push mirror "$GIT_BRANCH"

    # Ensure all existing tags are pushed as well
    git push mirror --tags
  else
    echoerr "Function expects two Arguments!\n" \
    	"1: path to ssh key\n"
    	"2: git remote url"
  fi
}
