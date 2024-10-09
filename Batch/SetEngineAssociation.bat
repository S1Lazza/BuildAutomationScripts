REM ## Script to keep engine UUID association (can be seen in the .uproject file) consistent between team members when dealing with Unreal Engine custom versions, needs to run on the target machine
REM ## Thanks to: https://x157.github.io/UE5/Windows-Registry-Keys#CustomEngineAlias

@echo off
setlocal

REM ## The same keyname must be set in the .uproject file for the EngineAssociation section
set KEYNAME=EngineCustomName

echo Creating or updating registry key for custom Unreal Engine version.
reg add "HKCU\SOFTWARE\Epic Games\Unreal Engine\Builds" /v "%KEYNAME%" /t REG_SZ /d "%cd%" /f

if %errorlevel% equ 0 (
    echo Registry key for "%KEYNAME%" successfully created or updated.
) else (
    echo Failed to create or update registry key! Error level: %errorlevel%
    exit /B %errorlevel%
)

timeout /t 5 /nobreak

echo Done.
exit /B 0
endlocal