--------------------------------------------------------------------------
-- PACOTE DE FUN��ES PARA O BANCO DE DADOS SBDB
--
-- Sistema Integrado da SBD
-- 
-- importante: * copiar cxrjlib.dll para c:\winnt\system32 do servidor
--------------------------------------------------------------------------



Create or Replace Package LSBD is

	Function  LSocio_Isento(nMat in number) Return varchar2;
	Procedure LSocio_Status(nMat in number, bTrigger in boolean default false);
	Procedure LObrigacao_Status(nMat in number,Atualiza in boolean default FALSE);
	Procedure LAltera_Categoria;
	Procedure LAtualiza_Obrig_Status(Atualiza in boolean default FALSE);
	Procedure LAtualiza_Socio_Status(Atualiza in boolean default FALSE);
	Procedure LExclui_Socio;
    	Procedure LExclui_Parcelas;
	Procedure LExtrato_emcd_simp (nMat in number,dtInicioContagem in date default null,dtFinalContagem in date default null) ;
	Procedure LExtrato_emcd_det (nMat in number, dtInicioContagem in date default null, dtFinalContagem in date default null) ;
	Procedure LCria_Job(vNomeJob in varchar2,vProced in varchar2, vHoraExec in varchar2,vIntervaloHoras in varchar2 default '24');
	Procedure LApaga_Job(vNomeJob in varchar2);
end;
/

CREATE OR REPLACE PACKAGE BODY LSBD is

      	--------------------------------------------------------------------------------------------------------------
	-- Fun��o que verifica se o s�cio � isento ou n�o, seguindo os crit�rios estabelecidos no estatuto.
	--------------------------------------------------------------------------------------------------------------
	Function LSocio_Isento(nMat in number) Return varchar2 is

  	DtDataNasc date;
  	dtDataIsento date;
  	nMatSocio number;
  	nTotReg number;
  	nAno number;  	
  	vCategoria S�CIO.CATEGORIA_COD%type;
	vTipoIsento varchar2(50);
  	vRetorno varchar2(50);
	nLinha number;

	begin			
	  		
  		nAno := TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) - 70;
  	  	dtDataIsento := TO_DATE(TO_CHAR(SYSDATE,'DD/MM')||'/'||TO_CHAR(nAno),'DD/MM/YYYY');
		-- Seleciona a categoria atual do s�cio.
  		SELECT MAT,DATA_NASCIMENTO,CATEGORIA_COD INTO nMatSocio,DtDataNasc,vCategoria FROM S�CIO WHERE MAT = nMat;
		-- Verifica se o s�cio possui isen��o tempor�ria na tabela S�CIO_ISEN��O
		begin
	  		SELECT max(ROWNUM) into nLinha FROM S�CIO_ISEN��O WHERE S�CIO_MAT = nMat;
			select mat,tipo into nTotReg,vTipoIsento from (select COUNT(S�CIO_MAT) as mat,TIPO,rownum as linha FROM S�CIO_ISEN��O WHERE S�CIO_MAT = nMat AND  (to_date(Data_Fim,'DD/MM/YYYY')>=TO_DATE(SYSDATE,'DD/MM/YYYY') OR DATA_FIM IS NULL) GROUP BY TIPO, rownum) where linha=nLinha;
		exception
			when NO_DATA_FOUND then
				nTotReg := 0;
		end;	
		
  	  	vRetorno := null;
  	  	-- Verifica os crit�rios de isen��o.
  	  	if (dtDataNasc <= dtDataISento) then
    	  		vRetorno := 'ISENTO';      	      
  	  	elsif vCategoria = 'BENEM�RITO' or vCategoria = 'HONOR�RIO' then
  	  		vRetorno := 'ISENTO';  	  		
 		elsif nTotReg > 0 then
  	  		vRetorno := 'ISENTO - ' || vTipoIsento;			
  	  	end if;
  	  
  	  	Return vRetorno;
	exception
        	when others then
                	raise_application_error(-20000, 'Erro em LSocio_Isento - ' || SQLERRM);		
	
	end LSocio_Isento;

        --------------------------------------------------------------------------------------------------------------
	-- Procedimento para excluir as parcelas 
	--------------------------------------------------------------------------------------------------------------
	Procedure LExclui_Parcelas is

	nComp number;

	begin

		for CurSocio in (SELECT MAT FROM S�CIO WHERE EXCLU�DO = 0 ORDER BY MAT) loop
                	nComp := 0;
 			SELECT COUNT(SEQ) into ncomp FROM OBRIGA��O WHERE OBRIG_STATUS_COD = 'VENCIDA' AND INSTR(OBRIG_TIPO,'ANUIDADE-PARCELA') <> 0 AND S�CIO_MAT = CurSocio.mAT AND (TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY') - TO_DATE(TO_CHAR(DATA_VENCIMENTO,'DD/MM/YYYY'),'DD/MM/YYYY') > 1);	 
                        
			IF NVL(ncomp,0) > 0 then
        		   DELETE FROM OBRIGA��O WHERE 
			   S�CIO_MAT = CurSocio.mAT 
			   AND 
			   INSTR(OBRIG_TIPO,'ANUIDADE-PARCELA') <> 0 
			   AND S�CIO_MAT NOT IN 
                           (
				SELECT OBB.S�CIO_MAT 
				FROM 
				OBRIGA��O OBB 
				WHERE 
				INSTR(OBB.OBRIG_TIPO,'ANUIDADE-PARCELA') <> 0 
				AND 
				OBB.OBRIG_STATUS_COD = 'VENCIDA' 
				AND 
 		            	(TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY') > TO_DATE(TO_CHAR(DATA_VENCIMENTO,'DD/MM/YYYY'),'DD/MM/YYYY') )		                          
                           	AND 
				OBB.S�CIO_MAT IN 
				(
				SELECT OB.S�CIO_MAT 
				FROM OBRIGA��O OB, PAGAMENTO PAG 
				WHERE 
				PAG.OBRIG_SEQ = OB.SEQ 
				AND 
				OB.S�CIO_MAT = PAG.S�CIO_MAT 
				AND 
                           	INSTR(OB.OBRIG_TIPO,'ANUIDADE-PARCELA') <> 0 GROUP BY OB.S�CIO_MAT));
                           	LSBD.LSOCIO_STATUS(CurSocio.MAT);                           
			End If;  

		end loop;


	exception
		when others then
                	raise_application_error(-20000, 'Erro em LExclui_Parcelas - ' || SQLERRM);

	end LExclui_Parcelas;

	--------------------------------------------------------------------------------------------------------------
	-- Altera o Status do s�cio de acordo com os status das obriga��es.
	--------------------------------------------------------------------------------------------------------------
	Procedure LSocio_Status(nMat in number, bTrigger in boolean default false) is

	nTotBaixado number;
	nTotAberto number;
	nTotVencido number;
	nTotSubst number;
	nTotBiblio number;
                nTotTolerancia number;
	vStatus OBRIGA��O.OBRIG_STATUS_COD%type;
	vTipoIsento OBRIGA��O.OBRIG_STATUS_COD%type;
        	v_Obrig_Status_Cod S�CIO.OBRIG_STATUS_COD%type;

	begin
                nTotTolerancia := 0;
		nTotVencido := 0;
		nTotAberto := 0;
		nTotBaixado := 0;
		nTotSubst := 0;
    		nTotBiblio:=0;
    
    		SELECT COUNT(*) INTO nTotTolerancia FROM OBRIGA��O O, PARCELAMENTO P WHERE OBRIG_STATUS_COD = 'VENCIDA' AND O.SEQ = P.OBRIG_NOVA AND O.S�CIO_MAT = P.S�CIO_MAT AND P.SEQ = 1 AND O.S�CIO_MAT = nMat AND TRUNC(SYSDATE-O.DATA_VENCIMENTO) <= 20;
    		SELECT COUNT(*) INTO nTotVencido FROM OBRIGA��O WHERE S�CIO_MAT = nMat AND  OBRIG_STATUS_COD = 'VENCIDA' AND ( (INSTR(OBRIG_TIPO,'ANUIDADE-PARCELA') = 0)  OR (TO_DATE(SYSDATE,'DD/MM/YYYY') > (SELECT NVL(TO_DATE(MAX(DATA_VENCIMENTO),'DD/MM/YYYY'),TO_DATE(SYSDATE,'DD/MM/YYYY')) AS DAT FROM OBRIGA��O WHERE INSTR(OBRIG_TIPO,'ANUIDADE-PARCELA') <> 0 AND S�CIO_MAT = nMat))) AND OBRIG_TIPO<>'DESPESAS BIBLIOTECA';
	  	SELECT COUNT(*) INTO nTotAberto FROM OBRIGA��O WHERE S�CIO_MAT = nMat AND OBRIG_STATUS_COD = 'EM ABERTO';
		SELECT COUNT(*) INTO nTotSubst FROM OBRIGA��O WHERE S�CIO_MAT = nMat AND OBRIG_STATUS_COD = 'SUBSTITUIDA';
		SELECT COUNT(*) INTO nTotBaixado FROM OBRIGA��O WHERE S�CIO_MAT = nMat AND OBRIG_STATUS_COD = 'BAIXADA';
		SELECT COUNT(*) INTO nTotBiblio FROM OBRIGA��O WHERE S�CIO_MAT = nMat AND OBRIG_STATUS_COD = 'VENCIDA' AND OBRIG_TIPO='DESPESAS BIBLIOTECA';
		SELECT LSBD.LSOCIO_ISENTO(MAT) SOCIO_STATUS INTO vTipoIsento FROM S�CIO WHERE MAT = nMat;
		SELECT OBRIG_STATUS_COD INTO v_Obrig_Status_Cod FROM SBDB.S�CIO WHERE MAT=nMat;
		if NOT vTipoIsento IS NULL then
			vStatus := vTipoIsento;
    		elsif nTotTolerancia > 0 then
      			vStatus := 'QUITE - TL';
		elsif nTotVencido > 0 then
			vStatus := 'INADIMPLENTE';
		elsif nTotAberto > 0 then
			vStatus := 'QUITE - CO';
	  	ELSIF nTotAberto=0 AND nTotBiblio>0 then
			vStatus := 'QUITE - CO';
		elsif nTotBaixado > 0 then
			vStatus := 'QUITE';
		else
			vStatus := 'RECENTE';
		end if;

		if v_Obrig_Status_Cod<>vStatus then
			if   bTrigger then
				UPDATE S�CIO SET OBRIG_STATUS_COD = vStatus ,OBRIG_STATUS_DATA = SYSDATE WHERE MAT = nMat;
			else
				UPDATE S�CIO SET OBRIG_STATUS_COD = vStatus ,OBRIG_STATUS_DATA = SYSDATE, SYS_STATUS = 'X' WHERE MAT = nMat;
			end if;
		end if;



	exception
        	when others then
                	raise_application_error(-20000, 'Erro em LSocio_Status - ' || SQLERRM);

	end LSocio_Status;

	--------------------------------------------------------------------------------------------------------------
	-- Altera o Status da Obriga��o de acordo com o pagamento realizado.
	--------------------------------------------------------------------------------------------------------------
	Procedure LObrigacao_Status(nMat in number,Atualiza in boolean default FALSE) is

	dtDataDesc date;
	flValDesc float;
	flDesc float;
	vObrigStatus OBRIGA��O.OBRIG_STATUS_COD%type;
	bSemDesc boolean;
	nDataVencimento date;
        nDataSistema date;
	begin
		bSemDesc := false;
		-- Cursor para sele��o das obriga��es e pagamentos do s�cio.
		for CurObrigPag in (SELECT OBRIGA��O.S�CIO_MAT,OBRIGA��O.SEQ,OBRIGA��O.DATA_LAN�AMENTO,OBRIGA��O.DATA_VENCIMENTO,ROUND(NVL(OBRIGA��O.VALOR,0),2) AS OBRIG_VALOR,TRIM(OBRIGA��O.OBRIG_TIPO) AS TIPO,OBRIGA��O.COMPET�NCIA,OBRIGA��O.OBRIG_STATUS_COD,MAX(PAGAMENTO.DATA) AS PAG_DATA,ROUND(SUM(NVL(PAGAMENTO.VALOR,0)),2) AS PAG_VALOR,SUM(NVL(PAGAMENTO.DESCONTO,0)) AS PAG_DESC,SUM(NVL(PAGAMENTO.MULTA,0)) AS PAG_MULTA,SUM(NVL(PAGAMENTO.JUROS,0)) AS PAG_JUROS FROM SBDB.OBRIGA��O,SBDB.PAGAMENTO 
					WHERE ((OBRIGA��O.OBRIG_STATUS_COD NOT IN ('SUBSTITUIDA','CANCELADA')) OR OBRIGA��O.OBRIG_STATUS_COD IS NULL) AND PAGAMENTO.OBRIG_SEQ(+) = OBRIGA��O.SEQ AND PAGAMENTO.S�CIO_MAT(+) = OBRIGA��O.S�CIO_MAT AND OBRIGA��O.S�CIO_MAT = nMat GROUP BY OBRIGA��O.S�CIO_MAT,OBRIGA��O.SEQ,OBRIGA��O.DATA_LAN�AMENTO,OBRIGA��O.DATA_VENCIMENTO,OBRIGA��O.VALOR,OBRIGA��O.OBRIG_TIPO,
OBRIGA��O.COMPET�NCIA,OBRIGA��O.OBRIG_STATUS_COD ORDER BY OBRIGA��O.S�CIO_MAT,OBRIGA��O.SEQ) loop		
			-- Verifica se o s�cio possui um pagamento correspondente a obriga��o corrente.Se n�o possuir pagamento antes do vencimento da obriga��o STATUS "EM ABERTO", sen�o STATUS "VENCIDA".	
                        if (CurObrigPag.PAG_DATA IS NULL) AND (CurObrigPag.PAG_VALOR = 0) then

				nDataVencimento := CurObrigPag.DATA_VENCIMENTO;
                                nDatasistema :=  SYSDATE;
				if (TRUNC(nDataVencimento - nDatasistema) < 0) then
					vObrigStatus := 'VENCIDA';
				else
					vObrigStatus := 'EM ABERTO';
				end if;	
			else				
				-- Se a obriga��o for do tipo ANUIDADE , ANUIDADE - COTA �NIC ou PARCELAMENTO verifica se a anuidade possui desconto.(De acordo com a data de pagamento).
				if (CurObrigPag.TIPO = 'ANUIDADE') or (CurObrigPag.TIPO = 'ANUIDADE - COTA �NICA') or (CurObrigPag.TIPO = 'PARCELAMENTO') or (CurObrigPag.TIPO = 'ANUIDADE-PARCELA 1') or (CurObrigPag.TIPO = 'ANUIDADE-PARCELA 2') or (CurObrigPag.TIPO = 'ANUIDADE-PARCELA 3') then			
					begin
						SELECT DATA_DESCONTO,VALOR,DESCONTO INTO dtDataDesc,flValDesc,flDesc FROM
						(SELECT ANUIDADE_DESCONTO.DATA_DESCONTO, NVL(ANUIDADE_DESCONTO.VALOR,0) AS VALOR, NVL(ANUIDADE_DESCONTO.DESCONTO,0) AS DESCONTO
FROM S�CIO,ANUIDADE_CATEGORIA,ANUIDADE_DESCONTO WHERE ANUIDADE_CATEGORIA.CATEGORIA_COD(+) = S�CIO.CATEGORIA_COD AND ANUIDADE_DESCONTO.ANUIDADE_REF(+) = ANUIDADE_CATEGORIA.ANUIDADE_REF AND ANUIDADE_DESCONTO.CATEGORIA_COD(+) = ANUIDADE_CATEGORIA.CATEGORIA_COD AND S�CIO.MAT = CurObrigPag.S�CIO_MAT AND ANUIDADE_DESCONTO.DATA_DESCONTO >= CurObrigPag.PAG_DATA
ORDER BY ANUIDADE_DESCONTO.DATA_DESCONTO) WHERE ROWNUM = 1;
					-- Se n�o encontrar desconto para a data do pagamento altera flag para true.
					exception
						when NO_DATA_FOUND then
							bSemDesc := true;					
					end;
				end if;
				-- Se a data de pagamento for <= a data do vencimento verifica se o valor de pagamento confere com o valor da obriga��o.
				if CurObrigPag.PAG_DATA <= CurObrigPag.DATA_VENCIMENTO then 				
					if (CurObrigPag.TIPO = 'ANUIDADE') or (CurObrigPag.TIPO = 'ANUIDADE - COTA �NICA') or (CurObrigPag.TIPO = 'PARCELAMENTO') or (CurObrigPag.TIPO = 'ANUIDADE-PARCELA 1') or (CurObrigPag.TIPO = 'ANUIDADE-PARCELA 2') or (CurObrigPag.TIPO = 'ANUIDADE-PARCELA 3') then
						-- Se a obriga��o for do tipo "ANUIDADE" ou "ANUIDADE - COTA �NICA"e o Valor da obriga��o = (valor pag + valor desc), ou se a <> (valor obrig - valor pag) <= valor desc).(Pagou com desconto)												
						if (ABS(CurObrigPag.OBRIG_VALOR - CurObrigPag.PAG_VALOR) <= flDesc) OR (CurObrigPag.OBRIG_VALOR <= (CurObrigPag.PAG_VALOR + CurObrigPag.PAG_DESC)) then
							vObrigStatus := 'BAIXADA';
						-- Se o valor pag > valor obrig(Pagou a maior).
						elsif CurObrigPag.PAG_VALOR > CurObrigPag.OBRIG_VALOR then
							vObrigStatus := 'BAIXADA';
						-- Se o valor pag < valor obrig(Pagou a menor).
						else
							vObrigStatus := 'EM ABERTO';					
						end if;					
					elsif CurObrigPag.PAG_VALOR < CurObrigPag.OBRIG_VALOR then
						vObrigStatus := 'EM ABERTO';				
					else
						vObrigStatus := 'BAIXADA';				
					end if;			
				else
					if (CurObrigPag.PAG_VALOR + CurObrigPag.PAG_DESC) < CurObrigPag.OBRIG_VALOR then
						vObrigStatus := 'EM ABERTO';				
					else
						vObrigStatus := 'BAIXADA';				
					end if;			
				end if;
			end if;
			-- Atualiza o status da obriga��o.
			if Atualiza then
	  	    		UPDATE OBRIGA��O SET OBRIG_STATUS_COD = vObrigStatus,SYS_STATUS = 'X' WHERE S�CIO_MAT = CurObrigPag.S�CIO_MAT AND 
                	        SEQ = CurObrigPag.SEQ;										
			ELSE
	  	    		UPDATE OBRIGA��O SET OBRIG_STATUS_COD = vObrigStatus WHERE S�CIO_MAT = CurObrigPag.S�CIO_MAT AND 
                	        SEQ = CurObrigPag.SEQ;										
			END IF;
		end loop;

	exception
        	when others then
                	raise_application_error(-20000, 'Erro em LObrigacao_Status - ' || SQLERRM);		

	end LObrigacao_Status;

	--------------------------------------------------------------------------------------------------------------
	-- Altera a categoria dos s�cios ASPIRANTES, com 5 anos de cadastro, para s�cios CONTRIBUINTES.
	--------------------------------------------------------------------------------------------------------------
	Procedure LAltera_Categoria is

	nCategSeq number;
	begin
		-- Seleciona os s�cio ASPIRANTES com 5 anos(1826 dias) entre a data de cadastro e a data atual.
		-- Atualiza a categoria para CONTRIBUINTE, e insere na tabela de S�CIO_CATEGORIA com a Obs. "ALTERA��O DE CATEGORIA CONFORME ESTATUTO".
		for Cur in (SELECT MAT,CATEGORIA_COD,DATA_CADASTRO FROM S�CIO WHERE CATEGORIA_COD = 'ASPIRANTE' AND ABS(TRUNC(SYSDATE - DATA_CADASTRO)) >= 1826 ORDER BY MAT) loop
			SELECT NVL(MAX(SEQ),0)+ 1 AS SEQ INTO nCategSeq FROM S�CIO_CATEGORIA WHERE S�CIO_MAT = Cur.MAT;
			UPDATE S�CIO SET CATEGORIA_COD = 'CONTRIBUINTE', SYS_STATUS = 'X' WHERE MAT = Cur.MAT;
			INSERT INTO S�CIO_CATEGORIA (S�CIO_MAT,CATEGORIA_COD,SEQ,DATA_ALTERA��O,OBS) VALUES (Cur.MAT,'CONTRIBUINTE',nCategSeq,TO_DATE(TO_CHAR(Cur.DATA_CADASTRO,'DD/MM')||'/'||TO_CHAR(SYSDATE,'YYYY'),'dd/mm/yyyy'),
'ALTERA��O DE CATEGORIA CONFORME ESTATUTO');
		end loop;
		Commit;
	exception
        	when others then
                	raise_application_error(-20000, 'Erro em LAltera_Categoria - ' || SQLERRM);	

	end LAltera_Categoria;

	--------------------------------------------------------------------------------------------------------------
	-- Procedimento para atualizar o status(FIN) das obriga��es pertinentes aos s�cios
	--------------------------------------------------------------------------------------------------------------
	Procedure LAtualiza_Obrig_Status(Atualiza in boolean default FALSE) is

	nI NUMBER;
	Cursor CurSocio IS 
		SELECT MAT FROM S�CIO ORDER BY MAT;
	Begin
		nI := 0;
		for Cur in CurSocio loop
			LSBD.LOBRIGACAO_STATUS(CUR.MAT,Atualiza);
			nI := nI + 1;
		end loop;
		Commit;

	exception
        	when others then
                	raise_application_error(-20000, 'Erro em LAtualiza_Obrig_Status - ' || SQLERRM);		
	
	end LAtualiza_Obrig_Status;

	--------------------------------------------------------------------------------------------------------------
	-- Procedimento para atualizar o status(FIN) de todos s�cio
	--------------------------------------------------------------------------------------------------------------
	Procedure LAtualiza_Socio_Status(Atualiza in boolean default FALSE) is
		
	nI NUMBER;
	Cursor CurSocio IS 
		SELECT MAT FROM S�CIO ORDER BY MAT;
	Begin
		nI := 0;
		for Cur in CurSocio loop
			LSBD.LSOCIO_STATUS(CUR.MAT,Atualiza);
			Commit;
			nI := nI + 1;
		end loop;

	exception
        	when others then
                	raise_application_error(-20000, 'Erro em LAtualiza_Socio_Status - ' || SQLERRM);		
	
	end LAtualiza_Socio_Status;

	
	--------------------------------------------------------------------------------------------------------------
	-- Procedimento para verificar todos os s�cios e exclu�-los caso tenham 2 anuidades vencidas consecutivas
	--------------------------------------------------------------------------------------------------------------
	Procedure LExclui_Socio is

	nComp number;

	begin

		for CurSocio in (SELECT MAT FROM S�CIO WHERE EXCLU�DO = 0 AND OBRIG_STATUS_COD = 'INADIMPLENTE' ORDER BY MAT) loop
			nComp := 0;
			for CurObrig in (SELECT SEQ, TO_CHAR(COMPET�NCIA,'YYYY') COMPETENCIA FROM OBRIGA��O WHERE S�CIO_MAT = CurSocio.Mat AND OBRIG_STATUS_COD = 'VENCIDA' ORDER BY SEQ) loop
				if nComp = 0 then
					nComp := To_Number(CurObrig.Competencia);
				else
					if (nComp + 1 = To_Number(CurObrig.Competencia)) then
						UPDATE S�CIO SET SYS_STATUS = 'X', EXCLU�DO = -1, DATA_EXCLUS�O = SYSDATE, MOTIVO_EXCLUS�O = 'EXCLUS�O POR INADIMPL�NCIA CONFORME ESTATUTO', RESP_EXCLUS�O = 'ADMINISTRA��O'
						WHERE MAT = CurSocio.MAT;
						EXIT;
					else
						nComp := To_Number(CurObrig.Competencia);
					end if;
				end if;	
			end loop;
		end loop;
		--Commit;

	exception
		when others then
                	raise_application_error(-20000, 'Erro em LExclui_Socio - ' || SQLERRM);

	end LExclui_Socio;

	
	--------------------------------------------------------------------------------------------------------------
	-- Procedimento para preencher a tabela tempor�ria TEMP_EXTRATO_ATIV com as atividades realizadas pelo associado
	-- de n�vel n� 2 somando a pontua��o dos sub-n�veis para o relat�rio de extrato simplificado
	--------------------------------------------------------------------------------------------------------------
	Procedure LExtrato_emcd_simp (nMat in number,dtInicioContagem in date default null,dtFinalContagem in date default null) is

	nCodAtiv number;
	nCodAtiv2 number;
	vNomeAtiv varchar2(100);
	nSuperior number;
	nN�vel number;
	dtDataIniCont date;
        dtDataFimCont date; 
	bAchouNivel2 boolean;

	begin
		if dtInicioContagem is null then
			SELECT DATA_INICIO_CONTAGEM INTO dtDataIniCont FROM S�CIO WHERE MAT = nMat;
                        dtDataFimCont :=  (TO_CHAR(dtDataIniCont,'DD/MM/')) ||  (TO_CHAR(dtDataIniCont,'YYYY') + 5);
		else
			dtDataIniCont := dtInicioContagem;
                        dtDatafimCont := dtFinalContagem;
                        
		end if;
                
                
 
		For CurAtiv in (SELECT S.MAT,S.NOME,S.DATA_INICIO_CONTAGEM,A.NOME NOME_ATIV,A.COD,A.N�VEL_N�,A.SUPERIOR,PS.PONTO_VALOR
				FROM S�CIO S,EMCD_ATIVIDADE A,EMCD_PONTO_S�CIO PS,EMCD_TIPO_PONTO TP 
				WHERE S.MAT = PS.S�CIO_MAT AND A.COD = PS.ATIV_COD AND PS.PONTO_COD = TP.COD AND S.EXCLU�DO = 0 
      				AND (PS.PONTO_DATA >= dtDataIniCont AND PS.PONTO_DATA <= dtDatafimCont) AND S.MAT = nMat AND TP.COD <> 1 AND S.EXCLU�DO = 0
				ORDER BY A.N�VEL_N�) loop
			bAchouNivel2 := false;
			if CurAtiv.N�VEL_N� <= 2 then
				INSERT INTO TEMP_EXTRATO_ATIV(MAT,NOME,DATA_INICIO_CONTAGEM,DATA_PERIODO,NOME_ATIV,COD_ATIV,N�VEL_N�,SUPERIOR,PONTO_VALOR) 
				VALUES (CurAtiv.MAT,CurAtiv.NOME,CurAtiv.DATA_INICIO_CONTAGEM,dtDataIniCont,CurAtiv.NOME_ATIV,CurAtiv.COD,CurAtiv.N�VEL_N�,CurAtiv.SUPERIOR,CurAtiv.PONTO_VALOR);
			else
				nSuperior := CurAtiv.SUPERIOR;
				while not bAchouNivel2 loop
					SELECT COD,NOME,N�VEL_N�,SUPERIOR INTO nCodAtiv,vNomeAtiv,nN�vel,nSuperior FROM EMCD_ATIVIDADE WHERE COD = nSuperior;
					if nN�vel = 2 then
						begin
							bAchouNivel2 := true;
							SELECT COD_ATIV INTO nCodAtiv2 FROM TEMP_EXTRATO_ATIV WHERE COD_ATIV = nCodAtiv AND MAT = nMat;
							UPDATE TEMP_EXTRATO_ATIV SET PONTO_VALOR = PONTO_VALOR + CurAtiv.PONTO_VALOR WHERE COD_ATIV = nCodAtiv2;
						   exception
							when NO_DATA_FOUND then
								INSERT INTO TEMP_EXTRATO_ATIV(MAT,NOME,DATA_INICIO_CONTAGEM,DATA_PERIODO,NOME_ATIV,COD_ATIV,N�VEL_N�,SUPERIOR,PONTO_VALOR) 
								VALUES (CurAtiv.MAT,CurAtiv.NOME,CurAtiv.DATA_INICIO_CONTAGEM,dtDataIniCont,vNomeAtiv,nCodAtiv,nN�vel,nSuperior,CurAtiv.PONTO_VALOR);
						end;
					end if;
				end loop;
			end if;
		end loop;
	exception
        	when others then
                	raise_application_error(-20000, 'Erro em LExtrato_emcd_simp - ' || SQLERRM);

	end LExtrato_emcd_simp;

	--------------------------------------------------------------------------------------------------------------
	-- Procedimento para preencher a tabela tempor�ria TEMP_EXTRATO_ATIV com as atividades realizadas pelo associado
	-- junto com o c�digo da atividade superior a ela para a gera��o do extrato detalhado
	--------------------------------------------------------------------------------------------------------------
	Procedure LExtrato_emcd_det (nMat in number, dtInicioContagem in date default null, dtFinalContagem in date default null) is

	dtDataIniCont date;
	dtDatafimCont date;
	nCodAtiv number;
	nSuperior number;
	nN�vel number;
	bAchouNivel2 boolean;


	begin
                if dtInicioContagem is null then
			SELECT DATA_INICIO_CONTAGEM INTO dtDataIniCont FROM S�CIO WHERE MAT = nMat;
                        dtDataFimCont :=  (TO_CHAR(dtDataIniCont,'DD/MM/')) ||  (TO_CHAR(dtDataIniCont,'YYYY') + 5);
		else
			dtDataIniCont := dtInicioContagem;
                        dtDatafimCont := dtFinalContagem;
		end if;
		For CurAtiv in (SELECT S.MAT,S.DATA_INICIO_CONTAGEM,PS.ATIV_COD,PS.PONTO_COD,PS.PONTO_VALOR,A.N�VEL_N�,A.SUPERIOR
				FROM S�CIO S,EMCD_PONTO_S�CIO PS,EMCD_ATIVIDADE A
				WHERE S.MAT = PS.S�CIO_MAT AND PS.ATIV_COD = A.COD AND S.MAT = nMat AND (PS.PONTO_DATA >= dtDataIniCont AND PS.PONTO_DATA <= dtDataFimCont) AND PS.PONTO_COD <> 1 
				ORDER BY N�VEL_N�) loop
			bAchouNivel2 := false;
			if CurAtiv.N�VEL_N� <= 2 then
				INSERT INTO TEMP_EXTRATO_ATIV (MAT,DATA_INICIO_CONTAGEM,COD_ATIV,COD_ATIV_PAI,PONTO_COD,PONTO_VALOR,N�VEL_N�,SUPERIOR)
				VALUES (CurAtiv.MAT,CurAtiv.DATA_INICIO_CONTAGEM,CurAtiv.ATIV_COD,CurAtiv.ATIV_COD,CurAtiv.PONTO_COD,CurAtiv.PONTO_VALOR,CurAtiv.N�VEL_N�,CurAtiv.SUPERIOR);
			else
				nSuperior := CurAtiv.SUPERIOR;
				while not bAchouNivel2 loop
					SELECT COD,N�VEL_N�,SUPERIOR INTO nCodAtiv,nN�vel,nSuperior FROM EMCD_ATIVIDADE WHERE COD = nSuperior;
					if nN�vel = 2 then
						bAchouNivel2 := true;
						INSERT INTO TEMP_EXTRATO_ATIV (MAT,DATA_INICIO_CONTAGEM,COD_ATIV,COD_ATIV_PAI,PONTO_COD,PONTO_VALOR,N�VEL_N�,SUPERIOR)
						VALUES (CurAtiv.MAT,dtDataIniCont,CurAtiv.ATIV_COD,nCodAtiv,CurAtiv.PONTO_COD,CurAtiv.PONTO_VALOR,CurAtiv.N�VEL_N�,CurAtiv.SUPERIOR);
					end if;
				end loop;
			end if;
		end loop;
	exception
        	when others then
                	raise_application_error(-20000, 'Erro em LExtrato_emcd_det - ' || SQLERRM);

	end LExtrato_emcd_det;

  
	--------------------------------------------------------------------------------------------------------------
	-- Procedimento para cria��o de jobs(tarefas) a serem executadas periodicamente no Oracle
	--------------------------------------------------------------------------------------------------------------
	Procedure LCria_Job(vNomeJob in varchar2,vProced in varchar2, vHoraExec in varchar2,vIntervaloHoras in varchar2 default '24') as 

        job binary_integer;

        begin
                begin
                        for cur in (select job from user_jobs where what like '% ' || vNomeJob || ' %') loop
                        	dbms_job.remove(cur.job);
                        end loop;
                exception
                        when others then
                                null;
                end;
                dbms_job.submit(job, '/* ' || vNomeJob || ' */begin ' || vProced || ';end;',to_date('' || to_char(sysdate,'DD-MM-YYYY') || ' ' || VHoraExec ||'','DD-MM-YYYY HH24:MI:SS'), 'SYSDATE+(' ||vIntervaloHoras || '/24)');

        end LCria_Job;
	
	--------------------------------------------------------------------------------------------------------------
	-- Procedimento para exclus�o de jobs(tarefas) no Oracle
	--------------------------------------------------------------------------------------------------------------
	procedure LApaga_Job(vNomeJob in varchar2) as

        job binary_integer;

        begin
                begin
                        for cur in (select job from user_jobs where what like '% ' || vNomeJob || ' %') loop
                                dbms_job.remove(cur.job);
                        end loop;
                end;
        end LApaga_Job;

end LSBD;
/