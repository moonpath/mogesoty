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

SplitPath, A_AhkPath, , installPath, , processName
Register(installPath, processName)
MsgBox, 64, Install, Install Success!

Register(installPath, processName)
{
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\.ahk,,ahkfile
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\DefaultIcon,,"%installPath%\%processName%.ico"
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\shell\open\command,,"%installPath%\%processName%.exe" "`%1"
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\shell\edit\command,,notepad "`%1"
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\shell\runas\command,,"%installPath%\%processName%.exe" "`%1"
    RegWrite, REG_SZ, HKEY_CLASSES_ROOT\ahkfile\shell\Compile\command,,"%installPath%\Bin\Ahk2Exe.exe" "/in" "`%1"
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%processName%,DisplayIcon,"%installPath%\%processName%.ico"
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%processName%,DisplayName,%processName% 3.16 (64-bit)
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%processName%,DisplayVersion,3.16.7116.0
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%processName%,Publisher,A.H. Zhang
    RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%processName%,EstimatedSize,30205
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%processName%,UninstallString,"%installPath%\Bin\Unregister.exe"
    FileAppend,
(
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>%A_YYYY%-%A_MM%-%A_DD%T%A_Hour%:%A_Min%:%A_Sec%.%A_MSec%</Date>
    <Author>%A_ComputerName%\%A_UserName%</Author>
    <Description>Start %processName% and Skip UAC.</Description>
    <URI>\%processName%</URI>
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
      <Command>%installPath%\%processName%.exe</Command>
      <Arguments>"%installPath%\%processName%.ahk" /invisible</Arguments>
      <WorkingDirectory>%installPath%</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
),%installPath%\%processName%.xml
    Sleep,1000
    Run, SCHTASKS /Create /TN %processName% /XML "%installPath%\%processName%.xml",,Hide UseErrorLevel
    Sleep,1000
    FileDelete,%installPath%\%processName%.xml
    FileCreateShortcut,%installPath%\%processName%.exe,%A_DesktopCommon%\%processName%.lnk,%installPath%,,%processName% 3.16,%installPath%\%processName%.ico
    FileCreateShortcut,%installPath%\%processName%.exe,%A_ProgramsCommon%\%processName%.lnk,%installPath%,,%processName% 3.16,%installPath%\%processName%.ico
}
