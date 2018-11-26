;Created by Frankie
;Hold down the appskey and move the mouse to draw an arrow on the screen.
;Tap the appskey to remove the last arrow drawn.
;Thanks to Tic for the Gdi+ Library
;Thanks to Zed Gecko for help with the arrow point

#SingleInstance force
CoordMode, Mouse, Screen

If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, Exit

Width := A_ScreenWidth, Height := A_ScreenHeight
Window_D := Distance(0, 0, Width, Height)
TrayTip, Window_D, %Window_D%
Gui, 1: -Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
Gui, 1: Show, NA
hwnd1 := WinExist()
hbm := CreateDIBSection(Width, Height)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
G := Gdip_GraphicsFromHDC(hdc)
return

;You may change this hotkey to any single key without breaking the script
AppsKey::
Pressed_Time := A_TickCount
Loop, 4
{
	Sleep, 50
	If !( GetKeyState(A_ThisHotkey, "P") )
	{
		Gdip_GraphicsClear(G)
		Delete_One(List)
		Draw_Arrows(List)
		UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)
		return
	}
}

Add_One(List, 0,0,0,0) ;Dummy item to be deleted
MouseGetPos, StartX, StartY
While ( GetKeyState(A_ThisHotkey, "P") )
{
	MouseGetPos, MX, MY
	Gdip_GraphicsClear(G)
	Delete_One(List)
	Add_One(List, StartX, StartY, MX, MY)
	Draw_Arrows(List)
	UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)
}
return

Delete_One(ByRef List)
{
	global List_Count
	If !List
		return
	Loop, Parse, List, `n
		If (A_Index < List_Count)
			New_List .= A_LoopField . "`n"
	List := New_List
	List_Count -= 1
	return
}

Add_One(ByRef List, x1, y1, x2, y2)
{
	global List_Count
	Color := Get_Color()
	New = %x1%|%y1%|%x2%|%y2%|%Color%`n
	List .= New
	List_Count += 1
	return
}

Draw_Arrows(List) 
{ 
   global G, Window_D 
   ; define an arrow tip pointing right, front at 0/0 in polar 
   tip1_length := 30 
   tip1_angle := 150 ; degrees 
   tip2_length := 30 
   tip2_angle := 210 ; degrees 
   ; transform angle to radians 
   tip1_angle *= 0.01745329252 
   tip2_angle *= 0.01745329252 
   Loop, Parse, List, `n 
   { 
      StringSplit, Coord, A_Loopfield, | 
      pPen := Gdip_CreatePen(Coord5, 10) 
      ; move line to the base of the coord-system to ... 
      P2_X := Coord3 - Coord1 
      P2_Y := Coord4 - Coord2 
      ; get "direction the line is pointing to" 
      P2_r := Kart2Polar_r( P2_X, P2_Y) 
      P2_Phi := Kart2Polar_Phi( P2_X, P2_Y, P2_r) 
      ; rotate the arrow to the lines direction 
      curr_tip1_angle := tip1_angle + P2_Phi 
      curr_tip2_angle := tip2_angle + P2_Phi 
      ; transform arrow coord to cartesian    
      X1 := Round(Polar2Kart_X(tip1_length, curr_tip1_angle)) 
      X2 := Round(Polar2Kart_X(tip2_length, curr_tip2_angle)) 
      Y1 := Round(Polar2Kart_Y(tip1_length, curr_tip1_angle)) 
      Y2 := Round(Polar2Kart_Y(tip2_length, curr_tip2_angle)) 
      ; move arrow to the end of the line 
      X1 += Coord3 
      X2 += Coord3 
      Y1 += Coord4 
      Y2 += Coord4 
	  
      Points = %Coord1%,%Coord2%|%Coord3%,%Coord4% 
      PointArrow1 = %Coord3%,%Coord4%|%X1%,%Y1% 
      PointArrow2 = %Coord3%,%Coord4%|%X2%,%Y2% 
      TrayTip, Points, %PointArrow1%`n%PointArrow2% 
      Gdip_DrawLines(G, pPen, Points) 
      Gdip_DrawLines(G, pPen, PointArrow1) 
      Gdip_DrawLines(G, pPen, PointArrow2) 
      Gdip_DeletePen(pPen) 
   } 
   return 
}

Get_Color()
{
	Random, Red, 0, 225
	Random, Green, 0, 225
	Random, Blue, 0, 225
	Color := 0xFF000000
	Color += (Red << 16)
	Color += (Green << 8)
	Color += (Blue << 0)
	return (Color)
}

;Thanks to Zed Gecko for these four funtions
Polar2Kart_X(r, Phi)
{
   x := r * Cos(Phi)
   return x
}

Polar2Kart_Y(r, Phi)
{
   y := r * Sin(Phi)
   return y
}

Kart2Polar_r( x, y)
{
   r := Sqrt( (x*x) + (y*y) )
   return r
}

Kart2Polar_Phi(x, y, r)
{
   if (y < 0)
      Phi := -1 * ACos(x/r)
   else
      Phi := ACos(x/r)
   return Phi
}

;Currently this is not used
Distance(x1, y1, x2, y2)
{
	N := (x2-x1)**2 + (y2-y1)**2
	return ( sqrt(N) )
}


Exit:
Gdip_Shutdown(pToken)
ExitApp
Return