@echo off
set /a DOTNET_CLI_TELEMETRY_OPTOUT=1
dotnet build ShowMMR.csproj -c Release --self-contained=true -p:TargetFramework=net6.0
rem dotnet publish ShowMMR.csproj -r win-x64 -c Release --self-contained=true -p:TargetFramework=net6.0 -p:PublishSingleFile=true
cmd /k

