@echo off
set /a DOTNET_CLI_TELEMETRY_OPTOUT=1
dotnet build ShowMMR.csproj -c Release -p:TargetFramework=net48
cmd /k

