REM ====================================================================
REM ======== CUIDADO ====== ESTA ROTINA APAGA DADOS NO DESTINO
REM PARAM 1 = IP DESTINO EXEMPLO... 192.168.0.16
REM PARAM 2 = SERVIÇO PARA ACESSO AO DESTINO EXEMPLO... SBDB2
REM ==================================================================== 
REM
IF %1=="" GOTO FIM 
IF %2=="" GOTO FIM
ECHO SHUTDOWN ABORT | SQLPLUS SYS/XXXX@%2 AS SYSDBA 
DEL %1\c$\oracle\product\11.2.0\oradata\SBDB /Q 

SYNCDOS -dir "C:\oracle\product\11.2.0\flash_recovery_area" -repl "%1\c$\oracle\product\11.2.0\flash_recovery_area" -semconfirm -subject "SBD - Backup Oracle - Cópia do flashrecovery de \\192.168.0.16 para %1 DISCO C" -from "suporte@xxxxxxx.com.br" -email "web@xxxxxxx.com.br" -smtp "smtpi"
ECHO STARTUP NOMOUNT | SQLPLUS SYS/XXXX@%2 AS SYSDBA 
RMAN.EXE TARGET 'SYS/XXXX@SBDB AS SYSDBA' AUXILIARY 'SYS/XXXX@%2 AS SYSDBA' @C:\oracle\flash_recovery_area\SBDB\BACKUP_ORACLE\PREPARA_E_DUPL_BASE_02_RMAN.SQL 
SQLPLUS SYS/XXXX@%2 AS SYSDBA @C:\oracle\flash_recovery_area\SBDB\BACKUP_ORACLE\PREPARA_E_DUPL_BASE_03_SQLPLUS.SQL 
:FIM



