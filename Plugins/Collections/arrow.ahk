#NoEnv

#SingleInstance, Force

SendMode Input

SetWorkingDir %A_ScriptDir%



Gui, Add, Edit, x6 y7 w100 h20 vEdit1, Edit1

Gui, Add, Edit, x6 y37 w100 h20 vEdit2, Edit2

Gui, Add, Edit, x6 y67 w100 h20 vEdit3, Edit3

Gui, Add, Button, x116 y7 w100 h20 vButton1, Button1

Gui, Add, Button, x116 y37 w100 h20 vButton2, Button2

Gui, Add, Button, x116 y67 w100 h20 vButton3, Button3

; Generated using SmartGUI Creator 4.0

Gui, Show, w234 h101, Untitled GUI

SetTimer, Check, 100

Return



Check:

GuiControlGet, bb, FocusV

Tooltip, %bb%

return



#IfWinActive, Untitled GUI

+Up::		;Navigate among edit fields

GuiControlGet, out, FocusV

StringRight, aa, out, 1

aa--

if aa < 1

aa = 3		; Set to last number of edit fields

GuiControl, Focus, Edit%aa%

return



+Down::

GuiControlGet, out, FocusV

StringRight, aa, out, 1

aa++

if aa > 3

aa = 1		; Set to first number of edit fields

GuiControl, Focus, Edit%aa%

return





^Up::		;Navigate among Buttons

GuiControlGet, out, FocusV

StringRight, aa, out, 1

aa--

if aa < 1

aa = 3

GuiControl, Focus, Button%aa%

return



^Down::

GuiControlGet, out, FocusV

StringRight, aa, out, 1

aa++

if aa > 3

aa = 1

GuiControl, Focus, Button%aa%

return

#IfWinActive



GuiClose:

ExitApp