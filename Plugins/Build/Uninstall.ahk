GLOBAL ASSEMBLYTITLE := "Mogesoty"

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

SplitPath, A_ScriptDir, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
if(OutFileName!=ASSEMBLYTITLE)
{
    MsgBox, 16, Uninstall, Cannot find the installation directory.
    ExitApp
    return
}

MsgBox, 305, Uninstall, Would you like to uninstall %ASSEMBLYTITLE%?
IfMsgBox OK
{
FileCreateDir, %A_Temp%\%ASSEMBLYTITLE%
if(FileExist(A_Temp . "\" . ASSEMBLYTITLE . "\Uninstall.ahk"))
    FileDelete, %A_Temp%\%ASSEMBLYTITLE%\Uninstall.ahk
Sleep,1000
FileAppend,
(
Uninstall:
Run,TaskKill /F /IM %ASSEMBLYTITLE%.exe,,Hide UseErrorLevel
Sleep,1000
FileRemoveDir, %A_ScriptDir%, 1
if(ErrorLevel)
{
    MsgBox, 21, Uninstall,%ASSEMBLYTITLE% cannot be uninstall, please close all the dependent processes and retry it!
    Ifmsgbox,Retry
        goto, Uninstall
    ExitApp
}
RegDelete, HKEY_CLASSES_ROOT\.ahk
RegDelete, HKEY_CLASSES_ROOT\ahkfile
RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%ASSEMBLYTITLE%
RegDelete, HKEY_CLASSES_ROOT\SystemFileAssociations\.ahk
Run,SCHTASKS /Delete /TN %ASSEMBLYTITLE% /F,,Hide UseErrorLevel
FileDelete,%A_DesktopCommon%\%ASSEMBLYTITLE%.lnk
FileDelete,%A_ProgramsCommon%\%ASSEMBLYTITLE%.lnk
MsgBox, 64, Uninstall, %ASSEMBLYTITLE% has been uninstall!
ExitApp
),%A_Temp%\%ASSEMBLYTITLE%\Uninstall.ahk
FileCopy, %A_ScriptDir%\%ASSEMBLYTITLE%.exe, %A_Temp%\%ASSEMBLYTITLE%\Uninstall.exe, 1
Sleep,1000
Run, %A_Temp%\%ASSEMBLYTITLE%\Uninstall.exe,,UseErrorLevel
ExitApp
return
}
