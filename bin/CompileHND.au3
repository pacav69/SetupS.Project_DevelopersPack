#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=version based on SetupS Core
#AutoIt3Wrapper_Res_Description=Kludge to compile new .chm/.hhp from .hnd
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=100
#endregion

#cs ##################################################################################
	
	CompileHND
	
	Script Function:
	Kludge to compile a new .CHM-file from the corresponding .HND-file and retrieve
	its modified .HHP-file. Only need to use this once -- after editing	the .HND-file.
	
	(Optional) Can also use the utility "OpenWithArguments" to input as parameter a
	clipboard copy of the Project source files string available from the
	Generation Output box.
	
#ce ##################################################################################

#include <..\Source.Code\SetupS.Core.au3>
Opt("WinTitleMatchMode", 4) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
If Not @Compiled Then
	If $CLIparameters[0] = 0 Then
		$CLIparameters[0] = $CLIparameters[0] + 1
		ReDim $CLIparameters[$CLIparameters[0] + 1]
		$CLIparameters[$CLIparameters[0]] = 'D:\ssTEK.Projects\SetupS.Sendto.Suite\vCurrent\Source.Code'

		$CLIparameters[0] = $CLIparameters[0] + 1
		ReDim $CLIparameters[$CLIparameters[0] + 1]
		$CLIparameters[$CLIparameters[0]] = 'ssTek'
	EndIf
EndIf
Local $i, $j, $Helpndoc, $iFileList, $jFileList, $PID
If $CLIparameters[0] > 1 Then
	Local $BasePath = $CLIparameters[1], $BaseName = $CLIparameters[2]
	$Helpndoc = @ProgramFilesDir & '\HelpNDoc\helpndoc.exe'
	If Not FileExists($Helpndoc) Then $Helpndoc = @ProgramsCommonDir & '\HelpNDoc\helpndoc.exe'
	If Not FileExists($Helpndoc) Then
		GetppDrives()
		$Helpndoc = ConvertFromVars('%ppapps%') & '\HelpNDoc\helpndoc.exe'
	EndIf
	If FileExists($Helpndoc) Then
		If FileExists($BasePath & '\' & $BaseName & '.chm') Then DeleteMe($BasePath & '\' & $BaseName & '.chm')
		If FileExists($BasePath & '\' & $BaseName & '.hhp') Then DeleteMe($BasePath & '\' & $BaseName & '.hhp')
		If FileExists($BasePath & '\' & $BaseName & '.html') Then DeleteMe($BasePath & '\' & $BaseName & '.html')
		If FileExists($BasePath & '\files') Then DeleteMe($BasePath & '\files')
		$iFileList = _FileListToArray(@TempDir, '*.*', 2) ; Return folders only
		$PID = Run($Helpndoc & ' ' & '".\' & $BaseName & '.hnd" /c /sxc /sxh /uxp /uxr /oxc=".\' & $BaseName & '.chm" /oxh=".\' & $BaseName & '.html"', $BasePath, @SW_HIDE)
		WinWait('[TITLE:' & $Helpndoc & '; CLASS:ConsoleWindowClass]')
		;Search for (most current) Project.hhp
		$jFileList = _FileListToArray(@TempDir, '*.*', 2) ; Return folders only
		If IsArray($jFileList) Then
			If IsArray($iFileList) Then
				For $i = 1 To $iFileList[0]
					For $j = 1 To $jFileList[0]
						If StringCompare($iFileList[$i], $jFileList[$j]) <> 0 Then
							If StringLeft($jFileList[$j], 1) = '{' And StringRight($jFileList[$j], 1) = '}' Then
								If FileExists(@TempDir & '\' & $jFileList[$j] & '\Project.hhp') Then CreateHHP(@TempDir & '\' & $jFileList[$j] & '\Project.hhp', $BasePath & '\' & $BaseName & '.hhp')
								DeleteMe(@TempDir & '\' & $jFileList[$j])
							EndIf
						EndIf
					Next
				Next
			Else
				For $j = 1 To $jFileList[0]
					If StringLeft($jFileList[$j], 1) = '{' And StringRight($jFileList[$j], 1) = '}' Then
						If FileExists(@TempDir & '\' & $jFileList[$j] & '\Project.hhp') Then CreateHHP(@TempDir & '\' & $jFileList[$j] & '\Project.hhp', $BasePath & '\' & $BaseName & '.hhp')
						DeleteMe(@TempDir & '\' & $jFileList[$j])
					EndIf
				Next
			EndIf
		EndIf
		WinClose('[TITLE:' & $Helpndoc & '; CLASS:ConsoleWindowClass]')
		If ProcessExists($PID) Then ProcessClose($PID)
	EndIf
EndIf

Exit

Func CreateHHP($VarIn, $VarOut)
	If FileCopy($VarIn, $VarOut, 1) Then
		Local $CHM = IniRead($VarOut, 'OPTIONS', 'Compiled file', '')
		IniWrite($VarOut, 'OPTIONS', 'Compiled file', StringRight($CHM, StringLen($CHM) - StringInStr($CHM, '\', -1, -1)))
	EndIf
EndFunc
