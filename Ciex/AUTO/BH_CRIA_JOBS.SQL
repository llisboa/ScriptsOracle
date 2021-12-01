EXEC DBMS_CX.PROG_GERA_PACOTES('GERA_PACOTES_BH','20:00:00','D:\CXBH_T', 'INTERCON','CXBH.IMBH.COM.BR','notifica@dom.com.br;maisdeum@dom.com.br', '10.2.0.10');
EXEC DBMS_CX.PROG_RECEBE_PACOTES('RECEBE_PACOTES_RJ','2','CXRJ','D:\CXBH_T','INTERCON', 'CXBH.IMBH.COM.BR', 'maisdeum@dom.com.br', '10.2.0.10', 'CXBH', 'D4C', '10.0.0.185');
DECLARE
v_JobNum binary_integer;
BEGIN
	DBMS_CX.PROG_APAGA('%NOTIFICAÇÃO DE CADASTRO%');
	dbms_job.submit(v_JobNum, '/* NOTIFICAÇÃO DE CADASTRO */begin dbms_cx.cad_log(''cxrj@xxxxxxxxxx.com.br'', ''maisdeum@dom.com.br'',''10.2.0.10'');end;',to_date('' || to_char(sysdate,'DD-MM-YYYY') || '22:30','DD-MM-YYYY HH24:MI:SS'), 'SYSDATE+1');
END;
/

