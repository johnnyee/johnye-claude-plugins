# JohnYe's Claude Code Plugins

这是 JohnYe 的 Claude Code 插件集合仓库。

## 安装方式

```bash
# 添加市场
/plugin marketplace add YourGitHubUsername/johnye-claude-plugins

# 安装插件
/plugin install example-plugin@johnye-plugins
```

## 包含的插件

| 插件名称 | 描述 | 版本 |
|---------|------|------|
| example-plugin | 示例插件 | 1.0.0 |

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
│   └── your-plugin/
│       ├── .claude-plugin/
│       │   └── plugin.json    # 插件清单
│       ├── skills/            # 技能
│       ├── agents/            # 代理
│       └── commands/          # 命令
└── README.md
```
