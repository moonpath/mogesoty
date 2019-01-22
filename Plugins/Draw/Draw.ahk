#Persistent
#SingleInstance force

SetBatchLines,-1

trail := new Draw()

;OnMessage(0x4a, "ReceiveMessage")

Mbutton::
trail.StartTrail()
return

Mbutton Up::
trail.StopTrail()
return

~WheelDown::
trail.StopTrail()
trail.ClearTrail()
return

~^Mbutton::
trail.StartEraseTrail()
return

~^Mbutton Up::
trail.StopEraseTrail()
return

~#F4::ExitApp

class Draw
{
    __New(trailColor:=0x800080,trailWidth:=4)
    {
        Gui, Trail:New
        Gui, Trail:+HwndtrailHwnd -Caption +ToolWindow +AlwaysOnTop +LastFound 
        Gui, Trail:Color, 008080
        this.trailHwnd := trailHwnd
        BoundDrawLine := this.DrawLine.bind(this)
        this.BoundDrawLine := BoundDrawLine
        this.trailColor := trailColor
        this.trailWidth := trailWidth
        WinSet, TransColor, 008080
        WinSet, ExStyle, +0x00000020, ahk_id %trailHwnd%
        SysGet, SM_XVIRTUALSCREEN, 76
        SysGet, SM_YVIRTUALSCREEN, 77
        SysGet, SM_CXVIRTUALSCREEN, 78
        SysGet, SM_CYVIRTUALSCREEN, 79
        this.SM_XVIRTUALSCREEN := SM_XVIRTUALSCREEN
        this.SM_YVIRTUALSCREEN := SM_YVIRTUALSCREEN
        Gui, Trail:Show, x%SM_XVIRTUALSCREEN% y%SM_YVIRTUALSCREEN% w%SM_CXVIRTUALSCREEN% h%SM_CYVIRTUALSCREEN% NA
        return this
    }

    StartTrail()
    {
        CoordMode, Mouse, Screen
        MouseGetPos, pre_x, pre_y
        this.pre_x := pre_x, this.pre_y := pre_y
        Gui, Trail:+AlwaysOnTop +LastFound
        BoundDrawLine := this.BoundDrawLine
        SetTimer, %BoundDrawLine%, 10
        return
    }

    StopTrail()
    {
        BoundDrawLine := this.BoundDrawLine
        SetTimer, %BoundDrawLine%, Delete
        return
    }
    
    StartEraseTrail()
    {
        this.trailColor := "0x808000"
        this.trailWidth := 10
        CoordMode, Mouse, Screen
        MouseGetPos, pre_x, pre_y
        this.pre_x := pre_x, this.pre_y := pre_y
        BoundDrawLine := this.BoundDrawLine
        SetTimer, %BoundDrawLine%, 10
        return
    }
    
    StopEraseTrail()
    {
        BoundDrawLine := this.BoundDrawLine
        SetTimer, %BoundDrawLine%, Delete
        this.trailColor := "0x800080"
        this.trailWidth := 4
        return
    }
    
    ClearTrail()
    {
        trailHWnd := this.trailHWnd
        WinSet, Redraw,, ahk_id %trailHWnd%
    }

    DrawLine()
    {
        CoordMode, Mouse, Screen
        MouseGetPos, cur_x, cur_y
        if((this.pre_x-cur_x)**2+(this.pre_y-cur_y)**2 <= 1**2)
            return
        hDC := DllCall("GetDC", UInt, this.trailHWnd)
        hCurrPen := DllCall("CreatePen", UInt, 0, UInt, this.trailWidth, UInt, this.trailcolor)
        DllCall("SelectObject", UInt,hdc, UInt,hCurrPen)
        DllCall("gdi32.dll\MoveToEx", UInt, hdc, Uint,this.pre_x-this.SM_XVIRTUALSCREEN, Uint, this.pre_y-this.SM_YVIRTUALSCREEN, Uint, 0)
        DllCall("gdi32.dll\LineTo", UInt, hdc, Uint, cur_x-this.SM_XVIRTUALSCREEN, Uint, cur_y-this.SM_YVIRTUALSCREEN)
        DllCall("ReleaseDC", UInt, 0, UInt, hDC)
        DllCall("DeleteObject", UInt,hCurrPen)
        this.pre_x := cur_x
        this.pre_y := cur_y
        return
    }
}

ReceiveMessage(wParam, lParam)
{
  StringAddress := NumGet(lParam + 2*A_PtrSize)
  CopyOfData := StrGet(StringAddress)
  if(CopyOfData=0x12)
      ExitApp
  return true
}
