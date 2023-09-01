@echo off

set msbuild=& set clr="%SystemRoot%\Microsoft.NET\Framework\*MSBuild.exe" "%SystemRoot%\Microsoft.NET\Framework64\*MSBuild.exe"
for /f "tokens=* delims=" %%v in ('dir /b /s /a:-d /o:-n %clr%') do set msbuild="%%v"
if not defined msbuild (echo  AveYo: .net MSBuild.exe not found - it should come with windows & timeout /t -1 >nul & exit /b)

pushd "%~dp0"

%msbuild% ShowMMR.csproj /p:Configuration=Release;TargetFramework=net48

rmdir /s/q "obj" >nul 2>nul 

choice /c EX1T
