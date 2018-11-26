; Old script drew four rectangles to create a box around controls; this
; modification changes it to show a single, transparent, click-through overlay

; Box_Init - Creates the necessary GUIs.
; C - The color of the box.
Box_Init(C="FF0000") {
  ; Added WS_EXTENDED_TRANSPARENT to make the overlay click-through
  Gui,+E0x20 +ToolWindow -Caption +AlwaysOnTop +LastFound
  ; Set window to 50% transparency
  WinSet,Transparent,128
  Gui,Color, % C
}

; Box_Draw - Draws a box on the screen using 4 GUIs.
; X - The X coord.
; Y - The Y coord.
; W - The width of the box.
; H - The height of the box.
Box_Draw(X, Y, W, H, O="I") {
  ; No longer adding to the height since using only a single rectangle
  If(W < 0)
    X += W, W *= -1
  If(H < 0)
    Y += H, H *= -1
  ; Removed the options and calculation for the border (T and O) since it no
  ; longer applies. Now the drawing dimensions are completely straight-forward.
  Gui, Show, % "x" X " y" Y " w" W " h" H " NA"
}

; Box_Destroy - Destoyes the 4 GUIs.
Box_Destroy() {
  Gui,Destroy
}

; Box_Hide - Hides the GUI.
Box_Hide() {
  Gui,Hide
}

; Initialize the script and overlay
#SingleInstance,force
SetBatchLines, -1
SetWinDelay, -1
Box_Init("4B0082")

; Track the mouse position and draw an overlay over the control being hovered over
Loop {
  MouseGetPos, , , Window, Control, 2
  WinGetPos, X1, Y1, , , ahk_id %Window%
  ControlGetPos, X, Y, W, H, , ahk_id %Control%
  if (X)
    Box_Draw(X + X1, Y + Y1, W, H)
  Sleep, 10
}

; Convenient way to quit (useful when not using transparency—oops)
esc::exitapp