--------------------------------------------------------------------------
-- PACOTE DE FUNÇÕES PARA O BANCO DE DADOS SBDB
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
	-- Função que verifica se o sócio é isento ou não, seguindo os critérios estabelecidos no estatuto.
	--------------------------------------------------------------------------------------------------------------
	Function LSocio_Isento(nMat in number) Return varchar2 is

  	DtDataNasc date;
  	dtDataIsento date;
  	nMatSocio number;
  	nTotReg number;
  	nAno number;  	
  	vCategoria SÓCIO.CATEGORIA_COD%type;
	vTipoIsento varchar2(50);
  	vRetorno varchar2(50);
	nLinha number;

	begin			
	  		
  		nAno := TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) - 70;
  	  	dtDataIsento := TO_DATE(TO_CHAR(SYSDATE,'DD/MM')||'/'||TO_CHAR(nAno),'DD/MM/YYYY');
		-- Seleciona a categoria atual do sócio.
  		SELECT MAT,DATA_NASCIMENTO,CATEGORIA_COD INTO nMatSocio,DtDataNasc,vCategoria FROM SÓCIO WHERE MAT = nMat;
		-- Verifica se o sócio possui isenção temporária na tabela SÓCIO_ISENÇÃO
		begin
	  		SELECT max(ROWNUM) into nLinha FROM SÓCIO_ISENÇÃO WHERE SÓCIO_MAT = nMat;
			select mat,tipo into nTotReg,vTipoIsento from (select COUNT(SÓCIO_MAT) as mat,TIPO,rownum as linha FROM SÓCIO_ISENÇÃO WHERE SÓCIO_MAT = nMat AND  (to_date(Data_Fim,'DD/MM/YYYY')>=TO_DATE(SYSDATE,'DD/MM/YYYY') OR DATA_FIM IS NULL) GROUP BY TIPO, rownum) where linha=nLinha;
		exception
			when NO_DATA_FOUND then
				nTotReg := 0;
		end;	
		
  	  	vRetorno := null;
  	  	-- Verifica os critérios de isenção.
  	  	if (dtDataNasc <= dtDataISento) then
    	  		vRetorno := 'ISENTO';      	      
  	  	elsif vCategoria = 'BENEMÉRITO' or vCategoria = 'HONORÁRIO' then
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

		for CurSocio in (SELECT MAT FROM SÓCIO WHERE EXCLUÍDO = 0 ORDER BY MAT) loop
                	nComp := 0;
 			SELECT COUNT(SEQ) into ncomp FROM OBRIGAÇÃO WHERE OBRIG_STATUS_COD = 'VENCIDA' AND INSTR(OBRIG_TIPO,'ANUIDADE-PARCELA') <> 0 AND SÓCIO_MAT = CurSocio.mAT AND (TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY') - TO_DATE(TO_CHAR(DATA_VENCIMENTO,'DD/MM/YYYY'),'DD/MM/YYYY') > 1);	 
                        
			IF NVL(ncomp,0) > 0 then
        		   DELETE FROM OBRIGAÇÃO WHERE 
			   SÓCIO_MAT = CurSocio.mAT 
			   AND 
			   INSTR(OBRIG_TIPO,'ANUIDADE-PARCELA') <> 0 
			   AND SÓCIO_MAT NOT IN 
                           (
				SELECT OBB.SÓCIO_MAT 
				FROM 
				OBRIGAÇÃO OBB 
				WHERE 
				INSTR(OBB.OBRIG_TIPO,'ANUIDADE-PARCELA') <> 0 
				AND 
				OBB.OBRIG_STATUS_COD = 'VENCIDA' 
				AND 
 		            	(TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY') > TO_DATE(TO_CHAR(DATA_VENCIMENTO,'DD/MM/YYYY'),'DD/MM/YYYY') )		                          
                           	AND 
				OBB.SÓCIO_MAT IN 
				(
				SELECT OB.SÓCIO_MAT 
				FROM OBRIGAÇÃO OB, PAGAMENTO PAG 
				WHERE 
				PAG.OBRIG_SEQ = OB.SEQ 
				AND 
				OB.SÓCIO_MAT = PAG.SÓCIO_MAT 
				AND 
                           	INSTR(OB.OBRIG_TIPO,'ANUIDADE-PARCELA') <> 0 GROUP BY OB.SÓCIO_MAT));
                           	LSBD.LSOCIO_STATUS(CurSocio.MAT);                           
			End If;  

		end loop;


	exception
		when others then
                	raise_application_error(-20000, 'Erro em LExclui_Parcelas - ' || SQLERRM);

	end LExclui_Parcelas;

	--------------------------------------------------------------------------------------------------------------
	-- Altera o Status do sócio de acordo com os status das obrigações.
	--------------------------------------------------------------------------------------------------------------
	Procedure LSocio_Status(nMat in number, bTrigger in boolean default false) is

	nTotBaixado number;
	nTotAberto number;
	nTotVencido number;
	nTotSubst number;
	nTotBiblio number;
                nTotTolerancia number;
	vStatus OBRIGAÇÃO.OBRIG_STATUS_COD%type;
	vTipoIsento OBRIGAÇÃO.OBRIG_STATUS_COD%type;
        	v_Obrig_Status_Cod SÓCIO.OBRIG_STATUS_COD%type;

	begin
                nTotTolerancia := 0;
		nTotVencido := 0;
		nTotAberto := 0;
		nTotBaixado := 0;
		nTotSubst := 0;
    		nTotBiblio:=0;
    
    		SELECT COUNT(*) INTO nTotTolerancia FROM OBRIGAÇÃO O, PARCELAMENTO P WHERE OBRIG_STATUS_COD = 'VENCIDA' AND O.SEQ = P.OBRIG_NOVA AND O.SÓCIO_MAT = P.SÓCIO_MAT AND P.SEQ = 1 AND O.SÓCIO_MAT = nMat AND TRUNC(SYSDATE-O.DATA_VENCIMENTO) <= 20;
    		SELECT COUNT(*) INTO nTotVencido FROM OBRIGAÇÃO WHERE SÓCIO_MAT = nMat AND  OBRIG_STATUS_COD = 'VENCIDA' AND ( (INSTR(OBRIG_TIPO,'ANUIDADE-PARCELA') = 0)  OR (TO_DATE(SYSDATE,'DD/MM/YYYY') > (SELECT NVL(TO_DATE(MAX(DATA_VENCIMENTO),'DD/MM/YYYY'),TO_DATE(SYSDATE,'DD/MM/YYYY')) AS DAT FROM OBRIGAÇÃO WHERE INSTR(OBRIG_TIPO,'ANUIDADE-PARCELA') <> 0 AND SÓCIO_MAT = nMat))) AND OBRIG_TIPO<>'DESPESAS BIBLIOTECA';
	  	SELECT COUNT(*) INTO nTotAberto FROM OBRIGAÇÃO WHERE SÓCIO_MAT = nMat AND OBRIG_STATUS_COD = 'EM ABERTO';
		SELECT COUNT(*) INTO nTotSubst FROM OBRIGAÇÃO WHERE SÓCIO_MAT = nMat AND OBRIG_STATUS_COD = 'SUBSTITUIDA';
		SELECT COUNT(*) INTO nTotBaixado FROM OBRIGAÇÃO WHERE SÓCIO_MAT = nMat AND OBRIG_STATUS_COD = 'BAIXADA';
		SELECT COUNT(*) INTO nTotBiblio FROM OBRIGAÇÃO WHERE SÓCIO_MAT = nMat AND OBRIG_STATUS_COD = 'VENCIDA' AND OBRIG_TIPO='DESPESAS BIBLIOTECA';
		SELECT LSBD.LSOCIO_ISENTO(MAT) SOCIO_STATUS INTO vTipoIsento FROM SÓCIO WHERE MAT = nMat;
		SELECT OBRIG_STATUS_COD INTO v_Obrig_Status_Cod FROM SBDB.SÓCIO WHERE MAT=nMat;
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
				UPDATE SÓCIO SET OBRIG_STATUS_COD = vStatus ,OBRIG_STATUS_DATA = SYSDATE WHERE MAT = nMat;
			else
				UPDATE SÓCIO SET OBRIG_STATUS_COD = vStatus ,OBRIG_STATUS_DATA = SYSDATE, SYS_STATUS = 'X' WHERE MAT = nMat;
			end if;
		end if;



	exception
        	when others then
                	raise_application_error(-20000, 'Erro em LSocio_Status - ' || SQLERRM);

	end LSocio_Status;

	--------------------------------------------------------------------------------------------------------------
	-- Altera o Status da Obrigação de acordo com o pagamento realizado.
	--------------------------------------------------------------------------------------------------------------
	Procedure LObrigacao_Status(nMat in number,Atualiza in boolean default FALSE) is

	dtDataDesc date;
	flValDesc float;
	flDesc float;
	vObrigStatus OBRIGAÇÃO.OBRIG_STATUS_COD%type;
	bSemDesc boolean;
	nDataVencimento date;
        nDataSistema date;
	begin
		bSemDesc := false;
		-- Cursor para seleção das obrigações e pagamentos do sócio.
		for CurObrigPag in (SELECT OBRIGAÇÃO.SÓCIO_MAT,OBRIGAÇÃO.SEQ,OBRIGAÇÃO.DATA_LANÇAMENTO,OBRIGAÇÃO.DATA_VENCIMENTO,ROUND(NVL(OBRIGAÇÃO.VALOR,0),2) AS OBRIG_VALOR,TRIM(OBRIGAÇÃO.OBRIG_TIPO) AS TIPO,OBRIGAÇÃO.COMPETÊNCIA,OBRIGAÇÃO.OBRIG_STATUS_COD,MAX(PAGAMENTO.DATA) AS PAG_DATA,ROUND(SUM(NVL(PAGAMENTO.VALOR,0)),2) AS PAG_VALOR,SUM(NVL(PAGAMENTO.DESCONTO,0)) AS PAG_DESC,SUM(NVL(PAGAMENTO.MULTA,0)) AS PAG_MULTA,SUM(NVL(PAGAMENTO.JUROS,0)) AS PAG_JUROS FROM SBDB.OBRIGAÇÃO,SBDB.PAGAMENTO 
					WHERE ((OBRIGAÇÃO.OBRIG_STATUS_COD NOT IN ('SUBSTITUIDA','CANCELADA')) OR OBRIGAÇÃO.OBRIG_STATUS_COD IS NULL) AND PAGAMENTO.OBRIG_SEQ(+) = OBRIGAÇÃO.SEQ AND PAGAMENTO.SÓCIO_MAT(+) = OBRIGAÇÃO.SÓCIO_MAT AND OBRIGAÇÃO.SÓCIO_MAT = nMat GROUP BY OBRIGAÇÃO.SÓCIO_MAT,OBRIGAÇÃO.SEQ,OBRIGAÇÃO.DATA_LANÇAMENTO,OBRIGAÇÃO.DATA_VENCIMENTO,OBRIGAÇÃO.VALOR,OBRIGAÇÃO.OBRIG_TIPO,
OBRIGAÇÃO.COMPETÊNCIA,OBRIGAÇÃO.OBRIG_STATUS_COD ORDER BY OBRIGAÇÃO.SÓCIO_MAT,OBRIGAÇÃO.SEQ) loop		
			-- Verifica se o sócio possui um pagamento correspondente a obrigação corrente.Se não possuir pagamento antes do vencimento da obrigação STATUS "EM ABERTO", senão STATUS "VENCIDA".	
                        if (CurObrigPag.PAG_DATA IS NULL) AND (CurObrigPag.PAG_VALOR = 0) then

				nDataVencimento := CurObrigPag.DATA_VENCIMENTO;
                                nDatasistema :=  SYSDATE;
				if (TRUNC(nDataVencimento - nDatasistema) < 0) then
					vObrigStatus := 'VENCIDA';
				else
					vObrigStatus := 'EM ABERTO';
				end if;	
			else				
				-- Se a obrigação for do tipo ANUIDADE , ANUIDADE - COTA ÚNIC ou PARCELAMENTO verifica se a anuidade possui desconto.(De acordo com a data de pagamento).
				if (CurObrigPag.TIPO = 'ANUIDADE') or (CurObrigPag.TIPO = 'ANUIDADE - COTA ÚNICA') or (CurObrigPag.TIPO = 'PARCELAMENTO') or (CurObrigPag.TIPO = 'ANUIDADE-PARCELA 1') or (CurObrigPag.TIPO = 'ANUIDADE-PARCELA 2') or (CurObrigPag.TIPO = 'ANUIDADE-PARCELA 3') then			
					begin
						SELECT DATA_DESCONTO,VALOR,DESCONTO INTO dtDataDesc,flValDesc,flDesc FROM
						(SELECT ANUIDADE_DESCONTO.DATA_DESCONTO, NVL(ANUIDADE_DESCONTO.VALOR,0) AS VALOR, NVL(ANUIDADE_DESCONTO.DESCONTO,0) AS DESCONTO
FROM SÓCIO,ANUIDADE_CATEGORIA,ANUIDADE_DESCONTO WHERE ANUIDADE_CATEGORIA.CATEGORIA_COD(+) = SÓCIO.CATEGORIA_COD AND ANUIDADE_DESCONTO.ANUIDADE_REF(+) = ANUIDADE_CATEGORIA.ANUIDADE_REF AND ANUIDADE_DESCONTO.CATEGORIA_COD(+) = ANUIDADE_CATEGORIA.CATEGORIA_COD AND SÓCIO.MAT = CurObrigPag.SÓCIO_MAT AND ANUIDADE_DESCONTO.DATA_DESCONTO >= CurObrigPag.PAG_DATA
ORDER BY ANUIDADE_DESCONTO.DATA_DESCONTO) WHERE ROWNUM = 1;
					-- Se não encontrar desconto para a data do pagamento altera flag para true.
					exception
						when NO_DATA_FOUND then
							bSemDesc := true;					
					end;
				end if;
				-- Se a data de pagamento for <= a data do vencimento verifica se o valor de pagamento confere com o valor da obrigação.
				if CurObrigPag.PAG_DATA <= CurObrigPag.DATA_VENCIMENTO then 				
					if (CurObrigPag.TIPO = 'ANUIDADE') or (CurObrigPag.TIPO = 'ANUIDADE - COTA ÚNICA') or (CurObrigPag.TIPO = 'PARCELAMENTO') or (CurObrigPag.TIPO = 'ANUIDADE-PARCELA 1') or (CurObrigPag.TIPO = 'ANUIDADE-PARCELA 2') or (CurObrigPag.TIPO = 'ANUIDADE-PARCELA 3') then
						-- Se a obrigação for do tipo "ANUIDADE" ou "ANUIDADE - COTA ÚNICA"e o Valor da obrigação = (valor pag + valor desc), ou se a <> (valor obrig - valor pag) <= valor desc).(Pagou com desconto)												
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
			-- Atualiza o status da obrigação.
			if Atualiza then
	  	    		UPDATE OBRIGAÇÃO SET OBRIG_STATUS_COD = vObrigStatus,SYS_STATUS = 'X' WHERE SÓCIO_MAT = CurObrigPag.SÓCIO_MAT AND 
                	        SEQ = CurObrigPag.SEQ;										
			ELSE
	  	    		UPDATE OBRIGAÇÃO SET OBRIG_STATUS_COD = vObrigStatus WHERE SÓCIO_MAT = CurObrigPag.SÓCIO_MAT AND 
                	        SEQ = CurObrigPag.SEQ;										
			END IF;
		end loop;

	exception
        	when others then
                	raise_application_error(-20000, 'Erro em LObrigacao_Status - ' || SQLERRM);		

	end LObrigacao_Status;

	--------------------------------------------------------------------------------------------------------------
	-- Altera a categoria dos sócios ASPIRANTES, com 5 anos de cadastro, para sócios CONTRIBUINTES.
	--------------------------------------------------------------------------------------------------------------
	Procedure LAltera_Categoria is

	nCategSeq number;
	begin
		-- Seleciona os sócio ASPIRANTES com 5 anos(1826 dias) entre a data de cadastro e a data atual.
		-- Atualiza a categoria para CONTRIBUINTE, e insere na tabela de SÓCIO_CATEGORIA com a Obs. "ALTERAÇÃO DE CATEGORIA CONFORME ESTATUTO".
		for Cur in (SELECT MAT,CATEGORIA_COD,DATA_CADASTRO FROM SÓCIO WHERE CATEGORIA_COD = 'ASPIRANTE' AND ABS(TRUNC(SYSDATE - DATA_CADASTRO)) >= 1826 ORDER BY MAT) loop
			SELECT NVL(MAX(SEQ),0)+ 1 AS SEQ INTO nCategSeq FROM SÓCIO_CATEGORIA WHERE SÓCIO_MAT = Cur.MAT;
			UPDATE SÓCIO SET CATEGORIA_COD = 'CONTRIBUINTE', SYS_STATUS = 'X' WHERE MAT = Cur.MAT;
			INSERT INTO SÓCIO_CATEGORIA (SÓCIO_MAT,CATEGORIA_COD,SEQ,DATA_ALTERAÇÃO,OBS) VALUES (Cur.MAT,'CONTRIBUINTE',nCategSeq,TO_DATE(TO_CHAR(Cur.DATA_CADASTRO,'DD/MM')||'/'||TO_CHAR(SYSDATE,'YYYY'),'dd/mm/yyyy'),
'ALTERAÇÃO DE CATEGORIA CONFORME ESTATUTO');
		end loop;
		Commit;
	exception
        	when others then
                	raise_application_error(-20000, 'Erro em LAltera_Categoria - ' || SQLERRM);	

	end LAltera_Categoria;

	--------------------------------------------------------------------------------------------------------------
	-- Procedimento para atualizar o status(FIN) das obrigações pertinentes aos sócios
	--------------------------------------------------------------------------------------------------------------
	Procedure LAtualiza_Obrig_Status(Atualiza in boolean default FALSE) is

	nI NUMBER;
	Cursor CurSocio IS 
		SELECT MAT FROM SÓCIO ORDER BY MAT;
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
	-- Procedimento para atualizar o status(FIN) de todos sócio
	--------------------------------------------------------------------------------------------------------------
	Procedure LAtualiza_Socio_Status(Atualiza in boolean default FALSE) is
		
	nI NUMBER;
	Cursor CurSocio IS 
		SELECT MAT FROM SÓCIO ORDER BY MAT;
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
	-- Procedimento para verificar todos os sócios e excluí-los caso tenham 2 anuidades vencidas consecutivas
	--------------------------------------------------------------------------------------------------------------
	Procedure LExclui_Socio is

	nComp number;

	begin

		for CurSocio in (SELECT MAT FROM SÓCIO WHERE EXCLUÍDO = 0 AND OBRIG_STATUS_COD = 'INADIMPLENTE' ORDER BY MAT) loop
			nComp := 0;
			for CurObrig in (SELECT SEQ, TO_CHAR(COMPETÊNCIA,'YYYY') COMPETENCIA FROM OBRIGAÇÃO WHERE SÓCIO_MAT = CurSocio.Mat AND OBRIG_STATUS_COD = 'VENCIDA' ORDER BY SEQ) loop
				if nComp = 0 then
					nComp := To_Number(CurObrig.Competencia);
				else
					if (nComp + 1 = To_Number(CurObrig.Competencia)) then
						UPDATE SÓCIO SET SYS_STATUS = 'X', EXCLUÍDO = -1, DATA_EXCLUSÃO = SYSDATE, MOTIVO_EXCLUSÃO = 'EXCLUSÃO POR INADIMPLÊNCIA CONFORME ESTATUTO', RESP_EXCLUSÃO = 'ADMINISTRAÇÃO'
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
	-- Procedimento para preencher a tabela temporária TEMP_EXTRATO_ATIV com as atividades realizadas pelo associado
	-- de nível nó 2 somando a pontuação dos sub-níveis para o relatório de extrato simplificado
	--------------------------------------------------------------------------------------------------------------
	Procedure LExtrato_emcd_simp (nMat in number,dtInicioContagem in date default null,dtFinalContagem in date default null) is

	nCodAtiv number;
	nCodAtiv2 number;
	vNomeAtiv varchar2(100);
	nSuperior number;
	nNível number;
	dtDataIniCont date;
        dtDataFimCont date; 
	bAchouNivel2 boolean;

	begin
		if dtInicioContagem is null then
			SELECT DATA_INICIO_CONTAGEM INTO dtDataIniCont FROM SÓCIO WHERE MAT = nMat;
                        dtDataFimCont :=  (TO_CHAR(dtDataIniCont,'DD/MM/')) ||  (TO_CHAR(dtDataIniCont,'YYYY') + 5);
		else
			dtDataIniCont := dtInicioContagem;
                        dtDatafimCont := dtFinalContagem;
                        
		end if;
                
                
 
		For CurAtiv in (SELECT S.MAT,S.NOME,S.DATA_INICIO_CONTAGEM,A.NOME NOME_ATIV,A.COD,A.NÍVEL_NÓ,A.SUPERIOR,PS.PONTO_VALOR
				FROM SÓCIO S,EMCD_ATIVIDADE A,EMCD_PONTO_SÓCIO PS,EMCD_TIPO_PONTO TP 
				WHERE S.MAT = PS.SÓCIO_MAT AND A.COD = PS.ATIV_COD AND PS.PONTO_COD = TP.COD AND S.EXCLUÍDO = 0 
      				AND (PS.PONTO_DATA >= dtDataIniCont AND PS.PONTO_DATA <= dtDatafimCont) AND S.MAT = nMat AND TP.COD <> 1 AND S.EXCLUÍDO = 0
				ORDER BY A.NÍVEL_NÓ) loop
			bAchouNivel2 := false;
			if CurAtiv.NÍVEL_NÓ <= 2 then
				INSERT INTO TEMP_EXTRATO_ATIV(MAT,NOME,DATA_INICIO_CONTAGEM,DATA_PERIODO,NOME_ATIV,COD_ATIV,NÍVEL_NÓ,SUPERIOR,PONTO_VALOR) 
				VALUES (CurAtiv.MAT,CurAtiv.NOME,CurAtiv.DATA_INICIO_CONTAGEM,dtDataIniCont,CurAtiv.NOME_ATIV,CurAtiv.COD,CurAtiv.NÍVEL_NÓ,CurAtiv.SUPERIOR,CurAtiv.PONTO_VALOR);
			else
				nSuperior := CurAtiv.SUPERIOR;
				while not bAchouNivel2 loop
					SELECT COD,NOME,NÍVEL_NÓ,SUPERIOR INTO nCodAtiv,vNomeAtiv,nNível,nSuperior FROM EMCD_ATIVIDADE WHERE COD = nSuperior;
					if nNível = 2 then
						begin
							bAchouNivel2 := true;
							SELECT COD_ATIV INTO nCodAtiv2 FROM TEMP_EXTRATO_ATIV WHERE COD_ATIV = nCodAtiv AND MAT = nMat;
							UPDATE TEMP_EXTRATO_ATIV SET PONTO_VALOR = PONTO_VALOR + CurAtiv.PONTO_VALOR WHERE COD_ATIV = nCodAtiv2;
						   exception
							when NO_DATA_FOUND then
								INSERT INTO TEMP_EXTRATO_ATIV(MAT,NOME,DATA_INICIO_CONTAGEM,DATA_PERIODO,NOME_ATIV,COD_ATIV,NÍVEL_NÓ,SUPERIOR,PONTO_VALOR) 
								VALUES (CurAtiv.MAT,CurAtiv.NOME,CurAtiv.DATA_INICIO_CONTAGEM,dtDataIniCont,vNomeAtiv,nCodAtiv,nNível,nSuperior,CurAtiv.PONTO_VALOR);
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
	-- Procedimento para preencher a tabela temporária TEMP_EXTRATO_ATIV com as atividades realizadas pelo associado
	-- junto com o código da atividade superior a ela para a geração do extrato detalhado
	--------------------------------------------------------------------------------------------------------------
	Procedure LExtrato_emcd_det (nMat in number, dtInicioContagem in date default null, dtFinalContagem in date default null) is

	dtDataIniCont date;
	dtDatafimCont date;
	nCodAtiv number;
	nSuperior number;
	nNível number;
	bAchouNivel2 boolean;


	begin
                if dtInicioContagem is null then
			SELECT DATA_INICIO_CONTAGEM INTO dtDataIniCont FROM SÓCIO WHERE MAT = nMat;
                        dtDataFimCont :=  (TO_CHAR(dtDataIniCont,'DD/MM/')) ||  (TO_CHAR(dtDataIniCont,'YYYY') + 5);
		else
			dtDataIniCont := dtInicioContagem;
                        dtDatafimCont := dtFinalContagem;
		end if;
		For CurAtiv in (SELECT S.MAT,S.DATA_INICIO_CONTAGEM,PS.ATIV_COD,PS.PONTO_COD,PS.PONTO_VALOR,A.NÍVEL_NÓ,A.SUPERIOR
				FROM SÓCIO S,EMCD_PONTO_SÓCIO PS,EMCD_ATIVIDADE A
				WHERE S.MAT = PS.SÓCIO_MAT AND PS.ATIV_COD = A.COD AND S.MAT = nMat AND (PS.PONTO_DATA >= dtDataIniCont AND PS.PONTO_DATA <= dtDataFimCont) AND PS.PONTO_COD <> 1 
				ORDER BY NÍVEL_NÓ) loop
			bAchouNivel2 := false;
			if CurAtiv.NÍVEL_NÓ <= 2 then
				INSERT INTO TEMP_EXTRATO_ATIV (MAT,DATA_INICIO_CONTAGEM,COD_ATIV,COD_ATIV_PAI,PONTO_COD,PONTO_VALOR,NÍVEL_NÓ,SUPERIOR)
				VALUES (CurAtiv.MAT,CurAtiv.DATA_INICIO_CONTAGEM,CurAtiv.ATIV_COD,CurAtiv.ATIV_COD,CurAtiv.PONTO_COD,CurAtiv.PONTO_VALOR,CurAtiv.NÍVEL_NÓ,CurAtiv.SUPERIOR);
			else
				nSuperior := CurAtiv.SUPERIOR;
				while not bAchouNivel2 loop
					SELECT COD,NÍVEL_NÓ,SUPERIOR INTO nCodAtiv,nNível,nSuperior FROM EMCD_ATIVIDADE WHERE COD = nSuperior;
					if nNível = 2 then
						bAchouNivel2 := true;
						INSERT INTO TEMP_EXTRATO_ATIV (MAT,DATA_INICIO_CONTAGEM,COD_ATIV,COD_ATIV_PAI,PONTO_COD,PONTO_VALOR,NÍVEL_NÓ,SUPERIOR)
						VALUES (CurAtiv.MAT,dtDataIniCont,CurAtiv.ATIV_COD,nCodAtiv,CurAtiv.PONTO_COD,CurAtiv.PONTO_VALOR,CurAtiv.NÍVEL_NÓ,CurAtiv.SUPERIOR);
					end if;
				end loop;
			end if;
		end loop;
	exception
        	when others then
                	raise_application_error(-20000, 'Erro em LExtrato_emcd_det - ' || SQLERRM);

	end LExtrato_emcd_det;

  
	--------------------------------------------------------------------------------------------------------------
	-- Procedimento para criação de jobs(tarefas) a serem executadas periodicamente no Oracle
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
	-- Procedimento para exclusão de jobs(tarefas) no Oracle
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