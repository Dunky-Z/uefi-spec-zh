# Unified Extensible Firmware Interface (UEFI) 规范（V2.9）-中文

为快速学习UEFI，免于翻译软件反复翻译的痛苦，将UEFI规范翻译为中文。内容均为机翻加微调，欢迎大家提PR修正机翻的表述。

因UEFI规范主要是定义Protocol，是用来查阅的一个手册，想要学习入门UEFI只需要学习前八章即可，所以计划**只翻译前八章内容**。

## Build PDF

```bash
pandoc.exe -f  markdown-auto_identifiers --pdf-engine=xelatex   --template=../templates/mppl.tex -s --listings ./*.md -o ../build/UEFI-Spec-zh.pdf
```
