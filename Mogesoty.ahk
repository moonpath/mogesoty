;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                                                                      =
;Created on Oct 28, 2016                                               =
;Mogesoty 3.16.7116.0                                                  =
;Copyright © 2016 A.H. Zhang                                           =
;                                                                      =
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;<Initialization>=======================================================
#NoEnv
#Warn
#Persistent
#SingleInstance,Force

SetWorkingDir,%A_ScriptDir%
DetectHiddenWindows,On
SendMode,Input
Process,Priority,,AboveNormal
;Critical
;SetBatchLines,-1
;SetWinDelay,100
;SetTitleMatchMode,2

ErrorLevel:=[]
Loop,%0%
    ErrorLevel.Push(%A_Index%)
(Main := {Base: Main}.__new(%False%, ErrorLevel*)).Load()
return
;</Initialization>======================================================

;<Library>==============================================================
Lib:
#include %A_ScriptDir%\Functions.ahk
#include %A_ScriptDir%\MouseGestures.ahk
#include %A_ScriptDir%\Hotkeys.ahk
return
;</Library>=============================================================

;<Class>================================================================
class Main
{
    __new(ByRef argc := "", ByRef argv*)
    {
        Menu,Tray,Icon,Shell32.dll,174
        Menu,Tray,Tip,% this.ASSEMBLYPRODUCT
        
        this.config := {}
        IniRead, SectionNames, Config.ini
        for i, name in StrSplit(SectionNames, "`n")
        {
            this.config[name] := {}
            IniRead, Section, Config.ini, % name
            for j, item in StrSplit(Section, "`n")
            {
                element := StrSplit(item, "=")
                this.config[name][element[1]] := element[2]
            }
        }

        if(!A_IsAdmin && this.config["Config"]["runAsAdmin"])
        {
            Run,*RunAs "%A_ScriptFullPath%",% A_ScriptDir,UseErrorLevel
            ExitApp
        }

        while(WinExist(this.ASSEMBLYPRODUCT))
        {
            SendMessage,0x02,0,0,,% this.ASSEMBLYPRODUCT
            Sleep,1000
            if(A_Index>3)
            {
                WinGet, ScriptsList, List, % "ahk_exe" . this.ASSEMBLYTITLE . ".exe"
                Loop,%ScriptsList%
                {
                    currentID:=ScriptsList%A_Index%
                    WinGet, currentPID, PID, ahk_id %currentID%
                    if(currentPID!=DllCall("GetCurrentProcessId") && currentPID)
                        Run,TaskKill /F /PID %currentPID%,,Hide UseErrorLevel
                }
            }
        }

        WinSetTitle,% "ahk_id" . A_ScriptHwnd,,% this.ASSEMBLYPRODUCT
        WinSet,Style,-0x10000,% "ahk_id" . A_ScriptHwnd
        WinSet,Style,-0x40000,% "ahk_id" . A_ScriptHwnd
        WinMove,% "ahk_id" . A_ScriptHwnd,,% (A_ScreenWidth-round(A_ScreenWidth*5/8))/2,% (A_ScreenHeight-round(A_ScreenHeight*2/3))/2,% round(A_ScreenWidth*5/8),% round(A_ScreenHeight*2/3)

        this.argc:=argc,this.argv:=argv

        Keys := this.config["Key"]["Keys"]
        this.KeyList:=[]
        Loop, parse, Keys, CSV
            this.KeyList.Push(A_LoopField)

        if(this.config["Config"]["runtimeLog"])
            FileAppend,==========%A_UserName%@%A_ComputerName%==========%A_OSType%_%A_OSVersion%==========`n,Runtime.log

        return this
    }

    Load()
    {
        OnMessage(0x4A,this.ReceiveMessage.bind(this),5)
        OnExit(this.Recovery.bind(this),1)

        Component:=new Component(this.config["Boot"]["bootDir"])
        Gesture:=new Gesture(this.config["Trail"]["trailEnabled"],this.config["Trail"]["trailColor"],this.config["Trail"]["trailWidth"],"Lbutton","Capslock")
        Hotkey:=new Hotkey(this.KeyList*)
        this.Notification := new this.Notification()
        Gosub,Lib

        TrayMenu:=new TrayMenu()

        this.ShowLogo()

        return
    }

    ShowLogo()
    {
        if(this.argc)
            for argv_i,argv_v in this.argv
                if(argv_v="/invisible")
                    return
        Run,% A_WorkingDir . "\Logo.ahk",% A_WorkingDir,UseErrorLevel
        Sleep,2000
        TrayTip, ,% this.ASSEMBLYTITLE . " Has Started",,1
        return
    }
    
    class Notification
    {
        __new(Font:="Verdana", FontSize:=11, Width:=300, Color := "Black", Transparent:=220)
        {
            this.Font := Font
            this.FontSize := FontSize
            this.Width := Width
            this.Color := Color
            this.Transparent := Transparent
            return this
        }

        Notify(text)
        {
            Font := this.Font
            FontSize := this.FontSize
            Width := this.Width
            Color := this.Color
            Transparent := this.Transparent
            Gui,tip: Destroy
            text := "`n" . text . "`n"
            SysGet, WorkArea, MonitorWorkArea
            Gui,tip: New, -Caption +AlwaysOnTop +HwndtipHwnd +ToolWindow +Border +LastFound
            Gui,tip: Margin, , 0
            Gui,tip: Color,% Color
            Gui,tip: +LastFound
            WinSet, Transparent, 0
            Gui,tip: Font, s%FontSize% bold,% Font
            Gui,tip: Add, Text, cWhite gGuiDestroy W%Width%,% text
            GuiControlGet, TextSize, tip:Pos, Static1
            Xpos := WorkAreaRight - Width - 18
            Ypos := WorkAreaBottom - TextSizeH - 2 - 12
            Gui,tip: Show, X%Xpos% Y%Ypos% W%Width% NA
            SoundPlay, *-1
            BoundFade := this.Fade.bind(this,tipHwnd,Transparent)
            SetTimer,% BoundFade, -1
            return
            GuiDestroy:
            Gui,tip: Destroy
            return
        }

        Fade(Hwnd, Transparent)
        {
            diff := 0
            while(diff < Transparent)
            {
                Gui,tip: +LastFound
                WinSet, Transparent,% diff
                diff += 3
                Sleep, 10
            }
            Sleep, 3000
            MouseGetPos, , , OutputVarWin
            while(diff > 0)
            {
                MouseGetPos, , , HoveredWin
                if(Hwnd == HoveredWin)
                    diff := Transparent
                Gui,tip: +LastFound
                WinSet, Transparent,% diff
                diff -= 3
                Sleep, 10
            }
            Gui,tip: Destroy
            return
        }
    }
    
    LogToFile(ByRef event)
    {
        if(this.config["Config"]["runtimeLog"])
            FileAppend,%A_YYYY%/%A_MM%/%A_DD% %A_Hour%:%A_Min%:%A_Sec%.%A_MSec%----%event%`n,Runtime.log
        FileGetSize, LogSize, Runtime.log, M
        if(LogSize > 512 && LogSize < 1024)
            TrayTip, ,Log File Size Overrun, ,2
        else if(LogSize > 1024)
            FileDelete, Runtime.log
        return
    }

    RecognizeMessage(ByRef Command)
    {
        CommandList := []
        Parameters := []
        Loop, parse, Command, CSV
            CommandList.Push(A_LoopField)
        if(CommandList.Length())
        {
            Function := CommandList[1]
            for i,j in CommandList
            {
                if(i = 1)
                    continue
                Parameters.Push(j)
            }
            if(Function="LogToFile")
                this.LogToFile(Parameters*)
            else if(Function="RunPlugin")
                Component.RunPlugin(Parameters*)
            else
                %Function%(Parameters*)
        }
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

    ReceiveMessage(wParam, lParam)
    {
        StringAddress := NumGet(lParam + 2*A_PtrSize)
        CopyOfData := StrGet(StringAddress)
        this.RecognizeMessage(CopyOfData)
        return true
    }

    Recovery()
    {
        this.LogToFile("Exit By " . A_ExitReason)
;        ExitApp
    }

    ASSEMBLYTITLE[]
    {
        get
        {
            return "Mogesoty"
        }
    }

    ASSEMBLYPRODUCT[]
    {
        get
        {
            return "Mogesoty 3.16"
        }
    }

    ASSEMBLYVERSION[]
    {
        get
        {
            return "3.16.7116.0"
        }
    }
}

class Hotkey
{
    __new(keyList*)
    {
        SetCapsLockState,ALWAYSOFF
        BoundMask := this.Mask.bind(this)
        BoundUnMask := this.UnMask.bind(this)
        BoundKeyRecognition:= this.KeyRecognition.bind(this)
        BoundKeyCompensation := this.KeyCompensation.bind(this)
        ;Hotkey, !Capslock,% BoundUnMask
        Hotkey, Capslock & Space,% BoundUnMask
        for i,v in keyList
        {
            Hotkey, %v%,% BoundMask
            Hotkey, Capslock & %v%,% BoundKeyRecognition
            Hotkey, $*%v%,% BoundKeyCompensation
        }
        return this
    }

    Mask()
    {
        return
    }
    
    UnMask()
    {
        KeyState := GetKeyState("CapsLock", "T")
        if (KeyState)
            SetCapsLockState, ALWAYSOFF
        else
            SetCapsLockState, ALWAYSON
        return
    }

    KeyRecognition()
    {
        key := StrSplit(A_ThisHotkey, " ")[3]
        SendInput, {%key%}
        return
    }

    KeyCompensation()
    {
        ctrl_state := GetKeyState("ctrl", "P")
        alt_state := GetKeyState("alt", "P")
        shift_state := GetKeyState("shift", "P")
        win_state := GetKeyState("lwin", "P") || GetKeyState("rwin", "P")
        key_list := ""
        if (ctrl_state)
            key_list .= "^"
        if (alt_state)
            key_list .= "!"
        if (shift_state)
            key_list .= "+"
        if (win_state)
            key_list .= "#"
        key_list .= "{" . SubStr(A_ThisHotKey,3) . "}"
        SendInput,% key_list
        return
    }
}

class Gesture
{
    __new(trailEnabled:=false,trailColor:=0x800080,trailWidth:=4,additionalKey*)
    {
        this.trailEnabled:=trailEnabled
        trailEnabled?this.trail:=new this.Draw(trailColor,trailWidth):false
        this.additionalKey:=additionalKey
        this.BoundRecognition:=this.Recognition.bind(this)
        MouseGesture:=this.Start.bind(this)
        Hotkey,Rbutton,%MouseGesture%
        return this
    }

    Start()
    {
        this.track:=""
        BoundRecognition:=this.BoundRecognition
        prevCoordModeMouse:=A_CoordModeMouse
        CoordMode,Mouse,Screen
        MouseGetPos,xpos1,ypos1,hoveredHwnd,classNN
        CoordMode,Mouse,% prevCoordModeMouse
        this.gestureParams:=["ahk_id" . hoveredHwnd,classNN,xpos1,ypos1]
        this.xpos1:=xpos1,this.ypos1:=ypos1
        SetTimer,% BoundRecognition,1
        if(this.trailEnabled)
            this.trail.StartTrail()
        return
    }

    Recognition()
    {
        ListLines,Off
        BoundRecognition:=this.BoundRecognition
        if(!GetKeyState("Rbutton","P"))
        {
            for index,key in this.additionalKey
                if(GetKeyState(key,"P"))
                {
                    this.track:=this.track . index
                    break
                }
            track:=this.track
            SetTimer,% BoundRecognition,Delete
            if(this.trailEnabled)
            {
                this.trail.StopTrail()
                Sleep,0
            }
            if(!track&&!IsFunc("MouseGesture_"))
                SendInput,{Rbutton}
            else
                MouseGesture_%track%(this.gestureParams*)
        }
        else
        {
            CoordMode,Mouse,Screen
            MouseGetPos,xpos2,ypos2
            newTrack:=(abs(this.ypos1-ypos2)>=abs(this.xpos1-xpos2))?(this.ypos1>ypos2?"U":"D"):(this.xpos1>xpos2?"L":"R")
            if(newTrack!=SubStr(this.track,0,1))&&(abs(this.ypos1-ypos2)>12||abs(this.xpos1-xpos2)>12)
                this.track.=newTrack
            this.xpos1:=xpos2
            this.ypos1:=ypos2
        }
        return
    }

    class Draw
    {
        __New(trailColor:=0x800080,trailWidth:=4)
        {
            static index:=0
            Gui,% (this.index := index := Mod(index++, 8) + 1) . ":New", +HwndtrailHwnd -Caption -MinimizeBox -SysMenu +Owner +ToolWindow +Disabled +AlwaysOnTop +LastFound, Palette
            Gui,% this.index . ":Color", 008080
            this.trailHwnd := trailHwnd
            BoundDrawLine := this.DrawLine.bind(this)
            this.BoundDrawLine := BoundDrawLine
            this.trailColor := trailColor
            this.trailWidth := trailWidth
            WinSet, TransColor, 008080, ahk_id %trailHwnd%
            WinSet, ExStyle, +0x00000020, ahk_id %trailHwnd%
            return this
        }

        Hide()
        {
            Gui,% this.index . ":Cancel"
            return
        }

        Delete()
        {
            Gui,% this.index . ":Destroy"
            return
        }

        StartTrail()
        {
            prevCoordModeMouse := A_CoordModeMouse
            CoordMode, Mouse, Screen
            MouseGetPos, pre_x, pre_y
            CoordMode, Mouse,% prevCoordModeMouse
            this.pre_x := pre_x, this.pre_y := pre_y
            Gui,% this.index . ":+AlwaysOnTop"
            SysGet, SM_XVIRTUALSCREEN, 76
            SysGet, SM_YVIRTUALSCREEN, 77
            SysGet, SM_CXVIRTUALSCREEN, 78
            SysGet, SM_CYVIRTUALSCREEN, 79
            this.SM_XVIRTUALSCREEN := SM_XVIRTUALSCREEN
            this.SM_YVIRTUALSCREEN := SM_YVIRTUALSCREEN
            Gui,% this.index . ":Show", x%SM_XVIRTUALSCREEN% y%SM_YVIRTUALSCREEN% w%SM_CXVIRTUALSCREEN% h%SM_CYVIRTUALSCREEN% NA
            BoundDrawLine := this.BoundDrawLine
            SetTimer, %BoundDrawLine%, 10
            return
        }

        StopTrail()
        {
            BoundDrawLine := this.BoundDrawLine
            SetTimer, %BoundDrawLine%, Delete
            trailHWnd := this.trailHWnd
            WinSet, Redraw,, ahk_id %trailHWnd%
            return
        }

        DrawLine()
        {
            ListLines, Off
            Critical
            if(!GetKeyState("Rbutton","P"))
                this.StopTrail()
            else
            {
                CoordMode, Mouse, Screen
                MouseGetPos, cur_x, cur_y
                if((this.pre_x-cur_x)**2+(this.pre_y-cur_y)**2 > 2**2)
                {
                    hDC := DllCall("GetDC", UInt, this.trailHWnd)
                    hCurrPen := DllCall("CreatePen", UInt, 0, UInt, this.trailWidth, UInt, this.trailcolor)
                    DllCall("SelectObject", UInt, hDC, UInt, hCurrPen)
                    DllCall("MoveToEx", UInt, hDc, Uint, this.pre_x-this.SM_XVIRTUALSCREEN, Uint, this.pre_y-this.SM_YVIRTUALSCREEN, Uint, 0)
                    DllCall("LineTo", UInt, hDc, Uint, cur_x-this.SM_XVIRTUALSCREEN, Uint, cur_y-this.SM_YVIRTUALSCREEN)
                    DllCall("ReleaseDC", UInt, 0, UInt, hDC)
                    DllCall("DeleteObject", UInt, hCurrPen)
                    this.pre_x := cur_x
                    this.pre_y := cur_y
                }
            }
            return
        }
        
        GetColor()
        {
            Random, Red, 0, 255
            Random, Green, 0, 255
            Random, Blue, 0, 255

            oldIntFormat := A_FormatInteger

            SetFormat, IntegerFast, hex

            RGB := SubStr(Red & 255, 3) . SubStr(Green & 255, 3) . SubStr(Blue & 255, 3)

            SetFormat, IntegerFast, %oldIntFormat%
            
            return "0x" . RGB
        }
    }
}

class Component
{
    __new(bootDir:="Boot")
    {
        this.processList:={}
        this.pluginsDir:=A_workingdir . "\Plugins"
        this.BoundRunPlugin:=this.RunPlugin.bind(this)
        Menu,Boot,Add,Running Processes:,Component.__new
        Menu,Boot,Disable,Running Processes:
        Menu,Tray,Add,Boot,:Boot
        this.AddComponentsToMenu(this.pluginsDir)
        Loop, Parse, bootDir, CSV
        if(FileExist(this.pluginsDir . "\" . A_LoopField)="D")
            Loop,% this.pluginsDir . "\" . A_LoopField . "\*", 0, 0
                this.RunPlugin(A_LoopFileLongPath)
        else if(FileExist(this.pluginsDir . "\" . A_LoopField))
            this.RunPlugin(this.pluginsDir . "\" . A_LoopField)
        CheckProcess:=this.CheckProcess.bind(this)
        SetTimer,%CheckProcess%,1000
        OnExit(this.Recovery.bind(this),-1)
        return this
    }

    AddComponentsToMenu(dir,level="3")
    {
        static maxLevel:=0
        flag:=0,flags:=0
        maxLevel<level?maxLevel:=level:false
        if(level<=0)
            return false
        Loop,%dir%\*,1,0
        {
            flag:=this.AddComponentsToMenu(A_LoopFileLongPath,level-1)
            if(flag || A_LoopFileExt="exe" || A_LoopFileExt="lnk" || A_LoopFileExt="ahk")
            {
                BoundRunPlugin:=this.BoundRunPlugin
                if(InStr(A_LoopFileAttrib,"D"))
                    Menu,%A_LoopFileDir%,Add,%A_LoopFileName%,:%A_LoopFileLongPath%
                else
                    Menu,%A_LoopFileDir%,Add,%A_LoopFileName%,%BoundRunPlugin%
                flag:=1
            }
            flags:=(flags)?1:flag
        }
        if(level=maxLevel)
        {
            SplitPath, dir, , , , menuName
            if(!MenuGetHandle(dir))
            {
                Menu,% dir,Add,None,Component.AddComponentsToMenu
                Menu,% dir,disable,None
            }
            Menu,Tray,Add,%menuName%, :%dir%
            return true
        }
        return flags
    }

    RunPlugin(target:="",flag:="1",thisMenu:="")
    {
        if(target=A_ThisMenuItem && thisMenu="Boot")
            target:=A_ThisMenuItem
        else if(target=A_ThisMenuItem)
            target:=thisMenu . "\" . target
        else if(!InStr(target,":"))
            target:=this.pluginsDir . "\" . target
        SplitPath, target, OutFileName, OutDir, , OutNameNoExt
        if(this.processList.HasKey(target))
        {
            processID:=this.processList[target]
            this.processList.Delete(target)
            SendMessage,0x10,0,0,,% "ahk_pid" . processID
            SendMessage,0x02,0,0,,% "ahk_pid" . processID
            SendMessage,0x11,0,0,,% "ahk_pid" . processID
            SendMessage(0x12, "ahk_pid" . processID)
            Sleep 500
            Run,TaskKill /F /PID %processID%,,Hide UseErrorLevel
            Sleep 500
            if(!WinExist("ahk_pid" . processID))
            {
                Menu,%OutDir%,Uncheck,%OutFileName%
                Menu,Boot,Delete,%target%
                Main.LogToFile("Exit Of " . OutNameNoExt . " Successfully")
            }
            else
            {
                this.processList[target]:=processID
                Main.LogToFile("Exit Of " . OutNameNoExt . " Failed")
                TrayTip, ,Exit Of %OutNameNoExt% Failed,,3
            }
        }
        else
        {
            Run % target,% OutDir,UseErrorLevel,processID
            if(!ErrorLevel)
            {
                BoundRunPlugin:=this.BoundRunPlugin
                this.processList[target]:=processID
                Menu,%OutDir%,Check,%OutFileName%
                Menu,Boot,Add,%target%,%BoundRunPlugin%
                Menu,Boot,Check,%target%
                Main.LogToFile("Startup " . OutNameNoExt . " Successfully")
            }
            else
            {
                Main.LogToFile("Startup " . OutNameNoExt . " Failed")
                TrayTip, ,Startup %OutNameNoExt% Failed,,3
            }
        }
        return
    }

    CheckProcess()
    {
        ListLines,Off
        for item,processID in this.processList
        {
            if(!WinExist("ahk_pid" . processID))
            {
                SplitPath, item, OutFileName, OutDir, , OutNameNoExt
                this.processList.Delete(item)
                Menu,%OutDir%,Uncheck,%OutFileName%
                Menu, Boot, Delete, %item%
                Main.LogToFile("Exit Of " . OutNameNoExt . " By External Events")
            }
        }
        return
    }

    Recovery()
    {
        for item,processID in this.processList
        {
            SendMessage,0x10,0,0,,% "ahk_pid" . processID
            SendMessage,0x02,0,0,,% "ahk_pid" . processID
            SendMessage,0x11,0,0,,% "ahk_pid" . processID
            Main.SendMessage(0x12, "ahk_pid" . processID)
            Sleep,100
            Run,TaskKill /F /PID %processID%,,Hide UseErrorLevel
            Sleep,100
        }
        for item,processID in this.processList
        {
            SplitPath, item, OutFileName, OutDir, , OutNameNoExt
            if(!WinExist("ahk_pid" . processID))
                Main.LogToFile("Exit Of " . OutNameNoExt . " Successfully")
            else
                Main.LogToFile("Exit Of " . OutNameNoExt . " Failed")
        }
        return
    }
}

class TrayMenu
{
    __new()
    {
        OpenMainWindow:=this.OpenMainWindow.bind(this)
        WindowSpy:=this.WindowSpy.bind(this)
        Edit:=this.Edit.bind(this)
        Reload:=this.Reload.bind(this)
        Pause:=this.Pause.bind(this)
        Suspend:=this.Suspend.bind(this)
        Help:=this.Help.bind(this)
        ReadMe:=this.ReadMe.bind(this)
        Exit:=this.Exit.bind(this)

        OnMessage(0x111,this.WM_COMMAND.bind(this),-1)
        OnMessage(0x18,this.WM_SHOWWINDOW.bind(this),1)

        Menu,Tray,UseErrorLevel
        Menu,Tray,NoStandard

        Menu,Tray,Insert,1&,% Main.ASSEMBLYPRODUCT,%OpenMainWindow%
        Menu,Tray,Default,% Main.ASSEMBLYPRODUCT
        Menu,Tray,Insert,2&
        if(DllCall("GetMenuItemCount", "ptr", MenuGetHandle("Tray"))>2)
            Menu, Tray, Add
        Menu, Tray, Add, Window Spy, % WindowSpy
        Menu, Tray, Add
        Menu, Tray, Add, Edit, % Edit
        Menu, Tray, Add, Reload, % Reload
        Menu, Tray, Add, Pause, % Pause
        Menu, Tray, Add, Suspend, % Suspend
        Menu, Tray, Add
        Menu, Tray, Add, Help, % Help
        Menu, Tray, Add, About, % ReadMe
        Menu, Tray, Add
        Menu, Tray, Add, Exit, % Exit
        return this
    }

    WM_COMMAND(wParam, lParam, msg, hwnd)
    {
        ListLines,Off
        if(wParam=65400)
            this.Reload()
        else if(wParam=65403)
        {
            if(!A_IsPaused)
            {
                Menu,Tray,Check,Pause
                Hotkey,Rbutton,Off,UseErrorLevel
                TrayTip, ,The Program Has Been Paused,,1
            }
            else
            {
                Menu,Tray,UnCheck,Pause
                Hotkey,Rbutton,On,UseErrorLevel
                TrayTip, ,The Program Has Been Unpaused,,1
            }
        }
        else if(wParam=65404)
        {
            if(!A_IsSuspended)
            {
                Menu,Tray,Check,Suspend
                TrayTip, ,The Program Has Been Suspended,,1
            }
            else
            {
                Menu,Tray,UnCheck,Suspend
                TrayTip, ,The Program Has Been Enabled,,1
            }
        }
        return
    }

    WM_SHOWWINDOW(wParam, lParam, msg, hwnd)
    {
        ListLines,Off
        if(wParam && hwnd=A_ScriptHwnd)
            WinRestore,% "ahk_id" . A_ScriptHwnd
        return
    }

    OpenMainWindow()
    {
        ListLines,Off
        ListLines
        return
    }

    Reload()
    {
        WinHide,% "ahk_id" . A_ScriptHwnd
        WinSetTitle,% "ahk_id" . A_ScriptHwnd,,% A_ScriptFullPath . " - AutoHotkey v" . A_AhkVersion
        TrayTip, ,The Program Will Be Reload,,2
        Sleep,1000
        Reload
        Sleep 5000
        MsgBox,36,% Main.ASSEMBLYTITLE,The Script Could Not Be Reloaded`, Would You Like To Open It For Editing?
        IfMsgBox,Yes,Edit
        return
    }

    Edit()
    {
        Edit
        return
    }

    Suspend()
    {
        Suspend
        if(A_IsSuspended)
        {
            Menu,Tray,Check,Suspend
            TrayTip, ,The Program Has Been Suspended,,1
        }
        else
        {
            Menu,Tray,UnCheck,Suspend
            TrayTip, ,The Program Has Been Enabled,,1
        }
        return
    }

    Pause()
    {
        Pause,Toggle,1
        if(A_IsPaused)
        {
            Menu,Tray,Check,Pause
            Hotkey, Rbutton, Off, UseErrorLevel
            TrayTip, ,The Program Has Been Paused,,1
        }
        else
        {
            Menu,Tray,UnCheck,Pause
            Hotkey, Rbutton, On, UseErrorLevel
            TrayTip, ,The Program Has Been Unpaused,,1
        }
        return
    }

    WindowSpy()
    {
        Run,% A_workingdir . "\AU3_Spy.exe",% A_workingdir,UserErrorLevel
        return
    }

    Help()
    {
        Run,% A_workingdir . "\Doc\AutoHotkey.chm",% A_workingdir,UserErrorLevel
        return
    }

    ReadMe()
    {
        MsgBox,64,% Main.ASSEMBLYTITLE,% "Created on Oct 28, 2016`n" . Main.ASSEMBLYTITLE . A_Space . Main.ASSEMBLYVERSION . "`nCopyright © 2016 A.H. Zhang"
        return
    }

    Exit()
    {
        ExitApp
        return
    }
}
;</Class>===============================================================
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
