SetWorkingDir A_ScriptDir

Loop, Read, %A_ScriptDir%\List.csv
{
	Person:=[]
	Loop, Parse, A_LoopReadLine,CSV
	{
		Person[A_Index]:=A_LoopField
	}
	Loop,*, 1, 1
	{

		ID:=Person[1]
		name:=Person[2]
		if(InStr(A_LoopFileName, name))
		{
			FileCopy, %A_LoopFileFullPath%, %A_ScriptDir%\34\%ID%%name%.%A_LoopFileExt%, 1
			break
		}
	}
}