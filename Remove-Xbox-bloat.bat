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

:: Disable Xbox Game Monitoring Service
reg add "HKLM\System\CurrentControlSet\Services\xbgm" /v "Start" /t REG_DWORD /d "4" /f

:: Disable Xbox Services
sc config XblAuthManager start=disabled
sc config XblGameSave start=disabled
sc config XboxGipSvc start=disabled
sc config XboxNetApiSvc start=disabled

:: Disable Xbox GameSave Task
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /Disable

:: Disable GameBarPresenceWriter.exe
takeown /f "%WinDir%\System32\GameBarPresenceWriter.exe" /a
icacls "%WinDir%\System32\GameBarPresenceWriter.exe" /grant:r Administrators:F /c
taskkill /im GameBarPresenceWriter.exe /f
move "%WinDir%\System32\GameBarPresenceWriter.exe" "%WinDir%\System32\GameBarPresenceWriter.OLD"

:: Disable bcastdvr.exe
takeown /f "%WinDir%\System32\bcastdvr.exe" /a
icacls "%WinDir%\System32\bcastdvr.exe" /grant:r Administrators:F /c
taskkill /im bcastdvr.exe /f
move "%WinDir%\System32\bcastdvr.exe" "%WinDir%\System32\bcastdvr.OLD"

:: Disable GameDVR and Gamebar settings
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AudioCaptureEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "CursorCaptureEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d "0" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f

:: Disable GameDVR via Group Policy
reg add "HKLM\Software\Policies\Microsoft\Windows\GameDVR" /v "AllowgameDVR" /t REG_DWORD /d "0" /f

:: Disable Auto Game Mode in Gamebar
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f

pause
