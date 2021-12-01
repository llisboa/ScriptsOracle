SHUTDOWN ABORT;
SET DBID 1833282484;
STARTUP NOMOUNT;
HOST 'DEL C:\oracle\product\10.2.0\oradata\IM\*.* /Q';
RESTORE CONTROLFILE FROM AUTOBACKUP;
#RESTORE CONTROLFILE FROM 'C:\oracle\product\10.2.0\flash_recovery_area\IM\AUTOBACKUP\==ultimodirn\==ultimoarqc';
ALTER DATABASE MOUNT;

run {
CONFIGURE CONTROLFILE AUTOBACKUP OFF;
configure device type disk parallelism 1;
configure default device type to disk;
configure channel 1 device type disk format 'C:\oracle\flash_recovery_area\IMRJ\BACKUP_ORACLE\RMAN_DISK\1\%d_%T_%s_%t_F.BKP';
crosscheck archivelog all;
crosscheck backupset;
#SET UNTIL TIME 'SYSDATE-1';
#SET UNTIL TIME "TO_DATE('2011-08-24 17:05:00','YYYY-MM-DD HH24:MI:SS')";
RESTORE DATABASE;
RECOVER DATABASE;
}


