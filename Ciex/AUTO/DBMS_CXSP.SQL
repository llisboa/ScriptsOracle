-------------------------------------------------------------------------------------
-- CRIAÇÃO DE SCRIPT PARA GERAR PACOTE DE FUNÇÕES BÁSICAS DO CXSP
--
-- desenvolvedor...: Luciano Lisbôa -- data: 18/07/2000
-- programa assist.: ESTRUT_CIEX_8i_2000.MDB
--
-- importante: * para rodar este, necessário antes rodar CXSP.SQL e TRANSF_CXSP.SQL
--             * copiar cxrjlib.dll para c:\winnt\system32 (mesmo arquivo para SP e BH)
-------------------------------------------------------------------------------------

create or replace library cxrjlib as 'c:\winnt\system32\cxrjlib.dll';
/
create or replace package dbms_cx is

        function val_data(DataInicial date, DataFinal date, DataVal date) return number;
        function dosshell(command in varchar2) return pls_integer;
        function sendmail(De in varchar, Para in varchar, Assunto in varchar, Servidor in varchar, Texto in varchar default '', Arquivo in varchar default '') return pls_integer;
        function public_dir return varchar;
        function utl_dir return varchar;
        function servidor return varchar2;


        procedure acerta_ciex;
        procedure log(reglog in utl_file.file_type, texto in varchar2);
        procedure loga(reglog in utl_file.file_type, diretorio in varchar2, arquivo in varchar2);
        procedure inicia_localidade(diretorio in varchar2, arquivo in varchar2, senhalocal in varchar2, servicolocal in varchar2);

        procedure grava_log(texto in varchar2,nome_arq in varchar2);
        procedure cad_log(de in varchar, para in varchar, servidor_msg in varchar);
        procedure cria_cia(nome_antigo in varchar2, nome_novo in varchar2, excluir in INTEGER);
        procedure atualiza_cia(nome_antigo in varchar2, nome_novo in varchar2);

        procedure cria_pacote(diretorio in varchar2, senhalocal in varchar2, servicolocal in varchar2, email in varchar2 default '', servsmtp in varchar2 default '', full in varchar2 default 'n', arq in varchar2 default '');
        procedure trata_pacote(localpac_remoto in varchar2, diretorio in varchar2, senhalocal in varchar2, servicolocal in varchar2, email in varchar2 default '', servsmtp in varchar2 default '', usuariopop3 in varchar2 default '', senhapop3 in varchar2 default '', servpop3 in varchar2 default '');
        procedure ver_pacote(arqpac_remoto in varchar2, diretorio in varchar2, senhalocal in varchar2, servicolocal in varchar2);

        procedure prog_gera_pacotes(nome_prog in varchar2, hora_exec in varchar2, diretorio in varchar2, senhalocal in varchar2, servicolocal in varchar2, email in varchar2 default '', servsmtp in varchar2 default '', intervalo_horas in varchar2 default '24');
        procedure prog_recebe_pacotes(nome_prog in char, intervalo_horas in varchar2, localpac_remoto in varchar2, diretorio in varchar2, senhalocal in varchar2, servicolocal in varchar2, email in varchar2 default '', servsmtp in varchar2 default '', usuariopop3 in varchar2 default '', senhapop3 in varchar2 default '', servpop3 in varchar2 default '');
        procedure prog_apaga(nome_prog in varchar2);

        PRAGMA RESTRICT_REFERENCES(val_data, WNDS, WNPS);

end;
/
create or replace package body dbms_cx is


        function sendmail(De in varchar, Para in varchar, Assunto in varchar, Servidor in varchar,
                Texto in varchar default '', Arquivo in varchar default '') return pls_integer is

        comando varchar2(1000);
        f utl_file.file_type;
        ret integer;
        aux integer;
        nomearq varchar(200);

        begin

                comando := 'sendmail -f ' || De || ' -t ' || replace(Para, ';', ' -t ') || ' -s "' || Assunto || ' (' || dbms_cx.servidor() || ')"';

                if not Texto is null then
                        for aux in 1..9999 loop
                                begin
                                        nomearq := 'sdml' || to_char(aux, 'FM0000') || '.txt';
                                        f := utl_file.fopen(public_dir(), nomearq, 'r');
                                        utl_file.fclose(f);
                                exception
                                        when others then
                                                exit;
                                end;
                        end loop;

                        f := utl_file.fopen(public_dir(), nomearq, 'w');

                        utl_file.put_line(f, Texto);
                        utl_file.fclose(f);

                        comando := comando || ' -b ' || public_dir() || '\' || nomearq;

                end if;

                if not Arquivo is null then
                        comando := comando || ' -a ' || replace(Arquivo, ';', ' -a ') ;
                end if;

                comando := comando || ' -m ' || Servidor;

                ret := DBMS_CX.DOSSHELL(comando);
                if not Texto is null then
                        aux := DOSSHELL('DEL ' || public_dir() || '\' || nomearq);
                end if;

                return ret;

        exception
                when others then
                        raise_application_error(-20000, 'erro no envio de mensagem -> ' || SQLERRM);
        end;


        function public_dir return varchar is
        begin
                return 'd:\oracle\public';
        end;
        function utl_dir return varchar is
        begin
                return 'e:\artes\cia_logos';
        end;


        function val_data(DataInicial date, DataFinal date, DataVal date) return number is
        begin
                if DataVal is null and DataInicial is null and DataFinal is null then
                        return 0;
                else
                        if DataVal is null then
                                return 0;
                        end if;
                        if not DataInicial is null then
                                if DataVal < DataInicial then
                                        return 0;
                                end if;
                        end if;
                        if not DataFinal is null then
                                if DataVal > DataFinal then
                                        return 0;
                                end if;
                        end if;
                end if;
                return 1;
        end;




        function dosshell(command in varchar2) return pls_integer
        is external
        library cxrjlib
        name "?dosshell@@YAHPAD@Z"
        language c
        calling standard pascal
        parameters (command string, return long);


        function servidor return varchar2 is
        servidor varchar2(200);

        begin
                SELECT MACHINE INTO servidor FROM V$SESSION WHERE OSUSER LIKE 'SYSTEM%' AND TYPE LIKE 'BACKGROUND%' AND ROWNUM = 1;
                return servidor;
        end;


        procedure acerta_ciex is
        cursor tabs is select TABLE_NAME from USER_TABLES;
        cursor vw is select VIEW_NAME from USER_VIEWS;
        cursor config is select PARAM, CONFIG from SYS_CONFIG_GLOBAL;
        texto varchar2(4000);
        begin

                begin
                        -- acerta parâmetro tabelas
                        texto := '';
                        for cur in tabs loop
                                if not (cur.TABLE_NAME like '%_T' or cur.TABLE_NAME = 'PLAN_TABLE') then
                                        texto := texto || cur.TABLE_NAME || ';';
                                end if;
                        end loop;
                        update SYS_CONFIG_GLOBAL set CONFIG = texto where PARAM = 'Tabelas';
                        if SQL%NOTFOUND then
                                insert into SYS_CONFIG_GLOBAL values('Tabelas', texto);
                        end if;

                        -- acerta parâmetro visões
                        texto := '';
                        for cur in vw loop
                                texto := texto || cur.VIEW_NAME || ';';
                        end loop;
                        update SYS_CONFIG_GLOBAL set CONFIG = texto where PARAM = 'Visões';
                        if SQL%NOTFOUND then
                                insert into SYS_CONFIG_GLOBAL values('Visões', texto);
                        end if;
                        COMMIT;
                exception
                        when others then
                                ROLLBACK;
                                raise_application_error ( -20000, 'Erro na atualização do SYS_CONFIG_GLOBAL -> ' || SQLERRM || ' <- Nenhuma alteração realizada');
                end;


                -- mostra configuração
                for cur in config loop
                        dbms_output.put('* ' || cur.PARAM || ' = ' || rpad(cur.CONFIG,200));
                        if length(cur.CONFIG) > 200 then
                                dbms_output.put_line('...');
                        else
                                dbms_output.new_line;
                        end if;
                end loop;
        end;


        procedure log(reglog in utl_file.file_type, texto in varchar2) is
        begin
                if utl_file.is_open(reglog) then
                        if length(texto) <> 0 then
                                if lpad(texto,2) <> '> ' then
                                        utl_file.put_line(reglog, to_char(sysdate, 'DD/MM/YY HH24:MI:SS') || ' : ' || texto);
                                else
                                        utl_file.put_line(reglog, texto);
                                end if;
                        else
                                utl_file.new_line(reglog);
                        end if;
                        utl_file.fflush(reglog);
                end if;

        exception
                when others then
                        dbms_output.put_line('Problemas ao tentar registrar informações em log (rotina DBMS_CX.LOG).');
        end;




        procedure loga(reglog in utl_file.file_type, diretorio in varchar2, arquivo in varchar2) is
        arqlog utl_file.file_type;
        linha varchar2(500);
        begin
                arqlog := utl_file.fopen(diretorio, arquivo, 'r');

                loop
                        begin
                                utl_file.get_line(arqlog, linha);
                                if utl_file.is_open(reglog) then
                                        utl_file.put_line(reglog, '>  ' || linha);
                                end if;
                        exception
                                when others then
                                        exit;
                        end;
                end loop;

                utl_file.new_line(reglog);
                utl_file.fclose(arqlog);
        exception
                when others then
                        dbms_output.put_line('Problemas ao tentar adicionar ' || arquivo || ' no log (rotina DBMS_CX.LOGA).');
                        if utl_file.is_open(arqlog) then
                                utl_file.fclose(arqlog);
                        end if;
        end;




        procedure cria_pacote(diretorio in varchar2, senhalocal in varchar2, servicolocal in varchar2, email in varchar2 default '', servsmtp in varchar2 default '', full in varchar2 default 'n', arq in varchar2 default '') is

        err integer;
        numpac integer;
        arqpac varchar2(100);
        localpac varchar2(100);
        reglog utl_file.file_type;
        modelopac SYS_LOCALID.MODELO%type;
        modelorec SYS_LOCALID.MODELO%type := -1;
        momento_modelopac SYS_LOCALID.MOMENTO%type;

        begin
                begin
                    select NOME, PACOTE, MODELO, MOMENTO into localpac, numpac, modelopac, momento_modelopac from SYS_LOCALID where CORRENTE = -1;

                        -- se modelo for 2, significa que existe outra tarefa utilizando o buffer de transferência
                         if modelopac = 2 then
                                if (SYSDATE()-momento_modelopac) > (1/24*6) then
                                        if not (email is null or servsmtp is null) then
                                                err := sendmail('cxsp@xxxxxxxxxx.com.br', email, 'CIEX - Rotina de criação de pacote', servsmtp, 'O sistema não está conseguindo criar pacotes devido às estruturas temporárias estarem bloqueadas por mais de 6 horas (modelo = 2).');
                                        end if;
                                        raise_application_error(-20000, 'erro na função de criação de pacote -> bloqueio de estruturas temporárias já alcança 6 horas');
                                else
                                        return;
                                end if;
                        end if;

                        -- define o arquivo destino
                        if arq is null then
                                if full = 'n' then
                                        arqpac := localpac || to_char(numpac, 'FM0000');
                                else
                                        arqpac := 'GERAL_' || localpac;
                                end if;
                        else
                                arqpac := arq;
                        end if;

                        -- garante exclusividade
                        modelorec := modelopac; -- em caso de erro, retorna o valor antigo;
                        update SYS_LOCALID set MODELO = 2, MOMENTO = SYSDATE where NOME = localpac;
                        modelopac := 2;
                        COMMIT;

                        reglog := utl_file.fopen(diretorio, arqpac || '.LOG', 'a');

                        log(reglog, '');
                        log(reglog, '----------------------------------------------------------------------');

                        if full = 'n' then

                                if modelorec =  0 then

                                        log(reglog, 'Início da criação do pacote ' || diretorio || '\' || arqpac || '.ARJ');

                                        log(reglog, 'Inicializando estruturas temporárias para transferência.');
                                        delete from EMB_FAMÍLIA_GENÉRICA_T;
                                        delete from DOC_T;
                                        delete from EMB_FAMÍLIA_T;
                                        delete from EMB_RE_T;
                                        delete from BL_T;
                                        delete from BL_CARGA_T;
                                        delete from DIVISÃO_PRODUTO_T;
                                        delete from EMB_TOTALIZA_T;
                                        delete from DIVISÃO_TIPO_REF_T;
                                        delete from EMB_DOC_REL_T;
                                        delete from MAPA_T;
                                        delete from INCOTERM_LANÇ_T;
                                        delete from LOCAL_RESULT_T;
                                        delete from EMB_SD_T;
                                        delete from PARAM_CSN_T;
                                        delete from EMB_LANÇ_T;
                                        delete from EMB_MENSAGEM_T;
                                        delete from ANEXO_T;
                                        delete from EMPRESA_APUR_T;
                                        delete from LOG_IMPORT_T;
                                        delete from CIA_RAMO_ATIVIDADE_T;
                                        delete from CARTA_FECH_T;
                                        delete from SYS_DELETE_T;
                                        delete from SUB_CONTA_T;
                                        delete from RESULT_T;
                                        delete from RELACIONADA_T;
                                        delete from CIA_CONTATO_T;
                                        delete from PRODUTO_ESPECIF_T;
                                        delete from FRETE_T;
                                        delete from CONFIRM_VENDA_ITEM_T;
                                        delete from PLANILHA_STC_T;
                                        delete from PLANILHA_DEF_T;
                                        delete from PED_RESULT_T;
                                        delete from PED_LANÇ_T;
                                        delete from CONTA_T;
                                        delete from PED_CONTATO_T;
                                        delete from DIVISÃO_T;
                                        delete from EMB_T;
                                        delete from CARTA_T;
                                        delete from EMB_F_T;
                                        delete from TIPO_REF_T;
                                        delete from FECH_CARGA_T;
                                        delete from RAMO_ATIVIDADE_T;
                                        delete from LANÇ_T;
                                        delete from DEPTO_T;
                                        delete from CARTA_CRÉDITO_T;
                                        delete from CONFIRM_VENDA_T;
                                        delete from PED_ITEM_T;
                                        delete from COSIPA_NEGOCIAÇÃO_T;
                                        delete from ESCRITÓRIO_T;
                                        delete from FECH_T;
                                        delete from PRODUTO_T;
                                        delete from PARAM_T;
                                        delete from EMBALAGEM_T;
                                        delete from UNID_QUANTID_T;
                                        delete from VIAGEM_ESCALA_T;
                                        delete from PED_T;
                                        delete from VIAGEM_T;
                                        delete from VIA_TRANSPORTE_T;
                                        delete from CIA_T;
                                        delete from COND_PAG_T;
                                        delete from MOEDA_T;
                                        delete from PORTO_T;
                                        delete from INCOTERM_T;
                                        delete from GRUPO_PRODUTO_T;
                                        delete from MODALIDADE_FRETE_T;
                                        delete from NAVIO_T;
                                        delete from PAÍS_T;
                                        delete from IDIOMA_T;

                                        COMMIT;

                                        set transaction read write;

                                        log(reglog, 'Transferindo informações para estruturas de transferência.');
                                        insert into INCOTERM_T (COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from INCOTERM where SYS_STATUS <> ' ';

                                        insert into GRUPO_PRODUTO_T (COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from GRUPO_PRODUTO where SYS_STATUS <> ' ';

                                        insert into PARAM_T (GRUPO,PARAM,QUANDO_TEXTO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select GRUPO,PARAM,QUANDO_TEXTO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PARAM where SYS_STATUS <> ' ';

                                        insert into DOC_T (COD,NOME,OBJETO_VINCULADO,FORMULÁRIO_PARAM
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,NOME,OBJETO_VINCULADO,FORMULÁRIO_PARAM
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DOC where SYS_STATUS <> ' ';

                                        insert into MOEDA_T (COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from MOEDA where SYS_STATUS <> ' ';

                                        insert into MODALIDADE_FRETE_T (COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from MODALIDADE_FRETE where SYS_STATUS <> ' ';

                                        insert into MAPA_T (WORKSHEET,SEQ,EMPRESA,ARQUIVO,TITULO,LINHA,COLUNA,COR,LARGURA,FONT,FONT_NEGRITO,FONT_TAM,ALINHAMENTO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select WORKSHEET,SEQ,EMPRESA,ARQUIVO,TITULO,LINHA,COLUNA,COR,LARGURA,FONT,FONT_NEGRITO,FONT_TAM,ALINHAMENTO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from MAPA where SYS_STATUS <> ' ';

                                        insert into LOG_IMPORT_T (SEQ,NOME,DATA,SITUAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select SEQ,NOME,DATA,SITUAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from LOG_IMPORT where SYS_STATUS <> ' ';

                                        insert into CONTA_T (EMPRESA,CONTA,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,CONTA,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CONTA where SYS_STATUS <> ' ';

                                        insert into LANÇ_T (LANÇ,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select LANÇ,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from LANÇ where SYS_STATUS <> ' ';

                                        insert into PARAM_CSN_T (PROD,PARAM,VALOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select PROD,PARAM,VALOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PARAM_CSN where SYS_STATUS <> ' ';

                                        insert into IDIOMA_T (COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from IDIOMA where SYS_STATUS <> ' ';

                                        insert into COSIPA_NEGOCIAÇÃO_T (REF,REF_EXT,DATA_ORD,ALTERA,MÊS_NEG,MÊS_EMB,AGENTE,PRODUTO,TON,PAÍS_DESTINO,PORTO_DESTINO,IMP,OUTRO_DOC,PEÇAS,TRAT_TÉRMICO,TOLER_PROD_LOT_MAX,TOLER_PROD_LOT_MIN,COND_PAG,TERMO_ENTREGA,PREÇO,COMISS_AGENTE,OBS_GERAL,INSP_CLASS,FATURA_LÂMINA,FATURA_OUTRO,EXTERNAL_SURVEY_TYPE,EXTERNAL_SURVEYOR,SURVEY_SIGN_CERTIF,CLASS_ORG,END_USER,HRP,HRC,CRC,PREDAYS,POSDAYS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select REF,REF_EXT,DATA_ORD,ALTERA,MÊS_NEG,MÊS_EMB,AGENTE,PRODUTO,TON,PAÍS_DESTINO,PORTO_DESTINO,IMP,OUTRO_DOC,PEÇAS,TRAT_TÉRMICO,TOLER_PROD_LOT_MAX,TOLER_PROD_LOT_MIN,COND_PAG,TERMO_ENTREGA,PREÇO,COMISS_AGENTE,OBS_GERAL,INSP_CLASS,FATURA_LÂMINA,FATURA_OUTRO,EXTERNAL_SURVEY_TYPE,EXTERNAL_SURVEYOR,SURVEY_SIGN_CERTIF,CLASS_ORG,END_USER,HRP,HRC,CRC,PREDAYS,POSDAYS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from COSIPA_NEGOCIAÇÃO where SYS_STATUS <> ' ';

                                        insert into DEPTO_T (COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DEPTO where SYS_STATUS <> ' ';

                                        insert into ANEXO_T (NOME,SUB_CONTA,SUB_CONTA_REL
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select NOME,SUB_CONTA,SUB_CONTA_REL
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from ANEXO where SYS_STATUS <> ' ';

                                        insert into ESCRITÓRIO_T (ESCRITÓRIO,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ESCRITÓRIO,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from ESCRITÓRIO where SYS_STATUS <> ' ';

                                        insert into EMPRESA_APUR_T (EMPRESA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMPRESA_APUR where SYS_STATUS <> ' ';

                                        insert into EMBALAGEM_T (COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMBALAGEM where SYS_STATUS <> ' ';

                                        insert into LOCAL_RESULT_T (COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from LOCAL_RESULT where SYS_STATUS <> ' ';

                                        insert into RELACIONADA_T (REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from RELACIONADA where SYS_STATUS <> ' ';

                                        insert into VIA_TRANSPORTE_T (COD,DESCR,TIPO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,DESCR,TIPO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from VIA_TRANSPORTE where SYS_STATUS <> ' ';

                                        insert into UNID_QUANTID_T (COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from UNID_QUANTID where SYS_STATUS <> ' ';

                                        insert into SYS_DELETE_T (NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL)

                                        select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL
  from SYS_DELETE;

                                        insert into SUB_CONTA_T (EMPRESA,SUB_CONTA,CONTA,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,SUB_CONTA,CONTA,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from SUB_CONTA where SYS_STATUS <> ' ';

                                        insert into CARTA_CRÉDITO_T (REF,REF_LC,DATA_EMISS,MOEDA,VALOR,PESO,BCO_EMISSOR,BCO_NEGOCIADOR,BCO_AVISADOR,BCO_CONFIRMADOR,BCO_RECEBEDOR,VALIDADE_LC,VALIDADE_EMB,FORM_PAGAMENTO,TOLER_QTD,TOLER_VALOR,APRESENT_DOC,UNID_PESO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select REF,REF_LC,DATA_EMISS,MOEDA,VALOR,PESO,BCO_EMISSOR,BCO_NEGOCIADOR,BCO_AVISADOR,BCO_CONFIRMADOR,BCO_RECEBEDOR,VALIDADE_LC,VALIDADE_EMB,FORM_PAGAMENTO,TOLER_QTD,TOLER_VALOR,APRESENT_DOC,UNID_PESO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CARTA_CRÉDITO where SYS_STATUS <> ' ';

                                        insert into COND_PAG_T (COD,DESCR,PERÍODO,OBS,FIN_COND
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,DESCR,PERÍODO,OBS,FIN_COND
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from COND_PAG where SYS_STATUS <> ' ';

                                        insert into RAMO_ATIVIDADE_T (COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from RAMO_ATIVIDADE where SYS_STATUS <> ' ';

                                        insert into PLANILHA_STC_T (WORKSHEET,EMPRESA,ARQUIVO,MAPA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select WORKSHEET,EMPRESA,ARQUIVO,MAPA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PLANILHA_STC where SYS_STATUS <> ' ';

                                        insert into PLANILHA_DEF_T (WORKSHEET,SEQ,EMPRESA,ARQUIVO,TIPO,HISTÓRICO,DATAHIST,COLUNACRT,CRT,COLUNADBCR,DÉBITO,CRÉDITO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select WORKSHEET,SEQ,EMPRESA,ARQUIVO,TIPO,HISTÓRICO,DATAHIST,COLUNACRT,CRT,COLUNADBCR,DÉBITO,CRÉDITO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PLANILHA_DEF where SYS_STATUS <> ' ';

                                        insert into TIPO_REF_T (TIPO,DESCR,DEPTO,ARQUIVO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select TIPO,DESCR,DEPTO,ARQUIVO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from TIPO_REF where SYS_STATUS <> ' ';

                                        insert into INCOTERM_LANÇ_T (INCOTERM,LANÇ
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select INCOTERM,LANÇ
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from INCOTERM_LANÇ where SYS_STATUS <> ' ';

                                        insert into DIVISÃO_T (ESCRITÓRIO,DIVISÃO,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ESCRITÓRIO,DIVISÃO,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DIVISÃO where SYS_STATUS <> ' ';

                                        insert into PRODUTO_T (COD,NOME,GRUPO,NCM,NALADI,NCM_OBS,NALADI_OBS,MEDIDAS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,NOME,GRUPO,NCM,NALADI,NCM_OBS,NALADI_OBS,MEDIDAS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PRODUTO where SYS_STATUS <> ' ';

                                        insert into PAÍS_T (COD,NOME,ABREVIATURA,BANDEIRA_COD,IDIOMA,MSG
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,NOME,ABREVIATURA,BANDEIRA_COD,IDIOMA,MSG
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PAÍS where SYS_STATUS <> ' ';

                                        insert into NAVIO_T (COD,ANO_CONSTRUÇÃO,NOME,NOME_ANTERIOR,BANDEIRA,NAVIO_TIPO,DWAT,LOA,BEAN,GRT,NRT,CAPACIDADE_GRÃO,CAPACIDADE_FARDO,CALADO_VERÃO,GUINDASTE_NUM,GUINDASTE_DIMENSÃO,ESCOTILHA_NUM,ESCOTILHA_DIMENSÃO,ESCOTILHA_FECHAM_TIPO,EQUIPAMENTO,TANKTOP_STRENGTH,SOCIEDADE_CLASSIFICADORA,CLASSE,OBS,OWNER,CALL_SIGN,N_TANKS,SBT,DOUBLE_HULL,DOUBLE_BOTTOM,INERT_GAS_SYS,HEATING_COILS,IMO_NUM,IMO_TYPE,COATING,CARGO_PUMPS,CUBIC_CAPACITY,CARGO_LINES,CARGO_MANIFOLDS,MAJORS_AP,SUMMER_DRAFT
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,ANO_CONSTRUÇÃO,NOME,NOME_ANTERIOR,BANDEIRA,NAVIO_TIPO,DWAT,LOA,BEAN,GRT,NRT,CAPACIDADE_GRÃO,CAPACIDADE_FARDO,CALADO_VERÃO,GUINDASTE_NUM,GUINDASTE_DIMENSÃO,ESCOTILHA_NUM,ESCOTILHA_DIMENSÃO,ESCOTILHA_FECHAM_TIPO,EQUIPAMENTO,TANKTOP_STRENGTH,SOCIEDADE_CLASSIFICADORA,CLASSE,OBS,OWNER,CALL_SIGN,N_TANKS,SBT,DOUBLE_HULL,DOUBLE_BOTTOM,INERT_GAS_SYS,HEATING_COILS,IMO_NUM,IMO_TYPE,COATING,CARGO_PUMPS,CUBIC_CAPACITY,CARGO_LINES,CARGO_MANIFOLDS,MAJORS_AP,SUMMER_DRAFT
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from NAVIO where SYS_STATUS <> ' ';

                                        insert into PORTO_T (COD,NOME,CIDADE,ESTADO,PAÍS,RESTRIÇÕES,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,NOME,CIDADE,ESTADO,PAÍS,RESTRIÇÕES,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PORTO where SYS_STATUS <> ' ';

                                        insert into PRODUTO_ESPECIF_T (COD,SEQ,NCM,NALADI,MENOR_ESPESSURA,MAIOR_ESPESSURA,MENOR_LARGURA,MAIOR_LARGURA,MENOR_COMPRIMENTO,MAIOR_COMPRIMENTO,REVESTIMENTO,TÊMPERA,DESCR,DESCR_NALADI
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select COD,SEQ,NCM,NALADI,MENOR_ESPESSURA,MAIOR_ESPESSURA,MENOR_LARGURA,MAIOR_LARGURA,MENOR_COMPRIMENTO,MAIOR_COMPRIMENTO,REVESTIMENTO,TÊMPERA,DESCR,DESCR_NALADI
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PRODUTO_ESPECIF where SYS_STATUS <> ' ';

                                        insert into DIVISÃO_PRODUTO_T (ESCRITÓRIO,DIVISÃO,PROD
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ESCRITÓRIO,DIVISÃO,PROD
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DIVISÃO_PRODUTO where SYS_STATUS <> ' ';

                                        insert into DIVISÃO_TIPO_REF_T (ESCRITÓRIO,DIVISÃO,TIPO_REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ESCRITÓRIO,DIVISÃO,TIPO_REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DIVISÃO_TIPO_REF where SYS_STATUS <> ' ';

                                        insert into CIA_T (LOGO,LOGOTIPO,COD,CGC,NOME,ENDEREÇO,BAIRRO,CIDADE,ESTADO,PAÍS,CEP,CAIXA_POSTAL,TELEFONE,FAX,TELEX,E_MAIL,F_COD,MARCAÇÃO,OBS,LOCAL_RESULT
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select LOGO,LOGOTIPO,COD,CGC,NOME,ENDEREÇO,BAIRRO,CIDADE,ESTADO,PAÍS,CEP,CAIXA_POSTAL,TELEFONE,FAX,TELEX,E_MAIL,F_COD,MARCAÇÃO,OBS,LOCAL_RESULT
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CIA where SYS_STATUS <> ' ';

                                        insert into CIA_CONTATO_T (CIA_COD,CONTATO_NOME,TELEFONE,FUNÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CIA_COD,CONTATO_NOME,TELEFONE,FUNÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CIA_CONTATO where SYS_STATUS <> ' ';

                                        insert into CIA_RAMO_ATIVIDADE_T (CIA_COD,RAMO_ATIVIDADE
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CIA_COD,RAMO_ATIVIDADE
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CIA_RAMO_ATIVIDADE where SYS_STATUS <> ' ';

                                        insert into CARTA_T (REF,EMPRESA,IDIOMA,DOC_DATA,CIA,CONTATO,CIA_SUB,CONTATO_SUB,ASSUNTO,TEXTO,EMISSÃO_DATA,COM_CÓPIA,USUÁRIO,SUPERVISOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select REF,EMPRESA,IDIOMA,DOC_DATA,CIA,CONTATO,CIA_SUB,CONTATO_SUB,ASSUNTO,TEXTO,EMISSÃO_DATA,COM_CÓPIA,USUÁRIO,SUPERVISOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CARTA where SYS_STATUS <> ' ';

                                        insert into PED_T (REF,PED_DATA,MOEDA,TAXA_USD,VIA_TRANSPORTE,CARGA_PORTO,PAÍS_DESTINO,FORNECEDOR,FORNECEDOR_REF,FORNECEDOR_COND_RECEB,EXP,EXP_REF,EXP_COND_RECEB,IMP,IMP_REF,IMP_COND_RECEB,DISTRIBUIDOR,PAGADOR,FRETE_COND,FRETE_PREV_POR_MT,FRETE_PREV_VALOR,EMB_PREV,MARCAÇÃO,OBS,TIPO_VENDA,GRUPO_PROD,SUPERVISOR_VENDA,PRODUÇÃO_PREV,PARIDADE,INSPEÇÃO_EXTERNA,RESPONSÁVEL_INSP_EXT,AGENTE,TAXA_JUROS_FINANCIAM,JUROS_NO_PREÇO,COMISSÃO_PERCENT,COMISSÃO_MT,ADICIONAL_PERCENT,ADICIONAL_MT,INCIDÊNCIA,TIPO,ANEXO,BENEFICIÁRIO,LOCAL_PAG,BANCO,F_QUANTIDADE,F_PREÇO,F_RESULTADO,F_RESULTADO_MT,F_RESULTADO_P,F_COMISSÃO_FORN,F_COMISSÃO_FORN_P,F_PROFIT_SPLIT,F_DELIV_PURCHASE,F_DELIV_SALES,F_PAY_PURCHASE,F_PAY_SALES,F_OBS,FORNECEDOR_COND_VENDA,EXP_COND_VENDA,IMP_COND_VENDA,INSTRUC_INTERNA,PRODUTOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select REF,PED_DATA,MOEDA,TAXA_USD,VIA_TRANSPORTE,CARGA_PORTO,PAÍS_DESTINO,FORNECEDOR,FORNECEDOR_REF,FORNECEDOR_COND_RECEB,EXP,EXP_REF,EXP_COND_RECEB,IMP,IMP_REF,IMP_COND_RECEB,DISTRIBUIDOR,PAGADOR,FRETE_COND,FRETE_PREV_POR_MT,FRETE_PREV_VALOR,EMB_PREV,MARCAÇÃO,OBS,TIPO_VENDA,GRUPO_PROD,SUPERVISOR_VENDA,PRODUÇÃO_PREV,PARIDADE,INSPEÇÃO_EXTERNA,RESPONSÁVEL_INSP_EXT,AGENTE,TAXA_JUROS_FINANCIAM,JUROS_NO_PREÇO,COMISSÃO_PERCENT,COMISSÃO_MT,ADICIONAL_PERCENT,ADICIONAL_MT,INCIDÊNCIA,TIPO,ANEXO,BENEFICIÁRIO,LOCAL_PAG,BANCO,F_QUANTIDADE,F_PREÇO,F_RESULTADO,F_RESULTADO_MT,F_RESULTADO_P,F_COMISSÃO_FORN,F_COMISSÃO_FORN_P,F_PROFIT_SPLIT,F_DELIV_PURCHASE,F_DELIV_SALES,F_PAY_PURCHASE,F_PAY_SALES,F_OBS,FORNECEDOR_COND_VENDA,EXP_COND_VENDA,IMP_COND_VENDA,INSTRUC_INTERNA,PRODUTOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED where SYS_STATUS <> ' ';

                                        insert into VIAGEM_T (REF,NAVIO,NAVIO_ÚLTIMO,CORRENTE,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select REF,NAVIO,NAVIO_ÚLTIMO,CORRENTE,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from VIAGEM where SYS_STATUS <> ' ';

                                        insert into FRETE_T (CARGA_PORTO,DESCARGA_PORTO,PROPRIETÁRIO,FRETE_DETALHE,FRETE_UNID,FRETE_VALOR_POR_UNID,COMISSÃO_USD,COMISSÃO_PERCENT,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CARGA_PORTO,DESCARGA_PORTO,PROPRIETÁRIO,FRETE_DETALHE,FRETE_UNID,FRETE_VALOR_POR_UNID,COMISSÃO_USD,COMISSÃO_PERCENT,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from FRETE where SYS_STATUS <> ' ';

                                        insert into PED_RESULT_T (PED_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,COMPETÊNCIA,CALC,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select PED_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,COMPETÊNCIA,CALC,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED_RESULT where SYS_STATUS <> ' ';

                                        insert into PED_LANÇ_T (PED_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,EXP,IMP,BENEFICIÁRIO,COMISSÃO_MODALIDADE,INSTRUÇÃO_REMESSA,EXP_CALC,IMP_CALC,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select PED_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,EXP,IMP,BENEFICIÁRIO,COMISSÃO_MODALIDADE,INSTRUÇÃO_REMESSA,EXP_CALC,IMP_CALC,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED_LANÇ where SYS_STATUS <> ' ';

                                        insert into PED_ITEM_T (PED_REF,ITEM,USUÁRIO_FINAL,USUÁRIO_REF,PED_UNID,NOMINAL_PED_UNID,TOTAL_FECH,TOTAL_EMB,TOLERÂNCIA_MIN,TOLERÂNCIA_MAX,PROD,DESCARGA_PORTO,EMBALAGEM,EMBALAGEM_PESO_MIN,EMBALAGEM_PESO_MAX,PREÇO_UNITÁRIO_FORNECEDOR,PREÇO_UNITÁRIO_EXP,PREÇO_UNITÁRIO_IMP,ESPESSURA_TIPO,ESPESSURA_MM,LARGURA_MM,COMPRIMENTO_MM,ESPESSURA_POL,LARGURA_POL,COMPRIMENTO_POL,NCM,NALADI,P,LOTE,OV,NE_ITEM,NE_ENVIO,TBN,FSE,PO,BL_CODE,USO_FINAL,DIÂMETRO_INTERNO,DIÂMETRO_EXTERNO,PESO_POR_FOLHA,AÇO_TIPO,REVESTIMENTO,TÊMPERA,ACABAMENTO,NORMA_TOLERÂNCIA,NORMA_PRODUÇÃO,BORDAS,OLEAMENTO,TRAT_TÉRMICO,TRAT_QUÍMICO,LA,LE,LÍNGUA,PROD_DESCR,COMPOSIÇÃO_QUÍMICA,MARCAÇÃO_PRODUÇÃO,COMENTÁRIO,PED_USINA_DATA,PED_USINA_ID,PED_USINA_CONFIRM,LAYDAY_INÍCIO,LAYDAY_FINAL,QTD_VOL,PESO_LÍQUIDO,PESO_BRUTO,FECH_REQUISITADO,FECH_NOTIFICADO,CANCEL_DATA,CANCEL_MOTIVO,SEGURO_PERCENT,CUR_PERCENT,SUPERFÍCIE,DIAMET_INT_MAX_TOLER,DIAMET_INT_MIM_TOLER,TQ,CERTIF_QUALIDADE,RABO_PEIXE,RABO_PEIXE_MAX,LÍNGUA_MAX,MARCAÇÃO_ESPECIAL_DOC,OBS,MARCAÇÃO,NOMINAL_MT,DIMENSÃO,TOL_CSN,RECOZIDO_CSN,TOL_ESPESSURA_CSN,TOL_LARGURA_CSN,TOL_COMPRIMENTO_CSN,MARCAÇÃO_DIF_CSN,FACE_PESADA_CSN,APLAINAMENTO_CSN,PASSIVAÇÃO_CSN,ACABAMENTO_CSN,FAIXA_PESO_CSN,SOLDAS_CSN,NUM_SOLDAS_CSN,MARCAÇÃO_SOLDA_CSN,VERNIZ_DOURADO_CSN,POSIÇÃO_FOLHA_PALLET_CSN,RUGOSIDADE_CSN,ESQUADRIA_CSN,NUM_CONSULTA_CSN,TOLERÂNCIA_PADRÃO_CSN,MARCAÇOES_ADICIONAIS_CSN
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select PED_REF,ITEM,USUÁRIO_FINAL,USUÁRIO_REF,PED_UNID,NOMINAL_PED_UNID,TOTAL_FECH,TOTAL_EMB,TOLERÂNCIA_MIN,TOLERÂNCIA_MAX,PROD,DESCARGA_PORTO,EMBALAGEM,EMBALAGEM_PESO_MIN,EMBALAGEM_PESO_MAX,PREÇO_UNITÁRIO_FORNECEDOR,PREÇO_UNITÁRIO_EXP,PREÇO_UNITÁRIO_IMP,ESPESSURA_TIPO,ESPESSURA_MM,LARGURA_MM,COMPRIMENTO_MM,ESPESSURA_POL,LARGURA_POL,COMPRIMENTO_POL,NCM,NALADI,P,LOTE,OV,NE_ITEM,NE_ENVIO,TBN,FSE,PO,BL_CODE,USO_FINAL,DIÂMETRO_INTERNO,DIÂMETRO_EXTERNO,PESO_POR_FOLHA,AÇO_TIPO,REVESTIMENTO,TÊMPERA,ACABAMENTO,NORMA_TOLERÂNCIA,NORMA_PRODUÇÃO,BORDAS,OLEAMENTO,TRAT_TÉRMICO,TRAT_QUÍMICO,LA,LE,LÍNGUA,PROD_DESCR,COMPOSIÇÃO_QUÍMICA,MARCAÇÃO_PRODUÇÃO,COMENTÁRIO,PED_USINA_DATA,PED_USINA_ID,PED_USINA_CONFIRM,LAYDAY_INÍCIO,LAYDAY_FINAL,QTD_VOL,PESO_LÍQUIDO,PESO_BRUTO,FECH_REQUISITADO,FECH_NOTIFICADO,CANCEL_DATA,CANCEL_MOTIVO,SEGURO_PERCENT,CUR_PERCENT,SUPERFÍCIE,DIAMET_INT_MAX_TOLER,DIAMET_INT_MIM_TOLER,TQ,CERTIF_QUALIDADE,RABO_PEIXE,RABO_PEIXE_MAX,LÍNGUA_MAX,MARCAÇÃO_ESPECIAL_DOC,OBS,MARCAÇÃO,NOMINAL_MT,DIMENSÃO,TOL_CSN,RECOZIDO_CSN,TOL_ESPESSURA_CSN,TOL_LARGURA_CSN,TOL_COMPRIMENTO_CSN,MARCAÇÃO_DIF_CSN,FACE_PESADA_CSN,APLAINAMENTO_CSN,PASSIVAÇÃO_CSN,ACABAMENTO_CSN,FAIXA_PESO_CSN,SOLDAS_CSN,NUM_SOLDAS_CSN,MARCAÇÃO_SOLDA_CSN,VERNIZ_DOURADO_CSN,POSIÇÃO_FOLHA_PALLET_CSN,RUGOSIDADE_CSN,ESQUADRIA_CSN,NUM_CONSULTA_CSN,TOLERÂNCIA_PADRÃO_CSN,MARCAÇOES_ADICIONAIS_CSN
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED_ITEM where SYS_STATUS <> ' ';

                                        insert into PED_CONTATO_T (PED_REF,CIA_COD,CONTATO_NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select PED_REF,CIA_COD,CONTATO_NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED_CONTATO where SYS_STATUS <> ' ';

                                        insert into CONFIRM_VENDA_T (REF,SEQ,EMISSÃO_DATA,EMISSOR,PED_REF,OUTRA_REF,COMPRADOR,USUÁRIO_FINAL,DESTINATÁRIO,ENTREGA,CARGA_PORTO,IDIOMA,DIMENSÃO,PREÇO_DETALHE,ESPECIFICAÇÃO,EMBALAGEM,SEGURO,PAG,OBS,OBS_TERMOS,PRODUTOR,DESCARGA_PORTO,ASSINATURA,DT_REVISÃO,EMPRESA_REL,MOEDA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select REF,SEQ,EMISSÃO_DATA,EMISSOR,PED_REF,OUTRA_REF,COMPRADOR,USUÁRIO_FINAL,DESTINATÁRIO,ENTREGA,CARGA_PORTO,IDIOMA,DIMENSÃO,PREÇO_DETALHE,ESPECIFICAÇÃO,EMBALAGEM,SEGURO,PAG,OBS,OBS_TERMOS,PRODUTOR,DESCARGA_PORTO,ASSINATURA,DT_REVISÃO,EMPRESA_REL,MOEDA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CONFIRM_VENDA where SYS_STATUS <> ' ';

                                        insert into VIAGEM_ESCALA_T (VIAGEM_REF,ESCALA,PORTO,ETA,ETS,ATA,ATS,LD,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select VIAGEM_REF,ESCALA,PORTO,ETA,ETS,ATA,ATS,LD,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from VIAGEM_ESCALA where SYS_STATUS <> ' ';

                                        insert into EMB_F_T (PED_REF,SEQ,FATURA,INV_DATA,NAVIO,BL_DATA,COMPETÊNCIA,QUANTIDADE,VALOR,RESULT1,RESULT2,RESULT3,RESULT4,RESULT5,POSIÇÃO,OBSERVAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select PED_REF,SEQ,FATURA,INV_DATA,NAVIO,BL_DATA,COMPETÊNCIA,QUANTIDADE,VALOR,RESULT1,RESULT2,RESULT3,RESULT4,RESULT5,POSIÇÃO,OBSERVAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_F where SYS_STATUS <> ' ';

                                        insert into EMB_T (CALC_NOMINAL_PED,REF,VIAGEM,FRETE_UNID,FRETE_VALOR,FRETE_POR_MT,FRETE_VALOR_POR_UNID,FRETE_VALOR_TOTAL,FRETE_COND,DATA_EMBARQUE,DATA_EMISSÃO_DOC,CARGA_PORTO,DESCARGA_PORTO,TRANSPORTADOR,MOEDA,IDIOMA,PESO_UNID,PREÇO_UNITÁRIO_UNID,PREÇO_UNID,NEGOCIADOR,EMBARCADOR,EMB_ENDEREÇO,EMB_PAÍS,EMB_COND_VENDA,EMB_COND_PAG,EMB_COMENTÁRIOS,EXP,EXP_ENDEREÇO,EXP_PAÍS,EXP_COND_VENDA,EXP_COND_PAG,EXP_COMENTÁRIOS,EXP_LOGOTIPO,EXP_FAT,IMP,IMP_ENDEREÇO,IMP_PAÍS,IMP_COND_VENDA,IMP_COND_PAG,IMP_COMENTÁRIOS,IMP_LOGOTIPO,IMP_FAT,PAGADOR,PAG_ENDEREÇO,PAG_PAÍS,CONSIGNATÁRIO,CONSIGN_ENDEREÇO,CONSIGN_PAÍS,NOTIFICAR,NOTIFICAR_ENDEREÇO,NOTIFICAR_PAÍS,NUM_BL_DESCR,FAMÍLIA_GENÉRICA,TIPO_DESCR_MERCADORIA,MARCAÇÃO,TOTALIZAÇÃO_EMBALAGEM,CONFIG,EMB_ACORDO,VIA_TRANSPORTE,CARTA_CRED_REF,EMB_DATA,CARTA_CRÉDITO_BANCO_ABRIDOR,CARTA_CRÉDITO_REF,BANCO_AVISADOR,BANCO_CONFIRM,CALC_QTD_PED_UNID,CALC_PESO_LÍQUIDO,CALC_PESO_BRUTO,CALC_QTD_VOL,CALC_EXP_TOT_ITEM,CALC_EXP_TOT_EMB,CALC_EXP_COND_PAG,CALC_EXP_COND_VENDA,CALC_IMP_TOT_ITEM,CALC_IMP_TOT_EMB,CALC_IMP_COND_PAG,CALC_IMP_COND_VENDA,CALC_FRETE_TOTAL,CALC_PEND
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CALC_NOMINAL_PED,REF,VIAGEM,FRETE_UNID,FRETE_VALOR,FRETE_POR_MT,FRETE_VALOR_POR_UNID,FRETE_VALOR_TOTAL,FRETE_COND,DATA_EMBARQUE,DATA_EMISSÃO_DOC,CARGA_PORTO,DESCARGA_PORTO,TRANSPORTADOR,MOEDA,IDIOMA,PESO_UNID,PREÇO_UNITÁRIO_UNID,PREÇO_UNID,NEGOCIADOR,EMBARCADOR,EMB_ENDEREÇO,EMB_PAÍS,EMB_COND_VENDA,EMB_COND_PAG,EMB_COMENTÁRIOS,EXP,EXP_ENDEREÇO,EXP_PAÍS,EXP_COND_VENDA,EXP_COND_PAG,EXP_COMENTÁRIOS,EXP_LOGOTIPO,EXP_FAT,IMP,IMP_ENDEREÇO,IMP_PAÍS,IMP_COND_VENDA,IMP_COND_PAG,IMP_COMENTÁRIOS,IMP_LOGOTIPO,IMP_FAT,PAGADOR,PAG_ENDEREÇO,PAG_PAÍS,CONSIGNATÁRIO,CONSIGN_ENDEREÇO,CONSIGN_PAÍS,NOTIFICAR,NOTIFICAR_ENDEREÇO,NOTIFICAR_PAÍS,NUM_BL_DESCR,FAMÍLIA_GENÉRICA,TIPO_DESCR_MERCADORIA,MARCAÇÃO,TOTALIZAÇÃO_EMBALAGEM,CONFIG,EMB_ACORDO,VIA_TRANSPORTE,CARTA_CRED_REF,EMB_DATA,CARTA_CRÉDITO_BANCO_ABRIDOR,CARTA_CRÉDITO_REF,BANCO_AVISADOR,BANCO_CONFIRM,CALC_QTD_PED_UNID,CALC_PESO_LÍQUIDO,CALC_PESO_BRUTO,CALC_QTD_VOL,CALC_EXP_TOT_ITEM,CALC_EXP_TOT_EMB,CALC_EXP_COND_PAG,CALC_EXP_COND_VENDA,CALC_IMP_TOT_ITEM,CALC_IMP_TOT_EMB,CALC_IMP_COND_PAG,CALC_IMP_COND_VENDA,CALC_FRETE_TOTAL,CALC_PEND
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB where SYS_STATUS <> ' ';

                                        insert into BL_T (VIAGEM_REF,SEQ,BL_NUM,BL_DATA,EMB_REF,MSG
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select VIAGEM_REF,SEQ,BL_NUM,BL_DATA,EMB_REF,MSG
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from BL where SYS_STATUS <> ' ';

                                        insert into EMB_LANÇ_T (EMB_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,EXP,IMP,UNID,NA_FATURA,BENEFICIÁRIO,COMISSÃO_MODALIDADE,INSTRUÇÃO_REMESSA,EXP_CALC,IMP_CALC
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMB_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,EXP,IMP,UNID,NA_FATURA,BENEFICIÁRIO,COMISSÃO_MODALIDADE,INSTRUÇÃO_REMESSA,EXP_CALC,IMP_CALC
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_LANÇ where SYS_STATUS <> ' ';

                                        insert into RESULT_T (PED_REF,EMB_SEQ,SEQ,INV_DATA,RESULT1,RESULT2,RESULT3,RESULT4,RESULT5,DATA1,DATA2,DATA3,DATA4,DATA5,POSIÇÃO,OBSERVAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select PED_REF,EMB_SEQ,SEQ,INV_DATA,RESULT1,RESULT2,RESULT3,RESULT4,RESULT5,DATA1,DATA2,DATA3,DATA4,DATA5,POSIÇÃO,OBSERVAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from RESULT where SYS_STATUS <> ' ';

                                        insert into EMB_FAMÍLIA_GENÉRICA_T (EMB_REF,SEQ,FAMÍLIA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMB_REF,SEQ,FAMÍLIA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_FAMÍLIA_GENÉRICA where SYS_STATUS <> ' ';

                                        insert into CONFIRM_VENDA_ITEM_T (CONFIRM_VENDA_REF,SEQ,ITEM,DESCR,DIMENSÃO,QTD,UNID,PREÇO,MOEDA,QUALIDADE,PREÇO_C
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CONFIRM_VENDA_REF,SEQ,ITEM,DESCR,DIMENSÃO,QTD,UNID,PREÇO,MOEDA,QUALIDADE,PREÇO_C
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CONFIRM_VENDA_ITEM where SYS_STATUS <> ' ';

                                        insert into EMB_DOC_REL_T (EMB_REF,DOC,EMB_REL
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMB_REF,DOC,EMB_REL
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_DOC_REL where SYS_STATUS <> ' ';

                                        insert into EMB_TOTALIZA_T (EMB_REF,SEQ,LANÇ,EXP,IMP,EXP_DESCR,IMP_DESCR,EXP_CALC,IMP_CALC
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMB_REF,SEQ,LANÇ,EXP,IMP,EXP_DESCR,IMP_DESCR,EXP_CALC,IMP_CALC
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_TOTALIZA where SYS_STATUS <> ' ';

                                        insert into EMB_RE_T (EMB_REF,RE,EMISSÃO_DATA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMB_REF,RE,EMISSÃO_DATA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_RE where SYS_STATUS <> ' ';

                                        insert into EMB_MENSAGEM_T (EMB_REF,SEQ,MSG,EXP,IMP,DOC_ALADI,DOC_BORDERÔ_I,DOC_BORDERÔ_P,DOC_CÂMARA_COMÉRCIO,DOC_CARTA_I,DOC_CARTA_P,DOC_CONHECIM_ROD,DOC_FATURA,DOC_FATURA_JUROS,DOC_FECH_CAMBIO,DOC_FIRJAN,DOC_MERCOSUL,DOC_MERCOSUL_BOLIVIA,DOC_MERCOSUL_CHILE,DOC_PLIST_WEIG_CERT,DOC_SAQUE_JUR_2_VIAS,DOC_SAQUE_JUR_3_VIAS,DOC_SAQUE_2_VIAS,DOC_SAQUE_3_VIAS,DOC_ALADI_CERTIF_ORIGEM,DOC_BL,DOC_CÂM_COM_CERTIF_O,DOC_CAPA,DOC_CONHECIM_RODOVIÁRIO,DOC_CHECK_LIST,DOC_CARTA_DEOP_INGLÊS,DOC_CARTA_DEOP_PORTUG,DOC_FECHAM_CÂMBIO,DOC_FIRJAN_CERTIF_ORIGEM,DOC_FORM_A,DOC_INSTR_PAG,DOC_MERCOSUL_CERTIF_ORIGEM,DOC_PACKING_LIST,DOC_SAQUE,DOC_WEIGHT_CERTIFICATE,DOC_SAQUE_JUROS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMB_REF,SEQ,MSG,EXP,IMP,DOC_ALADI,DOC_BORDERÔ_I,DOC_BORDERÔ_P,DOC_CÂMARA_COMÉRCIO,DOC_CARTA_I,DOC_CARTA_P,DOC_CONHECIM_ROD,DOC_FATURA,DOC_FATURA_JUROS,DOC_FECH_CAMBIO,DOC_FIRJAN,DOC_MERCOSUL,DOC_MERCOSUL_BOLIVIA,DOC_MERCOSUL_CHILE,DOC_PLIST_WEIG_CERT,DOC_SAQUE_JUR_2_VIAS,DOC_SAQUE_JUR_3_VIAS,DOC_SAQUE_2_VIAS,DOC_SAQUE_3_VIAS,DOC_ALADI_CERTIF_ORIGEM,DOC_BL,DOC_CÂM_COM_CERTIF_O,DOC_CAPA,DOC_CONHECIM_RODOVIÁRIO,DOC_CHECK_LIST,DOC_CARTA_DEOP_INGLÊS,DOC_CARTA_DEOP_PORTUG,DOC_FECHAM_CÂMBIO,DOC_FIRJAN_CERTIF_ORIGEM,DOC_FORM_A,DOC_INSTR_PAG,DOC_MERCOSUL_CERTIF_ORIGEM,DOC_PACKING_LIST,DOC_SAQUE,DOC_WEIGHT_CERTIFICATE,DOC_SAQUE_JUROS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_MENSAGEM where SYS_STATUS <> ' ';

                                        insert into EMB_SD_T (EMB_REF,SD,AVERBAÇÃO_DATA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMB_REF,SD,AVERBAÇÃO_DATA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_SD where SYS_STATUS <> ' ';

                                        insert into FECH_T (REF,FECH_DATA,MOEDA,VIAGEM_REF,CARGA_PORTO_ESCALA,DESCARGA_PORTO_ESCALA,CONTRATANTE,CORRETOR,PROPRIETÁRIO,NEGOCIANTE,FRETE_DETALHE,FRETE_UNID,FRETE_VALOR,FRETE_VALOR_POR_UNID,FRETE_PAG_DETALHE,COMISSÃO_FRETE,COMISSÃO_BASE,COMISSÃO_PERCENT,CIA_PAGADORA,CARGA_AGENTE,CARGA_ESTIVA,CARGA_ESTIVA_CUSTO,CARGA_DETALHE,CARGA_OBS,DESCARGA_AGENTE,DESCARGA_ESTIVA,DESCARGA_ESTIVA_CUSTO,DESCARGA_DETALHE,DESCARGA_OBS,DETENÇÃO,DEMORA,OBS,DESPACHANTE
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select REF,FECH_DATA,MOEDA,VIAGEM_REF,CARGA_PORTO_ESCALA,DESCARGA_PORTO_ESCALA,CONTRATANTE,CORRETOR,PROPRIETÁRIO,NEGOCIANTE,FRETE_DETALHE,FRETE_UNID,FRETE_VALOR,FRETE_VALOR_POR_UNID,FRETE_PAG_DETALHE,COMISSÃO_FRETE,COMISSÃO_BASE,COMISSÃO_PERCENT,CIA_PAGADORA,CARGA_AGENTE,CARGA_ESTIVA,CARGA_ESTIVA_CUSTO,CARGA_DETALHE,CARGA_OBS,DESCARGA_AGENTE,DESCARGA_ESTIVA,DESCARGA_ESTIVA_CUSTO,DESCARGA_DETALHE,DESCARGA_OBS,DETENÇÃO,DEMORA,OBS,DESPACHANTE
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from FECH where SYS_STATUS <> ' ';

                                        insert into EMB_FAMÍLIA_T (EMB_REF,SEQ,FAMÍLIA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMB_REF,SEQ,FAMÍLIA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_FAMÍLIA where SYS_STATUS <> ' ';

                                        insert into FECH_CARGA_T (FECH_REF,PED_REF,PED_ITEM,QTD_PED_UNID,QTD_FRETE_UNID,QTD_TOTAL,NOMEAÇÃO_DATA,ACEITAÇÃO_FORNECEDOR_DATA,CANCEL_DATA,CANCEL_MOTIVO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select FECH_REF,PED_REF,PED_ITEM,QTD_PED_UNID,QTD_FRETE_UNID,QTD_TOTAL,NOMEAÇÃO_DATA,ACEITAÇÃO_FORNECEDOR_DATA,CANCEL_DATA,CANCEL_MOTIVO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from FECH_CARGA where SYS_STATUS <> ' ';

                                        insert into CARTA_FECH_T (CARTA_REF,FECH_REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CARTA_REF,FECH_REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CARTA_FECH where SYS_STATUS <> ' ';

                                        insert into BL_CARGA_T (PED_REF,PED_ITEM,VIAGEM_REF,BL_SEQ,FECH_REF,QTD_PED_UNID,QTD_VOL,PESO_LÍQUIDO,PESO_BRUTO,EMB_DATA,EMB_REF,EMB_SEQ,FAMÍLIA_GENÉRICA,FAMÍLIA,DESCR         ,EMBALAGEM,NCM,NALADI,EXP_PREÇO_UNIT,IMP_PREÇO_UNIT,CALC_EXP_EMB,CALC_EXP_FOB,CALC_IMP_EMB,CALC_IMP_FOB,NOMINAL_PED_UNID
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select PED_REF,PED_ITEM,VIAGEM_REF,BL_SEQ,FECH_REF,QTD_PED_UNID,QTD_VOL,PESO_LÍQUIDO,PESO_BRUTO,EMB_DATA,EMB_REF,EMB_SEQ,FAMÍLIA_GENÉRICA,FAMÍLIA,DESCR         ,EMBALAGEM,NCM,NALADI,EXP_PREÇO_UNIT,IMP_PREÇO_UNIT,CALC_EXP_EMB,CALC_EXP_FOB,CALC_IMP_EMB,CALC_IMP_FOB,NOMINAL_PED_UNID
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from BL_CARGA where SYS_STATUS <> ' ';


                                        log(reglog, 'Inicializando status dos registros exportados.');
                                        update INCOTERM set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update GRUPO_PRODUTO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PARAM set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update DOC set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update MOEDA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update MODALIDADE_FRETE set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update MAPA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update LOG_IMPORT set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CONTA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update LANÇ set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PARAM_CSN set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update IDIOMA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update COSIPA_NEGOCIAÇÃO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update DEPTO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update ANEXO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update ESCRITÓRIO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update EMPRESA_APUR set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update EMBALAGEM set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update LOCAL_RESULT set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update RELACIONADA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update VIA_TRANSPORTE set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update UNID_QUANTID set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        delete from SYS_DELETE;
                                        update SUB_CONTA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CARTA_CRÉDITO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update COND_PAG set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update RAMO_ATIVIDADE set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PLANILHA_STC set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PLANILHA_DEF set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update TIPO_REF set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update INCOTERM_LANÇ set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update DIVISÃO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PRODUTO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PAÍS set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update NAVIO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PORTO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PRODUTO_ESPECIF set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update DIVISÃO_PRODUTO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update DIVISÃO_TIPO_REF set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CIA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CIA_CONTATO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CIA_RAMO_ATIVIDADE set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CARTA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PED set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update VIAGEM set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update FRETE set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PED_RESULT set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PED_LANÇ set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PED_ITEM set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PED_CONTATO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CONFIRM_VENDA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update VIAGEM_ESCALA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update EMB_F set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update EMB set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update BL set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update EMB_LANÇ set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update RESULT set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update EMB_FAMÍLIA_GENÉRICA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CONFIRM_VENDA_ITEM set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update EMB_DOC_REL set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update EMB_TOTALIZA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update EMB_RE set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update EMB_MENSAGEM set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update EMB_SD set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update FECH set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update EMB_FAMÍLIA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update FECH_CARGA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CARTA_FECH set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update BL_CARGA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';

                                        -- define conteúdo de buffer como pacote válido
                                        log(reglog, 'Define conteúdo do buffer de transferência como um pacote válido mod=1.');
                                        modelorec := 1;

                                        COMMIT;

                                elsif modelopac = 1 then
                                        log(reglog, 'Localidada informações do pacote ' || diretorio || '\' || arqpac || '.ARJ' || ' ainda no pool de transferência. Criação anterior do pacote deve ter falhado.');
                                else
                                        log(reglog, 'Início da criação do pacote ' || diretorio || '\' || arqpac || '.ARJ');
                                        raise_application_error(-20000, 'modelo ' || to_char(modelopac) || ' inválido para criação de pacote na localidade ' || localpac);
                                end if;
                        else
                                log(reglog, 'Gerando pacote TOTAL para o arquivo ' || diretorio || '\' || arqpac || '.ARJ' || '.');

                                log(reglog, 'Inicializando estruturas temporárias para transferência.');
                                delete from EMB_FAMÍLIA_GENÉRICA_T;
                                delete from DOC_T;
                                delete from EMB_FAMÍLIA_T;
                                delete from EMB_RE_T;
                                delete from BL_T;
                                delete from BL_CARGA_T;
                                delete from DIVISÃO_PRODUTO_T;
                                delete from EMB_TOTALIZA_T;
                                delete from DIVISÃO_TIPO_REF_T;
                                delete from EMB_DOC_REL_T;
                                delete from MAPA_T;
                                delete from INCOTERM_LANÇ_T;
                                delete from LOCAL_RESULT_T;
                                delete from EMB_SD_T;
                                delete from PARAM_CSN_T;
                                delete from EMB_LANÇ_T;
                                delete from EMB_MENSAGEM_T;
                                delete from ANEXO_T;
                                delete from EMPRESA_APUR_T;
                                delete from LOG_IMPORT_T;
                                delete from CIA_RAMO_ATIVIDADE_T;
                                delete from CARTA_FECH_T;
                                delete from SYS_DELETE_T;
                                delete from SUB_CONTA_T;
                                delete from RESULT_T;
                                delete from RELACIONADA_T;
                                delete from CIA_CONTATO_T;
                                delete from PRODUTO_ESPECIF_T;
                                delete from FRETE_T;
                                delete from CONFIRM_VENDA_ITEM_T;
                                delete from PLANILHA_STC_T;
                                delete from PLANILHA_DEF_T;
                                delete from PED_RESULT_T;
                                delete from PED_LANÇ_T;
                                delete from CONTA_T;
                                delete from PED_CONTATO_T;
                                delete from DIVISÃO_T;
                                delete from EMB_T;
                                delete from CARTA_T;
                                delete from EMB_F_T;
                                delete from TIPO_REF_T;
                                delete from FECH_CARGA_T;
                                delete from RAMO_ATIVIDADE_T;
                                delete from LANÇ_T;
                                delete from DEPTO_T;
                                delete from CARTA_CRÉDITO_T;
                                delete from CONFIRM_VENDA_T;
                                delete from PED_ITEM_T;
                                delete from COSIPA_NEGOCIAÇÃO_T;
                                delete from ESCRITÓRIO_T;
                                delete from FECH_T;
                                delete from PRODUTO_T;
                                delete from PARAM_T;
                                delete from EMBALAGEM_T;
                                delete from UNID_QUANTID_T;
                                delete from VIAGEM_ESCALA_T;
                                delete from PED_T;
                                delete from VIAGEM_T;
                                delete from VIA_TRANSPORTE_T;
                                delete from CIA_T;
                                delete from COND_PAG_T;
                                delete from MOEDA_T;
                                delete from PORTO_T;
                                delete from INCOTERM_T;
                                delete from GRUPO_PRODUTO_T;
                                delete from MODALIDADE_FRETE_T;
                                delete from NAVIO_T;
                                delete from PAÍS_T;
                                delete from IDIOMA_T;
                                COMMIT;

                                set transaction read write;

                                log(reglog, 'Transferindo informações para estruturas de transferência.');
                                if full='y' then
                                insert into ESCRITÓRIO_T (ESCRITÓRIO,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select ESCRITÓRIO,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from ESCRITÓRIO where SYS_STATUS <> ' ';

                                insert into MOEDA_T (COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from MOEDA where SYS_STATUS <> ' ';

                                insert into MODALIDADE_FRETE_T (COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from MODALIDADE_FRETE where SYS_STATUS <> ' ';

                                insert into MAPA_T (WORKSHEET,SEQ,EMPRESA,ARQUIVO,TITULO,LINHA,COLUNA,COR,LARGURA,FONT,FONT_NEGRITO,FONT_TAM,ALINHAMENTO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select WORKSHEET,SEQ,EMPRESA,ARQUIVO,TITULO,LINHA,COLUNA,COR,LARGURA,FONT,FONT_NEGRITO,FONT_TAM,ALINHAMENTO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from MAPA where SYS_STATUS <> ' ';

                                insert into LOCAL_RESULT_T (COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from LOCAL_RESULT where SYS_STATUS <> ' ';

                                insert into COSIPA_NEGOCIAÇÃO_T (REF,REF_EXT,DATA_ORD,ALTERA,MÊS_NEG,MÊS_EMB,AGENTE,PRODUTO,TON,PAÍS_DESTINO,PORTO_DESTINO,IMP,OUTRO_DOC,PEÇAS,TRAT_TÉRMICO,TOLER_PROD_LOT_MAX,TOLER_PROD_LOT_MIN,COND_PAG,TERMO_ENTREGA,PREÇO,COMISS_AGENTE,OBS_GERAL,INSP_CLASS,FATURA_LÂMINA,FATURA_OUTRO,EXTERNAL_SURVEY_TYPE,EXTERNAL_SURVEYOR,SURVEY_SIGN_CERTIF,CLASS_ORG,END_USER,HRP,HRC,CRC,PREDAYS,POSDAYS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF,REF_EXT,DATA_ORD,ALTERA,MÊS_NEG,MÊS_EMB,AGENTE,PRODUTO,TON,PAÍS_DESTINO,PORTO_DESTINO,IMP,OUTRO_DOC,PEÇAS,TRAT_TÉRMICO,TOLER_PROD_LOT_MAX,TOLER_PROD_LOT_MIN,COND_PAG,TERMO_ENTREGA,PREÇO,COMISS_AGENTE,OBS_GERAL,INSP_CLASS,FATURA_LÂMINA,FATURA_OUTRO,EXTERNAL_SURVEY_TYPE,EXTERNAL_SURVEYOR,SURVEY_SIGN_CERTIF,CLASS_ORG,END_USER,HRP,HRC,CRC,PREDAYS,POSDAYS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from COSIPA_NEGOCIAÇÃO where SYS_STATUS <> ' ';

                                insert into INCOTERM_T (COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from INCOTERM where SYS_STATUS <> ' ';

                                insert into IDIOMA_T (COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from IDIOMA where SYS_STATUS <> ' ';

                                insert into PARAM_T (GRUPO,PARAM,QUANDO_TEXTO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select GRUPO,PARAM,QUANDO_TEXTO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PARAM where SYS_STATUS <> ' ';

                                insert into ANEXO_T (NOME,SUB_CONTA,SUB_CONTA_REL
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select NOME,SUB_CONTA,SUB_CONTA_REL
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from ANEXO where SYS_STATUS <> ' ';

                                insert into LOG_IMPORT_T (SEQ,NOME,DATA,SITUAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select SEQ,NOME,DATA,SITUAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from LOG_IMPORT where SYS_STATUS <> ' ';

                                insert into EMPRESA_APUR_T (EMPRESA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMPRESA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMPRESA_APUR where SYS_STATUS <> ' ';

                                insert into EMBALAGEM_T (COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMBALAGEM where SYS_STATUS <> ' ';

                                insert into CARTA_CRÉDITO_T (REF,REF_LC,DATA_EMISS,MOEDA,VALOR,PESO,BCO_EMISSOR,BCO_NEGOCIADOR,BCO_AVISADOR,BCO_CONFIRMADOR,BCO_RECEBEDOR,VALIDADE_LC,VALIDADE_EMB,FORM_PAGAMENTO,TOLER_QTD,TOLER_VALOR,APRESENT_DOC,UNID_PESO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF,REF_LC,DATA_EMISS,MOEDA,VALOR,PESO,BCO_EMISSOR,BCO_NEGOCIADOR,BCO_AVISADOR,BCO_CONFIRMADOR,BCO_RECEBEDOR,VALIDADE_LC,VALIDADE_EMB,FORM_PAGAMENTO,TOLER_QTD,TOLER_VALOR,APRESENT_DOC,UNID_PESO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CARTA_CRÉDITO where SYS_STATUS <> ' ';

                                insert into COND_PAG_T (COD,DESCR,PERÍODO,OBS,FIN_COND
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR,PERÍODO,OBS,FIN_COND
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from COND_PAG where SYS_STATUS <> ' ';

                                insert into CONTA_T (EMPRESA,CONTA,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMPRESA,CONTA,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CONTA where SYS_STATUS <> ' ';

                                insert into DOC_T (COD,NOME,OBJETO_VINCULADO,FORMULÁRIO_PARAM
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME,OBJETO_VINCULADO,FORMULÁRIO_PARAM
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DOC where SYS_STATUS <> ' ';

                                insert into DEPTO_T (COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DEPTO where SYS_STATUS <> ' ';

                                insert into GRUPO_PRODUTO_T (COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from GRUPO_PRODUTO where SYS_STATUS <> ' ';

                                insert into RAMO_ATIVIDADE_T (COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from RAMO_ATIVIDADE where SYS_STATUS <> ' ';

                                insert into VIA_TRANSPORTE_T (COD,DESCR,TIPO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR,TIPO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from VIA_TRANSPORTE where SYS_STATUS <> ' ';

                                insert into UNID_QUANTID_T (COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from UNID_QUANTID where SYS_STATUS <> ' ';

                                insert into SUB_CONTA_T (EMPRESA,SUB_CONTA,CONTA,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMPRESA,SUB_CONTA,CONTA,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from SUB_CONTA where SYS_STATUS <> ' ';

                                insert into LANÇ_T (LANÇ,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select LANÇ,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from LANÇ where SYS_STATUS <> ' ';

                                insert into RELACIONADA_T (REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from RELACIONADA where SYS_STATUS <> ' ';

                                insert into PARAM_CSN_T (PROD,PARAM,VALOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PROD,PARAM,VALOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PARAM_CSN where SYS_STATUS <> ' ';

                                insert into PLANILHA_STC_T (WORKSHEET,EMPRESA,ARQUIVO,MAPA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select WORKSHEET,EMPRESA,ARQUIVO,MAPA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PLANILHA_STC where SYS_STATUS <> ' ';

                                insert into PLANILHA_DEF_T (WORKSHEET,SEQ,EMPRESA,ARQUIVO,TIPO,HISTÓRICO,DATAHIST,COLUNACRT,CRT,COLUNADBCR,DÉBITO,CRÉDITO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select WORKSHEET,SEQ,EMPRESA,ARQUIVO,TIPO,HISTÓRICO,DATAHIST,COLUNACRT,CRT,COLUNADBCR,DÉBITO,CRÉDITO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PLANILHA_DEF where SYS_STATUS <> ' ';

                                insert into INCOTERM_LANÇ_T (INCOTERM,LANÇ
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select INCOTERM,LANÇ
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from INCOTERM_LANÇ where SYS_STATUS <> ' ';

                                insert into PRODUTO_T (COD,NOME,GRUPO,NCM,NALADI,NCM_OBS,NALADI_OBS,MEDIDAS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME,GRUPO,NCM,NALADI,NCM_OBS,NALADI_OBS,MEDIDAS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PRODUTO where SYS_STATUS <> ' ';

                                insert into DIVISÃO_T (ESCRITÓRIO,DIVISÃO,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select ESCRITÓRIO,DIVISÃO,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DIVISÃO where SYS_STATUS <> ' ';

                                insert into PAÍS_T (COD,NOME,ABREVIATURA,BANDEIRA_COD,IDIOMA,MSG
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME,ABREVIATURA,BANDEIRA_COD,IDIOMA,MSG
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PAÍS where SYS_STATUS <> ' ';

                                insert into TIPO_REF_T (TIPO,DESCR,DEPTO,ARQUIVO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select TIPO,DESCR,DEPTO,ARQUIVO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from TIPO_REF where SYS_STATUS <> ' ';

                                insert into CIA_T (LOGO,LOGOTIPO,COD,CGC,NOME,ENDEREÇO,BAIRRO,CIDADE,ESTADO,PAÍS,CEP,CAIXA_POSTAL,TELEFONE,FAX,TELEX,E_MAIL,F_COD,MARCAÇÃO,OBS,LOCAL_RESULT
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select LOGO,LOGOTIPO,COD,CGC,NOME,ENDEREÇO,BAIRRO,CIDADE,ESTADO,PAÍS,CEP,CAIXA_POSTAL,TELEFONE,FAX,TELEX,E_MAIL,F_COD,MARCAÇÃO,OBS,LOCAL_RESULT
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CIA where SYS_STATUS <> ' ';

                                insert into PORTO_T (COD,NOME,CIDADE,ESTADO,PAÍS,RESTRIÇÕES,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME,CIDADE,ESTADO,PAÍS,RESTRIÇÕES,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PORTO where SYS_STATUS <> ' ';

                                insert into DIVISÃO_PRODUTO_T (ESCRITÓRIO,DIVISÃO,PROD
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select ESCRITÓRIO,DIVISÃO,PROD
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DIVISÃO_PRODUTO where SYS_STATUS <> ' ';

                                insert into PRODUTO_ESPECIF_T (COD,SEQ,NCM,NALADI,MENOR_ESPESSURA,MAIOR_ESPESSURA,MENOR_LARGURA,MAIOR_LARGURA,MENOR_COMPRIMENTO,MAIOR_COMPRIMENTO,REVESTIMENTO,TÊMPERA,DESCR,DESCR_NALADI
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,SEQ,NCM,NALADI,MENOR_ESPESSURA,MAIOR_ESPESSURA,MENOR_LARGURA,MAIOR_LARGURA,MENOR_COMPRIMENTO,MAIOR_COMPRIMENTO,REVESTIMENTO,TÊMPERA,DESCR,DESCR_NALADI
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PRODUTO_ESPECIF where SYS_STATUS <> ' ';

                                insert into DIVISÃO_TIPO_REF_T (ESCRITÓRIO,DIVISÃO,TIPO_REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select ESCRITÓRIO,DIVISÃO,TIPO_REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DIVISÃO_TIPO_REF where SYS_STATUS <> ' ';

                                insert into NAVIO_T (COD,ANO_CONSTRUÇÃO,NOME,NOME_ANTERIOR,BANDEIRA,NAVIO_TIPO,DWAT,LOA,BEAN,GRT,NRT,CAPACIDADE_GRÃO,CAPACIDADE_FARDO,CALADO_VERÃO,GUINDASTE_NUM,GUINDASTE_DIMENSÃO,ESCOTILHA_NUM,ESCOTILHA_DIMENSÃO,ESCOTILHA_FECHAM_TIPO,EQUIPAMENTO,TANKTOP_STRENGTH,SOCIEDADE_CLASSIFICADORA,CLASSE,OBS,OWNER,CALL_SIGN,N_TANKS,SBT,DOUBLE_HULL,DOUBLE_BOTTOM,INERT_GAS_SYS,HEATING_COILS,IMO_NUM,IMO_TYPE,COATING,CARGO_PUMPS,CUBIC_CAPACITY,CARGO_LINES,CARGO_MANIFOLDS,MAJORS_AP,SUMMER_DRAFT
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,ANO_CONSTRUÇÃO,NOME,NOME_ANTERIOR,BANDEIRA,NAVIO_TIPO,DWAT,LOA,BEAN,GRT,NRT,CAPACIDADE_GRÃO,CAPACIDADE_FARDO,CALADO_VERÃO,GUINDASTE_NUM,GUINDASTE_DIMENSÃO,ESCOTILHA_NUM,ESCOTILHA_DIMENSÃO,ESCOTILHA_FECHAM_TIPO,EQUIPAMENTO,TANKTOP_STRENGTH,SOCIEDADE_CLASSIFICADORA,CLASSE,OBS,OWNER,CALL_SIGN,N_TANKS,SBT,DOUBLE_HULL,DOUBLE_BOTTOM,INERT_GAS_SYS,HEATING_COILS,IMO_NUM,IMO_TYPE,COATING,CARGO_PUMPS,CUBIC_CAPACITY,CARGO_LINES,CARGO_MANIFOLDS,MAJORS_AP,SUMMER_DRAFT
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from NAVIO where SYS_STATUS <> ' ';

                                insert into VIAGEM_T (REF,NAVIO,NAVIO_ÚLTIMO,CORRENTE,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF,NAVIO,NAVIO_ÚLTIMO,CORRENTE,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from VIAGEM where SYS_STATUS <> ' ';

                                insert into PED_T (REF,PED_DATA,MOEDA,TAXA_USD,VIA_TRANSPORTE,CARGA_PORTO,PAÍS_DESTINO,FORNECEDOR,FORNECEDOR_REF,FORNECEDOR_COND_RECEB,EXP,EXP_REF,EXP_COND_RECEB,IMP,IMP_REF,IMP_COND_RECEB,DISTRIBUIDOR,PAGADOR,FRETE_COND,FRETE_PREV_POR_MT,FRETE_PREV_VALOR,EMB_PREV,MARCAÇÃO,OBS,TIPO_VENDA,GRUPO_PROD,SUPERVISOR_VENDA,PRODUÇÃO_PREV,PARIDADE,INSPEÇÃO_EXTERNA,RESPONSÁVEL_INSP_EXT,AGENTE,TAXA_JUROS_FINANCIAM,JUROS_NO_PREÇO,COMISSÃO_PERCENT,COMISSÃO_MT,ADICIONAL_PERCENT,ADICIONAL_MT,INCIDÊNCIA,TIPO,ANEXO,BENEFICIÁRIO,LOCAL_PAG,BANCO,F_QUANTIDADE,F_PREÇO,F_RESULTADO,F_RESULTADO_MT,F_RESULTADO_P,F_COMISSÃO_FORN,F_COMISSÃO_FORN_P,F_PROFIT_SPLIT,F_DELIV_PURCHASE,F_DELIV_SALES,F_PAY_PURCHASE,F_PAY_SALES,F_OBS,FORNECEDOR_COND_VENDA,EXP_COND_VENDA,IMP_COND_VENDA,INSTRUC_INTERNA,PRODUTOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF,PED_DATA,MOEDA,TAXA_USD,VIA_TRANSPORTE,CARGA_PORTO,PAÍS_DESTINO,FORNECEDOR,FORNECEDOR_REF,FORNECEDOR_COND_RECEB,EXP,EXP_REF,EXP_COND_RECEB,IMP,IMP_REF,IMP_COND_RECEB,DISTRIBUIDOR,PAGADOR,FRETE_COND,FRETE_PREV_POR_MT,FRETE_PREV_VALOR,EMB_PREV,MARCAÇÃO,OBS,TIPO_VENDA,GRUPO_PROD,SUPERVISOR_VENDA,PRODUÇÃO_PREV,PARIDADE,INSPEÇÃO_EXTERNA,RESPONSÁVEL_INSP_EXT,AGENTE,TAXA_JUROS_FINANCIAM,JUROS_NO_PREÇO,COMISSÃO_PERCENT,COMISSÃO_MT,ADICIONAL_PERCENT,ADICIONAL_MT,INCIDÊNCIA,TIPO,ANEXO,BENEFICIÁRIO,LOCAL_PAG,BANCO,F_QUANTIDADE,F_PREÇO,F_RESULTADO,F_RESULTADO_MT,F_RESULTADO_P,F_COMISSÃO_FORN,F_COMISSÃO_FORN_P,F_PROFIT_SPLIT,F_DELIV_PURCHASE,F_DELIV_SALES,F_PAY_PURCHASE,F_PAY_SALES,F_OBS,FORNECEDOR_COND_VENDA,EXP_COND_VENDA,IMP_COND_VENDA,INSTRUC_INTERNA,PRODUTOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED where SYS_STATUS <> ' ';

                                insert into CIA_CONTATO_T (CIA_COD,CONTATO_NOME,TELEFONE,FUNÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select CIA_COD,CONTATO_NOME,TELEFONE,FUNÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CIA_CONTATO where SYS_STATUS <> ' ';

                                insert into CARTA_T (REF,EMPRESA,IDIOMA,DOC_DATA,CIA,CONTATO,CIA_SUB,CONTATO_SUB,ASSUNTO,TEXTO,EMISSÃO_DATA,COM_CÓPIA,USUÁRIO,SUPERVISOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF,EMPRESA,IDIOMA,DOC_DATA,CIA,CONTATO,CIA_SUB,CONTATO_SUB,ASSUNTO,TEXTO,EMISSÃO_DATA,COM_CÓPIA,USUÁRIO,SUPERVISOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CARTA where SYS_STATUS <> ' ';

                                insert into FRETE_T (CARGA_PORTO,DESCARGA_PORTO,PROPRIETÁRIO,FRETE_DETALHE,FRETE_UNID,FRETE_VALOR_POR_UNID,COMISSÃO_USD,COMISSÃO_PERCENT,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select CARGA_PORTO,DESCARGA_PORTO,PROPRIETÁRIO,FRETE_DETALHE,FRETE_UNID,FRETE_VALOR_POR_UNID,COMISSÃO_USD,COMISSÃO_PERCENT,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from FRETE where SYS_STATUS <> ' ';

                                insert into CIA_RAMO_ATIVIDADE_T (CIA_COD,RAMO_ATIVIDADE
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select CIA_COD,RAMO_ATIVIDADE
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CIA_RAMO_ATIVIDADE where SYS_STATUS <> ' ';

                                insert into PED_RESULT_T (PED_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,COMPETÊNCIA,CALC,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PED_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,COMPETÊNCIA,CALC,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED_RESULT where SYS_STATUS <> ' ';

                                insert into CONFIRM_VENDA_T (REF,SEQ,EMISSÃO_DATA,EMISSOR,PED_REF,OUTRA_REF,COMPRADOR,USUÁRIO_FINAL,DESTINATÁRIO,ENTREGA,CARGA_PORTO,IDIOMA,DIMENSÃO,PREÇO_DETALHE,ESPECIFICAÇÃO,EMBALAGEM,SEGURO,PAG,OBS,OBS_TERMOS,PRODUTOR,DESCARGA_PORTO,ASSINATURA,DT_REVISÃO,EMPRESA_REL,MOEDA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF,SEQ,EMISSÃO_DATA,EMISSOR,PED_REF,OUTRA_REF,COMPRADOR,USUÁRIO_FINAL,DESTINATÁRIO,ENTREGA,CARGA_PORTO,IDIOMA,DIMENSÃO,PREÇO_DETALHE,ESPECIFICAÇÃO,EMBALAGEM,SEGURO,PAG,OBS,OBS_TERMOS,PRODUTOR,DESCARGA_PORTO,ASSINATURA,DT_REVISÃO,EMPRESA_REL,MOEDA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CONFIRM_VENDA where SYS_STATUS <> ' ';

                                insert into EMB_F_T (PED_REF,SEQ,FATURA,INV_DATA,NAVIO,BL_DATA,COMPETÊNCIA,QUANTIDADE,VALOR,RESULT1,RESULT2,RESULT3,RESULT4,RESULT5,POSIÇÃO,OBSERVAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PED_REF,SEQ,FATURA,INV_DATA,NAVIO,BL_DATA,COMPETÊNCIA,QUANTIDADE,VALOR,RESULT1,RESULT2,RESULT3,RESULT4,RESULT5,POSIÇÃO,OBSERVAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_F where SYS_STATUS <> ' ';

                                insert into PED_CONTATO_T (PED_REF,CIA_COD,CONTATO_NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PED_REF,CIA_COD,CONTATO_NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED_CONTATO where SYS_STATUS <> ' ';

                                insert into EMB_T (CALC_NOMINAL_PED,REF,VIAGEM,FRETE_UNID,FRETE_VALOR,FRETE_POR_MT,FRETE_VALOR_POR_UNID,FRETE_VALOR_TOTAL,FRETE_COND,DATA_EMBARQUE,DATA_EMISSÃO_DOC,CARGA_PORTO,DESCARGA_PORTO,TRANSPORTADOR,MOEDA,IDIOMA,PESO_UNID,PREÇO_UNITÁRIO_UNID,PREÇO_UNID,NEGOCIADOR,EMBARCADOR,EMB_ENDEREÇO,EMB_PAÍS,EMB_COND_VENDA,EMB_COND_PAG,EMB_COMENTÁRIOS,EXP,EXP_ENDEREÇO,EXP_PAÍS,EXP_COND_VENDA,EXP_COND_PAG,EXP_COMENTÁRIOS,EXP_LOGOTIPO,EXP_FAT,IMP,IMP_ENDEREÇO,IMP_PAÍS,IMP_COND_VENDA,IMP_COND_PAG,IMP_COMENTÁRIOS,IMP_LOGOTIPO,IMP_FAT,PAGADOR,PAG_ENDEREÇO,PAG_PAÍS,CONSIGNATÁRIO,CONSIGN_ENDEREÇO,CONSIGN_PAÍS,NOTIFICAR,NOTIFICAR_ENDEREÇO,NOTIFICAR_PAÍS,NUM_BL_DESCR,FAMÍLIA_GENÉRICA,TIPO_DESCR_MERCADORIA,MARCAÇÃO,TOTALIZAÇÃO_EMBALAGEM,CONFIG,EMB_ACORDO,VIA_TRANSPORTE,CARTA_CRED_REF,EMB_DATA,CARTA_CRÉDITO_BANCO_ABRIDOR,CARTA_CRÉDITO_REF,BANCO_AVISADOR,BANCO_CONFIRM,CALC_QTD_PED_UNID,CALC_PESO_LÍQUIDO,CALC_PESO_BRUTO,CALC_QTD_VOL,CALC_EXP_TOT_ITEM,CALC_EXP_TOT_EMB,CALC_EXP_COND_PAG,CALC_EXP_COND_VENDA,CALC_IMP_TOT_ITEM,CALC_IMP_TOT_EMB,CALC_IMP_COND_PAG,CALC_IMP_COND_VENDA,CALC_FRETE_TOTAL,CALC_PEND
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select CALC_NOMINAL_PED,REF,VIAGEM,FRETE_UNID,FRETE_VALOR,FRETE_POR_MT,FRETE_VALOR_POR_UNID,FRETE_VALOR_TOTAL,FRETE_COND,DATA_EMBARQUE,DATA_EMISSÃO_DOC,CARGA_PORTO,DESCARGA_PORTO,TRANSPORTADOR,MOEDA,IDIOMA,PESO_UNID,PREÇO_UNITÁRIO_UNID,PREÇO_UNID,NEGOCIADOR,EMBARCADOR,EMB_ENDEREÇO,EMB_PAÍS,EMB_COND_VENDA,EMB_COND_PAG,EMB_COMENTÁRIOS,EXP,EXP_ENDEREÇO,EXP_PAÍS,EXP_COND_VENDA,EXP_COND_PAG,EXP_COMENTÁRIOS,EXP_LOGOTIPO,EXP_FAT,IMP,IMP_ENDEREÇO,IMP_PAÍS,IMP_COND_VENDA,IMP_COND_PAG,IMP_COMENTÁRIOS,IMP_LOGOTIPO,IMP_FAT,PAGADOR,PAG_ENDEREÇO,PAG_PAÍS,CONSIGNATÁRIO,CONSIGN_ENDEREÇO,CONSIGN_PAÍS,NOTIFICAR,NOTIFICAR_ENDEREÇO,NOTIFICAR_PAÍS,NUM_BL_DESCR,FAMÍLIA_GENÉRICA,TIPO_DESCR_MERCADORIA,MARCAÇÃO,TOTALIZAÇÃO_EMBALAGEM,CONFIG,EMB_ACORDO,VIA_TRANSPORTE,CARTA_CRED_REF,EMB_DATA,CARTA_CRÉDITO_BANCO_ABRIDOR,CARTA_CRÉDITO_REF,BANCO_AVISADOR,BANCO_CONFIRM,CALC_QTD_PED_UNID,CALC_PESO_LÍQUIDO,CALC_PESO_BRUTO,CALC_QTD_VOL,CALC_EXP_TOT_ITEM,CALC_EXP_TOT_EMB,CALC_EXP_COND_PAG,CALC_EXP_COND_VENDA,CALC_IMP_TOT_ITEM,CALC_IMP_TOT_EMB,CALC_IMP_COND_PAG,CALC_IMP_COND_VENDA,CALC_FRETE_TOTAL,CALC_PEND
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB where SYS_STATUS <> ' ';

                                insert into PED_ITEM_T (PED_REF,ITEM,USUÁRIO_FINAL,USUÁRIO_REF,PED_UNID,NOMINAL_PED_UNID,TOTAL_FECH,TOTAL_EMB,TOLERÂNCIA_MIN,TOLERÂNCIA_MAX,PROD,DESCARGA_PORTO,EMBALAGEM,EMBALAGEM_PESO_MIN,EMBALAGEM_PESO_MAX,PREÇO_UNITÁRIO_FORNECEDOR,PREÇO_UNITÁRIO_EXP,PREÇO_UNITÁRIO_IMP,ESPESSURA_TIPO,ESPESSURA_MM,LARGURA_MM,COMPRIMENTO_MM,ESPESSURA_POL,LARGURA_POL,COMPRIMENTO_POL,NCM,NALADI,P,LOTE,OV,NE_ITEM,NE_ENVIO,TBN,FSE,PO,BL_CODE,USO_FINAL,DIÂMETRO_INTERNO,DIÂMETRO_EXTERNO,PESO_POR_FOLHA,AÇO_TIPO,REVESTIMENTO,TÊMPERA,ACABAMENTO,NORMA_TOLERÂNCIA,NORMA_PRODUÇÃO,BORDAS,OLEAMENTO,TRAT_TÉRMICO,TRAT_QUÍMICO,LA,LE,LÍNGUA,PROD_DESCR,COMPOSIÇÃO_QUÍMICA,MARCAÇÃO_PRODUÇÃO,COMENTÁRIO,PED_USINA_DATA,PED_USINA_ID,PED_USINA_CONFIRM,LAYDAY_INÍCIO,LAYDAY_FINAL,QTD_VOL,PESO_LÍQUIDO,PESO_BRUTO,FECH_REQUISITADO,FECH_NOTIFICADO,CANCEL_DATA,CANCEL_MOTIVO,SEGURO_PERCENT,CUR_PERCENT,SUPERFÍCIE,DIAMET_INT_MAX_TOLER,DIAMET_INT_MIM_TOLER,TQ,CERTIF_QUALIDADE,RABO_PEIXE,RABO_PEIXE_MAX,LÍNGUA_MAX,MARCAÇÃO_ESPECIAL_DOC,OBS,MARCAÇÃO,NOMINAL_MT,DIMENSÃO,TOL_CSN,RECOZIDO_CSN,TOL_ESPESSURA_CSN,TOL_LARGURA_CSN,TOL_COMPRIMENTO_CSN,MARCAÇÃO_DIF_CSN,FACE_PESADA_CSN,APLAINAMENTO_CSN,PASSIVAÇÃO_CSN,ACABAMENTO_CSN,FAIXA_PESO_CSN,SOLDAS_CSN,NUM_SOLDAS_CSN,MARCAÇÃO_SOLDA_CSN,VERNIZ_DOURADO_CSN,POSIÇÃO_FOLHA_PALLET_CSN,RUGOSIDADE_CSN,ESQUADRIA_CSN,NUM_CONSULTA_CSN,TOLERÂNCIA_PADRÃO_CSN,MARCAÇOES_ADICIONAIS_CSN
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PED_REF,ITEM,USUÁRIO_FINAL,USUÁRIO_REF,PED_UNID,NOMINAL_PED_UNID,TOTAL_FECH,TOTAL_EMB,TOLERÂNCIA_MIN,TOLERÂNCIA_MAX,PROD,DESCARGA_PORTO,EMBALAGEM,EMBALAGEM_PESO_MIN,EMBALAGEM_PESO_MAX,PREÇO_UNITÁRIO_FORNECEDOR,PREÇO_UNITÁRIO_EXP,PREÇO_UNITÁRIO_IMP,ESPESSURA_TIPO,ESPESSURA_MM,LARGURA_MM,COMPRIMENTO_MM,ESPESSURA_POL,LARGURA_POL,COMPRIMENTO_POL,NCM,NALADI,P,LOTE,OV,NE_ITEM,NE_ENVIO,TBN,FSE,PO,BL_CODE,USO_FINAL,DIÂMETRO_INTERNO,DIÂMETRO_EXTERNO,PESO_POR_FOLHA,AÇO_TIPO,REVESTIMENTO,TÊMPERA,ACABAMENTO,NORMA_TOLERÂNCIA,NORMA_PRODUÇÃO,BORDAS,OLEAMENTO,TRAT_TÉRMICO,TRAT_QUÍMICO,LA,LE,LÍNGUA,PROD_DESCR,COMPOSIÇÃO_QUÍMICA,MARCAÇÃO_PRODUÇÃO,COMENTÁRIO,PED_USINA_DATA,PED_USINA_ID,PED_USINA_CONFIRM,LAYDAY_INÍCIO,LAYDAY_FINAL,QTD_VOL,PESO_LÍQUIDO,PESO_BRUTO,FECH_REQUISITADO,FECH_NOTIFICADO,CANCEL_DATA,CANCEL_MOTIVO,SEGURO_PERCENT,CUR_PERCENT,SUPERFÍCIE,DIAMET_INT_MAX_TOLER,DIAMET_INT_MIM_TOLER,TQ,CERTIF_QUALIDADE,RABO_PEIXE,RABO_PEIXE_MAX,LÍNGUA_MAX,MARCAÇÃO_ESPECIAL_DOC,OBS,MARCAÇÃO,NOMINAL_MT,DIMENSÃO,TOL_CSN,RECOZIDO_CSN,TOL_ESPESSURA_CSN,TOL_LARGURA_CSN,TOL_COMPRIMENTO_CSN,MARCAÇÃO_DIF_CSN,FACE_PESADA_CSN,APLAINAMENTO_CSN,PASSIVAÇÃO_CSN,ACABAMENTO_CSN,FAIXA_PESO_CSN,SOLDAS_CSN,NUM_SOLDAS_CSN,MARCAÇÃO_SOLDA_CSN,VERNIZ_DOURADO_CSN,POSIÇÃO_FOLHA_PALLET_CSN,RUGOSIDADE_CSN,ESQUADRIA_CSN,NUM_CONSULTA_CSN,TOLERÂNCIA_PADRÃO_CSN,MARCAÇOES_ADICIONAIS_CSN
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED_ITEM where SYS_STATUS <> ' ';

                                insert into PED_LANÇ_T (PED_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,EXP,IMP,BENEFICIÁRIO,COMISSÃO_MODALIDADE,INSTRUÇÃO_REMESSA,EXP_CALC,IMP_CALC,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PED_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,EXP,IMP,BENEFICIÁRIO,COMISSÃO_MODALIDADE,INSTRUÇÃO_REMESSA,EXP_CALC,IMP_CALC,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED_LANÇ where SYS_STATUS <> ' ';

                                insert into VIAGEM_ESCALA_T (VIAGEM_REF,ESCALA,PORTO,ETA,ETS,ATA,ATS,LD,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select VIAGEM_REF,ESCALA,PORTO,ETA,ETS,ATA,ATS,LD,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from VIAGEM_ESCALA where SYS_STATUS <> ' ';

                                insert into BL_T (VIAGEM_REF,SEQ,BL_NUM,BL_DATA,EMB_REF,MSG
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select VIAGEM_REF,SEQ,BL_NUM,BL_DATA,EMB_REF,MSG
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from BL where SYS_STATUS <> ' ';

                                insert into CONFIRM_VENDA_ITEM_T (CONFIRM_VENDA_REF,SEQ,ITEM,DESCR,DIMENSÃO,QTD,UNID,PREÇO,MOEDA,QUALIDADE,PREÇO_C
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select CONFIRM_VENDA_REF,SEQ,ITEM,DESCR,DIMENSÃO,QTD,UNID,PREÇO,MOEDA,QUALIDADE,PREÇO_C
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CONFIRM_VENDA_ITEM where SYS_STATUS <> ' ';

                                insert into EMB_DOC_REL_T (EMB_REF,DOC,EMB_REL
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,DOC,EMB_REL
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_DOC_REL where SYS_STATUS <> ' ';

                                insert into EMB_FAMÍLIA_T (EMB_REF,SEQ,FAMÍLIA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,SEQ,FAMÍLIA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_FAMÍLIA where SYS_STATUS <> ' ';

                                insert into EMB_FAMÍLIA_GENÉRICA_T (EMB_REF,SEQ,FAMÍLIA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,SEQ,FAMÍLIA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_FAMÍLIA_GENÉRICA where SYS_STATUS <> ' ';

                                insert into EMB_LANÇ_T (EMB_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,EXP,IMP,UNID,NA_FATURA,BENEFICIÁRIO,COMISSÃO_MODALIDADE,INSTRUÇÃO_REMESSA,EXP_CALC,IMP_CALC
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,EXP,IMP,UNID,NA_FATURA,BENEFICIÁRIO,COMISSÃO_MODALIDADE,INSTRUÇÃO_REMESSA,EXP_CALC,IMP_CALC
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_LANÇ where SYS_STATUS <> ' ';

                                insert into EMB_MENSAGEM_T (EMB_REF,SEQ,MSG,EXP,IMP,DOC_ALADI,DOC_BORDERÔ_I,DOC_BORDERÔ_P,DOC_CÂMARA_COMÉRCIO,DOC_CARTA_I,DOC_CARTA_P,DOC_CONHECIM_ROD,DOC_FATURA,DOC_FATURA_JUROS,DOC_FECH_CAMBIO,DOC_FIRJAN,DOC_MERCOSUL,DOC_MERCOSUL_BOLIVIA,DOC_MERCOSUL_CHILE,DOC_PLIST_WEIG_CERT,DOC_SAQUE_JUR_2_VIAS,DOC_SAQUE_JUR_3_VIAS,DOC_SAQUE_2_VIAS,DOC_SAQUE_3_VIAS,DOC_ALADI_CERTIF_ORIGEM,DOC_BL,DOC_CÂM_COM_CERTIF_O,DOC_CAPA,DOC_CONHECIM_RODOVIÁRIO,DOC_CHECK_LIST,DOC_CARTA_DEOP_INGLÊS,DOC_CARTA_DEOP_PORTUG,DOC_FECHAM_CÂMBIO,DOC_FIRJAN_CERTIF_ORIGEM,DOC_FORM_A,DOC_INSTR_PAG,DOC_MERCOSUL_CERTIF_ORIGEM,DOC_PACKING_LIST,DOC_SAQUE,DOC_WEIGHT_CERTIFICATE,DOC_SAQUE_JUROS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,SEQ,MSG,EXP,IMP,DOC_ALADI,DOC_BORDERÔ_I,DOC_BORDERÔ_P,DOC_CÂMARA_COMÉRCIO,DOC_CARTA_I,DOC_CARTA_P,DOC_CONHECIM_ROD,DOC_FATURA,DOC_FATURA_JUROS,DOC_FECH_CAMBIO,DOC_FIRJAN,DOC_MERCOSUL,DOC_MERCOSUL_BOLIVIA,DOC_MERCOSUL_CHILE,DOC_PLIST_WEIG_CERT,DOC_SAQUE_JUR_2_VIAS,DOC_SAQUE_JUR_3_VIAS,DOC_SAQUE_2_VIAS,DOC_SAQUE_3_VIAS,DOC_ALADI_CERTIF_ORIGEM,DOC_BL,DOC_CÂM_COM_CERTIF_O,DOC_CAPA,DOC_CONHECIM_RODOVIÁRIO,DOC_CHECK_LIST,DOC_CARTA_DEOP_INGLÊS,DOC_CARTA_DEOP_PORTUG,DOC_FECHAM_CÂMBIO,DOC_FIRJAN_CERTIF_ORIGEM,DOC_FORM_A,DOC_INSTR_PAG,DOC_MERCOSUL_CERTIF_ORIGEM,DOC_PACKING_LIST,DOC_SAQUE,DOC_WEIGHT_CERTIFICATE,DOC_SAQUE_JUROS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_MENSAGEM where SYS_STATUS <> ' ';

                                insert into EMB_RE_T (EMB_REF,RE,EMISSÃO_DATA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,RE,EMISSÃO_DATA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_RE where SYS_STATUS <> ' ';

                                insert into EMB_SD_T (EMB_REF,SD,AVERBAÇÃO_DATA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,SD,AVERBAÇÃO_DATA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_SD where SYS_STATUS <> ' ';

                                insert into EMB_TOTALIZA_T (EMB_REF,SEQ,LANÇ,EXP,IMP,EXP_DESCR,IMP_DESCR,EXP_CALC,IMP_CALC
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,SEQ,LANÇ,EXP,IMP,EXP_DESCR,IMP_DESCR,EXP_CALC,IMP_CALC
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_TOTALIZA where SYS_STATUS <> ' ';

                                insert into FECH_T (REF,FECH_DATA,MOEDA,VIAGEM_REF,CARGA_PORTO_ESCALA,DESCARGA_PORTO_ESCALA,CONTRATANTE,CORRETOR,PROPRIETÁRIO,NEGOCIANTE,FRETE_DETALHE,FRETE_UNID,FRETE_VALOR,FRETE_VALOR_POR_UNID,FRETE_PAG_DETALHE,COMISSÃO_FRETE,COMISSÃO_BASE,COMISSÃO_PERCENT,CIA_PAGADORA,CARGA_AGENTE,CARGA_ESTIVA,CARGA_ESTIVA_CUSTO,CARGA_DETALHE,CARGA_OBS,DESCARGA_AGENTE,DESCARGA_ESTIVA,DESCARGA_ESTIVA_CUSTO,DESCARGA_DETALHE,DESCARGA_OBS,DETENÇÃO,DEMORA,OBS,DESPACHANTE
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF,FECH_DATA,MOEDA,VIAGEM_REF,CARGA_PORTO_ESCALA,DESCARGA_PORTO_ESCALA,CONTRATANTE,CORRETOR,PROPRIETÁRIO,NEGOCIANTE,FRETE_DETALHE,FRETE_UNID,FRETE_VALOR,FRETE_VALOR_POR_UNID,FRETE_PAG_DETALHE,COMISSÃO_FRETE,COMISSÃO_BASE,COMISSÃO_PERCENT,CIA_PAGADORA,CARGA_AGENTE,CARGA_ESTIVA,CARGA_ESTIVA_CUSTO,CARGA_DETALHE,CARGA_OBS,DESCARGA_AGENTE,DESCARGA_ESTIVA,DESCARGA_ESTIVA_CUSTO,DESCARGA_DETALHE,DESCARGA_OBS,DETENÇÃO,DEMORA,OBS,DESPACHANTE
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from FECH where SYS_STATUS <> ' ';

                                insert into RESULT_T (PED_REF,EMB_SEQ,SEQ,INV_DATA,RESULT1,RESULT2,RESULT3,RESULT4,RESULT5,DATA1,DATA2,DATA3,DATA4,DATA5,POSIÇÃO,OBSERVAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PED_REF,EMB_SEQ,SEQ,INV_DATA,RESULT1,RESULT2,RESULT3,RESULT4,RESULT5,DATA1,DATA2,DATA3,DATA4,DATA5,POSIÇÃO,OBSERVAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from RESULT where SYS_STATUS <> ' ';

                                insert into CARTA_FECH_T (CARTA_REF,FECH_REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select CARTA_REF,FECH_REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CARTA_FECH where SYS_STATUS <> ' ';

                                insert into BL_CARGA_T (PED_REF,PED_ITEM,VIAGEM_REF,BL_SEQ,FECH_REF,QTD_PED_UNID,QTD_VOL,PESO_LÍQUIDO,PESO_BRUTO,EMB_DATA,EMB_REF,EMB_SEQ,FAMÍLIA_GENÉRICA,FAMÍLIA,DESCR         ,EMBALAGEM,NCM,NALADI,EXP_PREÇO_UNIT,IMP_PREÇO_UNIT,CALC_EXP_EMB,CALC_EXP_FOB,CALC_IMP_EMB,CALC_IMP_FOB,NOMINAL_PED_UNID
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PED_REF,PED_ITEM,VIAGEM_REF,BL_SEQ,FECH_REF,QTD_PED_UNID,QTD_VOL,PESO_LÍQUIDO,PESO_BRUTO,EMB_DATA,EMB_REF,EMB_SEQ,FAMÍLIA_GENÉRICA,FAMÍLIA,DESCR         ,EMBALAGEM,NCM,NALADI,EXP_PREÇO_UNIT,IMP_PREÇO_UNIT,CALC_EXP_EMB,CALC_EXP_FOB,CALC_IMP_EMB,CALC_IMP_FOB,NOMINAL_PED_UNID
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from BL_CARGA where SYS_STATUS <> ' ';

                                insert into FECH_CARGA_T (FECH_REF,PED_REF,PED_ITEM,QTD_PED_UNID,QTD_FRETE_UNID,QTD_TOTAL,NOMEAÇÃO_DATA,ACEITAÇÃO_FORNECEDOR_DATA,CANCEL_DATA,CANCEL_MOTIVO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select FECH_REF,PED_REF,PED_ITEM,QTD_PED_UNID,QTD_FRETE_UNID,QTD_TOTAL,NOMEAÇÃO_DATA,ACEITAÇÃO_FORNECEDOR_DATA,CANCEL_DATA,CANCEL_MOTIVO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from FECH_CARGA where SYS_STATUS <> ' ';

                                else
                                insert into ESCRITÓRIO_T (ESCRITÓRIO,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select ESCRITÓRIO,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from ESCRITÓRIO where SYS_STATUS <> ' ';

                                insert into MOEDA_T (COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from MOEDA where SYS_STATUS <> ' ';

                                insert into MODALIDADE_FRETE_T (COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from MODALIDADE_FRETE where SYS_STATUS <> ' ';

                                insert into MAPA_T (WORKSHEET,SEQ,EMPRESA,ARQUIVO,TITULO,LINHA,COLUNA,COR,LARGURA,FONT,FONT_NEGRITO,FONT_TAM,ALINHAMENTO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select WORKSHEET,SEQ,EMPRESA,ARQUIVO,TITULO,LINHA,COLUNA,COR,LARGURA,FONT,FONT_NEGRITO,FONT_TAM,ALINHAMENTO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from MAPA where SYS_STATUS <> ' ';

                                insert into LOCAL_RESULT_T (COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from LOCAL_RESULT where SYS_STATUS <> ' ';

                                insert into COSIPA_NEGOCIAÇÃO_T (REF,REF_EXT,DATA_ORD,ALTERA,MÊS_NEG,MÊS_EMB,AGENTE,PRODUTO,TON,PAÍS_DESTINO,PORTO_DESTINO,IMP,OUTRO_DOC,PEÇAS,TRAT_TÉRMICO,TOLER_PROD_LOT_MAX,TOLER_PROD_LOT_MIN,COND_PAG,TERMO_ENTREGA,PREÇO,COMISS_AGENTE,OBS_GERAL,INSP_CLASS,FATURA_LÂMINA,FATURA_OUTRO,EXTERNAL_SURVEY_TYPE,EXTERNAL_SURVEYOR,SURVEY_SIGN_CERTIF,CLASS_ORG,END_USER,HRP,HRC,CRC,PREDAYS,POSDAYS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF,REF_EXT,DATA_ORD,ALTERA,MÊS_NEG,MÊS_EMB,AGENTE,PRODUTO,TON,PAÍS_DESTINO,PORTO_DESTINO,IMP,OUTRO_DOC,PEÇAS,TRAT_TÉRMICO,TOLER_PROD_LOT_MAX,TOLER_PROD_LOT_MIN,COND_PAG,TERMO_ENTREGA,PREÇO,COMISS_AGENTE,OBS_GERAL,INSP_CLASS,FATURA_LÂMINA,FATURA_OUTRO,EXTERNAL_SURVEY_TYPE,EXTERNAL_SURVEYOR,SURVEY_SIGN_CERTIF,CLASS_ORG,END_USER,HRP,HRC,CRC,PREDAYS,POSDAYS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from COSIPA_NEGOCIAÇÃO where SYS_STATUS <> ' ';

                                insert into INCOTERM_T (COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from INCOTERM where SYS_STATUS <> ' ';

                                insert into IDIOMA_T (COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from IDIOMA where SYS_STATUS <> ' ';

                                insert into PARAM_T (GRUPO,PARAM,QUANDO_TEXTO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select GRUPO,PARAM,QUANDO_TEXTO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PARAM where SYS_STATUS <> ' ';

                                insert into ANEXO_T (NOME,SUB_CONTA,SUB_CONTA_REL
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select NOME,SUB_CONTA,SUB_CONTA_REL
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from ANEXO where SYS_STATUS <> ' ';

                                insert into LOG_IMPORT_T (SEQ,NOME,DATA,SITUAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select SEQ,NOME,DATA,SITUAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from LOG_IMPORT where SYS_STATUS <> ' ';

                                insert into EMPRESA_APUR_T (EMPRESA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMPRESA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMPRESA_APUR where SYS_STATUS <> ' ';

                                insert into EMBALAGEM_T (COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMBALAGEM where SYS_STATUS <> ' ';

                                insert into CARTA_CRÉDITO_T (REF,REF_LC,DATA_EMISS,MOEDA,VALOR,PESO,BCO_EMISSOR,BCO_NEGOCIADOR,BCO_AVISADOR,BCO_CONFIRMADOR,BCO_RECEBEDOR,VALIDADE_LC,VALIDADE_EMB,FORM_PAGAMENTO,TOLER_QTD,TOLER_VALOR,APRESENT_DOC,UNID_PESO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF,REF_LC,DATA_EMISS,MOEDA,VALOR,PESO,BCO_EMISSOR,BCO_NEGOCIADOR,BCO_AVISADOR,BCO_CONFIRMADOR,BCO_RECEBEDOR,VALIDADE_LC,VALIDADE_EMB,FORM_PAGAMENTO,TOLER_QTD,TOLER_VALOR,APRESENT_DOC,UNID_PESO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CARTA_CRÉDITO where SYS_STATUS <> ' ';

                                insert into COND_PAG_T (COD,DESCR,PERÍODO,OBS,FIN_COND
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR,PERÍODO,OBS,FIN_COND
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from COND_PAG where SYS_STATUS <> ' ';

                                insert into CONTA_T (EMPRESA,CONTA,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMPRESA,CONTA,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CONTA where SYS_STATUS <> ' ';

                                insert into DOC_T (COD,NOME,OBJETO_VINCULADO,FORMULÁRIO_PARAM
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME,OBJETO_VINCULADO,FORMULÁRIO_PARAM
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DOC where SYS_STATUS <> ' ';

                                insert into DEPTO_T (COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DEPTO where SYS_STATUS <> ' ';

                                insert into GRUPO_PRODUTO_T (COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from GRUPO_PRODUTO where SYS_STATUS <> ' ';

                                insert into RAMO_ATIVIDADE_T (COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from RAMO_ATIVIDADE where SYS_STATUS <> ' ';

                                insert into VIA_TRANSPORTE_T (COD,DESCR,TIPO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,DESCR,TIPO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from VIA_TRANSPORTE where SYS_STATUS <> ' ';

                                insert into UNID_QUANTID_T (COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from UNID_QUANTID where SYS_STATUS <> ' ';

                                insert into SUB_CONTA_T (EMPRESA,SUB_CONTA,CONTA,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMPRESA,SUB_CONTA,CONTA,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from SUB_CONTA where SYS_STATUS <> ' ';

                                insert into LANÇ_T (LANÇ,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select LANÇ,NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from LANÇ where SYS_STATUS <> ' ';

                                insert into RELACIONADA_T (REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from RELACIONADA where SYS_STATUS <> ' ';

                                insert into PARAM_CSN_T (PROD,PARAM,VALOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PROD,PARAM,VALOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PARAM_CSN where SYS_STATUS <> ' ';

                                insert into PLANILHA_STC_T (WORKSHEET,EMPRESA,ARQUIVO,MAPA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select WORKSHEET,EMPRESA,ARQUIVO,MAPA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PLANILHA_STC where SYS_STATUS <> ' ';

                                insert into PLANILHA_DEF_T (WORKSHEET,SEQ,EMPRESA,ARQUIVO,TIPO,HISTÓRICO,DATAHIST,COLUNACRT,CRT,COLUNADBCR,DÉBITO,CRÉDITO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select WORKSHEET,SEQ,EMPRESA,ARQUIVO,TIPO,HISTÓRICO,DATAHIST,COLUNACRT,CRT,COLUNADBCR,DÉBITO,CRÉDITO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PLANILHA_DEF where SYS_STATUS <> ' ';

                                insert into INCOTERM_LANÇ_T (INCOTERM,LANÇ
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select INCOTERM,LANÇ
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from INCOTERM_LANÇ where SYS_STATUS <> ' ';

                                insert into PRODUTO_T (COD,NOME,GRUPO,NCM,NALADI,NCM_OBS,NALADI_OBS,MEDIDAS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME,GRUPO,NCM,NALADI,NCM_OBS,NALADI_OBS,MEDIDAS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PRODUTO where SYS_STATUS <> ' ';

                                insert into DIVISÃO_T (ESCRITÓRIO,DIVISÃO,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select ESCRITÓRIO,DIVISÃO,DESCR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DIVISÃO where SYS_STATUS <> ' ';

                                insert into PAÍS_T (COD,NOME,ABREVIATURA,BANDEIRA_COD,IDIOMA,MSG
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME,ABREVIATURA,BANDEIRA_COD,IDIOMA,MSG
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PAÍS where SYS_STATUS <> ' ';

                                insert into TIPO_REF_T (TIPO,DESCR,DEPTO,ARQUIVO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select TIPO,DESCR,DEPTO,ARQUIVO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from TIPO_REF where SYS_STATUS <> ' ';

                                insert into CIA_T (LOGO,LOGOTIPO,COD,CGC,NOME,ENDEREÇO,BAIRRO,CIDADE,ESTADO,PAÍS,CEP,CAIXA_POSTAL,TELEFONE,FAX,TELEX,E_MAIL,F_COD,MARCAÇÃO,OBS,LOCAL_RESULT
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select LOGO,LOGOTIPO,COD,CGC,NOME,ENDEREÇO,BAIRRO,CIDADE,ESTADO,PAÍS,CEP,CAIXA_POSTAL,TELEFONE,FAX,TELEX,E_MAIL,F_COD,MARCAÇÃO,OBS,LOCAL_RESULT
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CIA where SYS_STATUS <> ' ';

                                insert into PORTO_T (COD,NOME,CIDADE,ESTADO,PAÍS,RESTRIÇÕES,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,NOME,CIDADE,ESTADO,PAÍS,RESTRIÇÕES,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PORTO where SYS_STATUS <> ' ';

                                insert into DIVISÃO_PRODUTO_T (ESCRITÓRIO,DIVISÃO,PROD
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select ESCRITÓRIO,DIVISÃO,PROD
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DIVISÃO_PRODUTO where SYS_STATUS <> ' ';

                                insert into PRODUTO_ESPECIF_T (COD,SEQ,NCM,NALADI,MENOR_ESPESSURA,MAIOR_ESPESSURA,MENOR_LARGURA,MAIOR_LARGURA,MENOR_COMPRIMENTO,MAIOR_COMPRIMENTO,REVESTIMENTO,TÊMPERA,DESCR,DESCR_NALADI
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,SEQ,NCM,NALADI,MENOR_ESPESSURA,MAIOR_ESPESSURA,MENOR_LARGURA,MAIOR_LARGURA,MENOR_COMPRIMENTO,MAIOR_COMPRIMENTO,REVESTIMENTO,TÊMPERA,DESCR,DESCR_NALADI
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PRODUTO_ESPECIF where SYS_STATUS <> ' ';

                                insert into DIVISÃO_TIPO_REF_T (ESCRITÓRIO,DIVISÃO,TIPO_REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select ESCRITÓRIO,DIVISÃO,TIPO_REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DIVISÃO_TIPO_REF where SYS_STATUS <> ' ';

                                insert into NAVIO_T (COD,ANO_CONSTRUÇÃO,NOME,NOME_ANTERIOR,BANDEIRA,NAVIO_TIPO,DWAT,LOA,BEAN,GRT,NRT,CAPACIDADE_GRÃO,CAPACIDADE_FARDO,CALADO_VERÃO,GUINDASTE_NUM,GUINDASTE_DIMENSÃO,ESCOTILHA_NUM,ESCOTILHA_DIMENSÃO,ESCOTILHA_FECHAM_TIPO,EQUIPAMENTO,TANKTOP_STRENGTH,SOCIEDADE_CLASSIFICADORA,CLASSE,OBS,OWNER,CALL_SIGN,N_TANKS,SBT,DOUBLE_HULL,DOUBLE_BOTTOM,INERT_GAS_SYS,HEATING_COILS,IMO_NUM,IMO_TYPE,COATING,CARGO_PUMPS,CUBIC_CAPACITY,CARGO_LINES,CARGO_MANIFOLDS,MAJORS_AP,SUMMER_DRAFT
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select COD,ANO_CONSTRUÇÃO,NOME,NOME_ANTERIOR,BANDEIRA,NAVIO_TIPO,DWAT,LOA,BEAN,GRT,NRT,CAPACIDADE_GRÃO,CAPACIDADE_FARDO,CALADO_VERÃO,GUINDASTE_NUM,GUINDASTE_DIMENSÃO,ESCOTILHA_NUM,ESCOTILHA_DIMENSÃO,ESCOTILHA_FECHAM_TIPO,EQUIPAMENTO,TANKTOP_STRENGTH,SOCIEDADE_CLASSIFICADORA,CLASSE,OBS,OWNER,CALL_SIGN,N_TANKS,SBT,DOUBLE_HULL,DOUBLE_BOTTOM,INERT_GAS_SYS,HEATING_COILS,IMO_NUM,IMO_TYPE,COATING,CARGO_PUMPS,CUBIC_CAPACITY,CARGO_LINES,CARGO_MANIFOLDS,MAJORS_AP,SUMMER_DRAFT
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from NAVIO where SYS_STATUS <> ' ';

                                insert into VIAGEM_T (REF,NAVIO,NAVIO_ÚLTIMO,CORRENTE,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF,NAVIO,NAVIO_ÚLTIMO,CORRENTE,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from VIAGEM where SYS_STATUS <> ' ';

                                insert into PED_T (REF,PED_DATA,MOEDA,TAXA_USD,VIA_TRANSPORTE,CARGA_PORTO,PAÍS_DESTINO,FORNECEDOR,FORNECEDOR_REF,FORNECEDOR_COND_RECEB,EXP,EXP_REF,EXP_COND_RECEB,IMP,IMP_REF,IMP_COND_RECEB,DISTRIBUIDOR,PAGADOR,FRETE_COND,FRETE_PREV_POR_MT,FRETE_PREV_VALOR,EMB_PREV,MARCAÇÃO,OBS,TIPO_VENDA,GRUPO_PROD,SUPERVISOR_VENDA,PRODUÇÃO_PREV,PARIDADE,INSPEÇÃO_EXTERNA,RESPONSÁVEL_INSP_EXT,AGENTE,TAXA_JUROS_FINANCIAM,JUROS_NO_PREÇO,COMISSÃO_PERCENT,COMISSÃO_MT,ADICIONAL_PERCENT,ADICIONAL_MT,INCIDÊNCIA,TIPO,ANEXO,BENEFICIÁRIO,LOCAL_PAG,BANCO,F_QUANTIDADE,F_PREÇO,F_RESULTADO,F_RESULTADO_MT,F_RESULTADO_P,F_COMISSÃO_FORN,F_COMISSÃO_FORN_P,F_PROFIT_SPLIT,F_DELIV_PURCHASE,F_DELIV_SALES,F_PAY_PURCHASE,F_PAY_SALES,F_OBS,FORNECEDOR_COND_VENDA,EXP_COND_VENDA,IMP_COND_VENDA,INSTRUC_INTERNA,PRODUTOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF,PED_DATA,MOEDA,TAXA_USD,VIA_TRANSPORTE,CARGA_PORTO,PAÍS_DESTINO,FORNECEDOR,FORNECEDOR_REF,FORNECEDOR_COND_RECEB,EXP,EXP_REF,EXP_COND_RECEB,IMP,IMP_REF,IMP_COND_RECEB,DISTRIBUIDOR,PAGADOR,FRETE_COND,FRETE_PREV_POR_MT,FRETE_PREV_VALOR,EMB_PREV,MARCAÇÃO,OBS,TIPO_VENDA,GRUPO_PROD,SUPERVISOR_VENDA,PRODUÇÃO_PREV,PARIDADE,INSPEÇÃO_EXTERNA,RESPONSÁVEL_INSP_EXT,AGENTE,TAXA_JUROS_FINANCIAM,JUROS_NO_PREÇO,COMISSÃO_PERCENT,COMISSÃO_MT,ADICIONAL_PERCENT,ADICIONAL_MT,INCIDÊNCIA,TIPO,ANEXO,BENEFICIÁRIO,LOCAL_PAG,BANCO,F_QUANTIDADE,F_PREÇO,F_RESULTADO,F_RESULTADO_MT,F_RESULTADO_P,F_COMISSÃO_FORN,F_COMISSÃO_FORN_P,F_PROFIT_SPLIT,F_DELIV_PURCHASE,F_DELIV_SALES,F_PAY_PURCHASE,F_PAY_SALES,F_OBS,FORNECEDOR_COND_VENDA,EXP_COND_VENDA,IMP_COND_VENDA,INSTRUC_INTERNA,PRODUTOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED where SYS_STATUS <> ' ';

                                insert into CIA_CONTATO_T (CIA_COD,CONTATO_NOME,TELEFONE,FUNÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select CIA_COD,CONTATO_NOME,TELEFONE,FUNÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CIA_CONTATO where SYS_STATUS <> ' ';

                                insert into CARTA_T (REF,EMPRESA,IDIOMA,DOC_DATA,CIA,CONTATO,CIA_SUB,CONTATO_SUB,ASSUNTO,TEXTO,EMISSÃO_DATA,COM_CÓPIA,USUÁRIO,SUPERVISOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF,EMPRESA,IDIOMA,DOC_DATA,CIA,CONTATO,CIA_SUB,CONTATO_SUB,ASSUNTO,TEXTO,EMISSÃO_DATA,COM_CÓPIA,USUÁRIO,SUPERVISOR
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CARTA where SYS_STATUS <> ' ';

                                insert into FRETE_T (CARGA_PORTO,DESCARGA_PORTO,PROPRIETÁRIO,FRETE_DETALHE,FRETE_UNID,FRETE_VALOR_POR_UNID,COMISSÃO_USD,COMISSÃO_PERCENT,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select CARGA_PORTO,DESCARGA_PORTO,PROPRIETÁRIO,FRETE_DETALHE,FRETE_UNID,FRETE_VALOR_POR_UNID,COMISSÃO_USD,COMISSÃO_PERCENT,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from FRETE where SYS_STATUS <> ' ';

                                insert into CIA_RAMO_ATIVIDADE_T (CIA_COD,RAMO_ATIVIDADE
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select CIA_COD,RAMO_ATIVIDADE
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CIA_RAMO_ATIVIDADE where SYS_STATUS <> ' ';

                                insert into PED_RESULT_T (PED_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,COMPETÊNCIA,CALC,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PED_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,COMPETÊNCIA,CALC,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED_RESULT where SYS_STATUS <> ' ';

                                insert into CONFIRM_VENDA_T (REF,SEQ,EMISSÃO_DATA,EMISSOR,PED_REF,OUTRA_REF,COMPRADOR,USUÁRIO_FINAL,DESTINATÁRIO,ENTREGA,CARGA_PORTO,IDIOMA,DIMENSÃO,PREÇO_DETALHE,ESPECIFICAÇÃO,EMBALAGEM,SEGURO,PAG,OBS,OBS_TERMOS,PRODUTOR,DESCARGA_PORTO,ASSINATURA,DT_REVISÃO,EMPRESA_REL,MOEDA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF,SEQ,EMISSÃO_DATA,EMISSOR,PED_REF,OUTRA_REF,COMPRADOR,USUÁRIO_FINAL,DESTINATÁRIO,ENTREGA,CARGA_PORTO,IDIOMA,DIMENSÃO,PREÇO_DETALHE,ESPECIFICAÇÃO,EMBALAGEM,SEGURO,PAG,OBS,OBS_TERMOS,PRODUTOR,DESCARGA_PORTO,ASSINATURA,DT_REVISÃO,EMPRESA_REL,MOEDA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CONFIRM_VENDA where SYS_STATUS <> ' ';

                                insert into EMB_F_T (PED_REF,SEQ,FATURA,INV_DATA,NAVIO,BL_DATA,COMPETÊNCIA,QUANTIDADE,VALOR,RESULT1,RESULT2,RESULT3,RESULT4,RESULT5,POSIÇÃO,OBSERVAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PED_REF,SEQ,FATURA,INV_DATA,NAVIO,BL_DATA,COMPETÊNCIA,QUANTIDADE,VALOR,RESULT1,RESULT2,RESULT3,RESULT4,RESULT5,POSIÇÃO,OBSERVAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_F where SYS_STATUS <> ' ';

                                insert into PED_CONTATO_T (PED_REF,CIA_COD,CONTATO_NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PED_REF,CIA_COD,CONTATO_NOME
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED_CONTATO where SYS_STATUS <> ' ';

                                insert into EMB_T (CALC_NOMINAL_PED,REF,VIAGEM,FRETE_UNID,FRETE_VALOR,FRETE_POR_MT,FRETE_VALOR_POR_UNID,FRETE_VALOR_TOTAL,FRETE_COND,DATA_EMBARQUE,DATA_EMISSÃO_DOC,CARGA_PORTO,DESCARGA_PORTO,TRANSPORTADOR,MOEDA,IDIOMA,PESO_UNID,PREÇO_UNITÁRIO_UNID,PREÇO_UNID,NEGOCIADOR,EMBARCADOR,EMB_ENDEREÇO,EMB_PAÍS,EMB_COND_VENDA,EMB_COND_PAG,EMB_COMENTÁRIOS,EXP,EXP_ENDEREÇO,EXP_PAÍS,EXP_COND_VENDA,EXP_COND_PAG,EXP_COMENTÁRIOS,EXP_LOGOTIPO,EXP_FAT,IMP,IMP_ENDEREÇO,IMP_PAÍS,IMP_COND_VENDA,IMP_COND_PAG,IMP_COMENTÁRIOS,IMP_LOGOTIPO,IMP_FAT,PAGADOR,PAG_ENDEREÇO,PAG_PAÍS,CONSIGNATÁRIO,CONSIGN_ENDEREÇO,CONSIGN_PAÍS,NOTIFICAR,NOTIFICAR_ENDEREÇO,NOTIFICAR_PAÍS,NUM_BL_DESCR,FAMÍLIA_GENÉRICA,TIPO_DESCR_MERCADORIA,MARCAÇÃO,TOTALIZAÇÃO_EMBALAGEM,CONFIG,EMB_ACORDO,VIA_TRANSPORTE,CARTA_CRED_REF,EMB_DATA,CARTA_CRÉDITO_BANCO_ABRIDOR,CARTA_CRÉDITO_REF,BANCO_AVISADOR,BANCO_CONFIRM,CALC_QTD_PED_UNID,CALC_PESO_LÍQUIDO,CALC_PESO_BRUTO,CALC_QTD_VOL,CALC_EXP_TOT_ITEM,CALC_EXP_TOT_EMB,CALC_EXP_COND_PAG,CALC_EXP_COND_VENDA,CALC_IMP_TOT_ITEM,CALC_IMP_TOT_EMB,CALC_IMP_COND_PAG,CALC_IMP_COND_VENDA,CALC_FRETE_TOTAL,CALC_PEND
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select CALC_NOMINAL_PED,REF,VIAGEM,FRETE_UNID,FRETE_VALOR,FRETE_POR_MT,FRETE_VALOR_POR_UNID,FRETE_VALOR_TOTAL,FRETE_COND,DATA_EMBARQUE,DATA_EMISSÃO_DOC,CARGA_PORTO,DESCARGA_PORTO,TRANSPORTADOR,MOEDA,IDIOMA,PESO_UNID,PREÇO_UNITÁRIO_UNID,PREÇO_UNID,NEGOCIADOR,EMBARCADOR,EMB_ENDEREÇO,EMB_PAÍS,EMB_COND_VENDA,EMB_COND_PAG,EMB_COMENTÁRIOS,EXP,EXP_ENDEREÇO,EXP_PAÍS,EXP_COND_VENDA,EXP_COND_PAG,EXP_COMENTÁRIOS,EXP_LOGOTIPO,EXP_FAT,IMP,IMP_ENDEREÇO,IMP_PAÍS,IMP_COND_VENDA,IMP_COND_PAG,IMP_COMENTÁRIOS,IMP_LOGOTIPO,IMP_FAT,PAGADOR,PAG_ENDEREÇO,PAG_PAÍS,CONSIGNATÁRIO,CONSIGN_ENDEREÇO,CONSIGN_PAÍS,NOTIFICAR,NOTIFICAR_ENDEREÇO,NOTIFICAR_PAÍS,NUM_BL_DESCR,FAMÍLIA_GENÉRICA,TIPO_DESCR_MERCADORIA,MARCAÇÃO,TOTALIZAÇÃO_EMBALAGEM,CONFIG,EMB_ACORDO,VIA_TRANSPORTE,CARTA_CRED_REF,EMB_DATA,CARTA_CRÉDITO_BANCO_ABRIDOR,CARTA_CRÉDITO_REF,BANCO_AVISADOR,BANCO_CONFIRM,CALC_QTD_PED_UNID,CALC_PESO_LÍQUIDO,CALC_PESO_BRUTO,CALC_QTD_VOL,CALC_EXP_TOT_ITEM,CALC_EXP_TOT_EMB,CALC_EXP_COND_PAG,CALC_EXP_COND_VENDA,CALC_IMP_TOT_ITEM,CALC_IMP_TOT_EMB,CALC_IMP_COND_PAG,CALC_IMP_COND_VENDA,CALC_FRETE_TOTAL,CALC_PEND
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB where SYS_STATUS <> ' ';

                                insert into PED_ITEM_T (PED_REF,ITEM,USUÁRIO_FINAL,USUÁRIO_REF,PED_UNID,NOMINAL_PED_UNID,TOTAL_FECH,TOTAL_EMB,TOLERÂNCIA_MIN,TOLERÂNCIA_MAX,PROD,DESCARGA_PORTO,EMBALAGEM,EMBALAGEM_PESO_MIN,EMBALAGEM_PESO_MAX,PREÇO_UNITÁRIO_FORNECEDOR,PREÇO_UNITÁRIO_EXP,PREÇO_UNITÁRIO_IMP,ESPESSURA_TIPO,ESPESSURA_MM,LARGURA_MM,COMPRIMENTO_MM,ESPESSURA_POL,LARGURA_POL,COMPRIMENTO_POL,NCM,NALADI,P,LOTE,OV,NE_ITEM,NE_ENVIO,TBN,FSE,PO,BL_CODE,USO_FINAL,DIÂMETRO_INTERNO,DIÂMETRO_EXTERNO,PESO_POR_FOLHA,AÇO_TIPO,REVESTIMENTO,TÊMPERA,ACABAMENTO,NORMA_TOLERÂNCIA,NORMA_PRODUÇÃO,BORDAS,OLEAMENTO,TRAT_TÉRMICO,TRAT_QUÍMICO,LA,LE,LÍNGUA,PROD_DESCR,COMPOSIÇÃO_QUÍMICA,MARCAÇÃO_PRODUÇÃO,COMENTÁRIO,PED_USINA_DATA,PED_USINA_ID,PED_USINA_CONFIRM,LAYDAY_INÍCIO,LAYDAY_FINAL,QTD_VOL,PESO_LÍQUIDO,PESO_BRUTO,FECH_REQUISITADO,FECH_NOTIFICADO,CANCEL_DATA,CANCEL_MOTIVO,SEGURO_PERCENT,CUR_PERCENT,SUPERFÍCIE,DIAMET_INT_MAX_TOLER,DIAMET_INT_MIM_TOLER,TQ,CERTIF_QUALIDADE,RABO_PEIXE,RABO_PEIXE_MAX,LÍNGUA_MAX,MARCAÇÃO_ESPECIAL_DOC,OBS,MARCAÇÃO,NOMINAL_MT,DIMENSÃO,TOL_CSN,RECOZIDO_CSN,TOL_ESPESSURA_CSN,TOL_LARGURA_CSN,TOL_COMPRIMENTO_CSN,MARCAÇÃO_DIF_CSN,FACE_PESADA_CSN,APLAINAMENTO_CSN,PASSIVAÇÃO_CSN,ACABAMENTO_CSN,FAIXA_PESO_CSN,SOLDAS_CSN,NUM_SOLDAS_CSN,MARCAÇÃO_SOLDA_CSN,VERNIZ_DOURADO_CSN,POSIÇÃO_FOLHA_PALLET_CSN,RUGOSIDADE_CSN,ESQUADRIA_CSN,NUM_CONSULTA_CSN,TOLERÂNCIA_PADRÃO_CSN,MARCAÇOES_ADICIONAIS_CSN
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PED_REF,ITEM,USUÁRIO_FINAL,USUÁRIO_REF,PED_UNID,NOMINAL_PED_UNID,TOTAL_FECH,TOTAL_EMB,TOLERÂNCIA_MIN,TOLERÂNCIA_MAX,PROD,DESCARGA_PORTO,EMBALAGEM,EMBALAGEM_PESO_MIN,EMBALAGEM_PESO_MAX,PREÇO_UNITÁRIO_FORNECEDOR,PREÇO_UNITÁRIO_EXP,PREÇO_UNITÁRIO_IMP,ESPESSURA_TIPO,ESPESSURA_MM,LARGURA_MM,COMPRIMENTO_MM,ESPESSURA_POL,LARGURA_POL,COMPRIMENTO_POL,NCM,NALADI,P,LOTE,OV,NE_ITEM,NE_ENVIO,TBN,FSE,PO,BL_CODE,USO_FINAL,DIÂMETRO_INTERNO,DIÂMETRO_EXTERNO,PESO_POR_FOLHA,AÇO_TIPO,REVESTIMENTO,TÊMPERA,ACABAMENTO,NORMA_TOLERÂNCIA,NORMA_PRODUÇÃO,BORDAS,OLEAMENTO,TRAT_TÉRMICO,TRAT_QUÍMICO,LA,LE,LÍNGUA,PROD_DESCR,COMPOSIÇÃO_QUÍMICA,MARCAÇÃO_PRODUÇÃO,COMENTÁRIO,PED_USINA_DATA,PED_USINA_ID,PED_USINA_CONFIRM,LAYDAY_INÍCIO,LAYDAY_FINAL,QTD_VOL,PESO_LÍQUIDO,PESO_BRUTO,FECH_REQUISITADO,FECH_NOTIFICADO,CANCEL_DATA,CANCEL_MOTIVO,SEGURO_PERCENT,CUR_PERCENT,SUPERFÍCIE,DIAMET_INT_MAX_TOLER,DIAMET_INT_MIM_TOLER,TQ,CERTIF_QUALIDADE,RABO_PEIXE,RABO_PEIXE_MAX,LÍNGUA_MAX,MARCAÇÃO_ESPECIAL_DOC,OBS,MARCAÇÃO,NOMINAL_MT,DIMENSÃO,TOL_CSN,RECOZIDO_CSN,TOL_ESPESSURA_CSN,TOL_LARGURA_CSN,TOL_COMPRIMENTO_CSN,MARCAÇÃO_DIF_CSN,FACE_PESADA_CSN,APLAINAMENTO_CSN,PASSIVAÇÃO_CSN,ACABAMENTO_CSN,FAIXA_PESO_CSN,SOLDAS_CSN,NUM_SOLDAS_CSN,MARCAÇÃO_SOLDA_CSN,VERNIZ_DOURADO_CSN,POSIÇÃO_FOLHA_PALLET_CSN,RUGOSIDADE_CSN,ESQUADRIA_CSN,NUM_CONSULTA_CSN,TOLERÂNCIA_PADRÃO_CSN,MARCAÇOES_ADICIONAIS_CSN
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED_ITEM where SYS_STATUS <> ' ';

                                insert into PED_LANÇ_T (PED_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,EXP,IMP,BENEFICIÁRIO,COMISSÃO_MODALIDADE,INSTRUÇÃO_REMESSA,EXP_CALC,IMP_CALC,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PED_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,EXP,IMP,BENEFICIÁRIO,COMISSÃO_MODALIDADE,INSTRUÇÃO_REMESSA,EXP_CALC,IMP_CALC,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PED_LANÇ where SYS_STATUS <> ' ';

                                insert into VIAGEM_ESCALA_T (VIAGEM_REF,ESCALA,PORTO,ETA,ETS,ATA,ATS,LD,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select VIAGEM_REF,ESCALA,PORTO,ETA,ETS,ATA,ATS,LD,OBS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from VIAGEM_ESCALA where SYS_STATUS <> ' ';

                                insert into BL_T (VIAGEM_REF,SEQ,BL_NUM,BL_DATA,EMB_REF,MSG
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select VIAGEM_REF,SEQ,BL_NUM,BL_DATA,EMB_REF,MSG
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from BL where SYS_STATUS <> ' ';

                                insert into CONFIRM_VENDA_ITEM_T (CONFIRM_VENDA_REF,SEQ,ITEM,DESCR,DIMENSÃO,QTD,UNID,PREÇO,MOEDA,QUALIDADE,PREÇO_C
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select CONFIRM_VENDA_REF,SEQ,ITEM,DESCR,DIMENSÃO,QTD,UNID,PREÇO,MOEDA,QUALIDADE,PREÇO_C
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CONFIRM_VENDA_ITEM where SYS_STATUS <> ' ';

                                insert into EMB_DOC_REL_T (EMB_REF,DOC,EMB_REL
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,DOC,EMB_REL
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_DOC_REL where SYS_STATUS <> ' ';

                                insert into EMB_FAMÍLIA_T (EMB_REF,SEQ,FAMÍLIA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,SEQ,FAMÍLIA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_FAMÍLIA where SYS_STATUS <> ' ';

                                insert into EMB_FAMÍLIA_GENÉRICA_T (EMB_REF,SEQ,FAMÍLIA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,SEQ,FAMÍLIA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_FAMÍLIA_GENÉRICA where SYS_STATUS <> ' ';

                                insert into EMB_LANÇ_T (EMB_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,EXP,IMP,UNID,NA_FATURA,BENEFICIÁRIO,COMISSÃO_MODALIDADE,INSTRUÇÃO_REMESSA,EXP_CALC,IMP_CALC
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,SEQ,LANÇ,VALOR,VALOR_POR_MT,TOTAL_PERCENT,TOTAL_TIPO,EXP,IMP,UNID,NA_FATURA,BENEFICIÁRIO,COMISSÃO_MODALIDADE,INSTRUÇÃO_REMESSA,EXP_CALC,IMP_CALC
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_LANÇ where SYS_STATUS <> ' ';

                                insert into EMB_MENSAGEM_T (EMB_REF,SEQ,MSG,EXP,IMP,DOC_ALADI,DOC_BORDERÔ_I,DOC_BORDERÔ_P,DOC_CÂMARA_COMÉRCIO,DOC_CARTA_I,DOC_CARTA_P,DOC_CONHECIM_ROD,DOC_FATURA,DOC_FATURA_JUROS,DOC_FECH_CAMBIO,DOC_FIRJAN,DOC_MERCOSUL,DOC_MERCOSUL_BOLIVIA,DOC_MERCOSUL_CHILE,DOC_PLIST_WEIG_CERT,DOC_SAQUE_JUR_2_VIAS,DOC_SAQUE_JUR_3_VIAS,DOC_SAQUE_2_VIAS,DOC_SAQUE_3_VIAS,DOC_ALADI_CERTIF_ORIGEM,DOC_BL,DOC_CÂM_COM_CERTIF_O,DOC_CAPA,DOC_CONHECIM_RODOVIÁRIO,DOC_CHECK_LIST,DOC_CARTA_DEOP_INGLÊS,DOC_CARTA_DEOP_PORTUG,DOC_FECHAM_CÂMBIO,DOC_FIRJAN_CERTIF_ORIGEM,DOC_FORM_A,DOC_INSTR_PAG,DOC_MERCOSUL_CERTIF_ORIGEM,DOC_PACKING_LIST,DOC_SAQUE,DOC_WEIGHT_CERTIFICATE,DOC_SAQUE_JUROS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,SEQ,MSG,EXP,IMP,DOC_ALADI,DOC_BORDERÔ_I,DOC_BORDERÔ_P,DOC_CÂMARA_COMÉRCIO,DOC_CARTA_I,DOC_CARTA_P,DOC_CONHECIM_ROD,DOC_FATURA,DOC_FATURA_JUROS,DOC_FECH_CAMBIO,DOC_FIRJAN,DOC_MERCOSUL,DOC_MERCOSUL_BOLIVIA,DOC_MERCOSUL_CHILE,DOC_PLIST_WEIG_CERT,DOC_SAQUE_JUR_2_VIAS,DOC_SAQUE_JUR_3_VIAS,DOC_SAQUE_2_VIAS,DOC_SAQUE_3_VIAS,DOC_ALADI_CERTIF_ORIGEM,DOC_BL,DOC_CÂM_COM_CERTIF_O,DOC_CAPA,DOC_CONHECIM_RODOVIÁRIO,DOC_CHECK_LIST,DOC_CARTA_DEOP_INGLÊS,DOC_CARTA_DEOP_PORTUG,DOC_FECHAM_CÂMBIO,DOC_FIRJAN_CERTIF_ORIGEM,DOC_FORM_A,DOC_INSTR_PAG,DOC_MERCOSUL_CERTIF_ORIGEM,DOC_PACKING_LIST,DOC_SAQUE,DOC_WEIGHT_CERTIFICATE,DOC_SAQUE_JUROS
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_MENSAGEM where SYS_STATUS <> ' ';

                                insert into EMB_RE_T (EMB_REF,RE,EMISSÃO_DATA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,RE,EMISSÃO_DATA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_RE where SYS_STATUS <> ' ';

                                insert into EMB_SD_T (EMB_REF,SD,AVERBAÇÃO_DATA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,SD,AVERBAÇÃO_DATA
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_SD where SYS_STATUS <> ' ';

                                insert into EMB_TOTALIZA_T (EMB_REF,SEQ,LANÇ,EXP,IMP,EXP_DESCR,IMP_DESCR,EXP_CALC,IMP_CALC
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select EMB_REF,SEQ,LANÇ,EXP,IMP,EXP_DESCR,IMP_DESCR,EXP_CALC,IMP_CALC
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMB_TOTALIZA where SYS_STATUS <> ' ';

                                insert into FECH_T (REF,FECH_DATA,MOEDA,VIAGEM_REF,CARGA_PORTO_ESCALA,DESCARGA_PORTO_ESCALA,CONTRATANTE,CORRETOR,PROPRIETÁRIO,NEGOCIANTE,FRETE_DETALHE,FRETE_UNID,FRETE_VALOR,FRETE_VALOR_POR_UNID,FRETE_PAG_DETALHE,COMISSÃO_FRETE,COMISSÃO_BASE,COMISSÃO_PERCENT,CIA_PAGADORA,CARGA_AGENTE,CARGA_ESTIVA,CARGA_ESTIVA_CUSTO,CARGA_DETALHE,CARGA_OBS,DESCARGA_AGENTE,DESCARGA_ESTIVA,DESCARGA_ESTIVA_CUSTO,DESCARGA_DETALHE,DESCARGA_OBS,DETENÇÃO,DEMORA,OBS,DESPACHANTE
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select REF,FECH_DATA,MOEDA,VIAGEM_REF,CARGA_PORTO_ESCALA,DESCARGA_PORTO_ESCALA,CONTRATANTE,CORRETOR,PROPRIETÁRIO,NEGOCIANTE,FRETE_DETALHE,FRETE_UNID,FRETE_VALOR,FRETE_VALOR_POR_UNID,FRETE_PAG_DETALHE,COMISSÃO_FRETE,COMISSÃO_BASE,COMISSÃO_PERCENT,CIA_PAGADORA,CARGA_AGENTE,CARGA_ESTIVA,CARGA_ESTIVA_CUSTO,CARGA_DETALHE,CARGA_OBS,DESCARGA_AGENTE,DESCARGA_ESTIVA,DESCARGA_ESTIVA_CUSTO,DESCARGA_DETALHE,DESCARGA_OBS,DETENÇÃO,DEMORA,OBS,DESPACHANTE
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from FECH where SYS_STATUS <> ' ';

                                insert into RESULT_T (PED_REF,EMB_SEQ,SEQ,INV_DATA,RESULT1,RESULT2,RESULT3,RESULT4,RESULT5,DATA1,DATA2,DATA3,DATA4,DATA5,POSIÇÃO,OBSERVAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PED_REF,EMB_SEQ,SEQ,INV_DATA,RESULT1,RESULT2,RESULT3,RESULT4,RESULT5,DATA1,DATA2,DATA3,DATA4,DATA5,POSIÇÃO,OBSERVAÇÃO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from RESULT where SYS_STATUS <> ' ';

                                insert into CARTA_FECH_T (CARTA_REF,FECH_REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select CARTA_REF,FECH_REF
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CARTA_FECH where SYS_STATUS <> ' ';

                                insert into BL_CARGA_T (PED_REF,PED_ITEM,VIAGEM_REF,BL_SEQ,FECH_REF,QTD_PED_UNID,QTD_VOL,PESO_LÍQUIDO,PESO_BRUTO,EMB_DATA,EMB_REF,EMB_SEQ,FAMÍLIA_GENÉRICA,FAMÍLIA,DESCR         ,EMBALAGEM,NCM,NALADI,EXP_PREÇO_UNIT,IMP_PREÇO_UNIT,CALC_EXP_EMB,CALC_EXP_FOB,CALC_IMP_EMB,CALC_IMP_FOB,NOMINAL_PED_UNID
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select PED_REF,PED_ITEM,VIAGEM_REF,BL_SEQ,FECH_REF,QTD_PED_UNID,QTD_VOL,PESO_LÍQUIDO,PESO_BRUTO,EMB_DATA,EMB_REF,EMB_SEQ,FAMÍLIA_GENÉRICA,FAMÍLIA,DESCR         ,EMBALAGEM,NCM,NALADI,EXP_PREÇO_UNIT,IMP_PREÇO_UNIT,CALC_EXP_EMB,CALC_EXP_FOB,CALC_IMP_EMB,CALC_IMP_FOB,NOMINAL_PED_UNID
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from BL_CARGA where SYS_STATUS <> ' ';

                                insert into FECH_CARGA_T (FECH_REF,PED_REF,PED_ITEM,QTD_PED_UNID,QTD_FRETE_UNID,QTD_TOTAL,NOMEAÇÃO_DATA,ACEITAÇÃO_FORNECEDOR_DATA,CANCEL_DATA,CANCEL_MOTIVO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                select FECH_REF,PED_REF,PED_ITEM,QTD_PED_UNID,QTD_FRETE_UNID,QTD_TOTAL,NOMEAÇÃO_DATA,ACEITAÇÃO_FORNECEDOR_DATA,CANCEL_DATA,CANCEL_MOTIVO
,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from FECH_CARGA where SYS_STATUS <> ' ';

                                end if;

                                COMMIT;
                        end if;


                        log(reglog, 'Exportando informações para o pacote.');
                        err := DBMS_CX.DOSSHELL('EXP ' || localpac || '/' || senhalocal || '@' || servicolocal || ' FILE=' || diretorio || '\' || arqpac || '.PAC LOG=' || diretorio || '\TRANSF.TMP PARFILE=' || diretorio || '\' || 'TRANSF.PAR');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando exp.exe');
                        end if;
                        loga(reglog, diretorio, 'TRANSF.TMP');

                        log(reglog, 'Compactando o pacote.');
                        err := DBMS_CX.DOSSHELL('arj32.exe a -t -y ' || diretorio || '\' || arqpac || '.ARJ ' || diretorio || '\' || arqpac || '.PAC>' || diretorio || '\TRANSF.TMP');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando arj32.exe');
                        end if;
                        loga(reglog, diretorio, 'TRANSF.TMP');

                        log(reglog, 'Envia arquivo para consolidador.');

                        if full = 'n' then
                                log(reglog, 'Gravando todas as alterações realizadas.');
                                update SYS_LOCALID set PACOTE = mod(numpac + 1, 10000), MOMENTO = SYSDATE, MODELO = 0 where NOME = localpac;
                                    modelopac := 0;
                                    modelorec := 0;
                                COMMIT;
                        end if;

                        log(reglog, 'Excluindo arquivos temporários.');
                        err := DBMS_CX.DOSSHELL('DEL ' || diretorio || '\' || arqpac || '.PAC>' || diretorio || '\TRANSF.TMP');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando DEL');
                        end if;
                        loga(reglog, diretorio, 'TRANSF.TMP');

                        err := DBMS_CX.DOSSHELL('DEL ' || diretorio || '\TRANSF.TMP');

                        log(reglog, 'Término de criação do pacote ' || diretorio || '\' || arqpac || '.ARJ');
                        utl_file.fclose(reglog);

                        if full = 'n' then
                                if not (email is null or servsmtp is null) then

                                        err := sendmail('cxsp@xxxxxxxxxx.com.br', email, 'CIEX - Transferência do pacote ' ||
                                                diretorio || '\' || arqpac || '.ARJ', servsmtp, NULL, diretorio || '\' ||
                                                arqpac || '.ARJ;D:\CXSP_T\' || arqpac || '.LOG');


                                end if;
                        end if;
                end;

        exception
                when others then
                        ROLLBACK;

                        if modelorec <> -1 then
                                update SYS_LOCALID set MODELO = modelorec, MOMENTO = SYSDATE where NOME = localpac;
                                COMMIT;
                        end if;

                        log(reglog, 'Erro durante a criação do pacote.');
                        log(reglog, SQLERRM);
                        if utl_file.is_open(reglog) then
                                utl_file.fclose(reglog);
                        end if;

                        if not (email is null or servsmtp is null) then
                                err := sendmail('cxsp@xxxxxxxxxx.com.br', email, 'CIEX - Rotina de criação de pacote', servsmtp, 'Erro durante a criação do pacote.', diretorio || '\' || arqpac || '.LOG');
                        end if;
                        raise_application_error ( -20000, 'erro na função de criação de pacote -> ' || SQLERRM );
        end;




        procedure trata_pacote(localpac_remoto in varchar2, diretorio in varchar2, senhalocal in varchar2, servicolocal in varchar2, email in varchar2 default '', servsmtp in varchar2 default '', usuariopop3 in varchar2 default '', senhapop3 in varchar2 default '', servpop3 in varchar2 default '') is
        sqlcursor integer;
        err integer;
        sql_notfound boolean;

        numpac integer;
    arqpac varchar2(100);
        localpac varchar2(100);
        numpac_remoto integer;
        arqpac_remoto varchar2(100);
        reglog utl_file.file_type;
        modelopac SYS_LOCALID.MODELO%type;
        momento_modelopac SYS_LOCALID.MOMENTO%type;
        modelorec SYS_LOCALID.MODELO%type := -1;

        origem_usuario char(20);
        origem_local char(20);
        origem_momento date;
        destino_usuario char(20);
        destino_local char(20);
        destino_momento date;


        begin
                begin
                        <<recebe_novamente>> -- executa até terminar os pacotes pendentes

                        select NOME, MODELO, MOMENTO into localpac, modelopac, momento_modelopac from SYS_LOCALID where CORRENTE = -1;

                        -- se modelo for 2, significa que existe outra tarefa utilizando o buffer de transferência
                         if modelopac = 2 then
                                if (SYSDATE()-momento_modelopac) > (1/24*6) then
                                        if not (email is null or servsmtp is null) then
                                                err := sendmail('cxsp@xxxxxxxxxx.com.br', email, 'CIEX - Rotina de tratamento de pacote', servsmtp, 'O sistema não está conseguindo tratar pacotes devido às estruturas temporárias estarem bloqueadas por mais de 6 horas (modelo = 2).');
                                        end if;
                                        raise_application_error(-20000, 'erro na função de tratamento de pacote -> bloqueio de estruturas temporárias já alcança 6 horas');
                                else
                                        return;
                                end if;
                        end if;

                        -- garante exclusividade
                        modelorec := modelopac;
                        update SYS_LOCALID set MODELO = 2, MOMENTO = SYSDATE where NOME = localpac;
                        modelopac := 2;
                        COMMIT;

                        -- tenta receber arquivos no caso de pop3 configurado
                        if not (usuariopop3 is null or servpop3 is null) then
                                log(reglog, 'Buscando arquivos na caixa de ' || usuariopop3 || '.');
                                err := dosshell('getmail.exe -u ' || usuariopop3 || ' -pw ' || senhapop3 || ' -s ' || servpop3 || ' -delete -xtract -plain -dir ' || diretorio || '\temp');
                                err := dosshell('erase ' || diretorio || '\temp\msg*.txt');
                                err := dosshell('erase ' || diretorio || '\temp\extract*.out');
                                err := dosshell('move ' || diretorio || '\temp\cx??????.arj ' || diretorio);
                                err := dosshell('copy ' || diretorio || '\temp\cx??????.log+' || diretorio || '\cx??????.log ' || diretorio || '\cx??????.L__');
                                err := dosshell('erase ' || diretorio || '\temp\cx??????.log');
                                err := dosshell('erase ' || diretorio || '\cx??????.log');
                                err := dosshell('ren ' || diretorio || '\cx??????.L__ CX??????.LOG');
                        end if;

                        -- define nome do arquivo de pacote remoto
                        begin
                                reglog := utl_file.fopen(diretorio, localpac_remoto || '.ARJ', 'r');
                                utl_file.fclose(reglog);
                                arqpac_remoto := localpac_remoto;
                        exception
                                when others then
                                        select PACOTE_REC into numpac_remoto from SYS_LOCALID where NOME = localpac_remoto;
                                        arqpac_remoto := localpac_remoto || to_char(numpac_remoto, 'FM0000');
                        end;

                        reglog := utl_file.fopen(diretorio, arqpac_remoto || '.LOG', 'a');

                        log(reglog, '');
                        log(reglog, '----------------------------------------------------------------------');
                        log(reglog, 'Tentativa de descompactação do pacote previsto ' || diretorio || '\' || arqpac_remoto || '.ARJ');

                        if modelorec = 1 then
                                raise_application_error(-20000, 'identificada criação de pacote não finalizada corretamente no modelo da localidade ' || localpac || ' (' || to_char(modelopac) || ')');
                        end if;

                        err := DBMS_CX.DOSSHELL('arj32.exe e -y -ht' || diretorio || '\ ' || diretorio || '\' || arqpac_remoto || '.ARJ ' || arqpac_remoto || '.PAC ' || '>' || diretorio || '\RECEB.TMP');

                        if err = 6 then
                                log(reglog, 'Pacote não encontrado.');
                                err := DBMS_CX.DOSSHELL('DEL ' || diretorio || '\RECEB.TMP');
                                utl_file.fclose(reglog);
                                update SYS_LOCALID set MODELO = 0, MOMENTO = SYSDATE where NOME = localpac;
                                modelopac := 0;
                                modelorec := 0;
                                commit;
                                return;
                        elsif err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando arj32.exe');
                        end if;
                        loga(reglog, diretorio, 'RECEB.TMP');

                        log(reglog, 'Apagando registros de estrutura de transferência.');
                        delete from EMB_FAMÍLIA_GENÉRICA_T;
                        delete from DOC_T;
                        delete from EMB_FAMÍLIA_T;
                        delete from EMB_RE_T;
                        delete from BL_T;
                        delete from BL_CARGA_T;
                        delete from DIVISÃO_PRODUTO_T;
                        delete from EMB_TOTALIZA_T;
                        delete from DIVISÃO_TIPO_REF_T;
                        delete from EMB_DOC_REL_T;
                        delete from MAPA_T;
                        delete from INCOTERM_LANÇ_T;
                        delete from LOCAL_RESULT_T;
                        delete from EMB_SD_T;
                        delete from PARAM_CSN_T;
                        delete from EMB_LANÇ_T;
                        delete from EMB_MENSAGEM_T;
                        delete from ANEXO_T;
                        delete from EMPRESA_APUR_T;
                        delete from LOG_IMPORT_T;
                        delete from CIA_RAMO_ATIVIDADE_T;
                        delete from CARTA_FECH_T;
                        delete from SYS_DELETE_T;
                        delete from SUB_CONTA_T;
                        delete from RESULT_T;
                        delete from RELACIONADA_T;
                        delete from CIA_CONTATO_T;
                        delete from PRODUTO_ESPECIF_T;
                        delete from FRETE_T;
                        delete from CONFIRM_VENDA_ITEM_T;
                        delete from PLANILHA_STC_T;
                        delete from PLANILHA_DEF_T;
                        delete from PED_RESULT_T;
                        delete from PED_LANÇ_T;
                        delete from CONTA_T;
                        delete from PED_CONTATO_T;
                        delete from DIVISÃO_T;
                        delete from EMB_T;
                        delete from CARTA_T;
                        delete from EMB_F_T;
                        delete from TIPO_REF_T;
                        delete from FECH_CARGA_T;
                        delete from RAMO_ATIVIDADE_T;
                        delete from LANÇ_T;
                        delete from DEPTO_T;
                        delete from CARTA_CRÉDITO_T;
                        delete from CONFIRM_VENDA_T;
                        delete from PED_ITEM_T;
                        delete from COSIPA_NEGOCIAÇÃO_T;
                        delete from ESCRITÓRIO_T;
                        delete from FECH_T;
                        delete from PRODUTO_T;
                        delete from PARAM_T;
                        delete from EMBALAGEM_T;
                        delete from UNID_QUANTID_T;
                        delete from VIAGEM_ESCALA_T;
                        delete from PED_T;
                        delete from VIAGEM_T;
                        delete from VIA_TRANSPORTE_T;
                        delete from CIA_T;
                        delete from COND_PAG_T;
                        delete from MOEDA_T;
                        delete from PORTO_T;
                        delete from INCOTERM_T;
                        delete from GRUPO_PRODUTO_T;
                        delete from MODALIDADE_FRETE_T;
                        delete from NAVIO_T;
                        delete from PAÍS_T;
                        delete from IDIOMA_T;
                        COMMIT;

                        log(reglog, 'Importando informações do pacote.');
                        err := DBMS_CX.DOSSHELL('imp.exe ' || localpac || '/' || senhalocal || '@' || servicolocal || ' FILE=' || diretorio || '\' || arqpac_remoto || '.PAC' || ' LOG=' || diretorio || '\RECEB.TMP PARFILE=' || diretorio || '\' || 'RECEB.PAR TOUSER=CXSP');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando imp.exe');
                        end if;
                        loga(reglog, diretorio, 'RECEB.TMP');

                        log(reglog, 'Tratando inclusões e alterações.');

                        -- tratando inclusões e alterações da tabela ESCRITÓRIO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select ESCRITÓRIO, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.ESCRITÓRIO_T T;
                                        reg CXSP.ESCRITÓRIO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.ESCRITÓRIO T where T.ESCRITÓRIO = cur.ESCRITÓRIO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into ESCRITÓRIO (ESCRITÓRIO, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.ESCRITÓRIO, cur.DESCR, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg ESCRITÓRIO: ' || cur.ESCRITÓRIO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg ESCRITÓRIO inexistente: ' || cur.ESCRITÓRIO || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg ESCRITÓRIO já manipulado localmente: ' || cur.ESCRITÓRIO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg ESCRITÓRIO já existente e manipulado localmente: ' || cur.ESCRITÓRIO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.ESCRITÓRIO t set T.DESCR = cur.DESCR, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.ESCRITÓRIO = cur.ESCRITÓRIO;
                                                                        log(reglog, '> Atualização realizada do reg ESCRITÓRIO: ' || cur.ESCRITÓRIO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg ESCRITÓRIO com data local igual ou mais atual: ' || cur.ESCRITÓRIO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg ESCRITÓRIO já existente e com data local igual ou mais atual: ' || cur.ESCRITÓRIO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela ESCRITÓRIO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela MOEDA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.MOEDA_T T;
                                        reg CXSP.MOEDA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.MOEDA T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into MOEDA (COD, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.NOME, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg MOEDA: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg MOEDA inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg MOEDA já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg MOEDA já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.MOEDA t set T.NOME = cur.NOME, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg MOEDA: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg MOEDA com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg MOEDA já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela MOEDA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela MODALIDADE_FRETE
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, DESCR, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.MODALIDADE_FRETE_T T;
                                        reg CXSP.MODALIDADE_FRETE%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.MODALIDADE_FRETE T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into MODALIDADE_FRETE (COD, DESCR, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.DESCR, cur.OBS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg MODALIDADE_FRETE: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg MODALIDADE_FRETE inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg MODALIDADE_FRETE já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg MODALIDADE_FRETE já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.MODALIDADE_FRETE t set T.DESCR = cur.DESCR, T.OBS = cur.OBS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg MODALIDADE_FRETE: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg MODALIDADE_FRETE com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg MODALIDADE_FRETE já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela MODALIDADE_FRETE - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela MAPA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select WORKSHEET, SEQ, EMPRESA, ARQUIVO, TITULO, LINHA, COLUNA, COR, LARGURA, FONT, FONT_NEGRITO, FONT_TAM, ALINHAMENTO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.MAPA_T T;
                                        reg CXSP.MAPA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.MAPA T where T.WORKSHEET = cur.WORKSHEET and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into MAPA (WORKSHEET, SEQ, EMPRESA, ARQUIVO, TITULO, LINHA, COLUNA, COR, LARGURA, FONT, FONT_NEGRITO, FONT_TAM, ALINHAMENTO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.WORKSHEET, cur.SEQ, cur.EMPRESA, cur.ARQUIVO, cur.TITULO, cur.LINHA, cur.COLUNA, cur.COR, cur.LARGURA, cur.FONT, cur.FONT_NEGRITO, cur.FONT_TAM, cur.ALINHAMENTO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg MAPA: ' || cur.WORKSHEET || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg MAPA inexistente: ' || cur.WORKSHEET || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg MAPA já manipulado localmente: ' || cur.WORKSHEET || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg MAPA já existente e manipulado localmente: ' || cur.WORKSHEET || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.MAPA t set T.EMPRESA = cur.EMPRESA, T.ARQUIVO = cur.ARQUIVO, T.TITULO = cur.TITULO, T.LINHA = cur.LINHA, T.COLUNA = cur.COLUNA, T.COR = cur.COR, T.LARGURA = cur.LARGURA, T.FONT = cur.FONT, T.FONT_NEGRITO = cur.FONT_NEGRITO, T.FONT_TAM = cur.FONT_TAM, T.ALINHAMENTO = cur.ALINHAMENTO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.WORKSHEET = cur.WORKSHEET and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg MAPA: ' || cur.WORKSHEET || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg MAPA com data local igual ou mais atual: ' || cur.WORKSHEET || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg MAPA já existente e com data local igual ou mais atual: ' || cur.WORKSHEET || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela MAPA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela LOCAL_RESULT
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.LOCAL_RESULT_T T;
                                        reg CXSP.LOCAL_RESULT%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.LOCAL_RESULT T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into LOCAL_RESULT (COD, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.DESCR, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg LOCAL_RESULT: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg LOCAL_RESULT inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg LOCAL_RESULT já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg LOCAL_RESULT já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.LOCAL_RESULT t set T.DESCR = cur.DESCR, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg LOCAL_RESULT: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg LOCAL_RESULT com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg LOCAL_RESULT já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela LOCAL_RESULT - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela COSIPA_NEGOCIAÇÃO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select REF, REF_EXT, DATA_ORD, ALTERA, MÊS_NEG, MÊS_EMB, AGENTE, PRODUTO, TON, PAÍS_DESTINO, PORTO_DESTINO, IMP, OUTRO_DOC, PEÇAS, TRAT_TÉRMICO, TOLER_PROD_LOT_MAX, TOLER_PROD_LOT_MIN, COND_PAG, TERMO_ENTREGA, PREÇO, COMISS_AGENTE, OBS_GERAL, INSP_CLASS, FATURA_LÂMINA, FATURA_OUTRO, EXTERNAL_SURVEY_TYPE, EXTERNAL_SURVEYOR, SURVEY_SIGN_CERTIF, CLASS_ORG, END_USER, HRP, HRC, CRC, PREDAYS, POSDAYS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.COSIPA_NEGOCIAÇÃO_T T WHERE T.REF LIKE 'SP%' OR T.REF LIKE 'RJP%';
                                        reg CXSP.COSIPA_NEGOCIAÇÃO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.COSIPA_NEGOCIAÇÃO T where T.REF = cur.REF;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into COSIPA_NEGOCIAÇÃO (REF, REF_EXT, DATA_ORD, ALTERA, MÊS_NEG, MÊS_EMB, AGENTE, PRODUTO, TON, PAÍS_DESTINO, PORTO_DESTINO, IMP, OUTRO_DOC, PEÇAS, TRAT_TÉRMICO, TOLER_PROD_LOT_MAX, TOLER_PROD_LOT_MIN, COND_PAG, TERMO_ENTREGA, PREÇO, COMISS_AGENTE, OBS_GERAL, INSP_CLASS, FATURA_LÂMINA, FATURA_OUTRO, EXTERNAL_SURVEY_TYPE, EXTERNAL_SURVEYOR, SURVEY_SIGN_CERTIF, CLASS_ORG, END_USER, HRP, HRC, CRC, PREDAYS, POSDAYS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.REF, cur.REF_EXT, cur.DATA_ORD, cur.ALTERA, cur.MÊS_NEG, cur.MÊS_EMB, cur.AGENTE, cur.PRODUTO, cur.TON, cur.PAÍS_DESTINO, cur.PORTO_DESTINO, cur.IMP, cur.OUTRO_DOC, cur.PEÇAS, cur.TRAT_TÉRMICO, cur.TOLER_PROD_LOT_MAX, cur.TOLER_PROD_LOT_MIN, cur.COND_PAG, cur.TERMO_ENTREGA, cur.PREÇO, cur.COMISS_AGENTE, cur.OBS_GERAL, cur.INSP_CLASS, cur.FATURA_LÂMINA, cur.FATURA_OUTRO, cur.EXTERNAL_SURVEY_TYPE, cur.EXTERNAL_SURVEYOR, cur.SURVEY_SIGN_CERTIF, cur.CLASS_ORG, cur.END_USER, cur.HRP, cur.HRC, cur.CRC, cur.PREDAYS, cur.POSDAYS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg COSIPA_NEGOCIAÇÃO: ' || cur.REF || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg COSIPA_NEGOCIAÇÃO inexistente: ' || cur.REF || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg COSIPA_NEGOCIAÇÃO já manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg COSIPA_NEGOCIAÇÃO já existente e manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.COSIPA_NEGOCIAÇÃO t set T.REF_EXT = cur.REF_EXT, T.DATA_ORD = cur.DATA_ORD, T.ALTERA = cur.ALTERA, T.MÊS_NEG = cur.MÊS_NEG, T.MÊS_EMB = cur.MÊS_EMB, T.AGENTE = cur.AGENTE, T.PRODUTO = cur.PRODUTO, T.TON = cur.TON, T.PAÍS_DESTINO = cur.PAÍS_DESTINO, T.PORTO_DESTINO = cur.PORTO_DESTINO, T.IMP = cur.IMP, T.OUTRO_DOC = cur.OUTRO_DOC, T.PEÇAS = cur.PEÇAS, T.TRAT_TÉRMICO = cur.TRAT_TÉRMICO, T.TOLER_PROD_LOT_MAX = cur.TOLER_PROD_LOT_MAX, T.TOLER_PROD_LOT_MIN = cur.TOLER_PROD_LOT_MIN, T.COND_PAG = cur.COND_PAG, T.TERMO_ENTREGA = cur.TERMO_ENTREGA, T.PREÇO = cur.PREÇO, T.COMISS_AGENTE = cur.COMISS_AGENTE, T.OBS_GERAL = cur.OBS_GERAL, T.INSP_CLASS = cur.INSP_CLASS, T.FATURA_LÂMINA = cur.FATURA_LÂMINA, T.FATURA_OUTRO = cur.FATURA_OUTRO, T.EXTERNAL_SURVEY_TYPE = cur.EXTERNAL_SURVEY_TYPE, T.EXTERNAL_SURVEYOR = cur.EXTERNAL_SURVEYOR, T.SURVEY_SIGN_CERTIF = cur.SURVEY_SIGN_CERTIF, T.CLASS_ORG = cur.CLASS_ORG, T.END_USER = cur.END_USER, T.HRP = cur.HRP, T.HRC = cur.HRC, T.CRC = cur.CRC, T.PREDAYS = cur.PREDAYS, T.POSDAYS = cur.POSDAYS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.REF = cur.REF;
                                                                        log(reglog, '> Atualização realizada do reg COSIPA_NEGOCIAÇÃO: ' || cur.REF || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg COSIPA_NEGOCIAÇÃO com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg COSIPA_NEGOCIAÇÃO já existente e com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela COSIPA_NEGOCIAÇÃO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela INCOTERM
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, DESCR, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.INCOTERM_T T;
                                        reg CXSP.INCOTERM%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.INCOTERM T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into INCOTERM (COD, DESCR, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.DESCR, cur.OBS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg INCOTERM: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg INCOTERM inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg INCOTERM já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg INCOTERM já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.INCOTERM t set T.DESCR = cur.DESCR, T.OBS = cur.OBS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg INCOTERM: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg INCOTERM com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg INCOTERM já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela INCOTERM - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela IDIOMA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.IDIOMA_T T;
                                        reg CXSP.IDIOMA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.IDIOMA T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into IDIOMA (COD, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.DESCR, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg IDIOMA: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg IDIOMA inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg IDIOMA já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg IDIOMA já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.IDIOMA t set T.DESCR = cur.DESCR, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg IDIOMA: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg IDIOMA com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg IDIOMA já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela IDIOMA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PARAM
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select GRUPO, PARAM, QUANDO_TEXTO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.PARAM_T T;
                                        reg CXSP.PARAM%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.PARAM T where T.GRUPO = cur.GRUPO and T.PARAM = cur.PARAM;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PARAM (GRUPO, PARAM, QUANDO_TEXTO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.GRUPO, cur.PARAM, cur.QUANDO_TEXTO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PARAM: ' || cur.GRUPO || cur.PARAM || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PARAM inexistente: ' || cur.GRUPO || cur.PARAM || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PARAM já manipulado localmente: ' || cur.GRUPO || cur.PARAM || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PARAM já existente e manipulado localmente: ' || cur.GRUPO || cur.PARAM || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.PARAM t set T.QUANDO_TEXTO = cur.QUANDO_TEXTO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.GRUPO = cur.GRUPO and T.PARAM = cur.PARAM;
                                                                        log(reglog, '> Atualização realizada do reg PARAM: ' || cur.GRUPO || cur.PARAM || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PARAM com data local igual ou mais atual: ' || cur.GRUPO || cur.PARAM || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PARAM já existente e com data local igual ou mais atual: ' || cur.GRUPO || cur.PARAM || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PARAM - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela ANEXO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select NOME, SUB_CONTA, SUB_CONTA_REL, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.ANEXO_T T;
                                        reg CXSP.ANEXO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.ANEXO T where T.NOME = cur.NOME;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into ANEXO (NOME, SUB_CONTA, SUB_CONTA_REL, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.NOME, cur.SUB_CONTA, cur.SUB_CONTA_REL, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg ANEXO: ' || cur.NOME || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg ANEXO inexistente: ' || cur.NOME || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg ANEXO já manipulado localmente: ' || cur.NOME || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg ANEXO já existente e manipulado localmente: ' || cur.NOME || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.ANEXO t set T.SUB_CONTA = cur.SUB_CONTA, T.SUB_CONTA_REL = cur.SUB_CONTA_REL, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.NOME = cur.NOME;
                                                                        log(reglog, '> Atualização realizada do reg ANEXO: ' || cur.NOME || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg ANEXO com data local igual ou mais atual: ' || cur.NOME || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg ANEXO já existente e com data local igual ou mais atual: ' || cur.NOME || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela ANEXO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela LOG_IMPORT
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select DATA, NOME, SEQ, SITUAÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.LOG_IMPORT_T T;
                                        reg CXSP.LOG_IMPORT%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.LOG_IMPORT T where T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into LOG_IMPORT (DATA, NOME, SEQ, SITUAÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.DATA, cur.NOME, cur.SEQ, cur.SITUAÇÃO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg LOG_IMPORT: ' || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg LOG_IMPORT inexistente: ' || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg LOG_IMPORT já manipulado localmente: ' || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg LOG_IMPORT já existente e manipulado localmente: ' || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.LOG_IMPORT t set T.DATA = cur.DATA, T.NOME = cur.NOME, T.SITUAÇÃO = cur.SITUAÇÃO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg LOG_IMPORT: ' || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg LOG_IMPORT com data local igual ou mais atual: ' || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg LOG_IMPORT já existente e com data local igual ou mais atual: ' || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela LOG_IMPORT - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela EMPRESA_APUR
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select EMPRESA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.EMPRESA_APUR_T T;
                                        reg CXSP.EMPRESA_APUR%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.EMPRESA_APUR T where T.EMPRESA = cur.EMPRESA;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into EMPRESA_APUR (EMPRESA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.EMPRESA, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg EMPRESA_APUR: ' || cur.EMPRESA || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg EMPRESA_APUR inexistente: ' || cur.EMPRESA || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg EMPRESA_APUR já manipulado localmente: ' || cur.EMPRESA || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg EMPRESA_APUR já existente e manipulado localmente: ' || cur.EMPRESA || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.EMPRESA_APUR t set T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.EMPRESA = cur.EMPRESA;
                                                                        log(reglog, '> Atualização realizada do reg EMPRESA_APUR: ' || cur.EMPRESA || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg EMPRESA_APUR com data local igual ou mais atual: ' || cur.EMPRESA || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg EMPRESA_APUR já existente e com data local igual ou mais atual: ' || cur.EMPRESA || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela EMPRESA_APUR - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela EMBALAGEM
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, DESCR, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.EMBALAGEM_T T;
                                        reg CXSP.EMBALAGEM%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.EMBALAGEM T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into EMBALAGEM (COD, DESCR, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.DESCR, cur.OBS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg EMBALAGEM: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg EMBALAGEM inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg EMBALAGEM já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg EMBALAGEM já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.EMBALAGEM t set T.DESCR = cur.DESCR, T.OBS = cur.OBS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg EMBALAGEM: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg EMBALAGEM com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg EMBALAGEM já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela EMBALAGEM - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CARTA_CRÉDITO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select REF, REF_LC, DATA_EMISS, MOEDA, VALOR, PESO, BCO_EMISSOR, BCO_NEGOCIADOR, BCO_AVISADOR, BCO_CONFIRMADOR, BCO_RECEBEDOR, VALIDADE_LC, VALIDADE_EMB, FORM_PAGAMENTO, TOLER_QTD, TOLER_VALOR, APRESENT_DOC, UNID_PESO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.CARTA_CRÉDITO_T T;
                                        reg CXSP.CARTA_CRÉDITO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.CARTA_CRÉDITO T where T.REF = cur.REF;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CARTA_CRÉDITO (REF, REF_LC, DATA_EMISS, MOEDA, VALOR, PESO, BCO_EMISSOR, BCO_NEGOCIADOR, BCO_AVISADOR, BCO_CONFIRMADOR, BCO_RECEBEDOR, VALIDADE_LC, VALIDADE_EMB, FORM_PAGAMENTO, TOLER_QTD, TOLER_VALOR, APRESENT_DOC, UNID_PESO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.REF, cur.REF_LC, cur.DATA_EMISS, cur.MOEDA, cur.VALOR, cur.PESO, cur.BCO_EMISSOR, cur.BCO_NEGOCIADOR, cur.BCO_AVISADOR, cur.BCO_CONFIRMADOR, cur.BCO_RECEBEDOR, cur.VALIDADE_LC, cur.VALIDADE_EMB, cur.FORM_PAGAMENTO, cur.TOLER_QTD, cur.TOLER_VALOR, cur.APRESENT_DOC, cur.UNID_PESO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CARTA_CRÉDITO: ' || cur.REF || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CARTA_CRÉDITO inexistente: ' || cur.REF || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CARTA_CRÉDITO já manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CARTA_CRÉDITO já existente e manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.CARTA_CRÉDITO t set T.REF_LC = cur.REF_LC, T.DATA_EMISS = cur.DATA_EMISS, T.MOEDA = cur.MOEDA, T.VALOR = cur.VALOR, T.PESO = cur.PESO, T.BCO_EMISSOR = cur.BCO_EMISSOR, T.BCO_NEGOCIADOR = cur.BCO_NEGOCIADOR, T.BCO_AVISADOR = cur.BCO_AVISADOR, T.BCO_CONFIRMADOR = cur.BCO_CONFIRMADOR, T.BCO_RECEBEDOR = cur.BCO_RECEBEDOR, T.VALIDADE_LC = cur.VALIDADE_LC, T.VALIDADE_EMB = cur.VALIDADE_EMB, T.FORM_PAGAMENTO = cur.FORM_PAGAMENTO, T.TOLER_QTD = cur.TOLER_QTD, T.TOLER_VALOR = cur.TOLER_VALOR, T.APRESENT_DOC = cur.APRESENT_DOC, T.UNID_PESO = cur.UNID_PESO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.REF = cur.REF;
                                                                        log(reglog, '> Atualização realizada do reg CARTA_CRÉDITO: ' || cur.REF || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CARTA_CRÉDITO com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CARTA_CRÉDITO já existente e com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CARTA_CRÉDITO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela COND_PAG
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, DESCR, PERÍODO, OBS, FIN_COND, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.COND_PAG_T T;
                                        reg CXSP.COND_PAG%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.COND_PAG T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into COND_PAG (COD, DESCR, PERÍODO, OBS, FIN_COND, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.DESCR, cur.PERÍODO, cur.OBS, cur.FIN_COND, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg COND_PAG: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg COND_PAG inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg COND_PAG já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg COND_PAG já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.COND_PAG t set T.DESCR = cur.DESCR, T.PERÍODO = cur.PERÍODO, T.OBS = cur.OBS, T.FIN_COND = cur.FIN_COND, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg COND_PAG: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg COND_PAG com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg COND_PAG já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela COND_PAG - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CONTA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select EMPRESA, CONTA, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.CONTA_T T;
                                        reg CXSP.CONTA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.CONTA T where T.EMPRESA = cur.EMPRESA and T.CONTA = cur.CONTA;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CONTA (EMPRESA, CONTA, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.EMPRESA, cur.CONTA, cur.NOME, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CONTA: ' || cur.EMPRESA || cur.CONTA || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CONTA inexistente: ' || cur.EMPRESA || cur.CONTA || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CONTA já manipulado localmente: ' || cur.EMPRESA || cur.CONTA || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CONTA já existente e manipulado localmente: ' || cur.EMPRESA || cur.CONTA || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.CONTA t set T.NOME = cur.NOME, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.EMPRESA = cur.EMPRESA and T.CONTA = cur.CONTA;
                                                                        log(reglog, '> Atualização realizada do reg CONTA: ' || cur.EMPRESA || cur.CONTA || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CONTA com data local igual ou mais atual: ' || cur.EMPRESA || cur.CONTA || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CONTA já existente e com data local igual ou mais atual: ' || cur.EMPRESA || cur.CONTA || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CONTA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela DOC
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, NOME, OBJETO_VINCULADO, FORMULÁRIO_PARAM, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.DOC_T T;
                                        reg CXSP.DOC%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.DOC T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into DOC (COD, NOME, OBJETO_VINCULADO, FORMULÁRIO_PARAM, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.NOME, cur.OBJETO_VINCULADO, cur.FORMULÁRIO_PARAM, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg DOC: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg DOC inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg DOC já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg DOC já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.DOC t set T.NOME = cur.NOME, T.OBJETO_VINCULADO = cur.OBJETO_VINCULADO, T.FORMULÁRIO_PARAM = cur.FORMULÁRIO_PARAM, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg DOC: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg DOC com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg DOC já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela DOC - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela DEPTO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.DEPTO_T T;
                                        reg CXSP.DEPTO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.DEPTO T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into DEPTO (COD, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.NOME, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg DEPTO: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg DEPTO inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg DEPTO já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg DEPTO já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.DEPTO t set T.NOME = cur.NOME, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg DEPTO: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg DEPTO com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg DEPTO já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela DEPTO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela GRUPO_PRODUTO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.GRUPO_PRODUTO_T T;
                                        reg CXSP.GRUPO_PRODUTO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.GRUPO_PRODUTO T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into GRUPO_PRODUTO (COD, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.DESCR, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg GRUPO_PRODUTO: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg GRUPO_PRODUTO inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg GRUPO_PRODUTO já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg GRUPO_PRODUTO já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.GRUPO_PRODUTO t set T.DESCR = cur.DESCR, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg GRUPO_PRODUTO: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg GRUPO_PRODUTO com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg GRUPO_PRODUTO já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela GRUPO_PRODUTO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela RAMO_ATIVIDADE
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.RAMO_ATIVIDADE_T T;
                                        reg CXSP.RAMO_ATIVIDADE%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.RAMO_ATIVIDADE T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into RAMO_ATIVIDADE (COD, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.NOME, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg RAMO_ATIVIDADE: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg RAMO_ATIVIDADE inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg RAMO_ATIVIDADE já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg RAMO_ATIVIDADE já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.RAMO_ATIVIDADE t set T.NOME = cur.NOME, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg RAMO_ATIVIDADE: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg RAMO_ATIVIDADE com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg RAMO_ATIVIDADE já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela RAMO_ATIVIDADE - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela VIA_TRANSPORTE
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, DESCR, TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.VIA_TRANSPORTE_T T;
                                        reg CXSP.VIA_TRANSPORTE%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.VIA_TRANSPORTE T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into VIA_TRANSPORTE (COD, DESCR, TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.DESCR, cur.TIPO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg VIA_TRANSPORTE: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg VIA_TRANSPORTE inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg VIA_TRANSPORTE já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg VIA_TRANSPORTE já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.VIA_TRANSPORTE t set T.DESCR = cur.DESCR, T.TIPO = cur.TIPO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg VIA_TRANSPORTE: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg VIA_TRANSPORTE com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg VIA_TRANSPORTE já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela VIA_TRANSPORTE - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela UNID_QUANTID
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.UNID_QUANTID_T T;
                                        reg CXSP.UNID_QUANTID%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.UNID_QUANTID T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into UNID_QUANTID (COD, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.NOME, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg UNID_QUANTID: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg UNID_QUANTID inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg UNID_QUANTID já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg UNID_QUANTID já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.UNID_QUANTID t set T.NOME = cur.NOME, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg UNID_QUANTID: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg UNID_QUANTID com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg UNID_QUANTID já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela UNID_QUANTID - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela SUB_CONTA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select EMPRESA, SUB_CONTA, CONTA, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.SUB_CONTA_T T;
                                        reg CXSP.SUB_CONTA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.SUB_CONTA T where T.EMPRESA = cur.EMPRESA and T.SUB_CONTA = cur.SUB_CONTA;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into SUB_CONTA (EMPRESA, SUB_CONTA, CONTA, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.EMPRESA, cur.SUB_CONTA, cur.CONTA, cur.NOME, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg SUB_CONTA: ' || cur.EMPRESA || cur.SUB_CONTA || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg SUB_CONTA inexistente: ' || cur.EMPRESA || cur.SUB_CONTA || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg SUB_CONTA já manipulado localmente: ' || cur.EMPRESA || cur.SUB_CONTA || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg SUB_CONTA já existente e manipulado localmente: ' || cur.EMPRESA || cur.SUB_CONTA || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.SUB_CONTA t set T.CONTA = cur.CONTA, T.NOME = cur.NOME, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.EMPRESA = cur.EMPRESA and T.SUB_CONTA = cur.SUB_CONTA;
                                                                        log(reglog, '> Atualização realizada do reg SUB_CONTA: ' || cur.EMPRESA || cur.SUB_CONTA || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg SUB_CONTA com data local igual ou mais atual: ' || cur.EMPRESA || cur.SUB_CONTA || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg SUB_CONTA já existente e com data local igual ou mais atual: ' || cur.EMPRESA || cur.SUB_CONTA || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela SUB_CONTA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela LANÇ
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select LANÇ, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.LANÇ_T T;
                                        reg CXSP.LANÇ%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.LANÇ T where T.LANÇ = cur.LANÇ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into LANÇ (LANÇ, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.LANÇ, cur.NOME, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg LANÇ: ' || cur.LANÇ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg LANÇ inexistente: ' || cur.LANÇ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg LANÇ já manipulado localmente: ' || cur.LANÇ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg LANÇ já existente e manipulado localmente: ' || cur.LANÇ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.LANÇ t set T.NOME = cur.NOME, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.LANÇ = cur.LANÇ;
                                                                        log(reglog, '> Atualização realizada do reg LANÇ: ' || cur.LANÇ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg LANÇ com data local igual ou mais atual: ' || cur.LANÇ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg LANÇ já existente e com data local igual ou mais atual: ' || cur.LANÇ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela LANÇ - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela RELACIONADA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select REF, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.RELACIONADA_T T;
                                        reg CXSP.RELACIONADA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.RELACIONADA T where T.REF = cur.REF;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into RELACIONADA (REF, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.REF, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg RELACIONADA: ' || cur.REF || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg RELACIONADA inexistente: ' || cur.REF || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg RELACIONADA já manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg RELACIONADA já existente e manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.RELACIONADA t set T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.REF = cur.REF;
                                                                        log(reglog, '> Atualização realizada do reg RELACIONADA: ' || cur.REF || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg RELACIONADA com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg RELACIONADA já existente e com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela RELACIONADA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PARAM_CSN
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select PROD, PARAM, VALOR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.PARAM_CSN_T T;
                                        reg CXSP.PARAM_CSN%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.PARAM_CSN T where T.PROD = cur.PROD and T.VALOR = cur.VALOR;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PARAM_CSN (PROD, PARAM, VALOR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.PROD, cur.PARAM, cur.VALOR, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PARAM_CSN: ' || cur.PROD || cur.VALOR || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PARAM_CSN inexistente: ' || cur.PROD || cur.VALOR || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PARAM_CSN já manipulado localmente: ' || cur.PROD || cur.VALOR || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PARAM_CSN já existente e manipulado localmente: ' || cur.PROD || cur.VALOR || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.PARAM_CSN t set T.PARAM = cur.PARAM, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.PROD = cur.PROD and T.VALOR = cur.VALOR;
                                                                        log(reglog, '> Atualização realizada do reg PARAM_CSN: ' || cur.PROD || cur.VALOR || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PARAM_CSN com data local igual ou mais atual: ' || cur.PROD || cur.VALOR || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PARAM_CSN já existente e com data local igual ou mais atual: ' || cur.PROD || cur.VALOR || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PARAM_CSN - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PLANILHA_STC
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select WORKSHEET, EMPRESA, ARQUIVO, MAPA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.PLANILHA_STC_T T;
                                        reg CXSP.PLANILHA_STC%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.PLANILHA_STC T where T.WORKSHEET = cur.WORKSHEET;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PLANILHA_STC (WORKSHEET, EMPRESA, ARQUIVO, MAPA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.WORKSHEET, cur.EMPRESA, cur.ARQUIVO, cur.MAPA, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PLANILHA_STC: ' || cur.WORKSHEET || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PLANILHA_STC inexistente: ' || cur.WORKSHEET || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PLANILHA_STC já manipulado localmente: ' || cur.WORKSHEET || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PLANILHA_STC já existente e manipulado localmente: ' || cur.WORKSHEET || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.PLANILHA_STC t set T.EMPRESA = cur.EMPRESA, T.ARQUIVO = cur.ARQUIVO, T.MAPA = cur.MAPA, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.WORKSHEET = cur.WORKSHEET;
                                                                        log(reglog, '> Atualização realizada do reg PLANILHA_STC: ' || cur.WORKSHEET || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PLANILHA_STC com data local igual ou mais atual: ' || cur.WORKSHEET || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PLANILHA_STC já existente e com data local igual ou mais atual: ' || cur.WORKSHEET || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PLANILHA_STC - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PLANILHA_DEF
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select WORKSHEET, SEQ, EMPRESA, ARQUIVO, TIPO, HISTÓRICO, DATAHIST, COLUNACRT, CRT, COLUNADBCR, DÉBITO, CRÉDITO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.PLANILHA_DEF_T T;
                                        reg CXSP.PLANILHA_DEF%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.PLANILHA_DEF T where T.WORKSHEET = cur.WORKSHEET and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PLANILHA_DEF (WORKSHEET, SEQ, EMPRESA, ARQUIVO, TIPO, HISTÓRICO, DATAHIST, COLUNACRT, CRT, COLUNADBCR, DÉBITO, CRÉDITO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.WORKSHEET, cur.SEQ, cur.EMPRESA, cur.ARQUIVO, cur.TIPO, cur.HISTÓRICO, cur.DATAHIST, cur.COLUNACRT, cur.CRT, cur.COLUNADBCR, cur.DÉBITO, cur.CRÉDITO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PLANILHA_DEF: ' || cur.WORKSHEET || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PLANILHA_DEF inexistente: ' || cur.WORKSHEET || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PLANILHA_DEF já manipulado localmente: ' || cur.WORKSHEET || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PLANILHA_DEF já existente e manipulado localmente: ' || cur.WORKSHEET || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.PLANILHA_DEF t set T.EMPRESA = cur.EMPRESA, T.ARQUIVO = cur.ARQUIVO, T.TIPO = cur.TIPO, T.HISTÓRICO = cur.HISTÓRICO, T.DATAHIST = cur.DATAHIST, T.COLUNACRT = cur.COLUNACRT, T.CRT = cur.CRT, T.COLUNADBCR = cur.COLUNADBCR, T.DÉBITO = cur.DÉBITO, T.CRÉDITO = cur.CRÉDITO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.WORKSHEET = cur.WORKSHEET and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg PLANILHA_DEF: ' || cur.WORKSHEET || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PLANILHA_DEF com data local igual ou mais atual: ' || cur.WORKSHEET || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PLANILHA_DEF já existente e com data local igual ou mais atual: ' || cur.WORKSHEET || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PLANILHA_DEF - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela INCOTERM_LANÇ
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select INCOTERM, LANÇ, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.INCOTERM_LANÇ_T T;
                                        reg CXSP.INCOTERM_LANÇ%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.INCOTERM_LANÇ T where T.INCOTERM = cur.INCOTERM and T.LANÇ = cur.LANÇ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into INCOTERM_LANÇ (INCOTERM, LANÇ, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.INCOTERM, cur.LANÇ, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg INCOTERM_LANÇ: ' || cur.INCOTERM || cur.LANÇ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg INCOTERM_LANÇ inexistente: ' || cur.INCOTERM || cur.LANÇ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg INCOTERM_LANÇ já manipulado localmente: ' || cur.INCOTERM || cur.LANÇ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg INCOTERM_LANÇ já existente e manipulado localmente: ' || cur.INCOTERM || cur.LANÇ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.INCOTERM_LANÇ t set T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.INCOTERM = cur.INCOTERM and T.LANÇ = cur.LANÇ;
                                                                        log(reglog, '> Atualização realizada do reg INCOTERM_LANÇ: ' || cur.INCOTERM || cur.LANÇ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg INCOTERM_LANÇ com data local igual ou mais atual: ' || cur.INCOTERM || cur.LANÇ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg INCOTERM_LANÇ já existente e com data local igual ou mais atual: ' || cur.INCOTERM || cur.LANÇ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela INCOTERM_LANÇ - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PRODUTO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, NOME, GRUPO, NCM, NALADI, NCM_OBS, NALADI_OBS, MEDIDAS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.PRODUTO_T T;
                                        reg CXSP.PRODUTO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.PRODUTO T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PRODUTO (COD, NOME, GRUPO, NCM, NALADI, NCM_OBS, NALADI_OBS, MEDIDAS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.NOME, cur.GRUPO, cur.NCM, cur.NALADI, cur.NCM_OBS, cur.NALADI_OBS, cur.MEDIDAS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PRODUTO: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PRODUTO inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PRODUTO já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PRODUTO já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.PRODUTO t set T.NOME = cur.NOME, T.GRUPO = cur.GRUPO, T.NCM = cur.NCM, T.NALADI = cur.NALADI, T.NCM_OBS = cur.NCM_OBS, T.NALADI_OBS = cur.NALADI_OBS, T.MEDIDAS = cur.MEDIDAS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg PRODUTO: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PRODUTO com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PRODUTO já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PRODUTO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela DIVISÃO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select ESCRITÓRIO, DIVISÃO, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.DIVISÃO_T T;
                                        reg CXSP.DIVISÃO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.DIVISÃO T where T.ESCRITÓRIO = cur.ESCRITÓRIO and T.DIVISÃO = cur.DIVISÃO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into DIVISÃO (ESCRITÓRIO, DIVISÃO, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.ESCRITÓRIO, cur.DIVISÃO, cur.DESCR, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg DIVISÃO: ' || cur.ESCRITÓRIO || cur.DIVISÃO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg DIVISÃO inexistente: ' || cur.ESCRITÓRIO || cur.DIVISÃO || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg DIVISÃO já manipulado localmente: ' || cur.ESCRITÓRIO || cur.DIVISÃO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg DIVISÃO já existente e manipulado localmente: ' || cur.ESCRITÓRIO || cur.DIVISÃO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.DIVISÃO t set T.DESCR = cur.DESCR, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.ESCRITÓRIO = cur.ESCRITÓRIO and T.DIVISÃO = cur.DIVISÃO;
                                                                        log(reglog, '> Atualização realizada do reg DIVISÃO: ' || cur.ESCRITÓRIO || cur.DIVISÃO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg DIVISÃO com data local igual ou mais atual: ' || cur.ESCRITÓRIO || cur.DIVISÃO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg DIVISÃO já existente e com data local igual ou mais atual: ' || cur.ESCRITÓRIO || cur.DIVISÃO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela DIVISÃO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PAÍS
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, NOME, ABREVIATURA, BANDEIRA_COD, IDIOMA, MSG, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.PAÍS_T T;
                                        reg CXSP.PAÍS%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.PAÍS T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PAÍS (COD, NOME, ABREVIATURA, BANDEIRA_COD, IDIOMA, MSG, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.NOME, cur.ABREVIATURA, cur.BANDEIRA_COD, cur.IDIOMA, cur.MSG, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PAÍS: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PAÍS inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PAÍS já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PAÍS já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.PAÍS t set T.NOME = cur.NOME, T.ABREVIATURA = cur.ABREVIATURA, T.BANDEIRA_COD = cur.BANDEIRA_COD, T.IDIOMA = cur.IDIOMA, T.MSG = cur.MSG, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg PAÍS: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PAÍS com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PAÍS já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PAÍS - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela TIPO_REF
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select TIPO, DESCR, DEPTO, ARQUIVO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.TIPO_REF_T T;
                                        reg CXSP.TIPO_REF%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.TIPO_REF T where T.TIPO = cur.TIPO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into TIPO_REF (TIPO, DESCR, DEPTO, ARQUIVO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.TIPO, cur.DESCR, cur.DEPTO, cur.ARQUIVO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg TIPO_REF: ' || cur.TIPO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg TIPO_REF inexistente: ' || cur.TIPO || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg TIPO_REF já manipulado localmente: ' || cur.TIPO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg TIPO_REF já existente e manipulado localmente: ' || cur.TIPO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.TIPO_REF t set T.DESCR = cur.DESCR, T.DEPTO = cur.DEPTO, T.ARQUIVO = cur.ARQUIVO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.TIPO = cur.TIPO;
                                                                        log(reglog, '> Atualização realizada do reg TIPO_REF: ' || cur.TIPO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg TIPO_REF com data local igual ou mais atual: ' || cur.TIPO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg TIPO_REF já existente e com data local igual ou mais atual: ' || cur.TIPO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela TIPO_REF - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CIA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select LOGO, LOGOTIPO, COD, CGC, NOME, ENDEREÇO, BAIRRO, CIDADE, ESTADO, PAÍS, CEP, CAIXA_POSTAL, TELEFONE, FAX, TELEX, E_MAIL, F_COD, MARCAÇÃO, OBS, LOCAL_RESULT, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.CIA_T T;
                                        reg CXSP.CIA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.CIA T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CIA (LOGO, LOGOTIPO, COD, CGC, NOME, ENDEREÇO, BAIRRO, CIDADE, ESTADO, PAÍS, CEP, CAIXA_POSTAL, TELEFONE, FAX, TELEX, E_MAIL, F_COD, MARCAÇÃO, OBS, LOCAL_RESULT, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.LOGO, cur.LOGOTIPO, cur.COD, cur.CGC, cur.NOME, cur.ENDEREÇO, cur.BAIRRO, cur.CIDADE, cur.ESTADO, cur.PAÍS, cur.CEP, cur.CAIXA_POSTAL, cur.TELEFONE, cur.FAX, cur.TELEX, cur.E_MAIL, cur.F_COD, cur.MARCAÇÃO, cur.OBS, cur.LOCAL_RESULT, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CIA: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CIA inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CIA já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CIA já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.CIA t set T.LOGO = cur.LOGO, T.LOGOTIPO = cur.LOGOTIPO, T.CGC = cur.CGC, T.NOME = cur.NOME, T.ENDEREÇO = cur.ENDEREÇO, T.BAIRRO = cur.BAIRRO, T.CIDADE = cur.CIDADE, T.ESTADO = cur.ESTADO, T.PAÍS = cur.PAÍS, T.CEP = cur.CEP, T.CAIXA_POSTAL = cur.CAIXA_POSTAL, T.TELEFONE = cur.TELEFONE, T.FAX = cur.FAX, T.TELEX = cur.TELEX, T.E_MAIL = cur.E_MAIL, T.F_COD = cur.F_COD, T.MARCAÇÃO = cur.MARCAÇÃO, T.OBS = cur.OBS, T.LOCAL_RESULT = cur.LOCAL_RESULT, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg CIA: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CIA com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CIA já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CIA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PORTO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, NOME, CIDADE, ESTADO, PAÍS, RESTRIÇÕES, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.PORTO_T T;
                                        reg CXSP.PORTO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.PORTO T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PORTO (COD, NOME, CIDADE, ESTADO, PAÍS, RESTRIÇÕES, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.NOME, cur.CIDADE, cur.ESTADO, cur.PAÍS, cur.RESTRIÇÕES, cur.OBS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PORTO: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PORTO inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PORTO já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PORTO já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.PORTO t set T.NOME = cur.NOME, T.CIDADE = cur.CIDADE, T.ESTADO = cur.ESTADO, T.PAÍS = cur.PAÍS, T.RESTRIÇÕES = cur.RESTRIÇÕES, T.OBS = cur.OBS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg PORTO: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PORTO com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PORTO já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PORTO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela DIVISÃO_PRODUTO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select ESCRITÓRIO, DIVISÃO, PROD, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.DIVISÃO_PRODUTO_T T;
                                        reg CXSP.DIVISÃO_PRODUTO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.DIVISÃO_PRODUTO T where T.ESCRITÓRIO = cur.ESCRITÓRIO and T.DIVISÃO = cur.DIVISÃO and T.PROD = cur.PROD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into DIVISÃO_PRODUTO (ESCRITÓRIO, DIVISÃO, PROD, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.ESCRITÓRIO, cur.DIVISÃO, cur.PROD, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg DIVISÃO_PRODUTO: ' || cur.ESCRITÓRIO || cur.DIVISÃO || cur.PROD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg DIVISÃO_PRODUTO inexistente: ' || cur.ESCRITÓRIO || cur.DIVISÃO || cur.PROD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg DIVISÃO_PRODUTO já manipulado localmente: ' || cur.ESCRITÓRIO || cur.DIVISÃO || cur.PROD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg DIVISÃO_PRODUTO já existente e manipulado localmente: ' || cur.ESCRITÓRIO || cur.DIVISÃO || cur.PROD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.DIVISÃO_PRODUTO t set T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.ESCRITÓRIO = cur.ESCRITÓRIO and T.DIVISÃO = cur.DIVISÃO and T.PROD = cur.PROD;
                                                                        log(reglog, '> Atualização realizada do reg DIVISÃO_PRODUTO: ' || cur.ESCRITÓRIO || cur.DIVISÃO || cur.PROD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg DIVISÃO_PRODUTO com data local igual ou mais atual: ' || cur.ESCRITÓRIO || cur.DIVISÃO || cur.PROD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg DIVISÃO_PRODUTO já existente e com data local igual ou mais atual: ' || cur.ESCRITÓRIO || cur.DIVISÃO || cur.PROD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela DIVISÃO_PRODUTO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PRODUTO_ESPECIF
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, SEQ, NCM, NALADI, MENOR_ESPESSURA, MAIOR_ESPESSURA, MENOR_LARGURA, MAIOR_LARGURA, MENOR_COMPRIMENTO, MAIOR_COMPRIMENTO, REVESTIMENTO, TÊMPERA, DESCR, DESCR_NALADI, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.PRODUTO_ESPECIF_T T;
                                        reg CXSP.PRODUTO_ESPECIF%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.PRODUTO_ESPECIF T where T.COD = cur.COD and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PRODUTO_ESPECIF (COD, SEQ, NCM, NALADI, MENOR_ESPESSURA, MAIOR_ESPESSURA, MENOR_LARGURA, MAIOR_LARGURA, MENOR_COMPRIMENTO, MAIOR_COMPRIMENTO, REVESTIMENTO, TÊMPERA, DESCR, DESCR_NALADI, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.SEQ, cur.NCM, cur.NALADI, cur.MENOR_ESPESSURA, cur.MAIOR_ESPESSURA, cur.MENOR_LARGURA, cur.MAIOR_LARGURA, cur.MENOR_COMPRIMENTO, cur.MAIOR_COMPRIMENTO, cur.REVESTIMENTO, cur.TÊMPERA, cur.DESCR, cur.DESCR_NALADI, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PRODUTO_ESPECIF: ' || cur.COD || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PRODUTO_ESPECIF inexistente: ' || cur.COD || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PRODUTO_ESPECIF já manipulado localmente: ' || cur.COD || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PRODUTO_ESPECIF já existente e manipulado localmente: ' || cur.COD || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.PRODUTO_ESPECIF t set T.NCM = cur.NCM, T.NALADI = cur.NALADI, T.MENOR_ESPESSURA = cur.MENOR_ESPESSURA, T.MAIOR_ESPESSURA = cur.MAIOR_ESPESSURA, T.MENOR_LARGURA = cur.MENOR_LARGURA, T.MAIOR_LARGURA = cur.MAIOR_LARGURA, T.MENOR_COMPRIMENTO = cur.MENOR_COMPRIMENTO, T.MAIOR_COMPRIMENTO = cur.MAIOR_COMPRIMENTO, T.REVESTIMENTO = cur.REVESTIMENTO, T.TÊMPERA = cur.TÊMPERA, T.DESCR = cur.DESCR, T.DESCR_NALADI = cur.DESCR_NALADI, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg PRODUTO_ESPECIF: ' || cur.COD || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PRODUTO_ESPECIF com data local igual ou mais atual: ' || cur.COD || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PRODUTO_ESPECIF já existente e com data local igual ou mais atual: ' || cur.COD || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PRODUTO_ESPECIF - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela DIVISÃO_TIPO_REF
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select ESCRITÓRIO, DIVISÃO, TIPO_REF, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.DIVISÃO_TIPO_REF_T T;
                                        reg CXSP.DIVISÃO_TIPO_REF%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.DIVISÃO_TIPO_REF T where T.ESCRITÓRIO = cur.ESCRITÓRIO and T.DIVISÃO = cur.DIVISÃO and T.TIPO_REF = cur.TIPO_REF;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into DIVISÃO_TIPO_REF (ESCRITÓRIO, DIVISÃO, TIPO_REF, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.ESCRITÓRIO, cur.DIVISÃO, cur.TIPO_REF, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg DIVISÃO_TIPO_REF: ' || cur.ESCRITÓRIO || cur.DIVISÃO || cur.TIPO_REF || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg DIVISÃO_TIPO_REF inexistente: ' || cur.ESCRITÓRIO || cur.DIVISÃO || cur.TIPO_REF || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg DIVISÃO_TIPO_REF já manipulado localmente: ' || cur.ESCRITÓRIO || cur.DIVISÃO || cur.TIPO_REF || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg DIVISÃO_TIPO_REF já existente e manipulado localmente: ' || cur.ESCRITÓRIO || cur.DIVISÃO || cur.TIPO_REF || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.DIVISÃO_TIPO_REF t set T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.ESCRITÓRIO = cur.ESCRITÓRIO and T.DIVISÃO = cur.DIVISÃO and T.TIPO_REF = cur.TIPO_REF;
                                                                        log(reglog, '> Atualização realizada do reg DIVISÃO_TIPO_REF: ' || cur.ESCRITÓRIO || cur.DIVISÃO || cur.TIPO_REF || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg DIVISÃO_TIPO_REF com data local igual ou mais atual: ' || cur.ESCRITÓRIO || cur.DIVISÃO || cur.TIPO_REF || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg DIVISÃO_TIPO_REF já existente e com data local igual ou mais atual: ' || cur.ESCRITÓRIO || cur.DIVISÃO || cur.TIPO_REF || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela DIVISÃO_TIPO_REF - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela NAVIO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select COD, ANO_CONSTRUÇÃO, NOME, NOME_ANTERIOR, BANDEIRA, NAVIO_TIPO, DWAT, LOA, BEAN, GRT, NRT, CAPACIDADE_GRÃO, CAPACIDADE_FARDO, CALADO_VERÃO, GUINDASTE_NUM, GUINDASTE_DIMENSÃO, ESCOTILHA_NUM, ESCOTILHA_DIMENSÃO, ESCOTILHA_FECHAM_TIPO, EQUIPAMENTO, TANKTOP_STRENGTH, SOCIEDADE_CLASSIFICADORA, CLASSE, OBS, OWNER, CALL_SIGN, N_TANKS, SBT, DOUBLE_HULL, DOUBLE_BOTTOM, INERT_GAS_SYS, HEATING_COILS, IMO_NUM, IMO_TYPE, COATING, CARGO_PUMPS, CUBIC_CAPACITY, CARGO_LINES, CARGO_MANIFOLDS, MAJORS_AP, SUMMER_DRAFT, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.NAVIO_T T;
                                        reg CXSP.NAVIO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.NAVIO T where T.COD = cur.COD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into NAVIO (COD, ANO_CONSTRUÇÃO, NOME, NOME_ANTERIOR, BANDEIRA, NAVIO_TIPO, DWAT, LOA, BEAN, GRT, NRT, CAPACIDADE_GRÃO, CAPACIDADE_FARDO, CALADO_VERÃO, GUINDASTE_NUM, GUINDASTE_DIMENSÃO, ESCOTILHA_NUM, ESCOTILHA_DIMENSÃO, ESCOTILHA_FECHAM_TIPO, EQUIPAMENTO, TANKTOP_STRENGTH, SOCIEDADE_CLASSIFICADORA, CLASSE, OBS, OWNER, CALL_SIGN, N_TANKS, SBT, DOUBLE_HULL, DOUBLE_BOTTOM, INERT_GAS_SYS, HEATING_COILS, IMO_NUM, IMO_TYPE, COATING, CARGO_PUMPS, CUBIC_CAPACITY, CARGO_LINES, CARGO_MANIFOLDS, MAJORS_AP, SUMMER_DRAFT, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.COD, cur.ANO_CONSTRUÇÃO, cur.NOME, cur.NOME_ANTERIOR, cur.BANDEIRA, cur.NAVIO_TIPO, cur.DWAT, cur.LOA, cur.BEAN, cur.GRT, cur.NRT, cur.CAPACIDADE_GRÃO, cur.CAPACIDADE_FARDO, cur.CALADO_VERÃO, cur.GUINDASTE_NUM, cur.GUINDASTE_DIMENSÃO, cur.ESCOTILHA_NUM, cur.ESCOTILHA_DIMENSÃO, cur.ESCOTILHA_FECHAM_TIPO, cur.EQUIPAMENTO, cur.TANKTOP_STRENGTH, cur.SOCIEDADE_CLASSIFICADORA, cur.CLASSE, cur.OBS, cur.OWNER, cur.CALL_SIGN, cur.N_TANKS, cur.SBT, cur.DOUBLE_HULL, cur.DOUBLE_BOTTOM, cur.INERT_GAS_SYS, cur.HEATING_COILS, cur.IMO_NUM, cur.IMO_TYPE, cur.COATING, cur.CARGO_PUMPS, cur.CUBIC_CAPACITY, cur.CARGO_LINES, cur.CARGO_MANIFOLDS, cur.MAJORS_AP, cur.SUMMER_DRAFT, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, 
                                                        cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg NAVIO: ' || cur.COD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg NAVIO inexistente: ' || cur.COD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg NAVIO já manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg NAVIO já existente e manipulado localmente: ' || cur.COD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.NAVIO t set T.ANO_CONSTRUÇÃO = cur.ANO_CONSTRUÇÃO, T.NOME = cur.NOME, T.NOME_ANTERIOR = cur.NOME_ANTERIOR, T.BANDEIRA = cur.BANDEIRA, T.NAVIO_TIPO = cur.NAVIO_TIPO, T.DWAT = cur.DWAT, T.LOA = cur.LOA, T.BEAN = cur.BEAN, T.GRT = cur.GRT, T.NRT = cur.NRT, T.CAPACIDADE_GRÃO = cur.CAPACIDADE_GRÃO, T.CAPACIDADE_FARDO = cur.CAPACIDADE_FARDO, T.CALADO_VERÃO = cur.CALADO_VERÃO, T.GUINDASTE_NUM = cur.GUINDASTE_NUM, T.GUINDASTE_DIMENSÃO = cur.GUINDASTE_DIMENSÃO, T.ESCOTILHA_NUM = cur.ESCOTILHA_NUM, T.ESCOTILHA_DIMENSÃO = cur.ESCOTILHA_DIMENSÃO, T.ESCOTILHA_FECHAM_TIPO = cur.ESCOTILHA_FECHAM_TIPO, T.EQUIPAMENTO = cur.EQUIPAMENTO, T.TANKTOP_STRENGTH = cur.TANKTOP_STRENGTH, T.SOCIEDADE_CLASSIFICADORA = cur.SOCIEDADE_CLASSIFICADORA, T.CLASSE = cur.CLASSE, T.OBS = cur.OBS, T.OWNER = cur.OWNER, T.CALL_SIGN = cur.CALL_SIGN, T.N_TANKS = cur.N_TANKS, T.SBT = cur.SBT, T.DOUBLE_HULL = cur.DOUBLE_HULL, T.DOUBLE_BOTTOM = cur.DOUBLE_BOTTOM, T.INERT_GAS_SYS = cur.INERT_GAS_SYS, T.HEATING_COILS = cur.HEATING_COILS, T.IMO_NUM = cur.IMO_NUM, T.IMO_TYPE = cur.IMO_TYPE, T.COATING = cur.COATING, T.CARGO_PUMPS = cur.CARGO_PUMPS, T.CUBIC_CAPACITY = cur.CUBIC_CAPACITY, T.CARGO_LINES = cur.CARGO_LINES, T.CARGO_MANIFOLDS = cur.CARGO_MANIFOLDS, T.MAJORS_AP = cur.MAJORS_AP, T.SUMMER_DRAFT = cur.SUMMER_DRAFT, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, 
                                                                        T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.COD = cur.COD;
                                                                        log(reglog, '> Atualização realizada do reg NAVIO: ' || cur.COD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg NAVIO com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg NAVIO já existente e com data local igual ou mais atual: ' || cur.COD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela NAVIO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela VIAGEM
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select REF, NAVIO, NAVIO_ÚLTIMO, CORRENTE, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.VIAGEM_T T;
                                        reg CXSP.VIAGEM%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.VIAGEM T where T.REF = cur.REF;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into VIAGEM (REF, NAVIO, NAVIO_ÚLTIMO, CORRENTE, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.REF, cur.NAVIO, cur.NAVIO_ÚLTIMO, cur.CORRENTE, cur.OBS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg VIAGEM: ' || cur.REF || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg VIAGEM inexistente: ' || cur.REF || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg VIAGEM já manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg VIAGEM já existente e manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.VIAGEM t set T.NAVIO = cur.NAVIO, T.NAVIO_ÚLTIMO = cur.NAVIO_ÚLTIMO, T.CORRENTE = cur.CORRENTE, T.OBS = cur.OBS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.REF = cur.REF;
                                                                        log(reglog, '> Atualização realizada do reg VIAGEM: ' || cur.REF || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg VIAGEM com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg VIAGEM já existente e com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela VIAGEM - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PED
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select REF, PED_DATA, MOEDA, TAXA_USD, VIA_TRANSPORTE, CARGA_PORTO, PAÍS_DESTINO, FORNECEDOR, FORNECEDOR_REF, FORNECEDOR_COND_RECEB, EXP, EXP_REF, EXP_COND_RECEB, IMP, IMP_REF, IMP_COND_RECEB, DISTRIBUIDOR, PAGADOR, FRETE_COND, FRETE_PREV_POR_MT, FRETE_PREV_VALOR, EMB_PREV, MARCAÇÃO, OBS, TIPO_VENDA, GRUPO_PROD, SUPERVISOR_VENDA, PRODUÇÃO_PREV, PARIDADE, INSPEÇÃO_EXTERNA, RESPONSÁVEL_INSP_EXT, AGENTE, TAXA_JUROS_FINANCIAM, JUROS_NO_PREÇO, COMISSÃO_PERCENT, COMISSÃO_MT, ADICIONAL_PERCENT, ADICIONAL_MT, INCIDÊNCIA, TIPO, ANEXO, BENEFICIÁRIO, LOCAL_PAG, BANCO, F_QUANTIDADE, F_PREÇO, F_RESULTADO, F_RESULTADO_MT, F_RESULTADO_P, F_COMISSÃO_FORN, F_COMISSÃO_FORN_P, F_PROFIT_SPLIT, F_DELIV_PURCHASE, F_DELIV_SALES, F_PAY_PURCHASE, F_PAY_SALES, F_OBS, FORNECEDOR_COND_VENDA, EXP_COND_VENDA, IMP_COND_VENDA, INSTRUC_INTERNA, PRODUTOR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.PED_T T WHERE T.REF LIKE 'RJP%' OR T.REF LIKE 'SP%';
                                        reg CXSP.PED%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.PED T where T.REF = cur.REF;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PED (REF, PED_DATA, MOEDA, TAXA_USD, VIA_TRANSPORTE, CARGA_PORTO, PAÍS_DESTINO, FORNECEDOR, FORNECEDOR_REF, FORNECEDOR_COND_RECEB, EXP, EXP_REF, EXP_COND_RECEB, IMP, IMP_REF, IMP_COND_RECEB, DISTRIBUIDOR, PAGADOR, FRETE_COND, FRETE_PREV_POR_MT, FRETE_PREV_VALOR, EMB_PREV, MARCAÇÃO, OBS, TIPO_VENDA, GRUPO_PROD, SUPERVISOR_VENDA, PRODUÇÃO_PREV, PARIDADE, INSPEÇÃO_EXTERNA, RESPONSÁVEL_INSP_EXT, AGENTE, TAXA_JUROS_FINANCIAM, JUROS_NO_PREÇO, COMISSÃO_PERCENT, COMISSÃO_MT, ADICIONAL_PERCENT, ADICIONAL_MT, INCIDÊNCIA, TIPO, ANEXO, BENEFICIÁRIO, LOCAL_PAG, BANCO, F_QUANTIDADE, F_PREÇO, F_RESULTADO, F_RESULTADO_MT, F_RESULTADO_P, F_COMISSÃO_FORN, F_COMISSÃO_FORN_P, F_PROFIT_SPLIT, F_DELIV_PURCHASE, F_DELIV_SALES, F_PAY_PURCHASE, F_PAY_SALES, F_OBS, FORNECEDOR_COND_VENDA, EXP_COND_VENDA, IMP_COND_VENDA, INSTRUC_INTERNA, PRODUTOR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.REF, cur.PED_DATA, cur.MOEDA, cur.TAXA_USD, cur.VIA_TRANSPORTE, cur.CARGA_PORTO, cur.PAÍS_DESTINO, cur.FORNECEDOR, cur.FORNECEDOR_REF, cur.FORNECEDOR_COND_RECEB, cur.EXP, cur.EXP_REF, cur.EXP_COND_RECEB, cur.IMP, cur.IMP_REF, cur.IMP_COND_RECEB, cur.DISTRIBUIDOR, cur.PAGADOR, cur.FRETE_COND, cur.FRETE_PREV_POR_MT, cur.FRETE_PREV_VALOR, cur.EMB_PREV, cur.MARCAÇÃO, cur.OBS, cur.TIPO_VENDA, cur.GRUPO_PROD, cur.SUPERVISOR_VENDA, cur.PRODUÇÃO_PREV, cur.PARIDADE, 
                                                        cur.INSPEÇÃO_EXTERNA, cur.RESPONSÁVEL_INSP_EXT, cur.AGENTE, cur.TAXA_JUROS_FINANCIAM, cur.JUROS_NO_PREÇO, cur.COMISSÃO_PERCENT, cur.COMISSÃO_MT, cur.ADICIONAL_PERCENT, cur.ADICIONAL_MT, cur.INCIDÊNCIA, cur.TIPO, cur.ANEXO, cur.BENEFICIÁRIO, cur.LOCAL_PAG, cur.BANCO, cur.F_QUANTIDADE, cur.F_PREÇO, cur.F_RESULTADO, cur.F_RESULTADO_MT, cur.F_RESULTADO_P, cur.F_COMISSÃO_FORN, cur.F_COMISSÃO_FORN_P, cur.F_PROFIT_SPLIT, cur.F_DELIV_PURCHASE, cur.F_DELIV_SALES, cur.F_PAY_PURCHASE, cur.F_PAY_SALES, cur.F_OBS, cur.FORNECEDOR_COND_VENDA, cur.EXP_COND_VENDA, cur.IMP_COND_VENDA, cur.INSTRUC_INTERNA, cur.PRODUTOR, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PED: ' || cur.REF || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PED inexistente: ' || cur.REF || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PED já manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PED já existente e manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.PED t set T.PED_DATA = cur.PED_DATA, T.MOEDA = cur.MOEDA, T.TAXA_USD = cur.TAXA_USD, T.VIA_TRANSPORTE = cur.VIA_TRANSPORTE, T.CARGA_PORTO = cur.CARGA_PORTO, T.PAÍS_DESTINO = cur.PAÍS_DESTINO, T.FORNECEDOR = cur.FORNECEDOR, T.FORNECEDOR_REF = cur.FORNECEDOR_REF, T.FORNECEDOR_COND_RECEB = cur.FORNECEDOR_COND_RECEB, T.EXP = cur.EXP, T.EXP_REF = cur.EXP_REF, T.EXP_COND_RECEB = cur.EXP_COND_RECEB, T.IMP = cur.IMP, T.IMP_REF = cur.IMP_REF, T.IMP_COND_RECEB = cur.IMP_COND_RECEB, T.DISTRIBUIDOR = cur.DISTRIBUIDOR, T.PAGADOR = cur.PAGADOR, T.FRETE_COND = cur.FRETE_COND, T.FRETE_PREV_POR_MT = cur.FRETE_PREV_POR_MT, T.FRETE_PREV_VALOR = cur.FRETE_PREV_VALOR, T.EMB_PREV = cur.EMB_PREV, T.MARCAÇÃO = cur.MARCAÇÃO, T.OBS = cur.OBS, T.TIPO_VENDA = cur.TIPO_VENDA, T.GRUPO_PROD = cur.GRUPO_PROD, T.SUPERVISOR_VENDA = cur.SUPERVISOR_VENDA, T.PRODUÇÃO_PREV = cur.PRODUÇÃO_PREV, T.PARIDADE = cur.PARIDADE, T.INSPEÇÃO_EXTERNA = cur.INSPEÇÃO_EXTERNA, T.RESPONSÁVEL_INSP_EXT = cur.RESPONSÁVEL_INSP_EXT, T.AGENTE = cur.AGENTE, T.TAXA_JUROS_FINANCIAM = cur.TAXA_JUROS_FINANCIAM, T.JUROS_NO_PREÇO = cur.JUROS_NO_PREÇO, T.COMISSÃO_PERCENT = cur.COMISSÃO_PERCENT, T.COMISSÃO_MT = cur.COMISSÃO_MT, T.ADICIONAL_PERCENT = cur.ADICIONAL_PERCENT, T.ADICIONAL_MT = cur.ADICIONAL_MT, T.INCIDÊNCIA = cur.INCIDÊNCIA, T.TIPO = cur.TIPO, T.ANEXO = cur.ANEXO, T.BENEFICIÁRIO = cur.BENEFICIÁRIO, T.LOCAL_PAG = cur.LOCAL_PAG, T.BANCO = cur.BANCO, T.F_QUANTIDADE = 
                                                                        cur.F_QUANTIDADE, T.F_PREÇO = cur.F_PREÇO, T.F_RESULTADO = cur.F_RESULTADO, T.F_RESULTADO_MT = cur.F_RESULTADO_MT, T.F_RESULTADO_P = cur.F_RESULTADO_P, T.F_COMISSÃO_FORN = cur.F_COMISSÃO_FORN, T.F_COMISSÃO_FORN_P = cur.F_COMISSÃO_FORN_P, T.F_PROFIT_SPLIT = cur.F_PROFIT_SPLIT, T.F_DELIV_PURCHASE = cur.F_DELIV_PURCHASE, T.F_DELIV_SALES = cur.F_DELIV_SALES, T.F_PAY_PURCHASE = cur.F_PAY_PURCHASE, T.F_PAY_SALES = cur.F_PAY_SALES, T.F_OBS = cur.F_OBS, T.FORNECEDOR_COND_VENDA = cur.FORNECEDOR_COND_VENDA, T.EXP_COND_VENDA = cur.EXP_COND_VENDA, T.IMP_COND_VENDA = cur.IMP_COND_VENDA, T.INSTRUC_INTERNA = cur.INSTRUC_INTERNA, T.PRODUTOR = cur.PRODUTOR, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.REF = cur.REF;
                                                                        log(reglog, '> Atualização realizada do reg PED: ' || cur.REF || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PED com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PED já existente e com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PED - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CIA_CONTATO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CIA_COD, CONTATO_NOME, TELEFONE, FUNÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.CIA_CONTATO_T T;
                                        reg CXSP.CIA_CONTATO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.CIA_CONTATO T where T.CIA_COD = cur.CIA_COD and T.CONTATO_NOME = cur.CONTATO_NOME;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CIA_CONTATO (CIA_COD, CONTATO_NOME, TELEFONE, FUNÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CIA_COD, cur.CONTATO_NOME, cur.TELEFONE, cur.FUNÇÃO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CIA_CONTATO: ' || cur.CIA_COD || cur.CONTATO_NOME || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CIA_CONTATO inexistente: ' || cur.CIA_COD || cur.CONTATO_NOME || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CIA_CONTATO já manipulado localmente: ' || cur.CIA_COD || cur.CONTATO_NOME || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CIA_CONTATO já existente e manipulado localmente: ' || cur.CIA_COD || cur.CONTATO_NOME || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.CIA_CONTATO t set T.TELEFONE = cur.TELEFONE, T.FUNÇÃO = cur.FUNÇÃO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CIA_COD = cur.CIA_COD and T.CONTATO_NOME = cur.CONTATO_NOME;
                                                                        log(reglog, '> Atualização realizada do reg CIA_CONTATO: ' || cur.CIA_COD || cur.CONTATO_NOME || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CIA_CONTATO com data local igual ou mais atual: ' || cur.CIA_COD || cur.CONTATO_NOME || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CIA_CONTATO já existente e com data local igual ou mais atual: ' || cur.CIA_COD || cur.CONTATO_NOME || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CIA_CONTATO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CARTA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select REF, EMPRESA, IDIOMA, DOC_DATA, CIA, CONTATO, CIA_SUB, CONTATO_SUB, ASSUNTO, TEXTO, EMISSÃO_DATA, COM_CÓPIA, USUÁRIO, SUPERVISOR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.CARTA_T T;
                                        reg CXSP.CARTA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.CARTA T where T.REF = cur.REF;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CARTA (REF, EMPRESA, IDIOMA, DOC_DATA, CIA, CONTATO, CIA_SUB, CONTATO_SUB, ASSUNTO, TEXTO, EMISSÃO_DATA, COM_CÓPIA, USUÁRIO, SUPERVISOR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.REF, cur.EMPRESA, cur.IDIOMA, cur.DOC_DATA, cur.CIA, cur.CONTATO, cur.CIA_SUB, cur.CONTATO_SUB, cur.ASSUNTO, cur.TEXTO, cur.EMISSÃO_DATA, cur.COM_CÓPIA, cur.USUÁRIO, cur.SUPERVISOR, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CARTA: ' || cur.REF || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CARTA inexistente: ' || cur.REF || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CARTA já manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CARTA já existente e manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.CARTA t set T.EMPRESA = cur.EMPRESA, T.IDIOMA = cur.IDIOMA, T.DOC_DATA = cur.DOC_DATA, T.CIA = cur.CIA, T.CONTATO = cur.CONTATO, T.CIA_SUB = cur.CIA_SUB, T.CONTATO_SUB = cur.CONTATO_SUB, T.ASSUNTO = cur.ASSUNTO, T.TEXTO = cur.TEXTO, T.EMISSÃO_DATA = cur.EMISSÃO_DATA, T.COM_CÓPIA = cur.COM_CÓPIA, T.USUÁRIO = cur.USUÁRIO, T.SUPERVISOR = cur.SUPERVISOR, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.REF = cur.REF;
                                                                        log(reglog, '> Atualização realizada do reg CARTA: ' || cur.REF || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CARTA com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CARTA já existente e com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CARTA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela FRETE
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CARGA_PORTO, DESCARGA_PORTO, PROPRIETÁRIO, FRETE_DETALHE, FRETE_UNID, FRETE_VALOR_POR_UNID, COMISSÃO_USD, COMISSÃO_PERCENT, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.FRETE_T T;
                                        reg CXSP.FRETE%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.FRETE T where T.CARGA_PORTO = cur.CARGA_PORTO and T.DESCARGA_PORTO = cur.DESCARGA_PORTO and T.PROPRIETÁRIO = cur.PROPRIETÁRIO and T.FRETE_DETALHE = cur.FRETE_DETALHE;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into FRETE (CARGA_PORTO, DESCARGA_PORTO, PROPRIETÁRIO, FRETE_DETALHE, FRETE_UNID, FRETE_VALOR_POR_UNID, COMISSÃO_USD, COMISSÃO_PERCENT, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CARGA_PORTO, cur.DESCARGA_PORTO, cur.PROPRIETÁRIO, cur.FRETE_DETALHE, cur.FRETE_UNID, cur.FRETE_VALOR_POR_UNID, cur.COMISSÃO_USD, cur.COMISSÃO_PERCENT, cur.OBS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg FRETE: ' || cur.CARGA_PORTO || cur.DESCARGA_PORTO || cur.PROPRIETÁRIO || cur.FRETE_DETALHE || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg FRETE inexistente: ' || cur.CARGA_PORTO || cur.DESCARGA_PORTO || cur.PROPRIETÁRIO || cur.FRETE_DETALHE || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg FRETE já manipulado localmente: ' || cur.CARGA_PORTO || cur.DESCARGA_PORTO || cur.PROPRIETÁRIO || cur.FRETE_DETALHE || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg FRETE já existente e manipulado localmente: ' || cur.CARGA_PORTO || cur.DESCARGA_PORTO || cur.PROPRIETÁRIO || cur.FRETE_DETALHE || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.FRETE t set T.FRETE_UNID = cur.FRETE_UNID, T.FRETE_VALOR_POR_UNID = cur.FRETE_VALOR_POR_UNID, T.COMISSÃO_USD = cur.COMISSÃO_USD, T.COMISSÃO_PERCENT = cur.COMISSÃO_PERCENT, T.OBS = cur.OBS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CARGA_PORTO = cur.CARGA_PORTO and T.DESCARGA_PORTO = cur.DESCARGA_PORTO and T.PROPRIETÁRIO = cur.PROPRIETÁRIO and T.FRETE_DETALHE = cur.FRETE_DETALHE;
                                                                        log(reglog, '> Atualização realizada do reg FRETE: ' || cur.CARGA_PORTO || cur.DESCARGA_PORTO || cur.PROPRIETÁRIO || cur.FRETE_DETALHE || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg FRETE com data local igual ou mais atual: ' || cur.CARGA_PORTO || cur.DESCARGA_PORTO || cur.PROPRIETÁRIO || cur.FRETE_DETALHE || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg FRETE já existente e com data local igual ou mais atual: ' || cur.CARGA_PORTO || cur.DESCARGA_PORTO || cur.PROPRIETÁRIO || cur.FRETE_DETALHE || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela FRETE - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CIA_RAMO_ATIVIDADE
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CIA_COD, RAMO_ATIVIDADE, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.CIA_RAMO_ATIVIDADE_T T;
                                        reg CXSP.CIA_RAMO_ATIVIDADE%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.CIA_RAMO_ATIVIDADE T where T.CIA_COD = cur.CIA_COD and T.RAMO_ATIVIDADE = cur.RAMO_ATIVIDADE;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CIA_RAMO_ATIVIDADE (CIA_COD, RAMO_ATIVIDADE, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CIA_COD, cur.RAMO_ATIVIDADE, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CIA_RAMO_ATIVIDADE: ' || cur.CIA_COD || cur.RAMO_ATIVIDADE || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CIA_RAMO_ATIVIDADE inexistente: ' || cur.CIA_COD || cur.RAMO_ATIVIDADE || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CIA_RAMO_ATIVIDADE já manipulado localmente: ' || cur.CIA_COD || cur.RAMO_ATIVIDADE || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CIA_RAMO_ATIVIDADE já existente e manipulado localmente: ' || cur.CIA_COD || cur.RAMO_ATIVIDADE || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.CIA_RAMO_ATIVIDADE t set T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CIA_COD = cur.CIA_COD and T.RAMO_ATIVIDADE = cur.RAMO_ATIVIDADE;
                                                                        log(reglog, '> Atualização realizada do reg CIA_RAMO_ATIVIDADE: ' || cur.CIA_COD || cur.RAMO_ATIVIDADE || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CIA_RAMO_ATIVIDADE com data local igual ou mais atual: ' || cur.CIA_COD || cur.RAMO_ATIVIDADE || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CIA_RAMO_ATIVIDADE já existente e com data local igual ou mais atual: ' || cur.CIA_COD || cur.RAMO_ATIVIDADE || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CIA_RAMO_ATIVIDADE - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PED_RESULT
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select PED_REF, SEQ, LANÇ, VALOR, VALOR_POR_MT, TOTAL_PERCENT, TOTAL_TIPO, COMPETÊNCIA, CALC, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.PED_RESULT_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                        reg CXSP.PED_RESULT%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.PED_RESULT T where T.PED_REF = cur.PED_REF and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PED_RESULT (PED_REF, SEQ, LANÇ, VALOR, VALOR_POR_MT, TOTAL_PERCENT, TOTAL_TIPO, COMPETÊNCIA, CALC, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.PED_REF, cur.SEQ, cur.LANÇ, cur.VALOR, cur.VALOR_POR_MT, cur.TOTAL_PERCENT, cur.TOTAL_TIPO, cur.COMPETÊNCIA, cur.CALC, cur.OBS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PED_RESULT: ' || cur.PED_REF || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PED_RESULT inexistente: ' || cur.PED_REF || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PED_RESULT já manipulado localmente: ' || cur.PED_REF || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PED_RESULT já existente e manipulado localmente: ' || cur.PED_REF || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.PED_RESULT t set T.LANÇ = cur.LANÇ, T.VALOR = cur.VALOR, T.VALOR_POR_MT = cur.VALOR_POR_MT, T.TOTAL_PERCENT = cur.TOTAL_PERCENT, T.TOTAL_TIPO = cur.TOTAL_TIPO, T.COMPETÊNCIA = cur.COMPETÊNCIA, T.CALC = cur.CALC, T.OBS = cur.OBS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.PED_REF = cur.PED_REF and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg PED_RESULT: ' || cur.PED_REF || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PED_RESULT com data local igual ou mais atual: ' || cur.PED_REF || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PED_RESULT já existente e com data local igual ou mais atual: ' || cur.PED_REF || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PED_RESULT - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CONFIRM_VENDA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select REF, SEQ, EMISSÃO_DATA, EMISSOR, PED_REF, OUTRA_REF, COMPRADOR, USUÁRIO_FINAL, DESTINATÁRIO, ENTREGA, CARGA_PORTO, IDIOMA, DIMENSÃO, PREÇO_DETALHE, ESPECIFICAÇÃO, EMBALAGEM, SEGURO, PAG, OBS, OBS_TERMOS, PRODUTOR, DESCARGA_PORTO, ASSINATURA, DT_REVISÃO, EMPRESA_REL, MOEDA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.CONFIRM_VENDA_T T WHERE T.REF LIKE 'SP%' OR T.REF LIKE 'RJP%';
                                        reg CXSP.CONFIRM_VENDA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.CONFIRM_VENDA T where T.REF = cur.REF and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CONFIRM_VENDA (REF, SEQ, EMISSÃO_DATA, EMISSOR, PED_REF, OUTRA_REF, COMPRADOR, USUÁRIO_FINAL, DESTINATÁRIO, ENTREGA, CARGA_PORTO, IDIOMA, DIMENSÃO, PREÇO_DETALHE, ESPECIFICAÇÃO, EMBALAGEM, SEGURO, PAG, OBS, OBS_TERMOS, PRODUTOR, DESCARGA_PORTO, ASSINATURA, DT_REVISÃO, EMPRESA_REL, MOEDA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.REF, cur.SEQ, cur.EMISSÃO_DATA, cur.EMISSOR, cur.PED_REF, cur.OUTRA_REF, cur.COMPRADOR, cur.USUÁRIO_FINAL, cur.DESTINATÁRIO, cur.ENTREGA, cur.CARGA_PORTO, cur.IDIOMA, cur.DIMENSÃO, cur.PREÇO_DETALHE, cur.ESPECIFICAÇÃO, cur.EMBALAGEM, cur.SEGURO, cur.PAG, cur.OBS, cur.OBS_TERMOS, cur.PRODUTOR, cur.DESCARGA_PORTO, cur.ASSINATURA, cur.DT_REVISÃO, cur.EMPRESA_REL, cur.MOEDA, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CONFIRM_VENDA: ' || cur.REF || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CONFIRM_VENDA inexistente: ' || cur.REF || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CONFIRM_VENDA já manipulado localmente: ' || cur.REF || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CONFIRM_VENDA já existente e manipulado localmente: ' || cur.REF || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.CONFIRM_VENDA t set T.EMISSÃO_DATA = cur.EMISSÃO_DATA, T.EMISSOR = cur.EMISSOR, T.PED_REF = cur.PED_REF, T.OUTRA_REF = cur.OUTRA_REF, T.COMPRADOR = cur.COMPRADOR, T.USUÁRIO_FINAL = cur.USUÁRIO_FINAL, T.DESTINATÁRIO = cur.DESTINATÁRIO, T.ENTREGA = cur.ENTREGA, T.CARGA_PORTO = cur.CARGA_PORTO, T.IDIOMA = cur.IDIOMA, T.DIMENSÃO = cur.DIMENSÃO, T.PREÇO_DETALHE = cur.PREÇO_DETALHE, T.ESPECIFICAÇÃO = cur.ESPECIFICAÇÃO, T.EMBALAGEM = cur.EMBALAGEM, T.SEGURO = cur.SEGURO, T.PAG = cur.PAG, T.OBS = cur.OBS, T.OBS_TERMOS = cur.OBS_TERMOS, T.PRODUTOR = cur.PRODUTOR, T.DESCARGA_PORTO = cur.DESCARGA_PORTO, T.ASSINATURA = cur.ASSINATURA, T.DT_REVISÃO = cur.DT_REVISÃO, T.EMPRESA_REL = cur.EMPRESA_REL, T.MOEDA = cur.MOEDA, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.REF = cur.REF and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg CONFIRM_VENDA: ' || cur.REF || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CONFIRM_VENDA com data local igual ou mais atual: ' || cur.REF || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CONFIRM_VENDA já existente e com data local igual ou mais atual: ' || cur.REF || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CONFIRM_VENDA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela EMB_F
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select PED_REF, SEQ, FATURA, INV_DATA, NAVIO, BL_DATA, COMPETÊNCIA, QUANTIDADE, VALOR, RESULT1, RESULT2, RESULT3, RESULT4, RESULT5, POSIÇÃO, OBSERVAÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.EMB_F_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                        reg CXSP.EMB_F%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.EMB_F T where T.PED_REF = cur.PED_REF and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into EMB_F (PED_REF, SEQ, FATURA, INV_DATA, NAVIO, BL_DATA, COMPETÊNCIA, QUANTIDADE, VALOR, RESULT1, RESULT2, RESULT3, RESULT4, RESULT5, POSIÇÃO, OBSERVAÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.PED_REF, cur.SEQ, cur.FATURA, cur.INV_DATA, cur.NAVIO, cur.BL_DATA, cur.COMPETÊNCIA, cur.QUANTIDADE, cur.VALOR, cur.RESULT1, cur.RESULT2, cur.RESULT3, cur.RESULT4, cur.RESULT5, cur.POSIÇÃO, cur.OBSERVAÇÃO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg EMB_F: ' || cur.PED_REF || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg EMB_F inexistente: ' || cur.PED_REF || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg EMB_F já manipulado localmente: ' || cur.PED_REF || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg EMB_F já existente e manipulado localmente: ' || cur.PED_REF || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.EMB_F t set T.FATURA = cur.FATURA, T.INV_DATA = cur.INV_DATA, T.NAVIO = cur.NAVIO, T.BL_DATA = cur.BL_DATA, T.COMPETÊNCIA = cur.COMPETÊNCIA, T.QUANTIDADE = cur.QUANTIDADE, T.VALOR = cur.VALOR, T.RESULT1 = cur.RESULT1, T.RESULT2 = cur.RESULT2, T.RESULT3 = cur.RESULT3, T.RESULT4 = cur.RESULT4, T.RESULT5 = cur.RESULT5, T.POSIÇÃO = cur.POSIÇÃO, T.OBSERVAÇÃO = cur.OBSERVAÇÃO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.PED_REF = cur.PED_REF and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg EMB_F: ' || cur.PED_REF || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg EMB_F com data local igual ou mais atual: ' || cur.PED_REF || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg EMB_F já existente e com data local igual ou mais atual: ' || cur.PED_REF || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela EMB_F - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PED_CONTATO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select PED_REF, CIA_COD, CONTATO_NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.PED_CONTATO_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                        reg CXSP.PED_CONTATO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.PED_CONTATO T where T.PED_REF = cur.PED_REF and T.CIA_COD = cur.CIA_COD and T.CONTATO_NOME = cur.CONTATO_NOME;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PED_CONTATO (PED_REF, CIA_COD, CONTATO_NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.PED_REF, cur.CIA_COD, cur.CONTATO_NOME, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PED_CONTATO: ' || cur.PED_REF || cur.CIA_COD || cur.CONTATO_NOME || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PED_CONTATO inexistente: ' || cur.PED_REF || cur.CIA_COD || cur.CONTATO_NOME || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PED_CONTATO já manipulado localmente: ' || cur.PED_REF || cur.CIA_COD || cur.CONTATO_NOME || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PED_CONTATO já existente e manipulado localmente: ' || cur.PED_REF || cur.CIA_COD || cur.CONTATO_NOME || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.PED_CONTATO t set T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.PED_REF = cur.PED_REF and T.CIA_COD = cur.CIA_COD and T.CONTATO_NOME = cur.CONTATO_NOME;
                                                                        log(reglog, '> Atualização realizada do reg PED_CONTATO: ' || cur.PED_REF || cur.CIA_COD || cur.CONTATO_NOME || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PED_CONTATO com data local igual ou mais atual: ' || cur.PED_REF || cur.CIA_COD || cur.CONTATO_NOME || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PED_CONTATO já existente e com data local igual ou mais atual: ' || cur.PED_REF || cur.CIA_COD || cur.CONTATO_NOME || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PED_CONTATO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela EMB
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CALC_NOMINAL_PED, REF, VIAGEM, FRETE_UNID, FRETE_VALOR, FRETE_POR_MT, FRETE_VALOR_POR_UNID, FRETE_VALOR_TOTAL, FRETE_COND, DATA_EMBARQUE, DATA_EMISSÃO_DOC, CARGA_PORTO, DESCARGA_PORTO, TRANSPORTADOR, MOEDA, IDIOMA, PESO_UNID, PREÇO_UNITÁRIO_UNID, PREÇO_UNID, NEGOCIADOR, EMBARCADOR, EMB_ENDEREÇO, EMB_PAÍS, EMB_COND_VENDA, EMB_COND_PAG, EMB_COMENTÁRIOS, EXP, EXP_ENDEREÇO, EXP_PAÍS, EXP_COND_VENDA, EXP_COND_PAG, EXP_COMENTÁRIOS, EXP_LOGOTIPO, EXP_FAT, IMP, IMP_ENDEREÇO, IMP_PAÍS, IMP_COND_VENDA, IMP_COND_PAG, IMP_COMENTÁRIOS, IMP_LOGOTIPO, IMP_FAT, PAGADOR, PAG_ENDEREÇO, PAG_PAÍS, CONSIGNATÁRIO, CONSIGN_ENDEREÇO, CONSIGN_PAÍS, NOTIFICAR, NOTIFICAR_ENDEREÇO, NOTIFICAR_PAÍS, NUM_BL_DESCR, FAMÍLIA_GENÉRICA, TIPO_DESCR_MERCADORIA, MARCAÇÃO, TOTALIZAÇÃO_EMBALAGEM, CONFIG, EMB_ACORDO, VIA_TRANSPORTE, CARTA_CRED_REF, EMB_DATA, CARTA_CRÉDITO_BANCO_ABRIDOR, CARTA_CRÉDITO_REF, BANCO_AVISADOR, BANCO_CONFIRM, CALC_QTD_PED_UNID, CALC_PESO_LÍQUIDO, CALC_PESO_BRUTO, CALC_QTD_VOL, CALC_EXP_TOT_ITEM, CALC_EXP_TOT_EMB, CALC_EXP_COND_PAG, CALC_EXP_COND_VENDA, CALC_IMP_TOT_ITEM, CALC_IMP_TOT_EMB, CALC_IMP_COND_PAG, CALC_IMP_COND_VENDA, CALC_FRETE_TOTAL, CALC_PEND, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.EMB_T T;
                                        reg CXSP.EMB%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.EMB T where T.REF = cur.REF;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into EMB (CALC_NOMINAL_PED, REF, VIAGEM, FRETE_UNID, FRETE_VALOR, FRETE_POR_MT, FRETE_VALOR_POR_UNID, FRETE_VALOR_TOTAL, FRETE_COND, DATA_EMBARQUE, DATA_EMISSÃO_DOC, CARGA_PORTO, DESCARGA_PORTO, TRANSPORTADOR, MOEDA, IDIOMA, PESO_UNID, PREÇO_UNITÁRIO_UNID, PREÇO_UNID, NEGOCIADOR, EMBARCADOR, EMB_ENDEREÇO, EMB_PAÍS, EMB_COND_VENDA, EMB_COND_PAG, EMB_COMENTÁRIOS, EXP, EXP_ENDEREÇO, EXP_PAÍS, EXP_COND_VENDA, EXP_COND_PAG, EXP_COMENTÁRIOS, EXP_LOGOTIPO, EXP_FAT, IMP, IMP_ENDEREÇO, IMP_PAÍS, IMP_COND_VENDA, IMP_COND_PAG, IMP_COMENTÁRIOS, IMP_LOGOTIPO, IMP_FAT, PAGADOR, PAG_ENDEREÇO, PAG_PAÍS, CONSIGNATÁRIO, CONSIGN_ENDEREÇO, CONSIGN_PAÍS, NOTIFICAR, NOTIFICAR_ENDEREÇO, NOTIFICAR_PAÍS, NUM_BL_DESCR, FAMÍLIA_GENÉRICA, TIPO_DESCR_MERCADORIA, MARCAÇÃO, TOTALIZAÇÃO_EMBALAGEM, CONFIG, EMB_ACORDO, VIA_TRANSPORTE, CARTA_CRED_REF, EMB_DATA, CARTA_CRÉDITO_BANCO_ABRIDOR, CARTA_CRÉDITO_REF, BANCO_AVISADOR, BANCO_CONFIRM, CALC_QTD_PED_UNID, CALC_PESO_LÍQUIDO, CALC_PESO_BRUTO, CALC_QTD_VOL, CALC_EXP_TOT_ITEM, CALC_EXP_TOT_EMB, CALC_EXP_COND_PAG, CALC_EXP_COND_VENDA, CALC_IMP_TOT_ITEM, CALC_IMP_TOT_EMB, CALC_IMP_COND_PAG, CALC_IMP_COND_VENDA, CALC_FRETE_TOTAL, CALC_PEND, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CALC_NOMINAL_PED, cur.REF, cur.VIAGEM, cur.FRETE_UNID, cur.FRETE_VALOR, cur.FRETE_POR_MT, cur.FRETE_VALOR_POR_UNID, 
                                                        cur.FRETE_VALOR_TOTAL, cur.FRETE_COND, cur.DATA_EMBARQUE, cur.DATA_EMISSÃO_DOC, cur.CARGA_PORTO, cur.DESCARGA_PORTO, cur.TRANSPORTADOR, cur.MOEDA, cur.IDIOMA, cur.PESO_UNID, cur.PREÇO_UNITÁRIO_UNID, cur.PREÇO_UNID, cur.NEGOCIADOR, cur.EMBARCADOR, cur.EMB_ENDEREÇO, cur.EMB_PAÍS, cur.EMB_COND_VENDA, cur.EMB_COND_PAG, cur.EMB_COMENTÁRIOS, cur.EXP, cur.EXP_ENDEREÇO, cur.EXP_PAÍS, cur.EXP_COND_VENDA, cur.EXP_COND_PAG, cur.EXP_COMENTÁRIOS, cur.EXP_LOGOTIPO, cur.EXP_FAT, cur.IMP, cur.IMP_ENDEREÇO, cur.IMP_PAÍS, cur.IMP_COND_VENDA, cur.IMP_COND_PAG, cur.IMP_COMENTÁRIOS, cur.IMP_LOGOTIPO, cur.IMP_FAT, cur.PAGADOR, cur.PAG_ENDEREÇO, cur.PAG_PAÍS, cur.CONSIGNATÁRIO, cur.CONSIGN_ENDEREÇO, cur.CONSIGN_PAÍS, cur.NOTIFICAR, cur.NOTIFICAR_ENDEREÇO, cur.NOTIFICAR_PAÍS, cur.NUM_BL_DESCR, cur.FAMÍLIA_GENÉRICA, cur.TIPO_DESCR_MERCADORIA, cur.MARCAÇÃO, cur.TOTALIZAÇÃO_EMBALAGEM, cur.CONFIG, cur.EMB_ACORDO, cur.VIA_TRANSPORTE, cur.CARTA_CRED_REF, cur.EMB_DATA, cur.CARTA_CRÉDITO_BANCO_ABRIDOR, cur.CARTA_CRÉDITO_REF, cur.BANCO_AVISADOR, cur.BANCO_CONFIRM, cur.CALC_QTD_PED_UNID, cur.CALC_PESO_LÍQUIDO, cur.CALC_PESO_BRUTO, cur.CALC_QTD_VOL, cur.CALC_EXP_TOT_ITEM, cur.CALC_EXP_TOT_EMB, cur.CALC_EXP_COND_PAG, cur.CALC_EXP_COND_VENDA, cur.CALC_IMP_TOT_ITEM, cur.CALC_IMP_TOT_EMB, cur.CALC_IMP_COND_PAG, cur.CALC_IMP_COND_VENDA, cur.CALC_FRETE_TOTAL, cur.CALC_PEND, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, 
                                                        cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg EMB: ' || cur.REF || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg EMB inexistente: ' || cur.REF || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg EMB já manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg EMB já existente e manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.EMB t set T.CALC_NOMINAL_PED = cur.CALC_NOMINAL_PED, T.VIAGEM = cur.VIAGEM, T.FRETE_UNID = cur.FRETE_UNID, T.FRETE_VALOR = cur.FRETE_VALOR, T.FRETE_POR_MT = cur.FRETE_POR_MT, T.FRETE_VALOR_POR_UNID = cur.FRETE_VALOR_POR_UNID, T.FRETE_VALOR_TOTAL = cur.FRETE_VALOR_TOTAL, T.FRETE_COND = cur.FRETE_COND, T.DATA_EMBARQUE = cur.DATA_EMBARQUE, T.DATA_EMISSÃO_DOC = cur.DATA_EMISSÃO_DOC, T.CARGA_PORTO = cur.CARGA_PORTO, T.DESCARGA_PORTO = cur.DESCARGA_PORTO, T.TRANSPORTADOR = cur.TRANSPORTADOR, T.MOEDA = cur.MOEDA, T.IDIOMA = cur.IDIOMA, T.PESO_UNID = cur.PESO_UNID, T.PREÇO_UNITÁRIO_UNID = cur.PREÇO_UNITÁRIO_UNID, T.PREÇO_UNID = cur.PREÇO_UNID, T.NEGOCIADOR = cur.NEGOCIADOR, T.EMBARCADOR = cur.EMBARCADOR, T.EMB_ENDEREÇO = cur.EMB_ENDEREÇO, T.EMB_PAÍS = cur.EMB_PAÍS, T.EMB_COND_VENDA = cur.EMB_COND_VENDA, T.EMB_COND_PAG = cur.EMB_COND_PAG, T.EMB_COMENTÁRIOS = cur.EMB_COMENTÁRIOS, T.EXP = cur.EXP, T.EXP_ENDEREÇO = cur.EXP_ENDEREÇO, T.EXP_PAÍS = cur.EXP_PAÍS, T.EXP_COND_VENDA = cur.EXP_COND_VENDA, T.EXP_COND_PAG = cur.EXP_COND_PAG, T.EXP_COMENTÁRIOS = cur.EXP_COMENTÁRIOS, T.EXP_LOGOTIPO = cur.EXP_LOGOTIPO, T.EXP_FAT = cur.EXP_FAT, T.IMP = cur.IMP, T.IMP_ENDEREÇO = cur.IMP_ENDEREÇO, T.IMP_PAÍS = cur.IMP_PAÍS, T.IMP_COND_VENDA = cur.IMP_COND_VENDA, T.IMP_COND_PAG = cur.IMP_COND_PAG, T.IMP_COMENTÁRIOS = cur.IMP_COMENTÁRIOS, T.IMP_LOGOTIPO = cur.IMP_LOGOTIPO, T.IMP_FAT = cur.IMP_FAT, T.PAGADOR = cur.PAGADOR, T.PAG_ENDEREÇO = 
                                                                        cur.PAG_ENDEREÇO, T.PAG_PAÍS = cur.PAG_PAÍS, T.CONSIGNATÁRIO = cur.CONSIGNATÁRIO, T.CONSIGN_ENDEREÇO = cur.CONSIGN_ENDEREÇO, T.CONSIGN_PAÍS = cur.CONSIGN_PAÍS, T.NOTIFICAR = cur.NOTIFICAR, T.NOTIFICAR_ENDEREÇO = cur.NOTIFICAR_ENDEREÇO, T.NOTIFICAR_PAÍS = cur.NOTIFICAR_PAÍS, T.NUM_BL_DESCR = cur.NUM_BL_DESCR, T.FAMÍLIA_GENÉRICA = cur.FAMÍLIA_GENÉRICA, T.TIPO_DESCR_MERCADORIA = cur.TIPO_DESCR_MERCADORIA, T.MARCAÇÃO = cur.MARCAÇÃO, T.TOTALIZAÇÃO_EMBALAGEM = cur.TOTALIZAÇÃO_EMBALAGEM, T.CONFIG = cur.CONFIG, T.EMB_ACORDO = cur.EMB_ACORDO, T.VIA_TRANSPORTE = cur.VIA_TRANSPORTE, T.CARTA_CRED_REF = cur.CARTA_CRED_REF, T.EMB_DATA = cur.EMB_DATA, T.CARTA_CRÉDITO_BANCO_ABRIDOR = cur.CARTA_CRÉDITO_BANCO_ABRIDOR, T.CARTA_CRÉDITO_REF = cur.CARTA_CRÉDITO_REF, T.BANCO_AVISADOR = cur.BANCO_AVISADOR, T.BANCO_CONFIRM = cur.BANCO_CONFIRM, T.CALC_QTD_PED_UNID = cur.CALC_QTD_PED_UNID, T.CALC_PESO_LÍQUIDO = cur.CALC_PESO_LÍQUIDO, T.CALC_PESO_BRUTO = cur.CALC_PESO_BRUTO, T.CALC_QTD_VOL = cur.CALC_QTD_VOL, T.CALC_EXP_TOT_ITEM = cur.CALC_EXP_TOT_ITEM, T.CALC_EXP_TOT_EMB = cur.CALC_EXP_TOT_EMB, T.CALC_EXP_COND_PAG = cur.CALC_EXP_COND_PAG, T.CALC_EXP_COND_VENDA = cur.CALC_EXP_COND_VENDA, T.CALC_IMP_TOT_ITEM = cur.CALC_IMP_TOT_ITEM, T.CALC_IMP_TOT_EMB = cur.CALC_IMP_TOT_EMB, T.CALC_IMP_COND_PAG = cur.CALC_IMP_COND_PAG, T.CALC_IMP_COND_VENDA = cur.CALC_IMP_COND_VENDA, T.CALC_FRETE_TOTAL = cur.CALC_FRETE_TOTAL, T.CALC_PEND = cur.CALC_PEND, 
                                                                        T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.REF = cur.REF;
                                                                        log(reglog, '> Atualização realizada do reg EMB: ' || cur.REF || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg EMB com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg EMB já existente e com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela EMB - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PED_ITEM
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select PED_REF, ITEM, USUÁRIO_FINAL, USUÁRIO_REF, PED_UNID, NOMINAL_PED_UNID, TOTAL_FECH, TOTAL_EMB, TOLERÂNCIA_MIN, TOLERÂNCIA_MAX, PROD, DESCARGA_PORTO, EMBALAGEM, EMBALAGEM_PESO_MIN, EMBALAGEM_PESO_MAX, PREÇO_UNITÁRIO_FORNECEDOR, PREÇO_UNITÁRIO_EXP, PREÇO_UNITÁRIO_IMP, ESPESSURA_TIPO, ESPESSURA_MM, LARGURA_MM, COMPRIMENTO_MM, ESPESSURA_POL, LARGURA_POL, COMPRIMENTO_POL, NCM, NALADI, P, LOTE, OV, NE_ITEM, NE_ENVIO, TBN, FSE, PO, BL_CODE, USO_FINAL, DIÂMETRO_INTERNO, DIÂMETRO_EXTERNO, PESO_POR_FOLHA, AÇO_TIPO, REVESTIMENTO, TÊMPERA, ACABAMENTO, NORMA_TOLERÂNCIA, NORMA_PRODUÇÃO, BORDAS, OLEAMENTO, TRAT_TÉRMICO, TRAT_QUÍMICO, LA, LE, LÍNGUA, PROD_DESCR, COMPOSIÇÃO_QUÍMICA, MARCAÇÃO_PRODUÇÃO, COMENTÁRIO, PED_USINA_DATA, PED_USINA_ID, PED_USINA_CONFIRM, LAYDAY_INÍCIO, LAYDAY_FINAL, QTD_VOL, PESO_LÍQUIDO, PESO_BRUTO, FECH_REQUISITADO, FECH_NOTIFICADO, CANCEL_DATA, CANCEL_MOTIVO, SEGURO_PERCENT, CUR_PERCENT, SUPERFÍCIE, DIAMET_INT_MAX_TOLER, DIAMET_INT_MIM_TOLER, TQ, CERTIF_QUALIDADE, RABO_PEIXE, RABO_PEIXE_MAX, LÍNGUA_MAX, MARCAÇÃO_ESPECIAL_DOC, OBS, MARCAÇÃO, NOMINAL_MT, DIMENSÃO, TOL_CSN, RECOZIDO_CSN, TOL_ESPESSURA_CSN, TOL_LARGURA_CSN, TOL_COMPRIMENTO_CSN, MARCAÇÃO_DIF_CSN, FACE_PESADA_CSN, APLAINAMENTO_CSN, PASSIVAÇÃO_CSN, ACABAMENTO_CSN, FAIXA_PESO_CSN, SOLDAS_CSN, NUM_SOLDAS_CSN, MARCAÇÃO_SOLDA_CSN, VERNIZ_DOURADO_CSN, POSIÇÃO_FOLHA_PALLET_CSN, RUGOSIDADE_CSN, ESQUADRIA_CSN, NUM_CONSULTA_CSN, 
                                        TOLERÂNCIA_PADRÃO_CSN, MARCAÇOES_ADICIONAIS_CSN, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.PED_ITEM_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                        reg CXSP.PED_ITEM%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.PED_ITEM T where T.PED_REF = cur.PED_REF and T.ITEM = cur.ITEM;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PED_ITEM (PED_REF, ITEM, USUÁRIO_FINAL, USUÁRIO_REF, PED_UNID, NOMINAL_PED_UNID, TOTAL_FECH, TOTAL_EMB, TOLERÂNCIA_MIN, TOLERÂNCIA_MAX, PROD, DESCARGA_PORTO, EMBALAGEM, EMBALAGEM_PESO_MIN, EMBALAGEM_PESO_MAX, PREÇO_UNITÁRIO_FORNECEDOR, PREÇO_UNITÁRIO_EXP, PREÇO_UNITÁRIO_IMP, ESPESSURA_TIPO, ESPESSURA_MM, LARGURA_MM, COMPRIMENTO_MM, ESPESSURA_POL, LARGURA_POL, COMPRIMENTO_POL, NCM, NALADI, P, LOTE, OV, NE_ITEM, NE_ENVIO, TBN, FSE, PO, BL_CODE, USO_FINAL, DIÂMETRO_INTERNO, DIÂMETRO_EXTERNO, PESO_POR_FOLHA, AÇO_TIPO, REVESTIMENTO, TÊMPERA, ACABAMENTO, NORMA_TOLERÂNCIA, NORMA_PRODUÇÃO, BORDAS, OLEAMENTO, TRAT_TÉRMICO, TRAT_QUÍMICO, LA, LE, LÍNGUA, PROD_DESCR, COMPOSIÇÃO_QUÍMICA, MARCAÇÃO_PRODUÇÃO, COMENTÁRIO, PED_USINA_DATA, PED_USINA_ID, PED_USINA_CONFIRM, LAYDAY_INÍCIO, LAYDAY_FINAL, QTD_VOL, PESO_LÍQUIDO, PESO_BRUTO, FECH_REQUISITADO, FECH_NOTIFICADO, CANCEL_DATA, CANCEL_MOTIVO, SEGURO_PERCENT, CUR_PERCENT, SUPERFÍCIE, DIAMET_INT_MAX_TOLER, DIAMET_INT_MIM_TOLER, TQ, CERTIF_QUALIDADE, RABO_PEIXE, RABO_PEIXE_MAX, LÍNGUA_MAX, MARCAÇÃO_ESPECIAL_DOC, OBS, MARCAÇÃO, NOMINAL_MT, DIMENSÃO, TOL_CSN, RECOZIDO_CSN, TOL_ESPESSURA_CSN, TOL_LARGURA_CSN, TOL_COMPRIMENTO_CSN, MARCAÇÃO_DIF_CSN, FACE_PESADA_CSN, APLAINAMENTO_CSN, PASSIVAÇÃO_CSN, ACABAMENTO_CSN, FAIXA_PESO_CSN, SOLDAS_CSN, NUM_SOLDAS_CSN, MARCAÇÃO_SOLDA_CSN, VERNIZ_DOURADO_CSN, POSIÇÃO_FOLHA_PALLET_CSN, RUGOSIDADE_CSN, ESQUADRIA_CSN, NUM_CONSULTA_CSN, 
                                                        TOLERÂNCIA_PADRÃO_CSN, MARCAÇOES_ADICIONAIS_CSN, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.PED_REF, cur.ITEM, cur.USUÁRIO_FINAL, cur.USUÁRIO_REF, cur.PED_UNID, cur.NOMINAL_PED_UNID, cur.TOTAL_FECH, cur.TOTAL_EMB, cur.TOLERÂNCIA_MIN, cur.TOLERÂNCIA_MAX, cur.PROD, cur.DESCARGA_PORTO, cur.EMBALAGEM, cur.EMBALAGEM_PESO_MIN, cur.EMBALAGEM_PESO_MAX, cur.PREÇO_UNITÁRIO_FORNECEDOR, cur.PREÇO_UNITÁRIO_EXP, cur.PREÇO_UNITÁRIO_IMP, cur.ESPESSURA_TIPO, cur.ESPESSURA_MM, cur.LARGURA_MM, cur.COMPRIMENTO_MM, cur.ESPESSURA_POL, cur.LARGURA_POL, cur.COMPRIMENTO_POL, cur.NCM, cur.NALADI, cur.P, cur.LOTE, cur.OV, cur.NE_ITEM, cur.NE_ENVIO, cur.TBN, cur.FSE, cur.PO, cur.BL_CODE, cur.USO_FINAL, cur.DIÂMETRO_INTERNO, cur.DIÂMETRO_EXTERNO, cur.PESO_POR_FOLHA, cur.AÇO_TIPO, cur.REVESTIMENTO, cur.TÊMPERA, cur.ACABAMENTO, cur.NORMA_TOLERÂNCIA, cur.NORMA_PRODUÇÃO, cur.BORDAS, cur.OLEAMENTO, cur.TRAT_TÉRMICO, cur.TRAT_QUÍMICO, cur.LA, cur.LE, cur.LÍNGUA, cur.PROD_DESCR, cur.COMPOSIÇÃO_QUÍMICA, cur.MARCAÇÃO_PRODUÇÃO, cur.COMENTÁRIO, cur.PED_USINA_DATA, cur.PED_USINA_ID, cur.PED_USINA_CONFIRM, cur.LAYDAY_INÍCIO, cur.LAYDAY_FINAL, cur.QTD_VOL, cur.PESO_LÍQUIDO, cur.PESO_BRUTO, cur.FECH_REQUISITADO, cur.FECH_NOTIFICADO, cur.CANCEL_DATA, cur.CANCEL_MOTIVO, cur.SEGURO_PERCENT, cur.CUR_PERCENT, cur.SUPERFÍCIE, cur.DIAMET_INT_MAX_TOLER, cur.DIAMET_INT_MIM_TOLER, 
                                                        cur.TQ, cur.CERTIF_QUALIDADE, cur.RABO_PEIXE, cur.RABO_PEIXE_MAX, cur.LÍNGUA_MAX, cur.MARCAÇÃO_ESPECIAL_DOC, cur.OBS, cur.MARCAÇÃO, cur.NOMINAL_MT, cur.DIMENSÃO, cur.TOL_CSN, cur.RECOZIDO_CSN, cur.TOL_ESPESSURA_CSN, cur.TOL_LARGURA_CSN, cur.TOL_COMPRIMENTO_CSN, cur.MARCAÇÃO_DIF_CSN, cur.FACE_PESADA_CSN, cur.APLAINAMENTO_CSN, cur.PASSIVAÇÃO_CSN, cur.ACABAMENTO_CSN, cur.FAIXA_PESO_CSN, cur.SOLDAS_CSN, cur.NUM_SOLDAS_CSN, cur.MARCAÇÃO_SOLDA_CSN, cur.VERNIZ_DOURADO_CSN, cur.POSIÇÃO_FOLHA_PALLET_CSN, cur.RUGOSIDADE_CSN, cur.ESQUADRIA_CSN, cur.NUM_CONSULTA_CSN, cur.TOLERÂNCIA_PADRÃO_CSN, cur.MARCAÇOES_ADICIONAIS_CSN, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PED_ITEM: ' || cur.PED_REF || cur.ITEM || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PED_ITEM inexistente: ' || cur.PED_REF || cur.ITEM || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PED_ITEM já manipulado localmente: ' || cur.PED_REF || cur.ITEM || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PED_ITEM já existente e manipulado localmente: ' || cur.PED_REF || cur.ITEM || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.PED_ITEM t set T.USUÁRIO_FINAL = cur.USUÁRIO_FINAL, T.USUÁRIO_REF = cur.USUÁRIO_REF, T.PED_UNID = cur.PED_UNID, T.NOMINAL_PED_UNID = cur.NOMINAL_PED_UNID, T.TOTAL_FECH = cur.TOTAL_FECH, T.TOTAL_EMB = cur.TOTAL_EMB, T.TOLERÂNCIA_MIN = cur.TOLERÂNCIA_MIN, T.TOLERÂNCIA_MAX = cur.TOLERÂNCIA_MAX, T.PROD = cur.PROD, T.DESCARGA_PORTO = cur.DESCARGA_PORTO, T.EMBALAGEM = cur.EMBALAGEM, T.EMBALAGEM_PESO_MIN = cur.EMBALAGEM_PESO_MIN, T.EMBALAGEM_PESO_MAX = cur.EMBALAGEM_PESO_MAX, T.PREÇO_UNITÁRIO_FORNECEDOR = cur.PREÇO_UNITÁRIO_FORNECEDOR, T.PREÇO_UNITÁRIO_EXP = cur.PREÇO_UNITÁRIO_EXP, T.PREÇO_UNITÁRIO_IMP = cur.PREÇO_UNITÁRIO_IMP, T.ESPESSURA_TIPO = cur.ESPESSURA_TIPO, T.ESPESSURA_MM = cur.ESPESSURA_MM, T.LARGURA_MM = cur.LARGURA_MM, T.COMPRIMENTO_MM = cur.COMPRIMENTO_MM, T.ESPESSURA_POL = cur.ESPESSURA_POL, T.LARGURA_POL = cur.LARGURA_POL, T.COMPRIMENTO_POL = cur.COMPRIMENTO_POL, T.NCM = cur.NCM, T.NALADI = cur.NALADI, T.P = cur.P, T.LOTE = cur.LOTE, T.OV = cur.OV, T.NE_ITEM = cur.NE_ITEM, T.NE_ENVIO = cur.NE_ENVIO, T.TBN = cur.TBN, T.FSE = cur.FSE, T.PO = cur.PO, T.BL_CODE = cur.BL_CODE, T.USO_FINAL = cur.USO_FINAL, T.DIÂMETRO_INTERNO = cur.DIÂMETRO_INTERNO, T.DIÂMETRO_EXTERNO = cur.DIÂMETRO_EXTERNO, T.PESO_POR_FOLHA = cur.PESO_POR_FOLHA, T.AÇO_TIPO = cur.AÇO_TIPO, T.REVESTIMENTO = cur.REVESTIMENTO, T.TÊMPERA = cur.TÊMPERA, T.ACABAMENTO = cur.ACABAMENTO, T.NORMA_TOLERÂNCIA = cur.NORMA_TOLERÂNCIA, T.NORMA_PRODUÇÃO = 
                                                                        cur.NORMA_PRODUÇÃO, T.BORDAS = cur.BORDAS, T.OLEAMENTO = cur.OLEAMENTO, T.TRAT_TÉRMICO = cur.TRAT_TÉRMICO, T.TRAT_QUÍMICO = cur.TRAT_QUÍMICO, T.LA = cur.LA, T.LE = cur.LE, T.LÍNGUA = cur.LÍNGUA, T.PROD_DESCR = cur.PROD_DESCR, T.COMPOSIÇÃO_QUÍMICA = cur.COMPOSIÇÃO_QUÍMICA, T.MARCAÇÃO_PRODUÇÃO = cur.MARCAÇÃO_PRODUÇÃO, T.COMENTÁRIO = cur.COMENTÁRIO, T.PED_USINA_DATA = cur.PED_USINA_DATA, T.PED_USINA_ID = cur.PED_USINA_ID, T.PED_USINA_CONFIRM = cur.PED_USINA_CONFIRM, T.LAYDAY_INÍCIO = cur.LAYDAY_INÍCIO, T.LAYDAY_FINAL = cur.LAYDAY_FINAL, T.QTD_VOL = cur.QTD_VOL, T.PESO_LÍQUIDO = cur.PESO_LÍQUIDO, T.PESO_BRUTO = cur.PESO_BRUTO, T.FECH_REQUISITADO = cur.FECH_REQUISITADO, T.FECH_NOTIFICADO = cur.FECH_NOTIFICADO, T.CANCEL_DATA = cur.CANCEL_DATA, T.CANCEL_MOTIVO = cur.CANCEL_MOTIVO, T.SEGURO_PERCENT = cur.SEGURO_PERCENT, T.CUR_PERCENT = cur.CUR_PERCENT, T.SUPERFÍCIE = cur.SUPERFÍCIE, T.DIAMET_INT_MAX_TOLER = cur.DIAMET_INT_MAX_TOLER, T.DIAMET_INT_MIM_TOLER = cur.DIAMET_INT_MIM_TOLER, T.TQ = cur.TQ, T.CERTIF_QUALIDADE = cur.CERTIF_QUALIDADE, T.RABO_PEIXE = cur.RABO_PEIXE, T.RABO_PEIXE_MAX = cur.RABO_PEIXE_MAX, T.LÍNGUA_MAX = cur.LÍNGUA_MAX, T.MARCAÇÃO_ESPECIAL_DOC = cur.MARCAÇÃO_ESPECIAL_DOC, T.OBS = cur.OBS, T.MARCAÇÃO = cur.MARCAÇÃO, T.NOMINAL_MT = cur.NOMINAL_MT, T.DIMENSÃO = cur.DIMENSÃO, T.TOL_CSN = cur.TOL_CSN, T.RECOZIDO_CSN = cur.RECOZIDO_CSN, T.TOL_ESPESSURA_CSN = cur.TOL_ESPESSURA_CSN, T.TOL_LARGURA_CSN = cur.TOL_LARGURA_CSN, 
                                                                        T.TOL_COMPRIMENTO_CSN = cur.TOL_COMPRIMENTO_CSN, T.MARCAÇÃO_DIF_CSN = cur.MARCAÇÃO_DIF_CSN, T.FACE_PESADA_CSN = cur.FACE_PESADA_CSN, T.APLAINAMENTO_CSN = cur.APLAINAMENTO_CSN, T.PASSIVAÇÃO_CSN = cur.PASSIVAÇÃO_CSN, T.ACABAMENTO_CSN = cur.ACABAMENTO_CSN, T.FAIXA_PESO_CSN = cur.FAIXA_PESO_CSN, T.SOLDAS_CSN = cur.SOLDAS_CSN, T.NUM_SOLDAS_CSN = cur.NUM_SOLDAS_CSN, T.MARCAÇÃO_SOLDA_CSN = cur.MARCAÇÃO_SOLDA_CSN, T.VERNIZ_DOURADO_CSN = cur.VERNIZ_DOURADO_CSN, T.POSIÇÃO_FOLHA_PALLET_CSN = cur.POSIÇÃO_FOLHA_PALLET_CSN, T.RUGOSIDADE_CSN = cur.RUGOSIDADE_CSN, T.ESQUADRIA_CSN = cur.ESQUADRIA_CSN, T.NUM_CONSULTA_CSN = cur.NUM_CONSULTA_CSN, T.TOLERÂNCIA_PADRÃO_CSN = cur.TOLERÂNCIA_PADRÃO_CSN, T.MARCAÇOES_ADICIONAIS_CSN = cur.MARCAÇOES_ADICIONAIS_CSN, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.PED_REF = cur.PED_REF and T.ITEM = cur.ITEM;
                                                                        log(reglog, '> Atualização realizada do reg PED_ITEM: ' || cur.PED_REF || cur.ITEM || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PED_ITEM com data local igual ou mais atual: ' || cur.PED_REF || cur.ITEM || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PED_ITEM já existente e com data local igual ou mais atual: ' || cur.PED_REF || cur.ITEM || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PED_ITEM - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PED_LANÇ
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select PED_REF, SEQ, LANÇ, VALOR, VALOR_POR_MT, TOTAL_PERCENT, TOTAL_TIPO, EXP, IMP, BENEFICIÁRIO, COMISSÃO_MODALIDADE, INSTRUÇÃO_REMESSA, EXP_CALC, IMP_CALC, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.PED_LANÇ_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                        reg CXSP.PED_LANÇ%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.PED_LANÇ T where T.PED_REF = cur.PED_REF and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PED_LANÇ (PED_REF, SEQ, LANÇ, VALOR, VALOR_POR_MT, TOTAL_PERCENT, TOTAL_TIPO, EXP, IMP, BENEFICIÁRIO, COMISSÃO_MODALIDADE, INSTRUÇÃO_REMESSA, EXP_CALC, IMP_CALC, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.PED_REF, cur.SEQ, cur.LANÇ, cur.VALOR, cur.VALOR_POR_MT, cur.TOTAL_PERCENT, cur.TOTAL_TIPO, cur.EXP, cur.IMP, cur.BENEFICIÁRIO, cur.COMISSÃO_MODALIDADE, cur.INSTRUÇÃO_REMESSA, cur.EXP_CALC, cur.IMP_CALC, cur.OBS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PED_LANÇ: ' || cur.PED_REF || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PED_LANÇ inexistente: ' || cur.PED_REF || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PED_LANÇ já manipulado localmente: ' || cur.PED_REF || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PED_LANÇ já existente e manipulado localmente: ' || cur.PED_REF || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.PED_LANÇ t set T.LANÇ = cur.LANÇ, T.VALOR = cur.VALOR, T.VALOR_POR_MT = cur.VALOR_POR_MT, T.TOTAL_PERCENT = cur.TOTAL_PERCENT, T.TOTAL_TIPO = cur.TOTAL_TIPO, T.EXP = cur.EXP, T.IMP = cur.IMP, T.BENEFICIÁRIO = cur.BENEFICIÁRIO, T.COMISSÃO_MODALIDADE = cur.COMISSÃO_MODALIDADE, T.INSTRUÇÃO_REMESSA = cur.INSTRUÇÃO_REMESSA, T.EXP_CALC = cur.EXP_CALC, T.IMP_CALC = cur.IMP_CALC, T.OBS = cur.OBS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.PED_REF = cur.PED_REF and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg PED_LANÇ: ' || cur.PED_REF || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PED_LANÇ com data local igual ou mais atual: ' || cur.PED_REF || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PED_LANÇ já existente e com data local igual ou mais atual: ' || cur.PED_REF || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PED_LANÇ - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela VIAGEM_ESCALA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select VIAGEM_REF, ESCALA, PORTO, ETA, ETS, ATA, ATS, LD, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.VIAGEM_ESCALA_T T;
                                        reg CXSP.VIAGEM_ESCALA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.VIAGEM_ESCALA T where T.VIAGEM_REF = cur.VIAGEM_REF and T.ESCALA = cur.ESCALA;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into VIAGEM_ESCALA (VIAGEM_REF, ESCALA, PORTO, ETA, ETS, ATA, ATS, LD, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.VIAGEM_REF, cur.ESCALA, cur.PORTO, cur.ETA, cur.ETS, cur.ATA, cur.ATS, cur.LD, cur.OBS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg VIAGEM_ESCALA: ' || cur.VIAGEM_REF || cur.ESCALA || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg VIAGEM_ESCALA inexistente: ' || cur.VIAGEM_REF || cur.ESCALA || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg VIAGEM_ESCALA já manipulado localmente: ' || cur.VIAGEM_REF || cur.ESCALA || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg VIAGEM_ESCALA já existente e manipulado localmente: ' || cur.VIAGEM_REF || cur.ESCALA || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.VIAGEM_ESCALA t set T.PORTO = cur.PORTO, T.ETA = cur.ETA, T.ETS = cur.ETS, T.ATA = cur.ATA, T.ATS = cur.ATS, T.LD = cur.LD, T.OBS = cur.OBS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.VIAGEM_REF = cur.VIAGEM_REF and T.ESCALA = cur.ESCALA;
                                                                        log(reglog, '> Atualização realizada do reg VIAGEM_ESCALA: ' || cur.VIAGEM_REF || cur.ESCALA || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg VIAGEM_ESCALA com data local igual ou mais atual: ' || cur.VIAGEM_REF || cur.ESCALA || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg VIAGEM_ESCALA já existente e com data local igual ou mais atual: ' || cur.VIAGEM_REF || cur.ESCALA || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela VIAGEM_ESCALA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela BL
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select VIAGEM_REF, SEQ, BL_NUM, BL_DATA, EMB_REF, MSG, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.BL_T T;
                                        reg CXSP.BL%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.BL T where T.VIAGEM_REF = cur.VIAGEM_REF and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into BL (VIAGEM_REF, SEQ, BL_NUM, BL_DATA, EMB_REF, MSG, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.VIAGEM_REF, cur.SEQ, cur.BL_NUM, cur.BL_DATA, cur.EMB_REF, cur.MSG, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg BL: ' || cur.VIAGEM_REF || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg BL inexistente: ' || cur.VIAGEM_REF || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg BL já manipulado localmente: ' || cur.VIAGEM_REF || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg BL já existente e manipulado localmente: ' || cur.VIAGEM_REF || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.BL t set T.BL_NUM = cur.BL_NUM, T.BL_DATA = cur.BL_DATA, T.EMB_REF = cur.EMB_REF, T.MSG = cur.MSG, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.VIAGEM_REF = cur.VIAGEM_REF and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg BL: ' || cur.VIAGEM_REF || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg BL com data local igual ou mais atual: ' || cur.VIAGEM_REF || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg BL já existente e com data local igual ou mais atual: ' || cur.VIAGEM_REF || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela BL - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CONFIRM_VENDA_ITEM
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CONFIRM_VENDA_REF, SEQ, ITEM, DESCR, DIMENSÃO, QTD, UNID, PREÇO, MOEDA, QUALIDADE, PREÇO_C, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.CONFIRM_VENDA_ITEM_T T WHERE T.CONFIRM_VENDA_REF LIKE 'RJP%' OR T.CONFIRM_VENDA_REF LIKE 'SP%';
                                        reg CXSP.CONFIRM_VENDA_ITEM%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.CONFIRM_VENDA_ITEM T where T.CONFIRM_VENDA_REF = cur.CONFIRM_VENDA_REF and T.SEQ = cur.SEQ and T.ITEM = cur.ITEM;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CONFIRM_VENDA_ITEM (CONFIRM_VENDA_REF, SEQ, ITEM, DESCR, DIMENSÃO, QTD, UNID, PREÇO, MOEDA, QUALIDADE, PREÇO_C, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CONFIRM_VENDA_REF, cur.SEQ, cur.ITEM, cur.DESCR, cur.DIMENSÃO, cur.QTD, cur.UNID, cur.PREÇO, cur.MOEDA, cur.QUALIDADE, cur.PREÇO_C, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CONFIRM_VENDA_ITEM: ' || cur.CONFIRM_VENDA_REF || cur.SEQ || cur.ITEM || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CONFIRM_VENDA_ITEM inexistente: ' || cur.CONFIRM_VENDA_REF || cur.SEQ || cur.ITEM || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CONFIRM_VENDA_ITEM já manipulado localmente: ' || cur.CONFIRM_VENDA_REF || cur.SEQ || cur.ITEM || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CONFIRM_VENDA_ITEM já existente e manipulado localmente: ' || cur.CONFIRM_VENDA_REF || cur.SEQ || cur.ITEM || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.CONFIRM_VENDA_ITEM t set T.DESCR = cur.DESCR, T.DIMENSÃO = cur.DIMENSÃO, T.QTD = cur.QTD, T.UNID = cur.UNID, T.PREÇO = cur.PREÇO, T.MOEDA = cur.MOEDA, T.QUALIDADE = cur.QUALIDADE, T.PREÇO_C = cur.PREÇO_C, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CONFIRM_VENDA_REF = cur.CONFIRM_VENDA_REF and T.SEQ = cur.SEQ and T.ITEM = cur.ITEM;
                                                                        log(reglog, '> Atualização realizada do reg CONFIRM_VENDA_ITEM: ' || cur.CONFIRM_VENDA_REF || cur.SEQ || cur.ITEM || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CONFIRM_VENDA_ITEM com data local igual ou mais atual: ' || cur.CONFIRM_VENDA_REF || cur.SEQ || cur.ITEM || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CONFIRM_VENDA_ITEM já existente e com data local igual ou mais atual: ' || cur.CONFIRM_VENDA_REF || cur.SEQ || cur.ITEM || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CONFIRM_VENDA_ITEM - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela EMB_DOC_REL
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select EMB_REF, DOC, EMB_REL, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.EMB_DOC_REL_T T;
                                        reg CXSP.EMB_DOC_REL%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.EMB_DOC_REL T where T.EMB_REF = cur.EMB_REF and T.DOC = cur.DOC and T.EMB_REL = cur.EMB_REL;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into EMB_DOC_REL (EMB_REF, DOC, EMB_REL, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.EMB_REF, cur.DOC, cur.EMB_REL, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg EMB_DOC_REL: ' || cur.EMB_REF || cur.DOC || cur.EMB_REL || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg EMB_DOC_REL inexistente: ' || cur.EMB_REF || cur.DOC || cur.EMB_REL || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg EMB_DOC_REL já manipulado localmente: ' || cur.EMB_REF || cur.DOC || cur.EMB_REL || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg EMB_DOC_REL já existente e manipulado localmente: ' || cur.EMB_REF || cur.DOC || cur.EMB_REL || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.EMB_DOC_REL t set T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.EMB_REF = cur.EMB_REF and T.DOC = cur.DOC and T.EMB_REL = cur.EMB_REL;
                                                                        log(reglog, '> Atualização realizada do reg EMB_DOC_REL: ' || cur.EMB_REF || cur.DOC || cur.EMB_REL || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg EMB_DOC_REL com data local igual ou mais atual: ' || cur.EMB_REF || cur.DOC || cur.EMB_REL || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg EMB_DOC_REL já existente e com data local igual ou mais atual: ' || cur.EMB_REF || cur.DOC || cur.EMB_REL || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela EMB_DOC_REL - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela EMB_FAMÍLIA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select EMB_REF, SEQ, FAMÍLIA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.EMB_FAMÍLIA_T T;
                                        reg CXSP.EMB_FAMÍLIA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.EMB_FAMÍLIA T where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into EMB_FAMÍLIA (EMB_REF, SEQ, FAMÍLIA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.EMB_REF, cur.SEQ, cur.FAMÍLIA, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg EMB_FAMÍLIA: ' || cur.EMB_REF || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg EMB_FAMÍLIA inexistente: ' || cur.EMB_REF || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg EMB_FAMÍLIA já manipulado localmente: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg EMB_FAMÍLIA já existente e manipulado localmente: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.EMB_FAMÍLIA t set T.FAMÍLIA = cur.FAMÍLIA, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg EMB_FAMÍLIA: ' || cur.EMB_REF || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg EMB_FAMÍLIA com data local igual ou mais atual: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg EMB_FAMÍLIA já existente e com data local igual ou mais atual: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela EMB_FAMÍLIA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela EMB_FAMÍLIA_GENÉRICA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select EMB_REF, SEQ, FAMÍLIA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.EMB_FAMÍLIA_GENÉRICA_T T;
                                        reg CXSP.EMB_FAMÍLIA_GENÉRICA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.EMB_FAMÍLIA_GENÉRICA T where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into EMB_FAMÍLIA_GENÉRICA (EMB_REF, SEQ, FAMÍLIA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.EMB_REF, cur.SEQ, cur.FAMÍLIA, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg EMB_FAMÍLIA_GENÉRICA: ' || cur.EMB_REF || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg EMB_FAMÍLIA_GENÉRICA inexistente: ' || cur.EMB_REF || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg EMB_FAMÍLIA_GENÉRICA já manipulado localmente: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg EMB_FAMÍLIA_GENÉRICA já existente e manipulado localmente: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.EMB_FAMÍLIA_GENÉRICA t set T.FAMÍLIA = cur.FAMÍLIA, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg EMB_FAMÍLIA_GENÉRICA: ' || cur.EMB_REF || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg EMB_FAMÍLIA_GENÉRICA com data local igual ou mais atual: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg EMB_FAMÍLIA_GENÉRICA já existente e com data local igual ou mais atual: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela EMB_FAMÍLIA_GENÉRICA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela EMB_LANÇ
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select EMB_REF, SEQ, LANÇ, VALOR, VALOR_POR_MT, TOTAL_PERCENT, TOTAL_TIPO, EXP, IMP, UNID, NA_FATURA, BENEFICIÁRIO, COMISSÃO_MODALIDADE, INSTRUÇÃO_REMESSA, EXP_CALC, IMP_CALC, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.EMB_LANÇ_T T;
                                        reg CXSP.EMB_LANÇ%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.EMB_LANÇ T where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into EMB_LANÇ (EMB_REF, SEQ, LANÇ, VALOR, VALOR_POR_MT, TOTAL_PERCENT, TOTAL_TIPO, EXP, IMP, UNID, NA_FATURA, BENEFICIÁRIO, COMISSÃO_MODALIDADE, INSTRUÇÃO_REMESSA, EXP_CALC, IMP_CALC, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.EMB_REF, cur.SEQ, cur.LANÇ, cur.VALOR, cur.VALOR_POR_MT, cur.TOTAL_PERCENT, cur.TOTAL_TIPO, cur.EXP, cur.IMP, cur.UNID, cur.NA_FATURA, cur.BENEFICIÁRIO, cur.COMISSÃO_MODALIDADE, cur.INSTRUÇÃO_REMESSA, cur.EXP_CALC, cur.IMP_CALC, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg EMB_LANÇ: ' || cur.EMB_REF || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg EMB_LANÇ inexistente: ' || cur.EMB_REF || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg EMB_LANÇ já manipulado localmente: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg EMB_LANÇ já existente e manipulado localmente: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.EMB_LANÇ t set T.LANÇ = cur.LANÇ, T.VALOR = cur.VALOR, T.VALOR_POR_MT = cur.VALOR_POR_MT, T.TOTAL_PERCENT = cur.TOTAL_PERCENT, T.TOTAL_TIPO = cur.TOTAL_TIPO, T.EXP = cur.EXP, T.IMP = cur.IMP, T.UNID = cur.UNID, T.NA_FATURA = cur.NA_FATURA, T.BENEFICIÁRIO = cur.BENEFICIÁRIO, T.COMISSÃO_MODALIDADE = cur.COMISSÃO_MODALIDADE, T.INSTRUÇÃO_REMESSA = cur.INSTRUÇÃO_REMESSA, T.EXP_CALC = cur.EXP_CALC, T.IMP_CALC = cur.IMP_CALC, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg EMB_LANÇ: ' || cur.EMB_REF || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg EMB_LANÇ com data local igual ou mais atual: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg EMB_LANÇ já existente e com data local igual ou mais atual: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela EMB_LANÇ - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela EMB_MENSAGEM
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select EMB_REF, SEQ, MSG, EXP, IMP, DOC_ALADI, DOC_BORDERÔ_I, DOC_BORDERÔ_P, DOC_CÂMARA_COMÉRCIO, DOC_CARTA_I, DOC_CARTA_P, DOC_CONHECIM_ROD, DOC_FATURA, DOC_FATURA_JUROS, DOC_FECH_CAMBIO, DOC_FIRJAN, DOC_MERCOSUL, DOC_MERCOSUL_BOLIVIA, DOC_MERCOSUL_CHILE, DOC_PLIST_WEIG_CERT, DOC_SAQUE_JUR_2_VIAS, DOC_SAQUE_JUR_3_VIAS, DOC_SAQUE_2_VIAS, DOC_SAQUE_3_VIAS, DOC_ALADI_CERTIF_ORIGEM, DOC_BL, DOC_CÂM_COM_CERTIF_O, DOC_CAPA, DOC_CONHECIM_RODOVIÁRIO, DOC_CHECK_LIST, DOC_CARTA_DEOP_INGLÊS, DOC_CARTA_DEOP_PORTUG, DOC_FECHAM_CÂMBIO, DOC_FIRJAN_CERTIF_ORIGEM, DOC_FORM_A, DOC_INSTR_PAG, DOC_MERCOSUL_CERTIF_ORIGEM, DOC_PACKING_LIST, DOC_SAQUE, DOC_WEIGHT_CERTIFICATE, DOC_SAQUE_JUROS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.EMB_MENSAGEM_T T;
                                        reg CXSP.EMB_MENSAGEM%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.EMB_MENSAGEM T where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into EMB_MENSAGEM (EMB_REF, SEQ, MSG, EXP, IMP, DOC_ALADI, DOC_BORDERÔ_I, DOC_BORDERÔ_P, DOC_CÂMARA_COMÉRCIO, DOC_CARTA_I, DOC_CARTA_P, DOC_CONHECIM_ROD, DOC_FATURA, DOC_FATURA_JUROS, DOC_FECH_CAMBIO, DOC_FIRJAN, DOC_MERCOSUL, DOC_MERCOSUL_BOLIVIA, DOC_MERCOSUL_CHILE, DOC_PLIST_WEIG_CERT, DOC_SAQUE_JUR_2_VIAS, DOC_SAQUE_JUR_3_VIAS, DOC_SAQUE_2_VIAS, DOC_SAQUE_3_VIAS, DOC_ALADI_CERTIF_ORIGEM, DOC_BL, DOC_CÂM_COM_CERTIF_O, DOC_CAPA, DOC_CONHECIM_RODOVIÁRIO, DOC_CHECK_LIST, DOC_CARTA_DEOP_INGLÊS, DOC_CARTA_DEOP_PORTUG, DOC_FECHAM_CÂMBIO, DOC_FIRJAN_CERTIF_ORIGEM, DOC_FORM_A, DOC_INSTR_PAG, DOC_MERCOSUL_CERTIF_ORIGEM, DOC_PACKING_LIST, DOC_SAQUE, DOC_WEIGHT_CERTIFICATE, DOC_SAQUE_JUROS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.EMB_REF, cur.SEQ, cur.MSG, cur.EXP, cur.IMP, cur.DOC_ALADI, cur.DOC_BORDERÔ_I, cur.DOC_BORDERÔ_P, cur.DOC_CÂMARA_COMÉRCIO, cur.DOC_CARTA_I, cur.DOC_CARTA_P, cur.DOC_CONHECIM_ROD, cur.DOC_FATURA, cur.DOC_FATURA_JUROS, cur.DOC_FECH_CAMBIO, cur.DOC_FIRJAN, cur.DOC_MERCOSUL, cur.DOC_MERCOSUL_BOLIVIA, cur.DOC_MERCOSUL_CHILE, cur.DOC_PLIST_WEIG_CERT, cur.DOC_SAQUE_JUR_2_VIAS, cur.DOC_SAQUE_JUR_3_VIAS, cur.DOC_SAQUE_2_VIAS, cur.DOC_SAQUE_3_VIAS, cur.DOC_ALADI_CERTIF_ORIGEM, cur.DOC_BL, cur.DOC_CÂM_COM_CERTIF_O, cur.DOC_CAPA, cur.DOC_CONHECIM_RODOVIÁRIO, cur.DOC_CHECK_LIST, cur.DOC_CARTA_DEOP_INGLÊS, 
                                                        cur.DOC_CARTA_DEOP_PORTUG, cur.DOC_FECHAM_CÂMBIO, cur.DOC_FIRJAN_CERTIF_ORIGEM, cur.DOC_FORM_A, cur.DOC_INSTR_PAG, cur.DOC_MERCOSUL_CERTIF_ORIGEM, cur.DOC_PACKING_LIST, cur.DOC_SAQUE, cur.DOC_WEIGHT_CERTIFICATE, cur.DOC_SAQUE_JUROS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg EMB_MENSAGEM: ' || cur.EMB_REF || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg EMB_MENSAGEM inexistente: ' || cur.EMB_REF || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg EMB_MENSAGEM já manipulado localmente: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg EMB_MENSAGEM já existente e manipulado localmente: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.EMB_MENSAGEM t set T.MSG = cur.MSG, T.EXP = cur.EXP, T.IMP = cur.IMP, T.DOC_ALADI = cur.DOC_ALADI, T.DOC_BORDERÔ_I = cur.DOC_BORDERÔ_I, T.DOC_BORDERÔ_P = cur.DOC_BORDERÔ_P, T.DOC_CÂMARA_COMÉRCIO = cur.DOC_CÂMARA_COMÉRCIO, T.DOC_CARTA_I = cur.DOC_CARTA_I, T.DOC_CARTA_P = cur.DOC_CARTA_P, T.DOC_CONHECIM_ROD = cur.DOC_CONHECIM_ROD, T.DOC_FATURA = cur.DOC_FATURA, T.DOC_FATURA_JUROS = cur.DOC_FATURA_JUROS, T.DOC_FECH_CAMBIO = cur.DOC_FECH_CAMBIO, T.DOC_FIRJAN = cur.DOC_FIRJAN, T.DOC_MERCOSUL = cur.DOC_MERCOSUL, T.DOC_MERCOSUL_BOLIVIA = cur.DOC_MERCOSUL_BOLIVIA, T.DOC_MERCOSUL_CHILE = cur.DOC_MERCOSUL_CHILE, T.DOC_PLIST_WEIG_CERT = cur.DOC_PLIST_WEIG_CERT, T.DOC_SAQUE_JUR_2_VIAS = cur.DOC_SAQUE_JUR_2_VIAS, T.DOC_SAQUE_JUR_3_VIAS = cur.DOC_SAQUE_JUR_3_VIAS, T.DOC_SAQUE_2_VIAS = cur.DOC_SAQUE_2_VIAS, T.DOC_SAQUE_3_VIAS = cur.DOC_SAQUE_3_VIAS, T.DOC_ALADI_CERTIF_ORIGEM = cur.DOC_ALADI_CERTIF_ORIGEM, T.DOC_BL = cur.DOC_BL, T.DOC_CÂM_COM_CERTIF_O = cur.DOC_CÂM_COM_CERTIF_O, T.DOC_CAPA = cur.DOC_CAPA, T.DOC_CONHECIM_RODOVIÁRIO = cur.DOC_CONHECIM_RODOVIÁRIO, T.DOC_CHECK_LIST = cur.DOC_CHECK_LIST, T.DOC_CARTA_DEOP_INGLÊS = cur.DOC_CARTA_DEOP_INGLÊS, T.DOC_CARTA_DEOP_PORTUG = cur.DOC_CARTA_DEOP_PORTUG, T.DOC_FECHAM_CÂMBIO = cur.DOC_FECHAM_CÂMBIO, T.DOC_FIRJAN_CERTIF_ORIGEM = cur.DOC_FIRJAN_CERTIF_ORIGEM, T.DOC_FORM_A = cur.DOC_FORM_A, T.DOC_INSTR_PAG = cur.DOC_INSTR_PAG, T.DOC_MERCOSUL_CERTIF_ORIGEM = 
                                                                        cur.DOC_MERCOSUL_CERTIF_ORIGEM, T.DOC_PACKING_LIST = cur.DOC_PACKING_LIST, T.DOC_SAQUE = cur.DOC_SAQUE, T.DOC_WEIGHT_CERTIFICATE = cur.DOC_WEIGHT_CERTIFICATE, T.DOC_SAQUE_JUROS = cur.DOC_SAQUE_JUROS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg EMB_MENSAGEM: ' || cur.EMB_REF || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg EMB_MENSAGEM com data local igual ou mais atual: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg EMB_MENSAGEM já existente e com data local igual ou mais atual: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela EMB_MENSAGEM - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela EMB_RE
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select EMB_REF, RE, EMISSÃO_DATA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.EMB_RE_T T;
                                        reg CXSP.EMB_RE%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.EMB_RE T where T.EMB_REF = cur.EMB_REF and T.RE = cur.RE;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into EMB_RE (EMB_REF, RE, EMISSÃO_DATA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.EMB_REF, cur.RE, cur.EMISSÃO_DATA, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg EMB_RE: ' || cur.EMB_REF || cur.RE || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg EMB_RE inexistente: ' || cur.EMB_REF || cur.RE || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg EMB_RE já manipulado localmente: ' || cur.EMB_REF || cur.RE || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg EMB_RE já existente e manipulado localmente: ' || cur.EMB_REF || cur.RE || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.EMB_RE t set T.EMISSÃO_DATA = cur.EMISSÃO_DATA, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.EMB_REF = cur.EMB_REF and T.RE = cur.RE;
                                                                        log(reglog, '> Atualização realizada do reg EMB_RE: ' || cur.EMB_REF || cur.RE || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg EMB_RE com data local igual ou mais atual: ' || cur.EMB_REF || cur.RE || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg EMB_RE já existente e com data local igual ou mais atual: ' || cur.EMB_REF || cur.RE || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela EMB_RE - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela EMB_SD
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select EMB_REF, SD, AVERBAÇÃO_DATA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.EMB_SD_T T;
                                        reg CXSP.EMB_SD%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.EMB_SD T where T.EMB_REF = cur.EMB_REF and T.SD = cur.SD;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into EMB_SD (EMB_REF, SD, AVERBAÇÃO_DATA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.EMB_REF, cur.SD, cur.AVERBAÇÃO_DATA, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg EMB_SD: ' || cur.EMB_REF || cur.SD || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg EMB_SD inexistente: ' || cur.EMB_REF || cur.SD || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg EMB_SD já manipulado localmente: ' || cur.EMB_REF || cur.SD || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg EMB_SD já existente e manipulado localmente: ' || cur.EMB_REF || cur.SD || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.EMB_SD t set T.AVERBAÇÃO_DATA = cur.AVERBAÇÃO_DATA, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.EMB_REF = cur.EMB_REF and T.SD = cur.SD;
                                                                        log(reglog, '> Atualização realizada do reg EMB_SD: ' || cur.EMB_REF || cur.SD || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg EMB_SD com data local igual ou mais atual: ' || cur.EMB_REF || cur.SD || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg EMB_SD já existente e com data local igual ou mais atual: ' || cur.EMB_REF || cur.SD || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela EMB_SD - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela EMB_TOTALIZA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select EMB_REF, SEQ, LANÇ, EXP, IMP, EXP_DESCR, IMP_DESCR, EXP_CALC, IMP_CALC, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.EMB_TOTALIZA_T T;
                                        reg CXSP.EMB_TOTALIZA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.EMB_TOTALIZA T where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into EMB_TOTALIZA (EMB_REF, SEQ, LANÇ, EXP, IMP, EXP_DESCR, IMP_DESCR, EXP_CALC, IMP_CALC, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.EMB_REF, cur.SEQ, cur.LANÇ, cur.EXP, cur.IMP, cur.EXP_DESCR, cur.IMP_DESCR, cur.EXP_CALC, cur.IMP_CALC, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg EMB_TOTALIZA: ' || cur.EMB_REF || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg EMB_TOTALIZA inexistente: ' || cur.EMB_REF || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg EMB_TOTALIZA já manipulado localmente: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg EMB_TOTALIZA já existente e manipulado localmente: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.EMB_TOTALIZA t set T.LANÇ = cur.LANÇ, T.EXP = cur.EXP, T.IMP = cur.IMP, T.EXP_DESCR = cur.EXP_DESCR, T.IMP_DESCR = cur.IMP_DESCR, T.EXP_CALC = cur.EXP_CALC, T.IMP_CALC = cur.IMP_CALC, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg EMB_TOTALIZA: ' || cur.EMB_REF || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg EMB_TOTALIZA com data local igual ou mais atual: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg EMB_TOTALIZA já existente e com data local igual ou mais atual: ' || cur.EMB_REF || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela EMB_TOTALIZA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela FECH
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select REF, FECH_DATA, MOEDA, VIAGEM_REF, CARGA_PORTO_ESCALA, DESCARGA_PORTO_ESCALA, CONTRATANTE, CORRETOR, PROPRIETÁRIO, NEGOCIANTE, FRETE_DETALHE, FRETE_UNID, FRETE_VALOR, FRETE_VALOR_POR_UNID, FRETE_PAG_DETALHE, COMISSÃO_FRETE, COMISSÃO_BASE, COMISSÃO_PERCENT, CIA_PAGADORA, CARGA_AGENTE, CARGA_ESTIVA, CARGA_ESTIVA_CUSTO, CARGA_DETALHE, CARGA_OBS, DESCARGA_AGENTE, DESCARGA_ESTIVA, DESCARGA_ESTIVA_CUSTO, DESCARGA_DETALHE, DESCARGA_OBS, DETENÇÃO, DEMORA, OBS, DESPACHANTE, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.FECH_T T;
                                        reg CXSP.FECH%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.FECH T where T.REF = cur.REF;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into FECH (REF, FECH_DATA, MOEDA, VIAGEM_REF, CARGA_PORTO_ESCALA, DESCARGA_PORTO_ESCALA, CONTRATANTE, CORRETOR, PROPRIETÁRIO, NEGOCIANTE, FRETE_DETALHE, FRETE_UNID, FRETE_VALOR, FRETE_VALOR_POR_UNID, FRETE_PAG_DETALHE, COMISSÃO_FRETE, COMISSÃO_BASE, COMISSÃO_PERCENT, CIA_PAGADORA, CARGA_AGENTE, CARGA_ESTIVA, CARGA_ESTIVA_CUSTO, CARGA_DETALHE, CARGA_OBS, DESCARGA_AGENTE, DESCARGA_ESTIVA, DESCARGA_ESTIVA_CUSTO, DESCARGA_DETALHE, DESCARGA_OBS, DETENÇÃO, DEMORA, OBS, DESPACHANTE, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.REF, cur.FECH_DATA, cur.MOEDA, cur.VIAGEM_REF, cur.CARGA_PORTO_ESCALA, cur.DESCARGA_PORTO_ESCALA, cur.CONTRATANTE, cur.CORRETOR, cur.PROPRIETÁRIO, cur.NEGOCIANTE, cur.FRETE_DETALHE, cur.FRETE_UNID, cur.FRETE_VALOR, cur.FRETE_VALOR_POR_UNID, cur.FRETE_PAG_DETALHE, cur.COMISSÃO_FRETE, cur.COMISSÃO_BASE, cur.COMISSÃO_PERCENT, cur.CIA_PAGADORA, cur.CARGA_AGENTE, cur.CARGA_ESTIVA, cur.CARGA_ESTIVA_CUSTO, cur.CARGA_DETALHE, cur.CARGA_OBS, cur.DESCARGA_AGENTE, cur.DESCARGA_ESTIVA, cur.DESCARGA_ESTIVA_CUSTO, cur.DESCARGA_DETALHE, cur.DESCARGA_OBS, cur.DETENÇÃO, cur.DEMORA, cur.OBS, cur.DESPACHANTE, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg FECH: ' || cur.REF || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg FECH inexistente: ' || cur.REF || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg FECH já manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg FECH já existente e manipulado localmente: ' || cur.REF || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.FECH t set T.FECH_DATA = cur.FECH_DATA, T.MOEDA = cur.MOEDA, T.VIAGEM_REF = cur.VIAGEM_REF, T.CARGA_PORTO_ESCALA = cur.CARGA_PORTO_ESCALA, T.DESCARGA_PORTO_ESCALA = cur.DESCARGA_PORTO_ESCALA, T.CONTRATANTE = cur.CONTRATANTE, T.CORRETOR = cur.CORRETOR, T.PROPRIETÁRIO = cur.PROPRIETÁRIO, T.NEGOCIANTE = cur.NEGOCIANTE, T.FRETE_DETALHE = cur.FRETE_DETALHE, T.FRETE_UNID = cur.FRETE_UNID, T.FRETE_VALOR = cur.FRETE_VALOR, T.FRETE_VALOR_POR_UNID = cur.FRETE_VALOR_POR_UNID, T.FRETE_PAG_DETALHE = cur.FRETE_PAG_DETALHE, T.COMISSÃO_FRETE = cur.COMISSÃO_FRETE, T.COMISSÃO_BASE = cur.COMISSÃO_BASE, T.COMISSÃO_PERCENT = cur.COMISSÃO_PERCENT, T.CIA_PAGADORA = cur.CIA_PAGADORA, T.CARGA_AGENTE = cur.CARGA_AGENTE, T.CARGA_ESTIVA = cur.CARGA_ESTIVA, T.CARGA_ESTIVA_CUSTO = cur.CARGA_ESTIVA_CUSTO, T.CARGA_DETALHE = cur.CARGA_DETALHE, T.CARGA_OBS = cur.CARGA_OBS, T.DESCARGA_AGENTE = cur.DESCARGA_AGENTE, T.DESCARGA_ESTIVA = cur.DESCARGA_ESTIVA, T.DESCARGA_ESTIVA_CUSTO = cur.DESCARGA_ESTIVA_CUSTO, T.DESCARGA_DETALHE = cur.DESCARGA_DETALHE, T.DESCARGA_OBS = cur.DESCARGA_OBS, T.DETENÇÃO = cur.DETENÇÃO, T.DEMORA = cur.DEMORA, T.OBS = cur.OBS, T.DESPACHANTE = cur.DESPACHANTE, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, 
                                                                        T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.REF = cur.REF;
                                                                        log(reglog, '> Atualização realizada do reg FECH: ' || cur.REF || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg FECH com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg FECH já existente e com data local igual ou mais atual: ' || cur.REF || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela FECH - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela RESULT
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select PED_REF, EMB_SEQ, SEQ, INV_DATA, RESULT1, RESULT2, RESULT3, RESULT4, RESULT5, DATA1, DATA2, DATA3, DATA4, DATA5, POSIÇÃO, OBSERVAÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.RESULT_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                        reg CXSP.RESULT%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.RESULT T where T.PED_REF = cur.PED_REF and T.EMB_SEQ = cur.EMB_SEQ and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into RESULT (PED_REF, EMB_SEQ, SEQ, INV_DATA, RESULT1, RESULT2, RESULT3, RESULT4, RESULT5, DATA1, DATA2, DATA3, DATA4, DATA5, POSIÇÃO, OBSERVAÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.PED_REF, cur.EMB_SEQ, cur.SEQ, cur.INV_DATA, cur.RESULT1, cur.RESULT2, cur.RESULT3, cur.RESULT4, cur.RESULT5, cur.DATA1, cur.DATA2, cur.DATA3, cur.DATA4, cur.DATA5, cur.POSIÇÃO, cur.OBSERVAÇÃO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg RESULT: ' || cur.PED_REF || cur.EMB_SEQ || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg RESULT inexistente: ' || cur.PED_REF || cur.EMB_SEQ || cur.SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg RESULT já manipulado localmente: ' || cur.PED_REF || cur.EMB_SEQ || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg RESULT já existente e manipulado localmente: ' || cur.PED_REF || cur.EMB_SEQ || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.RESULT t set T.INV_DATA = cur.INV_DATA, T.RESULT1 = cur.RESULT1, T.RESULT2 = cur.RESULT2, T.RESULT3 = cur.RESULT3, T.RESULT4 = cur.RESULT4, T.RESULT5 = cur.RESULT5, T.DATA1 = cur.DATA1, T.DATA2 = cur.DATA2, T.DATA3 = cur.DATA3, T.DATA4 = cur.DATA4, T.DATA5 = cur.DATA5, T.POSIÇÃO = cur.POSIÇÃO, T.OBSERVAÇÃO = cur.OBSERVAÇÃO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.PED_REF = cur.PED_REF and T.EMB_SEQ = cur.EMB_SEQ and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg RESULT: ' || cur.PED_REF || cur.EMB_SEQ || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg RESULT com data local igual ou mais atual: ' || cur.PED_REF || cur.EMB_SEQ || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg RESULT já existente e com data local igual ou mais atual: ' || cur.PED_REF || cur.EMB_SEQ || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela RESULT - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CARTA_FECH
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CARTA_REF, FECH_REF, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.CARTA_FECH_T T;
                                        reg CXSP.CARTA_FECH%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.CARTA_FECH T where T.CARTA_REF = cur.CARTA_REF and T.FECH_REF = cur.FECH_REF;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CARTA_FECH (CARTA_REF, FECH_REF, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CARTA_REF, cur.FECH_REF, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CARTA_FECH: ' || cur.CARTA_REF || cur.FECH_REF || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CARTA_FECH inexistente: ' || cur.CARTA_REF || cur.FECH_REF || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CARTA_FECH já manipulado localmente: ' || cur.CARTA_REF || cur.FECH_REF || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CARTA_FECH já existente e manipulado localmente: ' || cur.CARTA_REF || cur.FECH_REF || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.CARTA_FECH t set T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CARTA_REF = cur.CARTA_REF and T.FECH_REF = cur.FECH_REF;
                                                                        log(reglog, '> Atualização realizada do reg CARTA_FECH: ' || cur.CARTA_REF || cur.FECH_REF || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CARTA_FECH com data local igual ou mais atual: ' || cur.CARTA_REF || cur.FECH_REF || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CARTA_FECH já existente e com data local igual ou mais atual: ' || cur.CARTA_REF || cur.FECH_REF || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CARTA_FECH - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela BL_CARGA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select PED_REF, PED_ITEM, VIAGEM_REF, BL_SEQ, FECH_REF, QTD_PED_UNID, QTD_VOL, PESO_LÍQUIDO, PESO_BRUTO, EMB_DATA, EMB_REF, EMB_SEQ, FAMÍLIA_GENÉRICA, FAMÍLIA, DESCR         , EMBALAGEM, NCM, NALADI, EXP_PREÇO_UNIT, IMP_PREÇO_UNIT, CALC_EXP_EMB, CALC_EXP_FOB, CALC_IMP_EMB, CALC_IMP_FOB, NOMINAL_PED_UNID, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.BL_CARGA_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                        reg CXSP.BL_CARGA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.BL_CARGA T where T.PED_REF = cur.PED_REF and T.PED_ITEM = cur.PED_ITEM and T.VIAGEM_REF = cur.VIAGEM_REF and T.BL_SEQ = cur.BL_SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into BL_CARGA (PED_REF, PED_ITEM, VIAGEM_REF, BL_SEQ, FECH_REF, QTD_PED_UNID, QTD_VOL, PESO_LÍQUIDO, PESO_BRUTO, EMB_DATA, EMB_REF, EMB_SEQ, FAMÍLIA_GENÉRICA, FAMÍLIA, DESCR         , EMBALAGEM, NCM, NALADI, EXP_PREÇO_UNIT, IMP_PREÇO_UNIT, CALC_EXP_EMB, CALC_EXP_FOB, CALC_IMP_EMB, CALC_IMP_FOB, NOMINAL_PED_UNID, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.PED_REF, cur.PED_ITEM, cur.VIAGEM_REF, cur.BL_SEQ, cur.FECH_REF, cur.QTD_PED_UNID, cur.QTD_VOL, cur.PESO_LÍQUIDO, cur.PESO_BRUTO, cur.EMB_DATA, cur.EMB_REF, cur.EMB_SEQ, cur.FAMÍLIA_GENÉRICA, cur.FAMÍLIA, cur.DESCR         , cur.EMBALAGEM, cur.NCM, cur.NALADI, cur.EXP_PREÇO_UNIT, cur.IMP_PREÇO_UNIT, cur.CALC_EXP_EMB, cur.CALC_EXP_FOB, cur.CALC_IMP_EMB, cur.CALC_IMP_FOB, cur.NOMINAL_PED_UNID, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg BL_CARGA: ' || cur.PED_REF || cur.PED_ITEM || cur.VIAGEM_REF || cur.BL_SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg BL_CARGA inexistente: ' || cur.PED_REF || cur.PED_ITEM || cur.VIAGEM_REF || cur.BL_SEQ || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg BL_CARGA já manipulado localmente: ' || cur.PED_REF || cur.PED_ITEM || cur.VIAGEM_REF || cur.BL_SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg BL_CARGA já existente e manipulado localmente: ' || cur.PED_REF || cur.PED_ITEM || cur.VIAGEM_REF || cur.BL_SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.BL_CARGA t set T.FECH_REF = cur.FECH_REF, T.QTD_PED_UNID = cur.QTD_PED_UNID, T.QTD_VOL = cur.QTD_VOL, T.PESO_LÍQUIDO = cur.PESO_LÍQUIDO, T.PESO_BRUTO = cur.PESO_BRUTO, T.EMB_DATA = cur.EMB_DATA, T.EMB_REF = cur.EMB_REF, T.EMB_SEQ = cur.EMB_SEQ, T.FAMÍLIA_GENÉRICA = cur.FAMÍLIA_GENÉRICA, T.FAMÍLIA = cur.FAMÍLIA, T.DESCR          = cur.DESCR         , T.EMBALAGEM = cur.EMBALAGEM, T.NCM = cur.NCM, T.NALADI = cur.NALADI, T.EXP_PREÇO_UNIT = cur.EXP_PREÇO_UNIT, T.IMP_PREÇO_UNIT = cur.IMP_PREÇO_UNIT, T.CALC_EXP_EMB = cur.CALC_EXP_EMB, T.CALC_EXP_FOB = cur.CALC_EXP_FOB, T.CALC_IMP_EMB = cur.CALC_IMP_EMB, T.CALC_IMP_FOB = cur.CALC_IMP_FOB, T.NOMINAL_PED_UNID = cur.NOMINAL_PED_UNID, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.PED_REF = cur.PED_REF and T.PED_ITEM = cur.PED_ITEM and T.VIAGEM_REF = cur.VIAGEM_REF and T.BL_SEQ = cur.BL_SEQ;
                                                                        log(reglog, '> Atualização realizada do reg BL_CARGA: ' || cur.PED_REF || cur.PED_ITEM || cur.VIAGEM_REF || cur.BL_SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg BL_CARGA com data local igual ou mais atual: ' || cur.PED_REF || cur.PED_ITEM || cur.VIAGEM_REF || cur.BL_SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg BL_CARGA já existente e com data local igual ou mais atual: ' || cur.PED_REF || cur.PED_ITEM || cur.VIAGEM_REF || cur.BL_SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela BL_CARGA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela FECH_CARGA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select FECH_REF, PED_REF, PED_ITEM, QTD_PED_UNID, QTD_FRETE_UNID, QTD_TOTAL, NOMEAÇÃO_DATA, ACEITAÇÃO_FORNECEDOR_DATA, CANCEL_DATA, CANCEL_MOTIVO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXSP.FECH_CARGA_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                        reg CXSP.FECH_CARGA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXSP.FECH_CARGA T where T.FECH_REF = cur.FECH_REF and T.PED_REF = cur.PED_REF and T.PED_ITEM = cur.PED_ITEM;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into FECH_CARGA (FECH_REF, PED_REF, PED_ITEM, QTD_PED_UNID, QTD_FRETE_UNID, QTD_TOTAL, NOMEAÇÃO_DATA, ACEITAÇÃO_FORNECEDOR_DATA, CANCEL_DATA, CANCEL_MOTIVO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.FECH_REF, cur.PED_REF, cur.PED_ITEM, cur.QTD_PED_UNID, cur.QTD_FRETE_UNID, cur.QTD_TOTAL, cur.NOMEAÇÃO_DATA, cur.ACEITAÇÃO_FORNECEDOR_DATA, cur.CANCEL_DATA, cur.CANCEL_MOTIVO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg FECH_CARGA: ' || cur.FECH_REF || cur.PED_REF || cur.PED_ITEM || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg FECH_CARGA inexistente: ' || cur.FECH_REF || cur.PED_REF || cur.PED_ITEM || '. Registro foi incluído.');
                                                        end if;
                                                else
                                                        if cur.SYS_MOMENTO_ATUALIZA is null Then
                                                                origem_usuario := cur.SYS_USUÁRIO_CRIA;
                                                                origem_momento := cur.SYS_MOMENTO_CRIA;
                                                                origem_local := cur.SYS_LOCAL_CRIA;
                                                        else
                                                                origem_usuario := cur.SYS_USUÁRIO_ATUALIZA;
                                                                origem_momento := cur.SYS_MOMENTO_ATUALIZA;
                                                                origem_local := cur.SYS_LOCAL_ATUALIZA;
                                                        end if;
                                                        if reg.SYS_MOMENTO_ATUALIZA is null Then
                                                                destino_usuario := reg.SYS_USUÁRIO_CRIA;
                                                                destino_momento := reg.SYS_MOMENTO_CRIA;
                                                                destino_local := reg.SYS_LOCAL_CRIA;
                                                         else
                                                                destino_usuario := reg.SYS_USUÁRIO_ATUALIZA;
                                                                destino_momento := reg.SYS_MOMENTO_ATUALIZA;
                                                                destino_local := reg.SYS_LOCAL_ATUALIZA;
                                                        end if;

                                                        if origem_momento > destino_momento Then
                                                                if reg.SYS_STATUS <> ' ' and destino_local <> origem_local Then
                                                                        if cur.SYS_STATUS = 'A' then
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg FECH_CARGA já manipulado localmente: ' || cur.FECH_REF || cur.PED_REF || cur.PED_ITEM || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg FECH_CARGA já existente e manipulado localmente: ' || cur.FECH_REF || cur.PED_REF || cur.PED_ITEM || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXSP.FECH_CARGA t set T.QTD_PED_UNID = cur.QTD_PED_UNID, T.QTD_FRETE_UNID = cur.QTD_FRETE_UNID, T.QTD_TOTAL = cur.QTD_TOTAL, T.NOMEAÇÃO_DATA = cur.NOMEAÇÃO_DATA, T.ACEITAÇÃO_FORNECEDOR_DATA = cur.ACEITAÇÃO_FORNECEDOR_DATA, T.CANCEL_DATA = cur.CANCEL_DATA, T.CANCEL_MOTIVO = cur.CANCEL_MOTIVO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.FECH_REF = cur.FECH_REF and T.PED_REF = cur.PED_REF and T.PED_ITEM = cur.PED_ITEM;
                                                                        log(reglog, '> Atualização realizada do reg FECH_CARGA: ' || cur.FECH_REF || cur.PED_REF || cur.PED_ITEM || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg FECH_CARGA com data local igual ou mais atual: ' || cur.FECH_REF || cur.PED_REF || cur.PED_ITEM || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg FECH_CARGA já existente e com data local igual ou mais atual: ' || cur.FECH_REF || cur.PED_REF || cur.PED_ITEM || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela FECH_CARGA - ' || SQLERRM);

                                                end;
                        end;



                        log(reglog, 'Tratando exclusões.');

                        -- tratando exclusões da tabela EMB_FAMÍLIA_GENÉRICA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'EMB_FAMÍLIA_GENÉRICA';
                                begin
                                        for cur in origem loop
                                                delete from EMB_FAMÍLIA_GENÉRICA T where (T.EMB_REF || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg EMB_FAMÍLIA_GENÉRICA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído EMB_FAMÍLIA_GENÉRICA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela EMB_FAMÍLIA_GENÉRICA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela DOC
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'DOC';
                                begin
                                        for cur in origem loop
                                                delete from DOC T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg DOC: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído DOC: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela DOC - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela EMB_FAMÍLIA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'EMB_FAMÍLIA';
                                begin
                                        for cur in origem loop
                                                delete from EMB_FAMÍLIA T where (T.EMB_REF || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg EMB_FAMÍLIA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído EMB_FAMÍLIA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela EMB_FAMÍLIA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela EMB_RE
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'EMB_RE';
                                begin
                                        for cur in origem loop
                                                delete from EMB_RE T where (T.EMB_REF || T.RE = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg EMB_RE: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído EMB_RE: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela EMB_RE - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela BL_CARGA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'BL_CARGA';
                                begin
                                        for cur in origem loop
                                                delete from BL_CARGA T where (T.PED_REF || T.PED_ITEM || T.VIAGEM_REF || T.BL_SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg BL_CARGA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído BL_CARGA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela BL_CARGA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela BL
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'BL';
                                begin
                                        for cur in origem loop
                                                delete from BL T where (T.VIAGEM_REF || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg BL: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído BL: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela BL - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela EMB_SD
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'EMB_SD';
                                begin
                                        for cur in origem loop
                                                delete from EMB_SD T where (T.EMB_REF || T.SD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg EMB_SD: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído EMB_SD: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela EMB_SD - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela ANEXO
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'ANEXO';
                                begin
                                        for cur in origem loop
                                                delete from ANEXO T where (T.NOME = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg ANEXO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído ANEXO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela ANEXO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela EMPRESA_APUR
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'EMPRESA_APUR';
                                begin
                                        for cur in origem loop
                                                delete from EMPRESA_APUR T where (T.EMPRESA = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg EMPRESA_APUR: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído EMPRESA_APUR: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela EMPRESA_APUR - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela EMB_MENSAGEM
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'EMB_MENSAGEM';
                                begin
                                        for cur in origem loop
                                                delete from EMB_MENSAGEM T where (T.EMB_REF || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg EMB_MENSAGEM: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído EMB_MENSAGEM: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela EMB_MENSAGEM - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PARAM_CSN
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'PARAM_CSN';
                                begin
                                        for cur in origem loop
                                                delete from PARAM_CSN T where (T.PROD || T.VALOR = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PARAM_CSN: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PARAM_CSN: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PARAM_CSN - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela EMB_TOTALIZA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'EMB_TOTALIZA';
                                begin
                                        for cur in origem loop
                                                delete from EMB_TOTALIZA T where (T.EMB_REF || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg EMB_TOTALIZA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído EMB_TOTALIZA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela EMB_TOTALIZA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela INCOTERM_LANÇ
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'INCOTERM_LANÇ';
                                begin
                                        for cur in origem loop
                                                delete from INCOTERM_LANÇ T where (T.INCOTERM || T.LANÇ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg INCOTERM_LANÇ: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído INCOTERM_LANÇ: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela INCOTERM_LANÇ - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela LOCAL_RESULT
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'LOCAL_RESULT';
                                begin
                                        for cur in origem loop
                                                delete from LOCAL_RESULT T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg LOCAL_RESULT: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído LOCAL_RESULT: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela LOCAL_RESULT - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela LOG_IMPORT
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'LOG_IMPORT';
                                begin
                                        for cur in origem loop
                                                delete from LOG_IMPORT T where (T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg LOG_IMPORT: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído LOG_IMPORT: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela LOG_IMPORT - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela MAPA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'MAPA';
                                begin
                                        for cur in origem loop
                                                delete from MAPA T where (T.WORKSHEET || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg MAPA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído MAPA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela MAPA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela EMB_DOC_REL
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'EMB_DOC_REL';
                                begin
                                        for cur in origem loop
                                                delete from EMB_DOC_REL T where (T.EMB_REF || T.DOC || T.EMB_REL = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg EMB_DOC_REL: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído EMB_DOC_REL: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela EMB_DOC_REL - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela DIVISÃO_TIPO_REF
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'DIVISÃO_TIPO_REF';
                                begin
                                        for cur in origem loop
                                                delete from DIVISÃO_TIPO_REF T where (T.ESCRITÓRIO || T.DIVISÃO || T.TIPO_REF = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg DIVISÃO_TIPO_REF: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído DIVISÃO_TIPO_REF: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela DIVISÃO_TIPO_REF - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela EMB_LANÇ
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'EMB_LANÇ';
                                begin
                                        for cur in origem loop
                                                delete from EMB_LANÇ T where (T.EMB_REF || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg EMB_LANÇ: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído EMB_LANÇ: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela EMB_LANÇ - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CONFIRM_VENDA_ITEM
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'CONFIRM_VENDA_ITEM';
                                begin
                                        for cur in origem loop
                                                delete from CONFIRM_VENDA_ITEM T where (T.CONFIRM_VENDA_REF || T.SEQ || T.ITEM = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CONFIRM_VENDA_ITEM: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CONFIRM_VENDA_ITEM: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CONFIRM_VENDA_ITEM - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CARTA_FECH
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'CARTA_FECH';
                                begin
                                        for cur in origem loop
                                                delete from CARTA_FECH T where (T.CARTA_REF || T.FECH_REF = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CARTA_FECH: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CARTA_FECH: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CARTA_FECH - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela SUB_CONTA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'SUB_CONTA';
                                begin
                                        for cur in origem loop
                                                delete from SUB_CONTA T where (T.EMPRESA || T.SUB_CONTA = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg SUB_CONTA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído SUB_CONTA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela SUB_CONTA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela RESULT
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'RESULT';
                                begin
                                        for cur in origem loop
                                                delete from RESULT T where (T.PED_REF || T.EMB_SEQ || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg RESULT: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído RESULT: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela RESULT - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela RELACIONADA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'RELACIONADA';
                                begin
                                        for cur in origem loop
                                                delete from RELACIONADA T where (T.REF = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg RELACIONADA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído RELACIONADA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela RELACIONADA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CIA_CONTATO
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'CIA_CONTATO';
                                begin
                                        for cur in origem loop
                                                delete from CIA_CONTATO T where (T.CIA_COD || T.CONTATO_NOME = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CIA_CONTATO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CIA_CONTATO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CIA_CONTATO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PRODUTO_ESPECIF
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'PRODUTO_ESPECIF';
                                begin
                                        for cur in origem loop
                                                delete from PRODUTO_ESPECIF T where (T.COD || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PRODUTO_ESPECIF: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PRODUTO_ESPECIF: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PRODUTO_ESPECIF - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CIA_RAMO_ATIVIDADE
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'CIA_RAMO_ATIVIDADE';
                                begin
                                        for cur in origem loop
                                                delete from CIA_RAMO_ATIVIDADE T where (T.CIA_COD || T.RAMO_ATIVIDADE = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CIA_RAMO_ATIVIDADE: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CIA_RAMO_ATIVIDADE: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CIA_RAMO_ATIVIDADE - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela DIVISÃO_PRODUTO
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'DIVISÃO_PRODUTO';
                                begin
                                        for cur in origem loop
                                                delete from DIVISÃO_PRODUTO T where (T.ESCRITÓRIO || T.DIVISÃO || T.PROD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg DIVISÃO_PRODUTO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído DIVISÃO_PRODUTO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela DIVISÃO_PRODUTO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PLANILHA_STC
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'PLANILHA_STC';
                                begin
                                        for cur in origem loop
                                                delete from PLANILHA_STC T where (T.WORKSHEET = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PLANILHA_STC: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PLANILHA_STC: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PLANILHA_STC - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PLANILHA_DEF
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'PLANILHA_DEF';
                                begin
                                        for cur in origem loop
                                                delete from PLANILHA_DEF T where (T.WORKSHEET || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PLANILHA_DEF: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PLANILHA_DEF: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PLANILHA_DEF - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PED_RESULT
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'PED_RESULT';
                                begin
                                        for cur in origem loop
                                                delete from PED_RESULT T where (T.PED_REF || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PED_RESULT: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PED_RESULT: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PED_RESULT - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PED_LANÇ
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'PED_LANÇ';
                                begin
                                        for cur in origem loop
                                                delete from PED_LANÇ T where (T.PED_REF || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PED_LANÇ: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PED_LANÇ: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PED_LANÇ - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CONTA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'CONTA';
                                begin
                                        for cur in origem loop
                                                delete from CONTA T where (T.EMPRESA || T.CONTA = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CONTA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CONTA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CONTA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PED_CONTATO
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'PED_CONTATO';
                                begin
                                        for cur in origem loop
                                                delete from PED_CONTATO T where (T.PED_REF || T.CIA_COD || T.CONTATO_NOME = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PED_CONTATO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PED_CONTATO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PED_CONTATO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela FRETE
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'FRETE';
                                begin
                                        for cur in origem loop
                                                delete from FRETE T where (T.CARGA_PORTO || T.DESCARGA_PORTO || T.PROPRIETÁRIO || T.FRETE_DETALHE = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg FRETE: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído FRETE: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela FRETE - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela DIVISÃO
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'DIVISÃO';
                                begin
                                        for cur in origem loop
                                                delete from DIVISÃO T where (T.ESCRITÓRIO || T.DIVISÃO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg DIVISÃO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído DIVISÃO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela DIVISÃO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela EMB
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'EMB';
                                begin
                                        for cur in origem loop
                                                delete from EMB T where (T.REF = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg EMB: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído EMB: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela EMB - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CARTA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'CARTA';
                                begin
                                        for cur in origem loop
                                                delete from CARTA T where (T.REF = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CARTA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CARTA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CARTA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela EMB_F
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'EMB_F';
                                begin
                                        for cur in origem loop
                                                delete from EMB_F T where (T.PED_REF || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg EMB_F: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído EMB_F: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela EMB_F - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela FECH_CARGA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'FECH_CARGA';
                                begin
                                        for cur in origem loop
                                                delete from FECH_CARGA T where (T.FECH_REF || T.PED_REF || T.PED_ITEM = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg FECH_CARGA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído FECH_CARGA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela FECH_CARGA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela TIPO_REF
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'TIPO_REF';
                                begin
                                        for cur in origem loop
                                                delete from TIPO_REF T where (T.TIPO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg TIPO_REF: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído TIPO_REF: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela TIPO_REF - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela RAMO_ATIVIDADE
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'RAMO_ATIVIDADE';
                                begin
                                        for cur in origem loop
                                                delete from RAMO_ATIVIDADE T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg RAMO_ATIVIDADE: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído RAMO_ATIVIDADE: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela RAMO_ATIVIDADE - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela LANÇ
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'LANÇ';
                                begin
                                        for cur in origem loop
                                                delete from LANÇ T where (T.LANÇ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg LANÇ: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído LANÇ: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela LANÇ - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela DEPTO
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'DEPTO';
                                begin
                                        for cur in origem loop
                                                delete from DEPTO T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg DEPTO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído DEPTO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela DEPTO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CARTA_CRÉDITO
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'CARTA_CRÉDITO';
                                begin
                                        for cur in origem loop
                                                delete from CARTA_CRÉDITO T where (T.REF = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CARTA_CRÉDITO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CARTA_CRÉDITO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CARTA_CRÉDITO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CONFIRM_VENDA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'CONFIRM_VENDA';
                                begin
                                        for cur in origem loop
                                                delete from CONFIRM_VENDA T where (T.REF || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CONFIRM_VENDA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CONFIRM_VENDA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CONFIRM_VENDA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PED_ITEM
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'PED_ITEM';
                                begin
                                        for cur in origem loop
                                                delete from PED_ITEM T where (T.PED_REF || T.ITEM = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PED_ITEM: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PED_ITEM: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PED_ITEM - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela FECH
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'FECH';
                                begin
                                        for cur in origem loop
                                                delete from FECH T where (T.REF = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg FECH: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído FECH: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela FECH - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela COSIPA_NEGOCIAÇÃO
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'COSIPA_NEGOCIAÇÃO';
                                begin
                                        for cur in origem loop
                                                delete from COSIPA_NEGOCIAÇÃO T where (T.REF = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg COSIPA_NEGOCIAÇÃO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído COSIPA_NEGOCIAÇÃO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela COSIPA_NEGOCIAÇÃO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela ESCRITÓRIO
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'ESCRITÓRIO';
                                begin
                                        for cur in origem loop
                                                delete from ESCRITÓRIO T where (T.ESCRITÓRIO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg ESCRITÓRIO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído ESCRITÓRIO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela ESCRITÓRIO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PRODUTO
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'PRODUTO';
                                begin
                                        for cur in origem loop
                                                delete from PRODUTO T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PRODUTO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PRODUTO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PRODUTO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PARAM
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'PARAM';
                                begin
                                        for cur in origem loop
                                                delete from PARAM T where (T.GRUPO || T.PARAM = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PARAM: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PARAM: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PARAM - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela EMBALAGEM
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'EMBALAGEM';
                                begin
                                        for cur in origem loop
                                                delete from EMBALAGEM T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg EMBALAGEM: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído EMBALAGEM: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela EMBALAGEM - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela UNID_QUANTID
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'UNID_QUANTID';
                                begin
                                        for cur in origem loop
                                                delete from UNID_QUANTID T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg UNID_QUANTID: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído UNID_QUANTID: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela UNID_QUANTID - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela VIAGEM_ESCALA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'VIAGEM_ESCALA';
                                begin
                                        for cur in origem loop
                                                delete from VIAGEM_ESCALA T where (T.VIAGEM_REF || T.ESCALA = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg VIAGEM_ESCALA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído VIAGEM_ESCALA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela VIAGEM_ESCALA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PED
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'PED';
                                begin
                                        for cur in origem loop
                                                delete from PED T where (T.REF = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PED: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PED: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PED - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela VIAGEM
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'VIAGEM';
                                begin
                                        for cur in origem loop
                                                delete from VIAGEM T where (T.REF = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg VIAGEM: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído VIAGEM: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela VIAGEM - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela VIA_TRANSPORTE
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'VIA_TRANSPORTE';
                                begin
                                        for cur in origem loop
                                                delete from VIA_TRANSPORTE T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg VIA_TRANSPORTE: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído VIA_TRANSPORTE: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela VIA_TRANSPORTE - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CIA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'CIA';
                                begin
                                        for cur in origem loop
                                                delete from CIA T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CIA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CIA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CIA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela GRUPO_PRODUTO
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'GRUPO_PRODUTO';
                                begin
                                        for cur in origem loop
                                                delete from GRUPO_PRODUTO T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg GRUPO_PRODUTO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído GRUPO_PRODUTO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela GRUPO_PRODUTO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela COND_PAG
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'COND_PAG';
                                begin
                                        for cur in origem loop
                                                delete from COND_PAG T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg COND_PAG: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído COND_PAG: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela COND_PAG - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PORTO
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'PORTO';
                                begin
                                        for cur in origem loop
                                                delete from PORTO T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PORTO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PORTO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PORTO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela INCOTERM
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'INCOTERM';
                                begin
                                        for cur in origem loop
                                                delete from INCOTERM T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg INCOTERM: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído INCOTERM: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela INCOTERM - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela MODALIDADE_FRETE
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'MODALIDADE_FRETE';
                                begin
                                        for cur in origem loop
                                                delete from MODALIDADE_FRETE T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg MODALIDADE_FRETE: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído MODALIDADE_FRETE: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela MODALIDADE_FRETE - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela MOEDA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'MOEDA';
                                begin
                                        for cur in origem loop
                                                delete from MOEDA T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg MOEDA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído MOEDA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela MOEDA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela NAVIO
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'NAVIO';
                                begin
                                        for cur in origem loop
                                                delete from NAVIO T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg NAVIO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído NAVIO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela NAVIO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PAÍS
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'PAÍS';
                                begin
                                        for cur in origem loop
                                                delete from PAÍS T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PAÍS: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PAÍS: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PAÍS - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela IDIOMA
                        begin
                                declare
                                        cursor origem is select NOME_TABELA,CHAVE,MOMENTO,USUÁRIO,LOCAL from CXSP.SYS_DELETE_T where NOME_TABELA = 'IDIOMA';
                                begin
                                        for cur in origem loop
                                                delete from IDIOMA T where (T.COD = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg IDIOMA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído IDIOMA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela IDIOMA - ' || SQLERRM);
                                end;
                        end;


                        log(reglog, 'Gravando todas as alterações realizadas.');
                        if not arqpac_remoto = localpac_remoto then
                                update SYS_LOCALID set PACOTE_REC = mod(numpac_remoto + 1, 10000), MOMENTO_REC = SYSDATE where NOME = localpac_remoto;
                        end if;

                        update SYS_LOCALID set MODELO = 0, MOMENTO = SYSDATE where NOME = localpac;
                        modelopac := 0;
                        modelorec := 0;

                        COMMIT;

                        log(reglog, 'Excluindo arquivos temporários.');
                        err := DBMS_CX.DOSSHELL('DEL ' || diretorio || '\' || arqpac_remoto || '.PAC>' || diretorio || '\RECEB.TMP');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando DEL');
                        end if;
                        loga(reglog, diretorio, 'RECEB.TMP');

                        err := DBMS_CX.DOSSHELL('DEL ' || diretorio || '\RECEB.TMP');

                        log(reglog, 'Término de recebimento do pacote ' || diretorio || '\' || arqpac_remoto || '.ARJ');
                        utl_file.fclose(reglog);

                        if not (email is null or servsmtp is null) then

                                err := sendmail('cxsp@xxxxxxxxxx.com.br', email, 'CIEX - Recebimento de pacote ' ||
                                        diretorio || '\' || arqpac_remoto || '.ARJ', servsmtp, NULL,
                                        'D:\CXSP_T\' || arqpac_remoto || '.LOG');

                        end if;

                        if not (arqpac_remoto = localpac_remoto) then
                                goto recebe_novamente;
                        end if;
                end;

        exception
                when others then
                        ROLLBACK;

                        if modelorec <> -1 then
                                update SYS_LOCALID set MODELO = modelorec, MOMENTO = SYSDATE where NOME = localpac;
                                COMMIT;
                        end if;

                        log(reglog, 'Erro no recebimento do pacote.');
                        log(reglog, SQLERRM);
                        if utl_file.is_open(reglog) then
                                utl_file.fclose(reglog);
                        end if;

                        if not (email is null or servsmtp is null) then
                                err := sendmail('cxsp@xxxxxxxxxx.com.br', email, 'CIEX - Rotina de tratamento de pacote', servsmtp, 'Erro durante o tratamento do pacote.', diretorio || '\' || arqpac_remoto || '.LOG');
                        end if;
                        raise_application_error ( -20000, 'erro na função de tratamento de pacotes -> ' || SQLERRM );
        end;




        procedure inicia_localidade(diretorio in varchar2, arquivo in varchar2, senhalocal in varchar2, servicolocal in varchar2) is
        sqlcursor integer;
        err integer;
        sql_notfound boolean;

        numpac integer;
        arqpac varchar2(100);
        localpac varchar2(100);
        numpac_remoto integer;
        arqpac_remoto varchar2(100);
        reglog utl_file.file_type;
        modelopac SYS_LOCALID.MODELO%type;

        origem_usuario char(20);
        origem_local char(20);
        origem_momento date;
        destino_usuario char(20);
        destino_local char(20);
        destino_momento date;

        begin
                begin
                        reglog := utl_file.fopen(diretorio, 'RECEB.LOG', 'a');

                        log(reglog, '');
                        log(reglog, '----------------------------------------------------------------------');
                        log(reglog, 'Iniciando localidade a partir do arquivo ' || diretorio || '\' || arquivo || '.ARJ');

                        err := DBMS_CX.DOSSHELL('arj32.exe e -y -ht' || diretorio || '\ ' || diretorio || '\' || arquivo || '.ARJ ' || arquivo || '.PAC ' || '>' || diretorio || '\RECEB.TMP');

                        if err = 6 then
                                log(reglog, 'Pacote não encontrado.');
                                err := DBMS_CX.DOSSHELL('DEL ' || diretorio || '\RECEB.TMP');
                                utl_file.fclose(reglog);
                                return;
                        elsif err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando arj32.exe');
                        end if;
                        loga(reglog, diretorio, 'RECEB.TMP');

                        delete from EMB_FAMÍLIA_GENÉRICA_T;
                        delete from DOC_T;
                        delete from EMB_FAMÍLIA_T;
                        delete from EMB_RE_T;
                        delete from BL_T;
                        delete from BL_CARGA_T;
                        delete from DIVISÃO_PRODUTO_T;
                        delete from EMB_TOTALIZA_T;
                        delete from DIVISÃO_TIPO_REF_T;
                        delete from EMB_DOC_REL_T;
                        delete from MAPA_T;
                        delete from INCOTERM_LANÇ_T;
                        delete from LOCAL_RESULT_T;
                        delete from EMB_SD_T;
                        delete from PARAM_CSN_T;
                        delete from EMB_LANÇ_T;
                        delete from EMB_MENSAGEM_T;
                        delete from ANEXO_T;
                        delete from EMPRESA_APUR_T;
                        delete from LOG_IMPORT_T;
                        delete from CIA_RAMO_ATIVIDADE_T;
                        delete from CARTA_FECH_T;
                        delete from SYS_DELETE_T;
                        delete from SUB_CONTA_T;
                        delete from RESULT_T;
                        delete from RELACIONADA_T;
                        delete from CIA_CONTATO_T;
                        delete from PRODUTO_ESPECIF_T;
                        delete from FRETE_T;
                        delete from CONFIRM_VENDA_ITEM_T;
                        delete from PLANILHA_STC_T;
                        delete from PLANILHA_DEF_T;
                        delete from PED_RESULT_T;
                        delete from PED_LANÇ_T;
                        delete from CONTA_T;
                        delete from PED_CONTATO_T;
                        delete from DIVISÃO_T;
                        delete from EMB_T;
                        delete from CARTA_T;
                        delete from EMB_F_T;
                        delete from TIPO_REF_T;
                        delete from FECH_CARGA_T;
                        delete from RAMO_ATIVIDADE_T;
                        delete from LANÇ_T;
                        delete from DEPTO_T;
                        delete from CARTA_CRÉDITO_T;
                        delete from CONFIRM_VENDA_T;
                        delete from PED_ITEM_T;
                        delete from COSIPA_NEGOCIAÇÃO_T;
                        delete from ESCRITÓRIO_T;
                        delete from FECH_T;
                        delete from PRODUTO_T;
                        delete from PARAM_T;
                        delete from EMBALAGEM_T;
                        delete from UNID_QUANTID_T;
                        delete from VIAGEM_ESCALA_T;
                        delete from PED_T;
                        delete from VIAGEM_T;
                        delete from VIA_TRANSPORTE_T;
                        delete from CIA_T;
                        delete from COND_PAG_T;
                        delete from MOEDA_T;
                        delete from PORTO_T;
                        delete from INCOTERM_T;
                        delete from GRUPO_PRODUTO_T;
                        delete from MODALIDADE_FRETE_T;
                        delete from NAVIO_T;
                        delete from PAÍS_T;
                        delete from IDIOMA_T;
                        COMMIT;

                        log(reglog, 'Importando informações do pacote.');
                        err := DBMS_CX.DOSSHELL('imp.exe CXSP/' || senhalocal || '@' || servicolocal || ' FILE=' || diretorio || '\' || arquivo || '.PAC' || ' LOG=' || diretorio || '\RECEB.TMP PARFILE=' || diretorio || '\' || 'RECEB.PAR FROMUSER=CXRJ');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando imp.exe');
                        end if;
                        loga(reglog, diretorio, 'RECEB.TMP');

                        log(reglog, 'Apaga registros das tabelas da localidade.');
                        log(reglog, 'Excluindo registros de EMB_FAMÍLIA_GENÉRICA.');
                        delete from EMB_FAMÍLIA_GENÉRICA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de DOC.');
                        delete from DOC;
                        COMMIT;
                        log(reglog, 'Excluindo registros de EMB_FAMÍLIA.');
                        delete from EMB_FAMÍLIA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de EMB_RE.');
                        delete from EMB_RE;
                        COMMIT;
                        log(reglog, 'Excluindo registros de BL.');
                        delete from BL;
                        COMMIT;
                        log(reglog, 'Excluindo registros de BL_CARGA.');
                        delete from BL_CARGA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de DIVISÃO_PRODUTO.');
                        delete from DIVISÃO_PRODUTO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de EMB_TOTALIZA.');
                        delete from EMB_TOTALIZA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de DIVISÃO_TIPO_REF.');
                        delete from DIVISÃO_TIPO_REF;
                        COMMIT;
                        log(reglog, 'Excluindo registros de EMB_DOC_REL.');
                        delete from EMB_DOC_REL;
                        COMMIT;
                        log(reglog, 'Excluindo registros de MAPA.');
                        delete from MAPA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de INCOTERM_LANÇ.');
                        delete from INCOTERM_LANÇ;
                        COMMIT;
                        log(reglog, 'Excluindo registros de LOCAL_RESULT.');
                        delete from LOCAL_RESULT;
                        COMMIT;
                        log(reglog, 'Excluindo registros de EMB_SD.');
                        delete from EMB_SD;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PARAM_CSN.');
                        delete from PARAM_CSN;
                        COMMIT;
                        log(reglog, 'Excluindo registros de EMB_LANÇ.');
                        delete from EMB_LANÇ;
                        COMMIT;
                        log(reglog, 'Excluindo registros de EMB_MENSAGEM.');
                        delete from EMB_MENSAGEM;
                        COMMIT;
                        log(reglog, 'Excluindo registros de ANEXO.');
                        delete from ANEXO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de EMPRESA_APUR.');
                        delete from EMPRESA_APUR;
                        COMMIT;
                        log(reglog, 'Excluindo registros de LOG_IMPORT.');
                        delete from LOG_IMPORT;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CIA_RAMO_ATIVIDADE.');
                        delete from CIA_RAMO_ATIVIDADE;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CARTA_FECH.');
                        delete from CARTA_FECH;
                        COMMIT;
                        log(reglog, 'Excluindo registros de SYS_DELETE.');
                        delete from SYS_DELETE;
                        COMMIT;
                        log(reglog, 'Excluindo registros de SUB_CONTA.');
                        delete from SUB_CONTA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de RESULT.');
                        delete from RESULT;
                        COMMIT;
                        log(reglog, 'Excluindo registros de RELACIONADA.');
                        delete from RELACIONADA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CIA_CONTATO.');
                        delete from CIA_CONTATO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PRODUTO_ESPECIF.');
                        delete from PRODUTO_ESPECIF;
                        COMMIT;
                        log(reglog, 'Excluindo registros de FRETE.');
                        delete from FRETE;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CONFIRM_VENDA_ITEM.');
                        delete from CONFIRM_VENDA_ITEM;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PLANILHA_STC.');
                        delete from PLANILHA_STC;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PLANILHA_DEF.');
                        delete from PLANILHA_DEF;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PED_RESULT.');
                        delete from PED_RESULT;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PED_LANÇ.');
                        delete from PED_LANÇ;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CONTA.');
                        delete from CONTA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PED_CONTATO.');
                        delete from PED_CONTATO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de DIVISÃO.');
                        delete from DIVISÃO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de EMB.');
                        delete from EMB;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CARTA.');
                        delete from CARTA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de EMB_F.');
                        delete from EMB_F;
                        COMMIT;
                        log(reglog, 'Excluindo registros de TIPO_REF.');
                        delete from TIPO_REF;
                        COMMIT;
                        log(reglog, 'Excluindo registros de FECH_CARGA.');
                        delete from FECH_CARGA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de RAMO_ATIVIDADE.');
                        delete from RAMO_ATIVIDADE;
                        COMMIT;
                        log(reglog, 'Excluindo registros de LANÇ.');
                        delete from LANÇ;
                        COMMIT;
                        log(reglog, 'Excluindo registros de DEPTO.');
                        delete from DEPTO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CARTA_CRÉDITO.');
                        delete from CARTA_CRÉDITO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CONFIRM_VENDA.');
                        delete from CONFIRM_VENDA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PED_ITEM.');
                        delete from PED_ITEM;
                        COMMIT;
                        log(reglog, 'Excluindo registros de COSIPA_NEGOCIAÇÃO.');
                        delete from COSIPA_NEGOCIAÇÃO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de ESCRITÓRIO.');
                        delete from ESCRITÓRIO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de FECH.');
                        delete from FECH;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PRODUTO.');
                        delete from PRODUTO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PARAM.');
                        delete from PARAM;
                        COMMIT;
                        log(reglog, 'Excluindo registros de EMBALAGEM.');
                        delete from EMBALAGEM;
                        COMMIT;
                        log(reglog, 'Excluindo registros de UNID_QUANTID.');
                        delete from UNID_QUANTID;
                        COMMIT;
                        log(reglog, 'Excluindo registros de VIAGEM_ESCALA.');
                        delete from VIAGEM_ESCALA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PED.');
                        delete from PED;
                        COMMIT;
                        log(reglog, 'Excluindo registros de VIAGEM.');
                        delete from VIAGEM;
                        COMMIT;
                        log(reglog, 'Excluindo registros de VIA_TRANSPORTE.');
                        delete from VIA_TRANSPORTE;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CIA.');
                        delete from CIA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de COND_PAG.');
                        delete from COND_PAG;
                        COMMIT;
                        log(reglog, 'Excluindo registros de MOEDA.');
                        delete from MOEDA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PORTO.');
                        delete from PORTO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de INCOTERM.');
                        delete from INCOTERM;
                        COMMIT;
                        log(reglog, 'Excluindo registros de GRUPO_PRODUTO.');
                        delete from GRUPO_PRODUTO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de MODALIDADE_FRETE.');
                        delete from MODALIDADE_FRETE;
                        COMMIT;
                        log(reglog, 'Excluindo registros de NAVIO.');
                        delete from NAVIO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PAÍS.');
                        delete from PAÍS;
                        COMMIT;
                        log(reglog, 'Excluindo registros de IDIOMA.');
                        delete from IDIOMA;
                        COMMIT;
                        COMMIT;

                        -- transfere registros da tabela ESCRITÓRIO para a localidade
                        log(reglog, 'Transferindo registros da tabela ESCRITÓRIO.');
                        begin
                                insert into CXSP.ESCRITÓRIO         (ESCRITÓRIO, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.ESCRITÓRIO, T.DESCR, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.ESCRITÓRIO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela ESCRITÓRIO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela MOEDA para a localidade
                        log(reglog, 'Transferindo registros da tabela MOEDA.');
                        begin
                                insert into CXSP.MOEDA         (COD, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.NOME, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.MOEDA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela MOEDA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela MODALIDADE_FRETE para a localidade
                        log(reglog, 'Transferindo registros da tabela MODALIDADE_FRETE.');
                        begin
                                insert into CXSP.MODALIDADE_FRETE         (COD, DESCR, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.DESCR, T.OBS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.MODALIDADE_FRETE_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela MODALIDADE_FRETE -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela MAPA para a localidade
                        log(reglog, 'Transferindo registros da tabela MAPA.');
                        begin
                                insert into CXSP.MAPA         (WORKSHEET, SEQ, EMPRESA, ARQUIVO, TITULO, LINHA, COLUNA, COR, LARGURA, FONT, FONT_NEGRITO, FONT_TAM, ALINHAMENTO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.WORKSHEET, T.SEQ, T.EMPRESA, T.ARQUIVO, T.TITULO, T.LINHA, T.COLUNA, T.COR, T.LARGURA, T.FONT, T.FONT_NEGRITO, T.FONT_TAM, T.ALINHAMENTO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.MAPA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela MAPA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela LOCAL_RESULT para a localidade
                        log(reglog, 'Transferindo registros da tabela LOCAL_RESULT.');
                        begin
                                insert into CXSP.LOCAL_RESULT         (COD, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.DESCR, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.LOCAL_RESULT_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela LOCAL_RESULT -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela COSIPA_NEGOCIAÇÃO para a localidade
                        log(reglog, 'Transferindo registros da tabela COSIPA_NEGOCIAÇÃO.');
                        begin
                                insert into CXSP.COSIPA_NEGOCIAÇÃO         (REF, REF_EXT, DATA_ORD, ALTERA, MÊS_NEG, MÊS_EMB, AGENTE, PRODUTO, TON, PAÍS_DESTINO, PORTO_DESTINO, IMP, OUTRO_DOC, PEÇAS, TRAT_TÉRMICO, TOLER_PROD_LOT_MAX, TOLER_PROD_LOT_MIN, COND_PAG, TERMO_ENTREGA, PREÇO, COMISS_AGENTE, OBS_GERAL, INSP_CLASS, FATURA_LÂMINA, FATURA_OUTRO, EXTERNAL_SURVEY_TYPE, EXTERNAL_SURVEYOR, SURVEY_SIGN_CERTIF, CLASS_ORG, END_USER, HRP, HRC, CRC, PREDAYS, POSDAYS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.REF, T.REF_EXT, T.DATA_ORD, T.ALTERA, T.MÊS_NEG, T.MÊS_EMB, T.AGENTE, T.PRODUTO, T.TON, T.PAÍS_DESTINO, T.PORTO_DESTINO, T.IMP, T.OUTRO_DOC, T.PEÇAS, T.TRAT_TÉRMICO, T.TOLER_PROD_LOT_MAX, T.TOLER_PROD_LOT_MIN, T.COND_PAG, T.TERMO_ENTREGA, T.PREÇO, T.COMISS_AGENTE, T.OBS_GERAL, T.INSP_CLASS, T.FATURA_LÂMINA, T.FATURA_OUTRO, T.EXTERNAL_SURVEY_TYPE, T.EXTERNAL_SURVEYOR, T.SURVEY_SIGN_CERTIF, T.CLASS_ORG, T.END_USER, T.HRP, T.HRC, T.CRC, T.PREDAYS, T.POSDAYS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.COSIPA_NEGOCIAÇÃO_T T WHERE T.REF LIKE 'SP%' OR T.REF LIKE 'RJP%';
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela COSIPA_NEGOCIAÇÃO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela INCOTERM para a localidade
                        log(reglog, 'Transferindo registros da tabela INCOTERM.');
                        begin
                                insert into CXSP.INCOTERM         (COD, DESCR, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.DESCR, T.OBS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.INCOTERM_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela INCOTERM -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela IDIOMA para a localidade
                        log(reglog, 'Transferindo registros da tabela IDIOMA.');
                        begin
                                insert into CXSP.IDIOMA         (COD, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.DESCR, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.IDIOMA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela IDIOMA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PARAM para a localidade
                        log(reglog, 'Transferindo registros da tabela PARAM.');
                        begin
                                insert into CXSP.PARAM         (GRUPO, PARAM, QUANDO_TEXTO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.GRUPO, T.PARAM, T.QUANDO_TEXTO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.PARAM_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PARAM -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela ANEXO para a localidade
                        log(reglog, 'Transferindo registros da tabela ANEXO.');
                        begin
                                insert into CXSP.ANEXO         (NOME, SUB_CONTA, SUB_CONTA_REL, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.NOME, T.SUB_CONTA, T.SUB_CONTA_REL, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.ANEXO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela ANEXO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela LOG_IMPORT para a localidade
                        log(reglog, 'Transferindo registros da tabela LOG_IMPORT.');
                        begin
                                insert into CXSP.LOG_IMPORT         (DATA, NOME, SEQ, SITUAÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.DATA, T.NOME, T.SEQ, T.SITUAÇÃO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.LOG_IMPORT_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela LOG_IMPORT -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela EMPRESA_APUR para a localidade
                        log(reglog, 'Transferindo registros da tabela EMPRESA_APUR.');
                        begin
                                insert into CXSP.EMPRESA_APUR         (EMPRESA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.EMPRESA, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.EMPRESA_APUR_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela EMPRESA_APUR -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela EMBALAGEM para a localidade
                        log(reglog, 'Transferindo registros da tabela EMBALAGEM.');
                        begin
                                insert into CXSP.EMBALAGEM         (COD, DESCR, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.DESCR, T.OBS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.EMBALAGEM_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela EMBALAGEM -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CARTA_CRÉDITO para a localidade
                        log(reglog, 'Transferindo registros da tabela CARTA_CRÉDITO.');
                        begin
                                insert into CXSP.CARTA_CRÉDITO         (REF, REF_LC, DATA_EMISS, MOEDA, VALOR, PESO, BCO_EMISSOR, BCO_NEGOCIADOR, BCO_AVISADOR, BCO_CONFIRMADOR, BCO_RECEBEDOR, VALIDADE_LC, VALIDADE_EMB, FORM_PAGAMENTO, TOLER_QTD, TOLER_VALOR, APRESENT_DOC, UNID_PESO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.REF, T.REF_LC, T.DATA_EMISS, T.MOEDA, T.VALOR, T.PESO, T.BCO_EMISSOR, T.BCO_NEGOCIADOR, T.BCO_AVISADOR, T.BCO_CONFIRMADOR, T.BCO_RECEBEDOR, T.VALIDADE_LC, T.VALIDADE_EMB, T.FORM_PAGAMENTO, T.TOLER_QTD, T.TOLER_VALOR, T.APRESENT_DOC, T.UNID_PESO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.CARTA_CRÉDITO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CARTA_CRÉDITO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela COND_PAG para a localidade
                        log(reglog, 'Transferindo registros da tabela COND_PAG.');
                        begin
                                insert into CXSP.COND_PAG         (COD, DESCR, PERÍODO, OBS, FIN_COND, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.DESCR, T.PERÍODO, T.OBS, T.FIN_COND, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.COND_PAG_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela COND_PAG -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CONTA para a localidade
                        log(reglog, 'Transferindo registros da tabela CONTA.');
                        begin
                                insert into CXSP.CONTA         (EMPRESA, CONTA, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.EMPRESA, T.CONTA, T.NOME, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.CONTA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CONTA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela DOC para a localidade
                        log(reglog, 'Transferindo registros da tabela DOC.');
                        begin
                                insert into CXSP.DOC         (COD, NOME, OBJETO_VINCULADO, FORMULÁRIO_PARAM, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.NOME, T.OBJETO_VINCULADO, T.FORMULÁRIO_PARAM, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.DOC_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela DOC -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela DEPTO para a localidade
                        log(reglog, 'Transferindo registros da tabela DEPTO.');
                        begin
                                insert into CXSP.DEPTO         (COD, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.NOME, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.DEPTO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela DEPTO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela GRUPO_PRODUTO para a localidade
                        log(reglog, 'Transferindo registros da tabela GRUPO_PRODUTO.');
                        begin
                                insert into CXSP.GRUPO_PRODUTO         (COD, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.DESCR, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.GRUPO_PRODUTO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela GRUPO_PRODUTO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela RAMO_ATIVIDADE para a localidade
                        log(reglog, 'Transferindo registros da tabela RAMO_ATIVIDADE.');
                        begin
                                insert into CXSP.RAMO_ATIVIDADE         (COD, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.NOME, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.RAMO_ATIVIDADE_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela RAMO_ATIVIDADE -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela VIA_TRANSPORTE para a localidade
                        log(reglog, 'Transferindo registros da tabela VIA_TRANSPORTE.');
                        begin
                                insert into CXSP.VIA_TRANSPORTE         (COD, DESCR, TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.DESCR, T.TIPO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.VIA_TRANSPORTE_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela VIA_TRANSPORTE -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela UNID_QUANTID para a localidade
                        log(reglog, 'Transferindo registros da tabela UNID_QUANTID.');
                        begin
                                insert into CXSP.UNID_QUANTID         (COD, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.NOME, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.UNID_QUANTID_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela UNID_QUANTID -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela SUB_CONTA para a localidade
                        log(reglog, 'Transferindo registros da tabela SUB_CONTA.');
                        begin
                                insert into CXSP.SUB_CONTA         (EMPRESA, SUB_CONTA, CONTA, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.EMPRESA, T.SUB_CONTA, T.CONTA, T.NOME, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.SUB_CONTA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela SUB_CONTA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela LANÇ para a localidade
                        log(reglog, 'Transferindo registros da tabela LANÇ.');
                        begin
                                insert into CXSP.LANÇ         (LANÇ, NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.LANÇ, T.NOME, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.LANÇ_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela LANÇ -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela RELACIONADA para a localidade
                        log(reglog, 'Transferindo registros da tabela RELACIONADA.');
                        begin
                                insert into CXSP.RELACIONADA         (REF, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.REF, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.RELACIONADA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela RELACIONADA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PARAM_CSN para a localidade
                        log(reglog, 'Transferindo registros da tabela PARAM_CSN.');
                        begin
                                insert into CXSP.PARAM_CSN         (PROD, PARAM, VALOR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.PROD, T.PARAM, T.VALOR, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.PARAM_CSN_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PARAM_CSN -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PLANILHA_STC para a localidade
                        log(reglog, 'Transferindo registros da tabela PLANILHA_STC.');
                        begin
                                insert into CXSP.PLANILHA_STC         (WORKSHEET, EMPRESA, ARQUIVO, MAPA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.WORKSHEET, T.EMPRESA, T.ARQUIVO, T.MAPA, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.PLANILHA_STC_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PLANILHA_STC -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PLANILHA_DEF para a localidade
                        log(reglog, 'Transferindo registros da tabela PLANILHA_DEF.');
                        begin
                                insert into CXSP.PLANILHA_DEF         (WORKSHEET, SEQ, EMPRESA, ARQUIVO, TIPO, HISTÓRICO, DATAHIST, COLUNACRT, CRT, COLUNADBCR, DÉBITO, CRÉDITO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.WORKSHEET, T.SEQ, T.EMPRESA, T.ARQUIVO, T.TIPO, T.HISTÓRICO, T.DATAHIST, T.COLUNACRT, T.CRT, T.COLUNADBCR, T.DÉBITO, T.CRÉDITO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.PLANILHA_DEF_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PLANILHA_DEF -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela INCOTERM_LANÇ para a localidade
                        log(reglog, 'Transferindo registros da tabela INCOTERM_LANÇ.');
                        begin
                                insert into CXSP.INCOTERM_LANÇ         (INCOTERM, LANÇ, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.INCOTERM, T.LANÇ, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.INCOTERM_LANÇ_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela INCOTERM_LANÇ -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PRODUTO para a localidade
                        log(reglog, 'Transferindo registros da tabela PRODUTO.');
                        begin
                                insert into CXSP.PRODUTO         (COD, NOME, GRUPO, NCM, NALADI, NCM_OBS, NALADI_OBS, MEDIDAS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.NOME, T.GRUPO, T.NCM, T.NALADI, T.NCM_OBS, T.NALADI_OBS, T.MEDIDAS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.PRODUTO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PRODUTO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela DIVISÃO para a localidade
                        log(reglog, 'Transferindo registros da tabela DIVISÃO.');
                        begin
                                insert into CXSP.DIVISÃO         (ESCRITÓRIO, DIVISÃO, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.ESCRITÓRIO, T.DIVISÃO, T.DESCR, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.DIVISÃO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela DIVISÃO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PAÍS para a localidade
                        log(reglog, 'Transferindo registros da tabela PAÍS.');
                        begin
                                insert into CXSP.PAÍS         (COD, NOME, ABREVIATURA, BANDEIRA_COD, IDIOMA, MSG, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.NOME, T.ABREVIATURA, T.BANDEIRA_COD, T.IDIOMA, T.MSG, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.PAÍS_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PAÍS -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela TIPO_REF para a localidade
                        log(reglog, 'Transferindo registros da tabela TIPO_REF.');
                        begin
                                insert into CXSP.TIPO_REF         (TIPO, DESCR, DEPTO, ARQUIVO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.TIPO, T.DESCR, T.DEPTO, T.ARQUIVO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.TIPO_REF_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela TIPO_REF -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CIA para a localidade
                        log(reglog, 'Transferindo registros da tabela CIA.');
                        begin
                                insert into CXSP.CIA         (LOGO, LOGOTIPO, COD, CGC, NOME, ENDEREÇO, BAIRRO, CIDADE, ESTADO, PAÍS, CEP, CAIXA_POSTAL, TELEFONE, FAX, TELEX, E_MAIL, F_COD, MARCAÇÃO, OBS, LOCAL_RESULT, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.LOGO, T.LOGOTIPO, T.COD, T.CGC, T.NOME, T.ENDEREÇO, T.BAIRRO, T.CIDADE, T.ESTADO, T.PAÍS, T.CEP, T.CAIXA_POSTAL, T.TELEFONE, T.FAX, T.TELEX, T.E_MAIL, T.F_COD, T.MARCAÇÃO, T.OBS, T.LOCAL_RESULT, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.CIA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CIA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PORTO para a localidade
                        log(reglog, 'Transferindo registros da tabela PORTO.');
                        begin
                                insert into CXSP.PORTO         (COD, NOME, CIDADE, ESTADO, PAÍS, RESTRIÇÕES, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.NOME, T.CIDADE, T.ESTADO, T.PAÍS, T.RESTRIÇÕES, T.OBS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.PORTO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PORTO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela DIVISÃO_PRODUTO para a localidade
                        log(reglog, 'Transferindo registros da tabela DIVISÃO_PRODUTO.');
                        begin
                                insert into CXSP.DIVISÃO_PRODUTO         (ESCRITÓRIO, DIVISÃO, PROD, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.ESCRITÓRIO, T.DIVISÃO, T.PROD, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.DIVISÃO_PRODUTO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela DIVISÃO_PRODUTO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PRODUTO_ESPECIF para a localidade
                        log(reglog, 'Transferindo registros da tabela PRODUTO_ESPECIF.');
                        begin
                                insert into CXSP.PRODUTO_ESPECIF         (COD, SEQ, NCM, NALADI, MENOR_ESPESSURA, MAIOR_ESPESSURA, MENOR_LARGURA, MAIOR_LARGURA, MENOR_COMPRIMENTO, MAIOR_COMPRIMENTO, REVESTIMENTO, TÊMPERA, DESCR, DESCR_NALADI, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.SEQ, T.NCM, T.NALADI, T.MENOR_ESPESSURA, T.MAIOR_ESPESSURA, T.MENOR_LARGURA, T.MAIOR_LARGURA, T.MENOR_COMPRIMENTO, T.MAIOR_COMPRIMENTO, T.REVESTIMENTO, T.TÊMPERA, T.DESCR, T.DESCR_NALADI, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.PRODUTO_ESPECIF_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PRODUTO_ESPECIF -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela DIVISÃO_TIPO_REF para a localidade
                        log(reglog, 'Transferindo registros da tabela DIVISÃO_TIPO_REF.');
                        begin
                                insert into CXSP.DIVISÃO_TIPO_REF         (ESCRITÓRIO, DIVISÃO, TIPO_REF, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.ESCRITÓRIO, T.DIVISÃO, T.TIPO_REF, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.DIVISÃO_TIPO_REF_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela DIVISÃO_TIPO_REF -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela NAVIO para a localidade
                        log(reglog, 'Transferindo registros da tabela NAVIO.');
                        begin
                                insert into CXSP.NAVIO         (COD, ANO_CONSTRUÇÃO, NOME, NOME_ANTERIOR, BANDEIRA, NAVIO_TIPO, DWAT, LOA, BEAN, GRT, NRT, CAPACIDADE_GRÃO, CAPACIDADE_FARDO, CALADO_VERÃO, GUINDASTE_NUM, GUINDASTE_DIMENSÃO, ESCOTILHA_NUM, ESCOTILHA_DIMENSÃO, ESCOTILHA_FECHAM_TIPO, EQUIPAMENTO, TANKTOP_STRENGTH, SOCIEDADE_CLASSIFICADORA, CLASSE, OBS, OWNER, CALL_SIGN, N_TANKS, SBT, DOUBLE_HULL, DOUBLE_BOTTOM, INERT_GAS_SYS, HEATING_COILS, IMO_NUM, IMO_TYPE, COATING, CARGO_PUMPS, CUBIC_CAPACITY, CARGO_LINES, CARGO_MANIFOLDS, MAJORS_AP, SUMMER_DRAFT, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.COD, T.ANO_CONSTRUÇÃO, T.NOME, T.NOME_ANTERIOR, T.BANDEIRA, T.NAVIO_TIPO, T.DWAT, T.LOA, T.BEAN, T.GRT, T.NRT, T.CAPACIDADE_GRÃO, T.CAPACIDADE_FARDO, T.CALADO_VERÃO, T.GUINDASTE_NUM, T.GUINDASTE_DIMENSÃO, T.ESCOTILHA_NUM, T.ESCOTILHA_DIMENSÃO, T.ESCOTILHA_FECHAM_TIPO, T.EQUIPAMENTO, T.TANKTOP_STRENGTH, T.SOCIEDADE_CLASSIFICADORA, T.CLASSE, T.OBS, T.OWNER, T.CALL_SIGN, T.N_TANKS, T.SBT, T.DOUBLE_HULL, T.DOUBLE_BOTTOM, T.INERT_GAS_SYS, T.HEATING_COILS, T.IMO_NUM, T.IMO_TYPE, T.COATING, T.CARGO_PUMPS, T.CUBIC_CAPACITY, T.CARGO_LINES, T.CARGO_MANIFOLDS, T.MAJORS_AP, T.SUMMER_DRAFT, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.NAVIO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela NAVIO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela VIAGEM para a localidade
                        log(reglog, 'Transferindo registros da tabela VIAGEM.');
                        begin
                                insert into CXSP.VIAGEM         (REF, NAVIO, NAVIO_ÚLTIMO, CORRENTE, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.REF, T.NAVIO, T.NAVIO_ÚLTIMO, T.CORRENTE, T.OBS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.VIAGEM_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela VIAGEM -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PED para a localidade
                        log(reglog, 'Transferindo registros da tabela PED.');
                        begin
                                insert into CXSP.PED         (REF, PED_DATA, MOEDA, TAXA_USD, VIA_TRANSPORTE, CARGA_PORTO, PAÍS_DESTINO, FORNECEDOR, FORNECEDOR_REF, FORNECEDOR_COND_RECEB, EXP, EXP_REF, EXP_COND_RECEB, IMP, IMP_REF, IMP_COND_RECEB, DISTRIBUIDOR, PAGADOR, FRETE_COND, FRETE_PREV_POR_MT, FRETE_PREV_VALOR, EMB_PREV, MARCAÇÃO, OBS, TIPO_VENDA, GRUPO_PROD, SUPERVISOR_VENDA, PRODUÇÃO_PREV, PARIDADE, INSPEÇÃO_EXTERNA, RESPONSÁVEL_INSP_EXT, AGENTE, TAXA_JUROS_FINANCIAM, JUROS_NO_PREÇO, COMISSÃO_PERCENT, COMISSÃO_MT, ADICIONAL_PERCENT, ADICIONAL_MT, INCIDÊNCIA, TIPO, ANEXO, BENEFICIÁRIO, LOCAL_PAG, BANCO, F_QUANTIDADE, F_PREÇO, F_RESULTADO, F_RESULTADO_MT, F_RESULTADO_P, F_COMISSÃO_FORN, F_COMISSÃO_FORN_P, F_PROFIT_SPLIT, F_DELIV_PURCHASE, F_DELIV_SALES, F_PAY_PURCHASE, F_PAY_SALES, F_OBS, FORNECEDOR_COND_VENDA, EXP_COND_VENDA, IMP_COND_VENDA, INSTRUC_INTERNA, PRODUTOR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.REF, T.PED_DATA, T.MOEDA, T.TAXA_USD, T.VIA_TRANSPORTE, T.CARGA_PORTO, T.PAÍS_DESTINO, T.FORNECEDOR, T.FORNECEDOR_REF, T.FORNECEDOR_COND_RECEB, T.EXP, T.EXP_REF, T.EXP_COND_RECEB, T.IMP, T.IMP_REF, T.IMP_COND_RECEB, T.DISTRIBUIDOR, T.PAGADOR, T.FRETE_COND, T.FRETE_PREV_POR_MT, T.FRETE_PREV_VALOR, T.EMB_PREV, T.MARCAÇÃO, T.OBS, T.TIPO_VENDA, T.GRUPO_PROD, T.SUPERVISOR_VENDA, T.PRODUÇÃO_PREV, T.PARIDADE, T.INSPEÇÃO_EXTERNA, T.RESPONSÁVEL_INSP_EXT, T.AGENTE, T.TAXA_JUROS_FINANCIAM, T.JUROS_NO_PREÇO, T.COMISSÃO_PERCENT, T.COMISSÃO_MT, T.ADICIONAL_PERCENT, T.ADICIONAL_MT, T.INCIDÊNCIA, T.TIPO, T.ANEXO, T.BENEFICIÁRIO, T.LOCAL_PAG, T.BANCO, T.F_QUANTIDADE, T.F_PREÇO, T.F_RESULTADO, T.F_RESULTADO_MT, T.F_RESULTADO_P, T.F_COMISSÃO_FORN, T.F_COMISSÃO_FORN_P, T.F_PROFIT_SPLIT, T.F_DELIV_PURCHASE, T.F_DELIV_SALES, T.F_PAY_PURCHASE, T.F_PAY_SALES, T.F_OBS, T.FORNECEDOR_COND_VENDA, T.EXP_COND_VENDA, T.IMP_COND_VENDA, T.INSTRUC_INTERNA, T.PRODUTOR, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.PED_T T WHERE T.REF LIKE 'RJP%' OR T.REF LIKE 'SP%';
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PED -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CIA_CONTATO para a localidade
                        log(reglog, 'Transferindo registros da tabela CIA_CONTATO.');
                        begin
                                insert into CXSP.CIA_CONTATO         (CIA_COD, CONTATO_NOME, TELEFONE, FUNÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CIA_COD, T.CONTATO_NOME, T.TELEFONE, T.FUNÇÃO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.CIA_CONTATO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CIA_CONTATO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CARTA para a localidade
                        log(reglog, 'Transferindo registros da tabela CARTA.');
                        begin
                                insert into CXSP.CARTA         (REF, EMPRESA, IDIOMA, DOC_DATA, CIA, CONTATO, CIA_SUB, CONTATO_SUB, ASSUNTO, TEXTO, EMISSÃO_DATA, COM_CÓPIA, USUÁRIO, SUPERVISOR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.REF, T.EMPRESA, T.IDIOMA, T.DOC_DATA, T.CIA, T.CONTATO, T.CIA_SUB, T.CONTATO_SUB, T.ASSUNTO, T.TEXTO, T.EMISSÃO_DATA, T.COM_CÓPIA, T.USUÁRIO, T.SUPERVISOR, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.CARTA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CARTA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela FRETE para a localidade
                        log(reglog, 'Transferindo registros da tabela FRETE.');
                        begin
                                insert into CXSP.FRETE         (CARGA_PORTO, DESCARGA_PORTO, PROPRIETÁRIO, FRETE_DETALHE, FRETE_UNID, FRETE_VALOR_POR_UNID, COMISSÃO_USD, COMISSÃO_PERCENT, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CARGA_PORTO, T.DESCARGA_PORTO, T.PROPRIETÁRIO, T.FRETE_DETALHE, T.FRETE_UNID, T.FRETE_VALOR_POR_UNID, T.COMISSÃO_USD, T.COMISSÃO_PERCENT, T.OBS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.FRETE_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela FRETE -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CIA_RAMO_ATIVIDADE para a localidade
                        log(reglog, 'Transferindo registros da tabela CIA_RAMO_ATIVIDADE.');
                        begin
                                insert into CXSP.CIA_RAMO_ATIVIDADE         (CIA_COD, RAMO_ATIVIDADE, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CIA_COD, T.RAMO_ATIVIDADE, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.CIA_RAMO_ATIVIDADE_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CIA_RAMO_ATIVIDADE -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PED_RESULT para a localidade
                        log(reglog, 'Transferindo registros da tabela PED_RESULT.');
                        begin
                                insert into CXSP.PED_RESULT         (PED_REF, SEQ, LANÇ, VALOR, VALOR_POR_MT, TOTAL_PERCENT, TOTAL_TIPO, COMPETÊNCIA, CALC, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.PED_REF, T.SEQ, T.LANÇ, T.VALOR, T.VALOR_POR_MT, T.TOTAL_PERCENT, T.TOTAL_TIPO, T.COMPETÊNCIA, T.CALC, T.OBS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.PED_RESULT_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PED_RESULT -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CONFIRM_VENDA para a localidade
                        log(reglog, 'Transferindo registros da tabela CONFIRM_VENDA.');
                        begin
                                insert into CXSP.CONFIRM_VENDA         (REF, SEQ, EMISSÃO_DATA, EMISSOR, PED_REF, OUTRA_REF, COMPRADOR, USUÁRIO_FINAL, DESTINATÁRIO, ENTREGA, CARGA_PORTO, IDIOMA, DIMENSÃO, PREÇO_DETALHE, ESPECIFICAÇÃO, EMBALAGEM, SEGURO, PAG, OBS, OBS_TERMOS, PRODUTOR, DESCARGA_PORTO, ASSINATURA, DT_REVISÃO, EMPRESA_REL, MOEDA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.REF, T.SEQ, T.EMISSÃO_DATA, T.EMISSOR, T.PED_REF, T.OUTRA_REF, T.COMPRADOR, T.USUÁRIO_FINAL, T.DESTINATÁRIO, T.ENTREGA, T.CARGA_PORTO, T.IDIOMA, T.DIMENSÃO, T.PREÇO_DETALHE, T.ESPECIFICAÇÃO, T.EMBALAGEM, T.SEGURO, T.PAG, T.OBS, T.OBS_TERMOS, T.PRODUTOR, T.DESCARGA_PORTO, T.ASSINATURA, T.DT_REVISÃO, T.EMPRESA_REL, T.MOEDA, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.CONFIRM_VENDA_T T WHERE T.REF LIKE 'SP%' OR T.REF LIKE 'RJP%';
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CONFIRM_VENDA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela EMB_F para a localidade
                        log(reglog, 'Transferindo registros da tabela EMB_F.');
                        begin
                                insert into CXSP.EMB_F         (PED_REF, SEQ, FATURA, INV_DATA, NAVIO, BL_DATA, COMPETÊNCIA, QUANTIDADE, VALOR, RESULT1, RESULT2, RESULT3, RESULT4, RESULT5, POSIÇÃO, OBSERVAÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.PED_REF, T.SEQ, T.FATURA, T.INV_DATA, T.NAVIO, T.BL_DATA, T.COMPETÊNCIA, T.QUANTIDADE, T.VALOR, T.RESULT1, T.RESULT2, T.RESULT3, T.RESULT4, T.RESULT5, T.POSIÇÃO, T.OBSERVAÇÃO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.EMB_F_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela EMB_F -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PED_CONTATO para a localidade
                        log(reglog, 'Transferindo registros da tabela PED_CONTATO.');
                        begin
                                insert into CXSP.PED_CONTATO         (PED_REF, CIA_COD, CONTATO_NOME, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.PED_REF, T.CIA_COD, T.CONTATO_NOME, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.PED_CONTATO_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PED_CONTATO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela EMB para a localidade
                        log(reglog, 'Transferindo registros da tabela EMB.');
                        begin
                                insert into CXSP.EMB         (CALC_NOMINAL_PED, REF, VIAGEM, FRETE_UNID, FRETE_VALOR, FRETE_POR_MT, FRETE_VALOR_POR_UNID, FRETE_VALOR_TOTAL, FRETE_COND, DATA_EMBARQUE, DATA_EMISSÃO_DOC, CARGA_PORTO, DESCARGA_PORTO, TRANSPORTADOR, MOEDA, IDIOMA, PESO_UNID, PREÇO_UNITÁRIO_UNID, PREÇO_UNID, NEGOCIADOR, EMBARCADOR, EMB_ENDEREÇO, EMB_PAÍS, EMB_COND_VENDA, EMB_COND_PAG, EMB_COMENTÁRIOS, EXP, EXP_ENDEREÇO, EXP_PAÍS, EXP_COND_VENDA, EXP_COND_PAG, EXP_COMENTÁRIOS, EXP_LOGOTIPO, EXP_FAT, IMP, IMP_ENDEREÇO, IMP_PAÍS, IMP_COND_VENDA, IMP_COND_PAG, IMP_COMENTÁRIOS, IMP_LOGOTIPO, IMP_FAT, PAGADOR, PAG_ENDEREÇO, PAG_PAÍS, CONSIGNATÁRIO, CONSIGN_ENDEREÇO, CONSIGN_PAÍS, NOTIFICAR, NOTIFICAR_ENDEREÇO, NOTIFICAR_PAÍS, NUM_BL_DESCR, FAMÍLIA_GENÉRICA, TIPO_DESCR_MERCADORIA, MARCAÇÃO, TOTALIZAÇÃO_EMBALAGEM, CONFIG, EMB_ACORDO, VIA_TRANSPORTE, CARTA_CRED_REF, EMB_DATA, CARTA_CRÉDITO_BANCO_ABRIDOR, CARTA_CRÉDITO_REF, BANCO_AVISADOR, BANCO_CONFIRM, CALC_QTD_PED_UNID, CALC_PESO_LÍQUIDO, CALC_PESO_BRUTO, CALC_QTD_VOL, CALC_EXP_TOT_ITEM, CALC_EXP_TOT_EMB, CALC_EXP_COND_PAG, CALC_EXP_COND_VENDA, CALC_IMP_TOT_ITEM, CALC_IMP_TOT_EMB, CALC_IMP_COND_PAG, CALC_IMP_COND_VENDA, CALC_FRETE_TOTAL, CALC_PEND, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CALC_NOMINAL_PED, T.REF, T.VIAGEM, T.FRETE_UNID, T.FRETE_VALOR, T.FRETE_POR_MT, T.FRETE_VALOR_POR_UNID, T.FRETE_VALOR_TOTAL, T.FRETE_COND, T.DATA_EMBARQUE, T.DATA_EMISSÃO_DOC, T.CARGA_PORTO, T.DESCARGA_PORTO, T.TRANSPORTADOR, T.MOEDA, T.IDIOMA, T.PESO_UNID, T.PREÇO_UNITÁRIO_UNID, T.PREÇO_UNID, T.NEGOCIADOR, T.EMBARCADOR, T.EMB_ENDEREÇO, T.EMB_PAÍS, T.EMB_COND_VENDA, T.EMB_COND_PAG, T.EMB_COMENTÁRIOS, T.EXP, T.EXP_ENDEREÇO, T.EXP_PAÍS, T.EXP_COND_VENDA, T.EXP_COND_PAG, T.EXP_COMENTÁRIOS, T.EXP_LOGOTIPO, T.EXP_FAT, T.IMP, T.IMP_ENDEREÇO, T.IMP_PAÍS, T.IMP_COND_VENDA, T.IMP_COND_PAG, T.IMP_COMENTÁRIOS, T.IMP_LOGOTIPO, T.IMP_FAT, T.PAGADOR, T.PAG_ENDEREÇO, T.PAG_PAÍS, T.CONSIGNATÁRIO, T.CONSIGN_ENDEREÇO, T.CONSIGN_PAÍS, T.NOTIFICAR, T.NOTIFICAR_ENDEREÇO, T.NOTIFICAR_PAÍS, T.NUM_BL_DESCR, T.FAMÍLIA_GENÉRICA, T.TIPO_DESCR_MERCADORIA, T.MARCAÇÃO, T.TOTALIZAÇÃO_EMBALAGEM, T.CONFIG, T.EMB_ACORDO, T.VIA_TRANSPORTE, T.CARTA_CRED_REF, T.EMB_DATA, T.CARTA_CRÉDITO_BANCO_ABRIDOR, T.CARTA_CRÉDITO_REF, T.BANCO_AVISADOR, T.BANCO_CONFIRM, T.CALC_QTD_PED_UNID, T.CALC_PESO_LÍQUIDO, T.CALC_PESO_BRUTO, T.CALC_QTD_VOL, T.CALC_EXP_TOT_ITEM, T.CALC_EXP_TOT_EMB, T.CALC_EXP_COND_PAG, T.CALC_EXP_COND_VENDA, T.CALC_IMP_TOT_ITEM, T.CALC_IMP_TOT_EMB, T.CALC_IMP_COND_PAG, T.CALC_IMP_COND_VENDA, T.CALC_FRETE_TOTAL, T.CALC_PEND, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, 
                                T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.EMB_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela EMB -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PED_ITEM para a localidade
                        log(reglog, 'Transferindo registros da tabela PED_ITEM.');
                        begin
                                insert into CXSP.PED_ITEM         (PED_REF, ITEM, USUÁRIO_FINAL, USUÁRIO_REF, PED_UNID, NOMINAL_PED_UNID, TOTAL_FECH, TOTAL_EMB, TOLERÂNCIA_MIN, TOLERÂNCIA_MAX, PROD, DESCARGA_PORTO, EMBALAGEM, EMBALAGEM_PESO_MIN, EMBALAGEM_PESO_MAX, PREÇO_UNITÁRIO_FORNECEDOR, PREÇO_UNITÁRIO_EXP, PREÇO_UNITÁRIO_IMP, ESPESSURA_TIPO, ESPESSURA_MM, LARGURA_MM, COMPRIMENTO_MM, ESPESSURA_POL, LARGURA_POL, COMPRIMENTO_POL, NCM, NALADI, P, LOTE, OV, NE_ITEM, NE_ENVIO, TBN, FSE, PO, BL_CODE, USO_FINAL, DIÂMETRO_INTERNO, DIÂMETRO_EXTERNO, PESO_POR_FOLHA, AÇO_TIPO, REVESTIMENTO, TÊMPERA, ACABAMENTO, NORMA_TOLERÂNCIA, NORMA_PRODUÇÃO, BORDAS, OLEAMENTO, TRAT_TÉRMICO, TRAT_QUÍMICO, LA, LE, LÍNGUA, PROD_DESCR, COMPOSIÇÃO_QUÍMICA, MARCAÇÃO_PRODUÇÃO, COMENTÁRIO, PED_USINA_DATA, PED_USINA_ID, PED_USINA_CONFIRM, LAYDAY_INÍCIO, LAYDAY_FINAL, QTD_VOL, PESO_LÍQUIDO, PESO_BRUTO, FECH_REQUISITADO, FECH_NOTIFICADO, CANCEL_DATA, CANCEL_MOTIVO, SEGURO_PERCENT, CUR_PERCENT, SUPERFÍCIE, DIAMET_INT_MAX_TOLER, DIAMET_INT_MIM_TOLER, TQ, CERTIF_QUALIDADE, RABO_PEIXE, RABO_PEIXE_MAX, LÍNGUA_MAX, MARCAÇÃO_ESPECIAL_DOC, OBS, MARCAÇÃO, NOMINAL_MT, DIMENSÃO, TOL_CSN, RECOZIDO_CSN, TOL_ESPESSURA_CSN, TOL_LARGURA_CSN, TOL_COMPRIMENTO_CSN, MARCAÇÃO_DIF_CSN, FACE_PESADA_CSN, APLAINAMENTO_CSN, PASSIVAÇÃO_CSN, ACABAMENTO_CSN, FAIXA_PESO_CSN, SOLDAS_CSN, NUM_SOLDAS_CSN, MARCAÇÃO_SOLDA_CSN, VERNIZ_DOURADO_CSN, POSIÇÃO_FOLHA_PALLET_CSN, RUGOSIDADE_CSN, ESQUADRIA_CSN, NUM_CONSULTA_CSN, 
                                TOLERÂNCIA_PADRÃO_CSN, MARCAÇOES_ADICIONAIS_CSN, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.PED_REF, T.ITEM, T.USUÁRIO_FINAL, T.USUÁRIO_REF, T.PED_UNID, T.NOMINAL_PED_UNID, T.TOTAL_FECH, T.TOTAL_EMB, T.TOLERÂNCIA_MIN, T.TOLERÂNCIA_MAX, T.PROD, T.DESCARGA_PORTO, T.EMBALAGEM, T.EMBALAGEM_PESO_MIN, T.EMBALAGEM_PESO_MAX, T.PREÇO_UNITÁRIO_FORNECEDOR, T.PREÇO_UNITÁRIO_EXP, T.PREÇO_UNITÁRIO_IMP, T.ESPESSURA_TIPO, T.ESPESSURA_MM, T.LARGURA_MM, T.COMPRIMENTO_MM, T.ESPESSURA_POL, T.LARGURA_POL, T.COMPRIMENTO_POL, T.NCM, T.NALADI, T.P, T.LOTE, T.OV, T.NE_ITEM, T.NE_ENVIO, T.TBN, T.FSE, T.PO, T.BL_CODE, T.USO_FINAL, T.DIÂMETRO_INTERNO, T.DIÂMETRO_EXTERNO, T.PESO_POR_FOLHA, T.AÇO_TIPO, T.REVESTIMENTO, T.TÊMPERA, T.ACABAMENTO, T.NORMA_TOLERÂNCIA, T.NORMA_PRODUÇÃO, T.BORDAS, T.OLEAMENTO, T.TRAT_TÉRMICO, T.TRAT_QUÍMICO, T.LA, T.LE, T.LÍNGUA, T.PROD_DESCR, T.COMPOSIÇÃO_QUÍMICA, T.MARCAÇÃO_PRODUÇÃO, T.COMENTÁRIO, T.PED_USINA_DATA, T.PED_USINA_ID, T.PED_USINA_CONFIRM, T.LAYDAY_INÍCIO, T.LAYDAY_FINAL, T.QTD_VOL, T.PESO_LÍQUIDO, T.PESO_BRUTO, T.FECH_REQUISITADO, T.FECH_NOTIFICADO, T.CANCEL_DATA, T.CANCEL_MOTIVO, T.SEGURO_PERCENT, T.CUR_PERCENT, T.SUPERFÍCIE, T.DIAMET_INT_MAX_TOLER, T.DIAMET_INT_MIM_TOLER, T.TQ, T.CERTIF_QUALIDADE, T.RABO_PEIXE, T.RABO_PEIXE_MAX, T.LÍNGUA_MAX, T.MARCAÇÃO_ESPECIAL_DOC, T.OBS, T.MARCAÇÃO, T.NOMINAL_MT, T.DIMENSÃO, T.TOL_CSN, T.RECOZIDO_CSN, T.TOL_ESPESSURA_CSN, T.TOL_LARGURA_CSN, T.TOL_COMPRIMENTO_CSN, T.MARCAÇÃO_DIF_CSN, T.FACE_PESADA_CSN, T.APLAINAMENTO_CSN, T.PASSIVAÇÃO_CSN, T.ACABAMENTO_CSN, 
                                T.FAIXA_PESO_CSN, T.SOLDAS_CSN, T.NUM_SOLDAS_CSN, T.MARCAÇÃO_SOLDA_CSN, T.VERNIZ_DOURADO_CSN, T.POSIÇÃO_FOLHA_PALLET_CSN, T.RUGOSIDADE_CSN, T.ESQUADRIA_CSN, T.NUM_CONSULTA_CSN, T.TOLERÂNCIA_PADRÃO_CSN, T.MARCAÇOES_ADICIONAIS_CSN, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.PED_ITEM_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PED_ITEM -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PED_LANÇ para a localidade
                        log(reglog, 'Transferindo registros da tabela PED_LANÇ.');
                        begin
                                insert into CXSP.PED_LANÇ         (PED_REF, SEQ, LANÇ, VALOR, VALOR_POR_MT, TOTAL_PERCENT, TOTAL_TIPO, EXP, IMP, BENEFICIÁRIO, COMISSÃO_MODALIDADE, INSTRUÇÃO_REMESSA, EXP_CALC, IMP_CALC, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.PED_REF, T.SEQ, T.LANÇ, T.VALOR, T.VALOR_POR_MT, T.TOTAL_PERCENT, T.TOTAL_TIPO, T.EXP, T.IMP, T.BENEFICIÁRIO, T.COMISSÃO_MODALIDADE, T.INSTRUÇÃO_REMESSA, T.EXP_CALC, T.IMP_CALC, T.OBS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.PED_LANÇ_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PED_LANÇ -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela VIAGEM_ESCALA para a localidade
                        log(reglog, 'Transferindo registros da tabela VIAGEM_ESCALA.');
                        begin
                                insert into CXSP.VIAGEM_ESCALA         (VIAGEM_REF, ESCALA, PORTO, ETA, ETS, ATA, ATS, LD, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.VIAGEM_REF, T.ESCALA, T.PORTO, T.ETA, T.ETS, T.ATA, T.ATS, T.LD, T.OBS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.VIAGEM_ESCALA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela VIAGEM_ESCALA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela BL para a localidade
                        log(reglog, 'Transferindo registros da tabela BL.');
                        begin
                                insert into CXSP.BL         (VIAGEM_REF, SEQ, BL_NUM, BL_DATA, EMB_REF, MSG, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.VIAGEM_REF, T.SEQ, T.BL_NUM, T.BL_DATA, T.EMB_REF, T.MSG, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.BL_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela BL -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CONFIRM_VENDA_ITEM para a localidade
                        log(reglog, 'Transferindo registros da tabela CONFIRM_VENDA_ITEM.');
                        begin
                                insert into CXSP.CONFIRM_VENDA_ITEM         (CONFIRM_VENDA_REF, SEQ, ITEM, DESCR, DIMENSÃO, QTD, UNID, PREÇO, MOEDA, QUALIDADE, PREÇO_C, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CONFIRM_VENDA_REF, T.SEQ, T.ITEM, T.DESCR, T.DIMENSÃO, T.QTD, T.UNID, T.PREÇO, T.MOEDA, T.QUALIDADE, T.PREÇO_C, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.CONFIRM_VENDA_ITEM_T T WHERE T.CONFIRM_VENDA_REF LIKE 'RJP%' OR T.CONFIRM_VENDA_REF LIKE 'SP%';
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CONFIRM_VENDA_ITEM -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela EMB_DOC_REL para a localidade
                        log(reglog, 'Transferindo registros da tabela EMB_DOC_REL.');
                        begin
                                insert into CXSP.EMB_DOC_REL         (EMB_REF, DOC, EMB_REL, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.EMB_REF, T.DOC, T.EMB_REL, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.EMB_DOC_REL_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela EMB_DOC_REL -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela EMB_FAMÍLIA para a localidade
                        log(reglog, 'Transferindo registros da tabela EMB_FAMÍLIA.');
                        begin
                                insert into CXSP.EMB_FAMÍLIA         (EMB_REF, SEQ, FAMÍLIA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.EMB_REF, T.SEQ, T.FAMÍLIA, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.EMB_FAMÍLIA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela EMB_FAMÍLIA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela EMB_FAMÍLIA_GENÉRICA para a localidade
                        log(reglog, 'Transferindo registros da tabela EMB_FAMÍLIA_GENÉRICA.');
                        begin
                                insert into CXSP.EMB_FAMÍLIA_GENÉRICA         (EMB_REF, SEQ, FAMÍLIA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.EMB_REF, T.SEQ, T.FAMÍLIA, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.EMB_FAMÍLIA_GENÉRICA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela EMB_FAMÍLIA_GENÉRICA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela EMB_LANÇ para a localidade
                        log(reglog, 'Transferindo registros da tabela EMB_LANÇ.');
                        begin
                                insert into CXSP.EMB_LANÇ         (EMB_REF, SEQ, LANÇ, VALOR, VALOR_POR_MT, TOTAL_PERCENT, TOTAL_TIPO, EXP, IMP, UNID, NA_FATURA, BENEFICIÁRIO, COMISSÃO_MODALIDADE, INSTRUÇÃO_REMESSA, EXP_CALC, IMP_CALC, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.EMB_REF, T.SEQ, T.LANÇ, T.VALOR, T.VALOR_POR_MT, T.TOTAL_PERCENT, T.TOTAL_TIPO, T.EXP, T.IMP, T.UNID, T.NA_FATURA, T.BENEFICIÁRIO, T.COMISSÃO_MODALIDADE, T.INSTRUÇÃO_REMESSA, T.EXP_CALC, T.IMP_CALC, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.EMB_LANÇ_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela EMB_LANÇ -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela EMB_MENSAGEM para a localidade
                        log(reglog, 'Transferindo registros da tabela EMB_MENSAGEM.');
                        begin
                                insert into CXSP.EMB_MENSAGEM         (EMB_REF, SEQ, MSG, EXP, IMP, DOC_ALADI, DOC_BORDERÔ_I, DOC_BORDERÔ_P, DOC_CÂMARA_COMÉRCIO, DOC_CARTA_I, DOC_CARTA_P, DOC_CONHECIM_ROD, DOC_FATURA, DOC_FATURA_JUROS, DOC_FECH_CAMBIO, DOC_FIRJAN, DOC_MERCOSUL, DOC_MERCOSUL_BOLIVIA, DOC_MERCOSUL_CHILE, DOC_PLIST_WEIG_CERT, DOC_SAQUE_JUR_2_VIAS, DOC_SAQUE_JUR_3_VIAS, DOC_SAQUE_2_VIAS, DOC_SAQUE_3_VIAS, DOC_ALADI_CERTIF_ORIGEM, DOC_BL, DOC_CÂM_COM_CERTIF_O, DOC_CAPA, DOC_CONHECIM_RODOVIÁRIO, DOC_CHECK_LIST, DOC_CARTA_DEOP_INGLÊS, DOC_CARTA_DEOP_PORTUG, DOC_FECHAM_CÂMBIO, DOC_FIRJAN_CERTIF_ORIGEM, DOC_FORM_A, DOC_INSTR_PAG, DOC_MERCOSUL_CERTIF_ORIGEM, DOC_PACKING_LIST, DOC_SAQUE, DOC_WEIGHT_CERTIFICATE, DOC_SAQUE_JUROS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.EMB_REF, T.SEQ, T.MSG, T.EXP, T.IMP, T.DOC_ALADI, T.DOC_BORDERÔ_I, T.DOC_BORDERÔ_P, T.DOC_CÂMARA_COMÉRCIO, T.DOC_CARTA_I, T.DOC_CARTA_P, T.DOC_CONHECIM_ROD, T.DOC_FATURA, T.DOC_FATURA_JUROS, T.DOC_FECH_CAMBIO, T.DOC_FIRJAN, T.DOC_MERCOSUL, T.DOC_MERCOSUL_BOLIVIA, T.DOC_MERCOSUL_CHILE, T.DOC_PLIST_WEIG_CERT, T.DOC_SAQUE_JUR_2_VIAS, T.DOC_SAQUE_JUR_3_VIAS, T.DOC_SAQUE_2_VIAS, T.DOC_SAQUE_3_VIAS, T.DOC_ALADI_CERTIF_ORIGEM, T.DOC_BL, T.DOC_CÂM_COM_CERTIF_O, T.DOC_CAPA, T.DOC_CONHECIM_RODOVIÁRIO, T.DOC_CHECK_LIST, T.DOC_CARTA_DEOP_INGLÊS, T.DOC_CARTA_DEOP_PORTUG, T.DOC_FECHAM_CÂMBIO, T.DOC_FIRJAN_CERTIF_ORIGEM, T.DOC_FORM_A, T.DOC_INSTR_PAG, T.DOC_MERCOSUL_CERTIF_ORIGEM, T.DOC_PACKING_LIST, T.DOC_SAQUE, T.DOC_WEIGHT_CERTIFICATE, T.DOC_SAQUE_JUROS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.EMB_MENSAGEM_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela EMB_MENSAGEM -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela EMB_RE para a localidade
                        log(reglog, 'Transferindo registros da tabela EMB_RE.');
                        begin
                                insert into CXSP.EMB_RE         (EMB_REF, RE, EMISSÃO_DATA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.EMB_REF, T.RE, T.EMISSÃO_DATA, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.EMB_RE_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela EMB_RE -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela EMB_SD para a localidade
                        log(reglog, 'Transferindo registros da tabela EMB_SD.');
                        begin
                                insert into CXSP.EMB_SD         (EMB_REF, SD, AVERBAÇÃO_DATA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.EMB_REF, T.SD, T.AVERBAÇÃO_DATA, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.EMB_SD_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela EMB_SD -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela EMB_TOTALIZA para a localidade
                        log(reglog, 'Transferindo registros da tabela EMB_TOTALIZA.');
                        begin
                                insert into CXSP.EMB_TOTALIZA         (EMB_REF, SEQ, LANÇ, EXP, IMP, EXP_DESCR, IMP_DESCR, EXP_CALC, IMP_CALC, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.EMB_REF, T.SEQ, T.LANÇ, T.EXP, T.IMP, T.EXP_DESCR, T.IMP_DESCR, T.EXP_CALC, T.IMP_CALC, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.EMB_TOTALIZA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela EMB_TOTALIZA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela FECH para a localidade
                        log(reglog, 'Transferindo registros da tabela FECH.');
                        begin
                                insert into CXSP.FECH         (REF, FECH_DATA, MOEDA, VIAGEM_REF, CARGA_PORTO_ESCALA, DESCARGA_PORTO_ESCALA, CONTRATANTE, CORRETOR, PROPRIETÁRIO, NEGOCIANTE, FRETE_DETALHE, FRETE_UNID, FRETE_VALOR, FRETE_VALOR_POR_UNID, FRETE_PAG_DETALHE, COMISSÃO_FRETE, COMISSÃO_BASE, COMISSÃO_PERCENT, CIA_PAGADORA, CARGA_AGENTE, CARGA_ESTIVA, CARGA_ESTIVA_CUSTO, CARGA_DETALHE, CARGA_OBS, DESCARGA_AGENTE, DESCARGA_ESTIVA, DESCARGA_ESTIVA_CUSTO, DESCARGA_DETALHE, DESCARGA_OBS, DETENÇÃO, DEMORA, OBS, DESPACHANTE, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.REF, T.FECH_DATA, T.MOEDA, T.VIAGEM_REF, T.CARGA_PORTO_ESCALA, T.DESCARGA_PORTO_ESCALA, T.CONTRATANTE, T.CORRETOR, T.PROPRIETÁRIO, T.NEGOCIANTE, T.FRETE_DETALHE, T.FRETE_UNID, T.FRETE_VALOR, T.FRETE_VALOR_POR_UNID, T.FRETE_PAG_DETALHE, T.COMISSÃO_FRETE, T.COMISSÃO_BASE, T.COMISSÃO_PERCENT, T.CIA_PAGADORA, T.CARGA_AGENTE, T.CARGA_ESTIVA, T.CARGA_ESTIVA_CUSTO, T.CARGA_DETALHE, T.CARGA_OBS, T.DESCARGA_AGENTE, T.DESCARGA_ESTIVA, T.DESCARGA_ESTIVA_CUSTO, T.DESCARGA_DETALHE, T.DESCARGA_OBS, T.DETENÇÃO, T.DEMORA, T.OBS, T.DESPACHANTE, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.FECH_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela FECH -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela RESULT para a localidade
                        log(reglog, 'Transferindo registros da tabela RESULT.');
                        begin
                                insert into CXSP.RESULT         (PED_REF, EMB_SEQ, SEQ, INV_DATA, RESULT1, RESULT2, RESULT3, RESULT4, RESULT5, DATA1, DATA2, DATA3, DATA4, DATA5, POSIÇÃO, OBSERVAÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.PED_REF, T.EMB_SEQ, T.SEQ, T.INV_DATA, T.RESULT1, T.RESULT2, T.RESULT3, T.RESULT4, T.RESULT5, T.DATA1, T.DATA2, T.DATA3, T.DATA4, T.DATA5, T.POSIÇÃO, T.OBSERVAÇÃO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.RESULT_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela RESULT -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CARTA_FECH para a localidade
                        log(reglog, 'Transferindo registros da tabela CARTA_FECH.');
                        begin
                                insert into CXSP.CARTA_FECH         (CARTA_REF, FECH_REF, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CARTA_REF, T.FECH_REF, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.CARTA_FECH_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CARTA_FECH -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela BL_CARGA para a localidade
                        log(reglog, 'Transferindo registros da tabela BL_CARGA.');
                        begin
                                insert into CXSP.BL_CARGA         (PED_REF, PED_ITEM, VIAGEM_REF, BL_SEQ, FECH_REF, QTD_PED_UNID, QTD_VOL, PESO_LÍQUIDO, PESO_BRUTO, EMB_DATA, EMB_REF, EMB_SEQ, FAMÍLIA_GENÉRICA, FAMÍLIA, DESCR         , EMBALAGEM, NCM, NALADI, EXP_PREÇO_UNIT, IMP_PREÇO_UNIT, CALC_EXP_EMB, CALC_EXP_FOB, CALC_IMP_EMB, CALC_IMP_FOB, NOMINAL_PED_UNID, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.PED_REF, T.PED_ITEM, T.VIAGEM_REF, T.BL_SEQ, T.FECH_REF, T.QTD_PED_UNID, T.QTD_VOL, T.PESO_LÍQUIDO, T.PESO_BRUTO, T.EMB_DATA, T.EMB_REF, T.EMB_SEQ, T.FAMÍLIA_GENÉRICA, T.FAMÍLIA, T.DESCR         , T.EMBALAGEM, T.NCM, T.NALADI, T.EXP_PREÇO_UNIT, T.IMP_PREÇO_UNIT, T.CALC_EXP_EMB, T.CALC_EXP_FOB, T.CALC_IMP_EMB, T.CALC_IMP_FOB, T.NOMINAL_PED_UNID, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.BL_CARGA_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela BL_CARGA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela FECH_CARGA para a localidade
                        log(reglog, 'Transferindo registros da tabela FECH_CARGA.');
                        begin
                                insert into CXSP.FECH_CARGA         (FECH_REF, PED_REF, PED_ITEM, QTD_PED_UNID, QTD_FRETE_UNID, QTD_TOTAL, NOMEAÇÃO_DATA, ACEITAÇÃO_FORNECEDOR_DATA, CANCEL_DATA, CANCEL_MOTIVO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.FECH_REF, T.PED_REF, T.PED_ITEM, T.QTD_PED_UNID, T.QTD_FRETE_UNID, T.QTD_TOTAL, T.NOMEAÇÃO_DATA, T.ACEITAÇÃO_FORNECEDOR_DATA, T.CANCEL_DATA, T.CANCEL_MOTIVO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXSP.FECH_CARGA_T T WHERE T.PED_REF LIKE 'SP%' OR T.PED_REF LIKE 'RJP%';
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela FECH_CARGA -> ' || SQLERRM);
                        end;


                        COMMIT;
                        log(reglog, 'Excluindo arquivos temporários.');
                        err := DBMS_CX.DOSSHELL('DEL ' || diretorio || '\' || arquivo || '.PAC>' || diretorio || '\RECEB.TMP');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando DEL');
                        end if;
                        loga(reglog, diretorio, 'RECEB.TMP');

                        err := DBMS_CX.DOSSHELL('DEL ' || diretorio || '\RECEB.TMP');

                        log(reglog, 'Término de inicialização da localidade com o arquivo ' || diretorio || '\' || arquivo || '.ARJ');
                        utl_file.fclose(reglog);
                end;

        exception
                when others then
                        ROLLBACK;
                        log(reglog, 'Erro durante a inicialização da localidade. Base de dados resultante pode ter se tornado inconsistente.');
                        log(reglog, SQLERRM);
                        if utl_file.is_open(reglog) then
                                utl_file.fclose(reglog);
                        end if;

                        raise_application_error ( -20000, 'erro na função de inicialização de localidade -> ' || SQLERRM );
        end;




        procedure ver_pacote(arqpac_remoto in varchar2, diretorio in varchar2, senhalocal in varchar2, servicolocal in varchar2) is
        sqlcursor integer;
        err integer;
        modelopac SYS_LOCALID.MODELO%type;

        numpac integer;
        arqpac varchar2(100);
        localpac varchar2(100);
        numpac_remoto integer;
        reglog utl_file.file_type;

        begin
                begin
                        reglog := utl_file.fopen(diretorio, 'RECEB.LOG', 'a');

                        log(reglog, '');
                        log(reglog, '----------------------------------------------------------------------');
                        log(reglog, 'Verificação - Tentativa de descompactação do pacote ' || diretorio || '\' || arqpac_remoto || '.ARJ');

                        select NOME, MODELO into localpac, modelopac from SYS_LOCALID where CORRENTE = -1;

                        if modelopac <> 0 then
                                raise_application_error(-20000, 'identificada criação de pacote não finalizada corretamente no modelo da localidade ' || localpac || ' (' || to_char(modelopac) || ')');
                        end if;

                  err := DBMS_CX.DOSSHELL('arj32.exe e -y -ht' || diretorio || '\ ' || diretorio || '\' || arqpac_remoto || '.ARJ ' || arqpac_remoto || '.PAC ' || '>' || diretorio || '\RECEB.TMP');

                        if err = 6 then
                                log(reglog, 'Pacote não encontrado.');
                                err := DBMS_CX.DOSSHELL('DEL ' || diretorio || '\RECEB.TMP');
                                utl_file.fclose(reglog);
                                return;
                        elsif err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando arj32.exe');
                        end if;
                        loga(reglog, diretorio, 'RECEB.TMP');

                        log(reglog, 'Apagando registros de estrutura de transferência.');
                        delete from EMB_FAMÍLIA_GENÉRICA_T;
                        delete from DOC_T;
                        delete from EMB_FAMÍLIA_T;
                        delete from EMB_RE_T;
                        delete from BL_T;
                        delete from BL_CARGA_T;
                        delete from DIVISÃO_PRODUTO_T;
                        delete from EMB_TOTALIZA_T;
                        delete from DIVISÃO_TIPO_REF_T;
                        delete from EMB_DOC_REL_T;
                        delete from MAPA_T;
                        delete from INCOTERM_LANÇ_T;
                        delete from LOCAL_RESULT_T;
                        delete from EMB_SD_T;
                        delete from PARAM_CSN_T;
                        delete from EMB_LANÇ_T;
                        delete from EMB_MENSAGEM_T;
                        delete from ANEXO_T;
                        delete from EMPRESA_APUR_T;
                        delete from LOG_IMPORT_T;
                        delete from CIA_RAMO_ATIVIDADE_T;
                        delete from CARTA_FECH_T;
                        delete from SYS_DELETE_T;
                        delete from SUB_CONTA_T;
                        delete from RESULT_T;
                        delete from RELACIONADA_T;
                        delete from CIA_CONTATO_T;
                        delete from PRODUTO_ESPECIF_T;
                        delete from FRETE_T;
                        delete from CONFIRM_VENDA_ITEM_T;
                        delete from PLANILHA_STC_T;
                        delete from PLANILHA_DEF_T;
                        delete from PED_RESULT_T;
                        delete from PED_LANÇ_T;
                        delete from CONTA_T;
                        delete from PED_CONTATO_T;
                        delete from DIVISÃO_T;
                        delete from EMB_T;
                        delete from CARTA_T;
                        delete from EMB_F_T;
                        delete from TIPO_REF_T;
                        delete from FECH_CARGA_T;
                        delete from RAMO_ATIVIDADE_T;
                        delete from LANÇ_T;
                        delete from DEPTO_T;
                        delete from CARTA_CRÉDITO_T;
                        delete from CONFIRM_VENDA_T;
                        delete from PED_ITEM_T;
                        delete from COSIPA_NEGOCIAÇÃO_T;
                        delete from ESCRITÓRIO_T;
                        delete from FECH_T;
                        delete from PRODUTO_T;
                        delete from PARAM_T;
                        delete from EMBALAGEM_T;
                        delete from UNID_QUANTID_T;
                        delete from VIAGEM_ESCALA_T;
                        delete from PED_T;
                        delete from VIAGEM_T;
                        delete from VIA_TRANSPORTE_T;
                        delete from CIA_T;
                        delete from COND_PAG_T;
                        delete from MOEDA_T;
                        delete from PORTO_T;
                        delete from INCOTERM_T;
                        delete from GRUPO_PRODUTO_T;
                        delete from MODALIDADE_FRETE_T;
                        delete from NAVIO_T;
                        delete from PAÍS_T;
                        delete from IDIOMA_T;
                        COMMIT;

                        log(reglog, 'Importando informações do pacote.');
                        err := DBMS_CX.DOSSHELL('imp.exe ' || localpac || '/' || senhalocal || '@' || servicolocal || ' FILE=' || diretorio || '\' || arqpac_remoto || '.PAC' || ' LOG=' || diretorio || '\RECEB.TMP PARFILE=' || diretorio || '\' || 'RECEB.PAR TOUSER=CXSP');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando imp.exe');
                        end if;
                        loga(reglog, diretorio, 'RECEB.TMP');

                        log(reglog, 'Excluindo arquivos temporários.');
                        err := DBMS_CX.DOSSHELL('DEL ' || diretorio || '\' || arqpac_remoto || '.PAC>' || diretorio || '\RECEB.TMP');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando DEL');
                        end if;
                        loga(reglog, diretorio, 'RECEB.TMP');
                        err := DBMS_CX.DOSSHELL('DEL ' || diretorio || '\RECEB.TMP');

                        log(reglog, 'Pacote ' || diretorio || '\' || arqpac_remoto || '.ARJ disponível para verificação.');
                        utl_file.fclose(reglog);
                end;
        exception
                when others then
                        ROLLBACK;
                        log(reglog, 'Erro no recebimento do pacote para verificação.');
                        log(reglog, SQLERRM);
                        if utl_file.is_open(reglog) then
                                utl_file.fclose(reglog);
                        end if;
                        raise_application_error ( -20000, 'erro na função de verificação de pacotes -> ' || SQLERRM );
        end;





        procedure prog_gera_pacotes(nome_prog in varchar2, hora_exec in varchar2, diretorio in varchar2, senhalocal in varchar2, servicolocal in varchar2, email in varchar2 default '', servsmtp in varchar2 default '', intervalo_horas in varchar2 default '24') as
        job binary_integer;
        begin
                begin
                        for cur in (select job from user_jobs where what like '% ' || nome_prog || ' %') loop
                                dbms_job.remove(cur.job);
                                end loop;
                exception
                        when others then
                                null;
                end;
                dbms_job.submit(job, '/* ' || nome_prog || ' */begin DBMS_CX.CRIA_PACOTE(''' || diretorio || ''', ''' || senhalocal || ''', ''' || servicolocal || ''', ''' || email || ''', ''' || servsmtp || ''');end;',
                to_date('' || to_char(sysdate,'DD-MM-YYYY') || ' ' || hora_exec ||'','DD-MM-YYYY HH24:MI:SS'), 'SYSDATE+(' || intervalo_horas || '/24)');
        end;





        procedure prog_recebe_pacotes(nome_prog in char, intervalo_horas in varchar2, localpac_remoto in varchar2, diretorio in varchar2, senhalocal in varchar2, servicolocal in varchar2, email in varchar2 default '', servsmtp in varchar2 default '', usuariopop3 in varchar2 default '', senhapop3 in varchar2 default '', servpop3 in varchar2 default '') as
        job binary_integer;
        begin
                begin
                        for cur in (select job from user_jobs where what like '% ' || nome_prog || ' %') loop
                                dbms_job.remove(cur.job);
                        end loop;
                exception
                        when others then
                                null;
                end;
                begin
                        dbms_job.submit(job, '/* ' || nome_prog || ' */begin DBMS_CX.TRATA_PACOTE(''' || localpac_remoto || ''', ''' || diretorio || ''', ''' || senhalocal || ''', ''' || servicolocal || ''',''' || email || ''', ''' || servsmtp || ''', ''' || usuariopop3 || ''', ''' || senhapop3 || ''', ''' || servpop3 || ''');end;',
                        sysdate, 'SYSDATE+('|| intervalo_horas ||'/24)');
                exception
                        when others then
                                null;
                end;
        end;




        procedure prog_apaga(nome_prog in varchar2) as
        job binary_integer;
        begin
                begin
                        for cur in (select job from user_jobs where what like '% ' || nome_prog || ' %') loop
                                dbms_job.remove(cur.job);
                        end loop;
                end;
        end;






         procedure grava_log(texto in varchar2, nome_arq in varchar2) as
                        reglog utl_file.file_type;
        begin
                reglog := utl_file.fopen( public_dir() , nome_arq, 'a');
                if utl_file.is_open(reglog) then
                              if length(texto) <> 0 then
                                      utl_file.put_line(reglog, texto);
                              else
                                      utl_file.new_line(reglog);
                              end if;
                      utl_file.fflush(reglog);
                      end if;
        utl_file.fclose(reglog);
        exception
            when others then
                raise_application_error ( -20000, 'Erro na Grava LOG -> ');
        end;


procedure atualiza_cia(nome_antigo in varchar2, nome_novo in varchar2)  as
begin

        insert into CIA_CONTATO(cia_cod, contato_nome, telefone, função)
        select nome_novo, contato_nome, telefone, função from
        CIA_CONTATO where cia_cod = nome_antigo and  contato_nome
        not in (select contato_nome from CIA_CONTATO where cia_cod = nome_novo) ;

        insert into CIA_RAMO_ATIVIDADE(cia_cod, ramo_atividade)
        select nome_novo, ramo_atividade from CIA_RAMO_ATIVIDADE
        where  cia_cod = nome_antigo  and  ramo_atividade
        not in  (select ramo_atividade from CIA_RAMO_ATIVIDADE where cia_cod = nome_novo);
        --
        --Carta de Crédito

        --insert into CARTA_CRÉDITO(banco, ref, emb_validade, negociação_validade, tolerância_qtd, valor_tolerância, emb_parcial_permitido, transbordo_permitido, moeda, valor)
        --Select nome_novo,ref, emb_validade, negociação_validade, tolerância_qtd, valor_tolerância, emb_parcial_permitido, transbordo_permitido, moeda, valor
        --from CARTA_CRÉDITO where banco = nome_antigo;

        update EMB_DOC_DESTINO set cia = nome_novo where cia = nome_antigo;
        update FATURA set cia = nome_novo where cia = nome_antigo;
        update FATURA set cia_sub = nome_novo where cia_sub = nome_antigo;
        update FATURA set empresa = nome_novo where empresa = nome_antigo;
        update FECH set cia_pagadora = nome_novo where cia_pagadora = nome_antigo;
        update FECH set descarga_agente = nome_novo where descarga_agente = nome_antigo;
        update FECH set corretor = nome_novo where corretor = nome_antigo;
        update FECH set proprietário = nome_novo where proprietário = nome_antigo;
        update FECH set negociante = nome_novo where negociante = nome_antigo;
        update FECH set carga_agente = nome_novo where carga_agente = nome_antigo;
        update FECH set contratante = nome_novo where contratante = nome_antigo;
        update FECH set carga_estiva = nome_novo where carga_estiva = nome_antigo;
        update FECH set descarga_estiva = nome_novo where descarga_estiva = nome_antigo;
        update EMB_LANÇ set beneficiário = nome_novo where beneficiário = nome_antigo;
        update CARTA set cia = nome_novo where cia = nome_antigo;
        update CARTA set cia_sub = nome_novo where cia_sub = nome_antigo;
        update CARTA set empresa = nome_novo where empresa = nome_antigo;
        update CONFIRM_VENDA set comprador = nome_novo where comprador = nome_antigo;
        update CONFIRM_VENDA set usuário_final = nome_novo where usuário_final = nome_antigo;
        update CONFIRM_VENDA set produtor = nome_novo where produtor = nome_antigo;
        update EMB set exp_logotipo = nome_novo where exp_logotipo = nome_antigo;
        --update EMB set banco_avisador = nome_novo where banco_avisador = nome_antigo;
        --update EMB set banco_confirm = nome_novo where banco_confirm = nome_antigo;
        update EMB set negociador = nome_novo where negociador = nome_antigo;
        --update EMB set carta_crédito_banco_abridor = nome_novo where carta_crédito_banco_abridor = nome_antigo;
        update EMB set imp_logotipo = nome_novo where imp_logotipo = nome_antigo;
        update FAX_DESTINO set cia = nome_novo where cia = nome_antigo;
        update PED_ITEM set usuário_final = nome_novo where usuário_final = nome_antigo;
        update PED_LANÇ set beneficiário = nome_novo where beneficiário = nome_antigo;
        update PED_RESULT set competência = nome_novo where competência = nome_antigo;
        update FRETE set proprietário = nome_novo where proprietário = nome_antigo;
        update INSTRUÇÃO_PAG set pagador = nome_novo where pagador = nome_antigo;
        update INSTRUÇÃO_PAG set recebedor = nome_novo where recebedor = nome_antigo;
        --update MERCADO set contratante = nome_novo where contratante = nome_antigo;
        --update MERCADO set fornecedor = nome_novo where fornecedor = nome_antigo;
        --update MERCADO set transportador = nome_novo where transportador = nome_antigo;
        update NOTA_CRÉDITO set cia = nome_novo where cia = nome_antigo;
        update NOTA_CRÉDITO set cia_sub = nome_novo where cia_sub = nome_antigo;
        update NOTA_DÉBITO set cia = nome_novo where cia = nome_antigo;
        update NOTA_DÉBITO set cia_sub = nome_novo where cia_sub = nome_antigo;
        update PED set fornecedor = nome_novo where fornecedor = nome_antigo;
        update PED set exp = nome_novo where exp = nome_antigo;
        update PED set imp = nome_novo where imp = nome_antigo;
        update PED set distribuidor = nome_novo where distribuidor = nome_antigo;
        update PED set pagador = nome_novo where pagador = nome_antigo;

        --Carta de Crédito
        --Delete from CARTA_CRÉDITO where banco = nome_antigo;
        --

        Delete from CIA_RAMO_ATIVIDADE where cia_cod = nome_antigo;
        Delete from CIA_CONTATO where cia_cod = nome_antigo;
        Delete from CIA where cod = nome_antigo;
        COMMIT;


exception
        when others then
                ROLLBACK;
                RAISE_APPLICATION_ERROR(-20000, 'ERRO EM ATUALIZA_CIA: ' || SQLERRM);
end atualiza_cia;



procedure cria_cia(nome_antigo in varchar2, nome_novo in varchar2, excluir in INTEGER)  as

begin

        insert into CIA(logotipo, cod, cgc, nome, endereço, bairro, cidade, estado, país, cep, caixa_postal, telefone, fax, telex, e_mail, f_cod, marcação, obs, local_result, logo)
        select logotipo, nome_novo, cgc, nome, endereço, bairro, cidade, estado, país, cep, caixa_postal, telefone, fax, telex, e_mail, f_cod, marcação, obs, local_result, logo
        from CIA where cod = nome_antigo;
        insert into CIA_CONTATO(cia_cod, contato_nome, telefone, função)
        select nome_novo, contato_nome, telefone, função
        from CIA_CONTATO where cia_cod = nome_antigo;
        insert into CIA_RAMO_ATIVIDADE(cia_cod, ramo_atividade)
        select nome_novo, ramo_atividade
        from CIA_RAMO_ATIVIDADE where cia_cod = nome_antigo;
        --Carta de Crédito
        --insert into CARTA_CRÉDITO(banco, ref, emb_validade, negociação_validade, tolerância_qtd, valor_tolerância, emb_parcial_permitido, transbordo_permitido, moeda, valor)
        --Select nome_novo,ref, emb_validade, negociação_validade, tolerância_qtd, valor_tolerância, emb_parcial_permitido, transbordo_permitido, moeda, valor
        --from CARTA_CRÉDITO where banco = nome_antigo;

        update EMB_DOC_DESTINO set cia = nome_novo where cia = nome_antigo;
        update FATURA set cia = nome_novo where cia = nome_antigo;
        update FATURA set cia_sub = nome_novo where cia_sub = nome_antigo;
        update FATURA set empresa = nome_novo where empresa = nome_antigo;
        update FECH set cia_pagadora = nome_novo where cia_pagadora = nome_antigo;
        update FECH set descarga_agente = nome_novo where descarga_agente = nome_antigo;
        update FECH set corretor = nome_novo where corretor = nome_antigo;
        update FECH set proprietário = nome_novo where proprietário = nome_antigo;
        update FECH set negociante = nome_novo where negociante = nome_antigo;
        update FECH set carga_agente = nome_novo where carga_agente = nome_antigo;
        update FECH set contratante = nome_novo where contratante = nome_antigo;
        update FECH set carga_estiva = nome_novo where carga_estiva = nome_antigo;
        update FECH set descarga_estiva = nome_novo where descarga_estiva = nome_antigo;
        update EMB_LANÇ set beneficiário = nome_novo where beneficiário = nome_antigo;
        update CARTA set cia = nome_novo where cia = nome_antigo;
        update CARTA set cia_sub = nome_novo where cia_sub = nome_antigo;
        update CARTA set empresa = nome_novo where empresa = nome_antigo;
        update CONFIRM_VENDA set comprador = nome_novo where comprador = nome_antigo;
        update CONFIRM_VENDA set usuário_final = nome_novo where usuário_final = nome_antigo;
        update CONFIRM_VENDA set produtor = nome_novo where produtor = nome_antigo;
        update EMB set exp_logotipo = nome_novo where exp_logotipo = nome_antigo;
        --update EMB set banco_avisador = nome_novo where banco_avisador = nome_antigo;
        --update EMB set banco_confirm = nome_novo where banco_confirm = nome_antigo;
        update EMB set negociador = nome_novo where negociador = nome_antigo;
        --update EMB set carta_crédito_banco_abridor = nome_novo where carta_crédito_banco_abridor = nome_antigo;
        update EMB set imp_logotipo = nome_novo where imp_logotipo = nome_antigo;
        update FAX_DESTINO set cia = nome_novo where cia = nome_antigo;
        update PED_ITEM set usuário_final = nome_novo where usuário_final = nome_antigo;
        update PED_LANÇ set beneficiário = nome_novo where beneficiário = nome_antigo;
        update PED_RESULT set competência = nome_novo where competência = nome_antigo;
        update FRETE set proprietário = nome_novo where proprietário = nome_antigo;
        update INSTRUÇÃO_PAG set pagador = nome_novo where pagador = nome_antigo;
        update INSTRUÇÃO_PAG set recebedor = nome_novo where recebedor = nome_antigo;
        -- update MERCADO set contratante = nome_novo where contratante = nome_antigo;
        -- update MERCADO set fornecedor = nome_novo where fornecedor = nome_antigo;
        -- update MERCADO set transportador = nome_novo where transportador = nome_antigo;
        update NOTA_CRÉDITO set cia = nome_novo where cia = nome_antigo;
        update NOTA_CRÉDITO set cia_sub = nome_novo where cia_sub = nome_antigo;
        update NOTA_DÉBITO set cia = nome_novo where cia = nome_antigo;
        update NOTA_DÉBITO set cia_sub = nome_novo where cia_sub = nome_antigo;
        update PED set fornecedor = nome_novo where fornecedor = nome_antigo;
        update PED set exp = nome_novo where exp = nome_antigo;
        update PED set imp = nome_novo where imp = nome_antigo;
        update PED set distribuidor = nome_novo where distribuidor = nome_antigo;
        update PED set pagador = nome_novo where pagador = nome_antigo;

        --Carta de Crédito
        --Delete from CARTA_CRÉDITO where banco = nome_antigo;

        if excluir = -1 then
          Delete from CIA_RAMO_ATIVIDADE where cia_cod = nome_antigo;
          Delete from CIA_CONTATO where cia_cod = nome_antigo;
          Delete from CIA where cod = nome_antigo;
        end if;
        COMMIT;

exception
        when others then
                ROLLBACK;
                RAISE_APPLICATION_ERROR(-20000, 'ERRO EM ALTERA_CIA: ' || SQLERRM);
end cria_cia;

procedure cad_log(de in varchar, para in varchar, servidor_msg in varchar) as
Begin
Declare
tot_reg integer;
ret integer;
aux integer;
chav clob;
buf VARCHAR2(32000);
n_loop integer;
tam_str integer;
cursor c_cad_log is select  *  from sys_cad_log order by seq;
        begin
        select count(*) into tot_reg from sys_cad_log;
        if tot_reg <> 0 then -- header do HTML e a primeira linha da tabela
                dbms_cx.grava_log('<html><head><title>Ciex - Notificação de Cadastro</title></head><body bgcolor= #C0C0C0  text= #0000FF >','Cadastro.htm');
                dbms_cx.grava_log('<p align= center ><font face= Arial  size= 3 ><b>Ciex - Notificação de Alteração de Cadastro</b></font></p><table border= 1  width= 100% >','Cadastro.htm');
                dbms_cx.grava_log('<tr><td width= 19%  align= center ><p align= center ><b><font face= Arial >Horário</font></b></td><td width= 14%  align= center ><b><font face= Arial >Tabela</font></b></td> ','Cadastro.htm');
                dbms_cx.grava_log('<td width= 35%  align= center ><b><font face= Arial >Registro</font></b></td><td width= 13%  align= center ><b><font face= Arial >Ação</font></b></td>','Cadastro.htm');
                dbms_cx.grava_log('<td width= 29%  align= center ><b><font face= Arial >Usuário / Local</font></b></td></tr>','Cadastro.htm');
                for  CAMPO in  C_CAD_LOG loop -- células da tabela
                         dbms_cx.grava_log('<tr><td width=19% align=center><font face=Arial size=1>' || to_char(campo.momento, 'DD/MM/YYYY HH24:MI:SS') || '</font></td>','Cadastro.htm');
                        dbms_cx.grava_log('<td width=14% align=center><font face=Arial size=1> ' || campo.nome_tabela || '</font></td>','Cadastro.htm');
                         select chave into chav  from sys_cad_log  where SEQ = campo.seq;
                tam_str:=1;
                n_loop:= (DBMS_LOB.GETLENGTH (chav)/255) + 1;
                dbms_cx.grava_log('<td width=35% align=left><font face=Arial size=1>','Cadastro.htm');
                for aux in 1..n_loop loop
                        buf := DBMS_LOB.SUBSTR(chav, 255, tam_str);
                        dbms_cx.grava_log(buf ,'Cadastro.htm');
                        tam_str:=tam_str + 255;
                end loop;
        dbms_cx.grava_log('</font></td>','Cadastro.htm');
              dbms_cx.grava_log('<td width=13% align=center><font face=Arial size=1>' || campo.ação || '</font></td>','Cadastro.htm');
              dbms_cx.grava_log('<td width=29% align=center><font face=Arial size=1>' || campo.usuário || ' / ' || campo.local || ' </font></td></tr>','Cadastro.htm');
         end loop;
        dbms_cx.grava_log('</table></body></html>','Cadastro.htm'); -- fim da tabela e fim do HTML
        delete from sys_cad_log;
        commit;
        Ret :=   DBMS_CX.DOSSHELL('sendmail -f ' || de || ' -t ' || replace(Para, ';', ' -t ') || ' -s "Ciex - Notificação de Cadastro" -a "' ||  public_dir() || '\Cadastro.htm" -m ' || servidor_msg || '');
        Ret :=   DBMS_CX.DOSSHELL('DEL ' || public_dir() || '\' || 'Cadastro.htm');
        end if;
exception
            when others then
                raise_application_error ( -20000, 'Erro na CAD_LOG');
end;
end cad_log;

end;
/

