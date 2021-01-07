#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

$DIR/highlight.sh

hugo --baseURL https://docs.hofstadter.io/ -d dist

