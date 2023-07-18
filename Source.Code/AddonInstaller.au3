#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=SetupS.ico
#AutoIt3Wrapper_Outfile=AddonInstaller.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=AddonInstaller. An ssTek component tool.
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

	AddonInstaller v#ProjectVersion#
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
	Utility to for SetupS to install addon packages
	(especially from sites like RyanVM & Wincert, etc.)

#ce ##################################################################################

Opt('MustDeclareVars', 1)
#include <File.au3>
Local $CLIparameters = $CMDLine

;------------------------------------------------------ Debug & Testing -----------------------------------------------------------
$CLIparameters = $CMDLine
If Not @Compiled Then
	;Some examples of how to use this:
	$CLIparameters[0] += 1
	ReDim $CLIparameters[$CLIparameters[0] + 1]
	$CLIparameters[$CLIparameters[0]] = 'D:\ssTEK.Projects\SetupS.Sendto.Suite\tester-folder\!Kels.Runtimes_v7.6.1_ssApp\Kels_Runtimes_addon_v7.6.rar' ; specific test
EndIf

;------------------------------------------------------ Begin --------------------------------------------------------------------
If $CLIparameters[0] > 0 Then
	If FileExists($CLIparameters[1]) Then
		Local $INF, $Temp = _TempFile(), $PID, $var
		$Temp = FileGetShortName(StringLeft($Temp, StringLen($Temp) - 4)) & '\AddonInst'
		DirRemove($Temp, 1)
		RunWait('7z x -y -aoa "' & $CLIparameters[1] & '" -o"' & $Temp & '"', '.', @SW_HIDE)
		RunWait('7z x -y -aoa "' & $Temp & '\*.cab" -o"' & $Temp & '\i386"', '.', @SW_HIDE)
		RunWait('7z x -y -aoa "' & $Temp & '\*.in_" -o"' & $Temp & '"', '.', @SW_HIDE)
		$INF = _FileListToArray($Temp, '*.inf', 1)
		If @error <> 1 Then
			;$PID = Run(@SystemDir & '\rundll32.exe syssetup,SetupInfObjectInstallAction DefaultInstall 128 ' & $Temp & '\' & $INF[1], $Temp, @SW_SHOWNORMAL)
			;$PID = Run(@SystemDir & '\rundll32.exe setupapi.dll,InstallHinfSection DefaultInstall 132 ' & $Temp & '\' & $INF[1], $Temp, @SW_SHOWNORMAL)
			$PID = Run(@SystemDir & '\rundll32.exe advpack.dll,LaunchINFSectionEx ' & $Temp & '\' & $INF[1] & ',,,4,N', $Temp, @SW_SHOWNORMAL)
			Do
				Sleep(100)
				$var = ControlGetText('Confirm File Replace', 'target file exists', 'Button3')
				If $var <> '' Then ClickMe('Confirm File Replace', 'target file exists', 'Button3')
			Until Not ProcessExists($PID)
			FileCopy($Temp & '\' & $INF[1], @WindowsDir & '\inf', 1)
			Sleep(100)
		EndIf
		RunWait(@ComSpec & ' /c attrib . -R -S -H', $Temp, @SW_HIDE)
		FileSetAttrib($Temp & '\*.*', '-R-S-H+N', 1)
		DirRemove($Temp, 1)
	EndIf
EndIf
Exit

Func ClickMe($a, $b, $c) ;"title", "text", controlID
	Do
		Sleep(10)
	Until ControlCommand($a, $b, $c, "IsVisible", "")
	Do
		Sleep(10)
	Until ControlCommand($a, $b, $c, "IsEnabled", "")
	ControlClick($a, $b, $c)
EndFunc
