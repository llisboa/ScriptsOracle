set script=test_conn
@(
echo set echo on;
echo set heading off;
echo set pagesize 0;
echo select dbid, name from v$database;
echo select owner, count^(*^) from all_tables group by owner;
echo exit;

) > %temp%\%script%.sql

@(

ECHO *********************************************
ECHO ************************************* I M R J
SQLPLUS -S -L SYS/XXXXXX@IMRJ AS SYSDBA @%temp%\%script%.sql

ECHO *********************************************
ECHO ************************************* I M S P
SQLPLUS -S -L SYS/XXXXXX@IMSP AS SYSDBA @%temp%\%script%.sql

ECHO *********************************************
ECHO ************************************* I M B H 
SQLPLUS -S -L SYS/XXXXXX@IMBH AS SYSDBA @%temp%\%script%.sql

ECHO *********************************************
ECHO ************************************* I M S C
SQLPLUS -S -L SYS/XXXXXX@IMSC AS SYSDBA @%temp%\%script%.sql

ECHO *********************************************
ECHO ************************************* I M E S
SQLPLUS -S -L SYS/XXXXXX@IMES AS SYSDBA @%temp%\%script%.sql

) > %temp%\%script%.log

notepad "%temp%\%script%.log"

