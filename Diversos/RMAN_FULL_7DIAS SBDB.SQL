run {
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
configure device type disk parallelism 1;
configure default device type to disk;
configure channel 1 device type disk format 'C:\oracle\product\10.2.0\flash_recovery_area\SBDB\BACKUP_ORACLE\RMAN_DISK\1\%d_%T_%s_%t_F.BKP';
BACKUP AS COMPRESSED BACKUPSET INCREMENTAL LEVEL 0 DATABASE PLUS ARCHIVELOG DELETE INPUT;
crosscheck archivelog all;
crosscheck backupset;
#delete FORCE noprompt obsolete;
DELETE FORCE NOPROMPT ARCHIVELOG ALL BACKED UP 1 TIMES TO DISK;
}
