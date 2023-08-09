<!-- Instructions.md -->
# Instructions

## change ProjectVersion
After making changes to file(s) in the Source.Code directory

Edit the version number in the file: !!Make.SetupS-Project.cmd

    ProjectVersion= YY.MM.DD.0 ONLY numbers


change the ProjectVersion
so that it reads ProjectVersion= YY.MM.DD.0 use ONLY numbers
seperated with periods in the form YY.MM.DD.0
use the date of compilatation YY.MM.DD.Incremental number usually 0
where YY is the two digit year, MM the digit month, DD two digit day

eg.

    set ProjectVersion=23.07.18.0

### change ProjectDate
change the ProjectDate
ProjectDate=YYYY-MM-DD use ONLY numbers
use the date of compilatation in the format YYYY-MM-DD
where YYYY is the two digit year, MM the digit month, DD two digit day
use the date of compilatation YYYY-MM-DD seperated by a '-'

eg

    set ProjectDate=2023-07-23
## Generating SetupS-files.htm file
This file stores the download links for the files.
In order to generate a SetupS-files.htm file
make sure the Upload parameter is set to 'yes':

    set Upload=Yes

run the cmd file

     !!Make.SetupS-Project.cmd

this will generate the files with the new version numbers

The files will be moved to the files directory for later upload to the respective websites for distrubution.
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


