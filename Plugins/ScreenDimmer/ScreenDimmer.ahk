#NoEnv
#Warn
#SingleInstance, Force
#MaxHotkeysPerInterval, 200
SendMode, Input
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1

SetMenu()

BarOptionsMaster := "1: B1 ZH20 CW000000 ZX8 ZY4 WM200 FM9 W300 CBFFFFFF CTFFFFFF" . "X" . (A_ScreenWidth - 300) / 2 . "Y" . (A_ScreenHeight - 20) / 2

Step = 2.56

ShowBars(br := SetBrightness(128))

OnExit("Recover")

^Down::
Darken()
{
    global br, Step
    ShowBars(br := SetBrightness(br - Step))
    return
}

^Up::
Brighten()
{
    global br, Step
    ShowBars(br := SetBrightness(br + Step))
    return
}

SetBrightness(br)
{
    if (br > 256)
        br := 256
    else if (br < 0)
        br := 0
    VarSetCapacity(gr, 512*3)
    Loop, 256
    {
        if ((nValue := (br + 128) * (A_Index - 1)) > 65535)
            nValue := 65535
        NumPut(nValue, gr, 2*(A_Index-1), "Ushort")
        NumPut(nValue, gr, 512+2*(A_Index-1), "Ushort")
        NumPut(nValue, gr, 1024+2*(A_Index-1), "Ushort")
    }
    hDC := DllCall("GetDC", "Uint", 0) ;NULL for entire screen
    DllCall("SetDeviceGammaRamp", "Uint", hDC, "Uint", &gr)
    DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)
    return br
}

ShowBars(br)
{
    global BarOptionsMaster

    Master := br / 2.56
    vbr := Round(100 * br / 256, 0)

    Text := "Brightness: " . vbr . "%"

    IfWinNotExist, Screen Dimmer
    {
        Progress, %BarOptionsMaster%, , %Text%, Screen Dimmer, Microsoft YaHei
        WinSet, Transparent, 180, Screen Dimmer
    }

    Progress, 1: %Master%, , %Text%
    Hotkey, WheelUp, Brighten, On
    Hotkey, WheelDown, Darken, On
    SetTimer, BarOff, 2000
    return
}

BarOff()
{
    SetTimer, BarOff, Off
    Hotkey, WheelUp, Brighten, Off
    Hotkey, WheelDown, Darken, Off
    Progress, 1: Off
    return
}

Recover()
{
    SetBrightness(128)
    return
}

SetMenu()
{
    Menu, Tray, Tip, Screen Dimmer
    Menu, Tray, Icon, Shell32.dll,175
    Menu, Tray, UseErrorLevel
    Menu, Tray, NoStandard
    Menu, Tray, Add, Screen Dimmer, TrayMenu
    Menu, Tray, Default, Screen Dimmer
    Menu, Tray, Click, 1
    Menu, Tray, Add
    AddAdjustMenu()
    Menu, Tray, Add, Help, TrayMenu
    Menu, Tray, Add, About, TrayMenu
    Menu, Tray, Add, Exit, TrayMenu
}

AddAdjustMenu()
{
    while(A_Index <= 11)
        Menu, Adjust, Add,% (A_Index - 1) * 10 . "%", AdjustMenu
    Menu, Tray, Add, Adjust, :Adjust
}

TrayMenu()
{
    if (A_ThisMenuItem = "Exit")
        ExitApp
    else if (A_ThisMenuItem = "Help")
        MsgBox, 64, Screen Dimmer, Use "Ctrl+Up" or "Ctrl+Down" `nto adjust screen brightness.
    else if (A_ThisMenuItem = "About")
        MsgBox,64, Screen Dimmer,% "Created on Sept 11, 2017`nScreen Dimmer 1.0.0.0`nCopyright © 2017 A.H. Zhang"
    else if (A_ThisMenuItem = "Screen Dimmer")
    {
        global br
        ShowBars(br := SetBrightness(br))
    }
}

AdjustMenu()
{
    global br
    ShowBars(br := SetBrightness(SubStr(A_ThisMenuItem, 1, StrLen(A_ThisMenuItem) - 1) * 2.56))
}
