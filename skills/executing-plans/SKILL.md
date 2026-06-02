---
name: executing-plans
description: 当你有写好的实现计划需要在单独 session 中执行并带审阅检查点时使用
---

# 执行计划

## 概述

加载计划，批判性审阅，执行所有 task，完成后报告。

**开始时宣布：** "我正在使用 executing-plans skill 实现这个计划。"

**注意：** 告诉你的用户，如果有子 agent 支持（如 Claude Code 或 Codex），使用 subagent-driven-development 效果更好。

<HARD-GATE>
绝对禁止执行 git add、git commit、git push 或任何写入 git 历史的命令。可以读取 git diff、git log、git status 了解变更状态。git 操作由用户手动管理。
</HARD-GATE>

## 流程

### Step 1: 加载并审阅计划
1. 读取计划文件
2. 批判性审阅 — 识别计划中的任何问题或疑虑
3. 如果有疑虑：在开始之前向用户提出
4. 如果没有疑虑：创建 TodoWrite 并继续

### Step 2: 执行 Task

对每个 task：
1. 标记为 in_progress
2. 严格按每步执行（计划有小粒度步骤）
3. 按指定运行验证
4. 标记为 completed

### Step 3: Bug 记录

遇到任何错误（编译错误、运行时错误、测试失败、行为不符合预期），**先记录再修复**。

在计划文件的 `## Bugs and Findings` 区追加 bug 记录。如果该区域不存在，在计划文件末尾创建。

**Bug 记录格式：**

```markdown
### BUG-NNN: [简短描述]

- **状态:** [~] 活跃 / [x] 已解决
- **现象:** [用户或系统看到了什么异常行为]
- **原因:** [根本原因关键词]
- **影响:** [影响范围和严重程度]
- **修复:** [修复方案或临时 workaround]
- **知识去向:** design | standard | drop
```

**编号规则：** 第一个 bug 为 BUG-001，后续递增。以计划中已有最大编号为基础。

**状态标记：**
- `[~]` — 活跃 bug（尚未解决）
- `[x]` — 已解决 bug

**知识去向：**
- `design` — 项目特定的决策/约束/权衡 → 回流到 design 文件
- `standard` — 可复用的经验教训 → 回流到 standard/ 文件
- `drop` — 临时噪音，无未来价值 → 不写入

### Step 4: 3 次熔断机制

每次记录 bug 之前，执行熔断检查：

1. 构造当前 bug 的签名：现象（前 80 字符）+ 原因（关键词）双重签名
2. 在计划文件的 `## Bugs and Findings` 区搜索已有 bug，匹配签名
3. 如果找到 ≥ 2 个已有 bug 签名匹配（加上当前 bug 共 3 次）：
   - **触发熔断**：不记录当前 bug，停止执行
   - 告知用户：`同一 bug 出现 3 次：{现象}（原因：{原因}）。请审阅并决定下一步。`
4. 如果 < 2 个已有匹配，正常记录 bug 并继续

### Step 5: 完成开发

所有 task 完成并验证后：
- 逐项检查计划的 `## Success Criteria`（如果有），标记达成/未达成
- 更新 `docs/harness/workflow.md` 状态为"执行完成"
- 告知用户：代码变更已就绪，可以手动 review 后 commit。如需更新设计文档，可调用 updating-design skill。
- 不调用任何其他 skill — updating-design 由用户手动触发

## 何时停止并请求帮助

**立即停止执行当：**
- 遇到阻塞（缺少依赖、测试失败、指令不清楚）
- 计划有关键缺口无法开始
- 你不理解某个指令
- 验证反复失败

**请求澄清而不是猜测。**

## 何时回到早期步骤

**回到审阅（Step 1）当：**
- 用户根据你的反馈更新了计划
- 基本方法需要重新思考

**不要强行通过阻塞** — 停下来问。

## 记住
- 先批判性审阅计划
- 严格按计划步骤执行
- 不要跳过验证
- 遇到 bug 先记录再修复
- 同 bug 3 次触发熔断
- 阻塞时停止，不要猜测
- 绝对禁止 git 写入操作
- 完成后调用 updating-design

## 集成

**工作流 skill：**
- **using-git-worktrees** — 确保隔离工作空间
- **writing-plans** — 创建此 skill 执行的计划
- **updating-design** — 完成后进行设计回流
