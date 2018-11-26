#SingleInstance, Force
#NoEnv
#NoTrayIcon
SetBatchLines, -1

If !pToken := Gdip_Startup()
{
    MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
    ExitApp
}

OnExit, Exit

S:=400
Width := S, Height := S

Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs +HwndthisHwnd
Gui, 1: Show, NA
hwnd1 := WinExist()
hbm := CreateDIBSection(Width, Height)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
G := Gdip_GraphicsFromHDC(hdc)
Gdip_SetSmoothingMode(G, 4)
pBrush := Gdip_BrushCreateSolid(0xAF222222)
cBrush := Gdip_BrushCreateSolid(0x77000000)

p1_x:=S/2
p1_y:=0
p2_x:=S/2-Sqrt(3)*S/12
p2_y:=S/4
p3_x:=S/2
p3_y:=S/2
p4_x:=S/2+Sqrt(3)*S/12
p4_y:=S/4
Gdip_FillPolygon(G, pBrush,  p1_x . "," . p1_y . "|" . p2_x . "," . p2_y . "|" . p3_x . "," . p3_y . "|" . p4_x . "," . p4_y, FillMode=0)

p1_x:=S
p1_y:=S/2
p2_x:=S/2+S/4
p2_y:=S/2-Sqrt(3)*S/12
p3_x:=S/2
p3_y:=S/2
p4_x:=S/2+S/4
p4_y:=S/2+Sqrt(3)*S/12
Gdip_FillPolygon(G, pBrush,  p1_x . "," . p1_y . "|" . p2_x . "," . p2_y . "|" . p3_x . "," . p3_y . "|" . p4_x . "," . p4_y, FillMode=0)

p1_x:=S/2
p1_y:=S
p2_x:=S/2+Sqrt(3)*S/12
p2_y:=S-S/4
p3_x:=S/2
p3_y:=S/2
p4_x:=S/2-Sqrt(3)*S/12
p4_y:=S-S/4
Gdip_FillPolygon(G, pBrush,  p1_x . "," . p1_y . "|" . p2_x . "," . p2_y . "|" . p3_x . "," . p3_y . "|" . p4_x . "," . p4_y, FillMode=0)

p1_x:=0
p1_y:=S/2
p2_x:=S/4
p2_y:=S/2+Sqrt(3)*S/12
p3_x:=S/2
p3_y:=S/2
p4_x:=S/4
p4_y:=S/2-Sqrt(3)*S/12
Gdip_FillPolygon(G, pBrush,  p1_x . "," . p1_y . "|" . p2_x . "," . p2_y . "|" . p3_x . "," . p3_y . "|" . p4_x . "," . p4_y, FillMode=0)

Gdip_DeleteBrush(pBrush)
Gdip_DeleteBrush(cBrush)

UpdateLayeredWindow(hwnd1, hdc, (A_ScreenWidth-Width)/2, (A_ScreenHeight-Height)/2, Width, Height)

OnMessage(0x201, "WM_LBUTTONDOWN")

SelectObject(hdc, obm)
DeleteObject(hbm)
DeleteDC(hdc)
Gdip_DeleteGraphics(G)

Sleep,2000

goto,Exit

Return

WM_LBUTTONDOWN()
{
    PostMessage, 0xA1, 2
    return
}

Exit:
Gdip_Shutdown(pToken)
ExitApp
Return
