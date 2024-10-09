REM ## Automatic setup and running at startup of the SwarmAgent.exe on the target machine (file in the subfolder are taken from Unreal Engine 5.2)

@echo off
setlocal

REM ## Define a unique name for the VBScript 
set SCRIPT=%TEMP%\SwarmAgentShortcut-%RANDOM%.vbs

REM ## Check if SwarmAgent.exe exists in the container folder
REM ## Here a sub folder containing all the needed files is provided, it could be possible to directly point to the SwarmAgent.exe binaries built in Unreal under %PATHTOENGINE%\Engine\Binaries\DotNET
if not exist "%~dp0SwarmAgentFiles\SwarmAgent.exe" (
    echo SwarmAgent.exe not found in %~dp0SwarmAgentFiles. Aborting.
    exit /B 1
)

REM ## Make a shortcut in the Startup folder
(
echo Set oWS = WScript.CreateObject("WScript.Shell")
echo sLinkFile = "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\SwarmAgent.lnk" 
echo Set oLink = oWS.CreateShortcut(sLinkFile)
echo oLink.TargetPath = "%~dp0SwarmAgentFiles\SwarmAgent.exe"
echo oLink.Save 
) > %SCRIPT%

REM ## Create the shortcut and check the result of it 
cscript /nologo %SCRIPT%

if %errorlevel% neq 0 (
    echo Failed to create the shortcut. Aborting.
    del "%SCRIPT%"
    exit /B 1
)

del "%SCRIPT%"

start "" "%~dp0SwarmAgentFiles\SwarmAgent.exe"