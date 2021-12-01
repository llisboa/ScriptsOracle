SHUTDOWN ABORT;
STARTUP NOMOUNT;
HOST 'DEL C:\oracle\product\10.2.0\oradata\SBDB\*.* /Q';
RESTORE CONTROLFILE FROM AUTOBACKUP;
ALTER DATABASE MOUNT;
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 30 DAYS;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
configure device type disk parallelism 2;
configure default device type to disk;


run {
--SET UNTIL TIME 'SYSDATE-9/24';
set until time "TO_DATE('2014-09-16 10:00:00','yyyy-mm-dd hh24:mi:ss')";
configure default device type to disk;
configure channel 1 device type disk format 'C:\oracle\flash_recovery_area\SBDB\BACKUP_ORACLE\RMAN_DISK\1\%d_%T_%s_%t_F.BKP';
restore database;
recover database;
}


alter database open resetlogs;
