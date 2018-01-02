@echo off

cd %cd%

REM get name of current directory
for %%* in (.) do set CurrDirName=%%~nx*

rmdir /S /Q "%temp%\.build\"
del /f /s /q "%cd%\.build\%CurrDirName%.zip"

xcopy /e /s /y "%cd%" "%temp%\.build\%CurrDirName%\" /exclude:exclude.txt

powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('%temp%\.build\', '%cd%\.build\%CurrDirName%.zip'); }"

echo "Success!"
call explorer "%cd%\.build\"