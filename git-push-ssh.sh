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
# - $2 = remote url (optional)
# - $3 = push options (optional, e.g., "-o skip-ci")
# - $4 = "--tags" to also push tags (optional)
#
# Requirements:
# - Caller scripts workdir is a git repository
# - Passed SSH key has read/write permissions in remote repo
#
# shellcheck disable=SC2317  # Don't warn about unreachable commands in this function
git_push_ssh () {
  local ssh_key="$1"
  local remote_url="$2"
  local push_opts="$3"
  local push_tags="$4"
  local original_url

  export GIT_SSH_COMMAND="ssh -i $ssh_key -o UserKnownHostsFile=$SSH_GIT_KNOWN_HOSTS_FILE"

  # Handle remote URL
  if [ -n "$remote_url" ]; then
    original_url=$(git remote get-url origin 2>/dev/null || echo "")
    git remote set-url origin "$remote_url"
  fi

  # Push current branch
  # shellcheck disable=SC2086  # push_opts needs word splitting
  git push $push_opts origin HEAD

  # Push tags if requested
  if [ "$push_tags" = "--tags" ]; then
    # shellcheck disable=SC2086  # push_opts needs word splitting
    git push $push_opts origin --tags
  fi

  # Revert remote URL if it was changed
  if [ -n "$remote_url" ] && [ -n "$original_url" ]; then
    git remote set-url origin "$original_url"
  fi
}
