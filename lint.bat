cd ./src
dir
autocorrect.exe --fix 1-Introduction.md 2-Overview.md

pandoc.exe -f  markdown-auto_identifiers --pdf-engine=xelatex   --template=mppl.latex -s --listings  1-Introduction.md 2-Overview.md  -o ../build/UEFI-Spec-zh.pdf