# ohMyHarness Agent 文档约定片段

把下面片段加入目标项目的 `AGENTS.md` 或 `CLAUDE.md`，用于覆盖通用 workflow skill 的默认文档路径。

```markdown
## ohMyHarness 文档约定

本项目使用 ohMyHarness 文档结构。以下路径规则是用户偏好，覆盖任何通用 skill 的默认路径：

- feature/spec 写到 `docs/harness/feature/`
- plan 写到 `docs/harness/plan/`
- design 写到 `docs/harness/design/`
- standard 写到 `docs/harness/standard/`
- knowledge 写到 `docs/harness/knowledge/`

`feature` 说明要解决什么问题。
`plan` 是可变化的过程方案，不是最终事实。
`design` 记录实际构建了什么以及为什么这样构建。
`standard` 和 `knowledge` 保存跨任务可复用的约束与经验。

不要自动 `git add`、`git commit` 或 `git push`，除非用户明确要求。
```
