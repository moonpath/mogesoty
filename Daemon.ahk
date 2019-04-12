#NoTrayIcon
#Persistent
#SingleInstance, off

SetWorkingDir,%A_ScriptDir%
DetectHiddenWindows,On

args:=[]
Loop,%0%
{
    args.Push(%A_Index%)
}

pid := args[1]
cmd := args[2]
wd := args[3]

cmd := """" . StrReplace(cmd, ",", """" . " " . """") . """"

SetTimer, checkprocess, 5000 

checkprocess()
{
    global pid
    global cmd
    global wd

    Process, Exist,% pid
    if (ErrorLevel == 0)
    {
        Run,% cmd,% wd, UseErroeLevel
        ExitApp
    }
}
