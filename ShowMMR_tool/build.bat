@echo off

set msbuild=& set clr="%SystemRoot%\Microsoft.NET\Framework\*MSBuild.exe" "%SystemRoot%\Microsoft.NET\Framework64\*MSBuild.exe"
for /f "tokens=* delims=" %%v in ('dir /b /s /a:-d /o:-n %clr%') do set msbuild="%%v"
if not defined msbuild (echo  AveYo: .net MSBuild.exe not found - it should come with windows & timeout /t -1 >nul & exit /b)
if not exist "%~dp0packages\*.nupkg" (echo  AveYo: packages\*.nupkg not found! - use build_vs & timeout /t -1 >nul & exit /b)
pushd "%~dp0packages"
set pkg=& for /r %%W in (*.nupkg) do if exist "%%~nW\lib" (dir /b /s /a:-d "%%~nW\lib\*.dll" >nul || set pkg=1) else set pkg=1
if defined pkg call :UNZIP *.nupkg
pushd "%~dp0"

%msbuild% ShowMMR.csproj /p:Configuration=Release;TargetFramework=net48

rmdir /s/q "obj" >nul 2>nul 

timeout /t -1  & exit /b

#:UNZIP:# [PARAMS] "file" [optional]"path"
set ^ #=;$f0=[io.file]::ReadAllText($env:0); $0=($f0-split '#\:UNZIP\:' ,3)[1]; $1=$env:1-replace'([`@$])','`$1'; iex($0+$1)
set ^ #=& set "0=%~f0"& set 1=;UNZIP %*& powershell -nop -c "%#%"& exit /b %errorcode%
function UNZIP ($file, $target = (get-location).Path) { dir $file |foreach { $fn = $_.FullName; $dir = "$target\$($_.BaseName)"
  $zip = "${fn}.zip"; ren $fn $zip -force -ea 0; if (!(test-path $dir)) {mkdir $dir -ea 0 >''}
  if (get-command Expand-Archive -ea 0) {Expand-Archive $zip $dir -force -ea 0} else { $s = new-object -com shell.application
  foreach($i in $s.NameSpace($zip).items()) {$s.Namespace($dir).copyhere($i,1556)} } ; ren $zip $fn -force -ea 0
}} #:UNZIP:# extract zip(s) with powershell - snippet by AveYo, 2023.02.10