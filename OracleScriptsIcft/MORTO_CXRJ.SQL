-------------------------------------------------------------------------------------
-- CRIAÇÃO DE SCRIPT PARA GERAR PACOTE DE FUNÇÕES RELACIONADAS AO ARQUIVO MORTO
--
-- desenvolvedor...: Luciano Lisbôa -- data: 18/07/2000
-- programa assist.: ESTRUT_CIEX_8i_2000.MDB
-------------------------------------------------------------------------------------

create or replace package dbms_morto is

        procedure move_pacote_morto(diretorio in varchar2, senhalocal in varchar2, servicolocal in varchar2);

end;
/
create or replace package body dbms_morto is


        procedure move_pacote_morto(diretorio in varchar2, senhalocal in varchar2, servicolocal in varchar2) is

        err integer;
        numpac integer;
        arqpac varchar2(100);
        localpac varchar2(100);
        reglog utl_file.file_type;
        modelopac SYS_LOCALID.MODELO%type;

        begin
                begin
                        reglog := utl_file.fopen(diretorio, 'MORTO.LOG', 'a');

                        select NOME, PACOTE, MODELO into localpac, numpac, modelopac from SYS_LOCALID where CORRENTE = -1;
                        dbms_cx.log(reglog, '');
                        dbms_cx.log(reglog, '----------------------------------------------------------------------');
                               arqpac := 'MORTO_' || localpac;
                        dbms_cx.log(reglog, 'Gerando pacote para arquivo MORTO para o arquivo ' || diretorio || '\' || arqpac || '.ARJ' || '.');

GOTO PULO;

                        dbms_cx.log(reglog, 'Inicializando estruturas temporárias para transferência.');
                        delete from CRONOGRAMA_T;
                        delete from MOVIMENTO_T;
                        delete from REALIZADO_T;
                        delete from CONJ_IMPRESS_T;
                        delete from CONTA_T;
                        delete from CONTATO_T;
                        delete from HIERARQUIA_T;
                        delete from IDENTIF_T;
                        delete from IP_T;
                        delete from LICENÇA_T;
                        delete from MÁQUINA_RECURSO_T;
                        delete from CD_T;
                        delete from PONTO_T;
                        delete from CRONO_NOTIF_T;
                        delete from SERVIÇO_T;
                        delete from ACESSO_T;
                        delete from TÉCNICO_MENU_T;
                        delete from COBRARQ_T;
                        delete from CONTRATO_FIN_T;
                        delete from REALIZADO_COM_DURAÇÃO_STAT_T;
                        delete from SYS_DELETE_T;
                        delete from TAREFA_DEF_T;
                        delete from TABELA_SÓCIO_T;
                        delete from CONJ_REL_T;
                        delete from REDE_T;
                        delete from RECURSO_T;
                        delete from CLASSE_T;
                        delete from CLASSIF_T;
                        delete from PROJETO_T;
                        delete from CONTRATO_T;
                        delete from TIPO_TAREFA_T;
                        delete from MÁQUINA_T;
                        delete from TIPO_SERVIÇO_T;
                        delete from PATCH_T;
                        delete from TIPO_IDENTIF_T;
                        delete from TÉCNICO_T;
                        delete from USUÁRIO_T;
                        delete from TIPO_RECURSO_T;
                        delete from DEPTO_T;
                        delete from CLIENTE_T;
                        delete from GRUPO_T;
                        COMMIT;

                        set transaction read write;

                        dbms_cx.log(reglog, 'Transferindo informações para estruturas de transferência.');
                        COMMIT;

                        dbms_cx.log(reglog, 'Excluindo registros transferidos para o arquivo morto.');
                        COMMIT;

                        -- LEO TRATAR COMPLEMENTAÇÃO DE ARQUIVO MORTO
                        -- dbms_cx.log(reglog, 'Excluindo registros transferidos para o arquivo morto.');
                        -- excluindo registros transferidos para o arquivo morto>>
                        -- COMMIT;

<<PULO>> -- LUC PULO PARA GERAR PACOTE SEM FAZER TRATAMENTOS DIVERSOS

                        dbms_cx.log(reglog, 'Exportando informações para o pacote.');
                        err := DBMS_CX.DOSSHELL('EXP ' || localpac || '/' || senhalocal || '@' || servicolocal || ' FILE=' || diretorio || '\' || arqpac || '.PAC LOG=' || diretorio || '\MORTO.TMP PARFILE=' || diretorio || '\' || 'TRANSF.PAR');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando exp.exe');
                        end if;
                        dbms_cx.loga(reglog, diretorio, 'MORTO.TMP');

                        dbms_cx.log(reglog, 'Compactando o pacote.');
                        err := DBMS_CX.DOSSHELL('arj32.exe a -t -y ' || diretorio || '\' || arqpac || '.ARJ ' || diretorio || '\' || arqpac || '.PAC>' || diretorio || '\MORTO.TMP');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando arj32.exe');
                        end if;
                        dbms_cx.loga(reglog, diretorio, 'MORTO.TMP');

                        dbms_cx.log(reglog, 'Excluindo arquivos temporários.');
                        err := DBMS_CX.DOSSHELL('DEL ' || diretorio || '\' || arqpac || '.PAC>' || diretorio || '\MORTO.TMP');
                        if err <> 0 then
                                raise_application_error(-20000, 'erro cod' || to_char(err) || ' ao executar comando DEL');
                        end if;
                        dbms_cx.loga(reglog, diretorio, 'MORTO.TMP');

                        err := DBMS_CX.DOSSHELL('DEL ' || diretorio || '\MORTO.TMP');

                        dbms_cx.log(reglog, 'Término de criação do pacote para arquivo morto ' || diretorio || '\' || arqpac || '.ARJ');
                        utl_file.fclose(reglog);
                end;

        exception
                when others then
                        ROLLBACK;
                        dbms_cx.log(reglog, 'Erro na criação do pacote para arquivo morto. Nenhuma alteração realizada.');
                        dbms_cx.log(reglog, SQLERRM);
                        if utl_file.is_open(reglog) then
                                utl_file.fclose(reglog);
                        end if;
                        raise_application_error ( -20000, 'erro na função de criação de pacote arquivo morto -> ' || SQLERRM );
        end;


end;

/

