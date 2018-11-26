
path := "D:\Application\Mogesoty\Plugins\TaskBarControl\Prev.lnk"

global j:=0

PinToTaskbar(path)
PinToTaskbar(FilePath)
{
    SplitPath,FilePath,File,Dir
    For i in ComObjCreate("Shell.Application").Namespace(Dir).ParseName(File).Verbs()
;        if (i.Name = "¹Ì¶¨µ½ÈÎÎñÀ¸(&K)")
;            return i.DoIt()
        msgbox % i.Name . j++
} 
