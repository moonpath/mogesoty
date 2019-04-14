#NoTrayIcon
#Persistent
#SingleInstance, OFF

SetWorkingDir,%A_ScriptDir%
DetectHiddenWindows,On

args = %0%
if (args != 3)
    ExitApp

pid = %1%
cmd = %2%
wd = %3%

cmd := """" . StrReplace(cmd, ",", """" . " " . """") . """"

SetTimer, checkprocess, 5000 

checkprocess()
{
    global
    Process, Exist,% pid
    if (ErrorLevel == 0)
    {
        Run,% cmd,% wd, UseErrorLevel
        ExitApp
    }
}
