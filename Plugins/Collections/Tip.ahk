text := "Click here to launch Google"

ok := new ok()
ok.load()
ok.aa.Notify("aaa")

class ok
{
	__new()
	{
		return this
	}
	
	load()
	{
		this.aa:=new this.Notification()
	}
	
	class Notification
	{
		__new(Font:="Verdana", FontSize:=11, Width:=300, Color := "Black", Transparent:=220)
		{
			this.Font := Font
			this.FontSize := FontSize
			this.Width := Width
			this.Color := Color
			this.Transparent := Transparent
			return this
		}

		Notify(text)
		{
			Font := this.Font
			FontSize := this.FontSize
			Width := this.Width
			Color := this.Color
			Transparent := this.Transparent
			Gui,tip: Destroy
			text := "`n" . text . "`n"
			SysGet, WorkArea, MonitorWorkArea
			Gui,tip: New, -Caption +AlwaysOnTop +HwndtipHwnd +ToolWindow +Border +LastFound
			Gui,tip: Margin, , 0
			Gui,tip: Color,% Color
			Gui,tip: +LastFound
			WinSet, Transparent, 0
			Gui,tip: Font, s%FontSize% bold,% Font
			Gui,tip: Add, Text, cWhite gGuiDestroy W%Width%,% text
			GuiControlGet, TextSize, tip:Pos, Static1
			Xpos := WorkAreaRight - Width - 18
			Ypos := WorkAreaBottom - TextSizeH - 2 - 12
			Gui,tip: Show, X%Xpos% Y%Ypos% W%Width%
			SoundPlay, *-1
			BoundFade := this.Fade.bind(this,tipHwnd,Transparent)
			SetTimer,% BoundFade, -1
			return
			GuiDestroy:
			Gui,tip: Destroy
			return
		}

		Fade(Hwnd, Transparent)
		{
			diff := 0
			while(diff < Transparent)
			{
				Gui,tip: +LastFound
				WinSet, Transparent,% diff
				diff += 3
				Sleep, 10
			}
			Sleep, 3000
			MouseGetPos, , , OutputVarWin
			while(diff > 0)
			{
				MouseGetPos, , , HoveredWin
				if(Hwnd == HoveredWin)
					diff := Transparent
				Gui,tip: +LastFound
				WinSet, Transparent,% diff
				diff -= 3
				Sleep, 10
			}
			Gui,tip: Destroy
			return
		}
	}
}
