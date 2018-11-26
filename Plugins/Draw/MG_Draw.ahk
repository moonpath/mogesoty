MG_InitTrail()

MButton::
{
    CoordMode, Mouse, Screen
    MouseGetPos, MG_TX, MG_TY
    MG_StartTrail()
    return
}

MButton Up::
{
    MG_StopTrail()
    return
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;    Gesture Trail Usage
; Start By MG_StartTrail()
; Stop By MG_StopTrail()
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

MG_StartTrail()
{
    global
    if (MG_ShowTrail)
    {
        CoordMode, Mouse, Screen
        MouseGetPos, MG_TX, MG_TY
        MG_X:=MG_TX
        MG_Y:=MG_TY
        SetTimer, MG_DrawTrail, %MG_TrailInterval%
    }
}

MG_StopTrail()
{
    global
    if (MG_ShowTrail)
    {
        SetTimer, MG_DrawTrail, Off
        MG_ClearTrail()
    }
}

MG_InitTrail()
{
    global
    
    MG_ShowTrail=1
    MG_DrawTrailWnd=1
    MG_TrailColor=884898   
    MG_TrailTranspcy=255
    MG_TrailWidth=4
    MG_TrailStartMove=3
    MG_TrailInterval=10

    MG_TrailDrawn := 0
    MG_TrailColor2 := MG_ConvertHex(MG_TrailColor)
    MG_TrailTransClr := (MG_TrailColor!="FF00FF") ? "FF00FF" : "FE00FE"
    MG_TrailTransClr2 := MG_ConvertHex(MG_TrailTransClr)
    if (MG_DrawTrailWnd)
    {
        local x, y, width, height
        SysGet, x,        76
        SysGet, y,        77
        SysGet, width,  78
        SysGet, height, 79
        Gui, MGW_Trail:New
        Gui, MGW_Trail:+HwndMG_TrailHwnd -Caption +ToolWindow +AlwaysOnTop +LastFound
        Gui, MGW_Trail:Color, %MG_TrailTransClr%
        local trans := ""
        if (0<MG_TrailTranspcy && MG_TrailTranspcy<255) 
        {
            trans := " " . MG_TrailTranspcy
        }
        WinSet, TransColor, %MG_TrailTransClr%%trans%
        Gui, MGW_Trail:Show, x%x% y%y% w%width% h%height% NA
    }
}

MG_DrawTrail()
{
    global
    static fCritical := 0
    if (!MG_ShowTrail || fCritical) 
    {
        return
    }
    fCritical := 1
    local curX, curY
    CoordMode, Mouse, Screen
    MouseGetPos, curX, curY
    if (!MG_TrailDrawn &&    ((MG_X-curX)**2+(MG_Y-curY)**2 < MG_TrailStartMove**2))
    {
        fCritical := 0
        return
    }
    MG_TrailDrawn = 1
    local x1:=MG_TX, y1:=MG_TY, x2:=curX, y2:=curY
    if (MG_DrawTrailWnd)
    {
        Gui, MGW_Trail:+LastFound
        WinGetPos, left, top
        x1-=left, x2-=left, y1-=top, y2-=top
    }
    local hWnd := MG_DrawTrailWnd ? MG_TrailHwnd : 0
    local hDC := DllCall("GetWindowDC", "Ptr",hWnd, "Ptr")
    local hPen := DllCall("CreatePen", "Ptr",0, "Ptr",MG_TrailWidth, "Int",MG_TrailColor2)
    local hPenOld := DllCall("SelectObject", "Ptr",hDC, "Ptr",hPen, "Ptr")
    DllCall("MoveToEx", "Ptr",hDC, "Ptr",x1, "Ptr",y1, "Ptr",0)
    DllCall("LineTo", "Ptr",hDC, "Ptr",x2, "Ptr",y2)
    DllCall("SelectObject", "Ptr",hDC, "Ptr",hPenOld)
    DllCall("DeleteObject", "Ptr",hPen)
    DllCall("ReleaseDC", "Ptr",hWnd, "Ptr",hDC)
    MG_TX:=curX, MG_TY:=curY
    if (!MG_DrawTrailWnd)
    {
        if (MG_TL > curX) 
        {
            MG_TL := curX
        }
        if (MG_TR < curX) 
        {
            MG_TR := curX
        }
        if (MG_TT > curY) 
        {
            MG_TT := curY
        }
        if (MG_TB < curY) 
        {
            MG_TB := curY
        }
    }
    fCritical := 0
}

MG_ClearTrail()
{
    global
    if (!MG_ShowTrail || !MG_TrailDrawn)
    {
        return
    }
    local rc
    VarSetCapacity(rc, 16, 0)
    if (MG_DrawTrailWnd)
    {
        local width, height
        Gui, MGW_Trail:+LastFound
        WinGetPos, , , width, height
        NumPut(width,  rc,  8, "UInt")
        NumPut(height, rc, 12, "UInt")
        local hDC := DllCall("GetWindowDC", "Ptr",MG_TrailHwnd, "Ptr")
        local hBrush := DllCall("CreateSolidBrush", "UInt",MG_TrailTransClr2, "Ptr")
        DllCall("FillRect", "Ptr",hDC, "Ptr",&rc, "Ptr",hBrush)
        DllCall("DeleteObject", "Ptr",hBrush)
        DllCall("ReleaseDC", "Ptr",MG_TrailHwnd, "Ptr",hDC)
    }
    else
    {
        NumPut(MG_TL-MG_TrailWidth-1, rc,  0, "UInt")
        NumPut(MG_TT-MG_TrailWidth-1, rc,  4, "UInt")
        NumPut(MG_TR+MG_TrailWidth+1, rc,  8, "UInt")
        NumPut(MG_TB+MG_TrailWidth+1, rc, 12, "UInt")
        DllCall("RedrawWindow", "Ptr",0, "Ptr",&rc, "Ptr",0, "Ptr",0x0587)
    }
    MG_TrailDrawn = 0
}

MG_ConvertHex(hex)
{
    return RegExReplace(hex,"([a-zA-Z0-9][a-zA-Z0-9])([a-zA-Z0-9][a-zA-Z0-9])([a-zA-Z0-9][a-zA-Z0-9])","0x$3$2$1")
}
