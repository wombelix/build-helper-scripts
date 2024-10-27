#!/bin/bash

# SPDX-FileCopyrightText: 2024 Dominik Wombacher
#
# SPDX-License-Identifier: MIT

export RC=0

echoerr() {
    echo "[ERROR] $*" 1>&2;
    RC=1
}

echoinfo() {
    echo "[INFO] $*"
}
