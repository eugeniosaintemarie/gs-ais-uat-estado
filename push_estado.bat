
@echo off

pushd "%~dp0" || (
  echo No se pudo cambiar al directorio del script
  exit /b 1
)

set "VERBOSE=0"
if /I "%~1"=="/v" set "VERBOSE=1"
if /I "%~1"=="-v" set "VERBOSE=1"
if /I "%~1"=="--verbose" set "VERBOSE=1"

git --version >nul 2>&1 || (
  echo Git no esta instalado o no esta en PATH
  pause
  popd
  exit /b 1
)

git rev-parse --is-inside-work-tree >nul 2>&1 || (
  echo Este directorio no es un repositorio git
  pause
  popd
  exit /b 1
)

git fetch origin >nul 2>&1

set "HAS_CHANGES="
for /f "delims=" %%i in ('git status --porcelain') do set "HAS_CHANGES=1"

if defined HAS_CHANGES (
  call :echomsg "Hay cambios locales — preparando commit..."
  git add -A
  git commit -m "actualizacion de estado" || (
    echo No se pudo crear el commit. Puede que no haya cambios staged o haya otro problema
    echo Salida de git status --porcelain:
    git status --porcelain
    pause
    popd
    exit /b 1
  )

  for /f "delims=" %%b in ('git rev-parse --abbrev-ref HEAD') do set "CURRENT_BRANCH=%%b"
  call :echomsg "Empujando %CURRENT_BRANCH% a origin/gh-pages..."
  git push origin %CURRENT_BRANCH%:gh-pages
  if errorlevel 1 (
    echo git push fallo. Revisa tu conexión o credenciales
    pause
    popd
    exit /b 1
  ) else (
    call :echomsg "Push completado correctamente"
    call :pauseif
  )
) else (
  call :echomsg "No hay cambios para subir"
  call :pauseif
)

popd
exit /b 0

:echomsg
if "%VERBOSE%"=="1" (
  echo %~1
)
goto :eof

:pauseif
if "%VERBOSE%"=="1" (
  pause
)
goto :eof
