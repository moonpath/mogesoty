times := 5
Size := 80, Color := "Gray"    ; settings
CoordMode, mouse, screen
Gui, -Caption +ToolWindow +AlwaysOnTop +LastFound
Gui, Color, %Color%
GuiHwnd := WinExist()
DetectHiddenWindows, On
transparent := 180
WinSet, Transparent, 180, ahk_id %GuiHwnd%
WinSet, Region, % "0-0 W" Size " H" Size " E", ahk_id %GuiHwnd%  ; An ellipse instead of a rectangle.
WinSet, ExStyle, +0x20, ahk_id %GuiHwnd%    ; set click through style
Gui, Show, w%Size% h%Size% hide
SetTimer,ShowMouse,500
Return

ShowMouse:
{
    CoordMode, mouse, screen
    MouseGetPos, MouseX, MouseY
    posX := Round(MouseX - Size/2), posY := Round(MouseY - Size/2)
    if(transparent = 180)
    {
        transparent := 0
    }
    else
        transparent := 180
    WinSet, Transparent, %transparent%, ahk_id %GuiHwnd%
    Gui, Show, x%posX% y%posY% NA
    if(times--<0)
    {
        ExitApp
    }
    Return
}

#F4::ExitApp