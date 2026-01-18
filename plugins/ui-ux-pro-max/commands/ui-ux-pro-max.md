---
description: "UI/UX design intelligence - search styles, colors, fonts, and generate design systems"
argument-hint: "[QUERY] [--design-system] [--domain DOMAIN] [--stack STACK]"
allowed-tools: ["Bash(python3 ${CLAUDE_PLUGIN_ROOT}/scripts/*.py:*)"]
---

# UI/UX Pro Max Command

Read and follow the comprehensive instructions from `SKILL.md` in the plugin directory.

## Quick Usage

### Generate Design System (Recommended)
```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/search.py" "$ARGUMENTS" --design-system
```

### Domain Search
```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/search.py" "$ARGUMENTS"
```

### Stack-Specific Guidelines
```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/search.py" "$ARGUMENTS" --stack html-tailwind
```

## Available Options

- `--design-system` - Generate complete design system recommendation
- `--domain <domain>` - Search specific domain (style, color, typography, ux, etc.)
- `--stack <stack>` - Get stack-specific guidelines (html-tailwind, react, nextjs, vue, etc.)
- `--persist` - Save design system to design-system/MASTER.md
- `--page <name>` - Create page-specific override file
- `-p <name>` - Project name for design system output
- `-f <format>` - Output format (ascii or markdown)
- `-n <number>` - Max results (default: 3)

## Examples

```bash
# Generate design system for SaaS dashboard
/ui-ux-pro-max "SaaS dashboard modern" --design-system -p "My Project"

# Search for glassmorphism style
/ui-ux-pro-max "glassmorphism" --domain style

# Get React performance guidelines
/ui-ux-pro-max "performance optimization" --stack react

# Search for color palettes
/ui-ux-pro-max "fintech professional" --domain color
```

For detailed documentation, see `SKILL.md` in the plugin directory.
