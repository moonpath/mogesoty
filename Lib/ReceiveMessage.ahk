ReceiveMessage(wParam, lParam)
{
    StringAddress := NumGet(lParam + 2*A_PtrSize)
    CopyOfData := StrGet(StringAddress)
    ToolTip %A_ScriptName%`nReceived the following string:`n%CopyOfData%
    return true
}