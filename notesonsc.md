https://ss64.com/nt/sc.html
https://ss64.com/nt/

To disable:

sc config WinDefend start= disabled
sc stop WinDefend

To re-enable:

sc config WinDefend start= auto
sc start WinDefend
Don't forget about the space after "start=" or the command will not work.

PS. You can get further description of these commands by typing:

sc /?
sc config /?

sc query WinDefend

sc stop WinDefend