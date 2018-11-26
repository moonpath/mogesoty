Gui, +LastFound

Gui, Show, [color=red]w250 h375[/color], Test

VarSetCapacity( rect, 16, 0 )

DllCall("GetClientRect", uint, MyGuiHWND := WinExist(), uint, &rect )

ClientW := NumGet( rect, 8, "int" )

ClientH := NumGet( rect, 12, "int" )

WinGetPos,,, Wid, Hei

Msgbox Your gui's client area is %ClientW% by %ClientH%`nbut the whole window is actually %Wid% by %Hei%