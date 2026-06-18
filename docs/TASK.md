# md-publish-kit 任务追踪

后续所有修改方案与任务均按序号追加到本文档中。

---

## Task 1：修复 DOCX 导入飞书后代码块未渲染为代码块的问题

### 问题描述

当前通过 Pipeline 生成的 DOCX 文件，在导入飞书云文档后，Markdown 中的 fenced code block（```）不会被识别为飞书原生代码块，仅显示为普通正文或丢失代码块样式。

### 根因分析

1. Pandoc 在将 Markdown fenced code block 转换为 DOCX 时，默认使用段落样式 `Source Code`（在 Word OOXML 中对应的 styleId 为 `SourceCode`）。
2. 当前 `postprocess_docx.py` 已对该样式段落应用浅灰背景（`code_bg`）和 Consolas 等宽字体，在 Word 本地打开显示正常。
3. 飞书云文档对“原生代码块”的识别逻辑基于 **Markdown 语法标记**（``` + 空格 + 语言标识），而非 DOCX 样式。DOCX 导入会丢失 Markdown 语法层信息，因此飞书无法将 `SourceCode` 段落还原为代码块。

### 已验证现状

- 解压 `dist/Compass_智能竞品分析平台_飞书导入版.docx` 检查 `word/document.xml`，代码块段落确实使用 `w:pStyle val="SourceCode"`，并带有 `w:shd fill="F3F5F7"` 底纹和 Consolas 字体。
- `style_paragraphs()` 中判断条件 `style_name == 'Source Code'` 可匹配到这些段落，说明后处理流程本身无异常。
- 飞书侧触发代码块的写法为：

  ````markdown
  ``` python
  print("hello")
  ```
  ````

  即反引号后必须跟一个空格，再写语言类型。

### 候选方案

#### 方案 A：更换代码块样式 ID（优先级降低）

在 `postprocess_docx.py` 中，将代码块段落的 `w:pStyle` 从 `SourceCode` 修改为飞书可能识别的样式 ID，例如 `HTMLCode`、`HTML Code`、`Code`、`PlainText`，或中文环境下的 `HTML代码`、`代码`。

- **优点**：若飞书识别该样式，可直接得到原生代码块。
- **缺点**：飞书的 DOCX 导入器大概率不依据样式识别代码块，此方案成功概率低；修改 styleId 后 Word 中的样式一致性可能受影响。

#### 方案 B：增强代码块视觉样式（DOCX 保底方案）

无论飞书是否识别为原生代码块，确保导入后至少呈现为“类代码块”样式：

- 添加段落边框（细灰色边框，四边统一）；
- 保持等宽字体和浅灰背景；
- 保留缩进和换行，避免导入后行首空格丢失；
- 在段前段后增加小间距，与普通正文区分。

- **优点**：兼容性好，不依赖飞书的样式映射，导入后至少可读。
- **缺点**：不是真正的飞书代码块，无语法高亮和一键复制功能。

#### 方案 C：转换为单单元格表格

将每个代码块包装为一个 1×1 的表格，设置表格底纹为浅灰、无边框或细边框、等宽字体。

- **优点**：飞书对表格样式保留较好，视觉上接近代码块。
- **缺点**：编辑体验差，无法使用飞书代码块功能；与正文交互不自然。

#### 方案 D：生成飞书专用 Markdown 并支持一键复制/导入（推荐）

既然飞书对代码块的识别依赖 Markdown 语法，最可靠的方式是保留并输出一份符合飞书语法的 Markdown 文件：

- 将 fenced code block 统一改写为 ``` + 空格 + 语言（如 ``` python）；
- 提供 `build.ps1 -Format feishu-md` 或独立脚本 `scripts/export_feishu_md.py`；
- 在 `README.md` 中说明：若需要飞书原生代码块，可直接复制该 Markdown 到飞书文档，而非导入 DOCX。

- **优点**：能真正触发飞书原生代码块、语法高亮、一键复制。
- **缺点**：图片和复杂表格仍需配合 DOCX 使用；需要维护两套输出格式。

### 建议实施步骤

1. 先验证方案 D 的可行性：取示例 Markdown，将代码块统一改为 ``` + 空格 + 语言，手动粘贴到飞书，确认能渲染为原生代码块。
2. 同步实施方案 B，作为 DOCX 导出的保底样式，确保“仅导入 DOCX”场景下代码块仍可读。
3. 若方案 A 经实验有效，可作为可选增强；否则不投入。
4. 在 `README.md` 中补充说明：DOCX 导入的代码块为视觉代码块；需要原生代码块时请使用飞书专用 Markdown。
5. 增加自动化测试：验证 DOCX 中代码块段落包含边框、底纹、等宽字体；验证 Markdown 输出中代码块符合飞书语法。

### 相关文件

- `scripts/postprocess_docx.py`
- `scripts/create_template.py`
- `scripts/build.ps1`
- `config/pipeline.json`
- `templates/compass-feishu-reference.docx`
- `README.md`
