@echo off
pushd "%~dp0"
(del /f/s/q "bin\*.*" & rmdir /s/q "bin" & del /f/s/q "obj\*.*" & rmdir /s/q "obj") >nul 2>nul

