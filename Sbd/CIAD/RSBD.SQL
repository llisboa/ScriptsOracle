Create or Replace Package RSBD as
	Procedure UpDateCascadeAutor(Antigo in varchar,Novo in varchar);
	Procedure AnaisEnderecos;
	Procedure AtualizaDelegados;
	Procedure TransfereMembros(Orgao in Varchar,Remanegado in varchar,NovoPosto in Varchar,Gestao in Date,qtRemanejado in number,Promover in boolean); 
	Procedure EMCDIncioContagem;
	Procedure EMCDApuracao;
	Procedure AssStatus;
end;
/

CREATE OR REPLACE PACKAGE BODY RSBD is
 --------------------------------------------------------------------------------------------------------------
 -- Procedimento para UPData Cascade do Ciad
 --------------------------------------------------------------------------------------------------------------
 Procedure  UpDateCascadeAutor(Antigo in varchar,Novo in varchar) is
 	autor responsavel%rowtype;
 begin
    	select * into autor from responsavel where nome=antigo;
	insert into responsavel (socio_mat,nome,endereço,bairro,cidade,estado,país,cep,ddd_residencial,tel_residencial,tel_comercial,
  	fax,tel_celular,email,matricula,autor,parecerista,revisor,tradutor,editor,sys_momento_cria,sys_usuário_cria,sys_local_cria,
  	sys_momento_atualiza,sys_local_atualiza,sys_status,contato1,telcontato1,contato2,telcontato2,SYS_USUÁRIO_ATUALIZA)
  	values(autor.socio_mat,Novo,autor.endereço,autor.bairro,autor.cidade,autor.estado,autor.país,autor.cep,autor.ddd_residencial,
  	autor.tel_residencial,autor.tel_comercial,autor.fax,autor.tel_celular,autor.email,autor.matricula,autor.autor,
  	autor.parecerista,autor.revisor,autor.tradutor,autor.editor,autor.sys_momento_cria,autor.sys_usuário_cria,autor.sys_local_cria,
  	SYSDATE,autor.sys_local_atualiza,'/',autor.contato1,autor.telcontato1,autor.contato2,autor.telcontato2,USER);
	update acompanhamento set responsavel_nome=novo where responsavel_nome=antigo;
	update tema_responsavel set responsavel_nome=novo where responsavel_nome=antigo;
	update artigo_responsavel set responsavel_nome=novo where responsavel_nome=antigo;
	delete responsavel where nome=antigo;
	commit;
 exception
	when others then
	rollback;
end UpDateCascadeAutor;
-----------------------------------------------------------------------------------------------------------------
--Gerencia a Transferancia de postos entre delegados e delegados suplenets
-----------------------------------------------------------------------------------------------------------------
Procedure AtualizaDelegados is
nDivisor number;
nPermitido number;
nSocio number;
dGestao Date;
vOrgao Varchar(100);
NREMANEJADO number;
begin
	Select divisor into nDivisor from sbdb.cargo where cargo='DELEGADOS';
	for cQtSocios in (SELECT COUNT(MAT) as qt,'DIRETORIA '||REGIONAL_COD as DIRETORIA FROM SBDB.SÓCIO WHERE EXCLUÍDO=0 AND (OBRIG_STATUS_COD LIKE 'QUITE%' OR OBRIG_STATUS_COD LIKE 'ISENTO%') group by regional_cod) LOOP
		nPermitido:=ROUND(cQtSocios.qt/nDivisor);
		if (nPermitido-(cQtSocios.qt/nDivisor))>0 then
			nPermitido:=nPermitido-1;
		end if;
		vOrgao:=cQtSocios.DIRETORIA;
		BEGIN
			select DISTINCT COUNT(SÓCIO_MAT),ÓRGÃO_GESTÃO_INI into nSocio,dGestao from
			sbdb.órgão_membro
			where órgão_nome=vOrgao
			AND
			ÓRGÃO_CARGO='DELEGADOS'
			AND
			ÓRGÃO_GESTÃO_INI=(SELECT MAX(ÓRGÃO_GESTÃO_INI) from sbdb.órgão_membro where órgão_nome=vOrgao AND ÓRGÃO_CARGO='DELEGADOS')
        		GROUP BY ÓRGÃO_NOME,ÓRGÃO_GESTÃO_INI;
			NREMANEJADO:=nSocio-nPermitido;
			if NREMANEJADO<0 then
				nRemaneJado:=nRemaneJado-(nRemaneJado*2);
				TransfereMembros(vOrgao,'DELEGADOS SUPLENTES','DELEGADOS',dGestao,nRemaneJado,TRUE);
			else
				TransfereMembros(vOrgao,'DELEGADOS','DELEGADOS SUPLENTES',dGestao,nRemaneJado,FALSE);
			end if;
		exception
			when NO_DATA_FOUND then
			nSocio:= 0;
		END;
	end loop;
COMMIT;
end AtualizaDelegados;
----------------------------------------------------------------------------------------------------------------------
-- Faz a Transferencia de menbros entre os ponstos enformados
----------------------------------------------------------------------------------------------------------------------
Procedure TransfereMembros(Orgao in Varchar,Remanegado in varchar,NovoPosto in Varchar,Gestao in Date,qtRemanejado in number,Promover in Boolean) is
EFalTaPosto EXCEPTION;
PRAGMA EXCEPTION_INIT(EFalTaPosto,-2291);
cMembrosID integer;
strsql varchar(500);
nOrdem órgão_membro.ordem%type;
nMat órgão_membro.sócio_mat%type;
nResult integer;
nLoop integer;
NovaOrdem nUMBER(3);
iPOsto varchar(50);
begin
	nLoop:=1;
	cMembrosID:=DBMS_SQL.OPEN_CURSOR;
	if promover then
		strsql:='select DISTINCT ORDEM,SÓCIO_MAT from sbdb.órgão_membro where
		órgão_nome=:pOrgao
		AND
		ÓRGÃO_CARGO=:pPOSTO
		AND
		ÓRGÃO_GESTÃO_INI=:pGestao
		GROUP BY
		ORDEM,
		SÓCIO_MAT
		ORDER BY
		ORDEM';
		select max(ORDEM) into NovaOrdem from sbdb.órgão_membro where órgão_nome=orgao AND ÓRGÃO_CARGO=NovoPosto AND ÓRGÃO_GESTÃO_INI=gestao;
	else
		strsql:='select DISTINCT ORDEM,SÓCIO_MAT from sbdb.órgão_membro where
		órgão_nome=:pOrgao
		AND
		ÓRGÃO_CARGO=:pPOSTO
		AND
		ÓRGÃO_GESTÃO_INI=:pGestao
		GROUP BY
		ORDEM,
		SÓCIO_MAT
		ORDER BY
		ORDEM DESC';
		NovaOrdem:=0;
	end if;
	dbms_sql.parse(cMembrosID,strsql,DBMS_SQL.NATIVE);
	DBMS_SQL.BIND_VARIABLE(cMembrosID,':pOrgao',Orgao);
	DBMS_SQL.BIND_VARIABLE(cMembrosID,':pPosto',Remanegado);
	DBMS_SQL.BIND_VARIABLE(cMembrosID,':pGestao',Gestao);
	DBMS_SQL.define_column(cMembrosID,1,nOrdem);
	DBMS_SQL.define_column(cMembrosID,2,nMat);
	nresult:=dbms_sql.execute(cMembrosID);
	Loop
		if (nloop>qtRemanejado) or (dbms_sql.fetch_rows(cMembrosID)=0) then
			exit;
		end if;
		DBMS_SQL.column_value(cMembrosID,1,nOrdem);
		DBMS_SQL.column_value(cMembrosID,2,nMat);
		IF PROMOVER THEN
			NovaOrdem:=NovaOrdem+1;
		ELSE
			NovaOrdem:=NovaOrdem-1;
		END IF;
		UPDATE SBDB.ÓRGÃO_MEMBRO SET ÓRGÃO_CARGO=NovoPosto,ORDEM=NovaOrdem,sys_status='X' where sócio_mat=nMat AND Órgão_Cargo=Remanegado AND ÓRGÃO_GESTÃO_INI=Gestao;
		nloop:=nloop+1;
	end loop;
	DBMS_SQL.CLOSE_CURSOR(cMembrosID);
	if promover then
		iposto:=Remanegado;
	else
		iposto:=NovoPosto;
	end if;
	strsql:='select DISTINCT ORDEM,SÓCIO_MAT from sbdb.órgão_membro where
	órgão_nome=:pOrgao
	AND
	ÓRGÃO_CARGO=:pPOSTO
	AND
	ÓRGÃO_GESTÃO_INI=:pGestao
	GROUP BY
	ORDEM,
	SÓCIO_MAT
	ORDER BY
	ORDEM';
	cMembrosID:=DBMS_SQL.OPEN_CURSOR;
	dbms_sql.parse(cMembrosID,strsql,DBMS_SQL.NATIVE);
	DBMS_SQL.BIND_VARIABLE(cMembrosID,':pOrgao',Orgao);
	DBMS_SQL.BIND_VARIABLE(cMembrosID,':pPosto',iposto);
	DBMS_SQL.BIND_VARIABLE(cMembrosID,':pGestao',Gestao);
	DBMS_SQL.define_column(cMembrosID,1,nOrdem);
	DBMS_SQL.define_column(cMembrosID,2,nMat);
	nresult:=dbms_sql.execute(cMembrosID);
	nloop:=1;
	loop
		if dbms_sql.fetch_rows(cMembrosID)=0 then
			exit;
		end if;
		DBMS_SQL.column_value(cMembrosID,1,nOrdem);
		DBMS_SQL.column_value(cMembrosID,2,nMat);
		UPDATE SBDB.ÓRGÃO_MEMBRO SET ORDEM=nLoop,sys_status='X' where sócio_mat=nMat AND Órgão_Cargo=iposto AND ÓRGÃO_GESTÃO_INI=Gestao;
		nLoop:=nLOop+1;
	End Loop;
	DBMS_SQL.CLOSE_CURSOR(cMembrosID);
	COMMIT;
	EXCEPTION
		when EFalTaPosto then
			IF NOT PROMOVER THEN
				DELETE FROM SBDB.ÓRGÃO_MEMBRO where sócio_mat=nMat AND Órgão_Cargo=Remanegado AND ÓRGÃO_GESTÃO_INI=Gestao;
			END IF;
			DBMS_SQL.CLOSE_CURSOR(cMembrosID);
		WHEN OTHERS THEN
		DBMS_SQL.CLOSE_CURSOR(cMembrosID);
		RAISE;
end TransfereMembros;
----------------------------------------------------------------------------------------------------------------------
--Atualiza o Inicio da Contagem dos Socios
----------------------------------------------------------------------------------------------------------------------
Procedure EMCDIncioContagem is
DataIni DATE;
DataFim DATE;
vFase number;
begin
vFase:=0;
for CPeriodos in (select to_number(fase) as Fase,to_number(seq) as seq,data_ini,data_fim from sbdb.emcd_periodo where apurado=0 order by fase,seq) loop
		if vFase<>Cperiodos.Fase then
			vFase:=CPeriodos.Fase;
			Select min(to_date(to_char(Data_Ini,'dd/mm/yyyy'),'dd/mm/yyyy')) into DataIni from sbdb.emcd_periodo where to_number(fase)=CPeriodos.Fase;
			Select max(to_date(to_char(Data_Fim,'dd/mm/yyyy'),'dd/mm/yyyy')) into DataFim from sbdb.emcd_periodo where to_number(fase)=CPeriodos.Fase;
			if to_date(to_char(DataFim,'dd/mm/yyyy'),'dd/mm/yyyy')<=to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')then
				update sbdb.Emcd_periodo set apurado=1,SYS_STATUS='X' where to_number(fase)=vfase;
				commit;
			end if;
	 	end if;
		end loop;
commit;		
end EMCDIncioContagem;
-------------------------------------------------------------------------------------------------------------------------
--Apuração dos Pontos
-------------------------------------------------------------------------------------------------------------------------
Procedure EMCDApuracao is
DataIni Date;
DataFim Date;
nValor Number;
nSeq  Number;
begin
nSeq:=0;
for CSocios in (select Sócio_Mat,TO_NUMBER(Apuração) AS Apuração from sbdb.emcd_ponto_sócio group By Sócio_Mat,Apuração) loop
		Select min(to_date(to_char(Data_Ini,'dd/mm/yyyy'),'dd/mm/yyyy')) into DataIni from sbdb.emcd_periodo where to_number(fase)=CSocios.Apuração;
		Select max(to_date(to_char(Data_Fim,'dd/mm/yyyy'),'dd/mm/yyyy')) into DataFim from sbdb.emcd_periodo where to_number(fase)=CSocios.Apuração;
		nvalor:=0;
		select sum(ponto_valor) into nvalor from sbdb.emcd_ponto_sócio where to_number(apuração)=CSocios.Apuração and Sócio_mat=cSocios.Sócio_Mat ;
		----------------------------------------------------------------------------------------------------------------
		-- loop sobre os pontos que iram mudar de fase devido não terem atingido 350
		----------------------------------------------------------------------------------------------------------------
		if (nValor<350) and (DataFim<Sysdate) then
		for cPontos in (SELECT sócio_mat,ATIV_COD,PONTO_DATA,TO_NUMBER(APURAÇÃO)+1 AS APURAÇÃO,DECODE(TO_NUMBER(SUBFASE),1,TO_NUMBER(SUBFASE),TO_NUMBER(SUBFASE)-1) AS SUBFASE FROM SBDB.EMCD_PONTO_SÓCIO 
				WHERE sócio_Mat=CSocios.SÓCIO_MAT AND TO_NUMBER(APURAÇÃO)=cSocios.Apuração and to_Number(SubFase)<>1 order by sócio_mat,ponto_data) loop
				update emcd_ponto_sócio set apuração=to_char(cPontos.Apuração,'0000'),SubFase=to_char(cPontos.SubFase,'000'),APURADO=-1,SYS_STATUS='X' where sócio_mat=cPontos.Sócio_Mat and Ativ_Cod=cPontos.Ativ_Cod;
				update emcd_apuração set 
				data_ini_cont=(Select mAX(to_date(to_char(Data_Ini,'dd/mm/yyyy'),'dd/mm/yyyy')) from sbdb.emcd_periodo where to_number(FASE)=CSocios.Apuração+1),
				data_apuração=(Select mAX(to_date(to_char(Data_Ini,'dd/mm/yyyy'),'dd/mm/yyyy')) from sbdb.emcd_periodo where to_number(FASE)=CSocios.Apuração+1),
				SYS_STATUS='X'
				where
				sócio_mat=cPontos.Sócio_Mat
				and
				seq=(select max(seq) from sbdb.emcd_apuração where sócio_mat=cPontos.Sócio_Mat);
				update Sócio set 
				DATA_INICIO_CONTAGEM=(Select mAX(to_date(to_char(Data_Ini,'dd/mm/yyyy'),'dd/mm/yyyy'))from sbdb.emcd_periodo where to_number(FASE)=CSocios.Apuração+1),
				sys_status='X' 
				where Mat=CSocios.Sócio_Mat;
				commit;
			end loop;
		----------------------------------------------------------------------------------------------------------------
		--Fim da Rotina de Mudar de Fase
		----------------------------------------------------------------------------------------------------------------		
		else
				SELECT nvl(max(SEQ),0) into nSeq FROM EMCD_APURAÇÃO 
				WHERE 
				DATA_INI_CONT=TO_DATE(to_char(dataini,'dd/mm/yyyy'),'dd/mm/yyyy') 
				and 
				DATA_APURAÇÃO=to_date(to_char(DataFim,'dd/mm/yyyy'),'dd/mm/yyyy')
				AND
				SÓCIO_MAT=cSocios.Sócio_Mat; 
				if nseq<>0 then
					update emcd_apuração set pontuação=nValor,Data_ini_Cont=DataIni,DAta_Apuração=DataFim,Apuracao=to_char(cSocios.Apuração,'0000'),SYS_STATUS='X'
					where sócio_Mat=CSocios.Sócio_Mat 
					and
					seq=nSeq;
					update Sócio set DATA_INICIO_CONTAGEM=DataIni,sys_status='X' where Mat=CSocios.Sócio_Mat;
 				else
					select nvl(max(seq)+1,1) INTO NSEQ from sbdb.emcd_apuração where sócio_mat=CSocios.Sócio_Mat;
					INSERT INTO emcd_apuração
					(SEQ,Sócio_Mat,pontuação,Data_ini_Cont,DAta_Apuração,apuracao)
					values(NsEQ,CSocios.Sócio_Mat,NvALOR,TO_DATE(to_char(DATAiNI,'dd/mm/yyyy'),'DD/MM/YYYY'),TO_DATE(to_char(DATAFIM,'dd/mm/yyyy'),'DD/MM/YYYY'),to_char(cSocios.Apuração,'0000'));
					update Sócio set DATA_INICIO_CONTAGEM=DataIni,sys_status='X' where Mat=CSocios.Sócio_Mat;
				end if;
									
		end if;
		if (DataFim=Sysdate) and (nValor>=350) then
			update sbdb.emcd_ponto_sócio set APURADO=-1,SYS_STATUS='X' where PONTO_DATA>=DataIni and PONTO_DATA<=DataFim and apuração=CSocios.Apuração and Sócio_Mat=CSocios.Sócio_Mat;
		end if;
			update sbdb.emcd_ponto_sócio set APURADO=-1,SYS_STATUS='X' where PONTO_DATA<DataIni and apuração=CSocios.Apuração and Sócio_Mat=CSocios.Sócio_Mat;
		commit;  
end loop;
end EMCDApuracao;
--------------------------------------------------------------------------------------
--Atualiza os endereços dos responsaveis que são sócios com a mala direta
--------------------------------------------------------------------------------------
Procedure AnaisEnderecos is
begin
	for cEnderecos in (
	select r.socio_mat,s.nome,
	decode(s.MALA_RESIDENCIAL,-1,s.endereço_residencial,decode(s.MALA_COMERCIAL_1,-1,s.ENDEREÇO_COMERCIAL_1,s.ENDEREÇO_COMERCIAL_2)) as Endereco,
	decode(s.MALA_RESIDENCIAL,-1,s.bairro_residencial,decode(s.MALA_COMERCIAL_1,-1,s.BAIRRO_COMERCIAL_1,s.BAIRRO_COMERCIAL_2)) as Bairro,
	decode(s.MALA_RESIDENCIAL,-1,s.cidade_residencial,decode(s.MALA_COMERCIAL_1,-1,s.CIDADE_COMERCIAL_1,s.CIDADE_COMERCIAL_2)) as Cidade,
	decode(s.MALA_RESIDENCIAL,-1,s.estado_residencial,decode(s.MALA_COMERCIAL_1,-1,s.ESTADO_COMERCIAL_1,s.ESTADO_COMERCIAL_2)) as UF,
	decode(s.MALA_RESIDENCIAL,-1,s.país_residencial,decode(s.MALA_COMERCIAL_1,-1,s.PAÍS_COMERCIAL_1,s.PAÍS_COMERCIAL_2)) as Pais,
	decode(s.MALA_RESIDENCIAL,-1,s.cep_residencial,decode(s.MALA_COMERCIAL_1,-1,s.CEP_COMERCIAL_1,s.CEP_COMERCIAL_2)) as Cep,
	decode(s.MALA_RESIDENCIAL,-1,s.ddd_residencial,decode(s.MALA_COMERCIAL_1,-1,s.DDD_COMERCIAL_1,s.DDD_COMERCIAL_2)) as DDD,
	s.tel_residencial,s.tel_comercial_1,s.tel_celular_residencial,s.fax_comercial_1,s.email_residencial
	from sbdb.sócio s,sbdb.responsavel r where R.socio_mat=s.mat )loop
			update sbdb.responsavel set ENDEREÇO=cEnderecos.endereco,BAIRRO=cEnderecos.bairro,CIDADE=cEnderecos.cidade,ESTADO=cEnderecos.uf,
			PAÍS=cEnderecos.pais,CEP=cEnderecos.cep,DDD_RESIDENCIAL=cEnderecos.ddd,TEL_RESIDENCIAL=cEnderecos.TEL_RESIDENCIAL,
			TEL_COMERCIAL=cEnderecos.TEL_COMERCIAL_1,FAX=cEnderecos.fax_comercial_1,TEL_CELULAR=cEnderecos.tel_celular_residencial,
			EMAIL=cEnderecos.email_residencial,sys_status='X' where SOCIO_MAT=cEnderecos.socio_mat;
	end loop;
	commit;
end AnaisEnderecos;
---------------------------------------------------------------------------------------
-- Atualiza Status da Assinatura
---------------------------------------------------------------------------------------
Procedure AssStatus is
begin
	update sbdb.editorial set status_sócio=1,SYS_STATUS='X' where assinatura_fim<sysdate and remessa<>'Doação';
	COMMIT;
end AssStatus;
end RSBD;
/
