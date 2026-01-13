---
name: planning-with-files
version: "2.1.3"
description: This skill should be used when the user asks to "create a plan", "make a task plan", "plan this task", "规划任务", "创建计划", "制定计划", "任务规划", "写个计划", "帮我规划", "分步骤执行", "多步骤任务", "复杂任务", or needs Manus-style file-based planning with task_plan.md, findings.md, and progress.md for complex multi-step tasks, research projects, or any task requiring >5 tool calls.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - WebFetch
  - WebSearch
hooks:
  SessionStart:
    - hooks:
        - type: command
          command: "echo '[planning-with-files] Ready. Auto-activates for complex tasks, or invoke manually with /planning-with-files'"
  PreToolUse:
    - matcher: "Write|Edit|Bash"
      hooks:
        - type: command
          command: "cat task_plan.md 2>/dev/null | head -30 || true"
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "echo '[planning-with-files] File updated. If this completes a phase, update task_plan.md status.'"
  Stop:
    - hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/scripts/check-complete.sh"
---

# Planning with Files

像 Manus 一样工作：使用持久化的 Markdown 文件作为你的"磁盘上的工作记忆"。

---

## ⚠️ 首要任务：检测旧规划文件

**在开始任何工作之前，你必须先检查项目根目录是否存在以下文件：**
- `task_plan.md`
- `findings.md`
- `progress.md`

### 检测逻辑

```
如果用户参数包含 "--clean"：
  → 直接删除旧文件，创建新文件，开始新任务

如果检测到任意规划文件已存在：
  → 使用 AskUserQuestion 询问用户：
    1. "继续上次任务" - 读取现有文件，继续执行
    2. "归档并开始新任务" - 将旧文件移动到 .planning/archived/YYYYMMDD_HHMMSS/，然后创建新文件
    3. "覆盖并开始新任务" - 直接删除旧文件，创建新文件

如果没有检测到规划文件：
  → 直接创建新文件，开始新任务
```

### 归档目录结构

```
.planning/
└── archived/
    ├── 20260113_143000/
    │   ├── task_plan.md
    │   ├── findings.md
    │   └── progress.md
    └── 20260114_091500/
        └── ...
```

---

## 重要：文件存放位置

| 位置 | 存放内容 |
|------|----------|
| 技能目录 (`${CLAUDE_PLUGIN_ROOT}/`) | 模板、脚本、参考文档 |
| 你的项目目录 | `task_plan.md`, `findings.md`, `progress.md` |

> **注意**：规划文件应创建在你的项目根目录，而不是技能安装目录。

---

## 核心原则

```
Context Window = RAM (易失、有限)
Filesystem = Disk (持久、无限)

→ 重要内容必须写入磁盘
```

---

## 快速开始

处理完旧文件后，执行以下步骤：

1. **创建 `task_plan.md`** — 参考 [templates/task_plan.md](templates/task_plan.md)
2. **创建 `findings.md`** — 参考 [templates/findings.md](templates/findings.md)
3. **创建 `progress.md`** — 参考 [templates/progress.md](templates/progress.md)
4. **决策前重读计划** — 刷新注意力窗口中的目标
5. **每个阶段后更新** — 标记完成，记录错误

---

## 文件用途

| 文件 | 用途 | 更新时机 |
|------|------|----------|
| `task_plan.md` | 阶段、进度、决策 | 每个阶段后 |
| `findings.md` | 研究、发现 | 任何发现后 |
| `progress.md` | 会话日志、测试结果 | 整个会话中 |

---

## 关键规则

### 1. 先创建计划
复杂任务必须先有 `task_plan.md`，不可妥协。

### 2. 2-Action 规则
> "每 2 次浏览/搜索操作后，立即将关键发现保存到文件。"

防止视觉/多模态信息丢失。

### 3. 决策前读取
重大决策前读取计划文件，保持目标在注意力窗口中。

### 4. 行动后更新
完成任何阶段后：
- 标记阶段状态：`in_progress` → `complete`
- 记录遇到的错误
- 记录创建/修改的文件

### 5. 记录所有错误
每个错误都写入计划文件，积累知识，防止重复。

```markdown
## 遇到的错误
| 错误 | 尝试次数 | 解决方案 |
|------|----------|----------|
| FileNotFoundError | 1 | 创建默认配置 |
| API timeout | 2 | 添加重试逻辑 |
```

### 6. 永不重复失败
```
if action_failed:
    next_action != same_action
```
追踪尝试过的方法，变换策略。

---

## 3-Strike 错误协议

```
尝试 1: 诊断 & 修复
  → 仔细阅读错误
  → 定位根因
  → 针对性修复

尝试 2: 替代方案
  → 同样错误？尝试不同方法
  → 不同工具？不同库？
  → 绝不重复完全相同的失败操作

尝试 3: 重新思考
  → 质疑假设
  → 搜索解决方案
  → 考虑更新计划

3 次失败后: 向用户求助
  → 解释尝试过的方法
  → 分享具体错误
  → 请求指导
```

---

## 读写决策矩阵

| 场景 | 操作 | 原因 |
|------|------|------|
| 刚写完文件 | 不要读取 | 内容仍在上下文中 |
| 查看了图片/PDF | 立即写入发现 | 多模态信息会丢失 |
| 浏览器返回数据 | 写入文件 | 截图不会持久化 |
| 开始新阶段 | 读取计划/发现 | 重新定向（如果上下文过期） |
| 发生错误 | 读取相关文件 | 需要当前状态来修复 |
| 间隔后恢复 | 读取所有规划文件 | 恢复状态 |

---

## 5问重启测试

如果你能回答这些问题，说明上下文管理良好：

| 问题 | 答案来源 |
|------|----------|
| 我在哪？ | task_plan.md 中的当前阶段 |
| 我要去哪？ | 剩余阶段 |
| 目标是什么？ | 计划中的目标声明 |
| 我学到了什么？ | findings.md |
| 我做了什么？ | progress.md |

---

## 何时使用此模式

**使用场景：**
- 多步骤任务（3+ 步骤）
- 研究任务
- 构建/创建项目
- 跨越多次工具调用的任务
- 任何需要组织的任务

**跳过场景：**
- 简单问题
- 单文件编辑
- 快速查询

---

## 模板位置

- `templates/task_plan.md` — 阶段追踪
- `templates/findings.md` — 研究存储
- `templates/progress.md` — 会话日志

---

## 反模式

| 不要这样做 | 应该这样做 |
|------------|------------|
| 用 TodoWrite 做持久化 | 创建 task_plan.md 文件 |
| 只说一次目标就忘记 | 决策前重读计划 |
| 隐藏错误默默重试 | 将错误记录到计划文件 |
| 把所有内容塞进上下文 | 将大内容存储到文件 |
| 立即开始执行 | 先创建计划文件 |
| 重复失败的操作 | 追踪尝试，变换策略 |
| 在技能目录创建文件 | 在项目目录创建文件 |

---

## 高级主题

- **Manus 原则**：参见 [reference.md](reference.md)
- **实际示例**：参见 [examples.md](examples.md)
