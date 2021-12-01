-------------------------------------------------------------------------------------
-- CRIAÇÃO DE SCRIPT PARA GERAR PACOTE DE FUNÇÕES BÁSICAS DO CNTA
--
-- desenvolvedor...: Luciano Lisbôa -- data: 18/07/2000
-- programa assist.: ESTRUT_CIEX_8i_2000.MDB
--
-- importante: * para rodar este, necessário antes rodar CNTA.SQL e TRANSF_CNTA.SQL
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
        procedure acerta_ciex;
        procedure log(reglog in utl_file.file_type, texto in varchar2);
        procedure loga(reglog in utl_file.file_type, diretorio in varchar2, arquivo in varchar2);
        procedure inicia_localidade(diretorio in varchar2, arquivo in varchar2, senhalocal in varchar2, servicolocal in varchar2);

        procedure grava_log(texto in varchar2,nome_arq in varchar2);
        procedure cad_log(de in varchar, para in varchar, servidor_msg in varchar);


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

                comando := 'sendmail -f ' || De || ' -t ' || replace(Para, ';', ' -t ') || ' -s "' || Assunto || '"';

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
                                                err := sendmail('cnta@xxxxxxxxx.com.br', email, 'CIEX - Rotina de criação de pacote', servsmtp, 'O sistema não está conseguindo criar pacotes devido às estruturas temporárias estarem bloqueadas por mais de 6 horas (modelo = 2).');
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
                                        delete from MAPA_T;
                                        delete from LOG_IMPORT_T;
                                        delete from ANEXO_T;
                                        delete from PLANILHA_DEF_T;
                                        delete from SYS_DELETE_T;
                                        delete from TRANSAÇÃO_LANCE_T;
                                        delete from PLANILHA_STC_T;
                                        delete from SUB_CONTA_T;
                                        delete from CONTA_T;
                                        delete from EMPRESA_T;
                                        delete from TRANSAÇÃO_T;

                                        COMMIT;

                                        set transaction read write;

                                        log(reglog, 'Transferindo informações para estruturas de transferência.');
                                        insert into TRANSAÇÃO_T (EMPRESA,TRANSAÇÃO,DATA,HISTÓRICO,REL_EMPRESA,REL_TRANSAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,TRANSAÇÃO,DATA,HISTÓRICO,REL_EMPRESA,REL_TRANSAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from TRANSAÇÃO where SYS_STATUS <> ' ';

                                        insert into LOG_IMPORT_T (SEQ,NOME,DATA,SITUAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select SEQ,NOME,DATA,SITUAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from LOG_IMPORT where SYS_STATUS <> ' ';

                                        insert into ANEXO_T (NOME,SUB_CONTA,SUB_CONTA_REL,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select NOME,SUB_CONTA,SUB_CONTA_REL,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from ANEXO where SYS_STATUS <> ' ';

                                        insert into SYS_DELETE_T (CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO)
                                        select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO  from SYS_DELETE;

                                        insert into EMPRESA_T (EMPRESA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from EMPRESA where SYS_STATUS <> ' ';

                                        insert into PLANILHA_STC_T (EMPRESA,WORKSHEET,ARQUIVO,MAPA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,WORKSHEET,ARQUIVO,MAPA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PLANILHA_STC where SYS_STATUS <> ' ';

                                        insert into CONTA_T (NOME,EMPRESA,CONTA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select NOME,EMPRESA,CONTA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CONTA where SYS_STATUS <> ' ';

                                        insert into MAPA_T (EMPRESA,WORKSHEET,SEQ,ARQUIVO,TITULO,LINHA,COLUNA,COR,LARGURA,FONT,FONT_NEGRITO,FONT_TAM,ALINHAMENTO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,WORKSHEET,SEQ,ARQUIVO,TITULO,LINHA,COLUNA,COR,LARGURA,FONT,FONT_NEGRITO,FONT_TAM,ALINHAMENTO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from MAPA where SYS_STATUS <> ' ';

                                        insert into PLANILHA_DEF_T (EMPRESA,WORKSHEET,SEQ,ARQUIVO,TIPO,HISTÓRICO,DATAHIST,COLUNACRT,CRT,COLUNADBCR,DÉBITO,CRÉDITO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,WORKSHEET,SEQ,ARQUIVO,TIPO,HISTÓRICO,DATAHIST,COLUNACRT,CRT,COLUNADBCR,DÉBITO,CRÉDITO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PLANILHA_DEF where SYS_STATUS <> ' ';

                                        insert into SUB_CONTA_T (EMPRESA,SUB_CONTA,CONTA,NOME,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,SUB_CONTA,CONTA,NOME,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from SUB_CONTA where SYS_STATUS <> ' ';

                                        insert into TRANSAÇÃO_LANCE_T (EMPRESA,TRANSAÇÃO,SEQ,SUB_CONTA,DÉBITO,CRÉDITO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,TRANSAÇÃO,SEQ,SUB_CONTA,DÉBITO,CRÉDITO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from TRANSAÇÃO_LANCE where SYS_STATUS <> ' ';


                                        log(reglog, 'Inicializando status dos registros exportados.');
                                        update TRANSAÇÃO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update LOG_IMPORT set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update ANEXO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        delete from SYS_DELETE;
                                        update EMPRESA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PLANILHA_STC set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CONTA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update MAPA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PLANILHA_DEF set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update SUB_CONTA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update TRANSAÇÃO_LANCE set SYS_STATUS = 'X' where SYS_STATUS <> ' ';

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
                                delete from MAPA_T;
                                delete from LOG_IMPORT_T;
                                delete from ANEXO_T;
                                delete from PLANILHA_DEF_T;
                                delete from SYS_DELETE_T;
                                delete from TRANSAÇÃO_LANCE_T;
                                delete from PLANILHA_STC_T;
                                delete from SUB_CONTA_T;
                                delete from CONTA_T;
                                delete from EMPRESA_T;
                                delete from TRANSAÇÃO_T;
                                COMMIT;

                                set transaction read write;

                                log(reglog, 'Transferindo informações para estruturas de transferência.');
                                if full='y' then
                                        insert into TRANSAÇÃO_T (EMPRESA,TRANSAÇÃO,DATA,HISTÓRICO,REL_EMPRESA,REL_TRANSAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,TRANSAÇÃO,DATA,HISTÓRICO,REL_EMPRESA,REL_TRANSAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TRANSAÇÃO;

                                        insert into LOG_IMPORT_T (SEQ,NOME,DATA,SITUAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select SEQ,NOME,DATA,SITUAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from LOG_IMPORT;

                                        insert into ANEXO_T (NOME,SUB_CONTA,SUB_CONTA_REL,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select NOME,SUB_CONTA,SUB_CONTA_REL,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from ANEXO;

                                        insert into EMPRESA_T (EMPRESA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from EMPRESA;

                                        insert into PLANILHA_STC_T (EMPRESA,WORKSHEET,ARQUIVO,MAPA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,WORKSHEET,ARQUIVO,MAPA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from PLANILHA_STC;

                                        insert into CONTA_T (NOME,EMPRESA,CONTA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select NOME,EMPRESA,CONTA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CONTA;

                                        insert into MAPA_T (EMPRESA,WORKSHEET,SEQ,ARQUIVO,TITULO,LINHA,COLUNA,COR,LARGURA,FONT,FONT_NEGRITO,FONT_TAM,ALINHAMENTO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,WORKSHEET,SEQ,ARQUIVO,TITULO,LINHA,COLUNA,COR,LARGURA,FONT,FONT_NEGRITO,FONT_TAM,ALINHAMENTO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from MAPA;

                                        insert into PLANILHA_DEF_T (EMPRESA,WORKSHEET,SEQ,ARQUIVO,TIPO,HISTÓRICO,DATAHIST,COLUNACRT,CRT,COLUNADBCR,DÉBITO,CRÉDITO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,WORKSHEET,SEQ,ARQUIVO,TIPO,HISTÓRICO,DATAHIST,COLUNACRT,CRT,COLUNADBCR,DÉBITO,CRÉDITO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from PLANILHA_DEF;

                                        insert into SUB_CONTA_T (EMPRESA,SUB_CONTA,CONTA,NOME,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,SUB_CONTA,CONTA,NOME,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from SUB_CONTA;

                                        insert into TRANSAÇÃO_LANCE_T (EMPRESA,TRANSAÇÃO,SEQ,SUB_CONTA,DÉBITO,CRÉDITO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,TRANSAÇÃO,SEQ,SUB_CONTA,DÉBITO,CRÉDITO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TRANSAÇÃO_LANCE;

                                else
                                        insert into TRANSAÇÃO_T (EMPRESA,TRANSAÇÃO,DATA,HISTÓRICO,REL_EMPRESA,REL_TRANSAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,TRANSAÇÃO,DATA,HISTÓRICO,REL_EMPRESA,REL_TRANSAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TRANSAÇÃO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into LOG_IMPORT_T (SEQ,NOME,DATA,SITUAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select SEQ,NOME,DATA,SITUAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from LOG_IMPORT where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into ANEXO_T (NOME,SUB_CONTA,SUB_CONTA_REL,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select NOME,SUB_CONTA,SUB_CONTA_REL,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from ANEXO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into EMPRESA_T (EMPRESA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from EMPRESA where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into PLANILHA_STC_T (EMPRESA,WORKSHEET,ARQUIVO,MAPA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,WORKSHEET,ARQUIVO,MAPA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from PLANILHA_STC where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into CONTA_T (NOME,EMPRESA,CONTA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select NOME,EMPRESA,CONTA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CONTA where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into MAPA_T (EMPRESA,WORKSHEET,SEQ,ARQUIVO,TITULO,LINHA,COLUNA,COR,LARGURA,FONT,FONT_NEGRITO,FONT_TAM,ALINHAMENTO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,WORKSHEET,SEQ,ARQUIVO,TITULO,LINHA,COLUNA,COR,LARGURA,FONT,FONT_NEGRITO,FONT_TAM,ALINHAMENTO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from MAPA where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into PLANILHA_DEF_T (EMPRESA,WORKSHEET,SEQ,ARQUIVO,TIPO,HISTÓRICO,DATAHIST,COLUNACRT,CRT,COLUNADBCR,DÉBITO,CRÉDITO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,WORKSHEET,SEQ,ARQUIVO,TIPO,HISTÓRICO,DATAHIST,COLUNACRT,CRT,COLUNADBCR,DÉBITO,CRÉDITO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from PLANILHA_DEF where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into SUB_CONTA_T (EMPRESA,SUB_CONTA,CONTA,NOME,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,SUB_CONTA,CONTA,NOME,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from SUB_CONTA where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into TRANSAÇÃO_LANCE_T (EMPRESA,TRANSAÇÃO,SEQ,SUB_CONTA,DÉBITO,CRÉDITO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select EMPRESA,TRANSAÇÃO,SEQ,SUB_CONTA,DÉBITO,CRÉDITO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TRANSAÇÃO_LANCE where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

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
                                        err := DBMS_CX.DOSSHELL('sendmail -f cnta@xxxxxxxxx.com.br -t ' || replace(email, ';', ' -t ') || ' -a "' ||
                                        diretorio || '\' || arqpac || '.ARJ' || '" -a "D:\CNTA_T\' || arqpac || '.LOG" -s "CIEX - Transferência do pacote ' ||
                                        diretorio || '\' || arqpac || '.ARJ' || '" -m ' || servsmtp);
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
                                err := sendmail('cnta@xxxxxxxxx.com.br', email, 'CIEX - Rotina de criação de pacote', servsmtp, 'Erro durante a criação do pacote.', diretorio || '\' || arqpac || '.LOG');
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
                                                err := sendmail('cnta@xxxxxxxxx.com.br', email, 'CIEX - Rotina de tratamento de pacote', servsmtp, 'O sistema não está conseguindo tratar pacotes devido às estruturas temporárias estarem bloqueadas por mais de 6 horas (modelo = 2).');
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
                        delete from MAPA_T;
                        delete from LOG_IMPORT_T;
                        delete from ANEXO_T;
                        delete from PLANILHA_DEF_T;
                        delete from SYS_DELETE_T;
                        delete from TRANSAÇÃO_LANCE_T;
                        delete from PLANILHA_STC_T;
                        delete from SUB_CONTA_T;
                        delete from CONTA_T;
                        delete from EMPRESA_T;
                        delete from TRANSAÇÃO_T;
                        COMMIT;

                        log(reglog, 'Importando informações do pacote.');
                        err := DBMS_CX.DOSSHELL('imp.exe ' || localpac || '/' || senhalocal || '@' || servicolocal || ' FILE=' || diretorio || '\' || arqpac_remoto || '.PAC' || ' LOG=' || diretorio || '\RECEB.TMP PARFILE=' || diretorio || '\' || 'RECEB.PAR TOUSER=CNTA');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando imp.exe');
                        end if;
                        loga(reglog, diretorio, 'RECEB.TMP');

                        log(reglog, 'Tratando inclusões e alterações.');



                        log(reglog, 'Tratando exclusões.');

                        -- tratando exclusões da tabela MAPA
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CNTA.SYS_DELETE_T where NOME_TABELA = 'MAPA';
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

                        -- tratando exclusões da tabela LOG_IMPORT
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CNTA.SYS_DELETE_T where NOME_TABELA = 'LOG_IMPORT';
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

                        -- tratando exclusões da tabela ANEXO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CNTA.SYS_DELETE_T where NOME_TABELA = 'ANEXO';
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

                        -- tratando exclusões da tabela PLANILHA_DEF
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CNTA.SYS_DELETE_T where NOME_TABELA = 'PLANILHA_DEF';
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

                        -- tratando exclusões da tabela TRANSAÇÃO_LANCE
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CNTA.SYS_DELETE_T where NOME_TABELA = 'TRANSAÇÃO_LANCE';
                                begin
                                        for cur in origem loop
                                                delete from TRANSAÇÃO_LANCE T where (T.EMPRESA || T.TRANSAÇÃO || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg TRANSAÇÃO_LANCE: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído TRANSAÇÃO_LANCE: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela TRANSAÇÃO_LANCE - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PLANILHA_STC
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CNTA.SYS_DELETE_T where NOME_TABELA = 'PLANILHA_STC';
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

                        -- tratando exclusões da tabela SUB_CONTA
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CNTA.SYS_DELETE_T where NOME_TABELA = 'SUB_CONTA';
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

                        -- tratando exclusões da tabela CONTA
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CNTA.SYS_DELETE_T where NOME_TABELA = 'CONTA';
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

                        -- tratando exclusões da tabela EMPRESA
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CNTA.SYS_DELETE_T where NOME_TABELA = 'EMPRESA';
                                begin
                                        for cur in origem loop
                                                delete from EMPRESA T where (T.EMPRESA = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg EMPRESA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído EMPRESA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela EMPRESA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela TRANSAÇÃO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CNTA.SYS_DELETE_T where NOME_TABELA = 'TRANSAÇÃO';
                                begin
                                        for cur in origem loop
                                                delete from TRANSAÇÃO T where (T.EMPRESA || T.TRANSAÇÃO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg TRANSAÇÃO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído TRANSAÇÃO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela TRANSAÇÃO - ' || SQLERRM);
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
                                err := DBMS_CX.DOSSHELL('sendmail -f cnta@xxxxxxxxx.com.br -t ' || replace(email, ';', ' -t ') || ' -a "D:\CNTA_T\' ||
                                arqpac_remoto || '.LOG" -s "CIEX - Recebimento de pacote ' ||
                                diretorio || '\' || arqpac_remoto || '.ARJ' || '" -m ' || servsmtp);
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
                                err := sendmail('cnta@xxxxxxxxx.com.br', email, 'CIEX - Rotina de tratamento de pacote', servsmtp, 'Erro durante o tratamento do pacote.', diretorio || '\' || arqpac_remoto || '.LOG');
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

                        delete from MAPA_T;
                        delete from LOG_IMPORT_T;
                        delete from ANEXO_T;
                        delete from PLANILHA_DEF_T;
                        delete from SYS_DELETE_T;
                        delete from TRANSAÇÃO_LANCE_T;
                        delete from PLANILHA_STC_T;
                        delete from SUB_CONTA_T;
                        delete from CONTA_T;
                        delete from EMPRESA_T;
                        delete from TRANSAÇÃO_T;
                        COMMIT;

                        log(reglog, 'Importando informações do pacote.');
                        err := DBMS_CX.DOSSHELL('imp.exe CNTA/' || senhalocal || '@' || servicolocal || ' FILE=' || diretorio || '\' || arquivo || '.PAC' || ' LOG=' || diretorio || '\RECEB.TMP PARFILE=' || diretorio || '\' || 'RECEB.PAR FROMUSER=CNTA');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando imp.exe');
                        end if;
                        loga(reglog, diretorio, 'RECEB.TMP');

                        log(reglog, 'Apaga registros das tabelas da localidade.');
                        log(reglog, 'Excluindo registros de MAPA.');
                        delete from MAPA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de LOG_IMPORT.');
                        delete from LOG_IMPORT;
                        COMMIT;
                        log(reglog, 'Excluindo registros de ANEXO.');
                        delete from ANEXO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PLANILHA_DEF.');
                        delete from PLANILHA_DEF;
                        COMMIT;
                        log(reglog, 'Excluindo registros de SYS_DELETE.');
                        delete from SYS_DELETE;
                        COMMIT;
                        log(reglog, 'Excluindo registros de TRANSAÇÃO_LANCE.');
                        delete from TRANSAÇÃO_LANCE;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PLANILHA_STC.');
                        delete from PLANILHA_STC;
                        COMMIT;
                        log(reglog, 'Excluindo registros de SUB_CONTA.');
                        delete from SUB_CONTA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CONTA.');
                        delete from CONTA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de EMPRESA.');
                        delete from EMPRESA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de TRANSAÇÃO.');
                        delete from TRANSAÇÃO;
                        COMMIT;
                        COMMIT;


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
                        delete from MAPA_T;
                        delete from LOG_IMPORT_T;
                        delete from ANEXO_T;
                        delete from PLANILHA_DEF_T;
                        delete from SYS_DELETE_T;
                        delete from TRANSAÇÃO_LANCE_T;
                        delete from PLANILHA_STC_T;
                        delete from SUB_CONTA_T;
                        delete from CONTA_T;
                        delete from EMPRESA_T;
                        delete from TRANSAÇÃO_T;
                        COMMIT;

                        log(reglog, 'Importando informações do pacote.');
                        err := DBMS_CX.DOSSHELL('imp.exe ' || localpac || '/' || senhalocal || '@' || servicolocal || ' FILE=' || diretorio || '\' || arqpac_remoto || '.PAC' || ' LOG=' || diretorio || '\RECEB.TMP PARFILE=' || diretorio || '\' || 'RECEB.PAR TOUSER=CNTA');
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

