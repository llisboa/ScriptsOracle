create or replace package lb is

	function litem(Texto in varchar2, Item in number, Sep in varchar2 default '') return varchar2;
	function litem(Texto in varchar2, Item in varchar2, Sep in varchar2 default '') return number;
	function lparam(Campo in varchar2, tipo in varchar2) return varchar2;
	function lustr(Texto in varchar2) return varchar2;
	function lextenso(VV in number, Ling in varchar2) return varchar2;
	function lmontacento(Strv0 in varchar2, StrCem in varchar2, Sep in varchar2, StrDez in varchar2, StrPrimaDez in varchar2, StrUnid in varchar2) return varchar2;
	function lconcatcamp(Dominio in varchar2, Delimit in varchar2) return varchar2;
	function lnumling(Num in number, Masc in varchar2, Ling in varchar2) return varchar2;
	procedure confirm(op in varchar2, confirm in varchar2, in_seq number, origconfirm in varchar2 default '', origseq number default 0, pedido in varchar2 default '', idioma in varchar2 default '', medida in varchar2 default '');	

end lb;
/ 


create or replace package body lb is
	
	procedure confirm(op in varchar2, confirm in varchar2, in_seq number, origconfirm in varchar2 default '', origseq number default 0, pedido in varchar2 default '', idioma in varchar2 default '', medida in varchar2 default '') is
	DESCR varchar2(3000);
	DESC_PORTO varchar2(100);
	USU_FINAL varchar2(30);
	VAL_TOL number;
	VAL_EMB number;
	MOEDA varchar2(20);
	TOTITENS number;
	MAXITEM number;
	RESP number;
	Tip_lingua varchar2(10);
	RET_PROC number;
	descri��o varchar2(1000);
	POS_INI number;
	POS_FIM number;
	RET varchar2(1000);
	OutraRef varchar2(3000);
	RESP NUMBER;
	COMP varchar2(100);
	MES varchar2(1000);
	ANO varchar2(4);
	DIA varchar2(2);
	AUX NUMBER;
	PORTO_DESC varchar2(100);
	begin
		OutraRef := '';
		MES := 'Janeiro.January.Enero;Fevereiro.February.Febrero;Mar�o.March.Marzo;Abril.April.Abril;Maio.May.Mayo;Junho.June.Junio;Julho.July.Julio;Agosto.August.Agosto;Setembro.September.Septiembre;Outubro.October.Octubre;Novembro.November.Noviembre;Dezembro.December.Diciembre';	
		if op = 'A' then	
			--atualizar a confirma��o de venda 	
			if not pedido is null then
				for cur_ped in (SELECT REF, IMP_COND_VENDA, EMB_PREV, FRETE_COND, CARGA_PORTO, DECODE(DISTRIBUIDOR,NULL,IMP,DISTRIBUIDOR) COMP, MOEDA FROM CXRJ.PED WHERE REF = pedido) loop 
					MOEDA := cur_ped.MOEDA;
					OutraRef := OutraRef || cur_ped.REF;
					ANO := TO_CHAR(cur_ped.EMB_PREV,'YYYY');
					RET := TO_CHAR(cur_ped.EMB_PREV,'MM');
					AUX := TO_NUMBER(RET);
					RET := LITEM(MES,AUX);
					if idioma = 'C' then
						RET := LITEM(RET,3);
						RET := RET || ', ' || ANO;
					elsif idioma = 'I' then
						RET := LITEM(RET,2);
						RET := RET || ', ' || ANO;
					else						
						DIA := TO_CHAR(cur_ped.EMB_PREV,'DD');
						RET := LITEM(RET,1);
						RET := DIA || ' de ' || RET || ' de ' || ANO;
					end if;
					update CXRJ.CONFIRM_VENDA set PED_REF = cur_ped.REF, PRE�O_DETALHE = cur_ped.IMP_COND_VENDA || ' ' || cur_ped.FRETE_COND, ENTREGA = RET , CARGA_PORTO = cur_ped.CARGA_PORTO , COMPRADOR = cur_ped.COMP WHERE REF = confirm AND SEQ = in_seq;
					COMMIT;
				end loop; 
			end if;

			if not confirm is null then
				for cur in (SELECT EMISSOR, DESTINAT�RIO, ESPECIFICA��O, EMBALAGEM, SEGURO, PAG, OBS_TERMOS, OBS, PRODUTOR, CARGA_PORTO, DESCARGA_PORTO FROM CXRJ.CONFIRM_VENDA WHERE REF = origconfirm AND SEQ = origseq) loop
					DESC_PORTO := cur.DESCARGA_PORTO;
					update CXRJ.CONFIRM_VENDA set EMISSOR = cur.EMISSOR, DESTINAT�RIO = cur.DESTINAT�RIO, ESPECIFICA��O = cur.ESPECIFICA��O, EMBALAGEM = cur.EMBALAGEM, SEGURO = cur.SEGURO, PAG = cur.PAG, OBS_TERMOS = cur.OBS_TERMOS, OBS = cur.OBS, CARGA_PORTO = cur.CARGA_PORTO, DESCARGA_PORTO = cur.DESCARGA_PORTO, PRODUTOR = cur.PRODUTOR WHERE REF = confirm AND SEQ = in_seq;
					COMMIT;
				end loop;	
			end if;
			DELETE FROM CXRJ.CONFIRM_VENDA_ITEM WHERE CONFIRM_VENDA_REF = confirm and SEQ = in_seq;
		elsif op = 'I' then
			-- incluir a confirma��o de venda		
			if not pedido is null then
				for cur_ped in (SELECT REF, IMP_COND_VENDA, EMB_PREV, FRETE_COND, CARGA_PORTO, DECODE(DISTRIBUIDOR,NULL,IMP,DISTRIBUIDOR) COMP, MOEDA FROM CXRJ.PED WHERE REF = pedido) loop 
					MOEDA := cur_ped.MOEDA;
					OutraRef := OutraRef || cur_ped.REF;
					ANO := TO_CHAR(cur_ped.EMB_PREV,'YYYY');
					RET := TO_CHAR(cur_ped.EMB_PREV,'MM');
					AUX := TO_NUMBER(RET);
					RET := LITEM(MES,AUX);
					if idioma = 'C' then
						RET := LITEM(RET,3);
						RET := RET || ', ' || ANO;
					elsif idioma = 'I' then
						RET := LITEM(RET,2);
						RET := RET || ', ' || ANO;
					else 
						DIA := TO_CHAR(cur_ped.EMB_PREV,'DD');
						RET := LITEM(RET,1);
						RET := DIA || ' de ' || RET || ' de ' || ANO;
					end if;
					insert INTO CXRJ.CONFIRM_VENDA (REF, SEQ, PED_REF, PRE�O_DETALHE, ENTREGA, CARGA_PORTO, COMPRADOR) VALUES (confirm, in_seq, cur_ped.REF, cur_ped.IMP_COND_VENDA || ' ' || cur_ped.FRETE_COND, RET, cur_ped.CARGA_PORTO, cur_ped.COMP);
					COMMIT;
				end loop; 
				if not confirm is null then
					for cur in (SELECT EMISSOR, DESTINAT�RIO, ESPECIFICA��O, EMBALAGEM, SEGURO, PAG, OBS_TERMOS, OBS, PRODUTOR, CARGA_PORTO, DESCARGA_PORTO FROM CXRJ.CONFIRM_VENDA WHERE REF = origconfirm AND SEQ = origseq) loop
						DESC_PORTO := cur.DESCARGA_PORTO;
						update CXRJ.CONFIRM_VENDA set EMISSOR = cur.EMISSOR, DESTINAT�RIO = cur.DESTINAT�RIO, ESPECIFICA��O = cur.ESPECIFICA��O, EMBALAGEM = cur.EMBALAGEM, SEGURO = cur.SEGURO, PAG = cur.PAG, OBS_TERMOS = cur.OBS_TERMOS, OBS = cur.OBS, CARGA_PORTO = cur.CARGA_PORTO, DESCARGA_PORTO = cur.DESCARGA_PORTO, PRODUTOR = cur.PRODUTOR WHERE REF = confirm AND SEQ = in_seq;
						COMMIT;
					end loop;	
				end if;
			else
				for cur in (SELECT EMISSOR, DESTINAT�RIO, ESPECIFICA��O, EMBALAGEM, SEGURO, PAG, OBS_TERMOS, OBS, PRODUTOR, CARGA_PORTO, DESCARGA_PORTO FROM CXRJ.CONFIRM_VENDA WHERE REF = origconfirm AND SEQ = origseq) loop
					DESC_PORTO := cur.DESCARGA_PORTO;
					insert INTO CXRJ.CONFIRM_VENDA (REF, SEQ, EMISSOR, DESTINAT�RIO, ESPECIFICA��O, EMBALAGEM, SEGURO, PAG, OBS_TERMOS, OBS, CARGA_PORTO, DESCARGA_PORTO, PRODUTOR) VALUES (confirm, in_seq, cur.EMISSOR, cur.DESTINAT�RIO, cur.ESPECIFICA��O, cur.EMBALAGEM, cur.SEGURO, cur.PAG, cur.OBS_TERMOS, cur.OBS, cur.CARGA_PORTO, cur.DESCARGA_PORTO, cur.PRODUTOR);
					COMMIT;
				end loop;
			end if;
		end if;		
		SELECT COUNT(*) INTO TOTITENS FROM PED_ITEM WHERE PED_REF = pedido;
		if TOTITENS > 0 then
			DESCR := '';
			for cur in (SELECT * FROM PED_ITEM WHERE PED_REF = pedido) loop
				DESCR := '';
				USU_FINAL := NVL(cur.USU�RIO_FINAL,'');
				PORTO_DESC := NVL(cur.DESCARGA_PORTO,'');

--PRODUTO
			if nvl(cur.PROD,' ') <> ' ' THEN
				SELECT NOME INTO descri��o FROM PRODUTO WHERE COD = cur.PROD;
				if not IDIOMA is null then
					Tip_lingua:= idioma || ':';
					SELECT COUNT(COD) into ret_proc FROM PRODUTO WHERE COD = cur.PROD AND UPPER (NOME) LIKE '%' || UPPER(Tip_lingua) || '%';
					if ret_proc = 0 then
						POS_FIM := instr(descri��o, CHR(13) || CHR(10));
						DESCR := DESCR || ' ; ' || SUBSTR(descri��o,1,POS_FIM - 1);
					else
						POS_INI := instr(descri��o, Tip_lingua) + length(Tip_lingua);
						POS_FIM := instr(SUBSTR(descri��o,POS_INI), CHR(13) || CHR(10)) - 1; 
						if (POS_INI - length(Tip_lingua) - 1) = 0 then
							DESCR := DESCR || '';
						else
							if POS_FIM < 0 THEN
								DESCR := DESCR || ' ; ' || SUBSTR(descri��o,POS_INI);
							else
								DESCR := DESCR || ' ; ' || SUBSTR(descri��o,POS_INI,POS_FIM);
							end if;
						end if;
					end if;
				else
					POS_FIM := instr(descri��o, CHR(13) || CHR(10));
					DESCR := DESCR || ' ; ' || SUBSTR(descri��o,1,POS_FIM - 1);
				end if;
			end if;

--EMBALAGEM
				if nvl(cur.EMBALAGEM,' ') <> ' ' then
					SELECT DESCR INTO descri��o FROM EMBALAGEM WHERE COD = cur.EMBALAGEM;	
					if not IDIOMA is null then
						Tip_lingua := idioma || ':';
						SELECT COUNT(COD) INTO ret_proc FROM EMBALAGEM WHERE COD = cur.EMBALAGEM AND UPPER(DESCR) LIKE '%' || UPPER(Tip_lingua) || '%';		
						if ret_proc = 0 then
							POS_FIM := instr(descri��o, CHR(13) || CHR(10));
							DESCR := DESCR || ' ; ' || SUBSTR(descri��o,1,POS_FIM - 1);
						else
							POS_INI := instr(descri��o, Tip_lingua) + length(Tip_lingua);
							POS_FIM := instr(SUBSTR(descri��o,POS_INI), CHR(13) || CHR(10)) - 1; 
							if (POS_INI - length(Tip_lingua) - 1) = 0 then
								DESCR := DESCR || '';
							else
								if POS_FIM < 0 THEN
									DESCR := DESCR || ' ; ' || SUBSTR(descri��o,POS_INI);
								else
									DESCR := DESCR || ' ; ' || SUBSTR(descri��o,POS_INI,POS_FIM);
								end if;
							end if;
						end if;
					else
						POS_FIM := instr(descri��o, CHR(13) || CHR(10));
						DESCR := DESCR || ' ; ' || SUBSTR(descri��o,1,POS_FIM - 1);
					end if;
				end if;

--DI�METRO_INTERNO
				if nvl(cur.DI�METRO_INTERNO,0) <> 0 then
					if idioma = 'C' then
						--DESCR := DESCR || ' ; Di�metro Interno ' || trim(replace(lnumling(cur.DI�METRO_INTERNO, '99999D999', 'C') || ' ', ', ', '')) || ' mm';
						DESCR := DESCR || ' ; Diametro Interno ' || trim(replace(round(cur.DI�METRO_INTERNO,2) || ' ', ', ', '')) || ' mm';
					elsif idioma = 'P' then
						--DESCR := DESCR || ' ; Di�metro Interno ' || trim(replace(lnumling(cur.DI�METRO_INTERNO, '99999D999', 'P') || ' ', ', ', '')) || ' mm';
						DESCR := DESCR || ' ; Di�metro Interno ' || trim(replace(round(cur.DI�METRO_INTERNO,2) || ' ', ', ', '')) || ' mm';
					--elsif idioma = 'I' then
					else
						--DESCR := DESCR || ' ; Internal Diameter ' || trim(replace(lnumling(cur.DI�METRO_INTERNO, '99999D999', 'I') || ' ', '. ', '')) || ' mm';
						DESCR := DESCR || ' ; Internal Diameter ' || trim(replace(replace(round(cur.DI�METRO_INTERNO,2),',','.') || ' ', ', ', '')) || ' mm';
					end if;
				end if;
		
--DI�METRO_EXTERNO		
				if nvl(cur.DI�METRO_EXTERNO,0) <> 0 then
					if idioma = 'C' then
						--DESCR := DESCR || ' ; Diametro Externo ' || trim(replace(lnumling(cur.DI�METRO_EXTERNO, '99999D999', 'C') || ' ', ', ', '')) || ' mm';
						DESCR := DESCR || ' ; Diametro Externo ' || trim(replace(round(cur.DI�METRO_EXTERNO,2) || ' ', ', ', '')) || ' mm';
					elsif idioma = 'P' then
						--DESCR := DESCR || ' ; Di�metro Externo ' || trim(replace(lnumling(cur.DI�METRO_EXTERNO, '99999D999', 'P') || ' ', ', ', '')) || ' mm';
						DESCR := DESCR || ' ; Di�metro Externo ' || trim(replace(round(cur.DI�METRO_EXTERNO,2) || ' ', ', ', '')) || ' mm';
					--elsif idioma = 'I' then
					else
						--DESCR := DESCR || ' ; External Diameter ' || trim(replace(lnumling(cur.DI�METRO_EXTERNO, '99999D999', 'I') || ' ', '. ', '')) || ' mm';
						DESCR := DESCR || ' ; External Diameter ' || trim(replace(replace(round(cur.DI�METRO_EXTERNO,2),',','.') || ' ', ', ', '')) || ' mm';
					end if;
				end if;

--REVESTIMENTO
				if nvl(cur.REVESTIMENTO,' ') <> ' ' then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Recubrimento ' || cur.REVESTIMENTO;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Revestimento ' || cur.REVESTIMENTO;	
					else
						DESCR := DESCR || ' ; Coating ' || cur.REVESTIMENTO;
					end if;	
				end if;

--T�MPERA
				if nvl(cur.T�MPERA,' ') <> ' ' then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Temple ' || cur.T�MPERA;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; T�mpera ' || cur.T�MPERA;	
					else
						DESCR := DESCR || ' ; Temper ' || cur.T�MPERA;	
					end if;
				end if;


--ACABAMENTO
				if nvl(cur.ACABAMENTO,' ') <> ' ' then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Acabado ' || cur.ACABAMENTO;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Acabamento ' || cur.ACABAMENTO;	
					else
						DESCR := DESCR || ' ; Finish ' || cur.ACABAMENTO;	
					end if;
				end if;

--NORMA_TOLER�NCIA
				if nvl(cur.NORMA_TOLER�NCIA,' ') <> ' ' then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Norma de Tolerancia ' || cur.NORMA_TOLER�NCIA;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Norma de Toler�ncia ' || cur.NORMA_TOLER�NCIA;	
					else
						DESCR := DESCR || ' ; Tol Norm ' || cur.NORMA_TOLER�NCIA;	
					end if;
				end if;

--NORMA_PRODU��O
				if nvl(cur.NORMA_PRODU��O,' ') <> ' ' then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Norma de Producion ' || cur.NORMA_PRODU��O;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Norma de Produ��o ' || cur.NORMA_PRODU��O;	
					else
						DESCR := DESCR || ' ; Prod Norm ' || cur.NORMA_PRODU��O;	
					end if;
				end if;

--BORDAS
				if nvl(cur.BORDAS,' ') <> ' ' then
					SELECT QUANDO_TEXTO INTO descri��o FROM PARAM WHERE GRUPO ='BORDAS' AND PARAM = cur.BORDAS;
					if not IDIOMA is null then
						Tip_lingua := IDIOMA || ':';
						SELECT COUNT(GRUPO) INTO RET_PROC FROM PARAM WHERE GRUPO = 'BORDAS' AND PARAM = cur.BORDAS AND UPPER(QUANDO_TEXTO) LIKE '%' || UPPER(Tip_lingua) || '%';
						if RET_PROC = 0 then
							 POS_FIM := instr(descri��o, CHR(13) || CHR(10));
  							 RET := SUBSTR(descri��o,1,POS_FIM - 1);
						else
							POS_INI := instr(descri��o,Tip_lingua) + length(Tip_lingua);
							POS_FIM := instr(SUBSTR(descri��o,POS_INI), CHR(13) || CHR(10)) - 1;
							if (POS_INI - length(Tip_lingua) - 1) = 0 then
								RET := '';
							else
								if POS_FIM < 0 then
									RET := SUBSTR(descri��o,POS_INI);
								else
									RET := SUBSTR(descri��o,POS_INI,POS_FIM);
								end if;
							end if;
						end if;
					else
						POS_FIM := instr(descri��o, CHR(13) || CHR(10));
			  			RET := SUBSTR(descri��o,1,POS_FIM - 1);  				 			 		
					end if;				
					if idioma = 'C' then
						DESCR := DESCR || ' ; Bordas ' || nvl(RET, cur.BORDAS);
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Bordas ' || nvl(RET, cur.BORDAS);	
					else 
						DESCR := DESCR || ' ; Edge ' || nvl(RET, cur.BORDAS);	
					end if;
				end if;

--OLEAMENTO
				if nvl(cur.OLEAMENTO,0) <> 0 then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Aceitado ' || cur.OLEAMENTO;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Oleamento ' || cur.OLEAMENTO;	
					else
						DESCR := DESCR || ' ; Oiled ' || cur.OLEAMENTO;	
					end if;
				end if;

--TRAT_T�RMICO
				if nvl(cur.TRAT_T�RMICO,0) <> 0 then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Tratam Termico ' || cur.TRAT_T�RMICO;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Tratam T�rmico ' || cur.TRAT_T�RMICO;	
					else
						DESCR := DESCR || ' ; Thermical Treat ' || cur.TRAT_T�RMICO;	
					end if;
				end if;

--TRAT_QU�MICO
				if nvl(cur.TRAT_QU�MICO,0) <> 0 then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Tratam Quimico ' || cur.TRAT_QU�MICO;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Tratam Qu�mico ' || cur.TRAT_QU�MICO;	
					else
						DESCR := DESCR || ' ; Chemic Treat ' || cur.TRAT_QU�MICO;	
					end if;
				end if;

--LA
				if nvl(cur.LA,0) <> 0 then
					DESCR := DESCR || ' ; LA';
				end if;

--LE
				if nvl(cur.LE,0) <> 0 then
					DESCR := DESCR || ' ; LE';
				end if;

--L�NGUA
				if nvl(cur.L�NGUA,0) <> 0 then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Lingua ';
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; L�ngua ';	
					else
						DESCR := DESCR || ' ; Tonque ';	
					end if;
				end if;

--COMPOSI��O_QU�MICA
				if nvl(cur.COMPOSI��O_QU�MICA,' ') <> ' ' then
					DESCR := DESCR || ' ; ' || cur.COMPOSI��O_QU�MICA; 
				end if;

--TOLER�NCIA_MIN				
				if nvl(cur.TOLER�NCIA_MIN,0) <> 0 then
					VAL_TOL := cur.TOLER�NCIA_MIN * 100;
					VAL_TOL := round(VAL_TOL);
					if idioma = 'C' then
						DESCR := DESCR || ' ; Tolerancia Min ' || VAL_TOL || ' %';
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Tolerancia Min ' || VAL_TOL || ' %';
					else
						DESCR := DESCR || ' ; Tolerance Min ' || VAL_TOL || ' %';
					end if;
				end if;

--TOLER�NCIA_MAX
				if nvl(cur.TOLER�NCIA_MAX,0) <> 0 then
					VAL_TOL := cur.TOLER�NCIA_MAX * 100;
					VAL_TOL := round(VAL_TOL);
					if idioma = 'C' then
						DESCR := DESCR || ' ; Tolerancia Max ' || trim(VAL_TOL) || ' %';
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Toler�ncia Max ' || trim(VAL_TOL) || ' %';
					else
						DESCR := DESCR || ' ; Tolerance Max ' || trim(VAL_TOL) || ' %';
					end if;
				end if;

--EMBALAGEM_PESO_MAX
				if nvl(cur.EMBALAGEM_PESO_MAX,0) <> 0 then
					Tip_lingua := nvl(idioma,'I') || ':';
					SELECT COUNT(COD) INTO ret_proc FROM UNID_QUANTID WHERE COD = cur.PED_UNID AND UPPER(NOME) LIKE '%' || UPPER(Tip_lingua) || '%';
					SELECT NOME INTO descri��o FROM UNID_QUANTID WHERE COD = cur.PED_UNID;
					if ret_proc = 0 then
						POS_FIM := instr(descri��o,CHR(13) || CHR(10));
						RET := SUBSTR(descri��o,1,POS_FIM - 1);
					else
						POS_INI := instr(descri��o, Tip_lingua) + length(Tip_lingua);
						POS_FIM := instr(SUBSTR(descri��o,POS_INI), CHR(13) || CHR(10)) - 1; 
						if (POS_INI - length(Tip_lingua) - 1) = 0 then
							RET := ' ';
						else
							if POS_FIM < 0 then
								RET := SUBSTR(DESCRI��O,POS_INI);
							else
								RET := SUBSTR(DESCRI��O,POS_INI,POS_FIM);
							end if;
						end if;
					end if;
					VAL_EMB := round(cur.EMBALAGEM_PESO_MAX,1);
					if idioma = 'C' then
						if (VAL_EMB > 0) AND (VAL_EMB < 1) then
							DESCR := DESCR || ' ; Peso Max da Embalaje ' || '0' || VAL_EMB || ' ' || RET;
						else
							DESCR := DESCR || ' ; Peso Max da Embalaje ' || VAL_EMB || ' ' || RET;
						end if;		
					elsif idioma = 'P' then
						if (VAL_EMB > 0) AND (VAL_EMB < 1) then
							DESCR := DESCR || ' ; Peso Max da Embalagem ' || '0' || VAL_EMB || ' ' || RET;
						else
							DESCR := DESCR || ' ; Peso Max da Embalagem ' || VAL_EMB || ' ' || RET;
						end if;
					else
						if (VAL_EMB > 0) AND (VAL_EMB < 1) then
							DESCR := DESCR || ' ; Max Weight of Volumes ' || '0' || replace(VAL_EMB,',','.') || ' ' || RET;
						else
							DESCR := DESCR || ' ; Max Weight of Volumes ' || replace(VAL_EMB,',','.') || ' ' || RET;
						end if;
					end if;
				end if;

--EMBALAGEM_PESO_MIN
				if nvl(cur.EMBALAGEM_PESO_MIN,0) <> 0 then
					Tip_lingua := nvl(idioma,'I') || ':';
					SELECT COUNT(COD) INTO ret_proc FROM UNID_QUANTID WHERE COD = cur.PED_UNID AND UPPER(NOME) LIKE '%' || UPPER(Tip_lingua) || '%';
					SELECT NOME INTO descri��o FROM UNID_QUANTID WHERE COD = cur.PED_UNID;
					if ret_proc = 0 then
						POS_FIM := instr(descri��o,CHR(13) || CHR(10));
						RET := SUBSTR(descri��o,1,POS_FIM - 1);
					else
						POS_INI := instr(descri��o, Tip_lingua) + length(Tip_lingua);
						POS_FIM := instr(SUBSTR(descri��o,POS_INI), CHR(13) || CHR(10)) - 1; 
						if (POS_INI - length(Tip_lingua) - 1) = 0 then
							RET := ' ';
						else
							if POS_FIM < 0 then
								RET := SUBSTR(DESCRI��O,POS_INI);
							else
								RET := SUBSTR(DESCRI��O,POS_INI,POS_FIM);
							end if;
						end if;
					end if;
					VAL_EMB := round(cur.EMBALAGEM_PESO_MIN,1);
					if idioma = 'C' then
						if (VAL_EMB > 0) AND (VAL_EMB < 1) then
							DESCR := DESCR || ' ; Peso Max da Embalaje ' || '0' || VAL_EMB || ' ' || RET;
						else
							DESCR := DESCR || ' ; Peso Max da Embalaje ' || VAL_EMB || ' ' || RET;
						end if;		
					elsif idioma = 'P' then
						if (VAL_EMB > 0) AND (VAL_EMB < 1) then
							DESCR := DESCR || ' ; Peso Max da Embalagem ' || '0' || VAL_EMB || ' ' || RET;
						else
							DESCR := DESCR || ' ; Peso Max da Embalagem ' || VAL_EMB || ' ' || RET;
						end if;
					else
						if (VAL_EMB > 0) AND (VAL_EMB < 1) then
							DESCR := DESCR || ' ; Max Weight of Volumes ' || '0' || replace(VAL_EMB,',','.') || ' ' || RET;
						else
							DESCR := DESCR || ' ; Max Weight of Volumes ' || replace(VAL_EMB,',','.') || ' ' || RET;
						end if;
					end if;
				end if;

				if litem(OutraRef, 'PO ' || cur.PO) = 0 and NVL(cur.PO, ' ') <> ' ' then
					if OutraRef is null then
						OutraRef := OutraRef || 'PO ' || cur.PO;
					else
						OutraRef := OutraRef || ';PO ' || cur.PO;
					end if;
				end if;
				SELECT MAX(ITEM) INTO MAXITEM FROM CXRJ.CONFIRM_VENDA_ITEM WHERE CONFIRM_VENDA_REF = confirm AND SEQ = in_seq;
				MAXITEM := NVL(MAXITEM,0) + 1;
				if DESCR <> ' ' then
					DESCR := SUBSTR(DESCR,4);
				end if;
				INSERT INTO CXRJ.CONFIRM_VENDA_ITEM (CONFIRM_VENDA_REF, SEQ, ITEM, DESCR, DIMENS�O, QTD, UNID, QUALIDADE, PRE�O, PRE�O_C, MOEDA) VALUES (confirm, in_seq, MAXITEM, NVL(DESCR,NULL), cur.DIMENS�O, cur.NOMINAL_PED_UNID, cur.PED_UNID, SUBSTR(cur.PROD_DESCR,1,15), cur.PRE�O_UNIT�RIO_IMP, cur.PRE�O_UNIT�RIO_FORNECEDOR, MOEDA); 
			end loop;
			RET := idioma;
			update CXRJ.CONFIRM_VENDA set DESCARGA_PORTO = DECODE(PORTO_DESC,NULL,DESC_PORTO,PORTO_DESC), USU�RIO_FINAL = USU_FINAL, OUTRA_REF = DECODE(OutraRef,NULL,NULL,replace(OutraRef,';',CHR(13) || CHR(10))), IDIOMA = RET, DIMENS�O = medida, EMISS�O_DATA = SYSDATE WHERE REF = confirm AND SEQ = in_seq;
			COMMIT;
		end if;

	end confirm;	







	function litem(Texto in varchar2, Item in number, Sep in varchar2 default '') return varchar2 is
	Pos number;
	Pos2 number;
	Busca number;
	Limit varchar2(500);
	
	begin
		if Sep is null then
			if instr(Texto, ';') <> 0 then
				Limit := ';';
			else
				Limit := '.';
			end if;
		else
			Limit := Sep;
		end if;

		Busca := 0;
		Pos := 1;

		while Pos <= length(Texto) loop
			Pos2 := instr(Texto, Limit, Pos);
			if Pos2 = 0 then
				Pos2 := length(Texto)+1;
			end if;

			Busca := Busca + 1;
			if Busca = Item then
				return substr(Texto, Pos, Pos2-Pos);
			else
				Pos := Pos2 + 1;
			end if;
		end loop;										
		return '';	
	exception
		when others then
		raise_application_error ( -20000, 'erro em litem: ' || SQLERRM);

	end litem;



	function litem(Texto in varchar2, Item in varchar2, Sep in varchar2 default '') return number is
	Pos number;
	Pos2 number;
	Busca number;
	Limit varchar2(500);
	
	begin
		if Sep is null then
			if instr(Texto, ';') <> 0 then
				Limit := ';';
			else
				Limit := '.';
			end if;
		else
			Limit := Sep;
		end if;
	
		Busca := 0;
		Pos := 1;

		while Pos <= length(Texto) loop
			Pos2 := instr(Texto, Limit, Pos);
			if Pos2 = 0 then
				Pos2 := length(Texto)+1;
			end if;
			Busca := Busca + 1;

			if not Item is null then
				if substr(Texto, Pos, Pos2-Pos) = Item then
					return Busca;
				end if;
			end if;

			Pos := Pos2 + 1;
		end loop;										

		return 0;	
	exception
		when others then
		raise_application_error ( -20000, 'erro em litem: ' || SQLERRM);

	end litem;


	function lparam(Campo in varchar2, Tipo in varchar2) return varchar2 is
	Pos integer;
	Pos2 integer;
	Texto varchar2(4000);
	begin
		Pos := instr(chr(13) || chr(10) || Campo, chr(13) || chr(10) || Tipo || ':');
		if Pos <> 0 then
			Pos := Pos + length(Tipo) + 1;
			Pos2 := instr(Campo, chr(13) || chr(10), pos);
			if Pos2 = 0 then
				Texto := substr(Campo, Pos);
			else
				Texto := substr(Campo, Pos, Pos2-Pos);
			end if;
		else
			return '';
		end if;

		return replace(Texto, '|', chr(10));
	exception
		when others then
			raise_application_error ( -20000, 'erro em lparam: ' || SQLERRM);
	
	end lparam;


	function lustr(Texto in varchar2) return varchar2 is
	begin
		return replace(Texto, chr(13) || chr(10), chr(10));

	exception
		when others then
			raise_application_error ( -20000, 'erro em lustr: ' || SQLERRM);

	end lustr;


	function lextenso(VV in number, Ling in varchar2) return varchar2 is
	
	StrUnid varchar2(500);
	StrDez varchar2(500);
	StrCem varchar2(500);
	StrMil varchar2(500);
	StrCent varchar2(500);
	Moeda varchar2(500);
	Sep varchar2(500);
	StrPrimaDez varchar2(500);
	StrVV varchar2(500);
	StrV0 varchar2(500);
	StrMoeda varchar2(500);
	StrM0 varchar2(500);
	Esp varchar2(500);
	SepDec varchar2(500);
	Z number;
	SepAndTres varchar2(500);
	SepMil varchar2(500);

	begin

		if Ling = 'R$' then
    			StrUnid := 'Um;Dois;Tr�s;Quatro;Cinco;Seis;Sete;Oito;Nove';
	    		StrPrimaDez := 'Onze;Doze;Treze;Quatorze;Quinze;Dezesseis;Dezesete;Dezoito;Dezenove';
	    		StrDez := 'Dez;Vinte;Trinta;Quarenta;Cinquenta;Sessenta;Setenta;Oitenta;Noventa';
	    		StrCem := 'Cento;Duzentos;Trezentos;Quatrocentos;Quinhentos;Seiscentos;Setecentos;Oitocentos;Novecentos';
	    		StrMil := 'Mil.Mil;Milh�o.Milh�es;Bilh�o.Bilh�es;Trilh�o.Trilh�es';
	    		StrCent := 'Centavo.Centavos';
	    		Moeda := 'Real;Reais;de Reais';
	    		Sep := ' e ';
	    		SepDec := ' e ';
	    		SepMil := ', ';
	    		SepAndTres := ' e ';
	    		Esp := ' ';
		elsif Ling = 'USD' or Ling = 'US$' or Ling = 'USD.' or Ling = 'U.S.DLRS' then
	    		StrUnid := 'One;Two;Three;Four;Five;Six;Seven;Eight;Nine';
	    		StrPrimaDez := 'Eleven;Twelve;Thirteen;Fourteen;Fifteen;Sixteen;Seventeen;Eighteen;Nineteen';
	    		StrDez := 'Ten;Twenty;Thirty;Forty;Fifty;Sixty;Seventy;Eighty;Ninety';
	    		StrCem := 'One Hundred;Two Hundred;Three Hundred;Four Hundred;Five Hundred;Six Hundred;Seven Hundred;Eight Hundred;Nine Hundred';
	    		StrMil := 'Thousand.Thousand;Million.Millions;Billion.Billions;Trillion.Trillions';
	    		StrCent := 'Cent.Cents';
			MOEDA := 'U.S. Dollar;U.S. Dollars;U.S. Dollars';
	    		Sep := ' ';
	    		SepDec := ' and ';
	    		SepMil := ', ';
	    		Esp := ' ';
	    		SepAndTres := ' and ';
		elsif Ling = 'DM' then
	    		StrUnid := 'One;Two;Three;Four;Five;Six;Seven;Eight;Nine';
	    		StrPrimaDez := 'Eleven;Twelve;Thirteen;Fourteen;Fifteen;Sixteen;Seventeen;Eighteen;Nineteen';
	    		StrDez := 'Ten;Twenty;Thirty;Forty;Fifty;Sixty;Seventy;Eighty;Ninety';
	    		StrCem := 'One Hundred;Two Hundred;Three Hundred;Four Hundred;Five Hundred;Six Hundred;Seven Hundred;Eight Hundred;Nine Hundred';
	    		StrMil := 'Thousand.Thousand;Million.Millions;Billion.Billions;Trillion.Trillions';
	    		StrCent := 'Cent.Cents';
	    		MOEDA := 'Deutsche Mark;Deutsche Mark;Deutsche Mark';
	    		Sep := ' ';
	    		SepDec := ' and ';
	   		SepMil := ', ';
	    		Esp := ' ';
	    		SepAndTres := ' and ';
		elsif Ling = 'YEN' then
	    		StrUnid := 'One;Two;Three;Four;Five;Six;Seven;Eight;Nine';
	    		StrPrimaDez := 'Eleven;Twelve;Thirteen;Fourteen;Fifteen;Sixteen;Seventeen;Eighteen;Nineteen';
	    		StrDez := 'Ten;Twenty;Thirty;Forty;Fifty;Sixty;Seventy;Eighty;Ninety';
	    		StrCem := 'One Hundred;Two Hundred;Three Hundred;Four Hundred;Five Hundred;Six Hundred;Seven Hundred;Eight Hundred;Nine Hundred';
	    		StrMil := 'Thousand.Thousand;Million.Millions;Billion.Billions;Trillion.Trillions';
	    		StrCent := 'Cent.Cents';
	    		MOEDA := 'Yen;Yen;Yen';
	    		Sep := ' ';
	    		SepDec := ' and ';
	    		SepMil := ', ';
	    		Esp := ' ';
	    		SepAndTres := ' and ';
		elsif Ling = 'EURO' then
	    		StrUnid := 'One;Two;Three;Four;Five;Six;Seven;Eight;Nine';
	    		StrPrimaDez := 'Eleven;Twelve;Thirteen;Fourteen;Fifteen;Sixteen;Seventeen;Eighteen;Nineteen';
	    		StrDez := 'Ten;Twenty;Thirty;Forty;Fifty;Sixty;Seventy;Eighty;Ninety';
	    		StrCem := 'One Hundred;Two Hundred;Three Hundred;Four Hundred;Five Hundred;Six Hundred;Seven Hundred;Eight Hundred;Nine Hundred';
	    		StrMil := 'Thousand.Thousand;Million.Millions;Billion.Billions;Trillion.Trillions';
	    		StrCent := 'Cent.Cents';
			MOEDA := 'Euro;Euro;Euro';
	    		Sep := ' ';
	    		SepDec := ' and ';
	    		SepMil := ', ';
	    		Esp := ' ';
	    		SepAndTres := ' and ';
		else
			return '#Erro';
		end if;		
		StrVV := to_char(VV, 'FM000000000000000.00');
		for Z in 1..6 loop
			StrM0 := '';
	    		if Z <> 6 then
		      		StrV0 := substr(StrVV, Z * 3 - 2, 3);
				StrM0 := lmontacento(Strv0, StrCem, Sep, StrDez, StrPrimaDez, StrUnid);			
				if not StrM0 is null or Z = 5 then
					if Z < 5 then
						if to_number(StrV0) = 1 then
							StrM0 := StrM0 || Esp || litem(litem(StrMil, 5 - Z, ';'), 1, '.');
						else
	                				StrM0 := StrM0 || Esp || litem(litem(StrMil, 5 - Z, ';'), 2, '.');
						end if;
	            			else
						if to_number(substr(StrVV, 1, 15)) <> 0 then
							if substr(StrVV, 10, 6) = 'FM000000' then
								StrM0 := StrM0 || Esp || litem(Moeda, 3, ';');
							elsif to_number(substr(StrVV, 1, 15)) = 1 then	
								StrM0 := StrM0 || Esp || lItem(Moeda, 1, ';');
							elsif to_number(substr(StrVV, 1, 15)) <> 1 then
								StrM0 := StrM0 || Esp || litem(Moeda, 2, ';');
							end if;
	                			end if;
	            			end if;
	        		end if;
	    		else
				StrV0 := 0 || substr(StrVV, 17, 2);
				StrM0 := lmontacento(Strv0, StrCem, Sep, StrDez, StrPrimaDez, StrUnid);			
			        if NOT StrM0 is null then
					if to_number(StrV0) = 1 then
	       					StrM0 := StrM0 || ' ' || litem(StrCent, 1, '.');				
					else	
	       					StrM0 := StrM0 || ' ' || litem(StrCent, 2, '.');								
					end if;
				end if;
	
			end if;
			if not StrM0 is null then
			        if Z = 6 Then
					if not StrMoeda is null then
		            			StrMoeda := StrMoeda ||  SepDec || StrM0;
					else
		            			StrMoeda := StrMoeda || '' || StrM0;
					end if;
	        		else
					if not StrMoeda is null and to_number(StrV0) <> 0 then
						if to_number(StrV0) < 101 Or mod(to_number(StrV0), 100) = 0 then
							StrMoeda := StrMoeda || SepAndTres || StrM0;
						else
							StrMoeda := StrMoeda || SepMil || StrM0;
						end if;
					else		
		            			StrMoeda := StrMoeda || '' || StrM0;
					end if;
	        		end if;
	    		end if;
		end loop;
		return StrMoeda;
	
	exception
		when others then
			raise_application_error ( -20000, 'erro em lextenso: ' || SQLERRM);
	
	end lextenso;


	function lmontacento (Strv0 in varchar2, StrCem in varchar2, Sep in varchar2, StrDez in varchar2, StrPrimaDez in varchar2, StrUnid in varchar2) return varchar2 is
	Pos number;
	ZZ number;
	StrM0 varchar2(100);
	begin
		for ZZ in 1..3 loop
	   		Pos := to_number(substr(Strv0, ZZ, 1));
			if POS <> 0 then
				if ZZ = 1 then
					StrM0 := StrM0 || litem(StrCem, Pos, ';');
				elsif ZZ = 2 then
					if Pos <> 1 Or substr(StrV0, 3, 1) = 0 then
						if not StrM0 is null then
							StrM0 := StrM0 || Sep || litem(StrDez, Pos, ';');			
						else
							StrM0 := StrM0 || '' || litem(StrDez, Pos, ';');	
						end if;
					else
						Pos := to_number(substr(StrV0, 3, 1));
						if not StrM0 is null then
							StrM0 := StrM0 || Sep || litem(StrPrimaDez, Pos, ';');			
						else
							StrM0 := StrM0 || '' || litem(StrPrimaDez, Pos, ';');	
						end if;
						exit;
					end if;
				
				elsif ZZ = 3 then
					if not StrM0 is null then
						StrM0 := StrM0 || Sep || litem(StrUnid, Pos, ';');			
					else
						StrM0 := StrM0 || '' || litem(StrUnid, Pos, ';');	
					end if;
				end if;
			end if;
		end loop;
		if StrM0 = 'Cento' then
			StrM0 := 'Cem'; 
		end if;
		return StrM0;
	
	exception
		when others then
			raise_application_error ( -20000, 'erro em lmontacento: ' || SQLERRM);
	
	end lmontacento;


	function lconcatcamp(Dominio in varchar2, Delimit in varchar2) return varchar2 is
	X pls_integer;
	Ret varchar2(4000);
	TextCol dbms_sql.varchar2_table;
	SqlCursor pls_integer;
	NumRows pls_integer;
	begin
		SqlCursor := dbms_sql.open_cursor;
		dbms_sql.parse(SqlCursor, Dominio, dbms_sql.v7);
		dbms_sql.define_array(SqlCursor, 1, TextCol, 10, 1);
		NumRows := dbms_sql.execute(SqlCursor);
		loop
			NumRows := dbms_sql.fetch_rows(SqlCursor);
			dbms_sql.column_value(SqlCursor, 1, TextCol);
			exit when NumRows < 10;
		end loop;	
		dbms_sql.close_cursor(SqlCursor);

		Ret := '';
		for X in 1..TextCol.count loop
			if not Ret is null then
				Ret := Ret || Delimit;
			end if;
			Ret := Ret || TextCol(X);
		end loop;	
		return Ret;

	exception
		when others then
			raise_application_error ( -20000, 'erro em lconcatcamp: ' || SQLERRM);

	end lconcatcamp;


	function lnumling(Num in number, Masc in varchar2, Ling in varchar2) return varchar2 is
	Result varchar2(1000);
	begin
		Result := to_char(Num, Masc);
		if Ling = 'P' then
			Result := replace(Result, ',', '@');
			Result := replace(Result, '.', ',');
			Result := replace(Result, '@', '.');
		end if;
		return trim(Result);
		
	exception
		when others then
			raise_application_error ( -20000, 'erro em lnumling: ' || SQLERRM);
	end lnumling;

end lb;
/


