SET ECHO ON
SPOOL C:\ATLAS_PARTE2.LOG
CONNECT ATLAS/XXXX@SBDB;

-- ELIMINA OS JOBS
begin
for cur in (select job from user_jobs where schema_user='ATLAS') loop
dbms_job.remove(cur.job);
end loop;
end;
/

-- CRIA ÍNDICES


/* **********************************************************************************
   CRIAÇÃO DE RELACIONAMENTOS
*/

ALTER TABLE ATLAS."FOTO" ADD CONSTRAINT "CLASSE_FOTO_01" FOREIGN KEY("COD_CLASSE") REFERENCES ATLAS."CLASSE"("CODIGO");
ALTER TABLE ATLAS."FOTO" ADD CONSTRAINT "AUTOR_FOTO_01" FOREIGN KEY("COD_AUTOR") REFERENCES ATLAS."AUTOR"("CODIGO");


/* **********************************************************************************
   CONSTRAINTS BASE EM CHECK
*/

/* **********************************************************************************
   CRIAÇÃO DE TRIGGERS PARA REGISTRO DE INCLUSÃO, ATUALIZAÇÃO E EXCLUSÃO
*/

CREATE OR REPLACE TRIGGER ATLAS.BEF_AUTOR BEFORE UPDATE OR INSERT OR DELETE ON ATLAS.AUTOR FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ATLAS.SYS_DELETE WHERE TABELA = 'AUTOR' AND CHAVE || '' = :OLD.CODIGO || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ATLAS.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('AUTOR', :OLD.CODIGO, SYSDATE, USER, 'ATLAS');
         ELSE
            UPDATE ATLAS.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ATLAS' WHERE TABELA = 'AUTOR' AND CHAVE || ''= :OLD.CODIGO || '';
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

CREATE OR REPLACE TRIGGER ATLAS.BEF_CLASSE BEFORE UPDATE OR INSERT OR DELETE ON ATLAS.CLASSE FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ATLAS.SYS_DELETE WHERE TABELA = 'CLASSE' AND CHAVE || '' = :OLD.CODIGO || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ATLAS.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('CLASSE', :OLD.CODIGO, SYSDATE, USER, 'ATLAS');
         ELSE
            UPDATE ATLAS.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ATLAS' WHERE TABELA = 'CLASSE' AND CHAVE || ''= :OLD.CODIGO || '';
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

CREATE OR REPLACE TRIGGER ATLAS.BEF_FOTO BEFORE UPDATE OR INSERT OR DELETE ON ATLAS.FOTO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ATLAS.SYS_DELETE WHERE TABELA = 'FOTO' AND CHAVE || '' = :OLD.CODIGO || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ATLAS.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('FOTO', :OLD.CODIGO, SYSDATE, USER, 'ATLAS');
         ELSE
            UPDATE ATLAS.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ATLAS' WHERE TABELA = 'FOTO' AND CHAVE || ''= :OLD.CODIGO || '';
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

CREATE OR REPLACE TRIGGER ATLAS.BEF_SYS_CONFIG_GLOBAL BEFORE UPDATE OR INSERT OR DELETE ON ATLAS.SYS_CONFIG_GLOBAL FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ATLAS.SYS_DELETE WHERE TABELA = 'SYS_CONFIG_GLOBAL' AND CHAVE || '' = :OLD.PARAM || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ATLAS.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_CONFIG_GLOBAL', :OLD.PARAM, SYSDATE, USER, 'ATLAS');
         ELSE
            UPDATE ATLAS.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ATLAS' WHERE TABELA = 'SYS_CONFIG_GLOBAL' AND CHAVE || ''= :OLD.PARAM || '';
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

CREATE OR REPLACE TRIGGER ATLAS.BEF_SYS_CONFIG_USUARIO BEFORE UPDATE OR INSERT OR DELETE ON ATLAS.SYS_CONFIG_USUARIO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ATLAS.SYS_DELETE WHERE TABELA = 'SYS_CONFIG_USUARIO' AND CHAVE || '' = :OLD.USUARIO || :OLD.PARAM || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ATLAS.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_CONFIG_USUARIO', :OLD.USUARIO || :OLD.PARAM, SYSDATE, USER, 'ATLAS');
         ELSE
            UPDATE ATLAS.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ATLAS' WHERE TABELA = 'SYS_CONFIG_USUARIO' AND CHAVE || ''= :OLD.USUARIO || :OLD.PARAM || '';
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

CREATE OR REPLACE TRIGGER ATLAS.BEF_SYS_LOCALID BEFORE UPDATE OR INSERT OR DELETE ON ATLAS.SYS_LOCALID FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ATLAS.SYS_DELETE WHERE TABELA = 'SYS_LOCALID' AND CHAVE || '' = :OLD.NOME || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ATLAS.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_LOCALID', :OLD.NOME, SYSDATE, USER, 'ATLAS');
         ELSE
            UPDATE ATLAS.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ATLAS' WHERE TABELA = 'SYS_LOCALID' AND CHAVE || ''= :OLD.NOME || '';
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

CREATE OR REPLACE TRIGGER ATLAS.BEF_SYS_OCORRENCIA BEFORE UPDATE OR INSERT OR DELETE ON ATLAS.SYS_OCORRENCIA FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ATLAS.SYS_DELETE WHERE TABELA = 'SYS_OCORRENCIA' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ATLAS.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_OCORRENCIA', :OLD.SEQ, SYSDATE, USER, 'ATLAS');
         ELSE
            UPDATE ATLAS.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ATLAS' WHERE TABELA = 'SYS_OCORRENCIA' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER ATLAS.BEF_TECNICO BEFORE UPDATE OR INSERT OR DELETE ON ATLAS.TECNICO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ATLAS.SYS_DELETE WHERE TABELA = 'TECNICO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ATLAS.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('TECNICO', :OLD.SEQ, SYSDATE, USER, 'ATLAS');
         ELSE
            UPDATE ATLAS.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ATLAS' WHERE TABELA = 'TECNICO' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER ATLAS.BEF_TECNICO_ACESSO BEFORE UPDATE OR INSERT OR DELETE ON ATLAS.TECNICO_ACESSO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM ATLAS.SYS_DELETE WHERE TABELA = 'TECNICO_ACESSO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO ATLAS.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('TECNICO_ACESSO', :OLD.SEQ, SYSDATE, USER, 'ATLAS');
         ELSE
            UPDATE ATLAS.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'ATLAS' WHERE TABELA = 'TECNICO_ACESSO' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER ATLAS.AFT_AUTOR_CCD
AFTER UPDATE ON ATLAS.AUTOR FOR EACH ROW
BEGIN

   --FOTO
   IF (:OLD.CODIGO <> :NEW.CODIGO) THEN
      UPDATE ATLAS.FOTO SET COD_AUTOR = :NEW.CODIGO WHERE COD_AUTOR = :OLD.CODIGO;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER ATLAS.AFT_CLASSE_CCD
AFTER UPDATE ON ATLAS.CLASSE FOR EACH ROW
BEGIN

   --FOTO
   IF (:OLD.CODIGO <> :NEW.CODIGO) THEN
      UPDATE ATLAS.FOTO SET COD_CLASSE = :NEW.CODIGO WHERE COD_CLASSE = :OLD.CODIGO;
   END IF;

END;
/

/* **********************************************************************************
   OUTROS CÓDIGOS E VISÕES EM GERAL
*/

-- OBJETO 100 | TRIGGER | BEF_AUTOR_INDICE
create or replace TRIGGER "ATLAS".bef_autor_indice BEFORE INSERT OR UPDATE ON atlas.autor FOR EACH ROW
DECLARE
  SEQ NUMBER;
BEGIN
  IF NVL(:NEW.CODIGO,0) = 0 THEN
    SELECT NVL(MAX(CODIGO),0)+1 INTO SEQ FROM ATLAS.AUTOR;
    :NEW.CODIGO := SEQ;
  END IF;
END;
/

-- OBJETO 101 | TRIGGER | BEF_CLASSE_INDICE
create or replace TRIGGER "ATLAS".bef_classe_indice BEFORE INSERT OR UPDATE ON atlas.classe
FOR EACH ROW
DECLARE
    SEQ NUMBER;
BEGIN
  IF NVL(:NEW.CODIGO,0) = 0 THEN
    SELECT NVL(MAX(CODIGO),0)+1 INTO SEQ FROM ATLAS.CLASSE;
    :NEW.CODIGO := SEQ;
  END IF;
END;
/

-- OBJETO 102 | TRIGGER | BEF_FOTO_INDICE
create or replace TRIGGER "ATLAS".bef_foto_indice BEFORE INSERT OR UPDATE ON atlas.foto
FOR EACH ROW
DECLARE
    SEQ NUMBER;
BEGIN
  IF NVL(:NEW.CODIGO,0) = 0 THEN
    SELECT NVL(MAX(CODIGO),0)+1 INTO SEQ FROM ATLAS.FOTO;
    :NEW.CODIGO := SEQ;
  END IF;
END;
/

-- OBJETO 103 | TRIGGER | BEF_TECNICO_ACESSO_INDICE
create or replace TRIGGER "ATLAS".bef_tecnico_acesso_indice BEFORE INSERT OR UPDATE ON atlas.tecnico_acesso
FOR EACH ROW
DECLARE
    SEQ NUMBER;
BEGIN
  IF NVL(:NEW.SEQ,0) = 0 THEN
    SELECT NVL(MAX(SEQ),0)+1 INTO SEQ FROM ATLAS.TECNICO_ACESSO;
    :NEW.SEQ := SEQ;
  END IF;
END;
/

-- OBJETO 104 | TRIGGER | BEF_TECNICO_INDICE
create or replace TRIGGER "ATLAS".bef_tecnico_indice BEFORE INSERT OR UPDATE ON atlas.tecnico
FOR EACH ROW
DECLARE
    SEQ NUMBER;
BEGIN
  IF NVL(:NEW.SEQ,0) = 0 THEN
    SELECT NVL(MAX(SEQ),0)+1 INTO SEQ FROM ATLAS.TECNICO;
    :NEW.SEQ := SEQ;
  END IF;
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

Procedure LCria_Job_N(vNomeJob in varchar2, vProced in varchar2, vHoraExec in varchar2, vIntervaloDias in number default '1', vIntervalo in number default '1', vMetodo in VARCHAR2 default 'd')  as
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


/* **********************************************************************************
   CRIAÇÃO DE USUÁRIOS
*/

SPOOL OFF
$ECHO - >>"C:\ATLAS_PARTES.LOG"
$ECHO - >>"C:\ATLAS_PARTES.LOG"
$ECHO - >>"C:\ATLAS_PARTES.LOG"
$COMMAND /C ECHO %DATE% %TIME% >>"C:\ATLAS_PARTES.LOG"
$COMMAND /C FIND "ORA-" "C:\ATLAS_PARTE2.LOG" >>"C:\ATLAS_PARTES.LOG"
$COMMAND /C FIND "SP2-" "C:\ATLAS_PARTE2.LOG" >>"C:\ATLAS_PARTES.LOG"
