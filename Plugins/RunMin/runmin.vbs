For Each arg in WScript.Arguments
    argsStr = argsStr + arg + " "
Next
Set objShell=WScript.CreateObject("WScript.Shell")
result=objShell.Run("CMD /C " + argsStr, 0, TRUE)
