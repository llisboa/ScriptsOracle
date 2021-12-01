run {
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 30 DAYS;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
configure device type disk parallelism 2;
configure default device type to disk;
configure channel 1 device type disk format 'C:\oracle\product\10.2.0\flash_recovery_area\BACKUP_ORACLE\RMAN_DISK\1\%u';
configure channel 2 device type disk format 'D:\backup_oracle\rman_disk\2\%u';
BACKUP DATABASE PLUS ARCHIVELOG;
}
