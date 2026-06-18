# md-publish-kit 任务追踪

后续所有修改方案与任务均按序号追加到本文档中。

---

## Task 1：修复 DOCX 导入飞书后代码块未渲染为代码块的问题

### 问题描述

当前通过 Pipeline 生成的 DOCX 文件，在导入飞书云文档后，Markdown 中的 fenced code block（```）不会被识别为飞书原生代码块，仅显示为普通正文或丢失代码块样式。

### 根因分析

1. Pandoc 在将 Markdown fenced code block 转换为 DOCX 时，默认使用段落样式 `Source Code`（在 Word OOXML 中对应的 styleId 为 `SourceCode`）。
2. 当前 `postprocess_docx.py` 已对该样式段落应用浅灰背景（`code_bg`）和 Consolas 等宽字体，在 Word 本地打开显示正常。
3. 飞书云文档的 DOCX 导入器对“原生代码块”的识别基于自身规则，目前并未将 `SourceCode` 样式映射为飞书代码块；因此导入后代码块样式丢失，仅保留为普通段落。

### 已验证现状

- 解压 `dist/Compass_智能竞品分析平台_飞书导入版.docx` 检查 `word/document.xml`，代码块段落确实使用 `w:pStyle val="SourceCode"`，并带有 `w:shd fill="F3F5F7"` 底纹和 Consolas 字体。
- `style_paragraphs()` 中判断条件 `style_name == 'Source Code'` 可匹配到这些段落，说明后处理流程本身无异常。

### 候选方案

#### 方案 A：更换代码块样式 ID（推荐优先验证）

在 `postprocess_docx.py` 中，将代码块段落的 `w:pStyle` 从 `SourceCode` 修改为飞书可能识别的样式 ID，例如 `HTMLCode`、`HTML Code`、`Code`、`PlainText`，或中文环境下的 `HTML代码`、`代码`。

- **优点**：若飞书识别该样式，可直接得到原生代码块，保留一键复制、语言切换等功能。
- **缺点**：需要实验确定飞书实际识别的样式名；修改 styleId 后 Word 中的样式一致性可能受影响，需在 `create_template.py` 中同步维护同名样式。

#### 方案 B：增强代码块视觉样式（保底方案）

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

### 建议实施步骤

1. 先实施方案 A 的快速验证：生成若干份仅 styleId 不同的 DOCX，手动导入飞书观察代码块识别效果。
2. 若方案 A 无效或效果不稳定，则实施方案 B 作为默认兜底，并在文档中记录已知限制。
3. 在 `README.md` 或 `PIPELINE_DESIGN.md` 中补充代码块在飞书中的呈现说明。
4. 增加自动化测试或断言：验证 DOCX 中代码块段落包含预期的样式、底纹、字体和边框。

### 相关文件

- `scripts/postprocess_docx.py`
- `scripts/create_template.py`
- `config/pipeline.json`
- `templates/compass-feishu-reference.docx`
