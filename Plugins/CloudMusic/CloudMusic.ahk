#Persistent
#SingleInstance Force

WinGet,ID,ID,ahk_exe cloudmusic.exe ahk_class OrpheusBrowserHost
WinGetTitle,Title,% "ahk_id" . ID
i := 400
while(i-- > 0)
{
    if(Title != prevTitle)
    {
        FileAppend,% Title . "`n",D:/Desktop/music.txt
        prevTitle := Title
    }
    SendInput, {Media_Next}
    Sleep,1000
    WinGetTitle,Title,% "ahk_id" . ID
}
