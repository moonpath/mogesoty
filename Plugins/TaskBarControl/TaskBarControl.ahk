;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                                                                              =
;Created on Jun 3, 2017                                                        =
;TaskBarControl 1.1.2.5                                                        =
;Copyright © 2017 A.H. Zhang                                                   =
;                                                                              =
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;<Initialization>===============================================================
#NoTrayIcon
#Persistent
#SingleInstance, Off
ErrorLevel := []
Loop, %0%
    ErrorLevel.Push(%A_Index%)
(TaskBarControl := {Base: TaskBarControl}.__new(%False%, ErrorLevel*)).main()
;</Initialization>==============================================================

;<Class>========================================================================
class TaskBarControl
{
    __new(ByRef argc := "", ByRef argv*)
    {
        ;Menu, Tray, Icon, Res.dll, 2
        ;Menu, Tray, Tip, TaskBarControl
        DetectHiddenWindows, On
        this.argc := argc, this.argv := argv
        OnExit(this.Recovery.bind(this), -1)
        return this
    }
    
    main()
    {
        WinGetTitle, ScriptTitle,% "ahk_id" . A_ScriptHwnd
        WinGet, TitleList, List,% ScriptTitle
        CloudMusicFlag := WinExist("ahk_class OrpheusBrowserHost ahk_exe cloudmusic.exe")
        if(this.argc && (TitleList != 1 || !CloudMusicFlag))
            for argv_i, argv_v in this.argv
            {
                if(argv_v = "/next")
                    SendInput, {Media_Next}
                if(argv_v = "/prev")
                    SendInput, {Media_Prev}
                if(argv_v = "/play_pause")
                    SendInput, {Media_Play_Pause}
            }
        if(TitleList == 1 && CloudMusicFlag)
        {
            BoundSetText := this.SetText.bind(this)
            SetTimer,% BoundSetText, 100
            VarSetCapacity(this.argc, 0), VarSetCapacity(this.argv, 0), VarSetCapacity(ScriptTitle, 0), VarSetCapacity(TitleList, 0), VarSetCapacity(BoundSetText, 0)
        }
        else
            ExitApp, -1
        return
    }
    
    SetText()
    {
        if(Hwnd := WinExist("ahk_class OrpheusBrowserHost ahk_exe cloudmusic.exe"))
        {
            WinGetTitle, WinTitle,% "ahk_id" . Hwnd
            ControlGetText, StaticText, Static1, ahk_class Shell_TrayWnd
            if(StaticText != (WinTitle := SubStr(RegExReplace(WinTitle, "\s+", " "), 1, 64)))
                ControlSetText, Static1,% WinTitle, ahk_class Shell_TrayWnd
        }
        else
            ExitApp, 0
        return
    }
    
    Recovery(ExitReason, ExitCode)
    {
        if(ExitCode != -1)
        {
            ControlGetText, ButtonText, Button1, ahk_class Shell_TrayWnd
            ControlGetText, StaticText, Static1, ahk_class Shell_TrayWnd
            if(ButtonText != StaticText)
                ControlSetText, Static1,% ButtonText, ahk_class Shell_TrayWnd
        }
        return
    }
}
;</Class>=======================================================================
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
