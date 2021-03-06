set script=passar_para_archivelog
@(
echo set echo on;
echo spool %temp%\%script%.log

echo shutdown immediate;
echo startup mount exclusive;
echo alter database noarchivelog;
echo alter database open;
echo spool off;
echo exit;

) > %temp%\%script%.sql
sqlplus / as sysdba @%temp%\%script%.sql
notepad %temp%\%script%.log
