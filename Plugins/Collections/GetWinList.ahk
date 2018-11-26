WinGet, id, list,,, Program Manager

Loop, %id%
{
    this_id := id%A_Index%
    ;WinActivate, ahk_id %this_id%
    WinGetClass, this_class, ahk_id %this_id%
    WinGetTitle, this_title, ahk_id %this_id%
    s=%s%%a_index% of %id%`,ahk_id %this_id%`,ahk_class %this_class%`,%this_title%`n
    ;~ msg = Visiting All Windows`n%a_index% of %id%`nahk_id %this_id%`nahk_class %this_class%`n%this_title%`n`nContinue?
    ;~ MsgBox, 4, , %msg%
    ;~ IfMsgBox, NO, break
}
gui add, edit, +multi, %s%
gui show
return

GuiClose:
ExitApp