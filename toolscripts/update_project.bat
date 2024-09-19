@echo off
setlocal enabledelayedexpansion

echo Verificando actualizaciones del proyecto...

:: Activar el entorno virtual
echo %PSModulePath% | findstr /C:WindowsPowerShell >nul
if %errorlevel% equ 0 (
    echo Detectado PowerShell
    
    :: Configurar política de ejecución para PowerShell
    powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
    
    :: Activar entorno virtual en PowerShell
    powershell -Command ".\%ENV_NAME%\Scripts\Activate.ps1"
    
) else (
    echo Detectado CMD u otro shell
    :: Activar entorno virtual en CMD
    call %ENV_NAME%\Scripts\activate.bat
)


:: Verificar si requirements.txt ha cambiado
git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD | findstr /I "requirements.txt" >nul
if %errorlevel% equ 0 (
    echo requirements.txt ha cambiado. Actualizando dependencias...
    python -m pip install -r requirements.txt
    echo Dependencias actualizadas.
) else (
    echo requirements.txt no ha cambiado. No se requiere actualización de dependencias.
)

echo Actualización del proyecto completada.

endlocal