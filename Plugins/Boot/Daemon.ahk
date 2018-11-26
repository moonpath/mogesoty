#NoEnv
#Warn

Run,wsl cd /home/hongyu/tmp; echo 1122 | sudo -S service cron start,,Hide UseErrorLevel,OutputVarPID
Run,wsl cd /home/hongyu/tmp; echo 1122 | sudo -S service ssh start,,Hide UseErrorLevel,OutputVarPID
