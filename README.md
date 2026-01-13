# JohnYe's Claude Code Plugins

JohnYe 的 Claude Code 插件集合仓库。

## 安装方式

```bash
# 添加市场
/plugin marketplace add johnnyee/johnye-claude-plugins

# 安装插件（选择你需要的）
/plugin install ralph-loop-custom@johnye-plugins
/plugin install planning-with-files@johnye-plugins
```

## 插件列表

### 1. ralph-loop-custom

> JohnYe 定制版 Ralph Loop，支持参数快捷方式和 Windows 兼容性修复

| 属性 | 值 |
|------|-----|
| 版本 | 1.0.0 |
| 功能 | 持续自引用 AI 循环，用于迭代开发 |
| 特点 | 参数快捷方式 (-m, -p)、Windows 兼容性修复 |

**命令**：
- `/ralph-loop` - 启动 Ralph Loop
- `/cancel-ralph` - 取消活动的 Ralph Loop
- `/help` - 获取帮助

---

### 2. planning-with-files

> Manus 风格的文件规划系统，使用持久化 Markdown 文件作为"磁盘上的工作记忆"

| 属性 | 值 |
|------|-----|
| 版本 | 2.1.2 |
| 功能 | 任务规划、进度追踪、知识存储 |
| 文件 | task_plan.md, findings.md, progress.md |

**命令**：
- `/planning-with-files [任务描述]` - 启动文件规划系统

**触发词**（自动激活）：
- 中文：规划任务、创建计划、制定计划、任务规划、写个计划、帮我规划、分步骤执行、多步骤任务、复杂任务
- English: create a plan, make a task plan, plan this task

**核心原则**：
```
Context Window = RAM (易失、有限)
Filesystem = Disk (持久、无限)
→ 重要内容必须写入磁盘
```

---

## 目录结构

```
johnye-claude-plugins/
├── .claude-plugin/
│   └── marketplace.json          # 市场清单
├── plugins/
│   ├── ralph-loop-custom/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json       # 插件配置
│   │   ├── commands/             # 命令定义
│   │   ├── hooks/                # 钩子脚本
│   │   └── scripts/              # 辅助脚本
│   └── planning-with-files/
│       ├── .claude-plugin/
│       │   └── plugin.json       # 插件配置
│       ├── commands/             # 命令定义
│       ├── templates/            # 规划文件模板
│       ├── scripts/              # 辅助脚本
│       ├── SKILL.md              # 技能文档
│       ├── reference.md          # Manus 原则参考
│       └── examples.md           # 使用示例
└── README.md
```

## 添加新插件

1. 在 `plugins/` 目录下创建新的插件文件夹
2. 添加 `.claude-plugin/plugin.json` 配置文件
3. 在根目录的 `.claude-plugin/marketplace.json` 中注册新插件

## Credits

- **ralph-loop-custom**: Fork of [ralph-loop](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/ralph-loop) from the official [Anthropic Claude Plugins](https://github.com/anthropics/claude-plugins-official) repository.
- **planning-with-files**: Fork of [planning-with-files](https://github.com/OthmanAdi/planning-with-files) by OthmanAdi (MIT License).

## License

MIT
