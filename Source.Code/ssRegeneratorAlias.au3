#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=Tiny.ico
#AutoIt3Wrapper_Outfile=Tools\Regenerator.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=Alias for SetupS Regenerator
#AutoIt3Wrapper_Res_Fileversion=23.07.17.0
#AutoIt3Wrapper_Res_LegalCopyright=©2017-2023, Vergitek Solutions
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Release Date|2023-07-17
#AutoIt3Wrapper_Res_Field=ssTek Forum|http://sstek.vergitek.com
#AutoIt3Wrapper_Res_Field=LastOS Team|http://www.lastos.org
#AutoIt3Wrapper_Res_Field=ssTek Distribution|http://dl.bintray.com/sstek
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=100
#AutoIt3Wrapper_UseX64=n
#endregion

Local $CLIparameters = $CMDLine
Run('ssRegenerator ' & ReconstructCmdLine($CLIparameters), '.', @SW_HIDE)

Func ReconstructCmdLine(ByRef $CLIparameters)
;~ 	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core.au3|ReconstructCmdLine()' & @CRLF)
	Local $i, $Temp = ''
	For $i = 1 To $CLIparameters[0]
		$Temp = $Temp & ' ' & $CLIparameters[$i]
	Next
	Return StringStripWS($Temp, 3)
EndFunc
