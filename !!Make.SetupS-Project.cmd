@REM !!Make.SetupS-Project.cmd
@echo off

:Set parameters
@REM change the ProjectVersion
@REM so that it reads ProjectVersion= YY.MM.DD.0 use ONLY numbers
@REM seperated with periods in the form YY.MM.DD.0
@REM use the date of compilatation YY.MM.DD.Incremental number usually 0
@REM where YY is the two digit year, MM the digit month, DD two digit day
@REM eg set ProjectVersion=23.07.23.0
set ProjectVersion=23.09.26.0
@REM ProjectDate=YYYY-MM-DD use ONLY numbers
@REM use the date of compilatation in the format YYYY-MM-DD
@REM where YYYY is the four digit year, MM the two digit month, DD two digit day
@REM use the date of compilatation YYYY-MM-DD seperated by a '-'
@REM eg set ProjectDate=2023-07-23
set ProjectDate=2023-09-26
@REM Upload=yes will also generate SetupS-files.htm file ready for upload
set Upload=Yes

:Begin
call !DistrPack.Project.cmd %ProjectVersion% %ProjectDate% %Upload%

:Exit