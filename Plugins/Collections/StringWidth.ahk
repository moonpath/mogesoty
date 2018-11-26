String := "泡沫 - G.E.M.邓紫棋    12312312"
Font := "Microsoft YaHei"
FontSize := 9

Width := StringWidth(String, Font, FontSize)
MsgBox % Width

Gui, New, +HwndtrailHwnd
Gui, font, s%FontSize%, %Font%
Gui, Add, Text, w%Width%, %String%
Gui, Show
WinSet, Transparent, 50, ahk_id %trailHwnd%


Esc::ExitApp

StringWidth(String, Font:="", FontSize:=10)
{
    Gui, StringWidth:Font, s%FontSize%, %Font%
    Gui, StringWidth:Add, Text, R1, %String%
    GuiControlGet, T, StringWidth:Pos, Static1
    Gui, StringWidth:Destroy
    return TW
}
