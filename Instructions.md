<!-- Instructions.md -->
# Instructions

## Changes
After making changes to file(s) in the Source.Code directory

Edit the version number in the file: !!Make.SetupS-Project.cmd

    ProjectVersion= YY.MM.DD.0 ONLY numbers

seperated with periods in the form XX.XX.XX.XX
use the date of compilatation YY.MM.DD.Incremental number usually 0 (zero)
eg.

    set ProjectVersion=23.07.18.0

ProjectDate=YY-MM-DD **ONLY** numbers used
use the date of compilatation in the form YY-MM-DD seperated by a '-'
eg.

    set ProjectDate=2023-07-18

## Generating SetupS-files.htm file
This file stores the download links for the files.
In order to generate a SetupS-files.htm file
make sure the Upload paramater is set to 'yes':

    set Upload=Yes

run the cmd file

     !!Make.SetupS-Project.cmd

this will generate the files with the new version numbers

The files will be moved to the files directory for later upload to the respective websites for distrubution.

