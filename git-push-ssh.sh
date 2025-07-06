#!/bin/bash

# SPDX-FileCopyrightText: 2024 Dominik Wombacher
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
# - $3 = branch name (optional, defaults to current branch)
# - $4 = push options (optional, e.g., "-o skip-ci")
#
# Requirements:
# - Caller scripts workdir is a git repository
# - Passed SSH key has read/write permissions in remote repo
#
# shellcheck disable=SC2317  # Don't warn about unreachable commands in this function
git_push_ssh () {
  if [ "$#" -lt "2" ]; then
    echoerr "Function expects at least two Arguments!\n" \
      "1: path to ssh key\n" \
      "2: git remote url\n" \
      "3: branch name (optional)\n" \
      "4: push options (optional)"
    return 1
  fi

  local ssh_key="$1"
  local remote_url="$2"
  local branch="${3:-$(git branch --show-current)}"
  local push_opts="$4"

  export GIT_SSH_COMMAND="ssh -i $ssh_key -o UserKnownHostsFile=$SSH_GIT_KNOWN_HOSTS_FILE"

  # Setup remote
  git remote remove origin 2>/dev/null || true
  git remote add origin "$remote_url"

  # Push branch and tags
  # shellcheck disable=SC2086  # push_opts needs word splitting
  git push $push_opts origin "$branch"
  # shellcheck disable=SC2086  # push_opts needs word splitting
  git push $push_opts origin --tags
}
