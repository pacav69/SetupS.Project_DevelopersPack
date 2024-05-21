:: Use:
:: %1=File
:: %2=Summary
:: %3=Labels
@echo off
set Site=#Domain#
set UN=#Account#
set PW=#Password#
echo Uploading to Google-code... %1

if not [%3]==[] goto wLabels
Source.Code\googlecode-upload.py --summary=%2 --project=%Site% --user=%UN% --password=%PW% %1
goto :End

:wLabels
Source.Code\googlecode-upload.py --summary=%2 --labels=%3 --project=%Site% --user=%UN% --password=%PW% %1
goto :End

:End
echo.