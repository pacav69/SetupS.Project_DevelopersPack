# FAQ
 FAQ stands for "Frequently Asked Questions"

 ## Winscp
Where to find infomation on Winscp?
Winscp command line parameters [here](https://winscp.net/eng/docs/commandline)

using winscp and script

    pathto\WinSCP.com /log=pathto\filename.log  /ini=nul /script=scriptfile.ini

notes:
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

    echo mv checksums_*.md5 SetupSoldfies/>>fileslastos.ini

files can be uploaded to ftp site by using the put command, wildcards are permitted

    echo ; files to upload >>fileslastos.ini
    echo put .\files\update.ini>>fileslastos.ini
    echo put .\files\*.exe >>fileslastos.ini

put is used ti upload the file to the ftp site

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
website [here](https://www.autoitscript.com/site/)
AutoIt v3 is a freeware BASIC-like scripting language designed for automating the Windows GUI and general scripting. It uses a combination of simulated keystrokes, mouse movement and window/control manipulation in order to automate tasks in a way not possible or reliable with other languages (e.g. VBScript and SendKeys). AutoIt is also very small, self-contained and will run on all versions of Windows out-of-the-box with no annoying “runtimes” required!

## fart
Find And Replace Text for the following (requires: bin\fart.exe)

## ANSI
ANSI escape codes
ANSI escape sequences are a standard for in-band signaling to control cursor location, color, font styling, and other options on video text terminals and terminal emulators. Certain sequences of bytes, most starting with an ASCII escape character and a bracket character, are embedded into text. The terminal interprets these sequences as commands, rather than text to display verbatim.

found [here](https://en.wikipedia.org/wiki/ANSI_escape_code)
[here](https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797)
ANSI Colors [here](https://ss64.com/nt/syntax-ansi.html

## CHOICE
information [Ref here](https://www.robvanderwoude.com/choice.php)
[ss64 here](https://ss64.com/nt/choice.html)

    CHOICE /C:YN /N /T 5 /D N  /M

### Syntax:
CHOICE [ /C choices ] [ /N ] [ /CS ] [ /T timeout /D choice ] [ /M text ]

Description:
    	This tool allows users to select one item from a list of choices and returns the index of the selected choice.
Parameter List:

    	/C choices	    	Specifies the list of choices to be created.
Default list for English versions is YN

    /N	 	Hides the list of choices in the prompt.
The message before the prompt is displayed and the choices are still enabled.

 	/CS	 	Enables case-sensitive choices to be selected.

By default, the utility is case-insensitive.

Note: DOS and NT Resource Kit versions use /S instead

 	/T timeout	 	The number of seconds to pause before a default choice is made.

Acceptable values are from 0 to 9999.
If 0 is specified, there will be no pause and the default choice is selected.

Note: DOS and NT Resource Kit versions use /T:default,timeout instead.

 	/D default	 	Specifies the default choice after timeout seconds.
Character must be in the set of choices specified by /C option and must also specify timeout with /T.

Note: DOS and NT Resource Kit versions use /T:default,timeout instead.

 	/M text	 	Specifies the message to be displayed before the prompt.
If not specified, the utility displays only a prompt.

The ERRORLEVEL is set to the offset of the index of the key that was selected from the set of choices.
The first choice listed returns a value of 1, the second a value of 2, and so on.
If the user presses a key that is not a valid choice, the tool sounds a warning beep.
If tool detects an error condition, it returns an ERRORLEVEL value of 255.
If the user presses CTRL+BREAK or CTRL+C, the tool returns an ERRORLEVEL value of 0.
When you use ERRORLEVEL parameters in a batch program, list them in decreasing order.

### Choice Examples:
The command:

    CHOICE /M "Do you really want to quit"

Will display the following line:

    Do you really want to quit? [YN]

If the user presses Y, CHOICE exits with return code ("errorlevel") 1 (1st character in choices), if the user presse N, CHOICE exits with return code 2 (2nd character in choices).

    CHOICE /C ABCDN /N /T 10 /D C /M "Format drive A:, B:, C:, D: or None?"
    IF ERRORLEVEL 5 SET DRIVE=None
    IF ERRORLEVEL 4 SET DRIVE=drive D:
    IF ERRORLEVEL 3 SET DRIVE=drive C:
    IF ERRORLEVEL 2 SET DRIVE=drive B:
    IF ERRORLEVEL 1 SET DRIVE=drive A:
    ECHO You chose to format %DRIVE%
example of using a number of choices.

in this example there are 5 choices with the error levels are set from highest to lowest.

## Using FOR %%i IN
this case finds the application in any drive

    :SetHelpNDoc8 working variable
    set HelpNDoc8="%ProgramFiles%\HelpNDoc8HelpNDoc8\hnd8.exe"
    if exist "%ProgramFiles(x86)%\HelpNDoc8\hnd8.exe" set HelpNDoc8="%ProgramFiles(x86)%\HelpNDoc8\hnd8.exe"
    FOR %%i IN (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST "%%i:\ppApps\HelpNDoc8\hnd8.exe" (SET HelpNDoc8="%%i:\ppApps\HelpNDoc8\hnd8.exe"& goto doitnow)


## using if existS

## versioning


## using accounts.ini