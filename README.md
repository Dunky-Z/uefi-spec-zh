# Unified Extensible Firmware Interface (UEFI) 规范（V2.9）- 中文

## 简介

为快速学习 UEFI，免于翻译软件反复翻译的痛苦，将 UEFI 规范-[Unified Extensible Firmware Interface_V2.9](https://uefi.org/sites/default/files/resources/UEFI_Spec_2_9_2021_03_18.pdf)翻译为中文。**内容均为机翻加微调**，欢迎大家提 PR 修正机翻的表述。

因 UEFI 规范主要是定义 Protocol，是用来查阅的一个手册，想要学习入门 UEFI 只需要学习前八章即可，所以计划**只翻译前八章内容**。

## 如何贡献翻译

本项目的所有文档使用[Autocorrect](https://github.com/huacnlee/autocorrect)和[markdownlint](https://github.com/DavidAnson/markdownlint)作为 Linter，检查拼写、术语缩写、中英文标点以及 Markdown 语法等。为了能够统一风格，提交的 PR 需要通过这些检查，也就需要配置以上工具对提交的内容进行预先检查。

### Linux

```bash
cd src
autocorrect --fix ./*.md

markdownlint -c ../.markdownlint.json -f ./*.md
```

### Windows

> 因为`*`通配符在实验过程中会报错，所以将`src`目录下的文件名一一列出，后续如果有增加新文件，请手动添加。

```bash
cd src
autocorrect.exe --fix 1-Introduction.md 2-Overview.md 

markdownlint -c ../.markdownlint.json -f 1-Introduction.md 2-Overview.md 
```

## 获取PDF

该项目已配置GitHub Action，可以在Action中下载Artifacts。具体路径如下：

![](./pic/get-pdf.jpg)

打开页面底端找到`Artifacts-output`。下载`output`解压即可。

## 手动构建 PDF

> 因为PDF不方便版本管理，所以未将其添加，需要安装[pandoc](https://github.com/jgm/pandoc)并手动构建。

### Linux

```bash
mkdir build
cd src
pandoc -f  markdown-auto_identifiers --pdf-engine=xelatex   --template=../templates/mppl.tex -s --listings ./*.md -o ../build/UEFI-Spec-zh.pdf
```

### Windows

```bash
md build
cd src
pandoc.exe -f  markdown-auto_identifiers --pdf-engine=xelatex   --template=../templates/mppl.tex -s --listings 1-Introduction.md 2-Overview.md  -o ../build/UEFI-Spec-zh.pdf
```