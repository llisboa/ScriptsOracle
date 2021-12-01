CALL C:\oracle\flash_recovery_area\SBDB\BACKUP_ORACLE\PREPARA_E_DUPL_BASE.BAT \\10.0.0.213 SBDB_213 > C:\DUPL_BASE_16.LOG
SENDMAIL -f contato@xxxxxxx.org.br -t suporte@xxxxxxx.com.br -t web@xxxxxxx.com.br -m smtpi -b c:\dupl_base_16.log -s "SBD - ORACLE - REPL BASE 192.168.0.16 PARA 10.0.0.213"
REM CALL C:\oracle\product\10.2.0\flash_recovery_area\SBDB\BACKUP_ORACLE\PREPARA_E_DUPL_BASE_11.BAT



