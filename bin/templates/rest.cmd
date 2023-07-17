:: Use:
:: %1=File to upload
:: %2=Repository name
:: %3=Package name
:: %4=Version
@echo off
set Site=#Domain#
set UN=#Account#
set PW=#Password#

:setDesc
set Desc=Uploading to Bintray... %1

:Begin
echo %Desc%
call curl\curl --insecure -T "%1" -u%UN%:%PW% https://%Site%/%UN%/%2/%1;bt_package=%3;bt_version=v%4;publish=1
echo.