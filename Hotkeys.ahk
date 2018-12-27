goto,HotkeysEnd ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;<Hotkey>===============================================================
#!F1::
Hotkey_Alt_Win_F1()
{
    Suspend
    if(A_IsSuspended)
    {
        Menu,Tray,Check,Suspend
        TrayTip,,The Program Has Been Suspended,,1
    }
    else
    {
        Menu,Tray,UnCheck,Suspend
        TrayTip,,The Program Has Been Enabled,,1
    }
    return
}

#!F2::
Hotkey_Alt_Win_F2()
{
    TrayMenu.Pause()
    return
}

#!F3::
Hotkey_Alt_Win_F3()
{
    TrayMenu.Reload()
    return
}

#!F4::
Hotkey_Alt_Win_F4()
{
    TrayMenu.Exit()
    return
}

#!F5::
Hotkey_Alt_Win_F5(command:="")
{
    static status:=true
    if(!command)
    {
        Hotkey, Rbutton, Toggle, UseErrorLevel
        status?status:=false:status:=true
    }
    else if(command="On")
    {
        Hotkey, Rbutton, On, UseErrorLevel
        status:=true
    }
    else
    {
        Hotkey, Rbutton, Off, UseErrorLevel
        status:=false
    }
    if(status)
        TrayTip,,Mouse Gestures Have Been Enabled,,1
    else
        TrayTip,,Mouse Gestures Have Been Suspended,,1
    return
}

#!F6::
Hotkey_Alt_Win_F6()
{
    if(Gesture.trailEnabled)
    {
        Gesture.trailEnabled:=false
        Gesture.trail.StopTrail()
        Gesture.trail.Hide()
        TrayTip,,Trail unenabled,,1
    }
    else
    {
        Gesture.trailEnabled:=true
        TrayTip,,Trail enabled,,1
    }
    return
}

Capslock & `::
Hotkey_screen()
{
    BlockInput,On
    SendMessage, 0x112, 0xF170, 2,, Program Manager
    Sleep,2000
    BlockInput,Off
    return
}

Capslock & 1::
Hotkey_1()
{
    Component.RunPlugin("KeyRecord\KeyRecord.ahk")
    return
}

Capslock & 2::
Hotkey_2()
{
    Component.RunPlugin("Draw\Draw.ahk")
    return
}

Capslock & 3::
Hotkey_3()
{
    Component.RunPlugin("Keypass\Keypass.ahk")
    return
}

Capslock & 4::
Hotkey_4()
{
    Component.RunPlugin("HotStrings\HotStrings.ahk")
    return
}

Capslock & 5::
Hotkey_5()
{
    Component.RunPlugin("WindowInfo\WindowInfo.ahk")
    return
}

Capslock & 6::
Hotkey_6()
{
    Component.RunPlugin("Navigation\Navigation.ahk")
    return
}

Capslock & 9::
Hotkey_9()
{
    if(GetKeyState("Shift", "P"))
        SendInput, {Raw}{
    else
        SendInput, [
}

Capslock & 0::
Hotkey_0()
{
    if(GetKeyState("Shift", "P"))
        SendInput, {Raw}}
    else
        SendInput, ]
}

Capslock & a::
Hotkey_a()
{
    Static flag := 0
    if(flag==0)
    {
        flag:=1
        MCA := new MCA()
    }
    MCA.show()
}

Capslock & b::
Hotkey_b()
{
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

Capslock & c::
Hotkey_c()
{
    WinGet,PID,PID,A
    WinGet,ProcessName,ProcessName,ahk_pid %PID%
    if(ProcessName="Explorer.EXE")
    {
        ClipSaved := ClipBoardAll
        ClipBoard:=""
        Send ^c
        ClipWait,0
        clipboard=%clipboard%
        if(!FileExist(clipboard))
        {
            ClipBoard:=ClipSaved
            return
        }
    }
    else
    {
        WinGet,ProcessPath,ProcessPath,ahk_pid %PID%
        clipboard=%ProcessPath%
    }
    Main.Notification.Notify("Address Copied")
    return
}

Capslock & d::
Hotkey_d()
{
    WinGet,Hwnd,ID,A
    WinGet,processName,ProcessName,% "ahk_id" . Hwnd
    WinGet,processPath,ProcessPath,% "ahk_id" . Hwnd
    Run,Explorer /select`,%processPath%,,UseErrorLevel,OutputVarPID
    /*
    if(processName!="explorer.exe")
    {
        WinGet,processPath,ProcessPath,% "ahk_id" . Hwnd
        Run,Explorer /select`,%processPath%,,UseErrorLevel,OutputVarPID
    }
    else if(SelectedFile:=WindowsExplorer.WindowsExplorerGetSelectedItemPath(Hwnd))
    {
        SplitPath,SelectedFile,OutFileName,OutDir,OutExtension
        if(OutExtension="lnk")
            FileGetShortcut,% SelectedFile,SelectedFile
        Run,Explorer /select`,%SelectedFile%,,UseErrorLevel,OutputVarPID
    }
    */
    return
}

Capslock & e::
Hotkey_e()
{
    if(GetKeyState("Shift", "P") || GetKeyState("Alt", "P"))
    {
        WinGet,PID,PID,A
        WinGet,ProcessName,ProcessName,ahk_pid %PID%
        Process,Close,%PID%
        if(ErrorLevel==0)
        {
            Main.LogToFile("Kill " . ProcessName . " Failed")
            TrayTip,,Process Termination Failed,,3
            return
        }
    }
}

Capslock & PgUp::
Hotkey_StringUpper()
{
    ClipSaved:=ClipBoardAll
    ClipBoard:=""
    SendInput,^c
    ClipWait,0
    StringUpper,capital,ClipBoard
    ClipBoard:=capital
    SendInput,^v
    Sleep,200
    ClipBoard:=ClipSaved
    return
}

Capslock & PgDn::
Hotkey_StringLower()
{
    ClipSaved:=ClipBoardAll
    ClipBoard:=""
    SendInput,^c
    ClipWait,0
    StringLower,lowercase,ClipBoard
    ClipBoard:=lowercase
    SendInput,^v
    Sleep,200
    ClipBoard:=ClipSaved
    return
}

Capslock & Home::
Capslock & End::
Hotkey_StringTitle()
{
    ClipSaved:=ClipBoardAll
    ClipBoard:=""
    SendInput,^c
    ClipWait,0
    StringUpper,title,ClipBoard,T
    ClipBoard:=title
    SendInput,^v
    Sleep,200
    ClipBoard:=ClipSaved
    return
}

+^f::
Capslock & f::
Hotkey_f()
{
    ControlGetFocus, FocusedControl, A
    if(InStr(FileExist(path := WindowsExplorer.WindowsExplorerLocation()), "D")&&!InStr(FocusedControl,"Edit"))
    {

        WinGetClass, activeClass, A
        if(activeClass~="Progman|WorkerW")
        {
            ControlGet, NameList, List, Col1, SysListView321, A
            NameWithoutPath:="New File"
            while(true)
            {
                flag:=true
                index:=A_Index
                Loop, Parse, NameList, `n
                    if(InStr(A_LoopField,NameWithoutPath))
                    {
                        NameWithoutPath:="New File (" . (index + 1) . ")"
                        flag:=false
                        break
                    }
                if(flag)
                    break
            }
            blankFileName:=path . "\" . NameWithoutPath
            FileAppend,,% blankFileName
        }
        else
        {
            blankFileName:=path . "\New File"
            while(FileExist(blankFileName))
                blankFileName:=path . "\New File (" . (A_Index + 1) . ")"
            FileAppend,,% blankFileName
        }
        SplitPath, blankFileName, FileNameWithoutPath
        WindowsExplorer.WindowsExplorerSelectItem(FileNameWithoutPath)
        Loop, 20
        {
            Sleep, 100
            SendInput, {F2}
            ControlGetFocus, focus
        }Until, focus = "Edit1"
    }
    return
}

Capslock & g::
Hotkey_g(Count := 1)
{
    static key:=new Press_Hotkey_Templet(400)
    key.Trigger(Count)
    return
}

Capslock & h::
Hotkey_capslock_h()
{
    if(GetKeyState("Shift", "P") || GetKeyState("Alt", "P"))
        SendInput, {Home}
    else
        SendInput,{Left}
}

Capslock & i::
Hotkey_i()
{
    SendInput, |
}

Capslock & j::
Hotkey_capslock_j()
{
    if(GetKeyState("Shift", "P") || GetKeyState("Alt", "P"))
        SendInput, {PgDn}
    else
        SendInput, {Down}
}

Capslock & k::
Hotkey_capslock_k()
{
    if(GetKeyState("Shift", "P") || GetKeyState("Alt", "P"))
        SendInput, {PgUp}
    else
        SendInput, {Up}
}

Capslock & l::
Hotkey_capslock_l()
{
    if(GetKeyState("Shift", "P") || GetKeyState("Alt", "P"))
        SendInput, {End}
    else
        SendInput, {Right}
}

Capslock & Left::
Hotkey_Left()
{
    SendInput,{Media_Prev}
}

Capslock & Right::
Hotkey_Right()
{
    SendInput,{Media_Next}
}

Capslock & Up::
Hotkey_Up()
{
    SoundSet +2
}

Capslock & Down::
Hotkey_Down()
{
    SoundSet -2
}

Capslock & m::
Hotkey_m()
{
    SendInput, {Raw}+
}

Capslock & Esc::
Hotkey_media_play_pause()
{
    SendInput,{Media_Play_Pause}
}

Capslock & o::
Hotkey_o()
{
    SendInput, =
}

Capslock & p::
Hotkey_p()
{
    clipboard := RTrim(RTrim(clipboard, "`n"), "`r")
    SendInput, +{Insert}
    return
}

Capslock & q::
Hotkey_q()
{
    Send !{F4}
    return
}

Capslock & r::
Hotkey_r()
{
    if(GetKeyState("Shift", "P") || GetKeyState("Alt", "P"))
    {
        WinGet,PID,PID,A
        WinGet,ProcessPath,ProcessPath,ahk_pid %PID%
        WinGet,ProcessName,ProcessName,ahk_pid %PID%
        Process,Close,%PID%
        Loop,10
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
    }
}

Capslock & s::
Hotkey_s()
{
    ClipBoard:=""
    Send ^c
    ClipWait,0
    if(Gesture.SearchEngine == 1)
        Run,% "www.bing.com/search?&q=" . ReplaceURL(clipboard),,UseErrorLevel
    else if(Gesture.SearchEngine==2)
        Run,% "www.baidu.com/s?ie=utf-8&wd=" . ReplaceURL(clipboard),,UseErrorLevel
    else
        Run,% "www.google.com/search?q=" . ReplaceURL(clipboard),,UseErrorLevel
    return
}

CapsLock & WheelUp::
Hotkey_ShiftWheelUp()
{
    Loop,2
        SendInput,{PgUp}
    return
}

CapsLock & WheelDown::
Hotkey_ShiftWheelDown()
{
    Loop,2
        SendInput,{PgDn}
    return
}

Capslock & T::
Hotkey_t()
{
    Run, %comspec% /c "title BusyBox & cd /d "`%USERPROFILE`%" & "%A_ScriptDir%\Plugins\Busybox\busybox64.exe" "sh"", , UseErrorLevel
}


Capslock & u::
Hotkey_u()
{
    KeyWait, Capslock
    KeyWait, u
    ToolTip, Receiving...,,,2
    input, unicode, L4, {Space}
    unicode := Trim(unicode)
    if(unicode != "")
    {
        ToolTip, Applied, , ,2
        SendInput, {U+%unicode%}
        Sleep, 500
        ToolTip, , , ,2
    }
    else
    {
        ToolTip, Error, , ,2
        Sleep, 500
        ToolTip, , , ,2
    }
    return
}

Capslock & v::
Hotkey_v()
{
    Run,Plugins\View\i_view64.exe /clippaste /silent,,UseErrorLevel
    return
}

Capslock & x::
Hotkey_x()
{
    Component.RunPlugin("Screenshot\Screenshot.exe")
    return
}

Capslock & y::
Hotkey_y()
{
    SendInput, ^{Insert}
    return
}

Capslock & [::
Hotkey_fun()
{
    KeyWait,Capslock
    KeyWait, [
    ToolTip,Receiving...,,,2
    input,funWithParams,T10,{Enter}
    funWithParams:=Trim(funWithParams)
    if(funWithParams=""||"Hotkey_" . funWithParams=A_ThisFunc)
    {
        ToolTip,Error,,,2
        Sleep,500
        ToolTip,,,,2
        return
    }
    paramsArray:=[]
    Loop, parse, funWithParams, CSV
        if(A_Index=1)
            funName:=A_LoopField
        else
            paramsArray.Push(A_LoopField)
    if(IsFunc("MouseGesture_" . funName)&&Asc(funName)>=65&&Asc(funName)<=90)
    {
        ToolTip,Applied,,,2
        MouseGesture_%funName%(paramsArray*)
        Sleep,500
        ToolTip,,,,2
    }
    else if(IsFunc("Hotkey_" . funName))
    {
        ToolTip,Apply,,,2
        Hotkey_%funName%(paramsArray*)
        Sleep,500
        ToolTip,,,,2
    }
    else if(IsFunc(funName))
    {
        ToolTip,Apply,,,2
        %funName%(paramsArray*)
        Sleep,500
        ToolTip,,,,2
    }
    else
    {
        ToolTip,Error,,,2
        Sleep,500
        ToolTip,,,,2
    }
    return
}

Capslock & ,::
Hotkey_del_left()
{
    SendInput, {Left}{Delete}
    return
}

Capslock & .::
Hotkey_del_right()
{
    SendInput, {Delete}
    return
}

Capslock & /::
Hotkey_back_slash()
{
    SendInput, \
    return
}

~Lshift & Rshift::
~Rshift & Lshift::
Capslock & `;::
Hotkey_typing()
{
    SendInput, ^{Space}
}

~ESC::
Hotkey_esc()
{
    SetCapsLockState, OFF
    SetCapsLockState, AlwaysOFF
    return
}

F1 & h::
Hotkey_F1_h()
{
    SendInput, -
    return
}

F1 & j::
Hotkey_F1_j()
{
    SendInput, _
    return
}

F1 & k::
Hotkey_F1_k()
{
    SendInput, =
    return
}

F1 & l::
Hotkey_F1_l()
{
    SendInput, {Raw}+
    return
}

F8::Ctrl

Capslock & F8::
Hotkey_F8_Compendation()
{
    SendInput, {F8}
}
;</Hotkey>==============================================================
HotkeysEnd:
