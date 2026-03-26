#!/bin/bash
# Installs claude skills by symlinking into ~/.claude/skills/
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DEST="$HOME/.claude/skills"

mkdir -p "$SKILLS_DEST"

for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"
    target="$SKILLS_DEST/$skill_name"

    if [[ -L "$target" ]]; then
        rm "$target"
    elif [[ -e "$target" ]]; then
        echo "Warning: $target exists and is not a symlink — skipping $skill_name"
        continue
    fi

    ln -s "$skill_dir" "$target"
    echo "Linked: $skill_name"
done

echo "Done. Restart Claude to pick up changes."
