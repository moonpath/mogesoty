WindowsExplorerSelectItem(fileName)
{
	local WinID,item,key,window,WinClass
	WinGetClass, WinClass, A
	if (WinClass ~= "CabinetWClass")
	{
		WinGet, WinID, ID, A
		for window in ComObjCreate("Shell.Application").Windows
		{
			if (window.HWND != WinID)
				continue
			sfv := window.Document
			items := sfv.Folder.Items
			for item in items
			{
				name := item.Name
				if (name = fileName)
				{
					sfv.SelectItem(item, true)
					break 2
				}
			}
		}
	}
	else if(WinClass = "Progman")
	{
		out:=""
		charList:=StrSplit(fileName)
		for key,val in charList
			out.="{Asc " . asc(val) . "}"
		Send % out
	}
	return
}