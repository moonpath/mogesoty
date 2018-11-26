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

RegDelete, HKEY_CLASSES_ROOT\.ahk
RegDelete, HKEY_CLASSES_ROOT\ahkfile
RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mogesoty
RegDelete, HKEY_CLASSES_ROOT\SystemFileAssociations\.ahk
Run,SCHTASKS /Delete /TN Mogesoty /F,,Hide UseErrorLevel
FileDelete, C:\Users\Public\Desktop\Mogesoty.lnk
FileDelete, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Mogesoty.lnk
MsgBox, 64, Uninstall, Uninstall Success!
ExitApp
