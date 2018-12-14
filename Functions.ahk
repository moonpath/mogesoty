;<Initialization>=======================================================
;FileAttribMenu:=new FileAttribMenu()
;WindowStyle:=new WindowStyle()
ContextMenu:=new ContextMenu()
;</Initialization>======================================================
Goto,FunctionsEnd ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;<Functions>============================================================
ClipboardBackup(target:="",flag:="",thisMenu:="")
{
    if(target == "Import Clipboard")
    {
        FileRead,Clipboard,*c clip.bak
        Main.Notification.Notify("Clipboard Imported")
    }
    else
    {
        FileAppend,%ClipboardAll%,clip.bak
        Main.Notification.Notify("Clipboard Exported")
    }
    return
}

SelectItems()
{
    Click down
    return
}

GetWindowInfo()
{
    Component.RunPlugin("WindowInfo\WindowInfo.ahk")
    return
}

GetColor()
{
    Sleep,100
    while(!GetKeyState("Lbutton","P"))
    {
        MouseGetPos,X,Y
        PixelGetColor,color,X,Y,RGB
        NumPut( "0x" SubStr(color,-5), (V:="000000") )
        ToolTip,% SubStr(color,-5) . " (R:" . NumGet(V,2,"UChar") . " G:" . NumGet(V,1,"UChar") " B:" . NumGet(V,0,"UChar") . ")"
        Sleep,10
    }
    ToolTip
    return
}

AlignToGrid()
{
    WinActivate, Program Manager
    shellWindows := ComObjCreate("Shell.Application").Windows
    VarSetCapacity(_hwnd, 4, 0)
    desktop := shellWindows.FindWindowSW(0, "", 8, ComObj(0x4003, &_hwnd), 1)
    sfv := desktop.Document
    items := sfv.SelectedItems
    Loop, % items.Count
        sfv.SelectItem(items.Item(A_Index-1), 0)
    SendInput,{AppsKey}vi
    SendInput,{AppsKey}vi
}

SetSearchEngine(target:="",flag:="",thisMenu:="")
{
    Menu,% thisMenu, Uncheck,% Gesture.SearchEngine . "&"
    Menu,% thisMenu, Check,% (Gesture.SearchEngine := flag) . "&"
}

CloseScripts()
{
    WinGet, ScriptsList, List,% "ahk_exe" . Main.ASSEMBLYTITLE . ".exe"
    Loop,%ScriptsList%
    {
        currentID:=ScriptsList%A_Index%
        WinGet, currentPID, PID, ahk_id %currentID%
        if(currentPID!=DllCall("GetCurrentProcessId") && currentPID)
        {
            WinGetTitle, currentTitle, ahk_pid %currentPID%
            SendMessage,0x10,0,0,,ahk_pid %currentPID%
            SendMessage,0x02,0,0,,ahk_pid %currentPID%
            SendMessage,0x11,0,0,,ahk_pid %currentPID%
            Sleep 500
            Run,TaskKill /F /PID %currentPID%,,Hide UseErrorLevel
            Sleep 500
            if(!WinExist("ahk_pid" . currentPID))
                Main.LogToFile("Exit Of " . currentTitle . " Successfully")
            else
            {
                Main.LogToFile("Exit Of " . currentTitle . " Failed")
                TrayTip,,Exit Of %currentTitle% Failed,,3
            }
        }
    }
    return
}

CloseMonitor()
{
    BlockInput,On
    SendMessage, 0x112, 0xF170, 2,, Program Manager
    Sleep,2000
    BlockInput,Off
    return
}

Restart()
{
    Run,%Comspec% /c "Shutdown /r /f /t 0",,Hide UseErrorLevel
    return
}

ShutDown()
{
    Run,%Comspec% /c "Shutdown /s /hybrid /f /t 0",,Hide UseErrorLevel
    return
}

ReplaceURL(command)
{
    return SubStr(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(SubStr(command,1,64),"""",""""""""),"`%","`%25")," ","`%20"),"`n","`%20"),"#","`%23"),"&","`%26"),"+","`%2B"),"=","`%3D"),1,128)
}
;</Functions>===========================================================

;<Class>================================================================
class WindowStyle
{
    __new()
    {
        this.hideWinList:={}
        this.ghostWinList:={}
        this.minWinList:={}
        this.minWinHeightList:={}
        
        this.BoundUnhideWindow:=BoundUnhideWindow:=this.UnhideWindow.bind(this)
        this.BoundUnghostWindow:=BoundUnghostWindow:=this.UnghostWindow.bind(this)
        this.BoundUnminWindow:=BoundUnminWindow:=this.UnminWindow.bind(this)

        BoundAlwaysOnTop:=this.AlwaysOnTop.Bind(this)
        BoundGetAddress:=this.GetAddress.bind(this)
        BoundHideWindow:=this.HideWindow.bind(this)
        BoundGhostWindow:=this.GhostWindow.bind(this)
        BoundMinWindow:=this.MinWindow.bind(this)
        BoundGetAddress:=this.GetAddress.bind(this)
        BoundOpenInDir:=this.OpenInDir.bind(this)
        BoundGetContent:=this.GetContent.bind(this)
        BoundCloseWindow:=this.CloseWindow.bind(this)
        BoundRestart:=this.Restart.bind(this)
        BoundChangeWindowSize:=this.ChangeWindowSize.bind(this)

        Menu,Window,Add,None,WindowStyle.__new
        Menu,Window,Add
        Menu,Window,Disable,None
        Menu, Window, Icon, None, Shell32.dll, 95
        Menu,Window,Add,Hide,% BoundHideWindow
        Menu, Window, Icon, Hide, Shell32.dll, 310
        Menu,Window,Add,Ghost,% BoundGhostWindow
        Menu, Window, Icon, Ghost, Shell32.dll, 101
        Menu,Window,Add,Min,% BoundMinWindow
        Menu, Window, Icon, Min, Shell32.dll, 249
        Menu,Window,Add,Top,% BoundAlwaysOnTop
        Menu, Window, Icon, Top, Shell32.dll, 251
        Menu,Window,Add,Address,% BoundGetAddress
        Menu, Window, Icon, Address, Shell32.dll, 157
        Menu,Window,Add,Open In Dir,% BoundOpenInDir
        Menu, Window, Icon, Open In Dir, Shell32.dll, 46
        Menu,Window,Add,Content,% BoundGetContent
        Menu, Window, Icon, Content, Shell32.dll, 2
        Menu,Window,Add,Close,% BoundCloseWindow
        Menu, Window, Icon, Close, Shell32.dll, 132
        Menu,Window,Add,Restart,% BoundRestart
        Menu, Window, Icon, Restart, Shell32.dll, 47

        Menu,Size,Add,Largest,% BoundChangeWindowSize
        Menu,Size,Add,Large,% BoundChangeWindowSize
        Menu,Size,Add,Medium,% BoundChangeWindowSize
        Menu,Size,Add,Small,% BoundChangeWindowSize
        Menu,Window,Add,Size,:Size
        Menu, Window, Icon, Size, Shell32.dll, 160

        OnExit(this.Recovery.bind(this),-1)
        return this
    }

    Show(winID:="")
    {
        winID?this.winID:=winID:this.winID:=WinExist("A")
        WinGetTitle,menuTitle,% "ahk_id" . this.winID
        menuTitle?false:menuTitle:="No Title"
        WinGetClass,winClass,% "ahk_id" . this.winID
        if(!(winClass~="Windows.UI.Core.CoreWindow|Progman|Shell_TrayWnd|Shell_SecondaryTrayWnd|MultitaskingViewFrame|NotifyIconOverflowWindow|WorkerW")&&menuTitle)
        {
            StrLen(MenuTitle)>16?MenuTitle:=SubStr(MenuTitle,1,13) . "..."
            Menu,Window,Rename,None,%menuTitle%
            Menu,Window,Show
            Sleep 250
            Menu,Window,Rename,%menuTitle%,None
        }
        return
    }

    AlwaysOnTop()
    {
        WinSet,AlwaysOnTop,Toggle,% "ahk_id" . this.winID
        return
    }

    GetAddress()
    {
        WinGet,ProcessPath,ProcessPath,% "ahk_id" . this.winID
        clipboard:=ProcessPath
        Main.Notification.Notify("Address Copied")
        return
    }

    OpenInDir()
    {
        WinGet,processPath,ProcessPath,% "ahk_id" . this.winID
        Run,Explorer /select`,%processPath%,,UseErrorLevel,OutputVarPID
        return
    }

    GetContent()
    {
        WinGetText,allText,% "ahk_id" . this.winID
        Run,Notepad
        Sleep,300
        ControlSetText, Edit1,% allText, A
        return
    }

    CloseWindow()
    {
        WinKill,% "ahk_id" . this.winID
        return
    }

    Restart()
    {
        WinGet,PID,PID,% "ahk_id" . this.winID
        WinGet,ProcessPath,ProcessPath,ahk_pid %PID%
        Process,Close,%PID%
        Loop,5
        {
            Sleep,1000
            Process,Exist,%PID%
            if(ErrorLevel==0)
            {
                Run,%ProcessPath%,,UseErrorLevel
                return
            }
        }
        TrayTip,,Restart Failed,,3
        return
    }

    ChangeWindowSize()
    {
        activeWinID := this.winID
        WinGet,MinMax,MinMax,ahk_id %activeWinID%
      if(MinMax=1)
          WinRestore,ahk_id %activeWinID%
      CoordMode,Mouse,Screen
        MouseGetPos,mouseXPos,mouseYPos
        SysGet,monitorCount,MonitorCount
        Loop,%MonitorCount%
        {
            SysGet,monitorSize%A_Index%,Monitor,%A_Index%
            a:=monitorSize%A_Index%Left
        }
        Loop,%monitorCount%
        {
            if(mouseXPos>=monitorSize%A_Index%Left && mouseXPos<monitorSize%A_Index%Right)
            {
                screenWidth:=monitorSize%A_Index%Right-monitorSize%A_Index%Left
                screenHeight:=monitorSize%A_Index%Bottom-monitorSize%A_Index%Top
                screenLeft:=monitorSize%A_Index%Left
                if(A_ThisMenuItem="Largest")
                    WinMove,ahk_id %activeWinID%,,% screenLeft,0,% screenWidth,% screenHeight
                else if(A_ThisMenuItem="Large")
                    WinMove,ahk_id %activeWinID%,,% screenLeft+screenWidth/16,% screenHeight/16,% screenWidth-screenWidth/8,% screenHeight-screenHeight/8
                else if(A_ThisMenuItem="Medium")
                    WinMove,ahk_id %activeWinID%,,% screenLeft+screenWidth/8,% screenHeight/8,% screenWidth-screenWidth/4,% screenHeight-screenHeight/4
                else if(A_ThisMenuItem="Small")
                    WinMove,ahk_id %activeWinID%,,% screenLeft+screenWidth/5,% screenHeight/5,% screenWidth-screenWidth/2.5,% screenHeight-screenHeight/2.5
                    
                break
            }
        }
        return
    }

    HideWindow()
    {
        hideWinID:=this.winID
        WinGetClass, hideWinClass, ahk_id %hideWinID%
        if hideWinClass in Windows.UI.Core.CoreWindow,Progman,Shell_TrayWnd,Shell_SecondaryTrayWnd,MultitaskingViewFrame,NotifyIconOverflowWindow,WorkerW
            return
        WinGetTitle, hideWinTitile, ahk_id %hideWinID%
        if(!hideWinTitile)
            hideWinTitile:="No Title"
        if(this.hideWinList[hideWinTitile]=hideWinID)
            return
        while(this.hideWinList.HasKey(hideWinTitile))
            if(A_Index=1)
                hideWinTitile.=A_Index
            else
                hideWinTitile:=SubStr(hideWinTitile, 1 , -1) . A_Index
        this.hideWinList[hideWinTitile]:=hideWinID
        WinHide,ahk_id %hideWinID%
        BoundUnhideWindow:=this.BoundUnhideWindow
        Menu, HideWins, add, %hideWinTitile%,% BoundUnhideWindow
        this.CheckHideWindowMenu()
        return
    }

    GhostWindow()
    {
        ghostWinID:=this.winID
        WinGetClass, ghostWinClass, ahk_id %ghostWinID%
        if ghostWinClass in Windows.UI.Core.CoreWindow,Progman,Shell_TrayWnd,Shell_SecondaryTrayWnd,MultitaskingViewFrame,NotifyIconOverflowWindow,WorkerW
            return
        WinGetTitle, ghostWinTitile, ahk_id %ghostWinID%
        if(!ghostWinTitile)
            ghostWinTitile:="No Title"
        if(this.ghostWinList[ghostWinTitile]=ghostWinID)
            return
        while(this.ghostWinList.HasKey(ghostWinTitile))
            if(A_Index=1)
                ghostWinTitile.=A_Index
            else
                ghostWinTitile:=SubStr(ghostWinTitile, 1 , -1) . A_Index
        this.ghostWinList[ghostWinTitile]:=ghostWinID
        WinSet,AlwaysOnTop,On,ahk_id %ghostWinID%
        WinSet,Transparent,150,ahk_id %ghostWinID%
        WinSet,ExStyle,+0x00000020,ahk_id %ghostWinID%
        BoundUnghostWindow:=this.BoundUnghostWindow
        Menu, GhostWins, add, %ghostWinTitile%,% BoundUnghostWindow
        this.CheckGhostWindowMenu()
        return
    }

    MinWindow()
    {
        minWinID:=this.winID
        WinGetClass, minWinClass, ahk_id %minWinID%
        if minWinClass in Windows.UI.Core.CoreWindow,Progman,Shell_TrayWnd,Shell_SecondaryTrayWnd,MultitaskingViewFrame,NotifyIconOverflowWindow,WorkerW
            return
        WinGetTitle,minWinTitile,ahk_id %minWinID%
        if(!minWinTitile)
            minWinTitile:="No Title"
        WinGetPos,,,,minWinHeight,ahk_id %minWinID%
        if(this.minWinList[minWinTitile]=minWinID)
            return
        while(this.minWinList.HasKey(minWinTitile))
            if(A_Index=1)
                minWinTitile.=A_Index
            else
                minWinTitile:=SubStr(minWinTitile, 1 , -1) . A_Index
        this.minWinList[minWinTitile]:=minWinID
        this.minWinHeightList[minWinTitile]:=minWinHeight
        WinMove, ahk_id %minWinID%,,,,,25
        BoundUnminWindow:=this.BoundUnminWindow
        Menu, MinWins, add, %minWinTitile%,% BoundUnminWindow
        this.CheckMinWindowMenu()
        return
    }

    UnhideWindow()
    {
        showWinID:=this.hideWinList.Delete(A_ThisMenuItem)
        WinShow,ahk_id %showWinID%
        Menu, HideWins, delete, %A_ThisMenuItem%
        this.CheckHideWindowMenu()
        return
    }

    UnghostWindow()
    {
        unghostWinID:=this.ghostWinList.Delete(A_ThisMenuItem)
        WinSet,AlwaysOnTop,Off,ahk_id %unghostWinID%
        WinSet,Transparent,Off,ahk_id %unghostWinID%
        WinSet,ExStyle,-0x00000020,ahk_id %unghostWinID%
        Menu, GhostWins, delete, %A_ThisMenuItem%
        this.CheckGhostWindowMenu()
        return
    }

    UnminWindow()
    {
        unMinWinID:=this.minWinList.Delete(A_ThisMenuItem)
        unMinWinHeight:=this.minWinHeightList.Delete(A_ThisMenuItem)
        WinMove,ahk_id %unMinWinID%,,,,,%unMinWinHeight%
        Menu,MinWins,delete,%A_ThisMenuItem%
        this.CheckMinWindowMenu()
        return
    }

    CheckHideWindowMenu()
    {
        count:=0
        for i,v in this.hideWinList
            count++
        if(!count)
            Menu, Functions, delete, HideWins
        else
            Menu, Functions, add, HideWins, :HideWins
        return
    }

    CheckGhostWindowMenu()
    {
        count:=0
        for i,v in this.ghostWinList
            count++
        if(!count)
            Menu, Functions, delete, GhostWins
        else
            Menu, Functions, add, GhostWins, :GhostWins
        return
    }

    CheckMinWindowMenu()
    {
        count:=0
        for i,v in this.minWinList
            count++
        if(!count)
            Menu, Functions, delete, MinWins
        else
            Menu, Functions, add, MinWins, :MinWins
        return
    }

    Recovery()
    {
        for item,showWinID in this.hideWinList
        {
            WinShow,ahk_id %showWinID%
        }
        for item,unghostWinID in this.ghostWinList
        {
            WinSet,AlwaysOnTop,Off,ahk_id %unghostWinID%
            WinSet,Transparent,Off,ahk_id %unghostWinID%
            WinSet,ExStyle,-0x00000020,ahk_id %unghostWinID%
        }
        for item,unMinWinID in this.minWinList
        {
            unMinWinHeight:=this.minWinHeightList.Delete(item)
            WinMove,ahk_id %unMinWinID%,,,,,%unMinWinHeight%
        }
        return
    }
}

class FileAttribMenu
{
    __new()
    {
        BoundAddress:=this.Address.bind(this)
        BoundRead:=this.Read.bind(this)
        BoundHide:=this.Hide.bind(this)
        BoundSystem:=this.System.bind(this)
        BoundTime:=this.Time.bind(this)
        BoundBackup:=this.Backup.bind(this)
        BoundAddress:=this.Address.bind(this)
        BoundOpenInDir:=this.OpenInDir.bind(this)
        BoundRunAsAdmin:=this.RunAsAdmin.bind(this)
        Menu,Attrib,Add,None,FileAttribMenu.__new
        Menu,Attrib,Add
        Menu,Attrib,Disable,None
        Menu, Attrib, Icon, None, Shell32.dll, 1
        Menu,Attrib,Add,Read,% BoundRead
        Menu, Attrib, Icon, Read, Shell32.dll, 153
        Menu,Attrib,Add,Hide,% BoundHide
        Menu, Attrib, Icon, Hide, Shell32.dll, 310
        Menu,Attrib,Add,System,% BoundSystem
        Menu, Attrib, Icon, System, Shell32.dll, 245
        Menu,Attrib,Add,Time,% BoundTime
        Menu, Attrib, Icon, Time, Shell32.dll, 240
        Menu,Attrib,Add,Backup,% BoundBackup
        Menu, Attrib, Icon, Backup, Shell32.dll, 55
        Menu,Attrib,Add,Address,% BoundAddress
        Menu, Attrib, Icon, Address, Shell32.dll, 157
        Menu,Attrib,Add,Open In Dir,% BoundOpenInDir
        Menu, Attrib, Icon, Open In Dir, Shell32.dll, 46
        Menu,Attrib,Add,Run As Admin,% BoundRunAsAdmin
        Menu, Attrib, Icon, Run As Admin, imageres.dll, 74
        return this
    }

    Show(file:="")
    {
        this.file:=file
        SplitPath,file,OutFileName
        if(attrib:=FileExist(file)&&OutFileName)
        {
            StrLen(OutFileName)>16?OutFileName:=SubStr(OutFileName,1,13) . "..."
            Menu,Attrib,Rename,None,%OutFileName%
            if(InStr(attrib,"R"))
                Menu,Attrib,Check,Read
            else
                Menu,Attrib,UnCheck,Read
            if(InStr(attrib,"H"))
                Menu,Attrib,Check,Hide
            else
                Menu,Attrib,UnCheck,Hide
            if(InStr(attrib,"S"))
                Menu,Attrib,Check,System
            else
                Menu,Attrib,UnCheck,System
            Menu,Attrib,Show
            Sleep,250
            Menu,Attrib,Rename,%OutFileName%,None
        }
        return
    }

    Read()
    {
        FileSetAttrib,^R,% this.file,1,0
        Menu,Attrib,ToggleCheck,Read
        return
    }
    
    System()
    {
        FileSetAttrib,^S,% this.file,1,0
        Menu,Attrib,ToggleCheck,System
        return
    }
    
    Hide()
    {
        FileSetAttrib,^H,% this.file,1,0
        Menu,Attrib,ToggleCheck,Hide
        return
    }
    
    Time()
    {
        FileSetTime,,% this.file,M,1,0
        FileSetTime,,% this.file,C,1,0
        FileSetTime,,% this.file,A,1,0
        return
    }

    Backup()
    {
        file:=this.file
        FileGetAttrib,Attributes,% this.file
        SplitPath, file, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        backupName:=OutDir . "\" . OutNameNoExt . ".bak." . OutExtension
        while(FileExist(backupName))
        {
            backupName:=OutDir . "\" . OutNameNoExt . ".bak" . A_Index . "." . OutExtension
        }
        IfInString,Attributes,D
        {
            FileCopyDir, % this.file, %backupName%, 1
        }else
        {
            FileCopy,% this.file,%backupName%
        }
        return
    }

    Address()
    {
        clipboard:=this.file
        Main.Notification.Notify("Address Copied")
        return
    }

    OpenInDir()
    {
        if(SelectedFile:=WindowsExplorer.WindowsExplorerGetSelectedItemPath())
        {
            SplitPath,SelectedFile,OutFileName,OutDir,OutExtension
            if(OutExtension="lnk")
                FileGetShortcut,% SelectedFile,SelectedFile
            Run,Explorer /select`,%SelectedFile%,,UseErrorLevel,OutputVarPID
        }
        return
    }

    RunAsAdmin()
    {
        file:=this.file
        SplitPath, file, , OutDir
        Run, % this.file, %OutDir%, UseErrorLevel
        return
    }
}

class WindowsExplorer
{
    WindowsExplorerLocation(HWnd="")
    {
        HWnd ? false:HWnd := WinExist("A")
        Location := ""
        WinGetClass, WinClass, ahk_id %HWnd%
        if(WinClass = "Progman" || WinClass = "WorkerW")
            Location := A_Desktop
        else if(WinClass = "CabinetWClass")
        {
            For Window In ComObjCreate("Shell.Application").Windows
                if(Window.HWnd == HWnd)
                {
                   URL := Window.LocationURL
                   Break
                }
            StringTrimLeft, Location, URL, 8
            StringReplace, Location, Location, /, \, All
            Location := RegExReplace(Location,"U)(.*)%20","$1 ")
        }
        Return Location
    }

    WindowsExplorerGetSelectedItemPath(HWnd="")
    {
        HWnd ? false:HWnd := WinExist("A")
        WinGetClass, WinClass, ahk_id %HWnd%
        SelectedItemPath:=""
        if(WinClass = "Progman" || WinClass = "WorkerW")
        {
            ControlGet, SelectedName, List, Selected Col1, SysListView321, A

            if(SelectedName&&!InStr(SelectedName,"`n"))
            {
                Loop, Parse, SelectedName, `n
                if(A_Index=1)
                    SelectedName:=A_LoopField
                else
                    break

                Desktop:=0
                DesktopCommon:=0

                Loop,%A_Desktop%\%SelectedName%*,1,0
                    if(Desktop++=0)
                        SelectedItemPath:=A_LoopFileLongPath
                    else
                        break

                Loop,%A_DesktopCommon%\%SelectedName%*,1,0
                    if(DesktopCommon++=0)
                        SelectedItemPath:=A_LoopFileLongPath
                    else
                        break

                if(Desktop+DesktopCommon>1)
                {
                    Prev_ClipBoard:=ClipBoardAll
                    ClipBoard:=""
                    SendInput ^c
                    ClipWait,0
                    SelectedItemPath:=ClipBoard
                    ClipBoard:=Prev_ClipBoard
                }
            }
        }
        else if(WinClass = "CabinetWClass")
        {
            for Window In ComObjCreate("Shell.Application").Windows
                if(Window.HWnd == HWnd)
                {
                    collection := window.document.SelectedItems
                    for item in collection
                        SelectedItemPath := item.path
                    break
                }
        }
        return SelectedItemPath
    }

    WindowsExplorerSelectItem(fileName,HWnd="")
    {
        HWnd ? false:HWnd := WinExist("A")
        WinGetClass, WinClass, ahk_id %HWnd%
        if(WinClass = "CabinetWClass")
        {
            WinGet, WinID, ID, A
            for window in ComObjCreate("Shell.Application").Windows
            {
                if (window.HWND != WinID)
                    continue
                sfv := window.Document
                items := sfv.SelectedItems
                Loop % items.Count
                    sfv.SelectItem(items.Item(A_Index-1), 0)
                ;desktop.Refresh()
                sfv.SelectItem(items.Item(fileName), 1)
            }
        }
        else if(WinClass = "Progman" || WinClass = "WorkerW")
        {
            shellWindows := ComObjCreate("Shell.Application").Windows
            VarSetCapacity(_hwnd, 4, 0)
            desktop := shellWindows.FindWindowSW(0, "", 8, ComObj(0x4003, &_hwnd), 1)
            sfv := desktop.Document
            items := sfv.SelectedItems
            Loop % items.Count
                sfv.SelectItem(items.Item(A_Index-1), 0)
            ;desktop.Refresh()
            sfv.SelectItem(items.Item(fileName), 1)
        }
        return
    }
}


class MCA
{
    __new()
    {
        this.BoundButtonOK:=BoundButtonOK:=this.ButtonOK.bind(this)
        this.BoundButtonCancel:=BoundButtonCancel:=this.ButtonCancel.bind(this)
        return this
    }

    Show()
    {    
        display:="",SearchList:=[],CommandList:=[]

        BoundButtonOK:=this.BoundButtonOK
        BoundButtonCancel:=this.BoundButtonCancel

        while(A_Index<=5)
        {
            IniRead,SearchList%A_Index%,Record.ini,SearchList,SearchList%A_Index%,0
            if(!(SearchList%A_Index%))
                SearchList%A_Index%:=""
            SearchList.Push(SearchList%A_Index%)
            if(SearchList[A_Index])
                display.=SearchList[A_Index] . "|"
        }

        while(A_Index<=10)
        {
            IniRead,CommandList%A_Index%,Record.ini,CommandList,CommandList%A_Index%,0
            if(!(CommandList%A_Index%))
                CommandList%A_Index%:=""
            CommandList.Push(CommandList%A_Index%)
            if(CommandList[A_Index])
                display.=CommandList[A_Index] . "|"
        }

        this.display:=display
        this.SearchList:=SearchList
        this.CommandList:=CommandList

        Gui,MCA: New, +LastFound +AlwaysOnTop, MCA
        Gui,MCA: font, s10, Microsoft JhengHei
        Gui, Color, FDFDFD
        Gui,MCA: Add, Text, W300, Type To Search or Run:
        Gui,MCA: Add, ComboBox, WP, %display%
        Gui,MCA: -MaximizeBox -MinimizeBox
        Gui,MCA: Add, Button, X163 W70 Default HwndOKHwnd, OK
        GuiControl, MCA:+G, % OKHwnd, % BoundButtonOK
        Gui,MCA: Add, Button, X+10 W70 HwndCancelHwnd, Cancel
        GuiControl, MCA:+G, % CancelHwnd, % BoundButtonCancel
        Gui,MCA: Show
        return
    }

    ButtonOK()
    {
        SearchList:=this.SearchList
        CommandList:=this.CommandList
        ControlGetText, command, Edit1
        Gui, MCA: Destroy
        command:=Trim(SubStr(command, 1, 100))
        if(command=""||StrLen(command)>100)
            return
        paramsArray:=[]
        Loop, parse, command, CSV
            if(A_Index=1)
                funName:=A_LoopField
            else
                paramsArray.Push(A_LoopField)
        if(IsFunc(funName))
        {
            ToolTip,Apply,,,20
            while(A_Index<=10)
            {
                flag:=A_Index
                if(CommandList[A_Index]=command)
                    break
            }
            while(A_Index<flag)
            {
                writeIndex:=A_Index+1
                IniWrite,% CommandList[A_Index],Record.ini,CommandList,CommandList%writeIndex%
            }
            IniWrite,%command%,Record.ini,CommandList,CommandList1
            %funName%(paramsArray*)
            Sleep,500
            ToolTip,,,,20
        }
        else
        {
            Run,% command,% A_WorkingDir,UseErrorLevel
            if(ErrorLevel="ERROR")
            {
                if(Gesture.SearchEngine == 1)
                    Run,% "www.bing.com/search?&q=" . ReplaceURL(command),,UseErrorLevel
                else if(Gesture.SearchEngine==2)
                    Run,% "www.baidu.com/s?ie=utf-8&wd=" . ReplaceURL(command),,UseErrorLevel
                else
                    Run,% "www.google.com/search?q=" . ReplaceURL(command),,UseErrorLevel
                while(A_Index<=5)
                {
                    flag:=A_Index
                    if(SearchList[A_Index]=command)
                        break
                }
                while(A_Index<flag)
                {
                    writeIndex:=A_Index+1
                    IniWrite,% SearchList[A_Index],Record.ini,SearchList,SearchList%writeIndex%
                }
                IniWrite,%command%,Record.ini,SearchList,SearchList1
            }
            else
            {
                Main.Notification.Notify("The command has been executed")
                while(A_Index<=10)
                {
                    flag:=A_Index
                    if(CommandList[A_Index]=command)
                        break
                }
                while(A_Index<flag)
                {
                    writeIndex:=A_Index+1
                    IniWrite,% CommandList[A_Index],Record.ini,CommandList,CommandList%writeIndex%
                }
                IniWrite,%command%,Record.ini,CommandList,CommandList1
            }
        }
        return
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

class Press
{
    __new(interval := 300)
    {
        this.Count := 0
        this.interval := interval
        this.BoundRecognize := this.Recognize.bind(this)
        return this
    }

    Trigger(Count := 1)
    {
        if(this.Count > 0)
        {
        this.Count += 1
        return
        }
        this.Count := Count
        interval := this.interval
        BoundRecognize := this.BoundRecognize
        SetTimer, %BoundRecognize%, -%interval%
        return
    }

    Recognize()
    {
        this.Execute(this.Count)
        this.Count := 0
        return
    }

    Execute(Count := 0)
    {
        MsgBox,% Count
        return
    }
}

class Press_Hotkey_Templet extends Press
{
    Execute(Count := 0)
    {
        if(Count = 3)
            MsgBox, OK
        return
    }
}

class ContextMenu
{
    __new()
    {
        ;static activeWin
        ;activeWin:="0x000000"
        ;this.addressOfActiveWin:=&activeWin
        Menu, Functions, add, Window Info, GetWindowInfo
        Menu, Functions, Icon, Window Info, Shell32.dll, 273
        Menu, Functions, add, Select Items, SelectItems
        Menu, Functions, Icon, Select Items, Shell32.dll, 134
        Menu, Functions, add, Get Color, GetColor
        Menu, Functions, Icon, Get Color, imageres.dll, 187
        Menu, Functions, add, Align To Grid,AlignToGrid
        Menu, Functions, Icon, Align To Grid, Shell32.dll, 326

        Menu, SearchEngine, add, Bing, SetSearchEngine
        Menu, SearchEngine, add, Baidu, SetSearchEngine
        Menu, SearchEngine, add, Google, SetSearchEngine
        Menu, SearchEngine, Check,% (Gesture.SearchEngine := 2) . "&"
        Menu, Functions, add, Search Engine, :SearchEngine
        Menu, Functions, Icon, Search Engine, Shell32.dll, 23

        Menu, Clipboard, add, Import Clipboard, ClipboardBackup
        Menu, Clipboard, add, Export Clipboard, ClipboardBackup
        Menu, Functions, add, Clipboard, :Clipboard
        Menu, Functions, Icon, Clipboard, Shell32.dll, 135

        Menu, PowerManager, add, Close Monitor, CloseMonitor
        Menu, PowerManager, add, Restart, Restart
        Menu, PowerManager, add, Shut Down, ShutDown
        Menu, Functions, add, Power Manager, :PowerManager
        Menu, Functions, Icon, Power Manager, Shell32.dll, 113

        Menu, Functions, add, Close Scripts, CloseScripts
        Menu, Functions, Icon, Close Scripts, Shell32.dll, 132

        Menu, Tray, add, Functions, :Functions
        return this
    }

    Show()
    {
        ;StrPut(WinExist("A"),this.addressOfActiveWin)
        Menu, Functions, Show
        return
    }
}
;</Class>===============================================================
FunctionsEnd:
