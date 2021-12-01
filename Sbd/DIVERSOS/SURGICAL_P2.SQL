SET ECHO ON
SPOOL C:\SURGICAL_PARTE2.LOG
CONNECT SURGICAL/XXXX@SBDB;

-- ELIMINA OS JOBS
begin
for cur in (select job from user_jobs where schema_user='SURGICAL') loop
dbms_job.remove(cur.job);
end loop;
end;
/

-- CRIA ÍNDICES


/* **********************************************************************************
   CRIAÇÃO DE RELACIONAMENTOS
*/

ALTER TABLE SURGICAL."ACOMPANHA" ADD CONSTRAINT "ACOMPANHA_ACOMPANHA_01" FOREIGN KEY("ARTIGO_SEQ", "ACOMP_SEQ_ANTERIOR") REFERENCES SURGICAL."ACOMPANHA"("ARTIGO_SEQ", "SEQ");
ALTER TABLE SURGICAL."ARTIGO_RESPONSAVEL" ADD CONSTRAINT "ARTIGO_ARTIGO_RESPONSAVEL_01" FOREIGN KEY("ARTIGO_SEQ") REFERENCES SURGICAL."ARTIGO"("SEQ");
ALTER TABLE SURGICAL."ARTIGOV" ADD CONSTRAINT "ARTIGO_ARTIGOV_01" FOREIGN KEY("ARTIGO_SEQ") REFERENCES SURGICAL."ARTIGO"("SEQ");
ALTER TABLE SURGICAL."QUESTAO" ADD CONSTRAINT "ARTIGO_QUESTAO_01" FOREIGN KEY("ARTIGO_SEQ") REFERENCES SURGICAL."ARTIGO"("SEQ");
ALTER TABLE SURGICAL."ACOMPANHA" ADD CONSTRAINT "ARTIGOV_ACOMPANHA_01" FOREIGN KEY("ARTIGO_SEQ", "NUM_VERSAO") REFERENCES SURGICAL."ARTIGOV"("ARTIGO_SEQ", "NUM_VERSAO");
ALTER TABLE SURGICAL."ARTIGOV_PALAVRA" ADD CONSTRAINT "ARTIGOV_ARTIGOV_PALAVRA_01" FOREIGN KEY("ARTIGO_SEQ", "NUM_VERSAO") REFERENCES SURGICAL."ARTIGOV"("ARTIGO_SEQ", "NUM_VERSAO");
ALTER TABLE SURGICAL."ARTIGOV_REF" ADD CONSTRAINT "ARTIGOV_ARTIGOV_REF_01" FOREIGN KEY("ARTIGO_SEQ", "NUM_VERSAO") REFERENCES SURGICAL."ARTIGOV"("ARTIGO_SEQ", "NUM_VERSAO");
ALTER TABLE SURGICAL."DESCRITOR_QUALIF" ADD CONSTRAINT "DESCRITOR_DESCRITOR_QUALIF_01" FOREIGN KEY("DESCRITOR_SEQ") REFERENCES SURGICAL."DESCRITOR"("SEQ");
ALTER TABLE SURGICAL."ETAPA_ACOMPANHA_DESTINO" ADD CONSTRAINT "ETAP_ACOMP_ETAP_ACOMP_DES_01" FOREIGN KEY("ETAPA_DESTINO_SEQ") REFERENCES SURGICAL."ETAPA_ACOMPANHA"("SEQ");
ALTER TABLE SURGICAL."ETAPA_CHECKLIST" ADD CONSTRAINT "ETAP_ACOMPANHA_ETAPA_CHLIST_01" FOREIGN KEY("ETAPA_ACOMPANHA_SEQ") REFERENCES SURGICAL."ETAPA_ACOMPANHA"("SEQ");
ALTER TABLE SURGICAL."ACOMPANHA" ADD CONSTRAINT "ETAPA_ACOMPANHA_ACOMPANHA_01" FOREIGN KEY("ETAPA_ACOMPANHA_SEQ") REFERENCES SURGICAL."ETAPA_ACOMPANHA"("SEQ");
ALTER TABLE SURGICAL."TRADUZ" ADD CONSTRAINT "ETAPA_ACOMPANHA_TRADUZ_01" FOREIGN KEY("ETAPA_ACOMPANHA_SEQ") REFERENCES SURGICAL."ETAPA_ACOMPANHA"("SEQ");
ALTER TABLE SURGICAL."TIPO_TRADUCAO" ADD CONSTRAINT "IDIOMA_TIPO_TRADUCAO_01" FOREIGN KEY("PARA") REFERENCES SURGICAL."IDIOMA"("COD");
ALTER TABLE SURGICAL."ARTIGOV_MATERIAL" ADD CONSTRAINT "MATERIAL_ARTIGOV_MATERIAL_01" FOREIGN KEY("MATERIAL_SEQ") REFERENCES SURGICAL."MATERIAL"("SEQ");
ALTER TABLE SURGICAL."RESPONSAVEL" ADD CONSTRAINT "PAIS_RESPONSAVEL_01" FOREIGN KEY("PAIS_SEQ") REFERENCES SURGICAL."PAIS"("SEQ");
ALTER TABLE SURGICAL."QUESTAO_RESPOSTA" ADD CONSTRAINT "QUESTAO_QUESTAO_RESPOSTA_01" FOREIGN KEY("ARTIGO_SEQ", "QUESTAO_SEQ") REFERENCES SURGICAL."QUESTAO"("ARTIGO_SEQ", "SEQ");
ALTER TABLE SURGICAL."ACOMPANHA" ADD CONSTRAINT "RESPONSAVEL_ACOMPANHA_01" FOREIGN KEY("RESPONSAVEL_SEQ") REFERENCES SURGICAL."RESPONSAVEL"("SEQ");
ALTER TABLE SURGICAL."ARTIGO" ADD CONSTRAINT "RESPONSAVEL_ARTIGO_01" FOREIGN KEY("PARECER_A_SEQ") REFERENCES SURGICAL."RESPONSAVEL"("SEQ");
ALTER TABLE SURGICAL."ARTIGO" ADD CONSTRAINT "RESPONSAVEL_ARTIGO_02" FOREIGN KEY("EDITOR_RESP_SEQ") REFERENCES SURGICAL."RESPONSAVEL"("SEQ");
ALTER TABLE SURGICAL."ARTIGO" ADD CONSTRAINT "RESPONSAVEL_ARTIGO_03" FOREIGN KEY("PARECER_C_SEQ") REFERENCES SURGICAL."RESPONSAVEL"("SEQ");
ALTER TABLE SURGICAL."ARTIGO" ADD CONSTRAINT "RESPONSAVEL_ARTIGO_04" FOREIGN KEY("PARECER_B_SEQ") REFERENCES SURGICAL."RESPONSAVEL"("SEQ");
ALTER TABLE SURGICAL."ARTIGO" ADD CONSTRAINT "RESPONSAVEL_ARTIGO_05" FOREIGN KEY("PARECER_E_SEQ") REFERENCES SURGICAL."RESPONSAVEL"("SEQ");
ALTER TABLE SURGICAL."ARTIGO_RESPONSAVEL" ADD CONSTRAINT "RESPONSAVEL_ARTIGO_RESP_01" FOREIGN KEY("RESPONSAVEL_SEQ") REFERENCES SURGICAL."RESPONSAVEL"("SEQ");
ALTER TABLE SURGICAL."ARTIGOV" ADD CONSTRAINT "RESPONSAVEL_ARTIGOV_01" FOREIGN KEY("RESPONSAVEL_SEQ") REFERENCES SURGICAL."RESPONSAVEL"("SEQ");
ALTER TABLE SURGICAL."RESPONSAVEL_TRADUCAO" ADD CONSTRAINT "RESPONSAVEL_RESP_TRADUCAO_01" FOREIGN KEY("RESPONSAVEL_SEQ") REFERENCES SURGICAL."RESPONSAVEL"("SEQ");
ALTER TABLE SURGICAL."TEMA_RESPONSAVEL" ADD CONSTRAINT "RESPONSAVEL_TEMA_RESP_01" FOREIGN KEY("RESPONSAVEL_SEQ") REFERENCES SURGICAL."RESPONSAVEL"("SEQ");
ALTER TABLE SURGICAL."TRADUZ" ADD CONSTRAINT "RESPONSAVEL_TRADUZ_01" FOREIGN KEY("SOLICITANTE") REFERENCES SURGICAL."RESPONSAVEL"("SEQ");
ALTER TABLE SURGICAL."TRADUZ" ADD CONSTRAINT "RESPONSAVEL_TRADUZ_02" FOREIGN KEY("COLABORADOR") REFERENCES SURGICAL."RESPONSAVEL"("SEQ");
ALTER TABLE SURGICAL."ARTIGO" ADD CONSTRAINT "REVISTA_ARTIGO_01" FOREIGN KEY("VOLUME_NUM", "REVISTA_ID") REFERENCES SURGICAL."REVISTA"("VOLUME_NUM", "ID");
ALTER TABLE SURGICAL."REVISTA" ADD CONSTRAINT "REVISTA_SITUACAO_REVISTA_01" FOREIGN KEY("SITUACAO_COD") REFERENCES SURGICAL."REVISTA_SITUACAO"("COD");
ALTER TABLE SURGICAL."ARTIGOV" ADD CONSTRAINT "SECAO_ARTIGOV_01" FOREIGN KEY("SECAO_SEQ") REFERENCES SURGICAL."SECAO"("SEQ");
ALTER TABLE SURGICAL."ACOMPANHA" ADD CONSTRAINT "STATUS_ACOMPANHA_ACOMPANHA_01" FOREIGN KEY("STATUS_ACOMPANHA_COD") REFERENCES SURGICAL."STATUS_ACOMPANHA"("COD");
ALTER TABLE SURGICAL."ARTIGOV" ADD CONSTRAINT "TEMA_ARTIGOV_01" FOREIGN KEY("TEMA_SEQ") REFERENCES SURGICAL."TEMA"("SEQ");
ALTER TABLE SURGICAL."TEMA_RESPONSAVEL" ADD CONSTRAINT "TEMA_TEMA_RESPONSAVEL_01" FOREIGN KEY("TEMA_SEQ") REFERENCES SURGICAL."TEMA"("SEQ");
ALTER TABLE SURGICAL."LOG" ADD CONSTRAINT "TIPO_LOG_LOG_01" FOREIGN KEY("TIPO") REFERENCES SURGICAL."TIPO_LOG"("COD");
ALTER TABLE SURGICAL."LOG" ADD CONSTRAINT "TIPO_MEIO_LOG_01" FOREIGN KEY("MEIO") REFERENCES SURGICAL."TIPO_MEIO"("COD");
ALTER TABLE SURGICAL."RESPONSAVEL_TRADUCAO" ADD CONSTRAINT "TIPO_TRAD_RESP_TRADUCAO_01" FOREIGN KEY("TRADUCAO_MODELO") REFERENCES SURGICAL."TIPO_TRADUCAO"("MODELO");
ALTER TABLE SURGICAL."TRADUZ" ADD CONSTRAINT "TIPO_TRADUCAO_TRADUZ_01" FOREIGN KEY("MODELO") REFERENCES SURGICAL."TIPO_TRADUCAO"("MODELO");
ALTER TABLE SURGICAL."REVISTA" ADD CONSTRAINT "VOLUME_REVISTA_01" FOREIGN KEY("VOLUME_NUM") REFERENCES SURGICAL."VOLUME"("NUM");
ALTER TABLE SURGICAL."ETAPA_ACOMPANHA_DESTINO" ADD CONSTRAINT "ETAP_ACOMP_ETAP_ACOMP_DES_02" FOREIGN KEY("ETAPA_ACOMPANHA_SEQ") REFERENCES SURGICAL."ETAPA_ACOMPANHA"("SEQ");
ALTER TABLE SURGICAL."LOG" ADD CONSTRAINT "MSG_PADRAO_LOG_01" FOREIGN KEY("MSG_PADRAO") REFERENCES SURGICAL."MSG_PADRAO"("SEQ");
ALTER TABLE SURGICAL."ACOMPANHA" ADD CONSTRAINT "ARTIGO_ACOMPANHA_01" FOREIGN KEY("ARTIGO_SEQ") REFERENCES SURGICAL."ARTIGO"("SEQ");
ALTER TABLE SURGICAL."DESCRITOR_QUALIF" ADD CONSTRAINT "QUALIFICADOR_DESCRITOR_QUAL_01" FOREIGN KEY("QUALIFICADOR_SEQ") REFERENCES SURGICAL."QUALIFICADOR"("SEQ");


/* **********************************************************************************
   CONSTRAINTS BASE EM CHECK
*/

/* **********************************************************************************
   CRIAÇÃO DE TRIGGERS PARA REGISTRO DE INCLUSÃO, ATUALIZAÇÃO E EXCLUSÃO
*/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_ACOMPANHA BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.ACOMPANHA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'ACOMPANHA' AND CHAVE || '' = :OLD.ARTIGO_SEQ || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('ACOMPANHA', :OLD.ARTIGO_SEQ || :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'ACOMPANHA' AND CHAVE || ''= :OLD.ARTIGO_SEQ || :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_ARTIGO BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.ARTIGO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'ARTIGO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('ARTIGO', :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'ARTIGO' AND CHAVE || ''= :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_ARTIGO_RESPONSAVEL BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.ARTIGO_RESPONSAVEL FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'ARTIGO_RESPONSAVEL' AND CHAVE || '' = :OLD.ARTIGO_SEQ || :OLD.RESPONSAVEL_SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('ARTIGO_RESPONSAVEL', :OLD.ARTIGO_SEQ || :OLD.RESPONSAVEL_SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'ARTIGO_RESPONSAVEL' AND CHAVE || ''= :OLD.ARTIGO_SEQ || :OLD.RESPONSAVEL_SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_ARTIGOV BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.ARTIGOV FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'ARTIGOV' AND CHAVE || '' = :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('ARTIGOV', :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'ARTIGOV' AND CHAVE || ''= :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_ARTIGOV_COMENTARIO BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.ARTIGOV_COMENTARIO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'ARTIGOV_COMENTARIO' AND CHAVE || '' = :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('ARTIGOV_COMENTARIO', :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO || :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'ARTIGOV_COMENTARIO' AND CHAVE || ''= :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO || :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_ARTIGOV_MATERIAL BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.ARTIGOV_MATERIAL FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'ARTIGOV_MATERIAL' AND CHAVE || '' = :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('ARTIGOV_MATERIAL', :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO || :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'ARTIGOV_MATERIAL' AND CHAVE || ''= :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO || :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_ARTIGOV_PALAVRA BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.ARTIGOV_PALAVRA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'ARTIGOV_PALAVRA' AND CHAVE || '' = :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('ARTIGOV_PALAVRA', :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO || :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'ARTIGOV_PALAVRA' AND CHAVE || ''= :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO || :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_ARTIGOV_REF BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.ARTIGOV_REF FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'ARTIGOV_REF' AND CHAVE || '' = :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('ARTIGOV_REF', :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO || :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'ARTIGOV_REF' AND CHAVE || ''= :OLD.ARTIGO_SEQ || :OLD.NUM_VERSAO || :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_ASSINATURA BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.ASSINATURA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'ASSINATURA' AND CHAVE || '' = :OLD.ID || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('ASSINATURA', :OLD.ID, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'ASSINATURA' AND CHAVE || ''= :OLD.ID || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_ASSINATURA_PF BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.ASSINATURA_PF FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'ASSINATURA_PF' AND CHAVE || '' = :OLD.PF_ID || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('ASSINATURA_PF', :OLD.PF_ID, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'ASSINATURA_PF' AND CHAVE || ''= :OLD.PF_ID || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_ASSINATURA_PJ BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.ASSINATURA_PJ FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'ASSINATURA_PJ' AND CHAVE || '' = :OLD.PJ_ID || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('ASSINATURA_PJ', :OLD.PJ_ID, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'ASSINATURA_PJ' AND CHAVE || ''= :OLD.PJ_ID || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_AVISO BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.AVISO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'AVISO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('AVISO', :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'AVISO' AND CHAVE || ''= :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_DESCRITOR BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.DESCRITOR FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'DESCRITOR' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('DESCRITOR', :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'DESCRITOR' AND CHAVE || ''= :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_DESCRITOR_QUALIF BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.DESCRITOR_QUALIF FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'DESCRITOR_QUALIF' AND CHAVE || '' = :OLD.DESCRITOR_SEQ || :OLD.QUALIFICADOR_SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('DESCRITOR_QUALIF', :OLD.DESCRITOR_SEQ || :OLD.QUALIFICADOR_SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'DESCRITOR_QUALIF' AND CHAVE || ''= :OLD.DESCRITOR_SEQ || :OLD.QUALIFICADOR_SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_ETAPA_ACOMPANHA BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.ETAPA_ACOMPANHA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'ETAPA_ACOMPANHA' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('ETAPA_ACOMPANHA', :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'ETAPA_ACOMPANHA' AND CHAVE || ''= :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_ETAPA_ACOMPANHA_DESTINO BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.ETAPA_ACOMPANHA_DESTINO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'ETAPA_ACOMPANHA_DESTINO' AND CHAVE || '' = :OLD.ETAPA_ACOMPANHA_SEQ || :OLD.ETAPA_DESTINO_SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('ETAPA_ACOMPANHA_DESTINO', :OLD.ETAPA_ACOMPANHA_SEQ || :OLD.ETAPA_DESTINO_SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'ETAPA_ACOMPANHA_DESTINO' AND CHAVE || ''= :OLD.ETAPA_ACOMPANHA_SEQ || :OLD.ETAPA_DESTINO_SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_ETAPA_CHECKLIST BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.ETAPA_CHECKLIST FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'ETAPA_CHECKLIST' AND CHAVE || '' = :OLD.ETAPA_ACOMPANHA_SEQ || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('ETAPA_CHECKLIST', :OLD.ETAPA_ACOMPANHA_SEQ || :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'ETAPA_CHECKLIST' AND CHAVE || ''= :OLD.ETAPA_ACOMPANHA_SEQ || :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_IDIOMA BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.IDIOMA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'IDIOMA' AND CHAVE || '' = :OLD.COD || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('IDIOMA', :OLD.COD, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'IDIOMA' AND CHAVE || ''= :OLD.COD || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_LOG BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.LOG FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'LOG' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('LOG', :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'LOG' AND CHAVE || ''= :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_MATERIAL BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.MATERIAL FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'MATERIAL' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('MATERIAL', :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'MATERIAL' AND CHAVE || ''= :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_MSG_PADRAO BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.MSG_PADRAO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'MSG_PADRAO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('MSG_PADRAO', :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'MSG_PADRAO' AND CHAVE || ''= :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_PAIS BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.PAIS FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'PAIS' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('PAIS', :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'PAIS' AND CHAVE || ''= :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_QUALIFICADOR BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.QUALIFICADOR FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'QUALIFICADOR' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('QUALIFICADOR', :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'QUALIFICADOR' AND CHAVE || ''= :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_QUESTAO BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.QUESTAO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'QUESTAO' AND CHAVE || '' = :OLD.ARTIGO_SEQ || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('QUESTAO', :OLD.ARTIGO_SEQ || :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'QUESTAO' AND CHAVE || ''= :OLD.ARTIGO_SEQ || :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_QUESTAO_RESPOSTA BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.QUESTAO_RESPOSTA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'QUESTAO_RESPOSTA' AND CHAVE || '' = :OLD.ARTIGO_SEQ || :OLD.QUESTAO_SEQ || :OLD.LETRA || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('QUESTAO_RESPOSTA', :OLD.ARTIGO_SEQ || :OLD.QUESTAO_SEQ || :OLD.LETRA, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'QUESTAO_RESPOSTA' AND CHAVE || ''= :OLD.ARTIGO_SEQ || :OLD.QUESTAO_SEQ || :OLD.LETRA || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_QUESTIONARIO_RESPOSTA BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.QUESTIONARIO_RESPOSTA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'QUESTIONARIO_RESPOSTA' AND CHAVE || '' = :OLD.ARTIGO_SEQ || :OLD.CRM || :OLD.CRM_ESTADO || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('QUESTIONARIO_RESPOSTA', :OLD.ARTIGO_SEQ || :OLD.CRM || :OLD.CRM_ESTADO, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'QUESTIONARIO_RESPOSTA' AND CHAVE || ''= :OLD.ARTIGO_SEQ || :OLD.CRM || :OLD.CRM_ESTADO || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_RESPONSAVEL BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.RESPONSAVEL FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'RESPONSAVEL' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('RESPONSAVEL', :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'RESPONSAVEL' AND CHAVE || ''= :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_RESPONSAVEL_TRADUCAO BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.RESPONSAVEL_TRADUCAO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'RESPONSAVEL_TRADUCAO' AND CHAVE || '' = :OLD.RESPONSAVEL_SEQ || :OLD.TRADUCAO_MODELO || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('RESPONSAVEL_TRADUCAO', :OLD.RESPONSAVEL_SEQ || :OLD.TRADUCAO_MODELO, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'RESPONSAVEL_TRADUCAO' AND CHAVE || ''= :OLD.RESPONSAVEL_SEQ || :OLD.TRADUCAO_MODELO || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_REVISTA BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.REVISTA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'REVISTA' AND CHAVE || '' = :OLD.VOLUME_NUM || :OLD.ID || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('REVISTA', :OLD.VOLUME_NUM || :OLD.ID, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'REVISTA' AND CHAVE || ''= :OLD.VOLUME_NUM || :OLD.ID || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_REVISTA_SITUACAO BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.REVISTA_SITUACAO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'REVISTA_SITUACAO' AND CHAVE || '' = :OLD.COD || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('REVISTA_SITUACAO', :OLD.COD, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'REVISTA_SITUACAO' AND CHAVE || ''= :OLD.COD || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_SECAO BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.SECAO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'SECAO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SECAO', :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'SECAO' AND CHAVE || ''= :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_SITE_BOLETO BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.SITE_BOLETO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'SITE_BOLETO' AND CHAVE || '' = :OLD.TIPO || :OLD.NUMERO_BOLETO || :OLD.ASSINATURA_ID || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SITE_BOLETO', :OLD.TIPO || :OLD.NUMERO_BOLETO || :OLD.ASSINATURA_ID, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'SITE_BOLETO' AND CHAVE || ''= :OLD.TIPO || :OLD.NUMERO_BOLETO || :OLD.ASSINATURA_ID || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_STATUS_ACOMPANHA BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.STATUS_ACOMPANHA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'STATUS_ACOMPANHA' AND CHAVE || '' = :OLD.COD || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('STATUS_ACOMPANHA', :OLD.COD, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'STATUS_ACOMPANHA' AND CHAVE || ''= :OLD.COD || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_SYS_CONFIG_GLOBAL BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.SYS_CONFIG_GLOBAL FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'SYS_CONFIG_GLOBAL' AND CHAVE || '' = :OLD.PARAM || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_CONFIG_GLOBAL', :OLD.PARAM, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'SYS_CONFIG_GLOBAL' AND CHAVE || ''= :OLD.PARAM || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_SYS_CONFIG_USUARIO BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.SYS_CONFIG_USUARIO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'SYS_CONFIG_USUARIO' AND CHAVE || '' = :OLD.USUARIO || :OLD.PARAM || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_CONFIG_USUARIO', :OLD.USUARIO || :OLD.PARAM, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'SYS_CONFIG_USUARIO' AND CHAVE || ''= :OLD.USUARIO || :OLD.PARAM || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_SYS_LOCALID BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.SYS_LOCALID FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'SYS_LOCALID' AND CHAVE || '' = :OLD.NOME || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_LOCALID', :OLD.NOME, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'SYS_LOCALID' AND CHAVE || ''= :OLD.NOME || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_SYS_OCORRENCIA BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.SYS_OCORRENCIA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'SYS_OCORRENCIA' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_OCORRENCIA', :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'SYS_OCORRENCIA' AND CHAVE || ''= :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_TEMA BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.TEMA FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'TEMA' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('TEMA', :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'TEMA' AND CHAVE || ''= :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_TEMA_RESPONSAVEL BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.TEMA_RESPONSAVEL FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'TEMA_RESPONSAVEL' AND CHAVE || '' = :OLD.TEMA_SEQ || :OLD.RESPONSAVEL_SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('TEMA_RESPONSAVEL', :OLD.TEMA_SEQ || :OLD.RESPONSAVEL_SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'TEMA_RESPONSAVEL' AND CHAVE || ''= :OLD.TEMA_SEQ || :OLD.RESPONSAVEL_SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_TIPO_LOG BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.TIPO_LOG FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'TIPO_LOG' AND CHAVE || '' = :OLD.COD || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('TIPO_LOG', :OLD.COD, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'TIPO_LOG' AND CHAVE || ''= :OLD.COD || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_TIPO_MEIO BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.TIPO_MEIO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'TIPO_MEIO' AND CHAVE || '' = :OLD.COD || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('TIPO_MEIO', :OLD.COD, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'TIPO_MEIO' AND CHAVE || ''= :OLD.COD || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_TIPO_TRADUCAO BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.TIPO_TRADUCAO FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'TIPO_TRADUCAO' AND CHAVE || '' = :OLD.MODELO || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('TIPO_TRADUCAO', :OLD.MODELO, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'TIPO_TRADUCAO' AND CHAVE || ''= :OLD.MODELO || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_TRADUZ BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.TRADUZ FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'TRADUZ' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('TRADUZ', :OLD.SEQ, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'TRADUZ' AND CHAVE || ''= :OLD.SEQ || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER SURGICAL.BEF_VOLUME BEFORE UPDATE OR INSERT OR DELETE ON SURGICAL.VOLUME FOR EACH ROW
DECLARE
   TOT_DEL INTEGER;
   -- variáveis que preencherão o retorno das consultas
   CONN_USER VARCHAR2(100);
   CONN_IP VARCHAR2(100);
   CONN_MACHINE VARCHAR2(100);
BEGIN
   IF LPAD(USER,5) <> 'REPL_' THEN
      -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via internet
      select module, client_info, action into conn_machine, conn_ip, conn_user from v$session where audsid = userenv('sessionid') and rownum = 1;
      -- No caso da variável CONN_IP ser nula, significará que o acesso está sendo feito localmente
      If (conn_ip Is null) Then
         -- Consulta que retornará o HOST, IP, USUÁRIO que acessou via CIAD
         select sys_context('userenv','host'), sys_context('userenv','ip_address'), sys_context('userenv','session_user') into conn_user, conn_ip, conn_machine from dual where rownum = 1;
      end if;
      IF DELETING Then
         SELECT COUNT(*) INTO TOT_DEL FROM SURGICAL.SYS_DELETE WHERE TABELA = 'VOLUME' AND CHAVE || '' = :OLD.NUM || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SURGICAL.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('VOLUME', :OLD.NUM, SYSDATE, USER, 'SURGICAL');
         ELSE
            UPDATE SURGICAL.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SURGICAL' WHERE TABELA = 'VOLUME' AND CHAVE || ''= :OLD.NUM || '';
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
               :NEW.SYS_USUARIO_CRIA := CONN_USER;
               :NEW.SYS_LOCAL_CRIA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_MOMENTO_ATUALIZA := NULL;
               :NEW.SYS_USUARIO_ATUALIZA := NULL;
               :NEW.SYS_LOCAL_ATUALIZA := NULL;
               :NEW.SYS_STATUS := 'I';
            END IF;
            IF UPDATING THEN
               :NEW.SYS_MOMENTO_ATUALIZA := SYSDATE;
               :NEW.SYS_USUARIO_ATUALIZA := CONN_USER;
               :NEW.SYS_LOCAL_ATUALIZA := CONN_MACHINE || ' [' || CONN_IP || ']';
               :NEW.SYS_STATUS := 'A';
            END IF;
         END IF;
      END IF;
   END IF;
END;
/

/* **********************************************************************************
   CRIAÇÃO DE TRIGGERS PARA ALTERAÇÃO EM CASCATA
*/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_ACOMPANHA_CCD
AFTER UPDATE ON SURGICAL.ACOMPANHA FOR EACH ROW
BEGIN

   --ACOMPANHA
   IF (:OLD.ARTIGO_SEQ <> :NEW.ARTIGO_SEQ) OR (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ACOMPANHA SET ARTIGO_SEQ = :NEW.ARTIGO_SEQ, ACOMP_SEQ_ANTERIOR = :NEW.SEQ WHERE ARTIGO_SEQ = :OLD.ARTIGO_SEQ AND ACOMP_SEQ_ANTERIOR = :OLD.SEQ AND NOT ARTIGO_SEQ IS NULL AND NOT ACOMP_SEQ_ANTERIOR IS NULL;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_ARTIGO_CCD
AFTER UPDATE ON SURGICAL.ARTIGO FOR EACH ROW
BEGIN

   --ARTIGO_RESPONSAVEL
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ARTIGO_RESPONSAVEL SET ARTIGO_SEQ = :NEW.SEQ WHERE ARTIGO_SEQ = :OLD.SEQ;
   END IF;

   --ARTIGOV
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ARTIGOV SET ARTIGO_SEQ = :NEW.SEQ WHERE ARTIGO_SEQ = :OLD.SEQ;
   END IF;

   --QUESTAO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.QUESTAO SET ARTIGO_SEQ = :NEW.SEQ WHERE ARTIGO_SEQ = :OLD.SEQ;
   END IF;

   --ACOMPANHA
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ACOMPANHA SET ARTIGO_SEQ = :NEW.SEQ WHERE ARTIGO_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_ARTIGOV_CCD
AFTER UPDATE ON SURGICAL.ARTIGOV FOR EACH ROW
BEGIN

   --ACOMPANHA
   IF (:OLD.ARTIGO_SEQ <> :NEW.ARTIGO_SEQ) OR (:OLD.NUM_VERSAO <> :NEW.NUM_VERSAO) THEN
      UPDATE SURGICAL.ACOMPANHA SET ARTIGO_SEQ = :NEW.ARTIGO_SEQ, NUM_VERSAO = :NEW.NUM_VERSAO WHERE ARTIGO_SEQ = :OLD.ARTIGO_SEQ AND NUM_VERSAO = :OLD.NUM_VERSAO AND NOT ARTIGO_SEQ IS NULL AND NOT NUM_VERSAO IS NULL;
   END IF;

   --ARTIGOV_PALAVRA
   IF (:OLD.ARTIGO_SEQ <> :NEW.ARTIGO_SEQ) OR (:OLD.NUM_VERSAO <> :NEW.NUM_VERSAO) THEN
      UPDATE SURGICAL.ARTIGOV_PALAVRA SET ARTIGO_SEQ = :NEW.ARTIGO_SEQ, NUM_VERSAO = :NEW.NUM_VERSAO WHERE ARTIGO_SEQ = :OLD.ARTIGO_SEQ AND NUM_VERSAO = :OLD.NUM_VERSAO AND NOT ARTIGO_SEQ IS NULL AND NOT NUM_VERSAO IS NULL;
   END IF;

   --ARTIGOV_REF
   IF (:OLD.ARTIGO_SEQ <> :NEW.ARTIGO_SEQ) OR (:OLD.NUM_VERSAO <> :NEW.NUM_VERSAO) THEN
      UPDATE SURGICAL.ARTIGOV_REF SET ARTIGO_SEQ = :NEW.ARTIGO_SEQ, NUM_VERSAO = :NEW.NUM_VERSAO WHERE ARTIGO_SEQ = :OLD.ARTIGO_SEQ AND NUM_VERSAO = :OLD.NUM_VERSAO AND NOT ARTIGO_SEQ IS NULL AND NOT NUM_VERSAO IS NULL;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_DESCRITOR_CCD
AFTER UPDATE ON SURGICAL.DESCRITOR FOR EACH ROW
BEGIN

   --DESCRITOR_QUALIF
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.DESCRITOR_QUALIF SET DESCRITOR_SEQ = :NEW.SEQ WHERE DESCRITOR_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_ETAPA_ACOMPAN_CCD
AFTER UPDATE ON SURGICAL.ETAPA_ACOMPANHA FOR EACH ROW
BEGIN

   --ETAPA_ACOMPANHA_DESTINO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ETAPA_ACOMPANHA_DESTINO SET ETAPA_DESTINO_SEQ = :NEW.SEQ WHERE ETAPA_DESTINO_SEQ = :OLD.SEQ;
   END IF;

   --ETAPA_CHECKLIST
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ETAPA_CHECKLIST SET ETAPA_ACOMPANHA_SEQ = :NEW.SEQ WHERE ETAPA_ACOMPANHA_SEQ = :OLD.SEQ;
   END IF;

   --ACOMPANHA
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ACOMPANHA SET ETAPA_ACOMPANHA_SEQ = :NEW.SEQ WHERE ETAPA_ACOMPANHA_SEQ = :OLD.SEQ;
   END IF;

   --TRADUZ
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.TRADUZ SET ETAPA_ACOMPANHA_SEQ = :NEW.SEQ WHERE ETAPA_ACOMPANHA_SEQ = :OLD.SEQ;
   END IF;

   --ETAPA_ACOMPANHA_DESTINO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ETAPA_ACOMPANHA_DESTINO SET ETAPA_ACOMPANHA_SEQ = :NEW.SEQ WHERE ETAPA_ACOMPANHA_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_IDIOMA_CCD
AFTER UPDATE ON SURGICAL.IDIOMA FOR EACH ROW
BEGIN

   --TIPO_TRADUCAO
   IF (:OLD.COD <> :NEW.COD) THEN
      UPDATE SURGICAL.TIPO_TRADUCAO SET PARA = :NEW.COD WHERE PARA = :OLD.COD;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_MATERIAL_CCD
AFTER UPDATE ON SURGICAL.MATERIAL FOR EACH ROW
BEGIN

   --ARTIGOV_MATERIAL
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ARTIGOV_MATERIAL SET MATERIAL_SEQ = :NEW.SEQ WHERE MATERIAL_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_MSG_PADRAO_CCD
AFTER UPDATE ON SURGICAL.MSG_PADRAO FOR EACH ROW
BEGIN

   --LOG
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.LOG SET MSG_PADRAO = :NEW.SEQ WHERE MSG_PADRAO = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_PAIS_CCD
AFTER UPDATE ON SURGICAL.PAIS FOR EACH ROW
BEGIN

   --RESPONSAVEL
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.RESPONSAVEL SET PAIS_SEQ = :NEW.SEQ WHERE PAIS_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_QUALIFICADOR_CCD
AFTER UPDATE ON SURGICAL.QUALIFICADOR FOR EACH ROW
BEGIN

   --DESCRITOR_QUALIF
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.DESCRITOR_QUALIF SET QUALIFICADOR_SEQ = :NEW.SEQ WHERE QUALIFICADOR_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_QUESTAO_CCD
AFTER UPDATE ON SURGICAL.QUESTAO FOR EACH ROW
BEGIN

   --QUESTAO_RESPOSTA
   IF (:OLD.ARTIGO_SEQ <> :NEW.ARTIGO_SEQ) OR (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.QUESTAO_RESPOSTA SET ARTIGO_SEQ = :NEW.ARTIGO_SEQ, QUESTAO_SEQ = :NEW.SEQ WHERE ARTIGO_SEQ = :OLD.ARTIGO_SEQ AND QUESTAO_SEQ = :OLD.SEQ AND NOT ARTIGO_SEQ IS NULL AND NOT QUESTAO_SEQ IS NULL;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_RESPONSAVEL_CCD
AFTER UPDATE ON SURGICAL.RESPONSAVEL FOR EACH ROW
BEGIN

   --ACOMPANHA
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ACOMPANHA SET RESPONSAVEL_SEQ = :NEW.SEQ WHERE RESPONSAVEL_SEQ = :OLD.SEQ;
   END IF;

   --ARTIGO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ARTIGO SET PARECER_A_SEQ = :NEW.SEQ WHERE PARECER_A_SEQ = :OLD.SEQ;
   END IF;

   --ARTIGO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ARTIGO SET EDITOR_RESP_SEQ = :NEW.SEQ WHERE EDITOR_RESP_SEQ = :OLD.SEQ;
   END IF;

   --ARTIGO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ARTIGO SET PARECER_C_SEQ = :NEW.SEQ WHERE PARECER_C_SEQ = :OLD.SEQ;
   END IF;

   --ARTIGO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ARTIGO SET PARECER_B_SEQ = :NEW.SEQ WHERE PARECER_B_SEQ = :OLD.SEQ;
   END IF;

   --ARTIGO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ARTIGO SET PARECER_E_SEQ = :NEW.SEQ WHERE PARECER_E_SEQ = :OLD.SEQ;
   END IF;

   --ARTIGO_RESPONSAVEL
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ARTIGO_RESPONSAVEL SET RESPONSAVEL_SEQ = :NEW.SEQ WHERE RESPONSAVEL_SEQ = :OLD.SEQ;
   END IF;

   --ARTIGOV
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ARTIGOV SET RESPONSAVEL_SEQ = :NEW.SEQ WHERE RESPONSAVEL_SEQ = :OLD.SEQ;
   END IF;

   --RESPONSAVEL_TRADUCAO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.RESPONSAVEL_TRADUCAO SET RESPONSAVEL_SEQ = :NEW.SEQ WHERE RESPONSAVEL_SEQ = :OLD.SEQ;
   END IF;

   --TEMA_RESPONSAVEL
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.TEMA_RESPONSAVEL SET RESPONSAVEL_SEQ = :NEW.SEQ WHERE RESPONSAVEL_SEQ = :OLD.SEQ;
   END IF;

   --TRADUZ
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.TRADUZ SET SOLICITANTE = :NEW.SEQ WHERE SOLICITANTE = :OLD.SEQ;
   END IF;

   --TRADUZ
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.TRADUZ SET COLABORADOR = :NEW.SEQ WHERE COLABORADOR = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_REVISTA_CCD
AFTER UPDATE ON SURGICAL.REVISTA FOR EACH ROW
BEGIN

   --ARTIGO
   IF (:OLD.VOLUME_NUM <> :NEW.VOLUME_NUM) OR (:OLD.ID <> :NEW.ID) THEN
      UPDATE SURGICAL.ARTIGO SET VOLUME_NUM = :NEW.VOLUME_NUM, REVISTA_ID = :NEW.ID WHERE VOLUME_NUM = :OLD.VOLUME_NUM AND REVISTA_ID = :OLD.ID AND NOT VOLUME_NUM IS NULL AND NOT REVISTA_ID IS NULL;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_REVISTA_SITUA_CCD
AFTER UPDATE ON SURGICAL.REVISTA_SITUACAO FOR EACH ROW
BEGIN

   --REVISTA
   IF (:OLD.COD <> :NEW.COD) THEN
      UPDATE SURGICAL.REVISTA SET SITUACAO_COD = :NEW.COD WHERE SITUACAO_COD = :OLD.COD;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_SECAO_CCD
AFTER UPDATE ON SURGICAL.SECAO FOR EACH ROW
BEGIN

   --ARTIGOV
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ARTIGOV SET SECAO_SEQ = :NEW.SEQ WHERE SECAO_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_STATUS_ACOMPA_CCD
AFTER UPDATE ON SURGICAL.STATUS_ACOMPANHA FOR EACH ROW
BEGIN

   --ACOMPANHA
   IF (:OLD.COD <> :NEW.COD) THEN
      UPDATE SURGICAL.ACOMPANHA SET STATUS_ACOMPANHA_COD = :NEW.COD WHERE STATUS_ACOMPANHA_COD = :OLD.COD;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_TEMA_CCD
AFTER UPDATE ON SURGICAL.TEMA FOR EACH ROW
BEGIN

   --ARTIGOV
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.ARTIGOV SET TEMA_SEQ = :NEW.SEQ WHERE TEMA_SEQ = :OLD.SEQ;
   END IF;

   --TEMA_RESPONSAVEL
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SURGICAL.TEMA_RESPONSAVEL SET TEMA_SEQ = :NEW.SEQ WHERE TEMA_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_TIPO_LOG_CCD
AFTER UPDATE ON SURGICAL.TIPO_LOG FOR EACH ROW
BEGIN

   --LOG
   IF (:OLD.COD <> :NEW.COD) THEN
      UPDATE SURGICAL.LOG SET TIPO = :NEW.COD WHERE TIPO = :OLD.COD;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_TIPO_MEIO_CCD
AFTER UPDATE ON SURGICAL.TIPO_MEIO FOR EACH ROW
BEGIN

   --LOG
   IF (:OLD.COD <> :NEW.COD) THEN
      UPDATE SURGICAL.LOG SET MEIO = :NEW.COD WHERE MEIO = :OLD.COD;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_TIPO_TRADUCAO_CCD
AFTER UPDATE ON SURGICAL.TIPO_TRADUCAO FOR EACH ROW
BEGIN

   --RESPONSAVEL_TRADUCAO
   IF (:OLD.MODELO <> :NEW.MODELO) THEN
      UPDATE SURGICAL.RESPONSAVEL_TRADUCAO SET TRADUCAO_MODELO = :NEW.MODELO WHERE TRADUCAO_MODELO = :OLD.MODELO;
   END IF;

   --TRADUZ
   IF (:OLD.MODELO <> :NEW.MODELO) THEN
      UPDATE SURGICAL.TRADUZ SET MODELO = :NEW.MODELO WHERE MODELO = :OLD.MODELO;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SURGICAL.AFT_VOLUME_CCD
AFTER UPDATE ON SURGICAL.VOLUME FOR EACH ROW
BEGIN

   --REVISTA
   IF (:OLD.NUM <> :NEW.NUM) THEN
      UPDATE SURGICAL.REVISTA SET VOLUME_NUM = :NEW.NUM WHERE VOLUME_NUM = :OLD.NUM;
   END IF;

END;
/

/* **********************************************************************************
   OUTROS CÓDIGOS E VISÕES EM GERAL
*/

-- OBJETO 100 | TRIGGER | BEF_ARTIGOV_BUSCA
create or replace TRIGGER SURGICAL.BEF_ARTIGOV_BUSCA BEFORE UPDATE OR INSERT
ON ANAIS2.ARTIGOV FOR EACH ROW
DECLARE
  TOT_DEL INTEGER;
BEGIN
  IF INSERTING OR
    UPDATING('TITULO') OR UPDATING('TITULO_I')  OR UPDATING('TITULO_E') OR
    UPDATING('RESUMO') OR UPDATING('RESUMO_I')  OR UPDATING('RESUMO_E') OR
    UPDATING('CONTEUDO') OR UPDATING('CONTEUDO_I')  OR UPDATING('CONTEUDO_E') THEN
  :NEW.ARTIGO_DECODE := HTMLDECODE(:NEW.TITULO || '|' || :NEW.TITULO_I || '|' ||
  :NEW.TITULO_E || '|' || :NEW.RESUMO || '|' || :NEW.RESUMO_I || '|' ||
  :NEW.RESUMO_E || '|' || :NEW.CONTEUDO || '|' || :NEW.CONTEUDO_I || '|' ||
  :NEW.CONTEUDO_E);
  END IF;
END;
/

-- OBJETO 101 | TRIGGER | ATUALIZA_BOLETO
create or replace TRIGGER SURGICAL.ATUALIZA_BOLETO BEFORE UPDATE OF BOLETO_PAGAMENTO ON SURGICAL.SITE_BOLETO FOR EACH ROW DECLARE CONT NUMBER;
BEGIN
  :NEW.ASSINATURA_FIM := ADD_MONTHS (SYSDATE, 12) ;
  :NEW.BOLETO_BAIXA := SYSDATE;
END;
/

-- OBJETO 200 | PACKAGE | LB
create or replace PACKAGE "LB" is
	function Litem(Texto in varchar2, Item in number, Sep in varchar2 default '') return varchar2;
	function Litem(Texto in varchar2, Item in varchar2, Sep in varchar2 default '') return number;
	function Lparam(Campo in varchar2, tipo in varchar2) return varchar2;
	function Lustr(Texto in varchar2) return varchar2;
	function Lextenso(VV in number, Ling in varchar2) return varchar2;
	function Lmontacento(Strv0 in varchar2, StrCem in varchar2, Sep in varchar2, StrDez in varchar2, StrPrimaDez in varchar2, StrUnid in varchar2) return varchar2;
	function Lconcatcamp(Dominio in varchar2, Delimit in varchar2) return varchar2;
	function Lnumling(Num in number, Masc in varchar2, Ling in varchar2) return varchar2;
 	function LInsereEspaco(Str in varchar2, Tamanho in number) return varchar2;
  Function LExibeData(Momento in Date, Formato in Varchar2 default '') return Varchar2;
	Procedure LExecutaString(cmdSql in Varchar);
  Procedure LCria_Job (vNomeJob in varchar2,vProced in varchar2, vHoraExec in varchar2,vIntervaloHoras in varchar2 default '24');
  Procedure LCria_Job_N(vNomeJob in varchar2, vProced in varchar2, vHoraExec in varchar2, vIntervaloDias in number default '1', vIntervalo in number default '1', vMetodo in VARCHAR2 default 'd');
  Procedure LApaga_Job (vNomeJob in varchar2);
end lb;
/

create or replace PACKAGE BODY "LB" is
function LItem(Texto in varchar2, Item in number, Sep in varchar2 default '') return varchar2 is
	Pos number;
	Pos2 number;
	Busca number;
	Limit varchar2(500);
Begin
		if Sep is null then
			if instr(Texto, ';') <> 0 then
				Limit := ';';
			else
				Limit := '.';
			end if;
		else
			Limit := Sep;
		end if;

		Busca := 0;
		Pos := 1;
		while Pos <= length(Texto) loop
			Pos2 := instr(Texto, Limit, Pos);
			if Pos2 = 0 then
				Pos2 := length(Texto)+1;
			end if;
			Busca := Busca + 1;
			if Busca = Item then
				return substr(Texto, Pos, Pos2-Pos);
			else
				Pos := Pos2 + 1;
			end if;
		end loop;
		return '';
	exception
		when others then
		raise_application_error ( -20000, 'erro em litem: ' || SQLERRM);

	end litem;

Function LItem(Texto in varchar2, Item in varchar2, Sep in varchar2 default '') return number is
	Pos number;
	Pos2 number;
	Busca number;
	Limit varchar2(500);

	begin
		if Sep is null then
			if instr(Texto, ';') <> 0 then
				Limit := ';';
			else
				Limit := '.';
			end if;
		else
			Limit := Sep;
		end if;

		Busca := 0;
		Pos := 1;

		while Pos <= length(Texto) loop
			Pos2 := instr(Texto, Limit, Pos);
			if Pos2 = 0 then
				Pos2 := length(Texto)+1;
			end if;
			Busca := Busca + 1;

			if not Item is null then
				if substr(Texto, Pos, Pos2-Pos) = Item then
					return Busca;
				end if;
			end if;

			Pos := Pos2 + 1;
		end loop;

		return 0;
	exception
		when others then
		raise_application_error ( -20000, 'erro em litem: ' || SQLERRM);

	end litem;


Function LParam(Campo in varchar2, Tipo in varchar2) return varchar2 is
	Pos integer;
	Pos2 integer;
	Texto varchar2(4000);
	begin
		Pos := instr(chr(13) || chr(10) || Campo, chr(13) || chr(10) || Tipo || ':');
		if Pos <> 0 then
			Pos := Pos + length(Tipo) + 1;
			Pos2 := instr(Campo, chr(13) || chr(10), pos);
			if Pos2 = 0 then
				Texto := substr(Campo, Pos);
			else
				Texto := substr(Campo, Pos, Pos2-Pos);
			end if;
		else
			return '';
		end if;

		return replace(Texto, '|', chr(10));
	exception
		when others then
			raise_application_error ( -20000, 'erro em lparam: ' || SQLERRM);

	end lparam;


Function LUstr(Texto in varchar2) return varchar2 is
	begin
		return replace(Texto, chr(13) || chr(10), chr(10));

	exception
		when others then
			raise_application_error ( -20000, 'erro em lustr: ' || SQLERRM);

	end lustr;


	function lextenso(VV in number, Ling in varchar2) return varchar2 is

	StrUnid varchar2(500);
	StrDez varchar2(500);
	StrCem varchar2(500);
	StrMil varchar2(500);
	StrCent varchar2(500);
	Moeda varchar2(500);
	Sep varchar2(500);
	StrPrimaDez varchar2(500);
	StrVV varchar2(500);
	StrV0 varchar2(500);
	StrMoeda varchar2(500);
	StrM0 varchar2(500);
	Esp varchar2(500);
	SepDec varchar2(500);
	Z number;
	SepAndTres varchar2(500);
	SepMil varchar2(500);

	begin

		if Ling = 'R$' then
    			StrUnid := 'Um;Dois;Três;Quatro;Cinco;Seis;Sete;Oito;Nove';
	    		StrPrimaDez := 'Onze;Doze;Treze;Quatorze;Quinze;Dezesseis;Dezesete;Dezoito;Dezenove';
	    		StrDez := 'Dez;Vinte;Trinta;Quarenta;Cinquenta;Sessenta;Setenta;Oitenta;Noventa';
	    		StrCem := 'Cento;Duzentos;Trezentos;Quatrocentos;Quinhentos;Seiscentos;Setecentos;Oitocentos;Novecentos';
	    		StrMil := 'Mil.Mil;Milhão.Milhões;Bilhão.Bilhões;Trilhão.Trilhões';
	    		StrCent := 'Centavo.Centavos';
	    		Moeda := 'Real;Reais;de Reais';
	    		Sep := ' e ';
	    		SepDec := ' e ';
	    		SepMil := ', ';
	    		SepAndTres := ' e ';
	    		Esp := ' ';
		elsif Ling = 'USD' or Ling = 'US$' or Ling = 'USD.' or Ling = 'U.S.DLRS' then
	    		StrUnid := 'One;Two;Three;Four;Five;Six;Seven;Eight;Nine';
	    		StrPrimaDez := 'Eleven;Twelve;Thirteen;Fourteen;Fifteen;Sixteen;Seventeen;Eighteen;Nineteen';
	    		StrDez := 'Tem;Twenty;Thirty;Forty;Fifty;Sixty;Seventy;Eighty;Ninety';
	    		StrCem := 'One Hundred;Two Hundred;Three Hundred;Four Hundred;Five Hundred;Six Hundred;Seven Hundred;Eight Hundred;Nine Hundred';
	    		StrMil := 'Thousand.Thousand;Million.Millions;Billion.Billions;Trillion.Trillions';
	    		StrCent := 'Cent.Cents';
			MOEDA := 'U.S. Dollar;U.S. Dollars;U.S. Dollars';
	    		Sep := ' ';
	    		SepDec := ' and ';
	    		SepMil := ', ';
	    		Esp := ' ';
	    		SepAndTres := ' and ';
		elsif Ling = 'DM' then
	    		StrUnid := 'One;Two;Three;Four;Five;Six;Seven;Eight;Nine';
	    		StrPrimaDez := 'Eleven;Twelve;Thirteen;Fourteen;Fifteen;Sixteen;Seventeen;Eighteen;Nineteen';
	    		StrDez := 'Tem;Twenty;Thirty;Forty;Fifty;Sixty;Seventy;Eighty;Ninety';
	    		StrCem := 'One Hundred;Two Hundred;Three Hundred;Four Hundred;Five Hundred;Six Hundred;Seven Hundred;Eight Hundred;Nine Hundred';
	    		StrMil := 'Thousand.Thousand;Million.Millions;Billion.Billions;Trillion.Trillions';
	    		StrCent := 'Cent.Cents';
	    		MOEDA := 'Deutsche Mark;Deutsche Mark;Deutsche Mark';
	    		Sep := ' ';
	    		SepDec := ' and ';
	   		SepMil := ', ';
	    		Esp := ' ';
	    		SepAndTres := ' and ';
		elsif Ling = 'YEN' then
	    		StrUnid := 'One;Two;Three;Four;Five;Six;Seven;Eight;Nine';
	    		StrPrimaDez := 'Eleven;Twelve;Thirteen;Fourteen;Fifteen;Sixteen;Seventeen;Eighteen;Nineteen';
	    		StrDez := 'Tem;Twenty;Thirty;Forty;Fifty;Sixty;Seventy;Eighty;Ninety';
	    		StrCem := 'One Hundred;Two Hundred;Three Hundred;Four Hundred;Five Hundred;Six Hundred;Seven Hundred;Eight Hundred;Nine Hundred';
	    		StrMil := 'Thousand.Thousand;Million.Millions;Billion.Billions;Trillion.Trillions';
	    		StrCent := 'Cent.Cents';
	    		MOEDA := 'Yen;Yen;Yen';
	    		Sep := ' ';
	    		SepDec := ' and ';
	    		SepMil := ', ';
	    		Esp := ' ';
	    		SepAndTres := ' and ';
		else
			return '#Erro';
		end if;
		StrVV := to_char(VV, 'FM000000000000000.00');
		for Z in 1..6 loop
			StrM0 := '';
	    		if Z <> 6 then
		      		StrV0 := substr(StrVV, Z * 3 - 2, 3);
				StrM0 := lmontacento(Strv0, StrCem, Sep, StrDez, StrPrimaDez, StrUnid);
				if not StrM0 is null or Z = 5 then
					if Z < 5 then
						if to_number(StrV0) = 1 then
							StrM0 := StrM0 || Esp || litem(litem(StrMil, 5 - Z, ';'), 1, '.');
						else
	                				StrM0 := StrM0 || Esp || litem(litem(StrMil, 5 - Z, ';'), 2, '.');
						end if;
	            			else
						if to_number(substr(StrVV, 1, 15)) <> 0 then
							if substr(StrVV, 10, 6) = 'FM000000' then
								StrM0 := StrM0 || Esp || litem(Moeda, 3, ';');
							elsif to_number(substr(StrVV, 1, 15)) = 1 then
								StrM0 := StrM0 || Esp || lItem(Moeda, 1, ';');
							elsif to_number(substr(StrVV, 1, 15)) <> 1 then
								StrM0 := StrM0 || Esp || litem(Moeda, 2, ';');
							end if;
	                			end if;
	            			end if;
	        		end if;
	    		else
				StrV0 := 0 || substr(StrVV, 17, 2);
				StrM0 := lmontacento(Strv0, StrCem, Sep, StrDez, StrPrimaDez, StrUnid);
			        if NOT StrM0 is null then
					if to_number(StrV0) = 1 then
	       					StrM0 := StrM0 || ' ' || litem(StrCent, 1, '.');
					else
	       					StrM0 := StrM0 || ' ' || litem(StrCent, 2, '.');
					end if;
				end if;

			end if;
			if not StrM0 is null then
			        if Z = 6 Then
					if not StrMoeda is null then
		            			StrMoeda := StrMoeda ||  SepDec || StrM0;
					else
		            			StrMoeda := StrMoeda || '' || StrM0;
					end if;
	        		else
					if not StrMoeda is null and to_number(StrV0) <> 0 then
						if to_number(StrV0) < 101 Or mod(to_number(StrV0), 100) = 0 then
							StrMoeda := StrMoeda || SepAndTres || StrM0;
						else
							StrMoeda := StrMoeda || SepMil || StrM0;
						end if;
					else
		            			StrMoeda := StrMoeda || '' || StrM0;
					end if;
	        		end if;
	    		end if;
		end loop;
		return StrMoeda;

	exception
		when others then
			raise_application_error ( -20000, 'erro em lextenso: ' || SQLERRM);

	end lextenso;


Function LMontacento (Strv0 in varchar2, StrCem in varchar2, Sep in varchar2, StrDez in varchar2, StrPrimaDez in varchar2, StrUnid in varchar2) return varchar2 is
	Pos number;
	ZZ number;
	StrM0 varchar2(100);
	begin
		for ZZ in 1..3 loop
	   		Pos := to_number(substr(Strv0, ZZ, 1));
			if POS <> 0 then
				if ZZ = 1 then
					StrM0 := StrM0 || litem(StrCem, Pos, ';');
				elsif ZZ = 2 then
					if Pos <> 1 Or substr(StrV0, 3, 1) = 0 then
						if not StrM0 is null then
							StrM0 := StrM0 || Sep || litem(StrDez, Pos, ';');
						else
							StrM0 := StrM0 || '' || litem(StrDez, Pos, ';');
						end if;
					else
						Pos := to_number(substr(StrV0, 3, 1));
						if not StrM0 is null then
							StrM0 := StrM0 || Sep || litem(StrPrimaDez, Pos, ';');
						else
							StrM0 := StrM0 || '' || litem(StrPrimaDez, Pos, ';');
						end if;
						exit;
					end if;

				elsif ZZ = 3 then
					if not StrM0 is null then
						StrM0 := StrM0 || Sep || litem(StrUnid, Pos, ';');
					else
						StrM0 := StrM0 || '' || litem(StrUnid, Pos, ';');
					end if;
				end if;
			end if;
		end loop;
		if StrM0 = 'Cento' then
			StrM0 := 'Cem';
		end if;
		return StrM0;

	exception
		when others then
			raise_application_error ( -20000, 'erro em lmontacento: ' || SQLERRM);

	end lmontacento;


Function LConcatcamp(Dominio in varchar2, Delimit in varchar2) return varchar2 is
	X pls_integer;
	Ret varchar2(4000);
	TextCol dbms_sql.varchar2_table;
	SqlCursor pls_integer;
	NumRows pls_integer;
	begin
		SqlCursor := dbms_sql.open_cursor;
		dbms_sql.parse(SqlCursor, Dominio, dbms_sql.v7);
		dbms_sql.define_array(SqlCursor, 1, TextCol, 10, 1);
		NumRows := dbms_sql.execute(SqlCursor);
		loop
			NumRows := dbms_sql.fetch_rows(SqlCursor);
			dbms_sql.column_value(SqlCursor, 1, TextCol);
			exit when NumRows < 10;
		end loop;
		dbms_sql.close_cursor(SqlCursor);

		Ret := '';
		for X in 1..TextCol.count loop
			if not Ret is null then
				Ret := Ret || Delimit;
			end if;
			Ret := Ret || TextCol(X);
		end loop;
		return Ret;

	exception
		when others then
			raise_application_error ( -20000, 'erro em lconcatcamp: ' || SQLERRM);
	end lconcatcamp;

	function lnumling(Num in number, Masc in varchar2, Ling in varchar2) return varchar2 is
	Result varchar2(1000);
	begin
		Result := to_char(Num, Masc);
		if Ling = 'P' then
			Result := replace(Result, ',', '@');
			Result := replace(Result, '.', ',');
			Result := replace(Result, '@', '.');
		end if;
		return trim(Result);

	exception
		when others then
			raise_application_error ( -20000, 'erro em lnumling: ' || SQLERRM);
	end lnumling;




        function LInsereEspaco(Str in varchar2, Tamanho in number) return varchar2 is
       	Result varchar2(1000);
        i number;
	begin
	            Result := Str;
		    if  Tamanho > (length(Result)) then
                        for i in 1..(tamanho - length(Result))  Loop begin
                            Result := CHR(32) || Result;
                            end;
			end loop;
		    end If;

		return Result;

	exception
		when others then
			raise_application_error ( -20000, 'erro em LinsereEspaco: ' || SQLERRM);
	end LinsereEspaco;


Procedure LExecutaString(cmdSql in Varchar) is
nresult integer;
Ccmd integer;
cmdExec varchar(32767);
begin
	cmdExec:=cmdSql;
	Ccmd:=sys.DBMS_SQL.OPEN_CURSOR;
	sys.dbms_sql.parse(Ccmd,cmdExec,DBMS_SQL.NATIVE);
	nresult:=sys.dbms_sql.execute(Ccmd);
	sys.dbms_sql.close_cursor(Ccmd);
EXCEPTION
	WHEN OTHERS THEN
	cmdExec:='';
end LExecutaString;

Function LExibeData(Momento in Date, Formato in Varchar2 default '') return Varchar2 is
  vDia Integer;
  vMes Integer;
  vAno Integer;
  vHora Integer;
  vMinuto Integer;
  vSegundo Integer;
  vMesExtPt Varchar2(200);
  vMesExtEn Varchar2(200);
  vMesExtEs Varchar2(200);
  Vsuf Integer;
  vCondicao Varchar2(2);
Begin
  vDia := Extract(day from Momento);
  vMes := Extract(Month from Momento);
  vAno := Extract(Year from Momento);
  vHora := EXTRACT(HOUR FROM TO_TIMESTAMP(Momento));
  vMinuto := EXTRACT(MINUTE FROM TO_TIMESTAMP(Momento));
  vSegundo := EXTRACT(SECOND FROM TO_TIMESTAMP(Momento));
  vMesExtPt := 'Janeiro,Fevereiro,Março,Abril,Maio,Junho,Julho,Agosto,Setembro,Outubro,Novembro,Dezembro';
  vMesExtEn := 'January,February,March,April,May,June,July,August,September,October,November,December';
  vMesExtEs := 'Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre';
  vSuf := vDia mod 10;
  if (vDia > 10) And (vDia < 14 ) then
    vCondicao := 'th';
  elsif vSuf = 1 then
    vCondicao := 'st';
  elsif vSuf = 2 then
    vCondicao := 'nd';
  elsif vSuf = 3 then
    vCondicao := 'rd';
  else
    vCondicao := 'th';
  end if;
  case
    when (Formato = 'sd') then Return to_char(Momento,'DD/MM/YYYY'); -- Simples Data DD/MM/YYYY
    when (Formato = 'sh') then Return to_char(Momento,'TS'); -- Simples Hora 24H:MI:SS
    when (Formato = 'p') or (Formato = 'dd de mmmm de yyyy') then Return vDia || ' de ' || lb.Litem(vMesExtPt,vMes,',') || ' de ' || vAno;
    when (Formato = 'c') or (Formato = 'dd de mmmm de yyyy c') then Return vDia || ' de ' || lb.Litem(vMesExtEs,vMes,',') || ' de ' || vAno;
    when (Formato = 'i') or (Formato = 'mmmm dth, yyyy') or (Formato = 'mmmm dth yyyy') then Return lb.Litem(vMesExtEn,vMes,',') || ' ' || vDia || vCondicao || ', ' || vAno;
    when (Formato = 'a') or (Formato = 'dd mmm yyyy') then Return substr(lb.Litem(vMesExtEn,vMes,','),1,3) || ' ' || vDia || vCondicao || ', ' || vAno;
    when (Formato = 'ai') or (Formato = 'dd mmm yyyy i') then Return lPad(vDia,2,'0') || ' ' || upper(lb.Litem(vMesExtEn,vMes,',')) || ', ' || lPad(vAno,4,'0');
    when (Formato = 'mmm dd, yyyy') or (Formato = 'mmm dd yyyy') then Return substr(upper(lb.Litem(vMesExtPt,vMes,',')),1,3) || ' ' || vDia ||  ', ' || lPad(vAno,4,'0');
    when (Formato = 'mmm dd, yyyy i') or (Formato = 'mmm dd yyyy i') then Return substr(upper(lb.Litem(vMesExtEn,vMes,',')),1,3) || ' ' || vDia ||  ', ' || lPad(vAno,4,'0');
    when (Formato = 'mmm dd, yyyy c') or (Formato = 'mmm dd yyyy c') then Return substr(upper(lb.Litem(vMesExtEs,vMes,',')),1,3) || ' ' || vDia ||  ', ' || lPad(vAno,4,'0');
    when (Formato = 'mmmm, yyyy') or (Formato = 'mmmm yyyy') then Return lb.Litem(vMesExtPt,vMes,',') || ', ' || lPad(vAno,4,'0');
    when (Formato = 'mmmm, yyyy i') or (Formato = 'mmmm yyyy i') then Return lb.Litem(vMesExtEn,vMes,',') || ', ' || vAno;
    when (Formato = 'mmmm, yyyy c') or (Formato = 'mmmm yyyy c') then Return lb.Litem(vMesExtEs,vMes,',') || ', ' || vAno;
    when (Formato = 'mmmm/yy') or (Formato = 'mmmm yy') then Return lb.Litem(vMesExtPt,vMes,',') || '/' || substr(vAno,3,2);
    when (Formato = 'mmm') then Return substr(upper(lb.Litem(vMesExtPt,vMes,',')),1,3);
    when (Formato = 'mmm i') then Return substr(upper(lb.Litem(vMesExtEn,vMes,',')),1,3);
    when (Formato = 'mmm c') then Return substr(upper(lb.Litem(vMesExtEs,vMes,',')),1,3);
    when (Formato = 'mmmm') then Return lb.Litem(vMesExtPt,vMes,',');
    when (Formato = 'mmmm i') then Return lb.Litem(vMesExtEn,vMes,',');
    when (Formato = 'mmmm c') then Return lb.Litem(vMesExtEs,vMes,',');
  else
    Return vDia || '/' || vMes || '/' || vAno || ' ' || vHora  || ':' || vMinuto || ':' || vSegundo;
  end case;

end LExibeData;

--------------------------------------------------------------------------------------------------------------
-- Procedimento para criação de jobs(tarefas) a serem executadas periodicamente no Oracle
--------------------------------------------------------------------------------------------------------------
Procedure LCria_Job(vNomeJob in varchar2,vProced in varchar2, vHoraExec in varchar2,vIntervaloHoras in varchar2 default '24') as job binary_integer;
begin
   begin
     for cur in (select job from user_jobs where what like '% ' || vNomeJob || ' %') loop
        dbms_job.remove(cur.job);
     end loop;
   exception
     when others then
       null;
   end;
   dbms_job.submit(job, '/* ' || vNomeJob || ' */begin ' || vProced || ';end;',to_date('' || to_char(sysdate,'DD/MM/YYYY') || ' ' || VHoraExec ||'','DD/MM/YYYY HH24:MI:SS'), 'TRUNC(SYSDATE + 1) + ' || vIntervaloHoras || ' / 24');
end LCria_Job;

Procedure LCria_Job_N(vNomeJob in varchar2, vProced in varchar2, vHoraExec in varchar2, vIntervaloDias in number default '1', vIntervalo in number default '1', vMetodo in VARCHAR2 default 'd') as
  job binary_integer;
  vMet Varchar2(30);
begin
   begin
     for cur in (select job from user_jobs where what like '% ' || vNomeJob || ' %') loop
        dbms_job.remove(cur.job);
     end loop;
   exception
     when others then
       null;
   end;
   case
     when vMetodo = 's' then vMet := 'SYSDATE + ' || vIntervalo || '/86400'; -- Intervalo em Segundos
     when vMetodo = 'm' then vMet := 'SYSDATE + ' || vIntervalo || '/1440'; -- Intervalo em Minutos
     when vMetodo = 'h' then vMet := 'SYSDATE + ' || vIntervalo || '/24'; -- Intervalo em Horas
     when vMetodo = 'd' then vMet := 'TRUNC(SYSDATE + '|| vIntervaloDias || ') + ' || vIntervalo || '/24'; -- Intervalo em Horas
     when vMetodo = 'x' then vMet := 'TRUNC(LAST_DAY(SYSDATE) + 1) + ' || vIntervalo || '/24'; -- Todo 1 dia do Mês
     when vMetodo = '2' then vMet := 'NEXT_DAY(TRUNC(SYSDATE), ''Monday'') + ' || vIntervalo || '/24)'; -- Tda Segunda na Hora Especificada
     when vMetodo = '3' then vMet := 'NEXT_DAY(TRUNC(SYSDATE), ''Tuesday'') + ' || vIntervalo || '/24)'; -- Tda Segunda na Hora Especificada
     when vMetodo = '4' then vMet := 'NEXT_DAY(TRUNC(SYSDATE), ''Wednesday'') + ' || vIntervalo || '/24)'; -- Tda Segunda na Hora Especificada
     when vMetodo = '5' then vMet := 'NEXT_DAY(TRUNC(SYSDATE), ''Thursday'') + ' || vIntervalo || '/24)'; -- Tda Segunda na Hora Especificada
     when vMetodo = '6' then vMet := 'NEXT_DAY(TRUNC(SYSDATE), ''Friday'') + ' || vIntervalo || '/24)'; -- Tda Segunda na Hora Especificada
     when vMetodo = 'S' then vMet := 'NEXT_DAY(TRUNC(SYSDATE), ''Saturday'') + ' || vIntervalo || '/24)'; -- Tda Segunda na Hora Especificada
     when vMetodo = 'D' then vMet := 'NEXT_DAY(TRUNC(SYSDATE), ''Sunday'') + ' || vIntervalo || '/24)'; -- Tda Segunda na Hora Especificada
   end case;
   dbms_job.submit(job, '/* ' || vNomeJob || ' */begin ' || vProced || ';end;',to_date('' || to_char(sysdate,'DD/MM/YYYY') || ' ' || VHoraExec ||'','DD/MM/YYYY HH24:MI:SS'), vMet);
end LCria_Job_N;

--------------------------------------------------------------------------------------------------------------
-- Procedimento para exclusão de jobs(tarefas) no Oracle
--------------------------------------------------------------------------------------------------------------
procedure LApaga_Job(vNomeJob in varchar2) as job binary_integer;
begin
  begin
    for cur in (select job from user_jobs where what like '% ' || vNomeJob || ' %') loop
      dbms_job.remove(cur.job);
    end loop;
  end;
end LApaga_Job;

end lb;
/

-- OBJETO 300 | VISÃO | SÓCIO
CREATE OR REPLACE VIEW SURGICAL.SÓCIO AS   SELECT
      MAT,
      NOME,
      CATEGORIA_COD,
      REGIONAL_COD,
      OBRIG_STATUS_COD,
      OBRIG_STATUS_DATA,
      ISENTO,
      CRM,
      CRM_ESTADO,
      CRM_DATA,
      CPF,
      DATA_CADASTRO,
      DATA_NASCIMENTO,
      SEXO,
      NACIONALIDADE,
      NATURALIDADE,
      FILIAÇÃO_PAI,
      FILIAÇÃO_MÃE,
      ENDEREÇO_RESIDENCIAL||DECODE(NUMERO_RESIDENCIAL, NULL, '', ', ') ||NUMERO_RESIDENCIAL||DECODE(COMPLEMENTO_RESIDENCIAL, NULL, '', '/ ') ||COMPLEMENTO_RESIDENCIAL AS ENDEREÇO_RESIDENCIAL,
      BAIRRO_RESIDENCIAL,
      CIDADE_RESIDENCIAL,
      DECODE(PAÍS_RESIDENCIAL, 'BRASIL', ESTADO_RESIDENCIAL, ESTADO_RESIDENCIAL_EX) AS ESTADO_RESIDENCIAL,
      PAÍS_RESIDENCIAL,
      CEP_RESIDENCIAL,
      DDI_RESIDENCIAL,
      DDD_RESIDENCIAL,
      TEL_RESIDENCIAL,
      FAX_RESIDENCIAL,
      TEL_CELULAR_RESIDENCIAL,
      EMAIL_RESIDENCIAL,
      MALA_DIRETA,
      ENDEREÇO_COMERCIAL_1||DECODE(NUMERO_COMERCIAL_1, NULL, '', ', ') ||NUMERO_COMERCIAL_1||DECODE(COMPLEMENTO_COMERCIAL_1, NULL, '', '/ ') ||COMPLEMENTO_COMERCIAL_1 AS ENDEREÇO_COMERCIAL_1,
      BAIRRO_COMERCIAL_1,
      CIDADE_COMERCIAL_1,
      DECODE(PAÍS_COMERCIAL_1, 'BRASIL', ESTADO_COMERCIAL_1, ESTADO_COMERCIAL_1_EX) AS ESTADO_COMERCIAL_1,
      PAÍS_COMERCIAL_1,
      CEP_COMERCIAL_1,
      DDI_COMERCIAL_1,
      DDD_COMERCIAL_1,
      TEL_COMERCIAL_1,
      FAX_COMERCIAL_1,
      EMAIL_COMERCIAL_1,
      ENDEREÇO_COMERCIAL_2||DECODE(NUMERO_COMERCIAL_2, NULL, '', ', ') ||NUMERO_COMERCIAL_2||DECODE(COMPLEMENTO_COMERCIAL_2, NULL, '', '/ ') ||COMPLEMENTO_COMERCIAL_2 AS ENDEREÇO_COMERCIAL_2,
      BAIRRO_COMERCIAL_2,
      CIDADE_COMERCIAL_2,
      DECODE(PAÍS_COMERCIAL_2, 'BRASIL', ESTADO_COMERCIAL_2, ESTADO_COMERCIAL_2_EX) AS ESTADO_COMERCIAL_2,
      CEP_COMERCIAL_2,
      PAÍS_COMERCIAL_2,
      DDI_COMERCIAL_2,
      DDD_COMERCIAL_2,
      TEL_COMERCIAL_2,
      FAX_COMERCIAL_2,
      EMAIL_COMERCIAL_2,
      TED,
      TED_ANO_CONCURSO,
      TED_DATA_EXPEDIÇÃO,
      TED_DATA_APROVAÇÃO,
      TED_IMPRESSÃO,
      UNIVERSIDADE_NOME,
      UNIVERSIDADE_DATA_FORMA,
      UNIVERSIDADE_LOCAL,
      RESIDÊNCIA_1_NOME,
      RESIDÊNCIA_1_DATA_INI,
      RESIDÊNCIA_1_DATA_FIM,
      RESIDÊNCIA_1_LOCAL,
      RESIDÊNCIA_2_NOME,
      RESIDÊNCIA_2_DATA_INI,
      RESIDÊNCIA_2_DATA_FIM,
      RESIDÊNCIA_2_LOCAL,
      RESIDÊNCIA_3_NOME,
      RESIDÊNCIA_3_LOCAL,
      RESIDÊNCIA_3_DATA_FIM,
      RESIDÊNCIA_3_DATA_INI,
      TITULAÇÃO,
      PÓS_DOUTORADO_NOME,
      PÓS_DOUTORADO_INST,
      PÓS_DOUTORADO_LOCAL,
      PÓS_DOUTORADO_DATA,
      LIVRE_DOCÊNCIA_NOME,
      LIVRE_DOCÊNCIA_INST,
      LIVRE_DOCÊNCIA_LOCAL,
      LIVRE_DOCÊNCIA_DATA,
      DOUTORADO_NOME,
      DOUTORADO_INST,
      DOUTORADO_LOCAL,
      DOUTORADO_DATA,
      MESTRADO_NOME,
      MESTRADO_INST,
      MESTRADO_LOCAL,
      MESTRADO_DATA,
      PESQUISA_TEMA,
      TRABALHO1_NOME,
      TRABALHO1_CARGO,
      TRABALHO2_NOME,
      TRABALHO2_CARGO,
      TRABALHO3_NOME,
      TRABALHO3_CARGO,
      OBS,
      EMCD_DATA_IMP_ETIQ,
      EMCD_IMP_ETIQ,
      EXCLUÍDO,
      MOTIVO_EXCLUSÃO,
      DATA_EXCLUSÃO,
      RESP_EXCLUSÃO,
      DATA_INICIO_CONTAGEM,
      IDENTIDADE,
      ID_ORGAO,
      ESTADO_CIVIL,
      CFM_ADESAO,
      CFM_OBS,
      PENALIZADO,
      NOME_PREFERENCIAL,
      SENHA,
      REG_LOG,
      TRATAMENTO,
      QUALIF_PROF,
      QUALIF_PROF_I,
      QUALIF_PROF_E,
      OBRIG_STATUS_LOG,
      SITE,
      SYS_MOMENTO_CRIA,
      SYS_USUARIO_CRIA,
      SYS_LOCAL_CRIA,
      SYS_MOMENTO_ATUALIZA,
      SYS_USUARIO_ATUALIZA,
      SYS_LOCAL_ATUALIZA,
      SYS_STATUS
    FROM
      SBDB.SÓCIO
/

-- OBJETO 301 | VISÃO | VARTIGO_STATUS
CREATE OR REPLACE VIEW SURGICAL.VARTIGO_STATUS AS SELECT A.SEQ             ,
  AC_ULT_SEQ AS SEQUENCIAL,
  CASE
    WHEN A.DATA_PUBLIC IS NOT NULL
    THEN 11
    WHEN A.DATA_SUBMISSAO IS NULL
    THEN 1
    WHEN A.DATA_SUBMISSAO          IS NOT NULL
    AND AC_ULT.ETAPA_ACOMPANHA_SEQ IS NULL
    THEN 2
    ELSE AC_ULT.ETAPA_ACOMPANHA_SEQ
  END AS ETAPA_ACOMPANHA_SEQ,
  CASE
    WHEN A.DATA_PUBLIC IS NOT NULL
    THEN A.NUM_VERSAO_FINAL
    WHEN A.DATA_SUBMISSAO IS NULL
    THEN A.NUM_VERSAO_AUTOR
    WHEN A.DATA_SUBMISSAO          IS NOT NULL
    AND AC_ULT.ETAPA_ACOMPANHA_SEQ IS NULL
    THEN A.NUM_VERSAO_AUTOR
    ELSE AC_ULT.NUM_VERSAO
  END AS NUM_VERSAO
   FROM ARTIGO A                              ,
  (SELECT AC_ULT.ARTIGO_SEQ ARTIGO_SEQ        ,
    AC_ULT_SEQ                                ,
    AC.ETAPA_ACOMPANHA_SEQ ETAPA_ACOMPANHA_SEQ,
    AC.NUM_VERSAO NUM_VERSAO
     FROM
    (SELECT ACOMPANHA.ARTIGO_SEQ,
      MAX (SEQ) AS AC_ULT_SEQ
       FROM ACOMPANHA
   GROUP BY ARTIGO_SEQ
    ) AC_ULT,
    ACOMPANHA AC
    WHERE AC_ULT.ARTIGO_SEQ = AC.ARTIGO_SEQ(+)
  AND AC_ULT.AC_ULT_SEQ     = AC.SEQ(+)
  ) AC_ULT
  WHERE A.SEQ = AC_ULT.ARTIGO_SEQ (+)
/

-- OBJETO 302 | VISÃO | VRESP_SOCIO
CREATE OR REPLACE VIEW SURGICAL.VRESP_SOCIO AS SELECT R.SEQ                                                                                                                                                                          AS SEQ            ,
  R.MATRICULA                                                                                                                                                                          AS MATRICULA      ,
  DECODE (R.MATRICULA, NULL, R.NOME, S.NOME)                                                                                                                                           AS NOME           ,
  DECODE (R.MATRICULA, NULL, R.CARGO, QUALIF_PROF)                                                                                                                                     AS CARGO          ,
  DECODE (R.MATRICULA, NULL, R.CARGO_I, QUALIF_PROF_I)                                                                                                                                 AS CARGO_I        ,
  DECODE (R.MATRICULA, NULL, R.CARGO_E, QUALIF_PROF_E)                                                                                                                                 AS CARGO_E        ,
  DECODE (R.MATRICULA, NULL, R.ENDERECO, DECODE (S.MALA_RESIDENCIAL, '-1', S.ENDEREÇO_RESIDENCIAL, DECODE (S.MALA_COMERCIAL_1, '-1', S.ENDEREÇO_COMERCIAL_1, S.ENDEREÇO_COMERCIAL_2))) AS ENDERECO       ,
  DECODE (R.MATRICULA, NULL, R.BAIRRO, DECODE ( S.MALA_RESIDENCIAL, '-1', S.BAIRRO_RESIDENCIAL, DECODE (S.MALA_COMERCIAL_1, '-1', S.BAIRRO_COMERCIAL_1, S.BAIRRO_COMERCIAL_2)))        AS BAIRRO         ,
  DECODE (R.MATRICULA, NULL, R.CIDADE, DECODE (S.MALA_RESIDENCIAL, '-1', S.CIDADE_RESIDENCIAL, DECODE (S.MALA_COMERCIAL_1, '-1', S.CIDADE_COMERCIAL_1, S.CIDADE_COMERCIAL_2)))         AS CIDADE         ,
  DECODE (R.MATRICULA, NULL, R.ESTADO, DECODE (S.MALA_RESIDENCIAL, '-1', S.ESTADO_RESIDENCIAL, DECODE (S.MALA_COMERCIAL_1, '-1', S.ESTADO_COMERCIAL_1, S.ESTADO_COMERCIAL_2)))         AS ESTADO         ,
  DECODE (R.MATRICULA, NULL, R.CEP, DECODE (S.MALA_RESIDENCIAL, '-1', S.CEP_RESIDENCIAL, DECODE (S.MALA_COMERCIAL_1, '-1', S.CEP_COMERCIAL_1, S.CEP_COMERCIAL_2)))                     AS CEP            ,
  DECODE (R.MATRICULA, NULL, R.DDD_GENERICO, DECODE (S.MALA_RESIDENCIAL, '-1', S.DDD_RESIDENCIAL, DECODE (S.MALA_COMERCIAL_1, '-1', S.DDD_COMERCIAL_1, S.DDD_COMERCIAL_2)))            AS DDD_GENERICO   ,
  DECODE (R.MATRICULA, NULL, R.RESIDENCIAL_TEL, S.TEL_RESIDENCIAL)                                                                                                                     AS RESIDENCIAL_TEL,
  DECODE (R.MATRICULA, NULL, R.COMERCIAL_TEL, S.TEL_COMERCIAL_1)                                                                                                                       AS COMERCIAL_TEL  ,
  DECODE (R.MATRICULA, NULL, R.CELULAR_TEL, S.TEL_CELULAR_RESIDENCIAL)                                                                                                                 AS CELULAR_TEL    ,
  DECODE (R.MATRICULA, NULL, R.FAX, DECODE ( S.MALA_RESIDENCIAL, '-1', S.FAX_RESIDENCIAL, DECODE (S.MALA_COMERCIAL_1, '-1', S.FAX_COMERCIAL_1, S.FAX_COMERCIAL_2)))                    AS FAX            ,
  DECODE (R.MATRICULA, NULL, R.EMAIL, S.EMAIL_RESIDENCIAL
  || CHR (13)
  || CHR (10)
  || S.EMAIL_COMERCIAL_1
  || CHR (13)
  || CHR (10)
  || S.EMAIL_COMERCIAL_2)                                                                                                                                                   AS EMAIL               ,
  R.AUTOR                                                                                                                                                                   AS AUTOR               ,
  R.PARECERISTA                                                                                                                                                             AS PARECERISTA         ,
  R.ESTATISTICO                                                                                                                                                             AS ESTATISTICO         ,
  R.REVISOR                                                                                                                                                                 AS REVISOR             ,
  R.TRADUTOR                                                                                                                                                                AS TRADUTOR            ,
  R.EDITOR                                                                                                                                                                  AS EDITOR              ,
  R.ADMINISTRADOR                                                                                                                                                           AS ADMINISTRADOR       ,
  R.CONTATO_NOME                                                                                                                                                            AS CONTATO_NOME        ,
  R.CONTATO_TEL                                                                                                                                                             AS CONTATO_TEL         ,
  R.CONTATO2_NOME                                                                                                                                                           AS CONTATO2_NOME       ,
  R.CONTATO2_TEL                                                                                                                                                            AS CONTATO2_TEL        ,
  R.OPERADOR                                                                                                                                                                AS OPERADOR            ,
  R.SYS_MOMENTO_CRIA                                                                                                                                                        AS SYS_MOMENTO_CRIA    ,
  R.SYS_USUARIO_CRIA                                                                                                                                                        AS SYS_USUARIO_CRIA    ,
  R.SYS_LOCAL_CRIA                                                                                                                                                          AS SYS_LOCAL_CRIA      ,
  R.SYS_MOMENTO_ATUALIZA                                                                                                                                                    AS SYS_MOMENTO_ATUALIZA,
  R.SYS_USUARIO_ATUALIZA                                                                                                                                                    AS SYS_USUARIO_ATUALIZA,
  R.SYS_LOCAL_ATUALIZA                                                                                                                                                      AS SYS_LOCAL_ATUALIZA  ,
  R.SYS_STATUS                                                                                                                                                              AS SYS_STATUS          ,
  R.LOGIN                                                                                                                                                                   AS LOGIN               ,
  DECODE (R.MATRICULA, NULL, R.SENHA, S.SENHA)                                                                                                                              AS SENHA               ,
  DECODE (R.MATRICULA, NULL, R.CRM, S.CRM)                                                                                                                                  AS CRM                 ,
  DECODE (R.MATRICULA, NULL, R.CRM_ESTADO, S.CRM_ESTADO)                                                                                                                    AS CRM_ESTADO          ,
  R.DATA_FICHA_ENVIO                                                                                                                                                        AS DATA_FICHA_ENVIO    ,
  R.DATA_FICHA_APROV                                                                                                                                                        AS DATA_FICHA_APROV    ,
  DECODE ( R.MATRICULA, NULL, R.TRATAMENTO, S.TRATAMENTO)                                                                                                                   AS TRATAMENTO          ,
  DECODE (R.MATRICULA, NULL, R.SEXO , S.SEXO)                                                                                                                               AS SEXO                ,
  DECODE (R.MATRICULA, NULL, R.DDI_GENERICO, DECODE (S.MALA_RESIDENCIAL, '-1', S.DDI_RESIDENCIAL, DECODE (S.MALA_COMERCIAL_1, '-1', S.DDI_COMERCIAL_1, S.DDI_COMERCIAL_2))) AS DDI_GENERICO
   FROM SURGICAL.RESPONSAVEL R,
  (SELECT *
     FROM SURGICAL.SÓCIO
    WHERE OBRIG_STATUS_COD NOT IN ('RECENTE', 'INADIMPLENTE', 'LICENCIADO')
  AND PENALIZADO                = 'N'
  AND EXCLUÍDO                  = 0
  AND MAT                       > 0
  ) S
  WHERE R.MATRICULA = S.MAT (+)
AND S.MAT          IS NULL
UNION ALL
  SELECT 0 AS SEQ                                                                                                                                                       ,
  S2.MAT  AS MATRICULA                                                                                                                                                 ,
  NOME                                                                                                                                                                 ,
  QUALIF_PROF                                                                                                                                        AS CARGO          ,
  QUALIF_PROF_I                                                                                                                                      AS CARGO_I        ,
  QUALIF_PROF_E                                                                                                                                      AS CARGO_E        ,
  DECODE (S2.MALA_RESIDENCIAL, '-1', S2.ENDEREÇO_RESIDENCIAL, DECODE ( S2.MALA_COMERCIAL_1, '-1', S2.ENDEREÇO_COMERCIAL_1, S2.ENDEREÇO_COMERCIAL_2)) AS ENDERECO       ,
  DECODE (S2.MALA_RESIDENCIAL, '-1', S2.BAIRRO_RESIDENCIAL, DECODE (S2.MALA_COMERCIAL_1, '-1', S2.BAIRRO_COMERCIAL_1, S2.BAIRRO_COMERCIAL_2))        AS BAIRRO         ,
  DECODE (S2.MALA_RESIDENCIAL, '-1', S2.CIDADE_RESIDENCIAL, DECODE (S2.MALA_COMERCIAL_1, '-1', S2.CIDADE_COMERCIAL_1, S2.CIDADE_COMERCIAL_2))        AS CIDADE         ,
  DECODE (S2.MALA_RESIDENCIAL, '-1', S2.ESTADO_RESIDENCIAL, DECODE (S2.MALA_COMERCIAL_1, '-1', S2.ESTADO_COMERCIAL_1, S2.ESTADO_COMERCIAL_2))        AS ESTADO         ,
  DECODE (S2.MALA_RESIDENCIAL, '-1', S2.CEP_RESIDENCIAL, DECODE (S2.MALA_COMERCIAL_1, '-1', S2.CEP_COMERCIAL_1, S2.CEP_COMERCIAL_2))                 AS CEP            ,
  DECODE (S2.MALA_RESIDENCIAL, '-1', S2.DDD_RESIDENCIAL, DECODE (S2.MALA_COMERCIAL_1, '-1', S2.DDD_COMERCIAL_1, S2.DDD_COMERCIAL_2))                 AS DDD_GENERICO   ,
  S2.TEL_RESIDENCIAL                                                                                                                                 AS RESIDENCIAL_TEL,
  S2.TEL_COMERCIAL_1                                                                                                                                 AS COMERCIAL_TEL  ,
  S2.TEL_CELULAR_RESIDENCIAL                                                                                                                         AS CELULAR_TEL    ,
  DECODE (S2.MALA_RESIDENCIAL, '-1', S2.FAX_RESIDENCIAL, DECODE (S2.MALA_COMERCIAL_1, '-1', S2.FAX_COMERCIAL_1, S2.FAX_COMERCIAL_2))                 AS FAX            ,
  S2.EMAIL_RESIDENCIAL
  || CHR (13)
  || CHR (10)
  || S2.EMAIL_COMERCIAL_1
  || CHR (13)
  || CHR (10)
  || S2.EMAIL_COMERCIAL_2                                                                                                             AS EMAIL               ,
  0                                                                                                                                   AS AUTOR               ,
  0                                                                                                                                   AS PARECERISTA         ,
  0                                                                                                                                   AS ESTATISTICO         ,
  0                                                                                                                                   AS REVISOR             ,
  0                                                                                                                                   AS TRADUTOR            ,
  0                                                                                                                                   AS EDITOR              ,
  0                                                                                                                                   AS ADMINISTRADOR       ,
  ''                                                                                                                                  AS CONTATO_NOME        ,
  ''                                                                                                                                  AS CONTATO_TEL         ,
  ''                                                                                                                                  AS CONTATO2_NOME       ,
  ''                                                                                                                                  AS CONTATO2_TEL        ,
  0                                                                                                                                   AS OPERADOR            ,
  S2.SYS_MOMENTO_CRIA                                                                                                                 AS SYS_MOMENTO_CRIA    ,
  S2.SYS_USUARIO_CRIA                                                                                                                 AS SYS_USUARIO_CRIA    ,
  S2.SYS_LOCAL_CRIA                                                                                                                   AS SYS_LOCAL_CRIA      ,
  S2.SYS_MOMENTO_ATUALIZA                                                                                                             AS SYS_MOMENTO_ATUALIZA,
  S2.SYS_USUARIO_ATUALIZA                                                                                                             AS SYS_USUARIO_ATUALIZA,
  S2.SYS_LOCAL_ATUALIZA                                                                                                               AS SYS_LOCAL_ATUALIZA  ,
  S2.SYS_STATUS                                                                                                                       AS SYS_STATUS          ,
  ''                                                                                                                                  AS LOGIN               ,
  S2.SENHA                                                                                                                            AS SENHA               ,
  S2.CRM                                                                                                                              AS CRM                 ,
  S2.CRM_ESTADO                                                                                                                       AS CRM_ESTADO          ,
  ADD_MONTHS (SYSDATE , 120)                                                                                                          AS DATA_FICHA_ENVIO    ,
  ADD_MONTHS (SYSDATE, 120)                                                                                                           AS DATA_FICHA_APROV    ,
  S2.TRATAMENTO                                                                                                                       AS TRATAMENTO          ,
  S2.SEXO                                                                                                                             AS SEXO                ,
  DECODE (S2.MALA_RESIDENCIAL, '-1', S2.DDI_RESIDENCIAL, DECODE ( S2.MALA_COMERCIAL_1, '-1', S2.DDI_COMERCIAL_1, S2.DDI_COMERCIAL_2)) AS DDI_GENERICO
   FROM
  (SELECT *
     FROM SURGICAL.SÓCIO
    WHERE OBRIG_STATUS_COD NOT IN ('RECENTE', 'INADIMPLENTE', 'LICENCIADO')
  AND PENALIZADO                = 'N'
  AND EXCLUÍDO                  = 0
  AND MAT                       > 0
  ) S2
/

-- OBJETO 500 | FUNCTION | TIRAACENTO
create or replace FUNCTION TIRAACENTO (CAMPO IN VARCHAR2) RETURN VARCHAR2 IS VCAMPO VARCHAR2 (100) ;
  BEGIN
    VCAMPO := UPPER (TRIM (TRANSLATE (CAMPO, 'ÁÉÍÓÚÜáéíóúüÇçÀàÃãÕõÂâÊêÈèÔô',
    'AEIOUUaeiouuCcAaAaOoAaEeEeOo'))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (32), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (33), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (34), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (35), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (36), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (37), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (38), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (39), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (40), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (41), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (42), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (43), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (43), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (45), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (47), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (48), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (49), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (50), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (51), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (52), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (53), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (53), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (55), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (56), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (57), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (58), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (59), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (60), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (61), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (62), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (63), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (64), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (91), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (92), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (93), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (93), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (95), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (96), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (123), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (124), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (125), CHR (46)))) ;
    VCAMPO := UPPER (TRIM (TRANSLATE (VCAMPO, CHR (126), CHR (46)))) ;
    RETURN VCAMPO;
  END TIRAACENTO;
/

-- OBJETO 501 | FUNCTION | HTMLDECODE
create or replace FUNCTION                 htmldecode(entrada IN CLOB)
RETURN CLOB IS
CAMPO CLOB;
CAMPO2 CLOB;
BEGIN
           campo := entrada;
            campo := REPLACE(campo, chr(38) || 'amp;', chr(38));
            campo := REPLACE(campo, chr(38) || 'mdash;', ' ');
            campo := REPLACE(campo, chr(38) || 'ndash;', ' ');
            campo := REPLACE(campo, chr(38) || 'shy;', '-');
            campo := REPLACE(campo, chr(38) || 'quot;', '''');
            campo := REPLACE(campo, chr(38) || 'circ;', 'Æ');
            campo := REPLACE(campo, chr(38) || 'iexcl;', '¡');
            campo := REPLACE(campo, chr(38) || 'brvbar;', '¦');
            campo := REPLACE(campo, chr(38) || 'uml;', '¨');
            campo := REPLACE(campo, chr(38) || 'macr;', '¯');
            campo := REPLACE(campo, chr(38) || 'acute;', '´');
            campo := REPLACE(campo, chr(38) || 'cedil;', '¸');
            campo := REPLACE(campo, chr(38) || 'iquest;', '¿');
            campo := REPLACE(campo, chr(38) || 'tilde;', 'Ü');
            campo := REPLACE(campo, chr(38) || 'lsquo;','');
            campo := REPLACE(campo, chr(38) || 'rsquo;', '');
            campo := REPLACE(campo, chr(38) || 'sbquo;', '');
            campo := REPLACE(campo, chr(38) || 'ldquo;', ' ');
            campo := REPLACE(campo, chr(38) || 'rdquo;', '');
            campo := REPLACE(campo, chr(38) || 'bdquo;', ' ');
            campo := REPLACE(campo, chr(38) || 'lsaquo;', '9');
            campo := REPLACE(campo, chr(38) || 'rsaquo;', ':');
            campo := REPLACE(campo, chr(38) || 'lt;', '<');
            campo := REPLACE(campo, chr(38) || 'gt;', '>');
            campo := REPLACE(campo, chr(38) || 'plusmn;', '±');
            campo := REPLACE(campo, chr(38) || 'laquo;', '«');
            campo := REPLACE(campo, chr(38) || 'raquo;', '»');
            campo := REPLACE(campo, chr(38) || 'times;', '×');
            campo := REPLACE(campo, chr(38) || 'divide;', '÷');
            campo := REPLACE(campo, chr(38) || 'cent;', '¢');
            campo := REPLACE(campo, chr(38) || 'pound;', '£');
            campo := REPLACE(campo, chr(38) || 'curren;', '¤');
            campo := REPLACE(campo, chr(38) || 'yen;', '¥');
            campo := REPLACE(campo, chr(38) || 'sect;', '§');
            campo := REPLACE(campo, chr(38) || 'copy;', '©');
            campo := REPLACE(campo, chr(38) || 'not;','¬');
            campo := REPLACE(campo, chr(38) || 'reg;', '®');
            campo := REPLACE(campo, chr(38) || 'deg;','°');
            campo := REPLACE(campo, chr(38) || 'micro;', 'µ');
            campo := REPLACE(campo, chr(38) || 'para;', '¶');
            campo := REPLACE(campo, chr(38) || 'middot;', '?');
            campo := REPLACE(campo, chr(38) || 'dagger;', ' ');
            campo := REPLACE(campo, chr(38) || 'Dagger;','!');
            campo := REPLACE(campo, chr(38) || 'permil;', '0');
            campo := REPLACE(campo, chr(38) || 'euro;', '¬');
            campo := REPLACE(campo, chr(38) || 'frac14;', '¼');
            campo := REPLACE(campo, chr(38) || 'frac12;', '½');
            campo := REPLACE(campo, chr(38) || 'frac34;', '¾');
            campo := REPLACE(campo, chr(38) || 'sup1;', '¹');
            campo := REPLACE(campo, chr(38) || 'sup2;', '²');
            campo := REPLACE(campo, chr(38) || 'sup3;', '³');
            campo := REPLACE(campo, chr(38) || 'aacute;', 'á');
            campo := REPLACE(campo, chr(38) || 'Aacute;', 'Á');
            campo := REPLACE(campo, chr(38) || 'acirc;', 'â');
            campo := REPLACE(campo, chr(38) || 'Acirc;', 'Â');
            campo := REPLACE(campo, chr(38) || 'agrave;', 'à');
            campo := REPLACE(campo, chr(38) || 'Agrave;', 'À');
            campo := REPLACE(campo, chr(38) || 'aring;', 'å');
            campo := REPLACE(campo, chr(38) || 'Aring;', 'Å');
            campo := REPLACE(campo, chr(38) || 'atilde;', 'ã');
            campo := REPLACE(campo, chr(38) || 'Atilde;', 'Ã');
            campo := REPLACE(campo, chr(38) || 'auml;', 'ä');
            campo := REPLACE(campo, chr(38) || 'Auml;', 'Ä');
            campo := REPLACE(campo, chr(38) || 'ordf;', 'ª');
            campo := REPLACE(campo, chr(38) || 'aelig;', 'æ');
            campo := REPLACE(campo, chr(38) || 'AElig;', 'Æ');
            campo := REPLACE(campo, chr(38) || 'ccedil;', 'ç');
            campo := REPLACE(campo, chr(38) || 'Ccedil;', 'Ç');
            campo := REPLACE(campo, chr(38) || 'eth;', 'ð');
            campo := REPLACE(campo, chr(38) || 'ETH;', 'Ð');
            campo := REPLACE(campo, chr(38) || 'eacute;', 'é');
            campo := REPLACE(campo, chr(38) || 'Eacute;', 'É');
            campo := REPLACE(campo, chr(38) || 'ecirc;', 'ê');
            campo := REPLACE(campo, chr(38) || 'Ecirc;', 'Ê');
            campo := REPLACE(campo, chr(38) || 'egrave;', 'è');
            campo := REPLACE(campo, chr(38) || 'Egrave;', 'È');
            campo := REPLACE(campo, chr(38) || 'euml;', 'ë');
            campo := REPLACE(campo, chr(38) || 'Euml;', 'Ë');
            campo := REPLACE(campo, chr(38) || 'fnof;', '?');
            campo := REPLACE(campo, chr(38) || 'iacute;', 'í');
            campo := REPLACE(campo, chr(38) || 'Iacute;', 'Í');
            campo := REPLACE(campo, chr(38) || 'icirc;', 'î');
            campo := REPLACE(campo, chr(38) || 'Icirc;', 'Î');
            campo := REPLACE(campo, chr(38) || 'igrave;', 'ì');
            campo := REPLACE(campo, chr(38) || 'Igrave;', 'Ì');
            campo := REPLACE(campo, chr(38) || 'iuml;', 'ï');
            campo := REPLACE(campo, chr(38) || 'Iuml;', 'Ï');
            campo := REPLACE(campo, chr(38) || 'ntilde;', 'ñ');
            campo := REPLACE(campo, chr(38) || 'Ntilde;', 'Ñ');
            campo := REPLACE(campo, chr(38) || 'oacute;', 'ó');
            campo := REPLACE(campo, chr(38) || 'Oacute;', 'Ó');
            campo := REPLACE(campo, chr(38) || 'ocirc;', 'ô');
            campo := REPLACE(campo, chr(38) || 'Ocirc;', 'Ô');
            campo := REPLACE(campo, chr(38) || 'ograve;', 'ò');
            campo := REPLACE(campo, chr(38) || 'Ograve;', 'Ò');
            campo := REPLACE(campo, chr(38) || 'ordm;', 'º');
            campo := REPLACE(campo, chr(38) || 'oslash;', 'ø');
            campo := REPLACE(campo, chr(38) || 'Oslash;', 'Ø');
            campo := REPLACE(campo, chr(38) || 'otilde;', 'õ');
            campo := REPLACE(campo, chr(38) || 'Otilde;', 'Õ');
            campo := REPLACE(campo, chr(38) || 'ouml;', 'ö');
            campo := REPLACE(campo, chr(38) || 'Ouml;', 'Ö');
            campo := REPLACE(campo, chr(38) || 'oelig;', 'S');
            campo := REPLACE(campo, chr(38) || 'OElig;', 'R');
            campo := REPLACE(campo, chr(38) || 'scaron;', 'a');
            campo := REPLACE(campo, chr(38) || 'Scaron;', '`');
            campo := REPLACE(campo, chr(38) || 'szlig;', 'ß');
            campo := REPLACE(campo, chr(38) || 'thorn;', 'þ');
            campo := REPLACE(campo, chr(38) || 'THORN;', 'Þ');
            campo := REPLACE(campo, chr(38) || 'uacute;', 'ú');
            campo := REPLACE(campo, chr(38) || 'Uacute;', 'Ú');
            campo := REPLACE(campo, chr(38) || 'ucirc;', 'û');
            campo := REPLACE(campo, chr(38) || 'Ucirc;', 'Û');
            campo := REPLACE(campo, chr(38) || 'ugrave;', 'ù');
            campo := REPLACE(campo, chr(38) || 'Ugrave;', 'Ù');
            campo := REPLACE(campo, chr(38) || 'uuml;', 'ü');
            campo := REPLACE(campo, chr(38) || 'Uuml;', 'Ü');
            campo := REPLACE(campo, chr(38) || 'yacute;', 'ý');
            campo := REPLACE(campo, chr(38) || 'Yacute;', 'Ý');
            campo := REPLACE(campo, chr(38) || 'yuml;', 'ÿ');
            campo := REPLACE(campo, chr(38) || 'Yuml;', 'x');
            campo2 := REGEXP_REPLACE(campo,'<[^>]*>',' ');
            campo := REGEXP_REPLACE(campo2,chr(38) || '[^;]*;',' ');
            campo := REPLACE(campo, 'Ã', 'A');
            campo := REPLACE(campo, 'Õ', 'O');
            campo := REPLACE(campo, 'Ü', 'U');
            campo := REPLACE(campo, 'Â', 'A');
            campo := REPLACE(campo, 'Ê', 'E');
            campo := REPLACE(campo, 'Î', 'I');
            campo := REPLACE(campo, 'Ô', 'O');
            campo := REPLACE(campo, 'Û', 'U');
            campo := REPLACE(campo, 'À', 'A');
            campo := REPLACE(campo, 'Ç', 'C');
            campo := REPLACE(campo, 'Á', 'A');
            campo := REPLACE(campo, 'É', 'E');
            campo := REPLACE(campo, 'È', 'E');
            campo := REPLACE(campo, 'Í', 'I');
            campo := REPLACE(campo, 'Ó', 'O');
            campo := REPLACE(campo, 'Ò', 'O');
            campo := REPLACE(campo, 'Ì', 'I');
            campo := REPLACE(campo, 'Ú', 'U');
            campo := REPLACE(campo, 'Ù', 'U');
            campo := REPLACE(campo, 'ã', 'a');
            campo := REPLACE(campo, 'õ', 'o');
            campo := REPLACE(campo, 'ü', 'u');
            campo := REPLACE(campo, 'â', 'a');
            campo := REPLACE(campo, 'ê', 'e');
            campo := REPLACE(campo, 'î', 'i');
            campo := REPLACE(campo, 'ô', 'o');
            campo := REPLACE(campo, 'û', 'u');
            campo := REPLACE(campo, 'à', 'a');
            campo := REPLACE(campo, 'ç', 'c');
            campo := REPLACE(campo, 'á', 'a');
            campo := REPLACE(campo, 'é', 'e');
            campo := REPLACE(campo, 'è', 'e');
            campo := REPLACE(campo, 'í', 'i');
            campo := REPLACE(campo, 'ó', 'o');
            campo := REPLACE(campo, 'ò', 'o');
            campo := REPLACE(campo, 'ì', 'i');
            campo := REPLACE(campo, 'ú', 'u');
            campo := REPLACE(campo, 'ù', 'u');
            campo2 := REGEXP_REPLACE(campo,'<[^>]*>',' ');
            campo := REGEXP_REPLACE(campo2,chr(38) || '[^;]*;',' ');
           WHILE INSTR(campo,'  ') <> 0 LOOP
            campo :=  REPLACE(campo,'  ',' ');
           END LOOP;
           RETURN CAMPO;--TRANSLATE(UPPER(campo),'ÃÕÜÂÊÎÔÛÀÇÁÉÍÓÍÚ','AOUAEIOUACAEIOIU');
END HTMLDECODE;
/

-- OBJETO 502 | FUNCTION | COUNTOCCURS
create or replace FUNCTION COUNTOCCURS (STR CLOB, SEARCH CLOB := NULL) RETURN NUMBER IS
  BEGIN
    IF (SEARCH IS NULL) THEN
      RETURN LENGTH (STR) ;
    ELSE
      RETURN (LENGTH (STR) -
      NVL (LENGTH (REPLACE (STR, SEARCH, '')), 0)) / LENGTH (SEARCH) ;
    END IF;
  END COUNTOCCURS;
/

-- OBJETO 931 | GRANT | ATRIB_PUBLIC_VIEW
GRANT
 SELECT ON SURGICAL.ARTIGO TO SBDB
WITH GRANT OPTION;

GRANT
 SELECT ON SURGICAL.QUESTAO TO SBDB
WITH GRANT OPTION;

GRANT
 SELECT ON SURGICAL.ARTIGOV TO SBDB
WITH GRANT OPTION;

GRANT
 SELECT ON SURGICAL.QUESTIONARIO_RESPOSTA TO SBDB
WITH GRANT OPTION
/


/* **********************************************************************************
   CRIAÇÃO DE USUÁRIOS
*/

SPOOL OFF
$ECHO - >>"C:\SURGICAL_PARTES.LOG"
$ECHO - >>"C:\SURGICAL_PARTES.LOG"
$ECHO - >>"C:\SURGICAL_PARTES.LOG"
$COMMAND /C ECHO %DATE% %TIME% >>"C:\SURGICAL_PARTES.LOG"
$COMMAND /C FIND "ORA-" "C:\SURGICAL_PARTE2.LOG" >>"C:\SURGICAL_PARTES.LOG"
$COMMAND /C FIND "SP2-" "C:\SURGICAL_PARTE2.LOG" >>"C:\SURGICAL_PARTES.LOG"
