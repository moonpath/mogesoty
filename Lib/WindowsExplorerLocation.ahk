WindowsExplorerLocation(WndH)
{
	If (WndH = "")
		WndH := WinExist("A")
	Location := ""
	WinGet Process, ProcessName, ahk_id %WndH%
	If (Process = "explorer.exe")
	{
		WinGetClass Class, ahk_id %WndH%
		If (Class = "Progman")
			Location := A_Desktop
		Else If (Class = "CabinetWClass")
		{
			For Window In ComObjCreate("Shell.Application").Windows
				If (Window.HWnd == WndH)
				{
				   URL := Window.LocationURL
				   Break
				}
			StringTrimLeft, Location, URL, 8
			StringReplace, Location, Location, /, \, All
		}
	}
	Return Location
}