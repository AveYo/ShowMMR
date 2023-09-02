@echo off

set /a DOTNET_VER=0
for /f "tokens=* delims=" %%v in ('dotnet --version 2^>nul') do set "DOTNET_VER=%%v"
set /a DOTNET_VER=%DOTNET_VER:~0,1%+0 
if %DOTNET_VER% neq 7 (echo  AveYo: dotnet sdk 7.0 required to build this version & timeout /t -1 & exit /b)

set /a DOTNET_CLI_TELEMETRY_OPTOUT=1

pushd "%~dp0"

dotnet build ShowMMR_net7.csproj -c Release --self-contained=false -p:TargetFramework=net7.0

rmdir /s/q "obj" >nul 2>nul 

timeout /t -1 

