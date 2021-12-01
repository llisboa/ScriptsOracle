SET ECHO ON
SPOOL C:\SEPON_PARTE2.LOG
CONNECT SEPON/XXXX@SBDB;

-- ELIMINA OS JOBS
begin
for cur in (select job from user_jobs where schema_user='SEPON') loop
dbms_job.remove(cur.job);
end loop;
end;
/

-- CRIA ÍNDICES


/* **********************************************************************************
   CRIAÇÃO DE RELACIONAMENTOS
*/

ALTER TABLE SEPON."CONEXAO" ADD CONSTRAINT "USUARIO_CONEXAO_01" FOREIGN KEY("USUARIO_SEQ") REFERENCES SEPON."USUARIO"("SEQ");
ALTER TABLE SEPON."EVENTO_CONTRATO" ADD CONSTRAINT "USUARIO_EVENTO_CONTRATO_01" FOREIGN KEY("USUARIO_SEQ") REFERENCES SEPON."USUARIO"("SEQ");
ALTER TABLE SEPON."EVENTO_GRATUIDADE" ADD CONSTRAINT "USUARIO_EVENTO_GRATUIDADE_01" FOREIGN KEY("USUARIO_SEQ") REFERENCES SEPON."USUARIO"("SEQ");
ALTER TABLE SEPON."PARTICIPANTE" ADD CONSTRAINT "USUARIO_PARTICIPANTE_01" FOREIGN KEY("USUARIO_SEQ") REFERENCES SEPON."USUARIO"("SEQ");
ALTER TABLE SEPON."VIDEO_ASSIST" ADD CONSTRAINT "USUARIO_VIDEO_ASSIST_01" FOREIGN KEY("USUARIO_SEQ") REFERENCES SEPON."USUARIO"("SEQ");
ALTER TABLE SEPON."VIDEO_ASSIST" ADD CONSTRAINT "VIDEO_VIDEO_ASSIST_01" FOREIGN KEY("VIDEO_SEQ") REFERENCES SEPON."VIDEO"("SEQ");
ALTER TABLE SEPON."EVENTO_CONTRATO" ADD CONSTRAINT "BOLETO_EVENTO_CONTRATO_01" FOREIGN KEY("BOLETO_SEQ") REFERENCES SEPON."BOLETO"("SEQ");
ALTER TABLE SEPON."EVENTO_CONTRATO" ADD CONSTRAINT "EVENTO_EVENTO_CONTRATO_01" FOREIGN KEY("EVENTO_SEQ") REFERENCES SEPON."EVENTO"("SEQ");
ALTER TABLE SEPON."EVENTO_GRATUIDADE" ADD CONSTRAINT "EVENTO_EVENTO_GRATUIDADE_01" FOREIGN KEY("EVENTO_SEQ") REFERENCES SEPON."EVENTO"("SEQ");
ALTER TABLE SEPON."FORMA_ACESSO" ADD CONSTRAINT "EVENTO_FORMA_ACESSO_01" FOREIGN KEY("EVENTO_SEQ") REFERENCES SEPON."EVENTO"("SEQ");
ALTER TABLE SEPON."PARTICIPANTE" ADD CONSTRAINT "EVENTO_PARTICIPANTE_01" FOREIGN KEY("EVENTO_SEQ") REFERENCES SEPON."EVENTO"("SEQ");
ALTER TABLE SEPON."SLIDE" ADD CONSTRAINT "EVENTO_SLIDE_01" FOREIGN KEY("EVENTO_SEQ") REFERENCES SEPON."EVENTO"("SEQ");
ALTER TABLE SEPON."VIDEO" ADD CONSTRAINT "EVENTO_VIDEO_01" FOREIGN KEY("EVENTO_SEQ") REFERENCES SEPON."EVENTO"("SEQ");
ALTER TABLE SEPON."CONEXAO" ADD CONSTRAINT "LINK_CONEXAO_01" FOREIGN KEY("LINK_SEQ") REFERENCES SEPON."LINK"("SEQ");
ALTER TABLE SEPON."FORMA_ACESSO" ADD CONSTRAINT "TIPO_ACESSO_FORMA_ACESSO_01" FOREIGN KEY("TIPO_ACESSO_SEQ") REFERENCES SEPON."TIPO_ACESSO"("SEQ");
ALTER TABLE SEPON."BOLETO" ADD CONSTRAINT "USUARIO_BOLETO_01" FOREIGN KEY("CONFIRM_OPER_SEQ") REFERENCES SEPON."USUARIO"("SEQ");


/* **********************************************************************************
   CONSTRAINTS BASE EM CHECK
*/

/* **********************************************************************************
   CRIAÇÃO DE TRIGGERS PARA REGISTRO DE INCLUSÃO, ATUALIZAÇÃO E EXCLUSÃO
*/

CREATE OR REPLACE TRIGGER SEPON.BEF_BOLETO BEFORE UPDATE OR INSERT OR DELETE ON SEPON.BOLETO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'BOLETO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('BOLETO', :OLD.SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'BOLETO' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_CONEXAO BEFORE UPDATE OR INSERT OR DELETE ON SEPON.CONEXAO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'CONEXAO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('CONEXAO', :OLD.SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'CONEXAO' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_EVENTO BEFORE UPDATE OR INSERT OR DELETE ON SEPON.EVENTO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'EVENTO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('EVENTO', :OLD.SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'EVENTO' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_EVENTO_CONTRATO BEFORE UPDATE OR INSERT OR DELETE ON SEPON.EVENTO_CONTRATO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'EVENTO_CONTRATO' AND CHAVE || '' = :OLD.EVENTO_SEQ || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('EVENTO_CONTRATO', :OLD.EVENTO_SEQ || :OLD.SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'EVENTO_CONTRATO' AND CHAVE || ''= :OLD.EVENTO_SEQ || :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_EVENTO_GRATUIDADE BEFORE UPDATE OR INSERT OR DELETE ON SEPON.EVENTO_GRATUIDADE FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'EVENTO_GRATUIDADE' AND CHAVE || '' = :OLD.EVENTO_SEQ || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('EVENTO_GRATUIDADE', :OLD.EVENTO_SEQ || :OLD.SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'EVENTO_GRATUIDADE' AND CHAVE || ''= :OLD.EVENTO_SEQ || :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_FORMA_ACESSO BEFORE UPDATE OR INSERT OR DELETE ON SEPON.FORMA_ACESSO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'FORMA_ACESSO' AND CHAVE || '' = :OLD.EVENTO_SEQ || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('FORMA_ACESSO', :OLD.EVENTO_SEQ || :OLD.SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'FORMA_ACESSO' AND CHAVE || ''= :OLD.EVENTO_SEQ || :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_LINK BEFORE UPDATE OR INSERT OR DELETE ON SEPON.LINK FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'LINK' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('LINK', :OLD.SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'LINK' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_LOG BEFORE UPDATE OR INSERT OR DELETE ON SEPON.LOG FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'LOG' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('LOG', :OLD.SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'LOG' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_PARTICIPANTE BEFORE UPDATE OR INSERT OR DELETE ON SEPON.PARTICIPANTE FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'PARTICIPANTE' AND CHAVE || '' = :OLD.EVENTO_SEQ || :OLD.USUARIO_SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('PARTICIPANTE', :OLD.EVENTO_SEQ || :OLD.USUARIO_SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'PARTICIPANTE' AND CHAVE || ''= :OLD.EVENTO_SEQ || :OLD.USUARIO_SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_SLIDE BEFORE UPDATE OR INSERT OR DELETE ON SEPON.SLIDE FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'SLIDE' AND CHAVE || '' = :OLD.EVENTO_SEQ || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SLIDE', :OLD.EVENTO_SEQ || :OLD.SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'SLIDE' AND CHAVE || ''= :OLD.EVENTO_SEQ || :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_SYS_CONFIG_GLOBAL BEFORE UPDATE OR INSERT OR DELETE ON SEPON.SYS_CONFIG_GLOBAL FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'SYS_CONFIG_GLOBAL' AND CHAVE || '' = :OLD.PARAM || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_CONFIG_GLOBAL', :OLD.PARAM, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'SYS_CONFIG_GLOBAL' AND CHAVE || ''= :OLD.PARAM || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_SYS_CONFIG_USUARIO BEFORE UPDATE OR INSERT OR DELETE ON SEPON.SYS_CONFIG_USUARIO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'SYS_CONFIG_USUARIO' AND CHAVE || '' = :OLD.USUARIO || :OLD.PARAM || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_CONFIG_USUARIO', :OLD.USUARIO || :OLD.PARAM, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'SYS_CONFIG_USUARIO' AND CHAVE || ''= :OLD.USUARIO || :OLD.PARAM || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_SYS_LOCALID BEFORE UPDATE OR INSERT OR DELETE ON SEPON.SYS_LOCALID FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'SYS_LOCALID' AND CHAVE || '' = :OLD.NOME || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_LOCALID', :OLD.NOME, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'SYS_LOCALID' AND CHAVE || ''= :OLD.NOME || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_SYS_OCORRENCIA BEFORE UPDATE OR INSERT OR DELETE ON SEPON.SYS_OCORRENCIA FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'SYS_OCORRENCIA' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_OCORRENCIA', :OLD.SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'SYS_OCORRENCIA' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_TIPO_ACESSO BEFORE UPDATE OR INSERT OR DELETE ON SEPON.TIPO_ACESSO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'TIPO_ACESSO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('TIPO_ACESSO', :OLD.SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'TIPO_ACESSO' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_USUARIO BEFORE UPDATE OR INSERT OR DELETE ON SEPON.USUARIO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'USUARIO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('USUARIO', :OLD.SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'USUARIO' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_VIDEO BEFORE UPDATE OR INSERT OR DELETE ON SEPON.VIDEO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'VIDEO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('VIDEO', :OLD.SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'VIDEO' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.BEF_VIDEO_ASSIST BEFORE UPDATE OR INSERT OR DELETE ON SEPON.VIDEO_ASSIST FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM SEPON.SYS_DELETE WHERE TABELA = 'VIDEO_ASSIST' AND CHAVE || '' = :OLD.VIDEO_SEQ || :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO SEPON.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('VIDEO_ASSIST', :OLD.VIDEO_SEQ || :OLD.SEQ, SYSDATE, USER, 'SEPON');
         ELSE
            UPDATE SEPON.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'SEPON' WHERE TABELA = 'VIDEO_ASSIST' AND CHAVE || ''= :OLD.VIDEO_SEQ || :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER SEPON.AFT_BOLETO_CCD
AFTER UPDATE ON SEPON.BOLETO FOR EACH ROW
BEGIN

   --EVENTO_CONTRATO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.EVENTO_CONTRATO SET BOLETO_SEQ = :NEW.SEQ WHERE BOLETO_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SEPON.AFT_EVENTO_CCD
AFTER UPDATE ON SEPON.EVENTO FOR EACH ROW
BEGIN

   --EVENTO_CONTRATO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.EVENTO_CONTRATO SET EVENTO_SEQ = :NEW.SEQ WHERE EVENTO_SEQ = :OLD.SEQ;
   END IF;

   --EVENTO_GRATUIDADE
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.EVENTO_GRATUIDADE SET EVENTO_SEQ = :NEW.SEQ WHERE EVENTO_SEQ = :OLD.SEQ;
   END IF;

   --FORMA_ACESSO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.FORMA_ACESSO SET EVENTO_SEQ = :NEW.SEQ WHERE EVENTO_SEQ = :OLD.SEQ;
   END IF;

   --PARTICIPANTE
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.PARTICIPANTE SET EVENTO_SEQ = :NEW.SEQ WHERE EVENTO_SEQ = :OLD.SEQ;
   END IF;

   --SLIDE
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.SLIDE SET EVENTO_SEQ = :NEW.SEQ WHERE EVENTO_SEQ = :OLD.SEQ;
   END IF;

   --VIDEO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.VIDEO SET EVENTO_SEQ = :NEW.SEQ WHERE EVENTO_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SEPON.AFT_LINK_CCD
AFTER UPDATE ON SEPON.LINK FOR EACH ROW
BEGIN

   --CONEXAO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.CONEXAO SET LINK_SEQ = :NEW.SEQ WHERE LINK_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SEPON.AFT_TIPO_ACESSO_CCD
AFTER UPDATE ON SEPON.TIPO_ACESSO FOR EACH ROW
BEGIN

   --FORMA_ACESSO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.FORMA_ACESSO SET TIPO_ACESSO_SEQ = :NEW.SEQ WHERE TIPO_ACESSO_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SEPON.AFT_USUARIO_CCD
AFTER UPDATE ON SEPON.USUARIO FOR EACH ROW
BEGIN

   --CONEXAO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.CONEXAO SET USUARIO_SEQ = :NEW.SEQ WHERE USUARIO_SEQ = :OLD.SEQ;
   END IF;

   --EVENTO_CONTRATO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.EVENTO_CONTRATO SET USUARIO_SEQ = :NEW.SEQ WHERE USUARIO_SEQ = :OLD.SEQ;
   END IF;

   --EVENTO_GRATUIDADE
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.EVENTO_GRATUIDADE SET USUARIO_SEQ = :NEW.SEQ WHERE USUARIO_SEQ = :OLD.SEQ;
   END IF;

   --PARTICIPANTE
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.PARTICIPANTE SET USUARIO_SEQ = :NEW.SEQ WHERE USUARIO_SEQ = :OLD.SEQ;
   END IF;

   --VIDEO_ASSIST
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.VIDEO_ASSIST SET USUARIO_SEQ = :NEW.SEQ WHERE USUARIO_SEQ = :OLD.SEQ;
   END IF;

   --BOLETO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.BOLETO SET CONFIRM_OPER_SEQ = :NEW.SEQ WHERE CONFIRM_OPER_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER SEPON.AFT_VIDEO_CCD
AFTER UPDATE ON SEPON.VIDEO FOR EACH ROW
BEGIN

   --VIDEO_ASSIST
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE SEPON.VIDEO_ASSIST SET VIDEO_SEQ = :NEW.SEQ WHERE VIDEO_SEQ = :OLD.SEQ;
   END IF;

END;
/

/* **********************************************************************************
   OUTROS CÓDIGOS E VISÕES EM GERAL
*/

-- OBJETO 10 | INDEX | IDX_CPF_REST
CREATE UNIQUE INDEX "IDX_CPF_REST" ON "SEPON"."USUARIO" ("CPF")
/

-- OBJETO 11 | INDEX | IDX_LOGIN_REST
CREATE UNIQUE INDEX "IDX_LOGIN_REST" ON "SEPON"."USUARIO" ("LOGIN")
/

-- OBJETO 100 | TRIGGER | AFT_CONEXAO_VAL
create or replace TRIGGER SEPON.AFT_CONEXAO_VAL AFTER INSERT OR UPDATE OR DELETE ON SEPON.CONEXAO FOR EACH ROW
DECLARE
   PROXSEQ NUMBER;
   DURACAO NUMBER;
BEGIN
   -- ATUALIZA QTD DE CONEXOES EM LINKS
   IF DELETING THEN
       UPDATE SEPON."LINK" SET NR_CONN_ATUAL = NVL(NR_CONN_ATUAL,0) - 1 WHERE SEQ = :OLD.LINK_SEQ;
       -- REGISTRA ASSIST
       IF NVL(:OLD.VIDEO_SEQ,0)<>0 THEN
           SELECT NVL(MAX(SEQ),0)+1 INTO PROXSEQ FROM SEPON.VIDEO_ASSIST WHERE VIDEO_SEQ = :OLD.VIDEO_SEQ;
    DURACAO := TRUNC( (SYSDATE-:OLD.MOMENTO_ENTRADA)*1440,4);
           INSERT INTO SEPON.VIDEO_ASSIST (VIDEO_SEQ, SEQ, MOMENTO, USUARIO_SEQ, DURACAO_MIN, NAVEGADOR) VALUES(:OLD.VIDEO_SEQ, PROXSEQ, SYSDATE, :OLD.USUARIO_SEQ, DURACAO, :OLD.NAVEGADOR);
       END IF;
   ELSIF INSERTING THEN
       UPDATE SEPON."LINK" SET NR_CONN_ATUAL = NVL(NR_CONN_ATUAL,0) + 1 WHERE SEQ = :NEW.LINK_SEQ;
   ELSE
       IF :OLD.LINK_SEQ <> :NEW.LINK_SEQ THEN
          UPDATE SEPON."LINK" SET NR_CONN_ATUAL = NVL(NR_CONN_ATUAL,0) - 1 WHERE SEQ = :OLD.LINK_SEQ;
          UPDATE SEPON."LINK" SET NR_CONN_ATUAL = NVL(NR_CONN_ATUAL,0) + 1 WHERE SEQ = :NEW.LINK_SEQ;
       END IF;
   END IF;
END;
/

-- OBJETO 101 | TRIGGER | AFT_SYS_CONFIG_GLOBAL
create or replace TRIGGER SEPON.AFT_SYS_CONFIG_GLOBAL AFTER INSERT OR UPDATE OR DELETE ON SEPON."SYS_CONFIG_GLOBAL" FOR EACH ROW
DECLARE
BEGIN
   IF DELETING OR UPDATING THEN
      IF :OLD.PARAM = 'SEPON_CONEXAO_INTERV_VER_MINS' OR :OLD.PARAM = 'SEPON_CONEXAO_MAX_MINS_SEM_CONFIRM' THEN
          SEPON.PALESTRA.REMOVE_JOB();
      END IF;
   END IF;

   IF INSERTING OR UPDATING THEN
      IF :NEW.PARAM = 'SEPON_CONEXAO_INTERV_VER_MINS' OR :NEW.PARAM = 'SEPON_CONEXAO_MAX_MINS_SEM_CONFIRM' THEN
         SEPON.PALESTRA.CRIA_JOB(TO_NUMBER(NVL(:NEW.CONFIG,'0')));
      END IF;
   END IF;
END;
/

-- OBJETO 102 | TRIGGER | BEF_CONEXAO_VAL
create or replace TRIGGER SEPON.BEF_CONEXAO_VAL BEFORE INSERT OR UPDATE on SEPON.CONEXAO FOR EACH ROW
BEGIN
   -- GARANTE DATA DO SERVIDOR CASO NULO SEJA PASSADO
   IF NVL(:NEW.SEQ,0) = 0 THEN
      SELECT NVL( MAX(SEQ),0) + 1 INTO :NEW.SEQ FROM SEPON.CONEXAO;
   END IF;
   IF :NEW.MOMENTO_CONFIRM IS NULL THEN
       :NEW.MOMENTO_CONFIRM := SYSDATE;
   END IF;
   IF :NEW.MOMENTO_ENTRADA IS NULL THEN
       :NEW.MOMENTO_ENTRADA := SYSDATE;
   END IF;
END;
/

-- OBJETO 103 | TRIGGER | BEF_LOG_VAL
create or replace TRIGGER SEPON.BEF_LOG_VAL BEFORE INSERT OR UPDATE ON SEPON."LOG" FOR EACH ROW
BEGIN
   -- AUTOSEQ PARA EVITAR ERROS
   IF NVL(:NEW.SEQ,0) = 0 THEN
      SELECT NVL(MAX(SEQ),0) + 1 INTO :NEW.SEQ FROM SEPON.LOG;
   END IF;
   -- GARANTE ENTRADA DE SYSDATE CASO NULO SEJA PASSADO
   IF :NEW.MOMENTO IS NULL THEN
      :NEW.MOMENTO := SYSDATE;
   END IF;
END;
/

-- OBJETO 104 | FUNCTION | CONEXAO_VAL
create or replace FUNCTION       CONEXAO_VAL
    (
      pUSUARIO_SEQ  NUMBER,
      pUSUARIO_NOME VARCHAR2,
      pIP_CLIENTE   VARCHAR2,
      pLINK_SEQ     NUMBER,
      pIP_SERVIDOR CLOB,
      pNAVEGADOR VARCHAR2,
      pMOMENTO_CONFIRM DATE,
      pSLIDE_VISUALIZADO NUMBER,
      pMOMENTO_ENTRADA DATE )
    RETURN NUMBER
  IS
    MAXSEQ NUMBER;
  BEGIN
     SELECT NVL(MAX(SEQ),0) + 1 INTO MAXSEQ FROM SEPON.CONEXAO;
     INSERT
       INTO SEPON.CONEXAO
      (
        SEQ              ,
        USUARIO_SEQ      ,
        USUARIO_NOME     ,
        IP_CLIENTE       ,
        LINK_SEQ         ,
        IP_SERVIDOR      ,
        NAVEGADOR        ,
        MOMENTO_CONFIRM  ,
        SLIDE_VISUALIZADO,
        MOMENTO_ENTRADA
      )
      VALUES
      (
        MAXSEQ            ,
        pUSUARIO_SEQ      ,
        pUSUARIO_NOME     ,
        pIP_CLIENTE       ,
        pLINK_SEQ         ,
        pIP_SERVIDOR      ,
        pNAVEGADOR        ,
        pMOMENTO_CONFIRM  ,
        pSLIDE_VISUALIZADO,
        pMOMENTO_ENTRADA
      );
    RETURN MAXSEQ;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
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

-- OBJETO 201 | PACKAGE | PALESTRA
create or replace PACKAGE       PALESTRA IS
  PROCEDURE ATUALIZA;
  PROCEDURE ATUALIZA_LINK;
  PROCEDURE VALIDA_CONN;
  PROCEDURE CRIA_JOB(MINS IN NUMBER DEFAULT 0);
  PROCEDURE REMOVE_JOB;
 FUNCTION  MINS_ASSIST(VVIDEO FLOAT, VUSUARIO FLOAT) RETURN FLOAT;
END;
/

create or replace PACKAGE BODY       PALESTRA AS
--------------------------------------------------------------------------------
-- Encarregade de disparar as procedures informadas
--------------------------------------------------------------------------------
  PROCEDURE ATUALIZA AS
  BEGIN
    VALIDA_CONN;
    ATUALIZA_LINK;
    CRIA_JOB;
  END;
--------------------------------------------------------------------------------
-- Atualiza o campo de quantidade de conexoes
--------------------------------------------------------------------------------
  PROCEDURE ATUALIZA_LINK AS
    QTD INTEGER;
  BEGIN
    FOR CUR IN (SELECT SEQ FROM SEPON.LINK) LOOP
      QTD := 0;
      SELECT COUNT(*) INTO QTD FROM SEPON.CONEXAO WHERE LINK_SEQ = CUR.SEQ;
      UPDATE SEPON.LINK SET NR_CONN_ATUAL = QTD WHERE SEQ = CUR.SEQ;
    END LOOP;
  END;
--------------------------------------------------------------------------------
-- Limpa conexoes inativas ap¢s um determinado tempo
--------------------------------------------------------------------------------
  PROCEDURE VALIDA_CONN AS
    MINS VARCHAR2(10);
  BEGIN
    BEGIN
      SELECT NVL(CONFIG,'3') INTO MINS FROM SEPON.SYS_CONFIG_GLOBAL WHERE PARAM='SEPON_CONEXAO_MAX_MINS_SEM_CONFIRM';
    EXCEPTION
      WHEN OTHERS THEN
        MINS := '3';
    END;
    DELETE FROM SEPON.CONEXAO WHERE (SYSDATE - MOMENTO_CONFIRM)*1440 > TO_NUMBER(MINS,'999999.99');
  END;
--------------------------------------------------------------------------------
-- CRIA JOB CONFORME PARAMETRO EM SYS_CONFIG_GLOBAL
--------------------------------------------------------------------------------
  PROCEDURE CRIA_JOB(MINS IN NUMBER DEFAULT 0) AS
     MINS2 VARCHAR2(10);
     JOBNUM NUMBER;
  BEGIN
     REMOVE_JOB;
     IF MINS = 0 THEN
         BEGIN
             SELECT NVL(CONFIG,'3') INTO MINS2 FROM SEPON.SYS_CONFIG_GLOBAL WHERE PARAM='SEPON_CONEXAO_INTERV_VER_MINS';
         EXCEPTION
             WHEN OTHERS THEN
                MINS2 := '3';
         END;
     ELSE
         MINS2 := TO_CHAR(MINS);
     END IF;
     DBMS_JOB.SUBMIT(JOBNUM,'/* SEPON CHECAGEM DE CONEXÕES */ BEGIN SEPON.PALESTRA.VALIDA_CONN;END;',SYSDATE,'SYSDATE + ' || MINS2 || '/1440');
  END;
--------------------------------------------------------------------------------
-- CRIA JOB CONFORME PARAMETRO EM SYS_CONFIG_GLOBAL
--------------------------------------------------------------------------------
  PROCEDURE REMOVE_JOB AS
  BEGIN
     FOR CUR IN (SELECT JOB FROM ALL_JOBS WHERE INSTR(WHAT,'/* SEPON CHECAGEM DE CONEXÕES */')<>0) LOOP
         DBMS_JOB.REMOVE(CUR.JOB);
     END LOOP;
  END;
--------------------------------------------------------------------------------
-- BUSCA TOTAL DE MINS VISUALIZADOS DE UM VÍDEO PARA USUÁRIO
--------------------------------------------------------------------------------
FUNCTION  MINS_ASSIST(VVIDEO FLOAT, VUSUARIO FLOAT) RETURN FLOAT AS
TOT1 NUMBER(10,2);
TOT2 NUMBER(10,2);
BEGIN
BEGIN
SELECT SUM(DURACAO_MIN) INTO TOT1 FROM SEPON.VIDEO_ASSIST WHERE VIDEO_SEQ=VVIDEO AND USUARIO_SEQ=VUSUARIO;
EXCEPTION
WHEN NO_DATA_FOUND THEN
TOT1 := 0;
END;
BEGIN
SELECT (SYSDATE-MOMENTO_ENTRADA)*1440 INTO TOT2 FROM SEPON.CONEXAO WHERE VIDEO_SEQ=VVIDEO AND USUARIO_SEQ=VUSUARIO;
EXCEPTION
WHEN NO_DATA_FOUND THEN
TOT2 := 0;
END;
RETURN TOT1 + TOT2;
END;
END PALESTRA;
/

-- OBJETO 300 | VISÃO | CHK_SEPON_SOCIO
CREATE OR REPLACE VIEW SEPON.CHK_SEPON_SOCIO AS SELECT seq, momento_inscr, idioma_pref, valido_ate, convidado, inscrito, operador ,MAT, CPF, CRM, EXCLUÍDO, OBRIG_STATUS_COD, CATEGORIA_COD, REGIONAL_COD,TIPO_END, ENDEREÇO_MALAD, BAIRRO_MALAD, CIDADE_MALAD, ESTADO_MALAD, PAÍS_MALAD, CEP_MALAD, DDI_MALAD, DDD_MALAD, TEL_MALAD, FAX_MALAD, TEL_CELULAR_MALAD, EMAIL_MALAD FROM
(SELECT MAT, CPF, CRM, EXCLUÍDO, OBRIG_STATUS_COD, CATEGORIA_COD, REGIONAL_COD, TIPO_END, ENDEREÇO_MALAD, BAIRRO_MALAD, CIDADE_MALAD, ESTADO_MALAD, PAÍS_MALAD, CEP_MALAD, DDI_MALAD, DDD_MALAD, TEL_MALAD, FAX_MALAD, TEL_CELULAR_MALAD, EMAIL_MALAD FROM SBDB.socio_endereco WHERE tipo_end = 'MALA') SC,
(SELECT seq, cpf as cpf_sbd, matr_sbd,  momento_inscr, idioma_pref, valido_ate, convidado, inscrito, operador FROM SEPON.usuario WHERE cpf is not null) SP
WHERE SC.CPF = SP.CPF_SBD AND EXCLUÍDO = 0 AND (SUBSTR(OBRIG_STATUS_COD,1,5) IN ('QUITE') OR SUBSTR(OBRIG_STATUS_COD,1,6) IN ('ISENTO'))
/

-- OBJETO 301 | VISÃO | REL_BOLETO
CREATE OR REPLACE VIEW SEPON.REL_BOLETO AS SELECT LPAD(B.SEQ, 6, '0') AS SEQ,
  B.NOSSO_NUM                     ,
  B.SACADO_CPF                    ,
  B.SACADO_NOME                   ,
  B.DATA_EMISSAO                  ,
  B.DATA_VENCIM                   ,
  B.DATA_PAGAM                    ,
  B.DATA_BAIXA                    ,
  B.CONFIRM_OPER_SEQ              ,
  U.LOGIN                         ,
  B.VALOR
   FROM SEPON.BOLETO B
LEFT OUTER JOIN SEPON.USUARIO U
     ON B.CONFIRM_OPER_SEQ = U.SEQ
ORDER BY B.SEQ
/

-- OBJETO 302 | VISÃO | SOCIO_VW
CREATE OR REPLACE VIEW SEPON.SOCIO_VW AS SELECT SC."MAT",SC."NOME",SC."CPF",SC."CRM",SC."EMAIL",SC."TEL_COMERCIAL",SC."TEL_RESIDENCIAL",SC."TEL_FAX",SC."CELULAR",SC."SENHA", SE.ENDEREÇO_MALAD,  SE.BAIRRO_MALAD,  SE.CIDADE_MALAD,  SE.ESTADO_MALAD,  SE.PAÍS_MALAD,  SE.CEP_MALAD FROM
(SELECT MAT,
  NOME,
  CPF,
  CRM_ESTADO || CRM AS CRM,
  TRIM(EMAIL_RESIDENCIAL) || DECODE(TRIM(EMAIL_RESIDENCIAL),NULL,'',';') || EMAIL_COMERCIAL_1 || DECODE(TRIM(EMAIL_COMERCIAL_2),NULL,'',';') || TRIM(EMAIL_COMERCIAL_2) AS EMAIL,
  DECODE(TRIM(DDD_COMERCIAL_1),NULL, SUBSTR(TEL_COMERCIAL_1,1,9), SUBSTR('(' ||DDD_COMERCIAL_1 ||') ' || TEL_COMERCIAL_1,1,14)) AS TEL_COMERCIAL,
  DECODE(TRIM(DDD_RESIDENCIAL),NULL, SUBSTR(TEL_RESIDENCIAL,1,9), SUBSTR('(' ||DDD_RESIDENCIAL ||') ' || TEL_RESIDENCIAL,1,14)) AS TEL_RESIDENCIAL,
  DECODE(TRIM(FAX_COMERCIAL_1),NULL, SUBSTR(FAX_COMERCIAL_1,1,9), SUBSTR('(' ||DDD_RESIDENCIAL ||') ' || FAX_COMERCIAL_1,1,14)) AS TEL_FAX,
  DECODE((TRIM(DDD_RESIDENCIAL)),NULL, SUBSTR(TEL_CELULAR_RESIDENCIAL,1,9), SUBSTR('('||DDD_RESIDENCIAL||')'||TEL_CELULAR_RESIDENCIAL,1,14)) AS CELULAR,
  SENHA
FROM SBDB.SÓCIO
WHERE CPF IS NOT NULL AND EXCLUÍDO = 0 AND (SUBSTR(OBRIG_STATUS_COD,1,5) IN ('QUITE') OR SUBSTR(OBRIG_STATUS_COD,1,6) IN ('ISENTO'))
) SC,
(SELECT MAT AS MATR,  TIPO_END,  ENDEREÇO_MALAD,  BAIRRO_MALAD,  CIDADE_MALAD,  ESTADO_MALAD,  PAÍS_MALAD,  CEP_MALAD FROM SBDB.SOCIO_ENDERECO) SE
WHERE SE.MATR (+) = SC.MAT  AND SE.TIPO_END = 'MALA'
/

-- OBJETO 303 | VISÃO | USUARIO_VW
CREATE OR REPLACE VIEW SEPON.USUARIO_VW AS SELECT
      /* PREENCHIMENTO OBRIGATÓRIO NA TABELA DE USUÁRIO */
      U.SEQ AS SEQ,
      U.MOMENTO_INSCR AS MOMENTO_INSCR,
      U.MATR_SBD AS MATR_SBD,
      U.IDIOMA_PREF AS IDIOMA_PREF,
      U.VALIDO_ATE AS VALIDO_ATE,
      U.CONVIDADO AS CONVIDADO,
      U.INSCRITO AS INSCRITO,
      U.OPERADOR AS OPERADOR,
      U.EMAIL AS EMAIL,
      /* CASO TENHA MATRÍCULA, OBTIDO AUTO NO CAD SÓCIO */
      DECODE(S.MAT, NULL, U.CPF, S.CPF) AS CPF,
      DECODE(S.MAT, NULL, U.CRM, S.CRM_ESTADO || S.CRM) AS CRM,
      DECODE(S.MAT, NULL, U.NOME, S.NOME) AS NOME,
      DECODE(S.MAT, NULL, U.LOGIN, S.CRM_ESTADO || S.CRM) AS LOGIN,
      DECODE(S.MAT, NULL, U.SENHA, S.SENHA) AS SENHA,
      DECODE(S.MAT, NULL, 'FALSE', 'TRUE') AS ASSOCIADO,
      DECODE(S.MAT, NULL, U.ENDERECO, DECODE(S.MALA_DIRETA, 'R', S.ENDEREÇO_RESIDENCIAL, '1', S.ENDEREÇO_COMERCIAL_1, 'R', S.ENDEREÇO_COMERCIAL_2)) AS ENDERECO,
      DECODE(S.MAT, NULL, U.NUMERO, DECODE(S.MALA_DIRETA, 'R', S.NUMERO_RESIDENCIAL, '1', S.NUMERO_COMERCIAL_1, 'R', S.NUMERO_COMERCIAL_2)) AS NUMERO,
      DECODE(S.MAT, NULL, U.COMPLEMENTO, DECODE(S.MALA_DIRETA, 'R', S.COMPLEMENTO_RESIDENCIAL, '1', S.COMPLEMENTO_COMERCIAL_1, 'R', S.COMPLEMENTO_COMERCIAL_2)) AS COMPLEMENTO,
      DECODE(S.MAT, NULL, U.BAIRRO, DECODE(S.MALA_DIRETA, 'R', S.BAIRRO_RESIDENCIAL, '1', S.BAIRRO_COMERCIAL_1, '2', S.BAIRRO_COMERCIAL_2)) AS BAIRRO,
      DECODE(S.MAT, NULL, U.CIDADE, DECODE(S.MALA_DIRETA, 'R', S.CIDADE_RESIDENCIAL, '1', S.CIDADE_COMERCIAL_1, '2', S.CIDADE_COMERCIAL_2)) AS CIDADE,
      DECODE(S.MAT, NULL, U.ESTADO, DECODE(S.MALA_DIRETA, 'R', S.ESTADO_RESIDENCIAL, '1', S.ESTADO_COMERCIAL_1, '2', S.ESTADO_COMERCIAL_2)) AS ESTADO,
      DECODE(S.MAT, NULL, U.CEP, DECODE(S.MALA_DIRETA, 'R', S.CEP_RESIDENCIAL, '1', S.CEP_COMERCIAL_1, '2', S.CEP_COMERCIAL_2)) AS CEP,
      DECODE(S.MAT, NULL, U.PAIS, DECODE(S.MALA_DIRETA, 'R', S.PAÍS_RESIDENCIAL, '1', S.PAÍS_COMERCIAL_1, '2', S.PAÍS_COMERCIAL_2)) AS PAIS,
      DECODE(S.MAT, NULL, U.TEL_RES, S.TEL_RESIDENCIAL) AS TEL_RES,
      DECODE(S.MAT, NULL, U.TEL_COM, S.TEL_COMERCIAL_1) AS TEL_COM,
      DECODE(S.MAT, NULL, U.TEL_CEL, S.TEL_CELULAR_RESIDENCIAL) AS TEL_CEL,
      DECODE(S.MAT, NULL, U.FAX, S.FAX_COMERCIAL_1) AS FAX,
      DECODE(S.MAT, NULL, U.CARGO, S.TRABALHO1_NOME) AS CARGO,
      DECODE(S.MAT, NULL, U.INSTITUICAO, S.TRABALHO1_CARGO) AS INSTITUICAO,
      DECODE(S.MAT, NULL, U.CANCEL, NULL) AS CANCEL
    FROM
      SEPON.USUARIO U,
      SBDB.SÓCIO S
    WHERE
      U.MATR_SBD = S.MAT (+)
    AND U.MATR_SBD NOT IN
      (SELECT MAT FROM SBDB.SÓCIO WHERE EXCLUÍDO = '-1' OR MAT = 0 OR PENALIZADO = 'S' AND(SUBSTR(OBRIG_STATUS_COD, 1, 5) NOT IN('QUITE') OR SUBSTR(OBRIG_STATUS_COD, 1, 6) NOT IN('ISENTO'))
      )
/

-- OBJETO 304 | VISÃO | LOG_TOTAL_POR_CATEGORIA
CREATE OR REPLACE VIEW SEPON.LOG_TOTAL_POR_CATEGORIA AS   SELECT VIDEO_SEQ    ,
  CONEXAO_SEQ       ,
  NOME        ,
  MATR_SBD         ,
  MIN(CONN) CONN    ,
  MAX("DESC") "DESC",
  COUNT(ERRO) ERRO
   FROM
  (SELECT VIDEO_SEQ,
    CONEXAO_SEQ   ,
    NOME    ,
    MATR_SBD     ,
    CASE
      WHEN CATEGORIA='CONN'
      OR CATEGORIA  = 'PRES'
      THEN MOMENTO
      ELSE NULL
    END CONN,
    CASE
      WHEN CATEGORIA='DESC'
      OR CATEGORIA  = 'PRES'
      THEN MOMENTO
      ELSE NULL
    END "DESC",
    CASE
      WHEN CATEGORIA='ERRO'
      THEN MOMENTO
      ELSE NULL
    END "ERRO"
     FROM SEPON.LOG
  )
GROUP BY VIDEO_SEQ,
  CONEXAO_SEQ    ,
  NOME     ,
  MATR_SBD
/

-- OBJETO 305 | VISÃO | LOG_TOTAL_POR_MAT
CREATE OR REPLACE VIEW SEPON.LOG_TOTAL_POR_MAT AS   SELECT VIDEO_SEQ,
  MATR_SBD     ,
  NOME    ,
  ROUND(SUM(
  CASE
    WHEN CONN IS NULL
    OR "DESC" IS NULL
    OR CONN    = "DESC"
    THEN 1      /1440
    ELSE ("DESC"-CONN)
  END)          *1440,2) DUR_TOTAL,
  SUM(ERRO) QTD_ERROS
   FROM SEPON.LOG_TOTAL_POR_CATEGORIA
GROUP BY VIDEO_SEQ,
  MATR_SBD      ,
  NOME
/

-- OBJETO 900 | CRIA_JOBS | JOB
----------------------------------------------------------------------------------------------------
-- CRIA OS JOBS DA BASE
----------------------------------------------------------------------------------------------------
EXEC LB.LCRIA_JOB_N('SEPON CHECAGEM DE CONEXÕES','SEPON.PALESTRA.VALIDA_CONN','00:00:00',1,1,'m');
----------------------------------------------------------------------------------------------------
-- RODA OS JOBS DA BASE
----------------------------------------------------------------------------------------------------
SET SERVEROUTPUT ON SIZE 40000
BEGIN
  FOR CUR IN
  (SELECT JOB, WHAT FROM USER_JOBS WHERE SCHEMA_USER='SEPON'
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
$ECHO - >>"C:\SEPON_PARTES.LOG"
$ECHO - >>"C:\SEPON_PARTES.LOG"
$ECHO - >>"C:\SEPON_PARTES.LOG"
$COMMAND /C ECHO %DATE% %TIME% >>"C:\SEPON_PARTES.LOG"
$COMMAND /C FIND "ORA-" "C:\SEPON_PARTE2.LOG" >>"C:\SEPON_PARTES.LOG"
$COMMAND /C FIND "SP2-" "C:\SEPON_PARTE2.LOG" >>"C:\SEPON_PARTES.LOG"
