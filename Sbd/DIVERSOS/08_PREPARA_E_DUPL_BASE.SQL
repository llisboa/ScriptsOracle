ECHO SHUTDOWN ABORT | SQLPLUS SYS/XXXX@SBDB2 AS SYSDBA
ECHO STARTUP NOMOUNT | SQLPLUS SYS/XXXX@SBDB2 AS SYSDBA
DEL \\192.168.0.16\c$\oracle\product\10.2.0\oradata\SBDB /Q


SYNC -dir "C:\oracle\product\10.2.0\flash_recovery_area" -repl "\\192.168.0.16\c$\oracle\product\10.2.0\flash_recovery_area" -noregedit -execimed -email "lucianol@icraft.com.br" -fecharaoconcluir -subject "sbd - serv 192.168.0.18 replica para 192.168.0.16" -from "suporte@sbd.org.br" -semconfirm


ECHO SHUTDOWN IMMEDIATE; | SQLPLUS SYS/XXXX@SBDB2 AS SYSDBA

DEL \\Sbd01\c$\oracle\product\10.2.0\oradata\SBDB\*.* /Q

ECHO STARTUP NOMOUNT | SQLPLUS SYS/XXXX@SBDB2 AS SYSDBA


RMAN.EXE TARGET 'SYS/XXXX@SBDB AS SYSDBA' AUXILIARY 'SYS/XXXX@SBDB2 AS SYSDBA' 

STARTUP NOMOUNT;
run {
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 30 DAYS;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
configure device type disk parallelism 1;
configure default device type to disk;
configure channel 1 device type disk format 'C:\oracle\product\10.2.0\flash_recovery_area\BACKUP_ORACLE\RMAN_DISK\1\%u';
DUPLICATE TARGET DATABASE TO SBDB
NOFILENAMECHECK;
}


SQLPLUS SYS/XXXX@SBDB2 AS SYSDBA;
SHUTDOWN IMMEDIATE;
STARTUP RESTRICT;
BEGIN
	FOR JOB IN (SELECT JOB FROM DBA_JOBS) LOOP
	 	SYS.dbms_ijob.BROKEN(JOB.JOB,TRUE);
	END LOOP;
END;
/
COMMIT;
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE OPEN READ ONLY;
