---
name: finishing-a-development-branch
description: 实现完成、所有测试通过后，需要决定如何整合工作时使用——通过提供合并、PR 或清理的结构化选项来指导开发工作的完成
---

# 完成开发分支

## 概述

通过提供清晰的选项并处理选择的工作流来指导开发工作的完成。

**核心原则：** 验证测试 → 检测环境 → 提供选项 → 执行选择 → 清理。

**开始时宣告：** "我正在使用 finishing-a-development-branch skill 来完成这项工作。"

## 流程

### 第 1 步：验证测试

**在提供选项之前，验证测试通过：**

```bash
# 运行项目的测试套件
npm test / cargo test / pytest / go test ./...
```

**如果测试失败：**
```
测试失败（<N> 个失败）。完成前必须修复：

[显示失败]

在测试通过之前无法继续合并/PR。
```

停止。不要进入第 2 步。

**如果测试通过：** 继续第 2 步。

### 第 2 步：检测环境

**在提供选项之前确定工作空间状态：**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
```

这决定显示哪个菜单以及清理方式：

| 状态 | 菜单 | 清理 |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON`（普通 repo） | 标准 4 个选项 | 无 worktree 需清理 |
| `GIT_DIR != GIT_COMMON`，命名分支 | 标准 4 个选项 | 基于来源（见第 6 步） |
| `GIT_DIR != GIT_COMMON`，detached HEAD | 精简 3 个选项（无合并） | 无清理（外部管理） |

### 第 3 步：确定基础分支

```bash
# 尝试常见的基础分支
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

或询问："这个分支从 main 分出——对吗？"

### 第 4 步：提供选项

**普通 repo 和命名分支 worktree——提供恰好这 4 个选项：**

```
实现完成。你想怎么做？

1. 本地合并回 <base-branch>
2. 保持分支原样（我稍后处理）
3. 丢弃这项工作

选哪个？
```

**Detached HEAD——提供恰好这 3 个选项：**

```
实现完成。你在 detached HEAD 上（外部管理的工作空间）。

1. 保持原样（我稍后处理）
2. 丢弃这项工作

选哪个？
```

**不要添加说明**——保持选项简洁。

### 第 5 步：执行选择

#### 选项 1：本地合并

```bash
# 获取主 repo 根目录以确保 CWD 安全
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# 先合并——在移除任何东西之前验证成功
git checkout <base-branch>
git pull
git merge <feature-branch>

# 在合并结果上验证测试
<test command>

# 仅在合并成功后：清理 worktree（第 6 步），然后删除分支
```

然后：清理 worktree（第 6 步），然后删除分支：

```bash
git branch -d <feature-branch>
```

#### 选项 2：保持原样

报告："保持分支 <name>。Worktree 保留在 <path>。"

**不要清理 worktree。**

#### 选项 3：丢弃

**先确认：**
```
这将永久删除：
- 分支 <name>
- 所有提交：<commit-list>
- Worktree 位于 <path>

输入 'discard' 确认。
```

等待精确确认。

如果确认：
```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

然后：清理 worktree（第 6 步），然后强制删除分支：
```bash
git branch -D <feature-branch>
```

### 第 6 步：清理工作空间

**仅在选项 1 和 3 时运行。** 选项 2 始终保留 worktree。

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

**如果 `GIT_DIR == GIT_COMMON`：** 普通 repo，无 worktree 需清理。完成。

**如果 worktree 路径在 `.worktrees/`、`worktrees/` 或 `~/.config/superpowers/worktrees/` 下：** Superpowers 创建了这个 worktree——我们负责清理。

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git worktree remove "$WORKTREE_PATH"
git worktree prune  # 自愈：清理任何过期注册
```

**否则：** 宿主环境（harness）拥有这个工作空间。不要移除它。如果你的平台提供了 workspace-exit 工具，使用它。否则，保持工作空间不变。

## 快速参考

| 选项 | 合并 | 保持 Worktree | 清理分支 |
|--------|-------|---------------|----------------|
| 1. 本地合并 | 是 | - | 是 |
| 2. 保持原样 | - | 是 | - |
| 3. 丢弃 | - | - | 是（强制） |

## 常见错误

**跳过测试验证**
- **问题：** 合并有问题的代码，创建失败的 PR
- **修复：** 在提供选项之前始终验证测试

**开放式问题**
- **问题：** "接下来做什么？"含义模糊
- **修复：** 提供恰好 4 个结构化选项（detached HEAD 为 3 个）

**在删除 worktree 之前删除分支**
- **问题：** `git branch -d` 失败，因为 worktree 仍然引用该分支
- **修复：** 先合并，移除 worktree，然后删除分支

**从 worktree 内部运行 git worktree remove**
- **问题：** 当 CWD 在被移除的 worktree 内部时命令静默失败
- **修复：** 在 `git worktree remove` 之前始终 `cd` 到主 repo 根目录

**清理 harness 拥有的 worktree**
- **问题：** 移除 harness 创建的 worktree 会导致幽灵状态
- **修复：** 只清理 `.worktrees/`、`worktrees/` 或 `~/.config/superpowers/worktrees/` 下的 worktree

**丢弃时无确认**
- **问题：** 意外删除工作
- **修复：** 要求输入"discard"确认

## Red Flags

**绝不：**
- 在测试失败时继续
- 在未验证合并结果测试的情况下合并
- 在无确认的情况下删除工作
- 在未明确请求的情况下强制推送
- 在确认合并成功之前移除 worktree
- 清理你没有创建的 worktree（来源检查）
- 从 worktree 内部运行 `git worktree remove`

**始终：**
- 在提供选项之前验证测试
- 在显示菜单之前检测环境
- 提供恰好 4 个选项（detached HEAD 为 3 个）
- 为选项 3 获取输入确认
- 仅为选项 1 和 3 清理 worktree
- 在移除 worktree 之前 `cd` 到主 repo 根目录
- 移除后运行 `git worktree prune`
