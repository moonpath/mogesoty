DetectHiddenWindows, On
if(!WinExist("ahk_exe goagent.exe"))
	Run,D:\Application\Agent\goagent.exe,,Hide UserErrorLevel