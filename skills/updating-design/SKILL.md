---
name: updating-design
description: 当用户明确要求更新设计、从实现生成设计、将计划与代码对账、或在手动提交前准备事实设计笔记时使用
---

# 设计回流

创建或更新 `docs/harness/design/` 下的设计文档，使其反映实际构建了什么，而非初始计划猜测会发生什么。

设计文档不是 Agent 规则，也不是需求历史。它是人和模型理解项目事实背景的入口：先读索引，再读全景，再按领域下钻。

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
- 领域设计在 `docs/harness/design/<domain>.md`
- 复杂细节可放在 `docs/harness/design/details/<topic>.md`
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
   - 找到现有 `docs/harness/design/README.md`、`overview.md` 和相关领域设计

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
   - 默认按中粒度领域维护单文件，例如 `browser.md`、`auth.md`、`agent-runtime.md`、`cache.md`、`operations.md`
   - 不默认创建领域目录。只有当领域文档超过约 300-500 行，或出现多个独立复杂机制时，才创建 `details/<topic>.md` 下钻
   - 不按日期或需求名创建 design 文件。需求名属于 `feature/` 和 `plan/`，design 按领域和长期概念命名
   - 每次新增、删除、移动 design 文档，必须同步更新 `docs/harness/design/README.md`
   - 重写过时部分而非追加矛盾历史
   - 用事实现在时写
   - 优先写最终行为、边界、数据流、接口、约束和权衡
   - 避免大段代码片段和显而易见的逐文件实现细节

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

这是项目设计文档入口。需要理解项目背景时，先读本文件，再读 `overview.md`，最后按领域进入具体文档。

## 推荐阅读顺序

1. `overview.md`：系统全景、核心链路、主要领域和关键约束
2. 相关领域文档：如 `browser.md`、`auth.md`、`cache.md`
3. `details/`：只有需要机制细节时再读

## 领域

- `browser.md`：浏览器运行、CDP、用户隔离、SSO 注入、登录态刷新
- `auth.md`：用户身份、登录态、TGT 获取、签名
- `agent-runtime.md`：Agent 会话、工具调用、上下文传播
- `cache.md`：Redis key、TTL、缓存降级
- `operations.md`：安装、启动、部署、运行约束

## 阅读路径

- 要理解浏览器免登：读 `overview.md` → `browser.md` → `auth.md`
- 要理解缓存：读 `overview.md` → `cache.md`
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

### 领域设计模板

```markdown
# [领域] 设计

## 职责

本领域负责什么，边界在哪里，不负责什么。

## 当前行为

## 架构和流程

## 关键决策

## 约束和权衡

## 已知限制

## 相关代码
```

### 细节下钻模板

```markdown
# [复杂机制] 设计细节

只有当领域文档过长或机制非常复杂时才创建。

## 背景

## 机制

## 边界条件

## 验证方式
```

## 粒度准则

- `overview.md` 让人获得全景，不承载全部细节
- 领域文档是默认承载单位，优先保持 100-300 行左右
- `details/` 是例外，不是默认；只有复杂机制才拆进去
- 避免两个极端：每需求一篇太散，过度拆分太碎
```

### 主题片段模板

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
