@echo off

:Begin
cd "%~dp0"
if exist "%1_ppApp" rd /s /q "%1_ppApp" >nul:
md "%1_ppApp" >nul:
cd "%1_ppApp" >nul:
copy ..\%1.exe /y >nul:
copy ..\%1_x64.exe /y >nul:
copy ..\%1.ini /y >nul:
copy ..\%1.hlp /y >nul:
copy ..\%1.chm /y >nul:
copy ..\ppApp.* /y >nul:
copy ..\folder.* /y >nul:
copy ..\*.lst /y >nul:
rem copy ..\%1.jpg /y >nul:

md Licenses
cd Licenses
copy ..\..\..\Licenses\*.* /y >nul:
cd ..

md bin
cd bin
copy ..\..\bin\*.* /y >nul:
cd ..

md Tools
cd Tools
md x86
cd x86
copy ..\..\..\..\Tools\_x86\7z.exe /y >nul:
copy ..\..\..\..\Tools\_x86\7z.dll /y >nul:
cd ..

md x64
cd x64
copy ..\..\..\..\Tools\_x64\7z.exe /y >nul:
copy ..\..\..\..\Tools\_x64\7z.dll /y >nul:
cd ..

md Menus
cd Menus
copy ..\..\..\..\Tools\Menus\MenuDefaults.ini /y >nul:
copy ..\..\..\..\Tools\Menus\MenuStyles.ini /y >nul:

md KazzMenu
cd KazzMenu
copy ..\..\..\..\..\Tools\Menus\KazzMenu\Definitions.ini /y >nul:
cd ..

md LastOSMenu
cd LastOSMenu
copy ..\..\..\..\..\Tools\Menus\LastOSMenu\Definitions.ini /y >nul:

goto exit
:Exit