#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=SetupS.ico
#AutoIt3Wrapper_Outfile=Tools\FaderModules\RunRUNAway.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=SetupS Fadertainer Module - RunRUNAway.
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

	SetupS Fadertainer Module - RunRUNAway v#ProjectVersion#
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
	SetupS Fadertainer moves away from the mouse.
	Automatic exit after 8 second timeout.

#ce ##################################################################################
#include <Misc.au3>

Opt("TrayIconHide", 1) ;Hide Tray Icon

If _Singleton(@ScriptName, 1) = 0 Then Exit ;Only One Instance

; Script Start - Add your code below here
Dim $IcoPos[6]

Dim $CurX
Dim $CurY
Dim $CurW
Dim $CurH

Dim $OldW
Dim $OldH

Dim $Px = -256
Dim $Py = -256

Dim $Xs = 0
Dim $Ys = 0

Dim $Started = False
Dim $DoOnce = True

Dim $T

Dim $Co

ProcessSetPriority(@AutoItPID, 0) ; 3 Is High Priority  4 is Higher Priority (never use above 4)

Dim $pos[2]
Dim $Mx, $My
Dim $oMx, $oMy

Dim $LsX
Dim $LsY
Dim $RsX
Dim $RsY

$pos = MouseGetPos()
$Mx = $pos[0]
$My = $pos[1]

$Co = TimerInit() ; Checked Below, this will force exit of this After 8 seconds

While 1
	$T = TimerInit()
	$oMx = $Mx
	$oMy = $My
	$pos = MouseGetPos()
	$Mx = $pos[0]
	$My = $pos[1]

	$IcoPos = WinGetPos("FaderIcon")
	If IsArray($IcoPos) Then
		$OldW = $CurW
		$OldH = $CurH
		$CurX = $IcoPos[0]
		$CurY = $IcoPos[1]
		$CurW = $IcoPos[2]
		$CurH = $IcoPos[3]
		If $Px = -256 Then
			$Started = True
			$Px = $CurX + ($CurW / 2)
			$Py = $CurY + ($CurH / 2)
			$OldW = $CurW
			$OldH = $CurH
		EndIf
		$DoOnce = False
	Else
		If $DoOnce = True Then
			$DoOnce = False
		EndIf
	EndIf

	If $Started = True Then
		$Px = $Px + $Xs
		$Py = $Py + $Ys
		$Xs = $Xs - ($Xs / 20) ;Div is the slowing down speed (Less is quicker)
		$Ys = $Ys - ($Ys / 20)

		;Wrap desktop
		If $Px > @DesktopWidth Then
			$Px = 1
		EndIf

		If $Px < 0 Then
			$Px = @DesktopWidth - 1
		EndIf

		If $Py > @DesktopHeight Then
			$Py = 1
		EndIf

		If $Py < 0 Then
			$Py = @DesktopHeight - 1
		EndIf

		;Calculate Mouse position (I use the OldW and OldH to set the mouse boundries, makes it twice as big as the shape)
		If $Mx >= $Px - ($OldW) And $Mx <= $Px + ($OldW) Then
			If $My >= $Py - ($OldH) And $My <= $Py + ($OldH) Then
				$RsX = ($Mx - $Px)
				$RsY = ($My - $Py)

				If $RsX < 0 Then
					$LsX = $OldW + $RsX
					$LsX = -$LsX
				Else
					$LsX = $OldW - $RsX
				EndIf

				If $RsY < 0 Then
					$LsY = $OldH + $RsY
					$LsY = -$LsY
				Else
					$LsY = $OldH - $RsY
				EndIf

				$Xs = $Xs - ($LsX / 240)
				$Ys = $Ys - ($LsY / 240)
			EndIf
		EndIf

	EndIf

	;Place actual Window if exists
	If WinExists("FaderIcon") Then
		WinMove("FaderIcon", '', $Px - ($OldW / 2), $Py - ($OldH / 2));, $CurW, $CurH, 50)
		$Co = TimerInit()
	Else
		If TimerDiff($Co) >= 8000 Then Exit ;After 8 seconds of No Fader Window, this script will exit
	EndIf

	; Using a while loop instead of larger sleep so animation is smoother under high CPU load
	While TimerDiff($T) <= 18
		Sleep(1)
	WEnd

WEnd
