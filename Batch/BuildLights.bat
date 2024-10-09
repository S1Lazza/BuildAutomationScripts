REM ## Generic script to handle build of the light using UAT

@echo off
setlocal

REM ## Perform all needed checks before running the script
set PATHTOPROJECT=PathToProjectDirectory 
set PATHTOENGINE=PathToEngineDirectory 
set PATHTOLOGFILE=%PATHTOPROJECT%\LogFile.txt

call :CheckPath "%PATHTOPROJECT%" "Project directory cannot be found."
call :CheckPath "%PATHTOENGINE%"  "Engine directory cannot be found."

echo Start building the lights.
REM ## Run the UAT and build only the lights of the project
REM ## 1 - The -quality command can be changed to match the value wanted like in the editor: Preview, Medium, High, Production
REM ## 2 - For better control and fine tuning, the scalability settings commands can be used instead of the -quality: -ExecCmds="r.LightmassQuality=3, r.PostProcessQuality=3, r.ShadowQuality=4"
REM ##     Here's the full list: https://dev.epicgames.com/documentation/en-us/unreal-engine/scalability-reference-for-unreal-engine
REM ## 3 - To target a specific level the command -map=TargetLevel can be used. If not specified, Unreal will target the default editor map
"%PATHTOENGINE%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -project="%PATHTOPROJECT%" -buildlightingonly -unattended -noeditor -verbose -quality=Production > "%PATHTOLOGFILE%" 2>&1

 :CheckPath
if not exist "%~1" (
    echo.
    echo %2
    echo.
    pause
    goto ExitError
)
goto :EOF

:ExitError
exit /B 1

:ExitSuccess
exit /B 0

endlocal