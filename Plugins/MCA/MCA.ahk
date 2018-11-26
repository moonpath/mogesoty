#SingleInstance force
;#NoTrayIcon
SetWorkingDir %A_ScriptDir%

MCA.Show()

class MCA
{
    Show()
    {
        global MCA_Command:=""
        display:=""
        SearchList:=[]
        CommandList:=[]

        while(A_Index<=5)
        {
            IniRead,SearchList%A_Index%,Command.ini,SearchList,SearchList%A_Index%,0
            if(!(SearchList%A_Index%))
                SearchList%A_Index%:=""
            SearchList[A_Index]:=SearchList%A_Index%
            if(SearchList[A_Index])
                display.=SearchList[A_Index] . "|"
        }

        while(A_Index<=10)
        {
            IniRead,CommandList%A_Index%,Command.ini,CommandList,CommandList%A_Index%,0
            if(!(CommandList%A_Index%))
                CommandList%A_Index%:=""
            CommandList[A_Index]:=CommandList%A_Index%
            if(CommandList[A_Index])
                display.=CommandList[A_Index] . "|"
        }
        
        MCA.display:=display
        MCA.SearchList:=SearchList
        MCA.CommandList:=CommandList

        Gui,MCA: New, +LabelMCA.Gui, MCA
        Gui,MCA: font, s10, Microsoft JhengHei
        Gui,MCA: Add, Text,W330,MCA will open the corresponding program`, document`, folder or Internet resource according to the name you input.
        Gui,MCA: Add, ComboBox,WP vMCA_Command, %display%
        Gui,MCA: -MaximizeBox -MinimizeBox
        Gui,MCA: Add, Button,X193 W70 GMCA.ButtonOK Default, OK
        Gui,MCA: Add, Button,X+10 W70 GMCA.ButtonCancel, Cancel
        Gui,MCA: Show
        return
    }

    ButtonOK()
    {
        global MCA_Command
        SearchList:=MCA.SearchList
        CommandList:=MCA.CommandList
        Gui,Submit
            
        MCA_Command:=Trim(MCA_Command)
        if(!MCA_Command||StrLen(MCA_Command)>100)
            return
        paramsArray:=[]
        Loop, parse, MCA_Command, CSV
            if(A_Index=1)
                funName:=A_LoopField
            else
                paramsArray[A_Index-1] := A_LoopField
        if(IsFunc(funName))
        {
            SetTimer,ToolTip,-1
            %funName%(paramsArray*)
            while(A_Index<=10)
            {
                flag:=A_Index
                if(CommandList[A_Index]=MCA_Command)
                    break
            }
            while(A_Index<flag)
            {
                writeIndex:=A_Index+1
                IniWrite,% CommandList[A_Index],Command.ini,CommandList,CommandList%writeIndex%
            }
            IniWrite,%MCA_Command%,Command.ini,CommandList,CommandList1
        }
        else
        {
            Run,%MCA_Command%,,UseErrorLevel
            if(ErrorLevel="ERROR")
            {
                Run www.baidu.com/s?ie=utf-8&wd=%MCA_Command%,,UseErrorLevel
                while(A_Index<=5)
                {
                    flag:=A_Index
                    if(SearchList[A_Index]=MCA_Command)
                        break
                }
                while(A_Index<flag)
                {
                    writeIndex:=A_Index+1
                    IniWrite,% SearchList[A_Index],Command.ini,SearchList,SearchList%writeIndex%
                }
                IniWrite,%MCA_Command%,Command.ini,SearchList,SearchList1
            }
            else
            {
                TrayTip,%NAME%,ÒÑÎªÄúÖ´ÐÐ¸ÃÃüÁî
                while(A_Index<=10)
                {
                    flag:=A_Index
                    if(CommandList[A_Index]=MCA_Command)
                        break
                }
                while(A_Index<flag)
                {
                    writeIndex:=A_Index+1
                    IniWrite,% CommandList[A_Index],Command.ini,CommandList,CommandList%writeIndex%
                }
                IniWrite,%MCA_Command%,Command.ini,CommandList,CommandList1
            }
        }
        Gui, MCA: Destroy
        return
        ToolTip:
        {
            ToolTip,Apply
            Sleep,500
            ToolTip
            return
        }
    }

    GuiClose()
    {
        Gui, MCA: Destroy
        return
    }

    ButtonCancel()
    {
        Gui, MCA: Destroy
        return
    }
}
