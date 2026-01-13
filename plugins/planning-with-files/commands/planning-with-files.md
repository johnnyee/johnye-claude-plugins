---
description: "启动 Manus 风格的文件规划系统，创建 task_plan.md、findings.md 和 progress.md"
argument-hint: "[任务描述]"
---

# Planning with Files

你已激活 **Manus 风格文件规划系统**。

## 核心原则

```
Context Window = RAM (易失、有限)
Filesystem = Disk (持久、无限)

→ 重要内容必须写入磁盘
```

## 立即执行

1. **创建 `task_plan.md`** - 任务阶段和进度追踪
2. **创建 `findings.md`** - 研究发现和知识存储
3. **创建 `progress.md`** - 会话日志和测试结果

## 关键规则

| 规则 | 说明 |
|------|------|
| **先创建计划** | 复杂任务必须先有 task_plan.md |
| **2-Action 规则** | 每 2 次搜索/浏览操作后，立即保存发现到文件 |
| **决策前读取** | 重大决策前重新读取计划文件 |
| **行动后更新** | 完成阶段后更新状态：`in_progress` → `complete` |
| **记录所有错误** | 每个错误都记录到计划文件 |

## 文件用途

| 文件 | 用途 | 更新时机 |
|------|------|----------|
| `task_plan.md` | 阶段、进度、决策 | 每个阶段后 |
| `findings.md` | 研究、发现 | 任何发现后 |
| `progress.md` | 会话日志、测试结果 | 整个会话中 |

## 3-Strike 错误协议

```
尝试 1: 诊断 & 修复 → 仔细阅读错误，定位根因，针对性修复
尝试 2: 替代方案 → 同样错误？尝试不同方法/工具/库
尝试 3: 重新思考 → 质疑假设，搜索解决方案，考虑更新计划
3 次失败后: 向用户求助 → 解释尝试过的方法，分享具体错误
```

## 模板位置

- `${CLAUDE_PLUGIN_ROOT}/templates/task_plan.md`
- `${CLAUDE_PLUGIN_ROOT}/templates/findings.md`
- `${CLAUDE_PLUGIN_ROOT}/templates/progress.md`

---

**现在开始**：请描述你的任务，我将为你创建规划文件并开始执行。

如果你提供了任务描述：$ARGUMENTS
