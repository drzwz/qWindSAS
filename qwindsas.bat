@echo off
rem 1.����SAS��������qsas.sas
rem start "sas" "D:\Program Files\SASHome\SASFoundation\9.4\sas.exe" -sysin  "%~dp0\sas\qwindsas.sas" -nosplash -noicon


rem 2.���� wind data feed�����͸�SAS
set qhome=%~dp0q
cd %~dp0
rem                                 qwindsas.q ��������ֱ�ʾ����Ƶ�ʣ���λΪ���룬��2000��ʾ2������1�Ρ�
start "qWindSAS"   %~dp0q\w32\q.exe qwindsas.q   1000   -p 5565 -U %~dp0q/qusers
