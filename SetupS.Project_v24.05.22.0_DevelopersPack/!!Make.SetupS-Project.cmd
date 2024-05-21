@REM !!Make.SetupS-Project.cmd
@echo off

@REM // !!Make.SetupS-Project
@REM // Copyright (c) 2023 LastOS Team
@REM // All rights reserved. License: MIT License
:Set parameters
@REM change the ProjectVersion
@REM so that it reads ProjectVersion= YY.MM.DD.0 use ONLY numbers
@REM seperated with periods in the form YY.MM.DD.0
@REM use the date of compilatation YY.MM.DD.Incremental number usually 0
@REM where YY is the two digit year, MM the digit month, DD two digit day
@REM eg set ProjectVersion=23.07.23.0
set ProjectVersion=24.05.22.0
@REM ProjectDate=YYYY-MM-DD use ONLY numbers
@REM use the date of compilatation in the format YYYY-MM-DD
@REM where YYYY is the four digit year, MM the two digit month, DD two digit day
@REM use the date of compilatation YYYY-MM-DD seperated by a '-'
@REM eg set ProjectDate=2023-07-23
set ProjectDate=2024-05-22
@REM Upload=yes will also create uploadme.cmd file ready for upload via ftp
set Upload=Yes

:Begin
call !DistrPack.Project.cmd %ProjectVersion% %ProjectDate% %Upload%

:Exit