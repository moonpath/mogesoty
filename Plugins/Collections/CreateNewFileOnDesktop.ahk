#ifWinActive ahk_class WorkerW
^+F::NewDesktopFile()
NewDesktopFile() {
    ; Find desktop window object.
    shellWindows := ComObjCreate("Shell.Application").Windows
    VarSetCapacity(_hwnd, 4, 0)
    desktop := shellWindows.FindWindowSW(0, "", 8, ComObj(0x4003, &_hwnd), 1)
    ; Deselect each item.
    ; IShellFolderViewDual: http://msdn.microsoft.com/en-us/library/dd894076
    sfv := desktop.Document
    items := sfv.SelectedItems
    Loop % items.Count
        sfv.SelectItem(items.Item(A_Index-1), 0)
    ; Create the file.
    FileAppend,, %A_Desktop%\New File
    ; Force the icon to show up (soon, but not instantly).
    desktop.Refresh()
    ; Select the item (doesn't matter whether it's visible yet).
    sfv.SelectItem(items.Item("New File"), 1)
    ; Loop usually isn't necessary, but adds a bit of reliability.
    Loop 5 {
        Sleep 50
        Send {F2}
        ; Verify we're now in rename mode.
        ControlGetFocus focus
    } until (focus = "Edit1")
}