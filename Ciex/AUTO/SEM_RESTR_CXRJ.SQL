-------------------------------------------------------------------------------------
-- CRIAÇÃO DE SCRIPT PARA GERAR ESTRUTURA BÁSICA SEM RESTRIÇÕES CXRJ
-------------------------------------------------------------------------------------
ALTER TABLESPACE T_CXRJ_DAT OFFLINE;
DROP TABLESPACE T_CXRJ_DAT INCLUDING CONTENTS;

CREATE TABLESPACE T_CXRJ_DAT DATAFILE 'D:\ORACLE\ORADATA\CXRJ\CIEX.DBF' SIZE 100M REUSE
AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL;

CREATE TABLE CXRJ.BL (
             VIAGEM_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             BL_NUM VARCHAR2 (30),
             BL_DATA DATE,
             EMB_REF VARCHAR2 (13),
             MSG VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.BL_CARGA (
             PED_REF VARCHAR2 (13),
             PED_ITEM NUMBER (5,0),
             VIAGEM_REF VARCHAR2 (13),
             BL_SEQ NUMBER (5,0),
             FECH_REF VARCHAR2 (13),
             QTD_PED_UNID NUMBER,
             QTD_VOL NUMBER (10,0),
             PESO_LÍQUIDO NUMBER,
             PESO_BRUTO NUMBER,
             EMB_DATA DATE,
             EMB_REF VARCHAR2 (13),
             EMB_SEQ NUMBER,
             FAMÍLIA_GENÉRICA NUMBER (5,0),
             FAMÍLIA NUMBER (5,0),
             DESCR          VARCHAR2 (255),
             EMBALAGEM VARCHAR2 (30),
             NCM VARCHAR2 (20),
             NALADI VARCHAR2 (20),
             EXP_PREÇO_UNIT NUMBER,
             IMP_PREÇO_UNIT NUMBER,
             CALC_EXP_EMB NUMBER,
             CALC_EXP_FOB NUMBER,
             CALC_IMP_EMB NUMBER,
             CALC_IMP_FOB NUMBER,
             NOMINAL_PED_UNID NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.BL_CONTINENTAL (
             REF VARCHAR2 (13),
             BL_NÚMERO VARCHAR2 (30),
             EMBARCAD_NOME VARCHAR2 (70),
             EMBARCAD_END VARCHAR2 (255),
             CONSIGN_NOME VARCHAR2 (70),
             CONSIGN_END VARCHAR2 (255),
             AGENTE_NOME VARCHAR2 (70),
             AGENTE_END VARCHAR2 (255),
             PAÍS_ORIGEM VARCHAR2 (30),
             NOTIFIC_NOME VARCHAR2 (70),
             NOTIFIC_END VARCHAR2 (255),
             NOTIFIC_DET VARCHAR2 (255),
             CARREGADO_POR VARCHAR2 (30),
             RECEB_LOCAL VARCHAR2 (30),
             PIER_TERMINAL VARCHAR2 (30),
             NAVIO VARCHAR2 (30),
             PORTO_CARGA VARCHAR2 (30),
             TERMINAL_CARGA VARCHAR2 (30),
             PORTO_DESCARGA VARCHAR2 (30),
             ENTREGA_LOCAL VARCHAR2 (30),
             TRANSPORTE VARCHAR2 (30),
             FRETE_PAG_LOCAL VARCHAR2 (30),
             CAB VARCHAR2 (1000),
             MARCAS VARCHAR2 (70),
             EMBALAG VARCHAR2 (30),
             PRODUTO_CAB VARCHAR2 (255),
             PRODUTO VARCHAR2 (255),
             PESO_BRUTO VARCHAR2 (30),
             MEDIDAS VARCHAR2 (30),
             RODAPÉ VARCHAR2 (1000),
             FRETE_MARCAS VARCHAR2 (255),
             VALOR_PAG VARCHAR2 (30),
             VALOR_COLETA VARCHAR2 (30),
             MOEDA_LOCAL VARCHAR2 (30),
             TOTAL_VALOR_PAG VARCHAR2 (30),
             TOTAL_VALOR_COLETA VARCHAR2 (30),
             TOTAL_MOEDA_LOCAL_1 VARCHAR2 (30),
             TOTAL_MOEDA_LOCAL_2 VARCHAR2 (30),
             ORIGINAIS VARCHAR2 (30),
             ASS VARCHAR2 (50),
             DATA_ASS VARCHAR2 (50),
             NAVIO_NACIONALIDADE VARCHAR2 (50),
             CAPITÃO_NOME VARCHAR2 (50),
             EMB_DATA VARCHAR2 (50),
             PERSONAGENS VARCHAR2 (500),
             NAVIO_MAN VARCHAR2 (30),
             PORTO_CARGA_MAN VARCHAR2 (30),
             PORTO_DESCARGA_MAN VARCHAR2 (30),
             ENTREGA_LOCAL_MAN VARCHAR2 (30),
             CAB_MAN VARCHAR2 (1000),
             MARCAS_MAN VARCHAR2 (70),
             EMBALAG_MAN VARCHAR2 (30),
             PRODUTO_CAB_MAN VARCHAR2 (255),
             PRODUTO_MAN VARCHAR2 (255),
             PESO_BRUTO_MAN VARCHAR2 (30),
             MEDIDAS_MAN VARCHAR2 (30),
             RODAPÉ_MAN VARCHAR2 (1000),
             FRETE_MARCAS_MAN VARCHAR2 (200),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.CARTA (
             REF VARCHAR2 (13),
             EMPRESA VARCHAR2 (30),
             IDIOMA VARCHAR2 (3),
             DOC_DATA DATE,
             CIA VARCHAR2 (30),
             CONTATO VARCHAR2 (50),
             CIA_SUB VARCHAR2 (30),
             CONTATO_SUB VARCHAR2 (50),
             ASSUNTO VARCHAR2 (3000),
             TEXTO VARCHAR2 (4000),
             EMISSÃO_DATA DATE,
             COM_CÓPIA VARCHAR2 (3000),
             USUÁRIO VARCHAR2 (20),
             SUPERVISOR VARCHAR2 (20),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.CARTA_CRÉDITO (
             REF VARCHAR2 (13),
             REF_LC VARCHAR2 (50),
             DATA_EMISS DATE,
             MOEDA VARCHAR2 (20),
             VALOR NUMBER,
             PESO NUMBER,
             BCO_EMISSOR VARCHAR2 (50),
             BCO_NEGOCIADOR VARCHAR2 (50),
             BCO_AVISADOR VARCHAR2 (50),
             BCO_CONFIRMADOR VARCHAR2 (50),
             BCO_RECEBEDOR VARCHAR2 (50),
             VALIDADE_LC DATE,
             VALIDADE_EMB DATE,
             FORM_PAGAMENTO VARCHAR2 (100),
             TOLER_QTD VARCHAR2 (100),
             TOLER_VALOR VARCHAR2 (100),
             APRESENT_DOC VARCHAR2 (100),
             UNID_PESO VARCHAR2 (10),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.CARTA_FECH (
             CARTA_REF VARCHAR2 (13),
             FECH_REF VARCHAR2 (13),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.CIA (
             LOGO BLOB,
             LOGOTIPO BLOB,
             COD VARCHAR2 (30),
             CGC VARCHAR2 (18),
             NOME VARCHAR2 (255),
             ENDEREÇO VARCHAR2 (255),
             BAIRRO VARCHAR2 (60),
             CIDADE VARCHAR2 (60),
             ESTADO VARCHAR2 (30),
             PAÍS VARCHAR2 (30),
             CEP VARCHAR2 (15),
             CAIXA_POSTAL VARCHAR2 (30),
             TELEFONE VARCHAR2 (255),
             FAX VARCHAR2 (255),
             TELEX VARCHAR2 (200),
             E_MAIL VARCHAR2 (60),
             F_COD VARCHAR2 (30),
             MARCAÇÃO VARCHAR2 (3000),
             OBS VARCHAR2 (3000),
             LOCAL_RESULT VARCHAR2 (8),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.CIA_CONTATO (
             CIA_COD VARCHAR2 (30),
             CONTATO_NOME VARCHAR2 (50),
             TELEFONE VARCHAR2 (3000),
             FUNÇÃO VARCHAR2 (30),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.CIA_RAMO_ATIVIDADE (
             CIA_COD VARCHAR2 (30),
             RAMO_ATIVIDADE VARCHAR2 (20),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.COND_PAG (
             COD VARCHAR2 (10),
             DESCR VARCHAR2 (3000),
             PERÍODO NUMBER (5,0),
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.CONFIRM_VENDA (
             REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             EMISSÃO_DATA DATE,
             EMISSOR VARCHAR2 (3000),
             PED_REF VARCHAR2 (13),
             OUTRA_REF VARCHAR2 (3000),
             COMPRADOR VARCHAR2 (30),
             USUÁRIO_FINAL VARCHAR2 (30),
             DESTINATÁRIO VARCHAR2 (3000),
             ENTREGA VARCHAR2 (30),
             CARGA_PORTO VARCHAR2 (30),
             IDIOMA VARCHAR2 (3),
             DIMENSÃO VARCHAR2 (5),
             PREÇO_DETALHE VARCHAR2 (3000),
             ESPECIFICAÇÃO VARCHAR2 (3000),
             EMBALAGEM VARCHAR2 (3000),
             SEGURO VARCHAR2 (3000),
             PAG VARCHAR2 (3000),
             OBS VARCHAR2 (4000),
             OBS_TERMOS VARCHAR2 (3000),
             PRODUTOR VARCHAR2 (30),
             DESCARGA_PORTO VARCHAR2 (30),
             ASSINATURA VARCHAR2 (50),
             DT_REVISÃO VARCHAR2 (30),
             EMPRESA_REL VARCHAR2(100),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.CONFIRM_VENDA_ITEM (
             CONFIRM_VENDA_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             ITEM NUMBER (5,0),
             DESCR VARCHAR2 (3000),
             DIMENSÃO VARCHAR2 (3000),
             QTD NUMBER,
             UNID VARCHAR2 (10),
             PREÇO NUMBER,
             MOEDA VARCHAR2 (10),
             QUALIDADE VARCHAR2 (15),
             PREÇO_C NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.CONTA_CORRENTE (
             COD VARCHAR2 (30),
             CONTA_CORRENTE VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.COSIPA_FOLHA_1 (
             APLAIN_OBS2 VARCHAR2 (37),
             DIAM_INT1 VARCHAR2 (30),
             APLAIN_PERC1 VARCHAR2 (10),
             APLAIN_PERC2 VARCHAR2 (10),
             APLAIN_PERC3 VARCHAR2 (10),
             ITEM_EXT_1 VARCHAR2 (15),
             LARGURA2 VARCHAR2 (50),
             ITEM_INT_2 VARCHAR2 (15),
             ITEM_INT_1 VARCHAR2 (15),
             DIAM_EXT2 VARCHAR2 (30),
             DIAM_EXT1 VARCHAR2 (30),
             ITEM_EXT_2 VARCHAR2 (15),
             DIAM_INT2 VARCHAR2 (30),
             ESPESS_OBS1 VARCHAR2 (37),
             LARGURA1 VARCHAR2 (50),
             COMPRIMENTO2 VARCHAR2 (45),
             COMPRIMENTO1 VARCHAR2 (45),
             ESPESS_OBS2 VARCHAR2 (37),
             ESPESS_PERC3 VARCHAR2 (10),
             ESPESS_PERC2 VARCHAR2 (10),
             ESPESS_PERC1 VARCHAR2 (10),
             ESPESS_OBS3 VARCHAR2 (37),
             APLAIN_OBS3 VARCHAR2 (37),
             APLAIN_OBS1 VARCHAR2 (37),
             ORD_REF VARCHAR2 (13),
             ITEM NUMBER (5,0),
             QUANTID VARCHAR2 (50),
             YR_REF VARCHAR2 (50),
             MARCA_EMB_VOL VARCHAR2 (25),
             COR_MARCA VARCHAR2 (50),
             COR_MARCA1 VARCHAR2 (50),
             COR_MARCA2 VARCHAR2 (50),
             COR_MARCA3 VARCHAR2 (50),
             MARGEM FLOAT,
             QUAL_NORMA VARCHAR2 (132),
             QUAL_OBS VARCHAR2 (168),
             SUPERFÍCIE FLOAT,
             TRAT_TERMICO VARCHAR2 (50),
             ULTRA_SOM VARCHAR2 (30),
             RUGOSIDADE VARCHAR2 (20),
             LUBRIFICADO NUMBER (5,0),
             LUBRIFICADO_OBS VARCHAR2 (50),
             APLICAÇÃO VARCHAR2 (100),
             SOLDA VARCHAR2 (50),
             DUREZA VARCHAR2 (50),
             RABO_PEIXE VARCHAR2 (100),
             TELESCOPICIDADE VARCHAR2 (100),
             ESPESS_NOMINAL VARCHAR2 (50),
             OUTRA_TOLER VARCHAR2 (40),
             IMP VARCHAR2 (50),
             OBS VARCHAR2 (255),
             ESPESS_MAX_MIN NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.COSIPA_FOLHA_2 (
             ORD_REF VARCHAR2 (13),
             FOLHA NUMBER (5,0),
             ITEM NUMBER (5,0),
             PED VARCHAR2 (30),
             NEG VARCHAR2 (30),
             LOT VARCHAR2 (30),
             PROD VARCHAR2 (30),
             ESPESSURA VARCHAR2 (30),
             LARGURA VARCHAR2 (30),
             COMPRIMENTO VARCHAR2 (30),
             MT NUMBER (5,0),
             CWT_MIN VARCHAR2 (30),
             CWT_MAX VARCHAR2 (30),
             TOLER_MAX VARCHAR2 (30),
             TOLER_MIN VARCHAR2 (30),
             PREÇO FLOAT,
             OBS VARCHAR2 (3000),
             PECAS NUMBER (5,0),
             ESPESS_MM FLOAT,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.COSIPA_FOLHA_2_PAG (
             ORD_REF VARCHAR2 (13),
             FOLHA NUMBER (5,0),
             UNIDADE NUMBER (5,0),
             MOEDA NUMBER (2,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.COSIPA_NEGOCIAÇÃO (
             REF VARCHAR2 (13),
             REF_EXT VARCHAR2 (3),
             DATA_ORD DATE,
             ALTERA VARCHAR2 (2),
             MÊS_NEG VARCHAR2 (20),
             MÊS_EMB DATE,
             AGENTE VARCHAR2 (50),
             PRODUTO VARCHAR2 (30),
             TON VARCHAR2 (15),
             PAÍS_DESTINO VARCHAR2 (30),
             PORTO_DESTINO VARCHAR2 (30),
             IMP VARCHAR2 (65),
             OUTRO_DOC VARCHAR2 (60),
             PEÇAS NUMBER (5,0),
             TRAT_TÉRMICO NUMBER (5,0),
             TOLER_PROD_LOT_MAX FLOAT,
             TOLER_PROD_LOT_MIN FLOAT,
             COND_PAG VARCHAR2 (30),
             TERMO_ENTREGA VARCHAR2 (30),
             PREÇO VARCHAR2 (30),
             COMISS_AGENTE VARCHAR2 (255),
             OBS_GERAL VARCHAR2 (255),
             INSP_CLASS NUMBER (5,0),
             FATURA_LÂMINA NUMBER (5,0),
             FATURA_OUTRO NUMBER (5,0),
             EXTERNAL_SURVEY_TYPE VARCHAR2 (50),
             EXTERNAL_SURVEYOR VARCHAR2 (50),
             SURVEY_SIGN_CERTIF VARCHAR2 (50),
             CLASS_ORG VARCHAR2 (50),
             END_USER VARCHAR2 (65),
             HRP VARCHAR2 (6),
             HRC VARCHAR2 (6),
             CRC VARCHAR2 (6),
             PREDAYS VARCHAR2 (2),
             POSDAYS VARCHAR2 (15),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DEPTO (
             COD VARCHAR2 (10),
             NOME VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DIVISÃO (
             ESCRITÓRIO VARCHAR2 (2),
             DIVISÃO VARCHAR2 (1),
             DESCR VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DIVISÃO_PRODUTO (
             ESCRITÓRIO VARCHAR2 (2),
             DIVISÃO VARCHAR2 (1),
             PROD VARCHAR2 (30),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DIVISÃO_TIPO_REF (
             ESCRITÓRIO VARCHAR2 (2),
             DIVISÃO VARCHAR2 (1),
             TIPO_REF VARCHAR2 (4),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC (
             COD VARCHAR2 (25),
             NOME VARCHAR2 (3000),
             OBJETO_VINCULADO VARCHAR2 (50),
             FORMULÁRIO_PARAM VARCHAR2 (20),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_ACORDO_COMPLEM (
             DOC NUMBER (10,0),
             DATA DATE,
             ACUMULADO_CR NUMBER,
             ACUMULADO_FL NUMBER,
             ASSINATURA VARCHAR2 (3000),
             ORIGEM_NOME VARCHAR2 (3000),
             ORIGEM_CONTATO VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             IDIOMA VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_ACORDO_COMPLEM_DET (
             DOC_SEQ NUMBER (10,0),
             SEQ_ITEM NUMBER (5,0),
             PAÍS VARCHAR2 (3000),
             CLIENTE VARCHAR2 (3000),
             REF_CIEX VARCHAR2 (3000),
             PRODUTO VARCHAR2 (3000),
             PESO_LÍQUIDO NUMBER,
             DATA DATE,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_ALADI (
             DOC NUMBER (10,0),
             IMP_PAÍS VARCHAR2 (3000),
             REF_CIEX VARCHAR2 (3000),
             DECLARAÇÃO VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             OBS VARCHAR2 (3000),
             UNID_PESO VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             MENSAGEM VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_ALADI_DET (
             DOC_SEQ NUMBER (10,0),
             SEQ_ITEM NUMBER (5,0),
             ORDEM NUMBER (5,0),
             NALADI VARCHAR2 (3000),
             FAMÍLIA VARCHAR2 (3000),
             VOLUME NUMBER (10,0),
             EMBALAGEM VARCHAR2 (3000),
             PESO_LÍQUIDO NUMBER,
             PESO_BRUTO NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_ALADI_NORMA (
             DOC_SEQ NUMBER (10,0),
             SEQ_NORMA NUMBER (5,0),
             NORMA VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_BORDERÔ_I (
             DOC NUMBER (10,0),
             ORIGEM_CIA_COD VARCHAR2 (3000),
             ORIGEM_LOGO_NOME VARCHAR2 (3000),
             ORIGEM_NOME VARCHAR2 (3000),
             ORIGEM_ENDEREÇO VARCHAR2 (3000),
             ORIGEM_PAÍS VARCHAR2 (3000),
             ORIGEM_CONTATO VARCHAR2 (3000),
             ASSINATURA VARCHAR2 (3000),
             DESTINO_CIA_COD VARCHAR2 (3000),
             DESTINO_NOME VARCHAR2 (3000),
             DESTINO_ENDEREÇO VARCHAR2 (3000),
             DESTINO_PAÍS VARCHAR2 (3000),
             DESTINO_CONTATO VARCHAR2 (3000),
             TÍTULO VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             REF_CIEX VARCHAR2 (3000),
             DESTINO_REF VARCHAR2 (3000),
             MOEDA VARCHAR2 (3000),
             VALOR NUMBER,
             SACADO VARCHAR2 (3000),
             SACADO_ENDEREÇO VARCHAR2 (3000),
             SACADO_PAÍS VARCHAR2 (3000),
             COMISSÃO VARCHAR2 (3000),
             INSTRUÇÕES VARCHAR2 (3000),
             DOCUMENTO VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_BORDERÔ_P (
             DOC NUMBER (10,0),
             ORIGEM_CIA_COD VARCHAR2 (3000),
             ORIGEM_LOGO_NOME VARCHAR2 (3000),
             ORIGEM_NOME VARCHAR2 (3000),
             ORIGEM_ENDEREÇO VARCHAR2 (3000),
             ORIGEM_PAÍS VARCHAR2 (3000),
             ORIGEM_CONTATO VARCHAR2 (3000),
             ASSINATURA VARCHAR2 (3000),
             DESTINO_CIA_COD VARCHAR2 (3000),
             DESTINO_NOME VARCHAR2 (3000),
             DESTINO_ENDEREÇO VARCHAR2 (3000),
             DESTINO_PAÍS VARCHAR2 (3000),
             DESTINO_CONTATO VARCHAR2 (3000),
             TÍTULO VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             REF_CIEX VARCHAR2 (3000),
             DESTINO_REF VARCHAR2 (3000),
             MOEDA VARCHAR2 (3000),
             VALOR NUMBER,
             SACADO VARCHAR2 (3000),
             SACADO_ENDEREÇO VARCHAR2 (3000),
             SACADO_PAÍS VARCHAR2 (3000),
             COMISSÃO VARCHAR2 (3000),
             INSTRUÇÕES VARCHAR2 (3000),
             DOCUMENTO VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_CÂMARA_COMÉRCIO (
             DOC NUMBER (10,0),
             COD_EXP VARCHAR2 (3000),
             EXPORTADOR VARCHAR2 (3000),
             EXP_ENDEREÇO VARCHAR2 (3000),
             EXP_PAÍS VARCHAR2 (3000),
             COD_IMP VARCHAR2 (3000),
             IMPORTADOR VARCHAR2 (3000),
             IMP_PAÍS VARCHAR2 (3000),
             REF_CIEX VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             TRANSPORTADOR VARCHAR2 (3000),
             CONSIGNATÁRIO VARCHAR2 (3000),
             UNID_PESO VARCHAR2 (3000),
             MOEDA VARCHAR2 (3000),
             TOTAL_DOC NUMBER,
             MENSAGEM VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_CÂMARA_COMÉRCIO_DET (
             DOC_SEQ NUMBER (10,0),
             SEQ_ITEM NUMBER (5,0),
             NCM VARCHAR2 (3000),
             FAMÍLIA VARCHAR2 (3000),
             VOLUME NUMBER (10,0),
             EMBALAGEM VARCHAR2 (3000),
             PESO_LÍQUIDO NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_CARTA_I (
             DOC NUMBER (10,0),
             ORIGEM_CIA_COD VARCHAR2 (3000),
             ORIGEM_LOGO_NOME VARCHAR2 (3000),
             ORIGEM_NOME VARCHAR2 (3000),
             ORIGEM_ENDEREÇO VARCHAR2 (3000),
             ORIGEM_PAÍS VARCHAR2 (3000),
             ORIGEM_CONTATO VARCHAR2 (3000),
             ASSINATURA VARCHAR2 (3000),
             DESTINO_CIA_COD VARCHAR2 (3000),
             DESTINO_NOME VARCHAR2 (3000),
             DESTINO_ENDEREÇO VARCHAR2 (3000),
             DESTINO_PAÍS VARCHAR2 (3000),
             DESTINO_CONTATO VARCHAR2 (3000),
             TÍTULO VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             ASSUNTO VARCHAR2 (3000),
             MENSAGEM VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_CARTA_P (
             DOC NUMBER (10,0),
             ORIGEM_CIA_COD VARCHAR2 (3000),
             ORIGEM_LOGO_NOME VARCHAR2 (3000),
             ORIGEM_NOME VARCHAR2 (3000),
             ORIGEM_ENDEREÇO VARCHAR2 (3000),
             ORIGEM_PAÍS VARCHAR2 (3000),
             ORIGEM_CONTATO VARCHAR2 (3000),
             ASSINATURA VARCHAR2 (3000),
             DESTINO_CIA_COD VARCHAR2 (3000),
             DESTINO_NOME VARCHAR2 (3000),
             DESTINO_ENDEREÇO VARCHAR2 (3000),
             DESTINO_PAÍS VARCHAR2 (3000),
             DESTINO_CONTATO VARCHAR2 (3000),
             TÍTULO VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             ASSUNTO VARCHAR2 (3000),
             MENSAGEM VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_CONHECIMENT_ROD (
             DOC NUMBER (10,0),
             TÍTULO VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             ORIGEM_CIA_COD VARCHAR2 (3000),
             ORIGEM_LOGO_NOME VARCHAR2 (3000),
             ORIGEM_NOME VARCHAR2 (3000),
             ORIGEM_ENDEREÇO VARCHAR2 (3000),
             ORIGEM_PAÍS VARCHAR2 (3000),
             ORIGEM_CONTATO VARCHAR2 (3000),
             TRANSPORTADOR_CIA_COD VARCHAR2 (3000),
             TRANSPORTADOR VARCHAR2 (3000),
             TRANSPORTADOR_ENDEREÇO VARCHAR2 (3000),
             TRANSPORTADOR_PAÍS VARCHAR2 (3000),
             TRANSPORTADOR_CONTATO VARCHAR2 (3000),
             REMETENTE_CIA_COD VARCHAR2 (3000),
             REMETENTE VARCHAR2 (3000),
             REMETENTE_ENDEREÇO VARCHAR2 (3000),
             REMETENTE_PAÍS VARCHAR2 (3000),
             DESTINATÁRIO_CIA_COD VARCHAR2 (3000),
             DESTINATÁRIO VARCHAR2 (3000),
             DESTINATÁRIO_ENDEREÇO VARCHAR2 (3000),
             DESTINATÁRIO_PAÍS VARCHAR2 (3000),
             CONSIGNATÁRIO_CIA_COD VARCHAR2 (3000),
             CONSIGNATÁRIO VARCHAR2 (3000),
             CONSIGNATÁRIO_ENDEREÇO VARCHAR2 (3000),
             CONSIGNATÁRIO_PAÍS VARCHAR2 (3000),
             MOEDA VARCHAR2 (3000),
             REF_CIEX VARCHAR2 (3000),
             CARGA_EMBARQUE VARCHAR2 (3000),
             CARGA_DESCARGA VARCHAR2 (3000),
             MARCAÇÃO VARCHAR2 (3000),
             REF_RE VARCHAR2 (3000),
             MENSAGEM VARCHAR2 (3000),
             ASSINATURA VARCHAR2 (3000),
             UNID_PESO VARCHAR2 (3000),
             DESTINO_CIA_COD VARCHAR2 (3000),
             DESTINO_NOME VARCHAR2 (3000),
             DESTINO_ENDEREÇO VARCHAR2 (3000),
             DESTINO_CONTATO VARCHAR2 (3000),
             DESTINO_PAÍS VARCHAR2 (3000),
             VALOR NUMBER,
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_CONHECIMENT_ROD_DET (
             DOC_SEQ NUMBER (10,0),
             SEQ_ITEM NUMBER (5,0),
             FAMÍLIA VARCHAR2 (3000),
             VOLUME NUMBER (10,0),
             EMBALAGEM VARCHAR2 (3000),
             PESO_LÍQUIDO NUMBER,
             PESO_BRUTO NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_FATURA (
             DOC NUMBER (10,0),
             ORIGEM_CIA_COD VARCHAR2 (3000),
             ORIGEM_LOGO_NOME VARCHAR2 (3000),
             ORIGEM_NOME VARCHAR2 (3000),
             ORIGEM_ENDEREÇO VARCHAR2 (3000),
             ORIGEM_PAÍS VARCHAR2 (3000),
             ORIGEM_CONTATO VARCHAR2 (3000),
             SACADO_CIA_COD VARCHAR2 (3000),
             SACADO_NOME VARCHAR2 (3000),
             SACADO_ENDEREÇO VARCHAR2 (3000),
             SACADO_PAÍS VARCHAR2 (3000),
             SACADO_CONTATO VARCHAR2 (3000),
             TÍTULO VARCHAR2 (3000),
             REF_CIEX VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             MOEDA VARCHAR2 (3000),
             FAT_VALOR NUMBER,
             CARGA_EMBARQUE VARCHAR2 (3000),
             CARGA_DESCARGA VARCHAR2 (3000),
             TRANSPORTADOR VARCHAR2 (3000),
             DESCR_BL VARCHAR2 (3000),
             COND_PAG VARCHAR2 (3000),
             UNID_PESO VARCHAR2 (3000),
             UNID_VALOR VARCHAR2 (3000),
             PESO_BRUTO NUMBER,
             MENSAGEM VARCHAR2 (3000),
             ASSINATURA VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             DESCR_MERC VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_FATURA_DET (
             DOC_SEQ NUMBER (10,0),
             SEQ_ITEM NUMBER (5,0),
             FAMÍLIA VARCHAR2 (3000),
             PEDIDO VARCHAR2 (3000),
             ITEM NUMBER (5,0),
             MEDIDAS VARCHAR2 (3000),
             VOLUME NUMBER (10,0),
             EMBALAGEM VARCHAR2 (3000),
             PESO_LÍQUIDO NUMBER,
             PREÇO_UNIT NUMBER,
             TOTAL_UNIT NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_FATURA_JUROS (
             DOC NUMBER (10,0),
             ORIGEM_CIA_COD VARCHAR2 (3000),
             ORIGEM_LOGO_NOME VARCHAR2 (3000),
             ORIGEM_NOME VARCHAR2 (3000),
             ORIGEM_ENDEREÇO VARCHAR2 (3000),
             ORIGEM_PAÍS VARCHAR2 (3000),
             ORIGEM_CONTATO VARCHAR2 (3000),
             SACADO_CIA_COD VARCHAR2 (3000),
             SACADO_NOME VARCHAR2 (3000),
             SACADO_ENDEREÇO VARCHAR2 (3000),
             SACADO_PAÍS VARCHAR2 (3000),
             SACADO_CONTATO VARCHAR2 (3000),
             TÍTULO VARCHAR2 (3000),
             REF_CIEX VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             MOEDA VARCHAR2 (3000),
             INTEREST NUMBER,
             TRANSPORTADOR VARCHAR2 (3000),
             DATE_SHIPMENT VARCHAR2 (3000),
             DESCR_BL VARCHAR2 (3000),
             COND_PAG VARCHAR2 (3000),
             DESCRIÇÃO VARCHAR2 (3000),
             DESCR_JUROS VARCHAR2 (3000),
             PRINCIPAL NUMBER,
             MENSAGEM VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             ASSINATURA VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_FATURA_TOT (
             DOC_SEQ NUMBER (10,0),
             SEQ_LANC NUMBER (5,0),
             LANÇAMENTO VARCHAR2 (3000),
             VALOR NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_FECHAMENTO_CÂMB (
             DOC NUMBER (10,0),
             ORIGEM_CIA_COD VARCHAR2 (3000),
             ORIGEM_LOGO_NOME VARCHAR2 (3000),
             ORIGEM_NOME VARCHAR2 (3000),
             ORIGEM_ENDEREÇO VARCHAR2 (3000),
             ORIGEM_PAÍS VARCHAR2 (3000),
             ORIGEM_CONTATO VARCHAR2 (3000),
             ASSINATURA VARCHAR2 (3000),
             DESTINO_CIA_COD VARCHAR2 (3000),
             DESTINO_NOME VARCHAR2 (3000),
             DESTINO_ENDEREÇO VARCHAR2 (3000),
             DESTINO_PAÍS VARCHAR2 (3000),
             DESTINO_CONTATO VARCHAR2 (3000),
             TÍTULO VARCHAR2 (3000),
             REF_CIEX VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             REF_RE VARCHAR2 (3000),
             REF_CÂMBIO VARCHAR2 (3000),
             BANCO_CIA_COD VARCHAR2 (3000),
             BANCO_NOME VARCHAR2 (3000),
             BANCO_ENDEREÇO VARCHAR2 (3000),
             BANCO_PAÍS VARCHAR2 (3000),
             BANCO_CONTATO VARCHAR2 (3000),
             VENCIMENTO VARCHAR2 (3000),
             COND_PAG VARCHAR2 (3000),
             COMISSÃO VARCHAR2 (3000),
             DATA_BL VARCHAR2 (3000),
             MENSAGEM VARCHAR2 (3000),
             SACADO_CIA_COD VARCHAR2 (3000),
             SACADO_NOME VARCHAR2 (3000),
             SACADO_CONTATO VARCHAR2 (3000),
             SACADO_ENDEREÇO VARCHAR2 (3000),
             SACADO_PAÍS VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_FECHAMENTO_CÂMB_TOT (
             DOC_SEQ NUMBER (10,0),
             SEQ_LANC NUMBER (5,0),
             LANÇAMENTO VARCHAR2 (3000),
             VALOR NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_FIRJAN (
             DOC NUMBER (10,0),
             COD_EXP VARCHAR2 (3000),
             EXPORTADOR VARCHAR2 (3000),
             EXP_PAÍS VARCHAR2 (3000),
             COD_IMP VARCHAR2 (3000),
             IMPORTADOR VARCHAR2 (3000),
             IMP_PAÍS VARCHAR2 (3000),
             COD_CONSIGN VARCHAR2 (3000),
             CONSIGNATÁRIO VARCHAR2 (3000),
             CONSIGN_PAÍS VARCHAR2 (3000),
             REF_CIEX VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             UNID_PESO VARCHAR2 (3000),
             MENSAGEM VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_FIRJAN_DET (
             DOC_SEQ NUMBER (10,0),
             SEQ_ITEM NUMBER (5,0),
             NCM VARCHAR2 (3000),
             FAMÍLIA VARCHAR2 (3000),
             VOLUME NUMBER (10,0),
             EMBALAGEM VARCHAR2 (3000),
             PESO_LÍQUIDO NUMBER,
             PESO_BRUTO NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_MERCOSUL (
             DOC NUMBER (10,0),
             COD_EXP VARCHAR2 (3000),
             EXPORTADOR VARCHAR2 (3000),
             EXP_ENDEREÇO VARCHAR2 (3000),
             EXP_PAÍS VARCHAR2 (3000),
             COD_IMP VARCHAR2 (3000),
             IMPORTADOR VARCHAR2 (3000),
             IMP_ENDEREÇO VARCHAR2 (3000),
             IMP_PAÍS VARCHAR2 (3000),
             COD_CONSIGN VARCHAR2 (3000),
             CONSIGNATÁRIO VARCHAR2 (3000),
             CONSIGN_PAÍS VARCHAR2 (3000),
             LOCAL_EMBARQUE VARCHAR2 (3000),
             DESTINO VARCHAR2 (3000),
             TRANSPORTE VARCHAR2 (3000),
             REF_CIEX VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             OBS VARCHAR2 (3000),
             DECLARAÇÃO VARCHAR2 (3000),
             DECLARAÇÃO_DATA VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             UNID_PESO VARCHAR2 (3000),
             MENSAGEM VARCHAR2 (3000),
             MOEDA VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_MERCOSUL_BOLIV (
             DOC NUMBER (10,0),
             COD_EXP VARCHAR2 (3000),
             EXPORTADOR VARCHAR2 (3000),
             EXP_ENDEREÇO VARCHAR2 (3000),
             EXP_PAÍS VARCHAR2 (3000),
             COD_IMP VARCHAR2 (3000),
             IMPORTADOR VARCHAR2 (3000),
             IMP_ENDEREÇO VARCHAR2 (3000),
             IMP_PAÍS VARCHAR2 (3000),
             COD_CONSIGN VARCHAR2 (3000),
             CONSIGNATÁRIO VARCHAR2 (3000),
             CONSIGN_PAÍS VARCHAR2 (3000),
             LOCAL_EMBARQUE VARCHAR2 (3000),
             DESTINO VARCHAR2 (3000),
             TRANSPORTE VARCHAR2 (3000),
             REF_CIEX VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             OBS VARCHAR2 (3000),
             DECLARAÇÃO VARCHAR2 (3000),
             DECLARAÇÃO_DATA VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             UNID_PESO VARCHAR2 (3000),
             MENSAGEM VARCHAR2 (3000),
             MOEDA VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_MERCOSUL_BOLIV_DET (
             DOC_SEQ NUMBER (10,0),
             SEQ_ITEM NUMBER (5,0),
             ORDEM NUMBER (5,0),
             NALADI VARCHAR2 (3000),
             FAMÍLIA VARCHAR2 (3000),
             DESCRIÇÃO VARCHAR2 (3000),
             VOLUME NUMBER (10,0),
             EMBALAGEM VARCHAR2 (3000),
             PESO_LÍQUIDO NUMBER,
             VALOR_FOB NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_MERCOSUL_BOLIV_NORMA (
             DOC_SEQ NUMBER (10,0),
             SEQ_NORMA NUMBER (5,0),
             NORMA VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_MERCOSUL_CHILE (
             DOC NUMBER (10,0),
             COD_EXP VARCHAR2 (3000),
             EXPORTADOR VARCHAR2 (3000),
             EXP_ENDEREÇO VARCHAR2 (3000),
             EXP_PAÍS VARCHAR2 (3000),
             COD_IMP VARCHAR2 (3000),
             IMPORTADOR VARCHAR2 (3000),
             IMP_ENDEREÇO VARCHAR2 (3000),
             IMP_PAÍS VARCHAR2 (3000),
             COD_CONSIGN VARCHAR2 (3000),
             CONSIGNATÁRIO VARCHAR2 (3000),
             CONSIGN_PAÍS VARCHAR2 (3000),
             LOCAL_EMBARQUE VARCHAR2 (3000),
             DESTINO VARCHAR2 (3000),
             TRANSPORTE VARCHAR2 (3000),
             REF_CIEX VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             OBS VARCHAR2 (3000),
             DECLARAÇÃO VARCHAR2 (3000),
             DECLARAÇÃO_DATA VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             UNID_PESO VARCHAR2 (3000),
             MENSAGEM VARCHAR2 (3000),
             MOEDA VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_MERCOSUL_CHILE_DET (
             DOC_SEQ NUMBER (10,0),
             SEQ_ITEM NUMBER (5,0),
             ORDEM NUMBER (5,0),
             NALADI VARCHAR2 (3000),
             FAMÍLIA VARCHAR2 (3000),
             DESCRIÇÃO VARCHAR2 (3000),
             VOLUME NUMBER (10,0),
             EMBALAGEM VARCHAR2 (3000),
             PESO_LÍQUIDO NUMBER,
             VALOR_FOB NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_MERCOSUL_CHILE_NORMA (
             DOC_SEQ NUMBER (10,0),
             SEQ_NORMA NUMBER (5,0),
             NORMA VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_MERCOSUL_DET (
             DOC_SEQ NUMBER (10,0),
             SEQ_ITEM NUMBER (5,0),
             ORDEM NUMBER (5,0),
             NCM VARCHAR2 (3000),
             FAMÍLIA VARCHAR2 (3000),
             DESCRIÇÃO VARCHAR2 (3000),
             VOLUME NUMBER (10,0),
             EMBALAGEM VARCHAR2 (3000),
             PESO_LÍQUIDO NUMBER,
             VALOR_FOB NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_MERCOSUL_NORMA (
             DOC_SEQ NUMBER (10,0),
             SEQ_NORMA NUMBER (5,0),
             NORMA VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_PLIST_WEIG_CERT (
             DOC NUMBER (10,0),
             ORIGEM_CIA_COD VARCHAR2 (3000),
             ORIGEM_LOGO_NOME VARCHAR2 (3000),
             ORIGEM_NOME VARCHAR2 (3000),
             ORIGEM_ENDEREÇO VARCHAR2 (3000),
             ORIGEM_PAÍS VARCHAR2 (3000),
             ORIGEM_CONTATO VARCHAR2 (3000),
             SACADO_CIA_COD VARCHAR2 (3000),
             SACADO_NOME VARCHAR2 (3000),
             SACADO_ENDEREÇO VARCHAR2 (3000),
             SACADO_PAÍS VARCHAR2 (3000),
             SACADO_CONTATO VARCHAR2 (3000),
             TÍTULO VARCHAR2 (3000),
             REF_CIEX VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             CARGA_EMBARQUE VARCHAR2 (3000),
             CARGA_DESCARGA VARCHAR2 (3000),
             TRANSPORTADOR VARCHAR2 (3000),
             UNID_PESO VARCHAR2 (3000),
             MENSAGEM VARCHAR2 (3000),
             ASSINATURA VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             DESCR_MERC VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_PLIST_WEIG_CERT_DET (
             DOC_SEQ NUMBER (10,0),
             SEQ_ITEM NUMBER (5,0),
             FAMÍLIA VARCHAR2 (3000),
             MEDIDAS VARCHAR2 (3000),
             VOLUME NUMBER (10,0),
             EMBALAGEM VARCHAR2 (3000),
             PESO_LÍQUIDO NUMBER,
             PESO_BRUTO NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_SAQUE_2V (
             DOC NUMBER (10,0),
             ASSISTENTE VARCHAR2 (3000),
             BENEF_CIA_COD VARCHAR2 (3000),
             BENEF_NOME VARCHAR2 (3000),
             COND_PAG VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             MENSAGEM VARCHAR2 (3000),
             MOEDA VARCHAR2 (3000),
             ORIGEM_CIA_COD VARCHAR2 (3000),
             ORIGEM_ESTADO VARCHAR2 (3000),
             ORIGEM_NOME VARCHAR2 (3000),
             SACADO_CIA_COD VARCHAR2 (3000),
             SACADO_NOME VARCHAR2 (3000),
             SAQ_VALOR NUMBER,
             SUPERVISOR VARCHAR2 (3000),
             TÍTULO VARCHAR2 (3000),
             VALOR_EXT VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             MENSAGEM_COMP VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_SAQUE_3V (
             DOC NUMBER (10,0),
             ASSISTENTE VARCHAR2 (3000),
             BENEF_CIA_COD VARCHAR2 (3000),
             BENEF_NOME VARCHAR2 (3000),
             COND_PAG VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             MENSAGEM VARCHAR2 (3000),
             MOEDA VARCHAR2 (3000),
             ORIGEM_CIA_COD VARCHAR2 (3000),
             ORIGEM_ESTADO VARCHAR2 (3000),
             ORIGEM_NOME VARCHAR2 (3000),
             SACADO_CIA_COD VARCHAR2 (3000),
             SACADO_NOME VARCHAR2 (3000),
             SAQ_VALOR NUMBER,
             SUPERVISOR VARCHAR2 (3000),
             TÍTULO VARCHAR2 (3000),
             VALOR_EXT VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             MENSAGEM_COMP VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_SAQUE_JUROS_2V (
             DOC NUMBER (10,0),
             ASSISTENTE VARCHAR2 (3000),
             BENEF_CIA_COD VARCHAR2 (3000),
             BENEF_NOME VARCHAR2 (3000),
             COND_PAG VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             MENSAGEM VARCHAR2 (3000),
             MOEDA VARCHAR2 (3000),
             ORIGEM_CIA_COD VARCHAR2 (3000),
             ORIGEM_ESTADO VARCHAR2 (3000),
             ORIGEM_NOME VARCHAR2 (3000),
             SACADO_CIA_COD VARCHAR2 (3000),
             SACADO_NOME VARCHAR2 (3000),
             SAQ_VALOR NUMBER,
             SUPERVISOR VARCHAR2 (3000),
             TÍTULO VARCHAR2 (3000),
             VALOR_EXT VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             MENSAGEM_COMP VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_SAQUE_JUROS_3V (
             DOC NUMBER (10,0),
             ASSISTENTE VARCHAR2 (3000),
             BENEF_CIA_COD VARCHAR2 (3000),
             BENEF_NOME VARCHAR2 (3000),
             COND_PAG VARCHAR2 (3000),
             DATA_DOC VARCHAR2 (3000),
             MENSAGEM VARCHAR2 (3000),
             MOEDA VARCHAR2 (3000),
             ORIGEM_CIA_COD VARCHAR2 (3000),
             ORIGEM_ESTADO VARCHAR2 (3000),
             ORIGEM_NOME VARCHAR2 (3000),
             SACADO_CIA_COD VARCHAR2 (3000),
             SACADO_NOME VARCHAR2 (3000),
             SAQ_VALOR NUMBER,
             SUPERVISOR VARCHAR2 (3000),
             TÍTULO VARCHAR2 (3000),
             VALOR_EXT VARCHAR2 (3000),
             IDIOMA VARCHAR2 (3000),
             MENSAGEM_COMP VARCHAR2 (3000),
             EMB_REF VARCHAR2 (3000),
             EMB_DOC_SEQ NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.DOC_TEMPLATE (
             NOME_TABELA VARCHAR2 (50),
             CAMPO VARCHAR2 (50),
             ORDEM NUMBER (5,0),
             ETIQ VARCHAR2 (50),
             TIPO VARCHAR2 (25),
             CORRESPOND_EXP VARCHAR2 (255),
             CORRESPOND_IMP VARCHAR2 (255),
             REL_ADICIONAL VARCHAR2 (255),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB (
             CALC_NOMINAL_PED NUMBER,
             REF VARCHAR2 (13),
             VIAGEM VARCHAR2 (13),
             FRETE_UNID VARCHAR2 (10),
             FRETE_VALOR NUMBER,
             FRETE_POR_MT NUMBER,
             FRETE_VALOR_POR_UNID NUMBER,
             FRETE_VALOR_TOTAL NUMBER,
             FRETE_COND VARCHAR2 (10),
             DATA_EMBARQUE DATE,
             DATA_EMISSÃO_DOC VARCHAR2 (30),
             CARGA_PORTO VARCHAR2 (3000),
             DESCARGA_PORTO VARCHAR2 (3000),
             TRANSPORTADOR VARCHAR2 (3000),
             MOEDA VARCHAR2 (20),
             IDIOMA VARCHAR2 (3),
             PESO_UNID VARCHAR2 (3000),
             PREÇO_UNITÁRIO_UNID VARCHAR2 (3000),
             PREÇO_UNID VARCHAR2 (3000),
             NEGOCIADOR VARCHAR2 (30),
             EMBARCADOR VARCHAR2 (3000),
             EMB_ENDEREÇO VARCHAR2 (3000),
             EMB_PAÍS VARCHAR2 (3000),
             EMB_COND_VENDA VARCHAR2 (3000),
             EMB_COND_PAG VARCHAR2 (3000),
             EMB_COMENTÁRIOS VARCHAR2 (3000),
             EXP VARCHAR2 (3000),
             EXP_ENDEREÇO VARCHAR2 (3000),
             EXP_PAÍS VARCHAR2 (3000),
             EXP_COND_VENDA VARCHAR2 (3000),
             EXP_COND_PAG VARCHAR2 (3000),
             EXP_COMENTÁRIOS VARCHAR2 (3000),
             EXP_LOGOTIPO VARCHAR2 (30),
             EXP_FAT VARCHAR2 (13),
             IMP VARCHAR2 (3000),
             IMP_ENDEREÇO VARCHAR2 (3000),
             IMP_PAÍS VARCHAR2 (3000),
             IMP_COND_VENDA VARCHAR2 (3000),
             IMP_COND_PAG VARCHAR2 (3000),
             IMP_COMENTÁRIOS VARCHAR2 (3000),
             IMP_LOGOTIPO VARCHAR2 (30),
             IMP_FAT VARCHAR2 (13),
             PAGADOR VARCHAR2 (3000),
             PAG_ENDEREÇO VARCHAR2 (3000),
             PAG_PAÍS VARCHAR2 (3000),
             CONSIGNATÁRIO VARCHAR2 (3000),
             CONSIGN_ENDEREÇO VARCHAR2 (3000),
             CONSIGN_PAÍS VARCHAR2 (3000),
             NOTIFICAR VARCHAR2 (3000),
             NOTIFICAR_ENDEREÇO VARCHAR2 (3000),
             NOTIFICAR_PAÍS VARCHAR2 (3000),
             NUM_BL_DESCR VARCHAR2 (3000),
             FAMÍLIA_GENÉRICA VARCHAR2 (3000),
             TIPO_DESCR_MERCADORIA VARCHAR2 (100),
             MARCAÇÃO VARCHAR2 (3000),
             TOTALIZAÇÃO_EMBALAGEM VARCHAR2 (20),
             CONFIG VARCHAR2 (4000),
             EMB_ACORDO DATE,
             VIA_TRANSPORTE VARCHAR2 (15),
             CARTA_CRED_REF VARCHAR2 (13),
             EMB_DATA VARCHAR2 (30),
             CARTA_CRÉDITO_BANCO_ABRIDOR VARCHAR2 (30),
             CARTA_CRÉDITO_REF VARCHAR2 (30),
             BANCO_AVISADOR VARCHAR2 (30),
             BANCO_CONFIRM VARCHAR2 (30),
             CALC_QTD_PED_UNID NUMBER,
             CALC_PESO_LÍQUIDO NUMBER,
             CALC_PESO_BRUTO NUMBER,
             CALC_QTD_VOL NUMBER (10,0),
             CALC_EXP_TOT_ITEM NUMBER,
             CALC_EXP_TOT_EMB NUMBER,
             CALC_EXP_COND_PAG VARCHAR2 (10),
             CALC_EXP_COND_VENDA VARCHAR2 (10),
             CALC_IMP_TOT_ITEM NUMBER,
             CALC_IMP_TOT_EMB NUMBER,
             CALC_IMP_COND_PAG VARCHAR2 (10),
             CALC_IMP_COND_VENDA VARCHAR2 (10),
             CALC_FRETE_TOTAL NUMBER,
             CALC_PEND NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB_CHECK_LIST (
             EMB_REF VARCHAR2 (13),
             CHECKLIST VARCHAR2 (13),
             CK_QTD_VALOR NUMBER (5,0),
             CK_DECLAR NUMBER (5,0),
             CK_CONFIRM NUMBER (5,0),
             CK_SUJEITA NUMBER (5,0),
             CK_CLASULA NUMBER (5,0),
             CK_PRAZO NUMBER (5,0),
             CK_EMB_PARCIAIS NUMBER (5,0),
             CK_TRANSBORDO NUMBER (5,0),
             CK_CONHECIMENTO NUMBER (5,0),
             CK_ASSINADO NUMBER (5,0),
             CK_END_CORRETO NUMBER (5,0),
             CK_DOC_TERCEIRO NUMBER (5,0),
             CK_CLAUSULA_DOC NUMBER (5,0),
             CE_PROIB_DATA NUMBER (5,0),
             CE_PROIB_EMISS NUMBER (5,0),
             CE_PROIB_SHORT NUMBER (5,0),
             CE_EXIG_DECL NUMBER (5,0),
             CE_ENDOSSO NUMBER (5,0),
             SQ_ENDOSSO NUMBER (5,0),
             SQ_MONTANT NUMBER (5,0),
             CK_CONSULADO NUMBER (5,0),
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB_DOC (
             EMB_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             DOC VARCHAR2 (25),
             EXP NUMBER (5,0),
             PARAM VARCHAR2 (4000),
             IMP NUMBER (5,0),
             CÓPIA_NUM NUMBER (5,0),
             ORIGINAL_NUM NUMBER (5,0),
             BRANCO_NUM NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB_DOC_DESTINO (
             EMB_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             CIA VARCHAR2 (30),
             ORIGINAL_NUM NUMBER (3,0),
             CÓPIA_NUM NUMBER (3,0),
             ORIGINAL_VISADA_NUM NUMBER (3,0),
             CÓPIA_VISADA_NUM NUMBER (3,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB_DOC_REL (
             EMB_REF VARCHAR2 (13),
             DOC NUMBER (5,0),
             EMB_REL VARCHAR2 (13),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB_F (
             PED_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             FATURA VARCHAR2 (20),
             INV_DATA DATE,
             NAVIO VARCHAR2 (30),
             BL_DATA DATE,
             COMPETÊNCIA DATE,
             QUANTIDADE NUMBER,
             VALOR NUMBER,
             RESULT1 NUMBER,
             RESULT2 NUMBER,
             RESULT3 NUMBER,
             RESULT4 NUMBER,
             RESULT5 NUMBER,
             POSIÇÃO CHAR,
             OBSERVAÇÃO VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB_FAMÍLIA (
             EMB_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             FAMÍLIA VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB_FAMÍLIA_GENÉRICA (
             EMB_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             FAMÍLIA VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB_FILTRO (
             EMB_REF VARCHAR2 (13),
             SEQ NUMBER,
             PED_REF VARCHAR2 (13),
             ITEM NUMBER,
             FECH_REF VARCHAR2 (13),
             OV VARCHAR2 (20),
             NE_ITEM VARCHAR2 (20),
             PO VARCHAR2 (20),
             LOTE VARCHAR2 (20),
             TBN VARCHAR2 (20),
             P VARCHAR2 (20),
             FSE VARCHAR2 (20),
             BL_CODE VARCHAR2 (20),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB_ITEM_TEMP (
             EMB_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             FECH_REF VARCHAR2 (13),
             PED_REF VARCHAR2 (13),
             PED_ITEM NUMBER (5,0),
             BL_SEQ NUMBER (5,0),
             QTD_NOMINAL NUMBER,
             QTD_VOL NUMBER (10,0),
             LÍQUIDO NUMBER,
             BRUTO NUMBER,
             QTD_FRETE NUMBER,
             SEQ_FAMÍLIA NUMBER (5,0),
             SEQ_FAMÍLIA_GENÉRICA NUMBER (5,0),
             PROD VARCHAR2 (30),
             ESPESSURA_MM FLOAT,
             LARGURA_MM FLOAT,
             COMPRIMENTO_MM FLOAT,
             ESPESSURA_POL FLOAT,
             LARGURA_POL FLOAT,
             COMPRIMENTO_POL FLOAT,
             REVESTIMENTO VARCHAR2 (15),
             TÊMPERA VARCHAR2 (15),
             OV VARCHAR2 (20),
             NE_ITEM VARCHAR2 (20),
             TBN VARCHAR2 (20),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB_LANÇ (
             EMB_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             LANÇ VARCHAR2 (20),
             VALOR NUMBER,
             VALOR_POR_MT NUMBER,
             TOTAL_PERCENT FLOAT,
             TOTAL_TIPO VARCHAR2 (10),
             EXP NUMBER (5,0),
             IMP NUMBER (5,0),
             UNID NUMBER (5,0),
             NA_FATURA NUMBER (5,0),
             BENEFICIÁRIO VARCHAR2 (30),
             COMISSÃO_MODALIDADE VARCHAR2 (1),
             INSTRUÇÃO_REMESSA VARCHAR2 (3000),
             EXP_CALC NUMBER,
             IMP_CALC NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB_MENSAGEM (
             EMB_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             MSG VARCHAR2 (3000),
             EXP NUMBER (5,0),
             IMP NUMBER (5,0),
             DOC_ALADI NUMBER (5,0),
             DOC_BORDERÔ_I NUMBER (5,0),
             DOC_BORDERÔ_P NUMBER (5,0),
             DOC_CÂMARA_COMÉRCIO NUMBER (5,0),
             DOC_CARTA_I NUMBER (5,0),
             DOC_CARTA_P NUMBER (5,0),
             DOC_CONHECIM_ROD NUMBER (5,0),
             DOC_FATURA NUMBER (5,0),
             DOC_FATURA_JUROS NUMBER (5,0),
             DOC_FECH_CAMBIO NUMBER (5,0),
             DOC_FIRJAN NUMBER (5,0),
             DOC_MERCOSUL NUMBER (5,0),
             DOC_MERCOSUL_BOLIVIA NUMBER (5,0),
             DOC_MERCOSUL_CHILE NUMBER (5,0),
             DOC_PLIST_WEIG_CERT NUMBER (5,0),
             DOC_SAQUE_JUR_2_VIAS NUMBER (5,0),
             DOC_SAQUE_JUR_3_VIAS NUMBER (5,0),
             DOC_SAQUE_2_VIAS NUMBER (5,0),
             DOC_SAQUE_3_VIAS NUMBER (5,0),
             DOC_ALADI_CERTIF_ORIGEM NUMBER (5,0),
             DOC_BL NUMBER (5,0),
             DOC_CÂM_COM_CERTIF_O NUMBER (5,0),
             DOC_CAPA NUMBER (5,0),
             DOC_CONHECIM_RODOVIÁRIO NUMBER (5,0),
             DOC_CHECK_LIST NUMBER (5,0),
             DOC_CARTA_DEOP_INGLÊS NUMBER (5,0),
             DOC_CARTA_DEOP_PORTUG NUMBER (5,0),
             DOC_FECHAM_CÂMBIO NUMBER (5,0),
             DOC_FIRJAN_CERTIF_ORIGEM NUMBER (5,0),
             DOC_FORM_A NUMBER (5,0),
             DOC_INSTR_PAG NUMBER (5,0),
             DOC_MERCOSUL_CERTIF_ORIGEM NUMBER (5,0),
             DOC_PACKING_LIST NUMBER (5,0),
             DOC_SAQUE NUMBER (5,0),
             DOC_WEIGHT_CERTIFICATE NUMBER (5,0),
             DOC_SAQUE_JUROS NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB_RE (
             EMB_REF VARCHAR2 (13),
             RE VARCHAR2 (15),
             EMISSÃO_DATA DATE,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB_SD (
             EMB_REF VARCHAR2 (13),
             SD VARCHAR2 (15),
             AVERBAÇÃO_DATA DATE,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMB_TOTALIZA (
             EMB_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             LANÇ VARCHAR2 (20),
             EXP NUMBER (5,0),
             IMP NUMBER (5,0),
             EXP_DESCR VARCHAR2 (3000),
             IMP_DESCR VARCHAR2 (3000),
             EXP_CALC NUMBER,
             IMP_CALC NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.EMBALAGEM (
             COD VARCHAR2 (20),
             DESCR VARCHAR2 (3000),
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.ESCRITÓRIO (
             ESCRITÓRIO VARCHAR2 (2),
             DESCR VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.ETIQ_MALA_DIRETA (
             USUÁRIO VARCHAR2 (20),
             CRIAÇÃO_DATA DATE,
             SEQ NUMBER (5,0),
             CIA VARCHAR2 (30),
             CONTATO VARCHAR2 (50),
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.FATURA (
             REF VARCHAR2 (13),
             EMPRESA VARCHAR2 (30),
             DOC_DATA DATE,
             CIA VARCHAR2 (30),
             CONTATO VARCHAR2 (50),
             CIA_SUB VARCHAR2 (30),
             CONTATO_SUB VARCHAR2 (50),
             FECH_REF VARCHAR2 (13),
             BANCO_DETALHE VARCHAR2 (3000),
             ASSUNTO VARCHAR2 (3000),
             EMISSÃO_DATA DATE,
             USUÁRIO VARCHAR2 (20),
             SUPERVISOR VARCHAR2 (20),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.FATURA_CONFIRM (
             REF VARCHAR2(13),
             SEQ NUMBER(5),
             TÍTULO VARCHAR2(100),
             NOME_CIA VARCHAR(45),
             LOGOTIPO BLOB,
             FATURA VARCHAR2(100),
             EMISSÃO_DATA VARCHAR2(35),
             EMISSOR VARCHAR2(3000),
             OUTRA_REF VARCHAR2(3000),
             PRODUTOR VARCHAR2(3000),
             COMPRADOR VARCHAR2(3000),
             USUÁRIO_FINAL VARCHAR2(3000),
             ENTREGA VARCHAR2(30),
             CARGA_PORTO VARCHAR2(30),
             DIMENSÃO VARCHAR2(20),
             ESPECIFICAÇÃO VARCHAR2(3000),
             PAG VARCHAR2(3000),
             PREÇO_DETALHE VARCHAR2(3000),
             DESCARGA_PORTO VARCHAR2(30),
             DESTINATÁRIO VARCHAR2(3000),
             ASSINATURA VARCHAR2(50),
             ETIQ_FATURA VARCHAR2(100),
             ETIQ_REFÊNCIAS VARCHAR2(100),
             ETIQ_COMPRADOR VARCHAR2(100),
             ETIQ_DATA VARCHAR2(100),
             ETIQ_PREV_EMB VARCHAR2(100),
             ETIQ_COND_PAG VARCHAR2(100),
             ETIQ_USU_FINAL VARCHAR2(100),
             ETIQ_ESPECIFICAÇÃO VARCHAR2(100),
             ETIQ_ORIGEM VARCHAR2(100),
             ETIQ_DESTINO VARCHAR2(100),
             ETIQ_EMBARQUE VARCHAR2(100),
             ETIQ_PAGINA VARCHAR2(100),
             ETIQ_DESCR VARCHAR2(100),
             ETIQ_QTD VARCHAR2(100),
             ETIQ_PREÇO_UNITÁRIO VARCHAR2(100),
             ETIQ_PREÇO_TOTAL VARCHAR2(100),
             ETIQ_PESO VARCHAR2(100),
             EMPRESA_REL VARCHAR2(100),
             ETIQ_ASSIN VARCHAR2(100),
             ETIQ_PREÇO_DET VARCHAR2(100),
             ETIQ_PRODUTOR VARCHAR2(100),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.FATURA_CONFIRM_ITEM (
             CONFIRM_VENDA_REF VARCHAR2(13),
             SEQ NUMBER(5),
             ITEM NUMBER(5),
             DESCR VARCHAR2(3000),
             DIMENSÃO VARCHAR2(3000),
             QTD FLOAT,
             UNID VARCHAR2(10),
             PESO_UNID VARCHAR2(50),
             PREÇO FLOAT,
             MOEDA VARCHAR2(15),
             PESO FLOAT,
             QUALIDADE VARCHAR2(15),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.FAX (
             REF VARCHAR2 (13),
             USUÁRIO VARCHAR2 (20),
             MOMENTO_CRIA DATE,
             MOMENTO_ENVIA DATE,
             MOMENTO_CONFIRM DATE,
             PÁGINAS_ADICIONAIS NUMBER (3,0),
             DOC VARCHAR2 (50),
             DE VARCHAR2 (3000),
             ASSUNTO VARCHAR2 (3000),
             FAX_CORPO VARCHAR2 (4000),
             FAX_OBJ BLOB,
             COMENTÁRIO VARCHAR2 (3000),
             CANCEL NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.FAX_CHAVE (
             FAX_REF VARCHAR2 (13),
             CHAVE VARCHAR2 (40),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.FAX_DESTINO (
             FAX_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             TIPO VARCHAR2 (3),
             CIA VARCHAR2 (30),
             CONTATO VARCHAR2 (50),
             CONTATO_2 VARCHAR2 (50),
             CONTATO_3 VARCHAR2 (50),
             DESCR VARCHAR2 (100),
             OBS VARCHAR2 (100),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.FECH (
             REF VARCHAR2 (13),
             FECH_DATA DATE,
             MOEDA VARCHAR2 (20),
             VIAGEM_REF VARCHAR2 (13),
             CARGA_PORTO_ESCALA NUMBER (5,0),
             DESCARGA_PORTO_ESCALA NUMBER (5,0),
             CONTRATANTE VARCHAR2 (30),
             CORRETOR VARCHAR2 (30),
             PROPRIETÁRIO VARCHAR2 (30),
             NEGOCIANTE VARCHAR2 (30),
             FRETE_DETALHE VARCHAR2 (10),
             FRETE_UNID VARCHAR2 (10),
             FRETE_VALOR NUMBER,
             FRETE_VALOR_POR_UNID NUMBER,
             FRETE_PAG_DETALHE VARCHAR2 (3000),
             COMISSÃO_FRETE NUMBER,
             COMISSÃO_BASE NUMBER,
             COMISSÃO_PERCENT FLOAT,
             CIA_PAGADORA VARCHAR2 (30),
             CARGA_AGENTE VARCHAR2 (30),
             CARGA_ESTIVA VARCHAR2 (30),
             CARGA_ESTIVA_CUSTO NUMBER,
             CARGA_DETALHE VARCHAR2 (3000),
             CARGA_OBS VARCHAR2 (3000),
             DESCARGA_AGENTE VARCHAR2 (30),
             DESCARGA_ESTIVA VARCHAR2 (30),
             DESCARGA_ESTIVA_CUSTO NUMBER,
             DESCARGA_DETALHE VARCHAR2 (3000),
             DESCARGA_OBS VARCHAR2 (3000),
             DETENÇÃO NUMBER,
             DEMORA NUMBER,
             OBS VARCHAR2 (3000),
             DESPACHANTE NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.FECH_CARGA (
             FECH_REF VARCHAR2 (13),
             PED_REF VARCHAR2 (13),
             PED_ITEM NUMBER (5,0),
             QTD_PED_UNID NUMBER,
             QTD_FRETE_UNID NUMBER,
             QTD_TOTAL NUMBER (5,0),
             NOMEAÇÃO_DATA DATE,
             ACEITAÇÃO_FORNECEDOR_DATA DATE,
             CANCEL_DATA DATE,
             CANCEL_MOTIVO VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.FECH_CONTATO (
             FECH_REF VARCHAR2 (13),
             CIA_COD VARCHAR2 (30),
             CONTATO_NOME VARCHAR2 (50),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.FECH_SUBSTITUÍDO (
             SUBSTITUÍDO VARCHAR2 (13),
             SUBSTITUTO VARCHAR2 (13),
             SUBSTITUIÇÃO_DATA DATE,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.FRETE (
             CARGA_PORTO VARCHAR2 (30),
             DESCARGA_PORTO VARCHAR2 (30),
             PROPRIETÁRIO VARCHAR2 (30),
             FRETE_DETALHE VARCHAR2 (10),
             FRETE_UNID VARCHAR2 (10),
             FRETE_VALOR_POR_UNID NUMBER,
             COMISSÃO_USD NUMBER,
             COMISSÃO_PERCENT FLOAT,
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.GRUPO_PRODUTO (
             COD VARCHAR2 (10),
             DESCR VARCHAR2 (200),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.IDIOMA (
             COD VARCHAR2 (3),
             DESCR VARCHAR2 (25),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.INCOTERM (
             COD VARCHAR2 (10),
             DESCR VARCHAR2 (3000),
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.INCOTERM_LANÇ (
             INCOTERM VARCHAR2 (10),
             LANÇ VARCHAR2 (20),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.INSTRUÇÃO_PAG (
             REF VARCHAR2 (13),
             SOLICITAÇÃO_DATA DATE,
             MOEDA VARCHAR2 (20),
             VALOR NUMBER,
             RECEBEDOR VARCHAR2 (30),
             PAG_DATA DATE,
             PAG_FORMA VARCHAR2 (3000),
             HISTÓRICO VARCHAR2 (3000),
             OBS VARCHAR2 (3000),
             PAGADOR VARCHAR2 (30),
             RESPONSÁVEL VARCHAR2 (3000),
             SOLICITANTE VARCHAR2 (3000),
             AUTORIZADOR VARCHAR2 (3000),
             COM_CÓPIA VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.INSTRUÇÃO_PAG_FECH (
             INSTRUÇÃO_PAG_REF VARCHAR2 (13),
             FECH_REF VARCHAR2 (13),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.LANÇ (
             LANÇ VARCHAR2 (20),
             NOME VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.LOCAL_RESULT (
             COD VARCHAR2 (8),
             DESCR VARCHAR2 (30),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.MERCADO (
             ANO_MÊS VARCHAR2 (4),
             CONTRATANTE VARCHAR2 (30),
             FORNECEDOR VARCHAR2 (30),
             TRANSPORTADOR VARCHAR2 (30),
             PROD VARCHAR2 (30),
             QTD NUMBER,
             FRETE_COND VARCHAR2 (10),
             FRETE_VALOR_POR_MT NUMBER,
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.MERCADO_PORTO (
             ANO_MÊS VARCHAR2 (4),
             CONTRATANTE VARCHAR2 (30),
             FORNECEDOR VARCHAR2 (30),
             TRANSPORTADOR VARCHAR2 (30),
             PROD VARCHAR2 (30),
             QTD VARCHAR2 (1),
             PORTO VARCHAR2 (30),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.MODALIDADE_FRETE (
             COD VARCHAR2 (10),
             DESCR VARCHAR2 (3000),
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.MOEDA (
             COD VARCHAR2 (20),
             NOME VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.NAVIO (
             COD VARCHAR2 (30),
             ANO_CONSTRUÇÃO NUMBER (5,0),
             NOME VARCHAR2 (3000),
             NOME_ANTERIOR VARCHAR2 (30),
             BANDEIRA VARCHAR2 (30),
             NAVIO_TIPO VARCHAR2 (3000),
             DWAT NUMBER (10,0),
             LOA FLOAT,
             BEAN FLOAT,
             GRT NUMBER (10,0),
             NRT NUMBER (10,0),
             CAPACIDADE_GRÃO NUMBER (10,0),
             CAPACIDADE_FARDO NUMBER (10,0),
             CALADO_VERÃO FLOAT,
             GUINDASTE_NUM NUMBER (5,0),
             GUINDASTE_DIMENSÃO VARCHAR2 (3000),
             ESCOTILHA_NUM NUMBER (5,0),
             ESCOTILHA_DIMENSÃO VARCHAR2 (3000),
             ESCOTILHA_FECHAM_TIPO VARCHAR2 (254),
             EQUIPAMENTO VARCHAR2 (3000),
             TANKTOP_STRENGTH VARCHAR2 (3000),
             SOCIEDADE_CLASSIFICADORA VARCHAR2 (50),
             CLASSE VARCHAR2 (40),
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.NOTA_CRÉDITO (
             REF VARCHAR2 (13),
             DOC_DATA DATE,
             MOEDA VARCHAR2 (20),
             TAXA_USD FLOAT,
             VALOR NUMBER,
             CIA VARCHAR2 (30),
             CONTATO VARCHAR2 (50),
             CIA_SUB VARCHAR2 (30),
             CONTATO_SUB VARCHAR2 (50),
             TEXTO VARCHAR2 (3000),
             EMISSOR VARCHAR2 (3000),
             ASSUNTO VARCHAR2 (3000),
             EMISSÃO_DATA DATE,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.NOTA_CRÉDITO_FECH (
             NOTA_CRÉDITO_REF VARCHAR2 (13),
             FECH_REF VARCHAR2 (13),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.NOTA_CRÉDITO_PAG (
             NOTA_CRÉDITO_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             PAG_DATA DATE,
             MOEDA VARCHAR2 (20),
             TAXA_USD FLOAT,
             VALOR NUMBER,
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.NOTA_DÉBITO (
             REF VARCHAR2 (13),
             DOC_DATA DATE,
             MOEDA VARCHAR2 (20),
             TAXA_USD FLOAT,
             VALOR NUMBER,
             CIA VARCHAR2 (30),
             CONTATO VARCHAR2 (50),
             CIA_SUB VARCHAR2 (30),
             CONTATO_SUB VARCHAR2 (50),
             TEXTO VARCHAR2 (3000),
             TRANSFERÊNCIA_DETALHE VARCHAR2 (3000),
             ASSUNTO VARCHAR2 (3000),
             EMISSÃO_DATA DATE,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.NOTA_DÉBITO_FECH (
             NOTA_DÉBITO_REF VARCHAR2 (13),
             FECH_REF VARCHAR2 (13),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.NOTA_DÉBITO_RECEB (
             NOTA_DÉBITO_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             RECEB_DATA DATE,
             MOEDA VARCHAR2 (20),
             TAXA_USD FLOAT,
             VALOR NUMBER,
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.PAÍS (
             COD VARCHAR2 (30),
             NOME VARCHAR2 (3000),
             ABREVIATURA VARCHAR2 (5),
             BANDEIRA_COD VARCHAR2 (5),
             IDIOMA VARCHAR2 (3),
             MSG VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.PARAM (
             GRUPO VARCHAR2 (30),
             PARAM VARCHAR2 (15),
             QUANDO_TEXTO VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.PED (
             REF VARCHAR2 (13),
             PED_DATA DATE,
             MOEDA VARCHAR2 (20),
             TAXA_USD FLOAT,
             VIA_TRANSPORTE VARCHAR2 (15),
             CARGA_PORTO VARCHAR2 (30),
             PAÍS_DESTINO VARCHAR2 (30),
             FORNECEDOR VARCHAR2 (30),
             FORNECEDOR_REF VARCHAR2 (50),
             FORNECEDOR_COND_RECEB VARCHAR2 (10),
             EXP VARCHAR2 (30),
             EXP_REF VARCHAR2 (50),
             EXP_COND_RECEB VARCHAR2 (10),
             IMP VARCHAR2 (30),
             IMP_REF VARCHAR2 (50),
             IMP_COND_RECEB VARCHAR2 (10),
             DISTRIBUIDOR VARCHAR2 (30),
             PAGADOR VARCHAR2 (30),
             FRETE_COND VARCHAR2 (10),
             FRETE_PREV_POR_MT NUMBER,
             FRETE_PREV_VALOR NUMBER,
             EMB_PREV DATE,
             MARCAÇÃO VARCHAR2 (3000),
             OBS VARCHAR2 (3000),
             TIPO_VENDA VARCHAR2 (10),
             GRUPO_PROD VARCHAR2 (15),
             SUPERVISOR_VENDA VARCHAR2 (20),
             PRODUÇÃO_PREV DATE,
             PARIDADE VARCHAR2 (10),
             INSPEÇÃO_EXTERNA NUMBER (5,0),
             RESPONSÁVEL_INSP_EXT VARCHAR2 (20),
             AGENTE VARCHAR2 (30),
             TAXA_JUROS_FINANCIAM NUMBER,
             JUROS_NO_PREÇO NUMBER (5,0),
             COMISSÃO_PERCENT NUMBER,
             COMISSÃO_MT NUMBER,
             ADICIONAL_PERCENT NUMBER,
             ADICIONAL_MT NUMBER,
             INCIDÊNCIA VARCHAR2 (10),
             TIPO VARCHAR2 (10),
             ANEXO VARCHAR2 (3000),
             BENEFICIÁRIO VARCHAR2 (30),
             LOCAL_PAG VARCHAR2 (50),
             BANCO VARCHAR2 (3000),
             F_QUANTIDADE NUMBER,
             F_PREÇO NUMBER,
             F_RESULTADO NUMBER,
             F_RESULTADO_MT NUMBER,
             F_RESULTADO_P FLOAT,
             F_COMISSÃO_FORN FLOAT,
             F_COMISSÃO_FORN_P FLOAT,
             F_PROFIT_SPLIT FLOAT,
             F_DELIV_PURCHASE VARCHAR2 (30),
             F_DELIV_SALES VARCHAR2 (30),
             F_PAY_PURCHASE VARCHAR2 (30),
             F_PAY_SALES VARCHAR2 (30),
             F_OBS VARCHAR2 (3000),
             FORNECEDOR_COND_VENDA VARCHAR2 (10),
             EXP_COND_VENDA VARCHAR2 (10),
             IMP_COND_VENDA VARCHAR2 (10),
             INSTRUC_INTERNA VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.PED_CONTATO (
             PED_REF VARCHAR2 (13),
             CIA_COD VARCHAR2 (30),
             CONTATO_NOME VARCHAR2 (50),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.PED_ITEM (
             PED_REF VARCHAR2 (13),
             ITEM NUMBER (5,0),
             USUÁRIO_FINAL VARCHAR2 (30),
             USUÁRIO_REF VARCHAR2 (500),
             PED_UNID VARCHAR2 (10),
             NOMINAL_PED_UNID NUMBER,
             TOTAL_FECH NUMBER (5,0),
             TOTAL_EMB NUMBER (5,0),
             TOLERÂNCIA_MIN FLOAT,
             TOLERÂNCIA_MAX FLOAT,
             PROD VARCHAR2 (30),
             DESCARGA_PORTO VARCHAR2 (30),
             EMBALAGEM VARCHAR2 (20),
             EMBALAGEM_PESO_MIN FLOAT,
             EMBALAGEM_PESO_MAX FLOAT,
             PREÇO_UNITÁRIO_FORNECEDOR NUMBER,
             PREÇO_UNITÁRIO_EXP NUMBER,
             PREÇO_UNITÁRIO_IMP NUMBER,
             ESPESSURA_TIPO VARCHAR2 (3),
             ESPESSURA_MM FLOAT,
             LARGURA_MM FLOAT,
             COMPRIMENTO_MM FLOAT,
             ESPESSURA_POL FLOAT,
             LARGURA_POL FLOAT,
             COMPRIMENTO_POL FLOAT,
             NCM VARCHAR2 (20),
             NALADI VARCHAR2 (20),
             P VARCHAR2 (20),
             LOTE VARCHAR2 (20),
             OV VARCHAR2 (20),
             NE_ITEM VARCHAR2 (20),
             NE_ENVIO VARCHAR2 (20),
             TBN VARCHAR2 (20),
             FSE VARCHAR2 (20),
             PO VARCHAR2 (20),
             BL_CODE VARCHAR2 (20),
             USO_FINAL VARCHAR2 (50),
             DIÂMETRO_INTERNO FLOAT,
             DIÂMETRO_EXTERNO FLOAT,
             PESO_POR_FOLHA FLOAT,
             AÇO_TIPO VARCHAR2 (15),
             REVESTIMENTO VARCHAR2 (15),
             TÊMPERA VARCHAR2 (15),
             ACABAMENTO VARCHAR2 (15),
             NORMA_TOLERÂNCIA VARCHAR2 (15),
             NORMA_PRODUÇÃO VARCHAR2 (15),
             BORDAS VARCHAR2 (15),
             OLEAMENTO NUMBER (5,0),
             TRAT_TÉRMICO NUMBER (5,0),
             TRAT_QUÍMICO NUMBER (5,0),
             LA NUMBER (5,0),
             LE NUMBER (5,0),
             LÍNGUA NUMBER (5,0),
             PROD_DESCR VARCHAR2 (3000),
             COMPOSIÇÃO_QUÍMICA VARCHAR2 (3000),
             MARCAÇÃO_PRODUÇÃO VARCHAR2 (3000),
             COMENTÁRIO VARCHAR2 (3000),
             PED_USINA_DATA DATE,
             PED_USINA_ID VARCHAR2 (25),
             PED_USINA_CONFIRM DATE,
             LAYDAY_INÍCIO DATE,
             LAYDAY_FINAL DATE,
             QTD_VOL NUMBER (10,0),
             PESO_LÍQUIDO NUMBER,
             PESO_BRUTO NUMBER,
             FECH_REQUISITADO DATE,
             FECH_NOTIFICADO DATE,
             CANCEL_DATA DATE,
             CANCEL_MOTIVO VARCHAR2 (3000),
             SEGURO_PERCENT NUMBER,
             CUR_PERCENT NUMBER,
             SUPERFÍCIE VARCHAR2 (2),
             DIAMET_INT_MAX_TOLER NUMBER,
             DIAMET_INT_MIM_TOLER NUMBER,
             TQ VARCHAR2 (5),
             CERTIF_QUALIDADE VARCHAR2 (25),
             RABO_PEIXE NUMBER (5,0),
             RABO_PEIXE_MAX NUMBER,
             LÍNGUA_MAX NUMBER,
             MARCAÇÃO_ESPECIAL_DOC VARCHAR2 (3000),
             OBS VARCHAR2 (3000),
             MARCAÇÃO VARCHAR2 (3000),
             NOMINAL_MT NUMBER,
             DIMENSÃO VARCHAR2(100),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.PED_LANÇ (
             PED_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             LANÇ VARCHAR2 (20),
             VALOR NUMBER,
             VALOR_POR_MT NUMBER,
             TOTAL_PERCENT FLOAT,
             TOTAL_TIPO VARCHAR2 (10),
             EXP NUMBER (5,0),
             IMP NUMBER (5,0),
             BENEFICIÁRIO VARCHAR2 (30),
             COMISSÃO_MODALIDADE VARCHAR2 (1),
             INSTRUÇÃO_REMESSA VARCHAR2 (3000),
             EXP_CALC NUMBER,
             IMP_CALC NUMBER,
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.PED_RESULT (
             PED_REF VARCHAR2 (13),
             SEQ NUMBER (5,0),
             LANÇ VARCHAR2 (20),
             VALOR NUMBER,
             VALOR_POR_MT NUMBER,
             TOTAL_PERCENT FLOAT,
             TOTAL_TIPO VARCHAR2 (10),
             COMPETÊNCIA VARCHAR2 (30),
             CALC NUMBER,
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.PORTO (
             COD VARCHAR2 (30),
             NOME VARCHAR2 (3000),
             CIDADE VARCHAR2 (50),
             ESTADO VARCHAR2 (30),
             PAÍS VARCHAR2 (30),
             RESTRIÇÕES VARCHAR2 (3000),
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.PRODUTO (
             COD VARCHAR2 (30),
             NOME VARCHAR2 (3000),
             GRUPO VARCHAR2 (10),
             NCM VARCHAR2(20),
             NALADI VARCHAR2(20),
             NCM_OBS VARCHAR2 (3000),
             NALADI_OBS VARCHAR2 (3000),
             MEDIDAS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.PRODUTO_ESPECIF (
             COD VARCHAR2 (30),
             SEQ NUMBER (5,0),
             NCM VARCHAR2 (20),
             NALADI VARCHAR2 (20),
             MENOR_ESPESSURA FLOAT,
             MAIOR_ESPESSURA FLOAT,
             MENOR_LARGURA FLOAT,
             MAIOR_LARGURA FLOAT,
             MENOR_COMPRIMENTO FLOAT,
             MAIOR_COMPRIMENTO FLOAT,
             REVESTIMENTO VARCHAR2 (15),
             TÊMPERA VARCHAR2 (15),
             DESCR VARCHAR2 (3000),
             DESCR_NALADI VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.PROG (
             FECH_REF VARCHAR2 (13),
             POSICIONAMENTO_DATA DATE,
             ARMAZÉM VARCHAR2 (50),
             TERNO_NUM NUMBER (3,0),
             FLUXO VARCHAR2 (3000),
             OBS VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.PROG_CARGA (
             FECH_REF VARCHAR2 (13),
             POSICIONAMENTO_DATA DATE,
             PED_REF VARCHAR2 (13),
             PED_ITEM NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.RAMO_ATIVIDADE (
             COD VARCHAR2 (20),
             NOME VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.REF (
             REF VARCHAR2 (13),
             TEXTO VARCHAR2 (3000),
             CANCEL NUMBER (5,0),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.REL_CSC_PAÍS_FORN_EMBARQUE (
             CHAVE VARCHAR2(65),
             ORDEM VARCHAR2(4),
             ESCRIT VARCHAR2(4),
             DIV VARCHAR2(3),
             QTD1 FLOAT,
             QTD2 FLOAT,
             PR1 FLOAT,
             PR2 FLOAT,
             RES1 FLOAT,
             RES2 FLOAT,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.REL_CSC_PAÍS_FORN_PEDIDO (
             CHAVE VARCHAR2(65),
             ORDEM VARCHAR2(4),
             ESCRIT VARCHAR2(4),
             DIV VARCHAR2(3),
             QTD1 FLOAT,
             QTD2 FLOAT,
             PR1 FLOAT,
             PR2 FLOAT,
             RES1 FLOAT,
             RES2 FLOAT,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.REL_CSC_PAÍS_FORN_RESULT (
             CHAVE VARCHAR2(65),
             ORDEM VARCHAR2(4),
             ESCRIT VARCHAR2(4),
             DIV VARCHAR2(3),
             RES1 FLOAT,
             RES2 FLOAT,
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.RESULT (
             PED_REF VARCHAR2 (13),
             EMB_SEQ NUMBER (5,0),
             SEQ NUMBER (5,0),
             INV_DATA DATE,
             RESULT1 NUMBER,
             RESULT2 NUMBER,
             RESULT3 NUMBER,
             RESULT4 NUMBER,
             RESULT5 NUMBER,
             DATA1 DATE,
             DATA2 DATE,
             DATA3 DATE,
             DATA4 DATE,
             DATA5 DATE,
             POSIÇÃO CHAR,
             OBSERVAÇÃO VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.SYS_CAD_LOG (
             SEQ NUMBER (10,0),
             NOME_TABELA VARCHAR2 (50),
             CHAVE CLOB,
             MOMENTO DATE,
             USUÁRIO VARCHAR2 (20),
             LOCAL VARCHAR2 (20),
             AÇÃO VARCHAR2 (20)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.SYS_CONFIG_GLOBAL (
             PARAM VARCHAR2 (30),
             CONFIG VARCHAR2 (4000)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.SYS_DELETE (
             NOME_TABELA VARCHAR2 (50),
             CHAVE VARCHAR2 (150),
             MOMENTO DATE,
             USUÁRIO VARCHAR2 (20),
             LOCAL VARCHAR2 (20)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.SYS_LOCALID (
             NOME VARCHAR2 (15),
             CORRENTE NUMBER (5,0),
             PACOTE NUMBER (5,0),
             PACOTE_REC NUMBER (5,0),
             MOMENTO DATE,
             MOMENTO_REC DATE,
             MODELO NUMBER (5,0),
             OBS VARCHAR2 (255)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.SYS_OCORRÊNCIA (
             SEQ NUMBER (10,0),
             APLICAÇÃO VARCHAR2 (30),
             OCORRÊNCIA VARCHAR2 (3000),
             USUÁRIO VARCHAR2 (20),
             MOMENTO DATE,
             LOCAL VARCHAR2 (20)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.SYS_TABELA (
             NOME VARCHAR2 (50),
             CHAVE VARCHAR2 (3000),
             EXPR_PRIMÁRIA VARCHAR2 (3000),
             EXPR_APRESENTA VARCHAR2 (3000),
             CAMPOS VARCHAR2 (3000),
             RELAÇÕES_1_N VARCHAR2 (3000),
             NÍVEL NUMBER (5,0)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.SYS_USUÁRIO (
             USUÁRIO VARCHAR2 (20),
             NOME VARCHAR2 (50),
             SUPERVISOR VARCHAR2 (20),
             DEPTO VARCHAR2 (10),
             MSG VARCHAR2 (3000),
             ASSINATURA BLOB,
             TEMPO_ATUALIZA NUMBER (5,0),
             FUNÇÃO VARCHAR2 (30),
             ASSINATURA_BMP BLOB
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.TIPO_REF (
             TIPO VARCHAR2 (4),
             DESCR VARCHAR2 (3000),
             DEPTO VARCHAR2 (10),
             ARQUIVO VARCHAR2 (40),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.UNID_QUANTID (
             COD VARCHAR2 (10),
             NOME VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.VIA_TRANSPORTE (
             COD VARCHAR2 (15),
             DESCR VARCHAR2 (3000),
             TIPO VARCHAR2 (3000),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.VIAGEM (
             REF VARCHAR2 (13),
             NAVIO VARCHAR2 (30),
             NAVIO_ÚLTIMO VARCHAR2 (30),
             CORRENTE NUMBER (5,0),
             OBS VARCHAR2 (255),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE TABLE CXRJ.VIAGEM_ESCALA (
             VIAGEM_REF VARCHAR2 (13),
             ESCALA NUMBER (5,0),
             PORTO VARCHAR2 (30),
             ETA DATE,
             ETS DATE,
             ATA DATE,
             ATS DATE,
             LD VARCHAR2 (1),
             OBS VARCHAR2 (50),
             SYS_MOMENTO_CRIA DATE,
             SYS_USUÁRIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USUÁRIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CXRJ_DAT;

CREATE USER ALAIR IDENTIFIED BY XXXXXX
DEFAULT TABLESPACE T_CXRJ_DAT
TEMPORARY TABLESPACE TEMP
PROFILE DEFAULT
ACCOUNT UNLOCK;
GRANT CREATE SESSION, EXECUTE ANY LIBRARY, EXECUTE ANY PROCEDURE TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.BL TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.BL_CARGA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.BL_CONTINENTAL TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.CARTA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.CARTA_CRÉDITO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.CARTA_FECH TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.CIA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.CIA_CONTATO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.CIA_RAMO_ATIVIDADE TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.COND_PAG TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.CONFIRM_VENDA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.CONFIRM_VENDA_ITEM TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.CONTA_CORRENTE TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.COSIPA_FOLHA_1 TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.COSIPA_FOLHA_2 TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.COSIPA_FOLHA_2_PAG TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.COSIPA_NEGOCIAÇÃO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DEPTO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DIVISÃO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DIVISÃO_PRODUTO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DIVISÃO_TIPO_REF TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_ACORDO_COMPLEM TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_ACORDO_COMPLEM_DET TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_ALADI TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_ALADI_DET TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_ALADI_NORMA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_BORDERÔ_I TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_BORDERÔ_P TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_CÂMARA_COMÉRCIO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_CÂMARA_COMÉRCIO_DET TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_CARTA_I TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_CARTA_P TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_CONHECIMENT_ROD TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_CONHECIMENT_ROD_DET TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_FATURA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_FATURA_DET TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_FATURA_JUROS TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_FATURA_TOT TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_FECHAMENTO_CÂMB TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_FECHAMENTO_CÂMB_TOT TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_FIRJAN TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_FIRJAN_DET TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_MERCOSUL TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_MERCOSUL_BOLIV TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_MERCOSUL_BOLIV_DET TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_MERCOSUL_BOLIV_NORMA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_MERCOSUL_CHILE TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_MERCOSUL_CHILE_DET TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_MERCOSUL_CHILE_NORMA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_MERCOSUL_DET TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_MERCOSUL_NORMA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_PLIST_WEIG_CERT TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_PLIST_WEIG_CERT_DET TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_SAQUE_2V TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_SAQUE_3V TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_SAQUE_JUROS_2V TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.DOC_SAQUE_JUROS_3V TO ALAIR;
GRANT SELECT ON CXRJ.DOC_TEMPLATE TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB_CHECK_LIST TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB_DOC TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB_DOC_DESTINO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB_DOC_REL TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB_F TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB_FAMÍLIA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB_FAMÍLIA_GENÉRICA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB_FILTRO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB_ITEM_TEMP TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB_LANÇ TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB_MENSAGEM TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB_RE TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB_SD TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.EMB_TOTALIZA TO ALAIR;
GRANT SELECT ON CXRJ.EMBALAGEM TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.ESCRITÓRIO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.ETIQ_MALA_DIRETA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.FATURA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.FAX TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.FAX_CHAVE TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.FAX_DESTINO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.FECH TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.FECH_CARGA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.FECH_CONTATO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.FECH_SUBSTITUÍDO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.FRETE TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.GRUPO_PRODUTO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.IDIOMA TO ALAIR;
GRANT SELECT ON CXRJ.INCOTERM TO ALAIR;
GRANT SELECT ON CXRJ.INCOTERM_LANÇ TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.INSTRUÇÃO_PAG TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.INSTRUÇÃO_PAG_FECH TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.LANÇ TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.LOCAL_RESULT TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.MERCADO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.MERCADO_PORTO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.MODALIDADE_FRETE TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.MOEDA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.NAVIO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.NOTA_CRÉDITO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.NOTA_CRÉDITO_FECH TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.NOTA_CRÉDITO_PAG TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.NOTA_DÉBITO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.NOTA_DÉBITO_FECH TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.NOTA_DÉBITO_RECEB TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.PAÍS TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.PARAM TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.PED TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.PED_CONTATO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.PED_ITEM TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.PED_LANÇ TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.PED_RESULT TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.PORTO TO ALAIR;
GRANT SELECT ON CXRJ.PRODUTO TO ALAIR;
GRANT SELECT ON CXRJ.PRODUTO_ESPECIF TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.PROG TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.PROG_CARGA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.RAMO_ATIVIDADE TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.REF TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.RESULT TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.SYS_CAD_LOG TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.SYS_CONFIG_GLOBAL TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.SYS_DELETE TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.SYS_LOCALID TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.SYS_OCORRÊNCIA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.SYS_TABELA TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.SYS_USUÁRIO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.TIPO_REF TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.UNID_QUANTID TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.VIA_TRANSPORTE TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.VIAGEM TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.VIAGEM_ESCALA TO ALAIR;
GRANT SELECT ON CXRJ.ACORDO_COMPLEMENTAÇÃO TO ALAIR;
GRANT SELECT ON CXRJ.ALADI_EXP TO ALAIR;
GRANT SELECT ON CXRJ.ALADI_IMP TO ALAIR;
GRANT SELECT ON CXRJ.ALADI_SUB TO ALAIR;
GRANT SELECT ON CXRJ.BL_CARGA_OK TO ALAIR;
GRANT SELECT ON CXRJ.BORDERO TO ALAIR;
GRANT SELECT ON CXRJ.BORDERO_EMB_DOC_REL TO ALAIR;
GRANT SELECT ON CXRJ.BORDERO_EXP TO ALAIR;
GRANT SELECT ON CXRJ.BORDERO_EXP_SUB TO ALAIR;
GRANT SELECT ON CXRJ.BORDERO_IMP TO ALAIR;
GRANT SELECT ON CXRJ.CAM_COM_EMB_DOC_REL TO ALAIR;
GRANT SELECT ON CXRJ.CAMARA_COMERCIO_EXP TO ALAIR;
GRANT SELECT ON CXRJ.CAMARA_COMERCIO_EXP_SUB TO ALAIR;
GRANT SELECT ON CXRJ.CAMARA_COMERCIO_IMP TO ALAIR;
GRANT SELECT ON CXRJ.CAMARA_COMERCIO_IMP_SUB TO ALAIR;
GRANT SELECT ON CXRJ.CAPA TO ALAIR;
GRANT SELECT ON CXRJ.CAPA_PACKING_LIST TO ALAIR;
GRANT SELECT ON CXRJ.CARGO_LEVANT TO ALAIR;
GRANT SELECT ON CXRJ.CARGO_LEVANT_SUB TO ALAIR;
GRANT SELECT ON CXRJ.CARTA_DEOP_INGLES TO ALAIR;
GRANT SELECT ON CXRJ.CARTA_DEOP_PORTUGUES TO ALAIR;
GRANT SELECT ON CXRJ.CHECK_LIST_SUB TO ALAIR;
GRANT SELECT ON CXRJ.CONHECIM_RODOV_EXP TO ALAIR;
GRANT SELECT ON CXRJ.CONHECIM_RODOV_IMP TO ALAIR;
GRANT SELECT ON CXRJ.EMB_COM_SOMA_QUANT TO ALAIR;
GRANT SELECT ON CXRJ.EMB_DESP_EXP TO ALAIR;
GRANT SELECT ON CXRJ.EMB_DESP_IMP TO ALAIR;
GRANT SELECT ON CXRJ.EMB_PARAM TO ALAIR;
GRANT SELECT ON CXRJ.EMB_PARAM_FIX TO ALAIR;
GRANT SELECT ON CXRJ.EMB_QTD TO ALAIR;
GRANT SELECT ON CXRJ.EMB_TOT_EXP TO ALAIR;
GRANT SELECT ON CXRJ.EMB_TOT_IMP TO ALAIR;
GRANT SELECT ON CXRJ.FATURA_EXP TO ALAIR;
GRANT SELECT ON CXRJ.FATURA_EXP_SUB TO ALAIR;
GRANT SELECT ON CXRJ.FATURA_IMP TO ALAIR;
GRANT SELECT ON CXRJ.FATURA_IMP_SUB TO ALAIR;
GRANT SELECT ON CXRJ.FATURA_ITF_1_SUB TO ALAIR;
GRANT SELECT ON CXRJ.FATURA_JUROS_EMB_DOC_REL TO ALAIR;
GRANT SELECT ON CXRJ.FATURA_JUROS_EXP TO ALAIR;
GRANT SELECT ON CXRJ.FATURA_JUROS_IMP TO ALAIR;
GRANT SELECT ON CXRJ.FATURA_JUROS_VALORES TO ALAIR;
GRANT SELECT ON CXRJ.FATURA_TOTAL_GERAL_VALORES TO ALAIR;
GRANT SELECT ON CXRJ.FAX_2 TO ALAIR;
GRANT SELECT ON CXRJ.FAX_2_CSN TO ALAIR;
GRANT SELECT ON CXRJ.FAX_CHAVE_REF TO ALAIR;
GRANT SELECT ON CXRJ.FAX_CONT_EST_D TO ALAIR;
GRANT SELECT ON CXRJ.FAX_CONT_EST_L TO ALAIR;
GRANT SELECT ON CXRJ.FAX_FECH TO ALAIR;
GRANT SELECT ON CXRJ.FAX_FECH_2 TO ALAIR;
GRANT SELECT ON CXRJ.FAX_NOM_EST_AG_D TO ALAIR;
GRANT SELECT ON CXRJ.FAX_NOM_NAV_CONT TO ALAIR;
GRANT SELECT ON CXRJ.FAX_NOM_NAV_CSN TO ALAIR;
GRANT SELECT ON CXRJ.FAX_NOM_NAV_CSN_FC TO ALAIR;
GRANT SELECT ON CXRJ.FAX_NOM_NAV_FOR TO ALAIR;
GRANT SELECT ON CXRJ.FAX_NOM_NAV_FOR_FC TO ALAIR;
GRANT SELECT ON CXRJ.FAX_NOM_TER_EST TO ALAIR;
GRANT SELECT ON CXRJ.FAX_SOL_POS_CAR_EMB TO ALAIR;
GRANT SELECT ON CXRJ.FECH_CAMBIO_SUB TO ALAIR;
GRANT SELECT ON CXRJ.FECH_CARGA_OK TO ALAIR;
GRANT SELECT ON CXRJ.FECH_DET TO ALAIR;
GRANT SELECT ON CXRJ.FECH_DET_1 TO ALAIR;
GRANT SELECT ON CXRJ.FECH_DET_4 TO ALAIR;
GRANT SELECT ON CXRJ.FECH_DET_6 TO ALAIR;
GRANT SELECT ON CXRJ.FECH_DET_7 TO ALAIR;
GRANT SELECT ON CXRJ.FECH_NCANCEL TO ALAIR;
GRANT SELECT ON CXRJ.FECHAM_CAMBIO TO ALAIR;
GRANT SELECT ON CXRJ.FIRJAN_EXP TO ALAIR;
GRANT SELECT ON CXRJ.FIRJAN_EXP_SUB TO ALAIR;
GRANT SELECT ON CXRJ.FIRJAN_IMP TO ALAIR;
GRANT SELECT ON CXRJ.FIRJAN_IMP_SUB TO ALAIR;
GRANT SELECT ON CXRJ.INS_EMB TO ALAIR;
GRANT SELECT ON CXRJ.INS_EMB_NAV TO ALAIR;
GRANT SELECT ON CXRJ.INS_PAG_1 TO ALAIR;
GRANT SELECT ON CXRJ.INSTRUÇÃO_DE_EMBARQUE TO ALAIR;
GRANT SELECT ON CXRJ.INSTRUÇÃO_PAG_1 TO ALAIR;
GRANT SELECT ON CXRJ.ITEM_FECHADO TO ALAIR;
GRANT SELECT ON CXRJ.MAP_CAR TO ALAIR;
GRANT SELECT ON CXRJ.MAP_CAR_1 TO ALAIR;
GRANT SELECT ON CXRJ.MAP_CAR_2 TO ALAIR;
GRANT SELECT ON CXRJ.MERCOSUL_BOLIVIA_EXP TO ALAIR;
GRANT SELECT ON CXRJ.MERCOSUL_BOLIVIA_EXP_SUB TO ALAIR;
GRANT SELECT ON CXRJ.MERCOSUL_BOLIVIA_IMP TO ALAIR;
GRANT SELECT ON CXRJ.MERCOSUL_BOLIVIA_IMP_SUB TO ALAIR;
GRANT SELECT ON CXRJ.MERCOSUL_CHILE_EXP TO ALAIR;
GRANT SELECT ON CXRJ.MERCOSUL_CHILE_EXP_SUB TO ALAIR;
GRANT SELECT ON CXRJ.MERCOSUL_CHILE_IMP TO ALAIR;
GRANT SELECT ON CXRJ.MERCOSUL_CHILE_IMP_SUB TO ALAIR;
GRANT SELECT ON CXRJ.MERCOSUL_EXP TO ALAIR;
GRANT SELECT ON CXRJ.MERCOSUL_EXP_SUB TO ALAIR;
GRANT SELECT ON CXRJ.MERCOSUL_IMP TO ALAIR;
GRANT SELECT ON CXRJ.MERCOSUL_IMP_SUB TO ALAIR;
GRANT SELECT ON CXRJ.NEG_FECH_ANA_QUANT TO ALAIR;
GRANT SELECT ON CXRJ.NEG_FECH_ANA_SUBFIN TO ALAIR;
GRANT SELECT ON CXRJ.NEGOCIO_COMERCIAL_NAVIO TO ALAIR;
GRANT SELECT ON CXRJ.PACKING_LIST_EXP TO ALAIR;
GRANT SELECT ON CXRJ.PACKING_LIST_IMP TO ALAIR;
GRANT SELECT ON CXRJ.PED_AFR_4 TO ALAIR;
GRANT SELECT ON CXRJ.PED_AFR_6 TO ALAIR;
GRANT SELECT ON CXRJ.PED_AFR_7 TO ALAIR;
GRANT SELECT ON CXRJ.PED_AFR_8 TO ALAIR;
GRANT SELECT ON CXRJ.PED_DETAL_10 TO ALAIR;
GRANT SELECT ON CXRJ.PED_ITEM_OK TO ALAIR;
GRANT SELECT ON CXRJ.PED_ITEM_SALDO TO ALAIR;
GRANT SELECT ON CXRJ.RESULT_VERTICAL TO ALAIR;
GRANT SELECT ON CXRJ.SAQUE_EMB_DOC_REL TO ALAIR;
GRANT SELECT ON CXRJ.SAQUE_EXP_2_VIAS TO ALAIR;
GRANT SELECT ON CXRJ.SAQUE_EXP_3_VIAS TO ALAIR;
GRANT SELECT ON CXRJ.SAQUE_IMP_2_VIAS TO ALAIR;
GRANT SELECT ON CXRJ.SAQUE_IMP_3_VIAS TO ALAIR;
GRANT SELECT ON CXRJ.SAQUE_JUROS_EMB_DOC_REL TO ALAIR;
GRANT SELECT ON CXRJ.SAQUE_JUROS_EXP_2_VIAS TO ALAIR;
GRANT SELECT ON CXRJ.SAQUE_JUROS_EXP_3_VIAS TO ALAIR;
GRANT SELECT ON CXRJ.SAQUE_JUROS_IMP_2_VIAS TO ALAIR;
GRANT SELECT ON CXRJ.SAQUE_JUROS_IMP_3_VIAS TO ALAIR;
GRANT SELECT ON CXRJ.SOL_POS_CARGA TO ALAIR;
GRANT SELECT ON CXRJ.TBS TO ALAIR;
GRANT SELECT ON CXRJ.TBS_SUB TO ALAIR;
GRANT SELECT ON CXRJ.TESTE TO ALAIR;
GRANT SELECT ON CXRJ.VALIDA_NOMEA_CSN TO ALAIR;
GRANT SELECT ON CXRJ.VALIDA_NOMEA_NAV_FALTA TO ALAIR;
GRANT SELECT ON CXRJ.VIAGEM_SEL TO ALAIR;
GRANT SELECT ON CXRJ.WEIGHT_CERTIFICATE_EXP TO ALAIR;
GRANT SELECT ON CXRJ.WEIGHT_CERTIFICATE_IMP TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.FATURA_CONFIRM TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.FATURA_CONFIRM_ITEM TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.REL_CSC_PAÍS_FORN_EMBARQUE TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.REL_CSC_PAÍS_FORN_PEDIDO TO ALAIR;
GRANT SELECT, INSERT, UPDATE, DELETE ON CXRJ.REL_CSC_PAÍS_FORN_RESULT TO ALAIR;

