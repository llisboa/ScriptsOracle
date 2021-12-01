@echo off
set base=IMRJ
set script=recupera_%base%
set diretorio_flash=C:\oracle\product\11.1.0\flash_recovery_area

set /p entrada="Rodar programa %script% voce confirma [S/N]?"
if /i "%entrada%" == "S" goto :exec
goto :fim

:exec
@(
echo set echo on;
echo shutdown abort;
echo startup nomount pfile="%diretorio_flash%\%base%\BACKUP_ORACLE\RMAN_DISK\1\%base%_PFILE.ORA";
echo restore ^(spfile from autobackup^) ^(controlfile from autobackup^);
echo startup mount force;
echo configure controlfile autobackup off;
echo restore database;
echo recover database;
echo alter database open resetlogs;
echo exit;

) > %temp%\%script%.sql
rman target '/ as sysdba' @%temp%\%script%.sql trace "%temp%\%script%.log"


:fim
notepad "%temp%\%script%.log"