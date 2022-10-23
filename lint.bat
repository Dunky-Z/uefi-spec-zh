cd ./src

@REM Just for test
dir 

@REM Use autocorrect to fix typo 
autocorrect.exe --fix 1-Introduction.md 2-Overview.md 3-Boot-Manager.md

@REM Use markdownlint to check markdown style
markdownlint -c ../.markdownlint.json -f 1-Introduction.md 2-Overview.md 3-Boot-Manager.md

@REM Use pandoc to build pdf
pandoc.exe -f  markdown-auto_identifiers --pdf-engine=xelatex   --template=mppl.latex -s --listings  1-Introduction.md 2-Overview.md 3-Boot-Manager.md -o ../build/UEFI-Spec-zh.pdf