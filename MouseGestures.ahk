goto,MouseGesturesEnd ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;<MouseGesture>=========================================================
MouseGesture_(hoveredHwnd,ClassNN)
{
    if(!(ClassNN~="MKSEmbedded2"))
        SendInput,{Rbutton}
    return
}

MouseGesture_1(hoveredHwnd,ClassNN,xPos,yPos)
{
    /*
    WinGetPos,,winY,,,% hoveredHwnd
    WinGetClass,ProcessClass,% hoveredHwnd
    if(yPos-winY<30&&ProcessClass~="CabinetWClass")
        WindowStyle.Show(SubStr(hoveredHwnd,7))
    else if((ProcessClass~="CabinetWClass|Progman|WorkerW")&&(SelectedFile:=WindowsExplorer.WindowsExplorerGetSelectedItemPath(SubStr(hoveredHwnd,7)))&&(StrLen(SelectedFile)-InStr(SelectedFile,":")-1))
        FileAttribMenu.Show(SelectedFile)
    else if(yPos-winY<30&&!(ProcessClass~="Windows.UI.Core.CoreWindow|Progman|Shell_TrayWnd|Shell_SecondaryTrayWnd|MultitaskingViewFrame|NotifyIconOverflowWindow|WorkerW|TaskListThumbnailWnd"))
        WindowStyle.Show(SubStr(hoveredHwnd,7))
    else
        ContextMenu.Show()
     */
    return
}

MouseGesture_2(hoveredHwnd,ClassNN,xPos,yPos)
{
    MouseGesture_1(hoveredHwnd,ClassNN,xPos,yPos)
    return
}

MouseGesture_L1()
{
    SendInput,{Lbutton Up}
    Hotkey,WheelDown,Hotkey_sound_down,On
    Hotkey,WheelUp,Hotkey_sound_up,On
    KeyWait,Lbutton,T10
    Hotkey,WheelDown,Hotkey_sound_down,Off
    Hotkey,WheelUp,Hotkey_sound_up,Off
}

MouseGesture_L2()
{
    SendInput,{Lbutton Up}
    Hotkey,WheelDown,Hotkey_sound_down,On
    Hotkey,WheelUp,Hotkey_sound_up,On
    KeyWait,``,T10
    Hotkey,WheelDown,Hotkey_sound_down,Off
    Hotkey,WheelUp,Hotkey_sound_up,Off
}

MouseGesture_L()
{
    Run ::{20d04fe0-3aea-1069-a2d8-08002b30309d},,UseErrorLevel
    return
}

MouseGesture_LR()
{
    Run,% comspec,% A_Desktop,UseErrorLevel
    return
}

MouseGesture_LU(hoveredHwnd)
{
    WinActivate,% hoveredHwnd
    SendInput,^c
    Main.Notification.Notify("Copy Completed")
    return
}

MouseGesture_LUL(hoveredHwnd)
{
    WinActivate,% hoveredHwnd
    SendInput,{BS}
    return
}

MouseGesture_LUR(hoveredHwnd)
{
    WinActivate,% hoveredHwnd
    SendInput,^v
    Main.Notification.Notify("Paste Completed")
    return
}

MouseGesture_LD(hoveredHwnd)
{
    WinActivate,% hoveredHwnd
    ClipBoard:=""
    SendInput,^c
    ClipWait,0
    if(FileExist(ClipBoard))
    {
        SplitPath, ClipBoard, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        if OutExtension in png,jpg,jpeg,bmp,gif
        {
            Run, Plugins\View\i_view64.exe %ClipBoard% /clipcopy /killmesoftly /silent,,UseErrorLevel
            Main.Notification.Notify("Image Copied to Clipboard")
        }
    }
    return
}

MouseGesture_LDR()
{
    Run, Plugins\View\i_view64.exe /clippaste /silent,,UseErrorLevel
    return
}

MouseGesture_R(hoveredHwnd)
{
    WinActivate,% hoveredHwnd
    WinGet, currentProcessName, ProcessName, %hoveredHwnd%
    ClipBoard:=""
    SendInput,^c
    ClipWait,0
    if(clipboard!="")
        if(Gesture.SearchEngine == 1)
            Run,% "www.bing.com/search?&q=" . ReplaceURL(clipboard),,UseErrorLevel
        else if(Gesture.SearchEngine==2)
            Run,% "www.baidu.com/s?ie=utf-8&wd=" . ReplaceURL(clipboard),,UseErrorLevel
        else
            Run,% "www.google.com/search?q=" . ReplaceURL(clipboard),,UseErrorLevel
    else if(currentProcessName~="chrome.exe|360chrome.exe")
        SendInput,^t
    else
        Run,http:,,UseErrorLevel
    return
}

MouseGesture_RL(hoveredHwnd)
{
    WinActivate,% hoveredHwnd
    SendInput,^w
    return
}

MouseGesture_RLR(hoveredHwnd)
{
    WinActivate,% hoveredHwnd
    WinGet, currentProcessName, ProcessName, %hoveredHwnd%
    if(currentProcessName~="chrome.exe|360chrome.exe")
        SendInput,^+t
    return
}

MouseGesture_RLRL(hoveredHwnd)
{
    WinActivate,% hoveredHwnd
    WinGet, currentProcessName, ProcessName, %hoveredHwnd%
    if(currentProcessName~="chrome.exe|360chrome.exe")
        SendInput,^k
    return
}

MouseGesture_RLDR()
{
    MouseGesture_RULDR()
    return
}

MouseGesture_RU(hoveredHwnd)
{
    WinActivate,% hoveredHwnd
    SendInput,^{Home}
    return
}

MouseGesture_RULDR()
{
    Run,https:,,UseErrorLevel
    return
}

MouseGesture_RD(hoveredHwnd)
{
    WinActivate,% hoveredHwnd
    SendInput,^{End}
    return
}

MouseGesture_U(hoveredHwnd)
{
    WinGet,windowStatus,MinMax,%hoveredHwnd%
    WinGetClass, hoveredWinClass, %hoveredHwnd%
    if hoveredWinClass not in Windows.UI.Core.CoreWindow,Progman,Shell_TrayWnd,Shell_SecondaryTrayWnd,MultitaskingViewFrame,NotifyIconOverflowWindow,WorkerW,TaskListThumbnailWnd
        if(windowStatus)
            WinRestore,%hoveredHwnd%
        else
            WinMaximize,%hoveredHwnd%
    else
        SendInput,#{Tab}
    return
}

MouseGesture_UL(hoveredHwnd)
{
    WinActivate,% hoveredHwnd
    SendInput,!{Left}
    return
}

MouseGesture_UR(hoveredHwnd)
{
    WinActivate,% hoveredHwnd
    SendInput,!{Right}
    return
}

MouseGesture_UD()
{
    WinMinimizeAll
    return
}

MouseGesture_UDU(hoveredHwnd)
{
    prevDetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows,Off
    WinGet,winIDList,List
    Loop,%winIDList% 
    {
        WinGet,style,Style,% "ahk_id" . winIDList%A_Index%
        WinGet,minMax,MinMax,% "ahk_id" . winIDList%A_Index%
        WinGetTitle,title,% "ahk_id" . winIDList%A_Index%
        if(minMax!=-1&&(style & 0x20000)&&title&&SubStr(hoveredHwnd,7)!=winIDList%A_Index%)
            WinMinimize,% "ahk_id" . winIDList%A_Index%
  }
  DetectHiddenWindows,% prevDetectHiddenWindows
    return
}

MouseGesture_D(hoveredHwnd)
{
    WinGetClass, mouseHoveredWinClass, %hoveredHwnd%
    if mouseHoveredWinClass not in Windows.UI.Core.CoreWindow,Progman,Shell_TrayWnd,Shell_SecondaryTrayWnd,MultitaskingViewFrame,NotifyIconOverflowWindow,WorkerW,TaskListThumbnailWnd
        WinMinimize, %hoveredHwnd%
    return
}

MouseGesture_DL(hoveredHwnd)
{
    WinActivate,% hoveredHwnd
    SendInput,^c
    RegRead, OneNote, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\OneNote.exe
    Run,% OneNote . " /sidenote /paste",,UseErrorLevel
    return
}

MouseGesture_DLU()
{
    Component.RunPlugin("Keypass\Keypass.ahk")
    return
}

MouseGesture_DR(hoveredHwnd)
{
    WinActivate,% hoveredHwnd
    SendInput,^c
    Run NotePad,,UseErrorLevel
    Sleep, 300
    SendInput,^v
    return
}

MouseGesture_DRU()
{
    KeyWait,Rbutton,U
    Send ^!y^+l
    Run,rundll32 user32.dll`,LockWorkStation,,UseErrorLevel
    return
}

MouseGesture_DU(hoveredHwnd)
{
    WinGetClass, mouseHoveredWinClass, %hoveredHwnd%
    if mouseHoveredWinClass not in Windows.UI.Core.CoreWindow,Progman,Shell_TrayWnd,Shell_SecondaryTrayWnd,MultitaskingViewFrame,NotifyIconOverflowWindow,WorkerW,TaskListThumbnailWnd
        WinKill,%hoveredHwnd%
    return
}

MouseGesture_DUD(hoveredHwnd)
{
    WinGet,PID,PID,%hoveredHwnd%
    WinGet,ProcessName,ProcessName,ahk_pid %PID%
    Process,Close,%PID%
    if(ErrorLevel==0)
    {
        Main.LogToFile("Kill " . ProcessName . " Failed")
        TrayTip,,Process Termination Failed,,3
    }
    return
}

MouseGesture_DUDU(hoveredHwnd)
{
    WinGet,PID,PID,%hoveredHwnd%
    WinGet,ProcessPath,ProcessPath,ahk_pid %PID%
    WinGet,ProcessName,ProcessName,ahk_pid %PID%
    Process,Close,%PID%
    Loop,5
    {
        Sleep,1000
        Process,Exist,%PID%
        if(ErrorLevel==0)
        {
            Run,%ProcessPath%,,UseErrorLevel
            return
        }
    }
    Main.LogToFile("Restart " . ProcessName . " Failed")
    TrayTip,,Restart Failed,,3
    return
}
;</MouseGesture>========================================================
MouseGesturesEnd:
