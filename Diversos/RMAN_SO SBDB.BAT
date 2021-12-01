RMAN.EXE TARGET 'SYS/XXXX@SBDB AS SYSDBA' @C:\oracle\product\10.2.0\flash_recovery_area\SBDB\BACKUP_ORACLE\%1 > C:\RMAN_%1.LOG
SENDMAIL -f suporte@xxxxxxx.com.br -t web@xxxxxxx.com.br -s "SBD - Oracle Backup 192.168.0.18 - %1 - Acompanhamento" -b C:\RMAN_%1.LOG -m 192.168.0.18
