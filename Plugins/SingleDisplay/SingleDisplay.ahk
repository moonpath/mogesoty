#SingleInstance,Force
SetWinDelay,1

Func("SingleDisplay").Call()

SingleDisplay(activeWinID:="")
{
    while(true)
    {
        WinGet,style,Style,ahk_id %activeWinID%
        WinGetTitle,title,ahk_id %activeWinID%
        if((style & 0x20000)&&title)
        {
            WinGet,winIDList,List
            Loop,%winIDList% 
            {
                WinGet,style,Style,% "ahk_id" . winIDList%A_Index%
                WinGet,minMax,MinMax,% "ahk_id" . winIDList%A_Index%
                WinGetTitle,title,% "ahk_id" . winIDList%A_Index%
                if(minMax!=-1&&(style & 0x20000)&&title&&activeWinID!=winIDList%A_Index%)
                    WinMinimize,% "ahk_id" . winIDList%A_Index%
          }
        }
        WinWaitNotActive,ahk_id %activeWinID%
        WinGet,activeWinID,ID,A
    }
    return
}
