@echo off
:: BatchGotAdmin
::-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    
    REM Get path from arguments without quotes and process spaces
    setlocal enabledelayedexpansion
    set "params="
    for %%I in (%*) do (
        set "arg=%%~I"
        if defined params (
            set "params=!params! ""!arg!"""
        ) else (
            set "params=""!arg!"""
        )
    )
	
    echo UAC.ShellExecute "cmd.exe", "/c """"%~s0"" !params!""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    endlocal

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

::--------------------------------------

::ENTER YOUR CODE BELOW:
setlocal enabledelayedexpansion
set "filename=service_list.txt"
set "tempfile=temp_service_list.txt"
REM The following directory is for .NET 4.0
set DOTNETFX2=%SystemRoot%\Microsoft.NET\Framework\v4.0.30319
set PATH=%PATH%;%DOTNETFX2%

REM Check if a parameter (file path) is provided
if "%~1"=="" (
    goto :uninstall
) else (
    goto :install
)

:install
REM Set service information
set service_bin="%~1"
set service_name=%~n1

:prompt_service_name
echo Install mode
echo Service bin: %service_bin%

:confirm_install
echo:
echo Current service name is: %service_name%
set /p confirm=Do you want to continue with this service name? (y/n): 

if /i "%confirm%"=="y" (
    echo Proceeding with service name: %service_name%
    echo:
    goto :do_install
) else if /i "%confirm%"=="n" (
    set /p service_name=Please enter a new service name: 
    cls
    goto :prompt_service_name
) else (
    echo Invalid input. Please enter 'y' or 'n'.
    goto :confirm_install
)

:do_install
echo Installing IEPPAMS Win Service...
echo ---------------------------------------------------
sc.exe create "%service_name%" binpath=%service_bin%
echo ---------------------------------------------------

REM Add service name in service_list.txt if install was successful
if '%errorlevel%' == '0' (
    echo %service_name%>> %filename%
)
goto :end


:uninstall
:: Counter for numbering services
set count=0

:: Read the file and list the services with numbers
for /f "tokens=*" %%A in (%filename%) do (
    set /a count+=1
    set "service[!count!]=%%A"
)

:services
echo Uninstall mode
if '%count%' == '0' (
    echo %filename% is empty.
    echo:
    goto :end
)
echo List of services:
for /l %%i in (1,1,%count%) do (
    echo %%i. !service[%%i]!
)

:: Prompt user to select a service by number
:choose
echo:
set /p "choice=Select a service by number: "

:: Validate the choice
if not defined service[%choice%] (
    echo Invalid choice.
    goto :choose
)

:: Set the selected service to a variable
set "selected_service=!service[%choice%]!"

:: Output the selected service
:confirm_uninstall
echo:
echo Current service name is: %selected_service%
set /p confirm=Are you sure you want to uninstall this service?: (y/n): 

if /i "%confirm%"=="y" (
    echo Proceeding with service name: %selected_service%
    echo:
    goto :do_uninstall
) else if /i "%confirm%"=="n" (
    cls
    goto :services
) else (
    echo Invalid input. Please enter 'y' or 'n'.
    goto :confirm_uninstall
)

:do_uninstall
echo Uninstalling IEPPAMS Win Service...
echo ---------------------------------------------------
sc.exe delete "%selected_service%"
echo ---------------------------------------------------

REM Remove service name from service_list.txt if uninstall was successful
if '%errorlevel%' == '0' (
    goto :remove_service
)
goto :end

:remove_service
:: Create a temporary file excluding the selected service
(for /f "tokens=*" %%A in (%filename%) do (
    if "%%A" neq "%selected_service%" echo %%A
)) > %tempfile%

:: Replace the original file with the temporary file
move /y %tempfile% %filename% >nul 2>&1
goto :end

:end
pause
echo Done.
