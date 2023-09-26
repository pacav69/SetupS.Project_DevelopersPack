[SetupS]
Title=SetupS Editor
Version=v23.09.26.0
Description=With more and more people finding uses for SetupS and ppApps, this will allow anyone to make their very own Silent Setup app or game. It will show up on ssWPI or can be used via SendTo SetupS for whenever one is in a rush to put an app (or game) back onto their PC.
URL=http://sstek.vergitek.com|http://www.lastos.org
Category=Development
BuildType=ppApp
App-File Format=v9.15.12.14.0
App-File Style=2 (INI)
AppPath=%ppApps%\SetupS.Editor
StartMenuSourcePath=ssWPI App Editor
Catalog=Development Setup & Installing
StartMenuLegacyPrimary=- Development\- Setup & Install Makers
StartMenuLegacySecondary=4 System\9 Development & Code
Flags=SendTo
[SetupS Editor (ppApp).lnk]
Target=ssEditor.exe
Arguments=-NoWait
Comment=Make your own SetupS/ppApp apps
