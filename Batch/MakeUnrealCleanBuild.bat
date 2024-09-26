REM ## Generic script to handle the making of builds in Unreal Engine 4/5
REM ## When used in CI/CD software, environment variables should be inject into the script

@echo off
setlocal

REM ## Perform all needed checks before running the script
set PATHTOPROJECT=PathToProjectDirectory 
set PATHTOENGINE=PathToEngineDirectory 
set PATHTOARCHIVE=PathToArchiveDirectory 

call :CheckPath "%PATHTOPROJECT%" "Project directory cannot be found."
call :CheckPath "%PATHTOENGINE%" "Engine directory cannot be found."
call :CheckPath "%PATHTOARCHIVE%" "Archive directory cannot be found."

REM ## Check for Visual Studio Installation, older Unreal versions also require checks for 2017/2015
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\Msbuild\Current\Bin\MSBuild.exe" (
 	set MSBUILD_EXE="%ProgramFiles%\Microsoft Visual Studio\2022\Community\Msbuild\Current\Bin\MSBuild.exe"
	goto ReadyToBuild
)
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\Msbuild\Current\Bin\MSBuild.exe" (
	set MSBUILD_EXE="%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\Msbuild\Current\Bin\MSBuild.exe"
	goto ReadyToBuild
)
echo Missing Visual Studio installation.
pause
goto ExitError

:ReadyToBuild
echo All checks passed, ready to build.
REM ## In some VCS like Perforce, make sure to remove the read-only from the folders
REM ## attrib -r "%PathToProject%\Binaries"\*" /s /d

REM ## List of generated folders to delete
del /s /q "%PATHTOPROJECT%\Binaries"
del /s /q "%PATHTOPROJECT%\Intermediate"
del /s /q "%PATHTOPROJECT%\Saved"
REM ## Build folder is optional, with Android projects with keystore DO NOT delete it, it will trigger a build error if in shipping mode for distribution
REM ## del /s /q "%PathToProject%\Build"

REM ## Generate Visual Studio project files
"%PathToEngine%\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe" -projectfiles -project="%PATHTOPROJECT%\ProjectName.uproject" -game -rocket -progress

REM ## Recompile the C++ code
"%MSBUILD_EXE%" "%PATHTOPROJECT%\ProjectName.sln" /t:build /p:Configuration="Development Editor";Platform=Win64;verbosity=diagnostic

REM ## Make example Android build, for Windows change -targetPlatform, remove -cookflavor
REM ## Good reference for list of commands: https://github.com/botman99/ue4-unreal-automation-tool
"%PathToEngine%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun -nocompile -nocompileeditor -installed -nop4 -project="%PATHTOPROJECT%\ProjectName.uproject" -cook -stage -archive -archivedirectory="%PATHTOARCHIVE%" -package -clean -compressed -SkipCookingEditorContent -pak -prereqs -nodebuginfo -targetplatform=Android -cookflavor=ASTC -build -clientconfig=Development -utf8output
goto Cleanup

:CheckPath
if not exist "%~1" (
    echo.
    echo %2
    echo.
    pause
    goto ExitError
)

:Cleanup
REM ## Optional addition back of the read-only if removed 
REM ## attrib +r "%PathToProject%\Binaries"\*" /s /d
goto ExitSuccess

:ExitError
exit /B 1

:ExitSuccess
exit /B 0

endlocal