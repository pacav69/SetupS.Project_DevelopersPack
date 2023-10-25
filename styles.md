# ----- Styles and conventions infornation ----

# Introduction
This document outlines the styles used in the coding
this ensures that developers follow a convention of formating and documenting code to ensure other people who try to develop understand how the code works and as we get older we have a tendancy to forget things so it essentical that we document everything.

## References
If you find a piece of code on some website then it would be wise to give a reference so oyhers can follow or look up on how to do it.

## Remarks
Remarks are always good to use on the headers of the code to describe the purpose of the code and provide the syntax used and what inputs are provided and why things are done a certain way.

## banner
example of  banner in a cmd file

    @REM #######################################################
    @REM ###  Begin
    @REM #######################################################

this provides easy to find banners

## Labels
Labels begin with a colon : followed by an appropiate meaningful name

     :Begin

example of a label named begin

## Messages
Messages are useful to display progress and the start of an event

    :Begin
    echo ###########################################################
    echo.
    echo #    Welcome to  the LastOS SetupS Project Developers Pack
    echo #    This will compile and upload the SetupS Suite
    echo.
    echo ###########################################################
    echo.

example of the start of a long process and what functions that it will carry out

    echo Updating file resource info ...

example of progress message

## Color

using the following for color:

    @REM black / Light Green color 0A
    color 0A

this provides a black bachground ewith = Light Green text making it easy to read