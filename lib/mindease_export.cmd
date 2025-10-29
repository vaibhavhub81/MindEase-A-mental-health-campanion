@echo off
setlocal enabledelayedexpansion

:: Set the output file name
set OUTPUT_FILE=mindease_code.txt

:: Clear the output file if it exists
if exist %OUTPUT_FILE% del %OUTPUT_FILE%

:: Specify the file extensions you want to include (Dart, Java, Python, Kotlin)
set EXTENSIONS=*.dart *.java *.kt *.py

:: Loop through each file type
for %%e in (%EXTENSIONS%) do (
    :: Recursively get all files of this type
    for /r %%f in (%%e) do (
        echo === File: %%~nxf === >> %OUTPUT_FILE%
        type "%%f" >> %OUTPUT_FILE%
        echo. >> %OUTPUT_FILE%
        echo. >> %OUTPUT_FILE%
    )
)

echo All source code has been exported to %OUTPUT_FILE%
pause
