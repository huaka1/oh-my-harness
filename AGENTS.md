# ohMyHarness 仓库规则

本仓库只维护可通过 Skills CLI 安装的 skills。

## 修改原则

1. 保持 `skills/<name>/SKILL.md` 标准结构。
2. 人类阅读的仓库文档默认使用中文；skill 内部可按现有语言维护。
3. 不重新引入 Claude、Codex、Cursor、Gemini 或 OpenCode 插件包装。
4. 不重新引入 npm 包、上游赞助信息、社区链接或发布同步脚本。
5. 修改 skill 后必须运行对应校验和 `bash scripts/check-repo-identity.sh`。
6. 发布前运行 `npx skills add . --list`，确认 Skills CLI 能发现全部 skills。

## 来源边界

部分 skills 来源于 `obra/superpowers`。保留 LICENSE 和必要的技术归属，但仓库品牌、安装说明和维护规则必须指向 ohMyHarness。
