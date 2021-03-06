-------------------------------------------------------------------------------------
-- CRIA��O DE SCRIPT PARA GERAR ESTRUTURA B�SICA CNTA
-------------------------------------------------------------------------------------
ALTER TABLESPACE T_CNTA_DAT OFFLINE;
DROP TABLESPACE T_CNTA_DAT INCLUDING CONTENTS;

CREATE TABLESPACE T_CNTA_DAT DATAFILE 'D:\ORACLE\ORADATA\CNTA\CIEX.DBF' SIZE 50M REUSE
AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL;

CREATE TABLE CNTA.ANEXO (
             NOME VARCHAR2 (50),
             SUB_CONTA NUMBER,
             SUB_CONTA_REL NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USU�RIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USU�RIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.ANEXO ADD CONSTRAINT ID_ANEXO
PRIMARY KEY (NOME);

CREATE TABLE CNTA.CONTA (
             EMPRESA VARCHAR2 (20),
             CONTA NUMBER,
             NOME VARCHAR2(50),
             SYS_MOMENTO_CRIA DATE,
             SYS_USU�RIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USU�RIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.CONTA ADD CONSTRAINT ID_CONTA
PRIMARY KEY (EMPRESA, CONTA);

CREATE TABLE CNTA.EMPRESA (
             EMPRESA VARCHAR2 (20),
             SYS_MOMENTO_CRIA DATE,
             SYS_USU�RIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USU�RIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.EMPRESA ADD CONSTRAINT ID_EMPRESA
PRIMARY KEY (EMPRESA);

CREATE TABLE CNTA.LOG_IMPORT (
             SEQ NUMBER,
             NOME VARCHAR2 (255),
             DATA DATE,
             SITUA��O VARCHAR2 (255),
             SYS_MOMENTO_CRIA DATE,
             SYS_USU�RIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USU�RIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.LOG_IMPORT ADD CONSTRAINT ID_LOG_IMPORT
PRIMARY KEY (SEQ);

CREATE TABLE CNTA.MAPA (
             WORKSHEET VARCHAR2 (30),
             SEQ NUMBER,
             EMPRESA VARCHAR2 (20),
             ARQUIVO VARCHAR2 (100),
             TITULO VARCHAR2 (50),
             LINHA NUMBER,
             COLUNA NUMBER,
             COR NUMBER,
             LARGURA NUMBER,
             FONT VARCHAR2 (50),
             FONT_NEGRITO NUMBER,
             FONT_TAM NUMBER,
             ALINHAMENTO NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USU�RIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USU�RIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.MAPA ADD CONSTRAINT ID_MAPA
PRIMARY KEY (WORKSHEET, SEQ);

CREATE TABLE CNTA.PLANILHA_DEF (
             WORKSHEET VARCHAR2 (30),
             SEQ NUMBER,
             EMPRESA VARCHAR2 (20),
             ARQUIVO VARCHAR2 (100),
             TIPO VARCHAR2 (20),
             HIST�RICO VARCHAR2 (20),
             DATAHIST NUMBER,
             COLUNACRT NUMBER,
             CRT VARCHAR2 (50),
             COLUNADBCR NUMBER,
             D�BITO VARCHAR2 (50),
             CR�DITO VARCHAR2 (50),
             SYS_MOMENTO_CRIA DATE,
             SYS_USU�RIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USU�RIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.PLANILHA_DEF ADD CONSTRAINT ID_PLAN_DEF
PRIMARY KEY (WORKSHEET, SEQ);

CREATE TABLE CNTA.PLANILHA_STC (
             WORKSHEET VARCHAR2 (30),
             EMPRESA VARCHAR2 (20),
             ARQUIVO VARCHAR2 (100),
             MAPA VARCHAR2 (100),
             SYS_MOMENTO_CRIA DATE,
             SYS_USU�RIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USU�RIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.PLANILHA_STC ADD CONSTRAINT ID_PLAN
PRIMARY KEY (WORKSHEET);

CREATE TABLE CNTA.SUB_CONTA (
             EMPRESA VARCHAR2 (20),
             SUB_CONTA NUMBER,
             CONTA NUMBER,
             NOME VARCHAR2 (50),
             SYS_MOMENTO_CRIA DATE,
             SYS_USU�RIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USU�RIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.SUB_CONTA ADD CONSTRAINT ID_SUB_CONTA
PRIMARY KEY (EMPRESA, SUB_CONTA);

CREATE TABLE CNTA.SYS_CAD_LOG (
             SEQ NUMBER,
             NOME_TABELA VARCHAR2 (50),
             CHAVE CLOB,
             MOMENTO DATE,
             USU�RIO VARCHAR2 (20),
             LOCAL VARCHAR2 (20),
             A��O VARCHAR2 (20)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.SYS_CAD_LOG ADD CONSTRAINT ID_CAD_LOG
PRIMARY KEY (SEQ);

CREATE TABLE CNTA.SYS_CONFIG_GLOBAL (
             PARAM VARCHAR2 (30),
             CONFIG VARCHAR2 (4000)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.SYS_CONFIG_GLOBAL ADD CONSTRAINT ID_CONFIG_GLOBAL
PRIMARY KEY (PARAM);

CREATE TABLE CNTA.SYS_DELETE (
             NOME_TABELA VARCHAR2 (50),
             CHAVE VARCHAR2 (150),
             MOMENTO DATE,
             USU�RIO VARCHAR2 (20),
             LOCAL VARCHAR2 (20)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.SYS_DELETE ADD CONSTRAINT ID_DELETE
PRIMARY KEY (NOME_TABELA, CHAVE);

CREATE TABLE CNTA.SYS_LOCALID (
             NOME VARCHAR2 (15),
             CORRENTE NUMBER,
             PACOTE NUMBER,
             PACOTE_REC NUMBER,
             MOMENTO DATE,
             MOMENTO_REC DATE,
             MODELO NUMBER,
             OBS VARCHAR2 (255)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.SYS_LOCALID ADD CONSTRAINT ID_SYS_LOCAL
PRIMARY KEY (NOME);

CREATE TABLE CNTA.SYS_OCORR�NCIA (
             SEQ NUMBER,
             APLICA��O VARCHAR2 (30),
             OCORR�NCIA VARCHAR2 (3000),
             USU�RIO VARCHAR2 (20),
             MOMENTO DATE,
             LOCAL VARCHAR2 (20)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.SYS_OCORR�NCIA ADD CONSTRAINT ID_OCORR�NCIA
PRIMARY KEY (SEQ);

CREATE TABLE CNTA.SYS_TABELA (
             NOME VARCHAR2 (50),
             CHAVE VARCHAR2 (3000),
             EXPR_PRIM�RIA VARCHAR2 (3000),
             EXPR_APRESENTA VARCHAR2 (3000),
             CAMPOS VARCHAR2 (3000),
             RELA��ES_1_N VARCHAR2 (3000),
             N�VEL NUMBER
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.SYS_TABELA ADD CONSTRAINT ID_SYS_TABELA
PRIMARY KEY (NOME);

CREATE TABLE CNTA.SYS_USU�RIO (
             USU�RIO VARCHAR2 (20),
             PARAM VARCHAR2 (30),
             CONFIG VARCHAR2 (4000)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.SYS_USU�RIO ADD CONSTRAINT ID_SYS_USU�RIO
PRIMARY KEY (USU�RIO, PARAM);

CREATE TABLE CNTA.TRANSA��O (
             EMPRESA VARCHAR2 (20),
             TRANSA��O NUMBER,
             DATA DATE,
             HIST�RICO VARCHAR2 (255),
             REL_EMPRESA VARCHAR2 (50),
             REL_TRANSA��O NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USU�RIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USU�RIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.TRANSA��O ADD CONSTRAINT ID_TRANS
PRIMARY KEY (EMPRESA, TRANSA��O);

CREATE TABLE CNTA.TRANSA��O_LANCE (
             EMPRESA VARCHAR2 (20),
             TRANSA��O NUMBER,
             SEQ NUMBER,
             SUB_CONTA NUMBER,
             D�BITO NUMBER,
             CR�DITO NUMBER,
             SYS_MOMENTO_CRIA DATE,
             SYS_USU�RIO_CRIA CHAR (20),
             SYS_LOCAL_CRIA CHAR (20),
             SYS_MOMENTO_ATUALIZA DATE,
             SYS_USU�RIO_ATUALIZA CHAR (20),
             SYS_LOCAL_ATUALIZA CHAR(20),
             SYS_STATUS CHAR (1)
             ) TABLESPACE T_CNTA_DAT;

ALTER TABLE CNTA.TRANSA��O_LANCE ADD CONSTRAINT ID_TRANS_LANCE
PRIMARY KEY (EMPRESA, TRANSA��O, SEQ);

ALTER TABLE CNTA.SUB_CONTA ADD CONSTRAINT CONTA$SUB_CONTA$01
FOREIGN KEY (EMPRESA, CONTA) REFERENCES CNTA.CONTA (EMPRESA, CONTA);

ALTER TABLE CNTA.CONTA ADD CONSTRAINT EMPRESA$CONTA$01
FOREIGN KEY (EMPRESA) REFERENCES CNTA.EMPRESA (EMPRESA);

ALTER TABLE CNTA.PLANILHA_STC ADD CONSTRAINT EMPRESA$PLAN$01
FOREIGN KEY (EMPRESA) REFERENCES CNTA.EMPRESA (EMPRESA);

ALTER TABLE CNTA.MAPA ADD CONSTRAINT PLAN$MAPA$01
FOREIGN KEY (WORKSHEET) REFERENCES CNTA.PLANILHA_STC (WORKSHEET);

ALTER TABLE CNTA.PLANILHA_DEF ADD CONSTRAINT PLAN$PLAN_DEF$01
FOREIGN KEY (WORKSHEET) REFERENCES CNTA.PLANILHA_STC (WORKSHEET);

ALTER TABLE CNTA.TRANSA��O_LANCE ADD CONSTRAINT SUB_CONTA$TRANS_LANCE$01
FOREIGN KEY (EMPRESA, SUB_CONTA) REFERENCES CNTA.SUB_CONTA (EMPRESA, SUB_CONTA);

ALTER TABLE CNTA.TRANSA��O ADD CONSTRAINT TRANS$TRANS$01
FOREIGN KEY (REL_EMPRESA, REL_TRANSA��O) REFERENCES CNTA.TRANSA��O (EMPRESA, TRANSA��O);

ALTER TABLE CNTA.TRANSA��O_LANCE ADD CONSTRAINT TRANS$TRANS_LANCE$01
FOREIGN KEY (EMPRESA, TRANSA��O) REFERENCES CNTA.TRANSA��O (EMPRESA, TRANSA��O);

CREATE OR REPLACE TRIGGER BEF_ANEXO BEFORE UPDATE OR INSERT OR DELETE ON CNTA.ANEXO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'ANEXO' AND CHAVE = :OLD.NOME;
      IF TOT_DEL = 0 THEN
         INSERT INTO CNTA.SYS_DELETE VALUES ('ANEXO', :OLD.NOME, SYSDATE, USER, 'CNTA');
      ELSE
         UPDATE CNTA.SYS_DELETE SET MOMENTO = SYSDATE, USU�RIO = USER, LOCAL = 'CNTA' WHERE NOME_TABELA = 'ANEXO' AND CHAVE = :OLD.NOME;
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
            :NEW.SYS_USU�RIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'CNTA';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USU�RIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USU�RIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'CNTA';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_CONTA BEFORE UPDATE OR INSERT OR DELETE ON CNTA.CONTA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'CONTA' AND CHAVE = :OLD.EMPRESA || :OLD.CONTA;
      IF TOT_DEL = 0 THEN
         INSERT INTO CNTA.SYS_DELETE VALUES ('CONTA', :OLD.EMPRESA || :OLD.CONTA, SYSDATE, USER, 'CNTA');
      ELSE
         UPDATE CNTA.SYS_DELETE SET MOMENTO = SYSDATE, USU�RIO = USER, LOCAL = 'CNTA' WHERE NOME_TABELA = 'CONTA' AND CHAVE = :OLD.EMPRESA || :OLD.CONTA;
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
            :NEW.SYS_USU�RIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'CNTA';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USU�RIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USU�RIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'CNTA';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_EMPRESA BEFORE UPDATE OR INSERT OR DELETE ON CNTA.EMPRESA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'EMPRESA' AND CHAVE = :OLD.EMPRESA;
      IF TOT_DEL = 0 THEN
         INSERT INTO CNTA.SYS_DELETE VALUES ('EMPRESA', :OLD.EMPRESA, SYSDATE, USER, 'CNTA');
      ELSE
         UPDATE CNTA.SYS_DELETE SET MOMENTO = SYSDATE, USU�RIO = USER, LOCAL = 'CNTA' WHERE NOME_TABELA = 'EMPRESA' AND CHAVE = :OLD.EMPRESA;
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
            :NEW.SYS_USU�RIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'CNTA';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USU�RIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USU�RIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'CNTA';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_LOG_IMPORT BEFORE UPDATE OR INSERT OR DELETE ON CNTA.LOG_IMPORT FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'LOG_IMPORT' AND CHAVE = :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO CNTA.SYS_DELETE VALUES ('LOG_IMPORT', :OLD.SEQ, SYSDATE, USER, 'CNTA');
      ELSE
         UPDATE CNTA.SYS_DELETE SET MOMENTO = SYSDATE, USU�RIO = USER, LOCAL = 'CNTA' WHERE NOME_TABELA = 'LOG_IMPORT' AND CHAVE = :OLD.SEQ;
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
            :NEW.SYS_USU�RIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'CNTA';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USU�RIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USU�RIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'CNTA';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_MAPA BEFORE UPDATE OR INSERT OR DELETE ON CNTA.MAPA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'MAPA' AND CHAVE = :OLD.WORKSHEET || :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO CNTA.SYS_DELETE VALUES ('MAPA', :OLD.WORKSHEET || :OLD.SEQ, SYSDATE, USER, 'CNTA');
      ELSE
         UPDATE CNTA.SYS_DELETE SET MOMENTO = SYSDATE, USU�RIO = USER, LOCAL = 'CNTA' WHERE NOME_TABELA = 'MAPA' AND CHAVE = :OLD.WORKSHEET || :OLD.SEQ;
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
            :NEW.SYS_USU�RIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'CNTA';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USU�RIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USU�RIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'CNTA';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_PLAN_DEF BEFORE UPDATE OR INSERT OR DELETE ON CNTA.PLANILHA_DEF FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'PLANILHA_DEF' AND CHAVE = :OLD.WORKSHEET || :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO CNTA.SYS_DELETE VALUES ('PLANILHA_DEF', :OLD.WORKSHEET || :OLD.SEQ, SYSDATE, USER, 'CNTA');
      ELSE
         UPDATE CNTA.SYS_DELETE SET MOMENTO = SYSDATE, USU�RIO = USER, LOCAL = 'CNTA' WHERE NOME_TABELA = 'PLANILHA_DEF' AND CHAVE = :OLD.WORKSHEET || :OLD.SEQ;
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
            :NEW.SYS_USU�RIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'CNTA';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USU�RIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USU�RIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'CNTA';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_PLAN BEFORE UPDATE OR INSERT OR DELETE ON CNTA.PLANILHA_STC FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'PLANILHA_STC' AND CHAVE = :OLD.WORKSHEET;
      IF TOT_DEL = 0 THEN
         INSERT INTO CNTA.SYS_DELETE VALUES ('PLANILHA_STC', :OLD.WORKSHEET, SYSDATE, USER, 'CNTA');
      ELSE
         UPDATE CNTA.SYS_DELETE SET MOMENTO = SYSDATE, USU�RIO = USER, LOCAL = 'CNTA' WHERE NOME_TABELA = 'PLANILHA_STC' AND CHAVE = :OLD.WORKSHEET;
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
            :NEW.SYS_USU�RIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'CNTA';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USU�RIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USU�RIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'CNTA';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_SUB_CONTA BEFORE UPDATE OR INSERT OR DELETE ON CNTA.SUB_CONTA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'SUB_CONTA' AND CHAVE = :OLD.EMPRESA || :OLD.SUB_CONTA;
      IF TOT_DEL = 0 THEN
         INSERT INTO CNTA.SYS_DELETE VALUES ('SUB_CONTA', :OLD.EMPRESA || :OLD.SUB_CONTA, SYSDATE, USER, 'CNTA');
      ELSE
         UPDATE CNTA.SYS_DELETE SET MOMENTO = SYSDATE, USU�RIO = USER, LOCAL = 'CNTA' WHERE NOME_TABELA = 'SUB_CONTA' AND CHAVE = :OLD.EMPRESA || :OLD.SUB_CONTA;
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
            :NEW.SYS_USU�RIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'CNTA';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USU�RIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USU�RIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'CNTA';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_TRANS BEFORE UPDATE OR INSERT OR DELETE ON CNTA.TRANSA��O FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'TRANSA��O' AND CHAVE = :OLD.EMPRESA || :OLD.TRANSA��O;
      IF TOT_DEL = 0 THEN
         INSERT INTO CNTA.SYS_DELETE VALUES ('TRANSA��O', :OLD.EMPRESA || :OLD.TRANSA��O, SYSDATE, USER, 'CNTA');
      ELSE
         UPDATE CNTA.SYS_DELETE SET MOMENTO = SYSDATE, USU�RIO = USER, LOCAL = 'CNTA' WHERE NOME_TABELA = 'TRANSA��O' AND CHAVE = :OLD.EMPRESA || :OLD.TRANSA��O;
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
            :NEW.SYS_USU�RIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'CNTA';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USU�RIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USU�RIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'CNTA';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER BEF_TRANS_LANCE BEFORE UPDATE OR INSERT OR DELETE ON CNTA.TRANSA��O_LANCE FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
BEGIN
   IF DELETING Then
      SELECT COUNT(*) INTO TOT_DEL FROM SYS_DELETE WHERE NOME_TABELA = 'TRANSA��O_LANCE' AND CHAVE = :OLD.EMPRESA || :OLD.TRANSA��O || :OLD.SEQ;
      IF TOT_DEL = 0 THEN
         INSERT INTO CNTA.SYS_DELETE VALUES ('TRANSA��O_LANCE', :OLD.EMPRESA || :OLD.TRANSA��O || :OLD.SEQ, SYSDATE, USER, 'CNTA');
      ELSE
         UPDATE CNTA.SYS_DELETE SET MOMENTO = SYSDATE, USU�RIO = USER, LOCAL = 'CNTA' WHERE NOME_TABELA = 'TRANSA��O_LANCE' AND CHAVE = :OLD.EMPRESA || :OLD.TRANSA��O || :OLD.SEQ;
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
            :NEW.SYS_USU�RIO_CRIA := USER;
            :NEW.SYS_LOCAL_CRIA := 'CNTA';
            :NEW.SYS_MOMENTO_ATUALIZA := NULL;
            :NEW.SYS_USU�RIO_ATUALIZA := NULL;
            :NEW.SYS_LOCAL_ATUALIZA := NULL;
            :NEW.SYS_STATUS := 'I';
         END IF;
         IF UPDATING THEN
            :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
            :NEW.SYS_USU�RIO_ATUALIZA := USER;
            :NEW.SYS_LOCAL_ATUALIZA := 'CNTA';
            :NEW.SYS_STATUS := 'A';
         END IF;
      END IF;
   END IF;
END;
/

CREATE USER ADMIN IDENTIFIED BY XXXXXX
DEFAULT TABLESPACE T_CNTA_DAT
TEMPORARY TABLESPACE TEMP
PROFILE DEFAULT
ACCOUNT UNLOCK;
GRANT CREATE SESSION, EXECUTE ANY LIBRARY, EXECUTE ANY PROCEDURE TO ADMIN;
GRANT SELECT ANY TABLE, INSERT ANY TABLE, UPDATE ANY TABLE, DELETE ANY TABLE TO ADMIN;

