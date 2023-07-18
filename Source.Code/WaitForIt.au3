#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=SetupS.ico
#AutoIt3Wrapper_Outfile=WaitForIt.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=WaitForIt. An ssTek component tool.
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
	
	WaitForIt v#ProjectVersion#
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
	
	Script Function:
	Utility to force SetupS to pause until a specific file is created or copied to
	that location. Shortcut files (.lnk) are recommended because they are often
	created last by installers.
	
#ce ##################################################################################

Opt('MustDeclareVars', 1)
Local $CLIparameters = $CMDLine

;------------------------------------------------------ Debug & Testing -----------------------------------------------------------
If Not @Compiled Then

	;Some examples of how to use this:
;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '' ; specific test

EndIf

;------------------------------------------------------ Begin --------------------------------------------------------------------
If $CLIparameters[0] > 0 Then
	Do
		Sleep(100)
	Until FileExists($CLIparameters[1]) Or WinExists($CLIparameters[1])
	;RunWait(@ComSpec & ' /c echo "' & $CLIparameters[1] & '" >>' & @ScriptDir & '\' & $ThisAppTitle & '.Log', '.', @SW_HIDE)
EndIf
Exit
