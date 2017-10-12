@echo off
rem 1.启动SAS，并运行qsas.sas
rem start "sas" "D:\Program Files\SASHome\SASFoundation\9.4\sas.exe" -sysin  "%~dp0\sas\qwindsas.sas" -nosplash -noicon


rem 2.启动 wind data feed，发送给SAS
set qhome=%~dp0q
cd %~dp0
rem                                 qwindsas.q 后面的数字表示推送频率，单位为毫秒，如2000表示2秒推送1次。
start "qWindSAS"   %~dp0q\w32\q.exe qwindsas.q   1000   -p 5565 -U %~dp0q/qusers
