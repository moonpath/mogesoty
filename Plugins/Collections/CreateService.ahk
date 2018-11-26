if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

SetWorkingDir, %A_ScriptDir%
#SingleInstance, force
#Persistent
#NoEnv

Gui, Add, Text,, Name the Service
Gui, Add, Edit, vser
Gui, Add, Button, default gbuttonx, Select an exe file
Gui, Show,,  Exe 2 Service
return

GuiClose:
buttonx:
Gui, Submit
Gui Destroy

FileSelectFile, SelectedFile, 3, , Select an exe file to make it run as a service, Executable (*.exe)
if SelectedFile =
    MsgBox, You didn't select anything.
else
sleep, 200
RunWait, cmd /c  sc create %ser% binpath= %SelectedFile%,, Hide
RunWait, cmd /c  sc create %ser% binpath= %SelectedFile%  >> Service %ser%.txt  ,, Hide
sleep, 200
MsgBox, 4160, Service,%ser% have now been made to a service.


;This is just a quick example of some things you can do

Gui, Add, Button, default gbuttonstart, Start %ser%
Gui, Add, Button, default gbuttonstop, Stop %ser%
Gui, Add, Button, default gbuttondel, Delete %ser%
Gui, Add, Button, default gbuttonget, Get %ser% ID
Gui, Add, Button, default gbuttonprev, Set Primitaions of %ser%
Gui, Show,,  %ser% Options
return


buttonstart:
Gui, Submit
RunWait, cmd /c net start %ser%,, Hide >> debug.txt
RunWait, cmd /c net start %ser%,, Hide
sleep, 500
MsgBox, 4160, Service, %ser% have now been started and is running.
return

buttonstop:
Gui, Submit
RunWait, cmd /c net Stop %ser%,, Hide >> debug.txt
RunWait, cmd /c net Stop %ser%,, Hide
sleep, 500
MsgBox, 4160, Service, %ser% have now been Stoped. 
return

buttondel:
Gui, Submit
RunWait, cmd /c sc Delete %ser%,, Hide >> debug.txt
RunWait, cmd /c sc Delete %ser%,, Hide
sleep, 500
MsgBox, 4160, Service, %ser% have now been Deleted.
return

buttonget:
Gui, Submit
RunWait, cmd /c sc showsid %ser%,, Hide >> debug.txt
RunWait, cmd /c sc showsid %ser%,, Hide
sleep, 500
MsgBox, 4160, Service, %ser% have now been Deleted.
return

buttonprev:
Gui, Submit
RunWait, cmd /c sc privs %ser%,, Hide  >> debug.txt
RunWait, cmd /c sc privs %ser%,, Hide
sleep, 500
MsgBox, 4160, Service, %ser% have now been Deleted.
return