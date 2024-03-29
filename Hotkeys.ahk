﻿goto,HotkeysEnd ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;<Hotkey>===============================================================
Capslock & Space::
Hotkey_()
{
    if(GetKeyState("Shift", "P"))
        SendInput, ^{Space}
    else if(GetKeyState("Ctrl", "P"))
    {
        RegRead, status, HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\CHS, Enable Double Pinyin
        if (status = 0)
            RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\CHS, Enable Double Pinyin, 1
        else if (status = 1)
            RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\CHS, Enable Double Pinyin, 0
    }
    else
    {
        KeyWait, CapsLock
        KeyState := GetKeyState("CapsLock", "T")
        if (KeyState)
            SetCapsLockState, ALWAYSOFF
        else
            SetCapsLockState, ALWAYSON
    }
}

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
}

#!F2::
Hotkey_Alt_Win_F2(cmd:="")
{
    static status := true
    if(cmd = "")
        status := !status
        ;status?status:=false:status:=true
    else if(cmd = "On")
        status := true
    else
        status := false
    if(status)
        TrayTip,, Mouse Gestures Have Been Enabled,,1
    else
        TrayTip,, Mouse Gestures Have Been Suspended,,1
    Gesture.Toggle(status)
}

#!F3::
Hotkey_Alt_Win_F3()
{
    TrayMenu.Reload()
}

#!F4::
Hotkey_Alt_Win_F4()
{
    TrayMenu.Exit()
}

Capslock & `::
Hotkey_start()
{
    input, key, L1, {Enter}
    if(key = "1")
        Component.RunPlugin("KeyRecord\KeyRecord.ahk")
    else if(key = "2")
        Component.RunPlugin("Draw\Draw.ahk")
    else if(key = "3")
        Component.RunPlugin("Keypass\Keypass.ahk")
    else if(key = "4")
        Component.RunPlugin("HotStrings\HotStrings.ahk")
    else if(key = "5")
        Component.RunPlugin("WindowInfo\WindowInfo.ahk")
    else if(key = "6")
        Component.RunPlugin("Navigation\Navigation.ahk")
    else if(key = "s")
        Run, cmd.exe /c "shutdown /s /hybrid /t 0", , Hide UseErrorLevel
    else if(key = "r")
        Run, cmd.exe /c "shutdown /r /t 0", , Hide UseErrorLevel
    else if(key = "q")
        DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
    else if(key = "m")
    {
        BlockInput,On
        SendMessage, 0x112, 0xF170, 2,, Program Manager
        Sleep,2000
        BlockInput,Off
    }
    else
        SendInput,% key
}

Capslock & 8::
Hotkey_8()
{
    SendInput, {Raw}+
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
    SendInput, ^{Insert}
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
    WinGet,Hwnd,ID,A
    WinGet,processName,ProcessName,% "ahk_id" . Hwnd
    if(processName~="WindowsTerminal.exe|idea64.exe|pycharm64.exe|Tabby.exe|Xshell.exe")
    {
        SendInput, ^{Insert}
    }
    else
    {
        SendInput, ^c
    }
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
    if (FileExist(Clipboard))
    {
        SplitPath, Clipboard, OutFileName, OutDir
        Run, cmd /c gvim -M "%OutFileName%", %OutDir%, Hide UseErrorLevel
    }
}

Capslock & Esc::
Hotkey_quit()
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
    else
        Send !{F4}
}

Capslock & PgUp::
Hotkey_StringUpper()
{
    ClipSaved:=ClipBoardAll
    ClipBoard:=""
    SendInput, ^{Insert}
    ClipWait,0
    StringUpper,capital,ClipBoard
    ClipBoard:=capital
    SendInput, +{Insert}
    Sleep,200
    ClipBoard:=ClipSaved
    return
}

Capslock & PgDn::
Hotkey_StringLower()
{
    ClipSaved:=ClipBoardAll
    ClipBoard:=""
    SendInput, ^{Insert}
    ClipWait,0
    StringLower,lowercase,ClipBoard
    ClipBoard:=lowercase
    SendInput, +{Insert}
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
    SendInput, ^{Insert}
    ClipWait,0
    StringUpper,title,ClipBoard,T
    ClipBoard:=title
    SendInput, +{Insert}
    Sleep,200
    ClipBoard:=ClipSaved
    return
}

Capslock & f::
Hotkey_f()
{
    KeyWait, Capslock
    KeyWait, f
    input, cmd, L1, {Enter}
    fun := "Hotkey_" . "modify_" . cmd
    if(IsFunc(fun))
        %fun%()
}

Hotkey_modify_e()
{
    clip_saved := ClipboardAll
    clip_text_saved := Clipboard
    Clipboard := ""
    SendInput, ^{Insert}
    ClipWait, 0
    to_search := Clipboard
    Clipboard := clip_saved
    if(to_search == "" && clip_text_saved != "")
        to_search := clip_text_saved
    Run,% "http://dict.youdao.com/w/eng/" . ReplaceURL(to_search),,UseErrorLevel
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
    if(GetKeyState("Shift", "P"))
        SendInput, {Home}
    else
        SendInput, {Left}
}

Capslock & i::
Hotkey_i()
{
    SendInput, |
}

Capslock & j::
Hotkey_capslock_j()
{
    if(GetKeyState("Shift", "P"))
        SendInput, {PgDn}
    else
        SendInput, {Down}
}

Capslock & k::
Hotkey_capslock_k()
{
    if(GetKeyState("Shift", "P"))
        SendInput, {PgUp}
    else
        SendInput, {Up}
}

Capslock & l::
Hotkey_capslock_l()
{
    if(GetKeyState("Shift", "P"))
        SendInput, {End}
    else
        SendInput, {Right}
}

Capslock & m::
Hotkey_m()
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

Capslock & n::
Hotkey_notepad()
{
    SendInput, ^{Insert}
    if(GetKeyState("Shift", "P"))
    {
        RegRead, OneNote, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\OneNote.exe
        Run,% OneNote . " /sidenote /paste",,UseErrorLevel
    }
    else
    {
        Run NotePad,,UseErrorLevel
        Sleep, 300
        SendInput, +{Insert}
    }
}

Capslock & Up::
Hotkey_sound_up()
{
    SoundSet +2
}

Capslock & Down::
Hotkey_sound_down()
{
    SoundSet -2
}

Capslock & Left::
Hotkey_media_left()
{
    SendInput,{Media_Prev}
}

Capslock & Right::
Hotkey_media_right()
{
    SendInput,{Media_Next}
}

Capslock & Tab::
Hotkey_media_play_pause()
{
    SendInput, {Media_Play_Pause}
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
    clip_saved := ClipboardAll
    clip_text_saved := Clipboard
    Clipboard := ""
    SendInput, ^{Insert}
    ClipWait, 0
    to_search := Clipboard
    Clipboard := clip_saved
    if(to_search == "" && clip_text_saved != "")
        to_search := clip_text_saved
    Run,% "https://plat-emrui-o.api.leiniao.com/gateway/cluster-topo/sparkhistory/history/" . to_search,,UseErrorLevel
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
    clip_saved := ClipboardAll
    clip_text_saved := Clipboard
    Clipboard := ""
    SendInput, ^{Insert}
    ClipWait, 0
    to_search := Clipboard
    Clipboard := clip_saved
    if(to_search == "" && clip_text_saved != "")
        to_search := clip_text_saved
    if(Gesture.SearchEngine == 1)
        Run,% "www.bing.com/search?&q=" . ReplaceURL(to_search),,UseErrorLevel
    else if(Gesture.SearchEngine == 2)
        Run,% "www.baidu.com/s?ie=utf-8&wd=" . ReplaceURL(to_search),,UseErrorLevel
    else
        Run,% "www.google.com/search?q=" . ReplaceURL(to_search),,UseErrorLevel
}

;CapsLock & WheelUp::
;Hotkey_ShiftWheelUp()
;{
;    Loop,2
;        SendInput,{PgUp}
;    return
;}

;CapsLock & WheelDown::
;Hotkey_ShiftWheelDown()
;{
;    Loop,2
;        SendInput,{PgDn}
;    return
;}

Capslock & t::
Hotkey_t()
{
    Run, powershell.exe /c "cd $ENV:USERPROFILE;"%A_ScriptDir%\Plugins\Busybox\busybox64.exe" "sh"", , UseErrorLevel
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
    WinGet,Hwnd,ID,A
    WinGet,processName,ProcessName,% "ahk_id" . Hwnd
    if(processName~="WindowsTerminal.exe|idea64.exe|pycharm64.exe|Tabby.exe|Xshell.exe")
    {
        SendInput, +{Insert}
    }
    else
    {
        SendInput, ^v
    }
}

Capslock & x::
Hotkey_x()
{
    ;Component.RunPlugin("Screenshot\Screenshot.exe")
    ;Run, Screenshot\Screenshot.exe,,UseErrorLevel
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

;~Lshift & Rshift::
;~Rshift & Lshift::
;Hotkey_typing()
;{
;    SendInput, ^{Space}
;}

F1 & h::
F1 & Left::
hotkey_mouse_left()
{
    hotkey_mouse("L")
}

F1 & l::
F1 & Right::
hotkey_mouse_right()
{
    hotkey_mouse("R")
}

F1 & j::
F1 & Down::
hotkey_mouse_down()
{
    hotkey_mouse("D")
}

F1 & k::
F1 & Up::
hotkey_mouse_up()
{
    hotkey_mouse("U")
}

F1 & p::
hotkey_mouse_wheelup()
{
    Click WheelUp
}

F1 & n::
hotkey_mouse_wheeldown()
{
    Click WheelDown
}

F1 & F4::
hotkey_mouse_middle()
{
    Click Middle
}

F1 & i::
F1 & F2::
hotkey_mouse_lbutton_down()
{
    Click Left Down
}

F1 & i Up::
F1 & F2 Up::
hotkey_mouse_lbutton_up()
{
    Click Left Up
}

F1 & o::
F1 & F3::
hotkey_mouse_rbutton_donw()
{
    Click Right Down
}

F1 & o Up::
F1 & F3 Up::
hotkey_mouse_rbutton_up()
{
    Click Right Up
}

F1 & Esc::
hotkey_mouse_caret()
{
    MouseMove, % A_CaretX, % A_CaretY
}

~ESC::
Hotkey_esc()
{
    SetCapsLockState, OFF
    SetCapsLockState, AlwaysOFF
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
