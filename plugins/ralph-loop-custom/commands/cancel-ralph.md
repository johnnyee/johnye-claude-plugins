---
description: "Cancel active Ralph Loop"
allowed-tools: ["Bash(ls .claude/ralph-loop-*.local.md:*)", "Bash(rm .claude/ralph-loop-*.local.md:*)", "Read(.claude/ralph-loop-*.local.md)"]
hide-from-slash-command-tool: "true"
---

# Cancel Ralph

[2026-01-13] 已更新：支持会话隔离的状态文件命名（ralph-loop-{loop_id}.local.md）

To cancel the Ralph loop:

1. List all ralph-loop state files using Bash:
   ```bash
   ls -la .claude/ralph-loop-*.local.md 2>/dev/null || echo "NO_FILES"
   ```

2. **If NO_FILES**: Say "No active Ralph loop found in this directory."

3. **If files exist**:
   - Read each state file to show details (loop_id, iteration, prompt)
   - For each file, extract the loop_id and iteration from the frontmatter
   - Remove all state files:
     ```bash
     rm -f .claude/ralph-loop-*.local.md
     ```
   - Report: "Cancelled N Ralph loop(s): [loop_id_1 at iteration X], [loop_id_2 at iteration Y], ..."

**Note**: Multiple state files may exist if multiple loops were started from this directory (from different sessions or previous runs).
