@echo off
pushd "%~dp0"
del /f /s /q ".vs\*.*" & rmdir /s /q ".vs"
del /f /s /q "bin\*.*" & rmdir /s /q "bin"
del /f /s /q "obj\*.*" & rmdir /s /q "obj"
for /d %%W in ("packages\*") do del /f /s /q "%%~W\*.*" & rmdir /s /q "%%~W"
