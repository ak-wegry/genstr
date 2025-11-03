@echo off
setlocal EnabledeLayedExpansion

set argc=0
set args=
for %%P in (%*) do (
	set /a argc=!argc!+1
	if !argc! gtr 1 (
		set args=!args!
	)
	set args=!args!%%P
)

set PROG=%~dp0%genstr.awk
set CURDIR=%~dp0%

if %argc% neq 0 (
	echo %args% | gawk -f %PROG% -
) else (
	echo.| gawk -f %PROG% -
)
