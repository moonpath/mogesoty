;Client
#SingleInstance force
#include socket.ahk
SetWorkingDir %A_ScriptDir%

myTcp := new SocketTCP()
myTcp.connect("localhost", 12345)
MsgBox, % myTcp.recvText()
;FileRead,keyLog,Key.log
InputBox,text,Client,Please Enter The Text To Be Sent:
myTcp.sendText(text)
ExitApp
