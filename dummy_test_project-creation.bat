@echo off
setlocal enabledelayedexpansion

set "baseDir=D:\FLUTTER\DUMMY_PROJECTS"
set "projectCount=5"
set "folders=pods .dart_tool .vscode build .idea .gradle ephemeral .flutter-plugins .flutter-plugins-dependencies .flutter-versions .metadata .packages"

:: Create base dir
mkdir "%baseDir%"

:: Loop to create dummy Flutter projects
for /L %%i in (1,1,%projectCount%) do (
    set "projectPath=%baseDir%\dummy_project_%%i"
    echo Creating dummy_project_%%i
    flutter create --project-name dummy_project_%%i "!projectPath!" >nul

    :: Create dummy folders inside project
    cd /d "!projectPath!"
    for %%f in (%folders%) do (
        mkdir "%%f"
    )
)

echo ✅ Dummy Flutter projects created with simulated build folders.
pause
