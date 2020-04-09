;<MultipleMonitor>=================================================
#NoTrayIcon
#Persistent
#SingleInstance Force

DetectHiddenWindows,On
CoordMode,Mouse,Screen
SetBatchLines,-1
SetWinDelay,100

DllCall("RegisterShellHookWindow",UInt,WinExist(A_ScriptFullPath))
OnMessage(DllCall("RegisterWindowMessage",Str,"SHELLHOOK"),"ShellMessage",-2)

ShellMessage(wParam,lParam)
{
    if(wParam=1 && WinExist("ahk_id" . lParam)) ;HSHELL_WINDOWCREATED
    {
        WinGetClass, current_class, A
        ;if(current_class == "ForegroundStaging")
        if current_class in ForegroundStaging,Windows.UI.Core.CoreWindow,Progman,Shell_TrayWnd,Shell_SecondaryTrayWnd,MultitaskingViewFrame,NotifyIconOverflowWindow,WorkerW,TaskListThumbnailWnd
            return
        SysGet,monitorCount,MonitorCount
        if(MonitorCount<=1)
            return
        showArea:=[],mouseIndex:=1
        WinGetPos,winXPos,winYPos,winWidth,winHeight,ahk_id %lParam%
        if(!winXPos || !winYPos || !winWidth || !winHeight)
        {
          WinWaitActive,ahk_id %lParam%,,0
          WinGetPos,winXPos,winYPos,winWidth,winHeight,ahk_id %lParam%
        }
        WinGetTitle,winTitle,ahk_id %lParam%
        if(!winTitle) ;Ignore special windows
          return
        MouseGetPos,mouseXPos,mouseYPos
        Loop,%monitorCount%
        {
            SysGet,monitorSize%A_Index%,Monitor,%A_Index%
            if(winXPos+winWidth<monitorSize%A_Index%Left || winXPos>monitorSize%A_Index%Right)
                showWidth%A_Index%:=0
            else if(winXPos>=monitorSize%A_Index%Left&&winXPos+winWidth<=monitorSize%A_Index%Right)
                showWidth%A_Index%:=winWidth
            else if(winXPos<monitorSize%A_Index%Left&&winXPos+winWidth<=monitorSize%A_Index%Right)
                showWidth%A_Index%:=winXPos+winWidth-monitorSize%A_Index%Left
            else if(winXPos>=monitorSize%A_Index%Left&&winXPos+winWidth>monitorSize%A_Index%Right)
                showWidth%A_Index%:=monitorSize%A_Index%Right-winXPos
            else
                showWidth%A_Index%:=monitorSize%A_Index%Right-monitorSize%A_Index%Left
                
            if(winYPos+winHeight<monitorSize%A_Index%Top || winYPos>monitorSize%A_Index%Bottom)
                showHeight%A_Index%:=0
            else if(winYPos>=monitorSize%A_Index%Top&&winYPos+winHeight<=monitorSize%A_Index%Bottom)
                showHeight%A_Index%:=winHeight
            else if(winYPos<monitorSize%A_Index%Top&&winYPos+winHeight<=monitorSize%A_Index%Bottom)
                showHeight%A_Index%:=winYPos+winHeight-monitorSize%A_Index%Top
            else if(winYPos>=monitorSize%A_Index%Top&&winYPos+winHeight>monitorSize%A_Index%Bottom)
                showHeight%A_Index%:=monitorSize%A_Index%Bottom-winYPos
            else
                showHeight%A_Index%:=monitorSize%A_Index%Bottom-monitorSize%A_Index%Top

            showArea[A_Index]:=showWidth%A_Index% * showHeight%A_Index%

            if(mouseXPos>=monitorSize%A_Index%Left && mouseXPos<=monitorSize%A_Index%Right && mouseYPos>=monitorSize%A_Index%Top && mouseYPos<=monitorSize%A_Index%Bottom)
                mouseIndex:=A_Index
        }

        for i,j in showArea
            i!=1?j<=maxArea?false:(maxArea:=j,winIndex:=i):(maxArea:=j,winIndex:=i)

        if(mouseIndex!=winIndex)
        {
            WinGet,MinMax,MinMax,ahk_id %lParam%
            if(MinMax=1)
            {
                WinRestore,ahk_id %lParam%
                WinGetPos,winXPos,winYPos,winWidth,winHeight,ahk_id %lParam%
            }
            if(winWidth>monitorSize%mouseIndex%Right-monitorSize%mouseIndex%Left || winHeight>monitorSize%mouseIndex%Bottom-monitorSize%mouseIndex%Top)
            {
                newWinXPos:=monitorSize%mouseIndex%Left, newWinYPos:=monitorSize%mouseIndex%Top
                WinMove,ahk_id %lParam%,,%newWinXPos%,%newWinYPos%
                WinMaximize,ahk_id %lParam%
            }
            else
            {
                winXPos<monitorSize%winIndex%Left || winXPos+winWidth>monitorSize%winIndex%Right?winXPos+winWidth/2-monitorSize%winIndex%Left<(monitorSize%winIndex%Right-monitorSize%winIndex%Left)/2?winWidthRatio:=0:winWidthRatio:=1:winWidthRatio:=(winXPos-monitorSize%winIndex%Left)/(monitorSize%winIndex%Right-monitorSize%winIndex%Left-winWidth)
                winYPos<monitorSize%winIndex%Top || winYPos+winHeight>monitorSize%winIndex%Bottom?winYPos+winHeight/2-monitorSize%winIndex%Top<(monitorSize%winIndex%Bottom-monitorSize%winIndex%Top)/2?winHeightRatio:=0:winHeightRatio:=1:winHeightRatio:=(winYPos-monitorSize%winIndex%Top)/(monitorSize%winIndex%Bottom-monitorSize%winIndex%Top-winHeight)
                newWinXPos:=monitorSize%mouseIndex%Left+(monitorSize%mouseIndex%Right-monitorSize%mouseIndex%Left-winWidth)*winWidthRatio,newWinYPos:=monitorSize%mouseIndex%Top+(monitorSize%mouseIndex%Bottom-monitorSize%mouseIndex%Top-winHeight)*winHeightRatio
                WinMove,ahk_id %lParam%,,%newWinXPos%,%newWinYPos%
                if(MinMax=1)
                    WinMaximize,ahk_id %lParam%
            }
        }
    }
}
;</MultipleMonitor>================================================
