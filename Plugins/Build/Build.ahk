SplitPath, A_AhkPath, , , , processName$
GLOBAL ASSEMBLYTITLE := processName
GLOBAL ASSEMBLYPRODUCT := processName . " 3.16"
GLOBAL ASSEMBLYVERSION := "3.16.7116.0"

if(!SetWorkingDir())
{
    MsgBox, 16, Build, No source found.
    ExitApp
    return
}

text=
(
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

Gui, New, , Install %ASSEMBLYTITLE%
gui, font, s10, Microsoft JhengHei
Gui, Add, Text,W330,Please select the path you want to install.
Gui, Add, ComboBox,WP vtext Choose1, `%A_ProgramFiles`%
Gui, -MaximizeBox -MinimizeBox
Gui, Add, Button,X193 W70 Default, OK
Gui, Add, Button,X+10 W70, Select
Gui, Show
return

ButtonOK()
{
    global text
    Gui, Submit, NoHide
    if(InStr(FileExist(text), "D"))
    {
        if(!Install(RegExReplace(text, "\\$")))
            ExitApp
        Register(RegExReplace(text, "\\$"))
        Gui, Hide
        if(FileExist(A_DesktopCommon . "\%ASSEMBLYTITLE%.lnk"))
            MsgBox, 64, , Install Successfully!
        else
            MsgBox, 16, , Error when installing %ASSEMBLYTITLE%!
        ExitApp
    }
    else
        MsgBox, 48, , The Installation Path Is Illegal`, Please Rechoose It!
    return
}

ButtonSelect()
{
    global text
    FileSelectFolder, text
    GuiControl, Text, text, `%text`%
    return
}

GuiClose()
{
    ExitApp
    return
}

Install(installPath)
{
    Process, Exist, %ASSEMBLYTITLE%.exe
    if(ErrorLevel)
    {
        Run,TaskKill /F /IM %ASSEMBLYTITLE%.exe,,Hide UseErrorLevel
        if(ErrorLevel)
        {
            Gui, Hide
            MsgBox, 16, , Install Faild`, Please Close %ASSEMBLYTITLE% And Retray It.
            return false
        }
    }


)

Loop, *, 2, 1
    text .= "    FileCreateDir, %installPath%\" . ASSEMBLYTITLE . "\" . A_LoopFileFullPath . "`n"

Loop, *, 0, 1
    text .= "    FileInstall, " . A_LoopFileLongPath . ", %installPath%\" . ASSEMBLYTITLE . "\" . A_LoopFileFullPath . ", 1`n"

Loop, *, 0, 1
    fileSize += A_LoopFileSize//1024

appendText =  
(

    if(!FileExist(installPath . "\%ASSEMBLYTITLE%\%ASSEMBLYTITLE%.exe"))
    {
        Gui, Hide
        MsgBox, 16, , Install Faild`, Please Retry It Later.
        return false
    }
    return true
}

Register(installPath)
{
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\.ahk,,ahkfile
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\DefaultIcon,,"`%installPath`%\%ASSEMBLYTITLE%\%ASSEMBLYTITLE%.ico"
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\shell\open\command,,"`%installPath`%\%ASSEMBLYTITLE%\%ASSEMBLYTITLE%.exe" "```%1"
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\shell\edit\command,,notepad "```%1"
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\shell\runas\command,,"`%installPath`%\%ASSEMBLYTITLE%\%ASSEMBLYTITLE%.exe" "```%1"
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\shell\Compile\command,,"`%installPath`%\%ASSEMBLYTITLE%\Bin\Ahk2Exe.exe" "/in" "```%1"
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%ASSEMBLYTITLE%,DisplayIcon,"`%installPath`%\%ASSEMBLYTITLE%\%ASSEMBLYTITLE%.ico"
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%ASSEMBLYTITLE%,DisplayName,%ASSEMBLYPRODUCT% (64-bit)
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%ASSEMBLYTITLE%,DisplayVersion,%ASSEMBLYVERSION%
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%ASSEMBLYTITLE%,Publisher,A.H. Zhang
    RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%ASSEMBLYTITLE%,EstimatedSize,%fileSize%
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%ASSEMBLYTITLE%,UninstallString,"`%installPath`%\%ASSEMBLYTITLE%\Uninstall.exe"
    FileAppend,
`(
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>`%A_YYYY`%-`%A_MM`%-`%A_DD`%T`%A_Hour`%:`%A_Min`%:`%A_Sec`%.`%A_MSec`%</Date>
    <Author>`%A_ComputerName`%\`%A_UserName`%</Author>
    <Description>Start %ASSEMBLYTITLE% and Skip UAC.</Description>
    <URI>\%ASSEMBLYTITLE%</URI>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
      <Delay>PT20S</Delay>
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
    <RestartOnFailure>
      <Interval>PT1M</Interval>
      <Count>3</Count>
    </RestartOnFailure>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>`%installPath`%\%ASSEMBLYTITLE%\%ASSEMBLYTITLE%.exe</Command>
      <Arguments>"`%installPath`%\%ASSEMBLYTITLE%\%ASSEMBLYTITLE%.ahk" /invisible</Arguments>
      <WorkingDirectory>`%installPath`%\%ASSEMBLYTITLE%</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
`),`%installPath`%\%ASSEMBLYTITLE%\%ASSEMBLYTITLE%.xml
    Sleep,1000
    Run, SCHTASKS /Create /TN %ASSEMBLYTITLE% /XML "`%installPath`%\%ASSEMBLYTITLE%\%ASSEMBLYTITLE%.xml",,Hide UseErrorLevel
    Sleep,1000
    FileDelete,`%installPath`%\%ASSEMBLYTITLE%\%ASSEMBLYTITLE%.xml
    FileCreateShortcut,`%installPath`%\%ASSEMBLYTITLE%\%ASSEMBLYTITLE%.exe,`%A_DesktopCommon`%\%ASSEMBLYTITLE%.lnk,`%installPath`%\%ASSEMBLYTITLE%,,%ASSEMBLYPRODUCT%,`%installPath`%\%ASSEMBLYTITLE%\%ASSEMBLYTITLE%.ico
    FileCreateShortcut,`%installPath`%\%ASSEMBLYTITLE%\%ASSEMBLYTITLE%.exe,`%A_ProgramsCommon`%\%ASSEMBLYTITLE%.lnk,`%installPath`%\%ASSEMBLYTITLE%,,%ASSEMBLYPRODUCT%,`%installPath`%\%ASSEMBLYTITLE%\%ASSEMBLYTITLE%.ico
}

)

text .= appendText

if(FileExist(A_ScriptDir . "\" . ASSEMBLYTITLE . "_Setup_" . ASSEMBLYVERSION . "_x86_64.ahk"))
{
    FileDelete, % A_ScriptDir . "\" . ASSEMBLYTITLE . "_Setup_" . ASSEMBLYVERSION . "_x86_64.ahk"
    Sleep,500
}
FileAppend, %text%, % A_ScriptDir . "\" . ASSEMBLYTITLE . "_Setup_" . ASSEMBLYVERSION . "_x86_64.ahk"

SetWorkingDir()
{
    SplitPath, A_ScriptDir, , OutDir
    SplitPath, OutDir, , OutDir
    if(FileExist(OutDir . "\" . ASSEMBLYTITLE . ".exe"))
    {
        SetWorkingDir,%OutDir%
        return true
    }
    return false
}
