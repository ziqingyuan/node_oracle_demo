@echo off
setlocal enabledelayedexpansion

:: Take input from the user
set /p destination_port="Enter your remote Node starting port number: "

set START=55001
set END=60000

:: Check if the provided port is free
netstat -an | find ":%destination_port%" > nul
if errorlevel 1 (
    echo Port %destination_port% is available.
    set chosen_port=%destination_port%
) else (
    :: If not free, find a port in the range START-END
    for /l %%i in (%START%,1,%END%) do (
        netstat -an | find "%%i" > nul
        if errorlevel 1 (
            echo Port %%i is available.
            set chosen_port=%%i
            goto portFound
        )
    )
)

:portFound
:: If no port is found in the range, exit 1
if not defined chosen_port (
    echo No free port found in range !START!-!END!.
    exit /b 1
)

echo --------------------------------------------------------------------------
echo         You will be able to access your application at:
echo         http://localhost:!chosen_port!
echo         after completing the steps below...
echo --------------------------------------------------------------------------


:: 4. Build the SSH tunnel using the chosen port
echo Building SSH tunnel using port !chosen_port!...
set /p cwl_name="Enter your CWL name: "

:: Insert your ssh command here, e.g.,
ssh -L !chosen_port!:localhost:!destination_port! !cwl_name!@remote.students.cs.ubc.ca

exit /b 0
