#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

TAG=$(git rev-parse --short HEAD | tr -d "\n")

cue export $DIR/cuelm.cue -t version=$TAG -e Install | kubectl apply -f -
