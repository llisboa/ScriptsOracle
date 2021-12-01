-------------------------------------------------------------------------------------
-- CRIAÇÃO DE SCRIPT PARA GERAR PACOTE DE FUNÇÕES BÁSICAS DO WIDB
--
-- desenvolvedor...: Luciano Lisbôa -- data: 18/07/2000
-- programa assist.: ESTRUT_CIEX_8i_2000.MDB
--
-- importante: * para rodar este, necessário antes rodar WIDB.SQL e TRANSF_WIDB.SQL
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
                                                err := sendmail('widb@xxxxxxxxx.com.br', email, 'CIEX - Rotina de criação de pacote', servsmtp, 'O sistema não está conseguindo criar pacotes devido às estruturas temporárias estarem bloqueadas por mais de 6 horas (modelo = 2).');
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
                                        delete from RNSC_NOTICIA_T;
                                        delete from SYS_DELETE_T;
                                        delete from SNRA_NOTICIA_T;

                                        COMMIT;

                                        set transaction read write;

                                        log(reglog, 'Transferindo informações para estruturas de transferência.');
                                        insert into RNSC_NOTICIA_T (ID,MES,INSERIDA_EM,FONTE,PERMANENCIA,EXTRA,TITULO,NOTICIA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ID,MES,INSERIDA_EM,FONTE,PERMANENCIA,EXTRA,TITULO,NOTICIA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from RNSC_NOTICIA where SYS_STATUS <> ' ';

                                        insert into SYS_DELETE_T (CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO)
                                        select CHAVE,LOCAL,MOMENTO,NOME_TABELA,USUÁRIO  from SYS_DELETE;

                                        insert into SNRA_NOTICIA_T (ID,MES,INSERIDA_EM,FONTE,PERMANENCIA,EXTRA,TITULO,NOTICIA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ID,MES,INSERIDA_EM,FONTE,PERMANENCIA,EXTRA,TITULO,NOTICIA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS  from SNRA_NOTICIA where SYS_STATUS <> ' ';


                                        log(reglog, 'Inicializando status dos registros exportados.');
                                        update RNSC_NOTICIA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';
                                        delete from SYS_DELETE;
                                        update SNRA_NOTICIA set SYS_STATUS = 'X' where SYS_STATUS <> ' ';

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
                                delete from RNSC_NOTICIA_T;
                                delete from SYS_DELETE_T;
                                delete from SNRA_NOTICIA_T;
                                COMMIT;

                                set transaction read write;

                                log(reglog, 'Transferindo informações para estruturas de transferência.');
                                if full='y' then
                                        insert into RNSC_NOTICIA_T (ID,MES,INSERIDA_EM,FONTE,PERMANENCIA,EXTRA,TITULO,NOTICIA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ID,MES,INSERIDA_EM,FONTE,PERMANENCIA,EXTRA,TITULO,NOTICIA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from RNSC_NOTICIA;

                                        insert into SNRA_NOTICIA_T (ID,MES,INSERIDA_EM,FONTE,PERMANENCIA,EXTRA,TITULO,NOTICIA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ID,MES,INSERIDA_EM,FONTE,PERMANENCIA,EXTRA,TITULO,NOTICIA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from SNRA_NOTICIA;

                                else
                                        insert into RNSC_NOTICIA_T (ID,MES,INSERIDA_EM,FONTE,PERMANENCIA,EXTRA,TITULO,NOTICIA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ID,MES,INSERIDA_EM,FONTE,PERMANENCIA,EXTRA,TITULO,NOTICIA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from RNSC_NOTICIA where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

                                        insert into SNRA_NOTICIA_T (ID,MES,INSERIDA_EM,FONTE,PERMANENCIA,EXTRA,TITULO,NOTICIA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS)
                                        select ID,MES,INSERIDA_EM,FONTE,PERMANENCIA,EXTRA,TITULO,NOTICIA,SYS_MOMENTO_CRIA,SYS_USUÁRIO_CRIA,SYS_LOCAL_CRIA,SYS_MOMENTO_ATUALIZA,SYS_USUÁRIO_ATUALIZA,SYS_LOCAL_ATUALIZA,SYS_STATUS from SNRA_NOTICIA where decode(SYS_MOMENTO_ATUALIZA, NULL, SYS_MOMENTO_CRIA, SYS_MOMENTO_ATUALIZA) >= to_date(full, 'DD/MM/YYYY HH24:MI');

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
                                        err := DBMS_CX.DOSSHELL('sendmail -f widb@xxxxxxxxx.com.br -t ' || replace(email, ';', ' -t ') || ' -a "' ||
                                        diretorio || '\' || arqpac || '.ARJ' || '" -a "D:\WIDB_T\' || arqpac || '.LOG" -s "CIEX - Transferência do pacote ' ||
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
                                err := sendmail('widb@xxxxxxxxx.com.br', email, 'CIEX - Rotina de criação de pacote', servsmtp, 'Erro durante a criação do pacote.', diretorio || '\' || arqpac || '.LOG');
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
                                                err := sendmail('widb@xxxxxxxxx.com.br', email, 'CIEX - Rotina de tratamento de pacote', servsmtp, 'O sistema não está conseguindo tratar pacotes devido às estruturas temporárias estarem bloqueadas por mais de 6 horas (modelo = 2).');
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
                        delete from RNSC_NOTICIA_T;
                        delete from SYS_DELETE_T;
                        delete from SNRA_NOTICIA_T;
                        COMMIT;

                        log(reglog, 'Importando informações do pacote.');
                        err := DBMS_CX.DOSSHELL('imp.exe ' || localpac || '/' || senhalocal || '@' || servicolocal || ' FILE=' || diretorio || '\' || arqpac_remoto || '.PAC' || ' LOG=' || diretorio || '\RECEB.TMP PARFILE=' || diretorio || '\' || 'RECEB.PAR TOUSER=WIDB');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando imp.exe');
                        end if;
                        loga(reglog, diretorio, 'RECEB.TMP');

                        log(reglog, 'Tratando inclusões e alterações.');

