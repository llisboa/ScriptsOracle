@echo off
set base=SBDB
set script=rman_full_7dias_%base%


set /p entrada="Rodar programa %script% voce confirma [S/N]?"
if /i "%entrada%" == "S" goto :exec
goto :fim

:exec
@(
echo set echo on;

echo sql "create pfile=''C:\oracle\product\11.2.0\flash_recovery_area\%base%\BACKUP_ORACLE\RMAN_DISK\1\%base%_PFILE.ORA'' from spfile";
echo run {
echo CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;
echo CONFIGURE CONTROLFILE AUTOBACKUP ON;
echo configure device type disk parallelism 1;
echo configure default device type to disk;
echo configure channel 1 device type disk format 'C:\oracle\product\11.2.0\flash_recovery_area\%base%\BACKUP_ORACLE\RMAN_DISK\1^\%%d_%%T_%%s_%%t_F.BKP';
echo BACKUP AS COMPRESSED BACKUPSET INCREMENTAL LEVEL 0 DATABASE PLUS ARCHIVELOG DELETE INPUT;
echo crosscheck archivelog all;
echo crosscheck backupset;
echo delete FORCE noprompt obsolete;
echo DELETE FORCE NOPROMPT ARCHIVELOG ALL BACKED UP 1 TIMES TO DISK;
echo }
echo sql 'alter system archive log current';
echo exit

) > %temp%\%script%.sql
rman target '/ as sysdba' @%temp%\%script%.sql trace "%temp%\%script%.log"


:fim
