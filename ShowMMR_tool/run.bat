@echo off
pushd "%~dp0" & for %%J in (*.csproj) do set "release=%%~nJ.exe" & set "output=*.vcfg"
set PATH=%PATH%;%CD%\bin\Release\net7.0;%CD%\bin\Release\net6.0;%CD%\bin\Release\net480
where %release% /Q || (echo Use dotnet_build script first & timeout /t -1 >nul & exit /b)


%release% %*


if not defined output timeout /t -1 & exit /b
pushd "%~dp0" & for /f "delims=" %%A in ('dir %output% /a:-D/b/oD') do set "file=%%~A"
echo;
echo Press any key to also install: %file% or Alt+F4 to exit...
timeout /t -1 >nul

::# detect STEAM path
for /f "tokens=2*" %%R in ('reg query HKCU\SOFTWARE\Valve\Steam /v SteamPath 2^>nul') do set "steam_reg=%%S" & set "libfs="
for %%S in ("%steam_reg%") do set "STEAM=%%~fS" & set "STEAMAPPS=%%~fS\steamapps"

::# detect DOTA2 path
for /f usebackq^ delims^=^"^ tokens^=4 %%s in (`findstr /c:":\\" "%STEAM%\steamapps\libraryfolders.vdf"`) do (
 if exist "%%s\steamapps\appmanifest_570.acf" if exist "%%s\steamapps\common\dota 2 beta\game\core\pak01_dir.vpk" set "libfs=%%s")
if defined libfs set "STEAMAPPS=%libfs:\\=\%\steamapps"
set "DOTA2=%STEAMAPPS%\common\dota 2 beta"

::# install the generated file
copy /y %file% "%dota2%\game\dota\cfg\"

cmd /k

