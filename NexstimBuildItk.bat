echo off

rem USAGE: NexstimBuildItk.bat [PRESET] [SOURCE_DIR] [BUILD_DIR] [INSTALL_DIR]
rem - [PRESET]      Name of the preset in the CMakePresets.json file.
rem - [SOURCE_DIR]  Source directory of the out-of-source build. This can be relative or absolute path.
rem - [BUILD_DIR]   Build directory of the out-of-source build. This can be relative or absolute path.
rem - [INSTALL_DIR] Target installation directory. This needs to be an absolute path.
rem                 Subdirectories bin, include, lib and share of the [INSTALL_DIR] will be deleted before installation.
rem.
rem EXAMPLE:
rem - Directory structure before the command if C:\builds directory is a root directory:
rem     C:\builds
rem     ├───itk-src
rem.
rem - Command in the c:\builds directory:
rem C:\builds> itk-src\NexstimBuildItk.bat MSVC142_X64 itk-src itk-build c:\builds\itk
rem.
rem - Directory structure after the command:
rem     C:\builds
rem     ├───itk
rem     │   ├───bin
rem     │   │   ├───Debug
rem     │   │   ├───Release
rem     │   │   └───UsableDebug
rem     │   ├───include
rem     │   ├───lib
rem     │   │   ├───Debug
rem     │   │   ├───Release
rem     │   │   └───UsableDebug
rem     │   └───share
rem     ├───itk-build
rem     └───itk-src

set PRESET=%1
set SOURCE_DIR=%2
set BUILD_DIR=%3
set INSTALL_DIR=%4
set CONFIGS=Release, Debug, UsableDebug
set ADDITIONAL_FILES=%SOURCE_DIR%\LICENSE, %SOURCE_DIR%\NOTICE

echo Configuring project for all configurations ...
cmake --preset %PRESET% -S %SOURCE_DIR% -B %BUILD_DIR% --install-prefix %INSTALL_DIR%

echo Cleaning ...
setlocal enabledelayedexpansion
for %%D in (bin, include, lib, share) do (
     rd /s /q %INSTALL_DIR%\%%D
)

echo Building and installing configurations to own directories ...
for %%C in (%CONFIGS%) do (
     cmake --build %BUILD_DIR% --config %%C
     cmake --install %BUILD_DIR% --config %%C --prefix %INSTALL_DIR%
     copy /Y %BUILD_DIR%\lib\%%C\*.pdb %INSTALL_DIR%\lib\%%C
)

echo Copying additional files to intallation ...
for %%F in (%ADDITIONAL_FILES%) do (
     copy /Y %%F %INSTALL_DIR%
)
