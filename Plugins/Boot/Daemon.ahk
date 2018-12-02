cron_status := StdOutStream("wsl service cron status")
ssh_status := StdOutStream("wsl service ssh status")

while(InStr(cron_status, "is not running") && A_Index < 10)
{
    Run,wsl echo 1122 | sudo -S service cron start,,Hide UseErrorLevel,OutputVarPID
    Sleep, 10000
    cron_status := StdOutStream("wsl service cron status")
}

while(InStr(ssh_status, "is not running") && A_Index < 10)
{
    Run,wsl echo 1122 | sudo -S service ssh start,,Hide UseErrorLevel,OutputVarPID
    Sleep, 10000
    ssh_status := StdOutStream("wsl service ssh status")
}
