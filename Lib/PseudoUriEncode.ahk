PseudoUriEncode(uri)
{
    return StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(uri,"""",""""""""),"`%","`%25"),"#","`%23"),"&","`%26"),"+","`%2B"),"=","`%3D")," ","+")
}