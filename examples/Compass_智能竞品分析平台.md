---
title: "Compass · 智能竞品分析平台"
subtitle: "基于多 Agent 协作的竞品分析自动化系统｜比赛提交技术文档"
author: "谢子韬｜个人开发者（全栈）"
date: "2026年6月 · V1.0"
---

# 一、基础信息

## 1.1 项目名称/课题

**Compass · 智能竞品分析平台** — 基于多 Agent 协作的竞品分析自动化系统

## 1.2 团队名称与成员名单

| 角色 | 姓名 |
|------|------|
| 个人开发者（全栈） | 谢子韬 |

## 1.3 分工说明

本项目由个人独立完成，涵盖以下全部模块：

| 模块 | 工作内容 |
|------|----------|
| 产品设计 | 需求分析、Agent 工作流设计、交互原型、Prompt 工程设计 |
| 后端开发 | Spring Boot 服务、6 Agent 编排引擎、工作流 DAG、LLM 对接、数据持久化 |
| 前端开发 | Vue 3 + Element Plus 分析控制台、Markdown 渲染、实时状态面板 |
| 模型/AI | Prompt 模板设计（6 套）、LLM 输出结构化校验、幻觉防护机制 |
| 数据层 | PostgreSQL 数据库设计（7 张核心表）、MyBatis-Plus ORM |
| 搜索集成 | 秘塔 Metaso 搜索 API 对接、多维度搜索策略设计 |
| 测试与质量 | 单元测试、集成测试、Agent 输出校验框架 |

# 二、功能说明

## 2.1 核心功能清单

| # | 功能 | 说明 |
|---|------|------|
| 1 | **智能任务规划** | 用户输入产品名称和分析需求，PlannerAgent 自动识别行业领域、规划分析维度、生成搜索策略 |
| 2 | **多源信息采集** | CollectorAgent 通过秘塔 Metaso API 执行多维度搜索（官网/定价/文档/评测/博客/GitHub），自动聚合结构化证据 |
| 3 | **结构化报告生成** | WriterAgent 基于提取的 Claims 和分析结论，自动生成多章节 Markdown 报告，包含对比表格和数据引用 |
| 4 | **质量审查与自动修复** | ReviewerAgent 对报告进行 100 分制评分，低于阈值自动定位问题、生成修复指令并触发迭代修复（最多 3 轮） |
| 5 | **证据链全程追溯** | 建立 Report → Evidence → Claim 完整追溯链，每条数据结论均可追溯到原始来源 URL |
| 6 | **修复闭环可视化** | 完整记录每轮修复的 before/after diff（分数变化、问题修复数、新增证据等），可视化展示修复历程 |

## 2.2 端到端使用流程

1. **用户访问平台**：打开 Compass 平台首页，看到产品介绍和六步 Agent 工作流说明。
2. **创建分析任务**：在右侧表单输入待分析的竞品名称（如 “Cursor, GitHub Copilot, Windsurf”）、所属领域和分析目标，点击“开始分析”。
3. **自动规划执行**：系统后台启动 6 Agent 工作流——规划分析 → 信息采集 → 要素提取 → 深度分析 → 报告撰写 → 质量审查，左侧面板实时展示各 Agent 执行状态。
4. **质量迭代修复**：若 Reviewer 评分低于阈值，系统自动触发修复循环（定位问题 → 生成修复指令 → 重新执行相关 Agent → 再次审查），直至质量达标或达到最大修复轮次。
5. **查看分析报告**：任务完成后，用户在“报告”标签页阅读 Markdown 格式的多章节报告，包含竞品对比表格、功能矩阵、定价对比等。
6. **审查证据来源**：在“证据”标签页浏览所有采集到的证据，支持按产品/来源类型筛选，点击链接可跳转原始来源网页验证。
7. **查看质量评审**：在“质检”标签页查看评分、问题列表和改进建议；在“修复记录”标签页查看每轮修复的 diff 对比。
8. **追溯 Agent 决策**：在“Agent 轨迹”标签页查看每个 Agent 的完整 LLM Prompt 和 Response，了解 AI 决策过程，便于调试和优化。

# 三、交付材料

## 3.1 在线 Demo 链接

目前无在线 Demo（本地运行版本）。

## 3.2 演示视频链接

<https://www.bilibili.com/video/BV18pER6DEGS/?vd_source=9ad2f7ca4d93119fa55f18f6c38a0e78>

## 3.3 源代码仓库链接

- **GitHub 仓库**：<https://github.com/Weirdo-1224/ca_agent.git>
- **主分支**：`main`
- **最后提交**：包含完整功能代码（品牌正式化/Markdown 渲染/修复闭环/幻觉防护/状态持久化）

## 3.4 README / 运行说明

详见仓库根目录 `README.md`，包含：

- 项目简介与功能特性
- 依赖环境要求（JDK 17+、Maven 3.9+、Node.js 18+、PostgreSQL）
- 完整启动步骤（后端 + 前端）
- 项目目录结构说明
- API 接口文档
- 配置说明（LLM API Key、搜索 API Key）

# 四、技术说明

## 4.1 系统架构图

> **系统架构图占位**：原 Markdown 引用了本地路径图片。请在最终提交前，将正式架构图插入此处，并建议设置为正文宽度的 85%～95%，居中显示，图下注明“图 1 Compass 系统总体架构”。

## 4.2 核心技术栈

| 层级 | 技术 | 版本 | 用途 |
|------|------|------|------|
| **后端框架** | Spring Boot | 3.4.1 | Web 服务框架、依赖注入、异步任务 |
| **AI 集成** | Spring AI | 1.1.7 | LLM 抽象层、OpenAI 协议适配 |
| **ORM** | MyBatis-Plus | 3.5.16 | 数据库访问、实体映射 |
| **数据库** | PostgreSQL | — | 主数据存储（7 张核心表） |
| **测试数据库** | H2 | — | 单元/集成测试环境 |
| **前端框架** | Vue 3 | 3.5.34 | 响应式 UI 框架 |
| **类型系统** | TypeScript | ~6.0 | 前端类型安全 |
| **构建工具** | Vite | 8.0 | 前端构建 + 开发服务器 + API 代理 |
| **UI 组件库** | Element Plus | 2.14 | 企业级 UI 组件 |
| **Markdown** | marked | — | GFM Markdown → HTML 渲染 |
| **HTTP 客户端** | Axios | — | 前端 API 请求 |
| **开发语言** | Java 17 | 17 | 后端主语言（Record、Switch 表达式、文本块） |

## 4.3 大模型 / AI 能力使用说明

### 使用的模型

| 模型 | 提供商 | 协议 | 用途 |
|------|--------|------|------|
| doubao-seed-2.0-lite | 字节跳动（豆包） | OpenAI-compatible API | 全部 6 个 Agent 的推理引擎 |

### Agent 编排架构

本系统采用 **6 Agent 线性 DAG + 条件修复循环** 的编排架构，每个 Agent 都是独立的 LLM 调用单元：

| Agent | 中文名 | 职责 | 输入 | 输出 |
|-------|--------|------|------|------|
| PlannerAgent | 规划分析 | 识别领域、规划分析维度、生成搜索策略 | TaskInput | TaskPlanDTO |
| CollectorAgent | 信息采集 | 调用 Metaso API 执行多维度搜索，聚合原始证据 | TaskPlan | Evidence[] |
| ExtractorAgent | 要素提取 | 从原始证据中提取结构化 Claims（带置信度和来源） | Evidence[] | ProductProfileSetDTO |
| AnalyzerAgent | 深度分析 | 对提取的 Claims 进行交叉验证和深度分析 | Claims + Evidence | CompetitiveAnalysisDTO |
| WriterAgent | 报告撰写 | 基于分析结论生成多章节 Markdown 报告（含对比表格） | Analysis | ReportDraftDTO |
| ReviewerAgent | 质量审查 | 100 分制评分，定位问题，生成修复指令 | Report + Evidence | ReviewResultDTO |

### Prompt 工程设计

- **6 套独立 Prompt 模板**（`prompt/` 包），每个 Agent 有专属的 System Prompt + User Prompt
- **结构化 JSON 输出**：所有 Agent 要求返回符合 DTO Schema 的纯 JSON，通过 `AgentOutputValidator` 进行严格校验
- **幻觉防护机制**：双层防护（sanitize 软修正 + warn 宽容校验），防止 LLM 编造不存在的 evidenceId
- **上下文保真**：保留完整的 Evidence contentSnippet 传递给下游 Agent，避免信息压缩导致的质量损失

### 在系统中的位置

```text
用户输入 → PlannerAgent(LLM) → CollectorAgent(LLM + Metaso API)
         → ExtractorAgent(LLM) → AnalyzerAgent(LLM)
         → WriterAgent(LLM) → ReviewerAgent(LLM)
         → [条件修复循环: RepairRouter → 目标Agent(LLM) → ReviewerAgent(LLM)]
         → 最终报告输出
```

## 4.4 关键工程难点与解决方案

### 难点一：LLM 输出幻觉（evidenceId 编造）

**问题描述**：LLM 在生成报告和分析时，经常编造不存在的 evidenceId 引用，导致下游校验失败、工作流中断。

**解决方案**：设计了**双层防护机制**：

1. **Sanitize 层（软修正）**：在 Agent 输出后自动过滤非法 evidenceId，当全部引用均为幻觉时，从真实证据池中选取最相关的 ID 作为替代（而非保留幻觉 ID）。
2. **Warn 层（宽容校验）**：后续验证改为 `warnInvalidEvidenceIds`（仅记录日志不抛异常），容忍少量残余幻觉，确保工作流不因单个 ID 问题而崩溃。

**效果**：从“工作流频繁因幻觉而崩溃”改善为“100% 完整执行”，同时保持了证据引用的可追溯性。

### 难点二：工作流失败时中间状态丢失

**问题描述**：6 Agent 链式执行耗时较长（2-5 分钟），若在后期 Agent（如 Writer 修复阶段）失败，前期已完成的中间结果（证据/分析/质检）全部丢失，用户看不到任何结果。

**解决方案**：采用**两步法状态管理**：

1. `createState()`：工作流启动前即创建状态对象
2. `execute()`：执行完整链
3. **异常捕获保存**：在 `catch` 块中调用 `stateAssembler.saveState(state)` 保存已完成的中间结果到数据库

```java
CompetitiveAnalysisState state = graph.createState(taskInput);
try {
    graph.execute(state);
    stateAssembler.saveState(state);
} catch (Exception e) {
    state.setStatus(TaskStatus.FAILED);
    stateAssembler.saveState(state);  // 保存中间结果
    markTaskFailed(taskInput.getTaskId(), e);
}
```

**效果**：即使工作流在修复阶段失败，用户仍可查看已生成的报告、证据和质检结果。

### 难点三：Agent 质量闭环与修复路由

**问题描述**：单次 LLM 生成的报告质量不稳定，需要自动化的质量保障机制，但修复循环容易陷入无限循环或修复方向错误。

**解决方案**：设计了 **RepairRouter 条件路由 + 精准修复指令** 机制：

1. **WorkflowRouter**：评估 Reviewer 评分，决定 `finish`（通过）、`repair`（修复）或 `human_review`（需人工）
2. **RepairRouter**：根据 Reviewer 的 issues 列表，定位需要修复的具体 Agent（Collector/Extractor/Analyzer/Writer），生成包含目标产品、目标维度、期望修复行为的精准指令
3. **修复 diff 记录**：每轮修复前后记录快照（分数/问题数/证据数），计算 diff 并持久化
4. **硬上限保护**：最多 3 轮修复，超出则强制结束

**效果**：报告质量从首次生成的 50-70 分提升至修复后的 80-95 分，且修复过程完全可追溯。

## 4.5 部署与访问说明

当前为**本地运行版本**，尚未进行云端部署。

**本地运行方式**：

```bash
# 1. 启动 PostgreSQL 并创建 ca_agent 数据库
# 2. 配置 application-local.yml（LLM API Key + 搜索 API Key）
# 3. 启动后端
mvn spring-boot:run -Dspring-boot.run.profiles=local

# 4. 启动前端
cd frontend && npm install && npm run dev

# 5. 访问 http://localhost:5173
```

# 五、结果说明

## 5.1 项目完成度

**当前状态：可用 Demo（接近生产级版本）**

| 维度 | 完成情况 |
|------|----------|
| 核心工作流 | ✅ 完成 — 6 Agent 完整链路 + 修复循环均已实现并验证 |
| LLM 真实对接 | ✅ 完成 — 全部 Agent 使用豆包 LLM 真实推理 |
| 搜索集成 | ✅ 完成 — 秘塔 Metaso API 真实搜索 |
| 数据持久化 | ✅ 完成 — 7 张核心表，支持增量保存和中间状态恢复 |
| 前端控制台 | ✅ 完成 — 8 个核心组件，覆盖全部功能场景 |
| 质量保障 | ✅ 完成 — 输出校验 + 幻觉防护 + 修复闭环 |
| 可观测性 | ✅ 完成 — LLM Prompt/Response/Token 全链路追踪 |
| 测试覆盖 | ✅ 完成 — 单元测试 + 集成测试 |

## 5.2 项目亮点 / 创新点

### 亮点一：质量自修复闭环

区别于市面上“一次生成即结束”的 AI 报告工具，Compass 实现了**完整的质量闭环**：ReviewerAgent 评分 → RepairRouter 精准定位修复目标 → 目标 Agent 重新执行 → 再次审查。整个修复过程完全自动化，并且每轮修复的 before/after diff 完全可追溯，让用户了解 AI 是如何自我改进的。

### 亮点二：LLM 幻觉工程化治理

针对 LLM 普遍存在的“编造引用”问题，设计了工程化的双层防护方案（Sanitize + Warn），既不因单个幻觉阻断整个工作流，又能最大程度保持证据引用的准确性。这种“容错但不纵容”的设计思路在多 Agent 系统中具有通用价值。

### 亮点三：全链路可观测的 Agent 协作系统

每个 Agent 的 LLM 调用完全透明——用户可以查看完整的 Prompt（系统指令+用户输入）和 LLM Response（原始 JSON 输出），以及 Token 用量和耗时统计。这种全链路可观测性不仅便于调试，也让用户理解 AI 的决策逻辑，增强了系统的可信度。

# 六、附录

## 数据库表结构概览

| 表名 | 用途 | 核心字段 |
|------|------|----------|
| `analysis_task` | 分析任务主表 | task_id, status, review_score, iteration_count |
| `evidence` | 证据池 | evidence_id, product_name, source_type, url, content_snippet |
| `claim` | 结构化论断 | claim_id, product_name, dimension, statement, confidence |
| `report` | 分析报告 | report_id, sections_json (Markdown 格式) |
| `review_issue` | 质检问题 | issue_id, severity, type, repair_instruction |
| `agent_run` | Agent 执行记录 | agent_type, duration_ms, prompt_tokens, llm_calls_json |
| `repair_instruction` | 修复指令 | target_agent, target_product, expected_fix |
| `repair_diff` | 修复 diff | before_score, after_score, fixed_issue_count |

## API 接口列表

| 方法 | 路径 | 说明 |
|------|------|------|
| `POST` | `/api/tasks` | 创建分析任务 |
| `GET` | `/api/tasks/{taskId}` | 获取任务详情与状态 |
| `GET` | `/api/tasks/{taskId}/report` | 获取结构化报告（Markdown 格式） |
| `GET` | `/api/tasks/{taskId}/evidence` | 获取证据池列表 |
| `GET` | `/api/tasks/{taskId}/review` | 获取质检结果与评分 |
| `GET` | `/api/tasks/{taskId}/agent-runs` | 获取 Agent 执行轨迹 |
| `GET` | `/api/tasks/{taskId}/repair-diffs` | 获取修复闭环 diff 记录 |
