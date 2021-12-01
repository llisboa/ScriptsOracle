RUN {
SET UNTIL TIME 'SYSDATE-1/24';
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 30 DAYS;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
configure device type disk parallelism 2;
configure default device type to disk;
configure channel 1 device type disk format 'C:\backup_oracle\rman_disk\1\%u';
configure channel 2 device type disk format 'D:\backup_oracle\rman_disk\2\%u';
DUPLICATE TARGET DATABASE TO IM2 
NOFILENAMECHECK;
}
