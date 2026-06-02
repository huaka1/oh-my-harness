---
name: writing-plans
description: 当你有需求或多步骤任务时，在写代码之前使用此 skill
---

# 编写计划

## 概述

编写全面的实现计划，假设工程师对代码库零上下文且品味可疑。记录他们需要知道的一切：每个 task 要改哪些文件、代码、测试、可能需要检查的文档、如何测试。把整个计划作为小粒度 task 给出。DRY。YAGNI。TDD。

假设他们是熟练的开发者，但对我们的工具集或问题领域几乎一无所知。假设他们不太了解好的测试设计。

**开始时宣布：** "我正在使用 writing-plans skill 创建实现计划。"

**上下文：** 如果在隔离的 worktree 中工作，它应该在执行时通过 `using-git-worktrees` skill 创建。

**保存计划到：** `docs/harness/plan/YYYY-MM-DD-<feature-name>-plan.md`
- （用户对计划位置的偏好覆盖此默认值）

**开始前阅读：**
- `docs/harness/standard/` — 项目编码规范
- `docs/harness/design/` — 现有架构设计
- `docs/harness/knowledge/` — 历史 bug 经验和缓存的网页知识

## 范围检查

如果需求覆盖了多个独立子系统，它应该在头脑风暴阶段就被分解为子项目需求。如果没有，建议拆分为独立计划 — 每个子系统一个。每个计划应该能独立产出可运行、可测试的软件。

## 文件结构

在定义 task 之前，先列出将要创建或修改的文件以及每个文件的职责。这是锁定分解决策的地方。

- 设计边界清晰、接口定义良好的单元。每个文件应有一个明确的职责。
- 你对能在上下文中完整容纳的代码推理更好，编辑也更可靠。优先选择更小、更聚焦的文件，而非大而全的文件。
- 一起变更的文件应该放在一起。按职责拆分，而非按技术层。
- 在现有代码库中，遵循已建立的模式。如果代码库使用大文件，不要单方面重构 — 但如果你正在修改的文件已经变得难以管理，在计划中包含拆分是合理的。

这个结构指导 task 分解。每个 task 应产出独立有意义的自包含变更。

## 小粒度 Task

**每步是一个操作（2-5 分钟）：**
- "写失败的测试" — 一步
- "运行它确保失败" — 一步
- "实现最小代码让测试通过" — 一步
- "运行测试确保通过" — 一步

## 计划文档头

**每个计划必须以此头开始：**

```markdown
# [功能名称] 实现计划

> **给 agent 工作者：** 必须使用 subagent-driven-development（推荐）或 executing-plans 来逐 task 实现此计划。步骤使用 checkbox（`- [ ]`）语法跟踪。

**目标：** [一句话描述构建什么]

**架构：** [2-3 句话描述方案]

**技术栈：** [关键技术/库]

---
```

## Task 结构

````markdown
### Task N: [组件名称]

**文件：**
- 创建：`exact/path/to/file.py`
- 修改：`exact/path/to/existing.py:123-145`
- 测试：`tests/exact/path/to/test.py`

- [ ] **Step 1: 写失败的测试**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: 运行测试验证失败**

运行：`pytest tests/path/test.py::test_name -v`
预期：FAIL，提示 "function not defined"

- [ ] **Step 3: 写最小实现**

```python
def function(input):
    return expected
```

- [ ] **Step 4: 运行测试验证通过**

运行：`pytest tests/path/test.py::test_name -v`
预期：PASS
````

## 禁止占位符

每步必须包含工程师需要的实际内容。以下是**计划失败** — 永远不要写它们：
- "TBD"、"TODO"、"稍后实现"、"填写细节"
- "添加适当的错误处理" / "添加验证" / "处理边界情况"
- "为上述写测试"（没有实际测试代码）
- "类似 Task N"（重复代码 — 工程师可能不按顺序阅读 task）
- 描述做什么但不展示如何做的步骤（代码步骤需要代码块）
- 引用任何 task 中未定义的类型、函数或方法

## 记住
- 总是精确文件路径
- 每步都有完整代码 — 如果步骤改了代码，展示代码
- 精确命令及预期输出
- DRY、YAGNI、TDD

## 自检

写完完整计划后，用全新视角对照需求检查计划。这是你自己运行的检查表 — 不是子 agent 调度。

**1. 需求覆盖：** 浏览需求中的每个部分/要求。你能指出实现它的 task 吗？列出任何缺口。

**2. 占位符扫描：** 在计划中搜索红旗 — 上述"禁止占位符"部分的任何模式。修复它们。

**3. 类型一致性：** 你在后面 task 中使用的类型、方法签名和属性名是否与前面 task 中定义的一致？Task 3 中叫 `clearLayers()` 但 Task 7 中叫 `clearFullLayers()` 就是 bug。

发现问题直接修复。不需要重新审阅 — 修完继续。如果发现需求中有对应 task 的要求，添加 task。

## 执行交接

保存计划后，提供执行选择：

**"计划已完成并保存到 `docs/harness/plan/<filename>.md`。两种执行方式：**

**1. 子 Agent 驱动（推荐）** — 我为每个 task 调度一个全新子 agent，task 之间审阅，快速迭代

**2. 内联执行** — 在当前 session 中使用 executing-plans 执行，批量执行带检查点

**选哪种？"**

**如果选择子 Agent 驱动：**
- **必须使用 SUB-SKILL：** subagent-driven-development
- 每个 task 全新子 agent + 两阶段审阅

**如果选择内联执行：**
- **必须使用 SUB-SKILL：** executing-plans
- 批量执行带审阅检查点
