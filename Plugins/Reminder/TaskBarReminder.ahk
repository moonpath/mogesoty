#SingleInstance, Force
#Persistent

ErrorLevel := []
Loop, %0%
    ErrorLevel.Push(%A_Index%)
(Reminder := {Base: Reminder}.__new(%False%, ErrorLevel*)).main()

class Reminder
{
    __new(ByRef argc := "", ByRef argv*)
    {
        SetWorkingDir %A_ScriptDir%
        Menu,Tray,Tip,Reminder
        this.argc := argc, this.argv := argv
        this.BoundShowText := this.ShowText.bind(this)
        OnExit(this.Recovery.bind(this), -1)
        return this
    }

    main()
    {
        BoundShowText := this.BoundShowText
        SetTimer,% BoundShowText,60000
        this.ShowText()
        return
    }

    ReadText()
    {
        allTextArray:=[]
        IniRead,text,Reminder.ini,Reminder,General,"Hello`, World!"
        text:=Trim(text)
        Loop, parse, text, CSV
            allTextArray.Push(A_LoopField)
        IniRead,text,Reminder.ini,Reminder,%A_MM%%A_DD%,0
        text?text:=Trim(text):text:=""
        Loop, parse, text, CSV
            allTextArray.Push(A_LoopField)
        return allTextArray
    }

    ShowText()
    {
        static preA_DD:="",allTextArray
        if(preA_DD!=A_DD)
        {
            allTextArray:=this.ReadText()
            preA_DD:=A_DD
        }
        Random, Index, 1, allTextArray.Length()
        ControlSetText, Static1,% allTextArray[Index], ahk_class Shell_TrayWnd
        return
    }

    Recovery()
    {
        ControlGetText, ButtonText, Button1, ahk_class Shell_TrayWnd
        ControlGetText, StaticText, Static1, ahk_class Shell_TrayWnd
        if(ButtonText!=StaticText)
            ControlSetText, Static1,% ButtonText, ahk_class Shell_TrayWnd
        return
    }
}
