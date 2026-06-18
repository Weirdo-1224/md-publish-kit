# Pipeline 设计说明

## 1. 设计目标

本系统不是简单调用一次 Pandoc，而是将文档生成拆成四个可验证阶段：

1. **内容层**：Markdown 只负责结构与内容；
2. **校验层**：在构建前发现图片路径、缺失资源和过宽表格；
3. **渲染层**：Pandoc 将 Markdown AST 转换为 DOCX，并继承统一 reference-doc；
4. **规范化层**：使用 `python-docx` 对表格列宽、行样式、图片和代码块进行二次处理。

这种分层方式解决了仅使用 `--reference-doc` 时无法精确控制每张表格列宽的问题。

## 2. 数据流

```text
examples/*.md + assets/*
        │
        ├─ validate_markdown.py
        │    ├─ YAML 元数据检查
        │    ├─ 图片相对路径检查
        │    ├─ 缺失资源检查
        │    └─ 表格宽度风险检查
        │
        ├─ pandoc
        │    └─ templates/compass-feishu-reference.docx
        │
        ├─ 临时 DOCX
        │
        └─ postprocess_docx.py
             ├─ 语义列宽规则匹配
             ├─ 未知表格列宽推断
             ├─ 表头与斑马纹
             ├─ 跨页表头和禁止拆行
             ├─ 图片缩放与居中
             ├─ 代码块/引用块样式
             └─ 封面与正文分页
                    │
                    ▼
          dist/*_飞书导入版.docx
```

## 3. 为什么增加 DOCX 后处理

Pandoc 的 reference-doc 适合控制全局样式，但不能仅依据表头自动判断：

- “姓名”列应较窄；
- “工作内容”列应较宽；
- `#`、版本、方法应居中；
- “说明”“职责”“核心字段”应左对齐；
- 五列 Agent 表和四列技术栈表需要不同宽度比例。

因此 `postprocess_docx.py` 采用两级策略：

### 精确规则

对频繁出现的表格，在 `pipeline.json` 中按表头配置固定比例。规则可复用、可审查、可版本管理。

### 自动推断

未命中规则时，根据每列的代表性文本长度、中文字符宽度和 URL/代码特征计算权重，并施加最小/最大列宽约束。

## 4. 配置边界

`config/pipeline.json` 只保存稳定、可共享的排版策略：

- 品牌文字；
- 页面和页边距；
- 主题色；
- 字体与字号；
- 常用表格规则；
- 图片宽度。

具体项目内容继续保留在 Markdown 中，避免模板与业务内容耦合。

## 5. 失败处理

构建遇到以下问题会停止：

- 输入 Markdown 不存在；
- Pandoc 或 Python 未安装；
- 图片使用绝对路径；
- 相对路径指向不存在的图片；
- Pandoc 转换失败；
- DOCX 后处理失败。

表格列数过多、单元格过长等问题只给出警告，允许用户先生成文档再决定是否拆表。

## 6. 扩展方式

### 新增表格样式

在 `tables.rules` 中添加表头、比例和对齐方式，无需修改 Python 代码。

### 新增主题

复制 `pipeline.json`，修改颜色、页眉、页脚、字体，再使用 `create_template.py` 生成另一套 reference-doc。

### 接入 CI

在 GitHub Actions、GitLab CI 或本地提交钩子中执行：

```bash
python scripts/validate_markdown.py docs/report.md
bash scripts/build.sh docs/report.md dist
```

生成的 DOCX 可作为 Release Artifact，不建议自动提交每次构建产物。

## 7. 飞书边界

Pipeline 负责生成结构稳定的 DOCX；飞书负责：

- 在线协作；
- 评论和权限；
- 最终轻量校对；
- 将 Word 表格转换为在线文档表格。

不建议依赖飞书对 Markdown 表格的直接粘贴解析，也不建议在飞书中逐张维护表格样式。
