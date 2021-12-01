-------------------------------------------------------------------------------------
-- CRIAÇÃO DE SCRIPT PARA GERAR ESTRUTURA DE TRANSFERÊNCIA TKRJ
-------------------------------------------------------------------------------------
ALTER TABLESPACE TRANSF OFFLINE;
DROP TABLESPACE TRANSF INCLUDING CONTENTS;

CREATE TABLESPACE TRANSF DATAFILE 'D:\ORACLE\ORADATA\TKRJ\TRANSF.DBF' SIZE 20M REUSE
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL;

CREATE TABLE TKRJ.LOTE_T (
             REF NUMBER,
             NOME VARCHAR2 (50),
             PROCESSO VARCHAR2 (100),
             CLI1_NOME VARCHAR2 (50),
             CLI1_DESTINO VARCHAR2 (100),
             CLI2_NOME VARCHAR2 (50),
             CLI2_DESTINO VARCHAR2 (100),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE TRANSF NOLOGGING;

CREATE TABLE TKRJ.LOTE_GRUPO_T (
             LOTE_REF NUMBER,
             SEQ NUMBER,
             QUALITY VARCHAR2 (20),
             PRODUCT VARCHAR2 (20),
             THICKNESS NUMBER,
             WIDTH NUMBER,
             LENGTH NUMBER,
             FINISH VARCHAR2 (20),
             COATING VARCHAR2 (20),
             TEMPER VARCHAR2 (20),
             VOLUME NUMBER (10,0),
             NET NUMBER,
             GROSS NUMBER,
             CLI1_PRIOR NUMBER (3,0),
             CLI2_PRIOR NUMBER (3,0),
             DIFER_PRIOR NUMBER (3,0),
             PORTO_CLI1 NUMBER,
             PORTO_CLI2 NUMBER,
             FINAL_PORTO1 NUMBER,
             FINAL_PORTO2 NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE TRANSF NOLOGGING;

CREATE TABLE TKRJ.LOTE_ITEM_T (
             LOTE_REF NUMBER,
             SEQ NUMBER,
             VOLUME VARCHAR2 (50),
             TAG VARCHAR2 (20),
             QUALITY VARCHAR2 (20),
             PRODUCT VARCHAR2 (20),
             THICKNESS NUMBER,
             WIDTH NUMBER,
             LENGTH NUMBER,
             FINISH VARCHAR2 (20),
             COATING VARCHAR2 (20),
             SPECIFICATION VARCHAR2 (100),
             TEMPER VARCHAR2 (20),
             PACKING VARCHAR2 (20),
             NET NUMBER,
             GROSS NUMBER,
             CLIENTE VARCHAR2 (100),
             BL_CODE VARCHAR2 (20),
             DESTINO VARCHAR2 (50),
             OVITEM VARCHAR2 (20),
             PO VARCHAR2 (20),
             LOTE VARCHAR2 (20),
             PED_REF VARCHAR2 (20),
             PED_ITEM NUMBER (5,0),
             EMB_REF VARCHAR2 (20),
             PORTO_DEST VARCHAR2 (50),
             REMARK VARCHAR2 (3000),
             C NUMBER,
             MN NUMBER,
             P NUMBER,
             S NUMBER,
             SI NUMBER,
             CU NUMBER,
             NI NUMBER,
             CR NUMBER,
             MO NUMBER,
             SN NUMBER,
             AL NUMBER,
             N NUMBER,
             NB NUMBER,
             V NUMBER,
             TI NUMBER,
             O NUMBER,
             B NUMBER,
             C_EQ NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE TRANSF NOLOGGING;

CREATE TABLE TKRJ.PACKING_LIST_T (
             SEQ NUMBER,
             EMPRESA_COD VARCHAR2 (255),
             EMPRESA_NOME VARCHAR2 (255),
             TÍTULO VARCHAR2 (100),
             REFERÊNCIA VARCHAR2 (255),
             DATA VARCHAR2 (50),
             TRANSPORTADOR VARCHAR2 (255),
             COMPRADOR_NOME VARCHAR2 (255),
             COMPRADOR_ENDEREÇO VARCHAR2 (255),
             ORIGEM VARCHAR2 (255),
             DESTINO VARCHAR2 (255),
             NOTAS VARCHAR2 (4000),
             EMPRESA_CONTATO VARCHAR2 (50),
             EMPRESA_ENDEREÇO VARCHAR2 (255),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE TRANSF NOLOGGING;

CREATE TABLE TKRJ.PACKING_LIST_FAM_T (
             DOC_SEQ NUMBER,
             SEQ NUMBER,
             FAMÍLIA VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE TRANSF NOLOGGING;

CREATE TABLE TKRJ.PACKING_LIST_FAM_LOTE_T (
             DOC_SEQ NUMBER,
             DOC_FAMÍLIA_SEQ NUMBER,
             SEQ NUMBER,
             LOTE NUMBER,
             BL_CODE VARCHAR2 (20),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE TRANSF NOLOGGING;

CREATE TABLE TKRJ.PADRONIZAÇÃO_T (
             SEQ NUMBER,
             REF VARCHAR2 (20),
             COD_FOR VARCHAR2 (100),
             COD_COM VARCHAR2 (100),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE TRANSF NOLOGGING;

CREATE TABLE TKRJ.PRODUTO_T (
             COD VARCHAR2 (20),
             DESCRIÇÃO VARCHAR2 (100),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE TRANSF NOLOGGING;

CREATE TABLE TKRJ.PRODUTO_ESPECIF_T (
             PRODUTO_COD VARCHAR2 (20),
             SEQ NUMBER,
             ESPESSURA_MIN NUMBER,
             ESPESSURA_MAX NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE TRANSF NOLOGGING;

CREATE TABLE TKRJ.SYS_DELETE_T (
             NOME_TABELA VARCHAR2 (50),
             CHAVE VARCHAR2 (150),
             MOMENTO DATE,
             USUÁRIO VARCHAR2 (20),
             LOCAL VARCHAR2 (20)
             ) TABLESPACE TRANSF NOLOGGING;


