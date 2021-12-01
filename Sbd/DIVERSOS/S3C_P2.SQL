SET ECHO ON
SPOOL C:\S3C_PARTE2.LOG
CONNECT S3C/XXXX@SBDB;

-- ELIMINA OS JOBS
begin
for cur in (select job from user_jobs where schema_user='S3C') loop
dbms_job.remove(cur.job);
end loop;
end;
/

-- CRIA ÍNDICES


/* **********************************************************************************
   CRIAÇÃO DE RELACIONAMENTOS
*/

ALTER TABLE S3C."USUARIO" ADD CONSTRAINT "TEMPLATE_USUARIO_01" FOREIGN KEY("TEMPLATE_SEQ") REFERENCES S3C."TEMPLATE"("SEQ");
ALTER TABLE S3C."USUARIO" ADD CONSTRAINT "TOPO_ANIM_USUARIO_01" FOREIGN KEY("TOPO_ANIM_SEQ") REFERENCES S3C."TOPO_ANIM"("SEQ");


/* **********************************************************************************
   CONSTRAINTS BASE EM CHECK
*/

/* **********************************************************************************
   CRIAÇÃO DE TRIGGERS PARA REGISTRO DE INCLUSÃO, ATUALIZAÇÃO E EXCLUSÃO
*/

CREATE OR REPLACE TRIGGER S3C.BEF_DNS_EXEC BEFORE UPDATE OR INSERT OR DELETE ON S3C.DNS_EXEC FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM S3C.SYS_DELETE WHERE TABELA = 'DNS_EXEC' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO S3C.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('DNS_EXEC', :OLD.SEQ, SYSDATE, USER, 'S3C');
         ELSE
            UPDATE S3C.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'S3C' WHERE TABELA = 'DNS_EXEC' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER S3C.BEF_SYS_CONFIG_GLOBAL BEFORE UPDATE OR INSERT OR DELETE ON S3C.SYS_CONFIG_GLOBAL FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM S3C.SYS_DELETE WHERE TABELA = 'SYS_CONFIG_GLOBAL' AND CHAVE || '' = :OLD.PARAM || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO S3C.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_CONFIG_GLOBAL', :OLD.PARAM, SYSDATE, USER, 'S3C');
         ELSE
            UPDATE S3C.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'S3C' WHERE TABELA = 'SYS_CONFIG_GLOBAL' AND CHAVE || ''= :OLD.PARAM || '';
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

CREATE OR REPLACE TRIGGER S3C.BEF_SYS_CONFIG_USUARIO BEFORE UPDATE OR INSERT OR DELETE ON S3C.SYS_CONFIG_USUARIO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM S3C.SYS_DELETE WHERE TABELA = 'SYS_CONFIG_USUARIO' AND CHAVE || '' = :OLD.USUARIO || :OLD.PARAM || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO S3C.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_CONFIG_USUARIO', :OLD.USUARIO || :OLD.PARAM, SYSDATE, USER, 'S3C');
         ELSE
            UPDATE S3C.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'S3C' WHERE TABELA = 'SYS_CONFIG_USUARIO' AND CHAVE || ''= :OLD.USUARIO || :OLD.PARAM || '';
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

CREATE OR REPLACE TRIGGER S3C.BEF_SYS_LOCALID BEFORE UPDATE OR INSERT OR DELETE ON S3C.SYS_LOCALID FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM S3C.SYS_DELETE WHERE TABELA = 'SYS_LOCALID' AND CHAVE || '' = :OLD.NOME || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO S3C.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_LOCALID', :OLD.NOME, SYSDATE, USER, 'S3C');
         ELSE
            UPDATE S3C.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'S3C' WHERE TABELA = 'SYS_LOCALID' AND CHAVE || ''= :OLD.NOME || '';
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

CREATE OR REPLACE TRIGGER S3C.BEF_SYS_OCORRENCIA BEFORE UPDATE OR INSERT OR DELETE ON S3C.SYS_OCORRENCIA FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM S3C.SYS_DELETE WHERE TABELA = 'SYS_OCORRENCIA' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO S3C.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('SYS_OCORRENCIA', :OLD.SEQ, SYSDATE, USER, 'S3C');
         ELSE
            UPDATE S3C.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'S3C' WHERE TABELA = 'SYS_OCORRENCIA' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER S3C.BEF_TEMPLATE BEFORE UPDATE OR INSERT OR DELETE ON S3C.TEMPLATE FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM S3C.SYS_DELETE WHERE TABELA = 'TEMPLATE' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO S3C.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('TEMPLATE', :OLD.SEQ, SYSDATE, USER, 'S3C');
         ELSE
            UPDATE S3C.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'S3C' WHERE TABELA = 'TEMPLATE' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER S3C.BEF_TOPO_ANIM BEFORE UPDATE OR INSERT OR DELETE ON S3C.TOPO_ANIM FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM S3C.SYS_DELETE WHERE TABELA = 'TOPO_ANIM' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO S3C.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('TOPO_ANIM', :OLD.SEQ, SYSDATE, USER, 'S3C');
         ELSE
            UPDATE S3C.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'S3C' WHERE TABELA = 'TOPO_ANIM' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER S3C.BEF_USUARIO BEFORE UPDATE OR INSERT OR DELETE ON S3C.USUARIO FOR EACH ROW
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
         SELECT COUNT(*) INTO TOT_DEL FROM S3C.SYS_DELETE WHERE TABELA = 'USUARIO' AND CHAVE || '' = :OLD.SEQ || '';
         IF TOT_DEL = 0 THEN
            INSERT INTO S3C.SYS_DELETE (TABELA,CHAVE,MOMENTO,USUARIO,LOCAL) VALUES ('USUARIO', :OLD.SEQ, SYSDATE, USER, 'S3C');
         ELSE
            UPDATE S3C.SYS_DELETE SET MOMENTO = SYSDATE, USUARIO = USER, LOCAL = 'S3C' WHERE TABELA = 'USUARIO' AND CHAVE || ''= :OLD.SEQ || '';
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

CREATE OR REPLACE TRIGGER S3C.AFT_TEMPLATE_CCD
AFTER UPDATE ON S3C.TEMPLATE FOR EACH ROW
BEGIN

   --USUARIO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE S3C.USUARIO SET TEMPLATE_SEQ = :NEW.SEQ WHERE TEMPLATE_SEQ = :OLD.SEQ;
   END IF;

END;
/

CREATE OR REPLACE TRIGGER S3C.AFT_TOPO_ANIM_CCD
AFTER UPDATE ON S3C.TOPO_ANIM FOR EACH ROW
BEGIN

   --USUARIO
   IF (:OLD.SEQ <> :NEW.SEQ) THEN
      UPDATE S3C.USUARIO SET TOPO_ANIM_SEQ = :NEW.SEQ WHERE TOPO_ANIM_SEQ = :OLD.SEQ;
   END IF;

END;
/

/* **********************************************************************************
   OUTROS CÓDIGOS E VISÕES EM GERAL
*/

-- OBJETO 1 | INDEX | IDX_HOST_COMPL
CREATE UNIQUE INDEX "IDX_HOST_COMPL" ON "S3C"."USUARIO" ("HOST_COMPL")
/

-- OBJETO 980 | VISÃO | VW_USUARIO_VALIDO
CREATE OR REPLACE VIEW S3C.VW_USUARIO_VALIDO AS SELECT USU.MATR_SBD,
  USU.SEQ           ,
  USU.CURRICULO     ,
  USU.ESPECIALIDADE ,
  USU.EQUIPE        ,
  USU.MIDIA         ,
  USU.CLINICA       ,
  USU.COMO_CHEGAR   ,
  USU.CONSULTA      ,
  USU.NOME_APRES    ,
  USU.FOTO_SITE     ,
  TEMPL.THEME       ,
  ANIM.COMPL        ,
  SOC.EMAIL         ,
  SOC.NOME          ,
  SOC.CATEGORIA_COD ,
  SOC.CNRM          ,
  USU.HOST_COMPL    ,
  USU.PUBLICAR      ,
  USU.CONSULTA_EMAIL,
  USU.MINI_CURRICULO
   FROM S3C.USUARIO USU,
  S3C.TEMPLATE TEMPL   ,
  S3C.TOPO_ANIM ANIM   ,
  SBDB.VW_LOGIN_EMAIL SOC
  WHERE USU.TEMPLATE_SEQ = TEMPL.SEQ (+)
AND USU.TOPO_ANIM_SEQ    = ANIM.SEQ (+)
AND USU.MATR_SBD         = SOC.MAT (+)
/

-- OBJETO 2001 | FUNCTION | DICT
create or replace TYPE     DICT_OBJ
AS
  OBJECT
  (
    CHAVE    VARCHAR2(70),
    CONTEUDO VARCHAR2(4000) )
/

create or replace TYPE     DICT_TBL
AS
  TABLE OF S3C.DICT_OBJ;
/

create or replace FUNCTION     DICT
  (
    LISTA VARCHAR2,
    DELIM VARCHAR2 := ';',
    ATRIB VARCHAR2 := ':' )
  RETURN DICT_TBL PIPELINED
                  IS
  POS PLS_INTEGER := 1;
  PROX PLS_INTEGER;
  TERMO VARCHAR2(4000);
  PAR DICT_OBJ := DICT_OBJ(NULL,NULL);
BEGIN
  WHILE POS<=LENGTH(LISTA)
  LOOP
    PROX    := INSTR(LISTA, DELIM, POS);
    IF PROX <> 0 THEN
      TERMO := SUBSTR(LISTA, POS, PROX-POS);
      POS   := PROX                   +1;
    ELSE
      TERMO := SUBSTR(LISTA, POS);
      POS   := LENGTH(LISTA)+1;
    END IF;
    PROX        := INSTR(TERMO, ATRIB);
    IF PROX     <>0 THEN
      PAR.CHAVE := SUBSTR(TERMO, 1, PROX-1);
    ELSE
      PAR.CHAVE := '';
    END IF;
    PAR.CONTEUDO := SUBSTR(TERMO, PROX+1);
    PIPE ROW(PAR);
  END LOOP;
END DICT;
/

-- OBJETO 2100 | VISÃO | VW_SOCIO_ATRIB_SELO
CREATE OR REPLACE VIEW S3C.VW_SOCIO_ATRIB_SELO AS SELECT ROWNUM SEQ,
  OB.*            ,
  P.CONTEUDO SELO
   FROM
  (SELECT CAT.COD CATEGORIA,
    CNRM.CONTEUDO CNRM     ,
    CAT.COD
    || '+'
    || CNRM.CONTEUDO GRUPO
     FROM SBDB.CATEGORIA CAT,
    (SELECT CHAVE           ,
      CONTEUDO
       FROM TABLE
      (SELECT DICT('0:SEM CNRM|1:COM CNRM','|') FROM DUAL
      )
    ) CNRM
  ) OB         ,
  (SELECT CHAVE,
    CONTEUDO
     FROM TABLE
    (SELECT DICT(CONFIG,'|')
       FROM S3C.SYS_CONFIG_GLOBAL
      WHERE PARAM = 'SOCIO_ATRIB_SELO'
    )
  ) P
  WHERE OB.GRUPO = P.CHAVE (+)
/

-- OBJETO 2101 | VISÃO | VW_CAT_SIT_PERMITIDAS
CREATE OR REPLACE VIEW S3C.VW_CAT_SIT_PERMITIDAS AS SELECT ROWNUM SEQ,
  OB."CATEGORIA",OB."CNRM",OB."STATUS_FIN",OB."GRUPO", P.CONTEUDO HABILITADO
   FROM
  (SELECT CAT.COD CATEGORIA,
    CNRM.CONTEUDO CNRM     ,
    OB.COD STATUS_FIN      ,
    CAT.COD
    || '+'
    || CNRM.CONTEUDO
    || '+'
    || OB.COD GRUPO
     FROM SBDB.CATEGORIA CAT,
    (SELECT CHAVE           ,
      CONTEUDO
       FROM TABLE
      (SELECT DICT('0:SEM CNRM|1:COM CNRM','|') FROM DUAL
      )
    ) CNRM,
    (SELECT OBRIG_STATUS_COD COD FROM SBDB.SÓCIO GROUP BY OBRIG_STATUS_COD
    ) OB
  ) OB, 
  
  (SELECT CHAVE,
    CONTEUDO
     FROM TABLE
    (SELECT DICT(CONFIG,'|')
       FROM S3C.SYS_CONFIG_GLOBAL
      WHERE PARAM = 'CAT_SIT_PERMITIDAS'
    )
  ) P
  WHERE OB.GRUPO = P.CHAVE (+)
/

-- OBJETO 2103 | VISÃO | VW_USU_DOM
CREATE OR REPLACE VIEW S3C.VW_USU_DOM AS SELECT U.SEQ     ,
  U.MINI_CURRICULO,
  U.CURRICULO     ,
  U.ESPECIALIDADE ,
  U.EQUIPE        ,
  U.MIDIA         ,
  U.CLINICA       ,
  U.COMO_CHEGAR   ,
  U.CONSULTA      ,
  U.NOME_APRES    ,
  U.FOTO_SITE     ,
  U.THEME         ,
  U.COMPL         ,
  U.EMAIL         ,
  U.CONSULTA_EMAIL,
  U.CATEGORIA_COD ,
  U.PUBLICAR      ,
  U.CNRM          ,
  U.HOST_COMPL    ,
  S.GRUPO         ,
  S.SELO        
  FROM S3C.VW_USUARIO_VALIDO U,
  S3C.VW_SOCIO_ATRIB_SELO S
  WHERE U.CATEGORIA_COD
  || '+'
  || DECODE(NVL(U.CNRM,0),0,'SEM CNRM','COM CNRM') = S.GRUPO (+)
/


/* **********************************************************************************
   CRIAÇÃO DE USUÁRIOS
*/

SPOOL OFF
$ECHO - >>"C:\S3C_PARTES.LOG"
$ECHO - >>"C:\S3C_PARTES.LOG"
$ECHO - >>"C:\S3C_PARTES.LOG"
$COMMAND /C ECHO %DATE% %TIME% >>"C:\S3C_PARTES.LOG"
$COMMAND /C FIND "ORA-" "C:\S3C_PARTE2.LOG" >>"C:\S3C_PARTES.LOG"
$COMMAND /C FIND "SP2-" "C:\S3C_PARTE2.LOG" >>"C:\S3C_PARTES.LOG"
