echo off

rem Example: NexstimBuildItk.bat itk-src\CmakeBuildItk.bat MSVC142_X64 itk-src itk-build c:\builds\itk

set PRESET=%1
set SOURCEDIR=%2
set BUILDDIR=%3
set INSTALLDIR=%4

echo Configuring project for all configurations ...
cmake --preset %PRESET% -B %BUILDDIR% -S %SOURCEDIR% --install-prefix %INSTALLDIR%

echo Cleaning ...
setlocal enabledelayedexpansion
for %%D in (bin, include, lib, share) do (
    rd /s /q %INSTALLDIR%\%%D
)

echo Building and installing Release configuration ...
set CONFIG=Release
cmake --build %BUILDDIR% --target INSTALL --config %CONFIG%
mkdir %INSTALLDIR%\lib\%CONFIG%
move /Y %INSTALLDIR%\lib\*.lib %INSTALLDIR%\lib\%CONFIG%
copy /Y %BUILDDIR%\lib\%CONFIG%\*.pdb %INSTALLDIR%\lib\%CONFIG%

echo Building and installing other configurations
for %%C in (Debug, UsableDebug, MinSizeRel, RelWithDebInfo) do (
    cmake --build %BUILDDIR% --config %%C
    mkdir %INSTALLDIR%\lib\%%C
    copy /Y %BUILDDIR%\lib\%%C\*.lib %INSTALLDIR%\lib\%%C
    copy /Y %BUILDDIR%\lib\%%C\*.pdb %INSTALLDIR%\lib\%%C
)

rem Copying additional files to intallation ...
for %%F in (%SOURCEDIR%\LICENSE, %SOURCEDIR%\NOTICE) do (
    copy /Y %%F %INSTALLDIR%
)
