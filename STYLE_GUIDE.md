# md-publish-kit 技术文档 Markdown 编写规范

## 1. 文档头部必须包含 YAML 元数据

```yaml
---
title: "Compass · 智能竞品分析平台"
subtitle: "基于多 Agent 协作的竞品分析自动化系统｜比赛提交技术文档"
author: "谢子韬｜个人开发者（全栈）"
date: "2026年6月 · V1.0"
---
```

这些字段会自动映射为封面标题、副标题、作者和日期。

## 2. 标题层级

```markdown
# 一、基础信息
## 1.1 项目名称/课题
### 难点一：LLM 输出幻觉
```

规则：

- `#`：章节；
- `##`：章节内功能模块；
- `###`：难点、方案、亮点或子模块；
- 不要从 `##` 直接跳到 `####`；
- 不要仅用粗体模拟标题。

## 3. 表格规范

### 3.1 推荐列数

- 2～5 列最适合 A4 DOCX 和飞书；
- 超过 5 列优先拆成两张表；
- 不要为了“信息全”而把字段全部挤进一张横向表格。

### 3.2 单元格内容

- 表头保持简短；
- 长说明放在最后一列；
- 姓名、版本、方法、状态等短字段放在前列；
- 单个单元格尽量控制在 120 字以内；
- 避免在单元格中嵌套列表、代码块和大段 HTML。

### 3.3 新增固定表格类型

如果某类表格经常出现，在 `config/pipeline.json` 的 `tables.rules` 中增加规则：

```json
{
  "headers": ["指标", "当前值", "目标值", "说明"],
  "ratios": [0.18, 0.16, 0.16, 0.50],
  "align": ["center", "center", "center", "left"]
}
```

Pipeline 会按表头精确匹配并自动应用，无需在飞书逐列拖宽。

## 4. 图片规范

图片统一放在 `assets/` 中，使用相对路径：

```markdown
![系统总体架构](../assets/architecture.png)
```

不允许：

```text
D:\download\architecture.png
C:\Users\xxx\Desktop\image.png
file:///...
```

建议：

- 架构图、流程图：PNG 或 SVG；
- 页面截图：PNG；
- 宽度优先控制在 1600～2200 px；
- 图中文字不要小于最终正文的可读字号；
- 一张图只表达一个核心主题。

## 5. 链接规范

推荐：

```markdown
- [GitHub 仓库](https://github.com/Weirdo-1224/ca_agent)
- [演示视频](https://www.bilibili.com/video/BV18pER6DEGS/)
```

不要把带有大量跟踪参数的 URL 直接裸露在正文中，除非提交方明确要求完整链接。

## 6. 代码块规范

必须标注语言：

````markdown
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=local
```
````

行宽过长时主动换行，避免在 Word 和飞书中产生横向溢出。

## 7. 提示块规范

使用引用语法表达提示、限制或待补材料：

```markdown
> **提交前检查**：替换架构图占位内容，并确认 GitHub 仓库为公开状态。
```

Pipeline 会将引用块渲染为浅蓝色提示区域。

## 8. 版本管理规范

推荐目录：

```text
docs/
├─ src/
│  └─ competition.md
├─ assets/
│  ├─ architecture.png
│  └─ screenshots/
├─ pipeline/
└─ dist/
```

只提交源 Markdown、图片和 Pipeline；`dist/` 中的 DOCX 可按交付节点提交，不作为日常编辑源。

## 9. 飞书最终检查清单

导入飞书后，只做以下少量检查：

- 标题层级是否正确进入文档目录；
- 表格是否被转换为可编辑原生表格；
- 超长表格是否分页合理；
- 图片是否清晰且居中；
- 外部链接是否可点击；
- 架构图、Demo、仓库和版本信息是否为最终值。

不再逐个修改表头颜色、行底色和列宽；这些工作应回到 Pipeline 配置中统一修复。
