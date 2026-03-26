# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal Claude Code skills repository. Skills are defined in `skills/<name>/SKILL.md` and symlinked into `~/.claude/skills/` via the install scripts. Claude automatically applies the relevant skill based on the context of each task.

## Skill File Format

Each `skills/<name>/SKILL.md` requires YAML frontmatter followed by standards content:

```yaml
---
name: your-skill-name
description: >
  Describe when Claude should automatically apply this skill.
  Be specific about file types, tasks, and trigger conditions.
---
```

The `description` field controls when Claude auto-applies the skill — be precise about trigger conditions.

## Common Tasks

### Add a new skill
1. Create `skills/<name>/SKILL.md` with the frontmatter above and standards content below it
2. Re-run the install script to create the symlink

### Update a skill
Edit `skills/<name>/SKILL.md` directly. Changes apply immediately via the symlink — no reinstall needed.

### Install / re-install symlinks

**Linux/macOS:**
```bash
./install.sh
```

**Windows (PowerShell — requires Developer Mode or Administrator):**
```powershell
.\install.ps1
```

Both scripts symlink each `skills/<name>/` directory into `~/.claude/skills/`. Existing symlinks are replaced; non-symlink conflicts are skipped with a warning.

After installing, restart Claude to pick up new skills.

### Azure CLI
Use `az -h` to discover available commands.
