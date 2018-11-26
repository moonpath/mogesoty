SetWorkingDir,%A_ScriptDir%

;C:\Users\Harvey\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch

FileCreateShortcut, %A_ScriptDir%\TaskBarControl.exe, %A_ScriptDir%\Next.lnk, %A_ScriptDir%, "%A_ScriptDir%\TaskBarControl.ahk" "/next", Next, %A_ScriptDir%\Res.dll, , 3, 7
FileCreateShortcut, %A_ScriptDir%\TaskBarControl.exe, %A_ScriptDir%\Play_Pause.lnk, %A_ScriptDir%, "%A_ScriptDir%\TaskBarControl.ahk" "/play_pause", Play_Pause, %A_ScriptDir%\Res.dll, , 4, 7
FileCreateShortcut, %A_ScriptDir%\TaskBarControl.exe, %A_ScriptDir%\Prev.lnk, %A_ScriptDir%, "%A_ScriptDir%\TaskBarControl.ahk" "/prev", Prev, %A_ScriptDir%\Res.dll, , 5, 7
