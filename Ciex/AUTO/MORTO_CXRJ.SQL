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

                        dbms_cx.log(reglog, 'Transferindo informações para estruturas de transferência.');
                        insert into IDIOMA_T
                        select * from IDIOMA;

                        insert into PAÍS_T
                        select * from PAÍS;

                        insert into NAVIO_T
                        select * from NAVIO;

                        insert into COND_PAG_T
                        select * from COND_PAG;

                        insert into CIA_T
                        select * from CIA;

                        insert into PORTO_T
                        select * from PORTO;

                        insert into GRUPO_PRODUTO_T
                        select * from GRUPO_PRODUTO;

                        insert into INCOTERM_T
                        select * from INCOTERM;

                        insert into MOEDA_T
                        select * from MOEDA;

                        insert into MODALIDADE_FRETE_T
                        select * from MODALIDADE_FRETE;

                        insert into VIA_TRANSPORTE_T
                        select * from VIA_TRANSPORTE;

                        insert into VIAGEM_T
                        select * from VIAGEM t where NOT EXISTS(
        SELECT VIAGEM_REF, ETA FROM VIAGEM_ESCALA VE
        WHERE VE.VIAGEM_REF = T.REF AND VE.ETA >=  ADD_MONTHS(SYSDATE,-60) 
)
AND EXISTS(
        SELECT VIAGEM_REF, ETA FROM VIAGEM_ESCALA VE
        WHERE VE.VIAGEM_REF = T.REF AND VE.ETA <  ADD_MONTHS(SYSDATE,-60) 
);

                        insert into VIAGEM_ESCALA_T
                        select * from VIAGEM_ESCALA t where EXISTS(
        (
                SELECT * FROM VIAGEM V WHERE V.REF = T.VIAGEM_REF AND 
                NOT EXISTS(
                        SELECT VIAGEM_REF, ETA FROM VIAGEM_ESCALA VE
                        WHERE VE.VIAGEM_REF = V.REF AND VE.ETA >=  ADD_MONTHS(SYSDATE,-60) 
                )
                AND EXISTS(
                        SELECT VIAGEM_REF, ETA FROM VIAGEM_ESCALA VE
                        WHERE VE.VIAGEM_REF = V.REF AND VE.ETA <  ADD_MONTHS(SYSDATE,-60) 
                )
        )
);

                        insert into EMBALAGEM_T
                        select * from EMBALAGEM;

                        insert into UNID_QUANTID_T
                        select * from UNID_QUANTID;

                        insert into PED_T
                        select * from PED t where T.PED_DATA <  ADD_MONTHS(SYSDATE,-60);

                        insert into PARAM_T
                        select * from PARAM;

                        insert into PRODUTO_T
                        select * from PRODUTO;

                        insert into CONFIRM_VENDA_T
                        select * from CONFIRM_VENDA t where T.EMISSÃO_DATA <  ADD_MONTHS(SYSDATE,-60)  OR 
EXISTS(
        SELECT * FROM PED P WHERE P.REF = T.PED_REF
        AND P.PED_DATA <  ADD_MONTHS(SYSDATE,-60) 
);

                        insert into DEPTO_T
                        select * from DEPTO;

                        insert into PED_ITEM_T
                        select * from PED_ITEM t where exists(select * from PED_T CUR where T.PED_REF = CUR.REF);

                        insert into FECH_T
                        select * from FECH t where T.FECH_DATA <  ADD_MONTHS(SYSDATE,-60)  OR
EXISTS(
        (
                SELECT * FROM VIAGEM V WHERE V.REF = T.VIAGEM_REF AND 
                NOT EXISTS(
                        SELECT VIAGEM_REF, ETA FROM VIAGEM_ESCALA VE
                        WHERE VE.VIAGEM_REF = V.REF AND VE.ETA >=  ADD_MONTHS(SYSDATE,-60) 
                )
                AND EXISTS(
                        SELECT VIAGEM_REF, ETA FROM VIAGEM_ESCALA VE
                        WHERE VE.VIAGEM_REF = V.REF AND VE.ETA <  ADD_MONTHS(SYSDATE,-60) 
                )
        )
);

                        insert into CARTA_CRÉDITO_T
                        select * from CARTA_CRÉDITO;

                        insert into ESCRITÓRIO_T
                        select * from ESCRITÓRIO;

                        insert into FAX_T
                        select * from FAX t where T.MOMENTO_CRIA <  ADD_MONTHS(SYSDATE,-60);

                        insert into INSTRUÇÃO_PAG_T
                        select * from INSTRUÇÃO_PAG t where T.SOLICITAÇÃO_DATA <  ADD_MONTHS(SYSDATE,-60);

                        insert into DIVISÃO_T
                        select * from DIVISÃO;

                        insert into EMB_F_T
                        select * from EMB_F t where exists(select * from PED_T CUR where T.PED_REF = CUR.REF);

                        insert into EMB_T
                        select * from EMB t where exists(select * from VIAGEM_T CUR where T.VIAGEM = CUR.REF);

                        insert into NOTA_CRÉDITO_T
                        select * from NOTA_CRÉDITO t where T.DOC_DATA <  ADD_MONTHS(SYSDATE,-60);

                        insert into TIPO_REF_T
                        select * from TIPO_REF;

                        insert into FECH_CARGA_T
                        select * from FECH_CARGA t where exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF) or exists(select * from PED_ITEM_T CUR where T.PED_REF = CUR.PED_REF AND T.PED_ITEM = CUR.ITEM);

                        insert into CARTA_T
                        select * from CARTA t where T.DOC_DATA <  ADD_MONTHS(SYSDATE,-60);

                        insert into NOTA_DÉBITO_T
                        select * from NOTA_DÉBITO t where T.DOC_DATA <  ADD_MONTHS(SYSDATE,-60);

                        insert into RAMO_ATIVIDADE_T
                        select * from RAMO_ATIVIDADE;

                        insert into LANÇ_T
                        select * from LANÇ;

                        insert into PROG_T
                        select * from PROG t where exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF);

                        insert into DIVISÃO_TIPO_REF_T
                        select * from DIVISÃO_TIPO_REF;

                        insert into EMB_LANÇ_T
                        select * from EMB_LANÇ t where exists(select * from EMB_T CUR where T.EMB_REF = CUR.REF);

                        insert into EMB_DOC_REL_T
                        select * from EMB_DOC_REL t where exists(select * from EMB_T CUR where T.EMB_REL = CUR.REF);

                        insert into EMB_DOC_DESTINO_T
                        select * from EMB_DOC_DESTINO;

                        insert into CONTA_CORRENTE_T
                        select * from CONTA_CORRENTE;

                        insert into CIA_CONTATO_T
                        select * from CIA_CONTATO;

                        insert into CIA_RAMO_ATIVIDADE_T
                        select * from CIA_RAMO_ATIVIDADE;

                        insert into CONFIRM_VENDA_ITEM_T
                        select * from CONFIRM_VENDA_ITEM t where exists(select * from CONFIRM_VENDA_T CUR where T.CONFIRM_VENDA_REF = CUR.REF AND T.SEQ = CUR.SEQ);

                        insert into DIVISÃO_PRODUTO_T
                        select * from DIVISÃO_PRODUTO;

                        insert into EMB_MENSAGEM_T
                        select * from EMB_MENSAGEM t where exists(select * from EMB_T CUR where T.EMB_REF = CUR.REF);

                        insert into CARTA_FECH_T
                        select * from CARTA_FECH t where exists(select * from CARTA_T CUR where T.CARTA_REF = CUR.REF) or exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF);

                        insert into INSTRUÇÃO_PAG_FECH_T
                        select * from INSTRUÇÃO_PAG_FECH t where exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF) or exists(select * from INSTRUÇÃO_PAG_T CUR where T.INSTRUÇÃO_PAG_REF = CUR.REF);

                        insert into RESULT_T
                        select * from RESULT t where exists(select * from EMB_F_T CUR where T.PED_REF = CUR.PED_REF AND T.EMB_SEQ = CUR.SEQ);

                        insert into PROG_CARGA_T
                        select * from PROG_CARGA t where exists(select * from FECH_CARGA_T CUR where T.FECH_REF = CUR.FECH_REF AND T.PED_REF = CUR.PED_REF AND T.PED_ITEM = CUR.PED_ITEM) or exists(select * from PROG_T CUR where T.FECH_REF = CUR.FECH_REF AND T.POSICIONAMENTO_DATA = CUR.POSICIONAMENTO_DATA);

                        insert into PRODUTO_ESPECIF_T
                        select * from PRODUTO_ESPECIF;

                        insert into PED_RESULT_T
                        select * from PED_RESULT t where exists(select * from PED_T CUR where T.PED_REF = CUR.REF);

                        insert into PED_LANÇ_T
                        select * from PED_LANÇ t where exists(select * from PED_T CUR where T.PED_REF = CUR.REF);

                        insert into PED_CONTATO_T
                        select * from PED_CONTATO t where exists(select * from PED_T CUR where T.PED_REF = CUR.REF);

                        insert into NOTA_DÉBITO_RECEB_T
                        select * from NOTA_DÉBITO_RECEB t where exists(select * from NOTA_DÉBITO_T CUR where T.NOTA_DÉBITO_REF = CUR.REF);

                        insert into NOTA_DÉBITO_FECH_T
                        select * from NOTA_DÉBITO_FECH t where exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF) or exists(select * from NOTA_DÉBITO_T CUR where T.NOTA_DÉBITO_REF = CUR.REF);

                        insert into NOTA_CRÉDITO_PAG_T
                        select * from NOTA_CRÉDITO_PAG t where exists(select * from NOTA_CRÉDITO_T CUR where T.NOTA_CRÉDITO_REF = CUR.REF);

                        insert into FECH_CONTATO_T
                        select * from FECH_CONTATO t where exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF);

                        insert into LOCAL_RESULT_T
                        select * from LOCAL_RESULT;

                        insert into INCOTERM_LANÇ_T
                        select * from INCOTERM_LANÇ;

                        insert into FECH_SUBSTITUÍDO_T
                        select * from FECH_SUBSTITUÍDO t where exists(select * from FECH_T CUR where T.SUBSTITUTO = CUR.REF) or exists(select * from FECH_T CUR where T.SUBSTITUÍDO = CUR.REF);

                        insert into FAX_DESTINO_T
                        select * from FAX_DESTINO t where exists(select * from FAX_T CUR where T.FAX_REF = CUR.REF);

                        insert into FAX_CHAVE_T
                        select * from FAX_CHAVE t where exists(select * from FAX_T CUR where T.FAX_REF = CUR.REF);

                        insert into FATURA_T
                        select * from FATURA t where T.DOC_DATA <  ADD_MONTHS(SYSDATE,-60);

                        insert into EMB_TOTALIZA_T
                        select * from EMB_TOTALIZA t where exists(select * from EMB_T CUR where T.EMB_REF = CUR.REF);

                        insert into EMB_SD_T
                        select * from EMB_SD t where exists(select * from EMB_T CUR where T.EMB_REF = CUR.REF);

                        insert into NOTA_CRÉDITO_FECH_T
                        select * from NOTA_CRÉDITO_FECH t where exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF) or exists(select * from NOTA_CRÉDITO_T CUR where T.NOTA_CRÉDITO_REF = CUR.REF);

                        insert into EMB_RE_T
                        select * from EMB_RE t where exists(select * from EMB_T CUR where T.EMB_REF = CUR.REF);

                        insert into DOC_T
                        select * from DOC;

                        insert into BL_T
                        select * from BL t where T.BL_DATA <  ADD_MONTHS(SYSDATE,-60)  OR 
EXISTS(
        (
                SELECT * FROM VIAGEM V WHERE V.REF = T.VIAGEM_REF AND 
                NOT EXISTS(
                        SELECT VIAGEM_REF, ETA FROM VIAGEM_ESCALA VE
                        WHERE VE.VIAGEM_REF = V.REF AND VE.ETA >=  ADD_MONTHS(SYSDATE,-60) 
                )
                AND EXISTS(
                        SELECT VIAGEM_REF, ETA FROM VIAGEM_ESCALA VE
                        WHERE VE.VIAGEM_REF = V.REF AND VE.ETA <  ADD_MONTHS(SYSDATE,-60) 
                )
        )
) OR
EXISTS(
        SELECT REF FROM EMB E WHERE E.REF = T.EMB_REF AND 
        EXISTS(
                (
                        SELECT * FROM VIAGEM V WHERE V.REF = E.VIAGEM AND 
                        NOT EXISTS(
                                SELECT VIAGEM_REF, ETA FROM VIAGEM_ESCALA VE
                                WHERE VE.VIAGEM_REF = V.REF AND VE.ETA >=  ADD_MONTHS(SYSDATE,-60) 
                        )
                        AND EXISTS(
                                SELECT VIAGEM_REF, ETA FROM VIAGEM_ESCALA VE
                                WHERE VE.VIAGEM_REF = V.REF AND VE.ETA <  ADD_MONTHS(SYSDATE,-60) 
                        )
                )
        )
);

                        insert into EMB_FAMÍLIA_T
                        select * from EMB_FAMÍLIA t where exists(select * from EMB_T CUR where T.EMB_REF = CUR.REF);

                        insert into EMB_FAMÍLIA_GENÉRICA_T
                        select * from EMB_FAMÍLIA_GENÉRICA t where exists(select * from EMB_T CUR where T.EMB_REF = CUR.REF);

                        insert into BL_CARGA_T
                        select * from BL_CARGA t where exists(select * from BL_T CUR where T.VIAGEM_REF = CUR.VIAGEM_REF AND T.BL_SEQ = CUR.SEQ) or exists(select * from EMB_FAMÍLIA_GENÉRICA_T CUR where T.EMB_REF = CUR.EMB_REF AND T.FAMÍLIA_GENÉRICA = CUR.SEQ) or exists(select * from EMB_FAMÍLIA_T CUR where T.EMB_REF = CUR.EMB_REF AND T.FAMÍLIA = CUR.SEQ) or exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF) or exists(select * from PED_ITEM_T CUR where T.PED_REF = CUR.PED_REF AND T.PED_ITEM = CUR.ITEM);

                        COMMIT;

                        dbms_cx.log(reglog, 'Excluindo registros transferidos para o arquivo morto.');
                        dbms_cx.log(reglog, 'Apagando registros da tabela EMB_FAMÍLIA.');
                        delete from EMB_FAMÍLIA cur where
                        exists(select * from EMB_FAMÍLIA_t t where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela BL.');
                        delete from BL cur where
                        exists(select * from BL_t t where T.VIAGEM_REF = cur.VIAGEM_REF and T.SEQ = cur.SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela EMB_RE.');
                        delete from EMB_RE cur where
                        exists(select * from EMB_RE_t t where T.EMB_REF = cur.EMB_REF and T.RE = cur.RE);

                        dbms_cx.log(reglog, 'Apagando registros da tabela EMB_FAMÍLIA_GENÉRICA.');
                        delete from EMB_FAMÍLIA_GENÉRICA cur where
                        exists(select * from EMB_FAMÍLIA_GENÉRICA_t t where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela BL_CARGA.');
                        delete from BL_CARGA cur where
                        exists(select * from BL_CARGA_t t where T.PED_REF = cur.PED_REF and T.PED_ITEM = cur.PED_ITEM and T.VIAGEM_REF = cur.VIAGEM_REF and T.BL_SEQ = cur.BL_SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela EMB_MENSAGEM.');
                        delete from EMB_MENSAGEM cur where
                        exists(select * from EMB_MENSAGEM_t t where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela INSTRUÇÃO_PAG_FECH.');
                        delete from INSTRUÇÃO_PAG_FECH cur where
                        exists(select * from INSTRUÇÃO_PAG_FECH_t t where T.INSTRUÇÃO_PAG_REF = cur.INSTRUÇÃO_PAG_REF and T.FECH_REF = cur.FECH_REF);

                        dbms_cx.log(reglog, 'Apagando registros da tabela FECH_CONTATO.');
                        delete from FECH_CONTATO cur where
                        exists(select * from FECH_CONTATO_t t where T.FECH_REF = cur.FECH_REF and T.CIA_COD = cur.CIA_COD and T.CONTATO_NOME = cur.CONTATO_NOME);

                        dbms_cx.log(reglog, 'Apagando registros da tabela FAX_DESTINO.');
                        delete from FAX_DESTINO cur where
                        exists(select * from FAX_DESTINO_t t where T.FAX_REF = cur.FAX_REF and T.SEQ = cur.SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela FAX_CHAVE.');
                        delete from FAX_CHAVE cur where
                        exists(select * from FAX_CHAVE_t t where T.FAX_REF = cur.FAX_REF and T.CHAVE = cur.CHAVE);

                        dbms_cx.log(reglog, 'Apagando registros da tabela FATURA.');
                        delete from FATURA cur where
                        exists(select * from FATURA_t t where T.REF = cur.REF);

                        dbms_cx.log(reglog, 'Apagando registros da tabela EMB_TOTALIZA.');
                        delete from EMB_TOTALIZA cur where
                        exists(select * from EMB_TOTALIZA_t t where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela EMB_LANÇ.');
                        delete from EMB_LANÇ cur where
                        exists(select * from EMB_LANÇ_t t where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela CARTA_FECH.');
                        delete from CARTA_FECH cur where
                        exists(select * from CARTA_FECH_t t where T.CARTA_REF = cur.CARTA_REF and T.FECH_REF = cur.FECH_REF);

                        dbms_cx.log(reglog, 'Apagando registros da tabela CONFIRM_VENDA_ITEM.');
                        delete from CONFIRM_VENDA_ITEM cur where
                        exists(select * from CONFIRM_VENDA_ITEM_t t where T.CONFIRM_VENDA_REF = cur.CONFIRM_VENDA_REF and T.SEQ = cur.SEQ and T.ITEM = cur.ITEM);

                        dbms_cx.log(reglog, 'Apagando registros da tabela FECH_SUBSTITUÍDO.');
                        delete from FECH_SUBSTITUÍDO cur where
                        exists(select * from FECH_SUBSTITUÍDO_t t where T.SUBSTITUÍDO = cur.SUBSTITUÍDO and T.SUBSTITUTO = cur.SUBSTITUTO);

                        dbms_cx.log(reglog, 'Apagando registros da tabela EMB_DOC_REL.');
                        delete from EMB_DOC_REL cur where
                        exists(select * from EMB_DOC_REL_t t where T.EMB_REF = cur.EMB_REF and T.DOC = cur.DOC and T.EMB_REL = cur.EMB_REL);

                        dbms_cx.log(reglog, 'Apagando registros da tabela EMB_DOC_DESTINO.');
                        delete from EMB_DOC_DESTINO cur where
                        exists(select * from EMB_DOC_DESTINO_t t where T.EMB_REF = cur.EMB_REF and T.SEQ = cur.SEQ and T.CIA = cur.CIA);

                        dbms_cx.log(reglog, 'Apagando registros da tabela EMB_SD.');
                        delete from EMB_SD cur where
                        exists(select * from EMB_SD_t t where T.EMB_REF = cur.EMB_REF and T.SD = cur.SD);

                        dbms_cx.log(reglog, 'Apagando registros da tabela PED_CONTATO.');
                        delete from PED_CONTATO cur where
                        exists(select * from PED_CONTATO_t t where T.PED_REF = cur.PED_REF and T.CIA_COD = cur.CIA_COD and T.CONTATO_NOME = cur.CONTATO_NOME);

                        dbms_cx.log(reglog, 'Apagando registros da tabela RESULT.');
                        delete from RESULT cur where
                        exists(select * from RESULT_t t where T.PED_REF = cur.PED_REF and T.EMB_SEQ = cur.EMB_SEQ and T.SEQ = cur.SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela PROG_CARGA.');
                        delete from PROG_CARGA cur where
                        exists(select * from PROG_CARGA_t t where T.FECH_REF = cur.FECH_REF and T.POSICIONAMENTO_DATA = cur.POSICIONAMENTO_DATA and T.PED_REF = cur.PED_REF and T.PED_ITEM = cur.PED_ITEM);

                        dbms_cx.log(reglog, 'Apagando registros da tabela PED_RESULT.');
                        delete from PED_RESULT cur where
                        exists(select * from PED_RESULT_t t where T.PED_REF = cur.PED_REF and T.SEQ = cur.SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela PED_LANÇ.');
                        delete from PED_LANÇ cur where
                        exists(select * from PED_LANÇ_t t where T.PED_REF = cur.PED_REF and T.SEQ = cur.SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela NOTA_DÉBITO_RECEB.');
                        delete from NOTA_DÉBITO_RECEB cur where
                        exists(select * from NOTA_DÉBITO_RECEB_t t where T.NOTA_DÉBITO_REF = cur.NOTA_DÉBITO_REF and T.SEQ = cur.SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela NOTA_DÉBITO_FECH.');
                        delete from NOTA_DÉBITO_FECH cur where
                        exists(select * from NOTA_DÉBITO_FECH_t t where T.NOTA_DÉBITO_REF = cur.NOTA_DÉBITO_REF and T.FECH_REF = cur.FECH_REF);

                        dbms_cx.log(reglog, 'Apagando registros da tabela NOTA_CRÉDITO_PAG.');
                        delete from NOTA_CRÉDITO_PAG cur where
                        exists(select * from NOTA_CRÉDITO_PAG_t t where T.NOTA_CRÉDITO_REF = cur.NOTA_CRÉDITO_REF and T.SEQ = cur.SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela NOTA_CRÉDITO_FECH.');
                        delete from NOTA_CRÉDITO_FECH cur where
                        exists(select * from NOTA_CRÉDITO_FECH_t t where T.NOTA_CRÉDITO_REF = cur.NOTA_CRÉDITO_REF and T.FECH_REF = cur.FECH_REF);

                        dbms_cx.log(reglog, 'Apagando registros da tabela CARTA.');
                        delete from CARTA cur where
                        exists(select * from CARTA_t t where T.REF = cur.REF);

                        dbms_cx.log(reglog, 'Apagando registros da tabela PROG.');
                        delete from PROG cur where
                        exists(select * from PROG_t t where T.FECH_REF = cur.FECH_REF and T.POSICIONAMENTO_DATA = cur.POSICIONAMENTO_DATA);

                        dbms_cx.log(reglog, 'Apagando registros da tabela NOTA_DÉBITO.');
                        delete from NOTA_DÉBITO cur where
                        exists(select * from NOTA_DÉBITO_t t where T.REF = cur.REF);

                        dbms_cx.log(reglog, 'Apagando registros da tabela FAX.');
                        delete from FAX cur where
                        exists(select * from FAX_t t where T.REF = cur.REF);

                        dbms_cx.log(reglog, 'Apagando registros da tabela EMB_F.');
                        delete from EMB_F cur where
                        exists(select * from EMB_F_t t where T.PED_REF = cur.PED_REF and T.SEQ = cur.SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela INSTRUÇÃO_PAG.');
                        delete from INSTRUÇÃO_PAG cur where
                        exists(select * from INSTRUÇÃO_PAG_t t where T.REF = cur.REF);

                        dbms_cx.log(reglog, 'Apagando registros da tabela EMB.');
                        delete from EMB cur where
                        exists(select * from EMB_t t where T.REF = cur.REF);

                        dbms_cx.log(reglog, 'Apagando registros da tabela FECH_CARGA.');
                        delete from FECH_CARGA cur where
                        exists(select * from FECH_CARGA_t t where T.FECH_REF = cur.FECH_REF and T.PED_REF = cur.PED_REF and T.PED_ITEM = cur.PED_ITEM);

                        dbms_cx.log(reglog, 'Apagando registros da tabela NOTA_CRÉDITO.');
                        delete from NOTA_CRÉDITO cur where
                        exists(select * from NOTA_CRÉDITO_t t where T.REF = cur.REF);

                        dbms_cx.log(reglog, 'Apagando registros da tabela PED_ITEM.');
                        delete from PED_ITEM cur where
                        exists(select * from PED_ITEM_t t where T.PED_REF = cur.PED_REF and T.ITEM = cur.ITEM);

                        dbms_cx.log(reglog, 'Apagando registros da tabela CONFIRM_VENDA.');
                        delete from CONFIRM_VENDA cur where
                        exists(select * from CONFIRM_VENDA_t t where T.REF = cur.REF and T.SEQ = cur.SEQ);

                        dbms_cx.log(reglog, 'Apagando registros da tabela FECH.');
                        delete from FECH cur where
                        exists(select * from FECH_t t where T.REF = cur.REF);

                        dbms_cx.log(reglog, 'Apagando registros da tabela VIAGEM_ESCALA.');
                        delete from VIAGEM_ESCALA cur where
                        exists(select * from VIAGEM_ESCALA_t t where T.VIAGEM_REF = cur.VIAGEM_REF and T.ESCALA = cur.ESCALA);

                        dbms_cx.log(reglog, 'Apagando registros da tabela PED.');
                        delete from PED cur where
                        exists(select * from PED_t t where T.REF = cur.REF);

                        dbms_cx.log(reglog, 'Apagando registros da tabela VIAGEM.');
                        delete from VIAGEM cur where
                        exists(select * from VIAGEM_t t where T.REF = cur.REF);

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

