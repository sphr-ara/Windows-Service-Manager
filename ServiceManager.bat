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
    echo UAC.ShellExecute "cmd.exe", "/c """"%~s0"" ""%~1""""", "", "runas", 1 >> "%temp%\getadmin.vbs"

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
    goto :management
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
choice /c yn /n /m "Do you want to continue with this service name? (y/n)" 

if %errorlevel% == 1 (
    cls
    echo Installing %service_name%
    echo:
    goto :do_install
) else (
    set /p service_name=Please enter a new service name: 
    cls
    goto :prompt_service_name
)

:do_install
echo Installing IEPPAMS Win Service...
echo ---------------------------------------------------
sc.exe create "%service_name%" binpath=%service_bin%
echo ---------------------------------------------------

REM Add service name in service_list.txt if install was successful
if '%errorlevel%' == '0' (
    echo %service_name%>> %filename%
	goto :install_description
)
goto :end

:install_description
echo:
choice /c yn /n /m "Do you want to set description for the installed service?: (y/n)"

if %errorlevel% == 1 (
    set "selected_service=!service_name!"
    goto :get_description
) else ( goto :eof )

:management
:: Counter for numbering services
set count=0

:: Read the file and list the services with numbers
for /f "tokens=*" %%A in (%filename%) do (
    set /a count+=1
    set "service[!count!]=%%A"
)

:services
echo Management mode
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

:: Confirm selected service
:confirm_management
echo:
echo Current service name is: %selected_service%
choice /c yn /n /m "Are you sure you want to continue with this service?: (y/n)"

if %errorlevel% == 1 (
    goto :choose_action
) else (
    cls
    goto :services
)

:choose_action
cls
echo %selected_service% management
echo:
echo Please choose your action:
echo 1. Uninstall
echo 2. Set description
choice /c 12 /n

if %errorlevel% == 1 (
    goto :confirm_uninstall
) else ( goto :get_description )

:confirm_uninstall
cls
echo Current service name is: %selected_service%
choice /c yn /n /m "Are you sure you want to uninstall this service?: (y/n)"

if %errorlevel% == 1 (
    cls
    echo Uninstalling %selected_service%
    echo:
    goto :do_uninstall
) else (
    cls
    goto :choose_action
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

:get_description
cls
echo Setting description for %selected_service% service
echo Please write your description for this service:
set /p description=
echo:
echo Entered description: "%description%"
choice /c yn /n /m "Continue?: (y/n)"

if %errorlevel% == 1 (
    cls
    echo Setting description for %selected_service% service
    echo:
    goto :set_description
) else ( goto :get_description )

:set_description
echo Setting IEPPAMS Win Service description...
echo ---------------------------------------------------
sc.exe description "%selected_service%" "%description%"
echo ---------------------------------------------------

:end
pause
:eof
echo Done.
