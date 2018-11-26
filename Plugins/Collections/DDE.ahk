; DDE_InitServer( ApplicationName, TopicName, LabelName [, LeaveCriticalOn ] )
;   Sets up the script to receive DDE "execute" requests. This function should
;   be called at the top of the script in order to support associating file
;   types with scripts via DDE. (See the comment above "Critical 500".)
;
; ApplicationName:
;   Identifies the application/DDE server.
;   Windows XP: This is the "Application" field of the file type action dialog.
;
; TopicName:
;   The topic of DDE "conversation".
;   Windows XP: This is the "Topic" field of the file type action dialog.
;               Since this field cannot be empty, TopicName must be specified.
;
; LabelName:
;   The label to execute when WM_DDE_EXECUTE is received.
;   DDE_Cmd will contain the command-line to execute.
;   In Windows XP, this is one of the following fields, depending on whether
;     the script was running when the relevant action was executed:
;         DDE Message
;         DDE Application Not Running
;     (If the latter is not specified, the former is used in its stead.)
;
; LeaveCriticalOn:
;   Since "Critical" must be used for reliability, this function also disables
;   Critical before returning. If the script must perform other actions that
;   require Critical to be enabled, specify true for LeaveCriticalOn.
;
; Windows XP notes may also apply to earlier versions of Windows.
;
DDE_InitServer(ApplicationName, TopicName, LabelName, LeaveCriticalOn=false)
{
    global
    ;
    ; The DDE server MUST be ready to process DDE requests before the AutoHotkey
    ; window becomes "idle", otherwise launching a document will result in
    ; "Windows cannot find '<document name>'. ..."
    ;
    ; '500' ensures no messages are processed (thus the window appears non-idle)
    Critical 500      ; for at least the next 500 milliseconds.
    
    DDE_Application := ApplicationName
    DDE_Topic := TopicName
    DDE_Label := LabelName
    
    DetectHiddenWindows, On
    Process, Exist
    DDE_hwnd := WinExist("ahk_class AutoHotkey ahk_pid " ErrorLevel)
    DetectHiddenWindows, Off
    
    OnMessage(0x3E0, "DDE_OnInitiate")
    OnMessage(0x3E8, "DDE_OnExecute")
    OnMessage(0x3E1, "DDE_OnTerminate")

    if ! LeaveCriticalOn
        Critical Off
}

DDE_OnInitiate(wParam, lParam)    ; handles WM_DDE_INITIATE
{
    global DDE_Application, DDE_Topic, DDE_hwnd
    
    if DDE_GlobalGetAtomName(lParam&0xFFFF) != DDE_Application
        return
    if DDE_GlobalGetAtomName(lParam>>16) != DDE_Topic
        return
    
    if (atomApplication := DllCall("GlobalAddAtom","str",DDE_Application)) != 0
    {
        if (atomTopic := DllCall("GlobalAddAtom","str",DDE_Topic)) != 0
        {
            DetectHiddenWindows, On
            ; Send WM_DDE_ACK with correct application and topic names.
            SendMessage, 0x3E4, DDE_hwnd, atomApplication | atomTopic<<16,, ahk_id %wParam%
            DllCall("GlobalDeleteAtom","ushort",atomTopic)
        }
        DllCall("GlobalDeleteAtom","ushort",atomApplication)
    }
}

DDE_OnExecute(wParam, lParam)     ; handles WM_DDE_EXECUTE
{
    global DDE_hwnd, DDE_Label, DDE_Cmd
    
    if DllCall("UnpackDDElParam","uint",0x3E8,"uint",lParam,"uint*",0,"uint*",hCmd)
    {
        DDE_Cmd := DllCall("GlobalLock","uint",hCmd,"str"), DllCall("GlobalUnlock","uint",hCmd)
        gosub %DDE_Label%
        success := true
    }
    lParam := DllCall("ReuseDDElParam","uint",lParam,"uint",0x3E8
        ,"uint",0x3E4,"uint",success ? 1<<15 : 0,"uint",hCmd)
    DetectHiddenWindows, On
    ; Acknowledge the request. (WM_DDE_ACK)
    PostMessage, 0x3E4, DDE_hwnd, lParam,, ahk_id %wParam%
}

DDE_OnTerminate(wParam)           ; handles WM_DDE_TERMINATE
{
    global DDE_hwnd
    DetectHiddenWindows, On
    ; Acknowledge WM_DDE_TERMINATE by posting another WM_DDE_TERMINATE.
    PostMessage, 0x3E1, DDE_hwnd, 0,, ahk_id %wParam%
}

DDE_GlobalGetAtomName(atom) {   ; helper function
    if !atom
        return ""
    VarSetCapacity(name,255) ; maximum size of an atom string
    return DllCall("GlobalGetAtomName","ushort",atom,"str",name,"int",256) ? name : ""
}