run {
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;
CONFIGURE CONTROLFILE AUTOBACKUP OFF;
configure device type disk parallelism 1;
configure default device type to disk;
configure channel 1 device type disk format 'C:\oracle\product\10.2.0\flash_recovery_area\SBDB\BACKUP_ORACLE\RMAN_DISK\1\%d_%T_%s_%t_F.BKP';
DUPLICATE TARGET DATABASE TO SBDB
NOFILENAMECHECK;
}



