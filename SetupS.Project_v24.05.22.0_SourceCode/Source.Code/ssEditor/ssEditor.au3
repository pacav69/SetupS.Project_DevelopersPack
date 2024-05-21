#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=ssEditor.ico
#AutoIt3Wrapper_Outfile=ssEditor.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=SetupS Editor. Edit or build the files used to create ssApps, ppApps, or ppGames
#AutoIt3Wrapper_Res_Fileversion=24.05.22.0
#AutoIt3Wrapper_Res_LegalCopyright=©2024, Vergitek Solutions
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Release Date|2024-05-22
#AutoIt3Wrapper_Res_Field=ssTek Forum|http://sstek.vergitek.com
#AutoIt3Wrapper_Res_Field=ssTek Development|http://www.lastos.org
#AutoIt3Wrapper_Res_Field=LastOS Team|http://#WebLink3#
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=100
#AutoIt3Wrapper_UseX64=n
#endregion

#cs ##################################################################################
	
	SetupS Editor v24.05.22.0
	Copyright © 2024, Vergitek Solutions
	All rights reserved.
	
	This file is part of the SetupS SendTo Suite.
	
	The SetupS SendTo Suite is open-source software: you can redistribute it and/or
	modify it under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your option)
	any later version of the License.
	
	DISCLAIMER:
	The SetupS SendTo Suite is distributed in the hope that it will be useful, but is
	provided by Vergitek Solutions "AS IS", without warranty of any kind, express or
	implied, including but not limited to the warranties of MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE, TITLE and NON-INFRINGEMENT. In no event shall
	the authors or Vergitek Solutions be liable for any direct, indirect, incidental, special,
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
	App to Create Silent SetupS Apps (ssApp, ppApps, ppGames)
	
#ce ##################################################################################
#include <..\SetupS.Core.au3>

;------------------------------------------------------ Debug & Testing -----------------------------------------------------------
If Not @Compiled And Not GetParameter('Test') Then
	If $CLIparameters[0] = 0 Then
		$CLIparameters[0] += 1
		ReDim $CLIparameters[$CLIparameters[0] + 1]
		$CLIparameters[$CLIparameters[0]] = 'D:\ssTEK.Projects' ;test folder
		$CLIparameters[$CLIparameters[0]] &= '' ;specific test

;~ 		FileDelete($CLIparameters[$CLIparameters[0]] & '\ppApp.reg')
;~ 		FileDelete($CLIparameters[$CLIparameters[0]] & '\ppApp.app')
;~ 		FileCopy($CLIparameters[$CLIparameters[0]] & '\Copy of ppApp.app', $CLIparameters[$CLIparameters[0]] & '\ppApp.app')

;~ 		$CLIparameters[0] += 1
;~ 		ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 		$CLIparameters[$CLIparameters[0]] = '-autobuild' ;'-SaveAs=new' ;'-Help' ;'-autobuild'

;~ 		$CLIparameters[0] += 1
;~ 		ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 		$CLIparameters[$CLIparameters[0]] = '-ExpressInstaller=yes'

;~ 		$CLIparameters[0] += 1
;~ 		ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 		$CLIparameters[$CLIparameters[0]] = '-autoupdate=yes'

		Opt('TrayIconDebug', 1)
	EndIf
Else
	Opt('TrayAutoPause', 0) ;Turn off autopause
EndIf
Opt('TrayIconHide', 0) ;Show tray icon

;------------------------------------------------------ Declarations -------------------------------------------------------------
SetThisApp() ; Sets $ThisAppTitle, $ThisAppVersion, & $ThisAppFilename; plus DualArch
;~ Local $Test = ConvertFromVars('%SystemRoot%\Resources\Themes')
;~ MsgBox(262144, 'Debug line ~' & @ScriptLineNumber, 'Selection:' & @CRLF & '$test' & @CRLF & @CRLF & 'Return:' & @CRLF & $Test) ;### Debug MSGBOX
;~ Exit

#include <ButtonConstants.au3>
#include <GuiComboBox.au3>
#include <GuiEdit.au3>
#include <EditConstants.au3>
#include <GuiStatusBar.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Clipboard.au3>
#include <..\UDFs\7zRead.au3>
#include <..\UDFs\icons.au3>

Opt('GUIOnEventMode', 1)
Opt("WinTitleMatchMode", 1) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
$HelpFile = FindMe('ssTek.chm')
Local $hOrigCur = CursorWait(), $CLIparametersCount = $CLIparameters[0], $TemplatesFolder = @ScriptDir & '\templates'
Local $i, $j, $var, $PathIn, $CurrentWorkingDir, $Unlock = True, $ssEditorINI = CheckINI($ThisAppFilename & '.ini'), $HelpTopic_old
;~ If $MakeDefaultINI Then SetEditorDefaults($ThisAppFilename & '.ini')
Global $Edit_Installers_Data = '', $Edit_URLs_Data = '', $Combo_Category_Data = '', $Edit_Description_Data = '', $Edit_Cmd_Data = ''
Global $Edit_CatalogList_Data = '', $Edit_scKeep_Data = '', $Edit_FileAssoc_Data = '', $Edit_Reg_Data = '', $Combo_scName_hEdit
Global $Edit_RegisterDLL_Data = '', $Edit_InstallFonts_Data = '', $TempSourceDir = '', $uiSelected = 0
Global $Installer_Selected = 0, $Installers[$Installer_Selected + 1][6], $scSelected = 0, $FormMode = False ;False=read, True=edit
Global $TargetEditMode = '', $DoNotSave = False, $IODirReset = True, $ForcedOutputMode = False, $ForcedInputMode = False
Global $OutputPath = '', $OutputPathCurrent = '', $ArchiveEditMode = '', $GuiPreviewPic = '', $ReadOnlyEditMode = ''
Global $ExcludeList = @ScriptDir & '\7z.Exclude.lst', $SetupSList = @ScriptDir & '\7z.SetupS.lst'
Global $ncList = @ScriptDir & '\7z.nc.lst', $PPMdList = @ScriptDir & '\7z.PPMd.lst'
Global $NewForm = True, $ExitState = False
Const $ASSF_Key_ID = 0, $ASSF_Key_Extension = 1, $ASSF_Key_Type = 2, $ASSF_Key_Usage = 3, $ASSF_Key_Notes = 4
Global $ASSF_Type, $ASSF_Usage, $ASSF_Notes
Global $Categories = IniReadSection($CategoryINI, 'Category'), $Tags = IniReadSection($CategoryINI, 'Tags')
Global $ViewFileVersionInfo = IniRead_Binary($ssEditorINI, 'Options', 'View File Version Info', 'False')
$i = 'Build Archive Deployment Package'
If IniRead($ssEditorINI, 'Options', $i, '') = '' Then $i = 'Build Express Installer Package'
Global $MakeExpressInstaller = IniRead_Binary($ssEditorINI, 'Options', $i, 'False')
Global $WebfriendlyFilenames = IniRead_Binary($ssEditorINI, 'Options', 'Webfriendly Filenames', 'True')
Global $PreviewIconSize = Number(IniRead($ssEditorINI, 'Options', 'Icon View Size', '256'))
Global $ArchiveCompressionLevel = IniRead($ssEditorINI, 'Options', 'Archive Compression Level', 5)
Global $JpgSize = Number(IniRead($ssEditorINI, 'Options', 'JPG Size', '0'))
Global $JpgQuality = Number(IniRead($ssEditorINI, 'Options', 'JPG Quality', '100'))
Global $StartMenuTargetSearch = IniRead_Binary($ssEditorINI, 'Options', 'StartMenu Target Search', 'True')
Global $SaveFormat = StringLeft(IniRead($ssEditorINI, 'Options', 'Save Format', 3), 1)
Global $SaveFormatsTest = IniRead_Binary($ssEditorINI, 'Options', 'Save Formats Test', 'False')
Global $UseOutputDir = StringStripWS(IniRead($ssEditorINI, 'Options', 'Use Output Folder', ''), 3)
Global $ppCompress = IniRead_Binary($ssEditorINI, 'Options', 'ppCompress', 'True')
Global $PatchCompress = IniRead_Binary($ssEditorINI, 'Options', 'Patch Compress', 'True')
Global $CalcMD5 = IniRead_Binary($ssEditorINI, 'Options', 'Calculate MD5 checksum', 'True')
Global $CalcExtractedSize = IniRead_Binary($ssEditorINI, 'Options', 'Calculate Extracted Size', 'True')
Global $UseLZMA2 = IniRead_Binary($ssEditorINI, 'Options', 'Use LZMA2', 'False')
Global $UseRAR = IniRead_Binary($ssEditorINI, 'Options', 'Use RAR', 'False')
Global $LastBuildType = IniRead($ssEditorINI, 'Options', 'Last BuildType', '')
Global $ExitBuild = IniRead_Binary($ssEditorINI, 'Options', 'Exit After Building', 'True')
Global $AutoBuild = GetParameter('Build') Or GetParameter('AutoBuild')
Global $DeleteSource = IniRead_Binary($ssEditorINI, 'Options', 'Delete Source', 'False')
Global $7zProcessPriority = IniRead($ssEditorINI, 'Options', '7z Process Priority', 0) ;0 - Idle/Low, 1 - Below Normal, 2 - Normal, 3 - Above Normal, 4 - High, 5 - Realtime (Use with caution, may make the system unstable)
Global $AppPathChange = False, $DefaultMenuChange = False, $CatalogListChange = False, $Installer_Change = False, $scName_Change = False
Global $GetVersionFromTitle = IniRead_Binary($ssEditorINI, 'Options', 'Get Version from Title', 'False')
Global $ActivateSendtoAutobuild = IniRead_Binary($ssEditorINI, 'Options', 'Activate Sendto Autobuild', 'False')
Global $IntegrateRegCmd = IniRead_Binary($ssEditorINI, 'Options', 'IntegrateRegCmd', 'False')
Global $SortTags = IniRead($ssEditorINI, 'Options', 'Tag Sorting', 'Alphabetical')
Global $UseTemplates = IniRead_Binary($ssEditorINI, 'Options', 'Use Templates', 'Yes')
Global $UseFilenameTags = IniRead_Binary($ssEditorINI, 'Options', 'Use Filename Tags', 'Yes')
Global $PublisherTag = IniRead_Binary($ssEditorINI, 'Filename Tags', 'Publisher', 'No')
Global $TitleTag = IniRead_Binary($ssEditorINI, 'Filename Tags', 'Title', 'Yes')
Global $VersionTag = IniRead_Binary($ssEditorINI, 'Filename Tags', 'Version', 'Yes')
Global $LanguageTag = IniRead_Binary($ssEditorINI, 'Filename Tags', 'Language', 'No')
Global $OSTag = IniRead_Binary($ssEditorINI, 'Filename Tags', 'OS', 'Yes')
Global $ArchitectureTag = IniRead_Binary($ssEditorINI, 'Filename Tags', 'Architecture', 'Yes')
Global $CategoryTag = IniRead_Binary($ssEditorINI, 'Filename Tags', 'Category', 'No')
Global $AdditionalTag = IniRead_Binary($ssEditorINI, 'Filename Tags', 'Additional', 'No')
Global $LicenseTag = IniRead_Binary($ssEditorINI, 'Filename Tags', 'License', 'No')
Global $BuildTypeTag = IniRead_Binary($ssEditorINI, 'Filename Tags', 'BuildType', 'Yes')
Global $ReleaserTag = IniRead_Binary($ssEditorINI, 'Filename Tags', 'Releaser', 'No')
Global $RequiredRuntimesTag = IniRead_Binary($ssEditorINI, 'Filename Tags', 'RequiredRuntimes', 'No')
Global $UseInputDir = ($UseOutputDir = '')
Global $ssUpdateINI = CheckINI('ssUpdate.ini'), $ssConfigINI = CheckINI('ssConfig.ini')
Global $SKF_Installer, $SKF_Key, $SKF_Product, $SKF_Company, $SKF_Copyright, $SKF_Description
Global $SKF_PVersion, $SKF_FVersion, $SKF_File, $SKF_Size, $SKF_Comments
Global $USSF_Type, $USSF_Usage, $USSF_Notes
Global $SaveAs = GetParameter('Save', '=')
If $SaveAs = '' Then $SaveAs = GetParameter('SaveAs', '=')
If $SaveAs = '' Then $SaveAs = GetParameter('SaveTo', '=')
If $SaveAs <> '' Then
	Switch $SaveAs
		Case 'Legacy', 'Old', '0'
			$SaveFormat = '0 (Legacy)'
		Case 'Dual', 'Both', '1'
			$SaveFormat = '1 (Dual)'
		Case 'INI', 'New', '2'
			$SaveFormat = '2 (INI)'
		Case 'Update', 'UpdateOnly', '4'
			$SaveFormat = '4 (UpdateOnly)'
		Case 'Default', '3'
			$SaveFormat = '3 (Default)'
		Case Else ;Default
			$SaveFormat = '3 (Default)'
	EndSwitch
	$SaveAs = True
ElseIf GetParameter('Save') Or GetParameter('SaveAs') Or GetParameter('SaveTo') Then
	$SaveAs = True
EndIf
Switch GetParameter('SaveFormat', '=')
	Case 'Legacy', 'Old', '0'
		$SaveFormat = '0 (Legacy)'
	Case 'Dual', 'Both', '1'
		$SaveFormat = '1 (Dual)'
	Case 'INI', 'New', '2'
		$SaveFormat = '2 (INI)'
	Case 'Update', 'UpdateOnly', '4'
		$SaveFormat = '4 (UpdateOnly)'
	Case 'Default', '3'
		$SaveFormat = '3 (Default)'
EndSwitch

$TempDir = GenerateTempFolder()
If $TempPixDir = '' Then
	$TempPixDir = GenerateTempFolder()
	DirCreate($TempPixDir)
EndIf

Local $tdReg, $tdCmd, $tdApp
GetSetupSOptions($ssConfigINI)
GetAlternateDistribution($ssUpdateINI)
Local $UseGUI = ($CLIparametersCount = $AutoUpdateReturn)
If $AutoUpdate Then UpdateMe('update.ini', @ScriptDir & '\..', $UseGUI)

#cs ##################################################################################
	# Don't change anything between Koda Gui Section Regions!
	# It will be over-written by any changes made to the .kxf file.
	# Use Ctrl+U from the Form=[see below] to update and save both files.
#ce ##################################################################################
#region ### START Koda GUI section ### Form=ssEditor.kxf
Global $Form_ssEditor = GUICreate("SetupS Editor", 621, 454, -1, -1)
Global $MenuItem_File = GUICtrlCreateMenu("&File")
GUICtrlSetOnEvent(-1, "MenuItem_FileClick")
Global $MenuItem_New = GUICtrlCreateMenuItem("&New" & @TAB & "Ctrl+N", $MenuItem_File)
GUICtrlSetOnEvent(-1, "MenuItem_NewClick")
Global $MenuItem_Open = GUICtrlCreateMenuItem("&Open" & @TAB & "Ctrl+O", $MenuItem_File)
GUICtrlSetOnEvent(-1, "MenuItem_OpenClick")
Global $MenuItem_Save = GUICtrlCreateMenuItem("&Save" & @TAB & "Ctrl+S", $MenuItem_File)
GUICtrlSetOnEvent(-1, "MenuItem_SaveClick")
Global $MenuItem_SaveAs = GUICtrlCreateMenuItem("Save &As", $MenuItem_File)
GUICtrlSetOnEvent(-1, "MenuItem_SaveAsClick")
Global $Menu_Exit = GUICtrlCreateMenuItem("E&xit", $MenuItem_File)
GUICtrlSetOnEvent(-1, "Form_ssEditorClose")
Global $MenuItem_View = GUICtrlCreateMenu("&View")
GUICtrlSetOnEvent(-1, "MenuItem_ViewClick")
Global $MenuItem_Browse2Working = GUICtrlCreateMenuItem("Current working folder..." & @TAB & "F2", $MenuItem_View)
GUICtrlSetOnEvent(-1, "MenuItem_Browse2WorkingClick")
Global $MenuItem_Browse2OutputPath = GUICtrlCreateMenuItem("Current destination folder...", $MenuItem_View)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "MenuItem_Browse2OutputPathClick")
Global $MenuItem_ViewPatchFolder = GUICtrlCreateMenuItem("Patch Folder...", $MenuItem_View)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Button_PatchFolderClick")
Global $MenuItem_ViewFader = GUICtrlCreateMenuItem("Fader (.png)", $MenuItem_View)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Button_FaderClick")
Global $MenuItem_ViewIcon = GUICtrlCreateMenuItem("Icon (.ico)", $MenuItem_View)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Button_IconClick")
Global $MenuItem_ViewScrShot = GUICtrlCreateMenuItem("Screenshot (.jpg)", $MenuItem_View)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Button_ScrShotClick")
Global $MenuItem_ViewCMD = GUICtrlCreateMenuItem("Batch/Script file (.bat/.cmd)", $MenuItem_View)
GUICtrlSetOnEvent(-1, "Button_cmdClick")
Global $MenuItem_ViewReg = GUICtrlCreateMenuItem("Registry file (.reg)", $MenuItem_View)
GUICtrlSetOnEvent(-1, "Button_RegClick")
Global $MenuItem_ViewVars = GUICtrlCreateMenuItem("View %Variables% List" & @TAB & "F3", $MenuItem_View)
GUICtrlSetOnEvent(-1, "MenuItem_ViewVarsClick")
Global $MenuItem_ViewInNotepad = GUICtrlCreateMenuItem("Source in Notepad" & @TAB & "F4", $MenuItem_View)
GUICtrlSetOnEvent(-1, "MenuItem_ViewInNotepadClick")
Global $MenuItem_ViewMetaEditor = GUICtrlCreateMenuItem("Meta-data Editor", $MenuItem_View)
GUICtrlSetOnEvent(-1, "MenuItem_ViewMetaEditorClick")
Global $MenuItem_ViewFileVersion = GUICtrlCreateMenuItem("File Version info", $MenuItem_View)
GUICtrlSetOnEvent(-1, "MenuItem_ViewFileVersionClick")
Global $MenuItem_Options = GUICtrlCreateMenu("&Options")
GUICtrlSetOnEvent(-1, "MenuItem_OptionsClick")
Global $MenuItem_IntegrateRegCmd = GUICtrlCreateMenuItem("Integrate .Reg && .Cmd into .App", $MenuItem_Options)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "MenuItem_IntegrateRegCmdClick")
Global $MenuItem_Options_GetVersionFromTitle = GUICtrlCreateMenuItem("Get Version from Title", $MenuItem_Options)
GUICtrlSetOnEvent(-1, "MenuItem_Options_GetVersionFromTitleClick")
Global $MenuItem_Options_scTargetSearch = GUICtrlCreateMenuItem("StartMenu Target Searching", $MenuItem_Options)
GUICtrlSetOnEvent(-1, "MenuItem_Options_scTargetSearchClick")
Global $MenuItem_Options_ActivateSendtoAutobuild = GUICtrlCreateMenuItem("Activate Sendto Autobuild", $MenuItem_Options)
GUICtrlSetOnEvent(-1, "MenuItem_Options_ActivateSendtoAutobuildClick")
Global $MenuItem_Options_IconViewSize = GUICtrlCreateMenu("Icon Viewing Size...", $MenuItem_Options)
GUICtrlSetOnEvent(-1, "MenuItem_Options_IconViewSizeClick")
Global $MenuItem_16x16ico = GUICtrlCreateMenuItem("16x16", $MenuItem_Options_IconViewSize)
GUICtrlSetOnEvent(-1, "MenuItem_16x16icoClick")
Global $MenuItem_24x24ico = GUICtrlCreateMenuItem("24x24", $MenuItem_Options_IconViewSize)
GUICtrlSetOnEvent(-1, "MenuItem_24x24icoClick")
Global $MenuItem_32x32ico = GUICtrlCreateMenuItem("32x32", $MenuItem_Options_IconViewSize)
GUICtrlSetOnEvent(-1, "MenuItem_32x32icoClick")
Global $MenuItem_48x48ico = GUICtrlCreateMenuItem("48x48", $MenuItem_Options_IconViewSize)
GUICtrlSetOnEvent(-1, "MenuItem_48x48icoClick")
Global $MenuItem_96x96ico = GUICtrlCreateMenuItem("96x96", $MenuItem_Options_IconViewSize)
GUICtrlSetOnEvent(-1, "MenuItem_96x96icoClick")
Global $MenuItem_128x128ico = GUICtrlCreateMenuItem("128x128", $MenuItem_Options_IconViewSize)
GUICtrlSetOnEvent(-1, "MenuItem_128x128icoClick")
Global $MenuItem_256x256ico = GUICtrlCreateMenuItem("256x256", $MenuItem_Options_IconViewSize)
GUICtrlSetOnEvent(-1, "MenuItem_256x256icoClick")
Global $MenuItem_Options_ScreenCapture = GUICtrlCreateMenu("Screen Capture...", $MenuItem_Options)
GUICtrlSetOnEvent(-1, "MenuItem_Options_ScreenCaptureClick")
Global $MenuItem_Options_ScreenCapture_Size = GUICtrlCreateMenu("Size...", $MenuItem_Options_ScreenCapture)
GUICtrlSetOnEvent(-1, "MenuItem_Options_ScreenCapture_SizeClick")
Global $MenuItem_800x600jpg = GUICtrlCreateMenuItem("800x600", $MenuItem_Options_ScreenCapture_Size)
GUICtrlSetOnEvent(-1, "MenuItem_800x600jpgClick")
Global $MenuItem_640x480jpg = GUICtrlCreateMenuItem("640x480", $MenuItem_Options_ScreenCapture_Size)
GUICtrlSetOnEvent(-1, "MenuItem_640x480jpgClick")
Global $MenuItem_FullResJPG = GUICtrlCreateMenuItem("Original or Full Res", $MenuItem_Options_ScreenCapture_Size)
GUICtrlSetOnEvent(-1, "MenuItem_FullResJPGClick")
Global $MenuItem_Options_ScreenCapture_Quality = GUICtrlCreateMenu("Quality...", $MenuItem_Options_ScreenCapture)
GUICtrlSetOnEvent(-1, "MenuItem_Options_ScreenCapture_QualityClick")
Global $MenuItem_JPGQuality100 = GUICtrlCreateMenuItem("100% (default)", $MenuItem_Options_ScreenCapture_Quality)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "MenuItem_JPGQuality100Click")
Global $MenuItem_JPGQualityCustom = GUICtrlCreateMenuItem("Custom...", $MenuItem_Options_ScreenCapture_Quality)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "MenuItem_JPGQualityCustomClick")
Global $MenuItem_Options_OutputDir = GUICtrlCreateMenu("Destination Folder...", $MenuItem_Options)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "MenuItem_Options_OutputDirClick")
Global $MenuItem_UseInputDir = GUICtrlCreateMenuItem("Use the Source folder", $MenuItem_Options_OutputDir)
GUICtrlSetOnEvent(-1, "MenuItem_UseInputDirClick")
Global $MenuItem_UseOutputDir = GUICtrlCreateMenuItem("Use an Output folder", $MenuItem_Options_OutputDir)
GUICtrlSetOnEvent(-1, "MenuItem_UseOutputDirClick")
Global $MenuItem_Options_OutputDir_Choose = GUICtrlCreateMenuItem("Set the Output folder...", $MenuItem_Options_OutputDir)
GUICtrlSetOnEvent(-1, "MenuItem_Options_OutputDir_ChooseClick")
Global $MenuItem_Logging = GUICtrlCreateMenu("Logging...", $MenuItem_Options)
GUICtrlSetOnEvent(-1, "MenuItem_LoggingClick")
Global $MenuItem_LogReporting = GUICtrlCreateMenuItem("Reporting", $MenuItem_Logging)
GUICtrlSetOnEvent(-1, "MenuItem_LogReportingClick")
Global $MenuItem_LogDebugging = GUICtrlCreateMenuItem("Debugging", $MenuItem_Logging)
GUICtrlSetOnEvent(-1, "MenuItem_LogDebuggingClick")
Global $MenuItem_Options_SaveFormat = GUICtrlCreateMenu("Save format(s)...", $MenuItem_Options)
GUICtrlSetOnEvent(-1, "MenuItem_Options_SaveFormatClick")
Global $MenuItem_Options_SaveDefault = GUICtrlCreateMenuItem("Default (recommended)", $MenuItem_Options_SaveFormat)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "MenuItem_Options_SaveDefaultClick")
Global $MenuItem_Options_SaveLegacyFormat = GUICtrlCreateMenuItem("Legacy format", $MenuItem_Options_SaveFormat)
GUICtrlSetOnEvent(-1, "MenuItem_Options_SaveLegacyFormatClick")
Global $MenuItem_Options_SaveDualFormat = GUICtrlCreateMenuItem("Dual-format", $MenuItem_Options_SaveFormat)
GUICtrlSetOnEvent(-1, "MenuItem_Options_SaveDualFormatClick")
Global $MenuItem_Options_SaveINIFormat = GUICtrlCreateMenuItem("INI format", $MenuItem_Options_SaveFormat)
GUICtrlSetOnEvent(-1, "MenuItem_Options_SaveINIFormatClick")
Global $MenuItem_Options_SaveUpdateOnly = GUICtrlCreateMenuItem("Update(s) only", $MenuItem_Options_SaveFormat)
GUICtrlSetOnEvent(-1, "MenuItem_Options_SaveUpdateOnlyClick")
Global $MenuItem_OptionsTagSorting = GUICtrlCreateMenu("Tag Sorting...", $MenuItem_Options)
GUICtrlSetOnEvent(-1, "MenuItem_OptionsTagSortingClick")
Global $MenuItem_OptionsTagSortingAlpha = GUICtrlCreateMenuItem("Alphabetical", $MenuItem_OptionsTagSorting)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "MenuItem_OptionsTagSortingAlphaClick")
Global $MenuItem_OptionsTagSortingGroups = GUICtrlCreateMenuItem("Subject Groups", $MenuItem_OptionsTagSorting)
GUICtrlSetOnEvent(-1, "MenuItem_OptionsTagSortingGroupsClick")
Global $MenuItem_OptionsReset = GUICtrlCreateMenuItem("Restore Defaults", $MenuItem_Options)
GUICtrlSetOnEvent(-1, "MenuItem_OptionsResetClick")
Global $MenuItem_BuildOptions = GUICtrlCreateMenu("&Builds")
GUICtrlSetOnEvent(-1, "MenuItem_BuildOptionsClick")
Global $MenuItem_ExitBuild = GUICtrlCreateMenuItem("Exit After Build", $MenuItem_BuildOptions)
GUICtrlSetOnEvent(-1, "MenuItem_ExitBuildClick")
Global $MenuItem_CalcMD5 = GUICtrlCreateMenuItem("Calculate MD5 Checksums", $MenuItem_BuildOptions)
GUICtrlSetOnEvent(-1, "MenuItem_CalcMD5Click")
Global $MenuItem_CalcExtractedSize = GUICtrlCreateMenuItem("Calculate Extracted Size", $MenuItem_BuildOptions)
GUICtrlSetOnEvent(-1, "MenuItem_CalcExtractedSizeClick")
Global $MenuItem_DeleteSource = GUICtrlCreateMenuItem("Delete Source (folder/files)", $MenuItem_BuildOptions)
GUICtrlSetOnEvent(-1, "MenuItem_DeleteSourceClick")
Global $MenuItem_Options_ExpressInstaller = GUICtrlCreateMenuItem("Make Archive Deployment Package (.apz/.pgz)", $MenuItem_BuildOptions)
GUICtrlSetOnEvent(-1, "MenuItem_Options_ExpressInstallerClick")
Global $MenuItem_Options_WebfriendlyFilenames = GUICtrlCreateMenuItem("Webserver-friendly Filenames  (.apz/.pgz)", $MenuItem_BuildOptions)
GUICtrlSetOnEvent(-1, "MenuItem_Options_WebfriendlyFilenamesClick")
Global $MenuItem_BuildsUseFilenameTags = GUICtrlCreateMenuItem("Use Filename Tags", $MenuItem_BuildOptions)
GUICtrlSetOnEvent(-1, "MenuItem_BuildsUseFilenameTagsClick")
Global $MenuItem_BuildsFilenameTags = GUICtrlCreateMenu("Filename Tags...", $MenuItem_BuildOptions)
GUICtrlSetOnEvent(-1, "MenuItem_BuildsFilenameTagsClick")
Global $MenuItem_FilenameTagPublisher = GUICtrlCreateMenuItem("Publisher", $MenuItem_BuildsFilenameTags)
GUICtrlSetOnEvent(-1, "MenuItem_FilenameTagPublisherClick")
Global $MenuItem_FilenameTagTitle = GUICtrlCreateMenuItem("Title", $MenuItem_BuildsFilenameTags)
GUICtrlSetOnEvent(-1, "MenuItem_FilenameTagTitleClick")
Global $MenuItem_FilenameTagVersion = GUICtrlCreateMenuItem("Version", $MenuItem_BuildsFilenameTags)
GUICtrlSetOnEvent(-1, "MenuItem_FilenameTagVersionClick")
Global $MenuItem_FilenameTagLanguage = GUICtrlCreateMenuItem("Language", $MenuItem_BuildsFilenameTags)
GUICtrlSetOnEvent(-1, "MenuItem_FilenameTagLanguageClick")
Global $MenuItem_FilenameTagOS = GUICtrlCreateMenuItem("OS", $MenuItem_BuildsFilenameTags)
GUICtrlSetOnEvent(-1, "MenuItem_FilenameTagOSClick")
Global $MenuItem_FilenameTagArchitecture = GUICtrlCreateMenuItem("Architecture", $MenuItem_BuildsFilenameTags)
GUICtrlSetOnEvent(-1, "MenuItem_FilenameTagArchitectureClick")
Global $MenuItem_FilenameTagCategory = GUICtrlCreateMenuItem("Category", $MenuItem_BuildsFilenameTags)
GUICtrlSetOnEvent(-1, "MenuItem_FilenameTagCategoryClick")
Global $MenuItem_FilenameTagAdditional = GUICtrlCreateMenuItem("Additional", $MenuItem_BuildsFilenameTags)
GUICtrlSetOnEvent(-1, "MenuItem_FilenameTagAdditionalClick")
Global $MenuItem_FilenameTagLicense = GUICtrlCreateMenuItem("License", $MenuItem_BuildsFilenameTags)
GUICtrlSetOnEvent(-1, "MenuItem_FilenameTagLicenseClick")
Global $MenuItem_FilenameTagBuildType = GUICtrlCreateMenuItem("Build Type", $MenuItem_BuildsFilenameTags)
GUICtrlSetOnEvent(-1, "MenuItem_FilenameTagBuildTypeClick")
Global $MenuItem_FilenameTagReleaser = GUICtrlCreateMenuItem("Releaser", $MenuItem_BuildsFilenameTags)
GUICtrlSetOnEvent(-1, "MenuItem_FilenameTagReleaserClick")
Global $MenuItem_FilenameTagRequiredRuntimes = GUICtrlCreateMenuItem("Required Runtimes", $MenuItem_BuildsFilenameTags)
GUICtrlSetOnEvent(-1, "MenuItem_FilenameTagRequiredRuntimesClick")
Global $MenuItem_CompressionOptions = GUICtrlCreateMenu("&Compression...", $MenuItem_BuildOptions)
GUICtrlSetOnEvent(-1, "MenuItem_CompressionOptionsClick")
Global $MenuItem_UseLZMA2 = GUICtrlCreateMenuItem("Use LZMA2 Method", $MenuItem_CompressionOptions)
GUICtrlSetOnEvent(-1, "MenuItem_UseLZMA2Click")
Global $MenuItem_ppCompress = GUICtrlCreateMenuItem("Make ppApp/ppGame Archive", $MenuItem_CompressionOptions)
GUICtrlSetOnEvent(-1, "MenuItem_ppCompressClick")
Global $MenuItem_PatchCompress = GUICtrlCreateMenuItem("Make Patch-folder Archive", $MenuItem_CompressionOptions)
GUICtrlSetOnEvent(-1, "MenuItem_PatchCompressClick")
Global $MenuItem_7zProcessPriority = GUICtrlCreateMenu("Process Priority...", $MenuItem_CompressionOptions)
GUICtrlSetOnEvent(-1, "MenuItem_7zProcessPriorityClick")
Global $MenuItem_7zProcessPriority5 = GUICtrlCreateMenuItem("Realtime (5)", $MenuItem_7zProcessPriority)
GUICtrlSetOnEvent(-1, "MenuItem_7zProcessPriority5Click")
Global $MenuItem_7zProcessPriority4 = GUICtrlCreateMenuItem("High (4)", $MenuItem_7zProcessPriority)
GUICtrlSetOnEvent(-1, "MenuItem_7zProcessPriority4Click")
Global $MenuItem_7zProcessPriority3 = GUICtrlCreateMenuItem("Above Normal (3)", $MenuItem_7zProcessPriority)
GUICtrlSetOnEvent(-1, "MenuItem_7zProcessPriority3Click")
Global $MenuItem_7zProcessPriority2 = GUICtrlCreateMenuItem("Normal (2)", $MenuItem_7zProcessPriority)
GUICtrlSetOnEvent(-1, "MenuItem_7zProcessPriority2Click")
Global $MenuItem_7zProcessPriority1 = GUICtrlCreateMenuItem("Below Normal (1)", $MenuItem_7zProcessPriority)
GUICtrlSetOnEvent(-1, "MenuItem_7zProcessPriority1Click")
Global $MenuItem_7zProcessPriority0 = GUICtrlCreateMenuItem("Idle/Low (0)", $MenuItem_7zProcessPriority)
GUICtrlSetOnEvent(-1, "MenuItem_7zProcessPriority0Click")
Global $MenuItem_Options_CompressionLevel = GUICtrlCreateMenu("Level...", $MenuItem_CompressionOptions)
GUICtrlSetOnEvent(-1, "MenuItem_Options_CompressionLevelClick")
Global $MenuItem_Options_CompressionLevel_Ultra = GUICtrlCreateMenuItem("Ultra (9)", $MenuItem_Options_CompressionLevel)
GUICtrlSetOnEvent(-1, "MenuItem_Options_CompressionLevel_UltraClick")
Global $MenuItem_Options_CompressionLevel_Max = GUICtrlCreateMenuItem("Maximum (7)", $MenuItem_Options_CompressionLevel)
GUICtrlSetOnEvent(-1, "MenuItem_Options_CompressionLevel_MaxClick")
Global $MenuItem_Options_CompressionLevel_Default = GUICtrlCreateMenuItem("Normal (5)", $MenuItem_Options_CompressionLevel)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "MenuItem_Options_CompressionLevel_DefaultClick")
Global $MenuItem_Options_CompressionLevel_Fast = GUICtrlCreateMenuItem("Fast (3)", $MenuItem_Options_CompressionLevel)
GUICtrlSetOnEvent(-1, "MenuItem_Options_CompressionLevel_FastClick")
Global $MenuItem_Options_CompressionLevel_Fastest = GUICtrlCreateMenuItem("Fastest (1)", $MenuItem_Options_CompressionLevel)
GUICtrlSetOnEvent(-1, "MenuItem_Options_CompressionLevel_FastestClick")
Global $MenuItem_Options_CompressionLevel_None = GUICtrlCreateMenuItem("None/Store (0)", $MenuItem_Options_CompressionLevel)
GUICtrlSetOnEvent(-1, "MenuItem_Options_CompressionLevel_NoneClick")
Global $MenuItem_UseRAR = GUICtrlCreateMenuItem("Use RAR", $MenuItem_BuildOptions)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "MenuItem_UseRARClick")
Global $MenuItem_Tools = GUICtrlCreateMenu("&Tools")
GUICtrlSetOnEvent(-1, "MenuItem_ToolsClick")
Global $MenuItem_ScreenshotTools = GUICtrlCreateMenu("Screenshot...", $MenuItem_Tools)
GUICtrlSetOnEvent(-1, "MenuItem_ScreenshotToolsClick")
Global $MenuItem_ScreenCapture = GUICtrlCreateMenuItem("Screen Capture" & @TAB & "F11", $MenuItem_ScreenshotTools)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "MenuItem_ScreenCaptureClick")
Global $MenuItem_GrabClipBoardPic = GUICtrlCreateMenuItem("Grab Clipboard Picture" & @TAB & "F12", $MenuItem_ScreenshotTools)
GUICtrlSetOnEvent(-1, "MenuItem_GrabClipBoardPicClick")
Global $MenuItem_ExtractICO = GUICtrlCreateMenuItem("Extract Icon(s)..." & @TAB & "F10", $MenuItem_Tools)
GUICtrlSetOnEvent(-1, "MenuItem_ExtractICOClick")
Global $MenuItem_SetupSTest = GUICtrlCreateMenuItem("SetupS Test" & @TAB & "F8", $MenuItem_Tools)
GUICtrlSetOnEvent(-1, "MenuItem_SetupSTestClick")
Global $MenuItem_Build = GUICtrlCreateMenuItem("Build" & @TAB & "F5", $MenuItem_Tools)
GUICtrlSetOnEvent(-1, "MenuItem_BuildClick")
Global $MenuItem_NewFileWizard = GUICtrlCreateMenuItem("New file Wizard...", $MenuItem_Tools)
GUICtrlSetOnEvent(-1, "MenuItem_NewFileWizardClick")
Global $MenuItem_Au3Info = GUICtrlCreateMenuItem("AutoIt Window Information" & @TAB & "Ctrl+I", $MenuItem_Tools)
GUICtrlSetOnEvent(-1, "MenuItem_Au3InfoClick")
Global $MenuItem_Taskmgr = GUICtrlCreateMenuItem("Windows Task Manager" & @TAB & "Ctrl+T", $MenuItem_Tools)
GUICtrlSetOnEvent(-1, "MenuItem_TaskmgrClick")
Global $MenuItem_Help = GUICtrlCreateMenu("&Help")
GUICtrlSetOnEvent(-1, "MenuItem_HelpClick")
Global $MenuItem_Contents = GUICtrlCreateMenuItem("Contents" & @TAB & "F1", $MenuItem_Help)
GUICtrlSetOnEvent(-1, "MenuItem_ContentsClick")
Global $MenuItem_About = GUICtrlCreateMenuItem("About", $MenuItem_Help)
GUICtrlSetOnEvent(-1, "MenuItem_AboutClick")
Global $MenuItem_UpdateCheck = GUICtrlCreateMenuItem("Check for &update...", $MenuItem_Help)
GUICtrlSetOnEvent(-1, "MenuItem_UpdateCheckClick")
GUISetOnEvent($GUI_EVENT_CLOSE, "Form_ssEditorClose")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "Form_ssEditorMinimize")
GUISetOnEvent($GUI_EVENT_MAXIMIZE, "Form_ssEditorMaximize")
GUISetOnEvent($GUI_EVENT_RESTORE, "Form_ssEditorRestore")
Global $PageControl_ssEditor = GUICtrlCreateTab(0, 2, 619, 362)
GUICtrlSetOnEvent(-1, "PageControl_ssEditorChange")
Global $TabSheet_General = GUICtrlCreateTabItem("General")
Global $Group_Details = GUICtrlCreateGroup("Application/Game Details", 4, 27, 348, 115)
GUICtrlSetColor(-1, 0x0000FF)
Global $Input_Title = GUICtrlCreateInput("", 51, 44, 295, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_TitleChange")
Global $Input_Version = GUICtrlCreateInput("", 51, 66, 230, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_VersionChange")
Global $Edit_URLs = GUICtrlCreateEdit("", 51, 88, 295, 51, $GUI_SS_DEFAULT_EDIT)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetOnEvent(-1, "Edit_URLsChange")
Global $Checkbox_Game = GUICtrlCreateCheckbox("Game", 293, 68, 48, 18)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Select this to see only the game categories")
GUICtrlSetOnEvent(-1, "Checkbox_GameClick")
Global $Label_Title = GUICtrlCreateLabel("Title", 8, 47, 40, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "shown in the ssWPI as the name of the option")
GUICtrlSetOnEvent(-1, "Label_TitleClick")
Global $Label_URL = GUICtrlCreateLabel("URL(s)", 8, 91, 40, 45, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Helps to find updates or information if you supply a URL to the app/game. Click on this to launch the link(s)")
GUICtrlSetOnEvent(-1, "Label_URLClick")
Global $Label_Version = GUICtrlCreateLabel("Version", 8, 69, 40, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "shown in the ssWPI as the name of the option")
GUICtrlSetOnEvent(-1, "Label_VersionClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "This Section is for the information ssWPI needs to list them and categorise them")
Global $Group_BuildType = GUICtrlCreateGroup("Build Type", 350, 27, 74, 92)
GUICtrlSetColor(-1, 0x0000FF)
Global $Radio_Build_ssApp = GUICtrlCreateRadio("ssApp", 355, 42, 48, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "(s)ilent (s)etup (App)lication -- a standard Installer that will be made silent, these are not kept on the system after a fresh OS install")
GUICtrlSetOnEvent(-1, "Radio_Build_ssAppClick")
Global $Radio_Build_ppApp = GUICtrlCreateRadio("ppApp", 355, 60, 50, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "(p)ermanent & (p)ortable (App)lication -- these are installed to the OS on a seperate partition/HDD and can be reused with no need to install them again")
GUICtrlSetOnEvent(-1, "Radio_Build_ppAppClick")
Global $Radio_Build_ppGame = GUICtrlCreateRadio("ppGame", 355, 78, 63, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "(p)ermanent & (p)ortable (Game) -- similar to ppApps but for games")
GUICtrlSetOnEvent(-1, "Radio_Build_ppGameClick")
Global $Radio_Build_ppTweak = GUICtrlCreateRadio("ppTweak", 355, 96, 63, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "(p)ermanent & (p)ortable (Tweak) -- this is a special kind of ppApp. No application to install")
GUICtrlSetOnEvent(-1, "Radio_Build_ppTweakClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "Pick your type of application/game to create")
Global $Group_Architecture = GUICtrlCreateGroup("Architecture", 422, 27, 82, 92)
GUICtrlSetColor(-1, 0x0000FF)
Global $Radio_Arch_Any = GUICtrlCreateRadio("Any", 427, 42, 41, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "list this application on any 32/64-bit system")
GUICtrlSetOnEvent(-1, "Radio_Arch_AnyClick")
Global $Radio_Arch_x86 = GUICtrlCreateRadio("x86 (32-bit)", 427, 60, 70, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "List this application only for 32-bit (x86) architectures")
GUICtrlSetOnEvent(-1, "Radio_Arch_x86Click")
Global $Radio_Arch_x64 = GUICtrlCreateRadio("x64 (64-bit)", 427, 78, 71, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "List this application only for 64-bit (x64) architectures")
GUICtrlSetOnEvent(-1, "Radio_Arch_x64Click")
Global $Radio_Arch_DualArch = GUICtrlCreateRadio("DualArch", 427, 96, 71, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Application installs structures for both x86 and x64.")
GUICtrlSetOnEvent(-1, "Radio_Arch_DualArchClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_ssWPI_Options = GUICtrlCreateGroup("ssWPI Options:", 515, 195, 100, 162)
GUICtrlSetColor(-1, 0x0000FF)
Global $Checkbox_AlwaysShow = GUICtrlCreateCheckbox("Always Show", 520, 210, 83, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "This will make the ssWPI show this item - even if on the wrong OS, already installed or other situations that will normally hide this item from the ssWPI")
GUICtrlSetOnEvent(-1, "Checkbox_AlwaysShowClick")
Global $Checkbox_AtSetupOnly = GUICtrlCreateCheckbox("At setup only", 520, 250, 81, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "The item above may only be of use during the initial setup of the OS - this item will only be shown if ssWPI is called with the -NewSetup switch")
GUICtrlSetOnEvent(-1, "Checkbox_AtSetupOnlyClick")
Global $Checkbox_InstallT13 = GUICtrlCreateCheckbox("Install T13", 520, 270, 70, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "XP allows you to install items at T13 part of setup - this will enable you to install and addon/app/game during setup so it is ready to go when the desktop first loads (no reboot required first)")
GUICtrlSetOnEvent(-1, "Checkbox_InstallT13Click")
Global $Checkbox_RunAsx64 = GUICtrlCreateCheckbox("Run as x64", 520, 290, 76, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "x64 redirect folder locations and reg entries, enabling this will treat it as a x64 OS and allow SetupS to access x64 locations")
GUICtrlSetOnEvent(-1, "Checkbox_RunAsx64Click")
Global $Checkbox_InstallInstant = GUICtrlCreateCheckbox("Install Instant", 520, 310, 83, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetOnEvent(-1, "Checkbox_InstallInstantClick")
Global $Input_PriorityOrder = GUICtrlCreateInput("5", 585, 331, 24, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_PriorityOrderChange")
GUICtrlSetTip(-1, "This is the Order to show and install items from ssWPI")
Global $Label_PriorityOrder = GUICtrlCreateLabel("Priority Order", 520, 334, 63, 14, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "This is the order to show and install items from ssWPI")
GUICtrlSetOnEvent(-1, "Label_PriorityOrderClick")
Global $Checkbox_AlwaysHide = GUICtrlCreateCheckbox("Always Hide", 520, 230, 83, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "This will make the ssWPI hide this item - even if on the wrong OS, already installed or other situations that will normally show this item from the ssWPI")
GUICtrlSetOnEvent(-1, "Checkbox_AlwaysHideClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "Extra ssWPI options")
Global $Group_EditDescription = GUICtrlCreateGroup("Description:", 4, 195, 513, 162)
GUICtrlSetColor(-1, 0x0000FF)
Global $Edit_Description = GUICtrlCreateEdit("", 7, 212, 507, 141, BitOR($ES_WANTRETURN, $WS_VSCROLL))
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetOnEvent(-1, "Edit_DescriptionChange")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Button_MetaEditorPopout = GUICtrlCreateButton("Meta-data Editor", 362, 124, 90, 20, $BS_NOTIFY)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Extra application or game information")
GUICtrlSetOnEvent(-1, "MenuItem_ViewMetaEditorClick")
Global $Group_Categories = GUICtrlCreateGroup("Categories (separate each with | )", 4, 144, 611, 48)
GUICtrlSetColor(-1, 0x0000FF)
Global $Input_Categories = GUICtrlCreateInput("", 341, 161, 260, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_CategoriesChange")
GUICtrlSetTip(-1, "Separate each with a vertical bar '' | ''")
Global $Combo_Category = GUICtrlCreateCombo("", 51, 161, 209, 100, $GUI_SS_DEFAULT_COMBO)
GUICtrlSetOnEvent(-1, "Combo_CategoryChange")
Global $Button_AddCategory = GUICtrlCreateButton("Add -->", 275, 162, 54, 19, $BS_NOTIFY)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Button_AddCategoryClick")
Global $Label_Category = GUICtrlCreateLabel("Select:", 8, 164, 40, 18, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "helps group ssWPI options so you can find them quicker")
GUICtrlSetOnEvent(-1, "Label_CategoryClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_OS2 = GUICtrlCreateGroup("For OS", 502, 27, 113, 92)
GUICtrlSetColor(-1, 0x0000FF)
Global $Checkbox_OS_NT5 = GUICtrlCreateCheckbox("NT5.x (XP/2K)", 507, 42, 93, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "NT5: Windows 2000, XP, 2003")
GUICtrlSetOnEvent(-1, "Checkbox_OS_NT5Click")
Global $Checkbox_OS_NT6 = GUICtrlCreateCheckbox("NT6.x (Vista/7)", 507, 60, 93, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "NT6 (pre-Metro/Modern): Windows Vista, 7, 2008, 2011")
GUICtrlSetOnEvent(-1, "Checkbox_OS_NT6Click")
Global $Checkbox_OS_Metro = GUICtrlCreateCheckbox("Metro (pre-Win10)", 507, 78, 104, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Metro/Modern (pre-Win10): Windows 8, 8.1, 2012")
GUICtrlSetOnEvent(-1, "Checkbox_OS_MetroClick")
Global $Checkbox_OS_Win10 = GUICtrlCreateCheckbox("NT10 (10/2k16)", 507, 96, 104, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "NT10: Windows 10, 2016, etc.")
GUICtrlSetOnEvent(-1, "Checkbox_OS_Win10Click")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "Some applications are only suitable for some OS's, Setting this will hide them from the ssWPI installer if it is ran on a noncompatible one")
Global $Label_FileVersion = GUICtrlCreateLabel("File version: v88.88.88.88.88", 472, 128, 140, 17, 0)
GUICtrlSetColor(-1, 0x800000)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetTip(-1, "SetupS file (.app/.ppg) version")
GUICtrlSetOnEvent(-1, "Label_FileVersionClick")
Global $TabSheet_Install = GUICtrlCreateTabItem("Assembly")
GUICtrlSetState(-1, $GUI_SHOW)
Global $Group_Installers = GUICtrlCreateGroup("Assembly Details:", 4, 61, 331, 192)
GUICtrlSetColor(-1, 0x0000FF)
Global $Combo_Installer = GUICtrlCreateInput("", 53, 80, 252, 21)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetOnEvent(-1, "Combo_InstallerChange")
Global $Button_Installer = GUICtrlCreateButton("···", 309, 81, 19, 19, $BS_NOTIFY)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetTip(-1, "Browse for the Install/Setup program(s) to use for this app")
GUICtrlSetOnEvent(-1, "Button_InstallerClick")
Global $Input_Switches = GUICtrlCreateInput("", 53, 104, 276, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_SwitchesChange")
Global $Button_Add_Installer = GUICtrlCreateButton("+", 32, 152, 19, 19, $BS_NOTIFY)
GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")
GUICtrlSetTip(-1, "Add the Installer with Switches to the assembly")
GUICtrlSetOnEvent(-1, "Button_Add_InstallerClick")
Global $Edit_Installers = GUICtrlCreateEdit("", 7, 172, 323, 76, $GUI_SS_DEFAULT_EDIT)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetOnEvent(-1, "Edit_InstallersChange")
Global $Label_Installer = GUICtrlCreateLabel("Installer:", 8, 83, 43, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "The installer or setup programs for this app. Any silent switches detected will automatically added below.")
GUICtrlSetOnEvent(-1, "Label_InstallerClick")
Global $Label_Switches = GUICtrlCreateLabel("Usage:", 8, 107, 38, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Silent switch(s) for the above installer")
GUICtrlSetOnEvent(-1, "Label_SwitchesClick")
Global $Label_InstallList = GUICtrlCreateLabel("Process the assembly below in the order shown:", 60, 153, 230, 17, 0)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetOnEvent(-1, "Label_InstallListClick")
Global $Label_SwitchNotes = GUICtrlCreateLabel("Notes:", 8, 131, 35, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Silent switch(s) for the above installer")
GUICtrlSetOnEvent(-1, "Label_SwitchNotesClick")
Global $Input_SwitchNotes = GUICtrlCreateInput("", 53, 128, 276, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_SwitchNotesChange")
Global $Checkbox_AssemblyNoWait = GUICtrlCreateCheckbox("Enable No-Wait", 230, 62, 98, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetOnEvent(-1, "Checkbox_AssemblyNoWaitClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_Uninstall = GUICtrlCreateGroup("Uninstall Data:", 340, 33, 250, 220)
GUICtrlSetColor(-1, 0x0000FF)
Global $Label_uiKey = GUICtrlCreateLabel("Key", 348, 90, 68, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "Name the shortcut here. The display name is the actual name shown in the startmenu and on the desktop etc.")
GUICtrlSetOnEvent(-1, "Label_uiKeyClick")
Global $Combo_uiKey = GUICtrlCreateCombo("", 418, 87, 167, 100, $GUI_SS_DEFAULT_COMBO)
GUICtrlSetOnEvent(-1, "Combo_uiKeyChange")
Global $Label_uiDisplayName = GUICtrlCreateLabel("DisplayName", 348, 112, 68, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "The physical exe location for the shortcut to execute")
GUICtrlSetOnEvent(-1, "Label_uiDisplayNameClick")
Global $Input_uiDisplayName = GUICtrlCreateInput("", 418, 109, 167, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_uiDisplayNameChange")
Global $Label_uiInstallLocation = GUICtrlCreateLabel("InstallLocation", 348, 134, 68, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "The folder to start the target from")
GUICtrlSetOnEvent(-1, "Label_uiInstallLocationClick")
Global $Input_uiInstallLocation = GUICtrlCreateInput("", 418, 131, 167, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_uiInstallLocationChange")
Global $Label_uiCount = GUICtrlCreateLabel("0", 421, 70, 161, 15, 0)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "This is the count of Shortcuts to create or Keep")
GUICtrlSetOnEvent(-1, "Label_uiCountClick")
Global $Label_uiDisplayIcon = GUICtrlCreateLabel("DisplayIcon", 348, 156, 68, 14, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Select the file to get the icon from (if different from the exe)")
GUICtrlSetOnEvent(-1, "Label_uiDisplayIconClick")
Global $Input_uiDisplayIcon = GUICtrlCreateInput("", 418, 153, 167, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_uiDisplayIconChange")
Global $Label_uiUninstallString = GUICtrlCreateLabel("UninstallString", 348, 179, 68, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Any parameters or switches required by this shortcut")
GUICtrlSetOnEvent(-1, "Label_uiUninstallStringClick")
Global $Input_uiUninstallString = GUICtrlCreateInput("", 418, 175, 167, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_uiUninstallStringChange")
Global $Label_uiSwitches = GUICtrlCreateLabel("Switches", 348, 201, 68, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Any parameters or switches required by this shortcut")
GUICtrlSetOnEvent(-1, "Label_uiSwitchesClick")
Global $Input_uiSwitches = GUICtrlCreateInput("", 418, 197, 167, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_uiSwitchesChange")
Global $Input_uiScript = GUICtrlCreateInput("", 418, 219, 167, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_uiScriptChange")
Global $Label_uiScript = GUICtrlCreateLabel("Script", 348, 223, 68, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Any parameters or switches required by this shortcut")
GUICtrlSetOnEvent(-1, "Label_uiScriptClick")
Global $Checkbox_App_ssUninstall = GUICtrlCreateCheckbox("Disable ssUninstall for this app", 348, 50, 167, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Never use ssUninstall with this app")
GUICtrlSetOnEvent(-1, "Checkbox_App_ssUninstallClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetState(-1, $GUI_DISABLE)
Global $Label_AppPath = GUICtrlCreateLabel("Install-to Path:", 6, 36, 71, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "Pick the location the app will be installed to, This is important to be set as it is where the patched files are copied to and also where the ssWPI checks to see if the app is already installed on each system")
GUICtrlSetOnEvent(-1, "Label_AppPathClick")
Global $Input_AppPath = GUICtrlCreateInput("", 80, 33, 220, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_AppPathChange")
Global $Button_AppPath = GUICtrlCreateButton("···", 304, 34, 19, 19, $BS_NOTIFY)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetOnEvent(-1, "Button_AppPathClick")
Global $Group_Directives = GUICtrlCreateGroup("Directives (click to add):", 4, 257, 331, 87)
GUICtrlSetColor(-1, 0x0000FF)
Global $Label_Directive_Cmd = GUICtrlCreateLabel("#CMD#", 194, 323, 39, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Process this line as a command-line using the DOS console (aka, the Command-line Interpreter).")
GUICtrlSetOnEvent(-1, "Label_Directive_CmdClick")
Global $Label_Directive_x86 = GUICtrlCreateLabel("#Is_x86#", 9, 272, 60, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Process this line for 32-bit OS-Architectures (x86) only.")
GUICtrlSetOnEvent(-1, "Label_Directive_x86Click")
Global $Label_Directive_x64 = GUICtrlCreateLabel("#Is_x64#", 9, 289, 60, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Process this line for 64-bit OS-Architectures (x64) only.")
GUICtrlSetOnEvent(-1, "Label_Directive_x64Click")
Global $Label_Directive_Script = GUICtrlCreateLabel("#RunScript#", 77, 272, 81, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Run the <Script> section and skip it during Post-processing. Uses the Source folder as the 'Start In' or working folder.")
GUICtrlSetOnEvent(-1, "Label_Directive_ScriptClick")
Global $Label_Directive_Registry = GUICtrlCreateLabel("#ApplyRegistry#", 77, 289, 109, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Apply the <Registry> section and skip it during Post-processing.")
GUICtrlSetOnEvent(-1, "Label_Directive_RegistryClick")
Global $Label_Directive_RegisterDLL = GUICtrlCreateLabel("#RegisterDLL#", 77, 306, 95, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Process the <RegisterDLL> section. Skips it during Post-processing.")
GUICtrlSetOnEvent(-1, "Label_Directive_RegisterDLLClick")
Global $Label_Directive_Fonts = GUICtrlCreateLabel("#InstallFonts#", 194, 272, 102, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Process the <InstallFonts> section. Skips it during Post-processing.")
GUICtrlSetOnEvent(-1, "Label_Directive_FontsClick")
Global $Label_Directive_ShortcutS = GUICtrlCreateLabel("#ShortcutS#", 194, 289, 81, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Process the <ShortcutS> section... all shortcut/startmenu related tasks (w/ StartMenu Folder icons) AND File Association(s). Skips it during Post-processing.")
GUICtrlSetOnEvent(-1, "Label_Directive_ShortcutSClick")
Global $Label_Directive_AppPathIcon = GUICtrlCreateLabel("#AppPathFolderIcon#", 194, 306, 137, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Install-path Folder Icon")
GUICtrlSetOnEvent(-1, "Label_Directive_AppPathIconClick")
Global $Label_Directive_NT6 = GUICtrlCreateLabel("#Is_NT6#", 9, 323, 60, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Process this line for NT6.x OS's only (Windows Vista/7/2008)")
GUICtrlSetOnEvent(-1, "Label_Directive_NT6Click")
Global $Label_Directive_NT5 = GUICtrlCreateLabel("#Is_NT5#", 9, 306, 60, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Process this line for NT5.x OS's only (Windows 2000/XP/2003)")
GUICtrlSetOnEvent(-1, "Label_Directive_NT5Click")
Global $Label_Directive_ApplyPatch = GUICtrlCreateLabel("#ApplyPatch#", 77, 323, 88, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Apply Patch archive/folder")
GUICtrlSetOnEvent(-1, "Label_Directive_ApplyPatchClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_Components = GUICtrlCreateGroup("Components (click to add):", 340, 257, 250, 87)
GUICtrlSetColor(-1, 0x0000FF)
Global $Label_Component_AddonInstaller = GUICtrlCreateLabel("%AddonInstaller%", 345, 272, 116, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "%AddonInstaller% [path\filename] : Process Addons such as ones from Kel or RyanVM.")
GUICtrlSetOnEvent(-1, "Label_Component_AddonInstallerClick")
Global $Label_Component_ProcessKill = GUICtrlCreateLabel("%ProcessKill%", 345, 289, 95, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "%ProcessKill% [filename] : To force a process/task to close from a given filename.")
GUICtrlSetOnEvent(-1, "Label_Component_ProcessKillClick")
Global $Label_Component_WaitForIt = GUICtrlCreateLabel("%WaitForIt%", 345, 306, 81, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "%WaitForIt% [path\filename] : Force SetupS to pause until a specific file is created or copied to that location. Shortcut files (.lnk) are recommended because they are often created last by installers.")
GUICtrlSetOnEvent(-1, "Label_Component_WaitForItClick")
Global $Label_Component_AddToHosts = GUICtrlCreateLabel("%AddToHosts%", 481, 272, 88, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "%AddToHosts% {IP address} {host name} : Sets mappings of IP addresses to host names.")
GUICtrlSetOnEvent(-1, "Label_Component_AddToHostsClick")
Global $Label_Component_Extract = GUICtrlCreateLabel("%Extract%", 481, 289, 67, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "%Extract% {archive} -o{destination path} : Extract an archive to a specified destination path. Exactly equivalent to: '7z x -y -aoa {archive} -o{destination path}'")
GUICtrlSetOnEvent(-1, "Label_Component_ExtractClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $TabSheet_Shortcuts = GUICtrlCreateTabItem("Shortcuts")
Global $Group_scLocations = GUICtrlCreateGroup("StartMenu Location(s)", 4, 27, 330, 159)
GUICtrlSetColor(-1, 0x0000FF)
Global $Input_DefaultMenu = GUICtrlCreateInput("", 78, 48, 222, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_DefaultMenuChange")
Global $Button_BrowseStartMenu = GUICtrlCreateButton("···", 303, 50, 19, 19, $BS_NOTIFY)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetTip(-1, "Browse Current User StartMenu")
GUICtrlSetOnEvent(-1, "Button_BrowseStartMenuClick")
Global $Combo_Catalog = GUICtrlCreateCombo("", 78, 73, 222, 100, $GUI_SS_DEFAULT_COMBO)
GUICtrlSetOnEvent(-1, "Combo_CatalogChange")
Global $Button_AddMenuCatalog = GUICtrlCreateButton("+", 48, 98, 19, 19, $BS_NOTIFY)
GUICtrlSetFont(-1, 16, 800, 0, "Arial")
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "Add this Location to the .app file")
GUICtrlSetOnEvent(-1, "Button_AddMenuCatalogClick")
Global $Edit_CatalogList = GUICtrlCreateEdit("", 78, 118, 222, 61, $GUI_SS_DEFAULT_EDIT)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetOnEvent(-1, "Edit_CatalogListChange")
Global $Label_DefaultMenu = GUICtrlCreateLabel("Default Menu", 8, 51, 68, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "The default Startmenu shortcut location (used in the absence of an Advanced Menu)")
GUICtrlSetOnEvent(-1, "Label_DefaultMenuClick")
Global $Label_Catalog = GUICtrlCreateLabel("Menu Catalog", 8, 76, 68, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "The location in Advanced Startmenu sorting where you wish to move the default location to")
GUICtrlSetOnEvent(-1, "Label_CatalogClick")
Global $Label_scLocations = GUICtrlCreateLabel("Advanced Menu Destinations Catalog List:", 84, 100, 205, 17, 0)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "This is the list of all the desired Advanced Startmenu catalog locations")
GUICtrlSetOnEvent(-1, "Label_scLocationsClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_scTo = GUICtrlCreateGroup("Shortcut(s) Location(s):", 332, 27, 132, 159)
GUICtrlSetColor(-1, 0x0000FF)
Global $Checkbox_scStartMenu = GUICtrlCreateCheckbox("Start Menu (normal)", 337, 58, 118, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "Untick this to NOT create Shortcuts in the StartMenu. Affected by the flags: ''Keep in folder'' and ''Keep all''.")
GUICtrlSetOnEvent(-1, "Checkbox_scStartMenuClick")
Global $Checkbox_scPrograms = GUICtrlCreateCheckbox("Programs", 354, 88, 68, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Create shortcut in ''Start Menu\Programs''. Only the first shortcut from ''Shortcut Names to Keep'' or from ''Definitions''.")
GUICtrlSetOnEvent(-1, "Checkbox_scProgramsClick")
Global $Checkbox_scStartup = GUICtrlCreateCheckbox("Startup", 354, 103, 64, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Create shortcut in ''Start Menu\Programs\Startup''. Only the first shortcut from ''Shortcut Names to Keep'' or from ''Definitions''.")
GUICtrlSetOnEvent(-1, "Checkbox_scStartupClick")
Global $Checkbox_scDesktop = GUICtrlCreateCheckbox("Desktop", 337, 119, 75, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Create shortcut on ''Desktop''. Only the first shortcut from ''Shortcut Names to Keep'' or from ''Definitions''.")
GUICtrlSetOnEvent(-1, "Checkbox_scDesktopClick")
Global $Checkbox_scQLaunch = GUICtrlCreateCheckbox("Quick Launch", 337, 135, 88, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Create shortcut in ''QuickLaunch''. Only the first shortcut from ''Shortcut Names to Keep'' or from ''Definitions''.")
GUICtrlSetOnEvent(-1, "Checkbox_scQLaunchClick")
Global $Checkbox_scSendTo = GUICtrlCreateCheckbox("SendTo", 337, 151, 87, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Create shortcut in ''SendTo'' context-menu. Only the first shortcut from ''Shortcut Names to Keep'' or from ''Definitions''.")
GUICtrlSetOnEvent(-1, "Checkbox_scSendToClick")
Global $Checkbox_scAllUsers = GUICtrlCreateCheckbox("All Users", 337, 42, 63, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Create shortcut(s) for ''AllUsers'' instead of ''Current User'' using below listed flags.")
GUICtrlSetOnEvent(-1, "Checkbox_scAllUsersClick")
Global $Checkbox_scRoot = GUICtrlCreateCheckbox("Root", 354, 73, 45, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Create shortcut in ''Start Menu'' (Root). Only the first shortcut from ''Shortcut Names to Keep'' or from ''Definitions''.")
GUICtrlSetOnEvent(-1, "Checkbox_scRootClick")
Global $Checkbox_scTaskbarPin = GUICtrlCreateCheckbox("Taskbar Pin", 337, 167, 115, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Pin shortcut to the Taskbar (Windows 7 only)")
GUICtrlSetOnEvent(-1, "Checkbox_scTaskbarPinClick")
Global $Checkbox_scStartmenuPin = GUICtrlCreateCheckbox("Pin", 412, 73, 43, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Pin shortcut to the Startmenu (Windows 7 only)")
GUICtrlSetOnEvent(-1, "Checkbox_scStartmenuPinClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_scOptions = GUICtrlCreateGroup("Shortcut(s) Options:", 462, 27, 124, 159)
GUICtrlSetColor(-1, 0x0000FF)
Global $Checkbox_scNeverSort = GUICtrlCreateCheckbox("Leave alone", 467, 138, 105, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Suppress shortcut creation of any kind whatsoever. Over-rides ''Adv. menu always'', above.")
GUICtrlSetOnEvent(-1, "Checkbox_scNeverSortClick")
Global $Checkbox_scAlwaysSort = GUICtrlCreateCheckbox("Adv. menu always", 467, 74, 105, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Force shortcut creation into an Advanced menu rather than the Standard one -- a.k.a ''Always Sort''")
GUICtrlSetOnEvent(-1, "Checkbox_scAlwaysSortClick")
Global $Checkbox_scKeepInFolder = GUICtrlCreateCheckbox("Keep in folder", 467, 58, 105, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "Contain the shortcut(s) in the folder specified in ''Default Menu''. Applies to ''Start Menu (normal)'' only.")
GUICtrlSetOnEvent(-1, "Checkbox_scKeepInFolderClick")
Global $Checkbox_scKeepAll = GUICtrlCreateCheckbox("Keep all", 467, 42, 105, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "Keep all the shortcuts available in ''Definitions'' and ignore ''Shortcut names to keep''. Applies to ''Start Menu (normal)'' only.")
GUICtrlSetOnEvent(-1, "Checkbox_scKeepAllClick")
Global $Checkbox_scRefreshExplorer = GUICtrlCreateCheckbox("Refresh Explorer", 467, 106, 105, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Force a desktop refresh (without having to cycle thru a logoff then logon).")
GUICtrlSetOnEvent(-1, "Checkbox_scRefreshExplorerClick")
Global $Checkbox_NoMenuIcons = GUICtrlCreateCheckbox("No menu icons", 467, 90, 94, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Suppress this App's StartMenu icon folder creation.")
GUICtrlSetOnEvent(-1, "Checkbox_NoMenuIconsClick")
Global $Checkbox_LivePE = GUICtrlCreateCheckbox("Live PE", 467, 122, 94, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Mark this ppApp/ppGame for LivePE's such as ppAppsLive or ppGamesLive (not implemented).")
GUICtrlSetOnEvent(-1, "Checkbox_LivePEClick")
Global $Checkbox_MetroFriendly = GUICtrlCreateCheckbox("StartScreen-friendly", 467, 154, 115, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Over-rides 'Keep in folder' and 'Keep all' (above) to place shortcuts from the 'Shortcut names to keep' list or if empty, then the first ShortcutS def listed.")
GUICtrlSetOnEvent(-1, "Checkbox_MetroFriendlyClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_scDetails = GUICtrlCreateGroup("Shortcut(s) Definitions (Make or Keep)", 4, 187, 609, 175)
GUICtrlSetColor(-1, 0x0000FF)
Global $Button_scNew = GUICtrlCreateButton("2", 352, 213, 20, 20, BitOR($BS_CENTER, $BS_NOTIFY, $BS_ICON))
GUICtrlSetFont(-1, 16, 400, 0, "Wingdings")
GUICtrlSetTip(-1, "Create a new Shortcut here")
GUICtrlSetOnEvent(-1, "Button_scNewClick")
Global $Button_scUp = GUICtrlCreateButton("ñ", 399, 204, 20, 20, BitOR($BS_CENTER, $BS_NOTIFY, $BS_ICON))
GUICtrlSetFont(-1, 14, 400, 0, "Wingdings")
GUICtrlSetTip(-1, "Move UP in the list")
GUICtrlSetOnEvent(-1, "Button_scUpClick")
Global $Button_scDown = GUICtrlCreateButton("ò", 399, 225, 20, 20, BitOR($BS_CENTER, $BS_NOTIFY, $BS_ICON))
GUICtrlSetFont(-1, 14, 400, 0, "Wingdings")
GUICtrlSetTip(-1, "Move DOWN in the list")
GUICtrlSetOnEvent(-1, "Button_scDownClick")
Global $Button_scNameAdd = GUICtrlCreateButton("+", 376, 204, 20, 20, BitOR($BS_DEFPUSHBUTTON, $BS_NOTIFY, $BS_ICON))
GUICtrlSetFont(-1, 16, 800, 0, "MS Sans Serif")
GUICtrlSetTip(-1, "Add this shortcut to the definitions list (or press Enter) ")
GUICtrlSetOnEvent(-1, "Button_scNameAddClick")
Global $Button_scNameRemove = GUICtrlCreateButton("û", 376, 225, 20, 20, BitOR($BS_CENTER, $BS_NOTIFY, $BS_ICON))
GUICtrlSetFont(-1, 18, 400, 0, "Wingdings")
GUICtrlSetTip(-1, "Remove this shortcut from the list")
GUICtrlSetOnEvent(-1, "Button_scNameRemoveClick")
Global $Combo_scName = GUICtrlCreateCombo("", 76, 203, 245, 100, $GUI_SS_DEFAULT_COMBO)
GUICtrlSetOnEvent(-1, "Combo_scNameChange")
Global $Button_scNameBrowse = GUICtrlCreateButton("···", 323, 204, 19, 19, $BS_NOTIFY)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetTip(-1, "Browse the existing Startmenu for shortcuts to use, or keep after an installation (Note: Clears other fields)")
GUICtrlSetOnEvent(-1, "Button_scNameBrowseClick")
Global $Input_scTarget = GUICtrlCreateInput("", 76, 225, 245, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_scTargetChange")
Global $Button_scFile = GUICtrlCreateButton("···", 323, 226, 19, 19, $BS_NOTIFY)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetTip(-1, "Browse for target. The file that gets run with this shortcut")
GUICtrlSetOnEvent(-1, "Button_scFileClick")
Global $Input_scWorkDir = GUICtrlCreateInput("", 76, 247, 245, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_scWorkDirChange")
Global $Input_scIcon = GUICtrlCreateInput("", 76, 269, 245, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_scIconChange")
Global $Button_scIcon = GUICtrlCreateButton("···", 323, 270, 19, 19, $BS_NOTIFY)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Button_scIconClick")
Global $Input_scIndex = GUICtrlCreateInput("0", 392, 270, 25, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_scIndexChange")
Global $Input_scArgs = GUICtrlCreateInput("", 76, 291, 141, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_scArgsChange")
Global $Input_scExt = GUICtrlCreateInput("", 284, 291, 134, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_scExtChange")
GUICtrlSetTip(-1, "Separate each with a dot '' . ''")
Global $Input_scDesc = GUICtrlCreateInput("", 76, 313, 533, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetLimit(-1, 256)
GUICtrlSetOnEvent(-1, "Input_scDescChange")
Global $Input_scFlags = GUICtrlCreateInput("", 76, 335, 244, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_scFlagsChange")
Global $Input_scCatalog = GUICtrlCreateInput("", 369, 335, 240, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_scCatalogChange")
GUICtrlSetState(-1, $GUI_DISABLE)
Global $Edit_scKeep = GUICtrlCreateEdit("", 426, 218, 182, 70, $GUI_SS_DEFAULT_EDIT)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetOnEvent(-1, "Edit_scKeepChange")
Global $Button_scKeep = GUICtrlCreateButton("Add to -->", 427, 198, 59, 20, BitOR($BS_CENTER, $BS_NOTIFY))
GUICtrlSetTip(-1, "Add this shortcut to the keep list")
GUICtrlSetOnEvent(-1, "Button_scKeepClick")
Global $Label_scKeep = GUICtrlCreateLabel("Shortcut names to keep:", 489, 201, 120, 17, 0)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Lists the shortcuts to keep if not using the ''Keep All'' Option")
GUICtrlSetOnEvent(-1, "Label_scKeepClick")
Global $Label_scTarget = GUICtrlCreateLabel("File Target", 17, 228, 56, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "The physical exe location for the shortcut to execute")
GUICtrlSetOnEvent(-1, "Label_scTargetClick")
Global $Label_scDesc = GUICtrlCreateLabel("Description", 17, 317, 56, 14, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "This is the comment for shortcuts to have shown on mouse hover, or lists the kept shortcuts for SetupS")
GUICtrlSetOnEvent(-1, "Label_scDescClick")
Global $Label_scName = GUICtrlCreateLabel("Display Name", 6, 206, 68, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "Name the shortcut here. The display name is the actual name shown in the startmenu and on the desktop etc.")
GUICtrlSetOnEvent(-1, "Label_scNameClick")
Global $Label_scArgs = GUICtrlCreateLabel("Arguments", 17, 295, 56, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Any parameters or switches required by this shortcut")
GUICtrlSetOnEvent(-1, "Label_scArgsClick")
Global $Label_scExt = GUICtrlCreateLabel("Assoc.Ext(s)", 220, 295, 62, 14, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Use dots (.) commas (,) or spaces to separate each association.")
GUICtrlSetOnEvent(-1, "Label_scExtClick")
Global $Label_scIcon = GUICtrlCreateLabel("Icon File", 17, 272, 56, 14, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Select the file to get the icon from (if different from the exe)")
GUICtrlSetOnEvent(-1, "Label_scIconClick")
Global $Label_scIndex = GUICtrlCreateLabel("Index", 361, 273, 29, 13, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "The icon picture to use from the icon file or exe. Default is the first one (0)")
GUICtrlSetOnEvent(-1, "Label_scIndexClick")
Global $Label_scWorkDir = GUICtrlCreateLabel("Start In", 17, 250, 56, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "The folder to start the target from")
GUICtrlSetOnEvent(-1, "Label_scWorkDirClick")
Global $Label_scCount = GUICtrlCreateLabel("0", 344, 252, 77, 15, 0)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "This is the count of Shortcuts to create or Keep")
GUICtrlSetOnEvent(-1, "Label_scCountClick")
Global $Label_scFlags = GUICtrlCreateLabel("Flags", 17, 339, 56, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Separate each Flag-keyword with a vertical bar '' | ''")
GUICtrlSetOnEvent(-1, "Label_scFlagsClick")
Global $Label_scCatalog = GUICtrlCreateLabel("Catalog", 323, 339, 43, 14, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "Separate each Catalog-key with a vertical bar '' | ''")
GUICtrlSetOnEvent(-1, "Label_scCatalogClick")
Global $Label_scKey = GUICtrlCreateLabel("Hotkey", 422, 295, 38, 14, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "Use dots (.) commas (,) or spaces to separate each association.")
GUICtrlSetOnEvent(-1, "Label_scKeyClick")
Global $Input_scKey = GUICtrlCreateInput("", 462, 291, 147, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_scKeyChange")
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "Creates the ''Shortcut-key'' for this shortcut. Press F1 for details on the codes to use this.")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "The shortcuts you wish your application/game to have")
Global $TabSheet_PostProcessing = GUICtrlCreateTabItem("Post-processing")
Global $Group_Cmd = GUICtrlCreateGroup("Script/Batch/.Cmd:", 4, 27, 304, 231)
GUICtrlSetColor(-1, 0x0000FF)
Global $Edit_Cmd = GUICtrlCreateEdit("", 7, 41, 298, 213)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetOnEvent(-1, "Edit_CmdChange")
Global $Button_cmd = GUICtrlCreateButton("Pop-out editor", 210, 27, 80, 20, $BS_NOTIFY)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "a Script you wish to run post install")
GUICtrlSetOnEvent(-1, "Button_cmdClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "a Script you wish to run post install")
Global $Group_Reg = GUICtrlCreateGroup("Registry Entries/.Reg:", 308, 27, 304, 231)
GUICtrlSetColor(-1, 0x0000FF)
Global $Edit_Reg = GUICtrlCreateEdit("", 311, 41, 298, 213)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetOnEvent(-1, "Edit_RegChange")
Global $Button_Reg = GUICtrlCreateButton("Pop-out editor", 514, 27, 80, 20, $BS_NOTIFY)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "Registry modifications you wish to apply post install")
GUICtrlSetOnEvent(-1, "Button_RegClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "Registry modifications you wish to apply post install")
Global $Group_FileAssoc = GUICtrlCreateGroup("App. Extensions:", 4, 264, 96, 92)
GUICtrlSetColor(-1, 0x0000FF)
Global $Edit_FileAssoc = GUICtrlCreateEdit("", 7, 278, 90, 74, $GUI_SS_DEFAULT_EDIT)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetOnEvent(-1, "Edit_FileAssocChange")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "Each association should be separated by a dot (.) or a new line")
Global $Group_InstallFonts = GUICtrlCreateGroup("Install Fonts:", 105, 264, 196, 92)
GUICtrlSetColor(-1, 0x0000FF)
Global $Edit_InstallFonts = GUICtrlCreateEdit("", 108, 278, 190, 74, $GUI_SS_DEFAULT_EDIT)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetOnEvent(-1, "Edit_InstallFontsChange")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "Each font-name should be separated by a period (.) or a new line")
Global $Group_RegisterDLL = GUICtrlCreateGroup("RegisterServer (DLL/OCX):", 308, 264, 146, 92)
GUICtrlSetColor(-1, 0x0000FF)
Global $Edit_RegisterDLL = GUICtrlCreateEdit("", 311, 278, 140, 74, $GUI_SS_DEFAULT_EDIT)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetOnEvent(-1, "Edit_RegisterDLLChange")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "Each should be separated by a period (.) or a new line")
Global $Group_Postprocessing_Options = GUICtrlCreateGroup("Post-processing Options:", 468, 264, 142, 59)
GUICtrlSetColor(-1, 0x0000FF)
Global $Checkbox_MakeNonething = GUICtrlCreateCheckbox("Make Nonething App", 473, 282, 125, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_MULTILINE))
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Prevents (or removes) SetupS related files.")
GUICtrlSetOnEvent(-1, "Checkbox_MakeNonethingClick")
Global $Checkbox_NeverUpdateAppFile = GUICtrlCreateCheckbox("Never update App-file", 473, 300, 125, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_MULTILINE))
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Forces SetupS to not update an .app/.pgz-file even if changes are found.")
GUICtrlSetOnEvent(-1, "Checkbox_NeverUpdateAppFileClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Button_PatchFolder = GUICtrlCreateButton("Explore Patch Folder", 468, 332, 142, 20, $BS_NOTIFY)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "Open the patch folder (if it present)")
GUICtrlSetOnEvent(-1, "Button_PatchFolderClick")
Global $TabSheet_Previews = GUICtrlCreateTabItem("Graphics")
Global $Group_ScreenShot = GUICtrlCreateGroup("ScreenShot", 222, 27, 390, 306)
GUICtrlSetColor(-1, 0x0000FF)
Global $Pic_ScreenShot = GUICtrlCreatePic("", 225, 41, 384, 288)
GUICtrlSetTip(-1, "Click to pop out")
GUICtrlSetOnEvent(-1, "Button_ScrShotClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "Click to pop out")
Global $Group_Popup = GUICtrlCreateGroup("Pop Outs:", 4, 27, 75, 89)
GUICtrlSetColor(-1, 0x0000FF)
Global $Button_Icon = GUICtrlCreateButton("Icon", 9, 68, 65, 20, $BS_NOTIFY)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "an .ico to use for folder and startmenu icons")
GUICtrlSetOnEvent(-1, "Button_IconClick")
Global $Button_Fader = GUICtrlCreateButton("Fader", 9, 92, 65, 20, $BS_NOTIFY)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "a png image you wish to show on the fader screen, if enabled")
GUICtrlSetOnEvent(-1, "Button_FaderClick")
Global $Button_ScrShot = GUICtrlCreateButton("ScreenShot", 9, 44, 65, 20, $BS_NOTIFY)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "a jpg you wish to display in the ssWPI when you click on the app/game title")
GUICtrlSetOnEvent(-1, "Button_ScrShotClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $GroupIcon = GUICtrlCreateGroup("Icon", 164, 27, 54, 66)
GUICtrlSetColor(-1, 0x0000FF)
Global $Pic_Icon = GUICtrlCreateIcon("", -1, 167, 41, 48, 48)
GUICtrlSetTip(-1, "Click to pop out")
GUICtrlSetOnEvent(-1, "Button_IconClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "Click to pop out")
Global $Group_Fader = GUICtrlCreateGroup("Fader", 4, 116, 215, 217)
GUICtrlSetColor(-1, 0x0000FF)
Global $Pic_Fader = GUICtrlCreatePic("", 12, 130, 199, 199)
GUICtrlSetTip(-1, "Click to pop out")
GUICtrlSetOnEvent(-1, "Button_FaderClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "Click to pop out")
Global $Button_Refresh = GUICtrlCreateButton("Refresh", 164, 96, 54, 20, $BS_VCENTER)
GUICtrlSetColor(-1, 0x800000)
GUICtrlSetOnEvent(-1, "Button_RefreshClick")
Global $Group_ForceAssign = GUICtrlCreateGroup("Force Assign:", 84, 27, 75, 90)
GUICtrlSetColor(-1, 0x0000FF)
Global $Button_ForceIcon = GUICtrlCreateButton("Icon", 89, 68, 65, 20, $BS_NOTIFY)
GUICtrlSetTip(-1, "an .ico to use for folder and startmenu icons")
GUICtrlSetOnEvent(-1, "Button_ForceIconClick")
Global $Button_ForceFader = GUICtrlCreateButton("Fader", 89, 92, 65, 20, $BS_NOTIFY)
GUICtrlSetTip(-1, "a png image you wish to show on the fader screen, if enabled")
GUICtrlSetOnEvent(-1, "Button_ForceFaderClick")
Global $Button_ForceScreenShot = GUICtrlCreateButton("ScreenShot", 89, 44, 65, 20, $BS_NOTIFY)
GUICtrlSetTip(-1, "a jpg you wish to display in the ssWPI when you click on the app/game title")
GUICtrlSetOnEvent(-1, "Button_ForceScreenShotClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateTabItem("")
GUICtrlSetTip(-1, "Special flag to prevent or remove SetupS files")
Global $StatusBar_ssEditor = _GUICtrlStatusBar_Create($Form_ssEditor)
Global $Label_InstalltoPath = GUICtrlCreateLabel("Install-to Path:", 6, 368, 71, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "Pick the location the app will be installed to, This is important to be set as it is where the patched files are copied to and also where the ssWPI checks to see if the app is already installed on each system")
GUICtrlSetOnEvent(-1, "Label_InstalltoPathClick")
Global $Label_StartSource = GUICtrlCreateLabel("Start Menu:", 19, 385, 58, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "The default Startmenu shortcut location (used in the absence of an Advanced Menu)")
GUICtrlSetOnEvent(-1, "Label_StartSourceClick")
Global $Label_CopyAppPath = GUICtrlCreateLabel("", 80, 368, 528, 17, 0)
GUICtrlSetColor(-1, 0x800000)
GUICtrlSetTip(-1, "Pick the location the app will be installed to, This is important to be set as it is where the patched files are copied to and also where the ssWPI checks to see if the app is already installed on each system")
GUICtrlSetOnEvent(-1, "Label_CopyAppPathClick")
Global $Label_CopyDefaultMenu = GUICtrlCreateLabel("", 80, 385, 528, 30, 0)
GUICtrlSetColor(-1, 0x800000)
GUICtrlSetTip(-1, "The default Startmenu shortcut location (used in the absence of an Advanced Menu)")
GUICtrlSetOnEvent(-1, "Label_CopyDefaultMenuClick")
Global $Button_Vars = GUICtrlCreateButton("", 454, 1, 20, 20, $BS_ICON)
GUICtrlSetFont(-1, 14, 400, 0, "Wingdings")
GUICtrlSetTip(-1, "View Variables List {F3}")
GUICtrlSetOnEvent(-1, "MenuItem_ViewVarsClick")
Global $Button_Save = GUICtrlCreateButton("", 404, 1, 20, 20, $BS_ICON)
GUICtrlSetFont(-1, 14, 400, 0, "Wingdings")
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "Save SetupS file {Ctrl+S}")
GUICtrlSetOnEvent(-1, "MenuItem_SaveClick")
Global $Button_Open = GUICtrlCreateButton("", 384, 1, 20, 20, $BS_ICON)
GUICtrlSetFont(-1, 11, 400, 0, "Wingdings")
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "Open SetupS file/folder {Ctrl+O}")
GUICtrlSetOnEvent(-1, "MenuItem_OpenClick")
Global $Button_New = GUICtrlCreateButton("", 364, 1, 20, 20, $BS_ICON)
GUICtrlSetFont(-1, 14, 400, 0, "Wingdings")
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "New SetupS file {Ctrl+N}")
GUICtrlSetOnEvent(-1, "MenuItem_NewClick")
Global $Button_Build = GUICtrlCreateButton("Build!", 594, 1, 20, 20, $BS_ICON)
GUICtrlSetFont(-1, 14, 400, 0, "Wingdings")
GUICtrlSetTip(-1, "Build! {F5}")
GUICtrlSetOnEvent(-1, "Button_BuildClick")
Global $Button_HelpContents = GUICtrlCreateButton("", 334, 1, 20, 20, $BS_ICON)
GUICtrlSetFont(-1, 14, 400, 0, "Wingdings")
GUICtrlSetTip(-1, "Help Contents {F1}")
GUICtrlSetOnEvent(-1, "MenuItem_ContentsClick")
Global $Group_VR1 = GUICtrlCreateGroup("", 358, 0, 1, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_VR3 = GUICtrlCreateGroup("", 498, 0, 1, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Button_ViewSource = GUICtrlCreateButton("", 474, 1, 20, 20, $BS_ICON)
GUICtrlSetFont(-1, 14, 400, 0, "Wingdings")
GUICtrlSetTip(-1, "Pop-out edit Source in Notepad {F4}")
GUICtrlSetOnEvent(-1, "MenuItem_ViewInNotepadClick")
Global $Group_VR2 = GUICtrlCreateGroup("", 428, 0, 1, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Button_ViewWorkDir = GUICtrlCreateButton("", 434, 1, 20, 20, $BS_ICON)
GUICtrlSetFont(-1, 14, 400, 0, "Wingdings")
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "Explore Working Folder {F2}")
GUICtrlSetOnEvent(-1, "MenuItem_Browse2WorkingClick")
Global $Button_SetupSTest = GUICtrlCreateButton("", 574, 1, 20, 20, $BS_ICON)
GUICtrlSetFont(-1, 14, 400, 0, "Wingdings")
GUICtrlSetTip(-1, "SetupS Test {F8}")
GUICtrlSetOnEvent(-1, "MenuItem_SetupSTestClick")
Global $Group_VR4 = GUICtrlCreateGroup("", 568, 0, 1, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Button_ExtactIcons = GUICtrlCreateButton("", 504, 1, 20, 20, $BS_ICON)
GUICtrlSetFont(-1, 14, 400, 0, "Wingdings")
GUICtrlSetTip(-1, "Extract Icons {F10}")
GUICtrlSetOnEvent(-1, "MenuItem_ExtractICOClick")
Global $Button_ScreenCapture = GUICtrlCreateButton("", 524, 1, 20, 20, $BS_ICON)
GUICtrlSetFont(-1, 14, 400, 0, "Wingdings")
GUICtrlSetTip(-1, "Screen Capture {F11}")
GUICtrlSetOnEvent(-1, "MenuItem_ScreenCaptureClick")
Global $Button_GrabClipboardPic = GUICtrlCreateButton("", 544, 1, 20, 20, $BS_ICON)
GUICtrlSetFont(-1, 14, 400, 0, "Wingdings")
GUICtrlSetTip(-1, "Grab Clipboard Picture {F12}")
GUICtrlSetOnEvent(-1, "MenuItem_GrabClipBoardPicClick")
Global $Form_ssEditor_AccelTable[14][2] = [["^n", $MenuItem_New],["^o", $MenuItem_Open],["^s", $MenuItem_Save],["{F2}", $MenuItem_Browse2Working],["{F3}", $MenuItem_ViewVars],["{F4}", $MenuItem_ViewInNotepad],["{F11}", $MenuItem_ScreenCapture],["{F12}", $MenuItem_GrabClipBoardPic],["{F10}", $MenuItem_ExtractICO],["{F8}", $MenuItem_SetupSTest],["{F5}", $MenuItem_Build],["^i", $MenuItem_Au3Info],["^t", $MenuItem_Taskmgr],["{F1}", $MenuItem_Contents]]
GUISetAccelerators($Form_ssEditor_AccelTable)
#endregion ### END Koda GUI section ###

#region ### START Koda GUI section ### Form=ssEditor_About.kxf
Global $Form_About = GUICreate("About", 388, 155, -1, -1, BitOR($WS_SIZEBOX, $WS_THICKFRAME, $WS_SYSMENU, $WS_POPUP), -1, $Form_ssEditor)
GUISetOnEvent($GUI_EVENT_CLOSE, "Form_AboutClose")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "Form_AboutMinimize")
GUISetOnEvent($GUI_EVENT_MAXIMIZE, "Form_AboutMaximize")
GUISetOnEvent($GUI_EVENT_RESTORE, "Form_AboutRestore")
Global $Button_Ok_About = GUICtrlCreateButton("&OK", 318, 123, 58, 24, 0)
GUICtrlSetOnEvent($Button_Ok_About, "Button_Ok_AboutClick")
Global $About_Logo = GUICtrlCreatePic("", 15, 10, 200, 100)
GUICtrlSetOnEvent($About_Logo, "About_LogoClick")
Global $About_Copyright = GUICtrlCreateLabel("(c)2012, Team ssTek", 235, 33, 130, 20)
GUICtrlSetFont($About_Copyright, 10, 400, 0, "MS Sans Serif")
GUICtrlSetOnEvent($About_Copyright, "About_CopyrightClick")
Global $About_Version = GUICtrlCreateLabel("Version xx.xx.xx.xx", 240, 14, 129, 20)
GUICtrlSetFont($About_Version, 10, 800, 0, "MS Sans Serif")
GUICtrlSetOnEvent($About_Version, "About_VersionClick")
Global $About_CoreVer = GUICtrlCreateLabel("Licensed under the terms of GPLv3", 32, 134, 204, 17)
GUICtrlSetFont($About_CoreVer, 8, 800, 4, "MS Sans Serif")
GUICtrlSetColor($About_CoreVer, 0x0000FF)
GUICtrlSetOnEvent($About_CoreVer, "About_CoreVerClick")
Global $About_Comment = GUICtrlCreateLabel("Built on LXP Technology", 48, 119, 144, 17)
GUICtrlSetFont($About_Comment, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor($About_Comment, 0x008000)
GUICtrlSetOnEvent($About_Comment, "About_CommentClick")
Global $About_URL = GUICtrlCreateLabel("ssTek Forum", 266, 60, 75, 17)
GUICtrlSetFont($About_URL, 8, 800, 4, "MS Sans Serif")
GUICtrlSetColor($About_URL, 0x0000FF)
GUICtrlSetOnEvent($About_URL, "About_URLClick")
Global $About_URL2 = GUICtrlCreateLabel("LastOS Forum", 266, 75, 75, 17)
GUICtrlSetFont($About_URL2, 8, 800, 4, "MS Sans Serif")
GUICtrlSetColor($About_URL2, 0x0000FF)
GUICtrlSetOnEvent($About_URL2, "About_URL2Click")
Global $About_URL3 = GUICtrlCreateLabel("#WebSite3#", 266, 90, 75, 17)
GUICtrlSetFont($About_URL3, 8, 800, 4, "MS Sans Serif")
GUICtrlSetColor($About_URL3, 0x0000FF)
GUICtrlSetOnEvent($About_URL3, "About_URL3Click")
#endregion ### END Koda GUI section ###

#region ### START Koda GUI section ### Form=ssEditor_Vars.kxf
Global $Form_Vars = GUICreate("Variables List (click to add to clipboard)", 625, 383, -1, -1, BitOR($GUI_SS_DEFAULT_GUI, $WS_MAXIMIZEBOX, $WS_SIZEBOX, $WS_THICKFRAME, $WS_TABSTOP), -1, $Form_ssEditor)
GUISetOnEvent($GUI_EVENT_CLOSE, "Form_VarsClose")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "Form_VarsMinimize")
GUISetOnEvent($GUI_EVENT_MAXIMIZE, "Form_VarsMaximize")
GUISetOnEvent($GUI_EVENT_RESTORE, "Form_VarsRestore")
Global $Group_Vars_Directives = GUICtrlCreateGroup("Gate Directives:", 418, 5, 169, 54)
GUICtrlSetColor(-1, 0x0000FF)
Global $Label_Directive_x86_Vars = GUICtrlCreateLabel("#Is_x86#", 428, 20, 60, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Process this line for 32-bit OS-Architectures (x86) only.")
GUICtrlSetOnEvent(-1, "Label_Directive_x86_VarsClick")
Global $Label_Directive_x64_Vars = GUICtrlCreateLabel("#Is_x64#", 428, 37, 60, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Process this line for 64-bit OS-Architectures (x64) only.")
GUICtrlSetOnEvent(-1, "Label_Directive_x64_VarsClick")
Global $Label_Directive_NT6_Vars = GUICtrlCreateLabel("#Is_NT6#", 511, 37, 60, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Process this line for NT6.x OS's only (Windows Vista/7/2008)")
GUICtrlSetOnEvent(-1, "Label_Directive_NT6_VarsClick")
Global $Label_Directive_NT5_Vars = GUICtrlCreateLabel("#Is_NT5#", 511, 20, 60, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Process this line for NT5.x OS's only (Windows 2000/XP/2003)")
GUICtrlSetOnEvent(-1, "Label_Directive_NT5_VarsClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_Vars_Components = GUICtrlCreateGroup("Components:", 419, 61, 200, 109)
GUICtrlSetColor(-1, 0x0000FF)
Global $Label_Component_AddonInstaller_Vars = GUICtrlCreateLabel("%AddonInstaller%", 429, 76, 116, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "%AddonInstaller% [path\filename] : Process Addons such as ones from Kel or RyanVM.")
GUICtrlSetOnEvent(-1, "Label_Component_AddonInstaller_VarsClick")
Global $Label_Component_ProcessKill_Vars = GUICtrlCreateLabel("%ProcessKill%", 429, 93, 95, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "%ProcessKill% [filename] : To force a process/task to close from a given filename.")
GUICtrlSetOnEvent(-1, "Label_Component_ProcessKill_VarsClick")
Global $Label_Component_WaitForIt_Vars = GUICtrlCreateLabel("%WaitForIt%", 429, 110, 81, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "%WaitForIt% [path\filename] : Force SetupS to pause until a specific file is created or copied to that location. Shortcut files (.lnk) are recommended because they are often created last by installers.")
GUICtrlSetOnEvent(-1, "Label_Component_WaitForIt_VarsClick")
Global $Label_Component_AddToHosts_Vars = GUICtrlCreateLabel("%AddToHosts%", 429, 127, 88, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "%AddToHosts% {IP address} {host name} : Sets mappings of IP addresses to host names.")
GUICtrlSetOnEvent(-1, "Label_Component_AddToHosts_VarsClick")
Global $Label_Component_Extract_Vars = GUICtrlCreateLabel("%Extract%", 429, 144, 67, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "%Extract% {archive} -o{destination path} : Extract an archive to a specified destination path. Exactly equivalent to: '7z x -y -aoa {archive} -o{destination path}'")
GUICtrlSetOnEvent(-1, "Label_Component_Extract_VarsClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_Vars_System = GUICtrlCreateGroup("System/Environment Data:", 5, 5, 415, 54)
GUICtrlSetColor(-1, 0x0000FF)
Global $Label_Vars_System_SystemDrive = GUICtrlCreateLabel("%SystemDrive%", 10, 20, 95, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''C:''")
GUICtrlSetOnEvent(-1, "Label_Vars_System_SystemDriveClick")
Global $Label_Vars_System_SystemRoot = GUICtrlCreateLabel("%SystemRoot%", 10, 37, 88, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''C:\Windows''")
GUICtrlSetOnEvent(-1, "Label_Vars_System_SystemRootClick")
Global $Label_Vars_System_ProgramFiles = GUICtrlCreateLabel("%ProgramFiles%", 119, 20, 102, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''C:\Program Files''")
GUICtrlSetOnEvent(-1, "Label_Vars_System_ProgramFilesClick")
Global $Label_Vars_System_CommonProgramFiles = GUICtrlCreateLabel("%CommonProgramfiles%", 119, 37, 144, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''C:\Program Files\Common Files''")
GUICtrlSetOnEvent(-1, "Label_Vars_System_CommonProgramFilesClick")
Global $Label_Vars_System_ComputerName = GUICtrlCreateLabel("%ComputerName%", 295, 20, 102, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "{computername}, ie, ''JOHNDOEPC''")
GUICtrlSetOnEvent(-1, "Label_Vars_System_ComputerNameClick")
Global $Label_Vars_System_SystemDir = GUICtrlCreateLabel("%SystemDir%", 295, 37, 81, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''C:\Windows\System32'")
GUICtrlSetOnEvent(-1, "Label_Vars_System_SystemDirClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Button_Close_Vars = GUICtrlCreateButton("&Close", 544, 352, 75, 25)
GUICtrlSetOnEvent(-1, "Button_Close_VarsClick")
Global $Group_Vars_CurrentUser = GUICtrlCreateGroup("Current User Data:", 5, 61, 416, 109)
GUICtrlSetColor(-1, 0x0000FF)
Global $Label_Vars_CurrentUser_Startup = GUICtrlCreateLabel("%Startup%", 220, 110, 67, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%Programs%\Startup''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_StartupClick")
Global $Label_Vars_CurrentUser_Username = GUICtrlCreateLabel("%Username%", 10, 76, 74, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "{username}, ie, ''JOHNDOE''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_UsernameClick")
Global $Label_Vars_CurrentUser_HomeDrive = GUICtrlCreateLabel("%HomeDrive%", 10, 93, 81, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Drive of %UserProfile%, ie, ''C:''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_HomeDriveClick")
Global $Label_Vars_CurrentUser_Temp = GUICtrlCreateLabel("%Temp%", 314, 110, 46, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "User's Temp folder, ie, ''%UserProfile%\Local Settings\Temp''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_TempClick")
Global $Label_Vars_CurrentUser_AppData = GUICtrlCreateLabel("%AppData%", 114, 127, 67, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%UserProfile%\Application Data''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_AppDataClick")
Global $Label_Vars_CurrentUser_Desktop = GUICtrlCreateLabel("%Desktop%", 114, 93, 67, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%UserProfile%\Desktop''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_DesktopClick")
Global $Label_Vars_CurrentUser_MyDocuments = GUICtrlCreateLabel("%MyDocuments%", 114, 76, 95, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%UserProfile%\JOHNDOE's Documents''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_MyDocumentsClick")
Global $Label_Vars_CurrentUser_StartMenu = GUICtrlCreateLabel("%StartMenu%", 220, 76, 81, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%UserProfile%\Start Menu''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_StartMenuClick")
Global $Label_Vars_CurrentUser_Programs = GUICtrlCreateLabel("%Programs%", 220, 93, 74, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%StartMenu%\Programs''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_ProgramsClick")
Global $Label_Vars_CurrentUser_UserProfile = GUICtrlCreateLabel("%UserProfile%", 10, 127, 95, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''C:\Documents and Settings\JOHNDOE''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_UserProfileClick")
Global $Label_Vars_CurrentUser_HomePath = GUICtrlCreateLabel("%HomePath%", 10, 110, 74, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Folder-only (no drive) of %UserProfile%, ie,  ''\Documents and Settings\JOHNDOE''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_HomePathClick")
Global $Label_Vars_CurrentUser_Favorites = GUICtrlCreateLabel("%Favorites%", 114, 110, 81, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%UserProfile%\Favorites''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_FavoritesClick")
Global $Label_Vars_CurrentUser_SendtoPath = GUICtrlCreateLabel("%SendtoPath%", 314, 76, 88, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%UserProfile%\SendTo''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_SendtoPathClick")
Global $Label_Vars_CurrentUser_QuickLaunch = GUICtrlCreateLabel("%QuickLaunch%", 314, 93, 95, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%AppData%\Microsoft\Internet Explorer\Quick Launch''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_QuickLaunchClick")
Global $Label_Vars_CurrentUser_LocalAppData = GUICtrlCreateLabel("%LocalAppData%", 220, 127, 102, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%UserProfile%\AppData\Local''")
GUICtrlSetOnEvent(-1, "Label_Vars_CurrentUser_LocalAppDataClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_Vars_SetupS = GUICtrlCreateGroup("SetupS Data:", 5, 263, 416, 109)
GUICtrlSetColor(-1, 0x0000FF)
Global $Label_Vars_SetupS_AppPath = GUICtrlCreateLabel("%AppPath%", 10, 295, 67, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Full path (drive + folder) to the App's or Game's actual installed-to folder.")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_AppPathClick")
Global $Label_Vars_SetupS_SourcePath = GUICtrlCreateLabel("%SourcePath%", 10, 312, 88, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Full path (drive + folder) to the .app or .ppg file.")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_SourcePathClick")
Global $Label_Vars_SetupS_ppApps = GUICtrlCreateLabel("%ppApps%", 10, 329, 60, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Full path (drive + folder) to the system's ''x:\ppApps\'' folder.")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_ppAppsClick")
Global $Label_Vars_SetupS_ppGames = GUICtrlCreateLabel("%ppGames%", 10, 346, 67, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Full path (drive + folder) to the system's ''x:\ppGames\'' folder.")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_ppGamesClick")
Global $Label_Vars_SetupS_Tools = GUICtrlCreateLabel("%Tools%", 10, 278, 53, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Full path (drive + folder) to SetupS's Tools folder.")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_ToolsClick")
Global $Label_Vars_SetupS_AppDrive = GUICtrlCreateLabel("%AppDrive%", 118, 295, 74, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Drive only of the App's or Game's actual installed-to folder.")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_AppDriveClick")
Global $Label_Vars_SetupS_SourceDrive = GUICtrlCreateLabel("%SourceDrive%", 118, 312, 95, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Drive only of the .app or .ppg file.")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_SourceDriveClick")
Global $Label_Vars_SetupS_ppAppsDrive = GUICtrlCreateLabel("%ppAppsDrive%", 118, 329, 95, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Drive only of the system's ''x:\ppApps\'' folder.")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_ppAppsDriveClick")
Global $Label_Vars_SetupS_ppGamesDrive = GUICtrlCreateLabel("%ppGamesDrive%", 118, 346, 102, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Drive only of the system's ''x:\ppGames\'' folder.")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_ppGamesDriveClick")
Global $Label_Vars_SetupS_ToolsDrive = GUICtrlCreateLabel("%ToolsDrive%", 118, 278, 88, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Drive only of SetupS's Tools folder.")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_ToolsDriveClick")
Global $Label_Vars_SetupS_AppFolder = GUICtrlCreateLabel("%AppFolder%", 240, 296, 81, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Folder only path to the App's or Game's actual installed-to folder.")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_AppFolderClick")
Global $Label_Vars_SetupS_SourceFolder = GUICtrlCreateLabel("%SourceFolder%", 240, 313, 102, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Folder only path to the .app or .ppg file.")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_SourceFolderClick")
Global $Label_Vars_SetupS_ToolsFolder = GUICtrlCreateLabel("%ToolsFolder%", 240, 279, 95, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Folder only path to SetupS's '\tools\' folder (no drive letter).")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_ToolsFolderClick")
Global $Label_Vars_SetupS_CDROM = GUICtrlCreateLabel("%CDROM%", 240, 329, 53, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "Drive only of the system's optical drive (real or virtual).")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_CDROMClick")
Global $Label_Vars_SetupS_ssTekResources = GUICtrlCreateLabel("%ssTekResources%", 240, 346, 116, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "For ''%WinDir%\ssTek'' (ie, ''C:\Windows\ssTek'')")
GUICtrlSetOnEvent(-1, "Label_Vars_SetupS_ssTekResourcesClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_Vars_AllUsers = GUICtrlCreateGroup("All Users Data:", 5, 172, 416, 90)
GUICtrlSetColor(-1, 0x0000FF)
Global $Label_Vars_AllUsers_StartupCommon = GUICtrlCreateLabel("%StartupCommon%", 158, 221, 109, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%ProgramsCommon%\Startup''")
GUICtrlSetOnEvent(-1, "Label_Vars_AllUsers_StartupCommonClick")
Global $Label_Vars_AllUsers_AllUsersProfile = GUICtrlCreateLabel("%AllUsersProfile%", 10, 187, 123, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''C:\Documents and Settings\All Users''")
GUICtrlSetOnEvent(-1, "Label_Vars_AllUsers_AllUsersProfileClick")
Global $Label_Vars_AllUsers_AppDataCommon = GUICtrlCreateLabel("%AppDataCommon%", 299, 204, 109, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%AllUsersProfile%\Application Data''")
GUICtrlSetOnEvent(-1, "Label_Vars_AllUsers_AppDataCommonClick")
Global $Label_Vars_AllUsers_DesktopCommon = GUICtrlCreateLabel("%DesktopCommon%", 10, 221, 109, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%AllUsersProfile%\Desktop''")
GUICtrlSetOnEvent(-1, "Label_Vars_AllUsers_DesktopCommonClick")
Global $Label_Vars_AllUsers_DocumentsCommon = GUICtrlCreateLabel("%DocumentsCommon%", 10, 204, 123, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%AllUsersProfile%\Documents''")
GUICtrlSetOnEvent(-1, "Label_Vars_AllUsers_DocumentsCommonClick")
Global $Label_Vars_AllUsers_StartMenuCommon = GUICtrlCreateLabel("%StartMenuCommon%", 158, 187, 123, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%AllUsersProfile%\Start Menu''")
GUICtrlSetOnEvent(-1, "Label_Vars_AllUsers_StartMenuCommonClick")
Global $Label_Vars_AllUsers_ProgramsCommon = GUICtrlCreateLabel("%ProgramsCommon%", 158, 204, 116, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%StartMenuCommon%\Programs''")
GUICtrlSetOnEvent(-1, "Label_Vars_AllUsers_ProgramsCommonClick")
Global $Label_Vars_AllUsers_FavoritesCommon = GUICtrlCreateLabel("%FavoritesCommon%", 10, 238, 123, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%AllUsersProfile%\Favorites''")
GUICtrlSetOnEvent(-1, "Label_Vars_AllUsers_FavoritesCommonClick")
Global $Label_Vars_AllUsers_SendtoCommon = GUICtrlCreateLabel("%SendtoCommon%", 299, 187, 102, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''%AllUsersProfile%\SendTo''")
GUICtrlSetOnEvent(-1, "Label_Vars_AllUsers_SendtoCommonClick")
Global $Label_Vars_AllUsers_Public = GUICtrlCreateLabel("%Public%", 299, 221, 60, 19)
GUICtrlSetFont(-1, 9, 400, 0, "Courier New")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetTip(-1, "ie, ''C:\Users\Public''")
GUICtrlSetOnEvent(-1, "Label_Vars_AllUsers_PublicClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
#endregion ### END Koda GUI section ###

#region ### START Koda GUI section ### Form=ssEditor_MetaEditor.kxf
Global $Form_MetaEditor = GUICreate("Meta-data Editor", 584, 197, -1, -1, BitOR($GUI_SS_DEFAULT_GUI, $WS_MAXIMIZEBOX, $WS_SIZEBOX, $WS_THICKFRAME, $WS_TABSTOP), -1, $Form_ssEditor)
GUISetOnEvent($GUI_EVENT_CLOSE, "Form_MetaEditorClose")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "Form_MetaEditorMinimize")
GUISetOnEvent($GUI_EVENT_MAXIMIZE, "Form_MetaEditorMaximize")
GUISetOnEvent($GUI_EVENT_RESTORE, "Form_MetaEditorRestore")
Global $Group_Tags = GUICtrlCreateGroup("Tags (separate each with | )", 4, 0, 575, 48)
GUICtrlSetColor(-1, 0x0000FF)
Global $Label_Tags = GUICtrlCreateLabel("Select:", 8, 20, 40, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "Searchable Tags or keywords here (separate each with | ). Click here for suggestions.")
GUICtrlSetOnEvent(-1, "Label_TagsClick")
Global $Combo_Tags = GUICtrlCreateCombo("", 51, 17, 194, 100, $GUI_SS_DEFAULT_COMBO)
GUICtrlSetOnEvent(-1, "Combo_TagsChange")
Global $Button_AddTag = GUICtrlCreateButton("Add -->", 257, 18, 54, 19, $BS_NOTIFY)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "Adds selection to the list")
GUICtrlSetOnEvent(-1, "Button_AddTagClick")
Global $Input_Tags = GUICtrlCreateInput("", 323, 17, 249, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_TagsChange")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_Details = GUICtrlCreateGroup("Additional Application/Game Details:", 0, 50, 485, 140)
GUICtrlSetColor(-1, 0x0000FF)
Global $Label_Publisher = GUICtrlCreateLabel("Publisher", 5, 71, 53, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Original author or developer of the app/game.")
GUICtrlSetOnEvent(-1, "Label_PublisherClick")
Global $Input_Publisher = GUICtrlCreateInput("", 60, 68, 158, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_PublisherChange")
Global $Label_Language = GUICtrlCreateLabel("Language", 5, 94, 53, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Language (if not English).")
GUICtrlSetOnEvent(-1, "Label_LanguageClick")
Global $Input_Language = GUICtrlCreateInput("", 60, 91, 158, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_LanguageChange")
Global $Label_Rating = GUICtrlCreateLabel("Rating", 5, 117, 53, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Use ratings between 1 to 5.")
GUICtrlSetOnEvent(-1, "Label_RatingClick")
Global $Input_Rating = GUICtrlCreateInput("", 60, 114, 158, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_RatingChange")
Global $Label_Additional = GUICtrlCreateLabel("Additional", 5, 139, 53, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Extra information or comments.")
GUICtrlSetOnEvent(-1, "Label_AdditionalClick")
Global $Input_Additional = GUICtrlCreateInput("", 60, 136, 158, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_AdditionalChange")
Global $Label_ReleaseVersion = GUICtrlCreateLabel("Release Version", 225, 71, 93, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "The version of publication by the original developer(s).")
GUICtrlSetOnEvent(-1, "Label_ReleaseVersionClick")
Global $Input_ReleaseVersion = GUICtrlCreateInput("", 321, 68, 158, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_ReleaseVersionChange")
Global $Label_ReleaseDate = GUICtrlCreateLabel("Release Date", 225, 94, 93, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "The date of publication by the original developer(s). Recommended format: yyyy-mm-dd.")
GUICtrlSetOnEvent(-1, "Label_ReleaseDateClick")
Global $Input_ReleaseDate = GUICtrlCreateInput("", 321, 91, 158, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_ReleaseDateChange")
Global $Label_RequiredRuntimes = GUICtrlCreateLabel("Required Runtimes", 225, 117, 93, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Prerequisites that need installed (such as, DirectX, Java, Flash, etc.).")
GUICtrlSetOnEvent(-1, "Label_RequiredRuntimesClick")
Global $Input_RequiredRuntimes = GUICtrlCreateInput("", 321, 114, 158, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_RequiredRuntimesChange")
Global $Label_Releaser = GUICtrlCreateLabel("Builder", 225, 139, 93, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "The person or group who prepared this SetupS package.")
GUICtrlSetOnEvent(-1, "Label_ReleaserClick")
Global $Input_Releaser = GUICtrlCreateInput("", 321, 136, 158, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_ReleaserChange")
Global $Label_InstalledSize = GUICtrlCreateLabel("Installed Size", 225, 162, 93, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "The approximate size on the drive this package will ultimately require.")
GUICtrlSetOnEvent(-1, "Label_InstalledSizeClick")
Global $Input_InstalledSize = GUICtrlCreateInput("", 321, 159, 101, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_InstalledSizeChange")
Global $Button_GetppExtractedSize = GUICtrlCreateButton("<-- Import", 424, 160, 55, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "A ppApp/ppGame/Patch archive(s) must be present. Only works reliably with ppGames or Dual-arch ppApps.")
GUICtrlSetOnEvent(-1, "Button_GetppExtractedSizeClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "This Section is for the information ssWPI needs to list them and categorise them")
Global $Group_LicenseType = GUICtrlCreateGroup("License Type:", 483, 50, 95, 87)
GUICtrlSetColor(-1, 0x0000FF)
Global $Radio_LicenseType_NA = GUICtrlCreateRadio("Unknown", 488, 65, 85, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Unassigned")
GUICtrlSetOnEvent(-1, "Radio_LicenseType_NAClick")
Global $Radio_LicenseType_NonGratis = GUICtrlCreateRadio("Commercial", 488, 82, 85, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Non-gratis (Non-Free) proprietary/closed-source.")
GUICtrlSetOnEvent(-1, "Radio_LicenseType_NonGratisClick")
Global $Radio_LicenseType_Gratis = GUICtrlCreateRadio("Non-profit", 488, 99, 85, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Gratis-only (Free as in beer) proprietary/closed-source.")
GUICtrlSetOnEvent(-1, "Radio_LicenseType_GratisClick")
Global $Radio_LicenseType_Libre = GUICtrlCreateRadio("Open-source", 487, 116, 85, 17)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "Libre (Free as in speech and beer) non-proprietary.")
GUICtrlSetOnEvent(-1, "Radio_LicenseType_LibreClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Button_Close_MetaEditor = GUICtrlCreateButton("&Close", 514, 159, 59, 25)
GUICtrlSetTip(-1, "Return to the main editor. (or press Esc)")
GUICtrlSetOnEvent(-1, "Form_MetaEditorClose")
#endregion ### END Koda GUI section ###

#region ### START Koda GUI section ### Form=ssEditor_ssCreator.kxf
Global $Form_ssCreator = GUICreate("SetupS Creator", 619, 187, -1, -1)
GUISetOnEvent($GUI_EVENT_CLOSE, "Form_ssCreatorClose")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "Form_ssCreatorMinimize")
GUISetOnEvent($GUI_EVENT_MAXIMIZE, "Form_ssCreatorMaximize")
GUISetOnEvent($GUI_EVENT_RESTORE, "Form_ssCreatorRestore")
Global $Label_DefaultMenu_ssc = GUICtrlCreateLabel("Default Start Menu", 172, 16, 93, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "The default Startmenu shortcut location (used in the absence of an Advanced Menu)")
GUICtrlSetOnEvent(-1, "Label_DefaultMenu_sscClick")
Global $Input_DefaultMenu_ssc = GUICtrlCreateInput("", 268, 13, 222, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_DefaultMenu_sscChange")
Global $Button_BrowseStartMenu_ssc = GUICtrlCreateButton("···", 493, 15, 19, 19, $BS_NOTIFY)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetTip(-1, "Browse Current User StartMenu")
GUICtrlSetOnEvent(-1, "Button_BrowseStartMenu_sscClick")
Global $Group_BuildType_ssc = GUICtrlCreateGroup("Build Type", 6, 6, 74, 92)
GUICtrlSetColor(-1, 0x0000FF)
Global $Radio_Build_ssApp_ssc = GUICtrlCreateRadio("ssApp", 11, 21, 48, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "(s)ilent (s)etup (App)lication -- a standard Installer that will be made silent, these are not kept on the system after a fresh OS install")
GUICtrlSetOnEvent(-1, "Radio_Build_ssApp_sscClick")
Global $Radio_Build_ppApp_ssc = GUICtrlCreateRadio("ppApp", 11, 39, 50, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "(p)ermanent & (p)ortable (App)lication -- these are installed to the OS on a seperate partition/HDD and can be reused with no need to install them again")
GUICtrlSetOnEvent(-1, "Radio_Build_ppApp_sscClick")
Global $Radio_Build_ppGame_ssc = GUICtrlCreateRadio("ppGame", 11, 57, 63, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "(p)ermanent & (p)ortable (Game) -- similar to ppApps but for games")
GUICtrlSetOnEvent(-1, "Radio_Build_ppGame_sscClick")
Global $Radio_Build_ppTweak_ssc = GUICtrlCreateRadio("ppTweak", 11, 75, 63, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "(p)ermanent & (p)ortable (Tweak) -- this is a special kind of ppApp. No application to install")
GUICtrlSetOnEvent(-1, "Radio_Build_ppTweak_sscClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "Pick your type of application/game to create")
Global $Label_Title_ssc = GUICtrlCreateLabel("Title", 175, 41, 40, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "shown in the ssWPI as the name of the option")
GUICtrlSetOnEvent(-1, "Label_Title_sscClick")
Global $Input_Title_ssc = GUICtrlCreateInput("", 218, 38, 295, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_Title_sscChange")
Global $Label_AppPath_ssc = GUICtrlCreateLabel("Install-to Path:", 173, 72, 71, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "Pick the location the app will be installed to, This is important to be set as it is where the patched files are copied to and also where the ssWPI checks to see if the app is already installed on each system")
GUICtrlSetOnEvent(-1, "Label_AppPath_sscClick")
Global $Input_AppPath_ssc = GUICtrlCreateInput("", 247, 69, 242, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_AppPath_sscChange")
Global $Button_AppPath_ssc = GUICtrlCreateButton("···", 493, 70, 19, 19, $BS_NOTIFY)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetOnEvent(-1, "Button_AppPath_sscClick")
Global $Button_ssCreatorClose = GUICtrlCreateButton("Close", 544, 40, 57, 25)
GUICtrlSetOnEvent(-1, "Form_ssCreatorClose")
Global $Group_Shortcuts = GUICtrlCreateGroup("Shortcuts?", 92, 6, 74, 58)
GUICtrlSetColor(-1, 0x0000FF)
Global $Radio_Shortcuts_Yes = GUICtrlCreateRadio("Yes", 111, 23, 48, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "Uses shortcuts")
GUICtrlSetOnEvent(-1, "Radio_Shortcuts_YesClick")
Global $Radio_Shortcuts_No = GUICtrlCreateRadio("No", 111, 41, 50, 17)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "Does NOT use shortcuts")
GUICtrlSetOnEvent(-1, "Radio_Shortcuts_NoClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetTip(-1, "Does your application or game use shortcuts?")
Global $Label_Installer_ssc = GUICtrlCreateLabel("Installer:", 193, 102, 43, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0x800080)
GUICtrlSetTip(-1, "The installer or setup programs for this app. Any silent switches detected will automatically added below.")
GUICtrlSetOnEvent(-1, "Label_Installer_sscClick")
Global $Combo_Installer_ssc = GUICtrlCreateInput("", 238, 99, 252, 21)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetOnEvent(-1, "Combo_Installer_sscChange")
Global $Button_Installer_ssc = GUICtrlCreateButton("···", 494, 100, 19, 19, $BS_NOTIFY)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetTip(-1, "Browse for the Install/Setup program(s) to use for this app")
GUICtrlSetOnEvent(-1, "Button_Installer_sscClick")
Global $Label_WorkingDir_ssc = GUICtrlCreateLabel("Working Folder:", 130, 132, 84, 17, $SS_RIGHT)
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetTip(-1, "shown in the ssWPI as the name of the option")
GUICtrlSetOnEvent(-1, "Label_WorkingDir_sscClick")
Global $Input_WorkingDir_ssc = GUICtrlCreateInput("", 215, 129, 275, 21, $GUI_SS_DEFAULT_INPUT)
GUICtrlSetOnEvent(-1, "Input_WorkingDir_sscChange")
Global $Button_WorkingDir_ssc = GUICtrlCreateButton("···", 494, 130, 19, 19, $BS_NOTIFY)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetTip(-1, "Browse for the Install/Setup program(s) to use for this app")
GUICtrlSetOnEvent(-1, "Button_WorkingDir_sscClick")
#endregion ### END Koda GUI section ###

#cs ##################################################################################
	# Okay to make changes from this point on...
	# Begin!
#ce ##################################################################################

If $AutoBuild Then ;Determine other parameters
	Switch StringLower(GetParameter('MakeExpressInstaller', '='))
		Case 'no', 'off', '0'
			$MakeExpressInstaller = False
		Case 'yes', 'on', '1'
			$MakeExpressInstaller = True
	EndSwitch
	Switch StringLower(GetParameter('BuildExpressInstaller', '='))
		Case 'no', 'off', '0'
			$MakeExpressInstaller = False
		Case 'yes', 'on', '1'
			$MakeExpressInstaller = True
	EndSwitch
	Switch StringLower(GetParameter('ExpressInstaller', '='))
		Case 'no', 'off', '0'
			$MakeExpressInstaller = False
		Case 'yes', 'on', '1'
			$MakeExpressInstaller = True
	EndSwitch

	Switch StringLower(GetParameter('ppCompress', '='))
		Case 'no', 'off', '0'
			$ppCompress = False
		Case 'yes', 'on', '1'
			$ppCompress = True
	EndSwitch

	Switch StringLower(GetParameter('PatchCompress', '='))
		Case 'no', 'off', '0'
			$PatchCompress = False
		Case 'yes', 'on', '1'
			$PatchCompress = True
	EndSwitch

	Switch StringLower(GetParameter('DeleteSource', '='))
		Case 'no', 'off', '0'
			$DeleteSource = False
		Case 'yes', 'on', '1'
			$DeleteSource = True
	EndSwitch

	Switch StringLower(GetParameter('VersionFromTitle', '='))
		Case 'no', 'off', '0'
			$GetVersionFromTitle = False
		Case 'yes', 'on', '1'
			$GetVersionFromTitle = True
	EndSwitch

	Switch StringLower(GetParameter('CalcMD5', '='))
		Case 'no', 'off', '0'
			$CalcMD5 = False
		Case 'yes', 'on', '1'
			$CalcMD5 = True
	EndSwitch

	Switch StringLower(GetParameter('UseLZMA2', '='))
		Case 'no', 'off', '0'
			$UseLZMA2 = False
		Case 'yes', 'on', '1'
			$UseLZMA2 = True
	EndSwitch

	Switch StringLower(GetParameter('UseRAR', '='))
		Case 'no', 'off', '0'
			$UseRAR = False
		Case 'yes', 'on', '1'
			$UseRAR = True
	EndSwitch

	$var = GetParameter('CompressionLevel', '=')
	If $var Then $ArchiveCompressionLevel = $var

	$var = GetParameter('7zProcessPriority', '=')
	If $var Then $7zProcessPriority = $var

	$var = GetParameter('UseOutputDir', '=')
	If $var Then
		$UseOutputDir = StringReplace($var, '"', '')
		$UseInputDir = ($UseOutputDir = '')
	EndIf
	$ExitBuild = False
EndIf
If $SaveAs Then $ExitBuild = False

MenuItem_UseDir()
GetReportingMode($ssEditorINI)
If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Initializing...' & @CRLF, True)
If GetParameter('Help') Or GetParameter('?') Or GetParameter('About') Then EndGame('Help requested', 'See displayed', True)

;Detail ssEditor form
GUICtrlSetCursor($Label_URL, 0) ; hand-hover
ControlSetText('', '', $Form_ssEditor, $ThisAppTitle)
GUICtrlSetState($TabSheet_General, $GUI_SHOW)
$HelpTopic = 'General'
CursorWait($hOrigCur)
If Not FileExists($TempPixDir & '\' & $ThisAppFilename & '.icl') Then
	$CurrentWorkingDir = @WorkingDir
	FileChangeDir(@ScriptDir)
	FileInstall('.\ssEditor.icl', $TempPixDir & '\' & $ThisAppFilename & '.icl')
	FileChangeDir($CurrentWorkingDir)
EndIf
_GUICtrlEdit_SetLimitText($Edit_Cmd, -1)
_GUICtrlEdit_SetLimitText($Edit_Reg, -1)
_GUICtrlEdit_SetLimitText($Edit_URLs, -1)
_GUICtrlEdit_SetLimitText($Edit_Description, -1)
_GUICtrlEdit_SetLimitText($Edit_Installers, -1)
_GUICtrlEdit_SetLimitText($Edit_CatalogList, -1)
_GUICtrlEdit_SetLimitText($Edit_scKeep, -1)
_GUICtrlEdit_SetLimitText($Edit_RegisterDLL, -1)
_GUICtrlEdit_SetLimitText($Edit_InstallFonts, -1)
_GUICtrlEdit_SetLimitText($Edit_FileAssoc, -1)

;1=Build ;2=open ;3=save ;4=save ;5=up ;6=down ;7=New ;8=Add ;9=Remove
;0=Build ;-2=open ;-3=save ;-4=up ;-5=down ;-6=New ;-7=Add ;-8=Remove ;-9=ViewVars
GUICtrlSetImage($Button_Build, $TempPixDir & '\' & $ThisAppFilename & '.icl', 1, 0)
GUICtrlSetImage($Button_Open, $TempPixDir & '\' & $ThisAppFilename & '.icl', 2, 0)
GUICtrlSetImage($Button_Save, $TempPixDir & '\' & $ThisAppFilename & '.icl', 3, 0)
GUICtrlSetImage($Button_scUp, $TempPixDir & '\' & $ThisAppFilename & '.icl', 4, 0)
GUICtrlSetImage($Button_scDown, $TempPixDir & '\' & $ThisAppFilename & '.icl', 5, 0)
GUICtrlSetImage($Button_New, $TempPixDir & '\' & $ThisAppFilename & '.icl', 6, 0)
GUICtrlSetImage($Button_scNew, $TempPixDir & '\' & $ThisAppFilename & '.icl', 6, 0)
GUICtrlSetImage($Button_scNameAdd, $TempPixDir & '\' & $ThisAppFilename & '.icl', 7, 0)
GUICtrlSetImage($Button_scNameRemove, $TempPixDir & '\' & $ThisAppFilename & '.icl', 8, 0)
GUICtrlSetImage($Button_Vars, $TempPixDir & '\' & $ThisAppFilename & '.icl', 9, 0)
GUICtrlSetImage($Button_HelpContents, $TempPixDir & '\' & $ThisAppFilename & '.icl', 10, 0)
GUICtrlSetImage($Button_ViewSource, $TempPixDir & '\' & $ThisAppFilename & '.icl', 12, 0)
GUICtrlSetImage($Button_ViewWorkDir, $TempPixDir & '\' & $ThisAppFilename & '.icl', 18, 0)
GUICtrlSetImage($Button_SetupSTest, $TempPixDir & '\' & $ThisAppFilename & '.icl', 14, 0)
GUICtrlSetImage($Button_ExtactIcons, $TempPixDir & '\' & $ThisAppFilename & '.icl', 15, 0)
GUICtrlSetImage($Button_ScreenCapture, $TempPixDir & '\' & $ThisAppFilename & '.icl', 16, 0)
GUICtrlSetImage($Button_GrabClipboardPic, $TempPixDir & '\' & $ThisAppFilename & '.icl', 17, 0)

;Detail the About box
ControlSetText('', '', $Form_About, 'About: ')
GUICtrlSetData($About_Version, 'Version ' & $ThisAppVersion)
GUICtrlSetData($About_Copyright, '© 2024, Vergitek Solutions')
GUICtrlSetData($About_URL, 'ssTek Forum')
GUICtrlSetData($About_URL2, 'LastOS Forum')
GUICtrlSetData($About_URL3, '#WebSite3#')
Local $aForm_About = ControlGetPos('', '', $Form_About)
Global $Form_About_Left = $aForm_About[0], $Form_About_Top = $aForm_About[1], $Form_About_Width = $aForm_About[2], $Form_About_Height = $aForm_About[3]
Local $aAbout_Logo = ControlGetPos($Form_About, '', $About_Logo)
Global $About_Logo_Left = $aAbout_Logo[0], $About_Logo_Top = $aAbout_Logo[1], $About_Logo_Width = $aAbout_Logo[2], $About_Logo_Height = $aAbout_Logo[3]
ResizeMe($Form_About, $About_URL, 8, 800, 4, 'MS Sans Serif')
CenterMe($Form_About, $About_URL, $Form_About_Width, $About_Logo_Left + $About_Logo_Width)
ResizeMe($Form_About, $About_URL2, 8, 800, 4, 'MS Sans Serif')
CenterMe($Form_About, $About_URL2, $Form_About_Width, $About_Logo_Left + $About_Logo_Width)
ResizeMe($Form_About, $About_URL3, 8, 800, 4, 'MS Sans Serif')
CenterMe($Form_About, $About_URL3, $Form_About_Width, $About_Logo_Left + $About_Logo_Width)
GUICtrlSetCursor($About_URL, 0) ; hand-hover
GUICtrlSetCursor($About_URL2, 0) ; hand-hover
GUICtrlSetCursor($About_URL3, 0) ; hand-hover
ResizeMe($Form_About, $About_Version, 10, 800, 0, 'MS Sans Serif')
CenterMe($Form_About, $About_Version, $Form_About_Width, $About_Logo_Left + $About_Logo_Width)
ResizeMe($Form_About, $About_CoreVer, 8, 800, 0, 'MS Sans Serif')
CenterMe($Form_About, $About_CoreVer, $About_Logo_Left * 2 + $About_Logo_Width, $About_Logo_Left)
GUICtrlSetCursor($About_CoreVer, 0) ; hand-hover
ResizeMe($Form_About, $About_Copyright, 10, 400, 0, 'MS Sans Serif')
CenterMe($Form_About, $About_Copyright, $Form_About_Width, $About_Logo_Left + $About_Logo_Width)
ResizeMe($Form_About, $About_Comment, 8, 800, 0, 'MS Sans Serif')
CenterMe($Form_About, $About_Comment, $About_Logo_Left * 2 + $About_Logo_Width, $About_Logo_Left)
CenterMe($Form_About, $Button_Ok_About, $Form_About_Width, $About_Logo_Left + $About_Logo_Width)
If Not (FileExists($TempPixDir & '\' & $ThisAppFilename & '.jpg') Or $AutoBuild) Then
	$CurrentWorkingDir = @WorkingDir
	FileChangeDir(@ScriptDir)
	FileInstall('.\ssEditor.jpg', $TempPixDir & '\' & $ThisAppFilename & '.jpg')
	FileChangeDir($CurrentWorkingDir)
EndIf
GUICtrlSetImage($About_Logo, $TempPixDir & '\' & $ThisAppFilename & '.jpg')
GUICtrlSetState($About_Logo, $GUI_DISABLE)

;Create the Preview window
Global $GuiPreview ;= GUICreate('Picture Viewer', @DesktopWidth - 30, @DesktopHeight - 30, -1, -1, -1, BitOR($WS_EX_APPWINDOW, $WS_EX_TOOLWINDOW), $Form_ssEditor)
;GUISetOnEvent($GUI_EVENT_CLOSE, 'Exit_GuiPreview', $GuiPreview)
;GUISetState(@SW_HIDE, $GuiPreview)

;Detail Menubar
Global $tInfo
If $UseLZMA2 Then
	GUICtrlSetState($MenuItem_UseLZMA2, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_UseLZMA2, $GUI_UNCHECKED)
EndIf
If $WINEVersion <> '' And VersionFormat($WINEVersion) < VersionFormat('1.7.5') Then GUICtrlSetState($MenuItem_ExtractICO, $GUI_DISABLE)
If FindMe('RAR.exe') = '' Then ; RAR not found
	$UseRAR = False
	NeoIniWrite($ssEditorINI, 'Options', 'Use RAR', $UseRAR)
	GUICtrlSetState($MenuItem_UseRAR, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_UseRAR, $GUI_DISABLE)
	GUICtrlSetState($MenuItem_UseRAR, $GUI_HIDE)
	GUICtrlSetState($MenuItem_UseLZMA2, $GUI_SHOW)
	GUICtrlSetState($MenuItem_UseLZMA2, $GUI_ENABLE)
Else
	GUICtrlSetState($MenuItem_UseRAR, $GUI_SHOW)
	GUICtrlSetState($MenuItem_UseRAR, $GUI_ENABLE)
	If $UseRAR Then
		GUICtrlSetState($MenuItem_UseRAR, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_UseLZMA2, $GUI_DISABLE)
		GUICtrlSetState($MenuItem_UseLZMA2, $GUI_HIDE)
	Else
		GUICtrlSetState($MenuItem_UseRAR, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_UseLZMA2, $GUI_SHOW)
		GUICtrlSetState($MenuItem_UseLZMA2, $GUI_ENABLE)
	EndIf
EndIf
If $MakeExpressInstaller Then
	GUICtrlSetState($MenuItem_Options_ExpressInstaller, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_Options_WebfriendlyFilenames, $GUI_ENABLE)
Else
	GUICtrlSetState($MenuItem_Options_ExpressInstaller, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_Options_WebfriendlyFilenames, $GUI_DISABLE)
EndIf
If _GUICtrlComboBox_GetComboBoxInfo($Combo_scName, $tInfo) Then $Combo_scName_hEdit = DllStructGetData($tInfo, 'hEdit')

If $WebfriendlyFilenames Then
	GUICtrlSetState($MenuItem_Options_WebfriendlyFilenames, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_Options_WebfriendlyFilenames, $GUI_UNCHECKED)
EndIf

If $StartMenuTargetSearch Then
	GUICtrlSetState($MenuItem_Options_scTargetSearch, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_Options_scTargetSearch, $GUI_UNCHECKED)
EndIf

Switch $SaveFormat
	Case 0 ;Legacy
		GUICtrlSetState($MenuItem_Options_SaveLegacyFormat, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDualFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveINIFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveUpdateOnly, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDefault, $GUI_UNCHECKED)
	Case 1 ;Dual
		GUICtrlSetState($MenuItem_Options_SaveLegacyFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDualFormat, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_Options_SaveINIFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveUpdateOnly, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDefault, $GUI_UNCHECKED)
	Case 2 ;INI
		GUICtrlSetState($MenuItem_Options_SaveLegacyFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDualFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveINIFormat, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_Options_SaveUpdateOnly, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDefault, $GUI_UNCHECKED)
	Case 4 ;UpdateOnly
		GUICtrlSetState($MenuItem_Options_SaveLegacyFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDualFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveINIFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveUpdateOnly, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDefault, $GUI_UNCHECKED)
	Case Else ;3 (Default)
		GUICtrlSetState($MenuItem_Options_SaveLegacyFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDualFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveINIFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveUpdateOnly, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDefault, $GUI_CHECKED)
EndSwitch

If $SaveFormatsTest Then
	GUICtrlSetState($MenuItem_Options_SaveFormat, $GUI_ENABLE)
Else
	GUICtrlSetState($MenuItem_Options_SaveFormat, $GUI_DISABLE)
EndIf

If $ppCompress Then
	GUICtrlSetState($MenuItem_ppCompress, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_ppCompress, $GUI_UNCHECKED)
EndIf

If $PatchCompress Then
	GUICtrlSetState($MenuItem_PatchCompress, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_PatchCompress, $GUI_UNCHECKED)
EndIf

If $DeleteSource Then
	GUICtrlSetState($MenuItem_DeleteSource, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_DeleteSource, $GUI_UNCHECKED)
EndIf

If $GetVersionFromTitle Then
	GUICtrlSetState($MenuItem_Options_GetVersionFromTitle, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_Options_GetVersionFromTitle, $GUI_UNCHECKED)
EndIf

If $ActivateSendtoAutobuild Then
	GUICtrlSetState($MenuItem_Options_ActivateSendtoAutobuild, $GUI_CHECKED)
;~ 	FileCreateShortcut(@ScriptDir & '\' & $ThisAppFilename & '.exe', $SendToPath & '\ssEditor(Autobuild).lnk', '', '-autobuild')
	If FileExists($SendToPath & '\ssEditor(Autobuild).lnk') Then FileDelete($SendToPath & '\ssEditor(Autobuild).lnk')
	If Not FileExists($SendToPath & '\ssEditor(Autobuild Archive).lnk') Then FileCreateShortcut(@ScriptDir & '\' & $ThisAppFilename & '.exe', $SendToPath & '\ssEditor(Autobuild Archive).lnk', '', '-autobuild -MakeExpressInstaller=on', 'Builds archive deployment package(s)')
	If Not FileExists($SendToPath & '\ssEditor(Autobuild Folder).lnk') Then FileCreateShortcut(@ScriptDir & '\' & $ThisAppFilename & '.exe', $SendToPath & '\ssEditor(Autobuild Folder).lnk', '', '-autobuild -MakeExpressInstaller=off', 'Builds folder deployment package(s)')
Else
	GUICtrlSetState($MenuItem_Options_ActivateSendtoAutobuild, $GUI_UNCHECKED)
	If FileExists($SendToPath & '\ssEditor(Autobuild).lnk') Then FileDelete($SendToPath & '\ssEditor(Autobuild).lnk')
	If FileExists($SendToPath & '\ssEditor(Autobuild Archive).lnk') Then FileDelete($SendToPath & '\ssEditor(Autobuild Archive).lnk')
	If FileExists($SendToPath & '\ssEditor(Autobuild Folder).lnk') Then FileDelete($SendToPath & '\ssEditor(Autobuild Folder).lnk')
EndIf

If $ExitBuild Then
	GUICtrlSetState($MenuItem_ExitBuild, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_ExitBuild, $GUI_UNCHECKED)
EndIf

If $CalcMD5 Then
	GUICtrlSetState($MenuItem_CalcMD5, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_CalcMD5, $GUI_UNCHECKED)
EndIf

If $CalcExtractedSize Then
	GUICtrlSetState($MenuItem_CalcExtractedSize, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_CalcExtractedSize, $GUI_UNCHECKED)
EndIf

If $Debug Then
	GUICtrlSetState($MenuItem_LogDebugging, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_LogDebugging, $GUI_UNCHECKED)
EndIf

If $Log Then
	GUICtrlSetState($MenuItem_LogReporting, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_LogReporting, $GUI_UNCHECKED)
EndIf

If $UseFilenameTags Then
	GUICtrlSetState($MenuItem_BuildsUseFilenameTags, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_BuildsUseFilenameTags, $GUI_UNCHECKED)
EndIf

If $PublisherTag Then
	GUICtrlSetState($MenuItem_FilenameTagPublisher, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_FilenameTagPublisher, $GUI_UNCHECKED)
EndIf
If $TitleTag Then
	GUICtrlSetState($MenuItem_FilenameTagTitle, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_FilenameTagTitle, $GUI_UNCHECKED)
EndIf
If $VersionTag Then
	GUICtrlSetState($MenuItem_FilenameTagVersion, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_FilenameTagVersion, $GUI_UNCHECKED)
EndIf
If $LanguageTag Then
	GUICtrlSetState($MenuItem_FilenameTagLanguage, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_FilenameTagLanguage, $GUI_UNCHECKED)
EndIf
If $OSTag Then
	GUICtrlSetState($MenuItem_FilenameTagOS, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_FilenameTagOS, $GUI_UNCHECKED)
EndIf
If $ArchitectureTag Then
	GUICtrlSetState($MenuItem_FilenameTagArchitecture, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_FilenameTagArchitecture, $GUI_UNCHECKED)
EndIf
If $CategoryTag Then
	GUICtrlSetState($MenuItem_FilenameTagCategory, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_FilenameTagCategory, $GUI_UNCHECKED)
EndIf
If $AdditionalTag Then
	GUICtrlSetState($MenuItem_FilenameTagAdditional, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_FilenameTagAdditional, $GUI_UNCHECKED)
EndIf
If $LicenseTag Then
	GUICtrlSetState($MenuItem_FilenameTagLicense, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_FilenameTagLicense, $GUI_UNCHECKED)
EndIf
If $BuildTypeTag Then
	GUICtrlSetState($MenuItem_FilenameTagBuildType, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_FilenameTagBuildType, $GUI_UNCHECKED)
EndIf
If $ReleaserTag Then
	GUICtrlSetState($MenuItem_FilenameTagReleaser, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_FilenameTagReleaser, $GUI_UNCHECKED)
EndIf
If $RequiredRuntimesTag Then
	GUICtrlSetState($MenuItem_FilenameTagRequiredRuntimes, $GUI_CHECKED)
Else
	GUICtrlSetState($MenuItem_FilenameTagRequiredRuntimes, $GUI_UNCHECKED)
EndIf

GUICtrlSetState($MenuItem_16x16ico, $GUI_UNCHECKED)
GUICtrlSetState($MenuItem_24x24ico, $GUI_UNCHECKED)
GUICtrlSetState($MenuItem_32x32ico, $GUI_UNCHECKED)
GUICtrlSetState($MenuItem_48x48ico, $GUI_UNCHECKED)
GUICtrlSetState($MenuItem_96x96ico, $GUI_UNCHECKED)
GUICtrlSetState($MenuItem_128x128ico, $GUI_UNCHECKED)
GUICtrlSetState($MenuItem_256x256ico, $GUI_UNCHECKED)
Switch $PreviewIconSize
	Case 16
		GUICtrlSetState($MenuItem_16x16ico, $GUI_CHECKED)
	Case 24
		GUICtrlSetState($MenuItem_24x24ico, $GUI_CHECKED)
	Case 32
		GUICtrlSetState($MenuItem_32x32ico, $GUI_CHECKED)
	Case 48
		GUICtrlSetState($MenuItem_48x48ico, $GUI_CHECKED)
	Case 96
		GUICtrlSetState($MenuItem_96x96ico, $GUI_CHECKED)
	Case 128
		GUICtrlSetState($MenuItem_128x128ico, $GUI_CHECKED)
	Case 256
		GUICtrlSetState($MenuItem_256x256ico, $GUI_CHECKED)
EndSwitch

GUICtrlSetState($MenuItem_800x600jpg, $GUI_UNCHECKED)
GUICtrlSetState($MenuItem_640x480jpg, $GUI_UNCHECKED)
Switch $JpgSize
	Case 0
		GUICtrlSetState($MenuItem_FullResJPG, $GUI_CHECKED)
	Case 800
		GUICtrlSetState($MenuItem_800x600jpg, $GUI_CHECKED)
	Case 640
		GUICtrlSetState($MenuItem_640x480jpg, $GUI_CHECKED)
EndSwitch

Switch $7zProcessPriority
	Case 1
		GUICtrlSetState($MenuItem_7zProcessPriority0, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority1, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority2, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority3, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority4, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority5, $GUI_UNCHECKED)
	Case 2
		GUICtrlSetState($MenuItem_7zProcessPriority0, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority1, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority2, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority3, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority4, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority5, $GUI_UNCHECKED)
	Case 3
		GUICtrlSetState($MenuItem_7zProcessPriority0, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority1, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority2, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority3, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority4, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority5, $GUI_UNCHECKED)
	Case 4
		GUICtrlSetState($MenuItem_7zProcessPriority0, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority1, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority2, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority3, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority4, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority5, $GUI_UNCHECKED)
	Case 5
		GUICtrlSetState($MenuItem_7zProcessPriority0, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority1, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority2, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority3, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority4, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority5, $GUI_CHECKED)
	Case Else ;0
		GUICtrlSetState($MenuItem_7zProcessPriority0, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority1, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority2, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority3, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority4, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_7zProcessPriority5, $GUI_UNCHECKED)
EndSwitch

Switch $ArchiveCompressionLevel
	Case 0
		GUICtrlSetState($MenuItem_Options_CompressionLevel_None, $GUI_CHECKED) ;0
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Fastest, $GUI_UNCHECKED) ;1
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Fast, $GUI_UNCHECKED) ;3
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Max, $GUI_UNCHECKED) ;7
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Ultra, $GUI_UNCHECKED) ;9
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Default, $GUI_UNCHECKED) ;5
	Case 1
		GUICtrlSetState($MenuItem_Options_CompressionLevel_None, $GUI_UNCHECKED) ;0
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Fastest, $GUI_CHECKED) ;1
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Fast, $GUI_UNCHECKED) ;3
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Max, $GUI_UNCHECKED) ;7
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Ultra, $GUI_UNCHECKED) ;9
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Default, $GUI_UNCHECKED) ;5
	Case 3
		GUICtrlSetState($MenuItem_Options_CompressionLevel_None, $GUI_UNCHECKED) ;0
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Fastest, $GUI_UNCHECKED) ;1
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Fast, $GUI_CHECKED) ;3
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Max, $GUI_UNCHECKED) ;7
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Ultra, $GUI_UNCHECKED) ;9
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Default, $GUI_UNCHECKED) ;5
	Case 7
		GUICtrlSetState($MenuItem_Options_CompressionLevel_None, $GUI_UNCHECKED) ;0
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Fastest, $GUI_UNCHECKED) ;1
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Fast, $GUI_UNCHECKED) ;3
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Max, $GUI_CHECKED) ;7
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Ultra, $GUI_UNCHECKED) ;9
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Default, $GUI_UNCHECKED) ;5
	Case 9
		GUICtrlSetState($MenuItem_Options_CompressionLevel_None, $GUI_UNCHECKED) ;0
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Fastest, $GUI_UNCHECKED) ;1
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Fast, $GUI_UNCHECKED) ;3
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Max, $GUI_UNCHECKED) ;7
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Ultra, $GUI_CHECKED) ;9
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Default, $GUI_UNCHECKED) ;5
	Case Else ;5
		GUICtrlSetState($MenuItem_Options_CompressionLevel_None, $GUI_UNCHECKED) ;0
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Fastest, $GUI_UNCHECKED) ;1
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Fast, $GUI_UNCHECKED) ;3
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Max, $GUI_UNCHECKED) ;7
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Ultra, $GUI_UNCHECKED) ;9
		GUICtrlSetState($MenuItem_Options_CompressionLevel_Default, $GUI_CHECKED) ;5
EndSwitch

Switch $SortTags
	Case 'Alphabetical'
		MenuItem_OptionsTagSortingAlphaClick()
	Case Else
		MenuItem_OptionsTagSortingGroupsClick()
EndSwitch

;------------------------------------------------------ Begin ----------------------------------------------------------
GetppDrives()
If $ToolsPath = '' Then GetToolsFolder() ;$ToolsPath ;EnvGet('Path')
GetMenuStyle()
PopulateCombo_Category()
PopulateCombo_Tags()
PopulateCombo_Catalog()
If $AutoBuild Or $SaveAs Then ; Get the Source Path(s)
	If Not GetSrcPath($SrcPath) Then
		$ScanDirs = $SrcPath
		ScanForExpressInstall($ScanDirs, True)
	EndIf
	If $ExpressInstall[0] = 0 Then ; only one to process: $SrcPath
		$ExpressInstall[0] += 1
		ReDim $ExpressInstall[$ExpressInstall[0] + 1]
		$ExpressInstall[$ExpressInstall[0]] = NoBackslash($SrcPath)
	EndIf
	If $ExpressInstall[0] > 0 Then _ArraySort($ExpressInstall, 0, 1)
	For $xi = 1 To $ExpressInstall[0]
		$SrcPath = $ExpressInstall[$xi]
		ControlSetText('', '', $StatusBar_ssEditor, 'Reading file. Please wait...')
		If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Reading file.' & @CRLF)
		If $AutoBuild Then
			_AppReset()
			$App_File = _AppRead($SrcPath, True, False)
		EndIf
		If $App_File <> '' Or $SaveAs Then
			$INIname = GetFilename($App_File)
			$SplashTemp = $App_Title
			If $App_Version <> '' And $App_Type < 5 Then $SplashTemp = $SplashTemp & ' ' & $App_Version
			If $App_Architecture > 0 Then
				Switch $App_Architecture
					Case 1 ; 'x86'
						$SplashTemp = $SplashTemp & ' (x86)'
					Case 2 ; 'x64'
						$SplashTemp = $SplashTemp & ' (x64)'
					Case 3 ; 'DualArch'
						$SplashTemp = $SplashTemp & ' (DualArch)'
				EndSwitch
			EndIf
			$NewForm = True
			MenuItem_OpenClick($SrcPath)
			Select
				Case $AutoBuild And IsBuildable()
					SplashThis('Building', GetFilename($SrcPath))
					MenuItem_BuildClick()
				Case $SaveAs
					SplashThis('Saving', GetFilename($SrcPath))
					MenuItem_SaveClick()
			EndSelect
			Cleanup() ; temp files, folders, etc.
			$AppInstallCount += 1
		ElseIf $ExpressInstall[0] = 1 And $ScanDepth = 1 Then
			EndGame('(126) SetupS was not able to install:', '"' & $SrcPath & '" is not a recognized SetupS file or folder.', True, 20, False)
		EndIf
	Next
	Form_ssEditorClose()
Else
	If GetSrcPath($SrcPath) Then
		If $SrcPath = @ScriptDir Then
			MenuItem_OpenClick($TemplatesFolder)
		Else
			MenuItem_OpenClick($SrcPath)
		EndIf
	Else
		If $SrcPath = @ScriptDir Then
			MenuItem_OpenClick($TemplatesFolder)
		Else
			MenuItem_NewClick($SrcPath)
		EndIf
	EndIf
	GUIRegisterMsg($WM_COMMAND, "MY_WM_COMMAND")
	GUISetState(@SW_SHOW, $Form_ssEditor)
	BuildOptToggle()
	Do
		Sleep(100)
	Until 0 ; Loop until user exits
EndIf

#region ;########################################## Form Controls ###############################################################
Func Add_Installer($var, $Init = '')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Add_Installer(): $var = ' & $var & @CRLF)
	If $var <> '' Then
		$Installer_Selected += 1
		ReDim $Installers[$Installer_Selected + 1][6]
		Local $Installer_Drive, $Installer_Dir, $Installer_FileName, $Installer_Ext, $Test = ''
		Local $Array = _PathSplit($var, $Installer_Drive, $Installer_Dir, $Installer_FileName, $Installer_Ext) ;0 = original path, 1 = drive, 2 = directory, 3 = filename, 4 = extension
		For $i = 0 To 4
			$Installers[$Installer_Selected][$i] = $Array[$i]
		Next
		If $Init <> '' And $Installer_Drive & $Installer_Dir <> $Init Then $Test = StringReplace($Installer_Drive & $Installer_Dir, $Init, '.')
		GUICtrlSetData($Combo_Installer, $Test & $Installer_FileName & $Installer_Ext)
		$Installers[$Installer_Selected][5] = StringReplace(_ASSF($Array[0]), $Installer_FileName & $Installer_Ext, $Test & $Installer_FileName & $Installer_Ext) ;
		GUICtrlSetData($Input_Switches, StringStripWS(StringReplace(StringStripWS(StringReplace($Installers[$Installer_Selected][5], '"' & $Test & $Installer_FileName & $Installer_Ext & '"', ''), 3), $Installer_FileName & $Installer_Ext, ''), 3))
		GUICtrlSetData($Input_SwitchNotes, $ASSF_Type & '. ' & $ASSF_Notes)
		GUICtrlSetState($Button_Add_Installer, $GUI_ENABLE)
	EndIf
EndFunc

Func BuildOptToggle()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|BuildOptToggle()' & @CRLF)
	Local $n = ''
	Switch $App_Type
		Case 1, 2
			$n = 'ssApp'
		Case 3, 4
			$n = 'ppApp'
		Case 5
			$n = 'ppGame'
	EndSwitch
	If $MakeExpressInstaller Then
		GUICtrlSetTip($Button_Build, 'Build an ' & $n & ' archive deployment package {F5}')
		GUICtrlSetData($MenuItem_Build, 'Build an ' & $n & ' archive deployment package' & @TAB & 'F5')
	Else
		GUICtrlSetTip($Button_Build, 'Build a ' & $n & ' folder deployment package {F5}')
		GUICtrlSetData($MenuItem_Build, 'Build a ' & $n & ' folder deployment package' & @TAB & 'F5')
	EndIf
	If IsBuildable() Then
		GUICtrlSetState($Button_Build, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_Build, $GUI_ENABLE)
	Else
		GUICtrlSetState($Button_Build, $GUI_DISABLE)
		GUICtrlSetState($MenuItem_Build, $GUI_DISABLE)
	EndIf
EndFunc

Func Button_Add_InstallerClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_Add_InstallerClick()' & @CRLF)
	$Edit_Installers_Data = GUICtrlRead($Edit_Installers)
	If $Edit_Installers_Data <> '' Then $Edit_Installers_Data = $Edit_Installers_Data & @CRLF
	If $Installers[$Installer_Selected][5] = '' Then
		If $Installer_Change And (GUICtrlRead($Combo_Installer) <> '' Or GUICtrlRead($Input_Switches) <> '') Then
			$Installers[$Installer_Selected][5] = StringStripWS('"' & GUICtrlRead($Combo_Installer) & '" ' & GUICtrlRead($Input_Switches), 3)
		EndIf
	EndIf
	Local $Test = $Installers[$Installer_Selected][5] ;GUICtrlRead($Combo_Installer)
	$Edit_Installers_Data = $Edit_Installers_Data & $Installers[$Installer_Selected][5]
	GUICtrlSetData($Edit_Installers, $Edit_Installers_Data)
	GUICtrlSetData($Combo_Installer, '')
	GUICtrlSetData($Input_Switches, '')
	GUICtrlSetState($Button_Add_Installer, $GUI_DISABLE)
	ChangesMade()
	$Installer_Change = False
EndFunc

Func Button_AddCategoryClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_AddCategoryClick()' & @CRLF)
	Local $i, $Found = False, $n = GUICtrlRead($Combo_Category)
	If GUICtrlRead($Checkbox_Game) = $GUI_CHECKED And StringLeft($n, StringLen('Games\')) <> 'Games\' Then $n = 'Games\' & $n
	For $i = 1 To $App_Category[0]
		If $App_Category[$i] = $n Then
			$Found = True
			ExitLoop
		EndIf
	Next
	If Not $Found Then
		$App_Category[0] += 1
		ReDim $App_Category[$App_Category[0] + 1]
		$App_Category[$App_Category[0]] = $n
		PopulateInput_Categories()
		ChangesMade()
	EndIf
	PopulateCombo_Category()
	GUICtrlSetState($Button_AddCategory, $GUI_DISABLE)
EndFunc

Func Button_AddMenuCatalogClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_AddMenuCatalogClick()' & @CRLF)
	Local $i, $Found = False, $n = GUICtrlRead($Combo_Catalog)
	If GUICtrlRead($Checkbox_Game) = $GUI_CHECKED And StringLeft($n, StringLen('Game ')) <> 'Game ' Then $n = 'Game ' & $n
	If $n <> '' Then
		For $i = 1 To $App_Catalog[0]
			If $App_Catalog[$i] = $n Then
				$Found = True
				ExitLoop
			EndIf
		Next
		If Not $Found Then
			$App_Catalog[0] += 1
			ReDim $App_Catalog[$App_Catalog[0] + 1]
			$App_Catalog[$App_Catalog[0]] = $n
			PopulateEdit_CatalogList()
			ChangesMade()
		EndIf
	EndIf
	PopulateCombo_Catalog()
	If StringLeft($n, 5) = 'Game ' Then Radio_Build_ppGameClick()
	$Found = False
	For $i = 1 To $Categories[0][0]
		If $App_Type >= 5 Then
			If $Categories[$i][1] = $n Then $Found = True
		Else
			If Not StringInStr($n, ' ') Then
				If $Categories[$i][1] = $n Then $Found = True
			Else
				If $Categories[$i][1] = StringLeft($n, StringInStr($n, ' ') - 1) Then $Found = True
			EndIf
		EndIf
		If $Found Then
			GUICtrlSetData($Combo_Category, $Combo_Category_Data, $Categories[$i][0])
			ExitLoop
		EndIf
	Next
EndFunc

Func Button_AddTagClick($fnDebug = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_AddTagClick()' & @CRLF)
	Local $i, $Found = False, $n = GUICtrlRead($Combo_Tags)
	For $i = 1 To $App_Tags[0]
		If $App_Tags[$i] = StringLeft($n, StringInStr($n, ' (') - 1) Then
			$Found = True
			ExitLoop
		EndIf
	Next
	If Not $Found Then
		$App_Tags[0] += 1
		ReDim $App_Tags[$App_Tags[0] + 1]
		$App_Tags[$App_Tags[0]] = StringLeft($n, StringInStr($n, ' (') - 1)
		PopulateInput_Tags()
		ChangesMade()
	EndIf
	PopulateCombo_Tags()
	GUICtrlSetState($Button_AddTag, $GUI_DISABLE)
EndFunc
Func Button_AppPath_sscClick()
	Button_AppPathClick()
	GUICtrlSetData($Input_AppPath_ssc, GUICtrlRead($Input_AppPath))
EndFunc

Func Button_AppPathClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_AppPathClick()' & @CRLF)
	Local $i, $var = FileSelectFolder('Browse for Installer Path', '.', 7)
	If Not @error Then
		$var = StringReplace($var, '|', @CRLF)
		$App_InstallPath = $var
		Populate_AppPath()
	EndIf
EndFunc

Func Button_BrowseStartMenu_sscClick()
	Button_BrowseStartMenuClick()
	GUICtrlSetData($Input_DefaultMenu_ssc, GUICtrlRead($Input_DefaultMenu))
	GUICtrlSetData($Input_Title_ssc, GUICtrlRead($Input_Title))
	GUICtrlSetData($Input_AppPath_ssc, GUICtrlRead($Input_AppPath))
EndFunc

Func Button_BrowseStartMenuClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_BrowseStartMenuClick()' & @CRLF)
	Local $hOrigCur = CursorWait(), $App_InstallPathOriginal = $App_InstallPath
	SplashThis('Opening', 'Opening StartMenu. Please wait...')
	DirRemove($TempDir & '\Start Menu', 1)
	NeoDirCopy(@StartMenuCommonDir, $TempDir & '\Start Menu')
	NeoDirCopy(@StartMenuDir, $TempDir & '\Start Menu')
	SplashOff()
	CursorWait($hOrigCur)
	Local $i, $var = FileSelectFolder('Browse for Default StartMenu', $TempDir & '\Start Menu', 7)
	If Not @error Then
		NeoDirCopy($var, $TempDir & '\' & $scFolder)
		GetShortcutS($TempDir & '\' & $scFolder)
		If $App_scCount > 0 Then
			$App_InstallPath = GetAppPathViaFolder($TempDir & '\' & $scFolder)
;~ 			ConvertBackAllPathVars()
			If $App_InstallPath = '' Then $App_InstallPath = $App_InstallPathOriginal
			If $App_InstallPath <> '' Then Populate_AppPath()
			If $scSelected = 0 Then $scSelected = 1
			PopulateCombo_scName()
			Populate_scDefs()
		EndIf
		If $App_smSource = '' Then
			$App_smSource = GetFilename($var)
			Populate_DefaultMenu()
		EndIf
		If $App_Title = '' Then
			$App_Title = GetFilename($var)
			GUICtrlSetData($Input_Title, $App_Title)
		EndIf
		If $App_InstallPath = '' Then
			$App_InstallPath = GetAppPathComplete($App_InstallPath)
			Populate_AppPath()
		EndIf
	EndIf
EndFunc

Func Button_BuildClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_BuildClick()' & @CRLF)
	MenuItem_BuildClick()
EndFunc

Func Button_cmdClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_cmdClick()' & @CRLF)
	Local $temp = $SrcPath & '\' & GetAppTypeBase($App_Type) & '.cmd'
	If FileExists($temp) Then
		;Local $td1 = FileGetTime($temp, 0, 1)
		ShellExecuteWait($temp, '', '.', 'edit')
		Local $td2 = FileGetTime($temp, 0, 1)
		If $td2 <> $tdCmd Then
			$App_CmdFile = File2String($temp)
			$Edit_Cmd_Data = $App_CmdFile
			GUICtrlSetData($Edit_Cmd, $Edit_Cmd_Data)
			$App_Changed = True
			$tdCmd = $td2
		EndIf
	EndIf
EndFunc

Func Button_FaderClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_FaderClick()' & @CRLF)
	Button_PicClick('.png')
EndFunc

Func Button_ForceFaderClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_ForceFaderClick()' & @CRLF)
	Local $i, $CurrentWorkingDir = @WorkingDir, $var = FileOpenDialog('Browse for Fader', '.', 'All Faders (*.png)', 1)
	If Not @error Then
		Switch $App_Type
			Case 1, 2
				NeoFileCopy($var, $CurrentWorkingDir & '\ssApp.png')
			Case 3, 4
				NeoFileCopy($var, $CurrentWorkingDir & '\ppApp.png')
			Case 5
				NeoFileCopy($var, $CurrentWorkingDir & '\ppGame.png')
		EndSwitch
		FileChangeDir($CurrentWorkingDir)
		Button_RefreshClick()
	EndIf
EndFunc

Func Button_ForceIconClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_ForceIconClick()' & @CRLF)
	Local $i, $CurrentWorkingDir = @WorkingDir, $var = FileOpenDialog('Browse for Icon', '.', 'All Icons (*.ico)', 1)
	If Not @error Then
		Switch $App_Type
			Case 1, 2
				NeoFileCopy($var, $CurrentWorkingDir & '\ssApp.ico')
			Case 3, 4
				NeoFileCopy($var, $CurrentWorkingDir & '\ppApp.ico')
			Case 5
				NeoFileCopy($var, $CurrentWorkingDir & '\ppGame.ico')
		EndSwitch
		FileChangeDir($CurrentWorkingDir)
		Button_RefreshClick()
	EndIf
EndFunc

Func Button_ForceScreenShotClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_ForceScreenShotClick()' & @CRLF)
	Local $i, $CurrentWorkingDir = @WorkingDir, $var = FileOpenDialog('Browse for Screenshot', '.', 'All Screenshots (*.jpg)', 1)
	If Not @error Then
		Switch $App_Type
			Case 1, 2
				NeoFileCopy($var, $CurrentWorkingDir & '\ssApp.jpg')
			Case 3, 4
				NeoFileCopy($var, $CurrentWorkingDir & '\ppApp.jpg')
			Case 5
				NeoFileCopy($var, $CurrentWorkingDir & '\ppGame.jpg')
		EndSwitch
		FileChangeDir($CurrentWorkingDir)
		Button_RefreshClick()
	EndIf
EndFunc

Func Button_GetppExtractedSizeClick()
	If ppArchiveCheck() Then
		Local $ppSub = @WorkingDir, $type, $InstallArc, $ppAuxSize = 0
		Switch $App_Type
			Case 1, 2
				$type = 'ssApp'
			Case 3, 4
				$type = 'ppApp'
			Case 5
				$type = 'ppGame'
		EndSwitch
		Select
			Case FileExists($ppSub & '\' & $type & '.7z')
				$InstallArc = '.7z'
			Case FileExists($ppSub & '\' & $type & '.zip')
				$InstallArc = '.zip'
			Case FileExists($ppSub & '\' & $type & '.rar')
				$InstallArc = '.rar'
			Case FileExists($ppSub & '\' & $type & '.cab')
				$InstallArc = '.cab'
		EndSelect
		Switch $App_Type
			Case 3, 4, 5 ;ppApp/ppGame
				$ppAuxSize += FileGetSize($ppSub & '\folder.gif')
				$ppAuxSize += FileGetSize($ppSub & '\folder.jpg')
				$ppAuxSize += FileGetSize($ppSub & '\' & $type & '.ico')
				$ppAuxSize += FileGetSize($ppSub & '\' & $type & '.mp4')
				$ppAuxSize += FileGetSize($ppSub & '\' & $type & '.jpg')
				$ppAuxSize += FileGetSize($ppSub & '\' & $type & '.png')
				$ppAuxSize += FileGetSize($ppSub & '\' & $type & '.cmd')
				$ppAuxSize += FileGetSize($ppSub & '\' & $type & '.reg')
				If $type = 'ppGame' Then
					$ppAuxSize += FileGetSize($ppSub & '\' & $type & '.ppg')
				Else
					$ppAuxSize += FileGetSize($ppSub & '\' & $type & '.app')
				EndIf
				$App_InstalledSize = GetppExtractedSizeInfo($ppSub & '\' & $type & $InstallArc)
				$type = 'patch'
				Select
					Case FileExists($ppSub & '\' & $type & '.7z')
						$InstallArc = '.7z'
					Case FileExists($ppSub & '\' & $type & '.zip')
						$InstallArc = '.zip'
					Case FileExists($ppSub & '\' & $type & '.rar')
						$InstallArc = '.rar'
					Case FileExists($ppSub & '\' & $type & '.cab')
						$InstallArc = '.cab'
				EndSelect
				$App_InstalledSize += GetppExtractedSizeInfo($ppSub & '\' & $type & $InstallArc) + $ppAuxSize
				GUICtrlSetData($Input_InstalledSize, FileSizeUnits($App_InstalledSize, 'to'))
		EndSwitch
	EndIf
EndFunc

Func Button_IconClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_IconClick()' & @CRLF)
	Button_PicClick('.ico')
EndFunc
Func Button_Installer_sscClick()
EndFunc

Func Button_InstallerClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_InstallerClick()' & @CRLF)
	Local $i = @WorkingDir, $j, $var = FileOpenDialog('Browse for Installer', $i, 'All Executables (*.exe;*.msi;*.cmd;*.bat)', 1)
	If Not @error Then
		Local $hOrigCur = CursorWait()
		$var = StringReplace($var, '|', @CRLF)
		If $i = GetFolderPath($var) Then $i = ''
		Add_Installer($var, $i)
		CursorWait($hOrigCur)
	EndIf
EndFunc

Func Button_PatchFolderClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_PatchFolderClick()' & @CRLF)
	Select
		Case FileExists($SrcPath & '\patch\')
			Run("explorer /n,/e, " & '"' & $SrcPath & '\patch\' & '"')
		Case FileExists($SrcPath & '\' & GetAppTypeBase($App_Type) & '\')
			Run("explorer /n,/e, " & '"' & $SrcPath & '\' & GetAppTypeBase($App_Type) & '\' & '"')
		Case FileExists($SrcPath & '\SetupS\')
			Run("explorer /n,/e, " & '"' & $SrcPath & '\SetupS\' & '"')
	EndSelect
EndFunc

Func Button_PicClick($ext)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_PicClick(): $ext = ' & $ext & @CRLF)
	If FileExists($SrcPath & '\' & GetAppTypeBase($App_Type) & $ext) Then
		PreviewPic($SrcPath & '\' & GetAppTypeBase($App_Type) & $ext)
	EndIf
EndFunc

Func Button_RefreshClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_RefreshClick()' & @CRLF)
	If $App_File = '' Then MenuItem_SaveClick()
	Populate_Main()
EndFunc

Func Button_RegClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_RegClick()' & @CRLF)
	Local $temp = $SrcPath & '\' & GetAppTypeBase($App_Type) & '.reg'
	If FileExists($temp) Then
		ShellExecuteWait($temp, '', '.', 'edit')
		Local $td2 = FileGetTime($temp, 0, 1)
		If $td2 <> $tdReg Then
			$App_RegFile = File2String($temp)
			$Edit_Reg_Data = $App_RegFile
			GUICtrlSetData($Edit_Reg, $Edit_Reg_Data)
			$App_Changed = True
			$tdReg = $td2
		EndIf
	EndIf
EndFunc

Func Button_scDownClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_scDownClick()' & @CRLF)
	If $scSelected < $App_scCount Then
		scSwap($scSelected, $scSelected + 1)
		$scSelected += 1
		PopulateCombo_scName()
		Populate_scDefs()
	EndIf
EndFunc

Func Button_scFileClick($PathIn = '')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_scFileClick(): $PathIn = ' & $PathIn & @CRLF)
	;open folder using $App_InstallPath
	Local $i = $App_InstallPath, $var, $FormModeTemp, $App_InstallPathOriginal = $App_InstallPath
	If $i = '' Then $i = '.'
	If $PathIn = '' Then
		$var = FileOpenDialog('Browse for target:', $i, 'Executables (*.exe;*.msi;*.cmd;*.bat)|Documents (*.doc;*.txt;*.pdf;*.chm;*.hlp;*.mht;*.lit)|Pictures (*.jpg;*.png;*.gif)|All (*.*)', 1)
	Else
		$var = $PathIn
	EndIf
	If Not @error Then
		$var = StringReplace($var, '|', @CRLF)
		Local $where = GetFolderPath($var)
		Local $what = GetFilename($var)
		Local $Found = False
		For $i = 1 To $App_scCount
			If ($App_scEXE[$i] = $what) Then
				$Found = True
				ExitLoop
			EndIf
		Next
		If Not $Found Then
			Local $hOrigCur = CursorWait(), $i = ''
			$App_scCount += 2
			ReDim $App_scEXE[$App_scCount]
			ReDim $App_scWorkDir[$App_scCount]
			ReDim $App_scLNK[$App_scCount]
			ReDim $App_scDesc[$App_scCount]
			ReDim $App_scArgs[$App_scCount]
			ReDim $App_scIcon[$App_scCount]
			ReDim $App_scExt[$App_scCount]
			ReDim $App_scIndex[$App_scCount]
			ReDim $App_scState[$App_scCount]
			ReDim $App_scDefaults[$App_scCount]
			ReDim $App_scFlags[$App_scCount]
			ReDim $App_scCatalog[$App_scCount]
			ReDim $App_scKey[$App_scCount]
			$App_scCount -= 1
		EndIf
		If $StartMenuTargetSearch Then
			SplashThis('Searching', 'Search StartMenu for a Shortcut to match selection. Please wait...')
			DirRemove($TempDir & '\Start Menu', 1)
			NeoDirCopy(@StartMenuCommonDir, $TempDir & '\Start Menu')
			NeoDirCopy(@StartMenuDir, $TempDir & '\Start Menu')
			$i = FindShortcutFromTarget($TempDir & '\Start Menu', GetFilename($var))
			SplashOff()
		EndIf
		If $i <> '' Then ; found it or a copy already in startmenu, so use that
			Local $Details = FileGetShortcutEx($i)
			If @error = 0 And IsArray($Details) Then
				Local $where = GetFilename(GetFolderPath($i))
				Local $what = GetFilename($i)
				If $App_Title = '' Then
					$App_Title = $where
					GUICtrlSetData($Input_Title, $App_Title)
				EndIf
				$App_InstallPath = ''
				GetAppPathFrom($i)
				If $App_smSource = '' Then $App_smSource = $where
				$App_scEXE[$App_scCount] = $Details[0] ;Shortcut target path
				$App_scWorkDir[$App_scCount] = $Details[1] ;Working directory
				$App_scLNK[$App_scCount] = StringLeft($what, StringInStr($what, '.lnk') - 1)
				$App_scArgs[$App_scCount] = $Details[2] ;Arguments
				$App_scDesc[$App_scCount] = $Details[3] ;Comment/Description
				$App_scIcon[$App_scCount] = $Details[4] ;Icon filename
				$App_scIndex[$App_scCount] = $Details[5] ;Icon index
				$App_scState[$App_scCount] = $Details[6] ;State
				$App_scKey[$App_scCount] = $Details[7] ;Hotkey
				$scSelected = $App_scCount
				DirRemove($TempDir & '\Start Menu', 1)
			EndIf
		Else
			$App_scEXE[$App_scCount] = $var ;Shortcut target path
			$App_InstallPath = GetAppPathComplete(GetFolderPath($App_scEXE[$App_scCount]))
			$App_scLNK[$App_scCount] = StringLeft(GetFilename($App_scEXE[$App_scCount]), StringLen(GetFilename($App_scEXE[$App_scCount])) - 4)
			$scSelected = $App_scCount
		EndIf
		If $App_InstallPath = '' Then $App_InstallPath = $App_InstallPathOriginal
		If $App_InstallPath <> '' Then
			$FormModeTemp = $FormMode
			$FormMode = False
			Populate_AppPath()
			$FormMode = $FormModeTemp
		EndIf
		If $App_Title = '' Then
			$App_Title = $App_scLNK[$scSelected]
			GUICtrlSetData($Input_Title, $App_Title)
		EndIf
		If $App_smSource = '' Then $App_smSource = $App_scLNK[$scSelected]
		If $App_smSource <> '' Then
			$FormModeTemp = $FormMode
			$FormMode = False
			Populate_DefaultMenu()
			$FormMode = $FormModeTemp
		EndIf
		If $App_InstallPath = '' Then
			$App_InstallPath = GetAppPathComplete($App_InstallPath)
			Populate_AppPath()
		EndIf
		PopulateCombo_scName()
		Combo_scNameChange()
		CursorWait($hOrigCur)
	EndIf
EndFunc

Func Button_scIconClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_scIconClick()' & @CRLF)
	Local $i = $App_InstallPath
	If $i = '' Then $i = '.'
	Local $var = FileOpenDialog('Browse for icon file:', $i, 'Icon files (*.exe;*.ico;*.dll)', 1)
	If Not @error Then
		$var = StringReplace($var, '|', @CRLF)
		Local $where = GetFolderPath($var)
		Local $what = GetFilename($var)
		$App_scIcon[$scSelected] = $var
		PopulateCombo_scName()
		Combo_scNameChange()
	EndIf
EndFunc

Func Button_scKeepClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_scKeepClick()' & @CRLF)
	Local $i, $Found
	For $i = 1 To $App_scKeep[0]
		If ($App_scKeep[$i] = $App_scLNK[$scSelected]) Then
			$Found = True
			ExitLoop
		EndIf
	Next
	If Not $Found Then
		$App_scKeep[0] += 1
		ReDim $App_scKeep[$App_scKeep[0] + 1]
		$App_scKeep[$App_scKeep[0]] = $App_scLNK[$scSelected]
		$Edit_scKeep_Data = ''
		For $i = 1 To $App_scKeep[0]
			If $Edit_scKeep_Data <> '' Then $Edit_scKeep_Data = $Edit_scKeep_Data & @CRLF
			$Edit_scKeep_Data = $Edit_scKeep_Data & $App_scKeep[$i]
		Next
		GUICtrlSetData($Edit_scKeep, $Edit_scKeep_Data)
	EndIf
	ChangesMade()
EndFunc

Func Button_scNameAddClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_scNameAddClick()' & @CRLF)
	;findout which combo/input changed
	If StringStripWS(GUICtrlRead($Combo_scName), 3) <> '' Then
		$App_scLNK[$scSelected] = StringFilterFilename(StringStripWS(GUICtrlRead($Combo_scName), 3), True, True)
		;$App_scCount
		$App_scEXE[$scSelected] = StringFilterFilename(StringStripWS(GUICtrlRead($Input_scTarget), 3), True, True)
		$App_scWorkDir[$scSelected] = StringFilterFilename(StringStripWS(GUICtrlRead($Input_scWorkDir), 3), True, True)
		$App_scIcon[$scSelected] = StringFilterFilename(StringStripWS(GUICtrlRead($Input_scIcon), 3), True, True)
		$App_scIndex[$scSelected] = StringStripWS(GUICtrlRead($Input_scIndex), 3)
		$App_scArgs[$scSelected] = StringStripWS(GUICtrlRead($Input_scArgs), 3)
		$App_scExt[$scSelected] = StringStripWS(GUICtrlRead($Input_scExt), 3)
		$App_scDesc[$scSelected] = StringStripWS(GUICtrlRead($Input_scDesc), 3)
		$App_scFlags[$scSelected] = StringStripWS(GUICtrlRead($Input_scFlags), 3)
		$App_scCatalog[$scSelected] = StringStripWS(GUICtrlRead($Input_scCatalog), 3)
		$App_scKey[$scSelected] = StringStripWS(GUICtrlRead($Input_scKey), 3)
	EndIf
	PopulateCombo_scName()
	Populate_scDefs()
	$App_scReset = True
	;ChangesMade()
EndFunc

Func Button_scNameBrowseClick($PathIn = '') ; compare to Button_scFileClick
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_scNameBrowseClick(): $PathIn = ' & $PathIn & @CRLF)
	Local $hOrigCur = CursorWait(), $i, $var, $Found, $FormModeTemp, $App_InstallPathOriginal = $App_InstallPath
	If $PathIn = '' Then
		SplashThis('Opening', 'Opening StartMenu. Please wait...')
		DirRemove($TempDir & '\Start Menu', 1)
		NeoDirCopy(@StartMenuCommonDir, $TempDir & '\Start Menu')
		NeoDirCopy(@StartMenuDir, $TempDir & '\Start Menu')
		SplashOff()
		CursorWait($hOrigCur)
		$var = FileOpenDialog('Browse StartMenu for:', $TempDir & '\Start Menu', 'Shortcuts (*.lnk)', 1)
	Else
		$var = $PathIn
	EndIf
	If Not @error Then
;~ 		$var = StringReplace($var, '|', @CRLF)
		Local $Details = FileGetShortcutEx($var)
		If @error = 0 And IsArray($Details) Then
			Local $where = GetFilename(GetFolderPath($var))
			Local $what = GetFilename($var)
			$Found = False
			For $i = 1 To $App_scCount
				If ($App_scLNK[$i] = $what) Then
					$Found = True
					ExitLoop
				EndIf
			Next
			$App_InstallPath = ''
			GetAppPathFrom($var)
			If StringInStr($where, 'Programs') Or StringInStr($where, 'Start Menu') Or StringInStr($where, 'Desktop') Then
				If $App_InstallPath <> '' Then
					$where = GetFilename($App_InstallPath)
				Else
					$where = StringReplace($what, '.lnk', '')
				EndIf
			EndIf
			If Not $Found Then
				$App_scCount += 2
				ReDim $App_scEXE[$App_scCount]
				ReDim $App_scWorkDir[$App_scCount]
				ReDim $App_scLNK[$App_scCount]
				ReDim $App_scDesc[$App_scCount]
				ReDim $App_scArgs[$App_scCount]
				ReDim $App_scIcon[$App_scCount]
				ReDim $App_scExt[$App_scCount]
				ReDim $App_scIndex[$App_scCount]
				ReDim $App_scState[$App_scCount]
				ReDim $App_scDefaults[$App_scCount]
				ReDim $App_scFlags[$App_scCount]
				ReDim $App_scCatalog[$App_scCount]
				ReDim $App_scKey[$App_scCount]
				$App_scCount -= 1
				$App_scEXE[$App_scCount] = $Details[0] ;Shortcut target path
;~ 			If $App_InstallPath <> '' Then
;~ 				If StringInStr($App_scEXE[$App_scCount], '\') > 0 And StringInStr($App_scEXE[$App_scCount], $App_InstallPath) = 1 Then
;~ 					$App_scEXE[$App_scCount] = StringMid($App_scEXE[$App_scCount], StringLen($App_InstallPath) + 2)
;~ 				EndIf
;~ 			EndIf
				$App_scWorkDir[$App_scCount] = $Details[1] ;Working directory
				$App_scLNK[$App_scCount] = StringLeft($what, StringInStr($what, '.lnk') - 1)
;~ 			If $App_smSource <> '' Then
;~ 				If StringInStr($App_scLNK[$App_scCount], '\') > 0 And StringInStr($App_scLNK[$App_scCount], $App_smSource) = 1 Then
;~ 					$App_scLNK[$App_scCount] = StringMid($App_scLNK[$App_scCount], StringLen($App_smSource) + 2)
;~ 				EndIf
;~ 			EndIf
				$App_scArgs[$App_scCount] = $Details[2] ;Arguments
				$App_scDesc[$App_scCount] = $Details[3] ;Description/Comment
				$App_scIcon[$App_scCount] = $Details[4] ;Icon filename
				$App_scIndex[$App_scCount] = $Details[5] ;Icon index
				$App_scState[$App_scCount] = $Details[6] ;State
				$App_scKey[$App_scCount] = $Details[7] ;Hotkey
				$scSelected = $App_scCount
;~ 			ConvertBackAllPathVars()
			EndIf
		EndIf
		If $App_InstallPath = '' Then $App_InstallPath = $App_InstallPathOriginal
		If $App_InstallPath <> '' Then
			$FormModeTemp = $FormMode
			$FormMode = False
			Populate_AppPath()
			$FormMode = $FormModeTemp
		EndIf
		If $App_scDesc[$App_scCount] And Not $App_Description Then
			$App_Description = StringSplit(StringReplace($App_scDesc[$App_scCount], @CRLF, @CR), @CR)
			$Edit_Description_Data = ''
			For $i = 1 To $App_Description[0]
				If $Edit_Description_Data <> '' Then $Edit_Description_Data = $Edit_Description_Data & @CRLF
				$Edit_Description_Data = $Edit_Description_Data & $App_Description[$i]
			Next
			GUICtrlSetData($Edit_Description, $Edit_Description_Data)
			GUICtrlSetTip($Edit_Description, '')
		EndIf
		PopulateCombo_scName()
		Combo_scNameChange()
		If $App_smSource = '' Then
			$App_smSource = GetApp_smSource($App_smSource)
;~ 				$App_smSource = GetFilename($App_scLNK[$App_scCount])
			Populate_DefaultMenu()
		EndIf
		If $App_Title = '' Then
			$App_Title = GetFilename($App_scLNK[$App_scCount])
			GUICtrlSetData($Input_Title, $App_Title)
		EndIf
		If $App_InstallPath = '' Then
			$App_InstallPath = GetAppPathComplete($App_InstallPath)
			Populate_AppPath()
		EndIf
	EndIf
EndFunc

Func Button_scNameRemoveClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_scNameRemoveClick()' & @CRLF)
	Local $i
	For $i = $scSelected To $App_scCount - 1
		$App_scEXE[$i] = $App_scEXE[$i + 1]
		$App_scWorkDir[$i] = $App_scWorkDir[$i + 1]
		$App_scLNK[$i] = $App_scLNK[$i + 1]
		$App_scDesc[$i] = $App_scDesc[$i + 1]
		$App_scArgs[$i] = $App_scArgs[$i + 1]
		$App_scIcon[$i] = $App_scIcon[$i + 1]
		$App_scExt[$i] = $App_scExt[$i + 1]
		$App_scIndex[$i] = $App_scIndex[$i + 1]
		$App_scState[$i] = $App_scState[$i + 1]
		$App_scDefaults[$i] = $App_scDefaults[$i + 1]
		$App_scFlags[$i] = $App_scFlags[$i + 1]
		$App_scCatalog[$i] = $App_scCatalog[$i + 1]
		$App_scKey[$i] = $App_scKey[$i + 1]
	Next
	If $App_scCount > 0 Then
		If $scSelected = $App_scCount Then $scSelected -= 1
		ReDim $App_scEXE[$App_scCount]
		ReDim $App_scWorkDir[$App_scCount]
		ReDim $App_scLNK[$App_scCount]
		ReDim $App_scDesc[$App_scCount]
		ReDim $App_scArgs[$App_scCount]
		ReDim $App_scIcon[$App_scCount]
		ReDim $App_scExt[$App_scCount]
		ReDim $App_scIndex[$App_scCount]
		ReDim $App_scState[$App_scCount]
		ReDim $App_scDefaults[$App_scCount]
		ReDim $App_scFlags[$App_scCount]
		ReDim $App_scCatalog[$App_scCount]
		ReDim $App_scKey[$App_scCount]
		$App_scCount -= 1
		If $App_scCount = 0 Then
			GUICtrlSetData($Combo_scName, '')
			GUICtrlSetData($Input_scTarget, '')
			GUICtrlSetData($Input_scWorkDir, '')
			GUICtrlSetData($Input_scArgs, '') ;
			GUICtrlSetData($Input_scExt, '') ;
			GUICtrlSetData($Input_scIcon, '') ;
			GUICtrlSetData($Input_scIndex, '') ;
			GUICtrlSetData($Input_scDesc, '') ;
			GUICtrlSetData($Label_scCount, 'Item' & _StringRepeat(' ', 3 - StringLen($scSelected)) & $scSelected & ' of' & _StringRepeat(' ', 3 - StringLen($App_scCount)) & $App_scCount & ' shortcuts total')
			GUICtrlSetData($Input_scFlags, '') ;
			GUICtrlSetData($Input_scCatalog, '') ;
			GUICtrlSetData($Input_scKey, '') ;
		Else
			If $scSelected = 0 Then $scSelected = 1
			PopulateCombo_scName()
			Populate_scDefs()
		EndIf
	EndIf
	ChangesMade()
EndFunc

Func Button_scNewClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_scNewClick()' & @CRLF)
	$App_scCount += 2
	ReDim $App_scEXE[$App_scCount]
	ReDim $App_scWorkDir[$App_scCount]
	ReDim $App_scLNK[$App_scCount]
	ReDim $App_scDesc[$App_scCount]
	ReDim $App_scArgs[$App_scCount]
	ReDim $App_scIcon[$App_scCount]
	ReDim $App_scExt[$App_scCount]
	ReDim $App_scIndex[$App_scCount]
	ReDim $App_scState[$App_scCount]
	ReDim $App_scDefaults[$App_scCount]
	ReDim $App_scFlags[$App_scCount]
	ReDim $App_scCatalog[$App_scCount]
	ReDim $App_scKey[$App_scCount]
	$App_scCount -= 1
	$scSelected = $App_scCount
	PopulateCombo_scName()
	Populate_scDefs()
EndFunc

Func Button_ScrShotClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_ScrShotClick()' & @CRLF)
	Button_PicClick('.jpg')
EndFunc

Func Button_scUpClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_scUpClick()' & @CRLF)
	If $scSelected > 1 Then
		scSwap($scSelected, $scSelected - 1)
		$scSelected -= 1
		PopulateCombo_scName()
		Populate_scDefs()
		ChangesMade()
	EndIf
EndFunc
Func Button_WorkingDir_sscClick()
EndFunc

Func CaptureTAB()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|CaptureTAB()' & @CRLF)
	HotKeySet('{TAB}')
	HotKeySet('+{TAB}')
	Switch @HotKeyPressed
		Case '{TAB}'
			Send('{TAB}')
		Case '+{TAB}'
			Send('+{TAB}')
	EndSwitch
	ReadFormData()
	HotKeySet('{TAB}', 'CaptureTAB')
	HotKeySet('+{TAB}', 'CaptureTAB')
EndFunc

Func Census_scDefs()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Census_scDefs()' & @CRLF)
	$App_scEXE[$scSelected] = StringFilterFilename(StringStripWS(GUICtrlRead($Input_scTarget), 3), True, True)
	$App_scWorkDir[$scSelected] = StringFilterFilename(StringStripWS(GUICtrlRead($Input_scWorkDir), 3), True, True)
	$App_scArgs[$scSelected] = StringStripWS(GUICtrlRead($Input_scArgs), 3)
	$App_scExt[$scSelected] = StringStripWS(GUICtrlRead($Input_scExt), 3)
	$App_scIcon[$scSelected] = StringFilterFilename(StringStripWS(GUICtrlRead($Input_scIcon), 3), True, True)
	$App_scIndex[$scSelected] = StringStripWS(GUICtrlRead($Input_scIndex), 3)
	$App_scDesc[$scSelected] = StringStripWS(GUICtrlRead($Input_scDesc), 3)
	$App_scLNK[$scSelected] = StringFilterFilename(StringStripWS(GUICtrlRead($Combo_scName), 3), True, True)
	$App_scFlags[$scSelected] = StringStripWS(GUICtrlRead($Input_scFlags), 3)
	$App_scCatalog[$scSelected] = StringStripWS(GUICtrlRead($Input_scCatalog), 3)
	$App_scKey[$scSelected] = StringStripWS(GUICtrlRead($Input_scKey), 3)
EndFunc

Func Census_uiDefs()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Census_uiDefs()' & @CRLF)
	$App_Uninstall[$uiSelected][0] = StringStripWS(GUICtrlRead($Combo_uiKey), 3)
	$App_Uninstall[$uiSelected][1] = StringStripWS(GUICtrlRead($Input_uiDisplayName), 3)
	$App_Uninstall[$uiSelected][2] = StringStripWS(GUICtrlRead($Input_uiInstallLocation), 3)
	$App_Uninstall[$uiSelected][3] = StringStripWS(GUICtrlRead($Input_uiDisplayIcon), 3)
	$App_Uninstall[$uiSelected][4] = StringStripWS(GUICtrlRead($Input_uiUninstallString), 3)
	$App_Uninstall[$uiSelected][5] = StringStripWS(GUICtrlRead($Input_uiSwitches), 3)
	$App_Uninstall[$uiSelected][6] = StringStripWS(GUICtrlRead($Input_uiScript), 3)
EndFunc

Func ChangeFilenameScheme($ext, $PathIn = '', $Rename = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ChangeFilenameScheme(): $ext = ' & $ext & ' : $PathIn = ' & $PathIn & ' : $Rename = ' & $Rename & @CRLF)
	Local $i, $FileArray, $Found, $App_TypeFilename = GetAppTypeBase($App_Type) & $ext
	If Not FileExists($App_TypeFilename) Then
		If $PathIn = '' Then $PathIn = @WorkingDir
		Local $test1 = StringLower(StringReplace(GetFilename($PathIn), ' ', '') & $ext)
		Local $test2 = StringLower(StringReplace(GetFilename($App_InstallPath), ' ', '') & $ext)
		Local $test3 = StringLower('Screenshot' & $ext)
		Local $test4 = StringLower('Aardvark' & $ext)
		$FileArray = _FileListToArray($PathIn, '*' & $ext, 1) ; files only
		If @error = 0 Then
			$Found = False
			For $i = 1 To $FileArray[0]
				Switch StringLower(StringReplace($FileArray[$i], ' ', ''))
					Case $test1, $test2, $test3, $test4
						FileMove($PathIn & '\' & $FileArray[$i], $PathIn & '\' & $App_TypeFilename, 9)
						$Found = True
						ExitLoop
				EndSwitch
			Next
			If Not $Found Then
				If $Rename Then
					FileMove($PathIn & '\' & $FileArray[1], $PathIn & '\' & $App_TypeFilename, 9)
;~ 				Else
;~ 					FileCopy($PathIn & '\' & $FileArray[1], $PathIn & '\' & $App_TypeFilename, 9)
				EndIf
			EndIf
		EndIf
	EndIf
EndFunc

Func ChangesMade()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ChangesMade()' & @CRLF)
	If $FormMode Then ReadFormData()
	$App_Changed = True
;~ 	GUICtrlSetState($Button_Save, $GUI_ENABLE)
EndFunc

Func Checkbox_AlwaysHideClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_AlwaysHideClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_AlwaysShowClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_AlwaysShowClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_App_ssUninstallClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_App_ssUninstallClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_AssemblyNoWaitClick()
	ChangesMade()
EndFunc

Func Checkbox_AtSetupOnlyClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_AtSetupOnlyClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_ftAdditionalClick()
EndFunc

Func Checkbox_ftLanguageClick()
EndFunc

Func Checkbox_ftLicenseTypeClick()
EndFunc

Func Checkbox_ftPublisherClick()
EndFunc

Func Checkbox_ftReleaserClick()
EndFunc

Func Checkbox_ftTitleClick()
EndFunc

Func Checkbox_ftVersionClick()
EndFunc

Func Checkbox_GameClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_GameClick()' & @CRLF)
	If GUICtrlRead($Checkbox_Game) = $GUI_CHECKED Then
		GUICtrlSetData($Label_Version, 'Year')
	Else
		GUICtrlSetData($Label_Version, 'Version')
	EndIf ;$Combo_Category_Data
	PopulateCombo_Category()
	PopulateCombo_Tags()
	PopulateCombo_Catalog()
EndFunc

Func Checkbox_InstallInstantClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_InstallInstantClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_InstallT13Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_InstallT13Click()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_LivePEClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_LivePEClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_MakeNonethingClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_MakeNonethingClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_MetroFriendlyClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_NeverUpdateAppFileClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_NeverUpdateAppFileClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_NeverUpdateAppFileClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_NoMenuIconsClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_NoMenuIconsClick()' & @CRLF)
	ChangesMade()
EndFunc
Func Checkbox_OS_MetroClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_OS_MetroClick()' & @CRLF)
	Checkbox_OS_ReadData()
EndFunc
Func Checkbox_OS_NT5Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_OS_NT5Click()' & @CRLF)
	Checkbox_OS_ReadData()
EndFunc
Func Checkbox_OS_NT6Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_OS_NT6Click()' & @CRLF)
	Checkbox_OS_ReadData()
EndFunc

;<OS>
Func Checkbox_OS_ReadData()
	$App_OS = 0
	If GUICtrlRead($Checkbox_OS_NT5) = $GUI_CHECKED Then $App_OS += 1
	If GUICtrlRead($Checkbox_OS_NT6) = $GUI_CHECKED Then $App_OS += 2
	If GUICtrlRead($Checkbox_OS_Metro) = $GUI_CHECKED Then $App_OS += 4
	If GUICtrlRead($Checkbox_OS_Win10) = $GUI_CHECKED Then $App_OS += 8
	If $App_OS = 15 Then $App_OS = 0
	ChangesMade()
EndFunc
Func Checkbox_OS_Win10Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_OS_Win10Click()' & @CRLF)
	Checkbox_OS_ReadData()
EndFunc

Func Checkbox_RunAsx64Click() ; $App_Runx64
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_RunAsx64Click()' & @CRLF)
	$App_Runx64 = Not $App_Runx64
	If $App_Runx64 Then
		$App_Architecture = 2
		GUICtrlSetState($Radio_Arch_x64, $GUI_CHECKED)
	Else
		$App_Architecture = 0
		GUICtrlSetState($Radio_Arch_Any, $GUI_CHECKED)
	EndIf
EndFunc

Func Checkbox_scAllUsersClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scAllUsersClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_scAlwaysSortClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scAlwaysSortClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_scDesktopClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scDesktopClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_scKeepAllClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scKeepAllClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_scKeepInFolderClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scKeepInFolderClick()' & @CRLF)
	ChangesMade()
	smPreview()
EndFunc

Func Checkbox_scNeverSortClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scNeverSortClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_scProgramsClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scProgramsClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_scQLaunchClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scQLaunchClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_scRefreshExplorerClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scRefreshExplorerClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_scRootClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scRootClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_scSendToClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scSendToClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_scStartMenuClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scStartMenuClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_scStartmenuPinClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scStartmenuPinClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_scStartupClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scStartupClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Checkbox_scTaskbarPinClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scTaskbarPinClick()' & @CRLF)
	ChangesMade()
EndFunc

Func Combo_CatalogChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Combo_CatalogChange()' & @CRLF)
	GUICtrlSetState($Button_AddMenuCatalog, $GUI_ENABLE)
EndFunc

Func Combo_CategoryChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Combo_CategoryChange()' & @CRLF)
	GUICtrlSetState($Button_AddCategory, $GUI_ENABLE)
	;ChangesMade()
EndFunc
Func Combo_Installer_sscChange()
EndFunc

Func Combo_InstallerChange()
EndFunc

Func Combo_scNameChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Combo_scNameChange()' & @CRLF)
	;Dropbox selection changed
	Local $i, $n = GUICtrlRead($Combo_scName), $Found = False
	For $i = 1 To $App_scCount
		If ($App_scLNK[$i] = $n) Then
			$Found = True
			$scSelected = $i
			ExitLoop
		EndIf
	Next
	If $App_scCount > 0 Then
		If $scSelected = 0 Then $scSelected = 1
		Populate_scDefs()
	EndIf
	ChangesMade()
	Census_scDefs()
EndFunc

Func Combo_TagsChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Combo_TagsChange()' & @CRLF)
	GUICtrlSetState($Button_AddTag, $GUI_ENABLE)
	;ChangesMade()
EndFunc

Func Combo_uiKeyChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Combo_uiKeyChange()' & @CRLF)
	;Dropbox selection changed
	Local $i, $n = GUICtrlRead($Combo_uiKey), $Found = False
	;_ArrayDisplay($App_Uninstall, @ScriptLineNumber)
	For $i = 1 To $App_Uninstall[0][0]
		If ($App_Uninstall[$i][0] = $n) Then
			$Found = True
			$uiSelected = $i
			ExitLoop
		EndIf
	Next
	If Not $Found Then $uiSelected = 0
	If $App_Uninstall[0][0] > 0 Then
		If $uiSelected = 0 Then $uiSelected = 1
	EndIf
	Populate_uiDefs()
	ChangesMade()
	Census_uiDefs()
EndFunc

Func Edit_CatalogListChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Edit_CatalogListChange()' & @CRLF)
	If GUICtrlRead($Edit_CatalogList) <> '' Then
		$App_Catalog = StringSplit(StringReplace(GUICtrlRead($Edit_CatalogList), @CRLF, @CR), @CR)
	Else
		ReDim $App_Catalog[1]
		$App_Catalog[0] = 0
		$Edit_CatalogList_Data = ''
	EndIf
	PopulateCombo_Catalog()
	ChangesMade()
	smPreview()
EndFunc
Func Edit_CmdChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Edit_CmdChange()' & @CRLF)
	ChangesMade()
EndFunc

Func Edit_DescriptionChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Edit_DescriptionChange()' & @CRLF)
	ChangesMade()
EndFunc

Func Edit_FileAssocChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Edit_FileAssocChange()' & @CRLF)
	ChangesMade()
EndFunc

Func Edit_InstallersChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Edit_InstallersChange()' & @CRLF)
	ChangesMade()
EndFunc

Func Edit_InstallFontsChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Edit_InstallFontsChange()' & @CRLF)
	ChangesMade()
EndFunc

Func Edit_RegChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Edit_RegChange()' & @CRLF)
	ChangesMade()
EndFunc

Func Edit_RegisterDLLChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Edit_RegisterDLLChange()' & @CRLF)
	ChangesMade()
EndFunc

Func Edit_scKeepChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Edit_scKeepChange()' & @CRLF)
	ChangesMade()
EndFunc

Func Edit_URLsChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Edit_URLsChange()' & @CRLF)
	ChangesMade()
EndFunc

Func FileSizeUnits($filesize, $Convert)
	Local $denom = 0
	Switch $Convert
		Case 'from'
			Select
				Case StringInStr($filesize, 'Bytes')
					$denom = 0
				Case StringInStr($filesize, 'KB') Or StringInStr($filesize, 'KiloBytes')
					$denom = 1
				Case StringInStr($filesize, 'MB') Or StringInStr($filesize, 'MegaBytes')
					$denom = 2
				Case StringInStr($filesize, 'GB') Or StringInStr($filesize, 'GigaBytes')
					$denom = 3
				Case StringInStr($filesize, 'TB') Or StringInStr($filesize, 'TeraBytes')
					$denom = 4
				Case StringInStr($filesize, 'PB') Or StringInStr($filesize, 'PetaBytes')
					$denom = 5
				Case StringInStr($filesize, 'EB') Or StringInStr($filesize, 'ExaBytes')
					$denom = 6
				Case StringInStr($filesize, 'ZB') Or StringInStr($filesize, 'ZettaBytes')
					$denom = 7
				Case StringInStr($filesize, 'YB') Or StringInStr($filesize, 'YottaBytes')
					$denom = 8
			EndSelect
			$filesize = Int(Number($filesize) * 1024 ^ $denom + .5)
			Return $filesize
		Case 'to'
			If $filesize > 0 Then
				Local $Test = $filesize / 1024
				While $Test > 1
					$denom += 1
					$filesize = $Test
					$Test = $filesize / 1024
				WEnd
				$filesize = Int($filesize * 100 + .5) / 100
				Switch $denom
					Case 0 ;bytes
						Return $filesize & ' Bytes'
					Case 1 ;KB
						Return $filesize & ' KB'
					Case 2 ;MB
						Return $filesize & ' MB'
					Case 3 ;GB
						Return $filesize & ' GB'
					Case 4 ;TB
						Return $filesize & ' TB'
					Case 5 ;PB
						Return $filesize & ' PB'
					Case 6 ;EB
						Return $filesize & ' EB'
					Case 7 ;ZB
						Return $filesize & ' ZB'
					Case 8 ;YB
						Return $filesize & ' YB'
				EndSwitch
			Else
				Return $filesize
			EndIf
	EndSwitch
EndFunc

Func Form_MetaEditorClose()
	HotKeySet('{Esc}')
	FadeOutGUI($Form_MetaEditor, '0') ; in seconds
	$HelpTopic = $HelpTopic_old
EndFunc

Func Form_MetaEditorMaximize()
EndFunc

Func Form_MetaEditorMinimize()
EndFunc

Func Form_MetaEditorRestore()
EndFunc

Func Form_ssCreatorClose()
	FadeOutGUI($Form_ssCreator, '0') ; in seconds
	$HelpTopic = $HelpTopic_old
	GUISetState(@SW_SHOW, $Form_ssEditor)
EndFunc
Func Form_ssCreatorMaximize()
EndFunc
Func Form_ssCreatorMinimize()
EndFunc
Func Form_ssCreatorRestore()
EndFunc

Func Form_ssEditorClose()
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Exit/Close' & @CRLF)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Form_ssEditorClose()' & @CRLF)
	$ExitState = True
	If Not $DoNotSave Then
		If StringInStr(MenuItem_NewClick(), 'Cancel') Then
			$ExitState = False
			Return
		EndIf
	EndIf
	$App_RefreshExplorer = True
	Cleanup()
	If $ArchiveEditMode <> '' Then DirRemove($SrcPath, 1)
	$IODirReset = False
	If $ForcedOutputMode Then
		Select
			Case $ReadOnlyEditMode = ''
				MenuItem_UseInputDirClick()
			Case $ReadOnlyEditMode <> ''
				$UseOutputDir = $ReadOnlyEditMode
				$UseInputDir = ($UseOutputDir = '')
				MenuItem_UseDir() ;restore UseIn/OutputDir
				$ReadOnlyEditMode = ''
;~ 			Case $TargetEditMode = ''
;~ 				MenuItem_UseInputDirClick()
;~ 			Case $TargetEditMode <> ''
;~ 				$UseOutputDir=$TargetEditMode
;~ 				$UseInputDir = ($UseOutputDir = '')
;~ 				MenuItem_UseDir() ;restore UseIn/OutputDir
;~ 				$TargetEditMode=''
		EndSelect
	ElseIf $ForcedInputMode Then
		$UseOutputDir = IniRead($ssEditorINI, 'Options', 'Use Output Folder', '')
		$UseInputDir = ($UseOutputDir = '')
		MenuItem_UseDir() ;restore UseIn/OutputDir
	EndIf
	If $Help_PID Then ProcessClose($Help_PID)
	Exit
;~ 	EndGame('Done', $ThisAppTitle)
EndFunc

Func Form_ssEditorMaximize()
EndFunc
Func Form_ssEditorMinimize()
EndFunc
Func Form_ssEditorRestore()
EndFunc

Func GetppExtractedSizeInfo($what)
	If FileExists($what) Then
		Local $n, $7zList = $TempDir & '\' & FileGetShortName(GetFilename(_TempFile())), $Line, $temp, $File, $EndOfFile = False
		DirCreate($TempDir)
		RunWait($CLIprefix & '7z.exe l "' & $what & '" >' & $7zList, '.', @SW_HIDE)
		$File = FileOpen($7zList, 0)
		If $File = -1 Then
			$Line = ''
		Else
			Do ; Read in lines of text until the EOF is reached
				$temp = FileReadLine($File)
				$EndOfFile = (@error = -1)
				If Not $EndOfFile Then $Line = $temp
			Until $EndOfFile
			FileClose($File)
		EndIf
		While StringInStr($Line, '  ')
			$Line = StringReplace($Line, '  ', ' ')
		WEnd
		$Line = StringStripWS($Line, 3)
		$n = StringSplit($Line, ' ')
		;_ArrayDisplay($n)
		Switch $n[0]
			Case 8
				Return $n[3] ; 7-Zip v15.12
			Case 6
				If $n[6] = 'folders' Then
					Return $n[1] ; 7-Zip v9.20
				Else
					Return $n[3] ; 7-Zip v15.12
				EndIf
		EndSwitch
	EndIf
	Return 0
EndFunc

Func Input_AdditionalChange()
EndFunc
Func Input_AppPath_sscChange()
	GUICtrlSetData($Input_AppPath, GUICtrlRead($Input_AppPath_ssc))
EndFunc

Func Input_AppPathChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_AppPathChange()' & @CRLF)
	ChangesMade()
	GUICtrlSetData($Label_CopyAppPath, $App_InstallPath)
;~ 	ResizeMe($Form_ssEditor, $Label_CopyAppPath, 8, 400, 0, 'MS Sans Serif')
EndFunc

Func Input_CategoriesChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_CategoriesChange()' & @CRLF)
	If GUICtrlRead($Input_Categories) <> '' Then
		$App_Category = SingleLine2Multi(GUICtrlRead($Input_Categories), '|')
	Else
		ReDim $App_Category[1]
		$App_Category[0] = 0
	EndIf
	PopulateCombo_Category()
	ChangesMade()
EndFunc

Func Input_cmdChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_cmdChange()' & @CRLF)
	ChangesMade()
EndFunc

Func Input_DefaultMenu_sscChange()
EndFunc

Func Input_DefaultMenuChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_DefaultMenuChange()' & @CRLF)
	ChangesMade()
	smPreview()
EndFunc

Func Input_InstalledSizeChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_InstalledSizeChange()' & @CRLF)
	;$App_InstalledSize
	If GUICtrlRead($Input_InstalledSize) <> '' Then
		$App_InstalledSize = FileSizeUnits(GUICtrlRead($Input_InstalledSize), 'from')
	Else
		$App_InstalledSize = ''
	EndIf
	;GUICtrlSetData($Input_InstalledSize, FileSizeUnits($App_InstalledSize, 'to'))
	ChangesMade()
EndFunc

Func Input_LanguageChange()
EndFunc

Func Input_PriorityOrderChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_PriorityOrderChange()' & @CRLF)
	ChangesMade()
EndFunc

Func Input_PublisherChange()
EndFunc

Func Input_RatingChange()
EndFunc

Func Input_RegChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_RegChange()' & @CRLF)
	ChangesMade()
EndFunc

Func Input_ReleaseDateChange()
EndFunc

Func Input_ReleaserChange()
EndFunc

Func Input_ReleaseVersionChange()
EndFunc

Func Input_RequiredRuntimesChange()
EndFunc

Func Input_scArgsChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_scArgsChange()' & @CRLF)
	ChangesMade()
	Census_scDefs()
EndFunc
Func Input_scCatalogChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_scCatalogChange()' & @CRLF)
	ChangesMade()
	Census_scDefs()
EndFunc
Func Input_scDescChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_scDescChange()' & @CRLF)
	ChangesMade()
	Census_scDefs()
EndFunc
Func Input_scExtChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_scExtChange()' & @CRLF)
	ChangesMade()
	Census_scDefs()
EndFunc
Func Input_scFlagsChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_scFlagsChange()' & @CRLF)
	ChangesMade()
	Census_scDefs()
EndFunc
Func Input_scIconChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_scIconChange()' & @CRLF)
	ChangesMade()
	Census_scDefs()
EndFunc
Func Input_scIndexChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_scIndexChange()' & @CRLF)
	ChangesMade()
	Census_scDefs()
EndFunc
Func Input_scKeyChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_scKeyChange()' & @CRLF)
	ChangesMade()
	Census_scDefs()
EndFunc
Func Input_scTargetChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_scTargetChange()' & @CRLF)
	ChangesMade()
	Census_scDefs()
EndFunc
Func Input_scWorkDirChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_scWorkDirChange()' & @CRLF)
	ChangesMade()
	Census_scDefs()
EndFunc
Func Input_SwitchesChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_SwitchesChange()' & @CRLF)
	ChangesMade()
EndFunc
Func Input_SwitchNotesChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_SwitchNotesChange()' & @CRLF)
EndFunc
Func Input_TagsChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_TagsChange()' & @CRLF)
	If GUICtrlRead($Input_Tags) <> '' Then
		$App_Tags = SingleLine2Multi(GUICtrlRead($Input_Tags), '|')
	Else
		ReDim $App_Tags[1]
		$App_Tags[0] = 0
	EndIf
	PopulateCombo_Tags()
	ChangesMade()
EndFunc
Func Input_Title_sscChange()
	GUICtrlSetData($Input_Title, GUICtrlRead($Input_Title_ssc))
EndFunc

Func Input_TitleChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_TitleChange()' & @CRLF)
	ChangesMade()
EndFunc
Func Input_uiDisplayIconChange()
	ChangesMade()
	Census_uiDefs()
EndFunc
Func Input_uiDisplayNameChange()
	ChangesMade()
	Census_uiDefs()
EndFunc
Func Input_uiInstallLocationChange()
	ChangesMade()
	Census_uiDefs()
EndFunc
Func Input_uiScriptChange()
	ChangesMade()
	Census_uiDefs()
EndFunc
Func Input_uiSwitchesChange()
	ChangesMade()
	Census_uiDefs()
EndFunc
Func Input_uiUninstallStringChange()
	ChangesMade()
	Census_uiDefs()
EndFunc
Func Input_VersionChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_VersionChange()' & @CRLF)
	ChangesMade()
EndFunc
Func Input_WorkingDir_sscChange()
EndFunc

Func Input_YearChange()
EndFunc

Func InsertStringToAssembly($what)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|InsertStringToAssembly(): $what = ' & $what & @CRLF)
	$Edit_Installers_Data = GUICtrlRead($Edit_Installers)
	$Edit_Installers_Data = $Edit_Installers_Data & $what
	GUICtrlSetData($Edit_Installers, $Edit_Installers_Data)
	ChangesMade()
EndFunc

Func IsBuildable()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|IsBuildable()' & @CRLF)
	Local $i = False
	Switch $App_Type
		Case 1, 2
			$i = ($MakeExpressInstaller Or Not $UseInputDir)
			$i = ($PatchCompress And (FileExists('ssApp' & '\') Or FileExists('SetupS' & '\') Or FileExists('Patch\')) And Not (FileExists('Patch.7z') Or FileExists('Patch.rar') Or FileExists('Patch.zip') Or FileExists('Patch.cab'))) Or $i
		Case 3, 4
			$i = ($MakeExpressInstaller Or ($ppCompress And Not (FileExists('ppApp.7z') Or FileExists('ppApp.rar'))) Or Not $UseInputDir)
			$i = ($PatchCompress And (FileExists('ppApp' & '\') Or FileExists('Patch\')) And Not (FileExists('Patch.7z') Or FileExists('Patch.rar') Or FileExists('Patch.zip') Or FileExists('Patch.cab'))) Or $i
		Case 5
			$i = ($MakeExpressInstaller Or ($ppCompress And Not (FileExists('ppGame.7z') Or FileExists('ppGame.rar'))) Or Not $UseInputDir)
			$i = ($PatchCompress And (FileExists('ppGame' & '\') Or FileExists('Patch\')) And Not (FileExists('Patch.7z') Or FileExists('Patch.rar') Or FileExists('Patch.zip') Or FileExists('Patch.cab'))) Or $i
	EndSwitch
	$i = $i And $ArchiveEditMode = ''
	Return $i
EndFunc

Func Label_AdditionalClick()
EndFunc
Func Label_AppPath_sscClick()
EndFunc

Func Label_AppPathClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_AppPathClick()' & @CRLF)
	$HelpTopic = 'InstalltoPath'
EndFunc

Func Label_CatalogClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_CatalogClick()' & @CRLF)
	$HelpTopic = 'MenuCatalog'
EndFunc
Func Label_CategoryClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_CategoryClick()' & @CRLF)
	$HelpTopic = 'Category'
EndFunc
Func Label_ClickToSeeClick()
EndFunc
Func Label_Component_AddonInstallerClick() ;%AddonInstaller%
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Component_AddonInstallerClick()' & @CRLF)
	InsertStringToAssembly('%AddonInstaller%')
EndFunc

Func Label_Component_AddToHostsClick() ;%AddToHosts%
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Component_AddToHostsClick()' & @CRLF)
	InsertStringToAssembly('%AddToHosts%')
EndFunc

Func Label_Component_ExtractClick() ;%Extract%
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Component_ExtractClick()' & @CRLF)
	InsertStringToAssembly('%Extract%')
EndFunc

Func Label_Component_ProcessKillClick() ;%ProcessKill%
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Component_ProcessKillClick()' & @CRLF)
	InsertStringToAssembly('%ProcessKill%')
EndFunc

Func Label_Component_WaitForItClick() ;%WaitForIt%
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Component_WaitForItClick()' & @CRLF)
	InsertStringToAssembly('%WaitForIt%')
EndFunc

Func Label_CopyAppPathClick()
EndFunc

Func Label_CopyDefaultMenuClick()
EndFunc
Func Label_DefaultMenu_sscClick()
EndFunc
Func Label_DefaultMenuClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_DefaultMenuClick()' & @CRLF)
	$HelpTopic = 'DefaultMenu'
EndFunc

Func Label_Directive_ApplyPatchClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Directive_ApplyPatchClick()' & @CRLF)
	InsertStringToAssembly('#ApplyPatch#')
EndFunc

Func Label_Directive_AppPathIconClick() ;#AppPathFolderIcon#
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Directive_AppPathIconClick()' & @CRLF)
	InsertStringToAssembly('#AppPathFolderIcon#')
EndFunc

Func Label_Directive_CmdClick() ;#CMD#
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Directive_CmdClick()' & @CRLF)
	InsertStringToAssembly('#CMD#')
EndFunc

Func Label_Directive_FontsClick() ;#InstallFonts#
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Directive_FontsClick()' & @CRLF)
	InsertStringToAssembly('#InstallFonts#')
EndFunc

Func Label_Directive_NT5Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Directive_NT5Click()' & @CRLF)
	InsertStringToAssembly('#Is_NT5#')
EndFunc

Func Label_Directive_NT6Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Directive_NT6Click()' & @CRLF)
	InsertStringToAssembly('#Is_NT6#')
EndFunc

Func Label_Directive_RegisterDLLClick() ;#RegisterDLL#
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Directive_RegisterDLLClick()' & @CRLF)
	InsertStringToAssembly('#RegisterDLL#')
EndFunc

Func Label_Directive_RegistryClick() ;#ApplyRegistry#
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Directive_RegistryClick()' & @CRLF)
	InsertStringToAssembly('#ApplyRegistry#')
EndFunc

Func Label_Directive_ScriptClick() ;#RunScript#
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Directive_ScriptClick()' & @CRLF)
	InsertStringToAssembly('#RunScript#')
EndFunc

Func Label_Directive_ShortcutSClick() ;#ShortcutS#
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Directive_ShortcutSClick()' & @CRLF)
	InsertStringToAssembly('#ShortcutS#')
EndFunc

Func Label_Directive_x64Click() ;#Is_x64#
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Directive_x64Click()' & @CRLF)
	InsertStringToAssembly('#Is_x64#')
EndFunc

Func Label_Directive_x86Click() ;#Is_x86#
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_Directive_x86Click()' & @CRLF)
	InsertStringToAssembly('#Is_x86#')
EndFunc

Func Label_FileVersionClick()
EndFunc

Func Label_InstalledSizeClick()
EndFunc
Func Label_Installer_sscClick()
EndFunc
Func Label_InstallerClick()
EndFunc
Func Label_InstallListClick()
EndFunc
Func Label_InstalltoPathClick()
EndFunc
Func Label_LanguageClick()
EndFunc
Func Label_PriorityOrderClick()
EndFunc
Func Label_PublisherClick()
EndFunc
Func Label_RatingClick()
EndFunc
Func Label_ReleaseDateClick()
EndFunc
Func Label_ReleaserClick()
EndFunc
Func Label_ReleaseVersionClick()
EndFunc
Func Label_RequiredRuntimesClick()
EndFunc
Func Label_scArgsClick()
EndFunc
Func Label_scCatalogClick()
EndFunc
Func Label_scCountClick()
EndFunc
Func Label_scDescClick()
EndFunc
Func Label_scExtClick()
EndFunc
Func Label_scFlagsClick()
EndFunc
Func Label_scIconClick()
EndFunc
Func Label_scIndexClick()
EndFunc
Func Label_scKeepClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_scKeepClick()' & @CRLF)
	$HelpTopic = 'ShortcutNamestoKeep'
EndFunc
Func Label_scKeyClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_scKeyClick()' & @CRLF)
	$HelpTopic = 'ShortcutHotkey'
EndFunc
Func Label_scLocationsClick()
EndFunc
Func Label_scNameClick()
EndFunc
Func Label_scTargetClick()
EndFunc
Func Label_scWorkDirClick()
EndFunc
Func Label_StartSourceClick()
EndFunc
Func Label_SwitchesClick()
EndFunc
Func Label_SwitchNotesClick()
EndFunc
Func Label_TagsClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_TagsClick()' & @CRLF)
	If $App_Type = 5 Then
		$HelpTopic = 'GameTagList'
	Else
		$HelpTopic = 'AppTagList'
	EndIf
	If ProcessExists($Help_PID) Then ProcessClose($Help_PID)
	$Help_PID = Run('hh.exe ' & $MSITStore & $HelpFile & '::/' & $HelpTopic & '.html')
EndFunc
Func Label_Title_sscClick()
EndFunc
Func Label_TitleClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_TitleClick()' & @CRLF)
	$HelpTopic = 'ApplicationGameDetails'
EndFunc
Func Label_uiCountClick()
EndFunc
Func Label_uiDisplayIconClick()
EndFunc
Func Label_uiDisplayNameClick()
EndFunc
Func Label_uiInstallLocationClick()
EndFunc
Func Label_uiKeyClick()
EndFunc
Func Label_uiScriptClick()
EndFunc
Func Label_uiSwitchesClick()
EndFunc
Func Label_uiUninstallStringClick()
EndFunc
Func Label_URLClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_URLClick()' & @CRLF)
	Local $i, $spawn
	$HelpTopic = 'ApplicationGameDetails'
	If IsArray($app_url) Then
		For $i = 1 To $App_URL[0]
			$spawn = ShellExecuteWait($App_URL[$i])
			If @error Then ExitLoop
			Sleep(2000)
		Next
	EndIf
EndFunc
Func Label_VersionClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_VersionClick()' & @CRLF)
	$HelpTopic = 'ApplicationGameDetails'
EndFunc
Func Label_WorkingDir_sscClick()
EndFunc
Func Label_YearClick()
EndFunc

Func LockDown($Activate = True)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|LockDown(): $Activate = ' & $Activate & @CRLF)

	; Form
	If $Activate Then
		;GUISetState(@SW_DISABLE, $Form_ssEditor)
		;GUICtrlSetState($PageControl_ssEditor, $GUI_DISABLE)
	ElseIf $Unlock Then
		;GUISetState(@SW_ENABLE, $Form_ssEditor)
		;GUICtrlSetState($PageControl_ssEditor, $GUI_ENABLE)
	EndIf

	; New
	If $Activate Then
		GUICtrlSetState($MenuItem_New, $GUI_DISABLE)
		GUICtrlSetState($Button_New, $GUI_DISABLE)
	ElseIf $Unlock Then
		GUICtrlSetState($MenuItem_New, $GUI_ENABLE)
		GUICtrlSetState($Button_New, $GUI_ENABLE)
	EndIf

	; Open
	If $Activate Then
		GUICtrlSetState($MenuItem_Open, $GUI_DISABLE)
		GUICtrlSetState($Button_Open, $GUI_DISABLE)
	ElseIf $Unlock Then
		GUICtrlSetState($MenuItem_Open, $GUI_ENABLE)
		GUICtrlSetState($Button_Open, $GUI_ENABLE)
	EndIf

	; Save
	If $Activate Then
		GUICtrlSetState($MenuItem_Save, $GUI_DISABLE)
		GUICtrlSetState($Button_Save, $GUI_DISABLE)
	ElseIf $Unlock Then
		GUICtrlSetState($MenuItem_Save, $GUI_ENABLE)
		GUICtrlSetState($Button_Save, $GUI_ENABLE)
	EndIf

	; ViewWorkDir
	If $Activate Then
		GUICtrlSetState($MenuItem_Browse2Working, $GUI_DISABLE)
		GUICtrlSetState($Button_ViewWorkDir, $GUI_DISABLE)
	ElseIf $Unlock Then
		GUICtrlSetState($MenuItem_Browse2Working, $GUI_ENABLE)
		GUICtrlSetState($Button_ViewWorkDir, $GUI_ENABLE)
	EndIf

	; Build
	If $Activate Then
		GUICtrlSetState($MenuItem_Build, $GUI_DISABLE)
		GUICtrlSetState($Button_Build, $GUI_DISABLE)
	ElseIf $Unlock And $ArchiveEditMode = '' Then
		GUICtrlSetState($MenuItem_Build, $GUI_ENABLE)
		GUICtrlSetState($Button_Build, $GUI_ENABLE)
	EndIf

	; SetupS Test
	If $Activate Then
		GUICtrlSetState($MenuItem_SetupSTest, $GUI_DISABLE)
		GUICtrlSetState($Button_SetupSTest, $GUI_DISABLE)
	ElseIf $Unlock And $ArchiveEditMode = '' Then
		GUICtrlSetState($MenuItem_SetupSTest, $GUI_ENABLE)
		GUICtrlSetState($Button_SetupSTest, $GUI_ENABLE)
	EndIf
EndFunc

Func MenuItem_128x128icoClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_128x128icoClick()' & @CRLF)
	$PreviewIconSize = 128
	NeoIniWrite($ssEditorINI, 'Options', 'Icon View Size', $PreviewIconSize)
	GUICtrlSetState($MenuItem_16x16ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_24x24ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_32x32ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_48x48ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_96x96ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_128x128ico, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_256x256ico, $GUI_UNCHECKED)
EndFunc
Func MenuItem_16x16icoClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_16x16icoClick()' & @CRLF)
	$PreviewIconSize = 16
	NeoIniWrite($ssEditorINI, 'Options', 'Icon View Size', $PreviewIconSize)
	GUICtrlSetState($MenuItem_16x16ico, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_24x24ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_32x32ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_48x48ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_96x96ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_128x128ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_256x256ico, $GUI_UNCHECKED)
EndFunc

Func MenuItem_24x24icoClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_24x24icoClick()' & @CRLF)
	$PreviewIconSize = 24
	NeoIniWrite($ssEditorINI, 'Options', 'Icon View Size', $PreviewIconSize)
	GUICtrlSetState($MenuItem_16x16ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_24x24ico, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_32x32ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_48x48ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_96x96ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_128x128ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_256x256ico, $GUI_UNCHECKED)
EndFunc
Func MenuItem_256x256icoClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_256x256icoClick()' & @CRLF)
	$PreviewIconSize = 256
	NeoIniWrite($ssEditorINI, 'Options', 'Icon View Size', $PreviewIconSize)
	GUICtrlSetState($MenuItem_16x16ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_24x24ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_32x32ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_48x48ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_96x96ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_128x128ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_256x256ico, $GUI_CHECKED)
EndFunc
Func MenuItem_32x32icoClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_32x32icoClick()' & @CRLF)
	$PreviewIconSize = 32
	NeoIniWrite($ssEditorINI, 'Options', 'Icon View Size', $PreviewIconSize)
	GUICtrlSetState($MenuItem_16x16ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_24x24ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_32x32ico, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_48x48ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_96x96ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_128x128ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_256x256ico, $GUI_UNCHECKED)
EndFunc
Func MenuItem_48x48icoClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_48x48icoClick()' & @CRLF)
	$PreviewIconSize = 48
	NeoIniWrite($ssEditorINI, 'Options', 'Icon View Size', $PreviewIconSize)
	GUICtrlSetState($MenuItem_16x16ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_24x24ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_32x32ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_48x48ico, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_96x96ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_128x128ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_256x256ico, $GUI_UNCHECKED)
EndFunc
Func MenuItem_640x480jpgClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_640x480jpgClick()' & @CRLF)
	$JpgSize = 640
	NeoIniWrite($ssEditorINI, 'Options', 'JPG Size', $JpgSize)
	GUICtrlSetState($MenuItem_640x480jpg, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_800x600jpg, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_FullResJPG, $GUI_UNCHECKED)
EndFunc
Func MenuItem_7zProcessPriority0Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_7zProcessPriority0Click()' & @CRLF)
	$7zProcessPriority = 0
	NeoIniWrite($ssEditorINI, 'Options', '7z Process Priority', $7zProcessPriority)
	GUICtrlSetState($MenuItem_7zProcessPriority0, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority1, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority2, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority3, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority4, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority5, $GUI_UNCHECKED)
EndFunc
Func MenuItem_7zProcessPriority1Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_7zProcessPriority1Click()' & @CRLF)
	$7zProcessPriority = 1
	NeoIniWrite($ssEditorINI, 'Options', '7z Process Priority', $7zProcessPriority)
	GUICtrlSetState($MenuItem_7zProcessPriority0, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority1, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority2, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority3, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority4, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority5, $GUI_UNCHECKED)
EndFunc
Func MenuItem_7zProcessPriority2Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_7zProcessPriority2Click()' & @CRLF)
	$7zProcessPriority = 2
	NeoIniWrite($ssEditorINI, 'Options', '7z Process Priority', $7zProcessPriority)
	GUICtrlSetState($MenuItem_7zProcessPriority0, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority1, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority2, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority3, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority4, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority5, $GUI_UNCHECKED)
EndFunc
Func MenuItem_7zProcessPriority3Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_7zProcessPriority3Click()' & @CRLF)
	$7zProcessPriority = 3
	NeoIniWrite($ssEditorINI, 'Options', '7z Process Priority', $7zProcessPriority)
	GUICtrlSetState($MenuItem_7zProcessPriority0, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority1, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority2, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority3, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority4, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority5, $GUI_UNCHECKED)
EndFunc
Func MenuItem_7zProcessPriority4Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_7zProcessPriority4Click()' & @CRLF)
	$7zProcessPriority = 4
	NeoIniWrite($ssEditorINI, 'Options', '7z Process Priority', $7zProcessPriority)
	GUICtrlSetState($MenuItem_7zProcessPriority0, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority1, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority2, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority3, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority4, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority5, $GUI_UNCHECKED)
EndFunc
Func MenuItem_7zProcessPriority5Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_7zProcessPriority5Click()' & @CRLF)
	$7zProcessPriority = 5
	NeoIniWrite($ssEditorINI, 'Options', '7z Process Priority', $7zProcessPriority)
	GUICtrlSetState($MenuItem_7zProcessPriority0, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority1, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority2, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority3, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority4, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_7zProcessPriority5, $GUI_CHECKED)
EndFunc

Func MenuItem_7zProcessPriorityClick()
EndFunc
Func MenuItem_800x600jpgClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_800x600jpgClick()' & @CRLF)
	$JpgSize = 800
	NeoIniWrite($ssEditorINI, 'Options', 'JPG Size', $JpgSize)
	GUICtrlSetState($MenuItem_640x480jpg, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_800x600jpg, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_FullResJPG, $GUI_UNCHECKED)
EndFunc

Func MenuItem_96x96icoClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_96x96icoClick()' & @CRLF)
	$PreviewIconSize = 96
	NeoIniWrite($ssEditorINI, 'Options', 'Icon View Size', $PreviewIconSize)
	GUICtrlSetState($MenuItem_16x16ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_24x24ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_32x32ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_48x48ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_96x96ico, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_128x128ico, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_256x256ico, $GUI_UNCHECKED)
EndFunc

Func MenuItem_Au3InfoClick()
	Local $EXEname = @ScriptDir & '\bin\au3info.exe'
	If $OSArch64 Then $EXEname = @ScriptDir & '\bin\au3info_x64.exe'
	If FileExists($EXEname) Then Run($EXEname)
EndFunc

Func MenuItem_Browse2OutputPathClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Browse2OutputPathClick()' & @CRLF)
	Run("explorer /n,/e, " & '"' & $OutputPath & '"')
EndFunc

Func MenuItem_Browse2WorkingClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Browse2WorkingClick()' & @CRLF)
	Run("explorer /n,/e, " & '"' & @WorkingDir & '"')
EndFunc

Func MenuItem_BuildClick()
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Build' & @CRLF)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_BuildClick()' & @CRLF)
	LockDown(True)
	$Unlock = False
	$Abort7z = False
	Local $var = GetFilename(GetFolderPath($App_File)), $n, $hOrigCur = CursorWait(), $ext, $i, $f, $Patch, $DS_Temp, $Unsafe
	Local $upper, $lower, $type, $7zWorking = NoBackslash(GetFolderPath($App_File)), $FileList, $ppSub = '', $ArcExt
	If $UseRAR Then
		$ArcExt = '.rar'
	Else
		$ArcExt = '.7z'
	EndIf
	$OutputPathCurrent = $OutputPath
	Switch $App_Type
		Case 1, 2
			$type = 'ssApp'
			$ext = '.apz'
		Case 3, 4
			$type = 'ppApp'
			$ext = '.apz'
;~ 		Case 4
;~ 			$type = 'ppTweak'
;~ 			$ext = '.apz'
		Case 5
			$type = 'ppGame'
			$ext = '.pgz'
	EndSwitch
	$n = $OutputPath
	If $SrcPath <> $OutputPath Then $n = $n & '\' & GetFilename($App_InstallPath)
	If $MakeExpressInstaller Then
		$upper = 'Build an archive deployment package'
		$lower = "This will create a single (distributable) archive package with the extension '" & StringUpper($ext)
		$lower &= "' in the following folder: " & '"' & $OutputPath & '"' & "." & @CRLF & @CRLF
		$lower &= "If this is not what you want, disable the Build option 'Make Archive Deployment Package (.apz/.pgz)'."
	Else
		$upper = 'Build a folder deployment package'
		$lower = "This will build a (distributable) folder package in the following folder: " & '"' & $n & '"' & "." & @CRLF & @CRLF
		$lower &= "If you wanted the single (distributable) archive instead, then enable the Build option 'Make Archive Deployment Package (.apz/.pgz)'."
	EndIf
	If Not $AutoBuild Then
		Switch MsgBox(3, $upper, $lower & @CRLF & @CRLF & 'Do you wish to Continue?')
			Case 6 ; Yes
				; Continue
			Case Else ; No or Cancel
				$OutputPathCurrent = ''
				$Unlock = True
				LockDown(False)
				Return 'Cancel'
		EndSwitch
	EndIf
	If $SrcPath <> $OutputPathCurrent Then
		DirRemove($OutputPath & '\' & GetFilename($App_InstallPath), 1)
		NeoDirCopy($SrcPath, $OutputPath & '\' & GetFilename($App_InstallPath))
		FileSetAttrib($OutputPath & '\' & GetFilename($App_InstallPath) & '\*.*', '-R')
	EndIf
	MenuItem_SaveClick()
	If $SrcPath <> $OutputPathCurrent Then
		SetOutputPath($OutputPath & '\' & GetFilename($App_InstallPath))
	EndIf
	GUICtrlSetState($Button_Build, $GUI_DISABLE)
	If Not $DeleteSource Then
		$TempSourceDir = StringLeft(_PathFull($OutputPath), 2) & '\' & GetFilename(GenerateTempFolder())
		DirCreate($TempSourceDir)
	EndIf
	If $PatchCompress And (FileExists($type & '\') Or FileExists('Patch\')) And Not (FileExists('Patch.7z') Or FileExists('Patch.rar') Or FileExists('Patch.zip') Or FileExists('Patch.cab')) Then
		Select
			Case FileExists($type & '\') And Not FileExists('Patch\')
				$Patch = $type
			Case FileExists('Patch\') And Not FileExists($type & '\')
				$Patch = 'Patch'
			Case FileExists($type & '\') And FileExists('Patch\')
				$Patch = 'Patch'
		EndSelect
		FileChangeDir($Patch)
		If Not $MakeExpressInstaller Then
			$DS_Temp = $DeleteSource
			$DeleteSource = True
		EndIf
		$n = Moveto7z('..\Patch' & $ArcExt, True, $ArchiveCompressionLevel, 'on', $App_Title, $Patch)
		If Not $MakeExpressInstaller Then $DeleteSource = $DS_Temp
		FileChangeDir('..')
		DirRemove($Patch)
	EndIf
	If Not $Abort7z Then
		Switch $App_Type
			Case 3, 4, 5 ;ppApp/ppGame
				If $ppCompress And Not (FileExists($type & '.7z') Or FileExists($type & '.rar') Or FileExists($type & '.zip') Or FileExists($type & '.cab')) Then ;Or FileExists($type & '.rar')
					ControlSetText('', '', $StatusBar_ssEditor, 'Building ' & $type & ' install package ...')
					If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Building ' & $type & ' install package.' & @CRLF)
					If FileExists($type & '\') Then
						$ppSub = '..\'
						FileChangeDir($type)
					EndIf
					If Not $MakeExpressInstaller Then
						$DS_Temp = $DeleteSource
						$DeleteSource = True
					EndIf
					$n = Moveto7z($ppSub & $type & $ArcExt, False, $ArchiveCompressionLevel, 'on', $App_Title)
					If Not $MakeExpressInstaller Then $DeleteSource = $DS_Temp
					If $ppSub = '..\' Then
						FileChangeDir('..')
						DirRemove($type)
					EndIf
				EndIf
		EndSwitch
		FileDelete('desktop.ini')
		FileDelete('thumbs.db')
	EndIf
	If $CalcExtractedSize And Not $Abort7z Then ;And ($App_InstalledSize = 0 Or $App_InstalledSize = '')
		Local $WriteMode = '', $App_InstalledSize_old = $App_InstalledSize
		Button_GetppExtractedSizeClick()
		If $App_InstalledSize_old <> $App_InstalledSize Then
			If VersionCompare($SetupSFileVersion, '=', '9') Then ;GetVersionNumber($SetupSFileVersion) = 9
				If $App_FileFormat = 0 Then
					$WriteMode = 'New'
				EndIf
			Else ; 'Legacy' still
				$WriteMode = 'Legacy'
			EndIf
			If $WriteMode = '' Then
				Switch $SaveFormat ;Test format saves
					Case 0 ; Legacy
						$WriteMode = 'Legacy'
					Case 1 ; Dual
						$WriteMode = 'Dual'
					Case 2 ; INI-only
						$WriteMode = 'New'
					Case 4 ; Update-only
						$WriteMode = 'Update'
					Case Else ; Default
						$WriteMode = ''
				EndSwitch
			EndIf
			If Not ($WriteMode = 'Legacy' Or $WriteMode = 'Dual' Or $WriteMode = 'New') Then _AppWrite($App_File, $WriteMode)
		EndIf
	EndIf
	If $CalcMD5 And ($WINEVersion = '' Or VersionFormat($WINEVersion) >= VersionFormat('1.7')) And Not $Abort7z Then
		FileDelete($type & '.md5')
		ControlSetText('', '', $StatusBar_ssEditor, 'Building ' & $type & ' md5 checksum file ...')
		If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Building ' & $type & ' md5 checksum file.' & @CRLF)
		Local $BatchList[1]
		$BatchList[0] = 0
		ScanForFiles(@WorkingDir, $BatchList)
		_Crypt_Startup()
		For $i = 1 To $BatchList[0]
			_MD5Write2File(_MD5Calc($BatchList[$i], True), StringReplace($BatchList[$i], @WorkingDir & '\', ''), $type & '.md5')
		Next
		_Crypt_Shutdown()
	EndIf
	If $MakeExpressInstaller And Not $Abort7z Then
		ControlSetText('', '', $StatusBar_ssEditor, 'Building Archive Deployment Package (' & StringLower($ext) & ') ...')
		If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Building Archive Deployment Package (' & StringLower($ext) & ').' & @CRLF)

		;Construct Filename using tag options
		Local $s, $sTitle = StringReplace($App_Title, ' ', '.'), $sVer = StringReplace($App_Version, ' ', '.')
		Local $sPublisher, $sLang, $sLic, $sCat, $sAdd, $sRuntimes, $sReleaser, $sOS, $sArch
		If 0 < $App_OS And $App_OS < 15 Then
			If BitAND($App_OS, 1) = 1 Then $sOS = 'NT5'
			If BitAND($App_OS, 2) = 2 Then $sOS = 'Vista-7'
			If BitAND($App_OS, 4) = 4 Then $sOS = 'Win8'
			If BitAND($App_OS, 8) = 8 Then $sOS = 'Win10'
		EndIf
		Switch $App_Architecture
			Case 1
				$sArch = 'x86'
			Case 2
				$sArch = 'x64'
			Case 3
				$sArch = 'DualArch'
		EndSwitch
		If $UseFilenameTags Then
			If $PublisherTag And $App_Publisher <> '' Then $s = StringReplace($App_Publisher, ' ', '.') & '.'
			If $TitleTag And $sTitle <> '' Then $s = $s & $sTitle
			If $VersionTag And $sVer <> '' Then $s = $s & '_' & $sVer
			If $LanguageTag And $App_Language <> '' Then $s = $s & '_' & StringReplace($App_Language, ' ', '.')
			If $OSTag And $sOS <> '' Then $s = $s & '_' & $sOS
			If $ArchitectureTag And $sArch <> '' Then $s = $s & '_' & $sArch
			If $LicenseTag Then
				Switch $App_LicenseType
					Case 1
						$s = $s & '_Non-gratis'
					Case 2
						$s = $s & '_Gratis-only'
					Case 3
						$s = $s & '_Libre'
				EndSwitch
			EndIf
			If $BuildTypeTag Then $s = $s & '_' & $type
			Select
				Case $CategoryTag
					If $App_Category <> '' Then $s = $s & '-' & StringReplace($App_Category, ' ', '.')
				Case $AdditionalTag
					If $App_Additional <> '' Then $s = $s & '-' & StringReplace($App_Additional, ' ', '.')
			EndSelect
			If $RequiredRuntimesTag And $App_RequiredRuntimes <> '' Then $s = $s & '-' & StringReplace($App_RequiredRuntimes, ' ', '.')
			If $ReleaserTag And $App_Releaser <> '' Then $s = $s & '-' & StringReplace($App_Releaser, ' ', '.')
		EndIf
		If $s = '' Or Not $UseFilenameTags Then $s = $sTitle & '_' & $sVer & '_' & $sOS & '_' & $sArch & '_' & $type
		$n = StringFilterFilename($s & $ext, False, True)
		If $WebfriendlyFilenames Then
			$n = MakeSafeFilename($n, '.php')
			$n = MakeSafeFilename($n, '.html')
			$n = MakeSafeFilename($n, '.htm')
		EndIf
		$n = Moveto7z($n, True, $ArchiveCompressionLevel, 'off', $App_Title)
		If $UseInputDir And $AutoBuild Then
			FileMove($n, '..\' & $n, 1)
			If $DeleteSource Then DirRemove(_PathFull('.'), 1)
		EndIf
		If Not $DeleteSource Then
			If FileExists($TempSourceDir) Then
				$FileList = _FileListToArray($TempSourceDir, '*.*', 2) ; Return folders only
				If @error = 0 Then
					For $i = 1 To $FileList[0]
						DirMove($TempSourceDir & '\' & $FileList[$i], $OutputPath & '\' & $FileList[$i])
					Next
				EndIf
				$FileList = _FileListToArray($TempSourceDir, '*.*', 1) ; Return files only
				If @error = 0 Then
					For $i = 1 To $FileList[0]
						FileMove($TempSourceDir & '\' & $FileList[$i], $OutputPath & '\' & $FileList[$i])
					Next
				EndIf
			EndIf
			DirRemove($TempSourceDir, 1)
			FileDelete($type & '.md5')
			FileDelete($type & '.7z')
			FileDelete($type & '.rar')
			FileDelete($type & '.zip')
			FileDelete($type & '.cab')
			FileDelete('Patch.7z')
			FileDelete('Patch.rar')
			FileDelete('Patch.zip')
			FileDelete('Patch.cab')
		EndIf
		If $n = '' Then
			GUICtrlSetState($Button_Build, $GUI_ENABLE)
			If $OutputPathCurrent <> '' Then
				SetOutputPath($OutputPathCurrent)
				$OutputPathCurrent = ''
			EndIf
			CursorWait($hOrigCur)
			SplashOff()
			Return
		EndIf
;~ 		MenuItem_NewClick()
		If $SrcPath <> $OutputPathCurrent Then
			FileDelete($OutputPathCurrent & '\' & $n)
			FileMove($OutputPath & '\' & $n, $OutputPathCurrent & '\' & $n)
			DirRemove($OutputPath, 1)
		EndIf
	EndIf
	If $OutputPathCurrent <> '' Then
		SetOutputPath($OutputPathCurrent)
		$OutputPathCurrent = ''
	EndIf
	CursorWait($hOrigCur)
	;$SrcPath = $SrcPathCurrent
	;FileChangeDir($SrcPath)
	SplashOff()
	If $CLIparameters[0] > 0 And $ExitBuild And Not $Abort7z Then Form_ssEditorClose()
;~ 	MenuItem_NewClick()
	$Unlock = True
	LockDown(False)
EndFunc

Func MenuItem_BuildOptionsClick()
	$HelpTopic = 'BuildsMenu'
EndFunc

Func MenuItem_BuildsFilenameTagsClick()
EndFunc

Func MenuItem_BuildsUseFilenameTagsClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_BuildsUseFilenameTagsClick()' & @CRLF)
	$UseFilenameTags = Not $UseFilenameTags
	If $UseFilenameTags Then
		GUICtrlSetState($MenuItem_BuildsUseFilenameTags, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_BuildsUseFilenameTags, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Use Filename Tags', $UseFilenameTags)
EndFunc

Func MenuItem_CalcExtractedSizeClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_CalcExtractedSizeClick()' & @CRLF)
	$CalcExtractedSize = Not $CalcExtractedSize
	If $CalcExtractedSize Then
		GUICtrlSetState($MenuItem_CalcExtractedSize, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_CalcExtractedSize, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Calculate Extracted Size', $CalcExtractedSize)
EndFunc

Func MenuItem_CalcMD5Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_CalcMD5Click()' & @CRLF)
	$CalcMD5 = Not $CalcMD5
	If $CalcMD5 Then
		GUICtrlSetState($MenuItem_CalcMD5, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_CalcMD5, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Calculate MD5 checksum', $CalcMD5)
EndFunc

Func MenuItem_CompressionOptionsClick()
EndFunc

Func MenuItem_ContentsClick() ;GUISetHelp ;KeyHH.exe
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_ContentsClick()' & @CRLF)
	If $HelpTopic = '' Then
		$Help_PID = Run('hh.exe ' & $MSITStore & $HelpFile)
	Else
		If ProcessExists($Help_PID) Then ProcessClose($Help_PID)
		$Help_PID = Run('hh.exe ' & $MSITStore & $HelpFile & '::/' & $HelpTopic & '.html')
	EndIf
EndFunc

Func MenuItem_DeleteSourceClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_DeleteSourceClick()' & @CRLF)
	$DeleteSource = Not $DeleteSource
	If $DeleteSource Then
		GUICtrlSetState($MenuItem_DeleteSource, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_DeleteSource, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Delete Source', $DeleteSource)
	BuildOptToggle()
EndFunc

Func MenuItem_ExitBuildClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_ExitBuildClick()' & @CRLF)
	$ExitBuild = Not $ExitBuild
	If $ExitBuild Then
		GUICtrlSetState($MenuItem_ExitBuild, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_ExitBuild, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Exit After Build', $ExitBuild)
EndFunc

Func MenuItem_ExtractICOClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_ExtractICOClick()' & @CRLF)
	Local $i = $App_InstallPath
	If $i = '' Then $i = '.'
	Local $var = FileOpenDialog('Browse for icon file:', $i, 'Icon files (*.exe;*.ico;*.dll)', 1)
	If Not @error Then
		$var = StringReplace($var, '|', @CRLF)
;~ 		If Not FileExists($TempPixDir & '\iconsext.exe') Then
;~ 			Local $CurrentWorkingDir = @WorkingDir
;~ 			FileChangeDir(@ScriptDir)
;~ 			FileInstall('.\bin\iconsext.exe', $TempPixDir & '\iconsext.exe', 1)
;~ 			FileChangeDir($CurrentWorkingDir)
;~ 		EndIf
		RunWait($CLIprefix & @ScriptDir & '\bin\iconsext.exe /save "' & $var & '" "' & $OutputPath & '" -icons -asico')
		MenuItem_Browse2OutputPathClick()
	EndIf
EndFunc

Func MenuItem_FileClick()
EndFunc
Func MenuItem_FilenameTagAdditionalClick()
	$AdditionalTag = Not $AdditionalTag
	If $AdditionalTag Then
		GUICtrlSetState($MenuItem_FilenameTagAdditional, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_FilenameTagAdditional, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Filename Tags', 'Additional', $AdditionalTag)
EndFunc
Func MenuItem_FilenameTagArchitectureClick()
	$ArchitectureTag = Not $ArchitectureTag
	If $ArchitectureTag Then
		GUICtrlSetState($MenuItem_FilenameTagArchitecture, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_FilenameTagArchitecture, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Filename Tags', 'Architecture', $ArchitectureTag)
EndFunc
Func MenuItem_FilenameTagBuildTypeClick()
	$BuildTypeTag = Not $BuildTypeTag
	If $BuildTypeTag Then
		GUICtrlSetState($MenuItem_FilenameTagBuildType, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_FilenameTagBuildType, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Filename Tags', 'BuildType', $BuildTypeTag)
EndFunc
Func MenuItem_FilenameTagCategoryClick()
	$CategoryTag = Not $CategoryTag
	If $CategoryTag Then
		GUICtrlSetState($MenuItem_FilenameTagCategory, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_FilenameTagCategory, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Filename Tags', 'Category', $CategoryTag)
EndFunc
Func MenuItem_FilenameTagLanguageClick()
	$LanguageTag = Not $LanguageTag
	If $LanguageTag Then
		GUICtrlSetState($MenuItem_FilenameTagLanguage, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_FilenameTagLanguage, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Filename Tags', 'Language', $LanguageTag)
EndFunc
Func MenuItem_FilenameTagLicenseClick()
	$LicenseTag = Not $LicenseTag
	If $LicenseTag Then
		GUICtrlSetState($MenuItem_FilenameTagLicense, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_FilenameTagLicense, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Filename Tags', 'License', $LicenseTag)
EndFunc
Func MenuItem_FilenameTagOSClick()
	$OSTag = Not $OSTag
	If $OSTag Then
		GUICtrlSetState($MenuItem_FilenameTagOS, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_FilenameTagOS, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Filename Tags', 'OS', $OSTag)
EndFunc

Func MenuItem_FilenameTagPublisherClick()
	$PublisherTag = Not $PublisherTag
	If $PublisherTag Then
		GUICtrlSetState($MenuItem_FilenameTagPublisher, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_FilenameTagPublisher, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Filename Tags', 'Publisher', $PublisherTag)
EndFunc
Func MenuItem_FilenameTagReleaserClick()
	$ReleaserTag = Not $ReleaserTag
	If $ReleaserTag Then
		GUICtrlSetState($MenuItem_FilenameTagReleaser, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_FilenameTagReleaser, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Filename Tags', 'Releaser', $ReleaserTag)
EndFunc
Func MenuItem_FilenameTagRequiredRuntimesClick()
	$RequiredRuntimesTag = Not $RequiredRuntimesTag
	If $RequiredRuntimesTag Then
		GUICtrlSetState($MenuItem_FilenameTagRequiredRuntimes, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_FilenameTagRequiredRuntimes, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Filename Tags', 'RequiredRuntimes', $RequiredRuntimesTag)
EndFunc
Func MenuItem_FilenameTagTitleClick()
	$TitleTag = Not $TitleTag
	If $TitleTag Then
		GUICtrlSetState($MenuItem_FilenameTagTitle, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_FilenameTagTitle, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Filename Tags', 'Title', $TitleTag)
EndFunc
Func MenuItem_FilenameTagVersionClick()
	$VersionTag = Not $VersionTag
	If $VersionTag Then
		GUICtrlSetState($MenuItem_FilenameTagVersion, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_FilenameTagVersion, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Filename Tags', 'Version', $VersionTag)
EndFunc

Func MenuItem_FullResJPGClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_FullResJPGClick()' & @CRLF)
	$JpgSize = 0
	NeoIniWrite($ssEditorINI, 'Options', 'JPG Size', $JpgSize)
	GUICtrlSetState($MenuItem_640x480jpg, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_800x600jpg, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_FullResJPG, $GUI_CHECKED)
EndFunc

Func MenuItem_GrabClipBoardPicClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_GrabClipBoardPicClick()' & @CRLF)
	Local $n = $OutputPath
	$OutputPathCurrent = $OutputPath
	If $SrcPath <> $OutputPath Then $n = $n & '\' & GetFilename($App_InstallPath)
	Switch MsgBox(3, 'Clipboard Grab Activated', 'Simply copy a picture to the clipboard and then return here to click "Yes"' & @CRLF & @CRLF & 'After clicking "Yes" here, a screenshot file from the clipboard picture will be saved to: ' & @CRLF & '"' & $n & '"')
		Case 6 ; Yes
			; Continue
		Case Else ; No or Cancel
			$OutputPathCurrent = ''
			Return 'Cancel'
	EndSwitch
	If $SrcPath <> $OutputPathCurrent Then SetOutputPath($OutputPath & '\' & GetFilename($App_InstallPath))
	SaveClipboardJpg()
EndFunc

Func MenuItem_HelpClick()
EndFunc

Func MenuItem_IntegrateRegCmdClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_IntegrateRegCmdClick()' & @CRLF)
	$IntegrateRegCmd = Not $IntegrateRegCmd
	If $IntegrateRegCmd Then
		GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'IntegrateRegCmd', $IntegrateRegCmd)
EndFunc

Func MenuItem_JPGQuality100Click()
EndFunc

Func MenuItem_JPGQualityCustomClick()
EndFunc

Func MenuItem_LogDebuggingClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_LogDebuggingClick()' & @CRLF)
	$Debug = Not $Debug
	If $Debug Then
		GUICtrlSetState($MenuItem_LogDebugging, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_LogDebugging, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Reporting Mode', 'Debug', $Debug)
EndFunc

Func MenuItem_LoggingClick()
EndFunc

Func MenuItem_LogReportingClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_LogReportingClick()' & @CRLF)
	$Log = Not $Log
	If $Log Then
		GUICtrlSetState($MenuItem_LogReporting, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_LogReporting, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Reporting Mode', 'Log', $Log)
EndFunc

Func MenuItem_NewClick($PathIn = '')
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'New File' & @CRLF)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_NewClick()' & @CRLF)
	Local $PathOut = '', $ExitFunc = False, $WriteMode
	LockDown()
	$FormMode = False
	Local $n
	;If @WorkingDir = $TemplatesFolder Then $App_Changed = True
	If $App_Changed Then
		Switch MsgBox(3, 'Changes have not been saved', 'Do you wish to save?')
			Case 6 ; Yes
				MenuItem_SaveClick()
			Case 7 ; No
				$App_Changed = False
				; Continue
			Case Else ; Cancel
				LockDown(False)
				Return 'Cancel'
		EndSwitch
	EndIf
	If $ExitState Then GUISetState(@SW_HIDE, $Form_ssEditor)
	If $ArchiveEditMode <> '' Then
		DirRemove($SrcPath, 1)
		$SrcPath = GetFolderPath($ArchiveEditMode)
		$UseOutputDir = IniRead($ssEditorINI, 'Options', 'Use Output Folder', '')
		$UseInputDir = ($UseOutputDir = '')
		MenuItem_UseDir() ;restore UseIn/OutputDir
		$ArchiveEditMode = ''
		ControlSetText('', '', $StatusBar_ssEditor, 'WorkingDir: "' & $SrcPath & '"')
		If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'WorkingDir: "' & $SrcPath & '"' & @CRLF)
		;$App_File = ''
	EndIf
	If $ReadOnlyEditMode <> '' Then
		$UseOutputDir = $ReadOnlyEditMode
		$UseInputDir = ($UseOutputDir = '')
		$IODirReset = False
		MenuItem_UseDir() ;restore UseIn/OutputDir
		$IODirReset = True
		$ReadOnlyEditMode = ''
	EndIf
	If $ExitState Then Return
	If $PathIn = '' Then
		Switch GetAppTypeBase($App_Type)
			Case 'ppGame'
				$PathOut = $SrcPath & '\' & GetAppTypeBase($App_Type) & '.ppg'
			Case ''
				$App_Type = 2
				$PathOut = $SrcPath & '\' & GetAppTypeBase($App_Type) & '.app'
			Case Else
				$PathOut = $SrcPath & '\' & GetAppTypeBase($App_Type) & '.app'
		EndSwitch
		Select
			Case StringInStr(@WorkingDir, $ppAppsDrive & '\ppApps\')
				$PathOut = FileSaveDialog('New SetupS-file', @WorkingDir, 'SetupS-file (*.app)', 2, 'ppApp.app')
				If @error <> 0 Then $ExitFunc = True
			Case StringInStr(@WorkingDir, $ppGamesDrive & '\ppGames\')
				$PathOut = FileSaveDialog('New SetupS-file', @WorkingDir, 'SetupS-file (*.ppg)', 2, 'ppGame.ppg')
				If @error <> 0 Then $ExitFunc = True
			Case StringInStr(@WorkingDir, @ProgramFilesDir) Or StringInStr(@WorkingDir, EnvGet('ProgramFiles(x86)'))
				$PathOut = FileSaveDialog('New SetupS-file', @WorkingDir, 'SetupS-file (*.app)', 2, 'ssApp.app')
				If @error <> 0 Then $ExitFunc = True
			Case FileExists($PathOut)
				Switch $App_Type
					Case 1, 2
						$PathOut = FileSaveDialog('New SetupS-file', @WorkingDir, 'SetupS-file (*.app)', 2, 'ssApp.app')
						If @error <> 0 Then $ExitFunc = True
					Case 3, 4
						$PathOut = FileSaveDialog('New SetupS-file', @WorkingDir, 'SetupS-file (*.app)', 2, 'ppApp.app')
						If @error <> 0 Then $ExitFunc = True
					Case 5
						$PathOut = FileSaveDialog('New SetupS-file', @WorkingDir, 'SetupS-file (*.ppg)', 2, 'ppGame.ppg')
						If @error <> 0 Then $ExitFunc = True
					Case Else
						$PathOut = FileSaveDialog('New SetupS-file', @WorkingDir, 'SetupS-file (*.app)|ppGame-file (*.ppg)', 2, '')
						If @error <> 0 Then $ExitFunc = True
				EndSwitch
		EndSelect
		If StringLeft($PathOut, StringLen($TemplatesFolder)) = $TemplatesFolder Then $ExitFunc = True ;Just get out if trying to set a new .app to the template path
		If Not $ExitFunc Then
			If FileExists($PathOut) And MsgBox(4, 'File exists', 'Overwrite? Selecting "Yes" will create an empty/blank SetupS-file.') <> 6 Then $ExitFunc = True
		EndIf
	EndIf
	If Not $ExitFunc Then
		_AppReset()
		If $PathIn = '' Then
			Switch $SaveFormat ;Test format saves
				Case 0 ; Legacy
					$WriteMode = 'Legacy'
				Case 1 ; Dual
					$WriteMode = 'Dual'
				Case 2 ; INI-only
					$WriteMode = 'New'
				Case 4 ; Update-only
					$WriteMode = 'Update'
				Case Else ; Default
					$WriteMode = ''
			EndSwitch
			Local $App_File = _AppWrite($PathOut, $WriteMode)
			If @WorkingDir = $TemplatesFolder Then FileDelete($App_File)
			$SrcPath = GetFolderPath($PathOut)
			SetOutputPath($SrcPath)
		EndIf
		NewForm()
		$App_Changed = False
		$FormMode = True
	EndIf
	LockDown(False)
EndFunc
Func MenuItem_NewFileWizardClick()
	MenuItem_OpenClick($TemplatesFolder)
EndFunc

Func MenuItem_OpenClick($PathIn = '')
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Open File' & @CRLF)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_OpenClick(): $PathIn = ' & $PathIn & @CRLF)
	If $NewForm And Not $DoNotSave Then
		MenuItem_NewClick('NotEmpty') ;clears any existing
	Else
		_AppReset()
	EndIf
	LockDown(True)
	$NewForm = True
	Local $App_ChangedOld, $StartIn = $PathIn, $temp
	If $StartIn = '' Then $StartIn = '.'
	If $PathIn = $TemplatesFolder Or $PathIn = '' Then
		If $UseTemplates Then
			$PathIn = FileOpenDialog('Open', $StartIn, 'SetupS-file (*.app;*.ini;*.ppg;*.apz;*.pgz)', 1)
		Else
			$PathIn = Open_ssCreator($TemplatesFolder)
		EndIf
	EndIf
	Select
		Case StringInStr(FileGetAttrib($PathIn), 'D') = 0 ; a file
			Switch StringRight($PathIn, 4)
				Case '.apz', '.pgz'
					If $ArchiveEditMode = '' And $ToolsPath <> '' Then
						If GetFileFromArchive('*' & StringLeft(StringLower(StringRight($PathIn, 4)), 2) & 'p' & StringMid(StringLower(StringRight($PathIn, 4)), 3, 1), $PathIn) Then
							GetFileFromArchive('*.mp4', $PathIn)
							GetFileFromArchive('*.jpg', $PathIn)
							GetFileFromArchive('*.png', $PathIn)
							GetFileFromArchive('*.ico', $PathIn)
							GetFileFromArchive('*.cmd', $PathIn)
							GetFileFromArchive('*.bat', $PathIn)
							GetFileFromArchive('*.reg', $PathIn)
							GetFileFromArchive('*.md5', $PathIn)
							$ArchiveEditMode = $PathIn
							$PathIn = $TempDir
						EndIf
					EndIf
				Case '.exe'
					$SrcPath = GetFolderPath($SrcPath)
					$temp = $SrcPath
					If GetSrcPath($temp) Then
						MenuItem_OpenClick($SrcPath)
						Return
					Else
						MenuItem_NewClick()
						Button_scFileClick($PathIn)
						Return
					EndIf
				Case '.lnk'
					Local $Details = FileGetShortcutEx($PathIn)
					If @error = 0 And IsArray($Details) Then
						$SrcPath = GetFolderPath($Details[0])
						$temp = $SrcPath
						If GetSrcPath($temp) Then
							MenuItem_OpenClick($SrcPath)
							Return
						Else
							MenuItem_NewClick()
							Button_scNameBrowseClick($PathIn)
							Return
						EndIf
					EndIf
			EndSwitch
		Case StringInStr(FileGetAttrib($PathIn), 'R') And $ReadOnlyEditMode = '' ;READONLY path (such as CDROM)
			$ForcedOutputMode = True
			$ReadOnlyEditMode = StringStripWS(IniRead($ssEditorINI, 'Options', 'Use Output Folder', ''), 3)
			$IODirReset = False
;~ 			$UseOutputDir = $TempDir
;~ 			;RunWait($CLIprefix & 'xcopy "' & $PathIn & '\*.*" "' & $TempDir & '\*.*" /e/s/y', '.', @SW_HIDE)
;~ 			If Not MenuItem_UseOutputDirClick() Then
;~ 				$DoNotSave = True
;~ 				Form_ssEditorClose()
;~ 			EndIf
			$IODirReset = True
	EndSelect
	If Not @error Then
		$FormMode = False
		Local $hOrigCur = CursorWait()
;~ 		SplashThis('Opening', 'Opening "' & $PathIn & '". Please wait...')
		$App_Changed = (@WorkingDir = $TemplatesFolder)
		ControlSetText('', '', $StatusBar_ssEditor, 'Reading file. Please wait...')
		If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Reading file.' & @CRLF)
		$App_File = _AppRead($PathIn, False, $GetVersionFromTitle)
		$tdApp = FileGetTime($App_File, 0, 1)
		If $ForcedOutputMode Then $App_Changed = False
		If $App_File = '' Then
			If $PathIn = '' Then $PathIn = @WorkingDir
			$SrcPath = $PathIn
		Else
			$SrcPath = GetFolderPath($App_File)
			$App_ChangedOld = $App_Changed
			Populate_Main()
			$App_Changed = $App_ChangedOld
		EndIf
		$PathIn = ''
		$FormMode = True
		;If $UseInputDir Then SetOutputPath($SrcPath)
		MenuItem_UseDir()
		If $ArchiveEditMode <> '' Then ;Force UseInputDir
			$ForcedInputMode = True
			MenuItem_UseInputDirClick()
		EndIf
		If $OutputPath = '' Then SetOutputPath($SrcPath)
	EndIf
	If $App_CmdFile <> '' Then $tdCmd = FileGetTime($SrcPath & '\' & GetAppTypeBase($App_Type) & '.cmd', 0, 1)
	If $App_RegFile <> '' Then $tdReg = FileGetTime($SrcPath & '\' & GetAppTypeBase($App_Type) & '.reg', 0, 1)
	LockDown(False)
EndFunc

Func MenuItem_Options_ActivateSendtoAutobuildClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_ActivateSendtoAutobuildClick()' & @CRLF)
	$ActivateSendtoAutobuild = Not $ActivateSendtoAutobuild
	If $ActivateSendtoAutobuild Then
		GUICtrlSetState($MenuItem_Options_ActivateSendtoAutobuild, $GUI_CHECKED)
;~ 		FileCreateShortcut(@ScriptDir & '\' & $ThisAppFilename & '.exe', $SendToPath & '\ssEditor(Autobuild).lnk', '', '-autobuild')
		If FileExists($SendToPath & '\ssEditor(Autobuild).lnk') Then FileDelete($SendToPath & '\ssEditor(Autobuild).lnk')
		FileCreateShortcut(@ScriptDir & '\' & $ThisAppFilename & '.exe', $SendToPath & '\ssEditor(Autobuild Archive).lnk', '', '-autobuild -MakeExpressInstaller=on', 'Builds archive deployment package(s)')
		FileCreateShortcut(@ScriptDir & '\' & $ThisAppFilename & '.exe', $SendToPath & '\ssEditor(Autobuild Folder).lnk', '', '-autobuild -MakeExpressInstaller=off', 'Builds folder deployment package(s)')
	Else
		GUICtrlSetState($MenuItem_Options_ActivateSendtoAutobuild, $GUI_UNCHECKED)
		If FileExists($SendToPath & '\ssEditor(Autobuild).lnk') Then FileDelete($SendToPath & '\ssEditor(Autobuild).lnk')
		If FileExists($SendToPath & '\ssEditor(Autobuild Archive).lnk') Then FileDelete($SendToPath & '\ssEditor(Autobuild Archive).lnk')
		If FileExists($SendToPath & '\ssEditor(Autobuild Folder).lnk') Then FileDelete($SendToPath & '\ssEditor(Autobuild Folder).lnk')
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Activate Sendto Autobuild', $ActivateSendtoAutobuild)
EndFunc

Func MenuItem_Options_CompressionLevel_DefaultClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_CompressionLevel_DefaultClick()' & @CRLF)
	$ArchiveCompressionLevel = 5
	NeoIniWrite($ssEditorINI, 'Options', 'Archive Compression Level', $ArchiveCompressionLevel)
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Default, $GUI_CHECKED) ;5
	GUICtrlSetState($MenuItem_Options_CompressionLevel_None, $GUI_UNCHECKED) ;0
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Fastest, $GUI_UNCHECKED) ;1
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Fast, $GUI_UNCHECKED) ;3
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Max, $GUI_UNCHECKED) ;7
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Ultra, $GUI_UNCHECKED) ;9
EndFunc
Func MenuItem_Options_CompressionLevel_FastClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_CompressionLevel_FastClick()' & @CRLF)
	$ArchiveCompressionLevel = 3
	NeoIniWrite($ssEditorINI, 'Options', 'Archive Compression Level', $ArchiveCompressionLevel)
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Default, $GUI_UNCHECKED) ;5
	GUICtrlSetState($MenuItem_Options_CompressionLevel_None, $GUI_UNCHECKED) ;0
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Fastest, $GUI_UNCHECKED) ;1
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Fast, $GUI_CHECKED) ;3
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Max, $GUI_UNCHECKED) ;7
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Ultra, $GUI_UNCHECKED) ;9
EndFunc
Func MenuItem_Options_CompressionLevel_FastestClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_CompressionLevel_FastestClick()' & @CRLF)
	$ArchiveCompressionLevel = 1
	NeoIniWrite($ssEditorINI, 'Options', 'Archive Compression Level', $ArchiveCompressionLevel)
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Default, $GUI_UNCHECKED) ;5
	GUICtrlSetState($MenuItem_Options_CompressionLevel_None, $GUI_UNCHECKED) ;0
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Fastest, $GUI_CHECKED) ;1
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Fast, $GUI_UNCHECKED) ;3
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Max, $GUI_UNCHECKED) ;7
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Ultra, $GUI_UNCHECKED) ;9
EndFunc
Func MenuItem_Options_CompressionLevel_MaxClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_CompressionLevel_MaxClick()' & @CRLF)
	$ArchiveCompressionLevel = 7
	NeoIniWrite($ssEditorINI, 'Options', 'Archive Compression Level', $ArchiveCompressionLevel)
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Default, $GUI_UNCHECKED) ;5
	GUICtrlSetState($MenuItem_Options_CompressionLevel_None, $GUI_UNCHECKED) ;0
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Fastest, $GUI_UNCHECKED) ;1
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Fast, $GUI_UNCHECKED) ;3
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Max, $GUI_CHECKED) ;7
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Ultra, $GUI_UNCHECKED) ;9
EndFunc
Func MenuItem_Options_CompressionLevel_NoneClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_CompressionLevel_NoneClick()' & @CRLF)
	$ArchiveCompressionLevel = 0
	NeoIniWrite($ssEditorINI, 'Options', 'Archive Compression Level', $ArchiveCompressionLevel)
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Default, $GUI_UNCHECKED) ;5
	GUICtrlSetState($MenuItem_Options_CompressionLevel_None, $GUI_CHECKED) ;0
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Fastest, $GUI_UNCHECKED) ;1
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Fast, $GUI_UNCHECKED) ;3
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Max, $GUI_UNCHECKED) ;7
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Ultra, $GUI_UNCHECKED) ;9
EndFunc
Func MenuItem_Options_CompressionLevel_UltraClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_CompressionLevel_UltraClick()' & @CRLF)
	$ArchiveCompressionLevel = 9
	NeoIniWrite($ssEditorINI, 'Options', 'Archive Compression Level', $ArchiveCompressionLevel)
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Default, $GUI_UNCHECKED) ;5
	GUICtrlSetState($MenuItem_Options_CompressionLevel_None, $GUI_UNCHECKED) ;0
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Fastest, $GUI_UNCHECKED) ;1
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Fast, $GUI_UNCHECKED) ;3
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Max, $GUI_UNCHECKED) ;7
	GUICtrlSetState($MenuItem_Options_CompressionLevel_Ultra, $GUI_CHECKED) ;9
EndFunc

Func MenuItem_Options_CompressionLevelClick()
EndFunc

Func MenuItem_Options_ExpressInstallerClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_ExpressInstallerClick()' & @CRLF)
	$MakeExpressInstaller = Not $MakeExpressInstaller
	If $MakeExpressInstaller Then
		GUICtrlSetState($MenuItem_Options_ExpressInstaller, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_Options_WebfriendlyFilenames, $GUI_ENABLE)
		If $App_Type > 0 Then GUICtrlSetState($Button_Build, $GUI_ENABLE)
	Else
		GUICtrlSetState($MenuItem_Options_ExpressInstaller, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_WebfriendlyFilenames, $GUI_DISABLE)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Build Archive Deployment Package', $MakeExpressInstaller)
	BuildOptToggle()
EndFunc

Func MenuItem_Options_GetVersionFromTitleClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_GetVersionFromTitleClick()' & @CRLF)
	$GetVersionFromTitle = Not $GetVersionFromTitle
	If $GetVersionFromTitle Then
		GUICtrlSetState($MenuItem_Options_GetVersionFromTitle, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_Options_GetVersionFromTitle, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Get Version from Title', $GetVersionFromTitle)
EndFunc

Func MenuItem_Options_IconViewSizeClick()
EndFunc

Func MenuItem_Options_OutputDir_ChooseClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_OutputDir_ChooseClick()' & @CRLF)
	$UseOutputDir = FileSelectFolder('Browse for Output Path', '', 7)
	If @error = 1 And $UseOutputDir = '' Then Return True
	If $UseOutputDir = '' Then
		MenuItem_UseInputDirClick()
	Else
		MenuItem_UseOutputDirClick()
	EndIf
	Return False
EndFunc
Func MenuItem_Options_OutputDirClick()
EndFunc

Func MenuItem_Options_SaveDefaultClick() ;$SaveFormat=3 (Default)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_SaveUpdateOnlyClick()' & @CRLF)
	GUICtrlSetState($MenuItem_Options_SaveDefault, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_Options_SaveLegacyFormat, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_Options_SaveDualFormat, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_Options_SaveINIFormat, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_Options_SaveUpdateOnly, $GUI_UNCHECKED)
	$SaveFormat = 3
	NeoIniWrite($ssEditorINI, 'Options', 'Save Format', '3 (Default)')
EndFunc

Func MenuItem_Options_SaveDualFormatClick() ;$SaveFormat=1 (Dual)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_SaveDualFormatClick()' & @CRLF)
	If $SaveFormat = 1 Then
		GUICtrlSetState($MenuItem_Options_SaveDualFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDefault, $GUI_CHECKED)
		$SaveFormat = 3
	Else
		GUICtrlSetState($MenuItem_Options_SaveDualFormat, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_Options_SaveINIFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveUpdateOnly, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveLegacyFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDefault, $GUI_UNCHECKED)
		$SaveFormat = 1
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Save Format', '1 (Dual)')
EndFunc

Func MenuItem_Options_SaveFormatClick()
EndFunc

Func MenuItem_Options_SaveINIFormatClick() ;$SaveFormat=2 (INI)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_SaveINIFormatClick()' & @CRLF)
	If $SaveFormat = 2 Then
		GUICtrlSetState($MenuItem_Options_SaveINIFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDefault, $GUI_CHECKED)
		$SaveFormat = 3
	Else
		GUICtrlSetState($MenuItem_Options_SaveINIFormat, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDualFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveUpdateOnly, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveLegacyFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDefault, $GUI_UNCHECKED)
		$SaveFormat = 2
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Save Format', '2 (INI)')
EndFunc

Func MenuItem_Options_SaveLegacyFormatClick() ;$SaveFormat=0 (Legacy)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_SaveLegacyFormatClick()' & @CRLF)
	If $SaveFormat = 0 Then
		GUICtrlSetState($MenuItem_Options_SaveLegacyFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDefault, $GUI_CHECKED)
		$SaveFormat = 3
	Else
		GUICtrlSetState($MenuItem_Options_SaveLegacyFormat, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDualFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveINIFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveUpdateOnly, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDefault, $GUI_UNCHECKED)
		$SaveFormat = 0
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Save Format', '0 (Legacy)')
EndFunc

Func MenuItem_Options_SaveUpdateOnlyClick() ;$SaveFormat=4 (Update-only)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_SaveUpdateOnlyClick()' & @CRLF)
	If $SaveFormat = 4 Then
		GUICtrlSetState($MenuItem_Options_SaveUpdateOnly, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDefault, $GUI_CHECKED)
		$SaveFormat = 3
	Else
		GUICtrlSetState($MenuItem_Options_SaveUpdateOnly, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDualFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveINIFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveLegacyFormat, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_Options_SaveDefault, $GUI_UNCHECKED)
		$SaveFormat = 4
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Save Format', '4 (Update-only)')
EndFunc
Func MenuItem_Options_ScreenCapture_QualityClick()
EndFunc
Func MenuItem_Options_ScreenCapture_SizeClick()
EndFunc
Func MenuItem_Options_ScreenCaptureClick()
EndFunc

Func MenuItem_Options_scTargetSearchClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_scTargetSearchClick()' & @CRLF)
	$StartMenuTargetSearch = Not $StartMenuTargetSearch
	If $StartMenuTargetSearch Then
		GUICtrlSetState($MenuItem_Options_scTargetSearch, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_Options_scTargetSearch, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'StartMenu Target Search', $StartMenuTargetSearch)
EndFunc

Func MenuItem_Options_WebfriendlyFilenamesClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_Options_WebfriendlyFilenamesClick()' & @CRLF)
	$WebfriendlyFilenames = Not $WebfriendlyFilenames
	If $WebfriendlyFilenames Then
		GUICtrlSetState($MenuItem_Options_WebfriendlyFilenames, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_Options_WebfriendlyFilenames, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Webfriendly Filenames', $WebfriendlyFilenames)
	BuildOptToggle()
EndFunc

Func MenuItem_OptionsClick()
EndFunc

Func MenuItem_OptionsResetClick()
	Local $App_File_Path = GetFolderPath($App_File), $TempDL = GenerateTempFolder()
	ResetINI($ThisAppFilename & '.ini')
	Local $File = FileOpen($TempDL & '\' & 'ResetMe.cmd', 10)
	If $File <> -1 Then
		FileWrite($File, 'cd ..' & @CRLF)
		If $App_File_Path <> '' Then
			FileWrite($File, '"' & @ScriptFullPath & '" "' & $App_File_Path & '" -AutoUpdate=' & $TempDL & @CRLF)
		Else
			FileWrite($File, '"' & @ScriptFullPath & '" -AutoUpdate=' & $TempDL & @CRLF)
		EndIf
		FileWrite($File, 'exit' & @CRLF)
		FileClose($File)
		FileChangeDir($TempDL)
		If $SetupSFolder <> '' And Not StringInStr(EnvGet('Path'), $SetupSFolder) Then EnvSet('path', $SetupSFolder & ';' & EnvGet('path'))
		Run('ResetMe.cmd', $TempDL, @SW_HIDE)
		Sleep(100)
		FileChangeDir(@ScriptDir)
		Cleanup()
		Exit
	EndIf
EndFunc

Func MenuItem_OptionsTagSortingAlphaClick()
	GUICtrlSetState($MenuItem_OptionsTagSortingAlpha, $GUI_CHECKED)
	GUICtrlSetState($MenuItem_OptionsTagSortingGroups, $GUI_UNCHECKED)
	$SortTags = 0
	NeoIniWrite($ssEditorINI, 'Options', 'Tag Sorting', 'Alphabetical')
	_ArraySort($Tags, 0, 1, 0, $SortTags)
	PopulateCombo_Tags()
EndFunc

Func MenuItem_OptionsTagSortingClick()
EndFunc

Func MenuItem_OptionsTagSortingGroupsClick()
	GUICtrlSetState($MenuItem_OptionsTagSortingAlpha, $GUI_UNCHECKED)
	GUICtrlSetState($MenuItem_OptionsTagSortingGroups, $GUI_CHECKED)
	$SortTags = 1
	NeoIniWrite($ssEditorINI, 'Options', 'Tag Sorting', 'Groups')
	_ArraySort($Tags, 0, 1, 0, $SortTags)
	PopulateCombo_Tags()
EndFunc

Func MenuItem_PatchCompressClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_PatchCompressClick()' & @CRLF)
	$PatchCompress = Not $PatchCompress
	If $PatchCompress Then
		GUICtrlSetState($MenuItem_PatchCompress, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_PatchCompress, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Patch Compress', $PatchCompress)
	BuildOptToggle()
EndFunc

Func MenuItem_ppCompressClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_ppCompressClick()' & @CRLF)
	$ppCompress = Not $ppCompress
	If $ppCompress Then
		GUICtrlSetState($MenuItem_ppCompress, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_ppCompress, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'ppCompress', $ppCompress)
	BuildOptToggle()
EndFunc

Func MenuItem_SaveAsClick()
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'File, Save As' & @CRLF)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_SaveAsClick()' & @CRLF)
	Local $PathOut = '', $ExitFunc = False, $WriteMode, $InitDir
	LockDown()
	$FormMode = False
	Local $n
	If $ExitState Then GUISetState(@SW_HIDE, $Form_ssEditor)
	If $ArchiveEditMode <> '' Then
		DirRemove($SrcPath, 1)
		$SrcPath = GetFolderPath($ArchiveEditMode)
		$UseOutputDir = IniRead($ssEditorINI, 'Options', 'Use Output Folder', '')
		$UseInputDir = ($UseOutputDir = '')
		MenuItem_UseDir() ;restore UseIn/OutputDir
		$ArchiveEditMode = ''
		ControlSetText('', '', $StatusBar_ssEditor, 'WorkingDir: "' & $SrcPath & '"')
		If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'WorkingDir: "' & $SrcPath & '"' & @CRLF)
	EndIf
	If $ReadOnlyEditMode <> '' Then
		$UseOutputDir = $ReadOnlyEditMode
		$UseInputDir = ($UseOutputDir = '')
		$IODirReset = False
		MenuItem_UseDir() ;restore UseIn/OutputDir
		$IODirReset = True
		$ReadOnlyEditMode = ''
	EndIf
	If $ExitState Then Return
	Switch GetAppTypeBase($App_Type)
		Case 'ppGame'
			$PathOut = $SrcPath & '\' & GetAppTypeBase($App_Type) & '.ppg'
		Case ''
			$App_Type = 2
			$PathOut = $SrcPath & '\' & GetAppTypeBase($App_Type) & '.app'
		Case Else
			$PathOut = $SrcPath & '\' & GetAppTypeBase($App_Type) & '.app'
	EndSwitch
	$InitDir = @WorkingDir
	If $InitDir = $TemplatesFolder Then $InitDir = '::{450D8FBA-AD25-11D0-98A8-0800361B1103}'
	Select
		Case StringInStr($InitDir, $ppAppsDrive & '\ppApps\')
			$PathOut = FileSaveDialog('Save As', $InitDir, 'SetupS-file (*.app)', 2, 'ppApp.app')
			If @error <> 0 Then $ExitFunc = True
		Case StringInStr($InitDir, $ppGamesDrive & '\ppGames\')
			$PathOut = FileSaveDialog('Save As', $InitDir, 'SetupS-file (*.ppg)', 2, 'ppGame.ppg')
			If @error <> 0 Then $ExitFunc = True
		Case StringInStr($InitDir, @ProgramFilesDir) Or StringInStr($InitDir, EnvGet('ProgramFiles(x86)'))
			$PathOut = FileSaveDialog('Save As', $InitDir, 'SetupS-file (*.app)', 2, 'ssApp.app')
			If @error <> 0 Then $ExitFunc = True
		Case FileExists($PathOut)
			Switch $App_Type
				Case 1, 2
					$PathOut = FileSaveDialog('Save As', $InitDir, 'SetupS-file (*.app)', 2, 'ssApp.app')
					If @error <> 0 Then $ExitFunc = True
				Case 3, 4
					$PathOut = FileSaveDialog('Save As', $InitDir, 'SetupS-file (*.app)', 2, 'ppApp.app')
					If @error <> 0 Then $ExitFunc = True
				Case 5
					$PathOut = FileSaveDialog('Save As', $InitDir, 'SetupS-file (*.ppg)', 2, 'ppGame.ppg')
					If @error <> 0 Then $ExitFunc = True
				Case Else
					$PathOut = FileSaveDialog('Save As', $InitDir, 'SetupS-file (*.app)|ppGame-file (*.ppg)', 2, '')
					If @error <> 0 Then $ExitFunc = True
			EndSwitch
		Case Else
			Switch $App_Type
				Case 1, 2
					$PathOut = FileSaveDialog('Save As', $InitDir, 'SetupS-file (*.app)', 2, 'ssApp.app')
					If @error <> 0 Then $ExitFunc = True
				Case 3, 4
					$PathOut = FileSaveDialog('Save As', $InitDir, 'SetupS-file (*.app)', 2, 'ppApp.app')
					If @error <> 0 Then $ExitFunc = True
				Case 5
					$PathOut = FileSaveDialog('Save As', $InitDir, 'SetupS-file (*.ppg)', 2, 'ppGame.ppg')
					If @error <> 0 Then $ExitFunc = True
				Case Else
					$PathOut = FileSaveDialog('Save As', $InitDir, 'SetupS-file (*.app)|ppGame-file (*.ppg)', 2, '')
					If @error <> 0 Then $ExitFunc = True
			EndSwitch
	EndSelect
	If StringLeft($PathOut, StringLen($TemplatesFolder)) = $TemplatesFolder Then $ExitFunc = True ;Just get out if trying to set a new .app to the template path
	If Not $ExitFunc Then
		If 0 <= $SaveFormat And $SaveFormat <= 2 Then
			If FileExists($PathOut) And MsgBox(4, 'File exists', 'Overwrite?') <> 6 Then $ExitFunc = True
		EndIf
	EndIf
	If Not $ExitFunc Then
		If $PathIn = '' Then
			Switch $SaveFormat ;Test format saves
				Case 0 ; Legacy
					$WriteMode = 'Legacy'
				Case 1 ; Dual
					$WriteMode = 'Dual'
				Case 2 ; INI-only
					$WriteMode = 'New'
				Case 4 ; Update-only
					$WriteMode = 'Update'
				Case Else ; Default
					$WriteMode = ''
			EndSwitch
			_AppWrite($PathOut, $WriteMode)
			$App_File = GetFilename($PathOut)
			$SrcPath = GetFolderPath($PathOut)
			SetOutputPath($SrcPath)
		EndIf
		$App_Changed = False
		$FormMode = True
	EndIf
	LockDown(False)
EndFunc

Func MenuItem_SaveClick()
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Save File' & @CRLF)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_SaveClick()' & @CRLF)
	If @WorkingDir = $TemplatesFolder Then
		MenuItem_SaveAsClick()
		Return
	EndIf
	LockDown()
	Local $App_FileCurrent = $App_File, $App_InstallPath_New = '', $i, $j, $CurrentWorkingDir, $NewFile, $WriteMode = '', $temp, $td2
	$OutputPathCurrent = $OutputPath
	ReadFormData()
	If $App_Type = 0 Then $App_Type = 2
	If $App_InstallPath = '' Then $App_InstallPath = GetAppPathComplete($App_InstallPath)
	If $App_smSource = '' Then $App_smSource = GetApp_smSource($App_smSource)
	If $SrcPath <> $OutputPathCurrent Then
		SetOutputPath($OutputPath & '\' & GetFilename($App_InstallPath))
		$App_File = $OutputPath & '\' & GetFilename($App_File)
	EndIf
	If $App_InstallPath = '' Then ; assign a derived one
		Select
			Case $App_Title <> ''
				$App_InstallPath_New = StringFilterFilename($App_Title, False, True)
			Case $App_smSource <> ''
				$App_InstallPath_New = StringFilterFilename(GetFilename($App_smSource), False, True)
		EndSelect
	Else
		If Not (StringInStr($App_InstallPath, ':') Or StringInStr($App_InstallPath, '%')) Then
			If Not GetInstallPath($App_InstallPath) Then $App_InstallPath_New = StringFilterFilename($App_InstallPath, True)
		ElseIf StringInStr($App_InstallPath, @ProgramFilesDir & '\') Or StringInStr($App_InstallPath, $ppAppsDrive & '\ppApps\') Or StringInStr($App_InstallPath, $ppGamesDrive & '\ppGames\') Then
			$App_InstallPath_New = StringFilterFilename(NormalizeInstallPath(ConvertFromVars($App_InstallPath)), True)
		EndIf
	EndIf
	If $App_InstallPath_New <> '' Then
		Switch $App_Type
			Case 1, 2
				$App_InstallPath = @ProgramFilesDir & '\' & $App_InstallPath_New
			Case 3, 4
				$App_InstallPath = $ppAppsDrive & '\ppApps\' & $App_InstallPath_New
			Case 5
				$App_InstallPath = $ppGamesDrive & '\ppGames\' & $App_InstallPath_New
		EndSwitch
	EndIf
	If $App_File = '' Then
		If $OutputPath = '' Then $OutputPath = FileSelectFolder('Save to (folder)', '.', 7)
		Switch $App_Type
			Case 1
				$App_File = $OutputPath & '\SetupS.app'
			Case 2
				$App_File = $OutputPath & '\ssApp.app'
			Case 3, 4
				$App_File = $OutputPath & '\ppApp.app'
			Case 5
				$App_File = $OutputPath & '\ppGame.ppg'
			Case Else
				Return
		EndSwitch
	EndIf
	If $App_Type < 3 And $App_scKeep[0] = 0 And $App_scCount > 0 And Not $App_KeepAll Then
		;Assume that if all theses conditions are met then this is what was really intended
		If $App_MakeStartMenu Or $App_MakeInRoot Or $App_MakeInPrograms Or $App_MakeStartup Or $App_MakeDesktop Or $App_MakeQuickLaunch Or $App_TaskbarPin Or $App_StartmenuPin Or $App_MakeSendTo Then
			$App_scKeep[0] += 1
			ReDim $App_scKeep[$App_scKeep[0] + 1]
			$App_scKeep[$App_scKeep[0]] = $App_scLNK[1]
		EndIf
	EndIf
	For $i = 1 To $App_scCount ;fix up any "duplicates" found
		$j = StringInStr($App_scLNK[$i], ' {#')
		If $j > 0 And StringInStr($App_scLNK[$i], '}', $j + 3) Then $App_scLNK[$i] = StringMid($App_scLNK[$i], 1, $j - 1)
	Next
	Switch $SaveFormat ;Test format saves
		Case 0 ; Legacy
			$WriteMode = 'Legacy'
			$App_FileFormat = 0
			$NewFile = $App_File & '.new'
		Case 1 ; Dual
			$WriteMode = 'Dual'
			$NewFile = $App_File & '.new'
		Case 2 ; INI-only
			$WriteMode = 'New'
			$NewFile = $App_File & '.new'
		Case 4 ; Update-only
			$WriteMode = 'Update'
			$NewFile = $App_File
		Case Else ; Default
			$WriteMode = ''
			$NewFile = $App_File
	EndSwitch
	If $WriteMode = '' Then
		If VersionCompare($SetupSFileVersion, '=', '9') Then ;GetVersionNumber($SetupSFileVersion) = 9
			If $App_FileFormat = 0 Then
				$WriteMode = 'New'
				$NewFile = $App_File & '.new'
			EndIf
		Else ; 'Legacy' still
			$WriteMode = 'Legacy'
			$App_FileFormat = 0
			$NewFile = $App_File & '.new'
		EndIf
	EndIf
	ControlSetText('', '', $StatusBar_ssEditor, 'Writing file. Please wait...')
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Writing file.' & @CRLF)
	$NewFile = _AppWrite($NewFile, $WriteMode)
	If $NewFile <> $App_File Then
		If $App_FileCurrent <> '' Then
			If FileExists($OutputPath & '\' & GetFilename($App_FileCurrent)) Then
				FileDelete($OutputPath & '\' & GetFilename($App_FileCurrent))
			EndIf
		EndIf
		If $ArchiveEditMode <> '' Then
			If FileExists($App_File) Then FileDelete($App_File)
		EndIf
		Select
			Case (GetFilename($App_FileCurrent) = 'SetupS.ini')
				$App_File = $OutputPath & '\SetupS.app'
			Case (GetFilename($App_FileCurrent) = 'ppApp.ini')
				$App_File = $OutputPath & '\ppApp.app'
		EndSelect
		FileDelete($App_File)
		FileMove($NewFile, $App_File)
	EndIf
	Local $App_File_Path = GetFolderPath($App_File)
	Switch GetFilename($App_File)
		Case 'SetupS.app'
			Switch $App_Type
				Case 1, 2
					MoveExt('SetupS', 'ssApp')
					$App_File = 'ssApp.app'
				Case 3, 4
					MoveExt('SetupS', 'ppApp')
					$App_File = 'ppApp.app'
				Case 5
					MoveExt('SetupS', 'ppGame')
					$App_File = 'ppGame.ppg'
			EndSwitch
		Case 'ssApp.app'
			Switch $App_Type
				Case 3, 4
					MoveExt('ssApp', 'ppApp')
					$App_File = 'ppApp.app'
				Case 5
					MoveExt('ssApp', 'ppGame')
					$App_File = 'ppGame.ppg'
			EndSwitch
		Case 'ppApp.app'
			Switch $App_Type
				Case 1, 2
					MoveExt('ppApp', 'ssApp')
					$App_File = 'ssApp.app'
				Case 5
					MoveExt('ppApp', 'ppGame')
					$App_File = 'ppGame.ppg'
			EndSwitch
		Case 'ppGame.ppg'
			Switch $App_Type
				Case 1, 2
					MoveExt('ppGame', 'ssApp')
					$App_File = 'ssApp.app'
				Case 3, 4
					MoveExt('ppGame', 'ppApp')
					$App_File = 'ppApp.app'
			EndSwitch
	EndSwitch
	ChangeFilenameScheme('.mp4', $App_File_Path)
	
	ChangeFilenameScheme('.jpg', $App_File_Path)
;~ 	DeleteDuplicates($App_File_Path, GetAppTypeBase($App_Type) & '.jpg', '.jpg')
	If FileExists(GetAppTypeBase($App_Type) & '.jpg') Then
		GUICtrlSetState($Button_ScrShot, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewScrShot, $GUI_ENABLE)
	Else
		GUICtrlSetState($Button_ScrShot, $GUI_DISABLE)
		GUICtrlSetState($MenuItem_ViewScrShot, $GUI_DISABLE)
	EndIf
	ChangeFilenameScheme('.png', $App_File_Path)
;~ 	DeleteDuplicates($App_File_Path, GetAppTypeBase($App_Type) & '.png', '.png')
	If FileExists(GetAppTypeBase($App_Type) & '.png') Then
		GUICtrlSetState($Button_Fader, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewFader, $GUI_ENABLE)
	Else
		GUICtrlSetState($Button_Fader, $GUI_DISABLE)
		GUICtrlSetState($MenuItem_ViewFader, $GUI_DISABLE)
	EndIf
	ChangeFilenameScheme('.ico', $App_File_Path)
;~ 	DeleteDuplicates($App_File_Path, GetAppTypeBase($App_Type) & '.ico', '.ico')
	If FileExists(GetAppTypeBase($App_Type) & '.ico') Then
		GUICtrlSetState($Button_Icon, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewIcon, $GUI_ENABLE)
	Else
		GUICtrlSetState($Button_Icon, $GUI_DISABLE)
		GUICtrlSetState($MenuItem_ViewIcon, $GUI_DISABLE)
	EndIf
	ChangeFilenameScheme('.cmd', $App_File_Path)
;~ 	DeleteDuplicates($App_File_Path, GetAppTypeBase($App_Type) & '.cmd', '.cmd')
;~ 	DeleteDuplicates($App_File_Path, GetAppTypeBase($App_Type) & '.cmd', '.bat')
	If FileExists(GetAppTypeBase($App_Type) & '.cmd') Then
		$temp = GetAppTypeBase($App_Type) & '.cmd'
		$td2 = FileGetTime($temp, 0, 1)
		If $td2 <> $tdCmd Then
			$App_CmdFile = File2String($temp)
			$Edit_Cmd_Data = $App_CmdFile
			GUICtrlSetData($Edit_Cmd, $Edit_Cmd_Data)
			$tdCmd = $td2
		EndIf
		GUICtrlSetState($Button_cmd, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewCMD, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_ENABLE)
	Else
		GUICtrlSetState($Button_cmd, $GUI_DISABLE)
		GUICtrlSetState($MenuItem_ViewCMD, $GUI_DISABLE)
		GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_DISABLE)
	EndIf
	ChangeFilenameScheme('.reg', $App_File_Path)
;~ 	DeleteDuplicates($App_File_Path, GetAppTypeBase($App_Type) & '.reg', '.reg')
	If FileExists(GetAppTypeBase($App_Type) & '.reg') Then
		$temp = GetAppTypeBase($App_Type) & '.reg'
		$td2 = FileGetTime($temp, 0, 1)
		If $td2 <> $tdReg Then
			$App_RegFile = File2String($temp)
			$Edit_Reg_Data = $App_RegFile
			GUICtrlSetData($Edit_Reg, $Edit_Reg_Data)
			$App_Changed = True
			$tdReg = $td2
		EndIf
		GUICtrlSetState($Button_Reg, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewReg, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_ENABLE)
	Else
		GUICtrlSetState($Button_Reg, $GUI_DISABLE)
		GUICtrlSetState($MenuItem_ViewReg, $GUI_DISABLE)
		GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_DISABLE)
	EndIf
	If $ArchiveEditMode <> '' Then
		SplashThis('Updating', 'Updating archive file. Please wait ...')
		ControlSetText('', '', $StatusBar_ssEditor, 'Updating archive file. Please wait ...')
		_Crypt_Startup()
		UpdateArchive(GetFilename($App_File), $ArchiveEditMode)
		UpdateArchive(GetAppTypeBase($App_Type) & '.mp4', $ArchiveEditMode)
		UpdateArchive(GetAppTypeBase($App_Type) & '.jpg', $ArchiveEditMode)
		UpdateArchive(GetAppTypeBase($App_Type) & '.png', $ArchiveEditMode)
		UpdateArchive(GetAppTypeBase($App_Type) & '.ico', $ArchiveEditMode)
		UpdateArchive(GetAppTypeBase($App_Type) & '.cmd', $ArchiveEditMode)
		UpdateArchive(GetAppTypeBase($App_Type) & '.reg', $ArchiveEditMode)
		_Crypt_Shutdown()
		AddFileToArchive(GetAppTypeBase($App_Type) & '.md5', $ArchiveEditMode)
		SplashOff()
	EndIf
	If $OutputPathCurrent <> '' Then SetOutputPath($OutputPathCurrent)
	$NewForm = False
	If $App_Changed And $ArchiveEditMode = '' Then MenuItem_OpenClick($App_File_Path)
	$App_Changed = False
	Update_Explorer()
	LockDown(False)
EndFunc

Func MenuItem_ScreenCaptureClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_ScreenCaptureClick()' & @CRLF)
	Local $n = $OutputPath
	$OutputPathCurrent = $OutputPath
	If $SrcPath <> $OutputPath Then $n = $n & '\' & GetFilename($App_InstallPath)
	Switch MsgBox(3, 'Screen Capture Activated', 'Simply press the "Print Screen" key to capture whatever active window is showing and a screenshot file will be created in: ' & @CRLF & '"' & $n & '"' & @CRLF & @CRLF & 'Do you wish to Continue?')
		Case 6 ; Yes
			; Continue
		Case Else ; Cancel
			$OutputPathCurrent = ''
			Return 'Cancel'
	EndSwitch
	If $SrcPath <> $OutputPathCurrent Then SetOutputPath($OutputPath & '\' & GetFilename($App_InstallPath))
	HotKeySet('{PRINTSCREEN}', 'TakeScreenShot')
EndFunc

Func MenuItem_ScreenshotToolsClick()
EndFunc

Func MenuItem_SetupSTestClick()
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Test SetupS' & @CRLF)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_SetupSTestClick()' & @CRLF)
	LockDown()
	Run($SetupS & ' "' & @WorkingDir & '" -Fadertainer=On -FaderOnTop=Yes')
	LockDown(False)
EndFunc

Func MenuItem_TaskmgrClick()
	Run('taskmgr.exe')
EndFunc

Func MenuItem_ToolsClick()
EndFunc

Func MenuItem_UseDir()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_UseDir()' & @CRLF)
	Local $Cancel = False
	If $UseInputDir Then
		GUICtrlSetState($MenuItem_UseInputDir, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_UseOutputDir, $GUI_UNCHECKED)
		$UseOutputDir = ''
		SetOutputPath($SrcPath)
		;$App_File = ''
	Else
		GUICtrlSetState($MenuItem_UseInputDir, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_UseOutputDir, $GUI_CHECKED)
		If $UseOutputDir = '' Then
			$Cancel = MenuItem_Options_OutputDir_ChooseClick()
		EndIf
		If Not $Cancel Then SetOutputPath($UseOutputDir)
		;$App_File = ''
	EndIf
	If Not $Cancel Then BuildOptToggle()
	Return $Cancel
EndFunc

Func MenuItem_UseInputDirClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_UseInputDirClick()' & @CRLF)
	$UseInputDir = True
	MenuItem_UseDir()
	If $ArchiveEditMode = '' Then
		NeoIniWrite($ssEditorINI, 'Options', 'Use Output Folder', $UseOutputDir)
		If $SrcPath <> '' And $IODirReset Then
			$DoNotSave = True
			MenuItem_OpenClick($SrcPath)
			$DoNotSave = False
		EndIf
		GUICtrlSetState($MenuItem_UseInputDir, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_UseOutputDir, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_Options_OutputDir_Choose, $GUI_ENABLE)
	Else
		GUICtrlSetState($MenuItem_UseInputDir, $GUI_DISABLE)
		GUICtrlSetState($MenuItem_UseOutputDir, $GUI_DISABLE)
		GUICtrlSetState($MenuItem_Options_OutputDir_Choose, $GUI_DISABLE)
	EndIf
EndFunc

Func MenuItem_UseLZMA2Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_UseLZMA2Click()' & @CRLF)
	$UseLZMA2 = Not $UseLZMA2
	If $UseLZMA2 Then
		GUICtrlSetState($MenuItem_UseLZMA2, $GUI_CHECKED)
	Else
		GUICtrlSetState($MenuItem_UseLZMA2, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Use LZMA2', $UseLZMA2)
EndFunc

Func MenuItem_UseOutputDirClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_UseOutputDirClick()' & @CRLF)
	$UseInputDir = False
	Local $Cancel = MenuItem_UseDir()
	If $ArchiveEditMode = '' And Not $Cancel Then
		NeoIniWrite($ssEditorINI, 'Options', 'Use Output Folder', $UseOutputDir)
		If $SrcPath <> '' And $IODirReset Then
			$DoNotSave = True
			MenuItem_OpenClick($SrcPath)
			$DoNotSave = False
		EndIf
		GUICtrlSetState($MenuItem_UseInputDir, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_UseOutputDir, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_Options_OutputDir_Choose, $GUI_ENABLE)
	Else
		GUICtrlSetState($MenuItem_UseInputDir, $GUI_DISABLE)
		GUICtrlSetState($MenuItem_UseOutputDir, $GUI_DISABLE)
		GUICtrlSetState($MenuItem_Options_OutputDir_Choose, $GUI_DISABLE)
	EndIf
	Return Not $Cancel
EndFunc

Func MenuItem_UseRARClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_UseRARClick()' & @CRLF)
	$UseRAR = Not $UseRAR
	If $UseRAR Then
		GUICtrlSetState($MenuItem_UseRAR, $GUI_CHECKED)
		GUICtrlSetState($MenuItem_UseLZMA2, $GUI_DISABLE)
		GUICtrlSetState($MenuItem_UseLZMA2, $GUI_HIDE)
	Else
		GUICtrlSetState($MenuItem_UseRAR, $GUI_UNCHECKED)
		GUICtrlSetState($MenuItem_UseLZMA2, $GUI_SHOW)
		GUICtrlSetState($MenuItem_UseLZMA2, $GUI_ENABLE)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'Use RAR', $UseRAR)
EndFunc

Func MenuItem_ViewClick()
EndFunc

Func MenuItem_ViewFileVersionClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_ViewFileVersionClick()' & @CRLF)
	$ViewFileVersionInfo = Not $ViewFileVersionInfo
	If $ViewFileVersionInfo Then
		GUICtrlSetState($MenuItem_ViewFileVersion, $GUI_CHECKED)
		GUICtrlSetState($Label_FileVersion, $GUI_SHOW)
	Else
		GUICtrlSetState($MenuItem_ViewFileVersion, $GUI_UNCHECKED)
		GUICtrlSetState($Label_FileVersion, $GUI_HIDE)
	EndIf
	NeoIniWrite($ssEditorINI, 'Options', 'View File Version Info', $ViewFileVersionInfo)
EndFunc

Func MenuItem_ViewInNotepadClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MenuItem_ViewInNotepadClick()' & @CRLF)
	If $App_File <> '' Then
		RunWait('notepad ' & $App_File)
		Local $td2 = FileGetTime($App_File, 0, 1)
		If $td2 <> $tdApp Then
			MenuItem_OpenClick(GetFolderPath($App_File))
			$tdApp = $td2
		EndIf
	EndIf
EndFunc

Func MoveExt($From, $To)
	Local $temp
	If FileExists($To & '.reg') Then
		FileMove($To & '.reg', 'save.' & $To & '.reg')
	EndIf
	If FileExists($To & '.cmd') Then
		FileMove($To & '.cmd', 'save.' & $To & '.cmd')
	EndIf
	FileDelete($To & '.*')
	DirRemove($To, 1)
	FileCopy($From & '.*', $To & '.*')
	DirCopy($From, $To)
	FileDelete($From & '.*')
	DirRemove($From, 1)
	If FileExists('save.' & $To & '.reg') Then
		FileMove('save.' & $To & '.reg', $To & '.reg')
	EndIf
	If FileExists('save.' & $To & '.cmd') Then
		FileMove('save.' & $To & '.cmd', $To & '.cmd')
	EndIf
	Select
		Case FileExists('ppGame.app')
			FileDelete('ppGame.ppg')
			FileCopy('ppGame.app', 'ppGame.ppg')
			FileDelete('ppGame.app')
		Case FileExists('ppApp.ppg')
			FileDelete('ppApp.app')
			FileCopy('ppApp.ppg', 'ppApp.app')
			FileDelete('ppApp.ppg')
		Case FileExists('ssApp.ppg')
			FileDelete('ssApp.app')
			FileCopy('ssApp.ppg', 'ssApp.app')
			FileDelete('ssApp.ppg')
	EndSelect
EndFunc

Func MY_WM_COMMAND($hWnd, $msg, $wParam, $lParam)
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MY_WM_COMMAND()' & @CRLF)
	If $FormMode Then
		Local $nNotifyCode = _HiWord($wParam), $hCtrl = $lParam, $nID = _LoWord($wParam)
		Switch $nID
			Case $Input_AppPath
				Switch $nNotifyCode
					Case $EN_CHANGE ; 0x300
						$AppPathChange = True
					Case $EN_KILLFOCUS ; 0x200
						If $AppPathChange Then
							$AppPathChange = False
							Input_AppPathChange()
						EndIf
					Case $EN_UPDATE ; 0x400
						$AppPathChange = True
				EndSwitch
				$HelpTopic = 'InstalltoPath'
			Case $Input_DefaultMenu
				Switch $nNotifyCode
					Case $EN_CHANGE ; 0x300
						$DefaultMenuChange = True
					Case $EN_KILLFOCUS ; 0x200
						If $DefaultMenuChange Then
							$DefaultMenuChange = False
							Input_DefaultMenuChange()
						EndIf
					Case $EN_UPDATE ; 0x400
						$DefaultMenuChange = True
				EndSwitch
				$HelpTopic = 'DefaultMenu'
			Case $Edit_CatalogList
				Switch $nNotifyCode
					Case $EN_CHANGE ; 0x300
						$CatalogListChange = True
					Case $EN_KILLFOCUS ; 0x200
						If $CatalogListChange Then
							$CatalogListChange = False
							Edit_CatalogListChange()
							PopulateCombo_Catalog()
						EndIf
					Case $EN_UPDATE ; 0x400
						$CatalogListChange = True
				EndSwitch
				$HelpTopic = 'MenuCatalog'
				;General Tab
			Case $Input_Title
				$HelpTopic = 'Title'
			Case $Input_Version
				$HelpTopic = 'Version'
			Case $Input_Publisher, $Input_Language, $Input_Releaser, $Input_Additional, $Input_ReleaseDate, $Input_RequiredRuntimes, $Input_Rating, $Input_InstalledSize, $Input_ReleaseVersion
				$HelpTopic = 'MetadataEditor'
			Case $Input_Tags
				$HelpTopic = 'TagList'
			Case $Edit_URLs
				$HelpTopic = 'URLs'
			Case $Combo_Category, $Input_Categories, $Checkbox_Game
				$HelpTopic = 'Category'
			Case $Edit_Description
				$HelpTopic = 'Description'
			Case $Radio_Build_ssApp, $Radio_Build_ppApp, $Radio_Build_ppGame, $Radio_Build_ppTweak
				$HelpTopic = 'BuildType'
			Case $Radio_Arch_Any, $Radio_Arch_x86, $Radio_Arch_x64
				$HelpTopic = 'Architecture'
			Case $Checkbox_OS_NT5, $Checkbox_OS_NT6, $Checkbox_OS_Metro, $Checkbox_OS_Win10
				$HelpTopic = 'ForOS'
			Case $Checkbox_AlwaysShow, $Checkbox_AlwaysHide, $Checkbox_AtSetupOnly, $Checkbox_InstallT13, $Checkbox_RunAsx64, $Checkbox_InstallInstant, $Checkbox_InstallInstant
				$HelpTopic = 'ssWPIOptions'
				;Assembly Tab
			Case $Combo_Installer
				Switch $nNotifyCode
					Case $EN_CHANGE ; 0x300
						$Installer_Change = True
					Case $EN_KILLFOCUS ; 0x200
						If $Installer_Change Then
							Add_Installer(StringReplace(GUICtrlRead($Combo_Installer), '"', ''))
							If GUICtrlRead($Input_Switches) <> '' Then
								$Installers[$Installer_Selected][5] = StringStripWS('"' & GUICtrlRead($Combo_Installer) & '" ' & GUICtrlRead($Input_Switches), 3)
							EndIf
						EndIf
					Case $EN_UPDATE ; 0x400
						$Installer_Change = True
				EndSwitch
				$HelpTopic = 'InstallerDetails'
			Case $Input_Switches
				Switch $nNotifyCode
					Case $EN_CHANGE ; 0x300
						$Installer_Change = True
					Case $EN_KILLFOCUS ; 0x200
						If $Installer_Change And GUICtrlRead($Combo_Installer) <> '' Then
							$Installers[$Installer_Selected][5] = StringStripWS('"' & GUICtrlRead($Combo_Installer) & '" ' & GUICtrlRead($Input_Switches), 3)
							GUICtrlSetState($Button_Add_Installer, $GUI_ENABLE)
						EndIf
					Case $EN_UPDATE ; 0x400
						$Installer_Change = True
				EndSwitch
				$HelpTopic = 'InstallerDetails'
			Case $Edit_Installers
				$HelpTopic = 'ProcessOrder'
				;Post-processing Tab
			Case $Edit_Cmd
				$HelpTopic = 'ScriptBatchCmd'
			Case $Edit_Reg
				$HelpTopic = 'RegistryEntriesReg'
			Case $Edit_FileAssoc
				$HelpTopic = 'AppExts'
			Case $Edit_InstallFonts
				$HelpTopic = 'InstallFonts'
			Case $Edit_RegisterDLL
				$HelpTopic = 'RegisterServer'
			Case $Checkbox_MakeNonething, $Checkbox_NeverUpdateAppFile
				$HelpTopic = 'PostprocessingOptions'
				;Shortcuts Tab
			Case $Combo_Catalog
				$HelpTopic = 'MenuCatalog'
			Case $Combo_scName
				$HelpTopic = 'ShortcutsDefinitions'
				Switch $nNotifyCode
					Case 5 ;$EN_CHANGE ; 0x300
						$scName_Change = True
					Case 10 ;$EN_KILLFOCUS ; 0x200
						If $scName_Change Then
;~ 							PopulateCombo_scName()
							Combo_scNameChange()
							$scName_Change = False
						EndIf
				EndSwitch
			Case $Checkbox_scAllUsers, $Checkbox_scStartMenu, $Checkbox_scRoot, $Checkbox_scPrograms, $Checkbox_scStartup, $Checkbox_scDesktop, $Checkbox_scQLaunch, $Checkbox_scSendTo, $Checkbox_scTaskbarPin, $Checkbox_scStartmenuPin
				$HelpTopic = 'Shortcutsto'
			Case $Checkbox_scNeverSort, $Checkbox_scAlwaysSort, $Checkbox_scKeepInFolder, $Checkbox_scKeepAll, $Checkbox_scRefreshExplorer, $Checkbox_NoMenuIcons, $Checkbox_LivePE, $Checkbox_MetroFriendly
				$HelpTopic = 'ShortcutsOptions'
			Case $Edit_scKeep ;Label_scKeepClick
				$HelpTopic = 'ShortcutNamestoKeep'
			Case $Input_scTarget, $Input_scWorkDir, $Input_scIcon, $Input_scArgs, $Input_scExt, $Input_scDesc, $Input_scFlags, $Input_scCatalog
				$HelpTopic = 'ShortcutsDefinitions'
			Case $Input_scKey
				$HelpTopic = 'ShortcutHotkey'
			Case Else
				;MsgBox(262144,'Debug line ~' & @ScriptLineNumber,'Selection:' & @lf & '$nID' & @lf & @lf & 'Return:' & @lf & $nID)
		EndSwitch
	EndIf
EndFunc

Func NewForm()
	GUICtrlSetState($Button_Build, $GUI_DISABLE)
	GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_DISABLE)

	;<Build Type>
	GUICtrlSetState($Radio_Build_ssApp, $GUI_UNCHECKED)
	GUICtrlSetState($Radio_Build_ppApp, $GUI_UNCHECKED)
	GUICtrlSetState($Radio_Build_ppTweak, $GUI_UNCHECKED)
	GUICtrlSetState($Radio_Build_ppGame, $GUI_UNCHECKED)
	GUICtrlSetState($Checkbox_Game, $GUI_UNCHECKED)
	GUICtrlSetState($Button_Fader, $GUI_DISABLE)
	GUICtrlSetState($Button_Icon, $GUI_DISABLE)
	GUICtrlSetState($Button_ScrShot, $GUI_DISABLE)
	GUICtrlSetState($Button_cmd, $GUI_DISABLE)
	GUICtrlSetState($Button_Reg, $GUI_DISABLE)
	GUICtrlSetState($Button_PatchFolder, $GUI_DISABLE)
	GUICtrlSetState($MenuItem_ScreenCapture, $GUI_DISABLE)
	GUICtrlSetState($MenuItem_ViewFader, $GUI_DISABLE)
	GUICtrlSetState($MenuItem_ViewIcon, $GUI_DISABLE)
	GUICtrlSetState($MenuItem_ViewScrShot, $GUI_DISABLE)
	GUICtrlSetState($MenuItem_ViewPatchFolder, $GUI_DISABLE)
	GUICtrlSetState($MenuItem_ViewCMD, $GUI_DISABLE)
	GUICtrlSetState($MenuItem_ViewReg, $GUI_DISABLE)

	;<Title>
	GUICtrlSetData($Input_Title, $App_Title)

	;<Version>
	GUICtrlSetData($Input_Version, $App_Version)

	;<URL>
	GUICtrlSetData($Edit_URLs, '')

	;<Install>
	GUICtrlSetData($Edit_Installers, '')

	;<Description>
	GUICtrlSetData($Edit_Description, '')

	;<Uninstall>

	;<Category>
	PopulateCombo_Category()
	PopulateCombo_Tags(True)

	; <Flags>
	GUICtrlSetState($Checkbox_scStartMenu, $GUI_CHECKED) ;
	GUICtrlSetState($Checkbox_scRoot, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_scPrograms, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_scStartup, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_scDesktop, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_scQLaunch, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_scTaskbarPin, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_scStartmenuPin, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_scSendTo, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_scAllUsers, $GUI_CHECKED) ;
	GUICtrlSetState($Checkbox_scNeverSort, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_scAlwaysSort, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_scKeepInFolder, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_scKeepAll, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_scRefreshExplorer, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_NoMenuIcons, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_LivePE, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_MakeNonething, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_NeverUpdateAppFile, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_MetroFriendly, $GUI_CHECKED) ;
	;ssWPI Options
	GUICtrlSetState($Checkbox_RunAsx64, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_AlwaysShow, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_AlwaysHide, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_AtSetupOnly, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_InstallT13, $GUI_UNCHECKED) ;
	GUICtrlSetState($Checkbox_InstallInstant, $GUI_UNCHECKED) ;

	;<PriorityOrder>
	GUICtrlSetData($Input_PriorityOrder, '5')

	;<AppPath>
	Populate_AppPath()

	;<StartMenuSourcePath>
	Populate_DefaultMenu()

	;<ShortCutNamesKeep>
	GUICtrlSetData($Edit_scKeep, '')

	;<ShortcutS>/<ppApps>
	$scSelected = 0
	GUICtrlSetData($Combo_scName, '')
	GUICtrlSetData($Input_scTarget, '')
	GUICtrlSetData($Input_scWorkDir, '')
	GUICtrlSetData($Input_scArgs, '')
	GUICtrlSetData($Input_scExt, '')
	GUICtrlSetData($Input_scIcon, '')
	GUICtrlSetData($Input_scIndex, '')
	GUICtrlSetData($Input_scDesc, '')
	GUICtrlSetData($Input_scFlags, '')
	GUICtrlSetData($Input_scCatalog, '')
	GUICtrlSetData($Input_scKey, '')
	GUICtrlSetData($Label_scCount, 'Item' & _StringRepeat(' ', 3 - StringLen($scSelected)) & $scSelected & ' of' & _StringRepeat(' ', 3 - StringLen($App_scCount)) & $App_scCount & ' shortcuts total')

	;<Extensions>
	GUICtrlSetData($Edit_FileAssoc, '')

	;<InstallFonts>
	GUICtrlSetData($Edit_InstallFonts, '')

	;<RegisterDLL>
	GUICtrlSetData($Edit_RegisterDLL, '')

	;<Script>
	GUICtrlSetData($Edit_Cmd, '')

	;<Registry>
	GUICtrlSetData($Edit_Reg, '')

	;<MenuCatalog>
	PopulateCombo_Catalog()
	GUICtrlSetData($Edit_CatalogList, '')

	;<OS>
	GUICtrlSetState($Checkbox_OS_NT5, $GUI_UNCHECKED)
	GUICtrlSetState($Checkbox_OS_NT6, $GUI_UNCHECKED)
	GUICtrlSetState($Checkbox_OS_Metro, $GUI_UNCHECKED)
	GUICtrlSetState($Checkbox_OS_Win10, $GUI_UNCHECKED)

	;<Architecture>
	GUICtrlSetState($Radio_Arch_Any, $GUI_CHECKED)
	GUICtrlSetState($Radio_Arch_x86, $GUI_UNCHECKED)
	GUICtrlSetState($Radio_Arch_x64, $GUI_UNCHECKED)

	;<Meta>
	GUICtrlSetData($Input_Tags, $App_Tags)
	GUICtrlSetData($Input_Publisher, $App_Publisher)
	GUICtrlSetData($Input_Language, $App_Language)
	GUICtrlSetData($Input_Releaser, $App_Releaser)
	GUICtrlSetData($Input_Additional, $App_Additional)
	GUICtrlSetData($Input_ReleaseDate, $App_ReleaseDate)
	GUICtrlSetData($Input_ReleaseVersion, $App_ReleaseVersion)
	GUICtrlSetData($Input_RequiredRuntimes, $App_RequiredRuntimes)
	GUICtrlSetData($Input_Rating, $App_Rating)
	GUICtrlSetData($Input_InstalledSize, FileSizeUnits($App_InstalledSize, 'to'))
	GUICtrlSetState($Button_GetppExtractedSize, $GUI_DISABLE)

	;<LicenseType>
	GUICtrlSetState($Radio_LicenseType_NA, $GUI_CHECKED)
	GUICtrlSetState($Radio_LicenseType_NonGratis, $GUI_UNCHECKED)
	GUICtrlSetState($Radio_LicenseType_Gratis, $GUI_UNCHECKED)
	GUICtrlSetState($Radio_LicenseType_Libre, $GUI_UNCHECKED)

	Populate_Main()
	If $SrcPath <> '' Then
		If $UseInputDir Then SetOutputPath($SrcPath)
		If $App_File = '' Then
			Switch $App_Type
				Case 1, 2
					$App_File = $OutputPath & '\ssApp.app'
				Case 3, 4, 0
					$App_File = $OutputPath & '\ppApp.app'
				Case 5
					$App_File = $OutputPath & '\ppGame.ppg'
			EndSwitch
		EndIf
		If $App_File <> '' Then SetOutputPath(GetFolderPath($App_File))
	EndIf
EndFunc

Func Open_ssCreator($TemplatesFolder)
	GUICtrlSetState($Radio_Build_ssApp_ssc, $GUI_UNCHECKED)
	GUICtrlSetState($Radio_Build_ppApp_ssc, $GUI_UNCHECKED)
	GUICtrlSetState($Radio_Build_ppTweak_ssc, $GUI_UNCHECKED)
	GUICtrlSetState($Radio_Build_ppGame_ssc, $GUI_UNCHECKED)

	GUICtrlSetState($Radio_Shortcuts_No, $GUI_UNCHECKED)
	GUICtrlSetState($Radio_Shortcuts_Yes, $GUI_UNCHECKED)
	GUICtrlSetState($Radio_Shortcuts_No, $GUI_DISABLE)
	GUICtrlSetState($Radio_Shortcuts_Yes, $GUI_DISABLE)

	GUICtrlSetData($Input_DefaultMenu_ssc, '')
	GUICtrlSetData($Input_Title_ssc, '')
	GUICtrlSetData($Input_AppPath_ssc, '')

	GUICtrlSetState($Label_DefaultMenu_ssc, $GUI_DISABLE)
	GUICtrlSetState($Input_DefaultMenu_ssc, $GUI_DISABLE)
	GUICtrlSetState($Button_BrowseStartMenu_ssc, $GUI_DISABLE)

	GUICtrlSetState($Label_Title_ssc, $GUI_DISABLE)
	GUICtrlSetState($Input_Title_ssc, $GUI_DISABLE)

	GUICtrlSetState($Label_AppPath_ssc, $GUI_DISABLE)
	GUICtrlSetState($Input_AppPath_ssc, $GUI_DISABLE)
	GUISetState(@SW_SHOW, $Form_ssEditor)

;~ 	$SrcPath = $TempDir
	FadeInGUI($Form_ssCreator, '.3') ; in seconds

EndFunc

Func PageControl_ssEditorChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|PageControl_ssEditorChange()' & @CRLF)
	Switch GUICtrlRead($PageControl_ssEditor)
		Case 0
			$HelpTopic = 'General'
		Case 1
			$HelpTopic = 'Assembly'
		Case 2
			$HelpTopic = 'ShortcutsTab'
		Case 3
			$HelpTopic = 'PostprocessingTab'
		Case 4
			$HelpTopic = 'GraphicsTab'
	EndSwitch
EndFunc

Func Populate_AppPath()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Populate_AppPath()' & @CRLF)
	GUICtrlSetData($Input_AppPath, StringFilterFilename($App_InstallPath, True, True))
	Input_AppPathChange()
EndFunc

Func Populate_DefaultMenu()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Populate_DefaultMenu()' & @CRLF)
	GUICtrlSetData($Input_DefaultMenu, StringFilterFilename($App_smSource, True, True))
	Input_DefaultMenuChange()
EndFunc

Func Populate_Main()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Populate_Main()' & @CRLF)
	Local $hImage, $hGraphic, $imgWidth
	;AppType
	If $App_Type = 0 And $SrcPath <> '' Then ; Guess
		Select
			Case FileExists($SrcPath & '\SetupS.*') Or FileExists($SrcPath & '\SetupS')
				$App_Type = 1
			Case FileExists($SrcPath & '\ssApp.*') Or FileExists($SrcPath & '\ssApp')
				$App_Type = 2
			Case FileExists($SrcPath & '\ppApp.*') Or FileExists($SrcPath & '\ppApp')
				$App_Type = 3
			Case FileExists($SrcPath & '\ppTweak.*') Or FileExists($SrcPath & '\ppTweak')
				$App_Type = 4
			Case FileExists($SrcPath & '\ppGame.*') Or FileExists($SrcPath & '\ppGame')
				$App_Type = 5
			Case Else
				$App_Type = $LastBuildType
		EndSelect
	EndIf
	Switch $App_Type
		Case 1, 2 ;ssApp
			Radio_Build_ssAppClick()
		Case 3, 4 ;ppApp
			If $App_Type = 3 Then
				Radio_Build_ppAppClick()
			Else
				Radio_Build_ppTweakClick()
			EndIf
		Case 5 ;ppGame
			Radio_Build_ppGameClick()
	EndSwitch
	If $ArchiveEditMode = '' Then
		GUICtrlSetState($Radio_Build_ssApp, $GUI_ENABLE)
		GUICtrlSetState($Radio_Build_ppApp, $GUI_ENABLE)
		GUICtrlSetState($Radio_Build_ppGame, $GUI_ENABLE)
		GUICtrlSetState($Radio_Build_ppTweak, $GUI_ENABLE)
	Else
		GUICtrlSetState($Radio_Build_ssApp, $GUI_DISABLE)
		GUICtrlSetState($Radio_Build_ppApp, $GUI_DISABLE)
		GUICtrlSetState($Radio_Build_ppGame, $GUI_DISABLE)
		GUICtrlSetState($Radio_Build_ppTweak, $GUI_DISABLE)
	EndIf
	If $App_Type > 0 Then NeoIniWrite($ssEditorINI, 'Options', 'Last BuildType', $App_Type)

	;File Version
	GUICtrlSetData($Label_FileVersion, 'File version: ' & $App_FileVersion)
	If $ViewFileVersionInfo Then
		GUICtrlSetState($MenuItem_ViewFileVersion, $GUI_CHECKED)
		GUICtrlSetState($Label_FileVersion, $GUI_SHOW)
	Else
		GUICtrlSetState($MenuItem_ViewFileVersion, $GUI_UNCHECKED)
		GUICtrlSetState($Label_FileVersion, $GUI_HIDE)
	EndIf

	;<Title>
	GUICtrlSetData($Input_Title, $App_Title)
	;<Version>
	GUICtrlSetData($Input_Version, $App_Version)
	;<URL>
	$Edit_URLs_Data = ''
	For $i = 1 To $App_URL[0]
		If $Edit_URLs_Data <> '' Then $Edit_URLs_Data = $Edit_URLs_Data & @CRLF
		$Edit_URLs_Data = $Edit_URLs_Data & $App_URL[$i]
	Next
	GUICtrlSetData($Edit_URLs, $Edit_URLs_Data)
	;<Assembly>
	$Edit_Installers_Data = ''
	For $i = 1 To $App_Assembly[0]
		If $Edit_Installers_Data <> '' Then $Edit_Installers_Data = $Edit_Installers_Data & @CRLF
		$Edit_Installers_Data = $Edit_Installers_Data & $App_Assembly[$i]
	Next
	GUICtrlSetData($Edit_Installers, $Edit_Installers_Data)
	;<Description>
	$Edit_Description_Data = ''
;~ 		GUISetStyle(BitOR($ES_WANTRETURN, $WS_VSCROLL), -1, $Edit_Description)
	For $i = 1 To $App_Description[0]
		If $Edit_Description_Data <> '' Then $Edit_Description_Data = $Edit_Description_Data & @CRLF
		$Edit_Description_Data = $Edit_Description_Data & $App_Description[$i]
	Next
	GUICtrlSetData($Edit_Description, $Edit_Description_Data)
	GUICtrlSetTip($Edit_Description, '')
	;<Category>
	PopulateCombo_Category()
	PopulateCombo_Tags()
	PopulateInput_Categories()
	;<Tags>
	PopulateInput_Tags()
	; <Flags>
	If Not $App_MakeStartMenu Then
		GUICtrlSetState($Checkbox_scStartMenu, $GUI_UNCHECKED)
	Else
		GUICtrlSetState($Checkbox_scStartMenu, $GUI_CHECKED)
	EndIf
	If $App_MakeInRoot Then
		GUICtrlSetState($Checkbox_scRoot, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_scRoot, $GUI_UNCHECKED)
	EndIf
	If $App_MakeInPrograms Then
		GUICtrlSetState($Checkbox_scPrograms, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_scPrograms, $GUI_UNCHECKED)
	EndIf
	If $App_MakeStartup Then
		GUICtrlSetState($Checkbox_scStartup, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_scStartup, $GUI_UNCHECKED)
	EndIf
	If $App_MakeDesktop Then
		GUICtrlSetState($Checkbox_scDesktop, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_scDesktop, $GUI_UNCHECKED)
	EndIf
	If $App_MakeQuickLaunch Then
		GUICtrlSetState($Checkbox_scQLaunch, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_scQLaunch, $GUI_UNCHECKED)
	EndIf
	If $App_TaskbarPin Then
		GUICtrlSetState($Checkbox_scTaskbarPin, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_scTaskbarPin, $GUI_UNCHECKED)
	EndIf
	If $App_StartmenuPin Then
		GUICtrlSetState($Checkbox_scStartmenuPin, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_scStartmenuPin, $GUI_UNCHECKED)
	EndIf
	If $App_MakeSendTo Then
		GUICtrlSetState($Checkbox_scSendTo, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_scSendTo, $GUI_UNCHECKED)
	EndIf
	If Not $App_AllUsers Then
		GUICtrlSetState($Checkbox_scAllUsers, $GUI_UNCHECKED)
	Else
		GUICtrlSetState($Checkbox_scAllUsers, $GUI_CHECKED)
	EndIf
	If $App_NeverSort Then
		GUICtrlSetState($Checkbox_scNeverSort, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_scNeverSort, $GUI_UNCHECKED)
	EndIf
	If $App_AlwaysSort Then
		GUICtrlSetState($Checkbox_scAlwaysSort, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_scAlwaysSort, $GUI_UNCHECKED)
	EndIf
	If $App_KeepInFolder Then
		GUICtrlSetState($Checkbox_scKeepInFolder, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_scKeepInFolder, $GUI_UNCHECKED)
	EndIf
	If $App_KeepAll Then
		GUICtrlSetState($Checkbox_scKeepAll, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_scKeepAll, $GUI_UNCHECKED)
	EndIf
	If $App_RefreshExplorer Then
		GUICtrlSetState($Checkbox_scRefreshExplorer, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_scRefreshExplorer, $GUI_UNCHECKED)
	EndIf
	If $App_NoIcons Then
		GUICtrlSetState($Checkbox_NoMenuIcons, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_NoMenuIcons, $GUI_UNCHECKED)
	EndIf
	If $App_LivePE Then
		GUICtrlSetState($Checkbox_LivePE, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_LivePE, $GUI_UNCHECKED)
	EndIf
	If $App_NoneThing Then
		GUICtrlSetState($Checkbox_MakeNonething, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_MakeNonething, $GUI_UNCHECKED)
	EndIf
	If Not $App_UpdateAppFile Then
		GUICtrlSetState($Checkbox_NeverUpdateAppFile, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_NeverUpdateAppFile, $GUI_UNCHECKED)
	EndIf
	If Not $App_ssUninstall Then
		GUICtrlSetState($Checkbox_App_ssUninstall, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_App_ssUninstall, $GUI_UNCHECKED)
	EndIf
	If $App_AssemblyNoWait Then
		GUICtrlSetState($Checkbox_AssemblyNoWait, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_AssemblyNoWait, $GUI_UNCHECKED)
	EndIf
	If Not $App_MetroFriendly Then
		GUICtrlSetState($Checkbox_MetroFriendly, $GUI_UNCHECKED)
	Else
		GUICtrlSetState($Checkbox_MetroFriendly, $GUI_CHECKED)
	EndIf

	;ssWPI Options
	If $App_Runx64 Then GUICtrlSetState($Checkbox_RunAsx64, $GUI_CHECKED)
	If $App_AlwaysShow Then GUICtrlSetState($Checkbox_AlwaysShow, $GUI_CHECKED)
	If $App_AlwaysHide Then GUICtrlSetState($Checkbox_AlwaysHide, $GUI_CHECKED)
	If $App_DuringSetupOnly Then GUICtrlSetState($Checkbox_AtSetupOnly, $GUI_CHECKED)
	If $App_InstallT13 Then GUICtrlSetState($Checkbox_InstallT13, $GUI_CHECKED)
	If $App_InstallInstant Then GUICtrlSetState($Checkbox_InstallInstant, $GUI_CHECKED)
	; <PriorityOrder>
	GUICtrlSetData($Input_PriorityOrder, $App_PriorityOrder)
	;<AppPath>
	Populate_AppPath()
	;<StartMenuSourcePath>
	Populate_DefaultMenu()
	;<ShortCutNamesKeep>
	$Edit_scKeep_Data = ''
	For $i = 1 To $App_scKeep[0]
		If $Edit_scKeep_Data <> '' Then $Edit_scKeep_Data = $Edit_scKeep_Data & @CRLF
		$Edit_scKeep_Data = $Edit_scKeep_Data & $App_scKeep[$i]
	Next
	GUICtrlSetData($Edit_scKeep, $Edit_scKeep_Data)
	;<ShortcutS>/<ppApps>
	If $App_scCount > 0 Then
		$scSelected = 1
		PopulateCombo_scName()
		Populate_scDefs()
	Else
		$scSelected = 0
		GUICtrlSetData($Combo_scName, '')
		GUICtrlSetState($Button_scIcon, $GUI_DISABLE)
		GUICtrlSetData($Input_scTarget, '')
		GUICtrlSetData($Input_scFlags, '')
		GUICtrlSetData($Input_scCatalog, '')
		GUICtrlSetData($Input_scKey, '')
	EndIf
	;<Uninstall>
	If $App_Uninstall[0][0] > 0 Then
		$uiSelected = 1
		PopulateCombo_uiKey()
		Populate_uiDefs()
	Else
		$uiSelected = 0
		GUICtrlSetData($Combo_uiKey, '')
		GUICtrlSetData($Input_uiDisplayIcon, '')
		GUICtrlSetData($Input_uiDisplayName, '')
		GUICtrlSetData($Input_uiInstallLocation, '')
		GUICtrlSetData($Input_uiScript, '')
		GUICtrlSetData($Input_uiSwitches, '')
		GUICtrlSetData($Input_uiUninstallString, '')
	EndIf
	;<Extensions>
	$Edit_FileAssoc_Data = ''
	For $i = 1 To $App_FileType[0]
		If $Edit_FileAssoc_Data <> '' Then $Edit_FileAssoc_Data = $Edit_FileAssoc_Data & @CRLF
		$Edit_FileAssoc_Data = $Edit_FileAssoc_Data & $App_FileType[$i]
	Next
	GUICtrlSetData($Edit_FileAssoc, $Edit_FileAssoc_Data)
	;<InstallFonts>
	$Edit_InstallFonts_Data = ''
	For $i = 1 To $App_InstallFonts[0]
		If $Edit_InstallFonts_Data <> '' Then $Edit_InstallFonts_Data = $Edit_InstallFonts_Data & @CRLF
		$Edit_InstallFonts_Data = $Edit_InstallFonts_Data & $App_InstallFonts[$i]
	Next
	GUICtrlSetData($Edit_InstallFonts, $Edit_InstallFonts_Data)
	;<RegisterDLL>
	$Edit_RegisterDLL_Data = ''
	For $i = 1 To $App_RegisterDLL[0]
		If $Edit_RegisterDLL_Data <> '' Then $Edit_RegisterDLL_Data = $Edit_RegisterDLL_Data & @CRLF
		$Edit_RegisterDLL_Data = $Edit_RegisterDLL_Data & $App_RegisterDLL[$i]
	Next
	GUICtrlSetData($Edit_RegisterDLL, $Edit_RegisterDLL_Data)
	;<Script>
	$Edit_Cmd_Data = $App_CmdFile
	GUICtrlSetData($Edit_Cmd, $Edit_Cmd_Data)
	;<Registry>
	$Edit_Reg_Data = $App_RegFile
	GUICtrlSetData($Edit_Reg, $Edit_Reg_Data)
	If $App_RegFile = '' And $App_CmdFile = '' Then GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_DISABLE)
	;<MenuCatalog>
	PopulateCombo_Catalog()
	PopulateEdit_CatalogList()
	;<OS>
	If BitAND($App_OS, 1) = 1 Then GUICtrlSetState($Checkbox_OS_NT5, $GUI_CHECKED)
	If BitAND($App_OS, 2) = 2 Then GUICtrlSetState($Checkbox_OS_NT6, $GUI_CHECKED)
	If BitAND($App_OS, 4) = 4 Then GUICtrlSetState($Checkbox_OS_Metro, $GUI_CHECKED)
	If BitAND($App_OS, 8) = 8 Then GUICtrlSetState($Checkbox_OS_Win10, $GUI_CHECKED)

	;<Architecture>
	Switch $App_Architecture
		Case 0 ;Radio_Arch_Any
			GUICtrlSetState($Radio_Arch_Any, $GUI_CHECKED)
		Case 1 ;Radio_Arch_x86
			GUICtrlSetState($Radio_Arch_x86, $GUI_CHECKED)
		Case 2 ;Radio_Arch_x64
			GUICtrlSetState($Radio_Arch_x64, $GUI_CHECKED)
		Case 3 ;Radio_Arch_DualArch
			GUICtrlSetState($Radio_Arch_DualArch, $GUI_CHECKED)
	EndSwitch
	;<Meta>
	GUICtrlSetData($Input_Publisher, $App_Publisher)
	GUICtrlSetData($Input_Language, $App_Language)
	GUICtrlSetData($Input_Releaser, $App_Releaser)
	GUICtrlSetData($Input_Additional, $App_Additional)
	GUICtrlSetData($Input_ReleaseDate, $App_ReleaseDate)
	GUICtrlSetData($Input_ReleaseVersion, $App_ReleaseVersion)
	GUICtrlSetData($Input_RequiredRuntimes, $App_RequiredRuntimes)
	GUICtrlSetData($Input_Rating, $App_Rating)
	GUICtrlSetData($Input_InstalledSize, FileSizeUnits($App_InstalledSize, 'to'))

	;<LicenseType>
	Switch $App_LicenseType
		Case 0
			GUICtrlSetState($Radio_LicenseType_NA, $GUI_CHECKED)
		Case 1
			GUICtrlSetState($Radio_LicenseType_NonGratis, $GUI_CHECKED)
		Case 2
			GUICtrlSetState($Radio_LicenseType_Gratis, $GUI_CHECKED)
		Case 3
			GUICtrlSetState($Radio_LicenseType_Libre, $GUI_CHECKED)
	EndSwitch
	;Graphics
	If Not $AutoBuild Then
		If FileExists($SrcPath & '\' & GetAppTypeBase($App_Type) & '.jpg') Then _SetImage($Pic_ScreenShot, $SrcPath & '\' & GetAppTypeBase($App_Type) & '.jpg')
		If FileExists($SrcPath & '\' & GetAppTypeBase($App_Type) & '.png') Then _SetImage($Pic_Fader, $SrcPath & '\' & GetAppTypeBase($App_Type) & '.png')
		If FileExists($SrcPath & '\' & GetAppTypeBase($App_Type) & '.ico') Then
			Switch @OSVersion
				Case 'WIN_2003', 'WIN_XP', 'WIN_XPe', 'WIN_2000'
					$imgWidth = 48
					If $PreviewIconSize > 0 And $PreviewIconSize < 128 Then $imgWidth = $PreviewIconSize
				Case 'WIN_2008R2', 'WIN_7', 'WIN_2008', 'WIN_VISTA'
					$imgWidth = 256
					If $PreviewIconSize > 0 Then $imgWidth = $PreviewIconSize
			EndSwitch
			If $imgWidth > 48 Then $imgWidth = 48
			_SetIcon($Pic_Icon, $SrcPath & '\' & GetAppTypeBase($App_Type) & '.ico', 0, $imgWidth, $imgWidth)
		EndIf
	EndIf
	If $GuiPreviewPic <> '' Then
		Switch StringLower(StringRight($GuiPreviewPic, 4))
			Case '.png'
				Button_FaderClick()
			Case '.ico'
				Button_IconClick()
			Case '.jpg'
				Button_ScrShotClick()
		EndSwitch
	EndIf
	CursorWait($hOrigCur)
EndFunc

Func Populate_scDefs()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Populate_scDefs()' & @CRLF)
	If $scSelected = 0 Then
		GUICtrlSetData($Input_scTarget, '')
		GUICtrlSetData($Input_scWorkDir, '')
		GUICtrlSetData($Input_scArgs, '')
		GUICtrlSetData($Input_scExt, '')
		GUICtrlSetData($Input_scIcon, '')
		GUICtrlSetData($Input_scIndex, '')
		GUICtrlSetData($Input_scDesc, '')
		GUICtrlSetData($Input_scFlags, '')
		GUICtrlSetData($Input_scCatalog, '')
		GUICtrlSetData($Input_scKey, '')
	Else
		GUICtrlSetData($Input_scTarget, $App_scEXE[$scSelected])
		GUICtrlSetData($Input_scWorkDir, $App_scWorkDir[$scSelected])
		GUICtrlSetData($Input_scArgs, $App_scArgs[$scSelected])
		GUICtrlSetData($Input_scExt, $App_scExt[$scSelected])
		GUICtrlSetData($Input_scIcon, $App_scIcon[$scSelected])
		GUICtrlSetData($Input_scIndex, $App_scIndex[$scSelected])
		GUICtrlSetData($Input_scDesc, $App_scDesc[$scSelected])
		GUICtrlSetData($Input_scFlags, $App_scFlags[$scSelected])
		GUICtrlSetData($Input_scCatalog, $App_scCatalog[$scSelected])
		GUICtrlSetData($Input_scKey, $App_scKey[$scSelected])
	EndIf
	GUICtrlSetData($Label_scCount, 'Item' & _StringRepeat(' ', 3 - StringLen($scSelected)) & $scSelected & ' of' & _StringRepeat(' ', 3 - StringLen($App_scCount)) & $App_scCount & ' shortcuts total')
EndFunc

Func Populate_uiDefs()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Populate_uiDefs()' & @CRLF)
	;_ArrayDisplay($App_Uninstall, @ScriptLineNumber)
	If $uiSelected = 0 Then
		GUICtrlSetData($Input_uiDisplayIcon, '')
		GUICtrlSetData($Input_uiDisplayName, '')
		GUICtrlSetData($Input_uiInstallLocation, '')
		GUICtrlSetData($Input_uiScript, '')
		GUICtrlSetData($Input_uiSwitches, '')
		GUICtrlSetData($Input_uiUninstallString, '')
	Else
		GUICtrlSetData($Input_uiDisplayName, $App_Uninstall[$uiSelected][1])
		GUICtrlSetData($Input_uiInstallLocation, $App_Uninstall[$uiSelected][2])
		GUICtrlSetData($Input_uiDisplayIcon, $App_Uninstall[$uiSelected][3])
		GUICtrlSetData($Input_uiUninstallString, $App_Uninstall[$uiSelected][4])
		GUICtrlSetData($Input_uiSwitches, $App_Uninstall[$uiSelected][5])
		GUICtrlSetData($Input_uiScript, $App_Uninstall[$uiSelected][6])
	EndIf
	GUICtrlSetData($Label_uiCount, 'Item' & _StringRepeat(' ', 3 - StringLen($uiSelected)) & $uiSelected & ' of' & _StringRepeat(' ', 3 - StringLen($App_Uninstall[0][0])) & $App_Uninstall[0][0] & ' keys total')
EndFunc

Func PopulateCombo_Catalog($Test = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|PopulateCombo_Catalog()' & @CRLF)
	If FileExists(GetMenuDefs(1)) Then
		Local $i, $j, $Found, $Populate, $Catalog = IniReadSection(GetMenuDefs(1), 'Catalog'), $Combo_Catalog_Data = ''
		GUICtrlSetData($Combo_Catalog, $Combo_Catalog_Data)
		For $i = 1 To $Catalog[0][0]
			$Populate = True
			Select
				Case GUICtrlRead($Checkbox_Game) = $GUI_CHECKED And StringInStr($Catalog[$i][0], 'Game ') = 1
				Case GUICtrlRead($Checkbox_Game) = $GUI_UNCHECKED And StringInStr($Catalog[$i][0], 'Game ') = 0 And StringLeft($Catalog[$i][0], 1) <> '!'
				Case Else
					$Populate = False
			EndSelect
			If $Populate Then
				$Found = False
				For $j = 1 To $App_Catalog[0]
					If ($Catalog[$i][0] = $App_Catalog[$j]) Then
						$Found = True
						ExitLoop
					EndIf
				Next
				If Not $Found Then
					If $Combo_Catalog_Data <> '' Then $Combo_Catalog_Data = $Combo_Catalog_Data & '|'
					$Combo_Catalog_Data = $Combo_Catalog_Data & StringReplace($Catalog[$i][0], 'Game ', '')
				EndIf
			EndIf
		Next
		If $App_Catalog[0] > 0 Then
			GUICtrlSetData($Combo_Catalog, $Combo_Catalog_Data, $App_Catalog[0])
		Else
			GUICtrlSetData($Combo_Catalog, $Combo_Catalog_Data)
		EndIf
		If $MenuStyle = 0 Then $MenuDefinitionINI = ''
	EndIf
	GUICtrlSetState($Button_AddMenuCatalog, $GUI_DISABLE)
EndFunc

Func PopulateCombo_Category($Test = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|PopulateCombo_Category(): $Init = ' & $Test & @CRLF)
	Local $i, $j, $Found, $Populate
	$Combo_Category_Data = ''
	GUICtrlSetData($Combo_Category, $Combo_Category_Data)
	For $i = 1 To $Categories[0][0]
		$Populate = True
		Select
			Case GUICtrlRead($Checkbox_Game) = $GUI_CHECKED And StringInStr($Categories[$i][0], 'Games\') = 1
			Case GUICtrlRead($Checkbox_Game) = $GUI_UNCHECKED And StringInStr($Categories[$i][0], 'Games\') = 0 And StringLeft($Categories[$i][0], 1) <> '!'
			Case Else
				$Populate = False
		EndSelect
		If $Populate Then
			$Found = False
			For $j = 1 To $App_Category[0]
				If $Categories[$i][0] = $App_Category[$j] Then
					$Found = True
					ExitLoop
				EndIf
			Next
			If Not $Found Then
				If $Combo_Category_Data <> '' Then $Combo_Category_Data = $Combo_Category_Data & '|'
				$Combo_Category_Data = $Combo_Category_Data & StringReplace($Categories[$i][0], 'Games\', '')
			EndIf
		EndIf
	Next
	GUICtrlSetData($Combo_Category, $Combo_Category_Data)
EndFunc

Func PopulateCombo_scName()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|PopulateCombo_scName()' & @CRLF)
	Local $i, $j, $Test, $Swap, $dup, $Combo_scName_Data = ''
	If $App_InstallPath <> '' Then
		For $i = 1 To $App_scCount
			If StringInStr($App_scEXE[$i], '\') > 0 And StringInStr($App_scEXE[$i], $App_InstallPath) = 1 Then
				$App_scEXE[$i] = StringMid($App_scEXE[$i], StringLen($App_InstallPath) + 2)
			EndIf
		Next
	EndIf
	If $App_smSource <> '' Then
		For $i = 1 To $App_scCount
			If StringInStr($App_scLNK[$i], '\') > 0 And StringInStr($App_scLNK[$i], $App_smSource) = 1 Then
				$App_scLNK[$i] = StringMid($App_scLNK[$i], StringLen($App_smSource) + 2)
			EndIf
		Next
	EndIf
	GUICtrlSetData($Combo_scName, $Combo_scName_Data)
	For $i = 1 To $App_scCount - 1 ;check for any "duplicates"
		$dup = 1
		For $j = $i + 1 To $App_scCount
			If $App_scLNK[$i] = $App_scLNK[$j] Then
				$dup += 1
				$App_scLNK[$j] = $App_scLNK[$j] & ' {#' & $dup & '}'
			EndIf
		Next
		If $dup > 1 Then $App_scLNK[$i] = $App_scLNK[$i] & ' {#1}'
	Next
	For $i = 1 To $App_scCount
		$App_scFlags[$i] = StringReplace($App_scFlags[$i], '#Is_x86#', 'Is_x86')
		$App_scFlags[$i] = StringReplace($App_scFlags[$i], 'Is_86', 'Is_x86')
		$App_scFlags[$i] = StringReplace($App_scFlags[$i], '#Is_x64#', 'Is_x64')
		$App_scFlags[$i] = StringReplace($App_scFlags[$i], 'Is_64', 'Is_x64')
		If StringInStr($App_scLNK[$i], ' {#') Then
			$App_scLNK[$i] = StringReplace($App_scLNK[$i], ' {#1} {#', ' {#')
			If StringInStr($App_scWorkDir[$i], '_x86') Or StringInStr($App_scLNK[$i], '_x86') Then
				If $App_scFlags[$i] = '' Then
					$App_scFlags[$i] = 'Is_x86'
				ElseIf StringInStr($App_scFlags[$i], 'Is_x86') = 0 Then
					$App_scFlags[$i] += '|Is_x86'
				EndIf
			EndIf
			If StringInStr($App_scWorkDir[$i], '_x64') Or StringInStr($App_scLNK[$i], '_x64') Then
				If $App_scFlags[$i] = '' Then
					$App_scFlags[$i] = 'Is_x64'
				ElseIf StringInStr($App_scFlags[$i], 'Is_x64') = 0 Then
					$App_scFlags[$i] += '|Is_x64'
				EndIf
			EndIf
		EndIf
		If $Combo_scName_Data <> '' Then $Combo_scName_Data = $Combo_scName_Data & '|'
		If $App_scLNK[$i] = '' Then
			$Combo_scName_Data = $Combo_scName_Data & ' '
		Else
			$Combo_scName_Data = $Combo_scName_Data & $App_scLNK[$i]
		EndIf
	Next
	If $App_scCount > 0 Then
		GUICtrlSetData($Combo_scName, $Combo_scName_Data, $App_scLNK[$scSelected])
		GUICtrlSetState($Button_scIcon, $GUI_ENABLE)
	Else
		GUICtrlSetData($Combo_scName, $Combo_scName_Data)
		GUICtrlSetState($Button_scIcon, $GUI_DISABLE)
	EndIf
EndFunc

Func PopulateCombo_Tags($Init = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|PopulateCombo_Tags(): $Init = ' & $Init & @CRLF)
	Local $i, $j, $Found, $Populate, $Combo_Tags_Data = ''
	GUICtrlSetData($Combo_Tags, $Combo_Tags_Data)
	For $i = 1 To $Tags[0][0]
		$Populate = True
		Select
			Case GUICtrlRead($Checkbox_Game) = $GUI_CHECKED And StringInStr($Tags[$i][1], 'Game ') = 1
			Case GUICtrlRead($Checkbox_Game) = $GUI_UNCHECKED And StringInStr($Tags[$i][1], 'Game ') = 0 And StringLeft($Tags[$i][0], 1) <> '!'
			Case Else
				$Populate = False
		EndSelect
		If $Populate Then
			$Found = False
			For $j = 1 To $App_Tags[0]
				If $Tags[$i][0] = $App_Tags[$j] Then
					$Found = True
					ExitLoop
				EndIf
			Next
			If Not $Found Then
				If $Combo_Tags_Data <> '' Then $Combo_Tags_Data = $Combo_Tags_Data & '|'
				$Combo_Tags_Data = $Combo_Tags_Data & $Tags[$i][0] & ' (' & StringReplace($Tags[$i][1], 'Game ', '') & ')'
			EndIf
		EndIf
	Next
	GUICtrlSetData($Combo_Tags, $Combo_Tags_Data)
EndFunc

Func PopulateCombo_uiKey()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|PopulateCombo_uiName()' & @CRLF)
	Local $i, $Combo_uiKey_Data = ''
	GUICtrlSetData($Combo_uiKey, $Combo_uiKey_Data)
	For $i = 1 To $App_Uninstall[0][0]
		If $Combo_uiKey_Data <> '' Then $Combo_uiKey_Data = $Combo_uiKey_Data & '|'
		If $App_Uninstall[$i][0] = '' Then
			$Combo_uiKey_Data = $Combo_uiKey_Data & ' '
		Else
			$Combo_uiKey_Data = $Combo_uiKey_Data & $App_Uninstall[$i][0]
		EndIf
	Next
	If $App_Uninstall[0][0] > 0 Then
		GUICtrlSetData($Combo_uiKey, $Combo_uiKey_Data, $App_Uninstall[$uiSelected][0])
	Else
		GUICtrlSetData($Combo_uiKey, $Combo_uiKey_Data)
	EndIf
EndFunc

Func PopulateEdit_CatalogList()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|PopulateEdit_CatalogList()' & @CRLF)
	Local $i
	$Edit_CatalogList_Data = ''
	If $App_Catalog[0] > 0 Then
		$Edit_CatalogList_Data = $App_Catalog[1]
		For $i = 2 To $App_Catalog[0]
			$Edit_CatalogList_Data = $Edit_CatalogList_Data & @CRLF & $App_Catalog[$i]
		Next
	EndIf
	GUICtrlSetData($Edit_CatalogList, StringReplace($Edit_CatalogList_Data, 'Game ', ''))
	smPreview()
EndFunc

Func PopulateInput_Categories()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|PopulateInput_Categories()' & @CRLF)
	GUICtrlSetData($Input_Categories, StringReplace(Multi2SingleLine($App_Category, '|'), 'Games\', ''))
	GUICtrlSetTip($Input_Categories, '')
EndFunc

Func PopulateInput_Tags()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|PopulateInput_Tags()' & @CRLF)
	GUICtrlSetData($Input_Tags, StringReplace(Multi2SingleLine($App_Tags, '|'), 'Games ', ''))
	GUICtrlSetTip($Input_Tags, '')
EndFunc

Func ppArchiveCheck()
	Local $ppSub = @WorkingDir, $type, $InstallArc, $Found = False
	Switch $App_Type
		Case 1, 2
			$type = 'ssApp'
		Case 3, 4
			$type = 'ppApp'
		Case 5
			$type = 'ppGame'
	EndSwitch
	Switch $App_Type
		Case 3, 4, 5 ;ppApp/ppGame
			Select
				Case FileExists($ppSub & '\' & $type & '.7z')
					$Found = True
				Case FileExists($ppSub & '\' & $type & '.zip')
					$Found = True
				Case FileExists($ppSub & '\' & $type & '.rar')
					$Found = True
				Case FileExists($ppSub & '\' & $type & '.cab')
					$Found = True
			EndSelect
			$type = 'patch'
			Select
				Case FileExists($ppSub & '\' & $type & '.7z')
					$Found = True
				Case FileExists($ppSub & '\' & $type & '.zip')
					$Found = True
				Case FileExists($ppSub & '\' & $type & '.rar')
					$Found = True
				Case FileExists($ppSub & '\' & $type & '.cab')
					$Found = True
			EndSelect
	EndSwitch
	If $Found Then
		GUICtrlSetState($Button_GetppExtractedSize, $GUI_ENABLE)
	Else
		GUICtrlSetState($Button_GetppExtractedSize, $GUI_DISABLE)
	EndIf
	Return $Found
EndFunc

;<Architecture>
Func Radio_Arch_AnyClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_Arch_AnyClick()' & @CRLF)
	$App_Architecture = 0
	$App_Runx64 = False
	GUICtrlSetState($Checkbox_RunAsx64, $GUI_UNCHECKED)
EndFunc

Func Radio_Arch_DualArchClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_Arch_DualArchClick()' & @CRLF)
	$App_Architecture = 3
	$App_Runx64 = False
	ppArchiveCheck()
	GUICtrlSetState($Checkbox_RunAsx64, $GUI_UNCHECKED)
EndFunc

Func Radio_Arch_x64Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_Arch_x64Click()' & @CRLF)
	$App_Architecture = 2
	$App_Runx64 = True
	GUICtrlSetState($Checkbox_RunAsx64, $GUI_CHECKED)
EndFunc

Func Radio_Arch_x86Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_Arch_x86Click()' & @CRLF)
	$App_Architecture = 1
	$App_Runx64 = False
	GUICtrlSetState($Checkbox_RunAsx64, $GUI_UNCHECKED)
EndFunc
Func Radio_Build_ppApp_sscClick()
	GUICtrlSetState($Radio_Shortcuts_No, $GUI_ENABLE)
	GUICtrlSetState($Radio_Shortcuts_Yes, $GUI_ENABLE)
	GUICtrlSetState($Label_Title_ssc, $GUI_ENABLE)
	GUICtrlSetState($Input_Title_ssc, $GUI_ENABLE)
	GUICtrlSetState($Label_AppPath_ssc, $GUI_ENABLE)
	GUICtrlSetState($Input_AppPath_ssc, $GUI_ENABLE)
EndFunc

Func Radio_Build_ppAppClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_Build_ppAppClick()' & @CRLF)
	$App_Type = 3
	GUICtrlSetState($Radio_Build_ppApp, $GUI_CHECKED)
	If FileExists($SrcPath & '\ppApp.png') Then
		GUICtrlSetState($Button_Fader, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewFader, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\ppApp.ico') Then
		GUICtrlSetState($Button_Icon, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewIcon, $GUI_ENABLE) ;$MenuItem_ViewIcon
	EndIf
	If FileExists($SrcPath & '\ppApp.jpg') Then
		GUICtrlSetState($Button_ScrShot, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewScrShot, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\ppApp.cmd') Then
		GUICtrlSetState($Button_cmd, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewCMD, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\ppApp.reg') Then
		GUICtrlSetState($Button_Reg, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewReg, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\patch\') Or FileExists($SrcPath & '\ppApp\') Then
		GUICtrlSetState($Button_PatchFolder, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewPatchFolder, $GUI_ENABLE)
	EndIf
	GUICtrlSetState($Radio_Arch_DualArch, $GUI_ENABLE)
	GUICtrlSetState($Group_Installers, $GUI_ENABLE)
	GUICtrlSetData($Group_Installers, 'Pre-processing Details')
	GUICtrlSetState($Combo_Installer, $GUI_DISABLE)
	GUICtrlSetState($Edit_Installers, $GUI_ENABLE)
	GUICtrlSetState($Button_Installer, $GUI_DISABLE)
	GUICtrlSetState($Label_Installer, $GUI_DISABLE)
	GUICtrlSetState($Label_Switches, $GUI_DISABLE)
	GUICtrlSetState($Input_Switches, $GUI_DISABLE)
	GUICtrlSetState($Label_SwitchNotes, $GUI_DISABLE)
	GUICtrlSetState($Input_SwitchNotes, $GUI_DISABLE)
	GUICtrlSetState($Button_Add_Installer, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_Game, $GUI_UNCHECKED)

	GUICtrlSetState($Group_scLocations, $GUI_ENABLE)
	GUICtrlSetState($Edit_CatalogList, $GUI_ENABLE)
	GUICtrlSetState($Label_scLocations, $GUI_ENABLE)
	GUICtrlSetState($Combo_Catalog, $GUI_ENABLE)
	GUICtrlSetState($Label_Catalog, $GUI_ENABLE)
	GUICtrlSetState($Button_AddMenuCatalog, $GUI_ENABLE)
	GUICtrlSetState($Input_DefaultMenu, $GUI_ENABLE)
	GUICtrlSetState($Button_BrowseStartMenu, $GUI_ENABLE)
	GUICtrlSetState($Label_DefaultMenu, $GUI_ENABLE)

	GUICtrlSetState($Group_scTo, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scStartMenu, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scRoot, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scPrograms, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scStartup, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scDesktop, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scQLaunch, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scTaskbarPin, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scStartmenuPin, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scSendTo, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scAllUsers, $GUI_ENABLE)
	GUICtrlSetState($Group_scOptions, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scNeverSort, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scAlwaysSort, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scKeepInFolder, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scKeepAll, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_NoMenuIcons, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_LivePE, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_MakeNonething, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_NeverUpdateAppFile, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_MetroFriendly, $GUI_ENABLE)

	GUICtrlSetState($Group_FileAssoc, $GUI_ENABLE)
	GUICtrlSetState($Edit_FileAssoc, $GUI_ENABLE)
	GUICtrlSetState($Edit_RegisterDLL, $GUI_ENABLE)
	GUICtrlSetState($Edit_InstallFonts, $GUI_ENABLE)
	GUICtrlSetState($Group_scDetails, $GUI_ENABLE)
	GUICtrlSetState($Label_scName, $GUI_ENABLE)
	GUICtrlSetState($Combo_scName, $GUI_ENABLE)
	GUICtrlSetState($Button_scNameBrowse, $GUI_ENABLE)
	GUICtrlSetState($Label_scTarget, $GUI_ENABLE)
	GUICtrlSetState($Input_scTarget, $GUI_ENABLE)
	GUICtrlSetState($Label_scWorkDir, $GUI_ENABLE)
	GUICtrlSetState($Input_scWorkDir, $GUI_ENABLE)
	GUICtrlSetState($Button_scFile, $GUI_ENABLE)
	GUICtrlSetState($Label_scIcon, $GUI_ENABLE)
	GUICtrlSetState($Input_scIcon, $GUI_ENABLE)
;~ 	GUICtrlSetState($Button_scIcon, $GUI_ENABLE)
	GUICtrlSetState($Label_scArgs, $GUI_ENABLE)
	GUICtrlSetState($Input_scArgs, $GUI_ENABLE)
	GUICtrlSetState($Label_scExt, $GUI_ENABLE)
	GUICtrlSetState($Input_scExt, $GUI_ENABLE)
	GUICtrlSetState($Label_scDesc, $GUI_ENABLE)
	GUICtrlSetState($Input_scDesc, $GUI_ENABLE)
	GUICtrlSetState($Label_scIndex, $GUI_ENABLE)
	GUICtrlSetState($Input_scIndex, $GUI_ENABLE)
	GUICtrlSetState($Label_scKeep, $GUI_ENABLE)
	GUICtrlSetState($Button_scKeep, $GUI_ENABLE)
	GUICtrlSetState($Edit_scKeep, $GUI_ENABLE)
	GUICtrlSetState($Button_scNew, $GUI_ENABLE)
	GUICtrlSetState($Button_scNameRemove, $GUI_ENABLE)
	GUICtrlSetState($Button_scUp, $GUI_ENABLE)
	GUICtrlSetState($Button_scDown, $GUI_ENABLE)
	GUICtrlSetState($Label_scCount, $GUI_ENABLE)
	GUICtrlSetState($MenuItem_ScreenCapture, $GUI_ENABLE)
	GUICtrlSetState($Label_scFlags, $GUI_ENABLE)
	GUICtrlSetState($Input_scFlags, $GUI_ENABLE)
;~ 	GUICtrlSetState($Label_scCatalog, $GUI_ENABLE)
;~ 	GUICtrlSetState($Input_scCatalog, $GUI_ENABLE)
	GUICtrlSetState($Label_scKey, $GUI_ENABLE)
	GUICtrlSetState($Input_scKey, $GUI_ENABLE)
	If GUICtrlGetState($Radio_Arch_DualArch) = $GUI_ENABLE Then
		ppArchiveCheck()
	Else
		GUICtrlSetState($Button_GetppExtractedSize, $GUI_DISABLE)
	EndIf
	If $App_InstallPath <> '' Then ;Input_AppPath
		Local $change = ''
		Select
			Case StringInStr($App_InstallPath, @ProgramFilesDir) = 1
				$change = @ProgramFilesDir
			Case StringInStr($App_InstallPath, @CommonFilesDir) = 1
				$change = @CommonFilesDir
			Case StringInStr($App_InstallPath, @WindowsDir) = 1
				$change = @WindowsDir
			Case StringInStr($App_InstallPath, @SystemDir) = 1
				$change = @SystemDir
			Case StringInStr($App_InstallPath, EnvGet('PROGRAMFILES(X86)')) = 1
				$change = EnvGet('PROGRAMFILES(X86)')
			Case StringInStr($App_InstallPath, EnvGet('COMMONPROGRAMFILES(x86)')) = 1
				$change = EnvGet('COMMONPROGRAMFILES(x86)')
			Case StringInStr($App_InstallPath, ConvertFromVars('%ppGames%')) = 1
				$change = ConvertFromVars('%ppGames%')
		EndSelect
		If $change <> '' Then
			$App_InstallPath = StringReplace($App_InstallPath, $change, ConvertFromVars('%ppApps%'), 1)
			Populate_AppPath()
		EndIf
	EndIf
	BuildOptToggle()
	Checkbox_GameClick()
;~ 	ConvertBackAllPathVars()
	If $App_InstallPath <> '' Then Populate_AppPath()
	ChangesMade()
EndFunc

Func Radio_Build_ppGame_sscClick()
	GUICtrlSetState($Radio_Shortcuts_No, $GUI_ENABLE)
	GUICtrlSetState($Radio_Shortcuts_Yes, $GUI_ENABLE)
	GUICtrlSetState($Label_Title_ssc, $GUI_ENABLE)
	GUICtrlSetState($Input_Title_ssc, $GUI_ENABLE)
	GUICtrlSetState($Label_AppPath_ssc, $GUI_ENABLE)
	GUICtrlSetState($Input_AppPath_ssc, $GUI_ENABLE)
EndFunc

Func Radio_Build_ppGameClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_Build_ppGameClick()' & @CRLF)
	$App_Type = 5
	GUICtrlSetState($Radio_Build_ppGame, $GUI_CHECKED)
	If FileExists($SrcPath & '\ppGame.png') Then
		GUICtrlSetState($Button_Fader, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewFader, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\ppGame.ico') Then
		GUICtrlSetState($Button_Icon, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewIcon, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\ppGame.jpg') Then
		GUICtrlSetState($Button_ScrShot, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewScrShot, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\ppGame.cmd') Then
		GUICtrlSetState($Button_cmd, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewCMD, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\ppGame.reg') Then
		GUICtrlSetState($Button_Reg, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewReg, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\patch\') Or FileExists($SrcPath & '\ppGame\') Then
		GUICtrlSetState($Button_PatchFolder, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewPatchFolder, $GUI_ENABLE)
	EndIf
	GUICtrlSetState($Radio_Arch_DualArch, $GUI_ENABLE)
	GUICtrlSetState($Group_Installers, $GUI_DISABLE)
	GUICtrlSetState($Combo_Installer, $GUI_DISABLE)
	GUICtrlSetState($Edit_Installers, $GUI_ENABLE)
	GUICtrlSetState($Button_Installer, $GUI_DISABLE)
	GUICtrlSetState($Label_Installer, $GUI_DISABLE)
	GUICtrlSetState($Label_Switches, $GUI_DISABLE)
	GUICtrlSetState($Input_Switches, $GUI_DISABLE)
	GUICtrlSetState($Label_SwitchNotes, $GUI_DISABLE)
	GUICtrlSetState($Input_SwitchNotes, $GUI_DISABLE)
	GUICtrlSetState($Button_Add_Installer, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_Game, $GUI_CHECKED)
	GUICtrlSetState($Group_scLocations, $GUI_ENABLE)
	GUICtrlSetState($Edit_CatalogList, $GUI_ENABLE)
	GUICtrlSetState($Label_scLocations, $GUI_ENABLE)
	GUICtrlSetState($Combo_Catalog, $GUI_ENABLE)
	GUICtrlSetState($Label_Catalog, $GUI_ENABLE)
	GUICtrlSetState($Button_AddMenuCatalog, $GUI_ENABLE)
	GUICtrlSetState($Input_DefaultMenu, $GUI_ENABLE)
	GUICtrlSetState($Button_BrowseStartMenu, $GUI_ENABLE)
	GUICtrlSetState($Label_DefaultMenu, $GUI_ENABLE)

	GUICtrlSetState($Group_scTo, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scStartMenu, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scRoot, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scPrograms, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scStartup, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scDesktop, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scQLaunch, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scTaskbarPin, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scStartmenuPin, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scSendTo, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scAllUsers, $GUI_ENABLE)
	GUICtrlSetState($Group_scOptions, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scNeverSort, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scAlwaysSort, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scKeepInFolder, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scKeepAll, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_NoMenuIcons, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_LivePE, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_MakeNonething, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_NeverUpdateAppFile, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_MetroFriendly, $GUI_ENABLE)

	GUICtrlSetState($Group_FileAssoc, $GUI_ENABLE)
	GUICtrlSetState($Edit_FileAssoc, $GUI_ENABLE)
	GUICtrlSetState($Edit_InstallFonts, $GUI_ENABLE)
	GUICtrlSetState($Edit_RegisterDLL, $GUI_ENABLE)
	GUICtrlSetState($Group_scDetails, $GUI_ENABLE)
	GUICtrlSetState($Label_scName, $GUI_ENABLE)
	GUICtrlSetState($Combo_scName, $GUI_ENABLE)
	GUICtrlSetState($Button_scNameBrowse, $GUI_ENABLE)
	GUICtrlSetState($Label_scTarget, $GUI_ENABLE)
	GUICtrlSetState($Input_scTarget, $GUI_ENABLE)
	GUICtrlSetState($Label_scWorkDir, $GUI_ENABLE)
	GUICtrlSetState($Input_scWorkDir, $GUI_ENABLE)
	GUICtrlSetState($Button_scFile, $GUI_ENABLE)
	GUICtrlSetState($Label_scIcon, $GUI_ENABLE)
	GUICtrlSetState($Input_scIcon, $GUI_ENABLE)
;~ 	GUICtrlSetState($Button_scIcon, $GUI_ENABLE)
	GUICtrlSetState($Label_scArgs, $GUI_ENABLE)
	GUICtrlSetState($Input_scArgs, $GUI_ENABLE)
	GUICtrlSetState($Label_scExt, $GUI_ENABLE)
	GUICtrlSetState($Input_scExt, $GUI_ENABLE)
	GUICtrlSetState($Label_scDesc, $GUI_ENABLE)
	GUICtrlSetState($Input_scDesc, $GUI_ENABLE)
	GUICtrlSetState($Label_scIndex, $GUI_ENABLE)
	GUICtrlSetState($Input_scIndex, $GUI_ENABLE)
	GUICtrlSetState($Label_scKeep, $GUI_ENABLE)
	GUICtrlSetState($Button_scKeep, $GUI_ENABLE)
	GUICtrlSetState($Edit_scKeep, $GUI_ENABLE)
	GUICtrlSetState($Button_scNew, $GUI_ENABLE)
	GUICtrlSetState($Button_scNameRemove, $GUI_ENABLE)
	GUICtrlSetState($Button_scUp, $GUI_ENABLE)
	GUICtrlSetState($Button_scDown, $GUI_ENABLE)
	GUICtrlSetState($Label_scCount, $GUI_ENABLE)
	GUICtrlSetState($MenuItem_ScreenCapture, $GUI_ENABLE)
	GUICtrlSetState($Label_scFlags, $GUI_ENABLE)
	GUICtrlSetState($Input_scFlags, $GUI_ENABLE)
;~ 	GUICtrlSetState($Label_scCatalog, $GUI_ENABLE)
;~ 	GUICtrlSetState($Input_scCatalog, $GUI_ENABLE)
	GUICtrlSetState($Label_scKey, $GUI_ENABLE)
	GUICtrlSetState($Input_scKey, $GUI_ENABLE)
	ppArchiveCheck()

	If $App_InstallPath <> '' Then ;Input_AppPath
		Local $change = ''
		Select
			Case StringInStr($App_InstallPath, @ProgramFilesDir) = 1
				$change = @ProgramFilesDir
			Case StringInStr($App_InstallPath, @CommonFilesDir) = 1
				$change = @CommonFilesDir
			Case StringInStr($App_InstallPath, @WindowsDir) = 1
				$change = @WindowsDir
			Case StringInStr($App_InstallPath, @SystemDir) = 1
				$change = @SystemDir
			Case StringInStr($App_InstallPath, EnvGet('PROGRAMFILES(X86)')) = 1
				$change = EnvGet('PROGRAMFILES(X86)')
			Case StringInStr($App_InstallPath, EnvGet('COMMONPROGRAMFILES(x86)')) = 1
				$change = EnvGet('COMMONPROGRAMFILES(x86)')
			Case StringInStr($App_InstallPath, ConvertFromVars('%ppApps%')) = 1
				$change = ConvertFromVars('%ppApps%')
		EndSelect
		If $change <> '' Then
			$App_InstallPath = StringReplace($App_InstallPath, $change, ConvertFromVars('%ppGames%'), 1)
			Populate_AppPath()
		EndIf
	EndIf
	BuildOptToggle()
	Checkbox_GameClick()
;~ 	ConvertBackAllPathVars()
	If $App_InstallPath <> '' Then Populate_AppPath()
	ChangesMade()
EndFunc
Func Radio_Build_ppTweak_sscClick()
	GUICtrlSetState($Radio_Shortcuts_No, $GUI_ENABLE)
	GUICtrlSetState($Radio_Shortcuts_Yes, $GUI_ENABLE)
	GUICtrlSetState($Label_Title_ssc, $GUI_ENABLE)
	GUICtrlSetState($Input_Title_ssc, $GUI_ENABLE)
	GUICtrlSetState($Label_AppPath_ssc, $GUI_ENABLE)
	GUICtrlSetState($Input_AppPath_ssc, $GUI_ENABLE)
	GUICtrlSetState($Radio_Shortcuts_No, $GUI_CHECKED)
	GUICtrlSetState($Input_DefaultMenu_ssc, $GUI_DISABLE)
	GUICtrlSetState($Button_BrowseStartMenu, $GUI_DISABLE)
	GUICtrlSetState($Label_DefaultMenu, $GUI_DISABLE)
EndFunc

Func Radio_Build_ppTweakClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_Build_ppTweakClick()' & @CRLF)
	$App_Type = 4
	$scSelected = 0
	$App_scCount = 0
	GUICtrlSetState($Radio_Build_ppTweak, $GUI_CHECKED)
	If FileExists($SrcPath & '\ppApp.png') Then
		GUICtrlSetState($Button_Fader, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewFader, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\ppApp.ico') Then
		GUICtrlSetState($Button_Icon, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewIcon, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\ppApp.jpg') Then
		GUICtrlSetState($Button_ScrShot, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewScrShot, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\ppApp.cmd') Then
		GUICtrlSetState($Button_cmd, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewCMD, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\ppApp.reg') Then
		GUICtrlSetState($Button_Reg, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewReg, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\patch\') Or FileExists($SrcPath & '\ppApp\') Then
		GUICtrlSetState($Button_PatchFolder, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewPatchFolder, $GUI_ENABLE)
	EndIf
	GUICtrlSetState($Radio_Arch_DualArch, $GUI_UNCHECKED)
	GUICtrlSetState($Radio_Arch_DualArch, $GUI_DISABLE)
	GUICtrlSetState($Group_Installers, $GUI_DISABLE)
	GUICtrlSetState($Combo_Installer, $GUI_DISABLE)
	GUICtrlSetState($Edit_Installers, $GUI_ENABLE)
	GUICtrlSetState($Button_Installer, $GUI_DISABLE)
	GUICtrlSetState($Label_Installer, $GUI_DISABLE)
	GUICtrlSetState($Label_Switches, $GUI_DISABLE)
	GUICtrlSetState($Input_Switches, $GUI_DISABLE)
	GUICtrlSetState($Label_SwitchNotes, $GUI_DISABLE)
	GUICtrlSetState($Input_SwitchNotes, $GUI_DISABLE)
	GUICtrlSetState($Button_Add_Installer, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_Game, $GUI_UNCHECKED)
	GUICtrlSetState($Group_scLocations, $GUI_DISABLE)
	GUICtrlSetState($Edit_CatalogList, $GUI_DISABLE)
	GUICtrlSetState($Label_scLocations, $GUI_DISABLE)
	GUICtrlSetState($Combo_Catalog, $GUI_DISABLE)
	GUICtrlSetState($Label_Catalog, $GUI_DISABLE)
	GUICtrlSetState($Input_DefaultMenu, $GUI_DISABLE)
	GUICtrlSetState($Button_BrowseStartMenu, $GUI_DISABLE)
	GUICtrlSetState($Label_DefaultMenu, $GUI_DISABLE)

	GUICtrlSetState($Group_scTo, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_scStartMenu, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_scRoot, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_scPrograms, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_scStartup, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_scDesktop, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_scQLaunch, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_scTaskbarPin, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_scStartmenuPin, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_scSendTo, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_scAllUsers, $GUI_DISABLE)
	GUICtrlSetState($Group_scOptions, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_scNeverSort, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_scAlwaysSort, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_scKeepInFolder, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_scKeepAll, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_NoMenuIcons, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_LivePE, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_MakeNonething, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_NeverUpdateAppFile, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_MetroFriendly, $GUI_ENABLE)

	GUICtrlSetState($Group_FileAssoc, $GUI_DISABLE)
	GUICtrlSetState($Edit_FileAssoc, $GUI_DISABLE)
	GUICtrlSetState($Edit_InstallFonts, $GUI_DISABLE)
	GUICtrlSetState($Edit_RegisterDLL, $GUI_DISABLE)
	GUICtrlSetState($Group_scDetails, $GUI_DISABLE)
	GUICtrlSetState($Label_scName, $GUI_DISABLE)
	GUICtrlSetState($Combo_scName, $GUI_DISABLE)
	GUICtrlSetState($Button_scNameBrowse, $GUI_DISABLE)
	GUICtrlSetState($Label_scTarget, $GUI_DISABLE)
	GUICtrlSetState($Input_scTarget, $GUI_DISABLE)
	GUICtrlSetState($Label_scWorkDir, $GUI_DISABLE)
	GUICtrlSetState($Input_scWorkDir, $GUI_DISABLE)
	GUICtrlSetState($Button_scFile, $GUI_DISABLE)
	GUICtrlSetState($Label_scIcon, $GUI_DISABLE)
	GUICtrlSetState($Input_scIcon, $GUI_DISABLE)
;~ 	GUICtrlSetState($Button_scIcon, $GUI_DISABLE)
	GUICtrlSetState($Label_scArgs, $GUI_DISABLE)
	GUICtrlSetState($Input_scArgs, $GUI_DISABLE)
	GUICtrlSetState($Label_scExt, $GUI_DISABLE)
	GUICtrlSetState($Input_scExt, $GUI_DISABLE)
	GUICtrlSetState($Label_scDesc, $GUI_DISABLE)
	GUICtrlSetState($Input_scDesc, $GUI_DISABLE)
	GUICtrlSetState($Label_scIndex, $GUI_DISABLE)
	GUICtrlSetState($Input_scIndex, $GUI_DISABLE)
	GUICtrlSetState($Label_scKeep, $GUI_DISABLE)
	GUICtrlSetState($Button_scKeep, $GUI_DISABLE)
	GUICtrlSetState($Edit_scKeep, $GUI_DISABLE)
	GUICtrlSetState($Button_scNew, $GUI_DISABLE)
	GUICtrlSetState($Button_scNameRemove, $GUI_DISABLE)
	GUICtrlSetState($Button_scUp, $GUI_DISABLE)
	GUICtrlSetState($Button_scDown, $GUI_DISABLE)
	GUICtrlSetState($Label_scCount, $GUI_DISABLE)
	GUICtrlSetState($MenuItem_ScreenCapture, $GUI_ENABLE)
	GUICtrlSetState($Button_GetppExtractedSize, $GUI_DISABLE)
	GUICtrlSetState($Label_scFlags, $GUI_ENABLE)
	GUICtrlSetState($Input_scFlags, $GUI_ENABLE)
;~ 	GUICtrlSetState($Label_scCatalog, $GUI_ENABLE)
;~ 	GUICtrlSetState($Input_scCatalog, $GUI_ENABLE)
	GUICtrlSetState($Label_scKey, $GUI_ENABLE)
	GUICtrlSetState($Input_scKey, $GUI_ENABLE)

	If $App_InstallPath <> '' Then ;Input_AppPath
		Local $change = ''
		Select
			Case StringInStr($App_InstallPath, @ProgramFilesDir) = 1
				$change = @ProgramFilesDir
			Case StringInStr($App_InstallPath, @CommonFilesDir) = 1
				$change = @CommonFilesDir
			Case StringInStr($App_InstallPath, @WindowsDir) = 1
				$change = @WindowsDir
			Case StringInStr($App_InstallPath, @SystemDir) = 1
				$change = @SystemDir
			Case StringInStr($App_InstallPath, EnvGet('PROGRAMFILES(X86)')) = 1
				$change = EnvGet('PROGRAMFILES(X86)')
			Case StringInStr($App_InstallPath, EnvGet('COMMONPROGRAMFILES(x86)')) = 1
				$change = EnvGet('COMMONPROGRAMFILES(x86)')
			Case StringInStr($App_InstallPath, ConvertFromVars('%ppGames%')) = 1
				$change = ConvertFromVars('%ppGames%')
		EndSelect
		If $change <> '' Then
			$App_InstallPath = StringReplace($App_InstallPath, $change, ConvertFromVars('%ppApps%'), 1)
			Populate_AppPath()
		EndIf
	EndIf
	BuildOptToggle()
	Checkbox_GameClick()
;~ 	ConvertBackAllPathVars()
	If $App_InstallPath <> '' Then Populate_AppPath()
	ChangesMade()
EndFunc
Func Radio_Build_ssApp_sscClick()
	GUICtrlSetState($Radio_Shortcuts_No, $GUI_ENABLE)
	GUICtrlSetState($Radio_Shortcuts_Yes, $GUI_ENABLE)
	GUICtrlSetState($Label_Title_ssc, $GUI_ENABLE)
	GUICtrlSetState($Input_Title_ssc, $GUI_ENABLE)
	GUICtrlSetState($Label_AppPath_ssc, $GUI_ENABLE)
	GUICtrlSetState($Input_AppPath_ssc, $GUI_ENABLE)
EndFunc

Func Radio_Build_ssAppClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_Build_ssAppClick()' & @CRLF)
	$App_Type = 2
	GUICtrlSetState($Radio_Build_ssApp, $GUI_CHECKED)
	If FileExists($SrcPath & '\SetupS.png') Or FileExists($SrcPath & '\ssApp.png') Then
		GUICtrlSetState($Button_Fader, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewFader, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\SetupS.ico') Or FileExists($SrcPath & '\ssApp.ico') Then
		GUICtrlSetState($Button_Icon, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewIcon, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\SetupS.jpg') Or FileExists($SrcPath & '\ssApp.jpg') Then
		GUICtrlSetState($Button_ScrShot, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewScrShot, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\SetupS.cmd') Or FileExists($SrcPath & '\ssApp.cmd') Then
		GUICtrlSetState($Button_cmd, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewCMD, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\SetupS.reg') Or FileExists($SrcPath & '\ssApp.reg') Then
		GUICtrlSetState($Button_Reg, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewReg, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_IntegrateRegCmd, $GUI_ENABLE)
	EndIf
	If FileExists($SrcPath & '\patch\') Or FileExists($SrcPath & '\SetupS\') Or FileExists($SrcPath & '\ssApp\') Then
		GUICtrlSetState($Button_PatchFolder, $GUI_ENABLE)
		GUICtrlSetState($MenuItem_ViewPatchFolder, $GUI_ENABLE)
	EndIf
	GUICtrlSetState($Radio_Arch_DualArch, $GUI_UNCHECKED)
	GUICtrlSetState($Radio_Arch_DualArch, $GUI_DISABLE)
	GUICtrlSetState($Group_Installers, $GUI_ENABLE)
	GUICtrlSetState($Combo_Installer, $GUI_ENABLE)
	GUICtrlSetState($Edit_Installers, $GUI_ENABLE)
	GUICtrlSetState($Button_Installer, $GUI_ENABLE)
	GUICtrlSetState($Label_Installer, $GUI_ENABLE)
	GUICtrlSetState($Label_Switches, $GUI_ENABLE)
	GUICtrlSetState($Input_Switches, $GUI_ENABLE)
	GUICtrlSetState($Label_SwitchNotes, $GUI_ENABLE)
	GUICtrlSetState($Input_SwitchNotes, $GUI_ENABLE)
	GUICtrlSetState($Button_Add_Installer, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_Game, $GUI_UNCHECKED)
	GUICtrlSetState($Group_scLocations, $GUI_ENABLE)
	GUICtrlSetState($Edit_CatalogList, $GUI_ENABLE)
	GUICtrlSetState($Label_scLocations, $GUI_ENABLE)
	GUICtrlSetState($Combo_Catalog, $GUI_ENABLE)
	GUICtrlSetState($Label_Catalog, $GUI_ENABLE)
	GUICtrlSetState($Button_AddMenuCatalog, $GUI_ENABLE)
	GUICtrlSetState($Input_DefaultMenu, $GUI_ENABLE)
	GUICtrlSetState($Button_BrowseStartMenu, $GUI_ENABLE)
	GUICtrlSetState($Label_DefaultMenu, $GUI_ENABLE)

	GUICtrlSetState($Group_scTo, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scStartMenu, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scRoot, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scPrograms, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scStartup, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scDesktop, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scQLaunch, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scTaskbarPin, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scStartmenuPin, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scSendTo, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scAllUsers, $GUI_ENABLE)
	GUICtrlSetState($Group_scOptions, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scNeverSort, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scAlwaysSort, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scKeepInFolder, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_scKeepAll, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_NoMenuIcons, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_LivePE, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_MakeNonething, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_NeverUpdateAppFile, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_MetroFriendly, $GUI_ENABLE)

	GUICtrlSetState($Group_FileAssoc, $GUI_ENABLE)
	GUICtrlSetState($Edit_FileAssoc, $GUI_ENABLE)
	GUICtrlSetState($Edit_InstallFonts, $GUI_ENABLE)
	GUICtrlSetState($Edit_RegisterDLL, $GUI_ENABLE)
	GUICtrlSetState($Group_scDetails, $GUI_ENABLE)
	GUICtrlSetState($Label_scName, $GUI_ENABLE)
	GUICtrlSetState($Combo_scName, $GUI_ENABLE)
	GUICtrlSetState($Button_scNameBrowse, $GUI_ENABLE)
	GUICtrlSetState($Label_scTarget, $GUI_ENABLE)
	GUICtrlSetState($Input_scTarget, $GUI_ENABLE)
	GUICtrlSetState($Label_scWorkDir, $GUI_ENABLE)
	GUICtrlSetState($Input_scWorkDir, $GUI_ENABLE)
	GUICtrlSetState($Button_scFile, $GUI_ENABLE)
	GUICtrlSetState($Label_scIcon, $GUI_ENABLE)
	GUICtrlSetState($Input_scIcon, $GUI_ENABLE)
;~ 	GUICtrlSetState($Button_scIcon, $GUI_ENABLE)
	GUICtrlSetState($Label_scArgs, $GUI_ENABLE)
	GUICtrlSetState($Input_scArgs, $GUI_ENABLE)
	GUICtrlSetState($Label_scExt, $GUI_ENABLE)
	GUICtrlSetState($Input_scExt, $GUI_ENABLE)
	GUICtrlSetState($Label_scDesc, $GUI_ENABLE)
	GUICtrlSetState($Input_scDesc, $GUI_ENABLE)
	GUICtrlSetState($Label_scIndex, $GUI_ENABLE)
	GUICtrlSetState($Input_scIndex, $GUI_ENABLE)
	GUICtrlSetState($Label_scKeep, $GUI_ENABLE)
	GUICtrlSetState($Button_scKeep, $GUI_ENABLE)
	GUICtrlSetState($Edit_scKeep, $GUI_ENABLE)
	GUICtrlSetState($Button_scNew, $GUI_ENABLE)
	GUICtrlSetState($Button_scNameRemove, $GUI_ENABLE)
	GUICtrlSetState($Button_scUp, $GUI_ENABLE)
	GUICtrlSetState($Button_scDown, $GUI_ENABLE)
	GUICtrlSetState($Label_scCount, $GUI_ENABLE)
	GUICtrlSetState($MenuItem_ScreenCapture, $GUI_ENABLE)
	GUICtrlSetState($Button_GetppExtractedSize, $GUI_DISABLE)
	GUICtrlSetState($Label_scFlags, $GUI_ENABLE)
	GUICtrlSetState($Input_scFlags, $GUI_ENABLE)
;~ 	GUICtrlSetState($Label_scCatalog, $GUI_ENABLE)
;~ 	GUICtrlSetState($Input_scCatalog, $GUI_ENABLE)
	GUICtrlSetState($Label_scKey, $GUI_ENABLE)
	GUICtrlSetState($Input_scKey, $GUI_ENABLE)

	If $App_InstallPath <> '' Then ;Input_AppPath
		Local $change = ''
		Select
			Case StringInStr($App_InstallPath, ConvertFromVars('%ppApps%')) = 1
				$change = ConvertFromVars('%ppApps%')
			Case StringInStr($App_InstallPath, ConvertFromVars('%ppGames%')) = 1
				$change = ConvertFromVars('%ppGames%')
		EndSelect
		If $change <> '' Then
			$App_InstallPath = StringReplace($App_InstallPath, $change, ConvertFromVars('%ProgramFiles%'), 1)
			Populate_AppPath()
		EndIf
	EndIf
	BuildOptToggle()
	Checkbox_GameClick()
;~ 	ConvertBackAllPathVars()
	If $App_InstallPath <> '' Then Populate_AppPath()
	ChangesMade()
EndFunc
Func Radio_LicenseType_GratisClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_LicenseType_GratisClick()' & @CRLF)
	$App_LicenseType = 2
EndFunc
Func Radio_LicenseType_LibreClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_LicenseType_LibreClick()' & @CRLF)
	$App_LicenseType = 3
EndFunc

;<LicenseType>
Func Radio_LicenseType_NAClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_LicenseType_NAClick()' & @CRLF)
	$App_LicenseType = 0
EndFunc
Func Radio_LicenseType_NonGratisClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_LicenseType_NonGratisClick()' & @CRLF)
	$App_LicenseType = 1
EndFunc
Func Radio_Shortcuts_NoClick()
	GUICtrlSetState($Input_DefaultMenu_ssc, $GUI_DISABLE)
	GUICtrlSetState($Button_BrowseStartMenu_ssc, $GUI_DISABLE)
	GUICtrlSetState($Label_DefaultMenu_ssc, $GUI_DISABLE)
EndFunc
Func Radio_Shortcuts_YesClick()
	GUICtrlSetState($Input_DefaultMenu_ssc, $GUI_ENABLE)
	GUICtrlSetState($Button_BrowseStartMenu_ssc, $GUI_ENABLE)
	GUICtrlSetState($Label_DefaultMenu_ssc, $GUI_ENABLE)
EndFunc

Func ReadFormData()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ReadFormData()' & @CRLF)
	Local $i, $s
	$FormMode = False
	Button_scNameAddClick()
	$App_Title = GUICtrlRead($Input_Title)
	$App_Version = GUICtrlRead($Input_Version)
	If GUICtrlRead($Edit_URLs) <> '' Then
		$s = StringReplace(GUICtrlRead($Edit_URLs), @CRLF, @CR)
		$s = StringStripWS($s, 3)
		$s = StringReplace($s, ' ', Chr(31))
		$s = StringReplace(StringStripWS(StringReplace($s, @CR, ' '), 7), ' ', @CR)
		$s = StringReplace($s, Chr(31), ' ')
		$App_URL = StringSplit($s, @CR)
	Else
		ReDim $App_URL[1]
		$App_URL[0] = 0
		$Edit_URLs_Data = ''
	EndIf
	If GUICtrlRead($Combo_Installer) <> '' And Not $Installer_Change Then Button_Add_InstallerClick()
	If GUICtrlRead($Edit_Installers) <> '' Then
		$App_Assembly = StringSplit(StringReplace(GUICtrlRead($Edit_Installers), @CRLF, @CR), @CR)
	Else
		ReDim $App_Assembly[1]
		$App_Assembly[0] = 0
		$Edit_Installers_Data = ''
	EndIf
	If GUICtrlRead($Edit_Description) <> '' Then
		$App_Description = StringSplit(StringReplace(GUICtrlRead($Edit_Description), @CRLF, @CR), @CR)
	Else
		ReDim $App_Description[1]
		$App_Description[0] = 0
		$Edit_Description_Data = ''
	EndIf
	If GUICtrlRead($Combo_Category) <> '' Then Button_AddCategoryClick()
	If GUICtrlRead($Input_Categories) <> '' Then
		$App_Category = SingleLine2Multi(GUICtrlRead($Input_Categories), '|')
		If IsArray($App_Category) And GUICtrlRead($Checkbox_Game) = $GUI_CHECKED Then
			For $i = 1 To $App_Category[0]
				If StringLeft($App_Category[$i], StringLen('Games\')) <> 'Games\' Then $App_Category[$i] = 'Games\' & $App_Category[$i]
			Next
		EndIf
	Else
		ReDim $App_Category[1]
		$App_Category[0] = 0
	EndIf
	If GUICtrlRead($Combo_Catalog) <> '' Then Button_AddMenuCatalogClick()
	If GUICtrlRead($Edit_CatalogList) <> '' Then
		$App_Catalog = StringSplit(StringReplace(GUICtrlRead($Edit_CatalogList), @CRLF, @CR), @CR)
		If IsArray($App_Catalog) And GUICtrlRead($Checkbox_Game) = $GUI_CHECKED Then
			For $i = 1 To $App_Catalog[0]
				If StringLeft($App_Catalog[$i], StringLen('Game ')) <> 'Game ' Then $App_Catalog[$i] = 'Game ' & $App_Catalog[$i]
			Next
		EndIf
	Else
		ReDim $App_Catalog[1]
		$App_Catalog[0] = 0
		$Edit_CatalogList_Data = ''
	EndIf
	If GUICtrlRead($Combo_Tags) <> '' Then
		Button_AddTagClick(@ScriptLineNumber)
	EndIf
	If GUICtrlRead($Input_Tags) <> '' Then
		;$App_Tags = SingleLine2Multi(GUICtrlRead($Input_Tags), '|')
		;If IsArray($App_Tags) And GUICtrlRead($Checkbox_Game) = $GUI_CHECKED Then
		;	For $i = 1 To $App_Tags[0]
		;		If StringLeft($App_Tags[$i], StringLen('Game ')) <> 'Game ' Then $App_Tags[$i] = 'Game ' & $App_Tags[$i]
		;	Next
		;EndIf
	Else
		ReDim $App_Tags[1]
		$App_Tags[0] = 0
	EndIf
	$App_MakeStartMenu = GUICtrlRead($Checkbox_scStartMenu) = $GUI_CHECKED
	$App_MakeInRoot = GUICtrlRead($Checkbox_scRoot) = $GUI_CHECKED
	$App_MakeInPrograms = GUICtrlRead($Checkbox_scPrograms) = $GUI_CHECKED
	$App_MakeStartup = GUICtrlRead($Checkbox_scStartup) = $GUI_CHECKED
	$App_MakeDesktop = GUICtrlRead($Checkbox_scDesktop) = $GUI_CHECKED
	$App_MakeQuickLaunch = GUICtrlRead($Checkbox_scQLaunch) = $GUI_CHECKED
	$App_TaskbarPin = GUICtrlRead($Checkbox_scTaskbarPin) = $GUI_CHECKED
	$App_StartmenuPin = GUICtrlRead($Checkbox_scStartmenuPin) = $GUI_CHECKED
	$App_MakeSendTo = GUICtrlRead($Checkbox_scSendTo) = $GUI_CHECKED
	$App_AllUsers = GUICtrlRead($Checkbox_scAllUsers) = $GUI_CHECKED
	$App_NeverSort = GUICtrlRead($Checkbox_scNeverSort) = $GUI_CHECKED
	$App_AlwaysSort = GUICtrlRead($Checkbox_scAlwaysSort) = $GUI_CHECKED
	$App_KeepInFolder = GUICtrlRead($Checkbox_scKeepInFolder) = $GUI_CHECKED
	$App_KeepAll = GUICtrlRead($Checkbox_scKeepAll) = $GUI_CHECKED
	$App_RefreshExplorer = GUICtrlRead($Checkbox_scRefreshExplorer) = $GUI_CHECKED
	$App_NoIcons = GUICtrlRead($Checkbox_NoMenuIcons) = $GUI_CHECKED
	$App_LivePE = GUICtrlRead($Checkbox_LivePE) = $GUI_CHECKED
	$App_NoneThing = GUICtrlRead($Checkbox_MakeNonething) = $GUI_CHECKED
	$App_UpdateAppFile = GUICtrlRead($Checkbox_NeverUpdateAppFile) <> $GUI_CHECKED
	$App_ssUninstall = GUICtrlRead($Checkbox_App_ssUninstall) <> $GUI_CHECKED
	$App_AssemblyNoWait = GUICtrlRead($Checkbox_AssemblyNoWait) = $GUI_CHECKED
	$App_MetroFriendly = GUICtrlRead($Checkbox_MetroFriendly) = $GUI_CHECKED
	$App_InstallPath = StringFilterFilename(GUICtrlRead($Input_AppPath), True, True)
	$App_smSource = StringFilterFilename(GUICtrlRead($Input_DefaultMenu), True, True)
	If GUICtrlRead($Edit_scKeep) <> '' Then
		$App_scKeep = StringSplit(StringReplace(GUICtrlRead($Edit_scKeep), @CRLF, @CR), @CR)
	Else
		ReDim $App_scKeep[1]
		$App_scKeep[0] = 0
		$Edit_scKeep_Data = ''
	EndIf
	If GUICtrlRead($Edit_FileAssoc) <> '' Then
		$App_FileType = StringSplit(StringReplace(GUICtrlRead($Edit_FileAssoc), @CRLF, @CR), @CR)
	Else
		ReDim $App_FileType[1]
		$App_FileType[0] = 0
		$Edit_FileAssoc_Data = ''
	EndIf
	If GUICtrlRead($Edit_InstallFonts) <> '' Then
		$App_InstallFonts = StringSplit(StringReplace(GUICtrlRead($Edit_InstallFonts), @CRLF, @CR), @CR)
	Else
		ReDim $App_InstallFonts[1]
		$App_InstallFonts[0] = 0
		$Edit_InstallFonts_Data = ''
	EndIf
	If GUICtrlRead($Edit_RegisterDLL) <> '' Then
		$App_RegisterDLL = StringSplit(StringReplace(GUICtrlRead($Edit_RegisterDLL), @CRLF, @CR), @CR)
	Else
		ReDim $App_RegisterDLL[1]
		$App_RegisterDLL[0] = 0
		$Edit_RegisterDLL_Data = ''
	EndIf
	If GUICtrlRead($Edit_Cmd) <> '' Then
		$App_CmdFile = GUICtrlRead($Edit_Cmd)
	Else
		ReDim $App_Script[1]
		$App_Script[0] = 0
		$App_CmdFile = ''
		$Edit_Cmd_Data = ''
	EndIf
	If GUICtrlRead($Edit_Reg) <> '' Then
		$App_RegFile = GUICtrlRead($Edit_Reg)
	Else
		ReDim $App_RegEntries[1]
		$App_RegEntries[0] = 0
		$App_RegFile = ''
		$Edit_Reg_Data = ''
	EndIf
	;ssWPI Options
	$App_Runx64 = GUICtrlRead($Checkbox_RunAsx64) = $GUI_CHECKED
	$App_AlwaysHide = GUICtrlRead($Checkbox_AlwaysHide) = $GUI_CHECKED
	$App_AlwaysShow = GUICtrlRead($Checkbox_AlwaysShow) = $GUI_CHECKED
	$App_DuringSetupOnly = GUICtrlRead($Checkbox_AtSetupOnly) = $GUI_CHECKED
	$App_InstallT13 = GUICtrlRead($Checkbox_InstallT13) = $GUI_CHECKED
	$App_InstallInstant = GUICtrlRead($Checkbox_InstallInstant) = $GUI_CHECKED
	$App_PriorityOrder = GUICtrlRead($Input_PriorityOrder)
	;<Meta>
	$App_Publisher = GUICtrlRead($Input_Publisher)
	$App_Language = GUICtrlRead($Input_Language)
	$App_Releaser = GUICtrlRead($Input_Releaser)
	$App_Additional = GUICtrlRead($Input_Additional)
	$App_ReleaseDate = GUICtrlRead($Input_ReleaseDate)
	$App_ReleaseVersion = GUICtrlRead($Input_ReleaseVersion)
	$App_RequiredRuntimes = GUICtrlRead($Input_RequiredRuntimes)
	$App_Rating = GUICtrlRead($Input_Rating)
	;$App_InstalledSize = GUICtrlRead($Input_InstalledSize)
	;<ShortcutS>
	Census_scDefs()
	;<Uninstall>
	Census_uiDefs()
	$FormMode = True
EndFunc

Func scSwap($Eigh, $Bee)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|scSwap(): $Eigh = ' & $Eigh & ' : $Bee = ' & $Bee & @CRLF)
	;Swap Shortcut defs position $Eigh with $Bee
	;Shortcut defs ($App_scXXX) is global
	$App_scCount += 2
	ReDim $App_scEXE[$App_scCount]
	ReDim $App_scWorkDir[$App_scCount]
	ReDim $App_scLNK[$App_scCount]
	ReDim $App_scDesc[$App_scCount]
	ReDim $App_scArgs[$App_scCount]
	ReDim $App_scIcon[$App_scCount]
	ReDim $App_scExt[$App_scCount]
	ReDim $App_scIndex[$App_scCount]
	ReDim $App_scState[$App_scCount]
	ReDim $App_scDefaults[$App_scCount]
	ReDim $App_scFlags[$App_scCount]
	ReDim $App_scCatalog[$App_scCount]
	ReDim $App_scKey[$App_scCount]
	$App_scCount -= 1

	$App_scEXE[$App_scCount] = $App_scEXE[$Eigh]
	$App_scWorkDir[$App_scCount] = $App_scWorkDir[$Eigh]
	$App_scLNK[$App_scCount] = $App_scLNK[$Eigh]
	$App_scDesc[$App_scCount] = $App_scDesc[$Eigh]
	$App_scArgs[$App_scCount] = $App_scArgs[$Eigh]
	$App_scIcon[$App_scCount] = $App_scIcon[$Eigh]
	$App_scExt[$App_scCount] = $App_scExt[$Eigh]
	$App_scIndex[$App_scCount] = $App_scIndex[$Eigh]
	$App_scState[$App_scCount] = $App_scState[$Eigh]
	$App_scDefaults[$App_scCount] = $App_scDefaults[$Eigh]
	$App_scFlags[$App_scCount] = $App_scFlags[$Eigh]
	$App_scCatalog[$App_scCount] = $App_scCatalog[$Eigh]
	$App_scKey[$App_scCount] = $App_scKey[$Eigh]

	$App_scEXE[$Eigh] = $App_scEXE[$Bee]
	$App_scWorkDir[$Eigh] = $App_scWorkDir[$Bee]
	$App_scLNK[$Eigh] = $App_scLNK[$Bee]
	$App_scDesc[$Eigh] = $App_scDesc[$Bee]
	$App_scArgs[$Eigh] = $App_scArgs[$Bee]
	$App_scIcon[$Eigh] = $App_scIcon[$Bee]
	$App_scExt[$Eigh] = $App_scExt[$Bee]
	$App_scIndex[$Eigh] = $App_scIndex[$Bee]
	$App_scState[$Eigh] = $App_scState[$Bee]
	$App_scDefaults[$Eigh] = $App_scDefaults[$Bee]
	$App_scFlags[$Eigh] = $App_scFlags[$Bee]
	$App_scCatalog[$Eigh] = $App_scCatalog[$Bee]
	$App_scKey[$Eigh] = $App_scKey[$Bee]

	$App_scEXE[$Bee] = $App_scEXE[$App_scCount]
	$App_scWorkDir[$Bee] = $App_scWorkDir[$App_scCount]
	$App_scLNK[$Bee] = $App_scLNK[$App_scCount]
	$App_scDesc[$Bee] = $App_scDesc[$App_scCount]
	$App_scArgs[$Bee] = $App_scArgs[$App_scCount]
	$App_scIcon[$Bee] = $App_scIcon[$App_scCount]
	$App_scExt[$Bee] = $App_scExt[$App_scCount]
	$App_scIndex[$Bee] = $App_scIndex[$App_scCount]
	$App_scState[$Bee] = $App_scState[$App_scCount]
	$App_scDefaults[$Bee] = $App_scDefaults[$App_scCount]
	$App_scFlags[$Bee] = $App_scFlags[$App_scCount]
	$App_scCatalog[$Bee] = $App_scCatalog[$App_scCount]
	$App_scKey[$Bee] = $App_scKey[$App_scCount]

	ReDim $App_scEXE[$App_scCount]
	ReDim $App_scWorkDir[$App_scCount]
	ReDim $App_scLNK[$App_scCount]
	ReDim $App_scDesc[$App_scCount]
	ReDim $App_scArgs[$App_scCount]
	ReDim $App_scIcon[$App_scCount]
	ReDim $App_scExt[$App_scCount]
	ReDim $App_scIndex[$App_scCount]
	ReDim $App_scState[$App_scCount]
	ReDim $App_scDefaults[$App_scCount]
	ReDim $App_scFlags[$App_scCount]
	ReDim $App_scCatalog[$App_scCount]
	ReDim $App_scKey[$App_scCount]
	$App_scCount -= 1

	$App_scReset = True
EndFunc

Func SetOutputPath($PathIn)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|SetOutputPath(): $PathIn = ' & $PathIn & @CRLF)
	If $PathIn <> '' Then
		$OutputPath = $PathIn
		FileChangeDir($OutputPath)
		If $ArchiveEditMode = '' Then
			ControlSetText('', '', $StatusBar_ssEditor, 'WorkingDir: "' & $OutputPath & '"')
			If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'WorkingDir: "' & $OutputPath & '"' & @CRLF)
		Else
			ControlSetText('', '', $StatusBar_ssEditor, 'WorkingDir: "' & $ArchiveEditMode & '"')
			If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'WorkingDir: "' & $ArchiveEditMode & '"' & @CRLF)
		EndIf
	EndIf
EndFunc

Func smPreview()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|smPreview()' & @CRLF)
	Local $AppValue, $smCurrent[1] ;, $i
	If $MenuStyle > 0 Then
		Catalog2Menu($smCurrent, $MenuStyle)
		If IsArray($smCurrent) Then
			If $smCurrent[0] > 0 Then
				$AppValue = $smCurrent[1]
				If $App_KeepInFolder Then $AppValue = $AppValue & '\' & $App_smSource
				For $i = 2 To $smCurrent[0]
					$AppValue = $AppValue & ' | ' & $smCurrent[$i]
					If $App_KeepInFolder Then $AppValue = $AppValue & '\' & $App_smSource
				Next
			Else
				$AppValue = $App_smSource
			EndIf
		EndIf
	Else
		$AppValue = $App_smSource
	EndIf
	GUICtrlSetData($Label_CopyDefaultMenu, StringReplace($AppValue, '&', '&&'))
	;ResizeMe($Form_ssEditor, $Label_CopyDefaultMenu, 8, 900, 0, 'MS Sans Serif')
EndFunc
#endregion

#region ;--------------------------Form About ---------------------------------
Func About_CommentClick()
EndFunc
Func About_CopyrightClick()
EndFunc
Func About_CoreVerClick()
	Local $i = FindMe('GNU.General.Public.License_GPLv3.txt')
	Run('notepad "' & $i & '"')
EndFunc
Func About_LogoClick()
EndFunc
Func About_URL2Click()
	ShellExecute($AboutLink2)
EndFunc
Func About_URL3Click()
	ShellExecute($AboutLink3)
EndFunc
Func About_URLClick()
	ShellExecute($AboutLink1)
EndFunc
Func About_VersionClick()
EndFunc
Func Button_Ok_AboutClick()
	FadeOutGUI($Form_About, '.3') ; in seconds
EndFunc
Func Form_AboutClose()
	GUISetState(@SW_HIDE, $Form_About)
EndFunc
Func Form_AboutMaximize()
EndFunc
Func Form_AboutMinimize()
EndFunc
Func Form_AboutRestore()
EndFunc
Func MenuItem_AboutClick()
	FadeInGUI($Form_About, '.3') ; in seconds
EndFunc
Func MenuItem_UpdateCheckClick()
	Local $App_File_Path = GetFolderPath($App_File)
	UpdateMe('update.ini', @ScriptDir & '\..', True, $UseGUI)
	If $App_File_Path <> '' Then
		MenuItem_OpenClick($App_File_Path)
	Else
		MenuItem_NewClick()
	EndIf
EndFunc
#endregion

#region ;--------------------------Form Preview ---------------------------------
Func Exit_GuiPreview()
	$GuiPreviewPic = ''
	GUIDelete($GuiPreview)
EndFunc
#endregion

#region ;--------------------------Form Variables ---------------------------------
Func Button_Close_VarsClick()
	Form_VarsClose()
EndFunc

Func Form_VarsClose()
	HotKeySet('{Esc}')
	FadeOutGUI($Form_Vars, '.3') ; in seconds
	$HelpTopic = $HelpTopic_old
EndFunc

Func Form_VarsMaximize()
EndFunc

Func Form_VarsMinimize()
EndFunc

Func Form_VarsRestore()
EndFunc
Func Label_Component_AddonInstaller_VarsClick()
	ClipPut('%AddonInstaller%') ;_ClipBoard_SetData
EndFunc
Func Label_Component_AddToHosts_VarsClick()
	ClipPut('%AddToHosts%')
EndFunc
Func Label_Component_Extract_VarsClick()
	ClipPut('%Extract%')
EndFunc
Func Label_Component_ProcessKill_VarsClick()
	ClipPut('%ProcessKill%')
EndFunc
Func Label_Component_WaitForIt_VarsClick()
	ClipPut('%WaitForIt%')
EndFunc
Func Label_Directive_ApplyPatch_VarsClick()
	ClipPut('#ApplyPatch#')
EndFunc
Func Label_Directive_AppPathIcon_VarsClick()
	ClipPut('#AppPathFolderIcon#')
EndFunc
Func Label_Directive_Cmd_VarsClick()
	ClipPut('#CMD#')
EndFunc
Func Label_Directive_Fonts_VarsClick()
	ClipPut('#InstallFonts#')
EndFunc
Func Label_Directive_NT5_VarsClick()
	ClipPut('#Is_NT5#')
EndFunc
Func Label_Directive_NT6_VarsClick()
	ClipPut('#Is_NT6#')
EndFunc
Func Label_Directive_RegisterDLL_VarsClick()
	ClipPut('#RegisterDLL#')
EndFunc
Func Label_Directive_Registry_VarsClick()
	ClipPut('#ApplyRegistry#')
EndFunc
Func Label_Directive_Script_VarsClick() ;#RunScript#
	ClipPut('#RunScript#')
EndFunc
Func Label_Directive_ShortcutS_VarsClick()
	ClipPut('#ShortcutS#')
EndFunc
Func Label_Directive_x64_VarsClick()
	ClipPut('#Is_x64#')
EndFunc
Func Label_Directive_x86_VarsClick()
	ClipPut('#Is_x86#')
EndFunc
Func Label_Vars_AllUsers_AllUsersProfileClick()
	ClipPut('%AllUsersProfile%')
EndFunc
Func Label_Vars_AllUsers_AppDataCommonClick()
	ClipPut('%AppDataCommon%')
EndFunc
Func Label_Vars_AllUsers_DesktopCommonClick()
	ClipPut('%DesktopCommon%')
EndFunc
Func Label_Vars_AllUsers_DocumentsCommonClick()
	ClipPut('%DocumentsCommon%')
EndFunc
Func Label_Vars_AllUsers_FavoritesCommonClick()
	ClipPut('%FavoritesCommon%')
EndFunc
Func Label_Vars_AllUsers_ProgramsCommonClick()
	ClipPut('%ProgramsCommon%')
EndFunc
Func Label_Vars_AllUsers_PublicClick()
	ClipPut('%Public%')
EndFunc
Func Label_Vars_AllUsers_SendtoCommonClick()
	ClipPut('%SendtoCommon%')
EndFunc
Func Label_Vars_AllUsers_StartMenuCommonClick()
	ClipPut('%StartMenuCommon%')
EndFunc
Func Label_Vars_AllUsers_StartupCommonClick()
	ClipPut('%StartupCommon%')
EndFunc
Func Label_Vars_CurrentUser_AppDataClick()
	ClipPut('%AppData%')
EndFunc
Func Label_Vars_CurrentUser_DesktopClick()
	ClipPut('%Desktop%')
EndFunc
Func Label_Vars_CurrentUser_FavoritesClick()
	ClipPut('%Favorites%')
EndFunc
Func Label_Vars_CurrentUser_HomeDriveClick()
	ClipPut('%HomeDrive%')
EndFunc
Func Label_Vars_CurrentUser_HomePathClick()
	ClipPut('%HomePath%')
EndFunc
Func Label_Vars_CurrentUser_LocalAppDataClick()
	ClipPut('%LocalAppData%')
EndFunc
Func Label_Vars_CurrentUser_MyDocumentsClick()
	ClipPut('%MyDocuments%')
EndFunc
Func Label_Vars_CurrentUser_ProgramsClick()
	ClipPut('%Programs%')
EndFunc
Func Label_Vars_CurrentUser_QuickLaunchClick()
	ClipPut('%QuickLaunch%')
EndFunc
Func Label_Vars_CurrentUser_SendtoPathClick()
	ClipPut('%SendtoPath%')
EndFunc
Func Label_Vars_CurrentUser_StartMenuClick()
	ClipPut('%StartMenu%')
EndFunc
Func Label_Vars_CurrentUser_StartupClick()
	ClipPut('%Startup%')
EndFunc
Func Label_Vars_CurrentUser_TempClick()
	ClipPut('%Temp%')
EndFunc
Func Label_Vars_CurrentUser_UsernameClick()
	ClipPut('%Username%')
EndFunc
Func Label_Vars_CurrentUser_UserProfileClick()
	ClipPut('%UserProfile%')
EndFunc
Func Label_Vars_SetupS_AppDriveClick()
	ClipPut('%AppDrive%')
EndFunc
Func Label_Vars_SetupS_AppFolderClick()
	ClipPut('%AppFolder%')
EndFunc
Func Label_Vars_SetupS_AppPathClick()
	ClipPut('%AppPath%')
EndFunc
Func Label_Vars_SetupS_CDROMClick()
	ClipPut('%CDROM%')
EndFunc
Func Label_Vars_SetupS_ppAppsClick()
	ClipPut('%ppApps%')
EndFunc
Func Label_Vars_SetupS_ppAppsDriveClick()
	ClipPut('%ppAppsDrive%')
EndFunc
Func Label_Vars_SetupS_ppGamesClick()
	ClipPut('%ppGames%')
EndFunc
Func Label_Vars_SetupS_ppGamesDriveClick()
	ClipPut('%ppGamesDrive%')
EndFunc
Func Label_Vars_SetupS_SourceDriveClick()
	ClipPut('%SourceDrive%')
EndFunc
Func Label_Vars_SetupS_SourceFolderClick()
	ClipPut('%SourceFolder%')
EndFunc
Func Label_Vars_SetupS_SourcePathClick()
	ClipPut('%SourcePath%')
EndFunc
Func Label_Vars_SetupS_ssTekResourcesClick()
	ClipPut('%ssTekResources%')
EndFunc
Func Label_Vars_SetupS_ToolsClick()
	ClipPut('%Tools%')
EndFunc
Func Label_Vars_SetupS_ToolsDriveClick()
	ClipPut('%ToolsDrive%')
EndFunc
Func Label_Vars_SetupS_ToolsFolderClick()
	ClipPut('%ToolsFolder%')
EndFunc
Func Label_Vars_System_CommonProgramFilesClick()
	ClipPut('%CommonProgramFiles%')
EndFunc
Func Label_Vars_System_ComputerNameClick()
	ClipPut('%ComputerName%')
EndFunc
Func Label_Vars_System_ProgramFilesClick()
	ClipPut('%ProgramFiles%')
EndFunc
Func Label_Vars_System_SystemDirClick()
	ClipPut('%SystemDir%')
EndFunc
Func Label_Vars_System_SystemDriveClick()
	ClipPut('%SystemDrive%')
EndFunc
Func Label_Vars_System_SystemRootClick()
	ClipPut('%SystemRoot%')
EndFunc

Func MenuItem_ViewMetaEditorClick()
	$HelpTopic_old = $HelpTopic
	$HelpTopic = 'MetadataEditor'
	HotKeySet('{F1}', 'MenuItem_ContentsClick')
	HotKeySet('{Esc}', 'Form_MetaEditorClose')
	ppArchiveCheck()
	FadeInGUI($Form_MetaEditor, '.3') ; in seconds
EndFunc

Func MenuItem_ViewVarsClick()
	$HelpTopic_old = $HelpTopic
	$HelpTopic = 'AutomaticVariableSubstitutionC'
	HotKeySet('{F1}', 'MenuItem_ContentsClick')
	HotKeySet('{Esc}', 'Form_VarsClose')
	FadeInGUI($Form_Vars, '.3') ; in seconds
EndFunc
#endregion

#region ;############################################# Jeep Functions Below #######################################################

Func _ASSF($File, $extracted = False) ;Auto Silent Switch Finder (ASSF)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|_ASSF(): $File = ' & $File & @CRLF)
	; Find the Installer Silent Switches for this file.
	$SplashOnTop = True
	SplashThis('Searching', 'Searching for Silent Switches. Please wait...')
	Local $ASSF_INI = FindMe('ASSF.ini'), $ASSF_IDs, $ASSF[1][1], $Test
	Local $i, $j, $var, $Found = False, $Usage = '', $IDstring = '', $upx = False
	Local $Filename = StringTrimLeft($File, StringInStr($File, "\", 0, -1))
	Local $FileExtension = StringRight($File, 3)
	Local $hMSI_3 = "D0CF11E0A1B11AE1000000000000000000000000000000003E000300FEFF090006"
	Local $hMSI_4 = "D0CF11E0A1B11AE1000000000000000000000000000000003E000400FEFF0C0006"
	Local $hEXE = "4D5A"
	$ASSF_Type = ''
	$ASSF_Usage = ''
	$ASSF_Notes = ''
	If Not IsArray($ASSF_IDs) Then $ASSF_IDs = IniReadSectionNames($ASSF_INI)
	If IsArray($ASSF_IDs) And $ASSF[0][0] <> $ASSF_IDs[0] Then
		ReDim $ASSF[$ASSF_IDs[0] + 1][5]
		$ASSF[0][0] = $ASSF_IDs[0]
		For $i = 1 To $ASSF_IDs[0]
			$var = IniReadSection($ASSF_INI, $ASSF_IDs[$i])
			If IsArray($var) Then
				$ASSF[$i][0] = $ASSF_IDs[$i]
				For $j = 1 To $var[0][0]
					$ASSF[$i][$j] = $var[$j][1]
				Next
			EndIf
		Next
	EndIf
	Select ;Type of file
		Case $FileExtension = "msi"
			Local $AUX = GetFileHeader($File, 66)
			If $AUX = $hMSI_3 Or $AUX = $hMSI_4 Then
				$IDstring = 'Windows Installer File'
			ElseIf $AUX <> 0 Then
				$IDstring = 'Damaged Windows Installer file'
			EndIf
		Case $FileExtension = "inf"
			$IDstring = 'Information or Setup File'
		Case $FileExtension = "reg"
			If TestRegFile($File) = 1 Then
				$IDstring = 'Registry Data File'
			Else
				$IDstring = 'Damaged Registry Data file'
			EndIf
		Case $FileExtension = "exe"
			Local $AUX = GetFileHeader($File, 4)
			If $AUX = $hEXE Then ; First, analyse with SKF
				ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') Analyse with SKF ... ' & @CRLF)
				SKF_Me($File)
				$IDstring = $SKF_Installer
			ElseIf $AUX <> 0 Then
				$IDstring = 'Damaged executable file'
			EndIf
		Case Else
			$IDstring = 'Unknown'
	EndSelect
	If StringInStr($IDstring, 'SFX') Or StringInStr($IDstring, 'UPX') Or StringInStr($IDstring, 'Unknown') Then
		If $SKF_Product <> '' Then
			ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') $SKF_Product = ' & $SKF_Product & @CRLF)
			$Usage = _SearchASSF($SKF_Product, $ASSF) ;$ASSF_Type, $ASSF_Usage, $ASSF_Notes
		EndIf
	EndIf
	If $ASSF_Usage = '' Or $ASSF_Usage = 'N/A' Or StringInStr($ASSF_Type, 'SFX') Or StringInStr($ASSF_Type, 'UPX') Then
		If $IDstring <> '' Then
			ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') $IDstring = ' & $IDstring & @CRLF)
			$Usage = _SearchASSF($IDstring, $ASSF) ;$ASSF_Type, $ASSF_Usage, $ASSF_Notes
		EndIf
	EndIf
	$upx = ($ASSF_Type = 'UPX Packed executable')
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') $ASSF_Type = ' & $ASSF_Type & @CRLF)
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') $Usage = ' & $Usage & @CRLF & @CRLF)

;~ 	$ASSF_Usage = '' ; uncomment this to "force" TrID scanning:
	If $ASSF_Usage = '' Or $ASSF_Usage = 'N/A' Or StringInStr($ASSF_Type, 'SFX') Or StringInStr($ASSF_Type, 'UPX') Then ; Analyse with TrID
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') Analyse with TrID ... ' & @CRLF)
		$IDstring = TrID_Me($File)
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') $IDstring = ' & $IDstring & @CRLF)
		$Usage = _SearchASSF($IDstring, $ASSF)
		$upx = ($ASSF_Type = 'UPX Packed executable')
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') $Usage = ' & $Usage & @CRLF & @CRLF)
	EndIf

;~ 	$ASSF_Usage = '' ; uncomment this to "force" USSF & PEiD scanning:
	If $ASSF_Usage = '' Or $ASSF_Usage = 'N/A' Or StringInStr($ASSF_Type, 'SFX') Or StringInStr($ASSF_Type, 'UPX') Then ; Analyse with USSF & PEiD
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') Analyse with USSF ... ' & @CRLF)
		If USSF_Me($File) <> 'Undetected PE file' Then
			$IDstring = $USSF_Type
		Else
			ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') Analyse with PEiD ... ' & @CRLF)
			$IDstring = PEiD_Me($File)
		EndIf
		Select ; Special cases
			Case StringInStr($IDstring, "Nothing found")
				Select
					Case StringInStr($File, 'aimp_3') Or StringInStr($File, 'aimp_4')
						$IDstring = 'AIMP Installer'
				EndSelect
			Case StringInStr($IDstring, "Microsoft Visual C++")
				Select
					Case StringInStr($File, 'aimp_3') Or StringInStr($File, 'aimp_4')
						$IDstring = 'AIMP Installer'
					Case Test7z($File) And Not StringInStr($IDstring, "SPx Method")
						$IDstring = '7z SFX-archive NSIS installer'
				EndSelect
		EndSelect
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') $IDstring = ' & $IDstring & @CRLF)
		$Usage = _SearchASSF($IDstring, $ASSF)
		$upx = ($ASSF_Type = 'UPX Packed executable')
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') $Usage = ' & $Usage & @CRLF & @CRLF)
	EndIf

	If $upx Then
		If $extracted Then
			If Test7z($File) Then
				$IDstring = '7z SFX'
				ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') $IDstring = ' & $IDstring & @CRLF)
				$Usage = _SearchASSF($IDstring, $ASSF)
				ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') $Usage = ' & $Usage & @CRLF & @CRLF)
			EndIf
		Else
			ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') Decompress UPX file ... ' & @CRLF)
			Local $FileX = UPX_Me($File)
			If FileExists($FileX) Then Return _ASSF($FileX, True)
		EndIf
	EndIf

;~ 	$ASSF_Usage = '' ; uncomment this to "force" misc scanning:
	If $ASSF_Usage = '' Or $ASSF_Usage = 'N/A' Then
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') Test Misc ... ' & @CRLF)
		SplashThis('Searching for Silent Switches. Please wait...', 'Analyzing ...')
		Select
			Case TestInno($File)
				$IDstring = 'Inno Setup'
			Case Test7z($File)
				$IDstring = '7z SFX'
			Case Else
				Switch TestZipSFX($File)
					Case 1
						$IDstring = 'ZIP SFX'
					Case 2
						$IDstring = 'Zip Archive'
					Case Else
						$IDstring = ''
				EndSwitch
		EndSelect
		If $IDstring = '' Or StringInStr($IDstring, 'Not a valid PE file') Then $IDstring = 'Undetected PE file'
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') $IDstring = ' & $IDstring & @CRLF)
		$Usage = _SearchASSF($IDstring, $ASSF)
		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') $Usage = ' & $Usage & @CRLF & @CRLF)
	EndIf

	SplashOff()
	If $ASSF_Notes = 'n/a' Then $ASSF_Notes = ''
	$Usage = $ASSF_Usage
	Return StringReplace(StringReplace($ASSF_Usage, '%Filename%', $Filename), '%FileExtension%', $FileExtension)
EndFunc

Func _ImageResize($sInImage, $sOutImage, $iW, $iH)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|_ImageResize(): $sInImage = ' & $sInImage & ' : $sOutImage = ' & $sOutImage & ' : $iW = ' & $iW & ' : $iH = ' & $iH & @CRLF)
	Local $hWnd, $hDC, $hBMP, $hImage1, $hImage2, $hGraphic, $CLSID, $i
	Local $sOP = StringLeft($sOutImage, StringInStr($sOutImage, '\', 0, -1)) ;OutFile path, to use later on.
	Local $sOF = StringMid($sOutImage, StringInStr($sOutImage, '\', 0, -1) + 1) ;OutFile name, to use later on.
	Local $ext = StringUpper(StringMid($sOutImage, StringInStr($sOutImage, '.', 0, -1) + 1)) ;OutFile extension , to use for the encoder later on.

	; Win api to create blank bitmap at the width and height to put your resized image on.
	$hWnd = _WinAPI_GetDesktopWindow()
	$hDC = _WinAPI_GetDC($hWnd)
	$hBMP = _WinAPI_CreateCompatibleBitmap($hDC, $iW, $iH)
	_WinAPI_ReleaseDC($hWnd, $hDC)

	;Start GDIPlus
	_GDIPlus_Startup()

	;Get the handle of blank bitmap you created above as an image
	$hImage1 = _GDIPlus_BitmapCreateFromHBITMAP($hBMP)

	;Load the image you want to resize.
	$hImage2 = _GDIPlus_ImageLoadFromFile($sInImage)

	;Get the graphic context of the blank bitmap
	$hGraphic = _GDIPlus_ImageGetGraphicsContext($hImage1)

	;Draw the loaded image onto the blank bitmap at the size you want
	_GDIPlus_GraphicsDrawImageRect($hGraphic, $hImage2, 0, 0, $iW, $iH)

	;Get the encoder of to save the resized image in the format you want.
	$CLSID = _GDIPlus_EncodersGetCLSID($ext)

	;Generate a number for out file that doesn't already exist, so you don't overwrite an existing image.
;~ 	Do
;~ 		$i += 1
;~ 	Until (Not FileExists($sOP & $i & '_' & $sOF))

	;Prefix the number to the begining of the output filename
;~ 	$sOutImage = $sOP & $i & '_' & $sOF

	$sOutImage = $sOP & $sOF

	;Save the new resized image.
	_GDIPlus_ImageSaveToFileEx($hImage1, $sOutImage, $CLSID)

	;Clean up and shutdown GDIPlus.
	_GDIPlus_ImageDispose($hImage1)
	_GDIPlus_ImageDispose($hImage2)
	_GDIPlus_GraphicsDispose($hGraphic)
	_WinAPI_DeleteObject($hBMP)
	_GDIPlus_Shutdown()
EndFunc

Func _SearchASSF($IDstring, ByRef $ASSF)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|_SearchASSF(): $IDstring = ' & $IDstring & @CRLF)
	Local $i
	$ASSF_Type = ''
	$ASSF_Usage = ''
	$ASSF_Notes = ''
	For $i = 1 To $ASSF[0][0]
		If StringInStr($IDstring, $ASSF[$i][$ASSF_Key_ID]) Then
			$ASSF_Type = StringStripWS($ASSF[$i][$ASSF_Key_Type], 3)
			$ASSF_Usage = StringStripWS($ASSF[$i][$ASSF_Key_Usage], 3)
			$ASSF_Notes = StringStripWS($ASSF[$i][$ASSF_Key_Notes], 3)
			If StringInStr($ASSF_Usage, 'N/A') Then
				If StringInStr($ASSF_Notes, 'N/A') Then Return $ASSF_Type
				Return $ASSF_Notes
			EndIf
			Return $ASSF_Usage
		EndIf
	Next
	Return ''
EndFunc

Func AddFileToArchive($what, $Archive)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|AddFileToArchive(): $what = ' & $what & ' : $Archive = ' & $Archive & @CRLF)
	RunWait($CLIprefix & '7z.exe u "' & $Archive & '" "' & GetFilename($what) & '"', GetFolderPath($what), @SW_HIDE)
EndFunc

; Create array on the fly
; Code based on _CreateArray UDF, which has been deprecated
Func CreateArray($i0, $i1 = 0, $i2 = 0, $i3 = 0, $i4 = 0, $i5 = 0, $i6 = 0, $i7 = 0, $i8 = 0, $i9 = 0)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|CreateArray()' & @CRLF)
	Local $arr[10] = [$i0, $i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $i9]
	ReDim $arr[@NumParams]
	Return $arr
EndFunc

Func DeleteFileFromArchive($what, $Archive)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|DeleteFileFromArchive(): $what = ' & $what & ' : $Archive = ' & $Archive & @CRLF)
	RunWait($CLIprefix & '7z.exe d "' & $Archive & '" "' & GetFilename($what) & '"', GetFolderPath($what), @SW_HIDE)
EndFunc

Func FindShortcutFromTarget($where, $what)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|FindShortcutFromTarget(): $where = ' & $where & ' : $what = ' & $what & @CRLF)
	;recursive function to find shortcut with
	;Target $What in folder $Where
	;returns Shortcut name/link
	Local $i, $j, $Found, $var, $FileList, $Path, $Details
	$FileList = _FileListToArray($where, '*.lnk', 1) ; Return files only
	If @error = 0 Then
		For $i = 1 To $FileList[0]
			$Details = FileGetShortcutEx($where & '\' & $FileList[$i])
			If @error = 0 And IsArray($Details) Then
				If GetFilename($Details[0]) = $what Then
					$Found = $where & '\' & $FileList[$i]
					ExitLoop
				EndIf
			EndIf
		Next
	EndIf
	If $Found = '' Then
		$FileList = _FileListToArray($where, '*.*', 2) ; Return folders only
		If @error = 0 And IsArray($FileList) Then
			For $i = 1 To $FileList[0]
				$Found = FindShortcutFromTarget($where & '\' & $FileList[$i], $what)
				If $Found <> '' Then ExitLoop
			Next
		EndIf
	EndIf
	Return $Found
EndFunc

Func GetFileHeader($ProgramToAnalyze, $NumberOfCharsToReturn)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|GetFileHeader(): $ProgramToAnalyze = ' & $ProgramToAnalyze & ' : $NumberOfCharsToReturn = ' & $NumberOfCharsToReturn & @CRLF)
	Local $filehandle = FileOpen($ProgramToAnalyze, 0)
	If $filehandle = -1 Then
		;PARSEERROR(7)
		FileClose($filehandle)
		Return 0
	Else
		Local $Header
		$Header = FileRead($filehandle, $NumberOfCharsToReturn / 2)
		$Header = _StringToHex($Header)
		FileClose($filehandle)
		Return $Header
	EndIf
EndFunc

Func GetInternal7z($File) ;-sfxconfig ..\config.txt
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|GetInternalSS(): $File = ' & $File & @CRLF)
	If FileExists($File) Then
		Local $Drive, $Dir, $FName, $ext, $ss, $PID
		Local $temp = _PathSplit($File, $Drive, $Dir, $FName, $ext) ;0 = original path, 1 = drive, 2 = directory, 3 = filename, 4 = extension
		Split7z($File)
		Local $infile = FileOpen($Drive & $Dir & $FName & '.txt', 0), $eof = (@error = -1), $Line
		While $ss = '' And Not $eof
			$Line = FileReadLine($infile)
			$eof = (@error = -1)
			;$Line = 'RunProgram="\"%ProgramFiles%\\Setup.exe\" -s -y"'
			Select
				Case StringInStr($Line, 'AutoInstall=')
					$ss = '"%Filename%" -ai'
				Case StringInStr($Line, 'RunProgram=')
					$ss = 'RunProgram='
				Case StringInStr($Line, 'ExecuteFile=')
					$ss = 'ExecuteFile='
			EndSelect
		WEnd
		FileClose($infile)
		If Not StringInStr($ss, '-ai') Then
			$ss = StringMid($Line, StringInStr($Line, $ss) + StringLen($ss))
			If StringLeft($ss, 1) = '"' Then $ss = StringMid($ss, 2)
			If StringRight($ss, 1) = '"' Then $ss = StringLeft($ss, StringLen($ss) - 1)
			$ss = StringReplace($ss, '\"', '"')
			$ss = StringReplace($ss, '\\', '\')
			$ss = StringReplace($ss, '\n', Chr(10), 0, 1)
			$ss = StringReplace($ss, '\t', Chr(9), 0, 1)
			Select
				Case StringInStr($ss, '"') ;Enclosed exe
					$ss = StringMid($ss, StringInStr($ss, '"', 0, 1) + 1, StringInStr($ss, '"', 0, 2) - (StringInStr($ss, '"', 0, 1) + 1))
				Case StringInStr($ss, ' ') ;Parametered exe
					$ss = StringLeft($ss, StringInStr($ss, ' ') - 1)
			EndSelect
			RunWait('7z.exe x -y -aoa "' & $File & '"', '', @SW_HIDE)
			$ss = _ASSF($Drive & $Dir & $ss)
			;FileDelete($File)
		EndIf
		;FileDelete($Drive & $dir & $FName & '.7z')
		;FileDelete($Drive & $dir & $FName & '.txt')
		Return $ss
	EndIf
EndFunc

Func GetPic($File)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|GetPic(): $File = ' & $File & @CRLF)
	;this is really only necessary for transparent images.  IE has to use a filter to display them.
	Local $temp
	If FileExists($File) Then
		Local $s_html = ''
		$temp = 'file:///' & StringReplace($File, '\', '/')
		$temp = StringReplace($temp, ' ', '%20')
		$s_html = $s_html & '<?xml version="1.0" encoding="UTF-8"?><html><head></head><body scroll="no">'
		$s_html = $s_html & '<!--[if gte IE 5.5]><![if lt IE 7]><style type="text/css">'
		$s_html = $s_html & '#Image1 img{ filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0); }#Image1 { display: inline-block; }'
		$s_html = $s_html & '#Image1 { filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src="' & $temp & '"); }'
		$s_html = $s_html & '</style><![endif]><![endif]-->'
		$s_html = $s_html & '<img id="Image1" style="position:absolute;top:0;left:0;" src="' & $temp & '" left="0" top="0"/></body></html>'
		Return $s_html
	EndIf
EndFunc

Func MakeScreenShotFile($ImagePath)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MakeScreenShotFile(): $ImagePath = ' & $ImagePath & @CRLF)
	Local $File
	$File = GetAppTypeBase($App_Type)
	If FileExists($OutputPath & '\' & $File & '.jpg') Then FileDelete($OutputPath & '\' & $File & '.jpg')
	;Local $ImagePath = 'scrshot0.jpg'
	_GDIPlus_Startup()
	Local $hImage = _GDIPlus_ImageLoadFromFile($ImagePath)
	Local $ImageWidth = _GDIPlus_ImageGetWidth($hImage)
	Local $ImageHeight = _GDIPlus_ImageGetHeight($hImage)
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_Shutdown()
	Local $NewImageWidth, $NewImageHeight, $x
	Switch $JpgSize
		Case 0
			$x = 1
		Case 640
			Select
				Case $ImageWidth > 640
					$x = 640 / $ImageWidth
				Case $ImageHeight > 480
					$x = 480 / $ImageHeight
				Case Else
					$x = 640 / $ImageWidth
			EndSelect
		Case 800
			Select
				Case $ImageWidth > 800
					$x = 800 / $ImageWidth
				Case $ImageHeight > 600
					$x = 600 / $ImageHeight
				Case Else
					$x = 800 / $ImageWidth
			EndSelect
	EndSwitch
	$NewImageWidth = $ImageWidth * $x
	$NewImageHeight = $ImageHeight * $x
	_ImageResize($ImagePath, $OutputPath & '\' & $File & '.jpg', $NewImageWidth, $NewImageHeight)
	FileDelete($ImagePath)
	Button_RefreshClick()
EndFunc

Func Moveto7z($var, $IncludeSetupSfiles = False, $mxLevel = 5, $msSolid = 'off', $AppTitle = '', $what = '')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Moveto7z(): $var = ' & $var & ' : $IncludeSetupSfiles = ' & $IncludeSetupSfiles & ' : $mxLevel = ' & $mxLevel & ' : $msSolid = ' & $msSolid & ' : $AppTitle = ' & $AppTitle & ' : $what = ' & $what & @CRLF)
	If $ToolsPath <> '' Then
		If $DeleteSource Then
		EndIf
		Local $Line, $i, $n, $count = 0, $sCmd, $DeleteList = '7z.Delete.lst'
		Local $TitleText = '7zip Progress', $m0Method = '' ;' -m0=lzma:d=16m:fb=32:mf=bt4:mc=0' => ' -mx=5'
		If $UseLZMA2 And $mxLevel > 0 Then $m0Method = ' -m0=lzma2'
		If $UseRAR Then
			If $msSolid = 'on' Then
				$msSolid = ' -s'
			Else
				$msSolid = ''
			EndIf
			Switch $mxLevel
				Case 0
					$mxLevel = ' -m0'
				Case 1
					$mxLevel = ' -m1'
				Case 3
					$mxLevel = ' -m2'
				Case 5
					$mxLevel = ' -m3'
				Case 7
					$mxLevel = ' -m4'
				Case 9
					$mxLevel = ' -m5'
			EndSwitch
			$TitleText = 'RAR Progress'
		EndIf
		Local $subtext = '... "' & StringReplace($var, '&', '&&') & '"', $cutoff = 53
		If StringLen($subtext) > $cutoff Then $subtext = StringLeft($subtext, $cutoff - (5 + 11)) & ' ... ' & StringRight($subtext, 11)
		$subtext = $subtext & @CRLF & @CRLF & 'Press <Alt+Ctrl+ESC> to abort'
		FileRecycle($var)
		FileDelete($DeleteList)
		If $AppTitle <> '' Then $AppTitle = ' (' & $AppTitle & ')'
		ProgressOn($TitleText & $AppTitle, 'Creating archive...', $var, -1, @DesktopHeight / 2 - 100, 16)
		ProgressSet(0, '0%' & $subtext, 'Compressing... ')
		$Abort7z = False
		HotKeySet('^!{ESC}', 'Stop7z')
;~ 		$sCmd = '7z a "' & $var & '" -ms=' & $msSolid &' -mx=' & $mxLevel & $m0Method & ' -xr@"' & $ExcludeList & '"'
		If $IncludeSetupSfiles Then
			If $what = '' Then
				If $UseRAR Then
					_7zRead('rar.exe', ' a "' & $var & '"' & $msSolid & $mxLevel & ' -r -x@"' & $ExcludeList & '"' & ' -x@"' & $ncList & '"', $7zProcessPriority, '', $subtext)
					_7zRead('rar.exe', ' a "' & $var & '"' & $msSolid & ' -m0' & ' -r -n@"' & $ncList & '"', $7zProcessPriority, '', $subtext)
				Else
					_7zRead('7z.exe', ' a "' & $var & '" -ms=' & $msSolid & ' -mx=' & $mxLevel & $m0Method & ' -xr@"' & $ExcludeList & '"' & ' -xr@"' & $ncList & '"' & ' -xr@"' & $PPMdList & '"', $7zProcessPriority, '', $subtext)
					_7zRead('7z.exe', ' a "' & $var & '" -ms=' & $msSolid & ' -m0=PPMd' & ' -ir@"' & $PPMdList & '"', $7zProcessPriority, '', $subtext)
					_7zRead('7z.exe', ' a "' & $var & '" -ms=' & $msSolid & ' -mx=0' & ' -ir@"' & $ncList & '"', $7zProcessPriority, '', $subtext)
				EndIf
			Else
				If $UseRAR Then
					_7zRead('rar.exe', ' a "' & $var & '"' & $msSolid & $mxLevel & ' -r -x@"' & $ExcludeList & '"' & ' -x@"' & $SetupSList & '"', $7zProcessPriority, '', $subtext)
				Else
					_7zRead('7z.exe', ' a "' & $var & '" -ms=' & $msSolid & ' -mx=' & $mxLevel & $m0Method & ' -xr@"' & $ExcludeList & '"' & ' -x@"' & $SetupSList & '"', $7zProcessPriority, '', $subtext)
				EndIf
			EndIf
		Else
			If $UseRAR Then
				_7zRead('rar.exe', ' a "' & $var & '"' & $msSolid & $mxLevel & ' -r -x@"' & $ExcludeList & '"' & ' -x@"' & $SetupSList & '"', $7zProcessPriority, '', $subtext)
			Else
				_7zRead('7z.exe', ' a "' & $var & '" -ms=' & $msSolid & ' -mx=' & $mxLevel & $m0Method & ' -xr@"' & $ExcludeList & '"' & ' -x@"' & $SetupSList & '"', $7zProcessPriority, '', $subtext)
			EndIf
		EndIf
		HotKeySet('^!{ESC}')
		$subtext = '... "' & StringReplace($var, '&', '&&') & '"'
		If StringLen($subtext) > $cutoff Then $subtext = StringLeft($subtext, $cutoff - (5 + 11)) & ' ... ' & StringRight($subtext, 11)
		$subtext = $subtext & @CRLF & @CRLF & 'Deleting files. Please wait...'
		ProgressSet(100, '100%' & $subtext)
		RunWait($CLIprefix & '7z.exe l "' & $var & '" >' & $DeleteList, '.', @SW_HIDE)
		Local $File = FileOpen($DeleteList, 0)
		If $File = -1 Then
			$var = ''
		Else
			Local $EndOfFile = False
			Do ; Read in lines of text until the EOF is reached
				$Line = FileReadLine($File)
				$EndOfFile = (@error = -1)
				If $Line = '------------------- ----- ------------ ------------  ------------------------' Then
					Do
						$Line = FileReadLine($File)
						$n = StringStripWS(StringMid($Line, 54), 3)
						If FileExists($n) Then
							$i = NoBackslash(StringLeft($n, StringInStr($n, '\')))
							If $i <> '' And StringInStr(FileGetAttrib($i), 'D') > 0 Then
								$count += 1
								If FileExists($i) Then
									If $DeleteSource Then
										FileRecycle($i)
									ElseIf $what = '' Then
										DirMove(@WorkingDir & '\' & $i, $TempSourceDir & '\' & $i)
									Else
										If Not FileExists($TempSourceDir & '\' & $what) Then DirCreate($TempSourceDir & '\' & $what)
										DirMove(@WorkingDir & '\' & $i, $TempSourceDir & '\' & $what & '\' & $i)
									EndIf
								EndIf
							Else
								$count += 1
								If $DeleteSource Then
									FileRecycle($n)
								ElseIf $what = '' Then
									FileMove(@WorkingDir & '\' & $n, $TempSourceDir & '\' & $n, 9)
								Else
									FileMove(@WorkingDir & '\' & $n, $TempSourceDir & '\' & $what & '\' & $n, 9)
								EndIf
							EndIf
						EndIf
					Until $Line = '------------------- ----- ------------ ------------  ------------------------'
				EndIf
			Until $EndOfFile
			FileClose($File)
			FileDelete($DeleteList)
			If $count = 0 Then
				FileDelete($var)
				$var = ''
			EndIf
			ProgressOff()
			Return $var
		EndIf
	EndIf
EndFunc

Func PEiD_Me($File)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|PEiD_Me(): $File = ' & $File & @CRLF)
	SplashThis('Searching for Silent Switches. Please wait...', 'Analyzing with PEiD ...')
	If FileExists(@ScriptDir & '\bin\PEiD\PEiD.exe') Then
		Local $PID, $Test = 0, $peidtitle = 'PEiD'
		; Backup existing PEiD options
		Local $exsig = RegRead('HKCU\Software\PEiD', 'ExSig')
		Local $loadplugins = RegRead('HKCU\Software\PEiD', 'LoadPlugins')
		Local $stayontop = RegRead('HKCU\Software\PEiD', 'StayOnTop')

		; Set PEiD options
		RegWrite('HKCU\Software\PEiD', 'ExSig', 'REG_DWORD', 1)
		RegWrite('HKCU\Software\PEiD', 'LoadPlugins', 'REG_DWORD', 0)
		RegWrite('HKCU\Software\PEiD', 'StayOnTop', 'REG_DWORD', 0)

		; Analyze file
		Local $IDstring = '', $scantypes = CreateArray('norm', 'deep', 'hard')
		For $i = 0 To UBound($scantypes) - 1
			; Run PEiD scan(s)
			While ProcessExists('PEiD.exe')
				ProcessClose('PEiD.exe')
				Sleep(100)
			WEnd
			$PID = Run(@ScriptDir & '\bin\PEiD\PEiD.exe -' & $scantypes[$i] & ' "' & $File & '"', '', @SW_HIDE) ;@SW_SHOW;@SW_HIDE
			If $PID <> 0 Then
				WinWait($peidtitle)
				$IDstring = ControlGetText($peidtitle, '', 'Edit2')
				While ($IDstring = '') Or StringInStr($IDstring, 'Scanning')
					$Test += 1
					SplashThis('Searching for Silent Switches. Please wait...', 'Analyzing with PEiD ... (' & $Test & ')')
					$IDstring = ControlGetText($peidtitle, '', 'Edit2')
					Sleep(100)
				WEnd
				WinClose($peidtitle)
				While ProcessExists($PID)
					ProcessClose($PID)
					Sleep(100)
				WEnd
				If Not StringInStr($IDstring, 'Nothing found') Then ExitLoop
			EndIf
		Next

		; Restore previous PEiD options
		If $exsig Then RegWrite('HKCU\Software\PEiD', 'ExSig', 'REG_DWORD', $exsig)
		If $loadplugins Then RegWrite('HKCU\Software\PEiD', 'LoadPlugins', 'REG_DWORD', $loadplugins)
		If $stayontop Then RegWrite('HKCU\Software\PEiD', 'StayOnTop', 'REG_DWORD', $stayontop)
		Return $IDstring
	EndIf
	Return ''
EndFunc

Func PreviewPic($pic, $ShowCaption = True)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|PreviewPic(): $pic = ' & $pic & ' : $ShowCaption = ' & $ShowCaption & @CRLF)
;~ 	$ShowCaption = False
	Local $iSize, $imgWidth, $imgHeight, $Pic1, $Icon1
	If (StringRight($pic, 4) <> '.ico') Then ;.png/jpg
		$iSize = StringSplit(StringStripWS(_GetFileProperty($pic, 'Dimensions'), 8), 'x') ;1=w, 2=h
		$imgWidth = $iSize[1]
		Switch @OSVersion
			Case 'WIN_2003', 'WIN_XP', 'WIN_XPe', 'WIN_2000'
			Case 'WIN_2008R2', 'WIN_7', 'WIN_2008', 'WIN_VISTA'
				$imgWidth = Number(StringMid($imgWidth, 2))
		EndSwitch
		$imgHeight = $iSize[2]
		If $GuiPreviewPic <> '' Then
			$GuiPreviewPic = ''
			GUIDelete($GuiPreview)
		EndIf
		If $ShowCaption Then
			$GuiPreview = GUICreate('Picture Viewer', $imgWidth, $imgHeight, -1, -1, -1, BitOR($WS_EX_APPWINDOW, $WS_EX_TOOLWINDOW), $Form_ssEditor) ;w,h,l,t;BitOR($WS_SYSMENU, $WS_POPUP)
		Else
			$GuiPreview = GUICreate('Picture Viewer', $imgWidth, $imgHeight, -1, -1, BitOR($WS_SIZEBOX, $WS_THICKFRAME, $WS_SYSMENU, $WS_POPUP), -1, $Form_ssEditor)
		EndIf
		$Pic1 = GUICtrlCreatePic('', 0, 0, $imgWidth, $imgHeight) ;l,t,w,h
		GUISetOnEvent($GUI_EVENT_CLOSE, 'Exit_GuiPreview', $GuiPreview)
		_SetImage($Pic1, $pic)
	Else ;.ico
		Switch @OSVersion
			Case 'WIN_2003', 'WIN_XP', 'WIN_XPe', 'WIN_2000'
				$imgWidth = 48
				If $PreviewIconSize > 0 And $PreviewIconSize < 128 Then $imgWidth = $PreviewIconSize
			Case 'WIN_2008R2', 'WIN_7', 'WIN_2008', 'WIN_VISTA'
				$imgWidth = 256
				If $PreviewIconSize > 0 Then $imgWidth = $PreviewIconSize
		EndSwitch
		$imgHeight = $imgWidth
		If $GuiPreviewPic <> '' Then
			$GuiPreviewPic = ''
			GUIDelete($GuiPreview)
		EndIf
		$GuiPreview = GUICreate('Picture Viewer', $imgWidth, $imgHeight, -1, -1, -1, BitOR($WS_EX_APPWINDOW, $WS_EX_TOOLWINDOW), $Form_ssEditor) ;w,h,l,t
		$Icon1 = GUICtrlCreateIcon('', -1, 0, 0, $imgWidth, $imgHeight) ;l,t,w,h
		GUISetOnEvent($GUI_EVENT_CLOSE, 'Exit_GuiPreview', $GuiPreview)
		_SetIcon($Icon1, $pic, 0, $imgWidth, $imgHeight)
	EndIf
	$GuiPreviewPic = $pic
	FadeInGUI($GuiPreview, '.3')
EndFunc

Func SaveClipboardJpg($temp = 'scrshot0.jpg') ;$OutputPath & '\scrshot0.jpg'
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|SaveClipboardJpg(): $temp = ' & $temp & @CRLF)
	Local $hBMP, $hImage
	If $temp = '' Then Return

	If Not _ClipBoard_Open(0) Then _WinAPI_ShowError('_ClipBoard_Open failed')
	$hBMP = _ClipBoard_GetDataEx($CF_BITMAP)
	_GDIPlus_Startup()
	$hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBMP)

	; Save bitmap to file
	If Not FileExists($OutputPath) Then DirCreate($OutputPath)
	If FileExists($OutputPath & '\' & $temp) Then FileDelete($OutputPath & '\' & $temp)
	_GDIPlus_ImageSaveToFile($hImage, $OutputPath & '\' & $temp) ;$sNewName)
	_GDIPlus_BitmapDispose($hImage)
	_GDIPlus_Shutdown()
	_ClipBoard_Close()
	If FileExists($OutputPath & '\' & $temp) Then
		MakeScreenShotFile($OutputPath & '\' & $temp)
		MsgBox(262144, $ThisAppTitle, 'Picture saved! Saved to:' & @LF & @LF & $OutputPath & @LF & @LF & '(This box will close in ' & 3 & ' seconds)', 3)
		If $OutputPathCurrent <> '' Then
			SetOutputPath($OutputPathCurrent)
			$OutputPathCurrent = ''
		EndIf
	EndIf
EndFunc

Func ScanForFiles($where, ByRef $BatchList)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ScanForFiles(): $where = ' & $where & @CRLF)
	; recursively scan for files from $where and
	; create a batch list of folders/files
	Local $i, $FileList
	If FileExists($where) Then
		$FileList = _FileListToArray($where, '*.*', 2) ; Return folders only
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				ScanForFiles($where & '\' & $FileList[$i], $BatchList)
			Next
		EndIf
		$FileList = _FileListToArray($where, '*.*', 1) ; files only
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				$BatchList[0] += 1
				ReDim $BatchList[$BatchList[0] + 1]
				$BatchList[$BatchList[0]] = $where & '\' & $FileList[$i]
			Next
		EndIf
	EndIf
EndFunc

Func SKF_Me($File)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|SKF_Me(): $File = ' & $File & @CRLF)
	SplashThis('Searching for Silent Switches. Please wait...', 'Analyzing with SKF ...')
	Local $PID, $error, $Test = 0, $SKFtitle = 'Silent key finder' ; 1.0.0.12' ;http://checkdevice.narod.ru
	$SKF_Installer = ''
	$SKF_Key = ''
	$SKF_Product = ''
	$SKF_Company = ''
	$SKF_Copyright = ''
	$SKF_Description = ''
	$SKF_Comments = ''
	$SKF_PVersion = ''
	$SKF_FVersion = ''
	$SKF_File = ''
	$SKF_Size = ''
	If FileExists(@ScriptDir & '\bin\skf.exe') Then
		While ProcessExists('skf.exe')
			ProcessClose('skf.exe')
			Sleep(100)
		WEnd
		$PID = Run(@ScriptDir & '\bin\skf.exe "' & $File & '"', '', @SW_HIDE) ;@SW_HIDE;@SW_SHOW
		$error = @error
		If $PID = 0 And $error <> 0 Then ;SciTE is not set to RUNASADMIN (affects Win8/10)
			ShellExecute(@ScriptDir & '\bin\skf.exe', '"' & $File & '"', '', 'Open', @SW_HIDE)
			$PID = ProcessExists('skf.exe')
		EndIf
		If $PID <> 0 Then
			WinWait($SKFtitle)
			$SKF_Installer = StringStripWS(ControlGetText($SKFtitle, '', 'TButtonedEdit10'), 3)
			While ($SKF_Installer = '') Or StringInStr($SKF_Installer, 'Reading file')
				$Test += 1
				SplashThis('Searching for Silent Switches. Please wait...', 'Analyzing with SKF ... (' & $Test & ')')
				$SKF_Installer = StringStripWS(ControlGetText($SKFtitle, '', 'TButtonedEdit10'), 3)
				Sleep(100)
			WEnd
			$SKF_Key = StringStripWS(ControlGetText($SKFtitle, '', 'TButtonedEdit9'), 3)
			$SKF_Product = StringStripWS(ControlGetText($SKFtitle, '', 'TButtonedEdit6'), 3)
			$SKF_Company = StringStripWS(ControlGetText($SKFtitle, '', 'TButtonedEdit2'), 3)
			$SKF_Copyright = StringStripWS(ControlGetText($SKFtitle, '', 'TButtonedEdit5'), 3)
			$SKF_Description = StringStripWS(ControlGetText($SKFtitle, '', 'TButtonedEdit4'), 3)
			$SKF_Comments = StringStripWS(ControlGetText($SKFtitle, '', 'TButtonedEdit3'), 3)
			$SKF_PVersion = StringReplace(StringStripWS(ControlGetText($SKFtitle, '', 'TButtonedEdit7'), 8), ',', '.')
			$SKF_FVersion = StringReplace(StringStripWS(ControlGetText($SKFtitle, '', 'TButtonedEdit8'), 8), ',', '.')
			$SKF_File = StringStripWS(ControlGetText($SKFtitle, '', 'TButtonedEdit11'), 3)
			$SKF_Size = StringStripWS(ControlGetText($SKFtitle, '', 'TButtonedEdit1'), 3)
			WinClose($SKFtitle)
			While ProcessExists($PID)
				ProcessClose($PID)
				Sleep(100)
			WEnd
			If $SKF_PVersion = '' Then $SKF_PVersion = $SKF_FVersion
			#cs Fill in some gaps:
				If $App_Publisher = '' And $SKF_Company <> '' Then $App_Publisher = $SKF_Company
				If $App_ReleaseDate = '' Then
				If $SKF_PVersion <> '' Then
				$App_ReleaseDate = $SKF_PVersion
				ElseIf $SKF_FVersion <> '' Then
				$App_ReleaseDate = $SKF_FVersion
				EndIf
				EndIf
				If $App_Version = '' Then
				If $App_Type = 5 Then
				If $SKF_Copyright <> '' Then $App_Version = $SKF_Copyright
				Else
				If $VersionTag <> '' Then $App_Version = 'v' & $VersionTag
				EndIf
				EndIf
				If $App_Title = '' And $SKF_Product <> '' Then $App_Title = StringStripWS(StringReplace(StringReplace($SKF_Product, 'install', ''), 'setup', ''), 3)
				If $App_Additional = '' And $SKF_Comments <> '' Then $App_Additional = $SKF_Comments
				If $App_ReleaseDate = '' And $SKF_Copyright <> '' Then $App_ReleaseDate = $SKF_Copyright
			#ce
		EndIf
	EndIf
EndFunc

Func Split7z($File, $SFXModule = False, $Config = True, $Archive = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Split7z(): $File = ' & $File & @CRLF)
	Local $PID, $Split7zTitle = '7z SFX Archives splitter'
	If FileExists(@ScriptDir & '\bin\7ZSplit.exe') And FileExists($File) Then
		$PID = Run(@ScriptDir & '\bin\7ZSplit.exe "' & $File & '"', '', @SW_SHOW) ;@SW_HIDE;@SW_SHOW
		If $PID <> 0 Then
			Do
				Sleep(10)
			Until ControlCommand($Split7zTitle, 'OK', 'Button1', 'IsEnabled', '')
			If $SFXModule Then ControlCommand($Split7zTitle, 'OK', 'Button6', 'Check', '') ;sfx module
			If Not $Config Then ControlCommand($Split7zTitle, 'OK', 'Button7', 'UnCheck', '') ;config
			If Not $Archive Then ControlCommand($Split7zTitle, 'OK', 'Button8', 'UnCheck', '') ;archive
			ControlClick($Split7zTitle, 'OK', 'Button1')
			Do
				Sleep(10)
			Until ControlCommand($Split7zTitle, 'OK', 'Button1', 'IsEnabled', '')
			ControlClick($Split7zTitle, 'OK', 'Button1')
			While ProcessExists($PID)
				Sleep(10)
			WEnd
		EndIf
	EndIf
EndFunc

Func TakeScreenShot()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|TakeScreenShot()' & @CRLF)
	If $App_Type > 0 Then
		HotKeySet('{PRINTSCREEN}')
		If ProcessExists('pic2file.exe') Then ProcessClose('pic2file.exe')
		If FileExists($OutputPath & '\scrshot*.jpg') Then FileDelete($OutputPath & '\scrshot*.jpg')
		Send('!{PRINTSCREEN}')
		If Not FileExists($OutputPath) Then DirCreate($OutputPath)
;~ 		If Not FileExists($TempPixDir & '\pic2file.exe') Then
;~ 			Local $CurrentWorkingDir = @WorkingDir
;~ 			FileChangeDir(@ScriptDir)
;~ 			FileInstall('.\bin\pic2file.exe', $TempPixDir & '\pic2file.exe', 1)
;~ 			FileChangeDir($CurrentWorkingDir)
;~ 		EndIf
		Local $n, $PID = Run(@ScriptDir & '\bin\pic2file.exe -prefix scrshot', $OutputPath, @SW_HIDE)
		If $PID Then
			Do
				Sleep(100)
			Until FileExists($OutputPath & '\scrshot0.jpg')
			Do
				Sleep(100)
				$n = FileGetSize($OutputPath & '\scrshot0.jpg')
				Sleep(100)
			Until $n = FileGetSize($OutputPath & '\scrshot0.jpg')
			ProcessClose($PID)
			MakeScreenShotFile($OutputPath & '\scrshot0.jpg')
			MsgBox(262144, $ThisAppTitle, 'Screenshot taken! Saved to:' & @LF & @LF & $OutputPath & @LF & @LF & '(This box will close in ' & 3 & ' seconds)', 3)
			If $OutputPathCurrent <> '' Then
				SetOutputPath($OutputPathCurrent)
				$OutputPathCurrent = ''
			EndIf
		EndIf
	EndIf
EndFunc

Func Test7z($ProgramToAnalyze)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Test7z(): $ProgramToAnalyze = ' & $ProgramToAnalyze & @CRLF)
	Local $PID = Run($CLIprefix & '7z.exe l "' & $ProgramToAnalyze & '"', '', @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	Local $OUTPUT, $OUTPUTAUX
	While 1
		$OUTPUTAUX = StdoutRead($PID)
		If @error Then
			ExitLoop
		EndIf
		$OUTPUT = $OUTPUT & $OUTPUTAUX
	WEnd
	While 1
		$OUTPUTAUX = StderrRead($PID)
		If @error Then
			ExitLoop
		EndIf
		$OUTPUT = $OUTPUT & $OUTPUTAUX
	WEnd
	ProcessClose($PID)
	If StringInStr($OUTPUT, "Listing archive:", 0) Then Return True
	Return False
EndFunc

Func TestInno($ProgramToAnalyze)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|TestInno(): $ProgramToAnalyze = ' & $ProgramToAnalyze & @CRLF)
;~ 	If Not FileExists($TempPixDir & '\innounp.exe') Then
;~ 		Local $CurrentWorkingDir = @WorkingDir
;~ 		FileChangeDir(@ScriptDir)
;~ 		FileInstall('.\bin\innounp.exe', $TempPixDir & '\innounp.exe', 1)
;~ 		FileChangeDir($CurrentWorkingDir)
;~ 	EndIf
	Local $PID = Run($CLIprefix & @ScriptDir & '\bin\innounp.exe "' & $ProgramToAnalyze & '"', '', @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	Local $OUTPUT, $OUTPUTAUX
	While 1
		$OUTPUTAUX = StdoutRead($PID)
		If @error Then
			ExitLoop
		EndIf
		$OUTPUT = $OUTPUT & $OUTPUTAUX
	WEnd
	While 1
		$OUTPUTAUX = StderrRead($PID)
		If @error Then
			ExitLoop
		EndIf
		$OUTPUT = $OUTPUT & $OUTPUTAUX
	WEnd
	ProcessClose($PID)
	Return StringInStr($OUTPUT, "Version detected:")
EndFunc

Func TestRegFile($ProgramToAnalyze)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|TestRegFile(): $ProgramToAnalyze = ' & $ProgramToAnalyze & @CRLF)
	Local $FinalHeader
	Local $Header = GetFileHeader($ProgramToAnalyze, 156)
	If $Header <> 0 Then
		If StringLeft($Header, 4) == "FFFE" Then
			$Header = StringTrimLeft($Header, 4)
			For $i = 1 To StringLen($Header) Step 4
				$FinalHeader = $FinalHeader & StringMid($Header, $i, 2)
			Next
			$Header = $FinalHeader
		EndIf
		If StringLeft($Header, 76) <> "57696E646F777320526567697374727920456469746F722056657273696F6E20352E30300D0A" And StringLeft($Header, 20) <> "52454745444954340D0A" Then
			;PARSEERROR(3)
			Return 2
		EndIf
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func TestZipSFX($ProgramToAnalyze)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|TestZipSFX(): $ProgramToAnalyze = ' & $ProgramToAnalyze & @CRLF)
;~ 	If Not FileExists($TempPixDir & '\unzip.exe') Then
;~ 		Local $CurrentWorkingDir = @WorkingDir
;~ 		FileChangeDir(@ScriptDir)
;~ 		FileInstall('.\bin\unzip.exe', $TempPixDir & '\unzip.exe', 1)
;~ 		FileChangeDir($CurrentWorkingDir)
;~ 	EndIf
	Local $PID = Run($CLIprefix & @ScriptDir & '\bin\unzip.exe -l "' & $ProgramToAnalyze & '"', '', @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	Local $OUTPUT, $OUTPUTAUX
	While 1
		$OUTPUTAUX = StdoutRead($PID)
		If @error Then
			ExitLoop
		EndIf
		$OUTPUT = $OUTPUT & $OUTPUTAUX
	WEnd
	While 1
		$OUTPUTAUX = StderrRead($PID)
		If @error Then
			ExitLoop
		EndIf
		$OUTPUT = $OUTPUT & $OUTPUTAUX
	WEnd
	ProcessClose($PID)
	If Not StringInStr($OUTPUT, "signature not found", 0) Then
		Return 1
	EndIf
	If StringInStr($OUTPUT, "Length", 0) Then
		Return 2
	EndIf
	Return 0
EndFunc

Func TrID_Me($File, $analyze = True)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|TrID_Me(): $File = ' & $File & @CRLF)
	SplashThis('Searching for Silent Switches. Please wait...', 'Analyzing with TrID ...')
	Local $PID, $Test = 0, $debugfile = $TempPixDir & '\' & 'TrIDout.txt' ;$TempPixDir & '\' &
	If FileExists(@ScriptDir & '\bin\TrID\trid.exe') Then
		While ProcessExists('TrID.exe')
			ProcessClose('TrID.exe')
			Sleep(100)
		WEnd
		$PID = Run(@ComSpec & ' /d /c ' & @ScriptDir & '\bin\TrID\TrID.exe "' & $File & '" >' & $debugfile & '', @ScriptDir & '\bin\TrID', @SW_HIDE) ;@SW_HIDE;@SW_SHOW
		While ProcessExists($PID)
			$Test += 1
			SplashThis('Searching for Silent Switches. Please wait...', 'Analyzing with TrID ... (' & $Test & ')')
			Sleep(100)
		WEnd
	EndIf

	; Parse through results and append to string
	Local $filetype = ''
	Local $infile = FileOpen($debugfile, 0)
	Local $Line = FileReadLine($infile)
	Do
		If StringInStr($Line, '%') Then
			$filetype &= $Line
			;ExitLoop ;comment out to get all hits
		EndIf
		$Line = FileReadLine($infile)
	Until @error
	FileClose($infile)
	FileDelete($debugfile)

	; Return filetype without matching if specified
	If $analyze Then
		; Match known patterns
		Select
			Case StringInStr($filetype, "7-Zip compressed archive", 0)

			Case StringInStr($filetype, "ACE compressed archive", 0) _
					Or StringInStr($filetype, "ACE Self-Extracting Archive", 0)

			Case StringInStr($filetype, "ARC Compressed archive", 0) _
					And Not StringInStr($filetype, "UHARC", 0)

			Case StringInStr($filetype, "ARJ compressed archive", 0)

			Case StringInStr($filetype, "bzip2 compressed archive", 0)

			Case StringInStr($filetype, "Microsoft Cabinet Archive", 0) _
					Or StringInStr($filetype, "IncrediMail letter/ecard", 0)

			Case StringInStr($filetype, "Compiled HTML Help File", 0)

			Case StringInStr($filetype, "CPIO Archive", 0)

			Case StringInStr($filetype, "Debian Linux Package", 0)

			Case StringInStr($filetype, "Gentee Installer executable", 0)

			Case StringInStr($filetype, "GZipped File", 0)

			Case StringInStr($filetype, "Windows Help File", 0)

			Case StringInStr($filetype, "Generic PC disk image", 0)

			Case StringInStr($filetype, "Inno Setup installer", 0)

			Case StringInStr($filetype, "Installer VISE executable", 0)

			Case StringInStr($filetype, "InstallShield archive", 0)

			Case StringInStr($filetype, "InstallShield compressed archive", 0)

			Case StringInStr($filetype, "KGB archive", 0)

			Case StringInStr($filetype, "LHARC/LZARK compressed archive", 0)

			Case StringInStr($filetype, "lzop compressed", 0)

			Case StringInStr($filetype, "LZX Amiga compressed archive", 0)

			Case StringInStr($filetype, "Microsoft Internet Explorer Web Archive", 0)

			Case StringInStr($filetype, "Microsoft Reader eBook", 0)

			Case StringInStr($filetype, "Microsoft Windows Installer merge module", 0)

			Case StringInStr($filetype, "Microsoft Windows Installer package", 0)

			Case StringInStr($filetype, "Microsoft Windows Installer patch", 0)

			Case StringInStr($filetype, "HTC NBH ROM Image", 0)

			Case StringInStr($filetype, "Outlook Express E-mail folder", 0)

			Case StringInStr($filetype, "PEA archive", 0)

			Case StringInStr($filetype, "RAR Archive", 0)

			Case StringInStr($filetype, "RAR Self Extracting archive", 0)

			Case StringInStr($filetype, "Reflexive Arcade installer wrapper", 0)

			Case StringInStr($filetype, "RPM Linux Package", 0)

			Case StringInStr($filetype, "Setup Factory 6.x Installer", 0)

			Case StringInStr($filetype, "StuffIT SIT compressed archive", 0)

			Case StringInStr($filetype, "SymbianOS Installer", 0)

			Case StringInStr($filetype, "TAR archive", 0)

			Case StringInStr($filetype, "UHARC compressed archive", 0)

			Case StringInStr($filetype, "Base64 Encoded file", 0)

			Case StringInStr($filetype, "Quoted-Printable Encoded file", 0)

			Case StringInStr($filetype, "UUencoded file", 0) _
					Or StringInStr($filetype, "XXencoded file", 0)

			Case StringInStr($filetype, "yEnc Encoded file", 0)

			Case StringInStr($filetype, "Windows Imaging Format", 0)

			Case StringInStr($filetype, "Wise Installer Executable", 0)

			Case StringInStr($filetype, "UNIX Compressed file", 0)

			Case StringInStr($filetype, "ZIP compressed archive", 0) _
					Or StringInStr($filetype, "Winzip Win32 self-extracting archive", 0)

			Case StringInStr($filetype, "Zip Self-Extracting archive", 0)

			Case StringInStr($filetype, "ZOO compressed archive", 0)

				; Forced to bottom of list due to false positives
			Case StringInStr($filetype, "LZMA compressed file", 0)

			Case StringInStr($filetype, "InstallShield setup", 0)

		EndSelect
	EndIf
	Return $filetype
EndFunc

Func UpdateArchive($File, $Archive)
	If FileExists($File) Then
		_MD5Write2File(_MD5Calc($File), StringReplace($File, @WorkingDir & '\', ''), GetAppTypeBase($App_Type) & '.md5')
		AddFileToArchive($File, $Archive)
	Else
		_MD5Remove($File, GetAppTypeBase($App_Type) & '.md5')
		DeleteFileFromArchive($File, $Archive)
	EndIf
EndFunc

Func UPX_Me($File)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|UPX_Me(): $File = ' & $File & @CRLF)
	SplashThis('Searching for Silent Switches. Please wait...', 'Decompressing UPX file ...')
	Local $PID, $Test = 0, $upxd = $TempPixDir & '\' & StringTrimLeft($File, StringInStr($File, "\", 0, -1))
	If FileExists(@ScriptDir & '\bin\upx.exe') Then
		$PID = Run(@ComSpec & ' /d /c ' & @ScriptDir & '\bin\upx.exe -d -o "' & $upxd & '" "' & $File & '"', '', @SW_HIDE) ;@SW_HIDE;@SW_SHOW
	EndIf
	While ProcessExists($PID)
		$Test += 1
		SplashThis('Searching for Silent Switches. Please wait...', 'Analyzing with TrID ... (' & $Test & ')')
		Sleep(100)
	WEnd
	Return $upxd
EndFunc

Func USSF_Me($File)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|USSF_Me(): $File = ' & $File & @CRLF)
	SplashThis('Searching for Silent Switches. Please wait...', 'Analyzing with USSF ...')
	Local $PID, $USSF_Title = 'USSF', $USSF_Installer = '', $USSF_Ext = '', $Test = 0
	If FileExists(@ScriptDir & '\bin\ussf.exe') Then
		While ProcessExists('ussf.exe')
			ProcessClose('ussf.exe')
			Sleep(100)
		WEnd
		$PID = Run(@ScriptDir & '\bin\ussf.exe "' & $File & '"', '', @SW_HIDE) ;@SW_HIDE;@SW_SHOW
		If $PID <> 0 Then
			WinWait($USSF_Title)
			WinSetOnTop($USSF_Title, '', 0)
			WinSetState($USSF_Title, '', @SW_HIDE)
			While ($USSF_Installer = '') Or StringInStr($USSF_Installer, 'Work in progress')
				$Test += 1
				SplashThis('Searching for Silent Switches. Please wait...', 'Analyzing with USSF ... (' & $Test & ')')
				$USSF_Installer = StringStripWS(ControlGetText($USSF_Title, '', 'Edit1'), 3)
				Sleep(100)
			WEnd
			$USSF_Ext = StringStripWS(ControlGetText($USSF_Title, '', 'Edit2'), 3)
			$USSF_Type = StringStripWS(ControlGetText($USSF_Title, '', 'Edit3'), 3)
			$USSF_Usage = StringStripWS(ControlGetText($USSF_Title, '', 'Edit4'), 3)
			$USSF_Notes = StringStripWS(ControlGetText($USSF_Title, '', 'Edit5'), 3)
			WinClose($USSF_Title)
			While ProcessExists($PID)
				ProcessClose($PID)
				Sleep(100)
			WEnd
			;If $USSF_Type = 'Undetected PE file' Then Return 'Unknown'
			Return $USSF_Type
		EndIf
	EndIf
EndFunc
#endregion

;~ End Of File

