---
name: requesting-code-review
description: 完成 task、实现重要 feature 或合并前，用于验证工作是否满足需求
---

# 请求代码审查

调度一个 code reviewer subagent 来在问题扩散之前捕获它们。Reviewer 获得精心设计的上下文进行评估——绝不继承你会话的历史。这使 reviewer 专注于工作产物而非你的思考过程，并为你自己的持续工作保留上下文。

**核心原则：** 早审查，勤审查。

## 何时请求审查

**强制：**
- 在 subagent 驱动开发中每个 task 之后
- 完成重要 feature 之后
- 合并到 main 之前

**可选但有价值：**
- 卡住时（新视角）
- 重构前（基线检查）
- 修复复杂 bug 后

## 如何请求

**1. 获取 git SHA：**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # 或 origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. 调度 code reviewer subagent：**

使用 Task 工具的 `general-purpose` 类型，填写 `code-reviewer.md` 中的模板

**占位符：**
- `{DESCRIPTION}` - 你构建内容的简要摘要
- `{PLAN_OR_REQUIREMENTS}` - 它应该做什么
- `{BASE_SHA}` - 起始提交
- `{HEAD_SHA}` - 结束提交

**3. 根据反馈行动：**
- 立即修复 Critical 问题
- 在继续之前修复 Important 问题
- 记录 Minor 问题留待以后
- 如果 reviewer 有误则反驳（附理由）

## 示例

```
[刚完成 Task 2: 添加验证函数]

You: 让我在继续之前请求代码审查。

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[调度 code reviewer subagent]
  DESCRIPTION: 添加了 verifyIndex() 和 repairIndex()，包含 4 种问题类型
  PLAN_OR_REQUIREMENTS: Task 2 from docs/harness/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent 返回]:
  优点: 架构清晰，真实测试
  问题:
    Important: 缺少进度指示器
    Minor: 报告间隔的魔法数字 (100)
  评估: 可以继续

You: [修复进度指示器]
[继续 Task 3]
```

## 与工作流的集成

**Subagent 驱动开发：**
- 每个 task 后审查
- 在问题累积之前捕获
- 在进入下一个 task 前修复

**执行 Plan：**
- 在每个 task 后或自然检查点审查
- 获取反馈，应用，继续

**临时开发：**
- 合并前审查
- 卡住时审查

## Red Flags

**绝不：**
- 因为"很简单"就跳过审查
- 忽略 Critical 问题
- 带着未修复的 Important 问题继续
- 与有效的技术反馈争论

**如果 reviewer 有误：**
- 用技术推理反驳
- 展示证明其有效的代码/测试
- 请求澄清

参见模板：requesting-code-review/code-reviewer.md
