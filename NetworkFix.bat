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
  wmic path win32_networkadapter where index=%%i call disable
)

timeout /t 5 /nobreak

:: Enable the same network adapters
for /l %%i in (0,1,5) do (
  wmic path win32_networkadapter where index=%%i call enable
)

:: Reset network settings
ipconfig /release
ipconfig /renew

:: Reset firewall, ARP cache, and more
netsh advfirewall reset
arp -d *
route -f
nbtstat -R
nbtstat -RR

:: Reset network components
netcfg -d
netsh winsock reset
netsh int 6to4 reset all
netsh int httpstunnel reset all
netsh int ip reset
netsh int ipv4 reset
netsh int ipv6 reset
netsh int isatap reset all
netsh int portproxy reset all
netsh int tcp reset all
netsh int teredo reset all
netsh branchcache reset

:: Restart essential services
sc config Dhcp start= auto
sc config DPS start= auto
sc config lmhosts start= auto
sc config NlaSvc start= auto
sc config nsi start= auto
sc config RmSvc start= auto
sc config Wcmsvc start= auto
sc config WdiServiceHost start= demand
sc config Winmgmt start= auto
sc config NcbService start= demand
sc config ndu start= demand
sc config Netman start= demand
sc config netprofm start= demand
sc config WlanSvc start= auto
sc config WwanSvc start= demand

:: Start required services
net start DPS
net start nsi
net start NlaSvc
net start Dhcp
net start Wcmsvc
net start RmSvc

:: Adjust TCP Size
netsh interface tcp set global autotuninglevel=experimental
netsh interface tcp set global rss=enabled
netsh interface tcp set global chimney=enabled

:: Disable Auto-Tuning
netsh interface tcp set global autotuning=disabled

:: Remove static ARP entries
arp -d *

:: Reset Windows Firewall
netsh advfirewall reset

:: Release and renew IP addresses
ipconfig /release
ipconfig /renew

:: Create new HOSTS File
echo # 127.0.0.1       localhost> %WINDIR%\System32\Drivers\Etc\Hosts
echo # ::1             localhost>> %WINDIR%\System32\Drivers\Etc\Hosts

:: Schedule a restart in 10 seconds
shutdown /r /t 10
pause
