PinToTaskbar("C:\Users\Harvey\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\UltraEdit.lnk")
PinToTaskbar(FilePath)
{
    SplitPath,FilePath,File,Dir
    For i in ComObjCreate("Shell.Application").Namespace(Dir).ParseName(File).Verbs()
 ;       if (i.Name = "Pin to Tas&kbar")
   ;         return i.DoIt()
   msgbox % i.Name
} 