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

# Inject update-skills shell function into .bashrc / .zshrc
_FUNCTION_BLOCK='
# BEGIN claude-skills
update-skills() {
    local skill_link target repo
    skill_link=$(ls -d ~/.claude/skills/*/ 2>/dev/null | head -1)
    if [[ -z "$skill_link" ]]; then
        echo "update-skills: no skills found in ~/.claude/skills/" >&2
        return 1
    fi
    target=$(readlink "${skill_link%/}")
    repo=$(git -C "$target" rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$repo" ]]; then
        echo "update-skills: could not locate git repo from $target" >&2
        return 1
    fi
    git -C "$repo" pull
}
# END claude-skills'

for rc_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [[ -f "$rc_file" ]]; then
        if grep -q '# BEGIN claude-skills' "$rc_file"; then
            echo "update-skills already present in $rc_file — skipping"
        else
            printf '%s\n' "$_FUNCTION_BLOCK" >> "$rc_file"
            echo "Added update-skills to $rc_file"
        fi
    fi
done
echo "Run 'source ~/.bashrc' (or open a new shell) to use update-skills."
