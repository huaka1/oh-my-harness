---
name: using-git-worktrees
description: 开始需要与当前工作空间隔离的 feature 工作时，或在执行 implementation plan 之前使用——通过原生工具或 git worktree 后备方案确保隔离工作空间存在
---

# 使用 Git Worktrees

## 概述

确保工作在隔离的工作空间中进行。优先使用平台的原生 worktree 工具。只在没有原生工具时才回退到手动 git worktree。

**核心原则：** 先检测现有隔离。然后使用原生工具。然后回退到 git。绝不与 harness 对抗。

**开始时宣告：** "我正在使用 using-git-worktrees skill 来设置隔离工作空间。"

## 第 0 步：检测现有隔离

**在创建任何东西之前，检查你是否已经在隔离工作空间中。**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule 保护：** `GIT_DIR != GIT_COMMON` 在 git submodule 中也成立。在得出"已经在 worktree 中"的结论之前，验证你不在 submodule 中：

```bash
# 如果返回路径，说明你在 submodule 中，不是 worktree——当作普通 repo 处理
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**如果 `GIT_DIR != GIT_COMMON`（且不是 submodule）：** 你已经在链接的 worktree 中。跳到第 3 步（项目设置）。不要创建另一个 worktree。

报告分支状态：
- 在分支上："已经在隔离工作空间 `<path>` 的分支 `<name>` 上。"
- Detached HEAD："已经在隔离工作空间 `<path>`（detached HEAD，外部管理）。完成时需要创建分支。"

**如果 `GIT_DIR == GIT_COMMON`（或在 submodule 中）：** 你在普通 repo 检出中。

用户是否已在指令中表明了 worktree 偏好？如果没有，在创建 worktree 前征得同意：

> "你想让我设置一个隔离的 worktree 吗？它可以保护你当前的分支不受变更影响。"

尊重任何已声明的偏好，无需询问。如果用户拒绝同意，在原地工作并跳到第 3 步。

## 第 1 步：创建隔离工作空间

**你有两种机制。按此顺序尝试。**

### 1a. 原生 Worktree 工具（首选）

用户已请求隔离工作空间（第 0 步同意）。你是否已有创建 worktree 的方式？可能是名为 `EnterWorktree`、`WorktreeCreate` 的工具，`/worktree` 命令，或 `--worktree` 标志。如果有，使用它并跳到第 3 步。

原生工具自动处理目录放置、分支创建和清理。当你有原生工具时使用 `git worktree add` 会产生 harness 无法看到或管理的幽灵状态。

只有在没有原生 worktree 工具可用时才进入第 1b 步。

### 1b. Git Worktree 后备

**仅在第 1a 步不适用时使用**——你没有原生 worktree 工具。使用 git 手动创建 worktree。

#### 目录选择

按以下优先级顺序。用户明确偏好始终优先于观察到的文件系统状态。

1. **检查你的指令中是否有已声明的 worktree 目录偏好。** 如果用户已指定，直接使用无需询问。

2. **检查是否存在项目本地 worktree 目录：**
   ```bash
   ls -d .worktrees 2>/dev/null     # 首选（隐藏）
   ls -d worktrees 2>/dev/null      # 替代
   ```
   如果找到，使用它。如果都存在，`.worktrees` 优先。

3. **检查是否存在全局目录：**
   ```bash
   project=$(basename "$(git rev-parse --show-toplevel)")
   ls -d ~/.config/superpowers/worktrees/$project 2>/dev/null
   ```
   如果找到，使用它（与遗留全局路径向后兼容）。

4. **如果没有其他可用指导**，默认使用项目根目录的 `.worktrees/`。

#### 安全验证（仅限项目本地目录）

**在创建 worktree 之前必须验证目录已被忽略：**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**如果未被忽略：** 添加到 .gitignore，然后继续。

**为什么关键：** 防止意外将 worktree 内容提交到仓库。

全局目录（`~/.config/superpowers/worktrees/`）无需验证。

#### 创建 Worktree

```bash
project=$(basename "$(git rev-parse --show-toplevel)")

# 根据选择的位置确定路径
# 项目本地: path="$LOCATION/$BRANCH_NAME"
# 全局: path="~/.config/superpowers/worktrees/$project/$BRANCH_NAME"

git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**沙箱后备：** 如果 `git worktree add` 因权限错误（沙箱拒绝）而失败，告诉用户沙箱阻止了 worktree 创建，你将改为在当前目录中工作。然后在原地运行设置和基线测试。

## 第 3 步：项目设置

自动检测并运行相应的设置：

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

## 第 4 步：验证干净基线

运行测试以确保工作空间起始状态干净：

```bash
# 使用项目对应的命令
npm test / cargo test / pytest / go test ./...
```

**如果测试失败：** 报告失败，询问是继续还是调查。

**如果测试通过：** 报告就绪。

### 报告

```
Worktree 就绪，位于 <full-path>
测试通过（<N> 个测试，0 个失败）
准备实现 <feature-name>
```

## 快速参考

| 情况 | 操作 |
|-----------|--------|
| 已在链接的 worktree 中 | 跳过创建（第 0 步） |
| 在 submodule 中 | 当作普通 repo 处理（第 0 步保护） |
| 有原生 worktree 工具 | 使用它（第 1a 步） |
| 无原生工具 | Git worktree 后备（第 1b 步） |
| `.worktrees/` 存在 | 使用它（验证已忽略） |
| `worktrees/` 存在 | 使用它（验证已忽略） |
| 都存在 | 使用 `.worktrees/` |
| 都不存在 | 检查指令文件，然后默认 `.worktrees/` |
| 全局路径存在 | 使用它（向后兼容） |
| 目录未忽略 | 添加到 .gitignore |
| 创建时权限错误 | 沙箱后备，在原地工作 |
| 基线测试失败 | 报告失败 + 询问 |
| 无 package.json/Cargo.toml | 跳过依赖安装 |

## 常见错误

### 与 harness 对抗

- **问题：** 当平台已提供隔离时使用 `git worktree add`
- **修复：** 第 0 步检测现有隔离。第 1a 步优先使用原生工具。

### 跳过检测

- **问题：** 在现有 worktree 内创建嵌套 worktree
- **修复：** 在创建任何东西之前始终运行第 0 步

### 跳过忽略验证

- **问题：** Worktree 内容被跟踪，污染 git status
- **修复：** 创建项目本地 worktree 前始终使用 `git check-ignore`

### 假设目录位置

- **问题：** 造成不一致，违反项目约定
- **修复：** 遵循优先级：现有 > 全局遗留 > 指令文件 > 默认

### 在测试失败时继续

- **问题：** 无法区分新 bug 和预先存在的问题
- **修复：** 报告失败，获得明确许可后再继续

## Red Flags

**绝不：**
- 在第 0 步检测到现有隔离时创建 worktree
- 当你有原生 worktree 工具时使用 `git worktree add`（如 `EnterWorktree`）。这是最常见的错误——如果有，就用它。
- 跳过第 1a 步直接跳到第 1b 步的 git 命令
- 在未验证项目本地目录是否被忽略的情况下创建 worktree
- 跳过基线测试验证
- 在未询问的情况下带着失败的测试继续

**始终：**
- 先运行第 0 步检测
- 优先使用原生工具而非 git 后备
- 遵循目录优先级：现有 > 全局遗留 > 指令文件 > 默认
- 对项目本地目录验证是否被忽略
- 自动检测并运行项目设置
- 验证干净的测试基线
