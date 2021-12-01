SET ECHO ON
SPOOL C:\ESEND_PARTE2.LOG
CONNECT ESEND/XXXX@SBDB;

-- ELIMINA OS JOBS
begin
for cur in (select job from user_jobs where schema_user='ESEND') loop
dbms_job.remove(cur.job);
end loop;
end;
/

-- CRIA ÍNDICES


/* **********************************************************************************
   CRIAÇÃO DE RELACIONAMENTOS
*/

ALTER TABLE ESEND."COMUNICADO_CONTR_EMAIL" ADD CONSTRAINT "COMUN_CONT_COMUN_CONT_EMAIL_01" FOREIGN KEY("COMUNICADO_SEQ", "CONTROLE_SEQ") REFERENCES ESEND."COMUNICADO_CONTR"("COMUNICADO_SEQ", "SEQ");
ALTER TABLE ESEND."CONTATO_TEL" ADD CONSTRAINT "CONTATO_CONTATO_TEL_01" FOREIGN KEY("CONTATO_SEQ") REFERENCES ESEND."CONTATO"("SEQ");
ALTER TABLE ESEND."LISTA_CONTATO" ADD CONSTRAINT "LISTA_LISTA_CONTATO_01" FOREIGN KEY("LISTA_SEQ") REFERENCES ESEND."LISTA"("SEQ");
ALTER TABLE ESEND."COMUNICADO_CONTR" ADD CONSTRAINT "COMUNICADO_COMUNICADO_CONTR_01" FOREIGN KEY("COMUNICADO_SEQ") REFERENCES ESEND."COMUNICADO"("SEQ");
ALTER TABLE ESEND."COMUNICADO_DEST" ADD CONSTRAINT "COMUNICADO_COMUNICADO_DEST_01" FOREIGN KEY("COMUNICADO_SEQ") REFERENCES ESEND."COMUNICADO"("SEQ");
ALTER TABLE ESEND."COMUNICADO_DEST" ADD CONSTRAINT "CONTATO_COMUNICADO_DEST_01" FOREIGN KEY("CONTATO_SEQ") REFERENCES ESEND."CONTATO"("SEQ");
ALTER TABLE ESEND."CONTATO" ADD CONSTRAINT "CONTATO_CONTATO_01" FOREIGN KEY("EMPRESA_SEQ") REFERENCES ESEND."CONTATO"("SEQ");
ALTER TABLE ESEND."LISTA_CONTATO" ADD CONSTRAINT "CONTATO_LISTA_CONTATO_01" FOREIGN KEY("CONTATO_SEQ") REFERENCES ESEND."CONTATO"("SEQ");
ALTER TABLE ESEND."COMUNICADO_DEST" ADD CONSTRAINT "LISTA_COMUNICADO_DEST_01" FOREIGN KEY("LISTA_SEQ") REFERENCES ESEND."LISTA"("SEQ");
ALTER TABLE ESEND."LISTA" ADD CONSTRAINT "TIPO_LISTA_LISTA_01" FOREIGN KEY("TIPO_LISTA_COD") REFERENCES ESEND."TIPO_LISTA"("COD");


/* **********************************************************************************
   CONSTRAINTS BASE EM CHECK
*/

/* **********************************************************************************
   CRIAÇÃO DE TRIGGERS PARA REGISTRO DE INCLUSÃO, ATUALIZAÇÃO E EXCLUSÃO
*/

CREATE OR REPLACE TRIGGER ESEND.BEF_COMUNICADO BEFORE UPDATE OR INSERT OR DELETE ON ESEND.COMUNICADO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ESEND.SYS_DELETE WHERE TABELA = 'COMUNICADO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ESEND.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('COMUNICADO', :OLD.SEQ, SYSDATE, USER, 'ESEND');
         ELSE
            UPDATE ESEND.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ESEND' WHERE TABELA = 'COMUNICADO' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER ESEND.BEF_COMUNICADO_CONTR BEFORE UPDATE OR INSERT OR DELETE ON ESEND.COMUNICADO_CONTR FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ESEND.SYS_DELETE WHERE TABELA = 'COMUNICADO_CONTR' AND CHAVE || '' = :OLD.COMUNICADO_SEQ || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ESEND.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('COMUNICADO_CONTR', :OLD.COMUNICADO_SEQ || :OLD.SEQ, SYSDATE, USER, 'ESEND');
         ELSE
            UPDATE ESEND.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ESEND' WHERE TABELA = 'COMUNICADO_CONTR' AND CHAVE || ''= :OLD.COMUNICADO_SEQ || :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER ESEND.BEF_COMUNICADO_CONTR_EMAIL BEFORE UPDATE OR INSERT OR DELETE ON ESEND.COMUNICADO_CONTR_EMAIL FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ESEND.SYS_DELETE WHERE TABELA = 'COMUNICADO_CONTR_EMAIL' AND CHAVE || '' = :OLD.COMUNICADO_SEQ || :OLD.CONTROLE_SEQ || :OLD.EMAIL || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ESEND.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('COMUNICADO_CONTR_EMAIL', :OLD.COMUNICADO_SEQ || :OLD.CONTROLE_SEQ || :OLD.EMAIL || :OLD.SEQ, SYSDATE, USER, 'ESEND');
         ELSE
            UPDATE ESEND.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ESEND' WHERE TABELA = 'COMUNICADO_CONTR_EMAIL' AND CHAVE || ''= :OLD.COMUNICADO_SEQ || :OLD.CONTROLE_SEQ || :OLD.EMAIL || :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER ESEND.BEF_COMUNICADO_DEST BEFORE UPDATE OR INSERT OR DELETE ON ESEND.COMUNICADO_DEST FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ESEND.SYS_DELETE WHERE TABELA = 'COMUNICADO_DEST' AND CHAVE || '' = :OLD.COMUNICADO_SEQ || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ESEND.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('COMUNICADO_DEST', :OLD.COMUNICADO_SEQ || :OLD.SEQ, SYSDATE, USER, 'ESEND');
         ELSE
            UPDATE ESEND.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ESEND' WHERE TABELA = 'COMUNICADO_DEST' AND CHAVE || ''= :OLD.COMUNICADO_SEQ || :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER ESEND.BEF_CONTATO BEFORE UPDATE OR INSERT OR DELETE ON ESEND.CONTATO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ESEND.SYS_DELETE WHERE TABELA = 'CONTATO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ESEND.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('CONTATO', :OLD.SEQ, SYSDATE, USER, 'ESEND');
         ELSE
            UPDATE ESEND.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ESEND' WHERE TABELA = 'CONTATO' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER ESEND.BEF_CONTATO_TEL BEFORE UPDATE OR INSERT OR DELETE ON ESEND.CONTATO_TEL FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ESEND.SYS_DELETE WHERE TABELA = 'CONTATO_TEL' AND CHAVE || '' = :OLD.CONTATO_SEQ || :OLD.TEL || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ESEND.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('CONTATO_TEL', :OLD.CONTATO_SEQ || :OLD.TEL, SYSDATE, USER, 'ESEND');
         ELSE
            UPDATE ESEND.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ESEND' WHERE TABELA = 'CONTATO_TEL' AND CHAVE || ''= :OLD.CONTATO_SEQ || :OLD.TEL || '';
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

CREATE OR REPLACE TRIGGER ESEND.BEF_LISTA BEFORE UPDATE OR INSERT OR DELETE ON ESEND.LISTA FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ESEND.SYS_DELETE WHERE TABELA = 'LISTA' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ESEND.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('LISTA', :OLD.SEQ, SYSDATE, USER, 'ESEND');
         ELSE
            UPDATE ESEND.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ESEND' WHERE TABELA = 'LISTA' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER ESEND.BEF_LISTA_CONTATO BEFORE UPDATE OR INSERT OR DELETE ON ESEND.LISTA_CONTATO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ESEND.SYS_DELETE WHERE TABELA = 'LISTA_CONTATO' AND CHAVE || '' = :OLD.LISTA_SEQ || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ESEND.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('LISTA_CONTATO', :OLD.LISTA_SEQ || :OLD.SEQ, SYSDATE, USER, 'ESEND');
         ELSE
            UPDATE ESEND.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ESEND' WHERE TABELA = 'LISTA_CONTATO' AND CHAVE || ''= :OLD.LISTA_SEQ || :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER ESEND.BEF_SYS_CONFIG_GLOBAL BEFORE UPDATE OR INSERT OR DELETE ON ESEND.SYS_CONFIG_GLOBAL FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ESEND.SYS_DELETE WHERE TABELA = 'SYS_CONFIG_GLOBAL' AND CHAVE || '' = :OLD.PARAM || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ESEND.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_CONFIG_GLOBAL', :OLD.PARAM, SYSDATE, USER, 'ESEND');
         ELSE
            UPDATE ESEND.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ESEND' WHERE TABELA = 'SYS_CONFIG_GLOBAL' AND CHAVE || ''= :OLD.PARAM || '';
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

CREATE OR REPLACE TRIGGER ESEND.BEF_SYS_CONFIG_USUARIO BEFORE UPDATE OR INSERT OR DELETE ON ESEND.SYS_CONFIG_USUARIO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ESEND.SYS_DELETE WHERE TABELA = 'SYS_CONFIG_USUARIO' AND CHAVE || '' = :OLD.USUARIO || :OLD.PARAM || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ESEND.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_CONFIG_USUARIO', :OLD.USUARIO || :OLD.PARAM, SYSDATE, USER, 'ESEND');
         ELSE
            UPDATE ESEND.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ESEND' WHERE TABELA = 'SYS_CONFIG_USUARIO' AND CHAVE || ''= :OLD.USUARIO || :OLD.PARAM || '';
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

CREATE OR REPLACE TRIGGER ESEND.BEF_SYS_LOCALID BEFORE UPDATE OR INSERT OR DELETE ON ESEND.SYS_LOCALID FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ESEND.SYS_DELETE WHERE TABELA = 'SYS_LOCALID' AND CHAVE || '' = :OLD.NOME || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ESEND.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_LOCALID', :OLD.NOME, SYSDATE, USER, 'ESEND');
         ELSE
            UPDATE ESEND.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ESEND' WHERE TABELA = 'SYS_LOCALID' AND CHAVE || ''= :OLD.NOME || '';
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

CREATE OR REPLACE TRIGGER ESEND.BEF_SYS_OCORRENCIA BEFORE UPDATE OR INSERT OR DELETE ON ESEND.SYS_OCORRENCIA FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ESEND.SYS_DELETE WHERE TABELA = 'SYS_OCORRENCIA' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ESEND.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_OCORRENCIA', :OLD.SEQ, SYSDATE, USER, 'ESEND');
         ELSE
            UPDATE ESEND.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ESEND' WHERE TABELA = 'SYS_OCORRENCIA' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER ESEND.BEF_TEMPL_COMUNICADO BEFORE UPDATE OR INSERT OR DELETE ON ESEND.TEMPL_COMUNICADO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ESEND.SYS_DELETE WHERE TABELA = 'TEMPL_COMUNICADO' AND CHAVE || '' = :OLD.COD || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ESEND.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('TEMPL_COMUNICADO', :OLD.COD, SYSDATE, USER, 'ESEND');
         ELSE
            UPDATE ESEND.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ESEND' WHERE TABELA = 'TEMPL_COMUNICADO' AND CHAVE || ''= :OLD.COD || '';
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

CREATE OR REPLACE TRIGGER ESEND.BEF_TIPO_LISTA BEFORE UPDATE OR INSERT OR DELETE ON ESEND.TIPO_LISTA FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ESEND.SYS_DELETE WHERE TABELA = 'TIPO_LISTA' AND CHAVE || '' = :OLD.COD || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ESEND.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('TIPO_LISTA', :OLD.COD, SYSDATE, USER, 'ESEND');
         ELSE
            UPDATE ESEND.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ESEND' WHERE TABELA = 'TIPO_LISTA' AND CHAVE || ''= :OLD.COD || '';
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

CREATE OR REPLACE TRIGGER ESEND.AFT_COMUNICADO_CCD
AFTER UPDATE ON ESEND.COMUNICADO FOR EACH ROW
BEGIN

   --COMUNICADO_CONTR
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE ESEND.COMUNICADO_CONTR SET COMUNICADO_SEQ = :NEW.SEQ WHERE COMUNICADO_SEQ = :OLD.SEQ;
   END IF;

   --COMUNICADO_DEST
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE ESEND.COMUNICADO_DEST SET COMUNICADO_SEQ = :NEW.SEQ WHERE COMUNICADO_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER ESEND.AFT_COMUNICADO_CO_CCD
AFTER UPDATE ON ESEND.COMUNICADO_CONTR FOR EACH ROW
BEGIN

   --COMUNICADO_CONTR_EMAIL
   IF (:OLD.COMUNICADO_SEQ <> :NEW.COMUNICADO_SEQ) OR (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE ESEND.COMUNICADO_CONTR_EMAIL SET COMUNICADO_SEQ = :NEW.COMUNICADO_SEQ, CONTROLE_SEQ = :NEW.SEQ WHERE COMUNICADO_SEQ = :OLD.COMUNICADO_SEQ AND CONTROLE_SEQ = :OLD.SEQ AND NOT COMUNICADO_SEQ IS NULL AND NOT CONTROLE_SEQ IS NULL;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER ESEND.AFT_CONTATO_CCD
AFTER UPDATE ON ESEND.CONTATO FOR EACH ROW
BEGIN

   --CONTATO_TEL
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE ESEND.CONTATO_TEL SET CONTATO_SEQ = :NEW.SEQ WHERE CONTATO_SEQ = :OLD.SEQ;
   END IF;

   --COMUNICADO_DEST
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE ESEND.COMUNICADO_DEST SET CONTATO_SEQ = :NEW.SEQ WHERE CONTATO_SEQ = :OLD.SEQ;
   END IF;

   --CONTATO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE ESEND.CONTATO SET EMPRESA_SEQ = :NEW.SEQ WHERE EMPRESA_SEQ = :OLD.SEQ;
   END IF;

   --LISTA_CONTATO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE ESEND.LISTA_CONTATO SET CONTATO_SEQ = :NEW.SEQ WHERE CONTATO_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER ESEND.AFT_LISTA_CCD
AFTER UPDATE ON ESEND.LISTA FOR EACH ROW
BEGIN

   --LISTA_CONTATO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE ESEND.LISTA_CONTATO SET LISTA_SEQ = :NEW.SEQ WHERE LISTA_SEQ = :OLD.SEQ;
   END IF;

   --COMUNICADO_DEST
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE ESEND.COMUNICADO_DEST SET LISTA_SEQ = :NEW.SEQ WHERE LISTA_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER ESEND.AFT_TIPO_LISTA_CCD
AFTER UPDATE ON ESEND.TIPO_LISTA FOR EACH ROW
BEGIN

   --LISTA
   IF (:OLD.COD <> :NEW.COD) THEN
      UPDATE ESEND.LISTA SET TIPO_LISTA_COD = :NEW.COD WHERE TIPO_LISTA_COD = :OLD.COD;
   END IF;

END;
/

/* **********************************************************************************
   OUTROS CÓDIGOS E VISÕES EM GERAL
*/

-- OBJETO 100 | TRIGGER | LISTA_CONTATO_RESTR
create or replace TRIGGER LISTA_CONTATO_RESTR BEFORE
   INSERT OR
   UPDATE ON LISTA_CONTATO FOR EACH ROW DECLARE TOT NUMBER;
  VLISTASEQ   INTEGER;
  VCONTATOSEQ INTEGER;
  VEMAIL CLOB;
  BEGIN
    TOT                :=0;
    VLISTASEQ          := :NEW.LISTA_SEQ;
    VEMAIL             := :NEW.EMAIL;
    VCONTATOSEQ        := :NEW.CONTATO_SEQ;
    IF NOT VCONTATOSEQ IS NULL THEN
       SELECT COUNT(*)
         INTO TOT
         FROM ESEND.LISTA_CONTATO
        WHERE LISTA_SEQ=VLISTASEQ
      AND CONTATO_SEQ  =VCONTATOSEQ;
      IF TOT           > 0 THEN
        RAISE_APPLICATION_ERROR(-20000,'Contato ' || VCONTATOSEQ || ' já existe nesta lista');
      END IF;
    END IF;
    IF DBMS_LOB.GETLENGTH(:NEW.EMAIL)<>0 THEN
       SELECT COUNT(*)
         INTO TOT
         FROM ESEND.LISTA_CONTATO
        WHERE LISTA_SEQ                     =VLISTASEQ
      AND DBMS_LOB.COMPARE(EMAIL,:NEW.EMAIL)=0;
      IF TOT                                >0 THEN
        RAISE_APPLICATION_ERROR(-20000,'Email ' || VEMAIL || ' já existe nesta lista');
      END IF;
    END IF;
  END;
/

-- OBJETO 101 | TRIGGER | BEF_COMUNICADO_RESTR
create or replace TRIGGER BEF_COMUNICADO_RESTR BEFORE
   UPDATE OR
   INSERT ON COMUNICADO FOR EACH ROW BEGIN IF :NEW.EDICAO_INICIO IS NULL THEN :NEW.STATUS := '';
ELSE
  IF :NEW.ENVIO_MOMENTO IS NULL THEN
    :NEW.STATUS         := '1-Edição';
  ELSE
    IF :NEW.ENVIO_INICIO   IS NULL THEN
      IF :NEW.ENVIO_MOMENTO < SYSDATE THEN
        :NEW.STATUS        := '2-Aguardo';
      ELSE
        :NEW.STATUS := '3-Atenção';
      END IF;
    ELSE
      IF :NEW.ENVIO_PREPARO IS NULL THEN
        :NEW.STATUS         := '4-Preparo';
      ELSE
        IF :NEW.ENVIO_FIM IS NULL THEN
          :NEW.STATUS     := '5-Enviando';
        ELSE
          IF :NEW.RESULT_INICIO IS NULL THEN
            :NEW.STATUS         := '6-Enviado';
          ELSE
            IF :NEW.RESULT_FIM IS NULL THEN
              :NEW.STATUS      := '7-Tratando Retorno';
            ELSE
              :NEW.STATUS := '8-Estatística';
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  END IF;
END IF;
END;
/

-- OBJETO 200 | PACKAGE | LB
create or replace PACKAGE "LB"
IS
FUNCTION LITEM
  (
    TEXTO IN VARCHAR2,
    ITEM  IN NUMBER,
    SEP   IN VARCHAR2 DEFAULT '')
  RETURN VARCHAR2;
FUNCTION LITEM
  (
    TEXTO IN VARCHAR2,
    ITEM  IN VARCHAR2,
    SEP   IN VARCHAR2 DEFAULT '')
  RETURN NUMBER;
FUNCTION LPARAM
  (
    CAMPO IN VARCHAR2,
    TIPO  IN VARCHAR2)
  RETURN VARCHAR2;
FUNCTION LUSTR
  (
    TEXTO IN VARCHAR2)
  RETURN VARCHAR2;
FUNCTION LEXTENSO
  (
    VV   IN NUMBER,
    LING IN VARCHAR2)
  RETURN VARCHAR2;
FUNCTION LMONTACENTO
  (
    STRV0       IN VARCHAR2,
    STRCEM      IN VARCHAR2,
    SEP         IN VARCHAR2,
    STRDEZ      IN VARCHAR2,
    STRPRIMADEZ IN VARCHAR2,
    STRUNID     IN VARCHAR2)
  RETURN VARCHAR2;
FUNCTION LCONCATCAMP
  (
    DOMINIO IN VARCHAR2,
    DELIMIT IN VARCHAR2)
  RETURN VARCHAR2;
FUNCTION LNUMLING
  (
    NUM  IN NUMBER,
    MASC IN VARCHAR2,
    LING IN VARCHAR2)
  RETURN VARCHAR2;
FUNCTION LINSEREESPACO
  (
    STR     IN VARCHAR2,
    TAMANHO IN NUMBER)
  RETURN VARCHAR2;
FUNCTION LEXIBEDATA
  (
    MOMENTO IN DATE,
    FORMATO IN VARCHAR2 DEFAULT '')
  RETURN VARCHAR2;
PROCEDURE LEXECUTASTRING
  (
    CMDSQL IN VARCHAR);
PROCEDURE LCRIA_JOB
  (
    VNOMEJOB        IN VARCHAR2,
    VPROCED         IN VARCHAR2,
    VHORAEXEC       IN VARCHAR2,
    VINTERVALOHORAS IN VARCHAR2 DEFAULT '24');
PROCEDURE LCRIA_JOB_N
  (
    VNOMEJOB       IN VARCHAR2,
    VPROCED        IN VARCHAR2,
    VHORAEXEC      IN VARCHAR2,
    VINTERVALODIAS IN NUMBER DEFAULT '1',
    VINTERVALO     IN NUMBER DEFAULT '1',
    VMETODO        IN VARCHAR2 DEFAULT 'd');
PROCEDURE LAPAGA_JOB
  (
    VNOMEJOB IN VARCHAR2);
END LB;
/

create or replace PACKAGE BODY "LB"
IS
FUNCTION LITEM
  (
    TEXTO IN VARCHAR2,
    ITEM  IN NUMBER,
    SEP   IN VARCHAR2 DEFAULT '')
  RETURN VARCHAR2
IS
  POS   NUMBER;
  POS2  NUMBER;
  BUSCA NUMBER;
  LIMIT VARCHAR2(500);
BEGIN
  IF SEP                 IS NULL THEN
    IF INSTR(TEXTO, ';') <> 0 THEN
      LIMIT              := ';';
    ELSE
      LIMIT := '.';
    END IF;
  ELSE
    LIMIT := SEP;
  END IF;
  BUSCA     := 0;
  POS       := 1;
  WHILE POS <= LENGTH(TEXTO)
  LOOP
    POS2   := INSTR(TEXTO, LIMIT, POS);
    IF POS2 = 0 THEN
      POS2 := LENGTH(TEXTO)+1;
    END IF;
    BUSCA   := BUSCA + 1;
    IF BUSCA = ITEM THEN
      RETURN SUBSTR(TEXTO, POS, POS2-POS);
    ELSE
      POS := POS2 + 1;
    END IF;
  END LOOP;
  RETURN '';
EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR ( -20000, 'erro em litem: ' || SQLERRM);
END LITEM;
FUNCTION LITEM
  (
    TEXTO IN VARCHAR2,
    ITEM  IN VARCHAR2,
    SEP   IN VARCHAR2 DEFAULT '')
  RETURN NUMBER
IS
  POS   NUMBER;
  POS2  NUMBER;
  BUSCA NUMBER;
  LIMIT VARCHAR2(500);
BEGIN
  IF SEP                 IS NULL THEN
    IF INSTR(TEXTO, ';') <> 0 THEN
      LIMIT              := ';';
    ELSE
      LIMIT := '.';
    END IF;
  ELSE
    LIMIT := SEP;
  END IF;
  BUSCA     := 0;
  POS       := 1;
  WHILE POS <= LENGTH(TEXTO)
  LOOP
    POS2   := INSTR(TEXTO, LIMIT, POS);
    IF POS2 = 0 THEN
      POS2 := LENGTH(TEXTO)+1;
    END IF;
    BUSCA                            := BUSCA + 1;
    IF NOT ITEM                      IS NULL THEN
      IF SUBSTR(TEXTO, POS, POS2-POS) = ITEM THEN
        RETURN BUSCA;
      END IF;
    END IF;
    POS := POS2 + 1;
  END LOOP;
  RETURN 0;
EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR ( -20000, 'erro em litem: ' || SQLERRM);
END LITEM;
FUNCTION LPARAM
  (
    CAMPO IN VARCHAR2,
    TIPO  IN VARCHAR2)
  RETURN VARCHAR2
IS
  POS   INTEGER;
  POS2  INTEGER;
  TEXTO VARCHAR2(4000);
BEGIN
  POS       := INSTR(CHR(13) || CHR(10) || CAMPO, CHR(13) || CHR(10) || TIPO || ':');
  IF POS    <> 0 THEN
    POS     := POS + LENGTH(TIPO) + 1;
    POS2    := INSTR(CAMPO, CHR(13) || CHR(10), POS);
    IF POS2  = 0 THEN
      TEXTO := SUBSTR(CAMPO, POS);
    ELSE
      TEXTO := SUBSTR(CAMPO, POS, POS2-POS);
    END IF;
  ELSE
    RETURN '';
  END IF;
  RETURN REPLACE(TEXTO, '|', CHR(10));
EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR ( -20000, 'erro em lparam: ' || SQLERRM);
END LPARAM;
FUNCTION LUSTR
  (
    TEXTO IN VARCHAR2)
  RETURN VARCHAR2
IS
BEGIN
  RETURN REPLACE(TEXTO, CHR(13) || CHR(10), CHR(10));
EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR ( -20000, 'erro em lustr: ' || SQLERRM);
END LUSTR;
FUNCTION LEXTENSO
  (
    VV   IN NUMBER,
    LING IN VARCHAR2)
  RETURN VARCHAR2
IS
  STRUNID     VARCHAR2(500);
  STRDEZ      VARCHAR2(500);
  STRCEM      VARCHAR2(500);
  STRMIL      VARCHAR2(500);
  STRCENT     VARCHAR2(500);
  MOEDA       VARCHAR2(500);
  SEP         VARCHAR2(500);
  STRPRIMADEZ VARCHAR2(500);
  STRVV       VARCHAR2(500);
  STRV0       VARCHAR2(500);
  STRMOEDA    VARCHAR2(500);
  STRM0       VARCHAR2(500);
  ESP         VARCHAR2(500);
  SEPDEC      VARCHAR2(500);
  Z           NUMBER;
  SEPANDTRES  VARCHAR2(500);
  SEPMIL      VARCHAR2(500);
BEGIN
  IF LING        = 'R$' THEN
    STRUNID     := 'Um;Dois;Três;Quatro;Cinco;Seis;Sete;Oito;Nove';
    STRPRIMADEZ := 'Onze;Doze;Treze;Quatorze;Quinze;Dezesseis;Dezesete;Dezoito;Dezenove';
    STRDEZ      := 'Dez;Vinte;Trinta;Quarenta;Cinquenta;Sessenta;Setenta;Oitenta;Noventa';
    STRCEM      := 'Cento;Duzentos;Trezentos;Quatrocentos;Quinhentos;Seiscentos;Setecentos;Oitocentos;Novecentos';
    STRMIL      := 'Mil.Mil;Milhão.Milhões;Bilhão.Bilhões;Trilhão.Trilhões';
    STRCENT     := 'Centavo.Centavos';
    MOEDA       := 'Real;Reais;de Reais';
    SEP         := ' e ';
    SEPDEC      := ' e ';
    SEPMIL      := ', ';
    SEPANDTRES  := ' e ';
    ESP         := ' ';
  ELSIF LING     = 'USD' OR LING = 'US$' OR LING = 'USD.' OR LING = 'U.S.DLRS' THEN
    STRUNID     := 'One;Two;Three;Four;Five;Six;Seven;Eight;Nine';
    STRPRIMADEZ := 'Eleven;Twelve;Thirteen;Fourteen;Fifteen;Sixteen;Seventeen;Eighteen;Nineteen';
    STRDEZ      := 'Tem;Twenty;Thirty;Forty;Fifty;Sixty;Seventy;Eighty;Ninety';
    STRCEM      := 'One Hundred;Two Hundred;Three Hundred;Four Hundred;Five Hundred;Six Hundred;Seven Hundred;Eight Hundred;Nine Hundred';
    STRMIL      := 'Thousand.Thousand;Million.Millions;Billion.Billions;Trillion.Trillions';
    STRCENT     := 'Cent.Cents';
    MOEDA       := 'U.S. Dollar;U.S. Dollars;U.S. Dollars';
    SEP         := ' ';
    SEPDEC      := ' and ';
    SEPMIL      := ', ';
    ESP         := ' ';
    SEPANDTRES  := ' and ';
  ELSIF LING     = 'DM' THEN
    STRUNID     := 'One;Two;Three;Four;Five;Six;Seven;Eight;Nine';
    STRPRIMADEZ := 'Eleven;Twelve;Thirteen;Fourteen;Fifteen;Sixteen;Seventeen;Eighteen;Nineteen';
    STRDEZ      := 'Tem;Twenty;Thirty;Forty;Fifty;Sixty;Seventy;Eighty;Ninety';
    STRCEM      := 'One Hundred;Two Hundred;Three Hundred;Four Hundred;Five Hundred;Six Hundred;Seven Hundred;Eight Hundred;Nine Hundred';
    STRMIL      := 'Thousand.Thousand;Million.Millions;Billion.Billions;Trillion.Trillions';
    STRCENT     := 'Cent.Cents';
    MOEDA       := 'Deutsche Mark;Deutsche Mark;Deutsche Mark';
    SEP         := ' ';
    SEPDEC      := ' and ';
    SEPMIL      := ', ';
    ESP         := ' ';
    SEPANDTRES  := ' and ';
  ELSIF LING     = 'YEN' THEN
    STRUNID     := 'One;Two;Three;Four;Five;Six;Seven;Eight;Nine';
    STRPRIMADEZ := 'Eleven;Twelve;Thirteen;Fourteen;Fifteen;Sixteen;Seventeen;Eighteen;Nineteen';
    STRDEZ      := 'Tem;Twenty;Thirty;Forty;Fifty;Sixty;Seventy;Eighty;Ninety';
    STRCEM      := 'One Hundred;Two Hundred;Three Hundred;Four Hundred;Five Hundred;Six Hundred;Seven Hundred;Eight Hundred;Nine Hundred';
    STRMIL      := 'Thousand.Thousand;Million.Millions;Billion.Billions;Trillion.Trillions';
    STRCENT     := 'Cent.Cents';
    MOEDA       := 'Yen;Yen;Yen';
    SEP         := ' ';
    SEPDEC      := ' and ';
    SEPMIL      := ', ';
    ESP         := ' ';
    SEPANDTRES  := ' and ';
  ELSE
    RETURN '#Erro';
  END IF;
  STRVV := TO_CHAR(VV, 'FM000000000000000.00');
  FOR Z IN 1..6
  LOOP
    STRM0                    := '';
    IF Z                     <> 6 THEN
      STRV0                  := SUBSTR(STRVV, Z * 3 - 2, 3);
      STRM0                  := LMONTACENTO(STRV0, STRCEM, SEP, STRDEZ, STRPRIMADEZ, STRUNID);
      IF NOT STRM0           IS NULL OR Z = 5 THEN
        IF Z                  < 5 THEN
          IF TO_NUMBER(STRV0) = 1 THEN
            STRM0            := STRM0 || ESP || LITEM(LITEM(STRMIL, 5 - Z, ';'), 1, '.');
          ELSE
            STRM0 := STRM0 || ESP || LITEM(LITEM(STRMIL, 5 - Z, ';'), 2, '.');
          END IF;
        ELSE
          IF TO_NUMBER(SUBSTR(STRVV, 1, 15))      <> 0 THEN
            IF SUBSTR(STRVV, 10, 6)                = 'FM000000' THEN
              STRM0                               := STRM0 || ESP || LITEM(MOEDA, 3, ';');
            ELSIF TO_NUMBER(SUBSTR(STRVV, 1, 15))  = 1 THEN
              STRM0                               := STRM0 || ESP || LITEM(MOEDA, 1, ';');
            ELSIF TO_NUMBER(SUBSTR(STRVV, 1, 15)) <> 1 THEN
              STRM0                               := STRM0 || ESP || LITEM(MOEDA, 2, ';');
            END IF;
          END IF;
        END IF;
      END IF;
    ELSE
      STRV0                := 0 || SUBSTR(STRVV, 17, 2);
      STRM0                := LMONTACENTO(STRV0, STRCEM, SEP, STRDEZ, STRPRIMADEZ, STRUNID);
      IF NOT STRM0         IS NULL THEN
        IF TO_NUMBER(STRV0) = 1 THEN
          STRM0            := STRM0 || ' ' || LITEM(STRCENT, 1, '.');
        ELSE
          STRM0 := STRM0 || ' ' || LITEM(STRCENT, 2, '.');
        END IF;
      END IF;
    END IF;
    IF NOT STRM0        IS NULL THEN
      IF Z               = 6 THEN
        IF NOT STRMOEDA IS NULL THEN
          STRMOEDA      := STRMOEDA || SEPDEC || STRM0;
        ELSE
          STRMOEDA := STRMOEDA || '' || STRM0;
        END IF;
      ELSE
        IF NOT STRMOEDA      IS NULL AND TO_NUMBER(STRV0) <> 0 THEN
          IF TO_NUMBER(STRV0) < 101 OR MOD(TO_NUMBER(STRV0), 100) = 0 THEN
            STRMOEDA         := STRMOEDA || SEPANDTRES || STRM0;
          ELSE
            STRMOEDA := STRMOEDA || SEPMIL || STRM0;
          END IF;
        ELSE
          STRMOEDA := STRMOEDA || '' || STRM0;
        END IF;
      END IF;
    END IF;
  END LOOP;
  RETURN STRMOEDA;
EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR ( -20000, 'erro em lextenso: ' || SQLERRM);
END LEXTENSO;
FUNCTION LMONTACENTO
  (
    STRV0       IN VARCHAR2,
    STRCEM      IN VARCHAR2,
    SEP         IN VARCHAR2,
    STRDEZ      IN VARCHAR2,
    STRPRIMADEZ IN VARCHAR2,
    STRUNID     IN VARCHAR2)
  RETURN VARCHAR2
IS
  POS   NUMBER;
  ZZ    NUMBER;
  STRM0 VARCHAR2(100);
BEGIN
  FOR ZZ IN 1..3
  LOOP
    POS                := TO_NUMBER(SUBSTR(STRV0, ZZ, 1));
    IF POS             <> 0 THEN
      IF ZZ             = 1 THEN
        STRM0          := STRM0 || LITEM(STRCEM, POS, ';');
      ELSIF ZZ          = 2 THEN
        IF POS         <> 1 OR SUBSTR(STRV0, 3, 1) = 0 THEN
          IF NOT STRM0 IS NULL THEN
            STRM0      := STRM0 || SEP || LITEM(STRDEZ, POS, ';');
          ELSE
            STRM0 := STRM0 || '' || LITEM(STRDEZ, POS, ';');
          END IF;
        ELSE
          POS          := TO_NUMBER(SUBSTR(STRV0, 3, 1));
          IF NOT STRM0 IS NULL THEN
            STRM0      := STRM0 || SEP || LITEM(STRPRIMADEZ, POS, ';');
          ELSE
            STRM0 := STRM0 || '' || LITEM(STRPRIMADEZ, POS, ';');
          END IF;
          EXIT;
        END IF;
      ELSIF ZZ        = 3 THEN
        IF NOT STRM0 IS NULL THEN
          STRM0      := STRM0 || SEP || LITEM(STRUNID, POS, ';');
        ELSE
          STRM0 := STRM0 || '' || LITEM(STRUNID, POS, ';');
        END IF;
      END IF;
    END IF;
  END LOOP;
  IF STRM0 = 'Cento' THEN
    STRM0 := 'Cem';
  END IF;
  RETURN STRM0;
EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR ( -20000, 'erro em lmontacento: ' || SQLERRM);
END LMONTACENTO;
FUNCTION LCONCATCAMP
  (
    DOMINIO IN VARCHAR2,
    DELIMIT IN VARCHAR2)
  RETURN VARCHAR2
IS
  X PLS_INTEGER;
  RET VARCHAR2(4000);
  TEXTCOL DBMS_SQL.VARCHAR2_TABLE;
  SQLCURSOR PLS_INTEGER;
  NUMROWS PLS_INTEGER;
BEGIN
  SQLCURSOR := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(SQLCURSOR, DOMINIO, DBMS_SQL.V7);
  DBMS_SQL.DEFINE_ARRAY(SQLCURSOR, 1, TEXTCOL, 10, 1);
  NUMROWS := DBMS_SQL.EXECUTE(SQLCURSOR);
  LOOP
    NUMROWS := DBMS_SQL.FETCH_ROWS(SQLCURSOR);
    DBMS_SQL.COLUMN_VALUE(SQLCURSOR, 1, TEXTCOL);
    EXIT
  WHEN NUMROWS < 10;
  END LOOP;
  DBMS_SQL.CLOSE_CURSOR(SQLCURSOR);
  RET   := '';
  FOR X IN 1..TEXTCOL.COUNT
  LOOP
    IF NOT RET IS NULL THEN
      RET      := RET || DELIMIT;
    END IF;
    RET := RET || TEXTCOL(X);
  END LOOP;
  RETURN RET;
EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR ( -20000, 'erro em lconcatcamp: ' || SQLERRM);
END LCONCATCAMP;
FUNCTION LNUMLING
  (
    NUM  IN NUMBER,
    MASC IN VARCHAR2,
    LING IN VARCHAR2)
  RETURN VARCHAR2
IS
  RESULT VARCHAR2(1000);
BEGIN
  RESULT   := TO_CHAR(NUM, MASC);
  IF LING   = 'P' THEN
    RESULT := REPLACE(RESULT, ',', '@');
    RESULT := REPLACE(RESULT, '.', ',');
    RESULT := REPLACE(RESULT, '@', '.');
  END IF;
  RETURN TRIM(RESULT);
EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR ( -20000, 'erro em lnumling: ' || SQLERRM);
END LNUMLING;
FUNCTION LINSEREESPACO
  (
    STR     IN VARCHAR2,
    TAMANHO IN NUMBER)
  RETURN VARCHAR2
IS
  RESULT VARCHAR2(1000);
  I      NUMBER;
BEGIN
  RESULT    := STR;
  IF TAMANHO > (LENGTH(RESULT)) THEN
    FOR I   IN 1..(TAMANHO - LENGTH(RESULT))
    LOOP
      BEGIN
        RESULT := CHR(32) || RESULT;
      END;
    END LOOP;
  END IF;
  RETURN RESULT;
EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR ( -20000, 'erro em LinsereEspaco: ' || SQLERRM);
END LINSEREESPACO;
PROCEDURE LEXECUTASTRING
  (
    CMDSQL IN VARCHAR)
           IS
  NRESULT INTEGER;
  CCMD    INTEGER;
  CMDEXEC VARCHAR(32767);
BEGIN
  CMDEXEC:=CMDSQL;
  CCMD   :=SYS.DBMS_SQL.OPEN_CURSOR;
  SYS.DBMS_SQL.PARSE(CCMD,CMDEXEC,DBMS_SQL.NATIVE);
  NRESULT:=SYS.DBMS_SQL.EXECUTE(CCMD);
  SYS.DBMS_SQL.CLOSE_CURSOR(CCMD);
EXCEPTION
WHEN OTHERS THEN
  CMDEXEC:='';
END LEXECUTASTRING;
FUNCTION LEXIBEDATA
  (
    MOMENTO IN DATE,
    FORMATO IN VARCHAR2 DEFAULT '')
  RETURN VARCHAR2
IS
  VDIA      INTEGER;
  VMES      INTEGER;
  VANO      INTEGER;
  VHORA     INTEGER;
  VMINUTO   INTEGER;
  VSEGUNDO  INTEGER;
  VMESEXTPT VARCHAR2(200);
  VMESEXTEN VARCHAR2(200);
  VMESEXTES VARCHAR2(200);
  VSUF      INTEGER;
  VCONDICAO VARCHAR2(2);
BEGIN
  VDIA        := EXTRACT(DAY FROM MOMENTO);
  VMES        := EXTRACT(MONTH FROM MOMENTO);
  VANO        := EXTRACT(YEAR FROM MOMENTO);
  VHORA       := EXTRACT(HOUR FROM TO_TIMESTAMP(MOMENTO));
  VMINUTO     := EXTRACT(MINUTE FROM TO_TIMESTAMP(MOMENTO));
  VSEGUNDO    := EXTRACT(SECOND FROM TO_TIMESTAMP(MOMENTO));
  VMESEXTPT   := 'Janeiro,Fevereiro,Março,Abril,Maio,Junho,Julho,Agosto,Setembro,Outubro,Novembro,Dezembro';
  VMESEXTEN   := 'January,February,March,April,May,June,July,August,September,October,November,December';
  VMESEXTES   := 'Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre';
  VSUF        := VDIA MOD 10;
  IF (VDIA     > 10) AND (VDIA < 14 ) THEN
    VCONDICAO := 'th';
  ELSIF VSUF   = 1 THEN
    VCONDICAO := 'st';
  ELSIF VSUF   = 2 THEN
    VCONDICAO := 'nd';
  ELSIF VSUF   = 3 THEN
    VCONDICAO := 'rd';
  ELSE
    VCONDICAO := 'th';
  END IF;
  CASE
  WHEN (FORMATO = 'sd') THEN
    RETURN TO_CHAR(MOMENTO,'DD/MM/YYYY'); -- Simples Data DD/MM/YYYY
  WHEN (FORMATO = 'sh') THEN
    RETURN TO_CHAR(MOMENTO,'TS'); -- Simples Hora 24H:MI:SS
  WHEN (FORMATO = 'p') OR (FORMATO = 'dd de mmmm de yyyy') THEN
    RETURN VDIA || ' de ' || LB.LITEM(VMESEXTPT,VMES,',') || ' de ' || VANO;
  WHEN (FORMATO = 'c') OR (FORMATO = 'dd de mmmm de yyyy c') THEN
    RETURN VDIA || ' de ' || LB.LITEM(VMESEXTES,VMES,',') || ' de ' || VANO;
  WHEN (FORMATO = 'i') OR (FORMATO = 'mmmm dth, yyyy') OR (FORMATO = 'mmmm dth yyyy') THEN
    RETURN LB.LITEM(VMESEXTEN,VMES,',') || ' ' || VDIA || VCONDICAO || ', ' || VANO;
  WHEN (FORMATO = 'a') OR (FORMATO = 'dd mmm yyyy') THEN
    RETURN SUBSTR(LB.LITEM(VMESEXTEN,VMES,','),1,3) || ' ' || VDIA || VCONDICAO || ', ' || VANO;
  WHEN (FORMATO = 'ai') OR (FORMATO = 'dd mmm yyyy i') THEN
    RETURN LPAD(VDIA,2,'0') || ' ' || UPPER(LB.LITEM(VMESEXTEN,VMES,',')) || ', ' || LPAD(VANO,4,'0');
  WHEN (FORMATO = 'mmm dd, yyyy') OR (FORMATO = 'mmm dd yyyy') THEN
    RETURN SUBSTR(UPPER(LB.LITEM(VMESEXTPT,VMES,',')),1,3) || ' ' || VDIA || ', ' || LPAD(VANO,4,'0');
  WHEN (FORMATO = 'mmm dd, yyyy i') OR (FORMATO = 'mmm dd yyyy i') THEN
    RETURN SUBSTR(UPPER(LB.LITEM(VMESEXTEN,VMES,',')),1,3) || ' ' || VDIA || ', ' || LPAD(VANO,4,'0');
  WHEN (FORMATO = 'mmm dd, yyyy c') OR (FORMATO = 'mmm dd yyyy c') THEN
    RETURN SUBSTR(UPPER(LB.LITEM(VMESEXTES,VMES,',')),1,3) || ' ' || VDIA || ', ' || LPAD(VANO,4,'0');
  WHEN (FORMATO = 'mmmm, yyyy') OR (FORMATO = 'mmmm yyyy') THEN
    RETURN LB.LITEM(VMESEXTPT,VMES,',') || ', ' || LPAD(VANO,4,'0');
  WHEN (FORMATO = 'mmmm, yyyy i') OR (FORMATO = 'mmmm yyyy i') THEN
    RETURN LB.LITEM(VMESEXTEN,VMES,',') || ', ' || VANO;
  WHEN (FORMATO = 'mmmm, yyyy c') OR (FORMATO = 'mmmm yyyy c') THEN
    RETURN LB.LITEM(VMESEXTES,VMES,',') || ', ' || VANO;
  WHEN (FORMATO = 'mmmm/yy') OR (FORMATO = 'mmmm yy') THEN
    RETURN LB.LITEM(VMESEXTPT,VMES,',') || '/' || SUBSTR(VANO,3,2);
  WHEN (FORMATO = 'mmm') THEN
    RETURN SUBSTR(UPPER(LB.LITEM(VMESEXTPT,VMES,',')),1,3);
  WHEN (FORMATO = 'mmm i') THEN
    RETURN SUBSTR(UPPER(LB.LITEM(VMESEXTEN,VMES,',')),1,3);
  WHEN (FORMATO = 'mmm c') THEN
    RETURN SUBSTR(UPPER(LB.LITEM(VMESEXTES,VMES,',')),1,3);
  WHEN (FORMATO = 'mmmm') THEN
    RETURN LB.LITEM(VMESEXTPT,VMES,',');
  WHEN (FORMATO = 'mmmm i') THEN
    RETURN LB.LITEM(VMESEXTEN,VMES,',');
  WHEN (FORMATO = 'mmmm c') THEN
    RETURN LB.LITEM(VMESEXTES,VMES,',');
  ELSE
    RETURN VDIA || '/' || VMES || '/' || VANO || ' ' || VHORA || ':' || VMINUTO || ':' || VSEGUNDO;
  END CASE;
END LEXIBEDATA;
--------------------------------------------------------------------------------------------------------------
-- Procedimento para criação de jobs(tarefas) a serem executadas periodicamente no Oracle
--------------------------------------------------------------------------------------------------------------
PROCEDURE LCRIA_JOB
  (
    VNOMEJOB        IN VARCHAR2,
    VPROCED         IN VARCHAR2,
    VHORAEXEC       IN VARCHAR2,
    VINTERVALOHORAS IN VARCHAR2 DEFAULT '24')
AS
  JOB BINARY_INTEGER;
BEGIN
  BEGIN
    FOR CUR IN
    (SELECT JOB FROM USER_JOBS WHERE WHAT LIKE '% ' || VNOMEJOB || ' %'
    )
    LOOP
      DBMS_JOB.REMOVE(CUR.JOB);
    END LOOP;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  DBMS_JOB.SUBMIT(JOB, '/* ' || VNOMEJOB || ' */begin ' || VPROCED || ';end;',TO_DATE('' || TO_CHAR(SYSDATE,'DD/MM/YYYY') || ' ' || VHORAEXEC ||'','DD/MM/YYYY HH24:MI:SS'), 'TRUNC(SYSDATE + 1) + ' || VINTERVALOHORAS || ' / 24');
END LCRIA_JOB;
PROCEDURE LCRIA_JOB_N
  (
    VNOMEJOB       IN VARCHAR2,
    VPROCED        IN VARCHAR2,
    VHORAEXEC      IN VARCHAR2,
    VINTERVALODIAS IN NUMBER DEFAULT '1',
    VINTERVALO     IN NUMBER DEFAULT '1',
    VMETODO        IN VARCHAR2 DEFAULT 'd')
AS
  JOB BINARY_INTEGER;
  VMET VARCHAR2(30);
BEGIN
  BEGIN
    FOR CUR IN
    (SELECT JOB FROM USER_JOBS WHERE WHAT LIKE '% ' || VNOMEJOB || ' %'
    )
    LOOP
      DBMS_JOB.REMOVE(CUR.JOB);
    END LOOP;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  CASE
  WHEN VMETODO = 's' THEN
    VMET      := 'SYSDATE + ' || VINTERVALO || '/86400'; -- Intervalo em Segundos
  WHEN VMETODO = 'm' THEN
    VMET      := 'SYSDATE + ' || VINTERVALO || '/1440'; -- Intervalo em Minutos
  WHEN VMETODO = 'h' THEN
    VMET      := 'SYSDATE + ' || VINTERVALO || '/24'; -- Intervalo em Horas
  WHEN VMETODO = 'd' THEN
    VMET      := 'TRUNC(SYSDATE + '|| VINTERVALODIAS || ') + ' || VINTERVALO || '/24'; -- Intervalo em Horas
  WHEN VMETODO = 'x' THEN
    VMET      := 'TRUNC(LAST_DAY(SYSDATE) + 1) + ' || VINTERVALO || '/24'; -- Todo 1 dia do Mês
  WHEN VMETODO = '2' THEN
    VMET      := 'NEXT_DAY(TRUNC(SYSDATE), ''Monday'') + ' || VINTERVALO || '/24)'; -- Tda Segunda na Hora Especificada
  WHEN VMETODO = '3' THEN
    VMET      := 'NEXT_DAY(TRUNC(SYSDATE), ''Tuesday'') + ' || VINTERVALO || '/24)'; -- Tda Segunda na Hora Especificada
  WHEN VMETODO = '4' THEN
    VMET      := 'NEXT_DAY(TRUNC(SYSDATE), ''Wednesday'') + ' || VINTERVALO || '/24)'; -- Tda Segunda na Hora Especificada
  WHEN VMETODO = '5' THEN
    VMET      := 'NEXT_DAY(TRUNC(SYSDATE), ''Thursday'') + ' || VINTERVALO || '/24)'; -- Tda Segunda na Hora Especificada
  WHEN VMETODO = '6' THEN
    VMET      := 'NEXT_DAY(TRUNC(SYSDATE), ''Friday'') + ' || VINTERVALO || '/24)'; -- Tda Segunda na Hora Especificada
  WHEN VMETODO = 'S' THEN
    VMET      := 'NEXT_DAY(TRUNC(SYSDATE), ''Saturday'') + ' || VINTERVALO || '/24)'; -- Tda Segunda na Hora Especificada
  WHEN VMETODO = 'D' THEN
    VMET      := 'NEXT_DAY(TRUNC(SYSDATE), ''Sunday'') + ' || VINTERVALO || '/24)'; -- Tda Segunda na Hora Especificada
  END CASE;
  DBMS_JOB.SUBMIT(JOB, '/* ' || VNOMEJOB || ' */begin ' || VPROCED || ';end;',TO_DATE('' || TO_CHAR(SYSDATE,'DD/MM/YYYY') || ' ' || VHORAEXEC ||'','DD/MM/YYYY HH24:MI:SS'), VMET);
END LCRIA_JOB_N;
--------------------------------------------------------------------------------------------------------------
-- Procedimento para exclusão de jobs(tarefas) no Oracle
--------------------------------------------------------------------------------------------------------------
PROCEDURE LAPAGA_JOB
  (
    VNOMEJOB IN VARCHAR2)
AS
  JOB BINARY_INTEGER;
BEGIN
  BEGIN
    FOR CUR IN
    (SELECT JOB FROM USER_JOBS WHERE WHAT LIKE '% ' || VNOMEJOB || ' %'
    )
    LOOP
      DBMS_JOB.REMOVE(CUR.JOB);
    END LOOP;
  END;
END LAPAGA_JOB;
END LB;
/

-- OBJETO 400 | PROCEDURE | CHECK_EXEC
create or replace PROCEDURE       CHECK_EXEC
AS
  STATUS VARCHAR2 (200) ;
  ULT_MOM DATE;
  MAX_MINS_SEM_CHECK INTEGER;
BEGIN
  BEGIN
     SELECT TO_NUMBER(CONFIG)
       INTO MAX_MINS_SEM_CHECK
       FROM ESEND.SYS_CONFIG_GLOBAL
      WHERE PARAM = 'ESEND_INTERV_CONFIRM_PRES';
  EXCEPTION
  WHEN OTHERS THEN
    MAX_MINS_SEM_CHECK := 20;
  END;
  BEGIN
     SELECT CONFIG
       INTO STATUS
       FROM ESEND.SYS_CONFIG_GLOBAL
      WHERE PARAM = 'ESEND_STATUS_ULTIMO';
    ULT_MOM                      := TO_DATE (LPAD (STATUS, 16), 'DD/MM/YYYY HH24:MI:SS') ;
    IF (SYSDATE - ULT_MOM) * 1440 < MAX_MINS_SEM_CHECK THEN
      STATUS                     := '';
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    STATUS := 'NUNCA EXECUTOU OU NÃO FOI POSSÍVEL DETERMINAR';
  END;
  IF LENGTH(STATUS)>0 THEN
    SBDB.SENDMAIL ('lucianol@icraft.com.br', 'lucianol@icraft.com.br', 'SBD - ESENDWEB - PARADA NO APLICATIVO', '<HTML><BODY><H1>ATENÇÃO</H1>PELO MENOS DURANTE ' || MAX_MINS_SEM_CHECK || ' MINS, O PROGRAMA ESENDAPP NÃO REALIZOU CHECAGENS. FAVOR VERIFICAR.<BR/><BR/>ÚLTIMO STATUS:' || STATUS || '</BODY></HTML>') ;
  END IF;
END CHECK_EXEC;
/

-- OBJETO 401 | PROCEDURE | COM_CONTR_EMAIL_NUMERA
create or replace PROCEDURE COM_CONTR_EMAIL_NUMERA
  (
    COM   NUMBER,
    CONTR NUMBER)
             IS
  SEQ NUMBER := 1;
BEGIN
  FOR CUR IN
  (SELECT COMUNICADO_SEQ,
    CONTROLE_SEQ        ,
    EMAIL
     FROM ESEND.COMUNICADO_CONTR_EMAIL
    WHERE COMUNICADO_SEQ = COM
  AND CONTROLE_SEQ       = CONTR
 ORDER BY DOMINIO,
    EMAIL
  )
  LOOP
     UPDATE ESEND.COMUNICADO_CONTR_EMAIL
    SET ORDEM              = SEQ
      WHERE COMUNICADO_SEQ = CUR.COMUNICADO_SEQ
    AND CONTROLE_SEQ       = CUR.CONTROLE_SEQ
    AND EMAIL              = CUR.EMAIL;
    SEQ := SEQ + 1;
  END LOOP;
  COMMIT;
END;
/

-- OBJETO 900 | CRIA_JOBS | JOB
----------------------------------------------------------------------------------------------------
-- CRIA OS JOBS DA BASE
----------------------------------------------------------------------------------------------------
EXEC LB.LCRIA_JOB_N('GARANTIA DE EXECUÇÃO DO PROG','CHECK_EXEC','00:00:00',1,20,'m');
----------------------------------------------------------------------------------------------------
-- RODA OS JOBS DA BASE
----------------------------------------------------------------------------------------------------
SET SERVEROUTPUT ON SIZE 40000
BEGIN
  FOR CUR IN
  (SELECT JOB, WHAT FROM USER_JOBS WHERE SCHEMA_USER='ESEND'
  )
  LOOP
    BEGIN
      DBMS_JOB.RUN(CUR.JOB);
    EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM || ' - JOB ' || CUR.WHAT);
    END;
  END LOOP;
END;
/


/* **********************************************************************************
   CRIAÇÃO DE USUÁRIOS
*/

SPOOL OFF
$ECHO - >>"C:\ESEND_PARTES.LOG"
$ECHO - >>"C:\ESEND_PARTES.LOG"
$ECHO - >>"C:\ESEND_PARTES.LOG"
$COMMAND /C ECHO %DATE% %TIME% >>"C:\ESEND_PARTES.LOG"
$COMMAND /C FIND "ORA-" "C:\ESEND_PARTE2.LOG" >>"C:\ESEND_PARTES.LOG"
$COMMAND /C FIND "SP2-" "C:\ESEND_PARTE2.LOG" >>"C:\ESEND_PARTES.LOG"
