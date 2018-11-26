SetWorkingDir A_ScriptDir

Loop, Read, %A_ScriptDir%\List.csv
{
	Person:=[]
	Loop, Parse, A_LoopReadLine,CSV
	{
		Person[A_Index]:=A_LoopField
	}
	Loop,%A_ScriptDir%\Old\*.*,1,1
	{
		ID:=Person[1]
		name:=Person[2]
		FileCopy, %A_LoopFileFullPath%, %A_ScriptDir%\New\%ID%%name%.docx, 1
		FileDelete, %A_LoopFileFullPath%
		break
	}
}