-------------------------------------------------------------------------------------
-- CRIAÇÃO DE SCRIPT PARA GERAR PACOTE DE FUNÇÕES BÁSICAS DO CXRJ
--
-- desenvolvedor...: Luciano Lisbôa -- data: 18/07/2000
-- programa assist.: ESTRUT_CIEX_8i_2000.MDB
--
-- importante: * para rodar este, necessário antes rodar CXRJ.SQL e TRANSF_CXRJ.SQL
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
                                                err := sendmail('cxrj@xxxxxxxxx.com.br', email, 'CIEX - Rotina de criação de pacote', servsmtp, 'O sistema não está conseguindo criar pacotes devido às estruturas temporárias estarem bloqueadas por mais de 6 horas (modelo = 2).');
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
                                        delete from CRONOGRAMA_T;
                                        delete from MOVIMENTO_PREV_T;
                                        delete from CLASSIF_T;
                                        delete from CONJ_IMPRESS_T;
                                        delete from CONTA_T;
                                        delete from CONTATO_T;
                                        delete from HIERARQUIA_T;
                                        delete from IDENTIF_T;
                                        delete from IP_T;
                                        delete from LICENÇA_T;
                                        delete from MÁQUINA_RECURSO_T;
                                        delete from CD_T;
                                        delete from MOVIMENTO_T;
                                        delete from REALIZADO_COM_DURAÇÃO_STAT_T;
                                        delete from PONTO_T;
                                        delete from TAREFA_DEF_T;
                                        delete from REALIZADO_T;
                                        delete from SERVIÇO_T;
                                        delete from SYS_DELETE_T;
                                        delete from TABELA_SÓCIO_T;
                                        delete from ACESSO_T;
                                        delete from CONJ_REL_T;
                                        delete from TIPO_TAREFA_T;
                                        delete from TIPO_SERVIÇO_T;
                                        delete from PATCH_T;
                                        delete from CLASSE_T;
                                        delete from PROJETO_T;
                                        delete from TIPO_IDENTIF_T;
                                        delete from MÁQUINA_T;
                                        delete from REDE_T;
                                        delete from RECURSO_T;
                                        delete from TIPO_RECURSO_T;
                                        delete from USUÁRIO_T;
                                        delete from TÉCNICO_T;
                                        delete from DEPTO_T;
                                        delete from CLIENTE_T;
                                        delete from GRUPO_T;

                                        COMMIT;

                                        set transaction read write;

                                        log(reglog, 'Transferindo informações para estruturas de transferência.');
                                        insert into MOVIMENTO_PREV_T (CLASSE,CONTA,CONTROLE,DATA_REF,ENTRADA,EVENTO,HISTÓRICO,INCREM_ANO,INCREM_DIA,INCREM_MÊS,OBS,OPERADOR,PENDÊNCIA,PERÍODO_REF,SAÍDA,SEQ,SÓCIO,ÚLTIMA_DATA,VEZES,VINC_CONTA,VINC_SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CONTA,CONTROLE,DATA_REF,ENTRADA,EVENTO,HISTÓRICO,INCREM_ANO,INCREM_DIA,INCREM_MÊS,OBS,OPERADOR,PENDÊNCIA,PERÍODO_REF,SAÍDA,SEQ,SÓCIO,ÚLTIMA_DATA,VEZES,VINC_CONTA,VINC_SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from MOVIMENTO_PREV where SYS_STATUS <> ' ';

                                        insert into CLASSE_T (LOC,NOME,PREF,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select LOC,NOME,PREF,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CLASSE where SYS_STATUS <> ' ';

                                        insert into CLASSIF_T (CLASSE,DESCRIÇÃO,OBS,TIPO,TRAT,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,DESCRIÇÃO,OBS,TIPO,TRAT,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CLASSIF where SYS_STATUS <> ' ';

                                        insert into CLIENTE_T (NOME,NOTIFIC_EMAIL,OBRIGATÓRIO,ORDEM,REQ_DEPTO,REQ_PROJETO,REQ_USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select NOME,NOTIFIC_EMAIL,OBRIGATÓRIO,ORDEM,REQ_DEPTO,REQ_PROJETO,REQ_USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CLIENTE where SYS_STATUS <> ' ';

                                        insert into CONJ_REL_T (ARQ,CLIENTE,DEFINIÇÃO,DEPTO,DUR_MIN,GRUPO_PROJETO,LOG,MÁQUINA,NOME_ARQ,NOTIFIC_AOCLIENTE,NOTIFIC_AODEPTO,NOTIFIC_AOTÉCNICO,NOTIFIC_AOUSUÁRIO,NOTIFIC_EMAIL,NOTIFIC_IMEDIATO,PERÍODO_ATÉ,PERÍODO_DE,QUEBRA_USU,RELATÓRIOS,SEQ,TÉCNICO,TIPO_HORA,TIPO_TAREFA,USUÁRIO,DATA_ACUMULA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ARQ,CLIENTE,DEFINIÇÃO,DEPTO,DUR_MIN,GRUPO_PROJETO,LOG,MÁQUINA,NOME_ARQ,NOTIFIC_AOCLIENTE,NOTIFIC_AODEPTO,NOTIFIC_AOTÉCNICO,NOTIFIC_AOUSUÁRIO,NOTIFIC_EMAIL,NOTIFIC_IMEDIATO,PERÍODO_ATÉ,PERÍODO_DE,QUEBRA_USU,RELATÓRIOS,SEQ,TÉCNICO,TIPO_HORA,TIPO_TAREFA,USUÁRIO,DATA_ACUMULA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CONJ_REL where SYS_STATUS <> ' ';

                                        insert into CONTA_T (CONTA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CONTA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CONTA where SYS_STATUS <> ' ';

                                        insert into CONTATO_T (CLASSE,CONTATO,EMAIL,EMPRESA,ENDEREÇO,FAX,OBS,SEQ,TELEFONE,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CONTATO,EMAIL,EMPRESA,ENDEREÇO,FAX,OBS,SEQ,TELEFONE,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CONTATO where SYS_STATUS <> ' ';

                                        insert into HIERARQUIA_T (CLASSE,CLASSIF,CLIENTE,LISTA,SUPER,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CLASSIF,CLIENTE,LISTA,SUPER,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from HIERARQUIA where SYS_STATUS <> ' ';

                                        insert into LICENÇA_T (CÓDIGO,OBS,RECURSO,SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CÓDIGO,OBS,RECURSO,SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from LICENÇA where SYS_STATUS <> ' ';

                                        insert into MOVIMENTO_T (CLASSE,CONTA,CONTROLE,DATA,ENTRADA,EVENTO,HISTÓRICO,MARCA,OBS,OPERADOR,PENDÊNCIA,PREV,REF,SAÍDA,SEQ,SÓCIO,VINC_CONTA,VINC_SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CONTA,CONTROLE,DATA,ENTRADA,EVENTO,HISTÓRICO,MARCA,OBS,OPERADOR,PENDÊNCIA,PREV,REF,SAÍDA,SEQ,SÓCIO,VINC_CONTA,VINC_SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from MOVIMENTO where SYS_STATUS <> ' ';

                                        insert into REALIZADO_COM_DURAÇÃO_STAT_T (TÉCNICO,INI,SEQ,TAREFA,TIPO,CLIENTE,DEPTO,USUÁRIO,OBS,PROJETO,CHAMADO_DATA,GRUPO,LISTA,ATENDIM_INÍCIO,ATENDIM_DATE,PROX_INI,ATENDIM_DUR,DUR,ATENDIM_MAX,ATENDIM_MIN,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select TÉCNICO,INI,SEQ,TAREFA,TIPO,CLIENTE,DEPTO,USUÁRIO,OBS,PROJETO,CHAMADO_DATA,GRUPO,LISTA,ATENDIM_INÍCIO,ATENDIM_DATE,PROX_INI,ATENDIM_DUR,DUR,ATENDIM_MAX,ATENDIM_MIN,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from REALIZADO_COM_DURAÇÃO_STAT where SYS_STATUS <> ' ';

                                        insert into TIPO_TAREFA_T (DESCR,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select DESCR,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from TIPO_TAREFA where SYS_STATUS <> ' ';

                                        insert into TIPO_RECURSO_T (TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from TIPO_RECURSO where SYS_STATUS <> ' ';

                                        insert into ACESSO_T (LOGIN,CLIENTE,DEPTO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select LOGIN,CLIENTE,DEPTO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from ACESSO where SYS_STATUS <> ' ';

                                        insert into TIPO_SERVIÇO_T (TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from TIPO_SERVIÇO where SYS_STATUS <> ' ';

                                        insert into SYS_DELETE_T (CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO)
                                        select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO  from SYS_DELETE;

                                        insert into TABELA_SÓCIO_T (PERÍODO,SÓCIO,VALOR,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select PERÍODO,SÓCIO,VALOR,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from TABELA_SÓCIO where SYS_STATUS <> ' ';

                                        insert into TÉCNICO_T (CLASSIFIC,EMAIL_TÉCNICO,SEC_ID,TÉCNICO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSIFIC,EMAIL_TÉCNICO,SEC_ID,TÉCNICO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from TÉCNICO where SYS_STATUS <> ' ';

                                        insert into TIPO_IDENTIF_T (TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from TIPO_IDENTIF where SYS_STATUS <> ' ';

                                        insert into TAREFA_DEF_T (CLIENTE,COMENTÁRIOS,DEPTO,DETALHE,FATO,GRUPOS,OBS,P_APLICATIVO,PROJETO,TAREFA,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,COMENTÁRIOS,DEPTO,DETALHE,FATO,GRUPOS,OBS,P_APLICATIVO,PROJETO,TAREFA,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from TAREFA_DEF where SYS_STATUS <> ' ';

                                        insert into DEPTO_T (CLIENTE,DEPTO,MARCA,NOTIFIC_EMAIL,SITUAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,DEPTO,MARCA,NOTIFIC_EMAIL,SITUAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from DEPTO where SYS_STATUS <> ' ';

                                        insert into PATCH_T (CLIENTE,PATCH,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,PATCH,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PATCH where SYS_STATUS <> ' ';

                                        insert into SERVIÇO_T (BKP_DIR_CONSOL,BKP_DIR_LOCAL,BKP_NOTIFICAR,BKP_PROG_RETEM,CLIENTE,DESCRIÇÃO,DESENVOLVEDOR,LOCALIZAÇÃO,SERVIÇO,SUPORTE,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select BKP_DIR_CONSOL,BKP_DIR_LOCAL,BKP_NOTIFICAR,BKP_PROG_RETEM,CLIENTE,DESCRIÇÃO,DESENVOLVEDOR,LOCALIZAÇÃO,SERVIÇO,SUPORTE,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from SERVIÇO where SYS_STATUS <> ' ';

                                        insert into CD_T (CLASSE,CONTEÚDO,DATA,ID,MOMENTO,NUM,TÍTULO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CONTEÚDO,DATA,ID,MOMENTO,NUM,TÍTULO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CD where SYS_STATUS <> ' ';

                                        insert into RECURSO_T (LOCALIZAÇÃO,OBS,RECURSO,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select LOCALIZAÇÃO,OBS,RECURSO,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from RECURSO where SYS_STATUS <> ' ';

                                        insert into REDE_T (CLIENTE,ENDEREÇO,MÁSCARA,OBS,REDE,SUBNET_AUTO,SUBNET_PARAM,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,ENDEREÇO,MÁSCARA,OBS,REDE,SUBNET_AUTO,SUBNET_PARAM,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from REDE where SYS_STATUS <> ' ';

                                        insert into CONJ_IMPRESS_T (ARQUIVO,DEFINIÇÃO,DEFINIÇÃO_SEQ,FILTRO,GERAÇÃO_MOMENTO,IMPRESSÃO_MOMENTO,ITEM,NOTIFIC_EMAIL,NOTIFIC_MOMENTO,REL,RESULT,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ARQUIVO,DEFINIÇÃO,DEFINIÇÃO_SEQ,FILTRO,GERAÇÃO_MOMENTO,IMPRESSÃO_MOMENTO,ITEM,NOTIFIC_EMAIL,NOTIFIC_MOMENTO,REL,RESULT,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CONJ_IMPRESS where SYS_STATUS <> ' ';

                                        insert into PONTO_T (ATUAL_UTILIZAÇÃO,CLIENTE,LOCALIZAÇÃO,PATCH,PONTO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ATUAL_UTILIZAÇÃO,CLIENTE,LOCALIZAÇÃO,PATCH,PONTO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PONTO where SYS_STATUS <> ' ';

                                        insert into USUÁRIO_T (SEC_ID,CLIENTE,DEPTO,DESLIGAMENTO,NOTIFIC_EMAIL,SITUAÇÃO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select SEC_ID,CLIENTE,DEPTO,DESLIGAMENTO,NOTIFIC_EMAIL,SITUAÇÃO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from USUÁRIO where SYS_STATUS <> ' ';

                                        insert into IDENTIF_T (CLIENTE,IDENTIF,OBS,SEC_ID,SENHA,SENHA2,TIPO_IDENTIF,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,IDENTIF,OBS,SEC_ID,SENHA,SENHA2,TIPO_IDENTIF,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from IDENTIF where SYS_STATUS <> ' ';

                                        insert into MÁQUINA_T (CLIENTE,MÁQUINA,OBS,SEC_ID,SENHA,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,MÁQUINA,OBS,SEC_ID,SENHA,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from MÁQUINA where SYS_STATUS <> ' ';

                                        insert into MÁQUINA_RECURSO_T (CLIENTE,COMPLEMENTO,MÁQUINA,RECURSO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,COMPLEMENTO,MÁQUINA,RECURSO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from MÁQUINA_RECURSO where SYS_STATUS <> ' ';

                                        insert into IP_T (CLIENTE,DNS,IP,MAC,MÁQUINA,OBS,REDE_CLIENTE,REDE_IDENTIF,ROTEADOR,SUBNET_HOST_ID,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,DNS,IP,MAC,MÁQUINA,OBS,REDE_CLIENTE,REDE_IDENTIF,ROTEADOR,SUBNET_HOST_ID,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from IP where SYS_STATUS <> ' ';

                                        insert into CRONOGRAMA_T (CLIENTE,CONFIRMAÇÃO,CONFIRMAÇÃO_ADM,CONFIRMADOR,CONSOLID,CONTÍNUA,CRIAÇÃO,CRIADOR_ADM,DELEGAÇÃO,DESENVOLVEDOR,DURAÇÃO,ETAPA,NOVA_OBS,NOVA_PREV,OBS,OBS_ADM,PAI_SEQ,PREVISÃO,PREVISÃO_ADM,PROJETO,REALIZAÇÃO,SEQ,SEQ_N,SUPORTE,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,CONFIRMAÇÃO,CONFIRMAÇÃO_ADM,CONFIRMADOR,CONSOLID,CONTÍNUA,CRIAÇÃO,CRIADOR_ADM,DELEGAÇÃO,DESENVOLVEDOR,DURAÇÃO,ETAPA,NOVA_OBS,NOVA_PREV,OBS,OBS_ADM,PAI_SEQ,PREVISÃO,PREVISÃO_ADM,PROJETO,REALIZAÇÃO,SEQ,SEQ_N,SUPORTE,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from CRONOGRAMA where SYS_STATUS <> ' ';

                                        insert into GRUPO_T (CLIENTE,DEPENDE,GRUPO,ORDEM,SUPERGRUPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,DEPENDE,GRUPO,ORDEM,SUPERGRUPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from GRUPO where SYS_STATUS <> ' ';

                                        insert into PROJETO_T (CLIENTE,DESENVOLVEDOR,GRUPO,OBS,ORDEM,PROJETO,STATUS,SUPORTE,DESENVOLVEDOR2,SUPORTE2,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,DESENVOLVEDOR,GRUPO,OBS,ORDEM,PROJETO,STATUS,SUPORTE,DESENVOLVEDOR2,SUPORTE2,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from PROJETO where SYS_STATUS <> ' ';

                                        insert into REALIZADO_T (ATENDIM_FIM,ATENDIM_INÍCIO,CHAMADO_DATA,CLIENTE,DEPTO,INI,OBS,PROJETO,SEQ,TAREFA,TÉCNICO,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ATENDIM_FIM,ATENDIM_INÍCIO,CHAMADO_DATA,CLIENTE,DEPTO,INI,OBS,PROJETO,SEQ,TAREFA,TÉCNICO,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from REALIZADO where SYS_STATUS <> ' ';


                                        log(reglog, 'Inicializando status dos registros exportados.');
                                        update MOVIMENTO_PREV set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CLASSE set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CLASSIF set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CLIENTE set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CONJ_REL set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CONTA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CONTATO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update HIERARQUIA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update LICENÇA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update MOVIMENTO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update REALIZADO_COM_DURAÇÃO_STAT set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update TIPO_TAREFA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update TIPO_RECURSO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update ACESSO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update TIPO_SERVIÇO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        delete from SYS_DELETE;
                                        update TABELA_SÓCIO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update TÉCNICO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update TIPO_IDENTIF set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update TAREFA_DEF set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update DEPTO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PATCH set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update SERVIÇO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CD set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update RECURSO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update REDE set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CONJ_IMPRESS set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PONTO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update USUÁRIO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update IDENTIF set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update MÁQUINA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update MÁQUINA_RECURSO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update IP set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update CRONOGRAMA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update GRUPO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update PROJETO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        update REALIZADO set SYS_STATUS = 'X' where SYS_STATUS <> ' ';

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
                                delete from CRONOGRAMA_T;
                                delete from MOVIMENTO_PREV_T;
                                delete from CLASSIF_T;
                                delete from CONJ_IMPRESS_T;
                                delete from CONTA_T;
                                delete from CONTATO_T;
                                delete from HIERARQUIA_T;
                                delete from IDENTIF_T;
                                delete from IP_T;
                                delete from LICENÇA_T;
                                delete from MÁQUINA_RECURSO_T;
                                delete from CD_T;
                                delete from MOVIMENTO_T;
                                delete from REALIZADO_COM_DURAÇÃO_STAT_T;
                                delete from PONTO_T;
                                delete from TAREFA_DEF_T;
                                delete from REALIZADO_T;
                                delete from SERVIÇO_T;
                                delete from SYS_DELETE_T;
                                delete from TABELA_SÓCIO_T;
                                delete from ACESSO_T;
                                delete from CONJ_REL_T;
                                delete from TIPO_TAREFA_T;
                                delete from TIPO_SERVIÇO_T;
                                delete from PATCH_T;
                                delete from CLASSE_T;
                                delete from PROJETO_T;
                                delete from TIPO_IDENTIF_T;
                                delete from MÁQUINA_T;
                                delete from REDE_T;
                                delete from RECURSO_T;
                                delete from TIPO_RECURSO_T;
                                delete from USUÁRIO_T;
                                delete from TÉCNICO_T;
                                delete from DEPTO_T;
                                delete from CLIENTE_T;
                                delete from GRUPO_T;
                                COMMIT;

                                set transaction read write;

                                log(reglog, 'Transferindo informações para estruturas de transferência.');
                                if full='y' then
                                        insert into MOVIMENTO_PREV_T (CLASSE,CONTA,CONTROLE,DATA_REF,ENTRADA,EVENTO,HISTÓRICO,INCREM_ANO,INCREM_DIA,INCREM_MÊS,OBS,OPERADOR,PENDÊNCIA,PERÍODO_REF,SAÍDA,SEQ,SÓCIO,ÚLTIMA_DATA,VEZES,VINC_CONTA,VINC_SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CONTA,CONTROLE,DATA_REF,ENTRADA,EVENTO,HISTÓRICO,INCREM_ANO,INCREM_DIA,INCREM_MÊS,OBS,OPERADOR,PENDÊNCIA,PERÍODO_REF,SAÍDA,SEQ,SÓCIO,ÚLTIMA_DATA,VEZES,VINC_CONTA,VINC_SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from MOVIMENTO_PREV;

                                        insert into CLASSE_T (LOC,NOME,PREF,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select LOC,NOME,PREF,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CLASSE;

                                        insert into CLASSIF_T (CLASSE,DESCRIÇÃO,OBS,TIPO,TRAT,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,DESCRIÇÃO,OBS,TIPO,TRAT,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CLASSIF;

                                        insert into CLIENTE_T (NOME,NOTIFIC_EMAIL,OBRIGATÓRIO,ORDEM,REQ_DEPTO,REQ_PROJETO,REQ_USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select NOME,NOTIFIC_EMAIL,OBRIGATÓRIO,ORDEM,REQ_DEPTO,REQ_PROJETO,REQ_USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CLIENTE;

                                        insert into CONJ_REL_T (ARQ,CLIENTE,DEFINIÇÃO,DEPTO,DUR_MIN,GRUPO_PROJETO,LOG,MÁQUINA,NOME_ARQ,NOTIFIC_AOCLIENTE,NOTIFIC_AODEPTO,NOTIFIC_AOTÉCNICO,NOTIFIC_AOUSUÁRIO,NOTIFIC_EMAIL,NOTIFIC_IMEDIATO,PERÍODO_ATÉ,PERÍODO_DE,QUEBRA_USU,RELATÓRIOS,SEQ,TÉCNICO,TIPO_HORA,TIPO_TAREFA,USUÁRIO,DATA_ACUMULA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ARQ,CLIENTE,DEFINIÇÃO,DEPTO,DUR_MIN,GRUPO_PROJETO,LOG,MÁQUINA,NOME_ARQ,NOTIFIC_AOCLIENTE,NOTIFIC_AODEPTO,NOTIFIC_AOTÉCNICO,NOTIFIC_AOUSUÁRIO,NOTIFIC_EMAIL,NOTIFIC_IMEDIATO,PERÍODO_ATÉ,PERÍODO_DE,QUEBRA_USU,RELATÓRIOS,SEQ,TÉCNICO,TIPO_HORA,TIPO_TAREFA,USUÁRIO,DATA_ACUMULA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CONJ_REL;

                                        insert into CONTA_T (CONTA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CONTA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CONTA;

                                        insert into CONTATO_T (CLASSE,CONTATO,EMAIL,EMPRESA,ENDEREÇO,FAX,OBS,SEQ,TELEFONE,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CONTATO,EMAIL,EMPRESA,ENDEREÇO,FAX,OBS,SEQ,TELEFONE,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CONTATO;

                                        insert into HIERARQUIA_T (CLASSE,CLASSIF,CLIENTE,LISTA,SUPER,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CLASSIF,CLIENTE,LISTA,SUPER,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from HIERARQUIA;

                                        insert into LICENÇA_T (CÓDIGO,OBS,RECURSO,SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CÓDIGO,OBS,RECURSO,SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from LICENÇA;

                                        insert into MOVIMENTO_T (CLASSE,CONTA,CONTROLE,DATA,ENTRADA,EVENTO,HISTÓRICO,MARCA,OBS,OPERADOR,PENDÊNCIA,PREV,REF,SAÍDA,SEQ,SÓCIO,VINC_CONTA,VINC_SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CONTA,CONTROLE,DATA,ENTRADA,EVENTO,HISTÓRICO,MARCA,OBS,OPERADOR,PENDÊNCIA,PREV,REF,SAÍDA,SEQ,SÓCIO,VINC_CONTA,VINC_SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from MOVIMENTO;

                                        insert into REALIZADO_COM_DURAÇÃO_STAT_T (TÉCNICO,INI,SEQ,TAREFA,TIPO,CLIENTE,DEPTO,USUÁRIO,OBS,PROJETO,CHAMADO_DATA,GRUPO,LISTA,ATENDIM_INÍCIO,ATENDIM_DATE,PROX_INI,ATENDIM_DUR,DUR,ATENDIM_MAX,ATENDIM_MIN,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select TÉCNICO,INI,SEQ,TAREFA,TIPO,CLIENTE,DEPTO,USUÁRIO,OBS,PROJETO,CHAMADO_DATA,GRUPO,LISTA,ATENDIM_INÍCIO,ATENDIM_DATE,PROX_INI,ATENDIM_DUR,DUR,ATENDIM_MAX,ATENDIM_MIN,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from REALIZADO_COM_DURAÇÃO_STAT;

                                        insert into TABELA_SÓCIO_T (PERÍODO,SÓCIO,VALOR,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select PERÍODO,SÓCIO,VALOR,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TABELA_SÓCIO;

                                        insert into TIPO_RECURSO_T (TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TIPO_RECURSO;

                                        insert into TIPO_SERVIÇO_T (TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TIPO_SERVIÇO;

                                        insert into TAREFA_DEF_T (CLIENTE,COMENTÁRIOS,DEPTO,DETALHE,FATO,GRUPOS,OBS,P_APLICATIVO,PROJETO,TAREFA,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,COMENTÁRIOS,DEPTO,DETALHE,FATO,GRUPOS,OBS,P_APLICATIVO,PROJETO,TAREFA,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TAREFA_DEF;

                                        insert into TIPO_IDENTIF_T (TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TIPO_IDENTIF;

                                        insert into TIPO_TAREFA_T (DESCR,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select DESCR,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TIPO_TAREFA;

                                        insert into TÉCNICO_T (CLASSIFIC,EMAIL_TÉCNICO,SEC_ID,TÉCNICO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSIFIC,EMAIL_TÉCNICO,SEC_ID,TÉCNICO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TÉCNICO;

                                        insert into ACESSO_T (LOGIN,CLIENTE,DEPTO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select LOGIN,CLIENTE,DEPTO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from ACESSO;

                                        insert into SERVIÇO_T (BKP_DIR_CONSOL,BKP_DIR_LOCAL,BKP_NOTIFICAR,BKP_PROG_RETEM,CLIENTE,DESCRIÇÃO,DESENVOLVEDOR,LOCALIZAÇÃO,SERVIÇO,SUPORTE,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select BKP_DIR_CONSOL,BKP_DIR_LOCAL,BKP_NOTIFICAR,BKP_PROG_RETEM,CLIENTE,DESCRIÇÃO,DESENVOLVEDOR,LOCALIZAÇÃO,SERVIÇO,SUPORTE,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from SERVIÇO;

                                        insert into PATCH_T (CLIENTE,PATCH,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,PATCH,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from PATCH;

                                        insert into REDE_T (CLIENTE,ENDEREÇO,MÁSCARA,OBS,REDE,SUBNET_AUTO,SUBNET_PARAM,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,ENDEREÇO,MÁSCARA,OBS,REDE,SUBNET_AUTO,SUBNET_PARAM,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from REDE;

                                        insert into CONJ_IMPRESS_T (ARQUIVO,DEFINIÇÃO,DEFINIÇÃO_SEQ,FILTRO,GERAÇÃO_MOMENTO,IMPRESSÃO_MOMENTO,ITEM,NOTIFIC_EMAIL,NOTIFIC_MOMENTO,REL,RESULT,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ARQUIVO,DEFINIÇÃO,DEFINIÇÃO_SEQ,FILTRO,GERAÇÃO_MOMENTO,IMPRESSÃO_MOMENTO,ITEM,NOTIFIC_EMAIL,NOTIFIC_MOMENTO,REL,RESULT,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CONJ_IMPRESS;

                                        insert into RECURSO_T (LOCALIZAÇÃO,OBS,RECURSO,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select LOCALIZAÇÃO,OBS,RECURSO,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from RECURSO;

                                        insert into DEPTO_T (CLIENTE,DEPTO,MARCA,NOTIFIC_EMAIL,SITUAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,DEPTO,MARCA,NOTIFIC_EMAIL,SITUAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from DEPTO;

                                        insert into CD_T (CLASSE,CONTEÚDO,DATA,ID,MOMENTO,NUM,TÍTULO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CONTEÚDO,DATA,ID,MOMENTO,NUM,TÍTULO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CD;

                                        insert into PONTO_T (ATUAL_UTILIZAÇÃO,CLIENTE,LOCALIZAÇÃO,PATCH,PONTO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ATUAL_UTILIZAÇÃO,CLIENTE,LOCALIZAÇÃO,PATCH,PONTO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from PONTO;

                                        insert into USUÁRIO_T (SEC_ID,CLIENTE,DEPTO,DESLIGAMENTO,NOTIFIC_EMAIL,SITUAÇÃO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select SEC_ID,CLIENTE,DEPTO,DESLIGAMENTO,NOTIFIC_EMAIL,SITUAÇÃO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from USUÁRIO;

                                        insert into IDENTIF_T (CLIENTE,IDENTIF,OBS,SEC_ID,SENHA,SENHA2,TIPO_IDENTIF,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,IDENTIF,OBS,SEC_ID,SENHA,SENHA2,TIPO_IDENTIF,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from IDENTIF;

                                        insert into MÁQUINA_T (CLIENTE,MÁQUINA,OBS,SEC_ID,SENHA,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,MÁQUINA,OBS,SEC_ID,SENHA,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from MÁQUINA;

                                        insert into MÁQUINA_RECURSO_T (CLIENTE,COMPLEMENTO,MÁQUINA,RECURSO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,COMPLEMENTO,MÁQUINA,RECURSO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from MÁQUINA_RECURSO;

                                        insert into IP_T (CLIENTE,DNS,IP,MAC,MÁQUINA,OBS,REDE_CLIENTE,REDE_IDENTIF,ROTEADOR,SUBNET_HOST_ID,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,DNS,IP,MAC,MÁQUINA,OBS,REDE_CLIENTE,REDE_IDENTIF,ROTEADOR,SUBNET_HOST_ID,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from IP;

                                        insert into CRONOGRAMA_T (CLIENTE,CONFIRMAÇÃO,CONFIRMAÇÃO_ADM,CONFIRMADOR,CONSOLID,CONTÍNUA,CRIAÇÃO,CRIADOR_ADM,DELEGAÇÃO,DESENVOLVEDOR,DURAÇÃO,ETAPA,NOVA_OBS,NOVA_PREV,OBS,OBS_ADM,PAI_SEQ,PREVISÃO,PREVISÃO_ADM,PROJETO,REALIZAÇÃO,SEQ,SEQ_N,SUPORTE,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,CONFIRMAÇÃO,CONFIRMAÇÃO_ADM,CONFIRMADOR,CONSOLID,CONTÍNUA,CRIAÇÃO,CRIADOR_ADM,DELEGAÇÃO,DESENVOLVEDOR,DURAÇÃO,ETAPA,NOVA_OBS,NOVA_PREV,OBS,OBS_ADM,PAI_SEQ,PREVISÃO,PREVISÃO_ADM,PROJETO,REALIZAÇÃO,SEQ,SEQ_N,SUPORTE,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CRONOGRAMA;

                                        insert into GRUPO_T (CLIENTE,DEPENDE,GRUPO,ORDEM,SUPERGRUPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,DEPENDE,GRUPO,ORDEM,SUPERGRUPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from GRUPO;

                                        insert into PROJETO_T (CLIENTE,DESENVOLVEDOR,GRUPO,OBS,ORDEM,PROJETO,STATUS,SUPORTE,DESENVOLVEDOR2,SUPORTE2,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,DESENVOLVEDOR,GRUPO,OBS,ORDEM,PROJETO,STATUS,SUPORTE,DESENVOLVEDOR2,SUPORTE2,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from PROJETO;

                                        insert into REALIZADO_T (ATENDIM_FIM,ATENDIM_INÍCIO,CHAMADO_DATA,CLIENTE,DEPTO,INI,OBS,PROJETO,SEQ,TAREFA,TÉCNICO,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ATENDIM_FIM,ATENDIM_INÍCIO,CHAMADO_DATA,CLIENTE,DEPTO,INI,OBS,PROJETO,SEQ,TAREFA,TÉCNICO,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from REALIZADO;

                                else
                                        insert into MOVIMENTO_PREV_T (CLASSE,CONTA,CONTROLE,DATA_REF,ENTRADA,EVENTO,HISTÓRICO,INCREM_ANO,INCREM_DIA,INCREM_MÊS,OBS,OPERADOR,PENDÊNCIA,PERÍODO_REF,SAÍDA,SEQ,SÓCIO,ÚLTIMA_DATA,VEZES,VINC_CONTA,VINC_SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CONTA,CONTROLE,DATA_REF,ENTRADA,EVENTO,HISTÓRICO,INCREM_ANO,INCREM_DIA,INCREM_MÊS,OBS,OPERADOR,PENDÊNCIA,PERÍODO_REF,SAÍDA,SEQ,SÓCIO,ÚLTIMA_DATA,VEZES,VINC_CONTA,VINC_SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from MOVIMENTO_PREV where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into CLASSE_T (LOC,NOME,PREF,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select LOC,NOME,PREF,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CLASSE where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into CLASSIF_T (CLASSE,DESCRIÇÃO,OBS,TIPO,TRAT,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,DESCRIÇÃO,OBS,TIPO,TRAT,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CLASSIF where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into CLIENTE_T (NOME,NOTIFIC_EMAIL,OBRIGATÓRIO,ORDEM,REQ_DEPTO,REQ_PROJETO,REQ_USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select NOME,NOTIFIC_EMAIL,OBRIGATÓRIO,ORDEM,REQ_DEPTO,REQ_PROJETO,REQ_USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CLIENTE where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into CONJ_REL_T (ARQ,CLIENTE,DEFINIÇÃO,DEPTO,DUR_MIN,GRUPO_PROJETO,LOG,MÁQUINA,NOME_ARQ,NOTIFIC_AOCLIENTE,NOTIFIC_AODEPTO,NOTIFIC_AOTÉCNICO,NOTIFIC_AOUSUÁRIO,NOTIFIC_EMAIL,NOTIFIC_IMEDIATO,PERÍODO_ATÉ,PERÍODO_DE,QUEBRA_USU,RELATÓRIOS,SEQ,TÉCNICO,TIPO_HORA,TIPO_TAREFA,USUÁRIO,DATA_ACUMULA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ARQ,CLIENTE,DEFINIÇÃO,DEPTO,DUR_MIN,GRUPO_PROJETO,LOG,MÁQUINA,NOME_ARQ,NOTIFIC_AOCLIENTE,NOTIFIC_AODEPTO,NOTIFIC_AOTÉCNICO,NOTIFIC_AOUSUÁRIO,NOTIFIC_EMAIL,NOTIFIC_IMEDIATO,PERÍODO_ATÉ,PERÍODO_DE,QUEBRA_USU,RELATÓRIOS,SEQ,TÉCNICO,TIPO_HORA,TIPO_TAREFA,USUÁRIO,DATA_ACUMULA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CONJ_REL where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into CONTA_T (CONTA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CONTA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CONTA where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into CONTATO_T (CLASSE,CONTATO,EMAIL,EMPRESA,ENDEREÇO,FAX,OBS,SEQ,TELEFONE,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CONTATO,EMAIL,EMPRESA,ENDEREÇO,FAX,OBS,SEQ,TELEFONE,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CONTATO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into HIERARQUIA_T (CLASSE,CLASSIF,CLIENTE,LISTA,SUPER,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CLASSIF,CLIENTE,LISTA,SUPER,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from HIERARQUIA where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into LICENÇA_T (CÓDIGO,OBS,RECURSO,SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CÓDIGO,OBS,RECURSO,SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from LICENÇA where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into MOVIMENTO_T (CLASSE,CONTA,CONTROLE,DATA,ENTRADA,EVENTO,HISTÓRICO,MARCA,OBS,OPERADOR,PENDÊNCIA,PREV,REF,SAÍDA,SEQ,SÓCIO,VINC_CONTA,VINC_SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CONTA,CONTROLE,DATA,ENTRADA,EVENTO,HISTÓRICO,MARCA,OBS,OPERADOR,PENDÊNCIA,PREV,REF,SAÍDA,SEQ,SÓCIO,VINC_CONTA,VINC_SEQ,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from MOVIMENTO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into REALIZADO_COM_DURAÇÃO_STAT_T (TÉCNICO,INI,SEQ,TAREFA,TIPO,CLIENTE,DEPTO,USUÁRIO,OBS,PROJETO,CHAMADO_DATA,GRUPO,LISTA,ATENDIM_INÍCIO,ATENDIM_DATE,PROX_INI,ATENDIM_DUR,DUR,ATENDIM_MAX,ATENDIM_MIN,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select TÉCNICO,INI,SEQ,TAREFA,TIPO,CLIENTE,DEPTO,USUÁRIO,OBS,PROJETO,CHAMADO_DATA,GRUPO,LISTA,ATENDIM_INÍCIO,ATENDIM_DATE,PROX_INI,ATENDIM_DUR,DUR,ATENDIM_MAX,ATENDIM_MIN,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from REALIZADO_COM_DURAÇÃO_STAT where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into TABELA_SÓCIO_T (PERÍODO,SÓCIO,VALOR,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select PERÍODO,SÓCIO,VALOR,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TABELA_SÓCIO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into TIPO_RECURSO_T (TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TIPO_RECURSO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into TIPO_SERVIÇO_T (TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TIPO_SERVIÇO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into TAREFA_DEF_T (CLIENTE,COMENTÁRIOS,DEPTO,DETALHE,FATO,GRUPOS,OBS,P_APLICATIVO,PROJETO,TAREFA,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,COMENTÁRIOS,DEPTO,DETALHE,FATO,GRUPOS,OBS,P_APLICATIVO,PROJETO,TAREFA,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TAREFA_DEF where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into TIPO_IDENTIF_T (TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TIPO_IDENTIF where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into TIPO_TAREFA_T (DESCR,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select DESCR,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TIPO_TAREFA where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into TÉCNICO_T (CLASSIFIC,EMAIL_TÉCNICO,SEC_ID,TÉCNICO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSIFIC,EMAIL_TÉCNICO,SEC_ID,TÉCNICO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from TÉCNICO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into ACESSO_T (LOGIN,CLIENTE,DEPTO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select LOGIN,CLIENTE,DEPTO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from ACESSO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into SERVIÇO_T (BKP_DIR_CONSOL,BKP_DIR_LOCAL,BKP_NOTIFICAR,BKP_PROG_RETEM,CLIENTE,DESCRIÇÃO,DESENVOLVEDOR,LOCALIZAÇÃO,SERVIÇO,SUPORTE,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select BKP_DIR_CONSOL,BKP_DIR_LOCAL,BKP_NOTIFICAR,BKP_PROG_RETEM,CLIENTE,DESCRIÇÃO,DESENVOLVEDOR,LOCALIZAÇÃO,SERVIÇO,SUPORTE,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from SERVIÇO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into PATCH_T (CLIENTE,PATCH,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,PATCH,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from PATCH where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into REDE_T (CLIENTE,ENDEREÇO,MÁSCARA,OBS,REDE,SUBNET_AUTO,SUBNET_PARAM,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,ENDEREÇO,MÁSCARA,OBS,REDE,SUBNET_AUTO,SUBNET_PARAM,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from REDE where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into CONJ_IMPRESS_T (ARQUIVO,DEFINIÇÃO,DEFINIÇÃO_SEQ,FILTRO,GERAÇÃO_MOMENTO,IMPRESSÃO_MOMENTO,ITEM,NOTIFIC_EMAIL,NOTIFIC_MOMENTO,REL,RESULT,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ARQUIVO,DEFINIÇÃO,DEFINIÇÃO_SEQ,FILTRO,GERAÇÃO_MOMENTO,IMPRESSÃO_MOMENTO,ITEM,NOTIFIC_EMAIL,NOTIFIC_MOMENTO,REL,RESULT,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CONJ_IMPRESS where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into RECURSO_T (LOCALIZAÇÃO,OBS,RECURSO,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select LOCALIZAÇÃO,OBS,RECURSO,TIPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from RECURSO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into DEPTO_T (CLIENTE,DEPTO,MARCA,NOTIFIC_EMAIL,SITUAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,DEPTO,MARCA,NOTIFIC_EMAIL,SITUAÇÃO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from DEPTO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into CD_T (CLASSE,CONTEÚDO,DATA,ID,MOMENTO,NUM,TÍTULO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLASSE,CONTEÚDO,DATA,ID,MOMENTO,NUM,TÍTULO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CD where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into PONTO_T (ATUAL_UTILIZAÇÃO,CLIENTE,LOCALIZAÇÃO,PATCH,PONTO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ATUAL_UTILIZAÇÃO,CLIENTE,LOCALIZAÇÃO,PATCH,PONTO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from PONTO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into USUÁRIO_T (SEC_ID,CLIENTE,DEPTO,DESLIGAMENTO,NOTIFIC_EMAIL,SITUAÇÃO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select SEC_ID,CLIENTE,DEPTO,DESLIGAMENTO,NOTIFIC_EMAIL,SITUAÇÃO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from USUÁRIO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into IDENTIF_T (CLIENTE,IDENTIF,OBS,SEC_ID,SENHA,SENHA2,TIPO_IDENTIF,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,IDENTIF,OBS,SEC_ID,SENHA,SENHA2,TIPO_IDENTIF,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from IDENTIF where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into MÁQUINA_T (CLIENTE,MÁQUINA,OBS,SEC_ID,SENHA,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,MÁQUINA,OBS,SEC_ID,SENHA,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from MÁQUINA where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into MÁQUINA_RECURSO_T (CLIENTE,COMPLEMENTO,MÁQUINA,RECURSO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,COMPLEMENTO,MÁQUINA,RECURSO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from MÁQUINA_RECURSO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into IP_T (CLIENTE,DNS,IP,MAC,MÁQUINA,OBS,REDE_CLIENTE,REDE_IDENTIF,ROTEADOR,SUBNET_HOST_ID,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,DNS,IP,MAC,MÁQUINA,OBS,REDE_CLIENTE,REDE_IDENTIF,ROTEADOR,SUBNET_HOST_ID,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from IP where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into CRONOGRAMA_T (CLIENTE,CONFIRMAÇÃO,CONFIRMAÇÃO_ADM,CONFIRMADOR,CONSOLID,CONTÍNUA,CRIAÇÃO,CRIADOR_ADM,DELEGAÇÃO,DESENVOLVEDOR,DURAÇÃO,ETAPA,NOVA_OBS,NOVA_PREV,OBS,OBS_ADM,PAI_SEQ,PREVISÃO,PREVISÃO_ADM,PROJETO,REALIZAÇÃO,SEQ,SEQ_N,SUPORTE,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,CONFIRMAÇÃO,CONFIRMAÇÃO_ADM,CONFIRMADOR,CONSOLID,CONTÍNUA,CRIAÇÃO,CRIADOR_ADM,DELEGAÇÃO,DESENVOLVEDOR,DURAÇÃO,ETAPA,NOVA_OBS,NOVA_PREV,OBS,OBS_ADM,PAI_SEQ,PREVISÃO,PREVISÃO_ADM,PROJETO,REALIZAÇÃO,SEQ,SEQ_N,SUPORTE,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from CRONOGRAMA where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into GRUPO_T (CLIENTE,DEPENDE,GRUPO,ORDEM,SUPERGRUPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,DEPENDE,GRUPO,ORDEM,SUPERGRUPO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from GRUPO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into PROJETO_T (CLIENTE,DESENVOLVEDOR,GRUPO,OBS,ORDEM,PROJETO,STATUS,SUPORTE,DESENVOLVEDOR2,SUPORTE2,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select CLIENTE,DESENVOLVEDOR,GRUPO,OBS,ORDEM,PROJETO,STATUS,SUPORTE,DESENVOLVEDOR2,SUPORTE2,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from PROJETO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into REALIZADO_T (ATENDIM_FIM,ATENDIM_INÍCIO,CHAMADO_DATA,CLIENTE,DEPTO,INI,OBS,PROJETO,SEQ,TAREFA,TÉCNICO,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ATENDIM_FIM,ATENDIM_INÍCIO,CHAMADO_DATA,CLIENTE,DEPTO,INI,OBS,PROJETO,SEQ,TAREFA,TÉCNICO,TIPO,USUÁRIO,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from REALIZADO where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

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
                                        err := DBMS_CX.DOSSHELL('sendmail -f cxrj@xxxxxxxxx.com.br -t ' || replace(email, ';', ' -t ') || ' -a "' ||
                                        diretorio || '\' || arqpac || '.ARJ' || '" -a "D:\CXRJ_T\' || arqpac || '.LOG" -s "CIEX - Transferência do pacote ' ||
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
                                err := sendmail('cxrj@xxxxxxxxx.com.br', email, 'CIEX - Rotina de criação de pacote', servsmtp, 'Erro durante a criação do pacote.', diretorio || '\' || arqpac || '.LOG');
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
                                                err := sendmail('cxrj@xxxxxxxxx.com.br', email, 'CIEX - Rotina de tratamento de pacote', servsmtp, 'O sistema não está conseguindo tratar pacotes devido às estruturas temporárias estarem bloqueadas por mais de 6 horas (modelo = 2).');
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
                        delete from CRONOGRAMA_T;
                        delete from MOVIMENTO_PREV_T;
                        delete from CLASSIF_T;
                        delete from CONJ_IMPRESS_T;
                        delete from CONTA_T;
                        delete from CONTATO_T;
                        delete from HIERARQUIA_T;
                        delete from IDENTIF_T;
                        delete from IP_T;
                        delete from LICENÇA_T;
                        delete from MÁQUINA_RECURSO_T;
                        delete from CD_T;
                        delete from MOVIMENTO_T;
                        delete from REALIZADO_COM_DURAÇÃO_STAT_T;
                        delete from PONTO_T;
                        delete from TAREFA_DEF_T;
                        delete from REALIZADO_T;
                        delete from SERVIÇO_T;
                        delete from SYS_DELETE_T;
                        delete from TABELA_SÓCIO_T;
                        delete from ACESSO_T;
                        delete from CONJ_REL_T;
                        delete from TIPO_TAREFA_T;
                        delete from TIPO_SERVIÇO_T;
                        delete from PATCH_T;
                        delete from CLASSE_T;
                        delete from PROJETO_T;
                        delete from TIPO_IDENTIF_T;
                        delete from MÁQUINA_T;
                        delete from REDE_T;
                        delete from RECURSO_T;
                        delete from TIPO_RECURSO_T;
                        delete from USUÁRIO_T;
                        delete from TÉCNICO_T;
                        delete from DEPTO_T;
                        delete from CLIENTE_T;
                        delete from GRUPO_T;
                        COMMIT;

                        log(reglog, 'Importando informações do pacote.');
                        err := DBMS_CX.DOSSHELL('imp.exe ' || localpac || '/' || senhalocal || '@' || servicolocal || ' FILE=' || diretorio || '\' || arqpac_remoto || '.PAC' || ' LOG=' || diretorio || '\RECEB.TMP PARFILE=' || diretorio || '\' || 'RECEB.PAR TOUSER=CXRJ');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando imp.exe');
                        end if;
                        loga(reglog, diretorio, 'RECEB.TMP');

                        log(reglog, 'Tratando inclusões e alterações.');

                        -- tratando inclusões e alterações da tabela MOVIMENTO_PREV
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CONTA, SEQ, ÚLTIMA_DATA, PERÍODO_REF, DATA_REF, SAÍDA, ENTRADA, INCREM_DIA, INCREM_MÊS, INCREM_ANO, VEZES, HISTÓRICO, CLASSE, EVENTO, PENDÊNCIA, OPERADOR, VINC_CONTA, VINC_SEQ, CONTROLE, OBS, SÓCIO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.MOVIMENTO_PREV_T T;
                                        reg CXRJ.MOVIMENTO_PREV%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.MOVIMENTO_PREV T where T.CONTA = cur.CONTA and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into MOVIMENTO_PREV (CONTA, SEQ, ÚLTIMA_DATA, PERÍODO_REF, DATA_REF, SAÍDA, ENTRADA, INCREM_DIA, INCREM_MÊS, INCREM_ANO, VEZES, HISTÓRICO, CLASSE, EVENTO, PENDÊNCIA, OPERADOR, VINC_CONTA, VINC_SEQ, CONTROLE, OBS, SÓCIO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CONTA, cur.SEQ, cur.ÚLTIMA_DATA, cur.PERÍODO_REF, cur.DATA_REF, cur.SAÍDA, cur.ENTRADA, cur.INCREM_DIA, cur.INCREM_MÊS, cur.INCREM_ANO, cur.VEZES, cur.HISTÓRICO, cur.CLASSE, cur.EVENTO, cur.PENDÊNCIA, cur.OPERADOR, cur.VINC_CONTA, cur.VINC_SEQ, cur.CONTROLE, cur.OBS, cur.SÓCIO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg MOVIMENTO_PREV: ' || cur.CONTA || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg MOVIMENTO_PREV inexistente: ' || cur.CONTA || cur.SEQ || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg MOVIMENTO_PREV já manipulado localmente: ' || cur.CONTA || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg MOVIMENTO_PREV já existente e manipulado localmente: ' || cur.CONTA || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.MOVIMENTO_PREV t set T.ÚLTIMA_DATA = cur.ÚLTIMA_DATA, T.PERÍODO_REF = cur.PERÍODO_REF, T.DATA_REF = cur.DATA_REF, T.SAÍDA = cur.SAÍDA, T.ENTRADA = cur.ENTRADA, T.INCREM_DIA = cur.INCREM_DIA, T.INCREM_MÊS = cur.INCREM_MÊS, T.INCREM_ANO = cur.INCREM_ANO, T.VEZES = cur.VEZES, T.HISTÓRICO = cur.HISTÓRICO, T.CLASSE = cur.CLASSE, T.EVENTO = cur.EVENTO, T.PENDÊNCIA = cur.PENDÊNCIA, T.OPERADOR = cur.OPERADOR, T.VINC_CONTA = cur.VINC_CONTA, T.VINC_SEQ = cur.VINC_SEQ, T.CONTROLE = cur.CONTROLE, T.OBS = cur.OBS, T.SÓCIO = cur.SÓCIO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CONTA = cur.CONTA and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg MOVIMENTO_PREV: ' || cur.CONTA || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg MOVIMENTO_PREV com data local igual ou mais atual: ' || cur.CONTA || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg MOVIMENTO_PREV já existente e com data local igual ou mais atual: ' || cur.CONTA || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela MOVIMENTO_PREV - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CLASSE
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select NOME, PREF, LOC, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.CLASSE_T T;
                                        reg CXRJ.CLASSE%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.CLASSE T where T.NOME = cur.NOME;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CLASSE (NOME, PREF, LOC, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.NOME, cur.PREF, cur.LOC, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CLASSE: ' || cur.NOME || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CLASSE inexistente: ' || cur.NOME || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CLASSE já manipulado localmente: ' || cur.NOME || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CLASSE já existente e manipulado localmente: ' || cur.NOME || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.CLASSE t set T.PREF = cur.PREF, T.LOC = cur.LOC, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.NOME = cur.NOME;
                                                                        log(reglog, '> Atualização realizada do reg CLASSE: ' || cur.NOME || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CLASSE com data local igual ou mais atual: ' || cur.NOME || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CLASSE já existente e com data local igual ou mais atual: ' || cur.NOME || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CLASSE - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CLASSIF
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLASSE, TRAT, DESCRIÇÃO, OBS, TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.CLASSIF_T T;
                                        reg CXRJ.CLASSIF%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.CLASSIF T where T.CLASSE = cur.CLASSE;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CLASSIF (CLASSE, TRAT, DESCRIÇÃO, OBS, TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLASSE, cur.TRAT, cur.DESCRIÇÃO, cur.OBS, cur.TIPO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CLASSIF: ' || cur.CLASSE || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CLASSIF inexistente: ' || cur.CLASSE || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CLASSIF já manipulado localmente: ' || cur.CLASSE || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CLASSIF já existente e manipulado localmente: ' || cur.CLASSE || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.CLASSIF t set T.TRAT = cur.TRAT, T.DESCRIÇÃO = cur.DESCRIÇÃO, T.OBS = cur.OBS, T.TIPO = cur.TIPO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLASSE = cur.CLASSE;
                                                                        log(reglog, '> Atualização realizada do reg CLASSIF: ' || cur.CLASSE || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CLASSIF com data local igual ou mais atual: ' || cur.CLASSE || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CLASSIF já existente e com data local igual ou mais atual: ' || cur.CLASSE || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CLASSIF - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CLIENTE
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select NOME, OBRIGATÓRIO, ORDEM, REQ_DEPTO, REQ_USUÁRIO, REQ_PROJETO, NOTIFIC_EMAIL, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.CLIENTE_T T;
                                        reg CXRJ.CLIENTE%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.CLIENTE T where T.NOME = cur.NOME;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CLIENTE (NOME, OBRIGATÓRIO, ORDEM, REQ_DEPTO, REQ_USUÁRIO, REQ_PROJETO, NOTIFIC_EMAIL, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.NOME, cur.OBRIGATÓRIO, cur.ORDEM, cur.REQ_DEPTO, cur.REQ_USUÁRIO, cur.REQ_PROJETO, cur.NOTIFIC_EMAIL, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CLIENTE: ' || cur.NOME || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CLIENTE inexistente: ' || cur.NOME || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CLIENTE já manipulado localmente: ' || cur.NOME || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CLIENTE já existente e manipulado localmente: ' || cur.NOME || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.CLIENTE t set T.OBRIGATÓRIO = cur.OBRIGATÓRIO, T.ORDEM = cur.ORDEM, T.REQ_DEPTO = cur.REQ_DEPTO, T.REQ_USUÁRIO = cur.REQ_USUÁRIO, T.REQ_PROJETO = cur.REQ_PROJETO, T.NOTIFIC_EMAIL = cur.NOTIFIC_EMAIL, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.NOME = cur.NOME;
                                                                        log(reglog, '> Atualização realizada do reg CLIENTE: ' || cur.NOME || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CLIENTE com data local igual ou mais atual: ' || cur.NOME || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CLIENTE já existente e com data local igual ou mais atual: ' || cur.NOME || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CLIENTE - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CONJ_REL
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select DEFINIÇÃO, SEQ, TÉCNICO, CLIENTE, DEPTO, USUÁRIO, GRUPO_PROJETO, TIPO_TAREFA, MÁQUINA, PERÍODO_DE, PERÍODO_ATÉ, DUR_MIN, RELATÓRIOS, NOME_ARQ, ARQ, TIPO_HORA, QUEBRA_USU, NOTIFIC_IMEDIATO, NOTIFIC_EMAIL, NOTIFIC_AOCLIENTE, NOTIFIC_AODEPTO, NOTIFIC_AOUSUÁRIO, NOTIFIC_AOTÉCNICO, LOG, DATA_ACUMULA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.CONJ_REL_T T;
                                        reg CXRJ.CONJ_REL%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.CONJ_REL T where T.DEFINIÇÃO = cur.DEFINIÇÃO and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CONJ_REL (DEFINIÇÃO, SEQ, TÉCNICO, CLIENTE, DEPTO, USUÁRIO, GRUPO_PROJETO, TIPO_TAREFA, MÁQUINA, PERÍODO_DE, PERÍODO_ATÉ, DUR_MIN, RELATÓRIOS, NOME_ARQ, ARQ, TIPO_HORA, QUEBRA_USU, NOTIFIC_IMEDIATO, NOTIFIC_EMAIL, NOTIFIC_AOCLIENTE, NOTIFIC_AODEPTO, NOTIFIC_AOUSUÁRIO, NOTIFIC_AOTÉCNICO, LOG, DATA_ACUMULA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.DEFINIÇÃO, cur.SEQ, cur.TÉCNICO, cur.CLIENTE, cur.DEPTO, cur.USUÁRIO, cur.GRUPO_PROJETO, cur.TIPO_TAREFA, cur.MÁQUINA, cur.PERÍODO_DE, cur.PERÍODO_ATÉ, cur.DUR_MIN, cur.RELATÓRIOS, cur.NOME_ARQ, cur.ARQ, cur.TIPO_HORA, cur.QUEBRA_USU, cur.NOTIFIC_IMEDIATO, cur.NOTIFIC_EMAIL, cur.NOTIFIC_AOCLIENTE, cur.NOTIFIC_AODEPTO, cur.NOTIFIC_AOUSUÁRIO, cur.NOTIFIC_AOTÉCNICO, cur.LOG, cur.DATA_ACUMULA, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CONJ_REL: ' || cur.DEFINIÇÃO || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CONJ_REL inexistente: ' || cur.DEFINIÇÃO || cur.SEQ || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CONJ_REL já manipulado localmente: ' || cur.DEFINIÇÃO || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CONJ_REL já existente e manipulado localmente: ' || cur.DEFINIÇÃO || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.CONJ_REL t set T.TÉCNICO = cur.TÉCNICO, T.CLIENTE = cur.CLIENTE, T.DEPTO = cur.DEPTO, T.USUÁRIO = cur.USUÁRIO, T.GRUPO_PROJETO = cur.GRUPO_PROJETO, T.TIPO_TAREFA = cur.TIPO_TAREFA, T.MÁQUINA = cur.MÁQUINA, T.PERÍODO_DE = cur.PERÍODO_DE, T.PERÍODO_ATÉ = cur.PERÍODO_ATÉ, T.DUR_MIN = cur.DUR_MIN, T.RELATÓRIOS = cur.RELATÓRIOS, T.NOME_ARQ = cur.NOME_ARQ, T.ARQ = cur.ARQ, T.TIPO_HORA = cur.TIPO_HORA, T.QUEBRA_USU = cur.QUEBRA_USU, T.NOTIFIC_IMEDIATO = cur.NOTIFIC_IMEDIATO, T.NOTIFIC_EMAIL = cur.NOTIFIC_EMAIL, T.NOTIFIC_AOCLIENTE = cur.NOTIFIC_AOCLIENTE, T.NOTIFIC_AODEPTO = cur.NOTIFIC_AODEPTO, T.NOTIFIC_AOUSUÁRIO = cur.NOTIFIC_AOUSUÁRIO, T.NOTIFIC_AOTÉCNICO = cur.NOTIFIC_AOTÉCNICO, T.LOG = cur.LOG, T.DATA_ACUMULA = cur.DATA_ACUMULA, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.DEFINIÇÃO = cur.DEFINIÇÃO and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg CONJ_REL: ' || cur.DEFINIÇÃO || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CONJ_REL com data local igual ou mais atual: ' || cur.DEFINIÇÃO || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CONJ_REL já existente e com data local igual ou mais atual: ' || cur.DEFINIÇÃO || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CONJ_REL - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CONTA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CONTA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.CONTA_T T;
                                        reg CXRJ.CONTA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.CONTA T where T.CONTA = cur.CONTA;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CONTA (CONTA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CONTA, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CONTA: ' || cur.CONTA || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CONTA inexistente: ' || cur.CONTA || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CONTA já manipulado localmente: ' || cur.CONTA || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CONTA já existente e manipulado localmente: ' || cur.CONTA || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.CONTA t set T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CONTA = cur.CONTA;
                                                                        log(reglog, '> Atualização realizada do reg CONTA: ' || cur.CONTA || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CONTA com data local igual ou mais atual: ' || cur.CONTA || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CONTA já existente e com data local igual ou mais atual: ' || cur.CONTA || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CONTA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CONTATO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select SEQ, EMPRESA, CONTATO, TELEFONE, FAX, EMAIL, ENDEREÇO, OBS, CLASSE, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.CONTATO_T T;
                                        reg CXRJ.CONTATO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.CONTATO T where T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CONTATO (SEQ, EMPRESA, CONTATO, TELEFONE, FAX, EMAIL, ENDEREÇO, OBS, CLASSE, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.SEQ, cur.EMPRESA, cur.CONTATO, cur.TELEFONE, cur.FAX, cur.EMAIL, cur.ENDEREÇO, cur.OBS, cur.CLASSE, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CONTATO: ' || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CONTATO inexistente: ' || cur.SEQ || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CONTATO já manipulado localmente: ' || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CONTATO já existente e manipulado localmente: ' || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.CONTATO t set T.EMPRESA = cur.EMPRESA, T.CONTATO = cur.CONTATO, T.TELEFONE = cur.TELEFONE, T.FAX = cur.FAX, T.EMAIL = cur.EMAIL, T.ENDEREÇO = cur.ENDEREÇO, T.OBS = cur.OBS, T.CLASSE = cur.CLASSE, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg CONTATO: ' || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CONTATO com data local igual ou mais atual: ' || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CONTATO já existente e com data local igual ou mais atual: ' || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CONTATO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela HIERARQUIA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLIENTE, CLASSIF, CLASSE, SUPER, LISTA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.HIERARQUIA_T T;
                                        reg CXRJ.HIERARQUIA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.HIERARQUIA T where T.CLIENTE = cur.CLIENTE and T.CLASSIF = cur.CLASSIF;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into HIERARQUIA (CLIENTE, CLASSIF, CLASSE, SUPER, LISTA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLIENTE, cur.CLASSIF, cur.CLASSE, cur.SUPER, cur.LISTA, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg HIERARQUIA: ' || cur.CLIENTE || cur.CLASSIF || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg HIERARQUIA inexistente: ' || cur.CLIENTE || cur.CLASSIF || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg HIERARQUIA já manipulado localmente: ' || cur.CLIENTE || cur.CLASSIF || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg HIERARQUIA já existente e manipulado localmente: ' || cur.CLIENTE || cur.CLASSIF || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.HIERARQUIA t set T.CLASSE = cur.CLASSE, T.SUPER = cur.SUPER, T.LISTA = cur.LISTA, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLIENTE = cur.CLIENTE and T.CLASSIF = cur.CLASSIF;
                                                                        log(reglog, '> Atualização realizada do reg HIERARQUIA: ' || cur.CLIENTE || cur.CLASSIF || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg HIERARQUIA com data local igual ou mais atual: ' || cur.CLIENTE || cur.CLASSIF || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg HIERARQUIA já existente e com data local igual ou mais atual: ' || cur.CLIENTE || cur.CLASSIF || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela HIERARQUIA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela LICENÇA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select SEQ, RECURSO, CÓDIGO, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.LICENÇA_T T;
                                        reg CXRJ.LICENÇA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.LICENÇA T where T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into LICENÇA (SEQ, RECURSO, CÓDIGO, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.SEQ, cur.RECURSO, cur.CÓDIGO, cur.OBS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg LICENÇA: ' || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg LICENÇA inexistente: ' || cur.SEQ || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg LICENÇA já manipulado localmente: ' || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg LICENÇA já existente e manipulado localmente: ' || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.LICENÇA t set T.RECURSO = cur.RECURSO, T.CÓDIGO = cur.CÓDIGO, T.OBS = cur.OBS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg LICENÇA: ' || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg LICENÇA com data local igual ou mais atual: ' || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg LICENÇA já existente e com data local igual ou mais atual: ' || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela LICENÇA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela MOVIMENTO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CONTA, SEQ, DATA, REF, SAÍDA, ENTRADA, HISTÓRICO, CLASSE, EVENTO, PENDÊNCIA, OPERADOR, VINC_CONTA, VINC_SEQ, CONTROLE, OBS, PREV, SÓCIO, MARCA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.MOVIMENTO_T T;
                                        reg CXRJ.MOVIMENTO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.MOVIMENTO T where T.CONTA = cur.CONTA and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into MOVIMENTO (CONTA, SEQ, DATA, REF, SAÍDA, ENTRADA, HISTÓRICO, CLASSE, EVENTO, PENDÊNCIA, OPERADOR, VINC_CONTA, VINC_SEQ, CONTROLE, OBS, PREV, SÓCIO, MARCA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CONTA, cur.SEQ, cur.DATA, cur.REF, cur.SAÍDA, cur.ENTRADA, cur.HISTÓRICO, cur.CLASSE, cur.EVENTO, cur.PENDÊNCIA, cur.OPERADOR, cur.VINC_CONTA, cur.VINC_SEQ, cur.CONTROLE, cur.OBS, cur.PREV, cur.SÓCIO, cur.MARCA, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg MOVIMENTO: ' || cur.CONTA || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg MOVIMENTO inexistente: ' || cur.CONTA || cur.SEQ || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg MOVIMENTO já manipulado localmente: ' || cur.CONTA || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg MOVIMENTO já existente e manipulado localmente: ' || cur.CONTA || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.MOVIMENTO t set T.DATA = cur.DATA, T.REF = cur.REF, T.SAÍDA = cur.SAÍDA, T.ENTRADA = cur.ENTRADA, T.HISTÓRICO = cur.HISTÓRICO, T.CLASSE = cur.CLASSE, T.EVENTO = cur.EVENTO, T.PENDÊNCIA = cur.PENDÊNCIA, T.OPERADOR = cur.OPERADOR, T.VINC_CONTA = cur.VINC_CONTA, T.VINC_SEQ = cur.VINC_SEQ, T.CONTROLE = cur.CONTROLE, T.OBS = cur.OBS, T.PREV = cur.PREV, T.SÓCIO = cur.SÓCIO, T.MARCA = cur.MARCA, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CONTA = cur.CONTA and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg MOVIMENTO: ' || cur.CONTA || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg MOVIMENTO com data local igual ou mais atual: ' || cur.CONTA || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg MOVIMENTO já existente e com data local igual ou mais atual: ' || cur.CONTA || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela MOVIMENTO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela REALIZADO_COM_DURAÇÃO_STAT
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select TÉCNICO, INI, SEQ, TAREFA, TIPO, CLIENTE, DEPTO, USUÁRIO, OBS, PROJETO, CHAMADO_DATA, GRUPO, LISTA, ATENDIM_INÍCIO, ATENDIM_DATE, PROX_INI, ATENDIM_DUR, DUR, ATENDIM_MAX, ATENDIM_MIN, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.REALIZADO_COM_DURAÇÃO_STAT_T T;
                                        reg CXRJ.REALIZADO_COM_DURAÇÃO_STAT%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.REALIZADO_COM_DURAÇÃO_STAT T where T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into REALIZADO_COM_DURAÇÃO_STAT (TÉCNICO, INI, SEQ, TAREFA, TIPO, CLIENTE, DEPTO, USUÁRIO, OBS, PROJETO, CHAMADO_DATA, GRUPO, LISTA, ATENDIM_INÍCIO, ATENDIM_DATE, PROX_INI, ATENDIM_DUR, DUR, ATENDIM_MAX, ATENDIM_MIN, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.TÉCNICO, cur.INI, cur.SEQ, cur.TAREFA, cur.TIPO, cur.CLIENTE, cur.DEPTO, cur.USUÁRIO, cur.OBS, cur.PROJETO, cur.CHAMADO_DATA, cur.GRUPO, cur.LISTA, cur.ATENDIM_INÍCIO, cur.ATENDIM_DATE, cur.PROX_INI, cur.ATENDIM_DUR, cur.DUR, cur.ATENDIM_MAX, cur.ATENDIM_MIN, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg REALIZADO_COM_DURAÇÃO_STAT: ' || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg REALIZADO_COM_DURAÇÃO_STAT inexistente: ' || cur.SEQ || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg REALIZADO_COM_DURAÇÃO_STAT já manipulado localmente: ' || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg REALIZADO_COM_DURAÇÃO_STAT já existente e manipulado localmente: ' || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.REALIZADO_COM_DURAÇÃO_STAT t set T.TÉCNICO = cur.TÉCNICO, T.INI = cur.INI, T.TAREFA = cur.TAREFA, T.TIPO = cur.TIPO, T.CLIENTE = cur.CLIENTE, T.DEPTO = cur.DEPTO, T.USUÁRIO = cur.USUÁRIO, T.OBS = cur.OBS, T.PROJETO = cur.PROJETO, T.CHAMADO_DATA = cur.CHAMADO_DATA, T.GRUPO = cur.GRUPO, T.LISTA = cur.LISTA, T.ATENDIM_INÍCIO = cur.ATENDIM_INÍCIO, T.ATENDIM_DATE = cur.ATENDIM_DATE, T.PROX_INI = cur.PROX_INI, T.ATENDIM_DUR = cur.ATENDIM_DUR, T.DUR = cur.DUR, T.ATENDIM_MAX = cur.ATENDIM_MAX, T.ATENDIM_MIN = cur.ATENDIM_MIN, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg REALIZADO_COM_DURAÇÃO_STAT: ' || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg REALIZADO_COM_DURAÇÃO_STAT com data local igual ou mais atual: ' || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg REALIZADO_COM_DURAÇÃO_STAT já existente e com data local igual ou mais atual: ' || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela REALIZADO_COM_DURAÇÃO_STAT - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela TABELA_SÓCIO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select PERÍODO, SÓCIO, VALOR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.TABELA_SÓCIO_T T;
                                        reg CXRJ.TABELA_SÓCIO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.TABELA_SÓCIO T where T.PERÍODO = cur.PERÍODO and T.SÓCIO = cur.SÓCIO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into TABELA_SÓCIO (PERÍODO, SÓCIO, VALOR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.PERÍODO, cur.SÓCIO, cur.VALOR, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg TABELA_SÓCIO: ' || cur.PERÍODO || cur.SÓCIO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg TABELA_SÓCIO inexistente: ' || cur.PERÍODO || cur.SÓCIO || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg TABELA_SÓCIO já manipulado localmente: ' || cur.PERÍODO || cur.SÓCIO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg TABELA_SÓCIO já existente e manipulado localmente: ' || cur.PERÍODO || cur.SÓCIO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.TABELA_SÓCIO t set T.VALOR = cur.VALOR, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.PERÍODO = cur.PERÍODO and T.SÓCIO = cur.SÓCIO;
                                                                        log(reglog, '> Atualização realizada do reg TABELA_SÓCIO: ' || cur.PERÍODO || cur.SÓCIO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg TABELA_SÓCIO com data local igual ou mais atual: ' || cur.PERÍODO || cur.SÓCIO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg TABELA_SÓCIO já existente e com data local igual ou mais atual: ' || cur.PERÍODO || cur.SÓCIO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela TABELA_SÓCIO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela TIPO_RECURSO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.TIPO_RECURSO_T T;
                                        reg CXRJ.TIPO_RECURSO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.TIPO_RECURSO T where T.TIPO = cur.TIPO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into TIPO_RECURSO (TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.TIPO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg TIPO_RECURSO: ' || cur.TIPO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg TIPO_RECURSO inexistente: ' || cur.TIPO || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg TIPO_RECURSO já manipulado localmente: ' || cur.TIPO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg TIPO_RECURSO já existente e manipulado localmente: ' || cur.TIPO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.TIPO_RECURSO t set T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.TIPO = cur.TIPO;
                                                                        log(reglog, '> Atualização realizada do reg TIPO_RECURSO: ' || cur.TIPO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg TIPO_RECURSO com data local igual ou mais atual: ' || cur.TIPO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg TIPO_RECURSO já existente e com data local igual ou mais atual: ' || cur.TIPO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela TIPO_RECURSO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela TIPO_SERVIÇO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.TIPO_SERVIÇO_T T;
                                        reg CXRJ.TIPO_SERVIÇO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.TIPO_SERVIÇO T where T.TIPO = cur.TIPO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into TIPO_SERVIÇO (TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.TIPO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg TIPO_SERVIÇO: ' || cur.TIPO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg TIPO_SERVIÇO inexistente: ' || cur.TIPO || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg TIPO_SERVIÇO já manipulado localmente: ' || cur.TIPO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg TIPO_SERVIÇO já existente e manipulado localmente: ' || cur.TIPO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.TIPO_SERVIÇO t set T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.TIPO = cur.TIPO;
                                                                        log(reglog, '> Atualização realizada do reg TIPO_SERVIÇO: ' || cur.TIPO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg TIPO_SERVIÇO com data local igual ou mais atual: ' || cur.TIPO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg TIPO_SERVIÇO já existente e com data local igual ou mais atual: ' || cur.TIPO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela TIPO_SERVIÇO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela TAREFA_DEF
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select TAREFA, DETALHE, OBS, TIPO, CLIENTE, DEPTO, USUÁRIO, PROJETO, FATO, P_APLICATIVO, GRUPOS, COMENTÁRIOS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.TAREFA_DEF_T T;
                                        reg CXRJ.TAREFA_DEF%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.TAREFA_DEF T where T.TAREFA = cur.TAREFA;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into TAREFA_DEF (TAREFA, DETALHE, OBS, TIPO, CLIENTE, DEPTO, USUÁRIO, PROJETO, FATO, P_APLICATIVO, GRUPOS, COMENTÁRIOS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.TAREFA, cur.DETALHE, cur.OBS, cur.TIPO, cur.CLIENTE, cur.DEPTO, cur.USUÁRIO, cur.PROJETO, cur.FATO, cur.P_APLICATIVO, cur.GRUPOS, cur.COMENTÁRIOS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg TAREFA_DEF: ' || cur.TAREFA || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg TAREFA_DEF inexistente: ' || cur.TAREFA || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg TAREFA_DEF já manipulado localmente: ' || cur.TAREFA || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg TAREFA_DEF já existente e manipulado localmente: ' || cur.TAREFA || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.TAREFA_DEF t set T.DETALHE = cur.DETALHE, T.OBS = cur.OBS, T.TIPO = cur.TIPO, T.CLIENTE = cur.CLIENTE, T.DEPTO = cur.DEPTO, T.USUÁRIO = cur.USUÁRIO, T.PROJETO = cur.PROJETO, T.FATO = cur.FATO, T.P_APLICATIVO = cur.P_APLICATIVO, T.GRUPOS = cur.GRUPOS, T.COMENTÁRIOS = cur.COMENTÁRIOS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.TAREFA = cur.TAREFA;
                                                                        log(reglog, '> Atualização realizada do reg TAREFA_DEF: ' || cur.TAREFA || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg TAREFA_DEF com data local igual ou mais atual: ' || cur.TAREFA || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg TAREFA_DEF já existente e com data local igual ou mais atual: ' || cur.TAREFA || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela TAREFA_DEF - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela TIPO_IDENTIF
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.TIPO_IDENTIF_T T;
                                        reg CXRJ.TIPO_IDENTIF%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.TIPO_IDENTIF T where T.TIPO = cur.TIPO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into TIPO_IDENTIF (TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.TIPO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg TIPO_IDENTIF: ' || cur.TIPO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg TIPO_IDENTIF inexistente: ' || cur.TIPO || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg TIPO_IDENTIF já manipulado localmente: ' || cur.TIPO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg TIPO_IDENTIF já existente e manipulado localmente: ' || cur.TIPO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.TIPO_IDENTIF t set T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.TIPO = cur.TIPO;
                                                                        log(reglog, '> Atualização realizada do reg TIPO_IDENTIF: ' || cur.TIPO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg TIPO_IDENTIF com data local igual ou mais atual: ' || cur.TIPO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg TIPO_IDENTIF já existente e com data local igual ou mais atual: ' || cur.TIPO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela TIPO_IDENTIF - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela TIPO_TAREFA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select TIPO, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.TIPO_TAREFA_T T;
                                        reg CXRJ.TIPO_TAREFA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.TIPO_TAREFA T where T.TIPO = cur.TIPO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into TIPO_TAREFA (TIPO, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.TIPO, cur.DESCR, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg TIPO_TAREFA: ' || cur.TIPO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg TIPO_TAREFA inexistente: ' || cur.TIPO || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg TIPO_TAREFA já manipulado localmente: ' || cur.TIPO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg TIPO_TAREFA já existente e manipulado localmente: ' || cur.TIPO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.TIPO_TAREFA t set T.DESCR = cur.DESCR, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.TIPO = cur.TIPO;
                                                                        log(reglog, '> Atualização realizada do reg TIPO_TAREFA: ' || cur.TIPO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg TIPO_TAREFA com data local igual ou mais atual: ' || cur.TIPO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg TIPO_TAREFA já existente e com data local igual ou mais atual: ' || cur.TIPO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela TIPO_TAREFA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela TÉCNICO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLASSIFIC, TÉCNICO, SEC_ID, EMAIL_TÉCNICO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.TÉCNICO_T T;
                                        reg CXRJ.TÉCNICO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.TÉCNICO T where T.TÉCNICO = cur.TÉCNICO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into TÉCNICO (CLASSIFIC, TÉCNICO, SEC_ID, EMAIL_TÉCNICO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLASSIFIC, cur.TÉCNICO, cur.SEC_ID, cur.EMAIL_TÉCNICO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg TÉCNICO: ' || cur.TÉCNICO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg TÉCNICO inexistente: ' || cur.TÉCNICO || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg TÉCNICO já manipulado localmente: ' || cur.TÉCNICO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg TÉCNICO já existente e manipulado localmente: ' || cur.TÉCNICO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.TÉCNICO t set T.CLASSIFIC = cur.CLASSIFIC, T.SEC_ID = cur.SEC_ID, T.EMAIL_TÉCNICO = cur.EMAIL_TÉCNICO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.TÉCNICO = cur.TÉCNICO;
                                                                        log(reglog, '> Atualização realizada do reg TÉCNICO: ' || cur.TÉCNICO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg TÉCNICO com data local igual ou mais atual: ' || cur.TÉCNICO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg TÉCNICO já existente e com data local igual ou mais atual: ' || cur.TÉCNICO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela TÉCNICO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela ACESSO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select LOGIN, CLIENTE, DEPTO, USUÁRIO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.ACESSO_T T;
                                        reg CXRJ.ACESSO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.ACESSO T where T.LOGIN = cur.LOGIN;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into ACESSO (LOGIN, CLIENTE, DEPTO, USUÁRIO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.LOGIN, cur.CLIENTE, cur.DEPTO, cur.USUÁRIO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg ACESSO: ' || cur.LOGIN || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg ACESSO inexistente: ' || cur.LOGIN || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg ACESSO já manipulado localmente: ' || cur.LOGIN || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg ACESSO já existente e manipulado localmente: ' || cur.LOGIN || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.ACESSO t set T.CLIENTE = cur.CLIENTE, T.DEPTO = cur.DEPTO, T.USUÁRIO = cur.USUÁRIO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.LOGIN = cur.LOGIN;
                                                                        log(reglog, '> Atualização realizada do reg ACESSO: ' || cur.LOGIN || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg ACESSO com data local igual ou mais atual: ' || cur.LOGIN || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg ACESSO já existente e com data local igual ou mais atual: ' || cur.LOGIN || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela ACESSO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela SERVIÇO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLIENTE, SERVIÇO, DESCRIÇÃO, TIPO, LOCALIZAÇÃO, DESENVOLVEDOR, SUPORTE, BKP_DIR_LOCAL, BKP_DIR_CONSOL, BKP_PROG_RETEM, BKP_NOTIFICAR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.SERVIÇO_T T;
                                        reg CXRJ.SERVIÇO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.SERVIÇO T where T.CLIENTE = cur.CLIENTE and T.SERVIÇO = cur.SERVIÇO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into SERVIÇO (CLIENTE, SERVIÇO, DESCRIÇÃO, TIPO, LOCALIZAÇÃO, DESENVOLVEDOR, SUPORTE, BKP_DIR_LOCAL, BKP_DIR_CONSOL, BKP_PROG_RETEM, BKP_NOTIFICAR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLIENTE, cur.SERVIÇO, cur.DESCRIÇÃO, cur.TIPO, cur.LOCALIZAÇÃO, cur.DESENVOLVEDOR, cur.SUPORTE, cur.BKP_DIR_LOCAL, cur.BKP_DIR_CONSOL, cur.BKP_PROG_RETEM, cur.BKP_NOTIFICAR, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg SERVIÇO: ' || cur.CLIENTE || cur.SERVIÇO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg SERVIÇO inexistente: ' || cur.CLIENTE || cur.SERVIÇO || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg SERVIÇO já manipulado localmente: ' || cur.CLIENTE || cur.SERVIÇO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg SERVIÇO já existente e manipulado localmente: ' || cur.CLIENTE || cur.SERVIÇO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.SERVIÇO t set T.DESCRIÇÃO = cur.DESCRIÇÃO, T.TIPO = cur.TIPO, T.LOCALIZAÇÃO = cur.LOCALIZAÇÃO, T.DESENVOLVEDOR = cur.DESENVOLVEDOR, T.SUPORTE = cur.SUPORTE, T.BKP_DIR_LOCAL = cur.BKP_DIR_LOCAL, T.BKP_DIR_CONSOL = cur.BKP_DIR_CONSOL, T.BKP_PROG_RETEM = cur.BKP_PROG_RETEM, T.BKP_NOTIFICAR = cur.BKP_NOTIFICAR, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLIENTE = cur.CLIENTE and T.SERVIÇO = cur.SERVIÇO;
                                                                        log(reglog, '> Atualização realizada do reg SERVIÇO: ' || cur.CLIENTE || cur.SERVIÇO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg SERVIÇO com data local igual ou mais atual: ' || cur.CLIENTE || cur.SERVIÇO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg SERVIÇO já existente e com data local igual ou mais atual: ' || cur.CLIENTE || cur.SERVIÇO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela SERVIÇO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PATCH
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLIENTE, PATCH, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.PATCH_T T;
                                        reg CXRJ.PATCH%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.PATCH T where T.CLIENTE = cur.CLIENTE and T.PATCH = cur.PATCH;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PATCH (CLIENTE, PATCH, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLIENTE, cur.PATCH, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PATCH: ' || cur.CLIENTE || cur.PATCH || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PATCH inexistente: ' || cur.CLIENTE || cur.PATCH || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PATCH já manipulado localmente: ' || cur.CLIENTE || cur.PATCH || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PATCH já existente e manipulado localmente: ' || cur.CLIENTE || cur.PATCH || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.PATCH t set T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLIENTE = cur.CLIENTE and T.PATCH = cur.PATCH;
                                                                        log(reglog, '> Atualização realizada do reg PATCH: ' || cur.CLIENTE || cur.PATCH || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PATCH com data local igual ou mais atual: ' || cur.CLIENTE || cur.PATCH || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PATCH já existente e com data local igual ou mais atual: ' || cur.CLIENTE || cur.PATCH || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PATCH - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela REDE
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLIENTE, REDE, ENDEREÇO, MÁSCARA, SUBNET_AUTO, SUBNET_PARAM, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.REDE_T T;
                                        reg CXRJ.REDE%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.REDE T where T.CLIENTE = cur.CLIENTE and T.REDE = cur.REDE;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into REDE (CLIENTE, REDE, ENDEREÇO, MÁSCARA, SUBNET_AUTO, SUBNET_PARAM, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLIENTE, cur.REDE, cur.ENDEREÇO, cur.MÁSCARA, cur.SUBNET_AUTO, cur.SUBNET_PARAM, cur.OBS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg REDE: ' || cur.CLIENTE || cur.REDE || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg REDE inexistente: ' || cur.CLIENTE || cur.REDE || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg REDE já manipulado localmente: ' || cur.CLIENTE || cur.REDE || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg REDE já existente e manipulado localmente: ' || cur.CLIENTE || cur.REDE || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.REDE t set T.ENDEREÇO = cur.ENDEREÇO, T.MÁSCARA = cur.MÁSCARA, T.SUBNET_AUTO = cur.SUBNET_AUTO, T.SUBNET_PARAM = cur.SUBNET_PARAM, T.OBS = cur.OBS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLIENTE = cur.CLIENTE and T.REDE = cur.REDE;
                                                                        log(reglog, '> Atualização realizada do reg REDE: ' || cur.CLIENTE || cur.REDE || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg REDE com data local igual ou mais atual: ' || cur.CLIENTE || cur.REDE || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg REDE já existente e com data local igual ou mais atual: ' || cur.CLIENTE || cur.REDE || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela REDE - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CONJ_IMPRESS
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select DEFINIÇÃO, DEFINIÇÃO_SEQ, ITEM, REL, ARQUIVO, FILTRO, GERAÇÃO_MOMENTO, IMPRESSÃO_MOMENTO, NOTIFIC_EMAIL, NOTIFIC_MOMENTO, RESULT, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.CONJ_IMPRESS_T T;
                                        reg CXRJ.CONJ_IMPRESS%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.CONJ_IMPRESS T where T.DEFINIÇÃO = cur.DEFINIÇÃO and T.DEFINIÇÃO_SEQ = cur.DEFINIÇÃO_SEQ and T.ITEM = cur.ITEM;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CONJ_IMPRESS (DEFINIÇÃO, DEFINIÇÃO_SEQ, ITEM, REL, ARQUIVO, FILTRO, GERAÇÃO_MOMENTO, IMPRESSÃO_MOMENTO, NOTIFIC_EMAIL, NOTIFIC_MOMENTO, RESULT, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.DEFINIÇÃO, cur.DEFINIÇÃO_SEQ, cur.ITEM, cur.REL, cur.ARQUIVO, cur.FILTRO, cur.GERAÇÃO_MOMENTO, cur.IMPRESSÃO_MOMENTO, cur.NOTIFIC_EMAIL, cur.NOTIFIC_MOMENTO, cur.RESULT, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CONJ_IMPRESS: ' || cur.DEFINIÇÃO || cur.DEFINIÇÃO_SEQ || cur.ITEM || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CONJ_IMPRESS inexistente: ' || cur.DEFINIÇÃO || cur.DEFINIÇÃO_SEQ || cur.ITEM || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CONJ_IMPRESS já manipulado localmente: ' || cur.DEFINIÇÃO || cur.DEFINIÇÃO_SEQ || cur.ITEM || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CONJ_IMPRESS já existente e manipulado localmente: ' || cur.DEFINIÇÃO || cur.DEFINIÇÃO_SEQ || cur.ITEM || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.CONJ_IMPRESS t set T.REL = cur.REL, T.ARQUIVO = cur.ARQUIVO, T.FILTRO = cur.FILTRO, T.GERAÇÃO_MOMENTO = cur.GERAÇÃO_MOMENTO, T.IMPRESSÃO_MOMENTO = cur.IMPRESSÃO_MOMENTO, T.NOTIFIC_EMAIL = cur.NOTIFIC_EMAIL, T.NOTIFIC_MOMENTO = cur.NOTIFIC_MOMENTO, T.RESULT = cur.RESULT, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.DEFINIÇÃO = cur.DEFINIÇÃO and T.DEFINIÇÃO_SEQ = cur.DEFINIÇÃO_SEQ and T.ITEM = cur.ITEM;
                                                                        log(reglog, '> Atualização realizada do reg CONJ_IMPRESS: ' || cur.DEFINIÇÃO || cur.DEFINIÇÃO_SEQ || cur.ITEM || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CONJ_IMPRESS com data local igual ou mais atual: ' || cur.DEFINIÇÃO || cur.DEFINIÇÃO_SEQ || cur.ITEM || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CONJ_IMPRESS já existente e com data local igual ou mais atual: ' || cur.DEFINIÇÃO || cur.DEFINIÇÃO_SEQ || cur.ITEM || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CONJ_IMPRESS - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela RECURSO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select RECURSO, TIPO, LOCALIZAÇÃO, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.RECURSO_T T;
                                        reg CXRJ.RECURSO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.RECURSO T where T.RECURSO = cur.RECURSO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into RECURSO (RECURSO, TIPO, LOCALIZAÇÃO, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.RECURSO, cur.TIPO, cur.LOCALIZAÇÃO, cur.OBS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg RECURSO: ' || cur.RECURSO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg RECURSO inexistente: ' || cur.RECURSO || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg RECURSO já manipulado localmente: ' || cur.RECURSO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg RECURSO já existente e manipulado localmente: ' || cur.RECURSO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.RECURSO t set T.TIPO = cur.TIPO, T.LOCALIZAÇÃO = cur.LOCALIZAÇÃO, T.OBS = cur.OBS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.RECURSO = cur.RECURSO;
                                                                        log(reglog, '> Atualização realizada do reg RECURSO: ' || cur.RECURSO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg RECURSO com data local igual ou mais atual: ' || cur.RECURSO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg RECURSO já existente e com data local igual ou mais atual: ' || cur.RECURSO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela RECURSO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela DEPTO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLIENTE, DEPTO, MARCA, SITUAÇÃO, NOTIFIC_EMAIL, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.DEPTO_T T;
                                        reg CXRJ.DEPTO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.DEPTO T where T.CLIENTE = cur.CLIENTE and T.DEPTO = cur.DEPTO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into DEPTO (CLIENTE, DEPTO, MARCA, SITUAÇÃO, NOTIFIC_EMAIL, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLIENTE, cur.DEPTO, cur.MARCA, cur.SITUAÇÃO, cur.NOTIFIC_EMAIL, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg DEPTO: ' || cur.CLIENTE || cur.DEPTO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg DEPTO inexistente: ' || cur.CLIENTE || cur.DEPTO || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg DEPTO já manipulado localmente: ' || cur.CLIENTE || cur.DEPTO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg DEPTO já existente e manipulado localmente: ' || cur.CLIENTE || cur.DEPTO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.DEPTO t set T.MARCA = cur.MARCA, T.SITUAÇÃO = cur.SITUAÇÃO, T.NOTIFIC_EMAIL = cur.NOTIFIC_EMAIL, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLIENTE = cur.CLIENTE and T.DEPTO = cur.DEPTO;
                                                                        log(reglog, '> Atualização realizada do reg DEPTO: ' || cur.CLIENTE || cur.DEPTO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg DEPTO com data local igual ou mais atual: ' || cur.CLIENTE || cur.DEPTO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg DEPTO já existente e com data local igual ou mais atual: ' || cur.CLIENTE || cur.DEPTO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela DEPTO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CD
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select ID, NUM, TÍTULO, DATA, CLASSE, CONTEÚDO, USUÁRIO, MOMENTO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.CD_T T;
                                        reg CXRJ.CD%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.CD T where T.ID = cur.ID;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CD (ID, NUM, TÍTULO, DATA, CLASSE, CONTEÚDO, USUÁRIO, MOMENTO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.ID, cur.NUM, cur.TÍTULO, cur.DATA, cur.CLASSE, cur.CONTEÚDO, cur.USUÁRIO, cur.MOMENTO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CD: ' || cur.ID || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CD inexistente: ' || cur.ID || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CD já manipulado localmente: ' || cur.ID || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CD já existente e manipulado localmente: ' || cur.ID || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.CD t set T.NUM = cur.NUM, T.TÍTULO = cur.TÍTULO, T.DATA = cur.DATA, T.CLASSE = cur.CLASSE, T.CONTEÚDO = cur.CONTEÚDO, T.USUÁRIO = cur.USUÁRIO, T.MOMENTO = cur.MOMENTO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.ID = cur.ID;
                                                                        log(reglog, '> Atualização realizada do reg CD: ' || cur.ID || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CD com data local igual ou mais atual: ' || cur.ID || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CD já existente e com data local igual ou mais atual: ' || cur.ID || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CD - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PONTO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLIENTE, PATCH, PONTO, LOCALIZAÇÃO, ATUAL_UTILIZAÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.PONTO_T T;
                                        reg CXRJ.PONTO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.PONTO T where T.CLIENTE = cur.CLIENTE and T.PATCH = cur.PATCH and T.PONTO = cur.PONTO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PONTO (CLIENTE, PATCH, PONTO, LOCALIZAÇÃO, ATUAL_UTILIZAÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLIENTE, cur.PATCH, cur.PONTO, cur.LOCALIZAÇÃO, cur.ATUAL_UTILIZAÇÃO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PONTO: ' || cur.CLIENTE || cur.PATCH || cur.PONTO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PONTO inexistente: ' || cur.CLIENTE || cur.PATCH || cur.PONTO || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PONTO já manipulado localmente: ' || cur.CLIENTE || cur.PATCH || cur.PONTO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PONTO já existente e manipulado localmente: ' || cur.CLIENTE || cur.PATCH || cur.PONTO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.PONTO t set T.LOCALIZAÇÃO = cur.LOCALIZAÇÃO, T.ATUAL_UTILIZAÇÃO = cur.ATUAL_UTILIZAÇÃO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLIENTE = cur.CLIENTE and T.PATCH = cur.PATCH and T.PONTO = cur.PONTO;
                                                                        log(reglog, '> Atualização realizada do reg PONTO: ' || cur.CLIENTE || cur.PATCH || cur.PONTO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PONTO com data local igual ou mais atual: ' || cur.CLIENTE || cur.PATCH || cur.PONTO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PONTO já existente e com data local igual ou mais atual: ' || cur.CLIENTE || cur.PATCH || cur.PONTO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PONTO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela USUÁRIO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLIENTE, USUÁRIO, DEPTO, DESLIGAMENTO, SITUAÇÃO, NOTIFIC_EMAIL, SEC_ID, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.USUÁRIO_T T;
                                        reg CXRJ.USUÁRIO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.USUÁRIO T where T.CLIENTE = cur.CLIENTE and T.USUÁRIO = cur.USUÁRIO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into USUÁRIO (CLIENTE, USUÁRIO, DEPTO, DESLIGAMENTO, SITUAÇÃO, NOTIFIC_EMAIL, SEC_ID, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLIENTE, cur.USUÁRIO, cur.DEPTO, cur.DESLIGAMENTO, cur.SITUAÇÃO, cur.NOTIFIC_EMAIL, cur.SEC_ID, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg USUÁRIO: ' || cur.CLIENTE || cur.USUÁRIO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg USUÁRIO inexistente: ' || cur.CLIENTE || cur.USUÁRIO || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg USUÁRIO já manipulado localmente: ' || cur.CLIENTE || cur.USUÁRIO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg USUÁRIO já existente e manipulado localmente: ' || cur.CLIENTE || cur.USUÁRIO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.USUÁRIO t set T.DEPTO = cur.DEPTO, T.DESLIGAMENTO = cur.DESLIGAMENTO, T.SITUAÇÃO = cur.SITUAÇÃO, T.NOTIFIC_EMAIL = cur.NOTIFIC_EMAIL, T.SEC_ID = cur.SEC_ID, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLIENTE = cur.CLIENTE and T.USUÁRIO = cur.USUÁRIO;
                                                                        log(reglog, '> Atualização realizada do reg USUÁRIO: ' || cur.CLIENTE || cur.USUÁRIO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg USUÁRIO com data local igual ou mais atual: ' || cur.CLIENTE || cur.USUÁRIO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg USUÁRIO já existente e com data local igual ou mais atual: ' || cur.CLIENTE || cur.USUÁRIO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela USUÁRIO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela IDENTIF
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLIENTE, USUÁRIO, TIPO_IDENTIF, IDENTIF, SENHA, SENHA2, OBS, SEC_ID, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.IDENTIF_T T;
                                        reg CXRJ.IDENTIF%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.IDENTIF T where T.CLIENTE = cur.CLIENTE and T.USUÁRIO = cur.USUÁRIO and T.TIPO_IDENTIF = cur.TIPO_IDENTIF and T.IDENTIF = cur.IDENTIF;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into IDENTIF (CLIENTE, USUÁRIO, TIPO_IDENTIF, IDENTIF, SENHA, SENHA2, OBS, SEC_ID, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLIENTE, cur.USUÁRIO, cur.TIPO_IDENTIF, cur.IDENTIF, cur.SENHA, cur.SENHA2, cur.OBS, cur.SEC_ID, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg IDENTIF: ' || cur.CLIENTE || cur.USUÁRIO || cur.TIPO_IDENTIF || cur.IDENTIF || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg IDENTIF inexistente: ' || cur.CLIENTE || cur.USUÁRIO || cur.TIPO_IDENTIF || cur.IDENTIF || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg IDENTIF já manipulado localmente: ' || cur.CLIENTE || cur.USUÁRIO || cur.TIPO_IDENTIF || cur.IDENTIF || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg IDENTIF já existente e manipulado localmente: ' || cur.CLIENTE || cur.USUÁRIO || cur.TIPO_IDENTIF || cur.IDENTIF || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.IDENTIF t set T.SENHA = cur.SENHA, T.SENHA2 = cur.SENHA2, T.OBS = cur.OBS, T.SEC_ID = cur.SEC_ID, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLIENTE = cur.CLIENTE and T.USUÁRIO = cur.USUÁRIO and T.TIPO_IDENTIF = cur.TIPO_IDENTIF and T.IDENTIF = cur.IDENTIF;
                                                                        log(reglog, '> Atualização realizada do reg IDENTIF: ' || cur.CLIENTE || cur.USUÁRIO || cur.TIPO_IDENTIF || cur.IDENTIF || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg IDENTIF com data local igual ou mais atual: ' || cur.CLIENTE || cur.USUÁRIO || cur.TIPO_IDENTIF || cur.IDENTIF || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg IDENTIF já existente e com data local igual ou mais atual: ' || cur.CLIENTE || cur.USUÁRIO || cur.TIPO_IDENTIF || cur.IDENTIF || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela IDENTIF - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela MÁQUINA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLIENTE, MÁQUINA, USUÁRIO, OBS, SENHA, SEC_ID, TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.MÁQUINA_T T;
                                        reg CXRJ.MÁQUINA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.MÁQUINA T where T.CLIENTE = cur.CLIENTE and T.MÁQUINA = cur.MÁQUINA;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into MÁQUINA (CLIENTE, MÁQUINA, USUÁRIO, OBS, SENHA, SEC_ID, TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLIENTE, cur.MÁQUINA, cur.USUÁRIO, cur.OBS, cur.SENHA, cur.SEC_ID, cur.TIPO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg MÁQUINA: ' || cur.CLIENTE || cur.MÁQUINA || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg MÁQUINA inexistente: ' || cur.CLIENTE || cur.MÁQUINA || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg MÁQUINA já manipulado localmente: ' || cur.CLIENTE || cur.MÁQUINA || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg MÁQUINA já existente e manipulado localmente: ' || cur.CLIENTE || cur.MÁQUINA || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.MÁQUINA t set T.USUÁRIO = cur.USUÁRIO, T.OBS = cur.OBS, T.SENHA = cur.SENHA, T.SEC_ID = cur.SEC_ID, T.TIPO = cur.TIPO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLIENTE = cur.CLIENTE and T.MÁQUINA = cur.MÁQUINA;
                                                                        log(reglog, '> Atualização realizada do reg MÁQUINA: ' || cur.CLIENTE || cur.MÁQUINA || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg MÁQUINA com data local igual ou mais atual: ' || cur.CLIENTE || cur.MÁQUINA || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg MÁQUINA já existente e com data local igual ou mais atual: ' || cur.CLIENTE || cur.MÁQUINA || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela MÁQUINA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela MÁQUINA_RECURSO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLIENTE, MÁQUINA, RECURSO, COMPLEMENTO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.MÁQUINA_RECURSO_T T;
                                        reg CXRJ.MÁQUINA_RECURSO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.MÁQUINA_RECURSO T where T.CLIENTE = cur.CLIENTE and T.MÁQUINA = cur.MÁQUINA and T.RECURSO = cur.RECURSO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into MÁQUINA_RECURSO (CLIENTE, MÁQUINA, RECURSO, COMPLEMENTO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLIENTE, cur.MÁQUINA, cur.RECURSO, cur.COMPLEMENTO, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg MÁQUINA_RECURSO: ' || cur.CLIENTE || cur.MÁQUINA || cur.RECURSO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg MÁQUINA_RECURSO inexistente: ' || cur.CLIENTE || cur.MÁQUINA || cur.RECURSO || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg MÁQUINA_RECURSO já manipulado localmente: ' || cur.CLIENTE || cur.MÁQUINA || cur.RECURSO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg MÁQUINA_RECURSO já existente e manipulado localmente: ' || cur.CLIENTE || cur.MÁQUINA || cur.RECURSO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.MÁQUINA_RECURSO t set T.COMPLEMENTO = cur.COMPLEMENTO, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLIENTE = cur.CLIENTE and T.MÁQUINA = cur.MÁQUINA and T.RECURSO = cur.RECURSO;
                                                                        log(reglog, '> Atualização realizada do reg MÁQUINA_RECURSO: ' || cur.CLIENTE || cur.MÁQUINA || cur.RECURSO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg MÁQUINA_RECURSO com data local igual ou mais atual: ' || cur.CLIENTE || cur.MÁQUINA || cur.RECURSO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg MÁQUINA_RECURSO já existente e com data local igual ou mais atual: ' || cur.CLIENTE || cur.MÁQUINA || cur.RECURSO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela MÁQUINA_RECURSO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela IP
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLIENTE, MÁQUINA, REDE_CLIENTE, REDE_IDENTIF, IP, ROTEADOR, DNS, MAC, SUBNET_HOST_ID, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.IP_T T;
                                        reg CXRJ.IP%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.IP T where T.CLIENTE = cur.CLIENTE and T.MÁQUINA = cur.MÁQUINA and T.REDE_CLIENTE = cur.REDE_CLIENTE and T.REDE_IDENTIF = cur.REDE_IDENTIF and T.IP = cur.IP;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into IP (CLIENTE, MÁQUINA, REDE_CLIENTE, REDE_IDENTIF, IP, ROTEADOR, DNS, MAC, SUBNET_HOST_ID, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLIENTE, cur.MÁQUINA, cur.REDE_CLIENTE, cur.REDE_IDENTIF, cur.IP, cur.ROTEADOR, cur.DNS, cur.MAC, cur.SUBNET_HOST_ID, cur.OBS, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg IP: ' || cur.CLIENTE || cur.MÁQUINA || cur.REDE_CLIENTE || cur.REDE_IDENTIF || cur.IP || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg IP inexistente: ' || cur.CLIENTE || cur.MÁQUINA || cur.REDE_CLIENTE || cur.REDE_IDENTIF || cur.IP || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg IP já manipulado localmente: ' || cur.CLIENTE || cur.MÁQUINA || cur.REDE_CLIENTE || cur.REDE_IDENTIF || cur.IP || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg IP já existente e manipulado localmente: ' || cur.CLIENTE || cur.MÁQUINA || cur.REDE_CLIENTE || cur.REDE_IDENTIF || cur.IP || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.IP t set T.ROTEADOR = cur.ROTEADOR, T.DNS = cur.DNS, T.MAC = cur.MAC, T.SUBNET_HOST_ID = cur.SUBNET_HOST_ID, T.OBS = cur.OBS, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLIENTE = cur.CLIENTE and T.MÁQUINA = cur.MÁQUINA and T.REDE_CLIENTE = cur.REDE_CLIENTE and T.REDE_IDENTIF = cur.REDE_IDENTIF and T.IP = cur.IP;
                                                                        log(reglog, '> Atualização realizada do reg IP: ' || cur.CLIENTE || cur.MÁQUINA || cur.REDE_CLIENTE || cur.REDE_IDENTIF || cur.IP || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg IP com data local igual ou mais atual: ' || cur.CLIENTE || cur.MÁQUINA || cur.REDE_CLIENTE || cur.REDE_IDENTIF || cur.IP || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg IP já existente e com data local igual ou mais atual: ' || cur.CLIENTE || cur.MÁQUINA || cur.REDE_CLIENTE || cur.REDE_IDENTIF || cur.IP || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela IP - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela CRONOGRAMA
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLIENTE, PROJETO, SEQ, ETAPA, CONSOLID, NOVA_PREV, NOVA_OBS, DESENVOLVEDOR, SUPORTE, CRIADOR_ADM, CRIAÇÃO, DELEGAÇÃO, PREVISÃO, PREVISÃO_ADM, REALIZAÇÃO, CONFIRMAÇÃO, CONFIRMAÇÃO_ADM, CONFIRMADOR, OBS, OBS_ADM, DURAÇÃO, CONTÍNUA, PAI_SEQ, SEQ_N, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.CRONOGRAMA_T T;
                                        reg CXRJ.CRONOGRAMA%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.CRONOGRAMA T where T.CLIENTE = cur.CLIENTE and T.PROJETO = cur.PROJETO and T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into CRONOGRAMA (CLIENTE, PROJETO, SEQ, ETAPA, CONSOLID, NOVA_PREV, NOVA_OBS, DESENVOLVEDOR, SUPORTE, CRIADOR_ADM, CRIAÇÃO, DELEGAÇÃO, PREVISÃO, PREVISÃO_ADM, REALIZAÇÃO, CONFIRMAÇÃO, CONFIRMAÇÃO_ADM, CONFIRMADOR, OBS, OBS_ADM, DURAÇÃO, CONTÍNUA, PAI_SEQ, SEQ_N, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLIENTE, cur.PROJETO, cur.SEQ, cur.ETAPA, cur.CONSOLID, cur.NOVA_PREV, cur.NOVA_OBS, cur.DESENVOLVEDOR, cur.SUPORTE, cur.CRIADOR_ADM, cur.CRIAÇÃO, cur.DELEGAÇÃO, cur.PREVISÃO, cur.PREVISÃO_ADM, cur.REALIZAÇÃO, cur.CONFIRMAÇÃO, cur.CONFIRMAÇÃO_ADM, cur.CONFIRMADOR, cur.OBS, cur.OBS_ADM, cur.DURAÇÃO, cur.CONTÍNUA, cur.PAI_SEQ, cur.SEQ_N, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg CRONOGRAMA: ' || cur.CLIENTE || cur.PROJETO || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg CRONOGRAMA inexistente: ' || cur.CLIENTE || cur.PROJETO || cur.SEQ || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg CRONOGRAMA já manipulado localmente: ' || cur.CLIENTE || cur.PROJETO || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg CRONOGRAMA já existente e manipulado localmente: ' || cur.CLIENTE || cur.PROJETO || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.CRONOGRAMA t set T.ETAPA = cur.ETAPA, T.CONSOLID = cur.CONSOLID, T.NOVA_PREV = cur.NOVA_PREV, T.NOVA_OBS = cur.NOVA_OBS, T.DESENVOLVEDOR = cur.DESENVOLVEDOR, T.SUPORTE = cur.SUPORTE, T.CRIADOR_ADM = cur.CRIADOR_ADM, T.CRIAÇÃO = cur.CRIAÇÃO, T.DELEGAÇÃO = cur.DELEGAÇÃO, T.PREVISÃO = cur.PREVISÃO, T.PREVISÃO_ADM = cur.PREVISÃO_ADM, T.REALIZAÇÃO = cur.REALIZAÇÃO, T.CONFIRMAÇÃO = cur.CONFIRMAÇÃO, T.CONFIRMAÇÃO_ADM = cur.CONFIRMAÇÃO_ADM, T.CONFIRMADOR = cur.CONFIRMADOR, T.OBS = cur.OBS, T.OBS_ADM = cur.OBS_ADM, T.DURAÇÃO = cur.DURAÇÃO, T.CONTÍNUA = cur.CONTÍNUA, T.PAI_SEQ = cur.PAI_SEQ, T.SEQ_N = cur.SEQ_N, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLIENTE = cur.CLIENTE and T.PROJETO = cur.PROJETO and T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg CRONOGRAMA: ' || cur.CLIENTE || cur.PROJETO || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg CRONOGRAMA com data local igual ou mais atual: ' || cur.CLIENTE || cur.PROJETO || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg CRONOGRAMA já existente e com data local igual ou mais atual: ' || cur.CLIENTE || cur.PROJETO || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela CRONOGRAMA - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela GRUPO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLIENTE, GRUPO, SUPERGRUPO, ORDEM, DEPENDE, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.GRUPO_T T;
                                        reg CXRJ.GRUPO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.GRUPO T where T.CLIENTE = cur.CLIENTE and T.GRUPO = cur.GRUPO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into GRUPO (CLIENTE, GRUPO, SUPERGRUPO, ORDEM, DEPENDE, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLIENTE, cur.GRUPO, cur.SUPERGRUPO, cur.ORDEM, cur.DEPENDE, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg GRUPO: ' || cur.CLIENTE || cur.GRUPO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg GRUPO inexistente: ' || cur.CLIENTE || cur.GRUPO || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg GRUPO já manipulado localmente: ' || cur.CLIENTE || cur.GRUPO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg GRUPO já existente e manipulado localmente: ' || cur.CLIENTE || cur.GRUPO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.GRUPO t set T.SUPERGRUPO = cur.SUPERGRUPO, T.ORDEM = cur.ORDEM, T.DEPENDE = cur.DEPENDE, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLIENTE = cur.CLIENTE and T.GRUPO = cur.GRUPO;
                                                                        log(reglog, '> Atualização realizada do reg GRUPO: ' || cur.CLIENTE || cur.GRUPO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg GRUPO com data local igual ou mais atual: ' || cur.CLIENTE || cur.GRUPO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg GRUPO já existente e com data local igual ou mais atual: ' || cur.CLIENTE || cur.GRUPO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela GRUPO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela PROJETO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select CLIENTE, PROJETO, DESENVOLVEDOR, SUPORTE, GRUPO, OBS, STATUS, ORDEM, DESENVOLVEDOR2, SUPORTE2, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.PROJETO_T T;
                                        reg CXRJ.PROJETO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.PROJETO T where T.CLIENTE = cur.CLIENTE and T.PROJETO = cur.PROJETO;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into PROJETO (CLIENTE, PROJETO, DESENVOLVEDOR, SUPORTE, GRUPO, OBS, STATUS, ORDEM, DESENVOLVEDOR2, SUPORTE2, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.CLIENTE, cur.PROJETO, cur.DESENVOLVEDOR, cur.SUPORTE, cur.GRUPO, cur.OBS, cur.STATUS, cur.ORDEM, cur.DESENVOLVEDOR2, cur.SUPORTE2, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg PROJETO: ' || cur.CLIENTE || cur.PROJETO || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg PROJETO inexistente: ' || cur.CLIENTE || cur.PROJETO || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg PROJETO já manipulado localmente: ' || cur.CLIENTE || cur.PROJETO || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg PROJETO já existente e manipulado localmente: ' || cur.CLIENTE || cur.PROJETO || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.PROJETO t set T.DESENVOLVEDOR = cur.DESENVOLVEDOR, T.SUPORTE = cur.SUPORTE, T.GRUPO = cur.GRUPO, T.OBS = cur.OBS, T.STATUS = cur.STATUS, T.ORDEM = cur.ORDEM, T.DESENVOLVEDOR2 = cur.DESENVOLVEDOR2, T.SUPORTE2 = cur.SUPORTE2, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.CLIENTE = cur.CLIENTE and T.PROJETO = cur.PROJETO;
                                                                        log(reglog, '> Atualização realizada do reg PROJETO: ' || cur.CLIENTE || cur.PROJETO || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg PROJETO com data local igual ou mais atual: ' || cur.CLIENTE || cur.PROJETO || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg PROJETO já existente e com data local igual ou mais atual: ' || cur.CLIENTE || cur.PROJETO || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela PROJETO - ' || SQLERRM);

                                                end;
                        end;

                        -- tratando inclusões e alterações da tabela REALIZADO
                        -- MARCIO
                        begin
                                declare
                                        cursor origem is select SEQ, INI, TAREFA, TIPO, CLIENTE, DEPTO, USUÁRIO, OBS, TÉCNICO, PROJETO, CHAMADO_DATA, ATENDIM_INÍCIO, ATENDIM_FIM, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS from CXRJ.REALIZADO_T T;
                                        reg CXRJ.REALIZADO%rowtype;
                                begin
                                        for cur in origem loop
                                                begin
                                                        select * into reg from CXRJ.REALIZADO T where T.SEQ = cur.SEQ;
                                                        sql_notfound := SQL%NOTFOUND;
                                                exception
                                                        when NO_DATA_FOUND then
                                                                sql_notfound := true;
                                                end;
                                                if sql_notfound then
                                                        insert into REALIZADO (SEQ, INI, TAREFA, TIPO, CLIENTE, DEPTO, USUÁRIO, OBS, TÉCNICO, PROJETO, CHAMADO_DATA, ATENDIM_INÍCIO, ATENDIM_FIM, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS) values (cur.SEQ, cur.INI, cur.TAREFA, cur.TIPO, cur.CLIENTE, cur.DEPTO, cur.USUÁRIO, cur.OBS, cur.TÉCNICO, cur.PROJETO, cur.CHAMADO_DATA, cur.ATENDIM_INÍCIO, cur.ATENDIM_FIM, cur.SYS_MOMENTO_CRIA, cur.SYS_USUÁRIO_CRIA, cur.SYS_LOCAL_CRIA, cur.SYS_MOMENTO_ATUALIZA, cur.SYS_USUÁRIO_ATUALIZA, cur.SYS_LOCAL_ATUALIZA, decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X'));
                                                        log(reglog, '> Inclusão realizada do reg REALIZADO: ' || cur.SEQ || '.');
                                                        if cur.SYS_STATUS = 'A' then
                                                                log(reglog, '> ADVERTÊNCIA - tentativa de alteração de reg REALIZADO inexistente: ' || cur.SEQ || '. Registro foi incluído.');
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
                                                                                log(reglog, '> CONFLITO - tentativa de alteração de reg REALIZADO já manipulado localmente: ' || cur.SEQ || '. Registro não modificado.');
                                                                        else
                                                                                log(reglog, '> CONFLITO - solicitação de inclusão de reg REALIZADO já existente e manipulado localmente: ' || cur.SEQ || '. Registro não modificado.');
                                                                        end if;
                                                                else
                                                                        update CXRJ.REALIZADO t set T.INI = cur.INI, T.TAREFA = cur.TAREFA, T.TIPO = cur.TIPO, T.CLIENTE = cur.CLIENTE, T.DEPTO = cur.DEPTO, T.USUÁRIO = cur.USUÁRIO, T.OBS = cur.OBS, T.TÉCNICO = cur.TÉCNICO, T.PROJETO = cur.PROJETO, T.CHAMADO_DATA = cur.CHAMADO_DATA, T.ATENDIM_INÍCIO = cur.ATENDIM_INÍCIO, T.ATENDIM_FIM = cur.ATENDIM_FIM, T.SYS_MOMENTO_CRIA = cur.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA = cur.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA = cur.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA = cur.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA = cur.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA = cur.SYS_LOCAL_ATUALIZA, T.SYS_STATUS = decode(cur.SYS_STATUS, 'I', '+', 'A', '/', 'X') where T.SEQ = cur.SEQ;
                                                                        log(reglog, '> Atualização realizada do reg REALIZADO: ' || cur.SEQ || '.');
                                                                end if;
                                                        else
                                                                if cur.SYS_STATUS = 'A' then
                                                                        log(reglog, '> IGNORADO - tentativa de alteração de reg REALIZADO com data local igual ou mais atual: ' || cur.SEQ || '. Registro não modificado.');
                                                                else
                                                                        log(reglog, '> IGNORADO - solicitação de inclusão de reg REALIZADO já existente e com data local igual ou mais atual: ' || cur.SEQ || '. Registro não modificado.');
                                                                end if;
                                                        end if;
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                                raise_application_error(-20000, 'erro durante o recebimento de informações da tabela REALIZADO - ' || SQLERRM);

                                                end;
                        end;



                        log(reglog, 'Tratando exclusões.');

                        -- tratando exclusões da tabela CRONOGRAMA
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'CRONOGRAMA';
                                begin
                                        for cur in origem loop
                                                delete from CRONOGRAMA T where (T.CLIENTE || T.PROJETO || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CRONOGRAMA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CRONOGRAMA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CRONOGRAMA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela MOVIMENTO_PREV
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'MOVIMENTO_PREV';
                                begin
                                        for cur in origem loop
                                                delete from MOVIMENTO_PREV T where (T.CONTA || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg MOVIMENTO_PREV: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído MOVIMENTO_PREV: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela MOVIMENTO_PREV - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CLASSIF
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'CLASSIF';
                                begin
                                        for cur in origem loop
                                                delete from CLASSIF T where (T.CLASSE = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CLASSIF: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CLASSIF: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CLASSIF - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CONJ_IMPRESS
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'CONJ_IMPRESS';
                                begin
                                        for cur in origem loop
                                                delete from CONJ_IMPRESS T where (T.DEFINIÇÃO || T.DEFINIÇÃO_SEQ || T.ITEM = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CONJ_IMPRESS: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CONJ_IMPRESS: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CONJ_IMPRESS - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CONTA
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'CONTA';
                                begin
                                        for cur in origem loop
                                                delete from CONTA T where (T.CONTA = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
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

                        -- tratando exclusões da tabela CONTATO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'CONTATO';
                                begin
                                        for cur in origem loop
                                                delete from CONTATO T where (T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CONTATO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CONTATO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CONTATO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela HIERARQUIA
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'HIERARQUIA';
                                begin
                                        for cur in origem loop
                                                delete from HIERARQUIA T where (T.CLIENTE || T.CLASSIF = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg HIERARQUIA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído HIERARQUIA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela HIERARQUIA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela IDENTIF
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'IDENTIF';
                                begin
                                        for cur in origem loop
                                                delete from IDENTIF T where (T.CLIENTE || T.USUÁRIO || T.TIPO_IDENTIF || T.IDENTIF = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg IDENTIF: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído IDENTIF: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela IDENTIF - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela IP
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'IP';
                                begin
                                        for cur in origem loop
                                                delete from IP T where (T.CLIENTE || T.MÁQUINA || T.REDE_CLIENTE || T.REDE_IDENTIF || T.IP = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg IP: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído IP: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela IP - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela LICENÇA
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'LICENÇA';
                                begin
                                        for cur in origem loop
                                                delete from LICENÇA T where (T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg LICENÇA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído LICENÇA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela LICENÇA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CD
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'CD';
                                begin
                                        for cur in origem loop
                                                delete from CD T where (T.ID = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CD: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CD: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CD - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela MOVIMENTO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'MOVIMENTO';
                                begin
                                        for cur in origem loop
                                                delete from MOVIMENTO T where (T.CONTA || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg MOVIMENTO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído MOVIMENTO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela MOVIMENTO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela REALIZADO_COM_DURAÇÃO_STAT
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'REALIZADO_COM_DURAÇÃO_STAT';
                                begin
                                        for cur in origem loop
                                                delete from REALIZADO_COM_DURAÇÃO_STAT T where (T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg REALIZADO_COM_DURAÇÃO_STAT: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído REALIZADO_COM_DURAÇÃO_STAT: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela REALIZADO_COM_DURAÇÃO_STAT - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PONTO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'PONTO';
                                begin
                                        for cur in origem loop
                                                delete from PONTO T where (T.CLIENTE || T.PATCH || T.PONTO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PONTO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PONTO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PONTO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela TAREFA_DEF
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'TAREFA_DEF';
                                begin
                                        for cur in origem loop
                                                delete from TAREFA_DEF T where (T.TAREFA = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg TAREFA_DEF: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído TAREFA_DEF: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela TAREFA_DEF - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela REALIZADO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'REALIZADO';
                                begin
                                        for cur in origem loop
                                                delete from REALIZADO T where (T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg REALIZADO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído REALIZADO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela REALIZADO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela SERVIÇO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'SERVIÇO';
                                begin
                                        for cur in origem loop
                                                delete from SERVIÇO T where (T.CLIENTE || T.SERVIÇO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg SERVIÇO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído SERVIÇO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela SERVIÇO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela MÁQUINA_RECURSO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'MÁQUINA_RECURSO';
                                begin
                                        for cur in origem loop
                                                delete from MÁQUINA_RECURSO T where (T.CLIENTE || T.MÁQUINA || T.RECURSO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg MÁQUINA_RECURSO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído MÁQUINA_RECURSO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela MÁQUINA_RECURSO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela TABELA_SÓCIO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'TABELA_SÓCIO';
                                begin
                                        for cur in origem loop
                                                delete from TABELA_SÓCIO T where (T.PERÍODO || T.SÓCIO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg TABELA_SÓCIO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído TABELA_SÓCIO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela TABELA_SÓCIO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela ACESSO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'ACESSO';
                                begin
                                        for cur in origem loop
                                                delete from ACESSO T where (T.LOGIN = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg ACESSO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído ACESSO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela ACESSO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CONJ_REL
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'CONJ_REL';
                                begin
                                        for cur in origem loop
                                                delete from CONJ_REL T where (T.DEFINIÇÃO || T.SEQ = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CONJ_REL: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CONJ_REL: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CONJ_REL - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela TIPO_TAREFA
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'TIPO_TAREFA';
                                begin
                                        for cur in origem loop
                                                delete from TIPO_TAREFA T where (T.TIPO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg TIPO_TAREFA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído TIPO_TAREFA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela TIPO_TAREFA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela TIPO_SERVIÇO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'TIPO_SERVIÇO';
                                begin
                                        for cur in origem loop
                                                delete from TIPO_SERVIÇO T where (T.TIPO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg TIPO_SERVIÇO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído TIPO_SERVIÇO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela TIPO_SERVIÇO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela CLASSE
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'CLASSE';
                                begin
                                        for cur in origem loop
                                                delete from CLASSE T where (T.NOME = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CLASSE: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CLASSE: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CLASSE - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PROJETO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'PROJETO';
                                begin
                                        for cur in origem loop
                                                delete from PROJETO T where (T.CLIENTE || T.PROJETO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PROJETO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PROJETO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PROJETO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela TIPO_IDENTIF
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'TIPO_IDENTIF';
                                begin
                                        for cur in origem loop
                                                delete from TIPO_IDENTIF T where (T.TIPO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg TIPO_IDENTIF: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído TIPO_IDENTIF: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela TIPO_IDENTIF - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela MÁQUINA
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'MÁQUINA';
                                begin
                                        for cur in origem loop
                                                delete from MÁQUINA T where (T.CLIENTE || T.MÁQUINA = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg MÁQUINA: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído MÁQUINA: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela MÁQUINA - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela REDE
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'REDE';
                                begin
                                        for cur in origem loop
                                                delete from REDE T where (T.CLIENTE || T.REDE = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg REDE: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído REDE: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela REDE - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela RECURSO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'RECURSO';
                                begin
                                        for cur in origem loop
                                                delete from RECURSO T where (T.RECURSO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg RECURSO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído RECURSO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela RECURSO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela PATCH
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'PATCH';
                                begin
                                        for cur in origem loop
                                                delete from PATCH T where (T.CLIENTE || T.PATCH = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg PATCH: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído PATCH: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela PATCH - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela TIPO_RECURSO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'TIPO_RECURSO';
                                begin
                                        for cur in origem loop
                                                delete from TIPO_RECURSO T where (T.TIPO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg TIPO_RECURSO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído TIPO_RECURSO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela TIPO_RECURSO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela USUÁRIO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'USUÁRIO';
                                begin
                                        for cur in origem loop
                                                delete from USUÁRIO T where (T.CLIENTE || T.USUÁRIO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg USUÁRIO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído USUÁRIO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela USUÁRIO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela TÉCNICO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'TÉCNICO';
                                begin
                                        for cur in origem loop
                                                delete from TÉCNICO T where (T.TÉCNICO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg TÉCNICO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído TÉCNICO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela TÉCNICO - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela DEPTO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'DEPTO';
                                begin
                                        for cur in origem loop
                                                delete from DEPTO T where (T.CLIENTE || T.DEPTO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
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

                        -- tratando exclusões da tabela CLIENTE
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'CLIENTE';
                                begin
                                        for cur in origem loop
                                                delete from CLIENTE T where (T.NOME = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg CLIENTE: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído CLIENTE: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela CLIENTE - ' || SQLERRM);
                                end;
                        end;

                        -- tratando exclusões da tabela GRUPO
                        begin
                                declare
                                        cursor origem is select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO from CXRJ.SYS_DELETE_T where NOME_TABELA = 'GRUPO';
                                begin
                                        for cur in origem loop
                                                delete from GRUPO T where (T.CLIENTE || T.GRUPO = cur.CHAVE) and (decode(T.SYS_MOMENTO_ATUALIZA, null, T.SYS_MOMENTO_CRIA, T.SYS_MOMENTO_ATUALIZA) < cur.MOMENTO);
                                                if SQL%NOTFOUND then
                                                        log(reglog, '> ADVERTÊNCIA - tentativa de exclusão de reg GRUPO: ' || cur.CHAVE || '. Registro não existia ou era mais atual.');
                                                else
                                                        log(reglog, '> reg excluído GRUPO: ' || cur.CHAVE || '.');
                                                end if;
                                        end loop;
                                exception
                                        when others then
                                               raise_application_error(-20000, 'erro durante o tratamento de exclusões da tabela GRUPO - ' || SQLERRM);
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
                                err := DBMS_CX.DOSSHELL('sendmail -f cxrj@xxxxxxxxx.com.br -t ' || replace(email, ';', ' -t ') || ' -a "D:\CXRJ_T\' ||
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
                                err := sendmail('cxrj@xxxxxxxxx.com.br', email, 'CIEX - Rotina de tratamento de pacote', servsmtp, 'Erro durante o tratamento do pacote.', diretorio || '\' || arqpac_remoto || '.LOG');
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

                        delete from CRONOGRAMA_T;
                        delete from MOVIMENTO_PREV_T;
                        delete from CLASSIF_T;
                        delete from CONJ_IMPRESS_T;
                        delete from CONTA_T;
                        delete from CONTATO_T;
                        delete from HIERARQUIA_T;
                        delete from IDENTIF_T;
                        delete from IP_T;
                        delete from LICENÇA_T;
                        delete from MÁQUINA_RECURSO_T;
                        delete from CD_T;
                        delete from MOVIMENTO_T;
                        delete from REALIZADO_COM_DURAÇÃO_STAT_T;
                        delete from PONTO_T;
                        delete from TAREFA_DEF_T;
                        delete from REALIZADO_T;
                        delete from SERVIÇO_T;
                        delete from SYS_DELETE_T;
                        delete from TABELA_SÓCIO_T;
                        delete from ACESSO_T;
                        delete from CONJ_REL_T;
                        delete from TIPO_TAREFA_T;
                        delete from TIPO_SERVIÇO_T;
                        delete from PATCH_T;
                        delete from CLASSE_T;
                        delete from PROJETO_T;
                        delete from TIPO_IDENTIF_T;
                        delete from MÁQUINA_T;
                        delete from REDE_T;
                        delete from RECURSO_T;
                        delete from TIPO_RECURSO_T;
                        delete from USUÁRIO_T;
                        delete from TÉCNICO_T;
                        delete from DEPTO_T;
                        delete from CLIENTE_T;
                        delete from GRUPO_T;
                        COMMIT;

                        log(reglog, 'Importando informações do pacote.');
                        err := DBMS_CX.DOSSHELL('imp.exe CXRJ/' || senhalocal || '@' || servicolocal || ' FILE=' || diretorio || '\' || arquivo || '.PAC' || ' LOG=' || diretorio || '\RECEB.TMP PARFILE=' || diretorio || '\' || 'RECEB.PAR FROMUSER=CXRJ');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando imp.exe');
                        end if;
                        loga(reglog, diretorio, 'RECEB.TMP');

                        log(reglog, 'Apaga registros das tabelas da localidade.');
                        log(reglog, 'Excluindo registros de CRONOGRAMA.');
                        delete from CRONOGRAMA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de MOVIMENTO_PREV.');
                        delete from MOVIMENTO_PREV;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CLASSIF.');
                        delete from CLASSIF;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CONJ_IMPRESS.');
                        delete from CONJ_IMPRESS;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CONTA.');
                        delete from CONTA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CONTATO.');
                        delete from CONTATO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de HIERARQUIA.');
                        delete from HIERARQUIA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de IDENTIF.');
                        delete from IDENTIF;
                        COMMIT;
                        log(reglog, 'Excluindo registros de IP.');
                        delete from IP;
                        COMMIT;
                        log(reglog, 'Excluindo registros de LICENÇA.');
                        delete from LICENÇA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de MÁQUINA_RECURSO.');
                        delete from MÁQUINA_RECURSO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CD.');
                        delete from CD;
                        COMMIT;
                        log(reglog, 'Excluindo registros de MOVIMENTO.');
                        delete from MOVIMENTO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de REALIZADO_COM_DURAÇÃO_STAT.');
                        delete from REALIZADO_COM_DURAÇÃO_STAT;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PONTO.');
                        delete from PONTO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de TAREFA_DEF.');
                        delete from TAREFA_DEF;
                        COMMIT;
                        log(reglog, 'Excluindo registros de REALIZADO.');
                        delete from REALIZADO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de SERVIÇO.');
                        delete from SERVIÇO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de SYS_DELETE.');
                        delete from SYS_DELETE;
                        COMMIT;
                        log(reglog, 'Excluindo registros de TABELA_SÓCIO.');
                        delete from TABELA_SÓCIO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de ACESSO.');
                        delete from ACESSO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CONJ_REL.');
                        delete from CONJ_REL;
                        COMMIT;
                        log(reglog, 'Excluindo registros de TIPO_TAREFA.');
                        delete from TIPO_TAREFA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de TIPO_SERVIÇO.');
                        delete from TIPO_SERVIÇO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PATCH.');
                        delete from PATCH;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CLASSE.');
                        delete from CLASSE;
                        COMMIT;
                        log(reglog, 'Excluindo registros de PROJETO.');
                        delete from PROJETO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de TIPO_IDENTIF.');
                        delete from TIPO_IDENTIF;
                        COMMIT;
                        log(reglog, 'Excluindo registros de MÁQUINA.');
                        delete from MÁQUINA;
                        COMMIT;
                        log(reglog, 'Excluindo registros de REDE.');
                        delete from REDE;
                        COMMIT;
                        log(reglog, 'Excluindo registros de RECURSO.');
                        delete from RECURSO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de TIPO_RECURSO.');
                        delete from TIPO_RECURSO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de USUÁRIO.');
                        delete from USUÁRIO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de TÉCNICO.');
                        delete from TÉCNICO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de DEPTO.');
                        delete from DEPTO;
                        COMMIT;
                        log(reglog, 'Excluindo registros de CLIENTE.');
                        delete from CLIENTE;
                        COMMIT;
                        log(reglog, 'Excluindo registros de GRUPO.');
                        delete from GRUPO;
                        COMMIT;
                        COMMIT;

                        -- transfere registros da tabela MOVIMENTO_PREV para a localidade
                        log(reglog, 'Transferindo registros da tabela MOVIMENTO_PREV.');
                        begin
                                insert into CXRJ.MOVIMENTO_PREV         (CONTA, SEQ, ÚLTIMA_DATA, PERÍODO_REF, DATA_REF, SAÍDA, ENTRADA, INCREM_DIA, INCREM_MÊS, INCREM_ANO, VEZES, HISTÓRICO, CLASSE, EVENTO, PENDÊNCIA, OPERADOR, VINC_CONTA, VINC_SEQ, CONTROLE, OBS, SÓCIO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CONTA, T.SEQ, T.ÚLTIMA_DATA, T.PERÍODO_REF, T.DATA_REF, T.SAÍDA, T.ENTRADA, T.INCREM_DIA, T.INCREM_MÊS, T.INCREM_ANO, T.VEZES, T.HISTÓRICO, T.CLASSE, T.EVENTO, T.PENDÊNCIA, T.OPERADOR, T.VINC_CONTA, T.VINC_SEQ, T.CONTROLE, T.OBS, T.SÓCIO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.MOVIMENTO_PREV_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela MOVIMENTO_PREV -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CLASSE para a localidade
                        log(reglog, 'Transferindo registros da tabela CLASSE.');
                        begin
                                insert into CXRJ.CLASSE         (NOME, PREF, LOC, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.NOME, T.PREF, T.LOC, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.CLASSE_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CLASSE -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CLASSIF para a localidade
                        log(reglog, 'Transferindo registros da tabela CLASSIF.');
                        begin
                                insert into CXRJ.CLASSIF         (CLASSE, TRAT, DESCRIÇÃO, OBS, TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLASSE, T.TRAT, T.DESCRIÇÃO, T.OBS, T.TIPO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.CLASSIF_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CLASSIF -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CLIENTE para a localidade
                        log(reglog, 'Transferindo registros da tabela CLIENTE.');
                        begin
                                insert into CXRJ.CLIENTE         (NOME, OBRIGATÓRIO, ORDEM, REQ_DEPTO, REQ_USUÁRIO, REQ_PROJETO, NOTIFIC_EMAIL, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.NOME, T.OBRIGATÓRIO, T.ORDEM, T.REQ_DEPTO, T.REQ_USUÁRIO, T.REQ_PROJETO, T.NOTIFIC_EMAIL, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.CLIENTE_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CLIENTE -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CONJ_REL para a localidade
                        log(reglog, 'Transferindo registros da tabela CONJ_REL.');
                        begin
                                insert into CXRJ.CONJ_REL         (DEFINIÇÃO, SEQ, TÉCNICO, CLIENTE, DEPTO, USUÁRIO, GRUPO_PROJETO, TIPO_TAREFA, MÁQUINA, PERÍODO_DE, PERÍODO_ATÉ, DUR_MIN, RELATÓRIOS, NOME_ARQ, ARQ, TIPO_HORA, QUEBRA_USU, NOTIFIC_IMEDIATO, NOTIFIC_EMAIL, NOTIFIC_AOCLIENTE, NOTIFIC_AODEPTO, NOTIFIC_AOUSUÁRIO, NOTIFIC_AOTÉCNICO, LOG, DATA_ACUMULA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.DEFINIÇÃO, T.SEQ, T.TÉCNICO, T.CLIENTE, T.DEPTO, T.USUÁRIO, T.GRUPO_PROJETO, T.TIPO_TAREFA, T.MÁQUINA, T.PERÍODO_DE, T.PERÍODO_ATÉ, T.DUR_MIN, T.RELATÓRIOS, T.NOME_ARQ, T.ARQ, T.TIPO_HORA, T.QUEBRA_USU, T.NOTIFIC_IMEDIATO, T.NOTIFIC_EMAIL, T.NOTIFIC_AOCLIENTE, T.NOTIFIC_AODEPTO, T.NOTIFIC_AOUSUÁRIO, T.NOTIFIC_AOTÉCNICO, T.LOG, T.DATA_ACUMULA, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.CONJ_REL_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CONJ_REL -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CONTA para a localidade
                        log(reglog, 'Transferindo registros da tabela CONTA.');
                        begin
                                insert into CXRJ.CONTA         (CONTA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CONTA, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.CONTA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CONTA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CONTATO para a localidade
                        log(reglog, 'Transferindo registros da tabela CONTATO.');
                        begin
                                insert into CXRJ.CONTATO         (SEQ, EMPRESA, CONTATO, TELEFONE, FAX, EMAIL, ENDEREÇO, OBS, CLASSE, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.SEQ, T.EMPRESA, T.CONTATO, T.TELEFONE, T.FAX, T.EMAIL, T.ENDEREÇO, T.OBS, T.CLASSE, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.CONTATO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CONTATO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela HIERARQUIA para a localidade
                        log(reglog, 'Transferindo registros da tabela HIERARQUIA.');
                        begin
                                insert into CXRJ.HIERARQUIA         (CLIENTE, CLASSIF, CLASSE, SUPER, LISTA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLIENTE, T.CLASSIF, T.CLASSE, T.SUPER, T.LISTA, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.HIERARQUIA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela HIERARQUIA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela LICENÇA para a localidade
                        log(reglog, 'Transferindo registros da tabela LICENÇA.');
                        begin
                                insert into CXRJ.LICENÇA         (SEQ, RECURSO, CÓDIGO, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.SEQ, T.RECURSO, T.CÓDIGO, T.OBS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.LICENÇA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela LICENÇA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela MOVIMENTO para a localidade
                        log(reglog, 'Transferindo registros da tabela MOVIMENTO.');
                        begin
                                insert into CXRJ.MOVIMENTO         (CONTA, SEQ, DATA, REF, SAÍDA, ENTRADA, HISTÓRICO, CLASSE, EVENTO, PENDÊNCIA, OPERADOR, VINC_CONTA, VINC_SEQ, CONTROLE, OBS, PREV, SÓCIO, MARCA, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CONTA, T.SEQ, T.DATA, T.REF, T.SAÍDA, T.ENTRADA, T.HISTÓRICO, T.CLASSE, T.EVENTO, T.PENDÊNCIA, T.OPERADOR, T.VINC_CONTA, T.VINC_SEQ, T.CONTROLE, T.OBS, T.PREV, T.SÓCIO, T.MARCA, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.MOVIMENTO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela MOVIMENTO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela REALIZADO_COM_DURAÇÃO_STAT para a localidade
                        log(reglog, 'Transferindo registros da tabela REALIZADO_COM_DURAÇÃO_STAT.');
                        begin
                                insert into CXRJ.REALIZADO_COM_DURAÇÃO_STAT         (TÉCNICO, INI, SEQ, TAREFA, TIPO, CLIENTE, DEPTO, USUÁRIO, OBS, PROJETO, CHAMADO_DATA, GRUPO, LISTA, ATENDIM_INÍCIO, ATENDIM_DATE, PROX_INI, ATENDIM_DUR, DUR, ATENDIM_MAX, ATENDIM_MIN, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.TÉCNICO, T.INI, T.SEQ, T.TAREFA, T.TIPO, T.CLIENTE, T.DEPTO, T.USUÁRIO, T.OBS, T.PROJETO, T.CHAMADO_DATA, T.GRUPO, T.LISTA, T.ATENDIM_INÍCIO, T.ATENDIM_DATE, T.PROX_INI, T.ATENDIM_DUR, T.DUR, T.ATENDIM_MAX, T.ATENDIM_MIN, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.REALIZADO_COM_DURAÇÃO_STAT_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela REALIZADO_COM_DURAÇÃO_STAT -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela TABELA_SÓCIO para a localidade
                        log(reglog, 'Transferindo registros da tabela TABELA_SÓCIO.');
                        begin
                                insert into CXRJ.TABELA_SÓCIO         (PERÍODO, SÓCIO, VALOR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.PERÍODO, T.SÓCIO, T.VALOR, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.TABELA_SÓCIO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela TABELA_SÓCIO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela TIPO_RECURSO para a localidade
                        log(reglog, 'Transferindo registros da tabela TIPO_RECURSO.');
                        begin
                                insert into CXRJ.TIPO_RECURSO         (TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.TIPO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.TIPO_RECURSO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela TIPO_RECURSO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela TIPO_SERVIÇO para a localidade
                        log(reglog, 'Transferindo registros da tabela TIPO_SERVIÇO.');
                        begin
                                insert into CXRJ.TIPO_SERVIÇO         (TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.TIPO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.TIPO_SERVIÇO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela TIPO_SERVIÇO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela TAREFA_DEF para a localidade
                        log(reglog, 'Transferindo registros da tabela TAREFA_DEF.');
                        begin
                                insert into CXRJ.TAREFA_DEF         (TAREFA, DETALHE, OBS, TIPO, CLIENTE, DEPTO, USUÁRIO, PROJETO, FATO, P_APLICATIVO, GRUPOS, COMENTÁRIOS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.TAREFA, T.DETALHE, T.OBS, T.TIPO, T.CLIENTE, T.DEPTO, T.USUÁRIO, T.PROJETO, T.FATO, T.P_APLICATIVO, T.GRUPOS, T.COMENTÁRIOS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.TAREFA_DEF_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela TAREFA_DEF -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela TIPO_IDENTIF para a localidade
                        log(reglog, 'Transferindo registros da tabela TIPO_IDENTIF.');
                        begin
                                insert into CXRJ.TIPO_IDENTIF         (TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.TIPO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.TIPO_IDENTIF_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela TIPO_IDENTIF -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela TIPO_TAREFA para a localidade
                        log(reglog, 'Transferindo registros da tabela TIPO_TAREFA.');
                        begin
                                insert into CXRJ.TIPO_TAREFA         (TIPO, DESCR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.TIPO, T.DESCR, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.TIPO_TAREFA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela TIPO_TAREFA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela TÉCNICO para a localidade
                        log(reglog, 'Transferindo registros da tabela TÉCNICO.');
                        begin
                                insert into CXRJ.TÉCNICO         (CLASSIFIC, TÉCNICO, SEC_ID, EMAIL_TÉCNICO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLASSIFIC, T.TÉCNICO, T.SEC_ID, T.EMAIL_TÉCNICO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.TÉCNICO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela TÉCNICO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela ACESSO para a localidade
                        log(reglog, 'Transferindo registros da tabela ACESSO.');
                        begin
                                insert into CXRJ.ACESSO         (LOGIN, CLIENTE, DEPTO, USUÁRIO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.LOGIN, T.CLIENTE, T.DEPTO, T.USUÁRIO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.ACESSO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela ACESSO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela SERVIÇO para a localidade
                        log(reglog, 'Transferindo registros da tabela SERVIÇO.');
                        begin
                                insert into CXRJ.SERVIÇO         (CLIENTE, SERVIÇO, DESCRIÇÃO, TIPO, LOCALIZAÇÃO, DESENVOLVEDOR, SUPORTE, BKP_DIR_LOCAL, BKP_DIR_CONSOL, BKP_PROG_RETEM, BKP_NOTIFICAR, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLIENTE, T.SERVIÇO, T.DESCRIÇÃO, T.TIPO, T.LOCALIZAÇÃO, T.DESENVOLVEDOR, T.SUPORTE, T.BKP_DIR_LOCAL, T.BKP_DIR_CONSOL, T.BKP_PROG_RETEM, T.BKP_NOTIFICAR, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.SERVIÇO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela SERVIÇO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PATCH para a localidade
                        log(reglog, 'Transferindo registros da tabela PATCH.');
                        begin
                                insert into CXRJ.PATCH         (CLIENTE, PATCH, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLIENTE, T.PATCH, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.PATCH_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PATCH -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela REDE para a localidade
                        log(reglog, 'Transferindo registros da tabela REDE.');
                        begin
                                insert into CXRJ.REDE         (CLIENTE, REDE, ENDEREÇO, MÁSCARA, SUBNET_AUTO, SUBNET_PARAM, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLIENTE, T.REDE, T.ENDEREÇO, T.MÁSCARA, T.SUBNET_AUTO, T.SUBNET_PARAM, T.OBS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.REDE_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela REDE -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CONJ_IMPRESS para a localidade
                        log(reglog, 'Transferindo registros da tabela CONJ_IMPRESS.');
                        begin
                                insert into CXRJ.CONJ_IMPRESS         (DEFINIÇÃO, DEFINIÇÃO_SEQ, ITEM, REL, ARQUIVO, FILTRO, GERAÇÃO_MOMENTO, IMPRESSÃO_MOMENTO, NOTIFIC_EMAIL, NOTIFIC_MOMENTO, RESULT, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.DEFINIÇÃO, T.DEFINIÇÃO_SEQ, T.ITEM, T.REL, T.ARQUIVO, T.FILTRO, T.GERAÇÃO_MOMENTO, T.IMPRESSÃO_MOMENTO, T.NOTIFIC_EMAIL, T.NOTIFIC_MOMENTO, T.RESULT, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.CONJ_IMPRESS_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CONJ_IMPRESS -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela RECURSO para a localidade
                        log(reglog, 'Transferindo registros da tabela RECURSO.');
                        begin
                                insert into CXRJ.RECURSO         (RECURSO, TIPO, LOCALIZAÇÃO, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.RECURSO, T.TIPO, T.LOCALIZAÇÃO, T.OBS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.RECURSO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela RECURSO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela DEPTO para a localidade
                        log(reglog, 'Transferindo registros da tabela DEPTO.');
                        begin
                                insert into CXRJ.DEPTO         (CLIENTE, DEPTO, MARCA, SITUAÇÃO, NOTIFIC_EMAIL, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLIENTE, T.DEPTO, T.MARCA, T.SITUAÇÃO, T.NOTIFIC_EMAIL, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.DEPTO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela DEPTO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CD para a localidade
                        log(reglog, 'Transferindo registros da tabela CD.');
                        begin
                                insert into CXRJ.CD         (ID, NUM, TÍTULO, DATA, CLASSE, CONTEÚDO, USUÁRIO, MOMENTO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.ID, T.NUM, T.TÍTULO, T.DATA, T.CLASSE, T.CONTEÚDO, T.USUÁRIO, T.MOMENTO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.CD_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CD -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PONTO para a localidade
                        log(reglog, 'Transferindo registros da tabela PONTO.');
                        begin
                                insert into CXRJ.PONTO         (CLIENTE, PATCH, PONTO, LOCALIZAÇÃO, ATUAL_UTILIZAÇÃO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLIENTE, T.PATCH, T.PONTO, T.LOCALIZAÇÃO, T.ATUAL_UTILIZAÇÃO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.PONTO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PONTO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela USUÁRIO para a localidade
                        log(reglog, 'Transferindo registros da tabela USUÁRIO.');
                        begin
                                insert into CXRJ.USUÁRIO         (CLIENTE, USUÁRIO, DEPTO, DESLIGAMENTO, SITUAÇÃO, NOTIFIC_EMAIL, SEC_ID, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLIENTE, T.USUÁRIO, T.DEPTO, T.DESLIGAMENTO, T.SITUAÇÃO, T.NOTIFIC_EMAIL, T.SEC_ID, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.USUÁRIO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela USUÁRIO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela IDENTIF para a localidade
                        log(reglog, 'Transferindo registros da tabela IDENTIF.');
                        begin
                                insert into CXRJ.IDENTIF         (CLIENTE, USUÁRIO, TIPO_IDENTIF, IDENTIF, SENHA, SENHA2, OBS, SEC_ID, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLIENTE, T.USUÁRIO, T.TIPO_IDENTIF, T.IDENTIF, T.SENHA, T.SENHA2, T.OBS, T.SEC_ID, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.IDENTIF_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela IDENTIF -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela MÁQUINA para a localidade
                        log(reglog, 'Transferindo registros da tabela MÁQUINA.');
                        begin
                                insert into CXRJ.MÁQUINA         (CLIENTE, MÁQUINA, USUÁRIO, OBS, SENHA, SEC_ID, TIPO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLIENTE, T.MÁQUINA, T.USUÁRIO, T.OBS, T.SENHA, T.SEC_ID, T.TIPO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.MÁQUINA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela MÁQUINA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela MÁQUINA_RECURSO para a localidade
                        log(reglog, 'Transferindo registros da tabela MÁQUINA_RECURSO.');
                        begin
                                insert into CXRJ.MÁQUINA_RECURSO         (CLIENTE, MÁQUINA, RECURSO, COMPLEMENTO, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLIENTE, T.MÁQUINA, T.RECURSO, T.COMPLEMENTO, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.MÁQUINA_RECURSO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela MÁQUINA_RECURSO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela IP para a localidade
                        log(reglog, 'Transferindo registros da tabela IP.');
                        begin
                                insert into CXRJ.IP         (CLIENTE, MÁQUINA, REDE_CLIENTE, REDE_IDENTIF, IP, ROTEADOR, DNS, MAC, SUBNET_HOST_ID, OBS, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLIENTE, T.MÁQUINA, T.REDE_CLIENTE, T.REDE_IDENTIF, T.IP, T.ROTEADOR, T.DNS, T.MAC, T.SUBNET_HOST_ID, T.OBS, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.IP_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela IP -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela CRONOGRAMA para a localidade
                        log(reglog, 'Transferindo registros da tabela CRONOGRAMA.');
                        begin
                                insert into CXRJ.CRONOGRAMA         (CLIENTE, PROJETO, SEQ, ETAPA, CONSOLID, NOVA_PREV, NOVA_OBS, DESENVOLVEDOR, SUPORTE, CRIADOR_ADM, CRIAÇÃO, DELEGAÇÃO, PREVISÃO, PREVISÃO_ADM, REALIZAÇÃO, CONFIRMAÇÃO, CONFIRMAÇÃO_ADM, CONFIRMADOR, OBS, OBS_ADM, DURAÇÃO, CONTÍNUA, PAI_SEQ, SEQ_N, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLIENTE, T.PROJETO, T.SEQ, T.ETAPA, T.CONSOLID, T.NOVA_PREV, T.NOVA_OBS, T.DESENVOLVEDOR, T.SUPORTE, T.CRIADOR_ADM, T.CRIAÇÃO, T.DELEGAÇÃO, T.PREVISÃO, T.PREVISÃO_ADM, T.REALIZAÇÃO, T.CONFIRMAÇÃO, T.CONFIRMAÇÃO_ADM, T.CONFIRMADOR, T.OBS, T.OBS_ADM, T.DURAÇÃO, T.CONTÍNUA, T.PAI_SEQ, T.SEQ_N, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.CRONOGRAMA_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela CRONOGRAMA -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela GRUPO para a localidade
                        log(reglog, 'Transferindo registros da tabela GRUPO.');
                        begin
                                insert into CXRJ.GRUPO         (CLIENTE, GRUPO, SUPERGRUPO, ORDEM, DEPENDE, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLIENTE, T.GRUPO, T.SUPERGRUPO, T.ORDEM, T.DEPENDE, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.GRUPO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela GRUPO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela PROJETO para a localidade
                        log(reglog, 'Transferindo registros da tabela PROJETO.');
                        begin
                                insert into CXRJ.PROJETO         (CLIENTE, PROJETO, DESENVOLVEDOR, SUPORTE, GRUPO, OBS, STATUS, ORDEM, DESENVOLVEDOR2, SUPORTE2, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.CLIENTE, T.PROJETO, T.DESENVOLVEDOR, T.SUPORTE, T.GRUPO, T.OBS, T.STATUS, T.ORDEM, T.DESENVOLVEDOR2, T.SUPORTE2, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.PROJETO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela PROJETO -> ' || SQLERRM);
                        end;

                        -- transfere registros da tabela REALIZADO para a localidade
                        log(reglog, 'Transferindo registros da tabela REALIZADO.');
                        begin
                                insert into CXRJ.REALIZADO         (SEQ, INI, TAREFA, TIPO, CLIENTE, DEPTO, USUÁRIO, OBS, TÉCNICO, PROJETO, CHAMADO_DATA, ATENDIM_INÍCIO, ATENDIM_FIM, SYS_MOMENTO_CRIA, SYS_USUÁRIO_CRIA, SYS_LOCAL_CRIA, SYS_MOMENTO_ATUALIZA, SYS_USUÁRIO_ATUALIZA, SYS_LOCAL_ATUALIZA, SYS_STATUS)
                                select T.SEQ, T.INI, T.TAREFA, T.TIPO, T.CLIENTE, T.DEPTO, T.USUÁRIO, T.OBS, T.TÉCNICO, T.PROJETO, T.CHAMADO_DATA, T.ATENDIM_INÍCIO, T.ATENDIM_FIM, T.SYS_MOMENTO_CRIA, T.SYS_USUÁRIO_CRIA, T.SYS_LOCAL_CRIA, T.SYS_MOMENTO_ATUALIZA, T.SYS_USUÁRIO_ATUALIZA, T.SYS_LOCAL_ATUALIZA, decode(T.SYS_STATUS, 'I', '+', 'A', '/', 'X') from CXRJ.REALIZADO_T T;
                                COMMIT;
                        exception
                                when others then
                                               raise_application_error(-20000, 'erro durante a transferência de registros da tabela REALIZADO -> ' || SQLERRM);
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
                        delete from CRONOGRAMA_T;
                        delete from MOVIMENTO_PREV_T;
                        delete from CLASSIF_T;
                        delete from CONJ_IMPRESS_T;
                        delete from CONTA_T;
                        delete from CONTATO_T;
                        delete from HIERARQUIA_T;
                        delete from IDENTIF_T;
                        delete from IP_T;
                        delete from LICENÇA_T;
                        delete from MÁQUINA_RECURSO_T;
                        delete from CD_T;
                        delete from MOVIMENTO_T;
                        delete from REALIZADO_COM_DURAÇÃO_STAT_T;
                        delete from PONTO_T;
                        delete from TAREFA_DEF_T;
                        delete from REALIZADO_T;
                        delete from SERVIÇO_T;
                        delete from SYS_DELETE_T;
                        delete from TABELA_SÓCIO_T;
                        delete from ACESSO_T;
                        delete from CONJ_REL_T;
                        delete from TIPO_TAREFA_T;
                        delete from TIPO_SERVIÇO_T;
                        delete from PATCH_T;
                        delete from CLASSE_T;
                        delete from PROJETO_T;
                        delete from TIPO_IDENTIF_T;
                        delete from MÁQUINA_T;
                        delete from REDE_T;
                        delete from RECURSO_T;
                        delete from TIPO_RECURSO_T;
                        delete from USUÁRIO_T;
                        delete from TÉCNICO_T;
                        delete from DEPTO_T;
                        delete from CLIENTE_T;
                        delete from GRUPO_T;
                        COMMIT;

                        log(reglog, 'Importando informações do pacote.');
                        err := DBMS_CX.DOSSHELL('imp.exe ' || localpac || '/' || senhalocal || '@' || servicolocal || ' FILE=' || diretorio || '\' || arqpac_remoto || '.PAC' || ' LOG=' || diretorio || '\RECEB.TMP PARFILE=' || diretorio || '\' || 'RECEB.PAR TOUSER=CXRJ');
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

        insert into CARTA_CRÉDITO(banco, ref, emb_validade, negociação_validade, tolerância_qtd, valor_tolerância, emb_parcial_permitido, transbordo_permitido, moeda, valor)
        Select nome_novo,ref, emb_validade, negociação_validade, tolerância_qtd, valor_tolerância, emb_parcial_permitido, transbordo_permitido, moeda, valor
        from CARTA_CRÉDITO where banco = nome_antigo;

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
        update EMB set exp_logotipo = nome_novo where exp_logotipo = nome_antigo;
        update EMB set banco_avisador = nome_novo where banco_avisador = nome_antigo;
        update EMB set banco_confirm = nome_novo where banco_confirm = nome_antigo;
        update EMB set negociador = nome_novo where negociador = nome_antigo;
        update EMB set carta_crédito_banco_abridor = nome_novo where carta_crédito_banco_abridor = nome_antigo;
        update EMB set imp_logotipo = nome_novo where imp_logotipo = nome_antigo;
        update FAX_DESTINO set cia = nome_novo where cia = nome_antigo;
        update PED_ITEM set usuário_final = nome_novo where usuário_final = nome_antigo;
        update PED_LANÇ set beneficiário = nome_novo where beneficiário = nome_antigo;
        update PED_RESULT set competência = nome_novo where competência = nome_antigo;
        update FRETE set proprietário = nome_novo where proprietário = nome_antigo;
        update INSTRUÇÃO_PAG set pagador = nome_novo where pagador = nome_antigo;
        update INSTRUÇÃO_PAG set recebedor = nome_novo where recebedor = nome_antigo;
        update MERCADO set contratante = nome_novo where contratante = nome_antigo;
        update MERCADO set fornecedor = nome_novo where fornecedor = nome_antigo;
        update MERCADO set transportador = nome_novo where transportador = nome_antigo;
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
        Delete from CARTA_CRÉDITO where banco = nome_antigo;
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

        insert into CIA(logotipo, cod, cgc, nome, endereço, bairro, cidade, estado, país, cep, caixa_postal, telefone, fax, telex, e_mail, f_cod, marcação, obs, local_result)
        select logotipo, nome_novo, cgc, nome, endereço, bairro, cidade, estado, país, cep, caixa_postal, telefone, fax, telex, e_mail, f_cod, marcação, obs, local_result
        from CIA where cod = nome_antigo;
        insert into CIA_CONTATO(cia_cod, contato_nome, telefone, função)
        select nome_novo, contato_nome, telefone, função
        from CIA_CONTATO where cia_cod = nome_antigo;
        insert into CIA_RAMO_ATIVIDADE(cia_cod, ramo_atividade)
        select nome_novo, ramo_atividade
        from CIA_RAMO_ATIVIDADE where cia_cod = nome_antigo;
        --Carta de Crédito
        insert into CARTA_CRÉDITO(banco, ref, emb_validade, negociação_validade, tolerância_qtd, valor_tolerância, emb_parcial_permitido, transbordo_permitido, moeda, valor)
        Select nome_novo,ref, emb_validade, negociação_validade, tolerância_qtd, valor_tolerância, emb_parcial_permitido, transbordo_permitido, moeda, valor
        from CARTA_CRÉDITO where banco = nome_antigo;

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
        update EMB set exp_logotipo = nome_novo where exp_logotipo = nome_antigo;
        update EMB set banco_avisador = nome_novo where banco_avisador = nome_antigo;
        update EMB set banco_confirm = nome_novo where banco_confirm = nome_antigo;
        update EMB set negociador = nome_novo where negociador = nome_antigo;
        update EMB set carta_crédito_banco_abridor = nome_novo where carta_crédito_banco_abridor = nome_antigo;
        update EMB set imp_logotipo = nome_novo where imp_logotipo = nome_antigo;
        update FAX_DESTINO set cia = nome_novo where cia = nome_antigo;
        update PED_ITEM set usuário_final = nome_novo where usuário_final = nome_antigo;
        update PED_LANÇ set beneficiário = nome_novo where beneficiário = nome_antigo;
        update PED_RESULT set competência = nome_novo where competência = nome_antigo;
        update FRETE set proprietário = nome_novo where proprietário = nome_antigo;
        update INSTRUÇÃO_PAG set pagador = nome_novo where pagador = nome_antigo;
        update INSTRUÇÃO_PAG set recebedor = nome_novo where recebedor = nome_antigo;
        update MERCADO set contratante = nome_novo where contratante = nome_antigo;
        update MERCADO set fornecedor = nome_novo where fornecedor = nome_antigo;
        update MERCADO set transportador = nome_novo where transportador = nome_antigo;
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
        Delete from CARTA_CRÉDITO where banco = nome_antigo;

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

