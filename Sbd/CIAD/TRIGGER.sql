--------------------------------------------------------------------------
-- TRIGGERS PARA O BANCO DE DADOS SBDB
--
-- Sistema Integrado da SBD
--------------------------------------------------------------------------

Create or Replace Trigger Status_Pagamento Before Update or Insert or Delete on PAGAMENTO For Each Row

Declare

flPagVal float;
flObrigVal float;
dtObrigDtVenc date;
dtDataDesc date;
flValDesc float;
flDesc float;
vObrigTipo OBRIGAÇÃO.OBRIG_TIPO%type;
vObrigStatus OBRIGAÇÃO.OBRIG_STATUS_COD%type;
bDesconto boolean;
dtCompetencia date;
nDataSistema date;
nMat NUMBER;

begin	
	
	if updating or inserting then		

		SELECT OBRIG_TIPO,ROUND(VALOR,2),DATA_VENCIMENTO,COMPETÊNCIA INTO vObrigTipo,flObrigVal,dtObrigDtVenc,dtCompetencia FROM OBRIGAÇÃO WHERE SÓCIO_MAT = :NEW.SÓCIO_MAT AND SEQ = :NEW.OBRIG_SEQ;
		flDesc := 0;
		vObrigStatus := 0;
		flPagVal := ROUND(NVL(:NEW.VALOR,0),2);
		flDesc := NVL(:NEW.DESCONTO,0);
		bDesconto := false;
		nMat:=0;

		if flpagVal+flDesc>=flObrigVal then
				vObrigStatus := 'BAIXADA';
		elsif flpagval>0 then
			vObrigStatus := 'EM ABERTO';
		end if;
			
		if NOT vObrigStatus IS NULL then
			UPDATE OBRIGAÇÃO SET OBRIG_STATUS_COD = vObrigStatus WHERE SÓCIO_MAT = :NEW.SÓCIO_MAT AND SEQ = :NEW.OBRIG_SEQ;
       		end if;

		if inserting and vObrigTipo = 'ANUIDADE - COTA ÚNICA' then
			nMat:=:NEW.SÓCIO_MAT;
			DELETE FROM OBRIGAÇÃO WHERE SÓCIO_MAT = nMat AND OBRIG_TIPO LIKE 'ANUIDADE-PARCELA%' AND TO_CHAR(COMPETÊNCIA,'YYYY') = TO_CHAR(dtCompetencia,'YYYY');
		elsif inserting and vObrigTipo = 'ANUIDADE-PARCELA 1' then
			nMat:=:NEW.SÓCIO_MAT;
			DELETE FROM OBRIGAÇÃO WHERE SÓCIO_MAT = nMat AND OBRIG_TIPO = 'ANUIDADE - COTA ÚNICA' AND TO_CHAR(COMPETÊNCIA,'YYYY') = TO_CHAR(dtCompetencia,'YYYY');
		end if;
	
	else
        	nDataSistema:= SYSDATE;
		SELECT OBRIG_TIPO,VALOR,DATA_VENCIMENTO INTO vObrigTipo,flObrigVal,dtObrigDtVenc FROM OBRIGAÇÃO WHERE SÓCIO_MAT = :OLD.SÓCIO_MAT AND SEQ = :OLD.OBRIG_SEQ;	
		if  TRUNC(dtObrigDtVenc - nDataSistema) >= 0 then
			vObrigStatus := 'EM ABERTO';
		else
			vObrigStatus := 'VENCIDA';
		end if;	
		UPDATE OBRIGAÇÃO SET OBRIG_STATUS_COD = vObrigStatus WHERE SÓCIO_MAT = :OLD.SÓCIO_MAT AND SEQ = :OLD.OBRIG_SEQ;
	end if;	
		
end;
/


Create or Replace Trigger Status_Obrigacao Before Update or Insert or Delete on OBRIGAÇÃO For Each Row


begin	
 
     if inserting then	
                
		if :NEW.OBRIG_STATUS_COD <> 'CANCELADA' or :NEW.OBRIG_STATUS_COD is null  then	
			if TRUNC(:NEW.DATA_VENCIMENTO - SYSDATE) >= 0 then
				:NEW.OBRIG_STATUS_COD := 'EM ABERTO';			
			elsif TRUNC(:NEW.DATA_VENCIMENTO - SYSDATE) < 0 then
				:NEW.OBRIG_STATUS_COD := 'VENCIDA';				
			end if;
		end if;
	elsif Updating then
              if :NEW.OBRIG_STATUS_COD = :OLD.OBRIG_STATUS_COD AND :NEW.OBRIG_STATUS_COD not in ('BAIXADA','CANCELADA','SUBSTITUIDA') then
                        
			if TRUNC(:NEW.DATA_VENCIMENTO - SYSDATE) >= 0 or (:NEW.DATA_VENCIMENTO = :OLD.DATA_VENCIMENTO AND :OLD.OBRIG_STATUS_COD = 'EM ABERTO')then
				:NEW.OBRIG_STATUS_COD := 'EM ABERTO';	
                        elsif  TRUNC(:NEW.DATA_VENCIMENTO - SYSDATE) < 0 then
				:NEW.OBRIG_STATUS_COD := 'VENCIDA';				
			end if;
		end if;
	end if;
	--LSBD.LSOCIO_STATUS(:NEW.SÓCIO_MAT,true);
				
end;
/


Create or Replace Trigger Socio_Mala_Direta before Update on SÓCIO For Each Row
BEGIN
IF :NEW.MALA_COMERCIAL_2=-1 THEN
 :NEW.MALA_COMERCIAL_1:=0;
 :NEW.MALA_RESIDENCIAL:=0;
ELSIF :NEW.MALA_COMERCIAL_1=-1 THEN
 :NEW.MALA_RESIDENCIAL:=0;
 :NEW.MALA_COMERCIAL_2:=0;
ELSE
 :NEW.MALA_RESIDENCIAL:=-1;
 :NEW.MALA_COMERCIAL_1:=0;
 :NEW.MALA_COMERCIAL_2:=0;
END IF;
end;
/


Create or Replace Trigger Socio_Fase_Contagem before Insert on EMCD_Ponto_Sócio For Each Row
declare
DataRef date;
vFase emcd_ponto_sócio.Apuração%type;
vSeq emcd_ponto_sócio.SubFase%type;
vMAt emcd_ponto_sócio.sócio_mat%type;
begin
 DataRef:=:new.Ponto_Data;
 vMat:=:new.Sócio_mat;
 FaseSeq(vmat,DataRef,vFase,vSeq);
 :New.Apuração:=vFase;
 :New.SubFase:=vSeq;
 :New.Apurado:=0;
end;
/
Create or Replace Procedure FaseSeq(pMat in Number,DataIni in Date,Pfase out char,pSeq Out char) as
DATACONT VARCHAR(10);
begin
PFASE:=NULL;
SELECT NVL(TO_CHAR(DATA_INICIO_CONTAGEM,'DD/MM/YYYY'),'NULL') into DataCont FROM SBDB.SÓCIO WHERE MAT=pMat;
	FOR CurPeriodo IN (SELECT PERIODO.* FROM SBDB.SÓCIO S,
		(SELECT QINI.FASE,QINI.DATA_INI,QFIM.DATA_FIM,sub.seq,sub.SUBINI,sub.SUBFIM
		FROM
		(select FASE,TO_CHAR(MIN(DATA_INI),'DD/MM/YYYY') AS Data_INi FROM SBDB.EMCD_PERIODO GROUP BY FASE) QINI,
		(select FASE,TO_CHAR(MAX(DATA_FIM),'DD/MM/YYYY') AS Data_FIM FROM SBDB.EMCD_PERIODO GROUP BY FASE) QFIM,
		(select FASE,seq,TO_CHAR(DATA_INI,'DD/MM/YYYY') AS SUBINi,TO_CHAR(DATA_FIM,'DD/MM/YYYY') AS SUBFIM FROM SBDB.EMCD_PERIODO GROUP BY FASE,seq,DATA_INI,DATA_FIM) SUB
		WHERE
		QINI.FASE(+)=QFIM.FASE AND QFIM.FASE=SUB.FASE) PERIODO WHERE S.MAT=pMAT AND PERIODO.DATA_INI=TO_CHAR(S.DATA_INICIO_CONTAGEM,'DD/MM/YYYY')) LOOP
		IF (DataIni>=to_date(CurPeriodo.Data_Ini,'dd/mm/yyyy')) and (DataIni<=to_date(CurPeriodo.Data_Fim,'dd/mm/yyyy')) and (DataIni>=to_date(CurPeriodo.SubIni,'dd/mm/yyyy')) and (DataIni<=to_date(CurPeriodo.SubFim,'dd/mm/yyyy')) then
			pFase:=CurPeriodo.Fase;
			pseq:=CurPeriodo.seq;
		end if;
	end loop;
IF NVL(PFASE,'1')='1' THEN
	SELECT FASE,SEQ INTO PFASE,PSEQ FROM SBDB.EMCD_PERIODO WHERE SYSDATE>=DATA_INI AND SYSDATE<=DATA_FIM
	AND
	FASE=(SELECT MAX(FASE) FROM SBDB.EMCD_PERIODO WHERE SYSDATE>=DATA_INI AND SYSDATE<=DATA_FIM);
END IF;
end FaseSeq;
/

CREATE OR REPLACE TRIGGER "SBDB"."BEF_IMP_ETIQ_CODIGO_BARRA" BEFORE UPDATE OF "EMCD_DATA_IMP_ETIQ", "SYS_STATUS" ON "SÓCIO" FOR EACH ROW BEGIN
         :NEW.SYS_STATUS := 'X';
END;


/*Este trigger foi desabilitado por causar erro logico quando se insere o primeiro ponto do sócio - Rogerio Ferreira 20/07/2005

Create or Replace Trigger Socio_Inico_Contagem Before Insert or Delete on EMCD_APURAÇÃO For Each Row
begin

	if inserting then
		UPDATE SÓCIO SET SYS_STATUS = 'X', DATA_INICIO_CONTAGEM = :NEW.DATA_APURAÇÃO WHERE MAT = :NEW.SÓCIO_MAT;

	elsif deleting then
		UPDATE SÓCIO SET SYS_STATUS = 'X', DATA_INICIO_CONTAGEM = :OLD.DATA_INI_CONT WHERE MAT = :OLD.SÓCIO_MAT;

	end if;

end;*/
/
-- SETA TODOS NÃO EXCLUÍDOS, EFETIVOS SEM OBRGAÇÕES COMO QUITE
UPDATE SÓCIO SET OBRIG_STATUS_COD = 'QUITE' WHERE EXCLUÍDO = 0 AND CATEGORIA_COD = 'EFETIVO' AND OBRIG_STATUS_COD IS NULL;
/