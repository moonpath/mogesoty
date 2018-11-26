GetUnicodeString(str)
{
	out := ""
	charList := StrSplit(str)
	SetFormat, integer, hex
	for key, val in charList
		out .= "{U+ " . ord(val) . "}"
	return out
}