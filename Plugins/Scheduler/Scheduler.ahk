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
    IniRead,WindowRecorder,Config.ini,Monitor,WindowRecorder,0
    IniRead,ReminderEnabled,Config.ini,Monitor,ReminderEnabled,0
    if(WindowDetector="1")
        new Windows()

    if(NetworkDetector="1")
        new Network()
    return
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
