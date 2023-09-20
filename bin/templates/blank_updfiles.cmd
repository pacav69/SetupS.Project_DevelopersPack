@REM change mypass to correct password
set pw=mypass
@REM this will replace the txt label of #password# to pw
fart -q -i -r ".\fileslastos.ini" "#password#" "%pw%" >nul: