RMAN.EXE TARGET 'SYS/XXXXXX@IMRJ AS SYSDBA' @%1 > C:\RMAN_%1.LOG
SENDMAIL -f suporte@xxxxxxx.com.br -t web@xxxxxxx.com.br -s "IM - Oracle Backup 10.0.0.51 - %1 - Acompanhamento" -b C:\RMAN_%1.LOG -m smtpi