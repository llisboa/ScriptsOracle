EXEC DBMS_CX.PROG_GERA_PACOTES('GERA_PACOTES_RJ', '21:00:00', 'D:\CXRJ_T', 'XXXXXX', 'CXRJ.IMRJ.COM.BR', 'cxsp@xxxxxxxxxx.com.br;cxbh@xxxxxxxxxx.com.br;marcio@xxxxxxxxxx.com.br;luciano.lisboa@xxxxxxxxxx.com.br', '10.0.0.10');
EXEC DBMS_CX.PROG_RECEBE_PACOTES('RECEBE_PACOTES_SP', '2', 'CXSP', 'D:\CXRJ_T', 'XXXXXX', 'CXRJ.IMRJ.COM.BR', 'marcio@xxxxxxxxxx.com.br;luciano.lisboa@xxxxxxxxxx.com.br', '10.0.0.10', 'EXDOM1/MARCIO\CXRJ', 'MARCIO', '10.0.0.10');
PAUSE
EXEC DBMS_CX.PROG_RECEBE_PACOTES('RECEBE_PACOTES_BH', '2', 'CXBH', 'D:\CXRJ_T', 'XXXXXX', 'CXRJ.IMRJ.COM.BR', 'marcio@xxxxxxxxxx.com.br;luciano.lisboa@xxxxxxxxxx.com.br', '10.0.0.10', 'EXDOM1/MARCIO\CXRJ', 'MARCIO', '10.0.0.10');
