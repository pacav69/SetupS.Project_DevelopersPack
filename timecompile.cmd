

@REM Using PowerShell (as an administrator) in Windows 10, use the following command:

@REM Set-MpPreference -DisableRealtimeMonitoring $true
@REM To re-enable it:

@REM Set-MpPreference -DisableRealtimeMonitoring $false

@REM  disable anti virus before compiling
@REM %ProgramFiles%\Windows Defender\MpCmdRun.exe
timecmd.cmd !!Make.SetupS-Project.cmd