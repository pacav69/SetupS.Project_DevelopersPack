#NoTrayIcon
#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Tiny.ico
#AutoIt3Wrapper_Outfile=bin\RunWait86.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=Embedded utility for Running DOS-x86
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=100
#AutoIt3Wrapper_UseX64=n
#endregion

#cs ##################################################################################

	Script Function:
	Part of SetupS (exclusively) as it forces an x86 shell process on an x64 OS-Arch.
	Mainly useful for importing (x86) registry entries.

#ce ##################################################################################

Opt('TrayIconHide', 1) ;Hide tray icon
RunWait($CmdLineRaw, '', @SW_HIDE)
