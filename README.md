# ohMyHarness

ohMyHarness 是一套面向 AI 编程 Agent 的工程工作流 skills，重点解决三个问题：

1. 开发前先澄清需求和设计，不直接跳进实现。
2. 实现过程遵循计划、测试、调试、审查和验收流程。
3. 实现完成后，把真实代码和过程发现回流为长期有效的设计文档。

仓库采用标准的 `skills/<name>/SKILL.md` 结构，可通过 [Skills CLI](https://skills.sh/) 同时安装到 Codex、Claude Code 和 OpenCode。

## 一键安装

全局安装全部 skills：

```bash
npx skills add huaka1/oh-my-harness -g -a codex claude-code opencode -s '*' -y
```

也可以使用本仓库提供的交互式 TUI 安装器，不需要先 `git clone`：

```bash
curl -fsSL https://raw.githubusercontent.com/huaka1/oh-my-harness/main/scripts/install.sh | bash
```

完整卸载这套安装器部署的 skills：

```bash
curl -fsSL https://raw.githubusercontent.com/huaka1/oh-my-harness/main/scripts/uninstall.sh | bash
```

查看仓库中可安装的 skills：

```bash
npx skills add huaka1/oh-my-harness --list
```

仓库更新后，同步本机已安装版本：

```bash
npx skills update -g
```

Skills CLI 会自动处理各 Agent 的 skill 目录。Codex 与 OpenCode 通常共享 `~/.agents/skills`，Claude Code 使用 `~/.claude/skills`。

## 核心流程

```text
需求或想法
  -> brainstorming：澄清需求，输出需求或设计文档
  -> writing-plans：生成可执行计划
  -> subagent-driven-development / executing-plans：执行计划
  -> test-driven-development：测试先行
  -> systematic-debugging：按证据定位问题
  -> requesting-code-review：代码审查
  -> verification-before-completion：完成前验证
  -> updating-design：根据真实实现回流设计
  -> finishing-a-development-branch：完成分支收尾
```

`brainstorming` 包含浏览器可视化伴侣，可用于展示 UI 模型、布局对比、架构图和流程图。详细规则位于：

```text
skills/brainstorming/visual-companion.md
```

## Skills

| Skill | 用途 |
| --- | --- |
| `using-superpowers` | 建立 skill 的发现和使用规则。名称为兼容上游工作流暂时保留。 |
| `brainstorming` | 澄清需求、比较方案、输出 feature 文档。 |
| `writing-plans` | 把需求拆成可执行、可验证的实现计划。 |
| `using-git-worktrees` | 在隔离 worktree 中开展功能开发。 |
| `subagent-driven-development` | 在当前会话中按 task 调度子 Agent 实现。 |
| `executing-plans` | 在独立会话中分批执行已有计划。 |
| `dispatching-parallel-agents` | 并行处理彼此独立的任务。 |
| `test-driven-development` | 执行 RED-GREEN-REFACTOR。 |
| `systematic-debugging` | 通过证据、假设和验证定位根因。 |
| `requesting-code-review` | 在交付或合并前发起代码审查。 |
| `receiving-code-review` | 严谨处理代码审查意见。 |
| `verification-before-completion` | 在声称完成前运行验证。 |
| `updating-design` | 根据实际代码、计划和 git diff 回流事实设计。 |
| `finishing-a-development-branch` | 完成测试后处理合并、PR 或清理。 |
| `writing-skills` | 创建、修改和验证 skills。 |

## 项目文档约定片段

ohMyHarness 不要求修改通用 Superpowers skills 来改变文档路径。推荐在目标项目的 `AGENTS.md` 或 `CLAUDE.md` 中加入项目偏好，让这些偏好覆盖通用 skill 的默认路径：

```text
docs/harness/
  feature/     # 已确认的需求
  plan/        # 实现过程中的工作计划
  design/      # 基于真实实现维护的事实设计
  standard/    # 稳定规范
  knowledge/   # 可复用经验和缓存知识
```

核心原则：

- `feature` 说明要解决什么问题。
- `plan` 是可变化的过程方案，不是最终事实。
- `design` 记录实际构建了什么以及为什么这样构建。
- `standard` 和 `knowledge` 保存跨任务可复用的约束与经验。

可直接复制的片段位于：

```text
docs/snippets/agent-docs-harness.md
```

## 仓库定位

本仓库是 **skills-first** 项目：

- 通过 Skills CLI 分发 skills。
- 通用 Superpowers skills 尽量保持上游原版；ohMyHarness 的 `docs/harness` 路径偏好通过目标项目的 `AGENTS.md` / `CLAUDE.md` 片段表达。
- 不发布 Claude、Codex、Cursor、Gemini 或 OpenCode 插件包。
- 不维护独立 npm 包。
- 不复制上游项目的赞助、社区、插件市场和发布流程。

## 验证

检查仓库定位和必要文件：

```bash
bash scripts/check-repo-identity.sh
```

检查 Skills CLI 是否能发现全部 skills：

```bash
npx skills add . --list
```

运行浏览器可视化伴侣测试：

```bash
cd tests/brainstorm-server
npm test
```

## 来源与许可

本仓库中的部分通用工程 skills 基于 [obra/superpowers](https://github.com/obra/superpowers) 修改，并保留其 MIT 许可证和原作者版权声明。

ohMyHarness 在此基础上保留自有增量能力，例如设计回流，并通过项目级 `AGENTS.md` / `CLAUDE.md` 片段提供 `docs/harness` 文档约定。

详见 [LICENSE](./LICENSE)。
