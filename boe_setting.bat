
@echo off
@CLS
@ECHO.
@chcp 936 >nul
@ECHO =========================
@ECHO BOE P510 设置工具
@ECHO =========================


@:init
@setlocal DisableDelayedExpansion
@set "batchPath=%~0"
@for %%k in (%0) do set batchName=%%~nk
@set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
@setlocal EnableDelayedExpansion

@:checkPrivileges
@NET FILE 1>NUL 2>NUL
@if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

@:getPrivileges
@if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
@ECHO.
@ECHO **************************************
@ECHO 获取Administrator权限中，请点击同意！
@ECHO **************************************

@ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
@ECHO args = "ELEV " >> "%vbsGetPrivileges%"
@ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
@ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
@ECHO Next >> "%vbsGetPrivileges%"
@ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
@"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
@exit /B

@:gotPrivileges
@setlocal & pushd .
@cd /d %~dp0
@if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

@::::::::::::::::::::::::::::
@::START
@::::::::::::::::::::::::::::
@set workpath=%cd%\temp
@set toolpath=%cd%\tools
@echo 修改BIOS设置中，请稍后！
%toolpath%\CFGWIN_x64.exe /r /path:%workpath%\bios.txt
@echo 修改电源计划中，请稍后！！
powercfg.exe -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >%workpath%\power.txt
set /p T=<%workpath%\power.txt
powercfg.exe /S %T:~11,36%
@rd /S/Q "%workpath%"
@rd /S/Q "%cd%\tools"
@del %0