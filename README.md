# claude-skills

Personal Claude Code skills — coding standards and best practices that travel across machines. Claude automatically applies the relevant skill when working with each technology.

## Installation

**Linux/macOS:**
```bash
git clone git@github.com:aaronearles/claude-skills.git ~/claude-skills
~/claude-skills/install.sh
```

**Windows (PowerShell):**
```powershell
git clone git@github.com:aaronearles/claude-skills.git "$HOME\claude-skills"
& "$HOME\claude-skills\install.ps1"
```

Symlinks skills into `~/.claude/skills/`. Re-run after adding new skills.

## Updating

After installing, an `update-skills` shell function is added to your `~/.bashrc` / `~/.zshrc` (or `$PROFILE` on Windows). Run it from anywhere:

```bash
update-skills
```

Or call the script directly without the alias:

```bash
~/claude-skills/update.sh       # Linux/macOS
& "$HOME\claude-skills\update.ps1"  # Windows
```

## Skills

| Skill | Triggers automatically when... |
|-------|-------------------------------|
| docker | Writing, reviewing, or scaffolding any Docker Compose file, Dockerfile, or Traefik configuration |
| powershell | Writing, reviewing, or scaffolding any PowerShell script or module |
| ansible | Writing, reviewing, or scaffolding any Ansible playbook, role, or Molecule test |
| bash | Writing, reviewing, or scaffolding any Bash/shell script |
| terraform | Writing, reviewing, or scaffolding any Terraform configuration or module |

## Adding a New Skill

1. Create `skills/<name>/SKILL.md` with YAML frontmatter:
   ```yaml
   ---
   name: your-skill-name
   description: >
     Describe when Claude should automatically apply this skill.
     Be specific about file types, tasks, and trigger conditions.
   ---
   ```
2. Add your standards content below the frontmatter
3. Re-run `install.sh` / `install.ps1` to symlink the new skill
4. Commit and push
