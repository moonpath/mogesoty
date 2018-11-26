#SingleInstance, force
#NoEnv

SetWorkingDir %A_ScriptDir%

Menu,Tray,Tip,Reminder
Menu,Tray,NoStandard
Menu,Tray,Add,Pin Widget,Pin
Menu,Tray,Add,Hide Widget,Hide
Menu,Tray,Add
Menu,Tray,Standard

If !pToken := Gdip_Startup()
{
    MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
    ExitApp
}
OnExit, Exit

ShowText("Hello, World!",(A_ScreenWidth-300)//2,(A_ScreenHeight-200)//2)
ChangeText()
SetTimer,ChangeText,60000
return

ShowText(text,x,y)
{
    global hwnd1
    Width := 300, Height := 200
    Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs +Hwndhwnd1
    Gui, 1: Show, NA
    hbm := CreateDIBSection(Width, Height)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    G := Gdip_GraphicsFromHDC(hdc)
    Gdip_SetSmoothingMode(G, 4)
    pBrush := Gdip_BrushCreateSolid(0xaa000000)
    Gdip_FillRoundedRectangle(G, pBrush, 0, 0, Width, Height, 20)
    Gdip_DeleteBrush(pBrush)
    Font = Arial
    If !Gdip_FontFamilyCreate(Font)
    {
        MsgBox, 48, Font error!, The font you have specified does not exist on the system
        ExitApp
    }
    Options = x10p y40p w80p Centre cbbffffff r4 s24
    Gdip_TextToGraphics(G, text, Options, Font, Width, Height)
    UpdateLayeredWindow(hwnd1, hdc, x, y, Width, Height)
    OnMessage(0x201, "WM_LBUTTONDOWN")
    OnMessage(0x18,"WM_SHOWWINDOW",-1)
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
    Return
}

ReshowText(text,x,y)
{
    global hwnd1
    Width := 300, Height := 200
    hbm := CreateDIBSection(Width, Height)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    G := Gdip_GraphicsFromHDC(hdc)
    Gdip_SetSmoothingMode(G, 4)
    pBrush := Gdip_BrushCreateSolid(0xaa000000)
    Gdip_FillRoundedRectangle(G, pBrush, 0, 0, Width, Height, 20)
    Gdip_DeleteBrush(pBrush)
    Font = Arial
    If !Gdip_FontFamilyCreate(Font)
    {
        MsgBox, 48, Font error!, The font you have specified does not exist on the system
        ExitApp
    }
    Options = x10p y40p w80p Centre cbbffffff r4 s24
    Gdip_TextToGraphics(G, text, Options, Font, Width, Height)
    UpdateLayeredWindow(hwnd1, hdc, x, y, Width, Height)
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
    Return
}

WM_LBUTTONDOWN()
{
    global
    PostMessage, 0xA1, 2
    WinGetPos, X, Y, Width, Height,% "ahk_id" . WinExist()
    return
}

WM_SHOWWINDOW(wParam, lParam, msg, hwnd)
{
    if(wParam)
        Menu,Tray,UnCheck,Hide Widget
    else
        Menu,Tray,Check,Hide Widget
    return
}

ReadText()
{
    allTextArray:=[]
    IniRead,text,Reminder.ini,Reminder,General,"Hello`, World!"
    text:=Trim(text)
    Loop, parse, text, CSV
        allTextArray.Push(A_LoopField)
    IniRead,text,Reminder.ini,Reminder,%A_MM%%A_DD%,0
    text?text:=Trim(text):text:=""
    Loop, parse, text, CSV
        allTextArray.Push(A_LoopField)
    return allTextArray
}

ChangeText()
{
    static preA_DD:="",allTextArray
    if(preA_DD!=A_DD)
    {
        allTextArray:=ReadText()
        preA_DD:=A_DD
    }
    WinGetPos, X, Y, Width, Height, % "ahk_id" . WinExist()
    Random, Index, 1, allTextArray.Length()
    ReshowText(allTextArray[Index],X,Y)
    return
}

Pin()
{
    global hwnd1
    static pinFlag:=false
    if(!pinFlag)
    {
        pinFlag := true
        WinSet,ExStyle,+0x00000020,ahk_id %hwnd1%
        WinSet,Bottom,,ahk_id %hwnd1%
        Menu,Tray,Check,Pin Widget
    }
    else
    {
        pinFlag := false
        WinSet,ExStyle,-0x00000020,ahk_id %hwnd1%
        WinSet,AlwaysOnTop,,ahk_id %hwnd1%
        Menu,Tray,UnCheck,Pin Widget
    }
    return
}

Hide()
{
    global hwnd1
    if(WinExist("ahk_id" . hwnd1))
        WinHide,% "ahk_id" . hwnd1
    else
        WinShow,% "ahk_id" . hwnd1
    return
}

Exit:
Gdip_Shutdown(pToken)
ExitApp
Return
