#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=SetupS.ico
#AutoIt3Wrapper_Outfile=AddToHosts.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=AddToHosts. An ssTek component tool.
#AutoIt3Wrapper_Res_Fileversion=#ProjectVersion#
#AutoIt3Wrapper_Res_LegalCopyright=©#cYear#, #cHolder#
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Release Date|#ProjectDate#
#AutoIt3Wrapper_Res_Field=#WebSite1#|http://#WebLink1#
#AutoIt3Wrapper_Res_Field=#WebSite2#|http://#WebLink2#
#AutoIt3Wrapper_Res_Field=#WebSite3#|http://#WebLink3#
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=100
#AutoIt3Wrapper_UseX64=n
#endregion

#cs ##################################################################################

	AddToHosts v#ProjectVersion#
	Copyright © #cYear#, #cHolder#
	All rights reserved.

	This file is part of the SetupS SendTo Suite.

	The SetupS SendTo Suite is open-source software: you can redistribute it and/or
	modify it under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your option)
	any later version of the License.

	DISCLAIMER:
	The SetupS SendTo Suite is distributed in the hope that it will be useful, but is
	provided by #cHolder# "AS IS", without warranty of any kind, express or
	implied, including but not limited to the warranties of MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE, TITLE and NON-INFRINGEMENT. In no event shall
	the authors or #cHolder# be liable for any direct, indirect, incidental, special,
	exemplary, or consequential damages (including, but not limited to, procurement of
	substitute goods or services; loss of use, data, or profits; or business
	interruption) however caused and on any theory of liability, whether in an action
	of contract, strict liability, or tort (including negligence or otherwise) arising
	from, out of or in connection with the software or the use or other dealings in the
	software, even if advised of the possibility of such damage.

	See the GNU General Public License for more details. You should have received a
	copy of the GNU General Public License along with the SetupS SendTo Suite. If not,
	see <http://www.gnu.org/licenses/>.

#ce ##################################################################################
#cs ##################################################################################

	Script Function: Sets mappings of IP addresses to host names.

#ce ##################################################################################

Opt('MustDeclareVars', 1)
#include <Constants.au3>

Local $CLIparameters = $CMDLine, $CL = ''

;------------------------------------------------------ Debug & Testing -----------------------------------------------------------
If Not @Compiled Then
;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	;$CLIparameters[$CLIparameters[0]] = '"127.0.0.1 secure.realsoftware4.com"'
;~ 	$CLIparameters[$CLIparameters[0]] = '"127.0.0.1" "secure.realsoftware4.com" "#secure realsoftware4 com"'

;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '"127.0.0.1"'

;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '"secure.realsoftware4.com"'

;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '"#secure realsoftware4 com"'
EndIf

If IsArray($CLIparameters) Then
	For $i = 1 To $CLIparameters[0]
		$CL = $CL & '     ' & $CLIparameters[$i]
	Next
	AddToHosts(StringStripWS(StringReplace($CL, '"', ''), 7))
EndIf

Exit

Func AddToHosts($CL)
	Local $Test = HostsLine($CL), $File = @SystemDir & '\drivers\etc\hosts'
	If $Test <> '' And StringInStr($Test, ' ') Then
		Local $hFile = FileOpen($File, 0), $Found = False, $FilePos = 0, $Line, $EOF, $LastChar
		If $hFile <> -1 Then
			Do
				$Line = FileReadLine($hFile)
				$EOF = (@error = -1)
				If $EOF Then
					$FilePos = FileGetPos($hFile)
				ElseIf (HostsLine($Line) = $Test) Then
					$Found = True
				EndIf
			Until $EOF Or $Found
			FileClose($hFile)
			$hFile = FileOpen($File, 0)
			FileSetPos($hFile, $FilePos - 1, $FILE_BEGIN)
			$LastChar = Asc(FileRead($hFile))
			FileClose($hFile)
			FileSetAttrib($File, '-RH')
			If Not $Found Then
				FileSetAttrib($File, '-RH')
				$hFile = FileOpen($File, 1)
				If $hFile <> -1 Then
					If Not ($LastChar = 10 Or $LastChar = 13) Then FileWriteLine($hFile, '')
					FileWriteLine($hFile, $CL)
					FileClose($hFile)
				EndIf
				FileSetAttrib($File, '+RH')
			EndIf
		EndIf
	EndIf
EndFunc

Func HostsLine($CL)
	Local $temp = StringSplit(StringStripWS($CL, 4), ' ')
	If IsArray($temp) Then
		If $temp[0] > 1 Then ; Only first two
			Return StringStripWS(StringReplace($temp[1] & ' ' & $temp[2], '"', ''), 7)
		EndIf
	EndIf
	Return ''
EndFunc
