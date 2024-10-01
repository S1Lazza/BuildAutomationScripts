REM ## Script to automatically build a source Unreal Engine 5, tested in Unreal Engine 5.1 & 5.2

@echo off
setlocal

REM ## Perform required checks
REM ## PATHTOBUILTENGINE is the default location the engine build with binaries is put
set PATHTOENGINE=PathToEngineDirectory 
set PATHTOBUILTENGINE=PathToBuiltEngineDirectory\LocalBuilds\Engine\Windows 

call :CheckPath "%PATHTOENGINE%" "Engine directory cannot be found."

if exist "%PATHTOBUILTENGINE%" (
    echo Removing previous engine build
    rd /q /s "%PATHTOBUILTENGINE%"
)

REM ## This step is optional. Keep in mind that, if you want to perform it, there are some local files that can be modified during the engine build and prevent this from running correctly in CI/CD environments.
REM ## The Setup.bat requires a manual input to overwrite these files, so you need to account for that
"%PATHTOENGINE%\Setup.bat" || goto ExitError

"%PATHTOENGINE%\GenerateProjectFiles.bat" || goto ExitError

echo Start building the engine
REM ## The -clean command force a full rebuild
"%PATHTOENGINE%\Engine\Build\BatchFiles\RunUAT.bat" BuildGraph -target="Make Installed Build Win64" -script=Engine/Build/InstalledEngineBuild.xml -clean -unattended -noeditor -set:WithMac=false -set:WithAndroid=false -set:WithIOS=false -set:WithTVOS=false -set:WithLinux=false -set:WithLinuxArm64=false -set:WithWin64=true -WithDCC=false || goto ExitError

REM Delete all the .pdb files to massively reduce the size of the engine (optional)
del /S /Q "%PATHTOBUILTENGINE%\*.pdb"

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
echo Build of the engine completed.
exit /B 1

:ExitSuccess
echo Error: build of the engine failed.
exit /B 0

endlocal