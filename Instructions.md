<!-- Instructions.md -->
# Instructions

## Development tools directory (devtools)
 install first the Development tools in devtools directory
 that contains the neccessary app files required for development.

## AutoIT3
Before starting
Ensure that AutoIT3 is version 3.3.8.1 dated 30/01/2012 is installed without modifications otherwise compiling will fail.

## Make changes to files

Make modifications or improvments to files

## change ProjectVersion

change the ProjectVersion
so that it reads ProjectVersion= YY.MM.DD.0 use ONLY numbers
* seperated with periods in the form YY.MM.DD.0
* use the date of compilatation YY.MM.DD.Incremental number usually 0
  where
* YY is the two digit year,
* MM the digit month,
* DD two digit day
* followed by Incremental number

eg.

    set ProjectVersion=23.07.18.0

### change ProjectDate
change the ProjectDate
* ProjectDate=YYYY-MM-DD use ONLY numbers
* use the date of compilatation in the format YYYY-MM-DD
  where
* YYYY is the four digit year,
* MM the digit month,
*  DD two digit day
* use the date of compilatation YYYY-MM-DD seperated by a '-'

eg

    set ProjectDate=2023-07-23
## Generating SetupS-files.htm file
This file stores the download links for the files.
In order to generate a SetupS-files.htm file make sure the Upload parameter is set to **'Yes'**:

    set Upload=Yes

## Upload files

Uploading using winscp
To add auto upload files
copy \bin\templates\blank_updfiles.cmd to root
rename file to updfiles.cmd
change the setting of pw=mypass to pw=[correct password]
save the file
when prompted the script will automagiclly move the old files and upload the new files

run the cmd file

     !!Make.SetupS-Project.cmd

this will generate the files based on the new version numbers.

The files will be moved to the 'files' sub directory on the host for later upload to the respective ftp websites for distribution.

this will also upload to LastOS Forum at the end of cleanup

or run

  timecompile.cmd

this will time the compile and upload of files

## Update changelog

record changes made to files in the changelog.txt so other people can see what was modified


## Updating help files on website

help files are located here:

     .\SetupS.Project_DevelopersPack\Source.Code\Tools\sstekhelpfiles\ssTek

use all the HTML and images files

## upload using ftp
* website ftp.vergitek.com
* login user name: sstek
* password: found on lastos Forums

onced logged in
uploaded files to

  root/help/files

to check goto

    http://sites.vergitek.com/sstek/help/ssTek.html

using shift F5 to refresh.

# Uploading files

## Github files

Use visual studio code with intergrated git
use github desktop

## Lastos.org site
FTP details

ftp-lastos
  Host: ftp.lastos.org
  Port: 21
  Username:  found on lastos Forums
  Password:  found on lastos Forums

  ### Procedure
*   first move old setups files to the following directory:

  \<root>/files/SetupSoldfies
*   upload files on host site to here:

    \<root>/files

* check files here https://www.lastos.org/files/SetupS-files.htm

## veritek.com site

FTP LastOS (on Vergitek); backup for the Bluehost site, plus the LastOS release archive:
  Host: ftp.vergitek.com
  Port: 21
  Username: found on lastos Forums
  Password: found on lastos Forums

  ### Procedure
*   first move old setups files to the following directory:

  \<root>/files/SetupSoldfies
  In winscp it is done as part of the script.
*   upload files on host site to here:

    \<root>/files

* check files here

    http://sites.vergitek.com/sstek/files/SetupS-files.htm


## Uploading using curl
To upload using curl and accounts.ini
copy bin\templates\blank_Accounts.ini to root directory
rename blank_Accounts.ini to Accounts.ini
change the contents with this file structure

    [www.domain.ext]
    Type=ftp [cmd files that are located inbin\templates\ such as ftp]
    Domain=ftp.domain.ext
    Port=21
    Username=[as defined by the admin]
    Password=[as defined by the admin]

:example of domain www.lastos.org]

    [www.lastos.org]
    Type=ftp
    Domain=ftp.lastos.org
    Port=21
    Username=myUsername
    Password=myPassword

the accounts.ini information can be found on lastos Forums

ensure that in file !!Make.SetupS-Project.cmd has the parameter is

   set Upload=Yes

   This will also upload to veritek  at the end of cleanup script.

## Manually upload files using winscp
When the file !DistrPack.Project.cmd  is run the user will be prompted to upload files, the default is 'No'.
To manually upload first check that the pw in file updfiles.cmd has been set then run it.
then run uploadlastos.cmd this will then use the generated fileslastos.ini script to upload files.


## Timing of compile
To find out how long it takes to compile and upload run timecompile.cmd

## References
### Winscp
[Winscp Home page](https://winscp.net/)
[Winscp put](https://winscp.net/eng/docs/scriptcommand_put)
[Winscp open](https://winscp.net/eng/docs/scriptcommand_open)

The LastOS Team



