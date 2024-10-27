#!/bin/bash

# SPDX-FileCopyrightText: 2024 Dominik Wombacher
#
# SPDX-License-Identifier: MIT

echoerr() {
    echo "[ERROR] $*" 1>&2;
    exit 1
}

echoinfo() {
    echo "[INFO] $*"
}
