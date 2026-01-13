# JohnYe's Claude Code Plugins

JohnYe 的 Claude Code 插件集合仓库。

## 安装方式

```bash
# 添加市场
/plugin marketplace add johnnyee/johnye-claude-plugins

# 安装插件
/plugin install ralph-loop-custom@johnye-plugins
```

## 包含的插件

| 插件名称 | 描述 | 版本 |
|---------|------|------|
| ralph-loop-custom | JohnYe's custom fork of Ralph Loop with parameter shortcuts (-m, -p) and Windows compatibility fixes | 1.0.0 |
| planning-with-files | Manus-style persistent markdown files for planning, progress tracking, and knowledge storage | 2.1.2 |

## 添加新插件

1. 在 `plugins/` 目录下创建新的插件文件夹
2. 添加 `.claude-plugin/plugin.json` 配置文件
3. 在根目录的 `marketplace.json` 中注册新插件

## 目录结构

```
johnye-claude-plugins/
├── .claude-plugin/
│   └── marketplace.json       # 市场清单
├── plugins/
│   └── ralph-loop-custom/
│       ├── .claude-plugin/
│       │   └── plugin.json    # 插件清单
│       ├── commands/          # 命令
│       ├── hooks/             # 钩子
│       └── scripts/           # 脚本
└── README.md
```

## Credits

- **ralph-loop-custom**: Fork of [ralph-loop](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/ralph-loop) from the official [Anthropic Claude Plugins](https://github.com/anthropics/claude-plugins-official) repository.
- **planning-with-files**: Fork of [planning-with-files](https://github.com/OthmanAdi/planning-with-files) by OthmanAdi (MIT License).
