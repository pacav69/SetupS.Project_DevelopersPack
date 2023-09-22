:: Use:
:: %1=File to ftp
:: %2=Remote path (needs trailing forward-slash)
:: %3=Local path (needs trailing backslash)
:: %4=Where
@echo off
set Site=ftp.vergitek.com
set UN=SetupS@LastOS.org
set PW=$etup$pass
if not [%4]==[] goto setDesc
set Desc=Uploading... %1
goto Begin

:setDesc
set Desc=Uploading to %4... %3%1 -->  ftp:%UN% %Site%/%2 

:Begin
echo %Desc%
call curl\curl --ftp-create-dirs -T %3%1 -u %UN%:%PW% ftp://%Site%/%2%1
echo.