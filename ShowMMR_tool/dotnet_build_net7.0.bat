@echo off
set /a DOTNET_CLI_TELEMETRY_OPTOUT=1
dotnet build ShowMMR_net7.csproj -c Release -p:TargetFramework=net7.0
rem dotnet publish -r win-x64 -c Release --self-contained=true -p:TargetFramework=net7.0 -p:PublishSingleFile=true
cmd /k

