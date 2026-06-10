---
name: updating-design
description: 当用户明确要求更新设计、从实现生成设计、将计划与代码对账、或在手动提交前准备事实设计笔记时使用
---

# 设计回流

创建或更新 `docs/harness/design/` 下的设计文档，使其反映实际构建了什么，而非初始计划猜测会发生什么。

设计文档不是 Agent 规则，也不是需求历史。它是人和模型理解项目事实背景的入口：先读索引，再读全景，再按领域阅读完整方案。

Design 的默认产物是“方案说明书 + 当前事实架构”，不是摘要。每篇 design 应解释背景、概念、架构、数据流、实现要点、决策原因、边界限制和代码位置，让新人能接手，让模型能正确修改。

此 skill 由用户触发。不要因为代码变更了或用户说他们会手动提交就自动运行。

<HARD-GATE>
1. 绝对禁止无 git diff 时编造变更。`git diff --stat` 为空时告知用户"没有未提交的变更。设计文档是最新的。"并停止。
2. 绝对禁止覆盖 standard/ 文件。`docs/harness/standard/` 下的文件只追加，不修改或删除已有内容。
3. 绝对禁止 git 写入操作。不执行 git add、git commit、git push。可读取 git diff、git log、git status。
4. 绝对禁止自动调用其他 skill。更新完成后报告并停止。
</HARD-GATE>

## 输入

- 活跃计划在 `docs/harness/plan/*.md`
- 当前 git diff 和最近提交
- 设计入口在 `docs/harness/design/README.md`
- 全景设计在 `docs/harness/design/overview.md`
- 领域索引在 `docs/harness/design/<domain>/README.md`
- 方案设计在 `docs/harness/design/<domain>/<mechanism>.md`
- 不使用日期或需求名作为 design 文件名
- 相关规范在 `docs/harness/standard/`

如果有多个活跃计划，问用哪个。如果没有活跃计划，说明没有可对工作面，询问用户是否要直接从 `git diff` 生成设计。

## Bug 定义

Bug 是任何发现的预期与实际行为之间的不匹配，且改变或阻塞了实现：

- 失败的测试、运行时错误、回归、损坏的 UI 流程、不正确的 API 行为
- 请求、计划或实现方法中的错误假设
- 在工作期间发现的依赖、平台、权限、数据或环境约束
- 应成为未来标准的重复 AI/操作者错误

临时错误在计划活跃时属于计划。只有持久知识才能存活到设计或标准中。

## 流程

1. **查找上下文**
   - 读取相关 `docs/harness/standard/*.md`
   - 找到活跃的 `docs/harness/plan/*.md`
   - 找到现有 `docs/harness/design/README.md`、`overview.md` 和相关领域/方案设计

2. **检查实现现实**
   - 运行 `git diff`
   - 运行 `git diff --staged`
   - 运行 `git log --oneline -10`
   - 在编辑设计之前总结实际变更了什么

3. **分类计划发现**
   - 与实现现实匹配的已完成 task：如果它们定义了功能，在设计中总结
   - 改变了方向的已完成 task：在设计中记录最终决策和原因
   - 未完成的 task：不纳入设计，除非它们是已发布行为的已知限制
   - 改变了决策的 bug：用最终决策和原因更新设计
   - 揭示了可复用实践的 bug：添加简短教训到 `docs/harness/standard/lessons.md`
   - 无未来价值的临时 bug：计划保留，不写入设计

4. **创建或更新设计**
   - 永远先读取 `docs/harness/design/README.md`。如果不存在，创建它作为入口 map
   - 默认维护 `docs/harness/design/overview.md`，让人能一次读懂系统全景、核心链路和主要约束
   - 按领域建立目录，例如 `browser/`、`auth/`、`agent-runtime/`、`cache/`、`operations/`，每个领域必须有 `README.md` 作为局部索引
   - 领域下的文档按“长期机制/方案”命名，例如 `browser/multi-tenant-isolation.md`、`browser/sso-auth-injection.md`、`auth/tgt-background-api.md`
   - 不按日期、需求名、函数名创建 design 文件。需求名属于 `feature/` 和 `plan/`，函数细节属于代码
   - 每次新增、删除、移动 design 文档，必须同步更新 `docs/harness/design/README.md` 和对应领域 `README.md`
   - 重写过时部分而非追加矛盾历史
   - 用事实现在时写
   - 优先写背景、基础概念、架构图、分层设计、关键流程、实现要点、设计决策、边界限制和代码位置
   - 可以引用关键代码片段和文件路径作为证据，但不要粘贴大段实现

5. **消费 resolved bug 的知识去向**
   - 扫描计划文件的 `## Bugs and Findings` 区
   - 处理所有 `[x]`（已解决）bug 的 `知识去向` 字段：
     - `design` → 在对应 design 文件中记录决策和原因
     - `standard` → 追加到 `docs/harness/standard/` 下对应文件（只追加不覆盖），格式：
       ```markdown
       ## YYYY-MM-DD

       - [教训] 从 bug 中提炼的简短规则。上下文：为什么重要。
       ```
     - `drop` → 不写入任何地方
   - 只处理 `[x]`（已解决）bug。`[~]`（活跃）bug 不处理。

6. **更新 workflow.md**
   - 更新 `docs/harness/workflow.md` 状态为"空闲"
   - 在历史区追加记录

7. **报告**
   - 说明创建或更新了哪个设计文件
   - 说明添加了哪些教训
   - 说明有多少 bug 的知识被消费（分别写入了哪些位置）
   - 不要 commit，除非用户明确要求

## 设计模板

### 入口索引模板

```markdown
# Design Map

这是项目设计文档入口。需要理解项目背景时，先读本文件，再读 `overview.md`，最后按领域进入具体方案文档。

## 推荐阅读顺序

1. `overview.md`：系统全景、核心链路、主要领域和关键约束
2. 相关领域索引：如 `browser/README.md`、`auth/README.md`
3. 具体方案文档：如 `browser/multi-tenant-isolation.md`

## 领域

- `browser/`：浏览器运行、CDP、用户隔离、SSO 注入、登录态刷新
- `auth/`：用户身份、登录态、TGT 获取、签名
- `agent-runtime/`：Agent 会话、工具调用、上下文传播
- `cache/`：Redis key、TTL、缓存降级
- `operations/`：安装、启动、部署、运行约束

## 阅读路径

- 要理解浏览器免登：读 `overview.md` → `browser/README.md` → `browser/sso-auth-injection.md` → `auth/tgt-background-api.md`
- 要理解多租户隔离：读 `overview.md` → `browser/multi-tenant-isolation.md`
- 要理解缓存：读 `overview.md` → `cache/README.md`
```

### 全景设计模板

```markdown
# [项目名] 设计概览

## 系统目标

## 核心链路

## 主要领域

## 关键约束

## 已知限制
```

### 领域索引模板

```markdown
# [Domain] Design

本领域负责什么，边界在哪里，不负责什么。

## 方案文档

- `mechanism.md`：一句话说明解决什么问题

## 相关代码
```

### 方案设计模板

```markdown
# [机制/方案] 方案

## 背景

为什么需要这个机制？解决什么问题？

## 基础概念

读者理解方案前必须知道哪些组件、术语、外部系统？

## 架构

整体结构图或组件关系。

## 设计分层

每一层解决什么问题，边界是什么？

## 关键流程

请求、数据、状态如何流动？

## 实现要点

改了哪些模块，关键逻辑是什么？引用关键代码位置或少量代码片段。

## 设计决策

为什么这样做？为什么不用其他方案？

## 边界和限制

哪些场景不支持？失败时如何降级？

## 验证方式

如何证明方案有效？

## 代码位置

相关文件、函数、模块。
```

## 粒度准则

- 一个长期机制或可独立解释的方案 = 一篇 design
- 例如：`multi-tenant-isolation.md`、`sso-auth-injection.md`、`tgt-background-api.md`
- 不要每个需求一篇 design；需求只是触发更新
- 不要把 design 写成 50 行摘要；缺少背景、概念、决策原因和验证方式时不算完整设计
- 不要按函数拆文档；函数细节留在代码里，design 写机制和边界
```

### 领域摘要反例

以下不是完整 design，只是摘要，不要作为默认产物：

```markdown
# Browser 设计

Browser 负责 Chrome、CDP、SSO、隔离。

## 当前行为

几句描述当前行为。
```

它缺少背景、基础概念、架构图、分层设计、改造详解、验证方法和代码证据。

### 主题片段模板（只用于嵌入方案内）

```markdown
# [主题] 设计

## 上下文

发布了什么或变更了什么，来自什么请求。

## 当前行为

代码现在做什么。

## 架构和流程

持久的结构、边界、数据流和重要接口。

## 关键决策

- 决策：
  原因：

## 约束和权衡

- ...

## 已知限制

- ...
```

## 常见错误

- 把初始计划当成真相。计划是证据，不是权威。
- 永远记录每个 bug。只有持久的设计决策和可复用的教训才能存活。
- 太早更新设计。如果实现还在快速变化，在计划中保留笔记直到用户要求对账。
- 自动 commit。此 skill 准备事实设计更新；用户可能手动 commit。
- 把 `CLAUDE.md` 当 design。`CLAUDE.md` 只放 Agent 工作规则；项目事实背景放 `docs/harness/design/`。
- 把每个需求都变成一篇 design。需求是触发更新，design 要按长期领域沉淀。
