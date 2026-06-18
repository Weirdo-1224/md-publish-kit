# md-publish-kit 任务追踪

后续所有修改方案与任务均按序号追加到本文档中。

---

## Task 1：修复 DOCX 导入飞书后代码块未渲染为代码块的问题

### 问题描述

当前通过 Pipeline 生成的 DOCX 文件，在导入飞书云文档后，Markdown 中的 fenced code block（```）不会被识别为飞书原生代码块，仅显示为普通正文或丢失代码块样式。同时，项目要求**只保留一份输出文件**，不能拆分为 DOCX（表格）+ Markdown（代码块）两种格式。

### 根因分析

1. Pandoc 在将 Markdown fenced code block 转换为 DOCX 时，默认使用段落样式 `Source Code`（在 Word OOXML 中对应的 styleId 为 `SourceCode`）。
2. 当前 `postprocess_docx.py` 已对该样式段落应用浅灰背景（`code_bg`）和 Consolas 等宽字体，在 Word 本地打开显示正常。
3. 飞书云文档对“原生代码块”的识别逻辑基于 **Markdown 语法标记**（``` + 空格 + 语言标识），DOCX 段落样式无法被还原为 Markdown 语法。因此通过 DOCX 导入很难得到真正的飞书代码块。
4. 由于必须保持单一输出文件，无法采用“DOCX 管表格、Markdown 管代码块”的分裂方案。

### 已验证现状

- 解压 `dist/Compass_智能竞品分析平台_飞书导入版.docx` 检查 `word/document.xml`，代码块段落确实使用 `w:pStyle val="SourceCode"`，并带有 `w:shd fill="F3F5F7"` 底纹和 Consolas 字体。
- `style_paragraphs()` 中判断条件 `style_name == 'Source Code'` 可匹配到这些段落，说明后处理流程本身无异常。
- 飞书侧触发原生代码块的 Markdown 写法为：

  ````markdown
  ``` python
  print("hello")
  ```
  ````

### 候选方案（统一在 DOCX 内解决）

#### 方案 A：增强代码块视觉样式（推荐主方案）

既然 DOCX 导入无法得到飞书原生代码块，就在 DOCX 内把代码块做得足够像代码块，确保导入飞书后依然可读、可区分：

- 添加段落边框（细灰色边框，四边统一）；
- 保持等宽字体和浅灰背景；
- 保留缩进和换行，避免导入后行首空格丢失；
- 在段前段后增加小间距，与普通正文区分；
- 可选：增加左侧彩色竖条（强调色）提升辨识度。

- **优点**：只产生一份 DOCX；表格和代码块都在同一份文件中处理；兼容性好。
- **缺点**：不是飞书原生代码块，无语法高亮和一键复制。

#### 方案 B：尝试让飞书识别 DOCX 中的代码块结构

在 DOCX 生成阶段探索飞书导入器可能识别的结构：

- 尝试不同的段落样式名（`HTMLCode`、`Code`、`PlainText` 等）；
- 尝试使用 Word 内容控件（Content Controls）或书签标记代码块；
- 尝试给代码块段落添加自定义 OOXML 属性，模拟 Markdown  fenced code 的语义。

- **优点**：若成功，可在同一份 DOCX 内得到原生代码块。
- **缺点**：需要大量实验，成功概率不确定；可能依赖飞书未公开的导入规则。

#### 方案 C：代码块转为带样式的单单元格表格

将每个代码块包装为一个 1×1 的表格，设置表格底纹为浅灰、细边框、等宽字体。

- **优点**：飞书对表格样式保留较好，视觉上接近代码块；与正文在同一文件内。
- **缺点**：编辑体验差；代码块与正文表格风格可能混淆；无法一键复制整块代码。

### 建议实施步骤

1. **优先实施方案 A**：在 `postprocess_docx.py` 中为 `Source Code` 段落添加段落边框，并验证飞书导入后的视觉效果。
2. 同步做小规模实验验证方案 B（尝试 1-2 个不同样式名/结构），若无效则放弃。
3. 若方案 A 视觉辨识度仍不足，再考虑方案 C 作为备选。
4. 在 `README.md` 中补充说明：由于飞书 DOCX 导入机制限制，代码块以“视觉代码块”形式呈现，非飞书原生代码块。
5. 增加自动化测试：验证 DOCX 中代码块段落包含边框、底纹、等宽字体和正确换行。

### 相关文件

- `scripts/postprocess_docx.py`
- `scripts/create_template.py`
- `config/pipeline.json`
- `templates/compass-feishu-reference.docx`
- `README.md`
