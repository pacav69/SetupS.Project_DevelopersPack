@echo off

:Set parameters
@REM ProjectVersion= YY.MM.DD.0 ONLY numbers
@REM seperated with periods in the form XX.XX.XX.XX
@REM use the date of compilatation YY.MM.DD.Incremental number usually 0
set ProjectVersion=23.07.18.1
@REM ProjectDate=YY-MM-DD ONLY numbers
@REM use the date of compilatation YY-MM-DD
@REM use the date of compilatation YY-MM-DD seperated by a '-'
set ProjectDate=2023-07-18
set Upload=Yes

:Begin
call !DistrPack.Project.cmd %ProjectVersion% %ProjectDate% %Upload%

:Exit