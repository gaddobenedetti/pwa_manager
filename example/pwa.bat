@echo off
setlocal enabledelayedexpansion

set "NAME="
set "VERSION="

:parse_args
if "%~1"=="" goto done_args
if /i "%~1"=="-name" (
    set "NAME=%~2"
    shift
    shift
    goto parse_args
)
if /i "%~1"=="-version" (
    set "VERSION=%~2"
    shift
    shift
    goto parse_args
)
echo Unknown argument: %~1
shift
goto parse_args

:done_args

if not exist "build\web" (
    echo ERROR: build\web directory not found.
    exit /b 1
)

echo ============================================
echo  PWA Post-Build Configuration
echo ============================================
echo.

:: Task 1: Insert PWA install prompt script into index.html
echo [Task 1] Inserting PWA install prompt script into index.html...

if not exist "build\web\index.html" (
    echo   ERROR: index.html not found.
    set "TASK1=FAILED"
    echo.
    goto task2
)

powershell -NoProfile -Command "$f='build\web\index.html'; $c=Get-Content $f -Raw -Encoding UTF8; if ($c -match '__pwaInstallPrompt') { exit 1 }; $lines=Get-Content $f -Encoding UTF8; $before=$lines[0..15]; $script=@('  <script>','    window.addEventListener(''beforeinstallprompt'', (e) => {','      window.__pwaInstallPrompt = e;','    });','  </script>',''); $after=$lines[16..($lines.Length-1)]; ($before + $script + $after) | Set-Content $f -Encoding UTF8; exit 0"

if !ERRORLEVEL! EQU 0 (
    echo   SUCCESS: PWA script inserted after line 16.
    set "TASK1=OK"
) else (
    echo   SKIPPED: PWA script already present in index.html.
    set "TASK1=SKIPPED"
)
echo.

:task2
if "%NAME%"=="" (
    echo [Task 2] SKIPPED: No -name parameter provided.
    echo.
    goto task3
)

echo [Task 2] Updating manifest.json name and short_name to "%NAME%"...

if not exist "build\web\manifest.json" (
    echo   ERROR: manifest.json not found.
    set "TASK2=FAILED"
    echo.
    goto task3
)

powershell -NoProfile -Command "$Q=[char]34; $f='build\web\manifest.json'; $c=Get-Content $f -Raw -Encoding UTF8; $p=$Q+'name'+$Q+'\s*:\s*'+$Q+'[^'+$Q+']*'+$Q; $r=$Q+'name'+$Q+': '+$Q+'%NAME%'+$Q; $c=$c -replace $p, $r; $p=$Q+'short_name'+$Q+'\s*:\s*'+$Q+'[^'+$Q+']*'+$Q; $r=$Q+'short_name'+$Q+': '+$Q+'%NAME%'+$Q; $c=$c -replace $p, $r; [System.IO.File]::WriteAllText($f, $c, [System.Text.UTF8Encoding]::new($false))"

if !ERRORLEVEL! EQU 0 (
    echo   SUCCESS: manifest.json name and short_name updated.
    set "TASK2=OK"
) else (
    echo   ERROR: Failed to update manifest.json.
    set "TASK2=FAILED"
)
echo.

:task3
if "%VERSION%"=="" (
    echo [Task 3] SKIPPED: No -version parameter provided.
    echo.
    goto summary
)

echo [Task 3] Updating version.json version to "%VERSION%"...

if not exist "build\web\version.json" (
    echo   ERROR: version.json not found.
    set "TASK3=FAILED"
    echo.
    goto summary
)

powershell -NoProfile -Command "$Q=[char]34; $f='build\web\version.json'; $c=Get-Content $f -Raw -Encoding UTF8; $p=$Q+'version'+$Q+'\s*:\s*'+$Q+'[^'+$Q+']*'+$Q; $r=$Q+'version'+$Q+':'+$Q+'%VERSION%'+$Q; $c=$c -replace $p, $r; [System.IO.File]::WriteAllText($f, $c, [System.Text.UTF8Encoding]::new($false))"

if !ERRORLEVEL! EQU 0 (
    echo   SUCCESS: version.json version updated.
    set "TASK3=OK"
) else (
    echo   ERROR: Failed to update version.json.
    set "TASK3=FAILED"
)
echo.

:summary
echo ============================================
echo  Done.
echo ============================================

endlocal
exit /b 0
