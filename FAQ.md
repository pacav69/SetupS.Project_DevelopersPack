# FAQ
 FAQ stands for "Frequently Asked Questions"

 ## Winscp
Where to find infomation on Winscp?

pathto\WinSCP.com /log=pathto\filename.log  /ini=nul /script=scriptfile.ini

/ini=nul is to prevent session being saved
/script=scriptfile.ini is a list of commands and files

in scriptfile.ini
@REM ref: https://winscp.net/eng/docs/commandline
to build a script with a batch file
text can be redirected to a text file using the character >> to append to file

comments are preceded with a ;
eg
    echo ; files to move >>fileslastos.ini

set parameters in a cmd file

    set domain2=username@domain.org
    set ftp2=ftp.domain.org

open a session to establish a connection

    echo open ftp://%domain2%:#Password#@%ftp2%/%Webfolder2%>>fileslastos.ini

where the variables are set
%domain2% is the domain name
%ftp2% is the ftp site
%Webfolder2% is the folder on the ftp site
#Password# is a parameter that is replaced with the correct password by a cmd file


files can be moved on ftp site
    echo echo moving files on ftp server
    echo mv checksums_*.md5 SetupSoldfies/>>fileslastos.ini

files can be uploaded to ftp site

    echo echo uploading files
    echo ; files to upload >>fileslastos.ini
    echo put .\files\update.ini>>fileslastos.ini

put is used ti upliad the file to the ftp site

### sample script file

    ; open a session
     open ftp://username@domain.org:usernamePassword@ftp.domain.org/<folder>
    ; files to move
    mv checksums_*.md5 SetupSoldfies/
    put .\files\update.ini


### using ERRORLEVEL
to display results either success or errors

set WINSCP_RESULT=%ERRORLEVEL%
if %WINSCP_RESULT% equ 0 (
    echo.
Echo %_fYellow%%_bBlue%#######################################################%_fBGreen%%_bBlack%
echo ### Successfully moved old and uploaded files
Echo %_fYellow%%_bBlue%#######################################################%_fBGreen%%_bBlack%
  echo.
) else (
echo.
Echo %_fRed%%_bBlack% #######################################################%_fBGreen%%_bBlack%
echo ### an Error occured
echo %_fRed%%_bBlack%####################################################### %_fBGreen%%_bBlack%
  echo.

    type fileslastos.ini
  goto Finish
)

:Finish
exit /b %WINSCP_RESULT%


    .\WinSCP\WinSCP.com  /log=".\WinSCP\winscp.log" /ini=nul /script=fileslastos.ini


## helpndoc 8
command line options for helpndoc 8

### for Building chm

    \pathto\HelpNDoc8\hnd8.exe \pathto\ssTek.hnd build -verbose  -x="Build chm documentation" -o="sstek.chm:c:\temp\"

### for Building html

    \pathto\HelpNDoc8\hnd8.exe pathto\ssTek.hnd build build -verbose  -x="Build HTML documentation" -o="Build HTML documentation:%htmlhelp%\%UpdateHelpFile%.html"

for development use -verbose to pause after compiling
other options  -silent displays compiling without pause
or -verysilent for no output display
the ssTek.hnd is the file used by the helpndoc GUI for creation and modification of the help file.

### final code for using  helpndoc 8 on command line

    :SetHelpNDoc8 working variable
    set HelpNDoc8="%ProgramFiles%\HelpNDoc8HelpNDoc8\hnd8.exe"
    if exist "%ProgramFiles(x86)%\HelpNDoc8\hnd8.exe" set HelpNDoc8="%ProgramFiles(x86)%\HelpNDoc8\hnd8.exe"
    FOR %%i IN (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST "%%i:\ppApps\HelpNDoc8\hnd8.exe" (SET HelpNDoc8="%%i:\ppApps\HelpNDoc8\hnd8.exe")
    if not exist "htmlhelp"  mkdir "htmlhelp" >nul:

    :MakeHelpFiles
    set sc=Source.Code
    set UpdateHelpPath=%~dp0%sc%
    set UpdateHelpFile=ssTek
    set htmlhelp=%UpdateHelpPath%\sstekhelpfiles\files
    @REM for Building chm
    %HelpNDoc8% %UpdateHelpPath%\%UpdateHelpFile%.hnd build  -silent -x="Build chm documentation" -o=%UpdateHelpFile%.chm"
 documentation:%~dp0\html\%UpdateHelpFile%.html"
    @REM for Building html
    %HelpNDoc8% %UpdateHelpPath%\%UpdateHelpFile%.hnd build -silent -x="Build HTML documentation" -o="Build HTML documentation:%htmlhelp%\%UpdateHelpFile%.html"

## Autoit

## fart
Find And Replace Text for the following (requires: bin\fart.exe)

## ANSI

## choice

## Using FOR %%i IN
:SetHelpNDoc8 working variable
set HelpNDoc8="%ProgramFiles%\HelpNDoc8HelpNDoc8\hnd8.exe"
if exist "%ProgramFiles(x86)%\HelpNDoc8\hnd8.exe" set HelpNDoc8="%ProgramFiles(x86)%\HelpNDoc8\hnd8.exe"
FOR %%i IN (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST "%%i:\ppApps\HelpNDoc8\hnd8.exe" (SET HelpNDoc8="%%i:\ppApps\HelpNDoc8\hnd8.exe"& goto doitnow)


## using if existS

## versioning


## using accounts.ini