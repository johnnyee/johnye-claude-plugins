---
description: "显示 planning-with-files 插件的帮助信息"
---

# Planning with Files - 帮助

## 插件简介

**planning-with-files** 是一个 Manus 风格的文件规划系统，使用持久化的 Markdown 文件作为"磁盘上的工作记忆"。

## 核心理念

```
Context Window = RAM (易失、有限)
Filesystem = Disk (持久、无限)

→ 重要内容必须写入磁盘
```

## 命令列表

| 命令 | 说明 |
|------|------|
| `/planning-with-files:start [任务描述]` | 启动新的规划会话 |
| `/planning-with-files:start --clean` | 清理旧会话，直接开始新任务 |
| `/planning-with-files:help` | 显示此帮助信息 |

## 多会话并发支持

本插件支持同一目录下多个会话并发执行任务：

- 每个会话生成唯一的 `session_id`（8字符十六进制）
- 规划文件存储在 `.planning/{session_id}/` 目录下
- 多个 Claude Code 窗口可以同时运行，互不干扰

## 文件结构

```
.planning/
├── a1b2c3d4/              # 会话1
│   ├── task_plan.md       # 任务计划和进度
│   ├── findings.md        # 研究发现
│   └── progress.md        # 会话日志
├── e5f6g7h8/              # 会话2
│   └── ...
└── archived/              # 归档的旧会话
```

## 关键规则

1. **先创建计划** - 复杂任务必须先有 task_plan.md
2. **2-Action 规则** - 每 2 次搜索/浏览后，立即保存发现
3. **决策前读取** - 重大决策前重读计划文件
4. **行动后更新** - 完成阶段后更新状态
5. **记录所有错误** - 每个错误都写入计划文件
6. **永不重复失败** - 追踪尝试过的方法，变换策略

## 3-Strike 错误协议

```
尝试 1: 诊断 & 修复
尝试 2: 替代方案
尝试 3: 重新思考
3 次失败后: 向用户求助
```

## 何时使用

**适用场景：**
- 多步骤任务（3+ 步骤）
- 研究任务
- 构建/创建项目
- 跨越多次工具调用的任务

**跳过场景：**
- 简单问题
- 单文件编辑
- 快速查询

## 更多信息

详细文档请阅读 SKILL.md：`${CLAUDE_PLUGIN_ROOT}/SKILL.md`
