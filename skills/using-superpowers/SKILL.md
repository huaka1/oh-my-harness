---
name: using-superpowers
description: 在开始任何对话时使用 — 建立如何查找和使用 skill 的规则，要求在任何响应（包括澄清问题）之前调用 Skill 工具
---

<SUBAGENT-STOP>
如果你被调度为子 agent 执行特定任务，跳过此 skill。
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
如果你认为哪怕有 1% 的可能性某个 skill 适用于你正在做的事，你绝对必须调用该 skill。

如果某个 SKILL 适用于你的任务，你别无选择。你必须使用它。

这不可协商。这不可选。你不能为此找借口。
</EXTREMELY-IMPORTANT>

## 指令优先级

Superpowers skill 覆盖默认系统提示行为，但**用户指令总是优先**：

1. **用户的明确指令**（CLAUDE.md、AGENTS.md、直接请求）— 最高优先级
2. **Superpowers skill** — 在与默认系统行为冲突时覆盖
3. **默认系统提示** — 最低优先级

如果 CLAUDE.md 或 AGENTS.md 说"不要用 TDD"而 skill 说"总是用 TDD"，遵循用户指令。用户在控制。

## 如何访问 Skill

**在 Claude Code 中：** 使用 `Skill` 工具。当你调用 skill 时，其内容被加载并展示给你 — 直接遵循它。永远不要用 Read 工具读 skill 文件。

**在 OpenCode 中：** 使用 `Skill` 工具。Skill 从已安装的插件自动发现。

**在其他环境中：** 检查你平台的文档了解如何加载 skill。

# 使用 Skill

## 规则

**在任何响应或操作之前调用相关或请求的 skill。** 哪怕只有 1% 的可能性某个 skill 适用，你也应该调用它来检查。如果调用的 skill 结果不适合当前情况，你不需要使用它。

## Red Flags

这些想法意味着停止 — 你在找借口：

| 想法 | 现实 |
|------|------|
| "这只是一个简单问题" | 问题是任务。检查 skill。 |
| "我需要更多上下文" | Skill 检查在澄清问题之前。 |
| "让我先探索代码库" | Skill 告诉你如何探索。先检查。 |
| "我可以快速检查 git/文件" | 文件缺少对话上下文。先检查 skill。 |
| "让我先收集信息" | Skill 告诉你如何收集信息。 |
| "这不需要正式 skill" | 如果 skill 存在，使用它。 |
| "我记得这个 skill" | Skill 会演变。读当前版本。 |
| "这不算任务" | 操作 = 任务。检查 skill。 |
| "这个 skill 太大材小用了" | 简单的事会变复杂。使用它。 |
| "我先做这一件事" | 在做任何事之前检查。 |
| "这感觉很高效" | 无纪律的操作浪费时间。Skill 防止这个。 |
| "我知道那是什么意思" | 知道概念 ≠ 使用 skill。调用它。 |

## Skill 优先级

当多个 skill 可能适用时，按此顺序：

1. **流程 skill 优先**（brainstorming、debugging）— 这些决定如何处理任务
2. **实现 skill 其次**（frontend-design、mcp-builder）— 这些指导执行

"让我们构建 X" → 先 brainstorming，然后实现 skill。
"修复这个 bug" → 先 debugging，然后领域特定 skill。

## Skill 类型

**严格的**（TDD、debugging）：严格遵循。不要用适应性来绕过纪律。

**灵活的**（模式）：根据上下文调整原则。

Skill 本身会告诉你是哪种。

## 用户指令

指令说什么（WHAT），不是怎么做（HOW）。"添加 X"或"修复 Y"不意味着跳过工作流。
