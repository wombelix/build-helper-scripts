#!/bin/bash

# SPDX-FileCopyrightText: 2025 Dominik Wombacher
#
# SPDX-License-Identifier: MIT

source _global.sh

# Configure SSH known hosts file
set_ssh_git_known_hosts

# Push with retries, forges are sometimes not reachable on first attempt
git_push_retry () {
  local attempt=1
  local max_attempts=3
  local delay=10

  while true; do
    if git push "$@"; then
      return 0
    fi

    if [ "$attempt" -ge "$max_attempts" ]; then
      echo "[ERROR] git push $* failed after $max_attempts attempts" 1>&2
      return 1
    fi

    echoinfo "git push $* failed (attempt $attempt/$max_attempts), retry in ${delay}s"
    sleep "$delay"
    attempt=$((attempt + 1))
    delay=$((delay * 3))
  done
}

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
    # IPv4 only, GitHub hosted runners have no IPv6 connectivity
    export GIT_SSH_COMMAND="ssh -i $1 -o UserKnownHostsFile=$SSH_GIT_KNOWN_HOSTS_FILE -o ConnectTimeout=15 -o AddressFamily=inet"

    GIT_SHA=$(git rev-parse --short HEAD)
    # Looks hacky but was the most reliable approach so far...
    GIT_BRANCH=$(git branch --points-at="$GIT_SHA" | tail -n1 | tr -d '* ')

    # Cleanup, ensure no 'mirror' remote exists from previous run
    if git remote get-url mirror > /dev/null 2>&1; then
      git remote remove mirror
    fi

    # Explicit return codes, 'set -e' is ignored when called from 'if' or '||'
    if ! git remote add mirror "$2"; then
      return 1
    fi

    if ! git_push_retry mirror "$GIT_BRANCH"; then
      return 1
    fi

    # Ensure all existing tags are pushed as well
    if ! git_push_retry mirror --tags; then
      return 1
    fi
  else
    echoerr "Function expects two Arguments!\n" \
    	"1: path to ssh key\n"
    	"2: git remote url"
  fi
}

#
# Arguments:
#
# - $1 = path to ssh key
# - $2... = git remote urls
#
# Mirrors to all remotes, even if one fails, and returns 1 if any failed.
#
git_mirror_many () {
  local ssh_key="$1"
  shift
  local remote_url
  local failed=""

  for remote_url in "$@"; do
    if ! git_mirror "$ssh_key" "$remote_url"; then
      failed="$failed $remote_url"
    fi
  done

  if [ -n "$failed" ]; then
    echo "[ERROR] Mirroring failed for:$failed" 1>&2
    return 1
  fi
}
