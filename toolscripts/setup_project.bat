@echo off
setlocal enabledelayedexpansion

:: Nombre personalizado del entorno virtual (cambia esto si quieres un nombre diferente)
set ENV_NAME=env

:: Verificar si el entorno virtual existe
if not exist %ENV_NAME% (
    echo Creando entorno virtual...
    python -m venv %ENV_NAME%
) else (
    echo Entorno virtual ya existe.
)

:: Detectar el tipo de shell
echo %PSModulePath% | findstr /C:WindowsPowerShell >nul
if %errorlevel% equ 0 (
    echo Detectado PowerShell
    
    :: Configurar política de ejecución para PowerShell
    powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
    
    :: Activar entorno virtual en PowerShell
    powershell -Command ".\%ENV_NAME%\Scripts\Activate.ps1"
    
    :: Crear perfil de PowerShell si no existe
    powershell -Command "if (!(Test-Path -Path $PROFILE.CurrentUserCurrentHost)) { New-Item -Path $PROFILE.CurrentUserCurrentHost -ItemType File -Force }"
    
    :: Añadir comando de activación al perfil de PowerShell si no existe
    powershell -Command "$profileContent = Get-Content $PROFILE.CurrentUserCurrentHost; $activationLine = 'if ($env:TERM_PROGRAM -eq \"vscode\") { $envPath = Join-Path -Path $PWD -ChildPath \"%ENV_NAME%\Scripts\Activate.ps1\"; if (Test-Path $envPath) { & $envPath } else { Write-Host \"Virtual environment not found in the current directory.\" } }'; if ($profileContent -notcontains $activationLine) { Add-Content -Path $PROFILE.CurrentUserCurrentHost -Value $activationLine }"
) else (
    echo Detectado CMD u otro shell
    :: Activar entorno virtual en CMD
    call %ENV_NAME%\Scripts\activate.bat
)

:: Crear archivo .env si no existe
if not exist .env (
    echo Intentando crear archivo .env...
    python toolscripts\create_env.py
) else (
    echo Archivo .env ya existe.

)

:: Instalar pre-commit
python -m pip install pre-commit

:: Instalar pre-commit hooks
pre-commit install --config ./toolscripts/.pre-commit-config.yaml

:: Instalar dependencias del proyecto
if exist requirements.txt (
    echo Instalando dependencias del proyecto...
    python -m pip install -r requirements.txt
) else (
    echo No se encontró requirements.txt. Saltando instalación de dependencias.
)

:: Copiar hooks personalizados
echo Instalando hooks personalizados...
if not exist .git\hooks mkdir .git\hooks
copy /Y git-hooks\* .git\hooks\

:: Dar permisos de ejecución a los hooks (para sistemas Unix-like)
if exist "C:\Program Files\Git\usr\bin\chmod.exe" (
    for %%f in (git-hooks\*) do (
        "C:\Program Files\Git\usr\bin\chmod.exe" +x .git\hooks\%%~nxf
    )
)

:: Instalar post-merge hook
echo Instalando post-merge hook...
(
echo #!/bin/sh
echo.
echo # Ejecutar update_project.bat
echo ./toolscripts\update_project.bat
) > .git\hooks\post-merge

:: Crear post-merge.bat para Windows
(
echo @echo off
echo call toolscripts\update_project.bat
) > .git\hooks\post-merge.bat

:: Dar permisos de ejecución al hook (solo para sistemas Unix-like)
if exist "C:\Program Files\Git\usr\bin\chmod.exe" (
    "C:\Program Files\Git\usr\bin\chmod.exe" +x .git\hooks\post-merge
)

echo Post-merge hook instalado.


echo Configuración completada.

:: Mantener la ventana abierta
echo.
echo Presiona cualquier tecla para cerrar esta ventana...
pause >nul
endlocal