#!/bin/bash
# Removes claude-skills symlinks from ~/.claude/skills/
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DEST="$HOME/.claude/skills"

for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"
    target="$SKILLS_DEST/$skill_name"

    if [[ -L "$target" ]]; then
        rm "$target"
        echo "Removed: $skill_name"
    elif [[ -e "$target" ]]; then
        echo "Warning: $target exists but is not a symlink — skipping $skill_name"
    fi
done

echo "Done. Restart Claude to apply changes."

# Remove update-skills shell function from .bashrc / .zshrc
for rc_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [[ -f "$rc_file" ]] && grep -q '# BEGIN claude-skills' "$rc_file"; then
        sed '/# BEGIN claude-skills/,/# END claude-skills/d' "$rc_file" > "$rc_file.tmp" && mv "$rc_file.tmp" "$rc_file"
        echo "Removed update-skills from $rc_file"
    fi
done
