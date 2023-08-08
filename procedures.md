# How to update SetupS.Project_DevelopersPack

# To update files
## change the '!!Make.SetupS-Project.cmd'
edit the '!!Make.SetupS-Project.cmd' file
### change ProjectVersion
change the ProjectVersion
so that it reads ProjectVersion= YY.MM.DD.0 use ONLY numbers
seperated with periods in the form YY.MM.DD.0
use the date of compilatation YY.MM.DD.Incremental number usually 0
where YY is the two digit year, MM the digit month, DD two digit day
eg set ProjectVersion=23.07.23.0

### change ProjectDate
change the ProjectDate
ProjectDate=YYYY-MM-DD use ONLY numbers
use the date of compilatation in the format YYYY-MM-DD
where YYYY is the two digit year, MM the digit month, DD two digit day
use the date of compilatation YYYY-MM-DD seperated by a '-'
eg set ProjectDate=2023-07-23
###  Upload flag
setting flag  Upload=yes will also generate SetupS-files.htm file ready for upload
eg set Upload=Yes

## Make changes to files

make modifications or improvments to files

## Update changelog

record changes made to files in the changelog.txt so other people can see what was modified


## Updating help files on website

help files are located here:
.\SetupS.Project_DevelopersPack\Source.Code\Tools\sstekhelpfiles\ssTek
use all the HTML and images files

upload using ftp
website ftp.vergitek.com
login user name: sstek
password: found on lastos Forums

onced logged in
uploaded files to
root/help/files

to check goto
http://sites.vergitek.com/sstek/help/ssTek.html

using shift F5 to refresh.
