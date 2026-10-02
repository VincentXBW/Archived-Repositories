@echo off
color 0a
title MultiTool
cls

:header
echo.
echo  ===============================================
echo  ||                 MULTI TOOL                ||
echo  ===============================================
echo.
echo   Type the number and press ENTER.
echo.
echo           (\_/)
echo           ( •_•)
echo          / >💾
echo.

echo  1  - System Info
echo  2  - Disk Usage
echo  3  - Network Info
echo  4  - Ping & Traceroute
echo  5  - Port Check
echo  6  - Processes
echo  7  - Kill Process
echo  8  - File Search
echo  9  - Backup Folder
echo 10  - Notes
echo 11  - Event Logs
echo 12  - Health Check
echo 13  - CMD Console
echo 14  - Restart Explorer
echo 15  - Shutdown
echo 16  - Restart
echo 17  - Exit
echo.
set /p choice=Choose: 

if "%choice%"=="1" goto sysinfo
if "%choice%"=="2" goto diskusage
if "%choice%"=="3" goto netinfo
if "%choice%"=="4" goto pingtrace
if "%choice%"=="5" goto portcheck
if "%choice%"=="6" goto listprocs
if "%choice%"=="7" goto killproc
if "%choice%"=="8" goto searchfiles
if "%choice%"=="9" goto backup
if "%choice%"=="10" goto createnote
if "%choice%"=="11" goto eventlog
if "%choice%"=="12" goto healthcheck
if "%choice%"=="13" start cmd & goto header
if "%choice%"=="14" goto restartexplorer
if "%choice%"=="15" shutdown /s /t 0 & exit
if "%choice%"=="16" shutdown /r /t 0 & exit
if "%choice%"=="17" goto exit

echo Invalid choice.
pause>nul
cls
goto header

:sysinfo
cls
systeminfo | findstr /B /C:"Host Name" /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Total Physical Memory"
tasklist /FI "STATUS eq running" | find /C /I ""
pause
cls
goto header

:diskusage
cls
wmic logicaldisk get name,size,freespace
pause
cls
goto header

:netinfo
cls
ipconfig /all
pause
cls
goto header

:pingtrace
cls
set /p host=Host: 
ping -n 4 %host%
tracert %host%
pause
cls
goto header

:portcheck
cls
set /p porthost=Host: 
set /p portnum=Port: 
echo Testing connection...
powershell -NoProfile -Command "try{(New-Object Net.Sockets.TcpClient('%porthost%',%portnum%)).Close();'Port %portnum% OPEN'}catch{'Port %portnum% CLOSED'}"
pause
cls
goto header

:listprocs
cls
tasklist | more
pause
cls
goto header

:killproc
cls
set /p proc=Process or PID: 
taskkill /F /IM "%proc%" 2>nul || taskkill /F /PID %proc% 2>nul
pause
cls
goto header

:searchfiles
cls
set /p filename=File pattern: 
dir /s /b "%filename%"
pause
cls
goto header

:backup
cls
set /p src=Source: 
set /p dest=Destination: 
xcopy "%src%" "%dest%" /E /I /H /Y
echo Backup complete.
pause
cls
goto header

:createnote
cls
set /p notefile=File (notes.txt default): 
if "%notefile%"=="" set notefile=notes.txt
set /p note=Note: 
echo %date% %time% - %note%>>"%notefile%"
echo Saved.
pause
cls
goto header

:eventlog
cls
wevtutil qe System /f:text /c:20
pause
cls
goto header

:healthcheck
cls
echo Checking disk space...
wmic logicaldisk get name,freespace,size
echo.
echo Checking key services...
sc query wuauserv | find "STATE"
sc query w32time | find "STATE"
sc query bits | find "STATE"
pause
cls
goto header

:restartexplorer
cls
taskkill /f /im explorer.exe
start explorer.exe
cls
goto header

:exit
cls
echo Done.
color 07
exit /b
