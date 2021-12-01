
drop database 'c:\almod2.fdb';
create database 'c:\almod2.fdb';

CREATE TABLE ACESSO (
             "LOGIN" VARCHAR (30) NOT NULL,
             "CLIENTE" VARCHAR (30),
             "DEPTO" VARCHAR (50),
             "USUÁRIO" VARCHAR (30),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE ACESSO ADD CONSTRAINT ID_ACESSO
PRIMARY KEY ("LOGIN");

CREATE TABLE CD (
             "ID" VARCHAR (13) NOT NULL,
             "NUM" VARCHAR (4),
             "TÍTULO" VARCHAR (200),
             "DATA" DATE,
             "CLASSE" VARCHAR (100),
             "CONTEÚDO" BLOB,
             "USUÁRIO" VARCHAR (300),
             "MOMENTO" DATE,
             "OBS" VARCHAR (200),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE CD ADD CONSTRAINT ID_CD
PRIMARY KEY ("ID");

CREATE TABLE CLASSE (
             "NOME" VARCHAR (100) NOT NULL,
             "PREF" VARCHAR (3),
             "LOC" VARCHAR (100),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE CLASSE ADD CONSTRAINT ID_CLASSE
PRIMARY KEY ("NOME");

CREATE TABLE CLASSIF (
             "CONTA" VARCHAR (30) NOT NULL,
             "CLASSE" VARCHAR (50) NOT NULL,
             "DESCRIÇÃO" VARCHAR (150),
             "OBS" VARCHAR (300),
             "TIPO" VARCHAR (50),
             "MARCA_PEND" NUMERIC (5,0),
             "TRAT" NUMERIC (5,0),
             "VALOR" FLOAT,
             "CENTRO" VARCHAR (100),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE CLASSIF ADD CONSTRAINT ID_CSIF
PRIMARY KEY ("CONTA", "CLASSE");

CREATE TABLE CLIENTE (
             "NOME" VARCHAR (30) NOT NULL,
             "RAZÃO_SOCIAL" VARCHAR (40),
             "OBRIGATÓRIO" VARCHAR (50),
             "ORDEM" NUMERIC (5,0),
             "REQ_DEPTO" NUMERIC (5,0),
             "REQ_USUÁRIO" NUMERIC (5,0),
             "REQ_PROJETO" NUMERIC (5,0),
             "NOTIFIC_EMAIL" VARCHAR (200),
             "INSCR_MUNICIPAL" VARCHAR (15),
             "INSCR_ESTADUAL" VARCHAR (15),
             "COB_ENDEREÇO" VARCHAR (40),
             "COB_BAIRRO" VARCHAR (20),
             "COB_CIDADE" VARCHAR (15),
             "COB_ESTADO" VARCHAR (2),
             "COB_CEP" VARCHAR (9),
             "NOTA_ENDEREÇO" VARCHAR (40),
             "NOTA_BAIRRO" VARCHAR (20),
             "NOTA_CIDADE" VARCHAR (15),
             "NOTA_ESTADO" VARCHAR (2),
             "NOTA_CEP" VARCHAR (9),
             "CNPJ" VARCHAR (20),
             "CPF" VARCHAR (20),
             "DEMO_ATÉ" DATE,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE CLIENTE ADD CONSTRAINT ID_CLIENTE
PRIMARY KEY ("NOME");

CREATE TABLE COBRARQ (
             "SEU_NUM" VARCHAR (10) NOT NULL,
             "SACADO_NOME" VARCHAR (40),
             "SACADO_ENDEREÇO" VARCHAR (40),
             "SACADO_CIDADE" VARCHAR (15),
             "SACADO_ESTADO" VARCHAR (2),
             "SACADO_CEP" VARCHAR (9),
             "SACADO_NUM_INSCR" VARCHAR (14),
             "BANCO_DEP" VARCHAR (3),
             "DATA_EMISSÃO" VARCHAR (6),
             "DATA_VENCIM" VARCHAR (6),
             "DATA_DESC_ATÉ" VARCHAR (6),
             "VALOR_DOC" NUMERIC (8,2),
             "VALOR_DESC" NUMERIC (8,2),
             "ESPÉCIE_TÍTULO" VARCHAR (2),
             "ACEITE" VARCHAR (1),
             "SACADO_CEP_SUFIXO" VARCHAR (3),
             "SACADO_TIPO_INSCR" VARCHAR (2),
             "NOSSO_NUM" VARCHAR (8),
             "LOTE" NUMERIC (5,0),
             "LOTE_ENVIO_DATA" DATE,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE COBRARQ ADD CONSTRAINT ID_COBRARQ
PRIMARY KEY ("SEU_NUM");

CREATE TABLE CONJ_IMPRESS (
             "DEFINIÇÃO" VARCHAR (50) NOT NULL,
             "DEFINIÇÃO_SEQ" NUMERIC (5,0) NOT NULL,
             "ITEM" NUMERIC (5,0) NOT NULL,
             "REL" VARCHAR (50),
             "ARQUIVO" VARCHAR (150),
             "FILTRO" VARCHAR (2000),
             "GERAÇÃO_MOMENTO" DATE,
             "IMPRESSÃO_MOMENTO" DATE,
             "NOTIFIC_EMAIL" VARCHAR (200),
             "NOTIFIC_MOMENTO" DATE,
             "RESULT" VARCHAR (1500),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE CONJ_IMPRESS ADD CONSTRAINT ID_CONJ_IMPRESS
PRIMARY KEY ("DEFINIÇÃO", "DEFINIÇÃO_SEQ", "ITEM");

CREATE TABLE CONJ_REL (
             "DEFINIÇÃO" VARCHAR (50) NOT NULL,
             "SEQ" NUMERIC (5,0) NOT NULL,
             "TÉCNICO" VARCHAR (200),
             "CLIENTE" VARCHAR (200),
             "DEPTO" VARCHAR (300),
             "USUÁRIO" VARCHAR (2000),
             "GRUPO_PROJETO" VARCHAR (300),
             "TIPO_TAREFA" VARCHAR (200),
             "MÁQUINA" VARCHAR (2000),
             "PERÍODO_DE" DATE,
             "PERÍODO_ATÉ" DATE,
             "DUR_MIN" NUMERIC (5,0),
             "RELATÓRIOS" VARCHAR (300),
             "NOME_ARQ" VARCHAR (200),
             "ARQ" VARCHAR (150),
             "TIPO_HORA" NUMERIC (5,0),
             "QUEBRA_USU" NUMERIC (5,0),
             "NOTIFIC_IMEDIATO" NUMERIC (5,0),
             "NOTIFIC_EMAIL" VARCHAR (200),
             "NOTIFIC_AOCLIENTE" NUMERIC (5,0),
             "NOTIFIC_AODEPTO" NUMERIC (5,0),
             "NOTIFIC_AOUSUÁRIO" NUMERIC (5,0),
             "NOTIFIC_AOTÉCNICO" NUMERIC (5,0),
             "LOG" VARCHAR (3000),
             "DATA_ACUMULA" DATE,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE CONJ_REL ADD CONSTRAINT ID_CONJ_REL
PRIMARY KEY ("DEFINIÇÃO", "SEQ");

CREATE TABLE CONTA (
             "CONTA" VARCHAR (30) NOT NULL,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE CONTA ADD CONSTRAINT ID_CONTA
PRIMARY KEY ("CONTA");

CREATE TABLE CONTATO (
             "SEQ" NUMERIC (5,0) NOT NULL,
             "EMPRESA" VARCHAR (300),
             "CONTATO" VARCHAR (300),
             "TELEFONE" VARCHAR (1000),
             "FAX" VARCHAR (500),
             "EMAIL" VARCHAR (500),
             "ENDEREÇO" VARCHAR (500),
             "OBS" VARCHAR (2000),
             "CLASSE" VARCHAR (30),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE CONTATO ADD CONSTRAINT ID_CONTATO
PRIMARY KEY ("SEQ");

CREATE TABLE CONTRATO (
             "REF" VARCHAR (10) NOT NULL,
             "ADITIVO" NUMERIC (5,0) NOT NULL,
             "CLIENTE" VARCHAR (30),
             "DESCRIÇÃO" VARCHAR (30),
             "OBS" VARCHAR (200),
             "DATA_INICIAL" DATE,
             "VALIDADE" NUMERIC (5,0),
             "DATA_ENCERRA" DATE,
             "QTD_EMAIL_DOM_COMUM" NUMERIC (5,0),
             "QTD_EMAIL_DOM_HOSP" NUMERIC (5,0),
             "DOM_HOSP" VARCHAR (200),
             "DOM_PRÓPRIO" VARCHAR (200),
             "QTD_HORAS_CONTRATO" NUMERIC (5,0),
             "QTD_MÁQUINAS" NUMERIC (5,0),
             "QTD_ACESSOS_LANNET" NUMERIC (5,0),
             "QTD_ACESSOS_DISCADOS" NUMERIC (5,0),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE CONTRATO ADD CONSTRAINT ID_CONTRATO
PRIMARY KEY ("REF", "ADITIVO");

CREATE TABLE CONTRATO_FIN (
             "REF" VARCHAR (10) NOT NULL,
             "ADITIVO" NUMERIC (5,0) NOT NULL,
             "PERIODIC_PAG" NUMERIC (5,0),
             "OBS_FIN" VARCHAR (200),
             "VALOR" FLOAT,
             "VENCIM_DIA" NUMERIC (5,0),
             "MORA_PERCENT" NUMERIC (5,2),
             "MORA_VALOR" NUMERIC (5,2),
             "JUROS_PERCENT" NUMERIC (5,2),
             "JUROS_VALOR" NUMERIC (5,2),
             "DESC_DIA" NUMERIC (5,2),
             "DESC_PERCENT" NUMERIC (5,2),
             "DESC_VALOR" NUMERIC (5,2),
             "CONTA_CONTAB" VARCHAR (30),
             "CLASSIF_CONTAB" VARCHAR (70),
             "TIPO_COBRANÇA" VARCHAR (20),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE CONTRATO_FIN ADD CONSTRAINT ID_CONTRATO_FIN
PRIMARY KEY ("REF", "ADITIVO");

CREATE TABLE CONTROLE (
             "CONTA" VARCHAR (30) NOT NULL,
             "CONTROLE" VARCHAR (30) NOT NULL,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE CONTROLE ADD CONSTRAINT ID_CONTROLE
PRIMARY KEY ("CONTA", "CONTROLE");

CREATE TABLE CRONO_NOTIF (
             "CRONO_SEQ" NUMERIC (5,0) NOT NULL,
             "ITEM" NUMERIC (5,0) NOT NULL,
             "AVISAR_QUANDO_INCLUIR" NUMERIC (5,0),
             "AVISAR_QUANDO_MUDAR" NUMERIC (5,0),
             "AVISAR_QUANDO_EXCLUIR" NUMERIC (5,0),
             "AVISAR_ANTES" NUMERIC (5,0),
             "AVISAR_ANTES_HORAS" FLOAT,
             "AVISAR_ANTES_VEZES" NUMERIC (5,0),
             "AVISAR_ANTES_INTERVALO" FLOAT,
             "AVISAR_DEPOIS" NUMERIC (5,0),
             "AVISAR_DEPOIS_HORAS" FLOAT,
             "AVISAR_DEPOIS_VEZES" NUMERIC (5,0),
             "AVISAR_DEPOIS_INTERVALO" FLOAT,
             "EMAILS" VARCHAR (200),
             "ÚLTIMO_AVISO" DATE,
             "NÃO_AVISAR_MAIS" NUMERIC (5,0),
             "INCLUIR_CLIENTE_PROJETO" NUMERIC (5,0),
             "INCLUIR_ETAPA" NUMERIC (5,0),
             "INCLUIR_OBS" NUMERIC (5,0),
             "INCLUIR_OBS_ADM" NUMERIC (5,0),
             "INCLUIR_TEXTO" VARCHAR (200),
             "ENTIDADES" VARCHAR (10),
             "EVENTOS" VARCHAR (10),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE CRONO_NOTIF ADD CONSTRAINT ID_CRONO_NOTIF
PRIMARY KEY ("CRONO_SEQ", "ITEM");

CREATE TABLE CRONOGRAMA (
             "SEQ" NUMERIC (5,0) NOT NULL,
             "CLIENTE" VARCHAR (30),
             "PROJETO" VARCHAR (30),
             "ETAPA" VARCHAR (1000),
             "OBS" VARCHAR (2000),
             "DESENVOLVEDOR" VARCHAR (100),
             "SUPORTE" VARCHAR (100),
             "ADMINISTRADOR" VARCHAR (100),
             "DURAÇÃO" NUMERIC (5,0),
             "CRIADOR" VARCHAR (100),
             "CRIAÇÃO" DATE,
             "DELEGAÇÃO" DATE,
             "PREVISÃO" DATE,
             "PREVISÃO_ADM" DATE,
             "NOVA_PREV" DATE,
             "NOVA_OBS" VARCHAR (2000),
             "REALIZAÇÃO" DATE,
             "CONFIRMAÇÃO" DATE,
             "CONFIRMADOR" VARCHAR (100),
             "CONFIRMAÇÃO_ADM" DATE,
             "OBS_ADM" VARCHAR (2000),
             "CONTÍNUA" NUMERIC (5,0),
             "SUPERSEQ" NUMERIC (5,0),
             "CONSOLID" VARCHAR (50),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE CRONOGRAMA ADD CONSTRAINT ID_CRONO
PRIMARY KEY ("SEQ");

CREATE TABLE DEPTO (
             "CLIENTE" VARCHAR (30) NOT NULL,
             "DEPTO" VARCHAR (50) NOT NULL,
             "MARCA" VARCHAR (10),
             "SITUAÇÃO" NUMERIC (5,0),
             "NOTIFIC_EMAIL" VARCHAR (200),
             "CANCEL" DATE,
             "RATEIO" NUMERIC (5,2),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE DEPTO ADD CONSTRAINT ID_DEPTO
PRIMARY KEY ("CLIENTE", "DEPTO");

CREATE TABLE DESC_S_PROG (
             "SEQ" NUMERIC (5,0) NOT NULL,
             "ENTRADA" FLOAT,
             "SAÍDA" FLOAT,
             "CONTROLE" VARCHAR (30),
             "CLASSE" VARCHAR (50),
             "HISTÓRICO" VARCHAR (2000),
             "EVENTO" VARCHAR (200),
             "SÓCIO" VARCHAR (30),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE DESC_S_PROG ADD CONSTRAINT ID_DESC_S_PROG
PRIMARY KEY ("SEQ");

CREATE TABLE DISTRIB_CUSTO_RECEITA (
             "CONTA" VARCHAR (30) NOT NULL,
             "CENTRO_CUSTO" VARCHAR (100) NOT NULL,
             "CENTRO_RECEITA" VARCHAR (100) NOT NULL,
             "PERCENT" FLOAT,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE DISTRIB_CUSTO_RECEITA ADD CONSTRAINT ID_DISTR_CUSTO_REC
PRIMARY KEY ("CONTA", "CENTRO_CUSTO", "CENTRO_RECEITA");

CREATE TABLE DISTRIB_FUNCIL_RECEITA (
             "CONTA" VARCHAR (30) NOT NULL,
             "FUNCIL" VARCHAR (100) NOT NULL,
             "CENTRO_RECEITA" VARCHAR (100) NOT NULL,
             "PERCENT" FLOAT,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE DISTRIB_FUNCIL_RECEITA ADD CONSTRAINT ID_DISTR_FUNCIL_REC
PRIMARY KEY ("CONTA", "FUNCIL", "CENTRO_RECEITA");

CREATE TABLE ESCALA (
             "SEQ" NUMERIC (5,0) NOT NULL,
             "DATA" DATE,
             "TÉCNICO" VARCHAR (30),
             "TIPO" VARCHAR (4),
             "OBS" VARCHAR (2000),
             "DATA_REL" DATE,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE ESCALA ADD CONSTRAINT ID_ESCALA
PRIMARY KEY ("SEQ");

CREATE TABLE ESCALA_TIPO (
             "TIPO" VARCHAR (4) NOT NULL,
             "DESCR" VARCHAR (50),
             "PARAM" VARCHAR (100),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE ESCALA_TIPO ADD CONSTRAINT ID_ESCALA_TIPO
PRIMARY KEY ("TIPO");

CREATE TABLE GRUPO (
             "CLIENTE" VARCHAR (30) NOT NULL,
             "GRUPO" VARCHAR (50) NOT NULL,
             "SUPERGRUPO" VARCHAR (50),
             "ORDEM" NUMERIC (5,0),
             "DEPENDE" NUMERIC (5,0),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE GRUPO ADD CONSTRAINT ID_GRUPO
PRIMARY KEY ("CLIENTE", "GRUPO");

CREATE TABLE HIERARQUIA (
             "CLIENTE" VARCHAR (30) NOT NULL,
             "CLASSIF" VARCHAR (30) NOT NULL,
             "CLASSE" VARCHAR (30),
             "SUPER" VARCHAR (30),
             "LISTA" VARCHAR (400),
             "TIPO" CHAR,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE HIERARQUIA ADD CONSTRAINT ID_HIERARQ
PRIMARY KEY ("CLIENTE", "CLASSIF");

CREATE TABLE IDENTIF (
             "CLIENTE" VARCHAR (30) NOT NULL,
             "USUÁRIO" VARCHAR (30) NOT NULL,
             "TIPO_IDENTIF" VARCHAR (30) NOT NULL,
             "IDENTIF" VARCHAR (100) NOT NULL,
             "SENHA" VARCHAR (30),
             "SENHA2" VARCHAR (30),
             "OBS" VARCHAR (1000),
             "SEC_ID" NUMERIC (5,0),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE IDENTIF ADD CONSTRAINT ID_IDENTIF
PRIMARY KEY ("CLIENTE", "USUÁRIO", "TIPO_IDENTIF", "IDENTIF");

CREATE TABLE IP (
             "CLIENTE" VARCHAR (30) NOT NULL,
             "MÁQUINA" VARCHAR (30) NOT NULL,
             "REDE_CLIENTE" VARCHAR (30) NOT NULL,
             "REDE_IDENTIF" VARCHAR (30) NOT NULL,
             "IP" VARCHAR (30) NOT NULL,
             "ROTEADOR" VARCHAR (30),
             "DNS" VARCHAR (50),
             "MAC" VARCHAR (30),
             "SUBNET_HOST_ID" NUMERIC (5,0),
             "OBS" VARCHAR (1000),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE IP ADD CONSTRAINT ID_IP
PRIMARY KEY ("CLIENTE", "MÁQUINA", "REDE_CLIENTE", "REDE_IDENTIF", "IP");

CREATE TABLE LICENÇA (
             "SEQ" NUMERIC (5,0) NOT NULL,
             "RECURSO" VARCHAR (100),
             "CÓDIGO" VARCHAR (50),
             "OBS" VARCHAR (300),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE LICENÇA ADD CONSTRAINT ID_LICENÇA
PRIMARY KEY ("SEQ");

CREATE TABLE MÁQUINA (
             "CLIENTE" VARCHAR (30) NOT NULL,
             "MÁQUINA" VARCHAR (30) NOT NULL,
             "USUÁRIO" VARCHAR (30),
             "OBS" VARCHAR (1000),
             "SENHA" VARCHAR (30),
             "SEC_ID" NUMERIC (5,0),
             "TIPO" VARCHAR (30),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE MÁQUINA ADD CONSTRAINT ID_MÁQUINA
PRIMARY KEY ("CLIENTE", "MÁQUINA");

CREATE TABLE MÁQUINA_RECURSO (
             "CLIENTE" VARCHAR (30) NOT NULL,
             "MÁQUINA" VARCHAR (30) NOT NULL,
             "RECURSO" VARCHAR (50) NOT NULL,
             "COMPLEMENTO" VARCHAR (1000),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE MÁQUINA_RECURSO ADD CONSTRAINT ID_MÁQ_REC
PRIMARY KEY ("CLIENTE", "MÁQUINA", "RECURSO");

CREATE TABLE MEMO (
             "SEQ" NUMERIC (5,0) NOT NULL,
             "INCLUSÃO_REF" DATE,
             "INCLUSÃO_USUÁRIO" VARCHAR (30),
             "MANUTENÇÃO_RESP" VARCHAR (100),
             "DESCRIÇÃO" VARCHAR (100),
             "DETALHES" VARCHAR (4000),
             "TIPO" VARCHAR (50),
             "SITUAÇÃO" VARCHAR (30),
             "SUBSTITUTO" NUMERIC (5,0),
             "CANCEL" DATE,
             "ANEXO" BLOB,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE MEMO ADD CONSTRAINT ID_MEMO
PRIMARY KEY ("SEQ");

CREATE TABLE MEMO_SITUAÇÃO (
             "SITUAÇÃO" VARCHAR (30) NOT NULL,
             "ORDEM" NUMERIC (5,0),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE MEMO_SITUAÇÃO ADD CONSTRAINT ID_MEMO_SITUAÇÃO
PRIMARY KEY ("SITUAÇÃO");

CREATE TABLE MEMO_TIPO (
             "TIPO" VARCHAR (50) NOT NULL,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE MEMO_TIPO ADD CONSTRAINT ID_MEMO_TIPO
PRIMARY KEY ("TIPO");

CREATE TABLE MOVIMENTO (
             "CONTA" VARCHAR (30) NOT NULL,
             "SEQ" NUMERIC (5,0) NOT NULL,
             "DATA" DATE,
             "REF" DATE,
             "SAÍDA" FLOAT,
             "ENTRADA" FLOAT,
             "HISTÓRICO" VARCHAR (2000),
             "CLASSE" VARCHAR (50),
             "EVENTO" VARCHAR (200),
             "PENDÊNCIA" NUMERIC (5,0),
             "OPERADOR" VARCHAR (30),
             "VINC_CONTA" VARCHAR (30),
             "VINC_SEQ" NUMERIC (5,0),
             "CONTROLE" VARCHAR (30),
             "OBS" VARCHAR (2000),
             "PREV" NUMERIC (5,0),
             "SÓCIO" VARCHAR (30),
             "MARCA" VARCHAR (150),
             "DOC" VARCHAR (30),
             "BAIXA" NUMERIC (5,0),
             "TRANSAÇÃO" NUMERIC (5,0),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE MOVIMENTO ADD CONSTRAINT ID_MOV
PRIMARY KEY ("CONTA", "SEQ");

CREATE TABLE PATCH (
             "CLIENTE" VARCHAR (30) NOT NULL,
             "PATCH" VARCHAR (30) NOT NULL,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE PATCH ADD CONSTRAINT ID_PATCH
PRIMARY KEY ("CLIENTE", "PATCH");

CREATE TABLE PLANO (
             "COD" VARCHAR (30) NOT NULL,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE PLANO ADD CONSTRAINT ID_PLANO
PRIMARY KEY ("COD");

CREATE TABLE PONTO (
             "CLIENTE" VARCHAR (30) NOT NULL,
             "PATCH" VARCHAR (20) NOT NULL,
             "PONTO" VARCHAR (10) NOT NULL,
             "LOCALIZAÇÃO" VARCHAR (50),
             "ATUAL_UTILIZAÇÃO" VARCHAR (100),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE PONTO ADD CONSTRAINT ID_PONTO
PRIMARY KEY ("CLIENTE", "PATCH", "PONTO");

CREATE TABLE PROJETO (
             "CLIENTE" VARCHAR (30) NOT NULL,
             "PROJETO" VARCHAR (30) NOT NULL,
             "DESENVOLVEDOR" VARCHAR (30),
             "SUPORTE" VARCHAR (30),
             "GRUPO" VARCHAR (30),
             "OBS" VARCHAR (500),
             "STATUS" VARCHAR (10),
             "ORDEM" NUMERIC (5,0),
             "DESENVOLVEDOR2" VARCHAR (30),
             "SUPORTE2" VARCHAR (30),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE PROJETO ADD CONSTRAINT ID_PROJETO
PRIMARY KEY ("CLIENTE", "PROJETO");

CREATE TABLE REALIZADO (
             "SEQ" NUMERIC (6,0) NOT NULL,
             "INI" DATE,
             "TAREFA" VARCHAR (4000),
             "TIPO" VARCHAR (30),
             "CLIENTE" VARCHAR (30),
             "DEPTO" VARCHAR (50),
             "USUÁRIO" VARCHAR (30),
             "OBS" VARCHAR (2000),
             "TÉCNICO" VARCHAR (30),
             "PROJETO" VARCHAR (30),
             "CHAMADO_DATA" DATE,
             "ATENDIM_INÍCIO" DATE,
             "ATENDIM_FIM" DATE,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE REALIZADO ADD CONSTRAINT ID_REAL
PRIMARY KEY ("SEQ");

CREATE TABLE RECURSO (
             "RECURSO" VARCHAR (50) NOT NULL,
             "TIPO" VARCHAR (20),
             "LOCALIZAÇÃO" VARCHAR (100),
             "OBS" VARCHAR (1000),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE RECURSO ADD CONSTRAINT ID_RECURSO
PRIMARY KEY ("RECURSO");

CREATE TABLE REDE (
             "CLIENTE" VARCHAR (30) NOT NULL,
             "REDE" VARCHAR (30) NOT NULL,
             "ENDEREÇO" VARCHAR (30),
             "MÁSCARA" VARCHAR (30),
             "SUBNET_AUTO" VARCHAR (50),
             "SUBNET_PARAM" VARCHAR (30),
             "OBS" VARCHAR (500),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE REDE ADD CONSTRAINT ID_REDE
PRIMARY KEY ("CLIENTE", "REDE");

CREATE TABLE SERVIÇO (
             "CLIENTE" VARCHAR (30) NOT NULL,
             "SERVIÇO" VARCHAR (50) NOT NULL,
             "DESCRIÇÃO" VARCHAR (100),
             "TIPO" VARCHAR (20),
             "LOCALIZAÇÃO" VARCHAR (100),
             "DESENVOLVEDOR" VARCHAR (30),
             "SUPORTE" VARCHAR (30),
             "BKP_DIR_LOCAL" VARCHAR (100),
             "BKP_DIR_CONSOL" VARCHAR (100),
             "BKP_PROG_RETEM" VARCHAR (100),
             "BKP_NOTIFICAR" VARCHAR (100),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE SERVIÇO ADD CONSTRAINT ID_SERVIÇO
PRIMARY KEY ("CLIENTE", "SERVIÇO");

CREATE TABLE SYS_CAD_LOG (
             "SEQ" NUMERIC (10,0) NOT NULL,
             "NOME_TABELA" VARCHAR (50),
             "CHAVE" BLOB,
             "MOMENTO" DATE,
             "USUÁRIO" VARCHAR (20),
             "LOCAL" VARCHAR (20),
             "AÇÃO" VARCHAR (20)
             );

ALTER TABLE SYS_CAD_LOG ADD CONSTRAINT ID_CAD_LOG
PRIMARY KEY ("SEQ");

CREATE TABLE SYS_CONFIG_GLOBAL (
             "PARAM" VARCHAR (100) NOT NULL,
             "CONFIG" VARCHAR (4000)
             );

ALTER TABLE SYS_CONFIG_GLOBAL ADD CONSTRAINT ID_CONFIG_GLOBAL
PRIMARY KEY ("PARAM");

CREATE TABLE SYS_DELETE (
             "NOME_TABELA" VARCHAR (50) NOT NULL,
             "CHAVE" VARCHAR (150) NOT NULL,
             "MOMENTO" DATE,
             "USUÁRIO" VARCHAR (20),
             "LOCAL" VARCHAR (20)
             );

ALTER TABLE SYS_DELETE ADD CONSTRAINT ID_DELETE
PRIMARY KEY ("NOME_TABELA", "CHAVE");

CREATE TABLE SYS_LOCALID (
             "NOME" VARCHAR (15) NOT NULL,
             "CORRENTE" NUMERIC (5,0),
             "PACOTE" NUMERIC (5,0),
             "PACOTE_REC" NUMERIC (5,0),
             "MOMENTO" DATE,
             "MOMENTO_REC" DATE,
             "MODELO" NUMERIC (5,0),
             "OBS" VARCHAR (300)
             );

ALTER TABLE SYS_LOCALID ADD CONSTRAINT ID_SYS_LOCAL
PRIMARY KEY ("NOME");

CREATE TABLE SYS_OCORRÊNCIA (
             "SEQ" NUMERIC (10,0) NOT NULL,
             "APLICAÇÃO" VARCHAR (30),
             "OCORRÊNCIA" VARCHAR (3000),
             "USUÁRIO" VARCHAR (20),
             "MOMENTO" DATE,
             "LOCAL" VARCHAR (20)
             );

ALTER TABLE SYS_OCORRÊNCIA ADD CONSTRAINT ID_OCORRÊNCIA
PRIMARY KEY ("SEQ");

CREATE TABLE SYS_TABELA (
             "NOME" VARCHAR (50) NOT NULL,
             "CHAVE" VARCHAR (3000),
             "EXPR_PRIMÁRIA" VARCHAR (3000),
             "EXPR_APRESENTA" VARCHAR (3000),
             "CAMPOS" VARCHAR (3000),
             "RELAÇÕES_1_N" VARCHAR (3000),
             "NÍVEL" NUMERIC (5,0)
             );

ALTER TABLE SYS_TABELA ADD CONSTRAINT ID_SYS_TABELA
PRIMARY KEY ("NOME");

CREATE TABLE SYS_USUÁRIO (
             "USUÁRIO" VARCHAR (20) NOT NULL,
             "NOME" VARCHAR (50),
             "SUPERVISOR" VARCHAR (20),
             "DEPTO" VARCHAR (10),
             "MSG" VARCHAR (3000),
             "ASSINATURA" BLOB,
             "TEMPO_ATUALIZA" NUMERIC (5,0),
             "FUNÇÃO" VARCHAR (30),
             "ASSINATURA_BMP" BLOB
             );

ALTER TABLE SYS_USUÁRIO ADD CONSTRAINT ID_SYS_USU
PRIMARY KEY ("USUÁRIO");

CREATE TABLE TABELA_SÓCIO (
             "PERÍODO" DATE NOT NULL,
             "SÓCIO" VARCHAR (50) NOT NULL,
             "VALOR" FLOAT,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE TABELA_SÓCIO ADD CONSTRAINT ID_TAB_SÓCIO
PRIMARY KEY ("PERÍODO", "SÓCIO");

CREATE TABLE TAREFA_DEF (
             "TAREFA" VARCHAR (50) NOT NULL,
             "DETALHE" VARCHAR (300),
             "OBS" VARCHAR (300),
             "TIPO" VARCHAR (30),
             "CLIENTE" VARCHAR (30),
             "DEPTO" VARCHAR (50),
             "USUÁRIO" VARCHAR (30),
             "PROJETO" VARCHAR (30),
             "FATO" VARCHAR (50),
             "P_APLICATIVO" VARCHAR (50),
             "GRUPOS" VARCHAR (300),
             "COMENTÁRIOS" VARCHAR (300),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE TAREFA_DEF ADD CONSTRAINT ID_TAR_DEF
PRIMARY KEY ("TAREFA");

CREATE TABLE TÉCNICO (
             "CLASSIFIC" VARCHAR (30),
             "TÉCNICO" VARCHAR (30) NOT NULL,
             "SEC_ID" NUMERIC (5,0),
             "NOTIFIC_EMAIL" VARCHAR (200),
             "CANCEL" DATE,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE TÉCNICO ADD CONSTRAINT ID_TÉCNICO
PRIMARY KEY ("TÉCNICO");

CREATE TABLE TÉCNICO_MENU (
             "TÉCNICO" VARCHAR (30) NOT NULL,
             "SEQ" NUMERIC (5,0) NOT NULL,
             "ELEMENTO" VARCHAR (50),
             "PROGRAMAÇÃO" VARCHAR (200),
             "OBJETO_VINC" VARCHAR (30),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE TÉCNICO_MENU ADD CONSTRAINT ID_TÉCNICO_MENU
PRIMARY KEY ("TÉCNICO", "SEQ");

CREATE TABLE TIPO_DOC (
,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE TIPO_DOC ADD CONSTRAINT ID_TIPO_DOC
PRIMARY KEY ("TIPO");

CREATE TABLE TIPO_IDENTIF (
             "TIPO" VARCHAR (30) NOT NULL,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE TIPO_IDENTIF ADD CONSTRAINT ID_TIPO_ID
PRIMARY KEY ("TIPO");

CREATE TABLE TIPO_RECURSO (
             "TIPO" VARCHAR (20) NOT NULL,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE TIPO_RECURSO ADD CONSTRAINT ID_TIPO_REC
PRIMARY KEY ("TIPO");

CREATE TABLE TIPO_SERVIÇO (
             "TIPO" VARCHAR (20) NOT NULL,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE TIPO_SERVIÇO ADD CONSTRAINT ID_TIPO_SERV
PRIMARY KEY ("TIPO");

CREATE TABLE TIPO_TAREFA (
             "TIPO" VARCHAR (30) NOT NULL,
             "DESCR" VARCHAR (200),
             "CRIT_RELEV" VARCHAR (30),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE TIPO_TAREFA ADD CONSTRAINT ID_TIPO_TAR
PRIMARY KEY ("TIPO");

CREATE TABLE TRANSAÇÃO (
             "SEQ" NUMERIC (5,0) NOT NULL,
             "DATA" DATE,
             "DOC" VARCHAR (30),
             "TIPO_DOC" VARCHAR (30),
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE TRANSAÇÃO ADD CONSTRAINT ID_TRANSAÇÃO
PRIMARY KEY ("SEQ");

CREATE TABLE USUÁRIO (
             "CLIENTE" VARCHAR (30) NOT NULL,
             "USUÁRIO" VARCHAR (30) NOT NULL,
             "DEPTO" VARCHAR (50),
             "SITUAÇÃO" NUMERIC (5,0),
             "NOTIFIC_EMAIL" VARCHAR (200),
             "SEC_ID" NUMERIC (5,0),
             "CANCEL" DATE,
             "SYS_MOMENTO_CRIA" DATE,
             "SYS_USUÁRIO_CRIA" CHAR (20),
             "SYS_LOCAL_CRIA" CHAR (20),
             "SYS_MOMENTO_ATUALIZA" DATE,
             "SYS_USUÁRIO_ATUALIZA" CHAR (20),
             "SYS_LOCAL_ATUALIZA" CHAR(20),
             "SYS_STATUS" CHAR (1)
             );

ALTER TABLE USUÁRIO ADD CONSTRAINT ID_USUÁRIO
PRIMARY KEY ("CLIENTE", "USUÁRIO");

ALTER TABLE ICFT.CD ADD CONSTRAINT CLASSE$CD$01
FOREIGN KEY (CLASSE) REFERENCES ICFT.CLASSE (NOME);

ALTER TABLE ICFT.CONTRATO ADD CONSTRAINT CLIENTE$CONTRATO$01
FOREIGN KEY (CLIENTE) REFERENCES ICFT.CLIENTE (NOME);

ALTER TABLE ICFT.DEPTO ADD CONSTRAINT CLIENTE$DEPTO$01
FOREIGN KEY (CLIENTE) REFERENCES ICFT.CLIENTE (NOME);

ALTER TABLE ICFT.GRUPO ADD CONSTRAINT CLIENTE$GRUPO$01
FOREIGN KEY (CLIENTE) REFERENCES ICFT.CLIENTE (NOME);

ALTER TABLE ICFT.MÁQUINA ADD CONSTRAINT CLIENTE$MÁQUINA$01
FOREIGN KEY (CLIENTE) REFERENCES ICFT.CLIENTE (NOME);

ALTER TABLE ICFT.PATCH ADD CONSTRAINT CLIENTE$PATCH$01
FOREIGN KEY (CLIENTE) REFERENCES ICFT.CLIENTE (NOME);

ALTER TABLE ICFT.PROJETO ADD CONSTRAINT CLIENTE$PROJETO$01
FOREIGN KEY (CLIENTE) REFERENCES ICFT.CLIENTE (NOME);

ALTER TABLE ICFT.REALIZADO ADD CONSTRAINT CLIENTE$REAL$01
FOREIGN KEY (CLIENTE) REFERENCES ICFT.CLIENTE (NOME);

ALTER TABLE ICFT.REDE ADD CONSTRAINT CLIENTE$REDE$01
FOREIGN KEY (CLIENTE) REFERENCES ICFT.CLIENTE (NOME);

ALTER TABLE ICFT.SERVIÇO ADD CONSTRAINT CLIENTE$SERVIÇO$01
FOREIGN KEY (CLIENTE) REFERENCES ICFT.CLIENTE (NOME);

ALTER TABLE ICFT.USUÁRIO ADD CONSTRAINT CLIENTE$USUÁRIO$01
FOREIGN KEY (CLIENTE) REFERENCES ICFT.CLIENTE (NOME);

ALTER TABLE ICFT.CONJ_IMPRESS ADD CONSTRAINT CONJ_REL$CONJ_IMPRESS$01
FOREIGN KEY (DEFINIÇÃO, DEFINIÇÃO_SEQ) REFERENCES ICFT.CONJ_REL (DEFINIÇÃO, SEQ);

ALTER TABLE ICFT.CLASSIF ADD CONSTRAINT CONTA$CSIF$01
FOREIGN KEY (CONTA) REFERENCES ICFT.CONTA (CONTA);

ALTER TABLE ICFT.CONTRATO_FIN ADD CONSTRAINT CONTRATO$CONTRATO_FIN$01
FOREIGN KEY (REF, ADITIVO) REFERENCES ICFT.CONTRATO (REF, ADITIVO);

ALTER TABLE ICFT.MOVIMENTO ADD CONSTRAINT CONTROLE_MOVIMENTO$01
FOREIGN KEY (CONTA, CONTROLE) REFERENCES ICFT.CONTROLE (CONTA, CONTROLE);

ALTER TABLE ICFT.CRONOGRAMA ADD CONSTRAINT CRONO$CRONO$01
FOREIGN KEY (SUPERSEQ) REFERENCES ICFT.CRONOGRAMA (SEQ);

ALTER TABLE ICFT.CONTRATO_FIN ADD CONSTRAINT CSIF$CONTRATO_FIN$01
FOREIGN KEY (CONTA_CONTAB, CLASSIF_CONTAB) REFERENCES ICFT.CLASSIF (CONTA, CLASSE);

ALTER TABLE ICFT.MOVIMENTO ADD CONSTRAINT CSIF$MOV$01
FOREIGN KEY (CONTA, CLASSE) REFERENCES ICFT.CLASSIF (CONTA, CLASSE);

ALTER TABLE ICFT.REALIZADO ADD CONSTRAINT DEPTO$REAL$01
FOREIGN KEY (CLIENTE, DEPTO) REFERENCES ICFT.DEPTO (CLIENTE, DEPTO);

ALTER TABLE ICFT.USUÁRIO ADD CONSTRAINT DEPTO$USUÁRIO$01
FOREIGN KEY (CLIENTE, DEPTO) REFERENCES ICFT.DEPTO (CLIENTE, DEPTO);

ALTER TABLE ICFT.ESCALA ADD CONSTRAINT ESCALA_TIPO$ESCALA$01
FOREIGN KEY (TIPO) REFERENCES ICFT.ESCALA_TIPO (TIPO);

ALTER TABLE ICFT.GRUPO ADD CONSTRAINT GRUPO$GRUPO$01
FOREIGN KEY (CLIENTE, SUPERGRUPO) REFERENCES ICFT.GRUPO (CLIENTE, GRUPO);

ALTER TABLE ICFT.PROJETO ADD CONSTRAINT GRUPO$PROJETO$01
FOREIGN KEY (CLIENTE, GRUPO) REFERENCES ICFT.GRUPO (CLIENTE, GRUPO);

ALTER TABLE ICFT.IP ADD CONSTRAINT MÁQUINA$IP$01
FOREIGN KEY (CLIENTE, MÁQUINA) REFERENCES ICFT.MÁQUINA (CLIENTE, MÁQUINA);

ALTER TABLE ICFT.MÁQUINA_RECURSO ADD CONSTRAINT MÁQUINA$MÁQ_REC$01
FOREIGN KEY (CLIENTE, MÁQUINA) REFERENCES ICFT.MÁQUINA (CLIENTE, MÁQUINA);

ALTER TABLE ICFT.MEMO ADD CONSTRAINT MEMO_SITUAÇÃO$MEMO$01
FOREIGN KEY (SITUAÇÃO) REFERENCES ICFT.MEMO_SITUAÇÃO (SITUAÇÃO);

ALTER TABLE ICFT.MEMO ADD CONSTRAINT MEMO_TIPO$MEMO$01
FOREIGN KEY (TIPO) REFERENCES ICFT.MEMO_TIPO (TIPO);

ALTER TABLE ICFT.MOVIMENTO ADD CONSTRAINT MOV$MOV$01
FOREIGN KEY (VINC_CONTA, VINC_SEQ) REFERENCES ICFT.MOVIMENTO (CONTA, SEQ);

ALTER TABLE ICFT.PONTO ADD CONSTRAINT PATCH$PONTO$01
FOREIGN KEY (CLIENTE, PATCH) REFERENCES ICFT.PATCH (CLIENTE, PATCH);

ALTER TABLE ICFT.CRONOGRAMA ADD CONSTRAINT PROJETO$CRONO$01
FOREIGN KEY (CLIENTE, PROJETO) REFERENCES ICFT.PROJETO (CLIENTE, PROJETO);

ALTER TABLE ICFT.REALIZADO ADD CONSTRAINT PROJETO$REAL$01
FOREIGN KEY (CLIENTE, PROJETO) REFERENCES ICFT.PROJETO (CLIENTE, PROJETO);

ALTER TABLE ICFT.MÁQUINA_RECURSO ADD CONSTRAINT RECURSO$MÁQ_REC$01
FOREIGN KEY (RECURSO) REFERENCES ICFT.RECURSO (RECURSO);

ALTER TABLE ICFT.IP ADD CONSTRAINT REDE$IP$01
FOREIGN KEY (REDE_CLIENTE, REDE_IDENTIF) REFERENCES ICFT.REDE (CLIENTE, REDE);

ALTER TABLE ICFT.PROJETO ADD CONSTRAINT TÉCNICO$PROJETO$01
FOREIGN KEY (DESENVOLVEDOR) REFERENCES ICFT.TÉCNICO (TÉCNICO);

ALTER TABLE ICFT.PROJETO ADD CONSTRAINT TÉCNICO$PROJETO$02
FOREIGN KEY (SUPORTE) REFERENCES ICFT.TÉCNICO (TÉCNICO);

ALTER TABLE ICFT.PROJETO ADD CONSTRAINT TÉCNICO$PROJETO$03
FOREIGN KEY (DESENVOLVEDOR2) REFERENCES ICFT.TÉCNICO (TÉCNICO);

ALTER TABLE ICFT.PROJETO ADD CONSTRAINT TÉCNICO$PROJETO$04
FOREIGN KEY (SUPORTE2) REFERENCES ICFT.TÉCNICO (TÉCNICO);

ALTER TABLE ICFT.REALIZADO ADD CONSTRAINT TÉCNICO$REAL$01
FOREIGN KEY (TÉCNICO) REFERENCES ICFT.TÉCNICO (TÉCNICO);

ALTER TABLE ICFT.SERVIÇO ADD CONSTRAINT TÉCNICO$SERVIÇO$01
FOREIGN KEY (DESENVOLVEDOR) REFERENCES ICFT.TÉCNICO (TÉCNICO);

ALTER TABLE ICFT.SERVIÇO ADD CONSTRAINT TÉCNICO$SERVIÇO$02
FOREIGN KEY (SUPORTE) REFERENCES ICFT.TÉCNICO (TÉCNICO);

ALTER TABLE ICFT.TÉCNICO_MENU ADD CONSTRAINT TÉCNICO$TÉCNICO_MENU$01
FOREIGN KEY (TÉCNICO) REFERENCES ICFT.TÉCNICO (TÉCNICO);

ALTER TABLE ICFT.ESCALA ADD CONSTRAINT TÉCNICO_ESCALA$01
FOREIGN KEY (TÉCNICO) REFERENCES ICFT.TÉCNICO (TÉCNICO);

ALTER TABLE ICFT.IDENTIF ADD CONSTRAINT TIPO_ID$IDENTIF$01
FOREIGN KEY (TIPO_IDENTIF) REFERENCES ICFT.TIPO_IDENTIF (TIPO);

ALTER TABLE ICFT.RECURSO ADD CONSTRAINT TIPO_REC$RECURSO$01
FOREIGN KEY (TIPO) REFERENCES ICFT.TIPO_RECURSO (TIPO);

ALTER TABLE ICFT.SERVIÇO ADD CONSTRAINT TIPO_SERV$SERVIÇO$01
FOREIGN KEY (TIPO) REFERENCES ICFT.TIPO_SERVIÇO (TIPO);

ALTER TABLE ICFT.REALIZADO ADD CONSTRAINT TIPO_TAR$REAL$01
FOREIGN KEY (TIPO) REFERENCES ICFT.TIPO_TAREFA (TIPO);

ALTER TABLE ICFT.IDENTIF ADD CONSTRAINT USUÁRIO$IDENTIF$01
FOREIGN KEY (CLIENTE, USUÁRIO) REFERENCES ICFT.USUÁRIO (CLIENTE, USUÁRIO);

ALTER TABLE ICFT.MÁQUINA ADD CONSTRAINT USUÁRIO$MÁQUINA$01
FOREIGN KEY (CLIENTE, USUÁRIO) REFERENCES ICFT.USUÁRIO (CLIENTE, USUÁRIO);

ALTER TABLE ICFT.REALIZADO ADD CONSTRAINT USUÁRIO$REAL$01
FOREIGN KEY (CLIENTE, USUÁRIO) REFERENCES ICFT.USUÁRIO (CLIENTE, USUÁRIO);

CREATE OR REPLACE TRIGGER BEF_ACESSO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.ACESSO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'ACESSO' AND CHAVE = :OLD.LOGIN;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('ACESSO', :OLD.LOGIN, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'ACESSO' AND CHAVE = :OLD.LOGIN;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_CD BEFORE UPDATE OR INSERT OR DELETE ON ICFT.CD FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'CD' AND CHAVE = :OLD.ID;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('CD', :OLD.ID, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'CD' AND CHAVE = :OLD.ID;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_CLASSE BEFORE UPDATE OR INSERT OR DELETE ON ICFT.CLASSE FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'CLASSE' AND CHAVE = :OLD.NOME;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('CLASSE', :OLD.NOME, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'CLASSE' AND CHAVE = :OLD.NOME;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_CSIF BEFORE UPDATE OR INSERT OR DELETE ON ICFT.CLASSIF FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'CLASSIF' AND CHAVE = :OLD.CONTA || :OLD.CLASSE;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('CLASSIF', :OLD.CONTA || :OLD.CLASSE, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'CLASSIF' AND CHAVE = :OLD.CONTA || :OLD.CLASSE;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_CLIENTE BEFORE UPDATE OR INSERT OR DELETE ON ICFT.CLIENTE FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'CLIENTE' AND CHAVE = :OLD.NOME;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('CLIENTE', :OLD.NOME, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'CLIENTE' AND CHAVE = :OLD.NOME;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_COBRARQ BEFORE UPDATE OR INSERT OR DELETE ON ICFT.COBRARQ FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'COBRARQ' AND CHAVE = :OLD.SEU_NUM;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('COBRARQ', :OLD.SEU_NUM, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'COBRARQ' AND CHAVE = :OLD.SEU_NUM;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_CONJ_IMPRESS BEFORE UPDATE OR INSERT OR DELETE ON ICFT.CONJ_IMPRESS FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'CONJ_IMPRESS' AND CHAVE = :OLD.DEFINIÇÃO || :OLD.DEFINIÇÃO_SEQ || :OLD.ITEM;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('CONJ_IMPRESS', :OLD.DEFINIÇÃO || :OLD.DEFINIÇÃO_SEQ || :OLD.ITEM, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'CONJ_IMPRESS' AND CHAVE = :OLD.DEFINIÇÃO || :OLD.DEFINIÇÃO_SEQ || :OLD.ITEM;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_CONJ_REL BEFORE UPDATE OR INSERT OR DELETE ON ICFT.CONJ_REL FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'CONJ_REL' AND CHAVE = :OLD.DEFINIÇÃO || :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('CONJ_REL', :OLD.DEFINIÇÃO || :OLD.SEQ, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'CONJ_REL' AND CHAVE = :OLD.DEFINIÇÃO || :OLD.SEQ;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_CONTA BEFORE UPDATE OR INSERT OR DELETE ON ICFT.CONTA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'CONTA' AND CHAVE = :OLD.CONTA;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('CONTA', :OLD.CONTA, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'CONTA' AND CHAVE = :OLD.CONTA;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_CONTATO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.CONTATO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'CONTATO' AND CHAVE = :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('CONTATO', :OLD.SEQ, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'CONTATO' AND CHAVE = :OLD.SEQ;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_CONTRATO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.CONTRATO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'CONTRATO' AND CHAVE = :OLD.REF || :OLD.ADITIVO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('CONTRATO', :OLD.REF || :OLD.ADITIVO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'CONTRATO' AND CHAVE = :OLD.REF || :OLD.ADITIVO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_CONTRATO_FIN BEFORE UPDATE OR INSERT OR DELETE ON ICFT.CONTRATO_FIN FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'CONTRATO_FIN' AND CHAVE = :OLD.REF || :OLD.ADITIVO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('CONTRATO_FIN', :OLD.REF || :OLD.ADITIVO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'CONTRATO_FIN' AND CHAVE = :OLD.REF || :OLD.ADITIVO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_CONTROLE BEFORE UPDATE OR INSERT OR DELETE ON ICFT.CONTROLE FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'CONTROLE' AND CHAVE = :OLD.CONTA || :OLD.CONTROLE;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('CONTROLE', :OLD.CONTA || :OLD.CONTROLE, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'CONTROLE' AND CHAVE = :OLD.CONTA || :OLD.CONTROLE;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_CRONO_NOTIF BEFORE UPDATE OR INSERT OR DELETE ON ICFT.CRONO_NOTIF FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'CRONO_NOTIF' AND CHAVE = :OLD.CRONO_SEQ || :OLD.ITEM;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('CRONO_NOTIF', :OLD.CRONO_SEQ || :OLD.ITEM, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'CRONO_NOTIF' AND CHAVE = :OLD.CRONO_SEQ || :OLD.ITEM;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_CRONO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.CRONOGRAMA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'CRONOGRAMA' AND CHAVE = :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('CRONOGRAMA', :OLD.SEQ, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'CRONOGRAMA' AND CHAVE = :OLD.SEQ;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_DEPTO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.DEPTO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'DEPTO' AND CHAVE = :OLD.CLIENTE || :OLD.DEPTO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('DEPTO', :OLD.CLIENTE || :OLD.DEPTO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'DEPTO' AND CHAVE = :OLD.CLIENTE || :OLD.DEPTO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_DESC_S_PROG BEFORE UPDATE OR INSERT OR DELETE ON ICFT.DESC_S_PROG FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'DESC_S_PROG' AND CHAVE = :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('DESC_S_PROG', :OLD.SEQ, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'DESC_S_PROG' AND CHAVE = :OLD.SEQ;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_DISTR_CUSTO_REC BEFORE UPDATE OR INSERT OR DELETE ON ICFT.DISTRIB_CUSTO_RECEITA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'DISTRIB_CUSTO_RECEITA' AND CHAVE = :OLD.CONTA || :OLD.CENTRO_CUSTO || :OLD.CENTRO_RECEITA;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('DISTRIB_CUSTO_RECEITA', :OLD.CONTA || :OLD.CENTRO_CUSTO || :OLD.CENTRO_RECEITA, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'DISTRIB_CUSTO_RECEITA' AND CHAVE = :OLD.CONTA || :OLD.CENTRO_CUSTO || :OLD.CENTRO_RECEITA;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_DISTR_FUNCIL_REC BEFORE UPDATE OR INSERT OR DELETE ON ICFT.DISTRIB_FUNCIL_RECEITA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'DISTRIB_FUNCIL_RECEITA' AND CHAVE = :OLD.CONTA || :OLD.FUNCIL || :OLD.CENTRO_RECEITA;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('DISTRIB_FUNCIL_RECEITA', :OLD.CONTA || :OLD.FUNCIL || :OLD.CENTRO_RECEITA, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'DISTRIB_FUNCIL_RECEITA' AND CHAVE = :OLD.CONTA || :OLD.FUNCIL || :OLD.CENTRO_RECEITA;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_ESCALA BEFORE UPDATE OR INSERT OR DELETE ON ICFT.ESCALA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'ESCALA' AND CHAVE = :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('ESCALA', :OLD.SEQ, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'ESCALA' AND CHAVE = :OLD.SEQ;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_ESCALA_TIPO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.ESCALA_TIPO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'ESCALA_TIPO' AND CHAVE = :OLD.TIPO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('ESCALA_TIPO', :OLD.TIPO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'ESCALA_TIPO' AND CHAVE = :OLD.TIPO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_GRUPO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.GRUPO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'GRUPO' AND CHAVE = :OLD.CLIENTE || :OLD.GRUPO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('GRUPO', :OLD.CLIENTE || :OLD.GRUPO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'GRUPO' AND CHAVE = :OLD.CLIENTE || :OLD.GRUPO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_HIERARQ BEFORE UPDATE OR INSERT OR DELETE ON ICFT.HIERARQUIA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'HIERARQUIA' AND CHAVE = :OLD.CLIENTE || :OLD.CLASSIF;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('HIERARQUIA', :OLD.CLIENTE || :OLD.CLASSIF, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'HIERARQUIA' AND CHAVE = :OLD.CLIENTE || :OLD.CLASSIF;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_IDENTIF BEFORE UPDATE OR INSERT OR DELETE ON ICFT.IDENTIF FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'IDENTIF' AND CHAVE = :OLD.CLIENTE || :OLD.USUÁRIO || :OLD.TIPO_IDENTIF || :OLD.IDENTIF;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('IDENTIF', :OLD.CLIENTE || :OLD.USUÁRIO || :OLD.TIPO_IDENTIF || :OLD.IDENTIF, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'IDENTIF' AND CHAVE = :OLD.CLIENTE || :OLD.USUÁRIO || :OLD.TIPO_IDENTIF || :OLD.IDENTIF;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_IP BEFORE UPDATE OR INSERT OR DELETE ON ICFT.IP FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'IP' AND CHAVE = :OLD.CLIENTE || :OLD.MÁQUINA || :OLD.REDE_CLIENTE || :OLD.REDE_IDENTIF || :OLD.IP;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('IP', :OLD.CLIENTE || :OLD.MÁQUINA || :OLD.REDE_CLIENTE || :OLD.REDE_IDENTIF || :OLD.IP, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'IP' AND CHAVE = :OLD.CLIENTE || :OLD.MÁQUINA || :OLD.REDE_CLIENTE || :OLD.REDE_IDENTIF || :OLD.IP;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_LICENÇA BEFORE UPDATE OR INSERT OR DELETE ON ICFT.LICENÇA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'LICENÇA' AND CHAVE = :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('LICENÇA', :OLD.SEQ, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'LICENÇA' AND CHAVE = :OLD.SEQ;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_MÁQUINA BEFORE UPDATE OR INSERT OR DELETE ON ICFT.MÁQUINA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'MÁQUINA' AND CHAVE = :OLD.CLIENTE || :OLD.MÁQUINA;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('MÁQUINA', :OLD.CLIENTE || :OLD.MÁQUINA, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'MÁQUINA' AND CHAVE = :OLD.CLIENTE || :OLD.MÁQUINA;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_MÁQ_REC BEFORE UPDATE OR INSERT OR DELETE ON ICFT.MÁQUINA_RECURSO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'MÁQUINA_RECURSO' AND CHAVE = :OLD.CLIENTE || :OLD.MÁQUINA || :OLD.RECURSO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('MÁQUINA_RECURSO', :OLD.CLIENTE || :OLD.MÁQUINA || :OLD.RECURSO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'MÁQUINA_RECURSO' AND CHAVE = :OLD.CLIENTE || :OLD.MÁQUINA || :OLD.RECURSO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_MEMO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.MEMO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'MEMO' AND CHAVE = :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('MEMO', :OLD.SEQ, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'MEMO' AND CHAVE = :OLD.SEQ;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_MEMO_SITUAÇÃO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.MEMO_SITUAÇÃO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'MEMO_SITUAÇÃO' AND CHAVE = :OLD.SITUAÇÃO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('MEMO_SITUAÇÃO', :OLD.SITUAÇÃO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'MEMO_SITUAÇÃO' AND CHAVE = :OLD.SITUAÇÃO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_MEMO_TIPO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.MEMO_TIPO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'MEMO_TIPO' AND CHAVE = :OLD.TIPO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('MEMO_TIPO', :OLD.TIPO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'MEMO_TIPO' AND CHAVE = :OLD.TIPO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_MOV BEFORE UPDATE OR INSERT OR DELETE ON ICFT.MOVIMENTO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'MOVIMENTO' AND CHAVE = :OLD.CONTA || :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('MOVIMENTO', :OLD.CONTA || :OLD.SEQ, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'MOVIMENTO' AND CHAVE = :OLD.CONTA || :OLD.SEQ;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_PATCH BEFORE UPDATE OR INSERT OR DELETE ON ICFT.PATCH FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'PATCH' AND CHAVE = :OLD.CLIENTE || :OLD.PATCH;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('PATCH', :OLD.CLIENTE || :OLD.PATCH, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'PATCH' AND CHAVE = :OLD.CLIENTE || :OLD.PATCH;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_PLANO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.PLANO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'PLANO' AND CHAVE = :OLD.COD;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('PLANO', :OLD.COD, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'PLANO' AND CHAVE = :OLD.COD;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_PONTO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.PONTO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'PONTO' AND CHAVE = :OLD.CLIENTE || :OLD.PATCH || :OLD.PONTO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('PONTO', :OLD.CLIENTE || :OLD.PATCH || :OLD.PONTO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'PONTO' AND CHAVE = :OLD.CLIENTE || :OLD.PATCH || :OLD.PONTO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_PROJETO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.PROJETO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'PROJETO' AND CHAVE = :OLD.CLIENTE || :OLD.PROJETO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('PROJETO', :OLD.CLIENTE || :OLD.PROJETO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'PROJETO' AND CHAVE = :OLD.CLIENTE || :OLD.PROJETO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_REAL BEFORE UPDATE OR INSERT OR DELETE ON ICFT.REALIZADO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'REALIZADO' AND CHAVE = :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('REALIZADO', :OLD.SEQ, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'REALIZADO' AND CHAVE = :OLD.SEQ;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_RECURSO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.RECURSO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'RECURSO' AND CHAVE = :OLD.RECURSO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('RECURSO', :OLD.RECURSO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'RECURSO' AND CHAVE = :OLD.RECURSO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_REDE BEFORE UPDATE OR INSERT OR DELETE ON ICFT.REDE FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'REDE' AND CHAVE = :OLD.CLIENTE || :OLD.REDE;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('REDE', :OLD.CLIENTE || :OLD.REDE, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'REDE' AND CHAVE = :OLD.CLIENTE || :OLD.REDE;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_SERVIÇO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.SERVIÇO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'SERVIÇO' AND CHAVE = :OLD.CLIENTE || :OLD.SERVIÇO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('SERVIÇO', :OLD.CLIENTE || :OLD.SERVIÇO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'SERVIÇO' AND CHAVE = :OLD.CLIENTE || :OLD.SERVIÇO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_TAB_SÓCIO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.TABELA_SÓCIO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'TABELA_SÓCIO' AND CHAVE = :OLD.PERÍODO || :OLD.SÓCIO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('TABELA_SÓCIO', :OLD.PERÍODO || :OLD.SÓCIO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'TABELA_SÓCIO' AND CHAVE = :OLD.PERÍODO || :OLD.SÓCIO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_TAR_DEF BEFORE UPDATE OR INSERT OR DELETE ON ICFT.TAREFA_DEF FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'TAREFA_DEF' AND CHAVE = :OLD.TAREFA;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('TAREFA_DEF', :OLD.TAREFA, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'TAREFA_DEF' AND CHAVE = :OLD.TAREFA;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_TÉCNICO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.TÉCNICO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'TÉCNICO' AND CHAVE = :OLD.TÉCNICO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('TÉCNICO', :OLD.TÉCNICO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'TÉCNICO' AND CHAVE = :OLD.TÉCNICO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_TÉCNICO_MENU BEFORE UPDATE OR INSERT OR DELETE ON ICFT.TÉCNICO_MENU FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'TÉCNICO_MENU' AND CHAVE = :OLD.TÉCNICO || :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('TÉCNICO_MENU', :OLD.TÉCNICO || :OLD.SEQ, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'TÉCNICO_MENU' AND CHAVE = :OLD.TÉCNICO || :OLD.SEQ;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_TIPO_DOC BEFORE UPDATE OR INSERT OR DELETE ON ICFT.TIPO_DOC FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'TIPO_DOC' AND CHAVE = :OLD.TIPO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('TIPO_DOC', :OLD.TIPO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'TIPO_DOC' AND CHAVE = :OLD.TIPO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_TIPO_ID BEFORE UPDATE OR INSERT OR DELETE ON ICFT.TIPO_IDENTIF FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'TIPO_IDENTIF' AND CHAVE = :OLD.TIPO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('TIPO_IDENTIF', :OLD.TIPO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'TIPO_IDENTIF' AND CHAVE = :OLD.TIPO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_TIPO_REC BEFORE UPDATE OR INSERT OR DELETE ON ICFT.TIPO_RECURSO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'TIPO_RECURSO' AND CHAVE = :OLD.TIPO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('TIPO_RECURSO', :OLD.TIPO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'TIPO_RECURSO' AND CHAVE = :OLD.TIPO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_TIPO_SERV BEFORE UPDATE OR INSERT OR DELETE ON ICFT.TIPO_SERVIÇO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'TIPO_SERVIÇO' AND CHAVE = :OLD.TIPO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('TIPO_SERVIÇO', :OLD.TIPO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'TIPO_SERVIÇO' AND CHAVE = :OLD.TIPO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_TIPO_TAR BEFORE UPDATE OR INSERT OR DELETE ON ICFT.TIPO_TAREFA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'TIPO_TAREFA' AND CHAVE = :OLD.TIPO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('TIPO_TAREFA', :OLD.TIPO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'TIPO_TAREFA' AND CHAVE = :OLD.TIPO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_TRANSAÇÃO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.TRANSAÇÃO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'TRANSAÇÃO' AND CHAVE = :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('TRANSAÇÃO', :OLD.SEQ, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'TRANSAÇÃO' AND CHAVE = :OLD.SEQ;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_USUÁRIO BEFORE UPDATE OR INSERT OR DELETE ON ICFT.USUÁRIO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'USUÁRIO' AND CHAVE = :OLD.CLIENTE || :OLD.USUÁRIO;
      IF TOT_DEL = 0 THEN
         INSERT INTO ICFT.SYS_DELETE VALUES ('USUÁRIO', :OLD.CLIENTE || :OLD.USUÁRIO, SYSDATE, USER, 'ICFT');
      ELSE
         UPDATE ICFT.SYS_DELETE SET MOMENTO = SYSDATE, USUÁRIO = USER, LOCAL = 'ICFT' WHERE NOME_TABELA = 'USUÁRIO' AND CHAVE = :OLD.CLIENTE || :OLD.USUÁRIO;
      END IF;
   ELSE
      IF :NEW.SYS_STATUS = '+' THEN
         :NEW.SYS_STATUS := 'I';
      ELSIF :NEW.SYS_STATUS = '/' THEN
         :NEW.SYS_STATUS := 'A';
      ELSIF :NEW.SYS_STATUS = 'X' THEN
         :NEW.SYS_STATUS := '';
      ELSE
         IF INSERTING THEN
            :NEW.SYS_MOMENTO_CRIA := SYSDATE;
            :NEW.SYS_USUÁRIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'ICFT';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USUÁRIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USUÁRIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'ICFT';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE USER CLAUDIO IDENTIFIED BY XXXXXX
DEFAULT TABLESPACE T_ICFT_DAT
TEMPORARY TABLESPACE TEMP
PROFILE DEFAULT
ACCOUNT UNLOCK;
GRANT CREATE SESSION, EXECUTE ANY LIBRARY, EXECUTE ANY PROCEDURE, CREATE ANY VIEW TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.CD TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.CLASSE TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.CLASSIF TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.CLIENTE TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.COBRARQ TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.CONJ_IMPRESS TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.CONJ_REL TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.CONTA TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.CONTATO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.CONTRATO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.CONTRATO_FIN TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.CRONO_NOTIF TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.CRONOGRAMA TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.DEPTO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.GRUPO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.HIERARQUIA TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.IDENTIF TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.IP TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.LICENÇA TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.MÁQUINA TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.MÁQUINA_RECURSO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.MEMO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.MEMO_SITUAÇÃO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.MEMO_TIPO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.MOVIMENTO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.PATCH TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.PLANO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.PONTO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.PROJETO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.REALIZADO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.RECURSO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.REDE TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.SERVIÇO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.SYS_CONFIG_GLOBAL TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.SYS_USUÁRIO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.TABELA_SÓCIO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.TAREFA_DEF TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.TÉCNICO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.TÉCNICO_MENU TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.TIPO_IDENTIF TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.TIPO_RECURSO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.TIPO_SERVIÇO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.TIPO_TAREFA TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.USUÁRIO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.TIPO_DOC TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.TRANSAÇÃO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.DISTRIB_CUSTO_RECEITA TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.DISTRIB_FUNCIL_RECEITA TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.DESC_S_PROG TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.ESCALA TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.ESCALA_TIPO TO CLÁUDIO;
GRANT SELECT, INSERT, UPDATE, DELETE ON ICFT.CONTROLE TO CLÁUDIO;
GRANT SELECT ON ICFT.REALIZADO_COM_DURAÇÃO TO CLÁUDIO;
GRANT SELECT ON ICFT.MOVIMENTO_CHECK TO CLÁUDIO;
GRANT SELECT ON ICFT.MOVIMENTO_SEQ_MAX TO CLÁUDIO;
GRANT SELECT ON ICFT.MOVIMENTO_CTL TO CLÁUDIO;

