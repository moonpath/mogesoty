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

RegRead, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\DefaultIcon
REG_SZ := Trim(REG_SZ, """")
SplitPath, REG_SZ, , , , processName
if (processName = "")
{
    MsgBox, 64, Uninstall, Uninstall Failed!
    ExitApp
}

RegDelete, HKEY_CLASSES_ROOT\.ahk
RegDelete, HKEY_CLASSES_ROOT\ahkfile
RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%processName%
RegDelete, HKEY_CLASSES_ROOT\SystemFileAssociations\.ahk
Run,SCHTASKS /Delete /TN "%processName%" /F,,Hide UseErrorLevel
FileDelete, C:\Users\Public\Desktop\%processName%.lnk
FileDelete, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\%processName%.lnk
MsgBox, 64, Uninstall, Uninstall Success!
ExitApp
