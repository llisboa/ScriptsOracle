RMAN.EXE TARGET 'SYS/XXXX@SBDB AS SYSDBA' @C:\oracle\flash_recovery_area\SBDB\BACKUP_ORACLE\%1 > C:\RMAN_%1.LOG
SQLPLUS.EXE SYS/XXXX@SBDB AS SYSDBA @C:\oracle\flash_recovery_area\SBDB\BACKUP_ORACLE\EXEC.SQL >> C:\RMAN_%1.LOG
sendmail -t web@xxxxxxx.com.br -f backup@xxxxxxx.org.br -s "SBD - Oracle Backup - SBDB - 201.49.216.134 - %1 - Acompanhamento" -a C:\RMAN_%1.LOG -m smtpi.xxxxxxx.org.br