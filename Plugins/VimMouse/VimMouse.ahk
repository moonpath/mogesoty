;commenter le code de rotation et voir l'impact, je devrais pas avoir ce code dans le script

;utiliser le bouton du milieu de la souris dans firefox et visual studio et possiblement d'autres apps

;utiliser aussi les diagonales ca sauve des touches

#NoEnv
#NoTrayIcon
#SingleInstance force

usage = 
(
    usage:
    ctrl-; : Mouse activate/deactivate
    h/j/k/l : left/down/up/right (may be preceded by a numeric percentage prefix)
    u/n/o/. : left up/left down/right up/right down (diagonal movements, may be preceded by a numeric percentage prefix)
    Any number : Percentage prefix (how many percent of the screen to move the cursor, followed by movement keys h/j/k/l)
    q/w/e/r/t/a/g/z/x/c/v/b : Percentage prefix presets (press them to see their values, followed by movement keys h/j/k/l)
    f/space : left click
    d/p : middle click
    s/[ : right click
    i/m : mouse wheel up/down
    f1/f2 : mouse cursor speed down/up
    f3/f4 : mouse cursor acceleration speed /down/up
    f5/f6 : mouse cursor max speed down/up
    f7/f8 : mouse wheel speed down/up
    f9/f10 : mouse wheel acceleration down/up
    f11/f12 : mouse wheel max speed down/up
    -/=, + : speed increment (from how much to increment the speed up or down)
    win+(h/j/k/l) : left/down/up/right arrow
)
;msgbox ,, vimouse, %usage%

;START OF CONFIG SECTION

; De combien de pixel le curseur se deplace
MouseSpeed = 1
; La vitesse a laquelle le pointeur atteint sa vitesse maximal
MouseAccelerationSpeed = 600
; La vitesse maximal que la souris ira une fois acceleree
MouseMaxSpeed = 600
; Facteur d'incrementation de vitesse
SpeedIncrement = 10

NumPrefix := ""

;Mouse wheel speed is also set on Control Panel. As that
;will affect the normal mouse behavior, the real speed of
;these three below are times the normal mouse wheel speed.
MouseWheelSpeed = 1
MouseWheelAccelerationSpeed = 1
MouseWheelMaxSpeed = 1

MouseRotationAngle = 0

;END OF CONFIG SECTION

;This is needed or key presses would faulty send their natural
;actions. Like NumPadDiv would send sometimes "/" to the
;screen.       
#InstallKeybdHook

Temp = 0
Temp2 = 0

MouseCurrentAccelerationSpeed = 0
MouseCurrentSpeed = %MouseSpeed%

MouseWheelCurrentAccelerationSpeed = 0
MouseWheelCurrentSpeed = %MouseSpeed%

SetKeyDelay, -1
SetMouseDelay, -1

Hotkey, *f, ButtonLeftClick
Hotkey, *space, ButtonLeftClick
Hotkey, *d, ButtonMiddleClick
Hotkey, *p, ButtonMiddleClick
Hotkey, *s, ButtonRightClick
Hotkey, *[, ButtonRightClick

Hotkey, *i, ButtonWheelUp
Hotkey, *m, ButtonWheelDown

Hotkey, 0, Num0
Hotkey, 1, Num1
Hotkey, 2, Num2
Hotkey, 3, Num3
Hotkey, 4, Num4
Hotkey, 5, Num5
Hotkey, 6, Num6
Hotkey, 7, Num7
Hotkey, 8, Num8
Hotkey, 9, Num9

Hotkey, q, Num1
Hotkey, w, Num3
Hotkey, e, Num6
Hotkey, r, Num12
Hotkey, t, Num25

Hotkey, a, Num50
Hotkey, g, Num75

Hotkey, z, Num100
Hotkey, x, Num125
Hotkey, c, Num150
Hotkey, v, Num175
Hotkey, b, Num200

Hotkey, k, ButtonUp 
Hotkey, j, ButtonDown 
Hotkey, h, ButtonLeft 
Hotkey, l, ButtonRight 
Hotkey, u, ButtonUpLeft 
Hotkey, o, ButtonUpRight 
Hotkey, n, ButtonDownLeft 
Hotkey, ., ButtonDownRight 

Hotkey, f1, ButtonSpeedDown 
Hotkey, f2, ButtonSpeedUp
Hotkey, f3, ButtonAccelerationSpeedDown
Hotkey, f4, ButtonAccelerationSpeedUp
Hotkey, f5, ButtonMaxSpeedDown
Hotkey, f6, ButtonMaxSpeedUp

HotKey, #!Esc, Toggle ; Activate/Desactivate

Hotkey, f7, ButtonWheelSpeedDown
Hotkey, f8, ButtonWheelSpeedUp
Hotkey, f9, ButtonWheelAccelerationSpeedDown
Hotkey, f10, ButtonWheelAccelerationSpeedUp
Hotkey, f11, ButtonWheelMaxSpeedDown
Hotkey, f12, ButtonWheelMaxSpeedUp

Hotkey, +, SpeedIncrementUp
Hotkey, =, SpeedIncrementUp
Hotkey, -, SpeedIncrementDown

Hotkey, #h, Left
Hotkey, #j, Down
Hotkey, #k, up
Hotkey, #l, Right


Hotkey, *f, off
Hotkey, *space, off
Hotkey, *d, off
Hotkey, *p, off
Hotkey, *s, off
Hotkey, *[, off

Hotkey, *i, off
Hotkey, *m, off

Hotkey, k, off 
Hotkey, j, off 
Hotkey, h, off 
Hotkey, l, off 
Hotkey, u, off 
Hotkey, n, off 
Hotkey, o, off
Hotkey, ., off

Hotkey, f1, off
Hotkey, f2, off
Hotkey, f3, off
Hotkey, f4, off
Hotkey, f5, off
Hotkey, f6, off


Hotkey, 0, off
Hotkey, 1, off
Hotkey, 2, off
Hotkey, 3, off
Hotkey, 4, off
Hotkey, 5, off
Hotkey, 6, off
Hotkey, 7, off
Hotkey, 8, off
Hotkey, 9, off

Hotkey, q, off
Hotkey, w, off
Hotkey, e, off
Hotkey, r, off
Hotkey, t, off

Hotkey, a, off
Hotkey, g, off

Hotkey, z, off
Hotkey, x, off
Hotkey, c, off
Hotkey, v, off
Hotkey, b, off

Hotkey, f7, off
Hotkey, f8, off
Hotkey, f9, off
Hotkey, f10, off
Hotkey, f11, off
Hotkey, f12, off

Hotkey, +, off
Hotkey, =, off
Hotkey, -, off

Hotkey, #h, off
Hotkey, #j, off
Hotkey, #k, off
Hotkey, #l, off
return

;Key activation support
Toggle()
{
    static MouseActivated := false
    if (MouseActivated == false)
    {
        Hotkey, *f, on
        Hotkey, *space, on
        Hotkey, *d, on
        Hotkey, *p, on
        Hotkey, *s, on
        Hotkey, *[, on

        Hotkey, *i, on
        Hotkey, *m, on

        Hotkey, k, on 
        Hotkey, j, on 
        Hotkey, h, on 
        Hotkey, l, on 
        Hotkey, u, on 
        Hotkey, n, on 
        Hotkey, o, on 
        Hotkey, ., on 

        Hotkey, f1, on
        Hotkey, f2, on
        Hotkey, f3, on
        Hotkey, f4, on
        Hotkey, f5, on
        Hotkey, f6, on

        
        Hotkey, 0, on
        Hotkey, 1, on
        Hotkey, 2, on
        Hotkey, 3, on
        Hotkey, 4, on
        Hotkey, 5, on
        Hotkey, 6, on
        Hotkey, 7, on
        Hotkey, 8, on
        Hotkey, 9, on
        
        Hotkey, q, on
        Hotkey, w, on
        Hotkey, e, on
        Hotkey, r, on
        Hotkey, t, on

        Hotkey, a, on
        Hotkey, g, on

        Hotkey, z, on
        Hotkey, x, on
        Hotkey, c, on
        Hotkey, v, on
        Hotkey, b, on

        Hotkey, f7, on
        Hotkey, f8, on
        Hotkey, f9, on
        Hotkey, f10, on
        Hotkey, f11, on
        Hotkey, f12, on

        Hotkey, +, on
        Hotkey, =, on
        Hotkey, -, on

        Hotkey, #h, on
        Hotkey, #j, on
        Hotkey, #k, on
        Hotkey, #l, on

        ToolTip, Mouse Activated
        SetTimer, RemoveToolTip, 1000
        MouseActivated := true
    }
    else
    {
        Hotkey, *f, off
        Hotkey, *space, off
        Hotkey, *d, off
        Hotkey, *p, off
        Hotkey, *s, off
        Hotkey, *[, off

        Hotkey, *i, off
        Hotkey, *m, off

        Hotkey, k, off 
        Hotkey, j, off 
        Hotkey, h, off 
        Hotkey, l, off 
        Hotkey, u, off 
        Hotkey, n, off 
        Hotkey, o, off
        Hotkey, ., off

        Hotkey, f1, off
        Hotkey, f2, off
        Hotkey, f3, off
        Hotkey, f4, off
        Hotkey, f5, off
        Hotkey, f6, off

        
        Hotkey, 0, off
        Hotkey, 1, off
        Hotkey, 2, off
        Hotkey, 3, off
        Hotkey, 4, off
        Hotkey, 5, off
        Hotkey, 6, off
        Hotkey, 7, off
        Hotkey, 8, off
        Hotkey, 9, off
        
        Hotkey, q, off
        Hotkey, w, off
        Hotkey, e, off
        Hotkey, r, off
        Hotkey, t, off

        Hotkey, a, off
        Hotkey, g, off

        Hotkey, z, off
        Hotkey, x, off
        Hotkey, c, off
        Hotkey, v, off
        Hotkey, b, off

        Hotkey, f7, off
        Hotkey, f8, off
        Hotkey, f9, off
        Hotkey, f10, off
        Hotkey, f11, off
        Hotkey, f12, off

        Hotkey, +, off
        Hotkey, =, off
        Hotkey, -, off

        Hotkey, #h, off
        Hotkey, #j, off
        Hotkey, #k, off
        Hotkey, #l, off

        ToolTip, Mouse Deactivated
        SetTimer, RemoveToolTip, 1000
        MouseActivated := false
    }
}

;Mouse click support

ButtonLeftClick:
    GetKeyState, already_down_state, LButton
    If already_down_state = D
        return
    Button2 = f
    ButtonClick = Left
    Goto ButtonClickStart
    ButtonLeftClickIns:
    GetKeyState, already_down_state, LButton
    If already_down_state = D
        return
    Button2 = NumPadIns
    ButtonClick = Left
    Goto ButtonClickStart

ButtonMiddleClick:
    GetKeyState, already_down_state, MButton
    If already_down_state = D
        return
    Button2 = NumPad5
    ButtonClick = Middle
    Goto ButtonClickStart
    ButtonMiddleClickClear:
    GetKeyState, already_down_state, MButton
    If already_down_state = D
        return
    Button2 = NumPadClear
    ButtonClick = Middle
    Goto ButtonClickStart

ButtonRightClick:
    GetKeyState, already_down_state, RButton
    If already_down_state = D
        return
    Button2 = .
    ButtonClick = Right
    Goto ButtonClickStart
    ButtonRightClickDel:
    GetKeyState, already_down_state, RButton
    If already_down_state = D
        return
    Button2 = NumPadDel
    ButtonClick = Right
    Goto ButtonClickStart

ButtonX1Click:
    GetKeyState, already_down_state, XButton1
    If already_down_state = D
        return
    Button2 = NumPadDiv
    ButtonClick = X1
    Goto ButtonClickStart

ButtonX2Click:
    GetKeyState, already_down_state, XButton2
    If already_down_state = D
        return
    Button2 = NumPadMult
    ButtonClick = X2
    Goto ButtonClickStart

ButtonClickStart:
    MouseClick, %ButtonClick%,,, 1, 0, D
    SetTimer, ButtonClickEnd, 10
return

ButtonClickEnd:
    GetKeyState, kclickstate, %Button2%, P
    if kclickstate = D
        return

    SetTimer, ButtonClickEnd, off
    MouseClick, %ButtonClick%,,, 1, 0, U
return

;Mouse movement support

ButtonSpeedUp:
    MouseSpeed+=SpeedIncrement
    ToolTip, Mouse speed: %MouseSpeed% pixels
    SetTimer, RemoveToolTip, 1000
return

ButtonSpeedDown:
	MouseSpeed-=SpeedIncrement
    If MouseSpeed <= 1
    {
        MouseSpeed = 1
        ToolTip, Mouse speed: %MouseSpeed% pixel
    }
    else
        ToolTip, Mouse speed: %MouseSpeed% pixels
    SetTimer, RemoveToolTip, 1000
return

ButtonAccelerationSpeedUp:
    MouseAccelerationSpeed+=SpeedIncrement
    ToolTip, Mouse acceleration speed: %MouseAccelerationSpeed% pixels
    SetTimer, RemoveToolTip, 1000
return

ButtonAccelerationSpeedDown:
	MouseAccelerationSpeed-=SpeedIncrement
    If MouseAccelerationSpeed <= 1
    {
        MouseAccelerationSpeed = 1
        ToolTip, Mouse acceleration speed: %MouseAccelerationSpeed% pixel
    }
    else
        ToolTip, Mouse acceleration speed: %MouseAccelerationSpeed% pixels
    SetTimer, RemoveToolTip, 1000
return

MouseCurrentSpeed = %MouseSpeed%
ToolTip, Mouse jump speed: %MouseSpeed% pixels
SetTimer, RemoveToolTip, 1000
return

Num0:
    NumPrefix .= 0 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
Num1:
    NumPrefix .= 1 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
Num2:
    NumPrefix .= 2 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
Num3:
    NumPrefix .= 3 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
Num4:
    NumPrefix .= 4 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
Num5:
    NumPrefix .= 5 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
Num6:
    NumPrefix .= 6 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
Num7:
    NumPrefix .= 7 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
Num8:
    NumPrefix .= 8 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
Num9:
    NumPrefix .= 9 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
Num12:
    NumPrefix = 12 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
Num25:
    NumPrefix = 25 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
Num50:
    NumPrefix = 50 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
Num75:
    NumPrefix = 75 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
Num100:
    NumPrefix = 100 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return
num125:
    numprefix = 125 
    tooltip, %numprefix%`% 
    settimer, removetooltip, 1000
return
num150:
    numprefix = 150 
    tooltip, %numprefix%`% 
    settimer, removetooltip, 1000
return
num175:
    numprefix = 175 
    tooltip, %numprefix%`% 
    settimer, removetooltip, 1000
return
Num200:
    NumPrefix = 200 
    ToolTip, %NumPrefix%`% 
    SetTimer, RemoveToolTip, 1000
return

ButtonMaxSpeedUp:
    MouseMaxSpeed+=SpeedIncrement
    ToolTip, Mouse maximum speed: %MouseMaxSpeed% pixels
    SetTimer, RemoveToolTip, 1000
    return
    ButtonMaxSpeedDown:
        MouseMaxSpeed-=SpeedIncrement 
        If MouseMaxSpeed <= 1
        {
            MouseMaxSpeed = 1
            ToolTip, Mouse maximum speed: %MouseMaxSpeed% pixel
        }
        else
            ToolTip, Mouse maximum speed: %MouseMaxSpeed% pixels
        SetTimer, RemoveToolTip, 1000
return

ButtonRotationAngleUp:
    MouseRotationAnglePart++
    If MouseRotationAnglePart >= 8
        MouseRotationAnglePart = 0
    MouseRotationAngle = %MouseRotationAnglePart%
    MouseRotationAngle *= 45
    ToolTip, Mouse rotation angle: %MouseRotationAngle%°
    SetTimer, RemoveToolTip, 1000
    return
    ButtonRotationAngleDown:
    MouseRotationAnglePart--
    If MouseRotationAnglePart < 0
        MouseRotationAnglePart = 7
    MouseRotationAngle = %MouseRotationAnglePart%
    MouseRotationAngle *= 45
    ToolTip, Mouse rotation angle: %MouseRotationAngle%°
    SetTimer, RemoveToolTip, 1000		
return

ButtonUp:
ButtonDown:
ButtonLeft:
ButtonRight:
ButtonUpLeft:
ButtonUpRight:
ButtonDownLeft:
ButtonDownRight:
    If Button <> 0
    {
        IfNotInString, A_ThisHotkey, %Button%
        {
            MouseCurrentAccelerationSpeed = 0
            MouseCurrentSpeed = %MouseSpeed%
        }
    }
    StringReplace, Button, A_ThisHotkey, *

    ButtonAccelerationStart:
    If MouseAccelerationSpeed >= 1
    {
        If MouseMaxSpeed > %MouseCurrentSpeed%
    {
            Temp = 0.001
            Temp *= %MouseAccelerationSpeed%
            MouseCurrentAccelerationSpeed += %Temp%
            MouseCurrentSpeed += %MouseCurrentAccelerationSpeed%
        }
    }

    ;MouseRotationAngle convertion to speed of button direction
    {
        MouseCurrentSpeedToDirection = %MouseRotationAngle%
        MouseCurrentSpeedToDirection /= 90.0
        Temp = %MouseCurrentSpeedToDirection%

        if Temp >= 0
        {
            if Temp < 1
            {
                MouseCurrentSpeedToDirection = 1
                MouseCurrentSpeedToDirection -= %Temp%
                Goto EndMouseCurrentSpeedToDirectionCalculation
            }
        }
        if Temp >= 1
        {
            if Temp < 2
            {
                MouseCurrentSpeedToDirection = 0
                Temp -= 1
                MouseCurrentSpeedToDirection -= %Temp%
                Goto EndMouseCurrentSpeedToDirectionCalculation
            }
        }
        if Temp >= 2
        {
            if Temp < 3
            {
                MouseCurrentSpeedToDirection = -1
                Temp -= 2
                MouseCurrentSpeedToDirection += %Temp%
                Goto EndMouseCurrentSpeedToDirectionCalculation
            }
        }
        if Temp >= 3
        {
            if Temp < 4
            {
                MouseCurrentSpeedToDirection = 0
                Temp -= 3
                MouseCurrentSpeedToDirection += %Temp%
                Goto EndMouseCurrentSpeedToDirectionCalculation
            }
        }
    }
    EndMouseCurrentSpeedToDirectionCalculation:

    ;MouseRotationAngle convertion to speed of 90 degrees to right
    {
        MouseCurrentSpeedToSide = %MouseRotationAngle%
        MouseCurrentSpeedToSide /= 90.0
        Temp = %MouseCurrentSpeedToSide%
        Transform, Temp, mod, %Temp%, 4

        if Temp >= 0
        {
            if Temp < 1
            {
                MouseCurrentSpeedToSide = 0
                MouseCurrentSpeedToSide += %Temp%
                Goto EndMouseCurrentSpeedToSideCalculation
            }
        }
        if Temp >= 1
        {
            if Temp < 2
            {
                MouseCurrentSpeedToSide = 1
                Temp -= 1
                MouseCurrentSpeedToSide -= %Temp%
                Goto EndMouseCurrentSpeedToSideCalculation
            }
        }
        if Temp >= 2
        {
            if Temp < 3
            {
                MouseCurrentSpeedToSide = 0
                Temp -= 2
                MouseCurrentSpeedToSide -= %Temp%
                Goto EndMouseCurrentSpeedToSideCalculation
            }
        }
        if Temp >= 3
        {
            if Temp < 4
            {
                MouseCurrentSpeedToSide = -1
                Temp -= 3
                MouseCurrentSpeedToSide += %Temp%
                Goto EndMouseCurrentSpeedToSideCalculation
            }
        }
    }
    EndMouseCurrentSpeedToSideCalculation:

    MouseCurrentSpeedToDirection *= %MouseCurrentSpeed%
    MouseCurrentSpeedToSide *= %MouseCurrentSpeed%

    Temp = %MouseRotationAnglePart%
    Transform, Temp, Mod, %Temp%, 2

    If Button = k 
    {
        if NumPrefix is number 
        {
            Percent := NumPrefix , Percent += 0 ; convert to number
            Offset := Ceil((Percent * A_ScreenHeight) / 100)
            MouseGetPos, xpos, ypos 
            MouseMove, xpos, ypos - Offset, 0
            ToolTip, Moved %Percent%`% (%Offset% pixels)
            SetTimer, RemoveToolTip, 1000
            NumPrefix := ""
            Button := ""
        }
        else
        {
            if Temp = 1
            {
                MouseCurrentSpeedToSide *= 2
                MouseCurrentSpeedToDirection *= 2
            }
            MouseCurrentSpeedToDirection *= -1
            MouseMove, %MouseCurrentSpeedToSide%, %MouseCurrentSpeedToDirection%, 1, R
        }
    }
    else if Button = j 
    {
        if NumPrefix is number 
        {
            Percent := NumPrefix , Percent += 0 ; convert to number
            Offset := Ceil((Percent * A_ScreenHeight) / 100)
            MouseGetPos, xpos, ypos 
            MouseMove, xpos, ypos + Offset, 0
            ToolTip, Moved %Percent%`% (%Offset% pixels)
            SetTimer, RemoveToolTip, 1000
            NumPrefix := ""
            Button := ""
        }
        else
        {
            if Temp = 1
            {
                MouseCurrentSpeedToSide *= 2
                MouseCurrentSpeedToDirection *= 2
            }
            MouseCurrentSpeedToSide *= -1
            MouseMove, %MouseCurrentSpeedToSide%, %MouseCurrentSpeedToDirection%, 0, R
        }
    }
    ;else if Button = NumPadLeft 
    else if Button = h 
    {
        if NumPrefix is number 
        {
            Percent := NumPrefix , Percent += 0 ; convert to number
            Offset := Ceil((Percent * A_ScreenWidth) / 100)
            MouseGetPos, xpos, ypos 
            MouseMove, xpos - Offset, ypos, 0
            ToolTip, Moved %Percent%`% (%Offset% pixels)
            SetTimer, RemoveToolTip, 1000
            NumPrefix := ""
            Button := ""
        }
        else
        {
            if Temp = 1
            {
                MouseCurrentSpeedToSide *= 2
                MouseCurrentSpeedToDirection *= 2
            }
            MouseCurrentSpeedToSide *= -1
            MouseCurrentSpeedToDirection *= -1
            MouseMove, %MouseCurrentSpeedToDirection%, %MouseCurrentSpeedToSide%, 0, R
        }
    }
    else if Button = l 
    {
        if NumPrefix is number 
        {
            Percent := NumPrefix , Percent += 0 ; convert to number
            Offset := Ceil((Percent * A_ScreenWidth) / 100)
            MouseGetPos, xpos, ypos 
            MouseMove, xpos + Offset, ypos, 0
            ToolTip, Moved %Percent%`% (%Offset% pixels)
            SetTimer, RemoveToolTip, 1000
            NumPrefix := ""
            Button := ""
        }
        else
        {
            if Temp = 1
            {
                MouseCurrentSpeedToSide *= 2
                MouseCurrentSpeedToDirection *= 2
            }
            MouseMove, %MouseCurrentSpeedToDirection%, %MouseCurrentSpeedToSide%, 0, R
        }
    }
    else if Button = u 
    {
        if NumPrefix is number 
        {
            Percent := NumPrefix , Percent += 0 ; convert to number
            if %Percent% = 0
                Percent := 100
            Offset := Ceil((Percent * A_ScreenWidth) / 100)
            MouseGetPos, xpos, ypos 
            MouseMove, xpos - Offset, ypos - Offset, 0
            ToolTip, Moved %Percent%`% (%Offset% pixels)
            SetTimer, RemoveToolTip, 1000
            NumPrefix := ""
            Button := ""
        }
        else
        {
            Temp = %MouseCurrentSpeedToDirection%
            Temp -= %MouseCurrentSpeedToSide%
            Temp *= -1
            Temp2 = %MouseCurrentSpeedToDirection%
            Temp2 += %MouseCurrentSpeedToSide%
            Temp2 *= -1
            MouseMove, %Temp%, %Temp2%, 0, R
        }
    }
    else if Button = o 
    {
        if NumPrefix is number 
        {
            Percent := NumPrefix , Percent += 0 ; convert to number
            Offset := Ceil((Percent * A_ScreenWidth) / 100)
            MouseGetPos, xpos, ypos 
            MouseMove, xpos + Offset, ypos - Offset, 0
            ToolTip, Moved %Percent%`% (%Offset% pixels)
            SetTimer, RemoveToolTip, 1000
            NumPrefix := ""
            Button := ""
        }
        else
        {
            Temp = %MouseCurrentSpeedToDirection%
            Temp += %MouseCurrentSpeedToSide%
            Temp2 = %MouseCurrentSpeedToDirection%
            Temp2 -= %MouseCurrentSpeedToSide%
            Temp2 *= -1
            MouseMove, %Temp%, %Temp2%, 0, R
        }
    }
    else if Button = n 
    {
        if NumPrefix is number 
        {
            Percent := NumPrefix , Percent += 0 ; convert to number
            Offset := Ceil((Percent * A_ScreenWidth) / 100)
            MouseGetPos, xpos, ypos 
            MouseMove, xpos - Offset, ypos + Offset, 0
            ToolTip, Moved %Percent%`% (%Offset% pixels)
            SetTimer, RemoveToolTip, 1000
            NumPrefix := ""
            Button := ""
        }
        else
        {
            Temp = %MouseCurrentSpeedToDirection%
            Temp += %MouseCurrentSpeedToSide%
            Temp *= -1
            Temp2 = %MouseCurrentSpeedToDirection%
            Temp2 -= %MouseCurrentSpeedToSide%
            MouseMove, %Temp%, %Temp2%, 0, R
        }
    }
    else if Button = . 
    {
        if NumPrefix is number 
        {
            Percent := NumPrefix , Percent += 0 ; convert to number
            if %Percent% = 0
                Percent := 100
            Offset := Ceil((Percent * A_ScreenWidth) / 100)
            MouseGetPos, xpos, ypos 
            MouseMove, xpos + Offset, ypos + Offset, 0
            ToolTip, Moved %Percent%`% (%Offset% pixels)
            SetTimer, RemoveToolTip, 1000
            NumPrefix := ""
            Button := ""
        }
        else
        {
            Temp = %MouseCurrentSpeedToDirection%
            Temp -= %MouseCurrentSpeedToSide%
            Temp2 *= -1
            Temp2 = %MouseCurrentSpeedToDirection%
            Temp2 += %MouseCurrentSpeedToSide%
            MouseMove, %Temp%, %Temp2%, 0, R
        }
    }

    SetTimer, ButtonAccelerationEnd, 10
return

ButtonAccelerationEnd:
    GetKeyState, kstate, %Button%, P
    if kstate = D
        Goto ButtonAccelerationStart

    SetTimer, ButtonAccelerationEnd, off
    MouseCurrentAccelerationSpeed = 0
    MouseCurrentSpeed = %MouseSpeed%
    Button = 0
return

;Mouse wheel movement support

ButtonWheelSpeedUp:
    MouseWheelSpeed+=SpeedIncrement
    RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
    If MouseWheelSpeedMultiplier <= 0
        MouseWheelSpeedMultiplier = 1
    MouseWheelSpeedReal = %MouseWheelSpeed%
    MouseWheelSpeedReal *= %MouseWheelSpeedMultiplier%
    ToolTip, Mouse wheel speed: %MouseWheelSpeedReal% lines
    SetTimer, RemoveToolTip, 1000
return

ButtonWheelSpeedDown:
    RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
    If MouseWheelSpeedMultiplier <= 0
        MouseWheelSpeedMultiplier = 1
    MouseWheelSpeedReal = 1
    If MouseWheelSpeedReal > %MouseWheelSpeedMultiplier%
    {
        MouseWheelSpeed-=SpeedIncrement
        MouseWheelSpeedReal = %MouseWheelSpeed%
        MouseWheelSpeedReal *= %MouseWheelSpeedMultiplier%
    }
    If MouseWheelSpeedReal = 1
        ToolTip, Mouse wheel speed: %MouseWheelSpeedReal% line
    else
        ToolTip, Mouse wheel speed: %MouseWheelSpeedReal% lines
    SetTimer, RemoveToolTip, 1000
return

ButtonWheelAccelerationSpeedUp:
    MouseWheelAccelerationSpeed+=SpeedIncrement
    RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
    If MouseWheelSpeedMultiplier <= 0
        MouseWheelSpeedMultiplier = 1
    MouseWheelAccelerationSpeedReal = %MouseWheelAccelerationSpeed%
    MouseWheelAccelerationSpeedReal *= %MouseWheelSpeedMultiplier%
    ToolTip, Mouse wheel acceleration speed: %MouseWheelAccelerationSpeedReal% lines
    SetTimer, RemoveToolTip, 1000
return

ButtonWheelAccelerationSpeedDown:
    RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
    If MouseWheelSpeedMultiplier <= 0
        MouseWheelSpeedMultiplier = 1
    MouseWheelAccelerationSpeedReal = 1
    If MouseWheelAccelerationSpeed > 1
    {
        MouseWheelAccelerationSpeed-=SpeedIncrement
        MouseWheelAccelerationSpeedReal = %MouseWheelAccelerationSpeed%
        MouseWheelAccelerationSpeedReal *= %MouseWheelSpeedMultiplier%
    }
    If MouseWheelAccelerationSpeedReal = 1
        ToolTip, Mouse wheel acceleration speed: %MouseWheelAccelerationSpeedReal% line
    else
        ToolTip, Mouse wheel acceleration speed: %MouseWheelAccelerationSpeedReal% lines
    SetTimer, RemoveToolTip, 1000
return

ButtonWheelMaxSpeedUp:
    MouseWheelMaxSpeed+=SpeedIncrement
    RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
    If MouseWheelSpeedMultiplier <= 0
        MouseWheelSpeedMultiplier = 1
    MouseWheelMaxSpeedReal = %MouseWheelMaxSpeed%
    MouseWheelMaxSpeedReal *= %MouseWheelSpeedMultiplier%
    ToolTip, Mouse wheel maximum speed: %MouseWheelMaxSpeedReal% lines
    SetTimer, RemoveToolTip, 1000
return

ButtonWheelMaxSpeedDown:
    RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
    If MouseWheelSpeedMultiplier <= 0
        MouseWheelSpeedMultiplier = 1
    MouseWheelMaxSpeedReal = 1
    If MouseWheelMaxSpeed > 1
    {
        MouseWheelMaxSpeed-=SpeedIncrement
        MouseWheelMaxSpeedReal = %MouseWheelMaxSpeed%
        MouseWheelMaxSpeedReal *= %MouseWheelSpeedMultiplier%
    }
    If MouseWheelMaxSpeedReal = 1
        ToolTip, Mouse wheel maximum speed: %MouseWheelMaxSpeedReal% line
    else
        ToolTip, Mouse wheel maximum speed: %MouseWheelMaxSpeedReal% lines
    SetTimer, RemoveToolTip, 1000
return

ButtonWheelUp:
ButtonWheelDown:

If Button <> 0
{
	If Button <> %A_ThisHotkey%
	{
		MouseWheelCurrentAccelerationSpeed = 0
		MouseWheelCurrentSpeed = %MouseWheelSpeed%
	}
}
StringReplace, Button, A_ThisHotkey, *

ButtonWheelAccelerationStart:
    If MouseWheelAccelerationSpeed >= 1
    {
        If MouseWheelMaxSpeed > %MouseWheelCurrentSpeed%
        {
            Temp = 0.001
            Temp *= %MouseWheelAccelerationSpeed%
            MouseWheelCurrentAccelerationSpeed += %Temp%
            MouseWheelCurrentSpeed += %MouseWheelCurrentAccelerationSpeed%
        }
    }

    If Button = i 
        MouseClick, wheelup,,, %MouseWheelCurrentSpeed%, 0, D
    else if Button = m
        MouseClick, wheeldown,,, %MouseWheelCurrentSpeed%, 0, D

    SetTimer, ButtonWheelAccelerationEnd, 100
return

ButtonWheelAccelerationEnd:
    GetKeyState, kstate, %Button%, P
    if kstate = D
        Goto ButtonWheelAccelerationStart

    MouseWheelCurrentAccelerationSpeed = 0
    MouseWheelCurrentSpeed = %MouseWheelSpeed%
    Button = 0
    return

    RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
return

SpeedIncrementUp:
    SpeedIncrement++
	ToolTip, Speed increment: %SpeedIncrement% pixels
    SetTimer, RemoveToolTip, 1000
return

SpeedIncrementDown:
    SpeedIncrement--
    if SpeedIncrement < 0 
        SpeedIncrement = 0
	ToolTip, Speed increment: %SpeedIncrement% pixels
    SetTimer, RemoveToolTip, 1000
return

Left:
    Send {Left}
return

Down:
    Send {Down}
return

Up:
    Send {Up}
return

Right:
    Send {Right}
return
