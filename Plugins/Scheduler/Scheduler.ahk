;<Scheduler>=========================================================
#NoTrayIcon
#Persistent
#SingleInstance Force

Sleep,1000

SetWorkingDir %A_ScriptDir%

GLOBAL ASSEMBLYPRODUCT := "Mogesoty 3.16"

Func("Main").call()

Main()
{
    IniRead,WindowDetector,Config.ini,Monitor,WindowDetector,0
    IniRead,NetworkDetector,Config.ini,Monitor,NetworkDetector,0
    IniRead,PowerManager,Config.ini,Monitor,PowerManager,0
    IniRead,ReminderDetector,Config.ini,Monitor,ReminderDetector,0
    IniRead,InfoDetector,Config.ini,Monitor,InfoDetector,0
    if(WindowDetector="1")
        new Windows()

    if(NetworkDetector="1")
        new Network()

    if(PowerManager="1")
        new Power()

    if(ReminderDetector="1")
        new ReminderCheck()

    if(InfoDetector == "1")
        new Info()
}

SendMessage(ByRef StringToSend, ByRef TargetScriptTitle)
{
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
    SendMessage, 0x4a, 0, &CopyDataStruct,, %TargetScriptTitle%
    DetectHiddenWindows %Prev_DetectHiddenWindows%
    SetTitleMatchMode %Prev_TitleMatchMode%
    return ErrorLevel
}

LogToFile(event)
{
    SendMessage("LogToFile,""" . event . """", ASSEMBLYPRODUCT . "ahk_class AutoHotkey")
    return
}

class Info
{
    __new()
    {
        this.pre_icon_hwnds := []
        this.last_time := -10000000
        this.notify := new this.Notify()
        BoundInfoReminder := this.judge.bind(this)
        BoundInfoShow := this.show.bind(this)
        SetTimer, % BoundInfoReminder, 1500 
        return this
    }

    show()
    {
        if (A_TickCount - this.last_time < 5000 && A_TickCount - this.notify.click_time > 1000000)
            this.notify.show()
        else
            this.notify.hide()
    }

    judge()
    {
        icon_hwnds := this.get_icon_hwnds()
        for key, value in icon_hwnds 
            if(this.pre_icon_hwnds[key] != "" && this.pre_icon_hwnds[key] != value || value == 0)
                this.last_time := A_TickCount
        this.pre_icon_hwnds := icon_hwnds

        if (A_TickCount - this.last_time < 1500 && A_TickCount - this.notify.click_time > 1000000)
            this.notify.show()
        else
            this.notify.hide()
    }

    get_icon_hwnds()
    {
        icons := TrayIcon_GetInfo()
        icon_hwnds := []
        Loop, % icons.MaxIndex()
        {
            process_name := icons[A_Index].process
            if (process_name ~= "QQ.exe|TIM.exe|WeChatStore.exe|WXWork.exe")
                icon_hwnds[process_name] := icons[A_Index].hicon
        }
        return icon_hwnds
    }

    class Notify
    {
        __new()
        {
            If !pToken := Gdip_Startup()
                MsgBox, 48, gdiplus error!
            Width := 65, Height := 65
            Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs +HwndthisHwnd
            Gui, 1: Show, NA
            Gui, 1: Hide
            hwnd := WinExist()

            hbm := CreateDIBSection(Width, Height)
            hdc := CreateCompatibleDC()
            obm := SelectObject(hdc, hbm)
            G := Gdip_GraphicsFromHDC(hdc)
            Gdip_SetSmoothingMode(G, 4)

            pBrush := Gdip_BrushCreateSolid(0x77222222)
            cBrush := Gdip_BrushCreateSolid(0x77CCCCCC)

            Gdip_FillRoundedRectangle(G, cBrush, 0, 0, 55, 55, 10)
            Gdip_FillRoundedRectangle(G, cBrush, 10, 10, 55, 55, 10)

            Gdip_DeleteBrush(pBrush)
            Gdip_DeleteBrush(cBrush)

            UpdateLayeredWindow(hwnd, hdc, A_ScreenWidth - (A_ScreenWidth-Width)//8, (A_ScreenHeight-Height)//8, Width, Height)

            OnMessage(0x201, this.WM_LBUTTONDOWN.bind(this))
            OnMessage(0x203, this.WM_LBUTTONDBLCLK.bind(this))

            SelectObject(hdc, obm)
            DeleteObject(hbm)
            DeleteDC(hdc)
            Gdip_DeleteGraphics(G)

            this.click_time := -10000000
            return this
        }

        WM_LBUTTONDOWN()
        {
            PostMessage, 0xA1, 2
        }

        WM_LBUTTONDBLCLK()
        {
            this.click_time := A_TickCount
        }

        hide()
        {
            Gui, 1: Hide
        }

        show()
        {
            Gui, 1: Show, NA
        }
    }
}

class Scheduler
{
    __new()
    {
        BoundSchedulerDetector:=Scheduler.SchedulerDetector.bind(SchedulerDetector)
        SetTimer,% BoundSchedulerDetector,5000
        return this
    }

    SchedulerDetector()
    {
    }
}

class Power
{
    __new()
    {
        IniRead,Idle,Config.ini,PowerManager,Idle,0
        Power.Idle:=Idle
        BoundPowerDetector:=Power.PowerDetector.bind(PowerDetector)
        SetTimer,% BoundPowerDetector,60000
        return this
    }

    PowerDetector()
    {
        if(Power.Idle)
            Power.IdleDetector()
    }

    IdleDetector()
    {
        if(A_TimeIdlePhysical > 10*60*1000 && A_Hour > 0 && A_Hour < 7)
        {
            ToolTip,% "Your computer will be shutdown for idle too long time."
            Sleep 60000
            LogToFile("Shutdown By PowerManager")
            Shutdown, 9
            ExitApp
        }
    }
}

class Windows
{
    __new()
    {
        IniRead,MouseGestures,Config.ini,WindowDetector,MouseGestures,0
        IniRead,TeamViewer,Config.ini,WindowDetector,TeamViewer,0
        IniRead,ConfidentialDocument,Config.ini,WindowDetector,ConfidentialDocument,0
        IniRead,KwPopupRbHost,Config.ini,WindowDetector,KwPopupRbHost,0
        IniRead,ThunderPlatform,Config.ini,WindowDetector,ThunderPlatform,0
        
        Windows.MouseGesturesFlag:=MouseGestures
        Windows.TeamViewerFlag:=TeamViewer
        Windows.ConfidentialDocumentFlag:=ConfidentialDocument
        Windows.KwPopupRbHostFlag:=KwPopupRbHost
        Windows.ThunderPlatformFlag:=ThunderPlatform
        
        BoundWindowDetector:=Windows.WindowDetector.bind(WindowDetector)
        SetTimer,% BoundWindowDetector,1000
        return this
    }

    WindowDetector()
    {
        if(Windows.MouseGesturesFlag)
            Windows.MouseGestures()
        if(Windows.TeamViewerFlag)
            Windows.TeamViewer()
        if(Windows.ConfidentialDocumentFlag)
            Windows.ConfidentialDocument()
        if(Windows.KwPopupRbHostFlag)
            Windows.KwPopupRbHost()
        if(Windows.ThunderPlatformFlag)
            Windows.ThunderPlatform()
        return
    }

    MouseGestures()
    {
        static exist:=1

        if(exist && WinExist("TeamViewer Panel"))
        {
            SendMessage("Hotkey_Alt_Win_F5" . "," . "Off", ASSEMBLYPRODUCT . "ahk_class AutoHotkey")
            exist:=0
        }

        if(!exist && !WinExist("TeamViewer Panel"))
        {
            Sleep,1000
            SendMessage("Hotkey_Alt_Win_F5" . "," . "On", ASSEMBLYPRODUCT . "ahk_class AutoHotkey")
            exist:=1
        }
        return
    }

    TeamViewer()
    {
        IfWinExist,发起会话 ahk_exe TeamViewer.exe
        {
            ControlSend,,{Enter},发起会话 ahk_exe TeamViewer.exe
            LogToFile("Close TeamViewer Popup Window")
        }
        return
    }

    ConfidentialDocument()
    {
        IfWinExist,机密文档 ahk_exe explorer.exe
        {
            WinKill 机密文档
            LogToFile("Trying To Open The Confidential Document")
        }
        return
    }

    KwPopupRbHost()
    {
        IfWinExist,ahk_class PopupRbWebDialog ahk_exe KwPopupRbHost.exe
        {
            WinKill,ahk_class PopupRbWebDialog ahk_exe KwPopupRbHost.exe
            LogToFile("Close KuWo Popup Window")
        }
        return
    }
    
    ThunderPlatform()
    {
        Process, Exist, ThunderPlatform.exe
        ThunderPlatformExe := ErrorLevel

        if(ErrorLevel)
        {
            Process, Exist, Thunder.exe
            if(!ErrorLevel)
            {
                Process, Close, ThunderPlatform.exe
                if(ErrorLevel)
                {
                    TrayTip,Mogesoty,已为您关闭迅雷P2P上传,,1
                    LogToFile("Close Thunder P2P Process")
                }
            }
        }
    }
}

class Network
{
    __new()
    {
        IniRead,InternetStatus,Config.ini,NetworkDetector,InternetStatus,0
        IniRead,EthernetStatus,Config.ini,NetworkDetector,EthernetStatus,0
        IniRead,RunTimeStatus,Config.ini,NetworkDetector,RunTimeStatus,0
        IniRead,IdleStatus,Config.ini,NetworkDetector,IdleStatus,0
        Network.InternetStatusFlag:=InternetStatus
        Network.EthernetStatusFlag:=EthernetStatus
        Network.RunTimeStatusFlag:=RunTimeStatus
        Network.IdleStatusFlag:=IdleStatus
        BoundNetworkDetector:=Network.NetworkDetector.bind(NetworkDetector)
        SetTimer, %BoundNetworkDetector%, 3600000
        return this
    }
    
    NetworkDetector()
    {
        if(Network.InternetStatusFlag)
            Network.InternetStatus()
        if(Network.EthernetStatusFlag)
            Network.EthernetStatus()
        if(Network.RunTimeStatusFlag)
            Network.RunTimeStatus()
        if(Network.IdleStatusFlag)
            Network.IdleStatus()
        return
    }
    
    InternetStatus()
    {
        static failureCounter
        if DllCall("Wininet.dll\InternetCheckConnection","Str","http://119.75.218.77","Int",1,"Int",0)
        {
            failureCounter:=0
        }
        else
        {
            failureCounter:=failureCounter+1
            LogToFile("NetWork Interruption")
            TrayTip,Mogesoty,您的网络连接已中断,,2
        }
        if(failureCounter>=6)
        {
            Run shutdown -r -f -t 80,,Hide UseErrorLevel
            LogToFile("Reboot By NetWork Interruption")
            TrayTip,Mogesoty,您的网络出现问题，正在准备为您重启,,2
            Sleep 20000
            TrayTip,Mogesoty,您的网络出现问题，正在准备为您重启,,2
            Sleep 20000
            TrayTip,Mogesoty,您的网络出现问题，正在准备为您重启,,2
            Sleep 20000
            ExitApp
        }
        return
    }

    EthernetStatus()
    {
        if(InStr(StdOutStream("ping 172.23.20.1"),"100%"))
        {
            Run,Plugins\RouteHelper\RouteHelper.exe,,Hide UseErrorLevel
            LogToFile("Startup RouteHelper Successfully")
        }
        return
    }

    RunTimeStatus()
    {
        static overtimeCounter
        StartTime:=A_TickCount
        Loop,10000000
        {
            Random,rand,1,10
        }
        ElapsedTime:=A_TickCount-StartTime
        if(ElapsedTime<20000)
        {
            overtimeCounter:=0
        }
        else
        {
            overtimeCounter:=overtimeCounter+1
            LogToFile("Overtime Error")
            TrayTip,Mogesoty,计划任务超时,,2
        }
        if(overtimeCounter>=6)
        {
            Run shutdown -r -f -t 80,,Hide UseErrorLevel
            LogToFile("Reboot By Overtime Error")
            TrayTip,Mogesoty,计划任务超时，正在准备为您重启,,2
            Sleep 20000
            TrayTip,Mogesoty,计划任务超时，正在准备为您重启,,2
            Sleep 20000
            TrayTip,Mogesoty,计划任务超时，正在准备为您重启,,2
            Sleep 20000
            ExitApp
        }
        return
    }

    IdleStatus()
    {
        if(A_TimeIdlePhysical>300000000)
        {
            Run shutdown -r -f -t 80,,Hide UseErrorLevel
            LogToFile("Reboot By Time Idle Error")
            TrayTip,Mogesoty,您的电脑闲置时间过长，正在准备为您重启,,2
            Sleep 20000
            TrayTip,Mogesoty,您的电脑闲置时间过长，正在准备为您重启,,2
            Sleep 20000
            TrayTip,Mogesoty,您的电脑闲置时间过长，正在准备为您重启,,2
            Sleep 20000
            ExitApp
        }
        return
    }
}

class ReminderCheck
{
    __new()
    {
        MAINDIR:=ReminderCheck.GetMainDir()
        IniRead,Reminder,%MAINDIR%\Plugins\Reminder\Reminder.ini,Reminder,%A_MM%%A_DD%,0
        flag:=A_DetectHiddenWindows
        DetectHiddenWindows,On
        if(Reminder && !WinExist("TaskBarReminder.ahk") && SendMessage("RunPlugin" . "," . MainDir . "\Plugins\Reminder\TaskBarReminder.ahk", ASSEMBLYPRODUCT . "ahk_class AutoHotkey") = FAIL)
            LogToFile("Startup Reminder Failed")
        else if(!Reminder && WinExist("TaskBarReminder.ahk") && SendMessage("RunPlugin" . "," . MainDir . "\Plugins\Reminder\TaskBarReminder.ahk", ASSEMBLYPRODUCT . "ahk_class AutoHotkey") = FAIL)
            LogToFile("Exit Of Reminder Failed")
        DetectHiddenWindows,%flag%
        return this
    }

    GetMainDir()
    {
        SplitPath, A_ScriptDir, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        SplitPath, OutDir, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        return OutDir
    }
}
;</Scheduler>========================================================
