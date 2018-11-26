#NoEnv
#NoTrayIcon
#SingleInstance, Force

CoordMode, ToolTip, Screen

TOOLTIPHEADER := "F1: Copy, F2: View, Esc: Exit"
;SEPARATOR := "┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈"
SEPARATOR := "-----------------------------------------"
textLen := 16

SysGet, monitorCount, MonitorCount
Loop, %monitorCount%
{
    SysGet, monitorSize%A_Index%, Monitor,%A_Index%
    SysGet, MonitorWorkArea%A_Index%, MonitorWorkArea, %A_Index%
}

SetTimer, WindowInfo, 40
Return

a::Clipboard := mousePosScreenX . ", " . mousePosScreenY
b::Clipboard := mousePosWindowX . ", " . mousePosWindowY
c::Clipboard := mousePosClientX . ", " . mousePosClientY
d::Clipboard := colorHex
e::Clipboard := colorRed . ", " . colorGreen . ", " . colorBlue
f::Clipboard := controlClassNN
g::Clipboard := winX . ", " . winY
h::Clipboard := winW . ", " . winH
i::Clipboard := winClientW . ", " . winClientH
j::Clipboard := winTitle
k::Clipboard := winClass
l::Clipboard := processName
m::Clipboard := path
n::Clipboard := winText
F1::
{
    fullInfo := "[Mouse]`n"
                . "(a) Absolute:`t" . mousePosScreenX . ", " . mousePosScreenY . "`n"
                . "(b) Relative:`t" . mousePosWindowX . ", " . mousePosWindowY . "`n"
                . "(c) Client:`t" . mousePosClientX . ", " . mousePosClientY . "`n"
                . "[Control]`n"
                . "(d) Color:`t" . StrReplace(colorHex, "0x") . "`n"
                . "(e) RGB:`t" . colorRed . ", " . colorGreen . ", " . colorBlue . "`n"
                . "(f) ClassNN:`t" . controlClassNN . "`n"
                . "[Window]`n"
                . "(g) Position:`t" . winX . ", " . winY . "`n"
                . "(h) Size:`t" . winW . ", " . winH . "`n"
                . "(i) Client:`t" . winClientW . ", " . winClientH . "`n"
                . "(j) Title:`t" . winTitle . "`n"
                . "(k) Class:`t" . winClass . "`n"
                . "(l) Process:`t" . processName . "`n"
                . "(m) Path:`t" . path . "`n"
                . "(n) Text:`t" . winText . "`n"

    Clipboard := fullInfo
    return
}
F2::textLen != 16 ? textLen := 16 : textLen := 128
Esc::ExitApp

WindowInfo()
{
    global
    static toolTipHwnd := 0, priorX := 0, priorY := 0, priorTextLen := 0
    CoordMode, Mouse, Screen
    MouseGetPos, mousePosScreenX, mousePosScreenY, winID
    if(priorX = mousePosScreenX && priorY = mousePosScreenY && priorTextLen = textLen && winClass != "")
        return
    else if(priorX = mousePosScreenX && priorY = mousePosScreenY && priorTextLen!= textLen)
        priorTextLen := textLen
    else
        priorX := mousePosScreenX, priorY := mousePosScreenY, priorTextLen := textLen := 16

    CoordMode, Mouse, Window
    MouseGetPos, mousePosWindowX, mousePosWindowY
    CoordMode, Mouse, Client
    MouseGetPos, mousePosClientX, mousePosClientY

    if(winID != toolTipHwnd)
    {
        CoordMode, Pixel, Screen
        PixelGetColor, colorHex, %mousePosScreenX%, %mousePosScreenY%, RGB
        colorRed := (colorHex & 0xFF0000) >> 16
        colorGreen := (colorHex & 0x00FF00) >> 8
        colorBlue := colorHex & 0x0000FF
        MouseGetPos,,,,controlClassNN

        WinGetPos, winX, winY, winW, winH, ahk_id %winID%
        VarSetCapacity(rect, 16)
        DllCall("GetClientRect", "ptr", winID, "ptr", &rect)
        winClientW := NumGet(rect, 8, "int")
        winClientH := NumGet(rect, 12, "int")
        WinGetClass, winClass, ahk_id %winID%
        WinGetTitle, winTitle, ahk_id %winID%
        WinGet, processPath, ProcessPath, ahk_id %winID%
        SplitPath, processPath, processName, path
        WinGetText, winText, ahk_id %winID%
    }
    else
    {
        colorHex :=""
        colorRed := "", colorGreen := "", colorBlue := ""
        controlClassNN := ""
        winX := "", winY := ""
        winW := "", winH := ""
        winClientW := "", winClientH := ""
        winTitle := ""
        winClass := ""
        processName := ""
        path := ""
        winText := ""
    }

    info := "[Mouse]`n"
                . "(a) Absolute:`t" . mousePosScreenX . ", " . mousePosScreenY . "`n"
                . "(b) Relative:`t" . mousePosWindowX . ", " . mousePosWindowY . "`n"
                . "(c) Client:`t" . mousePosClientX . ", " . mousePosClientY . "`n"
                . SEPARATOR . "`n"
                . "[Control]`n"
                . "(d) Color:`t" . StrReplace(colorHex, "0x") . "`n"
                . "(e) RGB:`t`t" . colorRed . ", " . colorGreen . ", " . colorBlue . "`n"
                . "(f) ClassNN:`t" . GetSubStr(controlClassNN, textLen) . "`n"
                . SEPARATOR . "`n"
                . "[Window]`n"
                . "(g) Position:`t" . winX . ", " . winY . "`n"
                . "(h) Size:`t`t" . winW . ", " . winH . "`n"
                . "(i) Client:`t" . winClientW . ", " . winClientH . "`n"
                . "(j) Title:`t`t" . GetSubStr(winTitle, textLen) . "`n"
                . "(k) Class:`t" . GetSubStr(winClass, textLen) . "`n"
                . "(l) Process:`t" . GetSubStr(processName, textLen) . "`n"
                . "(m) Path:`t" . GetSubStr(path, textLen) . "`n"
                . "(n) Text:`t`t" . GetSubStr(RegExReplace(SubStr(winText, 1, textLen), "\s+", " "), textLen) . "`n"
                . SEPARATOR . "`n"

    Loop, %monitorCount%
    {
        if(mousePosScreenX >= monitorSize%A_Index%Left && mousePosScreenX <= monitorSize%A_Index%Right && mousePosScreenY >= monitorSize%A_Index%Top && mousePosScreenY <= monitorSize%A_Index%Bottom)
        {
            mouseIndex := A_Index
            break
        }
    }

    if(!toolTipHwnd)
    {
        if(mousePosScreenY + 300 + 15 > MonitorWorkArea%mouseIndex%Bottom)
            toolTipPosY := mousePosScreenY - 300
        else
            toolTipPosY := mousePosScreenY + 15
        ToolTip,% A_space,,toolTipPosY
        WinGet, toolTipHwnd, ID, ahk_class tooltips_class32
        ;DllCall("SendMessage", "ptr", toolTipHwnd, "uint", 0x30, "ptr", 0, "ptr", 0)
        ToolTip,% info . TOOLTIPHEADER,, toolTipPosY
        WinGetPos, toolTipX, toolTipY, toolTipWidth, toolTipHeight,ahk_id %toolTipHwnd%
    }
    else
    {
        if(mousePosScreenX < MonitorWorkArea%mouseIndex%Left)
            toolTipPosX := MonitorWorkArea%mouseIndex%Left
        else if(mousePosScreenX > MonitorWorkArea%mouseIndex%Right)
            toolTipPosX := MonitorWorkArea%mouseIndex%Right - toolTipWidth - 1
        else if(mousePosScreenX + toolTipWidth + 15 >= MonitorWorkArea%mouseIndex%Right)
            toolTipPosX := mousePosScreenX - toolTipWidth - 5
        else
            toolTipPosX := mousePosScreenX + 15

        if(mousePosScreenY < MonitorWorkArea%mouseIndex%Top)
            toolTipPosY := MonitorWorkArea%mouseIndex%Top
        else if(mousePosScreenY > MonitorWorkArea%mouseIndex%Bottom)
            toolTipPosY := MonitorWorkArea%mouseIndex%Bottom - toolTipHeight - 1
        else if(mousePosScreenY + toolTipHeight + 15 >= MonitorWorkArea%mouseIndex%Bottom)
            toolTipPosY := mousePosScreenY - toolTipHeight - 5
        else
            toolTipPosY := mousePosScreenY + 15

        ToolTip,% info . TOOLTIPHEADER, toolTipPosX, toolTipPosY
    }
    return
}

GetSubStr(text, textLen)
{
    num := 0, subStr := ""
    Loop, Parse, text
    {
        if(Asc(A_LoopField) >= 128)
            num += 2
        else
            num ++
        if(num < textLen)
            subStr .= A_LoopField
        else
            break
    }
    return subStr
}
