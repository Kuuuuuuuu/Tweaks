@echo off

:: Check if the script is running with administrator privileges
NET SESSION >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges.
) else (
    echo Please run this script as an administrator.
    pause
    exit /b 1
)

setlocal enabledelayedexpansion

:: Disable specific network adapters (index 0-5)
for /l %%i in (0,1,5) do (
    wmic path win32_networkadapter where index=%%i call disable >nul 2>&1
)

timeout /t 5 /nobreak >nul

:: Enable the same network adapters
for /l %%i in (0,1,5) do (
    wmic path win32_networkadapter where index=%%i call enable >nul 2>&1
)

:: Reset firewall, ARP cache, and more
netsh advfirewall reset >nul 2>&1
arp -d * >nul 2>&1
route -f >nul 2>&1
nbtstat -R >nul 2>&1
nbtstat -RR >nul 2>&1

:: Reset network components
netcfg -d >nul 2>&1
netsh winsock reset >nul 2>&1
netsh int 6to4 reset all >nul 2>&1
netsh int httpstunnel reset all >nul 2>&1
netsh int ip reset >nul 2>&1
netsh int ipv4 reset >nul 2>&1
netsh int ipv6 reset >nul 2>&1
netsh int isatap reset all >nul 2>&1
netsh int portproxy reset all >nul 2>&1
netsh int tcp reset all >nul 2>&1
netsh int teredo reset all >nul 2>&1
netsh branchcache reset >nul 2>&1

:: Restart essential services
sc config Dhcp start= auto >nul 2>&1
sc config DPS start= auto >nul 2>&1
sc config lmhosts start= auto >nul 2>&1
sc config NlaSvc start= auto >nul 2>&1
sc config nsi start= auto >nul 2>&1
sc config RmSvc start= auto >nul 2>&1
sc config Wcmsvc start= auto >nul 2>&1
sc config WdiServiceHost start= demand >nul 2>&1
sc config Winmgmt start= auto >nul 2>&1
sc config NcbService start= demand >nul 2>&1
sc config ndu start= demand >nul 2>&1
sc config Netman start= demand >nul 2>&1
sc config netprofm start= demand >nul 2>&1
sc config WlanSvc start= auto >nul 2>&1
sc config WwanSvc start= demand >nul 2>&1

:: Start required services
net start DPS >nul 2>&1
net start nsi >nul 2>&1
net start NlaSvc >nul 2>&1
net start Dhcp >nul 2>&1
net start Wcmsvc >nul 2>&1
net start RmSvc >nul 2>&1

:: TCP settings
netsh interface tcp set global autotuninglevel=experimental >nul 2>&1
netsh interface tcp set global rss=enabled >nul 2>&1

:: Release and renew IP addresses
ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
ipconfig /flushdns >nul 2>&1

:: Create new HOSTS File
echo # 127.0.0.1       localhost> %WINDIR%\System32\Drivers\Etc\Hosts
echo # ::1             localhost>> %WINDIR%\System32\Drivers\Etc\Hosts

:: Schedule a restart in 10 seconds
shutdown /r /t 10
pause
