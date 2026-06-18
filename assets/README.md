# 图片资源目录

将架构图、流程图、界面截图等资源放在本目录，并在 Markdown 中使用相对路径：

```markdown
![Compass 系统总体架构](../assets/architecture.png)
```

不要使用 `D:\...`、`C:\...` 等本机绝对路径，否则换电脑或交给 CI 构建时会失效。
