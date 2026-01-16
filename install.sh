#!/bin/bash

# Z-Audit Installer
# Installs the Z-Audit skill, command, and subagent for Claude Code

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing Z-Audit..."
echo ""

# Create directories if they don't exist
mkdir -p "$CLAUDE_DIR/skills/z-audit"
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/agents"

# Copy skill
cp "$SCRIPT_DIR/skill/skill.md" "$CLAUDE_DIR/skills/z-audit/"
echo "Skill installed to $CLAUDE_DIR/skills/z-audit/"

# Copy command
cp "$SCRIPT_DIR/command/z-audit.md" "$CLAUDE_DIR/commands/"
echo "Command installed to $CLAUDE_DIR/commands/"

# Copy subagent
cp "$SCRIPT_DIR/agent/z-audit-subagent.md" "$CLAUDE_DIR/agents/"
echo "Subagent installed to $CLAUDE_DIR/agents/"

echo ""
echo "Z-Audit installed successfully!"
echo ""
echo "Usage:"
echo "  /z-audit https://your-site.com https://your-api.com"
echo "  /z-audit ./your-local-project"
echo "  /z-audit local"
echo ""
echo "Or ask Claude to use z-audit automatically."
