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
SET HEADING OFF;
SET PAGESIZE 0;
SELECT DBID, 'SCN EM ' || SCN_TO_TIMESTAMP(CHECKPOINT_CHANGE#) FROM V$DATABASE;
EXIT




