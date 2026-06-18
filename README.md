# md-publish-kit 文档自动生成 Pipeline

这套 Pipeline 用于解决：**Markdown 中有大量表格，直接粘贴到飞书后样式难看、无法稳定编辑**。

最终流程固定为：

```text
Markdown 内容源
    ↓ 结构与资源校验
Pandoc 转换
    ↓ 套用统一 reference.docx 模板
DOCX 后处理
    ↓ 表格列宽/表头/斑马纹/图片/代码块自动规范化
飞书导入版 DOCX
    ↓
飞书：上传及导入 → 导入为在线文档
```

## 1. 目录结构

```text
md-publish-kit/
├─ examples/
│  └─ Compass_智能竞品分析平台.md             # 当前项目的完整 Markdown 示例
├─ assets/
│  └─ README.md                       # 架构图、流程图、截图放这里
├─ templates/
│  └─ compass-feishu-reference.docx    # Pandoc reference-doc
├─ config/
│  └─ pipeline.json                   # 品牌、字体、表格列宽规则
├─ scripts/
│  ├─ install.ps1                     # Windows 环境初始化
│  ├─ build.ps1                       # 构建单个 Markdown
│  ├─ build_all.ps1                   # 批量构建目录中的所有 Markdown
│  ├─ build.sh                        # Linux/macOS/WSL 构建脚本
│  ├─ create_template.py              # 模板可复现生成器
│  ├─ validate_markdown.py            # 图片路径、表格列数等校验
│  └─ postprocess_docx.py             # DOCX 自动美化核心
├─ dist/                              # 最终输出目录
├─ requirements.txt
├─ STYLE_GUIDE.md                     # Markdown 编写规范
└─ 一键构建.bat                       # Windows 双击构建
```

## 2. Windows 第一次使用

在该目录打开 PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

安装内容：

- Pandoc：Markdown → DOCX 转换引擎；
- `python-docx`：DOCX 表格、图片、样式后处理；
- Pillow：图片信息处理依赖。

如果 Pandoc 刚安装完成，请关闭并重新打开 PowerShell，让 PATH 生效。

## 3. 一键生成 md-publish-kit 文档

最简单的方式是双击：

```text
一键构建.bat
```

或者在 PowerShell 执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build.ps1
```

默认输入：

```text
examples/Compass_智能竞品分析平台.md
```

默认输出：

```text
dist/Compass_智能竞品分析平台_飞书导入版.docx
```

## 4. 构建自己的 Markdown

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build.ps1 `
  -Input "D:\docs\比赛材料.md" `
  -OutputDir "D:\docs\output"
```

需要同时导出 PDF，可追加：

```powershell
-Pdf
```

PDF 导出依赖 LibreOffice；没有安装时只会跳过 PDF，不影响 DOCX。

## 5. 批量生成多个文档

将多个 `.md` 文件放入同一目录，然后执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_all.ps1 `
  -SourceDir "D:\docs\markdown" `
  -OutputDir "D:\docs\output"
```

## 6. 自动处理了什么

### 表格

- 表头深蓝底、白色粗体；
- 数据行使用浅色斑马纹；
- 单元格上下左右留白；
- 表头跨页重复；
- 行内容尽量不跨页拆分；
- 根据表头语义自动选择列宽；
- 未命中预设规则时，根据整列内容长度自动推断列宽；
- 姓名、版本、方法、输入、输出等短字段自动居中；
- 说明、职责、核心字段等长文本自动左对齐。

表格规则在 `config/pipeline.json` 中配置。例如：

```json
{
  "headers": ["#", "功能", "说明"],
  "ratios": [0.08, 0.28, 0.64],
  "align": ["center", "center", "left"]
}
```

新增某类表格时，只需添加一条规则，不需要逐表手调。

### 标题与封面

- YAML 元数据自动生成封面；
- 第一个一级标题自动换页，封面与正文分离；
- 一级标题增加品牌色下划线；
- 二级、三级标题使用统一字号、间距和颜色；
- 页眉、页脚、页码自动生成。

### 图片

- 自动限制在正文宽度的 92% 以内；
- 默认居中；
- Markdown 校验阶段阻止 `D:\...` 等本地绝对路径进入最终文档。

### 代码块与引用

- 代码块使用等宽字体和浅灰背景；
- 引用块使用浅蓝背景，适合作为提示、注意事项或架构图占位说明。

## 7. 飞书导入方式

生成 DOCX 后，在飞书中执行：

```text
云文档首页
→ 上传及导入
→ 选择生成的 DOCX
→ 导入为在线文档
```

不要直接把 Markdown 源文本粘贴到飞书，也不要仅作为附件上传。目标是让飞书将 Word 表格转换为原生在线文档表格。

## 8. 修改品牌或样式

编辑：

```text
config/pipeline.json
```

可修改：

- 项目名称和页眉文字；
- 页脚版本文字；
- 主色、强调色、边框色；
- 正文字体和代码字体；
- 页边距；
- 表格列宽规则；
- 图片最大宽度。

修改后重新生成模板：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build.ps1 -RebuildTemplate
```

## 9. 当前 md-publish-kit 文档的图片问题

原始 Markdown 中的架构图使用了类似下面的本机路径：

```html
<img src="D:\download\xxx.png" />
```

这类路径无法跨电脑复现。正确方式：

1. 将图片复制到 `assets/architecture.png`；
2. Markdown 改为：

```markdown
![Compass 系统总体架构](../assets/architecture.png)
```

3. 再运行构建脚本。

## 10. 推荐工作方式

```text
只维护 Markdown + assets
        ↓
提交 Git 仓库
        ↓
需要交付时一键构建 DOCX
        ↓
导入飞书做最终检查
```

飞书只作为协作和最终展示层，不再承担 Markdown 表格的逐个重建工作。
