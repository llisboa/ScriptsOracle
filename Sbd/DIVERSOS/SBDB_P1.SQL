/* **********************************************************************************
   INTERCRAFT SOLUTIONS INFORMÁTICA LTDA - 2008
   SCRIPT CRIADO EM 21/09/2011 23:44

   IMPORTANTE!!!
   * O SISTEMA LOGARÁ SYSTEM PARA INICIAR A EXECUÇÃO, LOGO, MUITO CUIDADO!
   * CASO O USUÁRIO DO ESQUEMA JÁ EXISTA, ESTE SERÁ ELIMINADO, PORTANTO, TENHA A CERTEZA DAQUILO QUE ESTÁ FAZENDO.
   * ARQUIVO C:\SBDB.LOG REGISTRARÁ O LOG DE EXECUÇÃO, QUE DEVE SER VERIFICADO.
   * CASO BANCO POSSUA ACENTOS, PRECISARÁ GARANTIR FORMATO ANSI ANTES DA EXECUÇÃO. PARA ISSO, EDITE O CONTEÚDO NO NOTEPAD E SALVE FAZENDO OPÇÃO POR ESTE FORMATO.
*/

SET ECHO ON
SET HEADING OFF
SET PAGESIZE 0
SET LINES 10000
SET LINESIZE 10000
SET SERVEROUTPUT ON SIZE 40000
SPOOL C:\SBDB_PARTE1.LOG

-- GARANTINDO QUE TODOS TENHA ACESSO AOS RECURSOS DE PACOTE
CONNECT SYS/XXXX@SBDB AS SYSDBA
GRANT EXECUTE ON SYS.UTL_FILE TO PUBLIC;
GRANT EXECUTE ON SYS.UTL_SMTP TO PUBLIC;
GRANT EXECUTE ON SYS.UTL_TCP TO PUBLIC;
GRANT SELECT ON SYS.V_$SESSION TO PUBLIC;
GRANT QUERY REWRITE TO PUBLIC;
GRANT CREATE MATERIALIZED VIEW TO PUBLIC;
ALTER SESSION SET QUERY_REWRITE_ENABLED = TRUE;

-- ELIMINA OS JOBS
begin
for cur in (select job from user_jobs where schema_user='SBDB') loop
dbms_job.remove(cur.job);
end loop;
end;
/

-- INICIALIZANDO TABLESPACE
ALTER TABLESPACE T_SBDB_DAT OFFLINE;
DROP TABLESPACE T_SBDB_DAT INCLUDING CONTENTS;
CREATE TABLESPACE T_SBDB_DAT DATAFILE 'C:\oracle\product\10.2.0\oradata\SBDB\SBDB.DBF' SIZE 100M REUSE
AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL;

-- DEFININDO USUÁRIO DE ESQUEMA
DROP USER SBDB CASCADE;
CREATE USER SBDB IDENTIFIED BY XXXXXX DEFAULT TABLESPACE T_SBDB_DAT;
GRANT DBA TO SBDB;
GRANT SELECT ON DBA_JOBS TO SBDB;
GRANT ALL PRIVILEGES TO SBDB;

-- CONECTANDO COM USUÁRIO DE ESQUEMA
DISCONNECT;
CONNECT SBDB/XXXX@SBDB;

/* **********************************************************************************
   CRIAÇÃO DE TABELAS
*/

-- TABELA ADM_HIST_TED
CREATE TABLE SBDB."ADM_HIST_TED" (
   "SOCIO_MAT" NUMBER (5,0),
   "SEQ" NUMBER (3,0),
   "SERV_CRED_COD" NUMBER (5,0),
   "DATA_PROVA" DATE,
   "SITUACAO" NUMBER (1,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."ADM_HIST_TED" ADD CONSTRAINT "ID_ADM_HIST_TED"
PRIMARY KEY("SOCIO_MAT", "SEQ");

COMMENT ON TABLE SBDB."ADM_HIST_TED" IS 'SERVIÇO CRED | Cadastro do histórico de provas do TED. | Histórico do TED';

COMMENT ON COLUMN SBDB."ADM_HIST_TED"."SOCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."ADM_HIST_TED"."SEQ" IS 'Sequencial do histórico do TED. | Sequencial';
COMMENT ON COLUMN SBDB."ADM_HIST_TED"."SERV_CRED_COD" IS 'Sequencial do serviço credenciado. | Sequencial do Serviço Credenciado';
COMMENT ON COLUMN SBDB."ADM_HIST_TED"."DATA_PROVA" IS 'Data da prova. | Data da Prova';
COMMENT ON COLUMN SBDB."ADM_HIST_TED"."SITUACAO" IS 'Status de aprovação no TED. | Aprovado?';
COMMENT ON COLUMN SBDB."ADM_HIST_TED".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."ADM_HIST_TED".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."ADM_HIST_TED".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."ADM_HIST_TED".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."ADM_HIST_TED".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."ADM_HIST_TED".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."ADM_HIST_TED".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA ANUIDADE_CATEGORIA
CREATE TABLE SBDB."ANUIDADE_CATEGORIA" (
   "ANUIDADE_REF" NUMBER (4,0),
   "CATEGORIA_COD" VARCHAR2 (20),
   "VALOR" FLOAT,
   "JUROS" FLOAT,
   "MULTA" FLOAT,
   "DESCONTO" FLOAT,
   "DATA_DESCONTO" DATE
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."ANUIDADE_CATEGORIA" ADD CONSTRAINT "ID_ANUIDADE_CATEGORIA"
PRIMARY KEY("ANUIDADE_REF", "CATEGORIA_COD", "DATA_DESCONTO");

COMMENT ON TABLE SBDB."ANUIDADE_CATEGORIA" IS 'FINANCEIRO | Cadastro das dos valores das anuidades por categoria. | Categoria da Anuidade';

COMMENT ON COLUMN SBDB."ANUIDADE_CATEGORIA"."ANUIDADE_REF" IS 'Anuidade da obrigação. | Anuidade';
COMMENT ON COLUMN SBDB."ANUIDADE_CATEGORIA"."CATEGORIA_COD" IS 'Categoria do associado. | Categoria';
COMMENT ON COLUMN SBDB."ANUIDADE_CATEGORIA"."VALOR" IS 'Valor da obrigação para a categoria. | Valor da Anuidade';
COMMENT ON COLUMN SBDB."ANUIDADE_CATEGORIA"."JUROS" IS 'Valor do juro. | Valor do Juro';
COMMENT ON COLUMN SBDB."ANUIDADE_CATEGORIA"."MULTA" IS 'Valor da multa. | Valor da Multa';
COMMENT ON COLUMN SBDB."ANUIDADE_CATEGORIA"."DESCONTO" IS 'Valor do desconto. | Valor do Desconto';
COMMENT ON COLUMN SBDB."ANUIDADE_CATEGORIA"."DATA_DESCONTO" IS 'Data de validade para desconto. | Data Limite do Desconto';
COMMENT ON COLUMN SBDB."ANUIDADE_CATEGORIA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."ANUIDADE_CATEGORIA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."ANUIDADE_CATEGORIA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."ANUIDADE_CATEGORIA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."ANUIDADE_CATEGORIA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."ANUIDADE_CATEGORIA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."ANUIDADE_CATEGORIA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA ARQ_PAGAMENTO
CREATE TABLE SBDB."ARQ_PAGAMENTO" (
   "ARQ_SEQ" NUMBER (5,0),
   "SEQ" NUMBER (5,0),
   "MATR" NUMBER (5,0),
   "TIPO_OBRIG" VARCHAR2 (10),
   "DATA_PAG" DATE,
   "DATA_VENC" DATE,
   "VALOR" FLOAT,
   "ARQUIVO" VARCHAR2 (50),
   "LINHA" NUMBER (5,0),
   "LOG" VARCHAR2 (200),
   "LOG_ANT" VARCHAR2 (200)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."ARQ_PAGAMENTO" ADD CONSTRAINT "ID_ARQ_PAGAMENTO"
PRIMARY KEY("ARQ_SEQ", "SEQ");

COMMENT ON TABLE SBDB."ARQ_PAGAMENTO" IS 'FINANCEIRO | Cadastro dos pagamentos do arquivos de retorno e o log dos pagamentos nele contido. | Arquivo de Pagamento';

COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO"."ARQ_SEQ" IS 'Sequencial do arquivo de retorno CNAB. | Sequencial do Arquivo de Retorno';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO"."SEQ" IS 'Sequencial da linha do arquivo inserida. | Sequencial';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO"."MATR" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO"."TIPO_OBRIG" IS 'Tipo obrigação. | Tipo de Obrigação';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO"."DATA_PAG" IS 'Data do pagamento. | Data do Pagamento';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO"."DATA_VENC" IS 'Data do vencimento. | Data do Vencimento';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO"."VALOR" IS 'Valor do pagamento. | Valor';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO"."ARQUIVO" IS 'Nome do arquivo de origem. | Nome do Arquivo';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO"."LINHA" IS 'Linha do arquivo origem. | Nº da Linha do Arquivo Origem';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO"."LOG" IS 'Informação sobre a leitura da linha. | Log';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO"."LOG_ANT" IS 'Antigo log. | Log Anterior';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."ARQ_PAGAMENTO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA ARQ_REMESSA
CREATE TABLE SBDB."ARQ_REMESSA" (
   "SEQ" NUMBER (5,0),
   "NOME_ARQ" VARCHAR2 (50),
   "DATA_GERAÇÃO" DATE,
   "QTD_REGISTROS" NUMBER (5,0),
   "STATUS" NUMBER (1,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."ARQ_REMESSA" ADD CONSTRAINT "ID_ARQ_REMESSA"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."ARQ_REMESSA" IS 'FINANCEIRO | Armazena as informações referente aos arquivos CNABs enviados ao banco. | Arquivo de Remessa';

COMMENT ON COLUMN SBDB."ARQ_REMESSA"."SEQ" IS 'Sequencial do arquivo de remessa. | Sequencial';
COMMENT ON COLUMN SBDB."ARQ_REMESSA"."NOME_ARQ" IS 'Nome do arquivo de remessa. | Nome do Arquivo de Origem';
COMMENT ON COLUMN SBDB."ARQ_REMESSA"."DATA_GERAÇÃO" IS 'Data da criação do arquivo da remessa. | Data de Criação do Arquivo';
COMMENT ON COLUMN SBDB."ARQ_REMESSA"."QTD_REGISTROS" IS 'Quantidade de registros criados. | Quantidade de Registros Criados';
COMMENT ON COLUMN SBDB."ARQ_REMESSA"."STATUS" IS 'Status de envio. | Remetido?';
COMMENT ON COLUMN SBDB."ARQ_REMESSA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."ARQ_REMESSA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."ARQ_REMESSA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."ARQ_REMESSA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."ARQ_REMESSA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."ARQ_REMESSA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."ARQ_REMESSA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA ARQ_RETORNO
CREATE TABLE SBDB."ARQ_RETORNO" (
   "SEQ" NUMBER (5,0),
   "NOME" VARCHAR2 (20),
   "NOME_ANTERIOR" VARCHAR2 (20),
   "DATA_PAG" DATE,
   "QTD_REGISTRO" NUMBER (5,0),
   "DATA_IMPORTAÇÃO" DATE,
   "STATUS" NUMBER (1,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."ARQ_RETORNO" ADD CONSTRAINT "ID_ARQ_RETORNO"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."ARQ_RETORNO" IS 'FINANCEIRO | Cadastro dos arquivos de retorno baixados. | Arquivo de Retorno';

COMMENT ON COLUMN SBDB."ARQ_RETORNO"."SEQ" IS 'Sequencial do arquivo. | Sequencial';
COMMENT ON COLUMN SBDB."ARQ_RETORNO"."NOME" IS 'Nome do arquivo. | Nome do Arquivo';
COMMENT ON COLUMN SBDB."ARQ_RETORNO"."NOME_ANTERIOR" IS 'Nome anterior do arquivo. | Nome do Arquivo antigo (Safra)';
COMMENT ON COLUMN SBDB."ARQ_RETORNO"."DATA_PAG" IS 'Data de pagamento. | Data do Pagamento';
COMMENT ON COLUMN SBDB."ARQ_RETORNO"."QTD_REGISTRO" IS 'Quantidade de registros. | Quantidade de registros';
COMMENT ON COLUMN SBDB."ARQ_RETORNO"."DATA_IMPORTAÇÃO" IS 'Data da importação. | Data de Importação';
COMMENT ON COLUMN SBDB."ARQ_RETORNO"."STATUS" IS 'Status de retorno. | Retornou?';
COMMENT ON COLUMN SBDB."ARQ_RETORNO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."ARQ_RETORNO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."ARQ_RETORNO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."ARQ_RETORNO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."ARQ_RETORNO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."ARQ_RETORNO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."ARQ_RETORNO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA BIBLIO_LANCAMENTO
CREATE TABLE SBDB."BIBLIO_LANCAMENTO" (
   "COD" NUMBER (5,0),
   "COD_PEDIDO" VARCHAR2 (6),
   "VALOR" FLOAT,
   "DATA" DATE
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."BIBLIO_LANCAMENTO" ADD CONSTRAINT "ID_BIBLIO_LANCAMENTO"
PRIMARY KEY("COD");

COMMENT ON TABLE SBDB."BIBLIO_LANCAMENTO" IS 'BIBLIOTECA | Informações de movimentações financeiras de débito e crédito geradas pelo controle de pedidos. | Lançamento da Biblioteca';

COMMENT ON COLUMN SBDB."BIBLIO_LANCAMENTO"."COD" IS 'Sequencial do lançamento da biblioteca. | Sequencial';
COMMENT ON COLUMN SBDB."BIBLIO_LANCAMENTO"."COD_PEDIDO" IS 'Sequencial do pedido. | Sequencial do Pedido';
COMMENT ON COLUMN SBDB."BIBLIO_LANCAMENTO"."VALOR" IS 'Valor do pedido. | Valor';
COMMENT ON COLUMN SBDB."BIBLIO_LANCAMENTO"."DATA" IS 'Data do pedido. | Data';
COMMENT ON COLUMN SBDB."BIBLIO_LANCAMENTO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."BIBLIO_LANCAMENTO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."BIBLIO_LANCAMENTO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."BIBLIO_LANCAMENTO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."BIBLIO_LANCAMENTO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."BIBLIO_LANCAMENTO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."BIBLIO_LANCAMENTO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA BIBLIO_PEDIDO
CREATE TABLE SBDB."BIBLIO_PEDIDO" (
   "COD" VARCHAR2 (6),
   "MAT_ASSOCIADO" NUMBER (5,0),
   "COD_REQUISITANTE" NUMBER (5,0),
   "DATA_ENTRADA" DATE,
   "DATA_ATENDIMENTO" DATE,
   "CANCELADO" NUMBER (1,0),
   "OBRIG_SEQ" NUMBER (5,0),
   "VIA_ENTRADA" VARCHAR2 (10),
   "VIA_ATENDIMENTO" VARCHAR2 (10),
   "COD_SERVICO" NUMBER (5,0),
   "QUANTIDADE" NUMBER (5,0),
   "QTDE_ATENDIDOS" NUMBER (5,0),
   "CUSTO_SERVICO" FLOAT,
   "CUSTO_POSTAGEM" FLOAT,
   "OBS" VARCHAR2 (4000),
   "QTDE_COPIAS" NUMBER (5,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."BIBLIO_PEDIDO" ADD CONSTRAINT "ID_BIBLIO_PEDIDO"
PRIMARY KEY("COD");

COMMENT ON TABLE SBDB."BIBLIO_PEDIDO" IS 'BIBLIOTECA | Cadastro de pedidos de serviços feitos pelos requisitantes. | Pedido da Biblioteca';

COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."COD" IS 'Sequencial do pedido. | Sequencial';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."MAT_ASSOCIADO" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."COD_REQUISITANTE" IS 'Sequencial do requisitante. | Sequencial do Requisitante';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."DATA_ENTRADA" IS 'Data da entrada. | Data de Entrada';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."DATA_ATENDIMENTO" IS 'Data de atendimento. | Data de Atendimento';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."CANCELADO" IS 'Quantidade de itens cancelados. | Atendimento Cancelado';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."OBRIG_SEQ" IS 'Sequencial da obrigação gerada. | Sequencial da Obrigação';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."VIA_ENTRADA" IS 'Forma de solicitação. | Forma de Solicitação';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."VIA_ATENDIMENTO" IS 'Forma de atendimento. | Forma de Atendimento';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."COD_SERVICO" IS 'Sequencial do serviço credenciado. | Sequencial do Serviço';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."QUANTIDADE" IS 'Quantidade. | Quantidade';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."QTDE_ATENDIDOS" IS 'Quantidade atendida. | Quantidade de Atendimento';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."CUSTO_SERVICO" IS 'Custo do serviço. | Custo do Serviço';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."CUSTO_POSTAGEM" IS 'Custo da postagem. | Custo da Postagem';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO"."QTDE_COPIAS" IS 'Quantidade de cópias. | Quantidade de Cópia';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."BIBLIO_PEDIDO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA BIBLIO_REQUISITANTE
CREATE TABLE SBDB."BIBLIO_REQUISITANTE" (
   "COD" NUMBER (5,0),
   "NOME" VARCHAR2 (50),
   "ENDERECO" VARCHAR2 (100),
   "BAIRRO" VARCHAR2 (50),
   "CIDADE" VARCHAR2 (50),
   "ESTADO" VARCHAR2 (2),
   "TELEFONE" VARCHAR2 (4000),
   "FAX" VARCHAR2 (4000),
   "OBS" VARCHAR2 (4000),
   "CPF" VARCHAR2 (12),
   "PASSAPORTE" VARCHAR2 (10)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."BIBLIO_REQUISITANTE" ADD CONSTRAINT "ID_BIBLIO_REQUISITANTE"
PRIMARY KEY("COD");

COMMENT ON TABLE SBDB."BIBLIO_REQUISITANTE" IS 'BIBLIOTECA | Cadastro de requisitantes não-associados. | Requisitante da Biblioteca';

COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE"."COD" IS 'Sequencial do requisitante. | Sequencial';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE"."NOME" IS 'Nome do requisitante. | Nome';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE"."ENDERECO" IS 'Endereço completo, tipo (rua, av.), logradouro e número. | Endereço Completo';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE"."BAIRRO" IS 'Bairro. | Bairro';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE"."CIDADE" IS 'Cidade do requisitante. | Cidade';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE"."ESTADO" IS 'Estado do requisitante. | Estado';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE"."TELEFONE" IS 'Telefone do requisitante. | Telefone';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE"."FAX" IS 'Fax do requisitante. | Fax';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE"."OBS" IS 'Observação do requisitante. | Observação';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE"."CPF" IS 'CPF do requisitante. | CPF';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE"."PASSAPORTE" IS 'Passaporte do requisitante. | Passaporte';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."BIBLIO_REQUISITANTE".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA BIBLIO_SERVICO
CREATE TABLE SBDB."BIBLIO_SERVICO" (
   "COD" NUMBER (5,0),
   "DESCRICAO" VARCHAR2 (50),
   "OBS" VARCHAR2 (4000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."BIBLIO_SERVICO" ADD CONSTRAINT "ID_BIBLIO_SERVICO"
PRIMARY KEY("COD");

COMMENT ON TABLE SBDB."BIBLIO_SERVICO" IS 'BIBLIOTECA | Cadastro de serviços prestados pela biblioteca. | Serviço da Biblioteca';

COMMENT ON COLUMN SBDB."BIBLIO_SERVICO"."COD" IS 'Sequencial do serviço credenciado. | Sequencial';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO"."DESCRICAO" IS 'Descrição do serviço. | Descrição';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO"."OBS" IS 'Observação do serviço. | Observação';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA BIBLIO_SERVICO_PRECO
CREATE TABLE SBDB."BIBLIO_SERVICO_PRECO" (
   "COD_SERVICO" NUMBER (5,0),
   "SEQ" NUMBER (5,0),
   "PRECO_ASSOC" FLOAT,
   "PRECO_NASSOC" FLOAT,
   "DATA" DATE
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."BIBLIO_SERVICO_PRECO" ADD CONSTRAINT "ID_BIBLIO_SERVICO_PRECO"
PRIMARY KEY("COD_SERVICO", "SEQ");

COMMENT ON TABLE SBDB."BIBLIO_SERVICO_PRECO" IS 'BIBLIOTECA | Registro de valores de cada serviço. | Preço do Serviço da Biblioteca';

COMMENT ON COLUMN SBDB."BIBLIO_SERVICO_PRECO"."COD_SERVICO" IS 'Sequencial  do serviço. | Sequencial do Serviço';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO_PRECO"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO_PRECO"."PRECO_ASSOC" IS 'Preço para associado. | Preço para Associado';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO_PRECO"."PRECO_NASSOC" IS 'Preço para não associado. | Preço para Não Associado';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO_PRECO"."DATA" IS 'Data de cadastro. | Data de Cadastro';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO_PRECO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO_PRECO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO_PRECO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO_PRECO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO_PRECO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO_PRECO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."BIBLIO_SERVICO_PRECO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA BOLETO
CREATE TABLE SBDB."BOLETO" (
   "SEQ" NUMBER (11,0),
   "BANCO_NUMERO" NUMBER (3,0),
   "CARTEIRA" NUMBER (3,0),
   "DATA_EMISSAO" DATE,
   "DATA_VENCIM" DATE,
   "NOSSO_NUM" VARCHAR2 (50),
   "VALOR" NUMBER (16,2),
   "TARIFA" NUMBER (11,2),
   "PRODUTO_SEQ" NUMBER (10,0),
   "PRODUTO_NOME" VARCHAR2 (200),
   "PRODUTO_REF" VARCHAR2 (200),
   "CEDENTE_NOME" VARCHAR2 (50),
   "CEDENTE_LOGO" VARCHAR2 (200),
   "CEDENTE_AGENCIA" NUMBER (4,0),
   "CEDENTE_CONTADAC" NUMBER (6,0),
   "CEDENTE_COD_CLIENTE" NUMBER (5,0),
   "SACADO_SOCIO_MAT" NUMBER (5,0),
   "SACADO_CPF" VARCHAR2 (12),
   "SACADO_CNPJ" VARCHAR2 (50),
   "SACADO_NOME" VARCHAR2 (50),
   "SACADO_ENDERECO" VARCHAR2 (200),
   "SACADO_NUMERO" VARCHAR2 (20),
   "SACADO_COMPLEMENTO" VARCHAR2 (30),
   "SACADO_BAIRRO" VARCHAR2 (50),
   "SACADO_CIDADE" VARCHAR2 (50),
   "SACADO_ESTADO" VARCHAR2 (2),
   "SACADO_CEP" VARCHAR2 (10),
   "SACADO_TEL_RES" VARCHAR2 (50),
   "SACADO_TEL_COM" VARCHAR2 (50),
   "SACADO_TEL_CEL" VARCHAR2 (50),
   "SACADO_EMAIL" VARCHAR2 (200),
   "INSTRUCAO_SUP_1" VARCHAR2 (80),
   "INSTRUCAO_SUP_2" VARCHAR2 (80),
   "INSTRUCAO_INF_1" VARCHAR2 (80),
   "INSTRUCAO_INF_2" VARCHAR2 (80),
   "INSTRUCAO_INF_3" VARCHAR2 (80),
   "INSTRUCAO_INF_4" VARCHAR2 (80),
   "INSTRUCAO_INF_5" VARCHAR2 (80),
   "INSTRUCAO_INF_6" VARCHAR2 (80),
   "CONFIRM_PAGAM_AG_COBR" NUMBER (11,0),
   "CONFIRM_PAGAM_OPER" VARCHAR2 (20),
   "CONFIRM_PAGAM_IOF" NUMBER (11,2),
   "CONFIRM_PAGAM_ABAT" NUMBER (11,2),
   "CONFIRM_PAGAM_DESC" NUMBER (11,2),
   "CONFIRM_PAGAM_JUROS" NUMBER (11,2),
   "CONFIRM_PAGAM_DESP_ADM" NUMBER (11,2),
   "CONFIRM_PAGAM_DATA" DATE,
   "CONFIRM_PAGAM_OUTROS_CRED" FLOAT,
   "CONFIRM_PAGAM_COD_LIQ" VARCHAR2 (2),
   "CONFIRM_PAGAM_VALOR" NUMBER (16,2),
   "BAIXA_CONDICAO" VARCHAR2 (1),
   "BAIXA_DATA" DATE,
   "BAIXA_OBS" VARCHAR2 (4000),
   "BAIXA_OPER" VARCHAR2 (100),
   "OPER_SEQ" NUMBER (11,0),
   "CANCEL_DATA" DATE,
   "CANCEL_OPER" VARCHAR2 (20),
   "CANCEL_MOTIVO" VARCHAR2 (1000),
   "CANCEL" NUMBER (1,0),
   "REMESSA_ARQUIVO" VARCHAR2 (100),
   "REMESSA_LOTE" NUMBER (11,0),
   "REMESSA_LINHA" NUMBER (11,0),
   "REMESSA_DATA_ENVIO" DATE,
   "REMESSA_OPER" VARCHAR2 (100),
   "RETORNO_ARQUIVO" VARCHAR2 (100),
   "RETORNO_LOTE" NUMBER (11,0),
   "RETORNO_LINHA" NUMBER (11,0),
   "RETORNO_DATA_RECEB" DATE,
   "RETORNO_OPER" VARCHAR2 (100),
   "CEDENTE_CNPJ" VARCHAR2 (50),
   "NOTIFICA_DATA" DATE
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."BOLETO" ADD CONSTRAINT "ID_BOLETO"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."BOLETO" IS 'FINANCEIRO | Cadastro consolidado de boletos da SBD. | Boleto da SBD';

COMMENT ON COLUMN SBDB."BOLETO"."SEQ" IS 'Referência do boleto e número para impressão no documento. | Número do Documento';
COMMENT ON COLUMN SBDB."BOLETO"."BANCO_NUMERO" IS 'Banco. | Banco';
COMMENT ON COLUMN SBDB."BOLETO"."CARTEIRA" IS 'Número da carteira utilizada. | Número da Carteira';
COMMENT ON COLUMN SBDB."BOLETO"."DATA_EMISSAO" IS 'Data da emissão do boleto. | Data de Emissão';
COMMENT ON COLUMN SBDB."BOLETO"."DATA_VENCIM" IS 'Data de vencimento do boleto. | Data de Vencimento';
COMMENT ON COLUMN SBDB."BOLETO"."NOSSO_NUM" IS 'Nosso número enviado ao banco para identificação do boleto. | Nosso Número';
COMMENT ON COLUMN SBDB."BOLETO"."VALOR" IS 'Valor do boleto a ser pago. | Valor';
COMMENT ON COLUMN SBDB."BOLETO"."TARIFA" IS 'Valor referente a taxa administrativa do banco. | Valor Tarifa';
COMMENT ON COLUMN SBDB."BOLETO"."PRODUTO_SEQ" IS 'Referência do produto negociado. | Produto da SBD negociado';
COMMENT ON COLUMN SBDB."BOLETO"."PRODUTO_NOME" IS 'Nome do produto ou da condição negociada. | Nome do Produto Negociado';
COMMENT ON COLUMN SBDB."BOLETO"."PRODUTO_REF" IS 'Referência do produto aplicável (campos de chave do repositório do produto vinculado separados por ponto e vírgula). | Referência do Produto Negociado';
COMMENT ON COLUMN SBDB."BOLETO"."CEDENTE_NOME" IS 'Nome do cedente. | Cedente';
COMMENT ON COLUMN SBDB."BOLETO"."CEDENTE_LOGO" IS 'Logo que aparece como cedente. | Logotipo do Cedente';
COMMENT ON COLUMN SBDB."BOLETO"."CEDENTE_AGENCIA" IS 'Agência sem dígito verificador do cedente. | Número da Agência';
COMMENT ON COLUMN SBDB."BOLETO"."CEDENTE_CONTADAC" IS 'Conta seguida de dígito verificador. | Número da Conta e Dígito';
COMMENT ON COLUMN SBDB."BOLETO"."CEDENTE_COD_CLIENTE" IS 'Código do cliente informado pelo banco. | Código do Cliente';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_SOCIO_MAT" IS 'Matrícula do associado quando o negócio considerá-lo como sacado. | Matrícula Associado';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_CPF" IS 'CPF do sacado (pode informar matrícula para obter dados automaticamente). | CPF';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_CNPJ" IS 'CPNJ quando pessoa jurídica. | CNPJ';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_NOME" IS 'Nome que aparece no campo de sacado no boleto. | Nome do Sacado';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_ENDERECO" IS 'Endereço completo, tipo (rua, av.), logradouro e número do sacado. | Endereço Completo';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_NUMERO" IS 'Número do endereço do sacado. | Número';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_COMPLEMENTO" IS 'Complemento do endereço do sacado. | Complemento';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_BAIRRO" IS 'Bairro do sacado. | Bairro';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_CIDADE" IS 'Nome da cidade do sacado. | Cidade';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_ESTADO" IS 'Estado do sacado. | Estado';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_CEP" IS 'CEP do sacado. | CEP';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_TEL_RES" IS 'Número do telefone residencial no formato: DDI DDD e TELEFONE. | Telefone da Residência';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_TEL_COM" IS 'Número do telefone comercial no formato: DDI DDD e TELEFONE. | Telefone Comercial';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_TEL_CEL" IS 'Número do telefone celular: DDI DDD e TELEFONE. | Telefone Celular';
COMMENT ON COLUMN SBDB."BOLETO"."SACADO_EMAIL" IS 'Emails para contato com o sacado. | E-mail';
COMMENT ON COLUMN SBDB."BOLETO"."INSTRUCAO_SUP_1" IS 'Linha de instrução superior. | Instrução Superior 1';
COMMENT ON COLUMN SBDB."BOLETO"."INSTRUCAO_SUP_2" IS 'Linha de instrução superior. | Instrução Superior 2';
COMMENT ON COLUMN SBDB."BOLETO"."INSTRUCAO_INF_1" IS 'Linha de instrução inferior. | Instrução Inferior 1';
COMMENT ON COLUMN SBDB."BOLETO"."INSTRUCAO_INF_2" IS 'Linha de instrução inferior. | Instrução Inferior 2';
COMMENT ON COLUMN SBDB."BOLETO"."INSTRUCAO_INF_3" IS 'Linha de instrução inferior. | Instrução Inferior 3';
COMMENT ON COLUMN SBDB."BOLETO"."INSTRUCAO_INF_4" IS 'Linha de instrução inferior. | Instrução Inferior 4';
COMMENT ON COLUMN SBDB."BOLETO"."INSTRUCAO_INF_5" IS 'Linha de instrução inferior. | Instrução Inferior 5';
COMMENT ON COLUMN SBDB."BOLETO"."INSTRUCAO_INF_6" IS 'Linha de instrução inferior. | Instrução Inferior 6';
COMMENT ON COLUMN SBDB."BOLETO"."CONFIRM_PAGAM_AG_COBR" IS 'Número da agência onde o sacado paga o boleto. | Agência Cobradora';
COMMENT ON COLUMN SBDB."BOLETO"."CONFIRM_PAGAM_OPER" IS 'Operador responsável pela baixa. | Operador Responsável';
COMMENT ON COLUMN SBDB."BOLETO"."CONFIRM_PAGAM_IOF" IS 'Valor do IOF que foi recolhido. | Valor IOF';
COMMENT ON COLUMN SBDB."BOLETO"."CONFIRM_PAGAM_ABAT" IS 'Valor do abatimento concedido. | Valor Abatimento';
COMMENT ON COLUMN SBDB."BOLETO"."CONFIRM_PAGAM_DESC" IS 'Valor do abatimento concedido. | Valor Desconto';
COMMENT ON COLUMN SBDB."BOLETO"."CONFIRM_PAGAM_JUROS" IS 'Valor do juros e mora pago. | Valor Juros\Mora';
COMMENT ON COLUMN SBDB."BOLETO"."CONFIRM_PAGAM_DESP_ADM" IS 'Valor somado das despesas administrativas. Ex: (mídia eletrônica, biblioteca, correios, etc). | Valor Despesa Administrativa Somados';
COMMENT ON COLUMN SBDB."BOLETO"."CONFIRM_PAGAM_DATA" IS 'Data na qual o boleto foi pago. | Data de Pagamento';
COMMENT ON COLUMN SBDB."BOLETO"."CONFIRM_PAGAM_OUTROS_CRED" IS 'Valor de outros créditos. | Outros Créditos';
COMMENT ON COLUMN SBDB."BOLETO"."CONFIRM_PAGAM_COD_LIQ" IS 'Indica o canal utilizado pelo sacado para pagamento do boleto (ex: aa caixa eletrônico ou ac pagamento em cartório automatizado). | Código de Liquidação';
COMMENT ON COLUMN SBDB."BOLETO"."CONFIRM_PAGAM_VALOR" IS 'Valor pago pelo boleto. | Valor';
COMMENT ON COLUMN SBDB."BOLETO"."BAIXA_CONDICAO" IS 'Condição de baixa entre P=Pago e C=Cancelado. | Status de Baixa';
COMMENT ON COLUMN SBDB."BOLETO"."BAIXA_DATA" IS 'Registro da data em que o operador deu baixa no boleto. | Data de Baixa';
COMMENT ON COLUMN SBDB."BOLETO"."BAIXA_OBS" IS 'Informações sobre a baixa como motivo do cancelamento, por exemplo. | Observações do a Baixa';
COMMENT ON COLUMN SBDB."BOLETO"."BAIXA_OPER" IS 'Usuário que baixou o documento. | Usuário da Baixa';
COMMENT ON COLUMN SBDB."BOLETO"."OPER_SEQ" IS 'Registro do operador que confirma o pagamento. | Operador que Confirma a Baixa';
COMMENT ON COLUMN SBDB."BOLETO"."CANCEL_DATA" IS 'Data de cancelamento do documento. | Data de Cancelamento';
COMMENT ON COLUMN SBDB."BOLETO"."CANCEL_OPER" IS 'Operador responsável pelo cancelamento. | Operador que Cancela';
COMMENT ON COLUMN SBDB."BOLETO"."CANCEL_MOTIVO" IS 'Motivo do cancelamento. | Motivo do Cancelamento';
COMMENT ON COLUMN SBDB."BOLETO"."CANCEL" IS 'Marcar para informar que este boleto foi cancelado. | Cancelado';
COMMENT ON COLUMN SBDB."BOLETO"."REMESSA_ARQUIVO" IS 'Arquivo de remessa onde este boleto foi comunicado. | Arquivo de Remessa';
COMMENT ON COLUMN SBDB."BOLETO"."REMESSA_LOTE" IS 'Número do lote de remessa onde esta linha foi comunicada ao banco. | Lote de Remessa';
COMMENT ON COLUMN SBDB."BOLETO"."REMESSA_LINHA" IS 'Número da linha onde este boleto foi comunicado. | Linha na Remessa';
COMMENT ON COLUMN SBDB."BOLETO"."REMESSA_DATA_ENVIO" IS 'Data de envio do arquivo de remessa. | Data de Envio da Remessa';
COMMENT ON COLUMN SBDB."BOLETO"."REMESSA_OPER" IS 'Usuário que criou o arquivo de remessa para este registro. | Usuário que Cria Arquivo de Remessa';
COMMENT ON COLUMN SBDB."BOLETO"."RETORNO_ARQUIVO" IS 'Arquivo de retorno onde este boleto foi comunicado. | Arquivo de Retorno';
COMMENT ON COLUMN SBDB."BOLETO"."RETORNO_LOTE" IS 'Número do lote do arquivo de retorno  onde esta linha foi comunicada ao banco. | Lote do Arquivo de Retorno';
COMMENT ON COLUMN SBDB."BOLETO"."RETORNO_LINHA" IS 'Número da linha onde este boleto foi comunicado. | Linha no Arquivo de Retorno';
COMMENT ON COLUMN SBDB."BOLETO"."RETORNO_DATA_RECEB" IS 'Data de recebimento do arquivo de retorno. | Data de Recebimento do Arquivo de Retorno';
COMMENT ON COLUMN SBDB."BOLETO"."RETORNO_OPER" IS 'Usuário que importou  o arquivo de retorno para este registro. | Usuário que Importa o Arquivo de Retorno';
COMMENT ON COLUMN SBDB."BOLETO"."CEDENTE_CNPJ" IS 'CNPJ do cedente. | CNPJ do Cedente';
COMMENT ON COLUMN SBDB."BOLETO"."NOTIFICA_DATA" IS 'Notifica Data. | Notifica Data';
COMMENT ON COLUMN SBDB."BOLETO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."BOLETO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."BOLETO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."BOLETO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."BOLETO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."BOLETO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."BOLETO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA CARGO
CREATE TABLE SBDB."CARGO" (
   "CARGO" VARCHAR2 (100),
   "DESCRIÇÃO" VARCHAR2 (100),
   "DIVISOR" NUMBER (3,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."CARGO" ADD CONSTRAINT "ID_CARGO"
PRIMARY KEY("CARGO");

COMMENT ON TABLE SBDB."CARGO" IS 'CADASTRO | Cadastro dos cargos que podem ser cadastrados nas gestões, diretorias e comissões. | Cargo';

COMMENT ON COLUMN SBDB."CARGO"."CARGO" IS 'Cargo. | Cargo';
COMMENT ON COLUMN SBDB."CARGO"."DESCRIÇÃO" IS 'Descrição do cargo. | Descrição';
COMMENT ON COLUMN SBDB."CARGO"."DIVISOR" IS 'Quantidade de associados existente para este cargo existir na regional. | Divisor';
COMMENT ON COLUMN SBDB."CARGO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."CARGO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."CARGO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."CARGO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."CARGO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."CARGO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."CARGO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA CATEGORIA
CREATE TABLE SBDB."CATEGORIA" (
   "COD" VARCHAR2 (20),
   "DESCRIÇÃO" VARCHAR2 (100),
   "ISENTO" NUMBER (1,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."CATEGORIA" ADD CONSTRAINT "ID_CATEGORIA"
PRIMARY KEY("COD");

COMMENT ON TABLE SBDB."CATEGORIA" IS 'CADASTRO | Cadastro das categorias dos associados. | Categoria';

COMMENT ON COLUMN SBDB."CATEGORIA"."COD" IS 'Categoria. | Categoria';
COMMENT ON COLUMN SBDB."CATEGORIA"."DESCRIÇÃO" IS 'Descrição. | Descrição';
COMMENT ON COLUMN SBDB."CATEGORIA"."ISENTO" IS 'Status de isento. | Isento';
COMMENT ON COLUMN SBDB."CATEGORIA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."CATEGORIA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."CATEGORIA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."CATEGORIA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."CATEGORIA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."CATEGORIA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."CATEGORIA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA CONVÊNIO
CREATE TABLE SBDB."CONVÊNIO" (
   "COD" VARCHAR2 (30),
   "DESCRIÇÃO" VARCHAR2 (100),
   "DATA" DATE,
   "OBS" VARCHAR2 (3000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."CONVÊNIO" ADD CONSTRAINT "ID_CONVÊNIO"
PRIMARY KEY("COD");

COMMENT ON TABLE SBDB."CONVÊNIO" IS 'CADASTRO | Cadastro de convênios. | Convênio';

COMMENT ON COLUMN SBDB."CONVÊNIO"."COD" IS 'Convênio. | Convênio';
COMMENT ON COLUMN SBDB."CONVÊNIO"."DESCRIÇÃO" IS 'Descrição. | Descrição';
COMMENT ON COLUMN SBDB."CONVÊNIO"."DATA" IS 'Data de cadastro. | Data do Convênio';
COMMENT ON COLUMN SBDB."CONVÊNIO"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."CONVÊNIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."CONVÊNIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."CONVÊNIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."CONVÊNIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."CONVÊNIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."CONVÊNIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."CONVÊNIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EDITORIAL
CREATE TABLE SBDB."EDITORIAL" (
   "SEQ" NUMBER (6,0),
   "NOME" VARCHAR2 (50),
   "NOME_2" VARCHAR2 (50),
   "ENDEREÇO" VARCHAR2 (100),
   "NUMERO" VARCHAR2 (10),
   "COMPLEMENTO" VARCHAR2 (50),
   "BAIRRO" VARCHAR2 (50),
   "CIDADE" VARCHAR2 (50),
   "ESTADO" VARCHAR2 (2),
   "ESTADO_EX" VARCHAR2 (50),
   "PAÍS" VARCHAR2 (30),
   "CEP" VARCHAR2 (10),
   "CX_POSTAL" VARCHAR2 (20),
   "TEL" VARCHAR2 (20),
   "FAX" VARCHAR2 (20),
   "CONTATO" VARCHAR2 (20),
   "EMAIL" VARCHAR2 (200),
   "WEB_SITE" VARCHAR2 (200),
   "ATUALIZAÇÃO" DATE,
   "OBS" VARCHAR2 (3000),
   "SENHA" VARCHAR2 (20)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."EDITORIAL" ADD CONSTRAINT "ID_EDITORIAL"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."EDITORIAL" IS 'ASSINATURA | Cadastro dos assinantes dos anais e do jornal da SBD. | Editorial';

COMMENT ON COLUMN SBDB."EDITORIAL"."SEQ" IS 'Referência de cadastro. | Sequencial';
COMMENT ON COLUMN SBDB."EDITORIAL"."NOME" IS 'Nome do assinante. | Nome';
COMMENT ON COLUMN SBDB."EDITORIAL"."NOME_2" IS 'Nome Preferencial do assinante. | Nome Preferencial';
COMMENT ON COLUMN SBDB."EDITORIAL"."ENDEREÇO" IS 'Endereço completo, tipo (rua, av.), logradouro e número. | Endereço Completo';
COMMENT ON COLUMN SBDB."EDITORIAL"."NUMERO" IS 'Número. | Número';
COMMENT ON COLUMN SBDB."EDITORIAL"."COMPLEMENTO" IS 'Complemento (Apto, Quadra, Lote, etc.) | Complemento';
COMMENT ON COLUMN SBDB."EDITORIAL"."BAIRRO" IS 'Bairro. | Bairro';
COMMENT ON COLUMN SBDB."EDITORIAL"."CIDADE" IS 'Cidade. | Cidade';
COMMENT ON COLUMN SBDB."EDITORIAL"."ESTADO" IS 'Estado. | Estado';
COMMENT ON COLUMN SBDB."EDITORIAL"."ESTADO_EX" IS 'Estado no exterior. | Estado no Exterior';
COMMENT ON COLUMN SBDB."EDITORIAL"."PAÍS" IS 'País. | País';
COMMENT ON COLUMN SBDB."EDITORIAL"."CEP" IS 'CEP designado para o logradouro. | CEP';
COMMENT ON COLUMN SBDB."EDITORIAL"."CX_POSTAL" IS 'Caixa postal. | Caixa Postal';
COMMENT ON COLUMN SBDB."EDITORIAL"."TEL" IS 'Telefone. (999) 9999-9999 | Telefone';
COMMENT ON COLUMN SBDB."EDITORIAL"."FAX" IS 'Fax. (999) 9999-9999 | Fax';
COMMENT ON COLUMN SBDB."EDITORIAL"."CONTATO" IS 'Contato. | Contato';
COMMENT ON COLUMN SBDB."EDITORIAL"."EMAIL" IS 'E-mail. | E-mail';
COMMENT ON COLUMN SBDB."EDITORIAL"."WEB_SITE" IS 'Web site. | Web Site';
COMMENT ON COLUMN SBDB."EDITORIAL"."ATUALIZAÇÃO" IS 'Data de atualização. | Atualizado em';
COMMENT ON COLUMN SBDB."EDITORIAL"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."EDITORIAL"."SENHA" IS 'Senha para acesso à áreas controladas por login e senha. | Senha';
COMMENT ON COLUMN SBDB."EDITORIAL".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."EDITORIAL".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."EDITORIAL".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."EDITORIAL".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."EDITORIAL".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."EDITORIAL".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."EDITORIAL".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EDITORIAL_TIPO_ASS_ENVIO
CREATE TABLE SBDB."EDITORIAL_TIPO_ASS_ENVIO" (
   "EDITORIAL_SEQ" NUMBER (6,0),
   "TIPO_ASS_SEQ" NUMBER (5,0),
   "DATA_ENVIO" DATE,
   "FASCICULO" VARCHAR2 (1000),
   "QUANTIDADE_ENVIADA" NUMBER (3,0),
   "SEQ" NUMBER (6,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."EDITORIAL_TIPO_ASS_ENVIO" ADD CONSTRAINT "ID_EDITORIAL_TIPO_ASS_ENVIO"
PRIMARY KEY("SEQ", "EDITORIAL_SEQ", "TIPO_ASS_SEQ");

COMMENT ON TABLE SBDB."EDITORIAL_TIPO_ASS_ENVIO" IS 'SBDB | Armazena o histórico de assinaturas enviadas. | Assinaturas Enviadas';

COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASS_ENVIO"."EDITORIAL_SEQ" IS 'Referência de cadastro do assinante. | Sequencial do Editorial';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASS_ENVIO"."TIPO_ASS_SEQ" IS 'Sequencial que será individual para cada assinante relacionado ao campo seq da tabela editorial_tipo_assinatura. | Sequencial Tipo Assinatura';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASS_ENVIO"."DATA_ENVIO" IS 'Data de envio dos fascículos - Oficial. | Data Envio';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASS_ENVIO"."FASCICULO" IS 'Identifica qual fascículo foi envido para o assinante. | Fascículo';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASS_ENVIO"."QUANTIDADE_ENVIADA" IS 'Quantidade de remessas por grupo de fascículos. | Quantidade Enviada';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASS_ENVIO"."SEQ" IS 'Sequencial identificador do envio. | Sequencial do Envio';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASS_ENVIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASS_ENVIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASS_ENVIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASS_ENVIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASS_ENVIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASS_ENVIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASS_ENVIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EDITORIAL_TIPO_ASSINATURA
CREATE TABLE SBDB."EDITORIAL_TIPO_ASSINATURA" (
   "EDITORIAL_SEQ" NUMBER (6,0),
   "SEQ" NUMBER (5,0),
   "TIPO_ASSINATURA" VARCHAR2 (50),
   "DATA_INICIO" DATE,
   "DATA_FINAL" DATE,
   "FASCICULO" VARCHAR2 (1000),
   "EDITOR_CHEFE" VARCHAR2 (100),
   "QUANTIDADE_ASSINATURA" NUMBER (3,0),
   "TIPO_REMESSA" VARCHAR2 (100),
   "TIPO_POSTAGEM" VARCHAR2 (15),
   "DATA_RENOVACAO" DATE,
   "OBS" VARCHAR2 (4000),
   "TOT_MAX_VOL_ASS" NUMBER (3,0),
   "AVISO_REN" NUMBER (1,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."EDITORIAL_TIPO_ASSINATURA" ADD CONSTRAINT "ID_EDITORIAL_TIPO_ASSINATURA"
PRIMARY KEY("EDITORIAL_SEQ", "SEQ");

COMMENT ON TABLE SBDB."EDITORIAL_TIPO_ASSINATURA" IS 'SBDB | Armazena o histórico de assinaturas. | Tipo de Assinatura do Editorial';

COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA"."EDITORIAL_SEQ" IS 'Sequencial que identifica o assinante relacionado ao campo sequencial da tabela editorial. | Sequencial do Editorial';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA"."SEQ" IS 'Sequencial que será individual para cada assinante. | Sequencial';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA"."TIPO_ASSINATURA" IS 'Identifica qual o tipo de assinatura (JORNAL=Jornal, REVISTA ABD=Revista ABD ou REVISTA SURGICAL=Revista Surgical). Informado pelo usuário. | Tipo de Assinatura';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA"."DATA_INICIO" IS 'Informa quando iniciou a assinatura. | Data de Início';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA"."DATA_FINAL" IS 'Informa data final de assinatura. | Data de Término';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA"."FASCICULO" IS 'Identifica quais fascículos o assinante irá receber. | Fascículo';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA"."EDITOR_CHEFE" IS 'Nome do editor chefe. | Editor Chefe';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA"."QUANTIDADE_ASSINATURA" IS 'Quantidade de revistas contratada pelo assinante. | Quantidade de Assinaturas';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA"."TIPO_REMESSA" IS 'Identifica o tipo de remessa. | Tipo de Remessa';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA"."TIPO_POSTAGEM" IS 'Identifica se o tipo de postagem é nacional ou internacional. | Tipo de Postagem';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA"."DATA_RENOVACAO" IS 'Registra a data de renovação. | Data de Renovação';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA"."OBS" IS 'Observação de cada assinatura. | Observação';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA"."TOT_MAX_VOL_ASS" IS 'Número total de grupo de fascículos diferentes enviados. | Máximo de Volumes';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA"."AVISO_REN" IS 'Informará se foi emitido o aviso de renovação quando necessário (0=não emitir, 1=emitir). | Aviso de Renovação ao Assinante';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."EDITORIAL_TIPO_ASSINATURA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EMCD_APURAÇÃO
CREATE TABLE SBDB."EMCD_APURAÇÃO" (
   "APURACAO" VARCHAR2 (5),
   "SÓCIO_MAT" NUMBER (5,0),
   "DATA_INI_CONT" DATE,
   "DATA_APURAÇÃO" DATE,
   "PONTUAÇÃO" FLOAT,
   "QTD_REGS" NUMBER (5,0),
   "CERTIF_IMPRIMIR" NUMBER (5,0),
   "CERTIF_IMPRESSO" DATE
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."EMCD_APURAÇÃO" ADD CONSTRAINT "ID_EMCD_APURAÇÃO"
PRIMARY KEY("APURACAO", "SÓCIO_MAT");

COMMENT ON TABLE SBDB."EMCD_APURAÇÃO" IS 'EMCD | Cadastro das consolidações dos pontos dos associado na EMCD. | Apuração do EMCD';

COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO"."APURACAO" IS 'Fase da apuração. | Fase';
COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO"."SÓCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO"."DATA_INI_CONT" IS 'Data do Início da contagem. | Data de Início';
COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO"."DATA_APURAÇÃO" IS 'Data da apuração. | Data da apuração';
COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO"."PONTUAÇÃO" IS 'Pontuação. | Pontuação';
COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO"."QTD_REGS" IS 'Quantidade de registros. | Quantidade de Registro';
COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO"."CERTIF_IMPRIMIR" IS 'Indica se o certificado será impresso. | O Certificado Será Impresso';
COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO"."CERTIF_IMPRESSO" IS 'Indica se o certificado foi impresso. | O Certificado foi Impresso';
COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."EMCD_APURAÇÃO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EMCD_ATIV_PONTO
CREATE TABLE SBDB."EMCD_ATIV_PONTO" (
   "ATIV_COD" NUMBER (6,0),
   "PONTO_COD" NUMBER (5,0),
   "TIPO" NUMBER (5,0),
   "STATUS_IMPORTACAO" VARCHAR2 (20)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."EMCD_ATIV_PONTO" ADD CONSTRAINT "ID_EMCD_ATIV_PONTO"
PRIMARY KEY("ATIV_COD", "PONTO_COD");

COMMENT ON TABLE SBDB."EMCD_ATIV_PONTO" IS 'EMCD | Cadastro que relaciona as atividades aos seus pontos. | Ponto por Atividade do EMCD';

COMMENT ON COLUMN SBDB."EMCD_ATIV_PONTO"."ATIV_COD" IS 'Sequencial da atividade. | Sequencial da atividade';
COMMENT ON COLUMN SBDB."EMCD_ATIV_PONTO"."PONTO_COD" IS 'Sequencial do ponto. | Sequencial da pontuação';
COMMENT ON COLUMN SBDB."EMCD_ATIV_PONTO"."TIPO" IS 'Tipo de atividade. | Tipo de Atividade';
COMMENT ON COLUMN SBDB."EMCD_ATIV_PONTO"."STATUS_IMPORTACAO" IS 'Status de importação dos pontos. | Status de Importação';
COMMENT ON COLUMN SBDB."EMCD_ATIV_PONTO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."EMCD_ATIV_PONTO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."EMCD_ATIV_PONTO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."EMCD_ATIV_PONTO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."EMCD_ATIV_PONTO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."EMCD_ATIV_PONTO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."EMCD_ATIV_PONTO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EMCD_ATIVIDADE
CREATE TABLE SBDB."EMCD_ATIVIDADE" (
   "COD" NUMBER (6,0),
   "NÍVEL_NÓ" NUMBER (6,0),
   "POSIÇÃO_NÓ" VARCHAR2 (80),
   "SUPERIOR" NUMBER (6,0),
   "ORDEM" NUMBER (6,0),
   "NOME" VARCHAR2 (100),
   "DESCRIÇÃO" VARCHAR2 (500),
   "DATA_INI" DATE,
   "DATA_FIM" DATE,
   "DURAÇÃO" VARCHAR2 (30),
   "LOCAL" VARCHAR2 (100),
   "REGIONAL_COD" VARCHAR2 (2),
   "OBS" VARCHAR2 (3000),
   "CFM" NUMBER (5,0),
   "APRESENTAR" NUMBER (1,0),
   "FLAG_ACERTO" VARCHAR2 (1),
   "FORMULARIO" VARCHAR2 (20),
   "STATUS_SITE" NUMBER (1,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."EMCD_ATIVIDADE" ADD CONSTRAINT "ID_EMCD_ATIVIDADE"
PRIMARY KEY("COD");

COMMENT ON TABLE SBDB."EMCD_ATIVIDADE" IS 'EMCD | Cadastro das atividades. | Atividade do EMCD';

COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."COD" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."NÍVEL_NÓ" IS 'Nível do nó. | Nível';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."POSIÇÃO_NÓ" IS 'Posição do nó. | Posição';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."SUPERIOR" IS 'Nó superior. | Nó superior';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."ORDEM" IS 'Ordenação. | Ordenação';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."NOME" IS 'Nome da atividade. | Título';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."DESCRIÇÃO" IS 'Descrição. | Descrição';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."DATA_INI" IS 'Data de inicio. | Data de Início';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."DATA_FIM" IS 'Data de término. | Data de Término';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."DURAÇÃO" IS 'Tempo de duração. | Duração (mins)';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."LOCAL" IS 'Local. | Local';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."REGIONAL_COD" IS 'Regional. | Regional';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."CFM" IS 'Status do ponto SBD\CFM. | CFM';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."APRESENTAR" IS 'Apresentação da atividade. | Apresentar';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."FLAG_ACERTO" IS 'Utilizado para apontar a atividade que permanecerá na tabela ativa. | Flag Acerto';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."FORMULARIO" IS 'Informação do formulário registrado na CNA. | Formulário';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE"."STATUS_SITE" IS 'Status de visualzação no site [0=Falso;1=Verdadeiro]. | Status Site';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."EMCD_ATIVIDADE".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EMCD_FASE
CREATE TABLE SBDB."EMCD_FASE" (
   "FASE" VARCHAR2 (5),
   "DATA_INICIO" DATE,
   "DATA_FINAL" DATE,
   "DATA_EMISSAO" VARCHAR2 (50),
   "DIAS_VALIDADE" DATE,
   "TIPO" VARCHAR2 (5),
   "NOME_PRESIDENTE" VARCHAR2 (40),
   "ASS_PRESIDENTE" VARCHAR2 (200),
   "NOME_COORDENADOR" VARCHAR2 (40),
   "ASS_COORDENADOR" VARCHAR2 (200),
   "NOME_COORDENADOR_ASSOC" VARCHAR2 (40),
   "ASS_COORDENADOR_ASSOC" VARCHAR2 (200),
   "TOTAL_PONTO" NUMBER (5,0),
   "EXTRATO_SITUACAO" VARCHAR2 (3000),
   "EXTRATO_CATEGORIA" VARCHAR2 (3000),
   "CERTIFICADO_SITUACAO" VARCHAR2 (3000),
   "CERTIFICADO_CATEGORIA" VARCHAR2 (3000),
   "DATA_APURACAO" DATE
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."EMCD_FASE" ADD CONSTRAINT "ID_EMCD_FASE"
PRIMARY KEY("FASE");

COMMENT ON TABLE SBDB."EMCD_FASE" IS 'EMCD | Cadastro das parametrizações referente ao módulo EMCD. | Fase de Pontuação do EMCD';

COMMENT ON COLUMN SBDB."EMCD_FASE"."FASE" IS 'Fase da pontuação. | Fase';
COMMENT ON COLUMN SBDB."EMCD_FASE"."DATA_INICIO" IS 'Data de início. | Data de Início';
COMMENT ON COLUMN SBDB."EMCD_FASE"."DATA_FINAL" IS 'Data de término. | Data de Término';
COMMENT ON COLUMN SBDB."EMCD_FASE"."DATA_EMISSAO" IS 'Data de emissão. | Data de Emissão';
COMMENT ON COLUMN SBDB."EMCD_FASE"."DIAS_VALIDADE" IS 'Data de validade. | Data de Validade';
COMMENT ON COLUMN SBDB."EMCD_FASE"."TIPO" IS 'Tipo. | Tipo';
COMMENT ON COLUMN SBDB."EMCD_FASE"."NOME_PRESIDENTE" IS 'Nome presidente. | Nome do Presidente';
COMMENT ON COLUMN SBDB."EMCD_FASE"."ASS_PRESIDENTE" IS 'Assinatura do presidente. | Assinatura do Presidente';
COMMENT ON COLUMN SBDB."EMCD_FASE"."NOME_COORDENADOR" IS 'Nome do coordenador. | Nome do Coordenador';
COMMENT ON COLUMN SBDB."EMCD_FASE"."ASS_COORDENADOR" IS 'Assinatura do coordenador. | Assinatura do Coordenado';
COMMENT ON COLUMN SBDB."EMCD_FASE"."NOME_COORDENADOR_ASSOC" IS 'Nome do coordenador associado. | Nome do Coordenador Associado';
COMMENT ON COLUMN SBDB."EMCD_FASE"."ASS_COORDENADOR_ASSOC" IS 'Assinatura do coordenador associado. | Assinatura do Coordenador Associado';
COMMENT ON COLUMN SBDB."EMCD_FASE"."TOTAL_PONTO" IS 'Total de ponto. | Total de Pontos';
COMMENT ON COLUMN SBDB."EMCD_FASE"."EXTRATO_SITUACAO" IS 'Situação do extrato. | Situação do Extrato';
COMMENT ON COLUMN SBDB."EMCD_FASE"."EXTRATO_CATEGORIA" IS 'Categoria do extrato. | Categoria do Extrato';
COMMENT ON COLUMN SBDB."EMCD_FASE"."CERTIFICADO_SITUACAO" IS 'Status do certificado. | Situação do Certificado';
COMMENT ON COLUMN SBDB."EMCD_FASE"."CERTIFICADO_CATEGORIA" IS 'Categoria do certificado. | Categoria do Certificado';
COMMENT ON COLUMN SBDB."EMCD_FASE"."DATA_APURACAO" IS 'Data da apuração. | Data da Apuração';
COMMENT ON COLUMN SBDB."EMCD_FASE".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."EMCD_FASE".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."EMCD_FASE".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."EMCD_FASE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."EMCD_FASE".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."EMCD_FASE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."EMCD_FASE".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EMCD_LOTE
CREATE TABLE SBDB."EMCD_LOTE" (
   "SEQ" NUMBER (10,0),
   "ARQ_LOTE" VARCHAR2 (200),
   "ORIGEM_IMPORTA" VARCHAR2 (500),
   "COLABORADOR" VARCHAR2 (20),
   "ATIV_NOME" VARCHAR2 (200),
   "ATIV_COD" NUMBER (6,0),
   "ATIV_COD_SUP" NUMBER (6,0),
   "DATA_INI" DATE ,
   "DATA_FIM" DATE ,
   "REGIONAL_COD" VARCHAR2 (2),
   "OBS" VARCHAR2 (4000),
   "FORMULARIO" VARCHAR2 (20),
   "QTD_LINHAS" NUMBER (5,0),
   "QTD_LINHAS_REG" NUMBER (5,0),
   "DATA_IMPORTA" DATE,
   "STATUS_ENVIO" VARCHAR2 (50),
   "RESP_IMPORTA" VARCHAR2 (50),
   "QTD_LINHAS_LIDAS" NUMBER (5,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."EMCD_LOTE" ADD CONSTRAINT "ID_EMCD_LOTE"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."EMCD_LOTE" IS 'EMCD | Informação sobre as atividades importadas. | Lote de Atividade Importada';

COMMENT ON COLUMN SBDB."EMCD_LOTE"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."ARQ_LOTE" IS 'Nome do arquivo importado. | Nome do Arquivo';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."ORIGEM_IMPORTA" IS 'Origem do arquivo. | Origem';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."COLABORADOR" IS 'Colaborador responsável pelo envio. | Colaborador';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."ATIV_NOME" IS 'Nome da atividade. | Nome da Atividade';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."ATIV_COD" IS 'Código da atividade. | Código da Atividade';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."ATIV_COD_SUP" IS 'Código da atividade superior. | Código da Atividade Superior';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."DATA_INI" IS 'Data de inicio. | Data de Inicio';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."DATA_FIM" IS 'Data de término. | Data de Término';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."REGIONAL_COD" IS 'Regional do evento. | Regional';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."FORMULARIO" IS 'Formulario cadastrado na CNA. | Formulário';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."QTD_LINHAS" IS 'Quantidade de linhas no arquivo. | Quantidade de linhas no Arquivo';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."QTD_LINHAS_REG" IS 'Quantidade de linhas regeitadas. | Quantidade de Linhas Regeitadas';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."DATA_IMPORTA" IS 'Data de importação dos pontos enviados. | Data Importação';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."STATUS_ENVIO" IS 'Status da envio.  | Status';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."RESP_IMPORTA" IS 'Responsável pela importação dos arquivos. | Responsável';
COMMENT ON COLUMN SBDB."EMCD_LOTE"."QTD_LINHAS_LIDAS" IS 'Quantidade de linhas importadas. | Quantidade de linhas importadas';
COMMENT ON COLUMN SBDB."EMCD_LOTE".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."EMCD_LOTE".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."EMCD_LOTE".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."EMCD_LOTE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."EMCD_LOTE".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."EMCD_LOTE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."EMCD_LOTE".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EMCD_LOTE_PONTO
CREATE TABLE SBDB."EMCD_LOTE_PONTO" (
   "LOTE_SEQ" NUMBER (10,0),
   "SEQ" NUMBER (10,0),
   "SOCIO_MAT" NUMBER (5,0),
   "ATIV_COD" NUMBER (6,0),
   "PONTO_COD" NUMBER (10,0),
   "PONTO_VALOR" NUMBER (10,2),
   "PONTO_DATA" DATE ,
   "PONTO_DATA_ORIG" DATE ,
   "PONTO_VALOR_ORIG" NUMBER (10,2),
   "STATUS_IMPORTA" VARCHAR2 (20),
   "OBS" VARCHAR2 (4000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."EMCD_LOTE_PONTO" ADD CONSTRAINT "ID_EMCD_LOTE_PONTO"
PRIMARY KEY("LOTE_SEQ", "SEQ");

COMMENT ON TABLE SBDB."EMCD_LOTE_PONTO" IS 'EMCD | Informação sobre os pontos importados. | Lote de Pontos Importados';

COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO"."LOTE_SEQ" IS 'Sequencial do arquivo. | Sequencial do arquivo';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO"."SOCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO"."ATIV_COD" IS 'Código da atividade. | Código da Atividade';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO"."PONTO_COD" IS 'Código do ponto. | Código do Ponto';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO"."PONTO_VALOR" IS 'Valor do ponto. | Valor do Ponto';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO"."PONTO_DATA" IS 'Data do ponto. | Data do Ponto';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO"."PONTO_DATA_ORIG" IS 'Data original do ponto. | Data Original do Ponto';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO"."PONTO_VALOR_ORIG" IS 'Valor original do ponto. | Valor Original do Ponto';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO"."STATUS_IMPORTA" IS 'Status de importação. | Status';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EMCD_LOTE_PONTO_STATUS
CREATE TABLE SBDB."EMCD_LOTE_PONTO_STATUS" (
   "STATUS" NUMBER (5,0),
   "DESCRIACAO" VARCHAR2 (50),
   "VALOR" VARCHAR2 (50)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."EMCD_LOTE_PONTO_STATUS" ADD CONSTRAINT "ID_EMCD_LOTE_PONTO_STATUS"
PRIMARY KEY("STATUS");

COMMENT ON TABLE SBDB."EMCD_LOTE_PONTO_STATUS" IS 'EMCD | Status dos pontos importados. | Status dos Pontos Importados';

COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO_STATUS"."STATUS" IS 'Status de importação. | Status';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO_STATUS"."DESCRIACAO" IS 'Descrição do status de importação do ponto. | Descrição';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO_STATUS"."VALOR" IS 'Valor do status. | Valor do Status';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO_STATUS".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO_STATUS".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO_STATUS".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO_STATUS".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO_STATUS".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO_STATUS".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."EMCD_LOTE_PONTO_STATUS".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EMCD_LOTE_STATUS
CREATE TABLE SBDB."EMCD_LOTE_STATUS" (
   "STATUS" NUMBER (5,0),
   "DESCRICAO" VARCHAR2 (50)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."EMCD_LOTE_STATUS" ADD CONSTRAINT "ID_EMCD_LOTE_STATUS"
PRIMARY KEY("STATUS");

COMMENT ON TABLE SBDB."EMCD_LOTE_STATUS" IS 'EMCD | Status das atividades importadas | Status das Atividades Importadas';

COMMENT ON COLUMN SBDB."EMCD_LOTE_STATUS"."STATUS" IS 'Status do arquivo. | Status';
COMMENT ON COLUMN SBDB."EMCD_LOTE_STATUS"."DESCRICAO" IS 'Descrição do status. | Descrição';
COMMENT ON COLUMN SBDB."EMCD_LOTE_STATUS".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."EMCD_LOTE_STATUS".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."EMCD_LOTE_STATUS".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."EMCD_LOTE_STATUS".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."EMCD_LOTE_STATUS".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."EMCD_LOTE_STATUS".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."EMCD_LOTE_STATUS".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EMCD_PONTO_FASE
CREATE TABLE SBDB."EMCD_PONTO_FASE" (
   "SOCIO_MAT" NUMBER (5,0),
   "ATIV_COD" NUMBER (6,0),
   "APURACAO" VARCHAR2 (5),
   "SUBFASE" VARCHAR2 (4),
   "PONTO_COD" NUMBER (5,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."EMCD_PONTO_FASE" ADD CONSTRAINT "ID_EMCD_PONTO_FASE"
PRIMARY KEY("SOCIO_MAT", "ATIV_COD", "APURACAO", "PONTO_COD");

COMMENT ON TABLE SBDB."EMCD_PONTO_FASE" IS 'EMCD | Armazena os pontos dos associados pelas fases. | Ponto por Fase do EMCD';

COMMENT ON COLUMN SBDB."EMCD_PONTO_FASE"."SOCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."EMCD_PONTO_FASE"."ATIV_COD" IS 'Sequencial da atividade. | Sequencial da Atividade';
COMMENT ON COLUMN SBDB."EMCD_PONTO_FASE"."APURACAO" IS 'Fase da apuração. | Fase';
COMMENT ON COLUMN SBDB."EMCD_PONTO_FASE"."SUBFASE" IS 'Subfase. | Subfase de Apuração';
COMMENT ON COLUMN SBDB."EMCD_PONTO_FASE"."PONTO_COD" IS 'Sequencial do ponto. | Sequencial de Pontuação';
COMMENT ON COLUMN SBDB."EMCD_PONTO_FASE".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."EMCD_PONTO_FASE".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."EMCD_PONTO_FASE".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."EMCD_PONTO_FASE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."EMCD_PONTO_FASE".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."EMCD_PONTO_FASE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."EMCD_PONTO_FASE".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EMCD_PONTO_SÓCIO
CREATE TABLE SBDB."EMCD_PONTO_SÓCIO" (
   "SÓCIO_MAT" NUMBER (5,0),
   "ATIV_COD" NUMBER (6,0),
   "PONTO_COD" NUMBER (5,0),
   "PONTO_VALOR" FLOAT,
   "PONTO_DATA" DATE,
   "CFM" NUMBER (5,0),
   "PONTO_DATA_ORIG" DATE,
   "OBS" VARCHAR2 (255),
   "PONTO_VALOR_ORIG" FLOAT,
   "STATUS_IMPORT" VARCHAR2 (20),
   "FLAG_ACERTO" VARCHAR2 (1)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."EMCD_PONTO_SÓCIO" ADD CONSTRAINT "ID_EMCD_PONTO_SÓCIO"
PRIMARY KEY("SÓCIO_MAT", "ATIV_COD", "PONTO_COD");

COMMENT ON TABLE SBDB."EMCD_PONTO_SÓCIO" IS 'EMCD | Cadastro dos pontos obtidos pelos associados na EMCD. | Ponto por Sócio do EMCD';

COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO"."SÓCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO"."ATIV_COD" IS 'Sequencial da atividade. | Sequencial da Atividade';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO"."PONTO_COD" IS 'Sequencial do ponto. | Sequencial do Ponto';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO"."PONTO_VALOR" IS 'Valor do ponto. | Valor da Pontuação';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO"."PONTO_DATA" IS 'Data do ponto. | Data da Pontuação';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO"."CFM" IS 'Status do ponto SBD\CFM. | CFM';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO"."PONTO_DATA_ORIG" IS 'Data original do ponto. | Data Original do Ponto';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO"."PONTO_VALOR_ORIG" IS 'Valor original do ponto. | Valor Original do Ponto';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO"."STATUS_IMPORT" IS 'Status de importação. | Status de Importação';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO"."FLAG_ACERTO" IS 'Utilizado para apontar a atividade que permanecerá na tabela ativa. | Flag Acerto';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."EMCD_PONTO_SÓCIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EMCD_TIPO_PONTO
CREATE TABLE SBDB."EMCD_TIPO_PONTO" (
   "COD" NUMBER (5,0),
   "DESCRIÇÃO" VARCHAR2 (100),
   "VALOR" NUMBER (5,2),
   "CFM" NUMBER (5,0),
   "TIPO" NUMBER (5,0),
   "DATA_REGIMENTO" DATE
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."EMCD_TIPO_PONTO" ADD CONSTRAINT "ID_EMCD_TIPO_PONTO"
PRIMARY KEY("COD");

COMMENT ON TABLE SBDB."EMCD_TIPO_PONTO" IS 'EMCD | Cadastro dos tipos de pontos. | Tipo do Ponto do EMCD';

COMMENT ON COLUMN SBDB."EMCD_TIPO_PONTO"."COD" IS 'Sequencial do ponto. | Sequencial';
COMMENT ON COLUMN SBDB."EMCD_TIPO_PONTO"."DESCRIÇÃO" IS 'Descrição. | Descrição';
COMMENT ON COLUMN SBDB."EMCD_TIPO_PONTO"."VALOR" IS 'Valor. | Valor da Pontuação';
COMMENT ON COLUMN SBDB."EMCD_TIPO_PONTO"."CFM" IS 'Status do ponto SBD\CFM. | CFM';
COMMENT ON COLUMN SBDB."EMCD_TIPO_PONTO"."TIPO" IS 'Tipo do Ponto. | Tipo do Ponto';
COMMENT ON COLUMN SBDB."EMCD_TIPO_PONTO"."DATA_REGIMENTO" IS 'Data do regimento. | Data do Regimento';
COMMENT ON COLUMN SBDB."EMCD_TIPO_PONTO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."EMCD_TIPO_PONTO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."EMCD_TIPO_PONTO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."EMCD_TIPO_PONTO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."EMCD_TIPO_PONTO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."EMCD_TIPO_PONTO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."EMCD_TIPO_PONTO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA ESTADO
CREATE TABLE SBDB."ESTADO" (
   "SIGLA" VARCHAR2 (2),
   "NOME" VARCHAR2 (50),
   "REGIAO" VARCHAR2 (30)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."ESTADO" ADD CONSTRAINT "ID_ESTADO"
PRIMARY KEY("SIGLA");

COMMENT ON TABLE SBDB."ESTADO" IS 'CADASTRO | Cadastro dos estados do brasil. | Estado';

COMMENT ON COLUMN SBDB."ESTADO"."SIGLA" IS 'Sigla. | Sigla do Estado';
COMMENT ON COLUMN SBDB."ESTADO"."NOME" IS 'Nome. | Nome';
COMMENT ON COLUMN SBDB."ESTADO"."REGIAO" IS 'Região. | Região';
COMMENT ON COLUMN SBDB."ESTADO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."ESTADO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."ESTADO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."ESTADO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."ESTADO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."ESTADO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."ESTADO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA FERIADO
CREATE TABLE SBDB."FERIADO" (
   "DIA" NUMBER (2,0),
   "MES" NUMBER (2,0),
   "NOME" VARCHAR2 (50)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."FERIADO" ADD CONSTRAINT "ID_FERIADO"
PRIMARY KEY("DIA", "MES");

COMMENT ON TABLE SBDB."FERIADO" IS 'SBDB | Armazena os feriados e suas datas. | Feriado';

COMMENT ON COLUMN SBDB."FERIADO"."DIA" IS 'Dia. | Dia';
COMMENT ON COLUMN SBDB."FERIADO"."MES" IS 'Mês do feriado. | Mês';
COMMENT ON COLUMN SBDB."FERIADO"."NOME" IS 'Feriado. | Feriado';
COMMENT ON COLUMN SBDB."FERIADO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."FERIADO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."FERIADO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."FERIADO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."FERIADO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."FERIADO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."FERIADO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA GER_ADICIONAL_OBJ
CREATE TABLE SBDB."GER_ADICIONAL_OBJ" (
   "SISTEMA" VARCHAR2 (30),
   "TIPO" VARCHAR2 (30),
   "OBJETO" VARCHAR2 (70),
   "CLASSE" VARCHAR2 (70),
   "ORDEM" NUMBER (11,0),
   "TEXTO" CLOB,
   "DESCR" VARCHAR2 (50),
   "PROP_EXTEND" CLOB
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."GER_ADICIONAL_OBJ" ADD CONSTRAINT "ID_GER_ADICIONAL_OBJ"
PRIMARY KEY("SISTEMA", "TIPO", "OBJETO");

COMMENT ON TABLE SBDB."GER_ADICIONAL_OBJ" IS 'Gerador | Objetos adicionais. | Obj Adcional';

COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ"."SISTEMA" IS 'Sistema relacionado. | Sistema';
COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ"."TIPO" IS 'Tipo do objeto. | Tipo';
COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ"."OBJETO" IS 'Nome do objeto. | Nome';
COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ"."CLASSE" IS 'Especificação de classe. | Classe';
COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ"."ORDEM" IS 'Ordenação de apresentação dos objetos. | Ordem';
COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ"."TEXTO" IS 'Conteúdo do objeto. | Texto de Criação';
COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ"."DESCR" IS 'Descrição do objeto. | Descrição';
COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ"."PROP_EXTEND" IS 'Propriedades extendidas do objeto. | Propriedades';
COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."GER_ADICIONAL_OBJ".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA GER_CAMPO
CREATE TABLE SBDB."GER_CAMPO" (
   "SISTEMA" VARCHAR2 (30),
   "TABELA" VARCHAR2 (70),
   "CAMPO" VARCHAR2 (70),
   "ORDEM" NUMBER (11,0),
   "ETIQ" VARCHAR2 (50),
   "DESCR" VARCHAR2 (4000),
   "PROP_EXTEND" CLOB,
   "TIPO_ACCESS" VARCHAR2 (20),
   "TIPO_ORACLE" VARCHAR2 (20),
   "TIPO_MYSQL" VARCHAR2 (20),
   "FORMATO" VARCHAR2 (1000),
   "VALOR_PADRAO" VARCHAR2 (100),
   "AUTO" VARCHAR2 (15),
   "VALOR_CHECK" VARCHAR2 (200),
   "CONJUNTO" VARCHAR2 (200)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."GER_CAMPO" ADD CONSTRAINT "ID_GER_CAMPO"
PRIMARY KEY("SISTEMA", "TABELA", "CAMPO");

COMMENT ON TABLE SBDB."GER_CAMPO" IS 'Gerador | Lista de campos de tabelas. | Campos de Tabela';

COMMENT ON COLUMN SBDB."GER_CAMPO"."SISTEMA" IS 'Sistema relacionado. | Sistema';
COMMENT ON COLUMN SBDB."GER_CAMPO"."TABELA" IS 'Nome da tabela. | Tabela';
COMMENT ON COLUMN SBDB."GER_CAMPO"."CAMPO" IS 'Nome do campo. | Campo';
COMMENT ON COLUMN SBDB."GER_CAMPO"."ORDEM" IS 'Ordem de apresentação. | Ordem';
COMMENT ON COLUMN SBDB."GER_CAMPO"."ETIQ" IS 'Etiqueta apresentada. | Etiqueta em Português';
COMMENT ON COLUMN SBDB."GER_CAMPO"."DESCR" IS 'Descrição em português. | Descrição em Português';
COMMENT ON COLUMN SBDB."GER_CAMPO"."PROP_EXTEND" IS 'Propriedades extendidas. | Propriedades';
COMMENT ON COLUMN SBDB."GER_CAMPO"."TIPO_ACCESS" IS 'Tipo quando criado em access. | Tipo em Access';
COMMENT ON COLUMN SBDB."GER_CAMPO"."TIPO_ORACLE" IS 'Tipo quando criado em oracle. | Tipo em Oracle';
COMMENT ON COLUMN SBDB."GER_CAMPO"."TIPO_MYSQL" IS 'Tipo quando criado em mysql. | Tipo em MySQL';
COMMENT ON COLUMN SBDB."GER_CAMPO"."FORMATO" IS 'Formato do campo. | Formato';
COMMENT ON COLUMN SBDB."GER_CAMPO"."VALOR_PADRAO" IS 'Valor padrão. | Valor Padrão';
COMMENT ON COLUMN SBDB."GER_CAMPO"."AUTO" IS 'Campo automático. | Campo Automático';
COMMENT ON COLUMN SBDB."GER_CAMPO"."VALOR_CHECK" IS 'Checagem do valor na sintaxe do ORACLE. | Sintaxe de Checagem';
COMMENT ON COLUMN SBDB."GER_CAMPO"."CONJUNTO" IS 'Organização dos campos em conjunto. | Nome do Conjunto';
COMMENT ON COLUMN SBDB."GER_CAMPO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."GER_CAMPO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."GER_CAMPO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."GER_CAMPO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."GER_CAMPO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."GER_CAMPO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."GER_CAMPO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA GER_CLASSE
CREATE TABLE SBDB."GER_CLASSE" (
   "SISTEMA" VARCHAR2 (30),
   "CLASSE" VARCHAR2 (70),
   "DESCR" VARCHAR2 (4000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."GER_CLASSE" ADD CONSTRAINT "ID_GER_CLASSE"
PRIMARY KEY("SISTEMA", "CLASSE");

COMMENT ON TABLE SBDB."GER_CLASSE" IS 'Gerador | Classe de objetos. | Classe';

COMMENT ON COLUMN SBDB."GER_CLASSE"."SISTEMA" IS 'Sistema relacionado. | Sistema';
COMMENT ON COLUMN SBDB."GER_CLASSE"."CLASSE" IS 'Classe de objetos. | Classe';
COMMENT ON COLUMN SBDB."GER_CLASSE"."DESCR" IS 'Descrição. | Descrição da classe.';
COMMENT ON COLUMN SBDB."GER_CLASSE".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."GER_CLASSE".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."GER_CLASSE".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."GER_CLASSE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."GER_CLASSE".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."GER_CLASSE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."GER_CLASSE".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA GER_DIREITO
CREATE TABLE SBDB."GER_DIREITO" (
   "SEQ" NUMBER (11,0),
   "SISTEMA" VARCHAR2 (30),
   "GRUPO" VARCHAR2 (30),
   "OBJETO_SISTEMA" VARCHAR2 (30),
   "OBJETO_TIPO" VARCHAR2 (30),
   "OBJETO_NOME" VARCHAR2 (70),
   "OBJETO_CLASSE" VARCHAR2 (70),
   "USUARIO" VARCHAR2 (100),
   "PERMISSAO" VARCHAR2 (30)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."GER_DIREITO" ADD CONSTRAINT "ID_GER_DIREITO"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."GER_DIREITO" IS 'Gerador | Direitos de usuários. | Direito';

COMMENT ON COLUMN SBDB."GER_DIREITO"."SEQ" IS 'Sequencial de direitos do usuário. | Sequencial';
COMMENT ON COLUMN SBDB."GER_DIREITO"."SISTEMA" IS 'Sistema tratado por este direito. | Sistema';
COMMENT ON COLUMN SBDB."GER_DIREITO"."GRUPO" IS 'Grupo que possui tal permissão. | Grupo';
COMMENT ON COLUMN SBDB."GER_DIREITO"."OBJETO_SISTEMA" IS 'Sistema do objeto a ser considerado para permissão. | Sistema do Objeto';
COMMENT ON COLUMN SBDB."GER_DIREITO"."OBJETO_TIPO" IS 'Tipo do objeto. | Tipo do Objeto';
COMMENT ON COLUMN SBDB."GER_DIREITO"."OBJETO_NOME" IS 'Nome do objeto. | Nome do Objeto';
COMMENT ON COLUMN SBDB."GER_DIREITO"."OBJETO_CLASSE" IS 'Classe de objetos. | Classe do Objeto';
COMMENT ON COLUMN SBDB."GER_DIREITO"."USUARIO" IS 'Usuário que possui tal permissão. | Usuário';
COMMENT ON COLUMN SBDB."GER_DIREITO"."PERMISSAO" IS 'Permissões concedidas entre SEL;INS;UPD;DEL podendo ser mais de uma. | Permissões';
COMMENT ON COLUMN SBDB."GER_DIREITO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."GER_DIREITO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."GER_DIREITO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."GER_DIREITO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."GER_DIREITO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."GER_DIREITO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."GER_DIREITO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA GER_GRUPO
CREATE TABLE SBDB."GER_GRUPO" (
   "SISTEMA" VARCHAR2 (30),
   "GRUPO" VARCHAR2 (30),
   "DESCR" VARCHAR2 (100)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."GER_GRUPO" ADD CONSTRAINT "ID_GER_GRUPO"
PRIMARY KEY("SISTEMA", "GRUPO");

COMMENT ON TABLE SBDB."GER_GRUPO" IS 'Gerador | Grupo de usuários. | Grupo de Usuário';

COMMENT ON COLUMN SBDB."GER_GRUPO"."SISTEMA" IS 'Sistema relacionado. | Sistema Relacionado';
COMMENT ON COLUMN SBDB."GER_GRUPO"."GRUPO" IS 'Grupo de usuários. | Grupo de Usuários';
COMMENT ON COLUMN SBDB."GER_GRUPO"."DESCR" IS 'Descrição do grupo de usuários. | Descrição do Grupo';
COMMENT ON COLUMN SBDB."GER_GRUPO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."GER_GRUPO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."GER_GRUPO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."GER_GRUPO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."GER_GRUPO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."GER_GRUPO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."GER_GRUPO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA GER_INDICE
CREATE TABLE SBDB."GER_INDICE" (
   "SISTEMA" VARCHAR2 (30),
   "TABELA" VARCHAR2 (70),
   "NOME" VARCHAR2 (70),
   "CAMPOS" VARCHAR2 (150),
   "ORDENA" VARCHAR2 (4),
   "UNICO" NUMBER (1,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."GER_INDICE" ADD CONSTRAINT "ID_GER_INDICE"
PRIMARY KEY("SISTEMA", "TABELA", "NOME");

COMMENT ON TABLE SBDB."GER_INDICE" IS 'Gerador | Índices de tabela. | Índice';

COMMENT ON COLUMN SBDB."GER_INDICE"."SISTEMA" IS 'Sistema relacionado. | Sistema';
COMMENT ON COLUMN SBDB."GER_INDICE"."TABELA" IS 'Tabela. | Tabela';
COMMENT ON COLUMN SBDB."GER_INDICE"."NOME" IS 'Nome do índice. | Nome';
COMMENT ON COLUMN SBDB."GER_INDICE"."CAMPOS" IS 'Campos considerados para índice. | Campos';
COMMENT ON COLUMN SBDB."GER_INDICE"."ORDENA" IS 'Tipo de ordenação. | Ordenação';
COMMENT ON COLUMN SBDB."GER_INDICE"."UNICO" IS 'Marcado se índice único. | Único';
COMMENT ON COLUMN SBDB."GER_INDICE".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."GER_INDICE".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."GER_INDICE".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."GER_INDICE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."GER_INDICE".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."GER_INDICE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."GER_INDICE".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA GER_RELACIONAMENTO
CREATE TABLE SBDB."GER_RELACIONAMENTO" (
   "SISTEMA" VARCHAR2 (30),
   "NOME" VARCHAR2 (50),
   "TABELA_1" VARCHAR2 (70),
   "CAMPO_1" VARCHAR2 (150),
   "CHAVE_APRES_1" VARCHAR2 (150),
   "TABELA_N" VARCHAR2 (70),
   "CAMPO_N" VARCHAR2 (150),
   "CHAVE_APRES_N" VARCHAR2 (150),
   "DELETE_CASCADE" VARCHAR2 (10),
   "UPDATE_CASCADE" VARCHAR2 (10),
   "OBRIG" NUMBER (1,0),
   "CHAVE_EXPR" VARCHAR2 (150),
   "FORMATO" VARCHAR2 (150),
   "MASCARA" VARCHAR2 (150),
   "VALOR_PADRAO" VARCHAR2 (150),
   "COMPR_ZERO" NUMBER (1,0),
   "AUTO" VARCHAR2 (150),
   "EXPR_APRES" VARCHAR2 (150),
   "PROP_EXTEND" CLOB
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."GER_RELACIONAMENTO" ADD CONSTRAINT "ID_GER_RELACIONAMENTO"
PRIMARY KEY("SISTEMA", "NOME");

COMMENT ON TABLE SBDB."GER_RELACIONAMENTO" IS 'Gerador | Relacionamentos entre tabelas. | Relacionamento';

COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."SISTEMA" IS 'Sistema relacionado. | Sistema';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."NOME" IS 'Nome do relacionamento. | Nome';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."TABELA_1" IS 'Tabela relacionada no lado 1. | Tabela Lado 1';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."CAMPO_1" IS 'Campos relacionados no lado 1. | Campo Lado 1';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."CHAVE_APRES_1" IS 'Chave de apresentação para lado 1. | Chave de Apresentação Lado 1';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."TABELA_N" IS 'Tabela relacionada no lado N. | Tabela Lado N';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."CAMPO_N" IS 'Campos relacionados no lado N. | Campo Lado N';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."CHAVE_APRES_N" IS 'Chave de apresentação para lado N. | Chave de Apresentação Lado N';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."DELETE_CASCADE" IS 'Tipo de instrução para delete cascade. | Exclusão em Cascata';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."UPDATE_CASCADE" IS 'Tipo de instrução para update cascade. | Atualização em Cascata';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."OBRIG" IS 'Marcado se relacionamento obrigatório. | Obrigatório';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."CHAVE_EXPR" IS 'Chave de apresentação para relacionamento. | Chave de Apresentação Geral';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."FORMATO" IS 'Formato de apresentação. | Formato';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."MASCARA" IS 'Máscara de apresentação. | Máscara';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."VALOR_PADRAO" IS 'Valor padrão. | Valor Padrão';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."COMPR_ZERO" IS 'Permite comprimento zero? | Permite Comprimento Zero?';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."AUTO" IS 'Campo automático. | Critério Automático';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."EXPR_APRES" IS 'Expressão de apresentação. | Expressão de Apresentação';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO"."PROP_EXTEND" IS 'Propriedades extendidas. | Propriedades';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."GER_RELACIONAMENTO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA GER_SISTEMA
CREATE TABLE SBDB."GER_SISTEMA" (
   "NOME" VARCHAR2 (30),
   "DESCR" VARCHAR2 (50),
   "VER" VARCHAR2 (10),
   "DATA_VER" DATE,
   "REV" VARCHAR2 (10),
   "PARAM" VARCHAR2 (4000),
   "PROP_EXTEND" CLOB
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."GER_SISTEMA" ADD CONSTRAINT "ID_GER_SISTEMA"
PRIMARY KEY("NOME");

COMMENT ON TABLE SBDB."GER_SISTEMA" IS 'Gerador | Detalhes do sistema. | Sistema';

COMMENT ON COLUMN SBDB."GER_SISTEMA"."NOME" IS 'Nome do sistema. | Nome';
COMMENT ON COLUMN SBDB."GER_SISTEMA"."DESCR" IS 'Descrição do sistema. | Descrição';
COMMENT ON COLUMN SBDB."GER_SISTEMA"."VER" IS 'Versão do sistema. | Versão';
COMMENT ON COLUMN SBDB."GER_SISTEMA"."DATA_VER" IS 'Data da versão do sistema. | Data da Versão';
COMMENT ON COLUMN SBDB."GER_SISTEMA"."REV" IS 'Revisão do sistema. | Revisão';
COMMENT ON COLUMN SBDB."GER_SISTEMA"."PARAM" IS 'Parâmetros do sistema. | Parâmetros';
COMMENT ON COLUMN SBDB."GER_SISTEMA"."PROP_EXTEND" IS 'Propriedades extendidas do sistema. | Propriedades';
COMMENT ON COLUMN SBDB."GER_SISTEMA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."GER_SISTEMA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."GER_SISTEMA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."GER_SISTEMA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."GER_SISTEMA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."GER_SISTEMA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."GER_SISTEMA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA GER_TABELA
CREATE TABLE SBDB."GER_TABELA" (
   "SISTEMA" VARCHAR2 (30),
   "TABELA" VARCHAR2 (70),
   "ORDEM" NUMBER (11,0),
   "CODIGO" VARCHAR2 (30),
   "ETIQ" VARCHAR2 (50),
   "DESCR" VARCHAR2 (100),
   "CHAVE_PRIMA" VARCHAR2 (150),
   "CLASSE" VARCHAR2 (70),
   "CHAVE_APRES" VARCHAR2 (150),
   "DEPENDE" NUMBER (11,0),
   "INTERFERE" NUMBER (11,0),
   "CHAVE_FILTRO" VARCHAR2 (150),
   "PROP_EXTEND" CLOB
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."GER_TABELA" ADD CONSTRAINT "ID_GER_TABELA"
PRIMARY KEY("SISTEMA", "TABELA");

COMMENT ON TABLE SBDB."GER_TABELA" IS 'Gerador | Tabelas do sistema. | Tabelas';

COMMENT ON COLUMN SBDB."GER_TABELA"."SISTEMA" IS 'Sistema relacionado. | Sistema Relacionado';
COMMENT ON COLUMN SBDB."GER_TABELA"."TABELA" IS 'Nome da tabela. | Nome da Tabela';
COMMENT ON COLUMN SBDB."GER_TABELA"."ORDEM" IS 'Ordem de apresentação. | Ordem de Apresentação';
COMMENT ON COLUMN SBDB."GER_TABELA"."CODIGO" IS 'Código da tabela. | Código da Tabela';
COMMENT ON COLUMN SBDB."GER_TABELA"."ETIQ" IS 'Etiqueta de apresentação. | Etiqueta de Apresentação';
COMMENT ON COLUMN SBDB."GER_TABELA"."DESCR" IS 'Descrição em português. | Descrição em Português';
COMMENT ON COLUMN SBDB."GER_TABELA"."CHAVE_PRIMA" IS 'Chave primária da tabela. | Chave Primária da Tabela';
COMMENT ON COLUMN SBDB."GER_TABELA"."CLASSE" IS 'Classe da tabela. | Classe da Tabela';
COMMENT ON COLUMN SBDB."GER_TABELA"."CHAVE_APRES" IS 'Chave de apresentação. | Chave de Apresentação';
COMMENT ON COLUMN SBDB."GER_TABELA"."DEPENDE" IS 'Nível de dependência da tabela (zero não depende). | Nível de Dependência da Tabela';
COMMENT ON COLUMN SBDB."GER_TABELA"."INTERFERE" IS 'Nível de interferência da tabela (zero não interfere). | Nível de Interferência da Tabela';
COMMENT ON COLUMN SBDB."GER_TABELA"."CHAVE_FILTRO" IS 'Campos de filtro da tabela. | Campos de Filtro da Tabela';
COMMENT ON COLUMN SBDB."GER_TABELA"."PROP_EXTEND" IS 'Propriedades extendidas das tabelas. | Propriedades Extendidas';
COMMENT ON COLUMN SBDB."GER_TABELA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."GER_TABELA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."GER_TABELA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."GER_TABELA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."GER_TABELA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."GER_TABELA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."GER_TABELA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA GER_TIPO_OBJ
CREATE TABLE SBDB."GER_TIPO_OBJ" (
   "TIPO" VARCHAR2 (30),
   "DESCR" VARCHAR2 (200),
   "PERM_OPC" VARCHAR2 (70)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."GER_TIPO_OBJ" ADD CONSTRAINT "ID_GER_TIPO_OBJ"
PRIMARY KEY("TIPO");

COMMENT ON TABLE SBDB."GER_TIPO_OBJ" IS 'Gerador | Opções de tipo de objeto. | Tipo de Objeto';

COMMENT ON COLUMN SBDB."GER_TIPO_OBJ"."TIPO" IS 'Tipo de objeto. | Tipo';
COMMENT ON COLUMN SBDB."GER_TIPO_OBJ"."DESCR" IS 'Descrição. | Descrição do Tipo';
COMMENT ON COLUMN SBDB."GER_TIPO_OBJ"."PERM_OPC" IS 'Tipo de permissões que podem ser atribuídas a este tipo (lista separada por ponto e vírgula). | Permissões Possíveis';
COMMENT ON COLUMN SBDB."GER_TIPO_OBJ".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."GER_TIPO_OBJ".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."GER_TIPO_OBJ".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."GER_TIPO_OBJ".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."GER_TIPO_OBJ".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."GER_TIPO_OBJ".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."GER_TIPO_OBJ".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA GER_USUARIO
CREATE TABLE SBDB."GER_USUARIO" (
   "SISTEMA" VARCHAR2 (30),
   "USUARIO" VARCHAR2 (100),
   "NOME" VARCHAR2 (50),
   "DESCR" VARCHAR2 (4000),
   "SENHA" VARCHAR2 (50),
   "VALIDO_ATE" DATE,
   "GRUPO" VARCHAR2 (100),
   "PROP_EXTEND" CLOB
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."GER_USUARIO" ADD CONSTRAINT "ID_GER_USUARIO"
PRIMARY KEY("SISTEMA", "USUARIO");

COMMENT ON TABLE SBDB."GER_USUARIO" IS 'Gerador | Usuários de sistema. | Usuários do Sistema';

COMMENT ON COLUMN SBDB."GER_USUARIO"."SISTEMA" IS 'Sistema relacionado. | Sistema Relacionado';
COMMENT ON COLUMN SBDB."GER_USUARIO"."USUARIO" IS 'Usuário. | Usuário';
COMMENT ON COLUMN SBDB."GER_USUARIO"."NOME" IS 'Nome do usuário. | Nome do Usuário';
COMMENT ON COLUMN SBDB."GER_USUARIO"."DESCR" IS 'Atuação, localização, departamento ou qualquer texto descritivo do usuário. | Qualquer Texto Descritivo do Usuário';
COMMENT ON COLUMN SBDB."GER_USUARIO"."SENHA" IS 'Senha do usuário com ou sem registro . | Senha do Usuário';
COMMENT ON COLUMN SBDB."GER_USUARIO"."VALIDO_ATE" IS 'Usuário válido até. | Usuário Válido Até';
COMMENT ON COLUMN SBDB."GER_USUARIO"."GRUPO" IS 'Lista de grupos aos quais este usuário pertence. | Lista de Grupos';
COMMENT ON COLUMN SBDB."GER_USUARIO"."PROP_EXTEND" IS 'Propriedades extendidas para configuração. | Propriedades';
COMMENT ON COLUMN SBDB."GER_USUARIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."GER_USUARIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."GER_USUARIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."GER_USUARIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."GER_USUARIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."GER_USUARIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."GER_USUARIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA GER_VISAO
CREATE TABLE SBDB."GER_VISAO" (
   "SISTEMA" VARCHAR2 (30),
   "VISAO" VARCHAR2 (70),
   "ORDEM" NUMBER (11,0),
   "CLASSE" VARCHAR2 (70),
   "TEXTO" CLOB
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."GER_VISAO" ADD CONSTRAINT "ID_GER_VISAO"
PRIMARY KEY("SISTEMA", "VISAO");

COMMENT ON TABLE SBDB."GER_VISAO" IS 'Gerador | Visões do sistema. | Visão';

COMMENT ON COLUMN SBDB."GER_VISAO"."SISTEMA" IS 'Sistema relacionado. | Sistema';
COMMENT ON COLUMN SBDB."GER_VISAO"."VISAO" IS 'Nome da visão. | Visão';
COMMENT ON COLUMN SBDB."GER_VISAO"."ORDEM" IS 'Ordenação de apresentação dos objetos. | Ordem';
COMMENT ON COLUMN SBDB."GER_VISAO"."CLASSE" IS 'Especificação de classe. | Classe';
COMMENT ON COLUMN SBDB."GER_VISAO"."TEXTO" IS 'Texto da visão. | Texto de Criação';
COMMENT ON COLUMN SBDB."GER_VISAO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."GER_VISAO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."GER_VISAO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."GER_VISAO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."GER_VISAO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."GER_VISAO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."GER_VISAO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA HISTORICO_LICENCIADO
CREATE TABLE SBDB."HISTORICO_LICENCIADO" (
   "SOCIO_MAT" NUMBER (5,0),
   "DATA_INICIO" DATE,
   "DATA_FINAL" DATE,
   "MOTIVO" VARCHAR2 (3000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."HISTORICO_LICENCIADO" ADD CONSTRAINT "ID_HISTORICO_LICENCIADO"
PRIMARY KEY("SOCIO_MAT", "DATA_INICIO");

COMMENT ON TABLE SBDB."HISTORICO_LICENCIADO" IS 'SÓCIO | Cadastro do histórico dos associados licenciados. | Histórico de Licenciado';

COMMENT ON COLUMN SBDB."HISTORICO_LICENCIADO"."SOCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."HISTORICO_LICENCIADO"."DATA_INICIO" IS 'Data de início. | Data de Início';
COMMENT ON COLUMN SBDB."HISTORICO_LICENCIADO"."DATA_FINAL" IS 'Data de término. | Data de Término';
COMMENT ON COLUMN SBDB."HISTORICO_LICENCIADO"."MOTIVO" IS 'Motivo do licenciamento. | Motivo';
COMMENT ON COLUMN SBDB."HISTORICO_LICENCIADO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."HISTORICO_LICENCIADO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."HISTORICO_LICENCIADO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."HISTORICO_LICENCIADO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."HISTORICO_LICENCIADO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."HISTORICO_LICENCIADO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."HISTORICO_LICENCIADO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA HISTORICO_PENALIZADO
CREATE TABLE SBDB."HISTORICO_PENALIZADO" (
   "SOCIO_MAT" NUMBER (5,0),
   "DATA_INICIO" DATE,
   "DATA_FINAL" DATE,
   "MOTIVO" VARCHAR2 (3000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."HISTORICO_PENALIZADO" ADD CONSTRAINT "ID_HISTORICO_PENALIZADO"
PRIMARY KEY("SOCIO_MAT", "DATA_INICIO");

COMMENT ON TABLE SBDB."HISTORICO_PENALIZADO" IS 'SÓCIO | Cadastro do histórico dos associados penalizados. | Histórico de Penalizado';

COMMENT ON COLUMN SBDB."HISTORICO_PENALIZADO"."SOCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."HISTORICO_PENALIZADO"."DATA_INICIO" IS 'Data de início. | Data de Início';
COMMENT ON COLUMN SBDB."HISTORICO_PENALIZADO"."DATA_FINAL" IS 'Data de término. | Data de Término';
COMMENT ON COLUMN SBDB."HISTORICO_PENALIZADO"."MOTIVO" IS 'Motivo da penalização. | Motivo da Penalização';
COMMENT ON COLUMN SBDB."HISTORICO_PENALIZADO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."HISTORICO_PENALIZADO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."HISTORICO_PENALIZADO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."HISTORICO_PENALIZADO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."HISTORICO_PENALIZADO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."HISTORICO_PENALIZADO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."HISTORICO_PENALIZADO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA HISTORICO_SOCIO_ELETRONICO
CREATE TABLE SBDB."HISTORICO_SOCIO_ELETRONICO" (
   "PROTOCOLO" NUMBER (10,0),
   "SOCIO_MAT" NUMBER (5,0),
   "OPCAO" VARCHAR2 (10),
   "DATA" DATE,
   "ANO_VIGENCIA" VARCHAR2 (4)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."HISTORICO_SOCIO_ELETRONICO" ADD CONSTRAINT "ID_HISTORICO_SOCIO_ELETRONICO"
PRIMARY KEY("PROTOCOLO");

COMMENT ON TABLE SBDB."HISTORICO_SOCIO_ELETRONICO" IS 'SBDB | Armazena o histórico referente à preferência pelo sócio eletrônico dos associados. | Histórico do Sócio Eletrônico';

COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_ELETRONICO"."PROTOCOLO" IS 'Informa o número do protocolo. | Sequencial';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_ELETRONICO"."SOCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_ELETRONICO"."OPCAO" IS 'Informa o tipo de opção. | Opção';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_ELETRONICO"."DATA" IS 'Informa a data da opção. | Data';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_ELETRONICO"."ANO_VIGENCIA" IS 'Ano de vigência para a opção de associado eletrônico. | Ano Vigência';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_ELETRONICO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_ELETRONICO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_ELETRONICO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_ELETRONICO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_ELETRONICO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_ELETRONICO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_ELETRONICO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA HISTORICO_SOCIO_PUBL_END
CREATE TABLE SBDB."HISTORICO_SOCIO_PUBL_END" (
   "SEQ" NUMBER (5,0),
   "SOCIO_MAT" NUMBER (5,0),
   "DATA" DATE,
   "PUBLICAR_COM_1" NUMBER (1,0),
   "PUBLICAR_COM_2" NUMBER (1,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."HISTORICO_SOCIO_PUBL_END" ADD CONSTRAINT "ID_HISTORICO_SOCIO_PUBL_END"
PRIMARY KEY("SEQ", "SOCIO_MAT");

COMMENT ON TABLE SBDB."HISTORICO_SOCIO_PUBL_END" IS 'SBDB | Armazena o histórico referente a preferência do associado pela publicação do endereço na internet. | Histórico de Endereço Publicado na Web do Sócio';

COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_PUBL_END"."SEQ" IS 'Sequencial do histórico de publicação de endereço. | Sequencial';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_PUBL_END"."SOCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_PUBL_END"."DATA" IS 'Data da publicação. | Data da Publicação';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_PUBL_END"."PUBLICAR_COM_1" IS 'Indica se o primeiro endereço comercial vai ser publicado no site. | Publicar Endereço Comercial 1';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_PUBL_END"."PUBLICAR_COM_2" IS 'Indica se o segundo endereço comercial vai ser publicado no site. | Publicar Endereço Comercial 2';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_PUBL_END".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_PUBL_END".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_PUBL_END".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_PUBL_END".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_PUBL_END".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_PUBL_END".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."HISTORICO_SOCIO_PUBL_END".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA NEGOCIAÇÃO
CREATE TABLE SBDB."NEGOCIAÇÃO" (
   "SÓCIO_MAT" NUMBER (5,0),
   "SEQ" NUMBER (5,0),
   "DATA" DATE,
   "VALOR" FLOAT,
   "SALDO" FLOAT,
   "QTD_PARCELAS" NUMBER (5,0),
   "OBS" VARCHAR2 (3000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."NEGOCIAÇÃO" ADD CONSTRAINT "ID_NEGOCIAÇÃO"
PRIMARY KEY("SÓCIO_MAT", "SEQ");

COMMENT ON TABLE SBDB."NEGOCIAÇÃO" IS 'FINANCEIRO | Cadastro das negociações financeiras do associado junto a sociedade. | Negociação';

COMMENT ON COLUMN SBDB."NEGOCIAÇÃO"."SÓCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."NEGOCIAÇÃO"."SEQ" IS 'Sequencial de negociação. | Sequencial';
COMMENT ON COLUMN SBDB."NEGOCIAÇÃO"."DATA" IS 'Data de cadastro. | Data de Cadastro';
COMMENT ON COLUMN SBDB."NEGOCIAÇÃO"."VALOR" IS 'Valor. | Valor';
COMMENT ON COLUMN SBDB."NEGOCIAÇÃO"."SALDO" IS 'Saldo. | Saldo';
COMMENT ON COLUMN SBDB."NEGOCIAÇÃO"."QTD_PARCELAS" IS 'Quantidade de parcelas. | Quantidade de Parcelas';
COMMENT ON COLUMN SBDB."NEGOCIAÇÃO"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."NEGOCIAÇÃO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."NEGOCIAÇÃO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."NEGOCIAÇÃO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."NEGOCIAÇÃO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."NEGOCIAÇÃO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."NEGOCIAÇÃO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."NEGOCIAÇÃO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA OBRIGAÇÃO
CREATE TABLE SBDB."OBRIGAÇÃO" (
   "SÓCIO_MAT" NUMBER (5,0),
   "SEQ" NUMBER (5,0),
   "OBRIG_TIPO" VARCHAR2 (30),
   "DATA_LANÇAMENTO" DATE,
   "COMPETÊNCIA" DATE,
   "VALOR" FLOAT,
   "DATA_VENCIMENTO" DATE,
   "OBRIG_STATUS_COD" VARCHAR2 (50),
   "BANCO" VARCHAR2 (30),
   "AGÊNCIA" VARCHAR2 (10),
   "CONTA_CORRENTE" VARCHAR2 (50),
   "NR_CHEQUE" VARCHAR2 (50),
   "OBS" VARCHAR2 (100)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."OBRIGAÇÃO" ADD CONSTRAINT "ID_OBRIGAÇÃO"
PRIMARY KEY("SÓCIO_MAT", "SEQ");

COMMENT ON TABLE SBDB."OBRIGAÇÃO" IS 'FINANCEIRO | Cadastro das obrigações dos associados. | Obrigação';

COMMENT ON COLUMN SBDB."OBRIGAÇÃO"."SÓCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO"."OBRIG_TIPO" IS 'Tipo da obrigação. | Tipo da Obrigação';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO"."DATA_LANÇAMENTO" IS 'Data do lançamento. | Data do Lançamento';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO"."COMPETÊNCIA" IS 'Competência. | Competência da Obrigação';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO"."VALOR" IS 'Valor. | Valor da Obrigação';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO"."DATA_VENCIMENTO" IS 'Data de vencimento. | Data do Vencimento';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO"."OBRIG_STATUS_COD" IS 'Status financeiro. | Status Financeiro';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO"."BANCO" IS 'Banco. | Banco';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO"."AGÊNCIA" IS 'Agência do banco. | Agência';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO"."CONTA_CORRENTE" IS 'Conta corrente. | Conta Corrente';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO"."NR_CHEQUE" IS 'Número do cheque. | Número do Cheque';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA OBRIGAÇÃO_STATUS
CREATE TABLE SBDB."OBRIGAÇÃO_STATUS" (
   "COD" VARCHAR2 (50),
   "TIPO" VARCHAR2 (50),
   "DESCRIÇÃO" VARCHAR2 (100),
   "PARAM" VARCHAR2 (100)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."OBRIGAÇÃO_STATUS" ADD CONSTRAINT "ID_OBRIGAÇÃO_STATUS"
PRIMARY KEY("COD");

COMMENT ON TABLE SBDB."OBRIGAÇÃO_STATUS" IS 'FINANCEIRO | Cadastro dos status das obrigações. | Status de Obrigação';

COMMENT ON COLUMN SBDB."OBRIGAÇÃO_STATUS"."COD" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_STATUS"."TIPO" IS 'Tipo de obrigação. | Tipo de Status';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_STATUS"."DESCRIÇÃO" IS 'Descrição. | Descrição';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_STATUS"."PARAM" IS 'Parâmetro. | Parâmetros';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_STATUS".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_STATUS".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_STATUS".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_STATUS".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_STATUS".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_STATUS".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_STATUS".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA OBRIGAÇÃO_TIPO
CREATE TABLE SBDB."OBRIGAÇÃO_TIPO" (
   "TIPO" VARCHAR2 (30),
   "DESCRIÇÃO" VARCHAR2 (100),
   "PARAM" VARCHAR2 (15),
   "INDICE_BOLETO" VARCHAR2 (2),
   "FORMA_PGTO" VARCHAR2 (10)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."OBRIGAÇÃO_TIPO" ADD CONSTRAINT "ID_OBRIGAÇÃO_TIPO"
PRIMARY KEY("TIPO");

COMMENT ON TABLE SBDB."OBRIGAÇÃO_TIPO" IS 'FINANCEIRO | Cadastro dos tipo de obrigação. | Tipo de Obrigação';

COMMENT ON COLUMN SBDB."OBRIGAÇÃO_TIPO"."TIPO" IS 'Tipo de obrigação. | Tipo';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_TIPO"."DESCRIÇÃO" IS 'Descrição. | Descrição';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_TIPO"."PARAM" IS 'Parâmetro. | Parâmetro';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_TIPO"."INDICE_BOLETO" IS 'Índice do boleto. | Índice do Boleto';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_TIPO"."FORMA_PGTO" IS 'Forma de pagamento. | Forma de Pagamento';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_TIPO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_TIPO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_TIPO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_TIPO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_TIPO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_TIPO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."OBRIGAÇÃO_TIPO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA ÓRGÃO
CREATE TABLE SBDB."ÓRGÃO" (
   "NOME" VARCHAR2 (100),
   "ÓRGÃO_TIPO" VARCHAR2 (50),
   "ATUAÇÃO" VARCHAR2 (30),
   "DESCRIÇÃO" VARCHAR2 (300),
   "REGIONAL_COD" VARCHAR2 (2),
   "BLOQUEADO" VARCHAR2 (1)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."ÓRGÃO" ADD CONSTRAINT "ID_ÓRGÃO"
PRIMARY KEY("NOME");

COMMENT ON TABLE SBDB."ÓRGÃO" IS 'GESTÃO | Cadastros dos órgãos que integram a sociedade. | Órgão';

COMMENT ON COLUMN SBDB."ÓRGÃO"."NOME" IS 'Nome do órgão. | Órgão';
COMMENT ON COLUMN SBDB."ÓRGÃO"."ÓRGÃO_TIPO" IS 'Tipo do órgão. | Tipo de órgão';
COMMENT ON COLUMN SBDB."ÓRGÃO"."ATUAÇÃO" IS 'Atuação do órgão. | Atuação';
COMMENT ON COLUMN SBDB."ÓRGÃO"."DESCRIÇÃO" IS 'Descrição do órgão. | Descrição';
COMMENT ON COLUMN SBDB."ÓRGÃO"."REGIONAL_COD" IS 'Código da regional que pertence o órgão. | Regional';
COMMENT ON COLUMN SBDB."ÓRGÃO"."BLOQUEADO" IS 'Status do bloqueio do órgão. | Bloqueado';
COMMENT ON COLUMN SBDB."ÓRGÃO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."ÓRGÃO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."ÓRGÃO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."ÓRGÃO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."ÓRGÃO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."ÓRGÃO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."ÓRGÃO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA ÓRGÃO_GESTÃO
CREATE TABLE SBDB."ÓRGÃO_GESTÃO" (
   "ÓRGÃO_NOME" VARCHAR2 (100),
   "GESTÃO_INI" DATE,
   "ÓRGÃO_CARGO" VARCHAR2 (100),
   "ORDEM" NUMBER (4,0),
   "GESTÃO_FIM" DATE,
   "DATA_ELEIÇÃO" DATE
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."ÓRGÃO_GESTÃO" ADD CONSTRAINT "ID_ÓRGÃO_GESTÃO"
PRIMARY KEY("ÓRGÃO_NOME", "GESTÃO_INI", "ÓRGÃO_CARGO");

COMMENT ON TABLE SBDB."ÓRGÃO_GESTÃO" IS 'GESTÃO | Cadastros órgãos pertencentes as gestões. | Gestão do Órgão';

COMMENT ON COLUMN SBDB."ÓRGÃO_GESTÃO"."ÓRGÃO_NOME" IS 'Nome do órgão. | Órgão';
COMMENT ON COLUMN SBDB."ÓRGÃO_GESTÃO"."GESTÃO_INI" IS 'Data de inicio da gestão. | Mês/Ano do Início da Gestão';
COMMENT ON COLUMN SBDB."ÓRGÃO_GESTÃO"."ÓRGÃO_CARGO" IS 'Cargo do órgão. | Cargo';
COMMENT ON COLUMN SBDB."ÓRGÃO_GESTÃO"."ORDEM" IS 'Ordenação de visualização dos dados. | Ordenação';
COMMENT ON COLUMN SBDB."ÓRGÃO_GESTÃO"."GESTÃO_FIM" IS 'Data final da gestão. | Mês/Ano de Término da Gestão';
COMMENT ON COLUMN SBDB."ÓRGÃO_GESTÃO"."DATA_ELEIÇÃO" IS 'Data da eleição. | Data da Eleição';
COMMENT ON COLUMN SBDB."ÓRGÃO_GESTÃO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."ÓRGÃO_GESTÃO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."ÓRGÃO_GESTÃO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."ÓRGÃO_GESTÃO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."ÓRGÃO_GESTÃO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."ÓRGÃO_GESTÃO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."ÓRGÃO_GESTÃO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA ÓRGÃO_MEMBRO
CREATE TABLE SBDB."ÓRGÃO_MEMBRO" (
   "ÓRGÃO_NOME" VARCHAR2 (100),
   "ORDEM" NUMBER (3,0),
   "ÓRGÃO_CARGO" VARCHAR2 (100),
   "ÓRGÃO_GESTÃO_INI" DATE,
   "SÓCIO_MAT" NUMBER (5,0),
   "CONTATO" VARCHAR2 (50),
   "TEL" VARCHAR2 (50),
   "OBS" VARCHAR2 (3000),
   "STATUS" VARCHAR2 (1)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."ÓRGÃO_MEMBRO" ADD CONSTRAINT "ID_ÓRGÃO_MEMBRO"
PRIMARY KEY("ÓRGÃO_NOME", "ÓRGÃO_CARGO", "ÓRGÃO_GESTÃO_INI", "SÓCIO_MAT");

COMMENT ON TABLE SBDB."ÓRGÃO_MEMBRO" IS 'GESTÃO | Cadastro dos membros dos órgãos. | Membro do Órgão';

COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO"."ÓRGÃO_NOME" IS 'Nome do órgão. | Órgão';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO"."ORDEM" IS 'Ordenação para visualização da informação. | Ordenação';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO"."ÓRGÃO_CARGO" IS 'Cargo do órgão. | Cargo';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO"."ÓRGÃO_GESTÃO_INI" IS 'Data de inicio da gestão. | Mês/Ano do Início da Gestão';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO"."SÓCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO"."CONTATO" IS 'Contato. | Contato';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO"."TEL" IS 'Telefone do membro. | Telefone';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO"."OBS" IS 'Observações sobre o membro. | Observação';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO"."STATUS" IS 'Status do membro (A=Ativo, I=Inativo). | Status';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."ÓRGÃO_MEMBRO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA ÓRGÃO_TIPO
CREATE TABLE SBDB."ÓRGÃO_TIPO" (
   "TIPO" VARCHAR2 (50),
   "DESCRIÇÃO" VARCHAR2 (100)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."ÓRGÃO_TIPO" ADD CONSTRAINT "ID_ÓRGÃO_TIPO"
PRIMARY KEY("TIPO");

COMMENT ON TABLE SBDB."ÓRGÃO_TIPO" IS 'GESTÃO | Cadastro dos Tipo de órgão que integram a sociedade. | Tipo do Órgão';

COMMENT ON COLUMN SBDB."ÓRGÃO_TIPO"."TIPO" IS 'Tipo do órgão. | Tipo do Órgão';
COMMENT ON COLUMN SBDB."ÓRGÃO_TIPO"."DESCRIÇÃO" IS 'Descrição do tipo de órgão. | Descrição';
COMMENT ON COLUMN SBDB."ÓRGÃO_TIPO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."ÓRGÃO_TIPO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."ÓRGÃO_TIPO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."ÓRGÃO_TIPO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."ÓRGÃO_TIPO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."ÓRGÃO_TIPO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."ÓRGÃO_TIPO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA PAGAMENTO
CREATE TABLE SBDB."PAGAMENTO" (
   "SÓCIO_MAT" NUMBER (5,0),
   "OBRIG_SEQ" NUMBER (5,0),
   "SEQ" NUMBER (5,0),
   "DATA" DATE,
   "VALOR" FLOAT,
   "DESCONTO" FLOAT,
   "MULTA" FLOAT,
   "JUROS" FLOAT,
   "TARIFA" FLOAT,
   "OBS" VARCHAR2 (3000),
   "ARQ_SEQ" NUMBER (5,0),
   "ARQ_PAG" NUMBER (5,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."PAGAMENTO" ADD CONSTRAINT "ID_PAGAMENTO"
PRIMARY KEY("SÓCIO_MAT", "OBRIG_SEQ", "SEQ");

COMMENT ON TABLE SBDB."PAGAMENTO" IS 'FINANCEIRO | Cadastro do pagamentos realizados. | Pagamento';

COMMENT ON COLUMN SBDB."PAGAMENTO"."SÓCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."PAGAMENTO"."OBRIG_SEQ" IS 'Sequencial da obrigação. | Sequencial da Obrigação';
COMMENT ON COLUMN SBDB."PAGAMENTO"."SEQ" IS 'Sequencial do pagamento. | Sequencial';
COMMENT ON COLUMN SBDB."PAGAMENTO"."DATA" IS 'Data da obrigação. | Data do Pagamento';
COMMENT ON COLUMN SBDB."PAGAMENTO"."VALOR" IS 'Valor da obrigação. | Valor do Pagamento';
COMMENT ON COLUMN SBDB."PAGAMENTO"."DESCONTO" IS 'Valor do desconto. | Valor do Desconto';
COMMENT ON COLUMN SBDB."PAGAMENTO"."MULTA" IS 'Valor da multa. | Valor da Multa';
COMMENT ON COLUMN SBDB."PAGAMENTO"."JUROS" IS 'Valor do juro. | Valor do Juro';
COMMENT ON COLUMN SBDB."PAGAMENTO"."TARIFA" IS 'Valor da tarifa. | Valor da Tarifa';
COMMENT ON COLUMN SBDB."PAGAMENTO"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."PAGAMENTO"."ARQ_SEQ" IS 'Sequencial do arquivo. | Referência do Arquivo';
COMMENT ON COLUMN SBDB."PAGAMENTO"."ARQ_PAG" IS 'Nome do arquivo. | Referência de Sequencial do Pagamento do Arquivo';
COMMENT ON COLUMN SBDB."PAGAMENTO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."PAGAMENTO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."PAGAMENTO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."PAGAMENTO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."PAGAMENTO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."PAGAMENTO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."PAGAMENTO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA PARAMETRO_FINANCEIRO
CREATE TABLE SBDB."PARAMETRO_FINANCEIRO" (
   "ANUIDADE" NUMBER (4,0),
   "SITUACAO" VARCHAR2 (3000),
   "CATEGORIA" VARCHAR2 (3000),
   "DIAS_VALIDADE" NUMBER (3,0),
   "CUN_DATA_JUROS" DATE,
   "CUN_DATA_DESC" DATE,
   "CUN_DATA_VENCIMENTO" DATE,
   "CUN_TARIFA" NUMBER (5,2),
   "CUN_MENSAGEM" VARCHAR2 (3000),
   "PRS_TARIFA" NUMBER (5,2),
   "PR1_MENSAGEM" VARCHAR2 (3000),
   "PR2_MENSAGEM" VARCHAR2 (3000),
   "PR3_MENSAGEM" VARCHAR2 (3000),
   "PR1_DATA_VENCIMENTO" DATE,
   "PR2_DATA_VENCIMENTO" DATE,
   "PR3_DATA_VENCIMENTO" DATE,
   "EMISSAO_BOLETO" VARCHAR2 (1),
   "DATA_LIMITE_VENCIMENTO" DATE,
   "SE_DESCONTO" NUMBER (5,2),
   "SE_DATA_INICIO" DATE,
   "SE_DATA_FINAL" DATE
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."PARAMETRO_FINANCEIRO" ADD CONSTRAINT "ID_PARAMETRO_FINANCEIRO"
PRIMARY KEY("ANUIDADE");

COMMENT ON TABLE SBDB."PARAMETRO_FINANCEIRO" IS 'PARAMETRO | Cadastro das parametrizações  referente ao módulo financeiro. | Parâmetro Financeiro';

COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."ANUIDADE" IS 'Anuidade da obrigação. | Anuidade';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."SITUACAO" IS 'Situações que não serão impressas. | Situação Administrativa';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."CATEGORIA" IS 'Categorias que não serão impressas. | Categoria';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."DIAS_VALIDADE" IS 'Dias de prorrogação de pagamento para considerar o fim de semana e feriado. | Dias de Prorrogação de Pagamento';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."CUN_DATA_JUROS" IS 'Data sem juros para cota única. | Data para Cobrança sem Juros da Cota Única';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."CUN_DATA_DESC" IS 'Data com desconto para cota única. | Data Limite para Cobrança com Desc.  da Cota Única';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."CUN_DATA_VENCIMENTO" IS 'Data de vencimento para cota única. | Data de Vencimento';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."CUN_TARIFA" IS 'Valor da tarifa para cota única. | Valor da Tarifa da Cota Única';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."CUN_MENSAGEM" IS 'Instruções para cota única. | Mensagem para Cota Única';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."PRS_TARIFA" IS 'Valor da tarifa para as parcelas. | Valor da Tarifa das Parcelas';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."PR1_MENSAGEM" IS 'Instruções para primeira parcela. | Instrução para Primeira para Parcela';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."PR2_MENSAGEM" IS 'Instruções para segunda parcela. | Instrução para Segunda para Parcela';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."PR3_MENSAGEM" IS 'Instruções para terceira parcela. | Instrução para Terceira para Parcela';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."PR1_DATA_VENCIMENTO" IS 'Data de vencimento para primeira parcela. | Data de Vencimento';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."PR2_DATA_VENCIMENTO" IS 'Data de vencimento para segunda parcela. | Data de Vencimento';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."PR3_DATA_VENCIMENTO" IS 'Data de vencimento para terceira parcela. | Data de Vencimento';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."EMISSAO_BOLETO" IS 'Status de emissão do boleto (S=Sim, N=Não). | Status de Emissão do Boleto';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."DATA_LIMITE_VENCIMENTO" IS 'Data de validade do boleto. | Data Limite Vencimento';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."SE_DESCONTO" IS 'informa o valor percentual do desconto para o associado que optou pela mídia eletrônica. | Valor de Desconto';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."SE_DATA_INICIO" IS 'Data de início para optar pela mídia eletrônica. | Data de Início';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO"."SE_DATA_FINAL" IS 'Data de término do desconto para o sócio eletrônico. | Data de Término';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."PARAMETRO_FINANCEIRO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA PARCELAMENTO
CREATE TABLE SBDB."PARCELAMENTO" (
   "NEG_SEQ" NUMBER (5,0),
   "SÓCIO_MAT" NUMBER (5,0),
   "SEQ" NUMBER (5,0),
   "OBRIG_ANTERIOR" NUMBER (5,0),
   "OBRIG_NOVA" NUMBER (5,0),
   "DATA" DATE,
   "VALOR" FLOAT,
   "SALDO" FLOAT
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."PARCELAMENTO" ADD CONSTRAINT "ID_PARCELAMENTO"
PRIMARY KEY("NEG_SEQ", "SÓCIO_MAT", "SEQ");

COMMENT ON TABLE SBDB."PARCELAMENTO" IS 'FINANCEIRO | Cadastro das parcelas negociadas. | Parcelamento';

COMMENT ON COLUMN SBDB."PARCELAMENTO"."NEG_SEQ" IS 'Sequencial da negociação. | Sequencial da Negociação';
COMMENT ON COLUMN SBDB."PARCELAMENTO"."SÓCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."PARCELAMENTO"."SEQ" IS 'Sequencial do parcelamento. | Sequencial';
COMMENT ON COLUMN SBDB."PARCELAMENTO"."OBRIG_ANTERIOR" IS 'Sequencial da obrigação anterior. | Sequencial da Obrigação Anterior';
COMMENT ON COLUMN SBDB."PARCELAMENTO"."OBRIG_NOVA" IS 'Sequencial da obrigação nova. | Sequencial da Obrigação Nova';
COMMENT ON COLUMN SBDB."PARCELAMENTO"."DATA" IS 'Data do parcelamento. | Data';
COMMENT ON COLUMN SBDB."PARCELAMENTO"."VALOR" IS 'Valor. | Valor';
COMMENT ON COLUMN SBDB."PARCELAMENTO"."SALDO" IS 'Saldo. | Saldo';
COMMENT ON COLUMN SBDB."PARCELAMENTO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."PARCELAMENTO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."PARCELAMENTO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."PARCELAMENTO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."PARCELAMENTO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."PARCELAMENTO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."PARCELAMENTO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA PROD_FINA
CREATE TABLE SBDB."PROD_FINA" (
   "SEQ" NUMBER (10,0),
   "TITULO" VARCHAR2 (200),
   "DESCR" VARCHAR2 (200),
   "DATA_INICIO" DATE,
   "DATA_TERMINO" DATE,
   "RESPONSAVEL" VARCHAR2 (200),
   "EMAIL_CONTATO" VARCHAR2 (200),
   "REF_DESCR" VARCHAR2 (200),
   "ORDEM" NUMBER (11,0),
   "VALOR" FLOAT,
   "INFO" VARCHAR2 (4000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."PROD_FINA" ADD CONSTRAINT "ID_PROD_FINA"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."PROD_FINA" IS 'FINANCEIRO | Produto financeiro. | Produto Financeiro';

COMMENT ON COLUMN SBDB."PROD_FINA"."SEQ" IS 'Sequencial e código do produto. | Sequencial';
COMMENT ON COLUMN SBDB."PROD_FINA"."TITULO" IS 'Título ou especificação resumida da condição de recebimento. | Título do Produto';
COMMENT ON COLUMN SBDB."PROD_FINA"."DESCR" IS 'Descrição do produto e não esqueça de incluir ano ou alguma especificação de sequência para evento. | Descrição do Produto';
COMMENT ON COLUMN SBDB."PROD_FINA"."DATA_INICIO" IS 'Início do período durante o qual são possíveis as emissões de boleto. | Início de Recebimento';
COMMENT ON COLUMN SBDB."PROD_FINA"."DATA_TERMINO" IS 'Término do período durante o qual são possíveis as emissões de boleto. | Término de Recebimento';
COMMENT ON COLUMN SBDB."PROD_FINA"."RESPONSAVEL" IS 'Texto aberto informando o responsável pelo produto (ou evento), podendo ser pessoal terceirizado. | Nome';
COMMENT ON COLUMN SBDB."PROD_FINA"."EMAIL_CONTATO" IS 'Lista de emails separados por ponto e vírgula que receberão assuntos relacionados com o produto negociado. | Email';
COMMENT ON COLUMN SBDB."PROD_FINA"."REF_DESCR" IS 'Descreve como o conteúdo do campo referência é montado. | Referência do Produto';
COMMENT ON COLUMN SBDB."PROD_FINA"."ORDEM" IS 'Informe número para ordenação sendo o item com menor ordem o primeiro. | Ordem';
COMMENT ON COLUMN SBDB."PROD_FINA"."VALOR" IS 'Valor em Reais do produto oferecido. | Custo do Produto';
COMMENT ON COLUMN SBDB."PROD_FINA"."INFO" IS 'Informações adicionais sobre o produto. | Informações Adicionais';
COMMENT ON COLUMN SBDB."PROD_FINA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."PROD_FINA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."PROD_FINA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."PROD_FINA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."PROD_FINA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."PROD_FINA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."PROD_FINA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA PROD_USUARIO
CREATE TABLE SBDB."PROD_USUARIO" (
   "SEQ" NUMBER (11,0),
   "CPF" VARCHAR2 (12),
   "CNPJ" VARCHAR2 (15),
   "SOCIO_MAT" NUMBER (5,0),
   "NOME" VARCHAR2 (50),
   "NOME_PREFERENCIAL" VARCHAR2 (50),
   "LOGIN" VARCHAR2 (30),
   "SENHA" VARCHAR2 (20),
   "MOMENTO_INSCR" DATE,
   "VALIDO_ATE" DATE,
   "INFO_CONTATO" VARCHAR2 (200),
   "ENDERECO" VARCHAR2 (60),
   "NUMERO" VARCHAR2 (30),
   "COMPLEMENTO" VARCHAR2 (30),
   "BAIRRO" VARCHAR2 (50),
   "CIDADE" VARCHAR2 (50),
   "PAIS" VARCHAR2 (30),
   "ESTADO" VARCHAR2 (2),
   "ESTADO_EX" VARCHAR2 (2),
   "CEP" VARCHAR2 (10),
   "TEL_RES" VARCHAR2 (40),
   "TEL_COM" VARCHAR2 (40),
   "TEL_CEL" VARCHAR2 (40),
   "FAX" VARCHAR2 (40),
   "EMAIL_PRINCIPAL" VARCHAR2 (200),
   "EMAIL_OPCIONAL" VARCHAR2 (200),
   "SITE" VARCHAR2 (200),
   "CONHECEU" VARCHAR2 (1000),
   "MOTIVO" VARCHAR2 (1000),
   "CRM" VARCHAR2 (20),
   "CATEGORIA" VARCHAR2 (50),
   "PROFISSAO" VARCHAR2 (50),
   "INSTITUICAO" VARCHAR2 (100),
   "CARGO" VARCHAR2 (50),
   "SETOR" VARCHAR2 (50),
   "AREA" VARCHAR2 (50),
   "ATUACAO" VARCHAR2 (50),
   "FORMACAO" VARCHAR2 (50),
   "ESPECIALIZACAO" VARCHAR2 (50),
   "UNIVERSIDADE" VARCHAR2 (100)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."PROD_USUARIO" ADD CONSTRAINT "ID_PROD_USUARIO"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."PROD_USUARIO" IS 'SBDB | Usuários de produtos do sistema. | Usuários de Produtos';

COMMENT ON COLUMN SBDB."PROD_USUARIO"."SEQ" IS 'Sequencial de inscrição. | Sequencial';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."CPF" IS 'CPF caso o inscrito seja pessoa física. | CPF';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."CNPJ" IS 'CNPJ caso seja pessoa jurídica. | CNPJ';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."SOCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."NOME" IS 'Nome. | Nome';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."NOME_PREFERENCIAL" IS 'Nome preferencial. | Nome Preferencial';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."LOGIN" IS 'Login do inscrito caso este opte por um. | Login';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."SENHA" IS 'Senha do inscrito. | Senha';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."MOMENTO_INSCR" IS 'Momento no qual o inscrito é inserido na base. | Momento de Inscrição';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."VALIDO_ATE" IS 'Momento até o qual este inscrito é válido. | Válido Até';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."INFO_CONTATO" IS 'Detalhes para sobre possibilidades de contato com o inscrito. | Dados de Contato';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."ENDERECO" IS 'Endereço completo, tipo (rua, av.), logradouro e número. | Endereço';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."NUMERO" IS 'Número. | Número';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."COMPLEMENTO" IS 'Complemento. | Complemento';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."BAIRRO" IS 'Bairro. | Bairro';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."CIDADE" IS 'Cidade. | Cidade';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."PAIS" IS 'País. | País';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."ESTADO" IS 'Estado. | Estado';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."ESTADO_EX" IS 'Estado caso seja país estrangeiro. | Estado no Exterior';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."CEP" IS 'CEP. | CEP';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."TEL_RES" IS 'Telefone residencial. | Telefone Residencial';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."TEL_COM" IS 'Telefone comercial. | Telefone Comercial';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."TEL_CEL" IS 'Telefone celular. | Telefone Celular';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."FAX" IS 'Telefone de recebimento de fax. | Fax';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."EMAIL_PRINCIPAL" IS 'Email preferencial. | Email Principal';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."EMAIL_OPCIONAL" IS 'Outro email caso exista. | Email Opcional';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."SITE" IS 'Site caso o inscrito possua um. | Site';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."CONHECEU" IS 'Detalhes sobre como conheceu a opção desejada. | Como Conheceu';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."MOTIVO" IS 'Motivo do interesse pela opção desejada. | Motivo';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."CRM" IS 'CRM quando usuário for um médico registrado. | CRM';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."CATEGORIA" IS 'Categoria entre profissional ou estudante. | Categoria';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."PROFISSAO" IS 'Profissão desempenhada pelo inscrito. | Profissão';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."INSTITUICAO" IS 'Nome da instituição onde trabalha. | Instituição onde Trabalha';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."CARGO" IS 'Cargo que ocupa na instituição. | Cargo na Instituição';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."SETOR" IS 'Setor. | Setor';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."AREA" IS 'Área de atuação. | Área de Atuação';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."ATUACAO" IS 'Formas de atuação no mercado em que trabalha. | Atuação no Mercado';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."FORMACAO" IS 'Sua formação acadêmica. | Formação';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."ESPECIALIZACAO" IS 'Especialização caso possua. | Especialização';
COMMENT ON COLUMN SBDB."PROD_USUARIO"."UNIVERSIDADE" IS 'Nome da universidade de formatura. | Nome da Universidade de Formatura';
COMMENT ON COLUMN SBDB."PROD_USUARIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."PROD_USUARIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."PROD_USUARIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."PROD_USUARIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."PROD_USUARIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."PROD_USUARIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."PROD_USUARIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA PRODUTO
CREATE TABLE SBDB."PRODUTO" (
   "SEQ" NUMBER (10,0),
   "TITULO" VARCHAR2 (100),
   "DESCR" VARCHAR2 (200),
   "DATA_INICIO" DATE,
   "DATA_TERMINO" DATE,
   "RESPONSAVEL" VARCHAR2 (200),
   "EMAIL_CONTATO" VARCHAR2 (200),
   "REF_DESCR" VARCHAR2 (200),
   "ORDEM" NUMBER (11,0),
   "VALOR" FLOAT,
   "INFO" VARCHAR2 (4000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."PRODUTO" ADD CONSTRAINT "ID_PRODUTO"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."PRODUTO" IS 'FINANCEIRO | Especificação de formas de receita. | Formas de Receita';

COMMENT ON COLUMN SBDB."PRODUTO"."SEQ" IS 'Sequencial e código do produto. | Sequencial';
COMMENT ON COLUMN SBDB."PRODUTO"."TITULO" IS 'Título ou especificação resumida da condição de recebimento. | Título do Produto';
COMMENT ON COLUMN SBDB."PRODUTO"."DESCR" IS 'Descrição do produto e não esqueça de incluir ano ou alguma especificação de sequência para evento. | Descrição do Produto';
COMMENT ON COLUMN SBDB."PRODUTO"."DATA_INICIO" IS 'Início do período durante o qual são possíveis as emissões de boleto. | Início de Recebimento';
COMMENT ON COLUMN SBDB."PRODUTO"."DATA_TERMINO" IS 'Término do período durante o qual são possíveis as emissões de boleto. | Término de Recebimento';
COMMENT ON COLUMN SBDB."PRODUTO"."RESPONSAVEL" IS 'Texto aberto informando o responsável pelo produto (ou evento), podendo ser pessoal terceirizado. | Nome';
COMMENT ON COLUMN SBDB."PRODUTO"."EMAIL_CONTATO" IS 'Lista de emails separados por ponto e vírgula que receberão assuntos relacionados com o produto negociado. | Email';
COMMENT ON COLUMN SBDB."PRODUTO"."REF_DESCR" IS 'Descreve como o conteúdo do campo referência é montado. | Referência do Produto';
COMMENT ON COLUMN SBDB."PRODUTO"."ORDEM" IS 'Informe número para ordenação sendo o item com menor ordem o primeiro. | Ordem';
COMMENT ON COLUMN SBDB."PRODUTO"."VALOR" IS 'Valor em Reais do produto oferecido. | Custo do Produto';
COMMENT ON COLUMN SBDB."PRODUTO"."INFO" IS 'Informações adicionais sobre o produto. | Informações Adicionais';
COMMENT ON COLUMN SBDB."PRODUTO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."PRODUTO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."PRODUTO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."PRODUTO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."PRODUTO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."PRODUTO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."PRODUTO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA PROPOSTA
CREATE TABLE SBDB."PROPOSTA" (
   "SEQ" NUMBER (5,0),
   "NOME" VARCHAR2 (50),
   "DATA_CADASTRO" DATE,
   "TRATAMENTO" VARCHAR2 (10),
   "NOME_PREFERENCIAL" VARCHAR2 (50),
   "CRM_ESTADO" VARCHAR2 (2),
   "CRM" VARCHAR2 (20),
   "CRM_DATA" DATE,
   "MLN" VARCHAR2 (20),
   "SEXO" VARCHAR2 (1),
   "CPF" VARCHAR2 (12),
   "ID_ORGAO" VARCHAR2 (10),
   "IDENTIDADE" VARCHAR2 (15),
   "NATURALIDADE" VARCHAR2 (2),
   "NACIONALIDADE" VARCHAR2 (20),
   "DATA_NASCIMENTO" DATE,
   "FILIAÇÃO_PAI" VARCHAR2 (50),
   "FILIAÇÃO_MÃE" VARCHAR2 (50),
   "ESTADO_CIVIL" VARCHAR2 (10),
   "REGIONAL_COD" VARCHAR2 (2),
   "CATEGORIA_COD" VARCHAR2 (20),
   "OBRIG_STATUS_COD" VARCHAR2 (50),
   "OBRIG_STATUS_DATA" DATE,
   "TED" NUMBER (5,0),
   "TED_ANO_CONCURSO" DATE,
   "TED_DATA_EXPEDIÇÃO" DATE,
   "TED_DATA_APROVAÇÃO" DATE,
   "TED_IMPRESSÃO" NUMBER (5,0),
   "CFM_ADESAO" DATE,
   "CFM_OBS" VARCHAR2 (3000),
   "DATA_INICIO_CONTAGEM" DATE,
   "SOCIO_ELETRONICO" NUMBER (1,0),
   "SITE" VARCHAR2 (4000),
   "FOTO" VARCHAR2 (100),
   "MALA_DIRETA" VARCHAR2 (1),
   "ENDEREÇO_RESIDENCIAL" VARCHAR2 (60),
   "NUMERO_RESIDENCIAL" VARCHAR2 (30),
   "COMPLEMENTO_RESIDENCIAL" VARCHAR2 (30),
   "BAIRRO_RESIDENCIAL" VARCHAR2 (50),
   "CIDADE_RESIDENCIAL" VARCHAR2 (50),
   "ESTADO_RESIDENCIAL" VARCHAR2 (2),
   "ESTADO_RESIDENCIAL_EX" VARCHAR2 (2),
   "PAÍS_RESIDENCIAL" VARCHAR2 (30),
   "CEP_RESIDENCIAL" VARCHAR2 (10),
   "DDI_RESIDENCIAL" VARCHAR2 (4),
   "DDD_RESIDENCIAL" VARCHAR2 (4),
   "TEL_RESIDENCIAL" VARCHAR2 (40),
   "TEL_CELULAR_RESIDENCIAL" VARCHAR2 (40),
   "FAX_RESIDENCIAL" VARCHAR2 (40),
   "EMAIL_RESIDENCIAL" VARCHAR2 (200),
   "ENDEREÇO_COMERCIAL_1" VARCHAR2 (60),
   "NUMERO_COMERCIAL_1" VARCHAR2 (30),
   "COMPLEMENTO_COMERCIAL_1" VARCHAR2 (30),
   "BAIRRO_COMERCIAL_1" VARCHAR2 (50),
   "CIDADE_COMERCIAL_1" VARCHAR2 (50),
   "ESTADO_COMERCIAL_1_EX" VARCHAR2 (2),
   "ESTADO_COMERCIAL_1" VARCHAR2 (2),
   "PAÍS_COMERCIAL_1" VARCHAR2 (30),
   "CEP_COMERCIAL_1" VARCHAR2 (10),
   "DDI_COMERCIAL_1" VARCHAR2 (4),
   "TEL_COMERCIAL_1" VARCHAR2 (40),
   "FAX_COMERCIAL_1" VARCHAR2 (40),
   "DDD_COMERCIAL_1" VARCHAR2 (4),
   "PUBLICAR_COMERCIAL_1" NUMBER (1,0),
   "EMAIL_COMERCIAL_1" VARCHAR2 (200),
   "ENDEREÇO_COMERCIAL_2" VARCHAR2 (60),
   "NUMERO_COMERCIAL_2" VARCHAR2 (30),
   "COMPLEMENTO_COMERCIAL_2" VARCHAR2 (30),
   "BAIRRO_COMERCIAL_2" VARCHAR2 (50),
   "CIDADE_COMERCIAL_2" VARCHAR2 (50),
   "ESTADO_COMERCIAL_2" VARCHAR2 (2),
   "ESTADO_COMERCIAL_2_EX" VARCHAR2 (2),
   "PAÍS_COMERCIAL_2" VARCHAR2 (30),
   "CEP_COMERCIAL_2" VARCHAR2 (10),
   "DDI_COMERCIAL_2" VARCHAR2 (4),
   "DDD_COMERCIAL_2" VARCHAR2 (4),
   "TEL_COMERCIAL_2" VARCHAR2 (40),
   "FAX_COMERCIAL_2" VARCHAR2 (40),
   "EMAIL_COMERCIAL_2" VARCHAR2 (200),
   "PUBLICAR_COMERCIAL_2" NUMBER (1,0),
   "UNIVERSIDADE_DATA_FORMA" DATE,
   "UNIVERSIDADE_NOME" VARCHAR2 (50),
   "UNIVERSIDADE_LOCAL" VARCHAR2 (40),
   "RESIDÊNCIA_1_NOME" VARCHAR2 (100),
   "RESIDÊNCIA_1_LOCAL" VARCHAR2 (50),
   "RESIDÊNCIA_1_DATA_INI" DATE,
   "RESIDÊNCIA_1_DATA_FIM" DATE,
   "RESIDÊNCIA_2_NOME" VARCHAR2 (100),
   "RESIDÊNCIA_2_LOCAL" VARCHAR2 (50),
   "RESIDÊNCIA_2_DATA_INI" DATE,
   "RESIDÊNCIA_2_DATA_FIM" DATE,
   "RESIDÊNCIA_3_NOME" VARCHAR2 (100),
   "RESIDÊNCIA_3_LOCAL" VARCHAR2 (50),
   "RESIDÊNCIA_3_DATA_INI" DATE,
   "RESIDÊNCIA_3_DATA_FIM" DATE,
   "ESPECIALIDADE_NOME" VARCHAR2 (50),
   "ESPECIALIDADE_LOCAL" VARCHAR2 (50),
   "ESPECIALIDADE_DATA_INI" DATE,
   "ESPECIALIDADE_DATA_FIM" DATE,
   "PÓS_DOUTORADO_NOME" VARCHAR2 (50),
   "PÓS_DOUTORADO_INST" VARCHAR2 (50),
   "PÓS_DOUTORADO_LOCAL" VARCHAR2 (50),
   "PÓS_DOUTORADO_DATA" DATE,
   "LIVRE_DOCÊNCIA_NOME" VARCHAR2 (50),
   "LIVRE_DOCÊNCIA_INST" VARCHAR2 (50),
   "LIVRE_DOCÊNCIA_LOCAL" VARCHAR2 (50),
   "LIVRE_DOCÊNCIA_DATA" DATE,
   "DOUTORADO_NOME" VARCHAR2 (50),
   "DOUTORADO_INST" VARCHAR2 (50),
   "DOUTORADO_LOCAL" VARCHAR2 (50),
   "DOUTORADO_DATA" DATE,
   "MESTRADO_NOME" VARCHAR2 (50),
   "MESTRADO_INST" VARCHAR2 (50),
   "MESTRADO_LOCAL" VARCHAR2 (50),
   "MESTRADO_DATA" DATE,
   "PESQUISA_TEMA" VARCHAR2 (50),
   "CNRM" NUMBER (1,0),
   "TRABALHO1_NOME" VARCHAR2 (50),
   "TRABALHO1_CARGO" VARCHAR2 (100),
   "TRABALHO2_NOME" VARCHAR2 (50),
   "TRABALHO2_CARGO" VARCHAR2 (100),
   "TRABALHO3_NOME" VARCHAR2 (50),
   "TRABALHO3_CARGO" VARCHAR2 (100),
   "EXCLUÍDO" NUMBER (1,0),
   "DATA_EXCLUSÃO" DATE,
   "MOTIVO_EXCLUSÃO" VARCHAR2 (3000),
   "RESP_EXCLUSÃO" VARCHAR2 (50),
   "OBS" VARCHAR2 (3000),
   "FALECIDO" NUMBER (1,0),
   "ISENTO" NUMBER (5,0),
   "PENALIZADO" VARCHAR2 (1),
   "TITULAÇÃO" VARCHAR2 (50),
   "QUALIF_PROF" CLOB,
   "QUALIF_PROF_I" CLOB,
   "QUALIF_PROF_E" CLOB,
   "EMCD_IMP_ETIQ" NUMBER (5,0),
   "EMCD_DATA_IMP_ETIQ" DATE,
   "SENHA" VARCHAR2 (20),
   "OBRIG_STATUS_LOG" CLOB,
   "REG_LOG" VARCHAR2 (4000),
   "DATA_TRANSF_SOCIO" DATE
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."PROPOSTA" ADD CONSTRAINT "ID_PROPOSTA"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."PROPOSTA" IS 'SÓCIO | Cadastro das propostas de associados. | Prosposta Associado';

COMMENT ON COLUMN SBDB."PROPOSTA"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."PROPOSTA"."NOME" IS 'Nome. | Nome';
COMMENT ON COLUMN SBDB."PROPOSTA"."DATA_CADASTRO" IS 'Data de cadastro. | Data de Cadastro';
COMMENT ON COLUMN SBDB."PROPOSTA"."TRATAMENTO" IS 'Tratamento. | Tratamento';
COMMENT ON COLUMN SBDB."PROPOSTA"."NOME_PREFERENCIAL" IS 'Nome preferencial. | Nome Preferencial';
COMMENT ON COLUMN SBDB."PROPOSTA"."CRM_ESTADO" IS 'Estado do registro de CRM. | Estado do CRM';
COMMENT ON COLUMN SBDB."PROPOSTA"."CRM" IS 'CRM quando usuário for um médico registrado. | CRM';
COMMENT ON COLUMN SBDB."PROPOSTA"."CRM_DATA" IS 'Data de emissão do Registro de CRM. | Data de Emissão CRM';
COMMENT ON COLUMN SBDB."PROPOSTA"."MLN" IS 'Medical License Number. | Medical License Number';
COMMENT ON COLUMN SBDB."PROPOSTA"."SEXO" IS 'Gênero. | Sexo';
COMMENT ON COLUMN SBDB."PROPOSTA"."CPF" IS 'Seu CPF. | CPF';
COMMENT ON COLUMN SBDB."PROPOSTA"."ID_ORGAO" IS 'Órgão expedidor da identidade. | Órgão Expedidor RG';
COMMENT ON COLUMN SBDB."PROPOSTA"."IDENTIDADE" IS 'Identidade. | RG';
COMMENT ON COLUMN SBDB."PROPOSTA"."NATURALIDADE" IS 'Naturalidade. | Naturalidade';
COMMENT ON COLUMN SBDB."PROPOSTA"."NACIONALIDADE" IS 'Nacionalidade. | Nacionalidade';
COMMENT ON COLUMN SBDB."PROPOSTA"."DATA_NASCIMENTO" IS 'Data de nascimento. | Data de Nascimento';
COMMENT ON COLUMN SBDB."PROPOSTA"."FILIAÇÃO_PAI" IS 'Nome do pai. | Nome do Pai';
COMMENT ON COLUMN SBDB."PROPOSTA"."FILIAÇÃO_MÃE" IS 'Nome da mãe. | Nome da Mãe';
COMMENT ON COLUMN SBDB."PROPOSTA"."ESTADO_CIVIL" IS 'Estado civil. | Estado Civil';
COMMENT ON COLUMN SBDB."PROPOSTA"."REGIONAL_COD" IS 'Regional. | Regional';
COMMENT ON COLUMN SBDB."PROPOSTA"."CATEGORIA_COD" IS 'Categoria. | Categoria';
COMMENT ON COLUMN SBDB."PROPOSTA"."OBRIG_STATUS_COD" IS 'Situação administrativa. | Situação Administrativa';
COMMENT ON COLUMN SBDB."PROPOSTA"."OBRIG_STATUS_DATA" IS 'Data de registro da situação administrativa. | Data de Reg. Situação Administrativa';
COMMENT ON COLUMN SBDB."PROPOSTA"."TED" IS 'Status de aprovação do TED. | Status de Aprovação do TED';
COMMENT ON COLUMN SBDB."PROPOSTA"."TED_ANO_CONCURSO" IS 'Ano de realização da prova do TED. | Ano do Concurso';
COMMENT ON COLUMN SBDB."PROPOSTA"."TED_DATA_EXPEDIÇÃO" IS 'Data de expedição do TED. | Data de Expedição do TED';
COMMENT ON COLUMN SBDB."PROPOSTA"."TED_DATA_APROVAÇÃO" IS 'Data do Exame TED. | Data de Exame do TED';
COMMENT ON COLUMN SBDB."PROPOSTA"."TED_IMPRESSÃO" IS 'Confirmação de impressão do TED. | Confirmação  de Impressão do TED';
COMMENT ON COLUMN SBDB."PROPOSTA"."CFM_ADESAO" IS 'Data de adesão do CNA. | Data de Adesão do CNA';
COMMENT ON COLUMN SBDB."PROPOSTA"."CFM_OBS" IS 'Observação do CNA. | Observação do CNA';
COMMENT ON COLUMN SBDB."PROPOSTA"."DATA_INICIO_CONTAGEM" IS 'Data de Início da pontuação EMC-D. | Data de Início';
COMMENT ON COLUMN SBDB."PROPOSTA"."SOCIO_ELETRONICO" IS 'Associado eletrônico. | Associado Eletrônico';
COMMENT ON COLUMN SBDB."PROPOSTA"."SITE" IS 'Site. | Site';
COMMENT ON COLUMN SBDB."PROPOSTA"."FOTO" IS '{Imagem} Foto. | Foto';
COMMENT ON COLUMN SBDB."PROPOSTA"."MALA_DIRETA" IS 'Endereço de correspondência. | Endereço de Correspondência';
COMMENT ON COLUMN SBDB."PROPOSTA"."ENDEREÇO_RESIDENCIAL" IS 'Endereço residencial completo, tipo (rua, av.), logradouro e número. | Endereço Residencial';
COMMENT ON COLUMN SBDB."PROPOSTA"."NUMERO_RESIDENCIAL" IS 'Número residencial. | Número';
COMMENT ON COLUMN SBDB."PROPOSTA"."COMPLEMENTO_RESIDENCIAL" IS 'Complemento residencial. | Complemento';
COMMENT ON COLUMN SBDB."PROPOSTA"."BAIRRO_RESIDENCIAL" IS 'Bairro residencial. | Bairro';
COMMENT ON COLUMN SBDB."PROPOSTA"."CIDADE_RESIDENCIAL" IS 'Cidade residencial. | Cidade';
COMMENT ON COLUMN SBDB."PROPOSTA"."ESTADO_RESIDENCIAL" IS 'Estado residencial. | Estado';
COMMENT ON COLUMN SBDB."PROPOSTA"."ESTADO_RESIDENCIAL_EX" IS 'Estado residencial. | Estado';
COMMENT ON COLUMN SBDB."PROPOSTA"."PAÍS_RESIDENCIAL" IS 'País residencial. | País';
COMMENT ON COLUMN SBDB."PROPOSTA"."CEP_RESIDENCIAL" IS 'CEP residencial. | CEP';
COMMENT ON COLUMN SBDB."PROPOSTA"."DDI_RESIDENCIAL" IS 'DDI residencial. | DDI';
COMMENT ON COLUMN SBDB."PROPOSTA"."DDD_RESIDENCIAL" IS 'DDD Residencial. | DDD';
COMMENT ON COLUMN SBDB."PROPOSTA"."TEL_RESIDENCIAL" IS 'Telefone residencial. | Telefone';
COMMENT ON COLUMN SBDB."PROPOSTA"."TEL_CELULAR_RESIDENCIAL" IS 'Celular Residencial. | Celular';
COMMENT ON COLUMN SBDB."PROPOSTA"."FAX_RESIDENCIAL" IS 'Fax residencial. | Fax';
COMMENT ON COLUMN SBDB."PROPOSTA"."EMAIL_RESIDENCIAL" IS 'E-mail residencial. | E-mail';
COMMENT ON COLUMN SBDB."PROPOSTA"."ENDEREÇO_COMERCIAL_1" IS 'Endereço comercial 1 completo, tipo (rua, av.), logradouro e número. | Endereço';
COMMENT ON COLUMN SBDB."PROPOSTA"."NUMERO_COMERCIAL_1" IS 'Número comercial 1. | Número';
COMMENT ON COLUMN SBDB."PROPOSTA"."COMPLEMENTO_COMERCIAL_1" IS 'Complemento comercial 1. | Complemento';
COMMENT ON COLUMN SBDB."PROPOSTA"."BAIRRO_COMERCIAL_1" IS 'Bairro comercial 1. | Bairro';
COMMENT ON COLUMN SBDB."PROPOSTA"."CIDADE_COMERCIAL_1" IS 'Cidade comercial 1. | Cidade';
COMMENT ON COLUMN SBDB."PROPOSTA"."ESTADO_COMERCIAL_1_EX" IS 'Estado comercial 1. | Estado';
COMMENT ON COLUMN SBDB."PROPOSTA"."ESTADO_COMERCIAL_1" IS 'Estado comercial 1. | Estado';
COMMENT ON COLUMN SBDB."PROPOSTA"."PAÍS_COMERCIAL_1" IS 'País comercial 1. | País';
COMMENT ON COLUMN SBDB."PROPOSTA"."CEP_COMERCIAL_1" IS 'CEP comercial 1. | CEP';
COMMENT ON COLUMN SBDB."PROPOSTA"."DDI_COMERCIAL_1" IS 'DDI comercial 1. | DDI';
COMMENT ON COLUMN SBDB."PROPOSTA"."TEL_COMERCIAL_1" IS 'Telefone comercial 1. | Telefone';
COMMENT ON COLUMN SBDB."PROPOSTA"."FAX_COMERCIAL_1" IS 'Fax comercial 1. | Fax';
COMMENT ON COLUMN SBDB."PROPOSTA"."DDD_COMERCIAL_1" IS 'DDD comercial 1. | DDD';
COMMENT ON COLUMN SBDB."PROPOSTA"."PUBLICAR_COMERCIAL_1" IS 'Status de publicação do endereço comercial 1. | Publicar Endereço Comercial 1';
COMMENT ON COLUMN SBDB."PROPOSTA"."EMAIL_COMERCIAL_1" IS 'E-mail comercial 1. | E-mail';
COMMENT ON COLUMN SBDB."PROPOSTA"."ENDEREÇO_COMERCIAL_2" IS 'Endereço comercial 2 completo, tipo (rua, av.), logradouro e número. | Endereço';
COMMENT ON COLUMN SBDB."PROPOSTA"."NUMERO_COMERCIAL_2" IS 'Número comercial 2. | Número';
COMMENT ON COLUMN SBDB."PROPOSTA"."COMPLEMENTO_COMERCIAL_2" IS 'Complemento comercial 2. | Complemento';
COMMENT ON COLUMN SBDB."PROPOSTA"."BAIRRO_COMERCIAL_2" IS 'Bairro comercial 2. | Bairro';
COMMENT ON COLUMN SBDB."PROPOSTA"."CIDADE_COMERCIAL_2" IS 'Cidade comercial 2. | Cidade';
COMMENT ON COLUMN SBDB."PROPOSTA"."ESTADO_COMERCIAL_2" IS 'Estado comercial 2. | Estado';
COMMENT ON COLUMN SBDB."PROPOSTA"."ESTADO_COMERCIAL_2_EX" IS 'Estado comercial 2. | Estado';
COMMENT ON COLUMN SBDB."PROPOSTA"."PAÍS_COMERCIAL_2" IS 'País comercial 2. | País';
COMMENT ON COLUMN SBDB."PROPOSTA"."CEP_COMERCIAL_2" IS 'CEP comercial 2. | CEP';
COMMENT ON COLUMN SBDB."PROPOSTA"."DDI_COMERCIAL_2" IS 'DDI comercial 2. | DDI';
COMMENT ON COLUMN SBDB."PROPOSTA"."DDD_COMERCIAL_2" IS 'DDD comercial 2. | DDD';
COMMENT ON COLUMN SBDB."PROPOSTA"."TEL_COMERCIAL_2" IS 'Telefone comercial 2. | Telefone';
COMMENT ON COLUMN SBDB."PROPOSTA"."FAX_COMERCIAL_2" IS 'Fax comercial 2. | Fax';
COMMENT ON COLUMN SBDB."PROPOSTA"."EMAIL_COMERCIAL_2" IS 'E-mail comercial 2. | E-mail';
COMMENT ON COLUMN SBDB."PROPOSTA"."PUBLICAR_COMERCIAL_2" IS 'Status de publicação do endereço comercial 2. | Publicar Endereço Comercial 2';
COMMENT ON COLUMN SBDB."PROPOSTA"."UNIVERSIDADE_DATA_FORMA" IS 'Data de formatura. | Ano de Formatura';
COMMENT ON COLUMN SBDB."PROPOSTA"."UNIVERSIDADE_NOME" IS 'Nome da universidade de formatura. | Nome da Universidade de Formatura';
COMMENT ON COLUMN SBDB."PROPOSTA"."UNIVERSIDADE_LOCAL" IS 'Local de formatura. | Local de Formatura';
COMMENT ON COLUMN SBDB."PROPOSTA"."RESIDÊNCIA_1_NOME" IS 'Nome da especialidade da primeira residência. | Residência em';
COMMENT ON COLUMN SBDB."PROPOSTA"."RESIDÊNCIA_1_LOCAL" IS 'Local da primeira residência. | Local';
COMMENT ON COLUMN SBDB."PROPOSTA"."RESIDÊNCIA_1_DATA_INI" IS 'Data de início da primeira residência. | Data de Início';
COMMENT ON COLUMN SBDB."PROPOSTA"."RESIDÊNCIA_1_DATA_FIM" IS 'Data de término da primeira residência. | Data de Término';
COMMENT ON COLUMN SBDB."PROPOSTA"."RESIDÊNCIA_2_NOME" IS 'Nome da especialidade da segunda residência. | Residência em';
COMMENT ON COLUMN SBDB."PROPOSTA"."RESIDÊNCIA_2_LOCAL" IS 'Local da segunda residência. | Local';
COMMENT ON COLUMN SBDB."PROPOSTA"."RESIDÊNCIA_2_DATA_INI" IS 'Data de início da segunda residência. | Data de Início';
COMMENT ON COLUMN SBDB."PROPOSTA"."RESIDÊNCIA_2_DATA_FIM" IS 'Data de término da segunda residência. | Data de Término';
COMMENT ON COLUMN SBDB."PROPOSTA"."RESIDÊNCIA_3_NOME" IS 'Nome da especialidade da terceira residência. | Residência em';
COMMENT ON COLUMN SBDB."PROPOSTA"."RESIDÊNCIA_3_LOCAL" IS 'Local da terceira residência. | Local';
COMMENT ON COLUMN SBDB."PROPOSTA"."RESIDÊNCIA_3_DATA_INI" IS 'Data de término da terceira residência. | Data de Término';
COMMENT ON COLUMN SBDB."PROPOSTA"."RESIDÊNCIA_3_DATA_FIM" IS 'Data de início da terceira residência. | Data de Início';
COMMENT ON COLUMN SBDB."PROPOSTA"."ESPECIALIDADE_NOME" IS 'Nome da especialização. | Nome da Especialização';
COMMENT ON COLUMN SBDB."PROPOSTA"."ESPECIALIDADE_LOCAL" IS 'Local da especialização. | Local da Especialização';
COMMENT ON COLUMN SBDB."PROPOSTA"."ESPECIALIDADE_DATA_INI" IS 'Data de início da especialização. | Data de Início da Especialização';
COMMENT ON COLUMN SBDB."PROPOSTA"."ESPECIALIDADE_DATA_FIM" IS 'Data de término da especialização. | Data de Término da Especialização';
COMMENT ON COLUMN SBDB."PROPOSTA"."PÓS_DOUTORADO_NOME" IS 'Especialidade na pós-graduação. | Pós-Doutorado em';
COMMENT ON COLUMN SBDB."PROPOSTA"."PÓS_DOUTORADO_INST" IS 'Instituição onde realizou a pós-graduação. | Instituição';
COMMENT ON COLUMN SBDB."PROPOSTA"."PÓS_DOUTORADO_LOCAL" IS 'Local da pós-graduação. | Local';
COMMENT ON COLUMN SBDB."PROPOSTA"."PÓS_DOUTORADO_DATA" IS 'Data de formatura da pós-graduação. | Data de Formatura';
COMMENT ON COLUMN SBDB."PROPOSTA"."LIVRE_DOCÊNCIA_NOME" IS 'Especialidade na livre docência. | Livre Docência em';
COMMENT ON COLUMN SBDB."PROPOSTA"."LIVRE_DOCÊNCIA_INST" IS 'Instituição da livre docência. | Instituição';
COMMENT ON COLUMN SBDB."PROPOSTA"."LIVRE_DOCÊNCIA_LOCAL" IS 'Local da livre docência. | Local';
COMMENT ON COLUMN SBDB."PROPOSTA"."LIVRE_DOCÊNCIA_DATA" IS 'Data de formatura da livre docência. | Data de Formatura';
COMMENT ON COLUMN SBDB."PROPOSTA"."DOUTORADO_NOME" IS 'Especialidade no doutorado. | Doutorado em';
COMMENT ON COLUMN SBDB."PROPOSTA"."DOUTORADO_INST" IS 'Instituição onde realizou o doutorado. | Instituição';
COMMENT ON COLUMN SBDB."PROPOSTA"."DOUTORADO_LOCAL" IS 'Local do doutorado. | Local';
COMMENT ON COLUMN SBDB."PROPOSTA"."DOUTORADO_DATA" IS 'Data de formatura do doutorado. | Data de Formatura';
COMMENT ON COLUMN SBDB."PROPOSTA"."MESTRADO_NOME" IS 'Especialidade no mestrado. | Mestrado em';
COMMENT ON COLUMN SBDB."PROPOSTA"."MESTRADO_INST" IS 'Instituição onde realizou o mestrado. | Instituição';
COMMENT ON COLUMN SBDB."PROPOSTA"."MESTRADO_LOCAL" IS 'Local do mestrado. | Local';
COMMENT ON COLUMN SBDB."PROPOSTA"."MESTRADO_DATA" IS 'Data de formatura do mestrado. | Data de Formatura';
COMMENT ON COLUMN SBDB."PROPOSTA"."PESQUISA_TEMA" IS 'Linha de pesquisa. | Linha de Pesquisa';
COMMENT ON COLUMN SBDB."PROPOSTA"."CNRM" IS 'Certificado pelo conselho nacional de residência médica. | Certificado pelo CNRM';
COMMENT ON COLUMN SBDB."PROPOSTA"."TRABALHO1_NOME" IS 'Primeiro local onde trabalhou. | Local de Trabalho';
COMMENT ON COLUMN SBDB."PROPOSTA"."TRABALHO1_CARGO" IS 'Cargo ocupado no primeiro trabalho. | Cargo';
COMMENT ON COLUMN SBDB."PROPOSTA"."TRABALHO2_NOME" IS 'Segundo local onde trabalhou. | Local de Trabalho';
COMMENT ON COLUMN SBDB."PROPOSTA"."TRABALHO2_CARGO" IS 'Cargo ocupado no segundo trabalho. | Cargo';
COMMENT ON COLUMN SBDB."PROPOSTA"."TRABALHO3_NOME" IS 'Terceiro local onde Trabalhou. | Local de Trabalho';
COMMENT ON COLUMN SBDB."PROPOSTA"."TRABALHO3_CARGO" IS 'Cargo ocupado no terceiro trabalho. | Cargo';
COMMENT ON COLUMN SBDB."PROPOSTA"."EXCLUÍDO" IS 'Status exclusão do associado. | Excluído';
COMMENT ON COLUMN SBDB."PROPOSTA"."DATA_EXCLUSÃO" IS 'Data da exclusão. | Data da Exclusão';
COMMENT ON COLUMN SBDB."PROPOSTA"."MOTIVO_EXCLUSÃO" IS 'Motivo da exclusão. | Motivo da Exclusão';
COMMENT ON COLUMN SBDB."PROPOSTA"."RESP_EXCLUSÃO" IS 'Responsável pela exclusão. | Responsável pela Exclusão';
COMMENT ON COLUMN SBDB."PROPOSTA"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."PROPOSTA"."FALECIDO" IS 'Informa se o associado está Falecido. | Falecido';
COMMENT ON COLUMN SBDB."PROPOSTA"."ISENTO" IS 'Status de isenção. | Status de Isento';
COMMENT ON COLUMN SBDB."PROPOSTA"."PENALIZADO" IS 'Status de penalidade. | Status de Penalidade';
COMMENT ON COLUMN SBDB."PROPOSTA"."TITULAÇÃO" IS 'Titulação. | Titulação';
COMMENT ON COLUMN SBDB."PROPOSTA"."QUALIF_PROF" IS 'Qualificação profissional. | Qualificação Profissional';
COMMENT ON COLUMN SBDB."PROPOSTA"."QUALIF_PROF_I" IS 'Qualificação profissional em inglês. | Qualificação Profissional em Inglês';
COMMENT ON COLUMN SBDB."PROPOSTA"."QUALIF_PROF_E" IS 'Qualificação profissional em espanhol. | Qualificação Profissional em Espanhol';
COMMENT ON COLUMN SBDB."PROPOSTA"."EMCD_IMP_ETIQ" IS 'Sequencial de impressão de etiqueta para EMC-D. | Sequencial de Impressão de Etiqueta para EMC-D';
COMMENT ON COLUMN SBDB."PROPOSTA"."EMCD_DATA_IMP_ETIQ" IS 'Data de Impressão da Etiqueta para EMC-D. | Data de Impressão da Etiqueta para EMC-D';
COMMENT ON COLUMN SBDB."PROPOSTA"."SENHA" IS 'Senha de acesso ao site. | Senha de Acesso ao Site';
COMMENT ON COLUMN SBDB."PROPOSTA"."OBRIG_STATUS_LOG" IS 'Registro de baixas de pagamentos. | Registro de Baixas de Pagamentos';
COMMENT ON COLUMN SBDB."PROPOSTA"."REG_LOG" IS 'Registra informações sobre o cadastro. | Registra Informações Sobre o Cadastro';
COMMENT ON COLUMN SBDB."PROPOSTA"."DATA_TRANSF_SOCIO" IS 'Data de transferência do cadastro de proposta para o cadastro de sócio. | Data Transferência';
COMMENT ON COLUMN SBDB."PROPOSTA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."PROPOSTA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."PROPOSTA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."PROPOSTA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."PROPOSTA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."PROPOSTA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."PROPOSTA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA REGIÃO
CREATE TABLE SBDB."REGIÃO" (
   "NOME" VARCHAR2 (30)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."REGIÃO" ADD CONSTRAINT "ID_REGIÃO"
PRIMARY KEY("NOME");

COMMENT ON TABLE SBDB."REGIÃO" IS 'CADASTRO | Cadastro das regiões geográficas. | Região';

COMMENT ON COLUMN SBDB."REGIÃO"."NOME" IS 'Nome da região. | Nome';
COMMENT ON COLUMN SBDB."REGIÃO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."REGIÃO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."REGIÃO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."REGIÃO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."REGIÃO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."REGIÃO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."REGIÃO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA REGIONAL
CREATE TABLE SBDB."REGIONAL" (
   "COD" VARCHAR2 (2),
   "NOME" VARCHAR2 (50),
   "ENDEREÇO" VARCHAR2 (60),
   "BAIRRO" VARCHAR2 (50),
   "CIDADE" VARCHAR2 (30),
   "ESTADO" VARCHAR2 (2),
   "CEP" VARCHAR2 (10),
   "TEL" VARCHAR2 (40),
   "FAX" VARCHAR2 (40),
   "E_MAIL" VARCHAR2 (200),
   "CONTATO" VARCHAR2 (50),
   "DDD" VARCHAR2 (4),
   "REPASSE_PERCENT" FLOAT,
   "BANCO" VARCHAR2 (30),
   "AGÊNCIA" VARCHAR2 (10),
   "CONTA" VARCHAR2 (20),
   "OBS" VARCHAR2 (3000),
   "SITE" VARCHAR2 (200),
   "CNPJ" VARCHAR2 (15),
   "APRES_REGIONAL" NUMBER (1,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."REGIONAL" ADD CONSTRAINT "ID_REGIONAL"
PRIMARY KEY("COD");

COMMENT ON TABLE SBDB."REGIONAL" IS 'REGIONAL | Cadastro das regionais da sociedade. | Regional';

COMMENT ON COLUMN SBDB."REGIONAL"."COD" IS 'Sigla da regional. | Sigla';
COMMENT ON COLUMN SBDB."REGIONAL"."NOME" IS 'Nome da regional. | Regional';
COMMENT ON COLUMN SBDB."REGIONAL"."ENDEREÇO" IS 'Endereço completo, tipo (rua, av.), logradouro e número. | Endereço Completo';
COMMENT ON COLUMN SBDB."REGIONAL"."BAIRRO" IS 'Bairro. | Bairro';
COMMENT ON COLUMN SBDB."REGIONAL"."CIDADE" IS 'Cidade da regional. | Cidade';
COMMENT ON COLUMN SBDB."REGIONAL"."ESTADO" IS 'Estado da regional. | Estado';
COMMENT ON COLUMN SBDB."REGIONAL"."CEP" IS 'CEP designado para o logradouro. | CEP';
COMMENT ON COLUMN SBDB."REGIONAL"."TEL" IS 'Telefone da regional. | Telefone';
COMMENT ON COLUMN SBDB."REGIONAL"."FAX" IS 'Fax da regional. | Fax';
COMMENT ON COLUMN SBDB."REGIONAL"."E_MAIL" IS 'E-mail da regional. | E-mail';
COMMENT ON COLUMN SBDB."REGIONAL"."CONTATO" IS 'Contato da regional. | Contato';
COMMENT ON COLUMN SBDB."REGIONAL"."DDD" IS 'DDD da regional. | DDD';
COMMENT ON COLUMN SBDB."REGIONAL"."REPASSE_PERCENT" IS 'Percentual de repasse à regional. | Percentual';
COMMENT ON COLUMN SBDB."REGIONAL"."BANCO" IS 'Banco. | Banco';
COMMENT ON COLUMN SBDB."REGIONAL"."AGÊNCIA" IS 'Agência do banco. | Agência';
COMMENT ON COLUMN SBDB."REGIONAL"."CONTA" IS 'Conta corrente. | Conta Corrente';
COMMENT ON COLUMN SBDB."REGIONAL"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."REGIONAL"."SITE" IS 'Site. | Site';
COMMENT ON COLUMN SBDB."REGIONAL"."CNPJ" IS 'CNPJ. | CNPJ';
COMMENT ON COLUMN SBDB."REGIONAL"."APRES_REGIONAL" IS 'Exibição da Regional no Site. | Exibir Regional';
COMMENT ON COLUMN SBDB."REGIONAL".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."REGIONAL".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."REGIONAL".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."REGIONAL".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."REGIONAL".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."REGIONAL".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."REGIONAL".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA REUNIAO
CREATE TABLE SBDB."REUNIAO" (
   "SEQ" NUMBER (6,0),
   "NOME" VARCHAR2 (200),
   "LOCAL" VARCHAR2 (200),
   "REUNIAO_DATA" DATE,
   "OBSERVACAO" VARCHAR2 (4000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."REUNIAO" ADD CONSTRAINT "ID_REUNIAO"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."REUNIAO" IS 'CADASTRO | Cadastro das reuniões a principio relacionadas aos congressos. | Reunião';

COMMENT ON COLUMN SBDB."REUNIAO"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."REUNIAO"."NOME" IS 'Nome. | Nome';
COMMENT ON COLUMN SBDB."REUNIAO"."LOCAL" IS 'Local. | Local';
COMMENT ON COLUMN SBDB."REUNIAO"."REUNIAO_DATA" IS 'Data da reunião. | Data da Reunião';
COMMENT ON COLUMN SBDB."REUNIAO"."OBSERVACAO" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."REUNIAO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."REUNIAO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."REUNIAO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."REUNIAO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."REUNIAO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."REUNIAO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."REUNIAO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA REUNIAO_SOCIO
CREATE TABLE SBDB."REUNIAO_SOCIO" (
   "REUNIAO_SEQ" NUMBER (6,0),
   "SEQ" NUMBER (6,0),
   "SOCIO_MAT" NUMBER (5,0),
   "SOCIO_CATEGORIA" VARCHAR2 (20),
   "REGIONAL_COD" VARCHAR2 (2),
   "MOMENTO_ENTRADA" DATE,
   "OBSERVACAO" VARCHAR2 (4000),
   "FLAG" VARCHAR2 (1)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."REUNIAO_SOCIO" ADD CONSTRAINT "ID_REUNIAO_SOCIO"
PRIMARY KEY("REUNIAO_SEQ", "SEQ");

COMMENT ON TABLE SBDB."REUNIAO_SOCIO" IS 'CADASTRO | Cadastro dos sequenciais dos associados nas reuniões a principio relacionadas aos congressos. | Sócio por Reunião';

COMMENT ON COLUMN SBDB."REUNIAO_SOCIO"."REUNIAO_SEQ" IS 'Sequencial da reunião. | Sequencial da Reunião';
COMMENT ON COLUMN SBDB."REUNIAO_SOCIO"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."REUNIAO_SOCIO"."SOCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."REUNIAO_SOCIO"."SOCIO_CATEGORIA" IS 'Categoria do associado. | Categoria do Associado';
COMMENT ON COLUMN SBDB."REUNIAO_SOCIO"."REGIONAL_COD" IS 'Regional. | Regional';
COMMENT ON COLUMN SBDB."REUNIAO_SOCIO"."MOMENTO_ENTRADA" IS 'Data de cadastro. | Data de Cadastro';
COMMENT ON COLUMN SBDB."REUNIAO_SOCIO"."OBSERVACAO" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."REUNIAO_SOCIO"."FLAG" IS 'Permite inclusão de associado bloqueado (S=Sim, N=Não). | Flag';
COMMENT ON COLUMN SBDB."REUNIAO_SOCIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."REUNIAO_SOCIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."REUNIAO_SOCIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."REUNIAO_SOCIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."REUNIAO_SOCIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."REUNIAO_SOCIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."REUNIAO_SOCIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SERV_CRED_CORPO_ADJ
CREATE TABLE SBDB."SERV_CRED_CORPO_ADJ" (
   "SERV_CRED_COD" NUMBER (5,0),
   "SEQ" NUMBER (6,0),
   "NOME" VARCHAR2 (50),
   "TITULACAO" VARCHAR2 (200),
   "VINCULO" VARCHAR2 (10),
   "AREA_INTERESSE" VARCHAR2 (300),
   "CURRICULO_LATTES" VARCHAR2 (300),
   "FOTO" VARCHAR2 (100),
   "ANO_FORMATURA" VARCHAR2 (4),
   "LOCAL_FORMATURA" VARCHAR2 (200)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SERV_CRED_CORPO_ADJ" ADD CONSTRAINT "ID_SERV_CRED_CORPO_ADJ"
PRIMARY KEY("SERV_CRED_COD", "SEQ");

COMMENT ON TABLE SBDB."SERV_CRED_CORPO_ADJ" IS 'SERVIÇO CRED | Cadastro com professores e colaboradores para este serviço credenciado. | Corpo Adjunto do Serviço Credenciado';

COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ"."SERV_CRED_COD" IS 'Código do serviço credenciado. | Código do Serviço';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ"."NOME" IS 'Nome. | Nome';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ"."TITULACAO" IS 'Titulação. | Titulação';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ"."VINCULO" IS 'Tipo de vínculo deste adjunto ao serviço credenciado. | Tipo de Vínculo';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ"."AREA_INTERESSE" IS 'Área de interesse do chefe do corpo clínico. | Área de Interesse';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ"."CURRICULO_LATTES" IS 'Currículo Lattes. | Currículo Lattes';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ"."FOTO" IS '{Imagem} Foto. | Foto';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ"."ANO_FORMATURA" IS 'Ano de formatura. | Ano de Formatura';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ"."LOCAL_FORMATURA" IS 'Local de formatura. | Local de Formatura';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_ADJ".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SERV_CRED_CORPO_CLINICO
CREATE TABLE SBDB."SERV_CRED_CORPO_CLINICO" (
   "SERV_CRED_COD" NUMBER (5,0),
   "SEQ" NUMBER (6,0),
   "NOME" VARCHAR2 (50),
   "TITULACAO" VARCHAR2 (200),
   "AREA_INTERESSE" VARCHAR2 (300),
   "CURRICULO_LATTES" VARCHAR2 (300),
   "FOTO" VARCHAR2 (100),
   "ANO_FORMATURA" VARCHAR2 (4),
   "LOCAL_FORMATURA" VARCHAR2 (200)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SERV_CRED_CORPO_CLINICO" ADD CONSTRAINT "ID_SERV_CRED_CORPO_CLINICO"
PRIMARY KEY("SERV_CRED_COD", "SEQ");

COMMENT ON TABLE SBDB."SERV_CRED_CORPO_CLINICO" IS 'SERVIÇO CRED | Cadastro do corpo clínico do serviço credenciado. | Corpo Clínico do Serviço Credenciado';

COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO"."SERV_CRED_COD" IS 'Código do serviço credenciado. | Código do Serviço';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO"."NOME" IS 'Nome. | Nome';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO"."TITULACAO" IS 'Titulação. | Titulação';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO"."AREA_INTERESSE" IS 'Área de interesse do chefe do corpo clínico. | Área de Interesse';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO"."CURRICULO_LATTES" IS 'Currículo Lattes. | Currículo Lattes';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO"."FOTO" IS '{Imagem} Foto. | Foto';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO"."ANO_FORMATURA" IS 'Ano de formatura do chefe do corpo clínico. | Ano';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO"."LOCAL_FORMATURA" IS 'Local de formatura. | Local de Formatura';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SERV_CRED_CORPO_CLINICO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SERV_CRED_FOTO
CREATE TABLE SBDB."SERV_CRED_FOTO" (
   "SERV_CRED_COD" NUMBER (5,0),
   "SEQ" NUMBER (10,0),
   "ARQUIVO" VARCHAR2 (100),
   "LEGENDA" VARCHAR2 (300)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SERV_CRED_FOTO" ADD CONSTRAINT "ID_SERV_CRED_FOTO"
PRIMARY KEY("SERV_CRED_COD", "SEQ");

COMMENT ON TABLE SBDB."SERV_CRED_FOTO" IS 'SERVIÇO CRED | Cadastro das fotos do serviço credenciado. | Foto do Serviço Credenciado';

COMMENT ON COLUMN SBDB."SERV_CRED_FOTO"."SERV_CRED_COD" IS 'Código do serviço credenciado. | Código do Serviço';
COMMENT ON COLUMN SBDB."SERV_CRED_FOTO"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."SERV_CRED_FOTO"."ARQUIVO" IS '{Imagem} Nome do arquivo. | Nome do Arquivo';
COMMENT ON COLUMN SBDB."SERV_CRED_FOTO"."LEGENDA" IS 'Legenda do foto. | Legenda da Foto';
COMMENT ON COLUMN SBDB."SERV_CRED_FOTO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SERV_CRED_FOTO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SERV_CRED_FOTO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SERV_CRED_FOTO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SERV_CRED_FOTO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SERV_CRED_FOTO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SERV_CRED_FOTO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SERV_CRED_RENOVAÇÃO
CREATE TABLE SBDB."SERV_CRED_RENOVAÇÃO" (
   "SERV_CRED_COD" NUMBER (5,0),
   "SEQ" NUMBER (5,0),
   "DATA_RENOVAÇÃO" DATE,
   "DATA_INI" DATE,
   "DATA_FIM" DATE,
   "OBS" VARCHAR2 (3000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SERV_CRED_RENOVAÇÃO" ADD CONSTRAINT "ID_SERV_CRED_RENOVAÇÃO"
PRIMARY KEY("SERV_CRED_COD", "SEQ");

COMMENT ON TABLE SBDB."SERV_CRED_RENOVAÇÃO" IS 'SERVIÇO CRED | Cadastro das renovações do serviço credenciado. | Renovação do Serviço Credenciado';

COMMENT ON COLUMN SBDB."SERV_CRED_RENOVAÇÃO"."SERV_CRED_COD" IS 'Código do serviço credenciado. | Código do Serviço';
COMMENT ON COLUMN SBDB."SERV_CRED_RENOVAÇÃO"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."SERV_CRED_RENOVAÇÃO"."DATA_RENOVAÇÃO" IS 'Data de renovação. | Data Renovação';
COMMENT ON COLUMN SBDB."SERV_CRED_RENOVAÇÃO"."DATA_INI" IS 'Data inicial do credenciamento anterior. | Data de Início';
COMMENT ON COLUMN SBDB."SERV_CRED_RENOVAÇÃO"."DATA_FIM" IS 'Data final do credenciamento anterior. | Data de Término';
COMMENT ON COLUMN SBDB."SERV_CRED_RENOVAÇÃO"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."SERV_CRED_RENOVAÇÃO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SERV_CRED_RENOVAÇÃO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SERV_CRED_RENOVAÇÃO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SERV_CRED_RENOVAÇÃO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SERV_CRED_RENOVAÇÃO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SERV_CRED_RENOVAÇÃO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SERV_CRED_RENOVAÇÃO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SERV_CRED_RESIDENTE
CREATE TABLE SBDB."SERV_CRED_RESIDENTE" (
   "SEQ" NUMBER (3,0),
   "SERV_CRED_COD" NUMBER (5,0),
   "MATRICULA" VARCHAR2 (5),
   "NOME" VARCHAR2 (50),
   "ANO" NUMBER (2,0),
   "DATA_INICIO" DATE,
   "DATA_FINAL" DATE,
   "CURSO" VARCHAR2 (50),
   "CPF" VARCHAR2 (12)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SERV_CRED_RESIDENTE" ADD CONSTRAINT "ID_SERV_CRED_RESIDENTE"
PRIMARY KEY("SERV_CRED_COD", "SEQ");

COMMENT ON TABLE SBDB."SERV_CRED_RESIDENTE" IS 'SERVIÇO CRED | Cadastro dos residentes do serviço credenciado. | Residente do Serviço Credenciado';

COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE"."SERV_CRED_COD" IS 'Código do serviço credenciado. | Código do Serviço';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE"."MATRICULA" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE"."NOME" IS 'Nome. | Nome';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE"."ANO" IS 'Ano da residência. | Ano';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE"."DATA_INICIO" IS 'Data de início. | Data de Início';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE"."DATA_FINAL" IS 'Data de término. | Data de Término';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE"."CURSO" IS 'Curso de Residência\Curso equivalente residência. | Cursando';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE"."CPF" IS 'CPF. | CPF';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SERV_CRED_RESIDENTE".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SERV_CRED_USUARIO
CREATE TABLE SBDB."SERV_CRED_USUARIO" (
   "SERV_CRED_COD" NUMBER (5,0),
   "USUARIO" VARCHAR2 (20),
   "SENHA" VARCHAR2 (10)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SERV_CRED_USUARIO" ADD CONSTRAINT "ID_SERV_CRED_USUARIO"
PRIMARY KEY("SERV_CRED_COD", "USUARIO");

COMMENT ON TABLE SBDB."SERV_CRED_USUARIO" IS 'SERVIÇO CRED | Cadastro dos Usuários do serviço credenciado no site. | Usuário do Serviço Credenciado';

COMMENT ON COLUMN SBDB."SERV_CRED_USUARIO"."SERV_CRED_COD" IS 'Código do serviço credenciado. | Código do Serviço';
COMMENT ON COLUMN SBDB."SERV_CRED_USUARIO"."USUARIO" IS 'Nome do usuário. | Usuário';
COMMENT ON COLUMN SBDB."SERV_CRED_USUARIO"."SENHA" IS 'Senha. | Senha';
COMMENT ON COLUMN SBDB."SERV_CRED_USUARIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SERV_CRED_USUARIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SERV_CRED_USUARIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SERV_CRED_USUARIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SERV_CRED_USUARIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SERV_CRED_USUARIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SERV_CRED_USUARIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SERVIÇO_CREDENCIADO
CREATE TABLE SBDB."SERVIÇO_CREDENCIADO" (
   "COD" NUMBER (5,0),
   "INSTITUIÇÃO" VARCHAR2 (50),
   "SERVIÇO_NOME" VARCHAR2 (50),
   "DEPTO" VARCHAR2 (50),
   "SÓCIO_MAT" NUMBER (5,0),
   "ENDEREÇO" VARCHAR2 (60),
   "BAIRRO" VARCHAR2 (50),
   "CIDADE" VARCHAR2 (50),
   "ESTADO" VARCHAR2 (2),
   "CEP" VARCHAR2 (10),
   "PAÍS" VARCHAR2 (30),
   "DDI" VARCHAR2 (4),
   "DDD" VARCHAR2 (4),
   "TEL" VARCHAR2 (40),
   "FAX" VARCHAR2 (40),
   "QTD_VAGAS" NUMBER (5,0),
   "OBS" VARCHAR2 (500),
   "CONTATO" VARCHAR2 (50),
   "EMAIL" VARCHAR2 (200),
   "CREDENCIADO" VARCHAR2 (1),
   "SOCIO_FOTO" VARCHAR2 (100),
   "SITE" VARCHAR2 (200),
   "LAYOUT" VARCHAR2 (27),
   "LOGO" VARCHAR2 (100),
   "SERV_HISTORICO" VARCHAR2 (4000),
   "SERV_CURSO" VARCHAR2 (4000),
   "PESQUISA_ANDAMENTO" CLOB,
   "RAMAL" VARCHAR2 (5),
   "CURRICULO_LATTES" VARCHAR2 (300),
   "TITULACAO" VARCHAR2 (200),
   "ANO_FORMATURA" VARCHAR2 (4),
   "LOCAL_FORMATURA" VARCHAR2 (200),
   "AREA_INTERESSE" VARCHAR2 (300),
   "CNRM" NUMBER (1,0),
   "DATA_VISITA" DATE
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SERVIÇO_CREDENCIADO" ADD CONSTRAINT "ID_SERVIÇO_CREDENCIADO"
PRIMARY KEY("COD");

COMMENT ON TABLE SBDB."SERVIÇO_CREDENCIADO" IS 'SERVIÇO CRED | Cadastro do serviço credenciado. | Serviço Credenciado';

COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."COD" IS 'Código do serviço credenciado. | Código do Serviço (SEQ.)';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."INSTITUIÇÃO" IS 'Nome da instituição. | Instituição';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."SERVIÇO_NOME" IS 'Nome do serviço credenciado. | Nome do Serviço';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."DEPTO" IS 'Departamento da instituição. | Departamento';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."SÓCIO_MAT" IS 'Matrícula do chefe do serviço credenciado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."ENDEREÇO" IS 'Endereço completo, tipo (rua, av.), logradouro e número. | Endereço Completo';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."BAIRRO" IS 'Bairro. | Bairro';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."CIDADE" IS 'Cidade do serviço credenciado. | Cidade';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."ESTADO" IS 'Estado do serviço. | Estado';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."CEP" IS 'CEP designado para o logradouro. | CEP';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."PAÍS" IS 'País do serviço. | País';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."DDI" IS 'DDI do serviço. | DDI';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."DDD" IS 'DDD do serviço. | DDD';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."TEL" IS 'Telefone do serviço. | Telefone';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."FAX" IS 'Fax do serviço. | Fax';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."QTD_VAGAS" IS 'Quantidades de vagas para estágios. | Vagas';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."CONTATO" IS 'Contato do serviço credenciado. | Contato';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."EMAIL" IS 'E-mail. | E-mail';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."CREDENCIADO" IS 'Credenciado S=Sim, N=Não. | Credenciado';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."SOCIO_FOTO" IS '{Imagem} Foto do associado. | Foto do Associado';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."SITE" IS 'Site. | Site';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."LAYOUT" IS 'Layout. | Layout';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."LOGO" IS '{Imagem} Logo do serviço credenciado. | Logo';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."SERV_HISTORICO" IS 'Histórico do serviço credenciado. | Histórico do Serviço Credenciado';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."SERV_CURSO" IS 'Curso ministrado pelo serviço credenciado. | Curso do Serviço Credenciado';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."PESQUISA_ANDAMENTO" IS 'Pesquisa em andamento. | Pesquisa em Andamento';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."RAMAL" IS 'Ramal. | Ramal';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."CURRICULO_LATTES" IS 'Currículo Lattes do chefe do serviço credenciado. | Currículo Lattes';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."TITULACAO" IS 'Titulação do chefe do serviço credenciado. | Titulação';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."ANO_FORMATURA" IS 'Ano de formatura do chefe do serviço credenciado. | Ano';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."LOCAL_FORMATURA" IS 'Local de formatura do chefe do serviço credenciado. | Local de Formatura';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."AREA_INTERESSE" IS 'Área de interesse do chefe do serviço credenciado. | Área de Interesse';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."CNRM" IS 'Registrado no Conselho Nacional de Residência Médica? | CNRM';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO"."DATA_VISITA" IS 'Data da visita do conselho ao serviço credenciado. | Data de Visita';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SERVIÇO_CREDENCIADO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_BANNER
CREATE TABLE SBDB."SITE_BANNER" (
   "SEQ" NUMBER (5,0),
   "IMAGEM" VARCHAR2 (200),
   "DESCRICAO" VARCHAR2 (200),
   "LINK" VARCHAR2 (200),
   "AREA" VARCHAR2 (100),
   "ORDEM_NA_AREA" NUMBER (5,0),
   "DATA_INI" DATE,
   "DATA_FIM" DATE,
   "ATIVO" NUMBER (1,0),
   "ABRIR_LINK" VARCHAR2 (20)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_BANNER" ADD CONSTRAINT "ID_SITE_BANNER"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."SITE_BANNER" IS 'SITE | Armazena dado referente aos banners publicados. | Banners no Site';

COMMENT ON COLUMN SBDB."SITE_BANNER"."SEQ" IS 'Sequencial de banners cadastrados. | Seq';
COMMENT ON COLUMN SBDB."SITE_BANNER"."IMAGEM" IS 'Arquivo de imagem do banner. | Arquivo de Imagem';
COMMENT ON COLUMN SBDB."SITE_BANNER"."DESCRICAO" IS 'Descrição que aparece no tooltip. | Descrição';
COMMENT ON COLUMN SBDB."SITE_BANNER"."LINK" IS 'Link podendo ser relativo ~/ ou absoluto http://... | Link';
COMMENT ON COLUMN SBDB."SITE_BANNER"."AREA" IS 'Área onde será apresentado este banner. | Área';
COMMENT ON COLUMN SBDB."SITE_BANNER"."ORDEM_NA_AREA" IS 'Posição caso não deseje a orientação por data decrescente. | Posição na Área';
COMMENT ON COLUMN SBDB."SITE_BANNER"."DATA_INI" IS 'Data inicial caso banner para apresentar em determinada data. | Início de Apresentação';
COMMENT ON COLUMN SBDB."SITE_BANNER"."DATA_FIM" IS 'Data final caso seja necessário apresentar banner até determinada data. | Término de Apresentação';
COMMENT ON COLUMN SBDB."SITE_BANNER"."ATIVO" IS 'Status se habilitado ou desabilitado. | Ativo?';
COMMENT ON COLUMN SBDB."SITE_BANNER"."ABRIR_LINK" IS 'Target padrão a ser utilizado para abertura do link. | Abrir Link em';
COMMENT ON COLUMN SBDB."SITE_BANNER".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_BANNER".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_BANNER".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_BANNER".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_BANNER".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_BANNER".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_BANNER".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_CALENDARIO_DATA
CREATE TABLE SBDB."SITE_CALENDARIO_DATA" (
   "SEQ" NUMBER (4,0),
   "TIPO" NUMBER (4,0),
   "IDENTIF" VARCHAR2 (300),
   "DATA_INICIO" DATE,
   "DATA_FIM" DATE,
   "ORGANIZACAO" VARCHAR2 (100),
   "CIDADE" VARCHAR2 (50),
   "ESTADO_PAIS" VARCHAR2 (100),
   "LINK" VARCHAR2 (255)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_CALENDARIO_DATA" ADD CONSTRAINT "ID_SITE_CALENDARIO_DATA"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."SITE_CALENDARIO_DATA" IS 'SBDB | Armazena as datas do calendário. | Datas do Calendário';

COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA"."TIPO" IS 'Tipo. | Tipo';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA"."IDENTIF" IS 'Identidade. | Identidade';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA"."DATA_INICIO" IS 'Data de início. | Data de Início';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA"."DATA_FIM" IS 'Data de término. | Data de Término';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA"."ORGANIZACAO" IS 'Organização. | Organização';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA"."CIDADE" IS 'Cidade. | Cidade';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA"."ESTADO_PAIS" IS 'Descrição do estado e país. | Estado - País';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA"."LINK" IS 'Link. | Link';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_DATA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_CALENDARIO_TIPO
CREATE TABLE SBDB."SITE_CALENDARIO_TIPO" (
   "SEQ" NUMBER (4,0),
   "TIPO" VARCHAR2 (100)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_CALENDARIO_TIPO" ADD CONSTRAINT "ID_SITE_CALENDARIO_TIPO"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."SITE_CALENDARIO_TIPO" IS 'SBDB | Armazena o tipo de calendário. | Tipo no Calendário';

COMMENT ON COLUMN SBDB."SITE_CALENDARIO_TIPO"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_TIPO"."TIPO" IS 'Tipo. | Tipo';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_TIPO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_TIPO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_TIPO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_TIPO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_TIPO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_TIPO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_CALENDARIO_TIPO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_EMAIL_LISTA
CREATE TABLE SBDB."SITE_EMAIL_LISTA" (
   "COD_EMAIL" VARCHAR2 (100),
   "NOME_EMAIL" VARCHAR2 (100),
   "IP_EMAIL" VARCHAR2 (15),
   "HORARIO_EMAIL" DATE,
   "SIT" CHAR
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_EMAIL_LISTA" ADD CONSTRAINT "ID_SITE_EMAIL_LISTA"
PRIMARY KEY("COD_EMAIL");

COMMENT ON TABLE SBDB."SITE_EMAIL_LISTA" IS 'SITE | Cadastro de e-mails para envio de comunicado e clipping. | Lista de E-mail';

COMMENT ON COLUMN SBDB."SITE_EMAIL_LISTA"."COD_EMAIL" IS 'Sequencial do e-mail. | Sequencial de E-mail';
COMMENT ON COLUMN SBDB."SITE_EMAIL_LISTA"."NOME_EMAIL" IS 'Nome do e-mail. | E-mail';
COMMENT ON COLUMN SBDB."SITE_EMAIL_LISTA"."IP_EMAIL" IS 'IP do servido de  e-mail de origem. | IP';
COMMENT ON COLUMN SBDB."SITE_EMAIL_LISTA"."HORARIO_EMAIL" IS 'Horário do envio de e-mail. | Horário';
COMMENT ON COLUMN SBDB."SITE_EMAIL_LISTA"."SIT" IS 'Situação. | Situação';
COMMENT ON COLUMN SBDB."SITE_EMAIL_LISTA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_EMAIL_LISTA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_EMAIL_LISTA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_EMAIL_LISTA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_EMAIL_LISTA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_EMAIL_LISTA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_EMAIL_LISTA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_EVENTO
CREATE TABLE SBDB."SITE_EVENTO" (
   "ID_EVENTO" NUMBER (5,0),
   "NOME" VARCHAR2 (200),
   "DATA_APRESENTA" DATE,
   "DATA_APRES_ATE" DATE,
   "ESTABELECIMENTO" VARCHAR2 (150),
   "CIDADE" VARCHAR2 (50),
   "ESTADO" VARCHAR2 (2),
   "VAGAS" VARCHAR2 (1),
   "DATA" DATE,
   "CORPO_HOME" CLOB,
   "LINK_ENCAMINHA" VARCHAR2 (200),
   "CORPO_INSCRICAO" CLOB,
   "INSCRICAO_SBD" VARCHAR2 (1),
   "LINK_HOSPEDAGEM" VARCHAR2 (200),
   "CORPO_HOSPEDAGEM" CLOB,
   "CORPO_PATROCINADOR" CLOB,
   "CORPO_PROGRAMA" CLOB
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_EVENTO" ADD CONSTRAINT "ID_SITE_EVENTO"
PRIMARY KEY("ID_EVENTO");

COMMENT ON TABLE SBDB."SITE_EVENTO" IS 'SBDB | Armazena informações sobre os eventos. | Evento no Site';

COMMENT ON COLUMN SBDB."SITE_EVENTO"."ID_EVENTO" IS 'Sequencial do evento. | Sequencial';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."NOME" IS 'Título que aparece sobre o evento no site. | Nome';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."DATA_APRESENTA" IS 'Data em que o evento será apresentado no site. | Data de Inicio de Apresentação';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."DATA_APRES_ATE" IS 'Ultima data de apresentação do evento no site. | Data de Final de Apresentação';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."ESTABELECIMENTO" IS 'Estabelecimento onde ocorrerá o evento. | Estabelecimento';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."CIDADE" IS 'Cidade onde ocorrerá o evento. | Cidade';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."ESTADO" IS 'Estado onde ocorrerá o evento. | Estado';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."VAGAS" IS 'Se ainda existem vagas para o evento  (S=SIM; N=NÃO). | Existem Vagas';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."DATA" IS 'Data de ocorrência do evento. | Data do Evento';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."CORPO_HOME" IS 'Conteúdo que será apresentado na página Home. | Conteúdo da Home';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."LINK_ENCAMINHA" IS 'Link de encaminhamento para inscrição. Este campo vazio corresponde ao encaminhamento padrão para incrição no próprio site da SBD.[Máximo de 200 caracteres] | Link de Inscrição<br />(Terceiros)';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."CORPO_INSCRICAO" IS 'Conteúdo que será apresentado na página Inscrição - Só será valido se Link Inscrição estiver vazio. | Conteúdo Inscrição<br />Só se NÃO existir link.';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."INSCRICAO_SBD" IS 'Informa se a inscrição será realizada pela site da SBD (S=Sim; N=Não). | Inscrição é pela SBD';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."LINK_HOSPEDAGEM" IS 'Link de encaminhamento para hospedagem. Este campo vazio corresponde ao encaminhamento padrão para página hospedagem no próprio site da SBD. [Máximo de 200 caracteres] | Link para Hospedagem<br />(Terceiros)';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."CORPO_HOSPEDAGEM" IS 'Conteúdo que será apresentado na página Hospedagem - Só será valido se Link Hospedagem estiver vazio. | Conteúdo Hospedagem<br />Só se NÃO existir link.';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."CORPO_PATROCINADOR" IS 'Conteúdo que será apresentado na página Patrocinador. | Conteúdo Patrocinador';
COMMENT ON COLUMN SBDB."SITE_EVENTO"."CORPO_PROGRAMA" IS 'Conteúdo que será apresentado na página Programação (Temas). | Conteúdo Programa';
COMMENT ON COLUMN SBDB."SITE_EVENTO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_EVENTO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_EVENTO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_EVENTO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_EVENTO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_EVENTO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_EVENTO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_EVENTO_INSCRICAO
CREATE TABLE SBDB."SITE_EVENTO_INSCRICAO" (
   "ID_EVENTO" NUMBER (5,0),
   "CPF" VARCHAR2 (12),
   "NOME" VARCHAR2 (50),
   "ENDERECO" VARCHAR2 (50),
   "BAIRRO" VARCHAR2 (30),
   "CIDADE" VARCHAR2 (30),
   "ESTADO" VARCHAR2 (2),
   "CEP" VARCHAR2 (10),
   "NOME_CRACHA" VARCHAR2 (40),
   "CRM_ESTADO" VARCHAR2 (2),
   "CRM_NUMERO" VARCHAR2 (20),
   "TEL_CELULAR" VARCHAR2 (40),
   "TEL_RESIDENCIAL" VARCHAR2 (40),
   "TEL_COMERCIAL" VARCHAR2 (40),
   "FAX" VARCHAR2 (40),
   "EMAIL" VARCHAR2 (200),
   "CATEGORIA" VARCHAR2 (255),
   "SOCIO_MAT" NUMBER (5,0),
   "TITULO_SBD" VARCHAR2 (1),
   "TITULO_CNRM" VARCHAR2 (1),
   "TITULO_CNA" VARCHAR2 (1)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_EVENTO_INSCRICAO" ADD CONSTRAINT "ID_SITE_EVENTO_INSCRICAO"
PRIMARY KEY("ID_EVENTO", "CPF");

COMMENT ON TABLE SBDB."SITE_EVENTO_INSCRICAO" IS 'SBDB | Armazena as inscrições realizadas para os eventos. | Inscrição do Evento';

COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."ID_EVENTO" IS 'Sequencial do Evento da tabela Site_Evento. | Sequencial do Evento';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."CPF" IS 'CPF do participante. | CPF';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."NOME" IS 'Nome do participante. | Nome Sacado';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."ENDERECO" IS 'Endereço completo, tipo (rua, av.), logradouro e número do participante. | Endereço do participante';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."BAIRRO" IS 'Bairro do participante. | Bairro';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."CIDADE" IS 'Cidade do participante. | Cidade';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."ESTADO" IS 'Estado do participante. | Estado';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."CEP" IS 'CEP participante. | CEP';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."NOME_CRACHA" IS 'Nome do crachá. | Nome no Crachá';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."CRM_ESTADO" IS 'Estado do CRM. | Estado do CRM';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."CRM_NUMERO" IS 'Número do CRM. | CRM';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."TEL_CELULAR" IS 'Telefone Celular. | Celular';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."TEL_RESIDENCIAL" IS 'Telefone residencial. | Tel. Residencial';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."TEL_COMERCIAL" IS 'Telefone comercial. | Tel. Comercial';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."FAX" IS 'Número do Fax. | Fax';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."EMAIL" IS 'E-mail. | E-mail';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."CATEGORIA" IS 'Categoria. | Categoria';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."SOCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."TITULO_SBD" IS 'Título na SBD. | Título na SBD';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."TITULO_CNRM" IS 'Título no CNRM. | Título no CNRM';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO"."TITULO_CNA" IS 'Titulo CNA. | Título no CNA';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_EVENTO_INSCRICAO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_JORNAL
CREATE TABLE SBDB."SITE_JORNAL" (
   "ANO" NUMBER (4,0),
   "NUM_EDICAO" NUMBER (11,0),
   "PERIODO" VARCHAR2 (50),
   "URL" VARCHAR2 (200),
   "ANO_JORNAL" VARCHAR2 (2)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_JORNAL" ADD CONSTRAINT "ID_SITE_JORNAL"
PRIMARY KEY("ANO", "NUM_EDICAO");

COMMENT ON TABLE SBDB."SITE_JORNAL" IS 'SITE | Cadastro de jornais publicados. | Jornal da SBD';

COMMENT ON COLUMN SBDB."SITE_JORNAL"."ANO" IS 'Ano de publicação. | Ano';
COMMENT ON COLUMN SBDB."SITE_JORNAL"."NUM_EDICAO" IS 'Número da edição. | Edição';
COMMENT ON COLUMN SBDB."SITE_JORNAL"."PERIODO" IS 'Texto de apresentação do período. | Período';
COMMENT ON COLUMN SBDB."SITE_JORNAL"."URL" IS 'Url para download. | Url';
COMMENT ON COLUMN SBDB."SITE_JORNAL"."ANO_JORNAL" IS 'Ano de apresentação sequencial sendo primeira (publicação=1). | Ano Sequencial';
COMMENT ON COLUMN SBDB."SITE_JORNAL".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_JORNAL".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_JORNAL".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_JORNAL".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_JORNAL".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_JORNAL".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_JORNAL".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_NOTICIA
CREATE TABLE SBDB."SITE_NOTICIA" (
   "ID" NUMBER (5,0),
   "TITULO" VARCHAR2 (255),
   "ASSINATURA" VARCHAR2 (255),
   "DATA_CADASTRO" DATE,
   "NOTICIA" CLOB,
   "APRES_PUBLICO" NUMBER (1,0),
   "APRES_MEDICO" NUMBER (1,0),
   "APRES_DEPTO" NUMBER (1,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_NOTICIA" ADD CONSTRAINT "ID_SITE_NOTICIA"
PRIMARY KEY("ID");

COMMENT ON TABLE SBDB."SITE_NOTICIA" IS 'SBDB | Publicação de notícias da SBD. | Notícia';

COMMENT ON COLUMN SBDB."SITE_NOTICIA"."ID" IS 'Sequencial da notícia. | Sequencial';
COMMENT ON COLUMN SBDB."SITE_NOTICIA"."TITULO" IS 'Título de apresentação da notícia. | Título';
COMMENT ON COLUMN SBDB."SITE_NOTICIA"."ASSINATURA" IS 'Assinatura da notícia. | Assinatura';
COMMENT ON COLUMN SBDB."SITE_NOTICIA"."DATA_CADASTRO" IS 'Data de cadastro. | Data de Cadastro';
COMMENT ON COLUMN SBDB."SITE_NOTICIA"."NOTICIA" IS 'Notícia. | Notícia Publicada';
COMMENT ON COLUMN SBDB."SITE_NOTICIA"."APRES_PUBLICO" IS 'Exibição em notícias do Site Público. | Site Público';
COMMENT ON COLUMN SBDB."SITE_NOTICIA"."APRES_MEDICO" IS 'Exibição em notícias do  Site Médico. | Site Médico';
COMMENT ON COLUMN SBDB."SITE_NOTICIA"."APRES_DEPTO" IS 'Exibição em notícias dos Departamentos Especializados. | Depto. Especializado';
COMMENT ON COLUMN SBDB."SITE_NOTICIA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_NOTICIA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_NOTICIA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_NOTICIA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_NOTICIA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_NOTICIA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_NOTICIA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_QUEST
CREATE TABLE SBDB."SITE_QUEST" (
   "SEQ" NUMBER (11,0),
   "TITULO" VARCHAR2 (200),
   "DATA_INICIO" DATE,
   "DATA_LIMITE" DATE,
   "TIPO" VARCHAR2 (20),
   "CABECALHO" CLOB,
   "RODAPE" CLOB
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_QUEST" ADD CONSTRAINT "ID_SITE_QUEST"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."SITE_QUEST" IS 'QUEST | Lista de questionários. | Questionário';

COMMENT ON COLUMN SBDB."SITE_QUEST"."SEQ" IS 'Sequencial de questionário. | Sequencial';
COMMENT ON COLUMN SBDB."SITE_QUEST"."TITULO" IS 'Título do questionário. | Título';
COMMENT ON COLUMN SBDB."SITE_QUEST"."DATA_INICIO" IS 'Data de início de apresentação. | Início';
COMMENT ON COLUMN SBDB."SITE_QUEST"."DATA_LIMITE" IS 'Data limite da apresentação. | Término';
COMMENT ON COLUMN SBDB."SITE_QUEST"."TIPO" IS 'Tipo de questionário. | Tipo';
COMMENT ON COLUMN SBDB."SITE_QUEST"."CABECALHO" IS 'Apresentação do questionário. | Cabeçalho';
COMMENT ON COLUMN SBDB."SITE_QUEST"."RODAPE" IS 'Rodapé do questionário. | Rodapé';
COMMENT ON COLUMN SBDB."SITE_QUEST".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_QUEST".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_QUEST".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_QUEST".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_QUEST".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_QUEST".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_QUEST".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_QUEST_MODELO_RESP
CREATE TABLE SBDB."SITE_QUEST_MODELO_RESP" (
   "COD" VARCHAR2 (50),
   "DESCR" VARCHAR2 (200),
   "PROP_EXTENDS" CLOB
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_QUEST_MODELO_RESP" ADD CONSTRAINT "ID_SITE_QUEST_MODELO_RESP"
PRIMARY KEY("COD");

COMMENT ON TABLE SBDB."SITE_QUEST_MODELO_RESP" IS 'QUEST | Condições possíveis de tipo de resposta. | Cadastro de Tipos de Resposta';

COMMENT ON COLUMN SBDB."SITE_QUEST_MODELO_RESP"."COD" IS 'Código do modelo escolhido para padrão de resposta. | Código';
COMMENT ON COLUMN SBDB."SITE_QUEST_MODELO_RESP"."DESCR" IS 'Descrição explicativa sobre a condição de padrão de resposta. | Título';
COMMENT ON COLUMN SBDB."SITE_QUEST_MODELO_RESP"."PROP_EXTENDS" IS 'Propriedades iniciais do modelo escolhido. | Parâmetros Iniciais';
COMMENT ON COLUMN SBDB."SITE_QUEST_MODELO_RESP".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_QUEST_MODELO_RESP".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_QUEST_MODELO_RESP".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_QUEST_MODELO_RESP".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_QUEST_MODELO_RESP".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_QUEST_MODELO_RESP".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_QUEST_MODELO_RESP".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_QUEST_QUESTAO
CREATE TABLE SBDB."SITE_QUEST_QUESTAO" (
   "QUEST_SEQ" NUMBER (11,0),
   "SEQ" NUMBER (11,0),
   "QUESTAO_SUP_SEQ" NUMBER (11,0),
   "TEXTO" CLOB,
   "ORDEM" NUMBER (11,0),
   "MODELO" VARCHAR2 (50),
   "EXTEND_PROPS" CLOB
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_QUEST_QUESTAO" ADD CONSTRAINT "ID_SITE_QUEST_QUESTAO"
PRIMARY KEY("QUEST_SEQ", "SEQ");

COMMENT ON TABLE SBDB."SITE_QUEST_QUESTAO" IS 'QUEST | Questões de questionário. | Questão';

COMMENT ON COLUMN SBDB."SITE_QUEST_QUESTAO"."QUEST_SEQ" IS 'Sequencial do questionário. | Questionário';
COMMENT ON COLUMN SBDB."SITE_QUEST_QUESTAO"."SEQ" IS 'Sequencial da questão. | Questão';
COMMENT ON COLUMN SBDB."SITE_QUEST_QUESTAO"."QUESTAO_SUP_SEQ" IS 'Questão superior em caso de cascateamento. | Questão Superior';
COMMENT ON COLUMN SBDB."SITE_QUEST_QUESTAO"."TEXTO" IS 'Texto da questão. | Texto';
COMMENT ON COLUMN SBDB."SITE_QUEST_QUESTAO"."ORDEM" IS 'Ordem de apresentação da questão neste nível. | Ordem';
COMMENT ON COLUMN SBDB."SITE_QUEST_QUESTAO"."MODELO" IS 'Modelo que especifica forma de resposta. | Modelo de Resposta';
COMMENT ON COLUMN SBDB."SITE_QUEST_QUESTAO"."EXTEND_PROPS" IS 'Propriedades extendidas para modelo de resposta escolhida permitindo especificação de mais parâmetros. | Parâmetros do Modelo de Resposta';
COMMENT ON COLUMN SBDB."SITE_QUEST_QUESTAO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_QUEST_QUESTAO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_QUEST_QUESTAO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_QUEST_QUESTAO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_QUEST_QUESTAO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_QUEST_QUESTAO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_QUEST_QUESTAO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_QUEST_RESP
CREATE TABLE SBDB."SITE_QUEST_RESP" (
   "QUEST_SEQ" NUMBER (11,0),
   "QUESTAO_SEQ" NUMBER (11,0),
   "SEQ" NUMBER (11,0),
   "TEXTO" CLOB,
   "ORDEM" NUMBER (11,0),
   "QTD_SEL" NUMBER (11,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_QUEST_RESP" ADD CONSTRAINT "ID_SITE_QUEST_RESP"
PRIMARY KEY("QUEST_SEQ", "QUESTAO_SEQ", "SEQ");

COMMENT ON TABLE SBDB."SITE_QUEST_RESP" IS 'QUEST | Possíveis respostas de cada questão. | Resposta';

COMMENT ON COLUMN SBDB."SITE_QUEST_RESP"."QUEST_SEQ" IS 'Sequencial do questionário. | Questionário';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP"."QUESTAO_SEQ" IS 'Sequencial da questão. | Questão';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP"."SEQ" IS 'Questão da resposta. | Sequencial da Resposta';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP"."TEXTO" IS 'Opção de resposta. | Resposta';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP"."ORDEM" IS 'Ordem de apresentação da resposta. | Ordem';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP"."QTD_SEL" IS 'Vezes em que este item foi selecionado para enquete. | Quantidade de Seleções';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_QUEST_RESP_ID
CREATE TABLE SBDB."SITE_QUEST_RESP_ID" (
   "SEQ" NUMBER (11,0),
   "QUEST_SEQ" NUMBER (11,0),
   "EMAIL" VARCHAR2 (200),
   "SOCIO_MAT" NUMBER (11,0),
   "RESPOSTA" CLOB,
   "USUARIO" VARCHAR2 (30)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_QUEST_RESP_ID" ADD CONSTRAINT "ID_SITE_QUEST_RESP_ID"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."SITE_QUEST_RESP_ID" IS 'QUEST | Registro de resposta quando identificado. | Registro de Resposta';

COMMENT ON COLUMN SBDB."SITE_QUEST_RESP_ID"."SEQ" IS 'Sequencial de registro de respostas. | Sequencial';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP_ID"."QUEST_SEQ" IS 'Sequencial do questionário. | Questionário';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP_ID"."EMAIL" IS 'Email de identificação de quem responde. | Email';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP_ID"."SOCIO_MAT" IS 'Matrícula quando quando associado. | Matrícula Quando Associado';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP_ID"."RESPOSTA" IS 'Texto concatenado que representa a resposta do usuário em questão. | Resposta Concatenada';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP_ID"."USUARIO" IS 'Usuário que fez login. | Nome do Usuário';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP_ID".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP_ID".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP_ID".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP_ID".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP_ID".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP_ID".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_QUEST_RESP_ID".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_QUEST_TIPO
CREATE TABLE SBDB."SITE_QUEST_TIPO" (
   "COD" VARCHAR2 (20),
   "DESCR" VARCHAR2 (200)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_QUEST_TIPO" ADD CONSTRAINT "ID_SITE_QUEST_TIPO"
PRIMARY KEY("COD");

COMMENT ON TABLE SBDB."SITE_QUEST_TIPO" IS 'QUEST | Tipos de questionários possíveis. | Tipo de Questionário';

COMMENT ON COLUMN SBDB."SITE_QUEST_TIPO"."COD" IS 'Código do tipo de questionário. | Tipo de Questionário';
COMMENT ON COLUMN SBDB."SITE_QUEST_TIPO"."DESCR" IS 'Descrição sobre o tipo. | Descrição';
COMMENT ON COLUMN SBDB."SITE_QUEST_TIPO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_QUEST_TIPO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_QUEST_TIPO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_QUEST_TIPO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_QUEST_TIPO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_QUEST_TIPO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_QUEST_TIPO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_REVISTA
CREATE TABLE SBDB."SITE_REVISTA" (
   "TITULO_EXTENSO_REVISTA" VARCHAR2 (200),
   "TITULO_ABREVIADO_REVISTA" VARCHAR2 (100),
   "ANO_INICIAL_REVISTA" NUMBER (4,0),
   "ANO_FINAL_REVISTA" NUMBER (4,0),
   "VOL_INICIAL_REVISTA" NUMBER (8,0),
   "VOL_FINAL_REVISTA" NUMBER (8,0),
   "DATA_CADASTRO" DATE,
   "DATA_ULT_ALTERACAO" DATE,
   "COD_POS_REVISTA" NUMBER (1,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_REVISTA" ADD CONSTRAINT "ID_SITE_REVISTA"
PRIMARY KEY("TITULO_EXTENSO_REVISTA");

COMMENT ON TABLE SBDB."SITE_REVISTA" IS 'SBDB | Armazena dado sobre a revista. | Revista no Site';

COMMENT ON COLUMN SBDB."SITE_REVISTA"."TITULO_EXTENSO_REVISTA" IS 'Título da revista. | Título da Revista';
COMMENT ON COLUMN SBDB."SITE_REVISTA"."TITULO_ABREVIADO_REVISTA" IS 'Abreviado do título. | Título Abreviado';
COMMENT ON COLUMN SBDB."SITE_REVISTA"."ANO_INICIAL_REVISTA" IS 'Ano de inicio da revista. | Ano';
COMMENT ON COLUMN SBDB."SITE_REVISTA"."ANO_FINAL_REVISTA" IS 'Ano de término. | Ano';
COMMENT ON COLUMN SBDB."SITE_REVISTA"."VOL_INICIAL_REVISTA" IS 'Volume de início. | Volume de Início';
COMMENT ON COLUMN SBDB."SITE_REVISTA"."VOL_FINAL_REVISTA" IS 'Volume de término. | Volume de Término';
COMMENT ON COLUMN SBDB."SITE_REVISTA"."DATA_CADASTRO" IS 'Data de cadastro. | Data de Cadastro';
COMMENT ON COLUMN SBDB."SITE_REVISTA"."DATA_ULT_ALTERACAO" IS 'Data da última alteração. | Data da Última Alteração';
COMMENT ON COLUMN SBDB."SITE_REVISTA"."COD_POS_REVISTA" IS 'Posição da revista. | Posição da Revista';
COMMENT ON COLUMN SBDB."SITE_REVISTA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_REVISTA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_REVISTA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_REVISTA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_REVISTA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_REVISTA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_REVISTA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SITE_REVISTA_POSICAO
CREATE TABLE SBDB."SITE_REVISTA_POSICAO" (
   "COD_POS_REVISTA" NUMBER (1,0),
   "DESC_POS_REVISTA" VARCHAR2 (50)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SITE_REVISTA_POSICAO" ADD CONSTRAINT "ID_SITE_REVISTA_POSICAO"
PRIMARY KEY("COD_POS_REVISTA");

COMMENT ON TABLE SBDB."SITE_REVISTA_POSICAO" IS 'SBDB | Armazena a posição da revista na edição. | Posição da Revista';

COMMENT ON COLUMN SBDB."SITE_REVISTA_POSICAO"."COD_POS_REVISTA" IS 'Posição da revista. | Posição da Revista';
COMMENT ON COLUMN SBDB."SITE_REVISTA_POSICAO"."DESC_POS_REVISTA" IS 'Descrição da posição da revista. | Descrição da Posição da Revista';
COMMENT ON COLUMN SBDB."SITE_REVISTA_POSICAO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SITE_REVISTA_POSICAO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SITE_REVISTA_POSICAO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SITE_REVISTA_POSICAO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SITE_REVISTA_POSICAO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SITE_REVISTA_POSICAO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SITE_REVISTA_POSICAO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SÓCIO
CREATE TABLE SBDB."SÓCIO" (
   "MAT" NUMBER (5,0),
   "NOME" VARCHAR2 (50),
   "DATA_CADASTRO" DATE,
   "TRATAMENTO" VARCHAR2 (10),
   "NOME_PREFERENCIAL" VARCHAR2 (50),
   "CRM_ESTADO" VARCHAR2 (2),
   "CRM" VARCHAR2 (20),
   "CRM_DATA" DATE,
   "MLN" VARCHAR2 (20),
   "SEXO" VARCHAR2 (1),
   "CPF" VARCHAR2 (12),
   "ID_ORGAO" VARCHAR2 (10),
   "IDENTIDADE" VARCHAR2 (15),
   "NATURALIDADE" VARCHAR2 (2),
   "NACIONALIDADE" VARCHAR2 (20),
   "DATA_NASCIMENTO" DATE,
   "FILIAÇÃO_PAI" VARCHAR2 (50),
   "FILIAÇÃO_MÃE" VARCHAR2 (50),
   "ESTADO_CIVIL" VARCHAR2 (10),
   "REGIONAL_COD" VARCHAR2 (2),
   "CATEGORIA_COD" VARCHAR2 (20),
   "OBRIG_STATUS_COD" VARCHAR2 (50),
   "OBRIG_STATUS_DATA" DATE,
   "TED" NUMBER (5,0),
   "TED_ANO_CONCURSO" DATE,
   "TED_DATA_EXPEDIÇÃO" DATE,
   "TED_DATA_APROVAÇÃO" DATE,
   "TED_IMPRESSÃO" NUMBER (5,0),
   "CFM_ADESAO" DATE,
   "CFM_OBS" VARCHAR2 (3000),
   "DATA_INICIO_CONTAGEM" DATE,
   "SOCIO_ELETRONICO" NUMBER (1,0),
   "SITE" VARCHAR2 (4000),
   "FOTO" VARCHAR2 (100),
   "MALA_DIRETA" VARCHAR2 (1),
   "ENDEREÇO_RESIDENCIAL" VARCHAR2 (60),
   "NUMERO_RESIDENCIAL" VARCHAR2 (30),
   "COMPLEMENTO_RESIDENCIAL" VARCHAR2 (30),
   "BAIRRO_RESIDENCIAL" VARCHAR2 (50),
   "CIDADE_RESIDENCIAL" VARCHAR2 (50),
   "ESTADO_RESIDENCIAL" VARCHAR2 (2),
   "ESTADO_RESIDENCIAL_EX" VARCHAR2 (2),
   "PAÍS_RESIDENCIAL" VARCHAR2 (30),
   "CEP_RESIDENCIAL" VARCHAR2 (10),
   "DDI_RESIDENCIAL" VARCHAR2 (4),
   "DDD_RESIDENCIAL" VARCHAR2 (4),
   "TEL_RESIDENCIAL" VARCHAR2 (40),
   "FAX_RESIDENCIAL" VARCHAR2 (40),
   "TEL_CELULAR_RESIDENCIAL" VARCHAR2 (40),
   "EMAIL_RESIDENCIAL" VARCHAR2 (200),
   "ENDEREÇO_COMERCIAL_1" VARCHAR2 (60),
   "NUMERO_COMERCIAL_1" VARCHAR2 (30),
   "COMPLEMENTO_COMERCIAL_1" VARCHAR2 (30),
   "BAIRRO_COMERCIAL_1" VARCHAR2 (50),
   "CIDADE_COMERCIAL_1" VARCHAR2 (50),
   "ESTADO_COMERCIAL_1_EX" VARCHAR2 (2),
   "ESTADO_COMERCIAL_1" VARCHAR2 (2),
   "PAÍS_COMERCIAL_1" VARCHAR2 (30),
   "CEP_COMERCIAL_1" VARCHAR2 (10),
   "DDI_COMERCIAL_1" VARCHAR2 (4),
   "TEL_COMERCIAL_1" VARCHAR2 (40),
   "FAX_COMERCIAL_1" VARCHAR2 (40),
   "DDD_COMERCIAL_1" VARCHAR2 (4),
   "PUBLICAR_COMERCIAL_1" NUMBER (1,0),
   "EMAIL_COMERCIAL_1" VARCHAR2 (200),
   "ENDEREÇO_COMERCIAL_2" VARCHAR2 (60),
   "NUMERO_COMERCIAL_2" VARCHAR2 (30),
   "COMPLEMENTO_COMERCIAL_2" VARCHAR2 (30),
   "BAIRRO_COMERCIAL_2" VARCHAR2 (50),
   "CIDADE_COMERCIAL_2" VARCHAR2 (50),
   "ESTADO_COMERCIAL_2" VARCHAR2 (2),
   "ESTADO_COMERCIAL_2_EX" VARCHAR2 (2),
   "PAÍS_COMERCIAL_2" VARCHAR2 (30),
   "CEP_COMERCIAL_2" VARCHAR2 (10),
   "DDI_COMERCIAL_2" VARCHAR2 (4),
   "DDD_COMERCIAL_2" VARCHAR2 (4),
   "TEL_COMERCIAL_2" VARCHAR2 (40),
   "FAX_COMERCIAL_2" VARCHAR2 (40),
   "EMAIL_COMERCIAL_2" VARCHAR2 (200),
   "PUBLICAR_COMERCIAL_2" NUMBER (1,0),
   "UNIVERSIDADE_DATA_FORMA" DATE,
   "UNIVERSIDADE_NOME" VARCHAR2 (50),
   "UNIVERSIDADE_LOCAL" VARCHAR2 (40),
   "RESIDÊNCIA_1_NOME" VARCHAR2 (100),
   "RESIDÊNCIA_1_LOCAL" VARCHAR2 (50),
   "RESIDÊNCIA_1_DATA_INI" DATE,
   "RESIDÊNCIA_1_DATA_FIM" DATE,
   "RESIDÊNCIA_2_NOME" VARCHAR2 (100),
   "RESIDÊNCIA_2_LOCAL" VARCHAR2 (50),
   "RESIDÊNCIA_2_DATA_INI" DATE,
   "RESIDÊNCIA_2_DATA_FIM" DATE,
   "RESIDÊNCIA_3_NOME" VARCHAR2 (100),
   "RESIDÊNCIA_3_LOCAL" VARCHAR2 (50),
   "RESIDÊNCIA_3_DATA_INI" DATE,
   "RESIDÊNCIA_3_DATA_FIM" DATE,
   "ESPECIALIDADE_NOME" VARCHAR2 (50),
   "ESPECIALIDADE_LOCAL" VARCHAR2 (50),
   "ESPECIALIDADE_DATA_INI" DATE,
   "ESPECIALIDADE_DATA_FIM" DATE,
   "PÓS_DOUTORADO_NOME" VARCHAR2 (50),
   "PÓS_DOUTORADO_INST" VARCHAR2 (50),
   "PÓS_DOUTORADO_LOCAL" VARCHAR2 (50),
   "PÓS_DOUTORADO_DATA" DATE,
   "LIVRE_DOCÊNCIA_NOME" VARCHAR2 (50),
   "LIVRE_DOCÊNCIA_INST" VARCHAR2 (50),
   "LIVRE_DOCÊNCIA_LOCAL" VARCHAR2 (50),
   "LIVRE_DOCÊNCIA_DATA" DATE,
   "DOUTORADO_NOME" VARCHAR2 (50),
   "DOUTORADO_INST" VARCHAR2 (50),
   "DOUTORADO_LOCAL" VARCHAR2 (50),
   "DOUTORADO_DATA" DATE,
   "MESTRADO_NOME" VARCHAR2 (50),
   "MESTRADO_INST" VARCHAR2 (50),
   "MESTRADO_LOCAL" VARCHAR2 (50),
   "MESTRADO_DATA" DATE,
   "PESQUISA_TEMA" VARCHAR2 (50),
   "CNRM" NUMBER (1,0),
   "TRABALHO1_NOME" VARCHAR2 (50),
   "TRABALHO1_CARGO" VARCHAR2 (100),
   "TRABALHO2_NOME" VARCHAR2 (50),
   "TRABALHO2_CARGO" VARCHAR2 (100),
   "TRABALHO3_NOME" VARCHAR2 (50),
   "TRABALHO3_CARGO" VARCHAR2 (100),
   "EXCLUÍDO" NUMBER (1,0),
   "DATA_EXCLUSÃO" DATE,
   "MOTIVO_EXCLUSÃO" VARCHAR2 (3000),
   "RESP_EXCLUSÃO" VARCHAR2 (50),
   "OBS" VARCHAR2 (3000),
   "FALECIDO" NUMBER (1,0),
   "ISENTO" NUMBER (5,0),
   "PENALIZADO" VARCHAR2 (1),
   "TITULAÇÃO" VARCHAR2 (50),
   "QUALIF_PROF" CLOB,
   "QUALIF_PROF_I" CLOB,
   "QUALIF_PROF_E" CLOB,
   "EMCD_IMP_ETIQ" NUMBER (5,0),
   "EMCD_DATA_IMP_ETIQ" DATE,
   "SENHA" VARCHAR2 (20),
   "OBRIG_STATUS_LOG" CLOB,
   "REG_LOG" VARCHAR2 (4000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SÓCIO" ADD CONSTRAINT "ID_SÓCIO"
PRIMARY KEY("MAT");

COMMENT ON TABLE SBDB."SÓCIO" IS 'SÓCIO | Cadastro dos associados. | Sócio';

COMMENT ON COLUMN SBDB."SÓCIO"."MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."SÓCIO"."NOME" IS 'Nome. | Nome';
COMMENT ON COLUMN SBDB."SÓCIO"."DATA_CADASTRO" IS 'Data de cadastro. | Data de Cadastro';
COMMENT ON COLUMN SBDB."SÓCIO"."TRATAMENTO" IS 'Tratamento. | Tratamento';
COMMENT ON COLUMN SBDB."SÓCIO"."NOME_PREFERENCIAL" IS 'Nome preferencial. | Nome Preferencial';
COMMENT ON COLUMN SBDB."SÓCIO"."CRM_ESTADO" IS 'Estado do registro de CRM. | Estado do CRM';
COMMENT ON COLUMN SBDB."SÓCIO"."CRM" IS 'CRM quando usuário for um médico registrado. | CRM';
COMMENT ON COLUMN SBDB."SÓCIO"."CRM_DATA" IS 'Data de emissão do Registro de CRM. | Data de Emissão CRM';
COMMENT ON COLUMN SBDB."SÓCIO"."MLN" IS 'Medical License Number. | Medical License Number';
COMMENT ON COLUMN SBDB."SÓCIO"."SEXO" IS 'Sexo M=Masculino, F=Feminino. | Sexo';
COMMENT ON COLUMN SBDB."SÓCIO"."CPF" IS 'Seu CPF. | CPF';
COMMENT ON COLUMN SBDB."SÓCIO"."ID_ORGAO" IS 'Órgão expedidor da identidade. | Órgão Expedidor RG';
COMMENT ON COLUMN SBDB."SÓCIO"."IDENTIDADE" IS 'Identidade. | RG';
COMMENT ON COLUMN SBDB."SÓCIO"."NATURALIDADE" IS 'Naturalidade. | Naturalidade';
COMMENT ON COLUMN SBDB."SÓCIO"."NACIONALIDADE" IS 'Nacionalidade. | Nacionalidade';
COMMENT ON COLUMN SBDB."SÓCIO"."DATA_NASCIMENTO" IS 'Data de nascimento. | Data de Nascimento';
COMMENT ON COLUMN SBDB."SÓCIO"."FILIAÇÃO_PAI" IS 'Nome do pai. | Nome do Pai';
COMMENT ON COLUMN SBDB."SÓCIO"."FILIAÇÃO_MÃE" IS 'Nome da mãe. | Nome da Mãe';
COMMENT ON COLUMN SBDB."SÓCIO"."ESTADO_CIVIL" IS 'Estado civil. | Estado Civil';
COMMENT ON COLUMN SBDB."SÓCIO"."REGIONAL_COD" IS 'Regional. | Regional';
COMMENT ON COLUMN SBDB."SÓCIO"."CATEGORIA_COD" IS 'Categoria. | Categoria';
COMMENT ON COLUMN SBDB."SÓCIO"."OBRIG_STATUS_COD" IS 'Situação administrativa. | Situação Administrativa';
COMMENT ON COLUMN SBDB."SÓCIO"."OBRIG_STATUS_DATA" IS 'Data de registro da situação administrativa. | Data de Reg. Situação Administrativa';
COMMENT ON COLUMN SBDB."SÓCIO"."TED" IS 'Status de aprovação do TED. | Status de Aprovação do TED';
COMMENT ON COLUMN SBDB."SÓCIO"."TED_ANO_CONCURSO" IS 'Ano de realização da prova do TED. | Ano do Concurso';
COMMENT ON COLUMN SBDB."SÓCIO"."TED_DATA_EXPEDIÇÃO" IS 'Data de expedição do TED. | Data de Expedição do TED';
COMMENT ON COLUMN SBDB."SÓCIO"."TED_DATA_APROVAÇÃO" IS 'Data de aprovação do TED. | Data de Exame do TED';
COMMENT ON COLUMN SBDB."SÓCIO"."TED_IMPRESSÃO" IS 'Confirmação de impressão do TED. | Confirmação  de Impressão do TED';
COMMENT ON COLUMN SBDB."SÓCIO"."CFM_ADESAO" IS 'Data de adesão do CNA. | Data de Adesão do CNA';
COMMENT ON COLUMN SBDB."SÓCIO"."CFM_OBS" IS 'Observação do CNA. | Observação do CNA';
COMMENT ON COLUMN SBDB."SÓCIO"."DATA_INICIO_CONTAGEM" IS 'Data de Início da pontuação EMC-D. | Data de Início';
COMMENT ON COLUMN SBDB."SÓCIO"."SOCIO_ELETRONICO" IS 'Associado eletrônico. | Associado Eletrônico';
COMMENT ON COLUMN SBDB."SÓCIO"."SITE" IS 'Site. | Site';
COMMENT ON COLUMN SBDB."SÓCIO"."FOTO" IS '{Imagem} Foto. | Foto';
COMMENT ON COLUMN SBDB."SÓCIO"."MALA_DIRETA" IS 'Endereço de correspondência. | Endereço de Correspondência';
COMMENT ON COLUMN SBDB."SÓCIO"."ENDEREÇO_RESIDENCIAL" IS 'Endereço residencial completo, tipo (rua, av.), logradouro e número. | Endereço Residencial';
COMMENT ON COLUMN SBDB."SÓCIO"."NUMERO_RESIDENCIAL" IS 'Número residencial. | Número';
COMMENT ON COLUMN SBDB."SÓCIO"."COMPLEMENTO_RESIDENCIAL" IS 'Complemento residencial. | Complemento';
COMMENT ON COLUMN SBDB."SÓCIO"."BAIRRO_RESIDENCIAL" IS 'Bairro residencial. | Bairro';
COMMENT ON COLUMN SBDB."SÓCIO"."CIDADE_RESIDENCIAL" IS 'Cidade residencial. | Cidade';
COMMENT ON COLUMN SBDB."SÓCIO"."ESTADO_RESIDENCIAL" IS 'Estado residencial. | Estado';
COMMENT ON COLUMN SBDB."SÓCIO"."ESTADO_RESIDENCIAL_EX" IS 'Estado residencial. | Estado';
COMMENT ON COLUMN SBDB."SÓCIO"."PAÍS_RESIDENCIAL" IS 'País residencial. | País';
COMMENT ON COLUMN SBDB."SÓCIO"."CEP_RESIDENCIAL" IS 'CEP residencial. | CEP';
COMMENT ON COLUMN SBDB."SÓCIO"."DDI_RESIDENCIAL" IS 'DDI residencial. | DDI';
COMMENT ON COLUMN SBDB."SÓCIO"."DDD_RESIDENCIAL" IS 'DDD Residencial. | DDD';
COMMENT ON COLUMN SBDB."SÓCIO"."TEL_RESIDENCIAL" IS 'Telefone residencial. | Telefone';
COMMENT ON COLUMN SBDB."SÓCIO"."FAX_RESIDENCIAL" IS 'Fax residencial. | Fax';
COMMENT ON COLUMN SBDB."SÓCIO"."TEL_CELULAR_RESIDENCIAL" IS 'Celular Residencial. | Celular Residencial';
COMMENT ON COLUMN SBDB."SÓCIO"."EMAIL_RESIDENCIAL" IS 'E-mail residencial. | E-mail';
COMMENT ON COLUMN SBDB."SÓCIO"."ENDEREÇO_COMERCIAL_1" IS 'Endereço comercial 1 completo, tipo (rua, av.), logradouro e número. | Endereço';
COMMENT ON COLUMN SBDB."SÓCIO"."NUMERO_COMERCIAL_1" IS 'Número comercial 1. | Número';
COMMENT ON COLUMN SBDB."SÓCIO"."COMPLEMENTO_COMERCIAL_1" IS 'Complemento comercial 1. | Complemento';
COMMENT ON COLUMN SBDB."SÓCIO"."BAIRRO_COMERCIAL_1" IS 'Bairro comercial 1. | Bairro';
COMMENT ON COLUMN SBDB."SÓCIO"."CIDADE_COMERCIAL_1" IS 'Cidade comercial 1. | Cidade';
COMMENT ON COLUMN SBDB."SÓCIO"."ESTADO_COMERCIAL_1_EX" IS 'Estado comercial 1. | Estado';
COMMENT ON COLUMN SBDB."SÓCIO"."ESTADO_COMERCIAL_1" IS 'Estado comercial 1. | Estado';
COMMENT ON COLUMN SBDB."SÓCIO"."PAÍS_COMERCIAL_1" IS 'País comercial 1. | País';
COMMENT ON COLUMN SBDB."SÓCIO"."CEP_COMERCIAL_1" IS 'CEP comercial 1. | CEP';
COMMENT ON COLUMN SBDB."SÓCIO"."DDI_COMERCIAL_1" IS 'DDI comercial 1. | DDI';
COMMENT ON COLUMN SBDB."SÓCIO"."TEL_COMERCIAL_1" IS 'Telefone comercial 1. | Telefone';
COMMENT ON COLUMN SBDB."SÓCIO"."FAX_COMERCIAL_1" IS 'Fax comercial 1. | Fax';
COMMENT ON COLUMN SBDB."SÓCIO"."DDD_COMERCIAL_1" IS 'DDD comercial 1. | DDD';
COMMENT ON COLUMN SBDB."SÓCIO"."PUBLICAR_COMERCIAL_1" IS 'Status de publicação do endereço comercial 1. | Publicar Endereço Comercial 1';
COMMENT ON COLUMN SBDB."SÓCIO"."EMAIL_COMERCIAL_1" IS 'E-mail comercial 1. | E-mail';
COMMENT ON COLUMN SBDB."SÓCIO"."ENDEREÇO_COMERCIAL_2" IS 'Endereço comercial 2 completo, tipo (rua, av.), logradouro e número. | Endereço';
COMMENT ON COLUMN SBDB."SÓCIO"."NUMERO_COMERCIAL_2" IS 'Número comercial 2. | Número';
COMMENT ON COLUMN SBDB."SÓCIO"."COMPLEMENTO_COMERCIAL_2" IS 'Complemento comercial 2. | Complemento';
COMMENT ON COLUMN SBDB."SÓCIO"."BAIRRO_COMERCIAL_2" IS 'Bairro comercial 2. | Bairro';
COMMENT ON COLUMN SBDB."SÓCIO"."CIDADE_COMERCIAL_2" IS 'Cidade comercial 2. | Cidade';
COMMENT ON COLUMN SBDB."SÓCIO"."ESTADO_COMERCIAL_2" IS 'Estado comercial 2. | Estado';
COMMENT ON COLUMN SBDB."SÓCIO"."ESTADO_COMERCIAL_2_EX" IS 'Estado comercial 2. | Estado';
COMMENT ON COLUMN SBDB."SÓCIO"."PAÍS_COMERCIAL_2" IS 'País comercial 2. | País';
COMMENT ON COLUMN SBDB."SÓCIO"."CEP_COMERCIAL_2" IS 'CEP comercial 2. | CEP';
COMMENT ON COLUMN SBDB."SÓCIO"."DDI_COMERCIAL_2" IS 'DDI comercial 2. | DDI';
COMMENT ON COLUMN SBDB."SÓCIO"."DDD_COMERCIAL_2" IS 'DDD comercial 2. | DDD';
COMMENT ON COLUMN SBDB."SÓCIO"."TEL_COMERCIAL_2" IS 'Telefone comercial 2. | Telefone';
COMMENT ON COLUMN SBDB."SÓCIO"."FAX_COMERCIAL_2" IS 'Fax comercial 2. | Fax';
COMMENT ON COLUMN SBDB."SÓCIO"."EMAIL_COMERCIAL_2" IS 'E-mail comercial 2. | E-mail';
COMMENT ON COLUMN SBDB."SÓCIO"."PUBLICAR_COMERCIAL_2" IS 'Status de publicação do endereço comercial 2. | Publicar Endereço Comercial 2';
COMMENT ON COLUMN SBDB."SÓCIO"."UNIVERSIDADE_DATA_FORMA" IS 'Data de formatura. | Ano de Formatura';
COMMENT ON COLUMN SBDB."SÓCIO"."UNIVERSIDADE_NOME" IS 'Nome da universidade de formatura. | Nome da Universidade de Formatura';
COMMENT ON COLUMN SBDB."SÓCIO"."UNIVERSIDADE_LOCAL" IS 'Local de formatura. | Local de Formatura';
COMMENT ON COLUMN SBDB."SÓCIO"."RESIDÊNCIA_1_NOME" IS 'Nome da especialidade da primeira residência. | Residência em';
COMMENT ON COLUMN SBDB."SÓCIO"."RESIDÊNCIA_1_LOCAL" IS 'Local da primeira residência. | Local';
COMMENT ON COLUMN SBDB."SÓCIO"."RESIDÊNCIA_1_DATA_INI" IS 'Data de início da primeira residência. | Data de Início';
COMMENT ON COLUMN SBDB."SÓCIO"."RESIDÊNCIA_1_DATA_FIM" IS 'Data de término da primeira residência. | Data de Término';
COMMENT ON COLUMN SBDB."SÓCIO"."RESIDÊNCIA_2_NOME" IS 'Nome da especialidade da segunda residência. | Residência em';
COMMENT ON COLUMN SBDB."SÓCIO"."RESIDÊNCIA_2_LOCAL" IS 'Local da segunda residência. | Local';
COMMENT ON COLUMN SBDB."SÓCIO"."RESIDÊNCIA_2_DATA_INI" IS 'Data de início da segunda residência. | Data de Início';
COMMENT ON COLUMN SBDB."SÓCIO"."RESIDÊNCIA_2_DATA_FIM" IS 'Data de término da segunda residência. | Data de Término';
COMMENT ON COLUMN SBDB."SÓCIO"."RESIDÊNCIA_3_NOME" IS 'Nome da especialidade da terceira residência. | Residência em';
COMMENT ON COLUMN SBDB."SÓCIO"."RESIDÊNCIA_3_LOCAL" IS 'Local da terceira residência. | Local';
COMMENT ON COLUMN SBDB."SÓCIO"."RESIDÊNCIA_3_DATA_INI" IS 'Data de término da terceira residência. | Data de Término';
COMMENT ON COLUMN SBDB."SÓCIO"."RESIDÊNCIA_3_DATA_FIM" IS 'Data de início da terceira residência. | Data de Início';
COMMENT ON COLUMN SBDB."SÓCIO"."ESPECIALIDADE_NOME" IS 'Nome da especialização. | Nome da Especialização';
COMMENT ON COLUMN SBDB."SÓCIO"."ESPECIALIDADE_LOCAL" IS 'Local da especialização. | Local da Especialização';
COMMENT ON COLUMN SBDB."SÓCIO"."ESPECIALIDADE_DATA_INI" IS 'Data de início da especialização. | Data de Início da Especialização';
COMMENT ON COLUMN SBDB."SÓCIO"."ESPECIALIDADE_DATA_FIM" IS 'Data de término da especialização. | Data de Término da Especialização';
COMMENT ON COLUMN SBDB."SÓCIO"."PÓS_DOUTORADO_NOME" IS 'Especialidade na pós-graduação. | Pós-Doutorado em';
COMMENT ON COLUMN SBDB."SÓCIO"."PÓS_DOUTORADO_INST" IS 'Instituição onde realizou a pós-graduação. | Instituição';
COMMENT ON COLUMN SBDB."SÓCIO"."PÓS_DOUTORADO_LOCAL" IS 'Local da pós-graduação. | Local';
COMMENT ON COLUMN SBDB."SÓCIO"."PÓS_DOUTORADO_DATA" IS 'Data de formatura da pós-graduação. | Data de Formatura';
COMMENT ON COLUMN SBDB."SÓCIO"."LIVRE_DOCÊNCIA_NOME" IS 'Especialidade na livre docência. | Livre Docência em';
COMMENT ON COLUMN SBDB."SÓCIO"."LIVRE_DOCÊNCIA_INST" IS 'Instituição da livre docência. | Instituição';
COMMENT ON COLUMN SBDB."SÓCIO"."LIVRE_DOCÊNCIA_LOCAL" IS 'Local da livre docência. | Local';
COMMENT ON COLUMN SBDB."SÓCIO"."LIVRE_DOCÊNCIA_DATA" IS 'Data de formatura da livre docência. | Data de Formatura';
COMMENT ON COLUMN SBDB."SÓCIO"."DOUTORADO_NOME" IS 'Especialidade no doutorado. | Doutorado em';
COMMENT ON COLUMN SBDB."SÓCIO"."DOUTORADO_INST" IS 'Instituição onde realizou o doutorado. | Instituição';
COMMENT ON COLUMN SBDB."SÓCIO"."DOUTORADO_LOCAL" IS 'Local do doutorado. | Local';
COMMENT ON COLUMN SBDB."SÓCIO"."DOUTORADO_DATA" IS 'Data de formatura do doutorado. | Data de Formatura';
COMMENT ON COLUMN SBDB."SÓCIO"."MESTRADO_NOME" IS 'Especialidade no mestrado. | Mestrado em';
COMMENT ON COLUMN SBDB."SÓCIO"."MESTRADO_INST" IS 'Instituição onde realizou o mestrado. | Instituição';
COMMENT ON COLUMN SBDB."SÓCIO"."MESTRADO_LOCAL" IS 'Local do mestrado. | Local';
COMMENT ON COLUMN SBDB."SÓCIO"."MESTRADO_DATA" IS 'Data de formatura do mestrado. | Data de Formatura';
COMMENT ON COLUMN SBDB."SÓCIO"."PESQUISA_TEMA" IS 'Linha de pesquisa. | Linha de Pesquisa';
COMMENT ON COLUMN SBDB."SÓCIO"."CNRM" IS 'Certificado pelo conselho nacional de residência médica. | Certificado pelo CNRM';
COMMENT ON COLUMN SBDB."SÓCIO"."TRABALHO1_NOME" IS 'Primeiro local onde trabalhou. | Local de Trabalho';
COMMENT ON COLUMN SBDB."SÓCIO"."TRABALHO1_CARGO" IS 'Cargo ocupado no primeiro trabalho. | Cargo';
COMMENT ON COLUMN SBDB."SÓCIO"."TRABALHO2_NOME" IS 'Segundo local onde trabalhou. | Local de Trabalho';
COMMENT ON COLUMN SBDB."SÓCIO"."TRABALHO2_CARGO" IS 'Cargo ocupado no segundo trabalho. | Cargo';
COMMENT ON COLUMN SBDB."SÓCIO"."TRABALHO3_NOME" IS 'Terceiro local onde Trabalhou. | Local de Trabalho';
COMMENT ON COLUMN SBDB."SÓCIO"."TRABALHO3_CARGO" IS 'Cargo ocupado no terceiro trabalho. | Cargo';
COMMENT ON COLUMN SBDB."SÓCIO"."EXCLUÍDO" IS 'Status de exclusão do associado.. | Excluído';
COMMENT ON COLUMN SBDB."SÓCIO"."DATA_EXCLUSÃO" IS 'Data da exclusão. | Data da Exclusão';
COMMENT ON COLUMN SBDB."SÓCIO"."MOTIVO_EXCLUSÃO" IS 'Motivo da exclusão. | Motivo da Exclusão';
COMMENT ON COLUMN SBDB."SÓCIO"."RESP_EXCLUSÃO" IS 'Responsável pela exclusão. | Responsável pela Exclusão';
COMMENT ON COLUMN SBDB."SÓCIO"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."SÓCIO"."FALECIDO" IS 'Informa se o associado está Falecido. | Falecido';
COMMENT ON COLUMN SBDB."SÓCIO"."ISENTO" IS 'Status de isenção. | Status de Isento';
COMMENT ON COLUMN SBDB."SÓCIO"."PENALIZADO" IS 'Status de penalidade S=Sim, N=Não. | Status de Penalidade';
COMMENT ON COLUMN SBDB."SÓCIO"."TITULAÇÃO" IS 'Titulação. | Titulação';
COMMENT ON COLUMN SBDB."SÓCIO"."QUALIF_PROF" IS 'Qualificação profissional. | Qualificação Profissional';
COMMENT ON COLUMN SBDB."SÓCIO"."QUALIF_PROF_I" IS 'Qualificação profissional em inglês. | Qualificação Profissional em Inglês';
COMMENT ON COLUMN SBDB."SÓCIO"."QUALIF_PROF_E" IS 'Qualificação profissional em espanhol. | Qualificação Profissional em Espanhol';
COMMENT ON COLUMN SBDB."SÓCIO"."EMCD_IMP_ETIQ" IS 'Sequencial de impressão de etiqueta para EMC-D. | Sequencial de Impressão de Etiqueta para EMC-D';
COMMENT ON COLUMN SBDB."SÓCIO"."EMCD_DATA_IMP_ETIQ" IS 'Data de Impressão da Etiqueta para EMC-D. | Data de Impressão da Etiqueta para EMC-D';
COMMENT ON COLUMN SBDB."SÓCIO"."SENHA" IS 'Senha de acesso ao site. | Senha de Acesso ao Site';
COMMENT ON COLUMN SBDB."SÓCIO"."OBRIG_STATUS_LOG" IS 'Registro de baixas de pagamentos. | Registro de Baixas de Pagamentos';
COMMENT ON COLUMN SBDB."SÓCIO"."REG_LOG" IS 'Registra informações sobre o cadastro. | Registra Informações Sobre o Cadastro';
COMMENT ON COLUMN SBDB."SÓCIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SÓCIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SÓCIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SÓCIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SÓCIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SÓCIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SÓCIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SÓCIO_CATEGORIA
CREATE TABLE SBDB."SÓCIO_CATEGORIA" (
   "SÓCIO_MAT" NUMBER (5,0),
   "CATEGORIA_COD" VARCHAR2 (20),
   "SEQ" NUMBER (5,0),
   "DATA_ALTERAÇÃO" DATE,
   "OBS" VARCHAR2 (3000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SÓCIO_CATEGORIA" ADD CONSTRAINT "ID_SÓCIO_CATEGORIA"
PRIMARY KEY("SÓCIO_MAT", "CATEGORIA_COD", "SEQ");

COMMENT ON TABLE SBDB."SÓCIO_CATEGORIA" IS 'SÓCIO | Cadastro dos históricos das categorias dos associados. | Categoria do Sócio';

COMMENT ON COLUMN SBDB."SÓCIO_CATEGORIA"."SÓCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."SÓCIO_CATEGORIA"."CATEGORIA_COD" IS 'Categoria. | Categoria';
COMMENT ON COLUMN SBDB."SÓCIO_CATEGORIA"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."SÓCIO_CATEGORIA"."DATA_ALTERAÇÃO" IS 'Data de alteração. | Data da Alteração';
COMMENT ON COLUMN SBDB."SÓCIO_CATEGORIA"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."SÓCIO_CATEGORIA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SÓCIO_CATEGORIA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SÓCIO_CATEGORIA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SÓCIO_CATEGORIA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SÓCIO_CATEGORIA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SÓCIO_CATEGORIA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SÓCIO_CATEGORIA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SÓCIO_CONVÊNIO
CREATE TABLE SBDB."SÓCIO_CONVÊNIO" (
   "CONVÊNIO_COD" VARCHAR2 (30),
   "SÓCIO_MAT" NUMBER (5,0),
   "DATA" DATE,
   "OBS" VARCHAR2 (3000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SÓCIO_CONVÊNIO" ADD CONSTRAINT "ID_SÓCIO_CONVÊNIO"
PRIMARY KEY("CONVÊNIO_COD", "SÓCIO_MAT");

COMMENT ON TABLE SBDB."SÓCIO_CONVÊNIO" IS 'SÓCIO | Cadastro dos convênios dos associados. | Convênio do Sócio';

COMMENT ON COLUMN SBDB."SÓCIO_CONVÊNIO"."CONVÊNIO_COD" IS 'Identificador do convênio. | Convênio';
COMMENT ON COLUMN SBDB."SÓCIO_CONVÊNIO"."SÓCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."SÓCIO_CONVÊNIO"."DATA" IS 'Data. | Data';
COMMENT ON COLUMN SBDB."SÓCIO_CONVÊNIO"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."SÓCIO_CONVÊNIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SÓCIO_CONVÊNIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SÓCIO_CONVÊNIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SÓCIO_CONVÊNIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SÓCIO_CONVÊNIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SÓCIO_CONVÊNIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SÓCIO_CONVÊNIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SÓCIO_ISENÇÃO
CREATE TABLE SBDB."SÓCIO_ISENÇÃO" (
   "SÓCIO_MAT" NUMBER (5,0),
   "SEQ" NUMBER (5,0),
   "TIPO" VARCHAR2 (50),
   "DATA_INI" DATE,
   "DATA_FIM" DATE,
   "OBS" VARCHAR2 (3000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SÓCIO_ISENÇÃO" ADD CONSTRAINT "ID_SÓCIO_ISENÇÃO"
PRIMARY KEY("SÓCIO_MAT", "SEQ");

COMMENT ON TABLE SBDB."SÓCIO_ISENÇÃO" IS 'CADASTRO | Cadastro das isenções dos associados. | Isenção do Sócio';

COMMENT ON COLUMN SBDB."SÓCIO_ISENÇÃO"."SÓCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."SÓCIO_ISENÇÃO"."SEQ" IS 'Sequencial. | Sequencial';
COMMENT ON COLUMN SBDB."SÓCIO_ISENÇÃO"."TIPO" IS 'Tipo. | Tipo de Isenção';
COMMENT ON COLUMN SBDB."SÓCIO_ISENÇÃO"."DATA_INI" IS 'Data de Início. | Data de Início';
COMMENT ON COLUMN SBDB."SÓCIO_ISENÇÃO"."DATA_FIM" IS 'Data de término. | Data de Término';
COMMENT ON COLUMN SBDB."SÓCIO_ISENÇÃO"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."SÓCIO_ISENÇÃO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SÓCIO_ISENÇÃO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SÓCIO_ISENÇÃO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SÓCIO_ISENÇÃO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SÓCIO_ISENÇÃO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SÓCIO_ISENÇÃO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SÓCIO_ISENÇÃO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SÓCIO_SUB_ESPECIALIDADE
CREATE TABLE SBDB."SÓCIO_SUB_ESPECIALIDADE" (
   "SUB_ESPECIAL_COD" VARCHAR2 (50),
   "SÓCIO_MAT" NUMBER (5,0),
   "DATA" DATE,
   "OBS" VARCHAR2 (3000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SÓCIO_SUB_ESPECIALIDADE" ADD CONSTRAINT "ID_SÓCIO_SUB_ESPECIALIDADE"
PRIMARY KEY("SUB_ESPECIAL_COD", "SÓCIO_MAT");

COMMENT ON TABLE SBDB."SÓCIO_SUB_ESPECIALIDADE" IS 'SÓCIO | Cadastro de subespecialidades dos associados. | Sub Especialidade do Sócio';

COMMENT ON COLUMN SBDB."SÓCIO_SUB_ESPECIALIDADE"."SUB_ESPECIAL_COD" IS 'Identificador da subespecialidade. | Subespecialidade';
COMMENT ON COLUMN SBDB."SÓCIO_SUB_ESPECIALIDADE"."SÓCIO_MAT" IS 'Matrícula do associado. | Matrícula do Associado';
COMMENT ON COLUMN SBDB."SÓCIO_SUB_ESPECIALIDADE"."DATA" IS 'Data. | Data';
COMMENT ON COLUMN SBDB."SÓCIO_SUB_ESPECIALIDADE"."OBS" IS 'Observação. | Observação';
COMMENT ON COLUMN SBDB."SÓCIO_SUB_ESPECIALIDADE".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SÓCIO_SUB_ESPECIALIDADE".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SÓCIO_SUB_ESPECIALIDADE".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SÓCIO_SUB_ESPECIALIDADE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SÓCIO_SUB_ESPECIALIDADE".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SÓCIO_SUB_ESPECIALIDADE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SÓCIO_SUB_ESPECIALIDADE".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SUB_ESPECIALIDADE
CREATE TABLE SBDB."SUB_ESPECIALIDADE" (
   "COD" VARCHAR2 (50),
   "DESCRIÇÃO" VARCHAR2 (100)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SUB_ESPECIALIDADE" ADD CONSTRAINT "ID_SUB_ESPECIALIDADE"
PRIMARY KEY("COD");

COMMENT ON TABLE SBDB."SUB_ESPECIALIDADE" IS 'CADASTRO | Cadastro de subespecialidades. | Sub Especialidade';

COMMENT ON COLUMN SBDB."SUB_ESPECIALIDADE"."COD" IS 'Identificado. | Subespecialidade';
COMMENT ON COLUMN SBDB."SUB_ESPECIALIDADE"."DESCRIÇÃO" IS 'Descrição. | Descrição';
COMMENT ON COLUMN SBDB."SUB_ESPECIALIDADE".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SUB_ESPECIALIDADE".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SUB_ESPECIALIDADE".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SUB_ESPECIALIDADE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SUB_ESPECIALIDADE".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SUB_ESPECIALIDADE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SUB_ESPECIALIDADE".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SYS_CONFIG_GLOBAL
CREATE TABLE SBDB."SYS_CONFIG_GLOBAL" (
   "PARAM" VARCHAR2 (200),
   "DESCR" VARCHAR2 (4000),
   "CONFIG" CLOB,
   "PROP_EXTEND" CLOB,
   "FORMATO" VARCHAR2 (100)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SYS_CONFIG_GLOBAL" ADD CONSTRAINT "ID_SYS_CONFIG_GLOBAL"
PRIMARY KEY("PARAM");

COMMENT ON TABLE SBDB."SYS_CONFIG_GLOBAL" IS 'Sistema | Armazena parâmetros globais do aplicativo. | Configuração Global';

COMMENT ON COLUMN SBDB."SYS_CONFIG_GLOBAL"."PARAM" IS 'Parametro. | Parâmetro';
COMMENT ON COLUMN SBDB."SYS_CONFIG_GLOBAL"."DESCR" IS 'Descrição. | Descrição';
COMMENT ON COLUMN SBDB."SYS_CONFIG_GLOBAL"."CONFIG" IS 'Configuração. | Configuração';
COMMENT ON COLUMN SBDB."SYS_CONFIG_GLOBAL"."PROP_EXTEND" IS 'Propriedades extendidas para configuração. | Propriedades';
COMMENT ON COLUMN SBDB."SYS_CONFIG_GLOBAL"."FORMATO" IS 'Formato de apresentação do campo MEMO, HTML ou vazio para texto comum. | Formato';
COMMENT ON COLUMN SBDB."SYS_CONFIG_GLOBAL".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SYS_CONFIG_GLOBAL".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SYS_CONFIG_GLOBAL".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SYS_CONFIG_GLOBAL".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SYS_CONFIG_GLOBAL".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SYS_CONFIG_GLOBAL".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SYS_CONFIG_GLOBAL".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SYS_CONFIG_USUARIO
CREATE TABLE SBDB."SYS_CONFIG_USUARIO" (
   "USUARIO" VARCHAR2 (100),
   "PARAM" VARCHAR2 (200),
   "DESCR" VARCHAR2 (4000),
   "CONFIG" VARCHAR2 (4000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SYS_CONFIG_USUARIO" ADD CONSTRAINT "ID_SYS_CONFIG_USUARIO"
PRIMARY KEY("USUARIO", "PARAM");

COMMENT ON TABLE SBDB."SYS_CONFIG_USUARIO" IS 'Sistema | Parâmetros específicos de usuários do sistema. | Configuração de Usuário';

COMMENT ON COLUMN SBDB."SYS_CONFIG_USUARIO"."USUARIO" IS 'Usuário. | Usuário';
COMMENT ON COLUMN SBDB."SYS_CONFIG_USUARIO"."PARAM" IS 'Parametro. | Parâmetro';
COMMENT ON COLUMN SBDB."SYS_CONFIG_USUARIO"."DESCR" IS 'Descrição. | Descrição';
COMMENT ON COLUMN SBDB."SYS_CONFIG_USUARIO"."CONFIG" IS 'Configuração. | Configuração';
COMMENT ON COLUMN SBDB."SYS_CONFIG_USUARIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SYS_CONFIG_USUARIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SYS_CONFIG_USUARIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SYS_CONFIG_USUARIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SYS_CONFIG_USUARIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SYS_CONFIG_USUARIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SYS_CONFIG_USUARIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SYS_DELETE
CREATE TABLE SBDB."SYS_DELETE" (
   "TABELA" VARCHAR2 (70),
   "CHAVE" VARCHAR2 (300),
   "MOMENTO" DATE,
   "USUARIO" VARCHAR2 (100),
   "LOCAL" VARCHAR2 (20)
);

ALTER TABLE SBDB."SYS_DELETE" ADD CONSTRAINT "ID_SYS_DELETE"
PRIMARY KEY("TABELA", "CHAVE");

COMMENT ON TABLE SBDB."SYS_DELETE" IS 'Sistema | Registro de exclusões do sistema. | Registro de Exclusões';

COMMENT ON COLUMN SBDB."SYS_DELETE"."TABELA" IS 'Nome da tabela onde a exclusão ocorreu. | Tabela';
COMMENT ON COLUMN SBDB."SYS_DELETE"."CHAVE" IS 'Conteúdo da chave do registro excluído. | Chave';
COMMENT ON COLUMN SBDB."SYS_DELETE"."MOMENTO" IS 'Momento em que ocorreu a exclusão. | Momento de Exclusão';
COMMENT ON COLUMN SBDB."SYS_DELETE"."USUARIO" IS 'Detalhes do usuário que efetuou a exclusão. | Usuário';
COMMENT ON COLUMN SBDB."SYS_DELETE"."LOCAL" IS 'De onde partiu a exclusão. | Local';

-- TABELA SYS_LOCALID
CREATE TABLE SBDB."SYS_LOCALID" (
   "NOME" VARCHAR2 (20),
   "CORRENTE" NUMBER (1,0),
   "PACOTE" NUMBER (11,0),
   "PACOTE_REC" NUMBER (11,0),
   "MOMENTO" DATE,
   "MOMENTO_REC" DATE,
   "MODELO" NUMBER (11,0),
   "DESCR" VARCHAR2 (50),
   "OBS" VARCHAR2 (4000)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SYS_LOCALID" ADD CONSTRAINT "ID_SYS_LOCALID"
PRIMARY KEY("NOME");

COMMENT ON TABLE SBDB."SYS_LOCALID" IS 'Sistema | Especificações de localidade para sistema distribuído. | Detalhes de Localidade';

COMMENT ON COLUMN SBDB."SYS_LOCALID"."NOME" IS 'Nome em caso de sistema distribuído. | Nome';
COMMENT ON COLUMN SBDB."SYS_LOCALID"."CORRENTE" IS 'Marcado caso seja localidade corrente. | Corrente';
COMMENT ON COLUMN SBDB."SYS_LOCALID"."PACOTE" IS 'Número do último pacote gerado. | Pacote Gerado';
COMMENT ON COLUMN SBDB."SYS_LOCALID"."PACOTE_REC" IS 'Número do último pacote recebido. | Pacote Recebido';
COMMENT ON COLUMN SBDB."SYS_LOCALID"."MOMENTO" IS 'Momento do último pacote gerado. | Momento de Geração';
COMMENT ON COLUMN SBDB."SYS_LOCALID"."MOMENTO_REC" IS 'Momento do último pacote recebido. | Momento de Recebimento';
COMMENT ON COLUMN SBDB."SYS_LOCALID"."MODELO" IS 'Modelo. | Modelo';
COMMENT ON COLUMN SBDB."SYS_LOCALID"."DESCR" IS 'Descrição de localidade, responsabilidade ou qualquer texto que informe sobre a localidade. | Descrição';
COMMENT ON COLUMN SBDB."SYS_LOCALID"."OBS" IS 'Observações sobre a localidade. | Observações';
COMMENT ON COLUMN SBDB."SYS_LOCALID".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SYS_LOCALID".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SYS_LOCALID".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SYS_LOCALID".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SYS_LOCALID".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SYS_LOCALID".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SYS_LOCALID".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SYS_OCORRENCIA
CREATE TABLE SBDB."SYS_OCORRENCIA" (
   "SEQ" NUMBER (11,0),
   "APLICACAO" VARCHAR2 (4000),
   "OCORRENCIA" VARCHAR2 (4000),
   "USUARIO" VARCHAR2 (100),
   "MOMENTO" DATE,
   "LOCAL" VARCHAR2 (20)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."SYS_OCORRENCIA" ADD CONSTRAINT "ID_SYS_OCORRENCIA"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SBDB."SYS_OCORRENCIA" IS 'Sistema | Registro de ocorrências do sistema. | Registro de Ocorrências';

COMMENT ON COLUMN SBDB."SYS_OCORRENCIA"."SEQ" IS 'Sequencial da ocorrência. | Sequencial';
COMMENT ON COLUMN SBDB."SYS_OCORRENCIA"."APLICACAO" IS 'Nome do aplicativo onde ocorreu o registro. | Aplicação';
COMMENT ON COLUMN SBDB."SYS_OCORRENCIA"."OCORRENCIA" IS 'Detalhes da ocorrência. | Ocorrência';
COMMENT ON COLUMN SBDB."SYS_OCORRENCIA"."USUARIO" IS 'Usuário logado no momento da ocorrência. | Usuário';
COMMENT ON COLUMN SBDB."SYS_OCORRENCIA"."MOMENTO" IS 'Momento em que ocorreu a situação. | Momento';
COMMENT ON COLUMN SBDB."SYS_OCORRENCIA"."LOCAL" IS 'Local onde ocorreu o registro. | Localidade';
COMMENT ON COLUMN SBDB."SYS_OCORRENCIA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."SYS_OCORRENCIA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."SYS_OCORRENCIA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."SYS_OCORRENCIA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."SYS_OCORRENCIA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."SYS_OCORRENCIA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."SYS_OCORRENCIA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA USUARIO
CREATE TABLE SBDB."USUARIO" (
   "USUÁRIO" VARCHAR2 (20),
   "NOME" VARCHAR2 (50),
   "SUPERVISOR" VARCHAR2 (20),
   "DEPTO" VARCHAR2 (50),
   "MSG" VARCHAR2 (3000),
   "ASSINATURA" CLOB,
   "TEMPO_ATUALIZA" NUMBER (5,0),
   "FUNÇÃO" VARCHAR2 (30),
   "ASSINATURA_BMP" CLOB,
   "ACESSO" VARCHAR2 (3000),
   "EMAIL" VARCHAR2 (200),
   "EMAIL_LOGIN" VARCHAR2 (200),
   "EMAIL_SENHA" VARCHAR2 (20)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SBDB."USUARIO" ADD CONSTRAINT "ID_USUARIO"
PRIMARY KEY("USUÁRIO");

COMMENT ON TABLE SBDB."USUARIO" IS 'SYS | Cadastro de usuário do sistema. | Usuário';

COMMENT ON COLUMN SBDB."USUARIO"."USUÁRIO" IS 'Login do usuário. | Usuário';
COMMENT ON COLUMN SBDB."USUARIO"."NOME" IS 'Nome do usuário. | Nome';
COMMENT ON COLUMN SBDB."USUARIO"."SUPERVISOR" IS 'Nome do supervisor. | Supervisor';
COMMENT ON COLUMN SBDB."USUARIO"."DEPTO" IS 'Nome do departamento. | Departamento';
COMMENT ON COLUMN SBDB."USUARIO"."MSG" IS 'Mensagem. | Mensagem';
COMMENT ON COLUMN SBDB."USUARIO"."ASSINATURA" IS 'Assinatura do usuário. | Assinatura';
COMMENT ON COLUMN SBDB."USUARIO"."TEMPO_ATUALIZA" IS 'Tempo de atualização. | Tempo de Atualização';
COMMENT ON COLUMN SBDB."USUARIO"."FUNÇÃO" IS 'Função do usuário. | Função';
COMMENT ON COLUMN SBDB."USUARIO"."ASSINATURA_BMP" IS 'Imagem da assinatura. | Imagem da Assinatura';
COMMENT ON COLUMN SBDB."USUARIO"."ACESSO" IS 'Direito de acesso. | Direito de Acesso';
COMMENT ON COLUMN SBDB."USUARIO"."EMAIL" IS 'E-mail do usuário. | E-mail';
COMMENT ON COLUMN SBDB."USUARIO"."EMAIL_LOGIN" IS 'E-mail para login. | E-mail para Login';
COMMENT ON COLUMN SBDB."USUARIO"."EMAIL_SENHA" IS 'Senha para login. | Senha para Login';
COMMENT ON COLUMN SBDB."USUARIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SBDB."USUARIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SBDB."USUARIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SBDB."USUARIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SBDB."USUARIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SBDB."USUARIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SBDB."USUARIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

/* **********************************************************************************
   CRIAÇÃO DE TABELAS DO SISTEMA
*/


-- TABELA DE SISTEMA - GRANTS GERAIS
GRANT SELECT ON SBDB.SYS_CONFIG_GLOBAL TO PUBLIC;
GRANT SELECT ON SBDB.SYS_CONFIG_USUARIO TO PUBLIC;
GRANT SELECT ON SBDB.SYS_DELETE TO PUBLIC;
GRANT SELECT ON SBDB.SYS_LOCALID TO PUBLIC;
GRANT SELECT ON SBDB.SYS_OCORRENCIA TO PUBLIC;
SPOOL OFF


-- EXEMPLO PARA IMPORT DE INFORMAÇÕES E 
-- CÓDIGO PARA ELIMINAR OBJETOS IMPORTADOS EQUIVOCADAMENTE

SET SERVEROUTPUT ON SIZE 40000
SET ECHO OFF
SELECT
'EXP SBDB/XXXX@SBDB OWNER=(SBDB) FILE=SBDB.DMP LOG=SBDB_EXP.LOG' || CHR(13) || CHR(10) ||
'IMP SBDB/XXXX@SBDB FROMUSER=SBDB CONSTRAINTS=NO GRANTS=NO FILE=SBDB.DMP LOG=SBDB_IMP.LOG IGNORE=YES' || CHR(13) || CHR(10) ||
'' || CHR(13) || CHR(10) ||
'' || CHR(13) || CHR(10) ||
'DECLARE' || CHR(13) || CHR(10) ||
'    MAX NUMBER := ' || MAX(OBJECT_ID) || ';' || CHR(13) || CHR(10) ||
'BEGIN' || CHR(13) || CHR(10) ||
' FOR CUR IN (SELECT ''DROP '' || OBJECT_TYPE || '' '' || OWNER || ''.'' || OBJECT_NAME ' || CHR(13) || CHR(10) ||
' AS COL FROM ALL_OBJECTS WHERE OBJECT_ID > MAX) LOOP' || CHR(13) || CHR(10) ||
'  DBMS_OUTPUT.PUT(CUR.COL);' || CHR(13) || CHR(10) ||
'  BEGIN' || CHR(13) || CHR(10) ||
'   EXECUTE IMMEDIATE CUR.COL;' || CHR(13) || CHR(10) ||
'   DBMS_OUTPUT.PUT_LINE('' ==> OK'');' || CHR(13) || CHR(10) ||
'  EXCEPTION WHEN OTHERS THEN' || CHR(13) || CHR(10) ||
'   DBMS_OUTPUT.PUT_LINE('' ==> '' || SQLERRM);' || CHR(13) || CHR(10) ||
'  END;' || CHR(13) || CHR(10) ||
' END LOOP;' || CHR(13) || CHR(10) ||
'END;' || CHR(13) || CHR(10) ||
'/' || CHR(13) || CHR(10) ||
'' || CHR(13) || CHR(10) ||
'' || CHR(13) || CHR(10) FROM ALL_OBJECTS
/



SPOOL OFF
$ECHO - >>"C:\SBDB_PARTES.LOG"
$ECHO - >>"C:\SBDB_PARTES.LOG"
$ECHO - >>"C:\SBDB_PARTES.LOG"
$COMMAND /C ECHO %DATE% %TIME% >>"C:\SBDB_PARTES.LOG"
$COMMAND /C FIND "ORA-" "C:\SBDB_PARTE1.LOG" >>"C:\SBDB_PARTES.LOG"
$COMMAND /C FIND "SP2-" "C:\SBDB_PARTE1.LOG" >>"C:\SBDB_PARTES.LOG"
