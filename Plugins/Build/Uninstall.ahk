Global dir
Global processName
SplitPath, A_AhkPath, , dir, , processName

if(!A_IsAdmin)
{
    if A_IsCompiled
    {
        DllCall("shell32\ShellExecute",uint,0,str,"RunAs",str,A_ScriptFullPath,str,"",str,A_WorkingDir,int,1)
        ExitApp
    }
    else
    {
        DllCall("shell32\ShellExecute",uint,0,str,"RunAs",str,A_AhkPath,str,"""" . A_ScriptFullPath . """",str,A_WorkingDir,int,1)
        ExitApp
    }
    return
}

SetWorkingDir %A_ScriptDir%

MsgBox, 305, Uninstall, Would you like to uninstall %processName%?
IfMsgBox OK
{
FileCreateDir, %A_Temp%\%processName%
if(FileExist(A_Temp . "\" . processName . "\Uninstall.ahk"))
    FileDelete, %A_Temp%\%processName%\Uninstall.ahk
Sleep,1000
FileAppend,
(
Uninstall:
Run,TaskKill /F /IM "%processName%.exe",,Hide UseErrorLevel
Sleep,1000
FileRemoveDir, %dir%, 1
if(ErrorLevel)
{
    MsgBox, 21, Uninstall,%processName% cannot be uninstall, please close all the dependent processes and retry it!
    Ifmsgbox,Retry
        goto, Uninstall
    ExitApp
}
RegDelete, HKEY_CLASSES_ROOT\.ahk
RegDelete, HKEY_CLASSES_ROOT\ahkfile
RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%processName%
RegDelete, HKEY_CLASSES_ROOT\SystemFileAssociations\.ahk
Run,SCHTASKS /Delete /TN "%processName%" /F,,Hide UseErrorLevel
FileDelete,%A_DesktopCommon%\%processName%.lnk
FileDelete,%A_ProgramsCommon%\%processName%.lnk
MsgBox, 64, Uninstall, %processName% has been uninstall!
ExitApp
),%A_Temp%\%processName%\Uninstall.ahk
FileCopy, %dir%\%processName%.exe, %A_Temp%\%processName%\Uninstall.exe, 1
Sleep,1000
Run, %A_Temp%\%processName%\Uninstall.exe,,UseErrorLevel
ExitApp
return
}
