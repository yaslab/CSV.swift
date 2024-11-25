#!/usr/bin/env zsh

set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)

swift format --in-place --parallel --recursive "$SCRIPT_DIR"
