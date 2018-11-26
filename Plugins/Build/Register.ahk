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

installPath := GetMainDir()
if (installPath != "")
{
    Register(installPath)
    MsgBox, Install Success!
}
else
    MsgBox, Install Failed!

GetMainDir()
{
    prev_dir := A_ScriptFullPath
    while (True)
    {
        SplitPath, prev_dir, , dir
        if(FileExist(dir . "\Mogesoty.exe"))
            return dir
        if(prev_dir == dir)
            return ""
        prev_dir := dir
    }
}

Register(installPath)
{
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\.ahk,,ahkfile
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\DefaultIcon,,"%installPath%\Mogesoty.ico"
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\shell\open\command,,"%installPath%\Mogesoty.exe" "`%1"
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\shell\edit\command,,notepad "`%1"
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\shell\runas\command,,"%installPath%\Mogesoty.exe" "`%1"
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\shell\Compile\command,,"%installPath%\Bin\Ahk2Exe.exe" "/in" "`%1"
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mogesoty,DisplayIcon,"%installPath%\Mogesoty.ico"
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mogesoty,DisplayName,Mogesoty 3.16 (64-bit)
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mogesoty,DisplayVersion,3.16.7116.0
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mogesoty,Publisher,A.H. Zhang
    RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mogesoty,EstimatedSize,30205
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mogesoty,UninstallString,"%installPath%\Bin\Unregister.exe"
    FileAppend,
(
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>%A_YYYY%-%A_MM%-%A_DD%T%A_Hour%:%A_Min%:%A_Sec%.%A_MSec%</Date>
    <Author>%A_ComputerName%\%A_UserName%</Author>
    <Description>Start Mogesoty and Skip UAC.</Description>
    <URI>\Mogesoty</URI>
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
      <Command>%installPath%\Mogesoty.exe</Command>
      <Arguments>"%installPath%\Mogesoty.ahk" /invisible</Arguments>
      <WorkingDirectory>%installPath%</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
),%installPath%\Mogesoty.xml
    Sleep,1000
    Run, SCHTASKS /Create /TN Mogesoty /XML "%installPath%\Mogesoty.xml",,Hide UseErrorLevel
    Sleep,1000
    FileDelete,%installPath%\Mogesoty.xml
    FileCreateShortcut,%installPath%\Mogesoty.exe,%A_DesktopCommon%\Mogesoty.lnk,%installPath%,,Mogesoty 3.16,%installPath%\Mogesoty.ico
    FileCreateShortcut,%installPath%\Mogesoty.exe,%A_ProgramsCommon%\Mogesoty.lnk,%installPath%,,Mogesoty 3.16,%installPath%\Mogesoty.ico
}
