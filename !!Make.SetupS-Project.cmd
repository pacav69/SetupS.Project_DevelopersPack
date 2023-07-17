@echo off

:Set parameters
set ProjectVersion=v23.07.17.0
set ProjectDate=2023-07-17
set Upload=Yes

:Begin
call !DistrPack.Project.cmd %ProjectVersion% %ProjectDate% %Upload%

:Exit