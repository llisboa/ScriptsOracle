DROP TABLE CXSP.ALTERA_PED;

CREATE TABLE CXSP.ALTERA_PED (
             TABELA VARCHAR2 (10),
             PED_REF VARCHAR2 (13),
             ITEM NUMBER (5,0),
             FORNECEDOR NUMBER,
             EXP NUMBER,
             IMP NUMBER,
             OBS VARCHAR2 (3000),
             NEW_FORNECEDOR NUMBER,
             NEW_EXP NUMBER,
             NEW_IMP NUMBER,
             NEW_OBS VARCHAR2 (3000),
             ATUALIZA VARCHAR2 (100),
             SYS_MOMENTO_CRIA DATE,
             SYS_USU�RIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USU�RIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXSP_DAT;
ALTER TABLE CXSP.ALTERA_PED ADD CONSTRAINT ID_ALTERA_PED;

CREATE OR REPLACE TRIGGER BEF_ALTERA BEFORE UPDATE ON CXRJ.PED_ITEM FOR EACH ROW
-- GRAVA LOG QUANDO OS PRE�OS FOREM ALTERADOS.
BEGIN
   IF UPDATING Then
    IF (nvl(:NEW.PRE�O_UNIT�RIO_FORNECEDOR,-99999) <> nvl(:OLD.PRE�O_UNIT�RIO_FORNECEDOR,-99999)) OR (nvl(:NEW.PRE�O_UNIT�RIO_IMP,-99999) <> nvl(:OLD.PRE�O_UNIT�RIO_IMP,-99999)) OR (nvl(:NEW.PRE�O_UNIT�RIO_EXP,-99999) <> nvl(:OLD.PRE�O_UNIT�RIO_EXP,-99999)) THEN
	INSERT INTO CXSP.ALTERA_PED(TABELA, PED_REF, ITEM, FORNECEDOR, NEW_FORNECEDOR, IMP, NEW_IMP, EXP, NEW_EXP, ATUALIZA ) VALUES ('PED_ITEM', :NEW.PED_REF, :NEW.ITEM, decode(:OLD.PRE�O_UNIT�RIO_FORNECEDOR,null,-99999,:OLD.PRE�O_UNIT�RIO_FORNECEDOR), decode(:NEW.PRE�O_UNIT�RIO_FORNECEDOR,null,-99999,:NEW.PRE�O_UNIT�RIO_FORNECEDOR), decode(:OLD.PRE�O_UNIT�RIO_IMP,null,-99999,:OLD.PRE�O_UNIT�RIO_IMP), decode(:NEW.PRE�O_UNIT�RIO_IMP,null,-99999,:NEW.PRE�O_UNIT�RIO_IMP), decode(:OLD.PRE�O_UNIT�RIO_EXP,null,-99999,:OLD.PRE�O_UNIT�RIO_EXP), decode(:NEW.PRE�O_UNIT�RIO_EXP,null,-99999,:NEW.PRE�O_UNIT�RIO_EXP),TO_CHAR(:NEW.SYS_MOMENTO_ATUALIZA, 'DD/MM/YYYY HH24:MI:SS') || ' - ' || USER);
   END IF;
END;

        procedure precoAlteradoAposEmb(de in varchar, para in varchar, adm in varchar2 ,servidor_msg in varchar) as
        Begin
        Declare
        public_dir VARCHAR2(30);
        arquivo varchar2(30);
        ret integer;
        PRECO_IMP VARCHAR2(1);
        PRECO_EXP VARCHAR2(1);
        COR_FOR VARCHAR2(25);
        COR_IMP VARCHAR2(25);
        COR_EXP VARCHAR2(25);
        TOT_REG INTEGER;
        cursor c_cad_log is sELECT * from CXSP.ALTERA_PED WHERE TABELA = 'PED_ITEM' ORDER BY PEDIDO, ITEM;
        begin
            arquivo := 'PedidosAlterados.htm';
	    public_dir := 'd:\oracle\public';
            Ret :=   DBMS_CX.DOSSHELL('DEL ' || public_dir || '\' || arquivo);
            sELECT COUNT(*) INTO TOT_REG from CXSP.ALTERA_PED WHERE TABELA = 'PED_ITEM' ORDER BY PEDIDO, ITEM;
            IF TOT_REG > 0 THEN
                dbms_cx.grava_log('<html><head><title>CIEX - Pre�os alterados.</title></head><body bgcolor= #C0C0C0 text= #0000FF >',arquivo);
                dbms_cx.grava_log('<p align= center ><font face= Arial  size= 3 ><b>CIEX - Pre�os alterados </b></font></p><table border= 1  width= 100% >',arquivo);
                dbms_cx.grava_log('<tr><td width= 9%  align= center ><p align= center ><b><font face= Arial SIZE =2>Pedido</font></b></td>',arquivo);
                dbms_cx.grava_log('<td width= 8%  align= center ><b><font face= Arial SIZE = 2>item</font></b></td>',arquivo);
                dbms_cx.grava_log('<td width= 13%  align= center ><b><font face= Arial SIZE =2>Pre�o Fornecedor <BR></font> <font face = arial size = 1>Anterior / Atual</font></b></td><td width= 7%  align= CENTER ><b><font face= Arial SIZE =2 >Pre�o Fornecedor</font></b></td>',arquivo);

                dbms_cx.grava_log('<td width= 13%  align= center ><b><font face= Arial SIZE =2>Pre�o Importador <BR></font> <font face = arial size = 1>Anterior / Atual</font></b></td><td width= 7%  align= CENTER ><b><font face= Arial SIZE =2 >Pre�o Importador</font></b></td>',arquivo);
                dbms_cx.grava_log('<td width= 13%  align= center ><b><font face= Arial SIZE =2>Pre�o Exportador <BR></font> <font face = arial size = 1>Anterior / Atual</font></b></td><td width= 7%  align= center ><b><font face= Arial SIZE =2 >Pre�o Exportador</font></b></td>',arquivo);
                dbms_cx.grava_log('<td width= 14%  align= center ><b><font face= Arial SIZE =2>�ltima Atualiza��o </font></b></td>',arquivo);
                for  CUR in  C_CAD_LOG loop -- c�lulas da tabela
                    if CUR.NEW_FORNECEDOR <> CUR.FORNECEDOR THEN
			COR_FOR := ' COLOR = #FF0000';
                    ELSE
			COR_FOR := '';
                    END IF;
                    if CUR.NEW_IMPORTADOR <> CUR.IMPORTADOR THEN
			COR_IMP := ' COLOR = #FF0000';
                    ELSE
			COR_IMP := '';
                    END IF;
                    if CUR.NEW_EXPORTADOR <> CUR.EXPORTADOR THEN
			COR_EXP := ' COLOR = #FF0000';
                    ELSE
			COR_EXP := '';
                    END IF;
                    dbms_cx.grava_log('<tr><td width=9% align=center><font face=Arial size=1> ' || CUR.PED_REF || '.' || CUR.ITEM || '</font></td>',arquivo);
                    dbms_cx.grava_log('<td width=8% align=center><font face=Arial size=1>' || CUR.EMBARQUE || ' </font></td>',arquivo);
                    dbms_cx.grava_log('<td width=13% align=center><font face=Arial size=1' || COR_IMP || ' >' || formataValor(cur.Pre�o_Imp_Pedido_Old) || ' / ' || formataValor(cur.Pre�o_Imp_Pedido_New) || ' </font></td>',arquivo);
                    dbms_cx.grava_log('<td width=7% align=CENTER><font face=Arial size=1>' || formataValor(CUR.pre�o_imp_embarque) || ' </font></td>',arquivo);
                    dbms_cx.grava_log('<td width=13% align=center><font face=Arial size=1' || COR_EXP || ' >' || formataValor(CUR.pre�o_exp_pedido_old) || ' / ' ||  formataValor(CUR.pre�o_EXP_pedido_new) || ' </font></td>',arquivo);
                    dbms_cx.grava_log('<td width=7% align=CENTER><font face=Arial size=1>' || formataValor(CUR.pre�o_exp_embarque) || ' </font></td>',arquivo);
                    dbms_cx.grava_log('<td width=14% align=center><font face=Arial size=1>' || CUR.ATUALIZA��O_PEDIDO || ' </font></td>',arquivo);
                    dbms_cx.grava_log('<td width=14% align=center><font face=Arial size=1>' || CUR.ATUALIZA��O_EMBARQUE || ' </font></td>',arquivo);
                end loop;
                dbms_cx.grava_log('</table><font face=Arial size=1 color = #FF0000>Data: ' || to_char(sysdate,'dd/mon/yyyy') || '</font></body></html>',arquivo); -- fim da tabela e fim do HTML
                Ret :=   DBMS_CX.DOSSHELL('sendmail -f ' || de || ' -t ' || replace(Para, ';', ' -t ') || ' -s "CIEX - Pre�os alterados ap�s o embarque" -b "CIEX - Controle de Exporta��o e Importa��o." -a ' ||  public_dir || '\' || arquivo || ' -m ' || servidor_msg || '');
                Ret :=   DBMS_CX.DOSSHELL('DEL ' || public_dir || '\' || arquivo);
            ELSE
              Ret := DBMS_CX.DOSSHELL('sendmail -f ' || de || ' -t ' || replace(adm, ';', ' -t') || ' -s "CIEX - Pre�os alterados ap�s o embarque - NENHUM PRE�O FOI ALTERADO" -b "NENHUM PRE�O FOI ALTERADO - ' || to_char(sysdate,'dd/mon/yyyy') || '"  -m ' || servidor_msg || '');
            END IF;
            delete from cxrj.preco_ped_emb_diferente;
            commit;
            exception
                when others then
                    Ret := DBMS_CX.DOSSHELL('sendmail -f ' || de || ' -t ' || replace(adm, ';', ' -t') || ' -s "ERRO - CIEX - Pre�os alterados ap�s o embarque - ERRO" -b"' || sqlerrm || chr(10) || to_char(sysdate,'dd/mon/yyyy') || '" -m ' || servidor_msg || '');
                    raise_application_error (-20000, 'Erro Precos alterados apos o embarque: ' || chr(10) || sqlerrm);
            end;
        end precoAlteradoAposEmb;

