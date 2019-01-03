SetWorkingDir %A_ScriptDir%
Gui,New,,Keypass
Gui,+AlwaysOnTop
Gui,Add,ListView,AltSubmit r20 w250 gMyListView,Name|Account|Password
Loop,read,Keypass.pwd
{
    OutputArray:=[]
    Loop,parse,A_LoopReadLine,CSV
        OutputArray.Push(A_LoopField)
    LV_Add("",OutputArray[1],OutputArray[2],OutputArray[3])
}
LV_ModifyCol()
LV_ModifyCol(3,0)
Gui,Show
return

MyListView()
{
    global account,passWord
    if(A_GuiEvent=="R")
    {
        LV_GetText(account,A_EventInfo,2)
        LV_GetText(passWord,A_EventInfo,3)
        HotKey,WheelUp,SendAccout
        HotKey,WheelDown,SendAccout
        HotKey,MButton,SendPassWord
        Gui,Hide
        Sleep,8000
        ExitApp
    }
    else if(A_GuiEvent=="DoubleClick")
        ExitApp
    return
}

SendAccout()
{
    global account
    if(account!="account")
        SendInput % GetUnicodeString(account)
    return
}

SendPassWord()
{
    global passWord
    if(passWord!="passWord")
        SendInput % GetUnicodeString(passWord)
    return
}

GetUnicodeString(str)
{
    out := ""
    charList := StrSplit(str)
    SetFormat, integer, hex
    for key, val in charList
        out .= "{U+ " . ord(val) . "}"
    return out
}

GuiClose()
{
    ExitApp
    return
}
