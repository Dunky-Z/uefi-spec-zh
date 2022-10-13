cd ./src

@REM Just for test
dir 

@REM Use autocorrect to fix typo 
autocorrect.exe --fix 1-Introduction.md 2-Overview.md 

@REM Use markdownlint to check markdown style
markdownlint -c ../.markdownlint.json -f 1-Introduction.md 2-Overview.md 

@REM Use pandoc to build pdf
pandoc.exe -f  markdown-auto_identifiers --pdf-engine=xelatex   --template=mppl.latex -s --listings  1-Introduction.md 2-Overview.md  -o ../build/UEFI-Spec-zh.pdf