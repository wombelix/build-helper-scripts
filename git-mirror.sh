#!/bin/bash

# SPDX-FileCopyrightText: 2024 Dominik Wombacher
#
# SPDX-License-Identifier: MIT

source _global.sh

GIT_MIRROR_SSH_KNOWN_HOSTS_FILE=~/.ssh/git_mirror_known_hosts

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
    export GIT_SSH_COMMAND="ssh -i $1 -o UserKnownHostsFile=$GIT_MIRROR_SSH_KNOWN_HOSTS_FILE"

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

git_mirror_set_ssh_known_hosts () {
  printf '%s' "$GIT_MIRROR_SSH_KNOWN_HOSTS" > "$GIT_MIRROR_SSH_KNOWN_HOSTS_FILE"
}

# The way 'read' is used will cause a return code of 1
# Ensure that this expected behavior doesn't stop script execution
set +e
IFS='' read -r -d '' GIT_MIRROR_SSH_KNOWN_HOSTS <<"EOF"
# SPDX-FileCopyrightText: 2024 Dominik Wombacher <dominik@wombacher.cc>
#
# SPDX-License-Identifier: CC0-1.0

# GitHub SSH host keys
# https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
#
# 2024-10-27 (match)
# ssh-keygen -lf <(ssh-keyscan github.com 2>/dev/null)
#   256 SHA256:p2QAMXNIC1TJYWeIOttrVc98/R1BUFWu3/LiyKgUfQM github.com (ECDSA)
#   3072 SHA256:uNiVztksCsDhcc0u9e8BujQXVUpKZIDTMczCvj3tD2s github.com (RSA)
#   256 SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU github.com (ED25519)
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=

# Gitlab SSH host keys
# https://docs.gitlab.com/ee/user/gitlab_com/#ssh-known_hosts-entries
#
# 2024-10-27 (match)
# ssh-keygen -lf <(ssh-keyscan gitlab.com 2>/dev/null)
#   2048 SHA256:ROQFvPThGrW4RuWLoL9tq9I9zJ42fK4XywyRtbOz/EQ gitlab.com (RSA)
#   256 SHA256:HbW3g8zUjNSksFbqTiUWPWg2Bq1x8xdGUrliXFzSnUw gitlab.com (ECDSA)
#   256 SHA256:eUXGGm1YGsMAS7vkcx6JOJdOGHPem5gQp4taiCfCLB8 gitlab.com (ED25519)
gitlab.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf
gitlab.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsj2bNKTBSpIYDEGk9KxsGh3mySTRgMtXL583qmBpzeQ+jqCMRgBqB98u3z++J1sKlXHWfM9dyhSevkMwSbhoR8XIq/U0tCNyokEi/ueaBMCvbcTHhO7FcwzY92WK4Yt0aGROY5qX2UKSeOvuP4D6TPqKF1onrSzH9bx9XUf2lEdWT/ia1NEKjunUqu1xOB/StKDHMoX4/OKyIzuS0q/T1zOATthvasJFoPrAjkohTyaDUz2LN5JoH839hViyEG82yB+MjcFV5MU3N1l1QL3cVUCh93xSaua1N85qivl+siMkPGbO5xR/En4iEY6K2XPASUEMaieWVNTRCtJ4S8H+9
gitlab.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY=

# Codeberg SSH host keys
# https://docs.codeberg.org/security/ssh-fingerprint/
#
# 2024-10-27 (match)
# ssh-keygen -lf <(ssh-keyscan codeberg.org 2>/dev/null)
#   2048 SHA256:6QQmYi4ppFS4/+zSZ5S4IU+4sa6rwvQ4PbhCtPEBekQ codeberg.org (RSA)
#   256 SHA256:T9FYDEHELhVkulEKKwge5aVhVTbqCW0MIRwAfpARs/E codeberg.org (ECDSA)
#   256 SHA256:mIlxA9k46MmM6qdJOdMnAQpzGxF4WIVVL+fj+wZbw0g codeberg.org (ED25519)
codeberg.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB
codeberg.org ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBL2pDxWr18SoiDJCGZ5LmxPygTlPu+cCKSkpqkvCyQzl5xmIMeKNdfdBpfbCGDPoZQghePzFZkKJNR/v9Win3Sc=
codeberg.org ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8hZi7K1/2E2uBX8gwPRJAHvRAob+3Sn+y2hxiEhN0buv1igjYFTgFO2qQD8vLfU/HT/P/rqvEeTvaDfY1y/vcvQ8+YuUYyTwE2UaVU5aJv89y6PEZBYycaJCPdGIfZlLMmjilh/Sk8IWSEK6dQr+g686lu5cSWrFW60ixWpHpEVB26eRWin3lKYWSQGMwwKv4LwmW3ouqqs4Z4vsqRFqXJ/eCi3yhpT+nOjljXvZKiYTpYajqUC48IHAxTWugrKe1vXWOPxVXXMQEPsaIRc2hpK+v1LmfB7GnEGvF1UAKnEZbUuiD9PBEeD5a1MZQIzcoPWCrTxipEpuXQ5Tni4mN

# sr.ht SSH host keys
# https://man.sr.ht/git.sr.ht/#ssh-host-keys
#
# 2025-07-06 (match)
# ssh-keygen -lf <(ssh-keyscan git.sr.ht 2>/dev/null)
#   2048 SHA256:rvz/I0S1T/9If9+/CU0HDTF8AV4MPu5Gkkxsb7vUTH4 git.sr.ht (RSA)
#   256 SHA256:1nUUjsHH0qwfjI3dYFWlXTjPUP/Un1oo6wfu9YL8tCQ git.sr.ht (ECDSA)
#   256 SHA256:WXXNZu0YyoE3KBl5qh4GsnF1vR0NeEPYJAiPME+P09g git.sr.ht (ED25519)
git.sr.ht ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ+l/lvYmaeOAPeijHL8d4794Am0MOvmXPyvHTtrqvgmvCJB8pen/qkQX2S1fgl9VkMGSNxbp7NF7HmKgs5ajTGV9mB5A5zq+161lcp5+f1qmn3Dp1MWKp/AzejWXKW+dwPBd3kkudDBA1fa3uK6g1gK5nLw3qcuv/V4emX9zv3P2ZNlq9XRvBxGY2KzaCyCXVkL48RVTTJJnYbVdRuq8/jQkDRA8lHvGvKI+jqnljmZi2aIrK9OGT2gkCtfyTw2GvNDV6aZ0bEza7nDLU/I+xmByAOO79R1Uk4EYCvSc1WXDZqhiuO2sZRmVxa0pQSBDn1DB3rpvqPYW+UvKB3SOz
git.sr.ht ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCj6y+cJlqK3BHZRLZuM+KP2zGPrh4H66DacfliU1E2DHAd1GGwF4g1jwu3L8gOZUTIvUptqWTkmglpYhFp4Iy4=
git.sr.ht ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60
EOF
set -e

# Configure SSH known hosts file once on sourcing
git_mirror_set_ssh_known_hosts
