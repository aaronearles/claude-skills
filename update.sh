#!/bin/bash
# Pulls the latest claude-skills from any working directory
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
git -C "$REPO_DIR" pull
