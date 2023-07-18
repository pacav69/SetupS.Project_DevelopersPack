@echo off

:Set parameters
set ProjectVersion=23.07.18.1
set ProjectDate=2023-07-18
set Upload=No

:Begin
call !DistrPack.Project.cmd %ProjectVersion% %ProjectDate% %Upload%

:Exit