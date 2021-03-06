/* **********************************************************************************
   INTERCRAFT SOLUTIONS INFORM�TICA LTDA - 2008
   SCRIPT CRIADO EM 22/09/2011 02:42

   IMPORTANTE!!!
   * O SISTEMA LOGAR� SYSTEM PARA INICIAR A EXECU��O, LOGO, MUITO CUIDADO!
   * CASO O USU�RIO DO ESQUEMA J� EXISTA, ESTE SER� ELIMINADO, PORTANTO, TENHA A CERTEZA DAQUILO QUE EST� FAZENDO.
   * ARQUIVO C:\S3C.LOG REGISTRAR� O LOG DE EXECU��O, QUE DEVE SER VERIFICADO.
   * CASO BANCO POSSUA ACENTOS, PRECISAR� GARANTIR FORMATO ANSI ANTES DA EXECU��O. PARA ISSO, EDITE O CONTE�DO NO NOTEPAD E SALVE FAZENDO OP��O POR ESTE FORMATO.
*/

SET ECHO ON
SET HEADING OFF
SET PAGESIZE 0
SET LINES 10000
SET LINESIZE 10000
SET SERVEROUTPUT ON SIZE 40000
SPOOL C:\S3C_PARTE1.LOG

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
for cur in (select job from user_jobs where schema_user='S3C') loop
dbms_job.remove(cur.job);
end loop;
end;
/

-- INICIALIZANDO TABLESPACE
ALTER TABLESPACE T_S3C_DAT OFFLINE;
DROP TABLESPACE T_S3C_DAT INCLUDING CONTENTS;
CREATE TABLESPACE T_S3C_DAT DATAFILE 'C:\oracle\product\10.2.0\oradata\SBDB\S3C.DBF' SIZE 100M REUSE
AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL;

-- DEFININDO USU�RIO DE ESQUEMA
DROP USER S3C CASCADE;
CREATE USER S3C IDENTIFIED BY XXXXXX DEFAULT TABLESPACE T_S3C_DAT;
GRANT DBA TO S3C;
GRANT SELECT ON DBA_JOBS TO S3C;
GRANT ALL PRIVILEGES TO S3C;

-- CONECTANDO COM USU�RIO DE ESQUEMA
DISCONNECT;
CONNECT S3C/XXXX@SBDB;

/* **********************************************************************************
   CRIA��O DE TABELAS
*/

-- TABELA DNS_EXEC
CREATE TABLE S3C."DNS_EXEC" (
   "SEQ" NUMBER (11,0),
   "DNS_COMANDO" VARCHAR2 (200),
   "DNS_MOMENTO" DATE,
   "DNS_RESULT" CLOB,
   "HEADER_COMANDO" VARCHAR2 (200),
   "HEADER_MOMENTO" DATE,
   "HEADER_RESULT" CLOB
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE S3C."DNS_EXEC" ADD CONSTRAINT "ID_DNS_EXEC"
PRIMARY KEY("SEQ");

COMMENT ON TABLE S3C."DNS_EXEC" IS 'GERAL | Execu��es de DNS. | Comandos no DNS';

COMMENT ON COLUMN S3C."DNS_EXEC"."SEQ" IS 'Sequencial sendo tratado pelo servidor sempre o menor primeiro. | Sequencial';
COMMENT ON COLUMN S3C."DNS_EXEC"."DNS_COMANDO" IS 'Comando DNS que ser� executado. | Comando DNS';
COMMENT ON COLUMN S3C."DNS_EXEC"."DNS_MOMENTO" IS 'Momento de execu��o. | Momento DNS';
COMMENT ON COLUMN S3C."DNS_EXEC"."DNS_RESULT" IS 'Resultado da execu��o. | Resultado DNS';
COMMENT ON COLUMN S3C."DNS_EXEC"."HEADER_COMANDO" IS 'Comando a ser tratado pelo cscript adsutil. | Comando Header';
COMMENT ON COLUMN S3C."DNS_EXEC"."HEADER_MOMENTO" IS 'Momento de inscri��o do header no IIS. | Momento Header';
COMMENT ON COLUMN S3C."DNS_EXEC"."HEADER_RESULT" IS 'Resultado da tentativa de inscri��o do header. | Resultado Header';
COMMENT ON COLUMN S3C."DNS_EXEC".SYS_MOMENTO_CRIA IS 'Registra momento de grava��o. | Momento de Cria��o';
COMMENT ON COLUMN S3C."DNS_EXEC".SYS_USUARIO_CRIA IS 'Registra usu�rio que gravou. | Usu�rio que Criou';
COMMENT ON COLUMN S3C."DNS_EXEC".SYS_LOCAL_CRIA IS 'Registra local de grava��o. | Local de Cria��o';
COMMENT ON COLUMN S3C."DNS_EXEC".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualiza��o. | Momento de Atualiza��o';
COMMENT ON COLUMN S3C."DNS_EXEC".SYS_USUARIO_ATUALIZA IS 'Registra usu�rio que atualizou. | Usu�rio que Alterou';
COMMENT ON COLUMN S3C."DNS_EXEC".SYS_LOCAL_ATUALIZA IS 'Registra local de atualiza��o. | Local de Altera��o';
COMMENT ON COLUMN S3C."DNS_EXEC".SYS_STATUS IS 'Status do registro entre I=Inclu�do, A=Alterado ou Vazio=Sem modifica��o. | Status do Registro';

-- TABELA SYS_CONFIG_GLOBAL
CREATE TABLE S3C."SYS_CONFIG_GLOBAL" (
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

ALTER TABLE S3C."SYS_CONFIG_GLOBAL" ADD CONSTRAINT "ID_SYS_CONFIG_GLOBAL"
PRIMARY KEY("PARAM");

COMMENT ON TABLE S3C."SYS_CONFIG_GLOBAL" IS 'Sistema | Armazena par�metros globais do aplicativo. | Configura��o Global';

COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL"."PARAM" IS 'Parametro. | Par�metro';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL"."DESCR" IS 'Descri��o. | Descri��o';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL"."CONFIG" IS 'Configura��o. | Configura��o';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL"."PROP_EXTEND" IS 'Propriedades extendidas para configura��o. | Propriedades';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL"."FORMATO" IS 'Formato de apresenta��o do campo MEMO, HTML ou vazio para texto comum. | Formato';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL".SYS_MOMENTO_CRIA IS 'Registra momento de grava��o. | Momento de Cria��o';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL".SYS_USUARIO_CRIA IS 'Registra usu�rio que gravou. | Usu�rio que Criou';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL".SYS_LOCAL_CRIA IS 'Registra local de grava��o. | Local de Cria��o';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualiza��o. | Momento de Atualiza��o';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL".SYS_USUARIO_ATUALIZA IS 'Registra usu�rio que atualizou. | Usu�rio que Alterou';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL".SYS_LOCAL_ATUALIZA IS 'Registra local de atualiza��o. | Local de Altera��o';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL".SYS_STATUS IS 'Status do registro entre I=Inclu�do, A=Alterado ou Vazio=Sem modifica��o. | Status do Registro';

-- TABELA SYS_CONFIG_USUARIO
CREATE TABLE S3C."SYS_CONFIG_USUARIO" (
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

ALTER TABLE S3C."SYS_CONFIG_USUARIO" ADD CONSTRAINT "ID_SYS_CONFIG_USUARIO"
PRIMARY KEY("USUARIO", "PARAM");

COMMENT ON TABLE S3C."SYS_CONFIG_USUARIO" IS 'Sistema | Par�metros espec�ficos de usu�rios do sistema. | Configura��o de Usu�rio';

COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO"."USUARIO" IS 'Usu�rio. | Usu�rio';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO"."PARAM" IS 'Parametro. | Par�metro';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO"."DESCR" IS 'Descri��o. | Descri��o';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO"."CONFIG" IS 'Configura��o. | Configura��o';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO".SYS_MOMENTO_CRIA IS 'Registra momento de grava��o. | Momento de Cria��o';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO".SYS_USUARIO_CRIA IS 'Registra usu�rio que gravou. | Usu�rio que Criou';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO".SYS_LOCAL_CRIA IS 'Registra local de grava��o. | Local de Cria��o';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualiza��o. | Momento de Atualiza��o';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO".SYS_USUARIO_ATUALIZA IS 'Registra usu�rio que atualizou. | Usu�rio que Alterou';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualiza��o. | Local de Altera��o';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO".SYS_STATUS IS 'Status do registro entre I=Inclu�do, A=Alterado ou Vazio=Sem modifica��o. | Status do Registro';

-- TABELA SYS_DELETE
CREATE TABLE S3C."SYS_DELETE" (
   "TABELA" VARCHAR2 (70),
   "CHAVE" VARCHAR2 (300),
   "MOMENTO" DATE,
   "USUARIO" VARCHAR2 (100),
   "LOCAL" VARCHAR2 (20)
);

ALTER TABLE S3C."SYS_DELETE" ADD CONSTRAINT "ID_SYS_DELETE"
PRIMARY KEY("TABELA", "CHAVE");

COMMENT ON TABLE S3C."SYS_DELETE" IS 'Sistema | Registro de exclus�es do sistema. | Registro de Exclus�es';

COMMENT ON COLUMN S3C."SYS_DELETE"."TABELA" IS 'Nome da tabela onde a exclus�o ocorreu. | Tabela';
COMMENT ON COLUMN S3C."SYS_DELETE"."CHAVE" IS 'Conte�do da chave do registro exclu�do. | Chave';
COMMENT ON COLUMN S3C."SYS_DELETE"."MOMENTO" IS 'Momento em que ocorreu a exclus�o. | Momento de Exclus�o';
COMMENT ON COLUMN S3C."SYS_DELETE"."USUARIO" IS 'Detalhes do usu�rio que efetuou a exclus�o. | Usu�rio';
COMMENT ON COLUMN S3C."SYS_DELETE"."LOCAL" IS 'De onde partiu a exclus�o. | Local';

-- TABELA SYS_LOCALID
CREATE TABLE S3C."SYS_LOCALID" (
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

ALTER TABLE S3C."SYS_LOCALID" ADD CONSTRAINT "ID_SYS_LOCALID"
PRIMARY KEY("NOME");

COMMENT ON TABLE S3C."SYS_LOCALID" IS 'Sistema | Especifica��es de localidade para sistema distribu�do. | Detalhes de Localidade';

COMMENT ON COLUMN S3C."SYS_LOCALID"."NOME" IS 'Nome em caso de sistema distribu�do. | Nome';
COMMENT ON COLUMN S3C."SYS_LOCALID"."CORRENTE" IS 'Marcado caso seja localidade corrente. | Corrente';
COMMENT ON COLUMN S3C."SYS_LOCALID"."PACOTE" IS 'N�mero do �ltimo pacote gerado. | Pacote Gerado';
COMMENT ON COLUMN S3C."SYS_LOCALID"."PACOTE_REC" IS 'N�mero do �ltimo pacote recebido. | Pacote Recebido';
COMMENT ON COLUMN S3C."SYS_LOCALID"."MOMENTO" IS 'Momento do �ltimo pacote gerado. | Momento de Gera��o';
COMMENT ON COLUMN S3C."SYS_LOCALID"."MOMENTO_REC" IS 'Momento do �ltimo pacote recebido. | Momento de Recebimento';
COMMENT ON COLUMN S3C."SYS_LOCALID"."MODELO" IS 'Modelo. | Modelo';
COMMENT ON COLUMN S3C."SYS_LOCALID"."DESCR" IS 'Descri��o de localidade, responsabilidade ou qualquer texto que informe sobre a localidade. | Descri��o';
COMMENT ON COLUMN S3C."SYS_LOCALID"."OBS" IS 'Observa��es sobre a localidade. | Observa��es';
COMMENT ON COLUMN S3C."SYS_LOCALID".SYS_MOMENTO_CRIA IS 'Registra momento de grava��o. | Momento de Cria��o';
COMMENT ON COLUMN S3C."SYS_LOCALID".SYS_USUARIO_CRIA IS 'Registra usu�rio que gravou. | Usu�rio que Criou';
COMMENT ON COLUMN S3C."SYS_LOCALID".SYS_LOCAL_CRIA IS 'Registra local de grava��o. | Local de Cria��o';
COMMENT ON COLUMN S3C."SYS_LOCALID".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualiza��o. | Momento de Atualiza��o';
COMMENT ON COLUMN S3C."SYS_LOCALID".SYS_USUARIO_ATUALIZA IS 'Registra usu�rio que atualizou. | Usu�rio que Alterou';
COMMENT ON COLUMN S3C."SYS_LOCALID".SYS_LOCAL_ATUALIZA IS 'Registra local de atualiza��o. | Local de Altera��o';
COMMENT ON COLUMN S3C."SYS_LOCALID".SYS_STATUS IS 'Status do registro entre I=Inclu�do, A=Alterado ou Vazio=Sem modifica��o. | Status do Registro';

-- TABELA SYS_OCORRENCIA
CREATE TABLE S3C."SYS_OCORRENCIA" (
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

ALTER TABLE S3C."SYS_OCORRENCIA" ADD CONSTRAINT "ID_SYS_OCORRENCIA"
PRIMARY KEY("SEQ");

COMMENT ON TABLE S3C."SYS_OCORRENCIA" IS 'Sistema | Registro de ocorr�ncias do sistema. | Registro de Ocorr�ncias';

COMMENT ON COLUMN S3C."SYS_OCORRENCIA"."SEQ" IS 'Sequencial da ocorr�ncia. | Sequencial';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA"."APLICACAO" IS 'Nome do aplicativo onde ocorreu o registro. | Aplica��o';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA"."OCORRENCIA" IS 'Detalhes da ocorr�ncia. | Ocorr�ncia';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA"."USUARIO" IS 'Usu�rio logado no momento da ocorr�ncia. | Usu�rio';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA"."MOMENTO" IS 'Momento em que ocorreu a situa��o. | Momento';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA"."LOCAL" IS 'Local onde ocorreu o registro. | Localidade';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA".SYS_MOMENTO_CRIA IS 'Registra momento de grava��o. | Momento de Cria��o';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA".SYS_USUARIO_CRIA IS 'Registra usu�rio que gravou. | Usu�rio que Criou';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA".SYS_LOCAL_CRIA IS 'Registra local de grava��o. | Local de Cria��o';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualiza��o. | Momento de Atualiza��o';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA".SYS_USUARIO_ATUALIZA IS 'Registra usu�rio que atualizou. | Usu�rio que Alterou';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualiza��o. | Local de Altera��o';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA".SYS_STATUS IS 'Status do registro entre I=Inclu�do, A=Alterado ou Vazio=Sem modifica��o. | Status do Registro';

-- TABELA TEMPLATE
CREATE TABLE S3C."TEMPLATE" (
   "SEQ" NUMBER (11,0),
   "TEMPLATE" VARCHAR2 (100),
   "THEME" VARCHAR2 (30)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE S3C."TEMPLATE" ADD CONSTRAINT "ID_TEMPLATE"
PRIMARY KEY("SEQ");

COMMENT ON TABLE S3C."TEMPLATE" IS 'GERAL | Templates de sites. | Op��es de Site';

COMMENT ON COLUMN S3C."TEMPLATE"."SEQ" IS 'Sequencial da template. | Sequencial';
COMMENT ON COLUMN S3C."TEMPLATE"."TEMPLATE" IS 'Nome de apresenta��o para escolha pelo associado. | Nome do Tipo de Site';
COMMENT ON COLUMN S3C."TEMPLATE"."THEME" IS 'Tema programado para esta template. | Tema';
COMMENT ON COLUMN S3C."TEMPLATE".SYS_MOMENTO_CRIA IS 'Registra momento de grava��o. | Momento de Cria��o';
COMMENT ON COLUMN S3C."TEMPLATE".SYS_USUARIO_CRIA IS 'Registra usu�rio que gravou. | Usu�rio que Criou';
COMMENT ON COLUMN S3C."TEMPLATE".SYS_LOCAL_CRIA IS 'Registra local de grava��o. | Local de Cria��o';
COMMENT ON COLUMN S3C."TEMPLATE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualiza��o. | Momento de Atualiza��o';
COMMENT ON COLUMN S3C."TEMPLATE".SYS_USUARIO_ATUALIZA IS 'Registra usu�rio que atualizou. | Usu�rio que Alterou';
COMMENT ON COLUMN S3C."TEMPLATE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualiza��o. | Local de Altera��o';
COMMENT ON COLUMN S3C."TEMPLATE".SYS_STATUS IS 'Status do registro entre I=Inclu�do, A=Alterado ou Vazio=Sem modifica��o. | Status do Registro';

-- TABELA TOPO_ANIM
CREATE TABLE S3C."TOPO_ANIM" (
   "SEQ" NUMBER (11,0),
   "ANIMACAO" VARCHAR2 (100),
   "COMPL" VARCHAR2 (30)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE S3C."TOPO_ANIM" ADD CONSTRAINT "ID_TOPO_ANIM"
PRIMARY KEY("SEQ");

COMMENT ON TABLE S3C."TOPO_ANIM" IS 'GERAL | Anima��es de topo. | Anima��o de Topo';

COMMENT ON COLUMN S3C."TOPO_ANIM"."SEQ" IS 'Sequencial da template. | Sequencial';
COMMENT ON COLUMN S3C."TOPO_ANIM"."ANIMACAO" IS 'Nome de apresenta��o para escolha pelo associado. | T�tulo da Anima��o';
COMMENT ON COLUMN S3C."TOPO_ANIM"."COMPL" IS 'Aponta para diret�rio onde foram salvas as imagens: App_Themes\Tema\Img\Head\Complemento\Imagens... | Complemento de Diret�rio';
COMMENT ON COLUMN S3C."TOPO_ANIM".SYS_MOMENTO_CRIA IS 'Registra momento de grava��o. | Momento de Cria��o';
COMMENT ON COLUMN S3C."TOPO_ANIM".SYS_USUARIO_CRIA IS 'Registra usu�rio que gravou. | Usu�rio que Criou';
COMMENT ON COLUMN S3C."TOPO_ANIM".SYS_LOCAL_CRIA IS 'Registra local de grava��o. | Local de Cria��o';
COMMENT ON COLUMN S3C."TOPO_ANIM".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualiza��o. | Momento de Atualiza��o';
COMMENT ON COLUMN S3C."TOPO_ANIM".SYS_USUARIO_ATUALIZA IS 'Registra usu�rio que atualizou. | Usu�rio que Alterou';
COMMENT ON COLUMN S3C."TOPO_ANIM".SYS_LOCAL_ATUALIZA IS 'Registra local de atualiza��o. | Local de Altera��o';
COMMENT ON COLUMN S3C."TOPO_ANIM".SYS_STATUS IS 'Status do registro entre I=Inclu�do, A=Alterado ou Vazio=Sem modifica��o. | Status do Registro';

-- TABELA USUARIO
CREATE TABLE S3C."USUARIO" (
   "SEQ" NUMBER (11,0),
   "MATR_SBD" NUMBER (11,0),
   "NOME_APRES" VARCHAR2 (200),
   "HOST_COMPL" VARCHAR2 (100),
   "TEMPLATE_SEQ" NUMBER (11,0),
   "PUBLICAR" NUMBER (1,0),
   "FOTO_SITE" VARCHAR2 (200),
   "MINI_CURRICULO" CLOB,
   "CURRICULO" CLOB,
   "ESPECIALIDADE" CLOB,
   "EQUIPE" CLOB,
   "MIDIA" CLOB,
   "CLINICA" CLOB,
   "COMO_CHEGAR" CLOB,
   "CONSULTA" CLOB,
   "TOPO_ANIM_SEQ" NUMBER (11,0),
   "CONSULTA_EMAIL" VARCHAR2 (200)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE S3C."USUARIO" ADD CONSTRAINT "ID_USUARIO"
PRIMARY KEY("SEQ");

COMMENT ON TABLE S3C."USUARIO" IS 'GERAL | Lista de usu�rios. | Usu�rios';

COMMENT ON COLUMN S3C."USUARIO"."SEQ" IS 'Sequencial de registro no S3C. | Sequencial';
COMMENT ON COLUMN S3C."USUARIO"."MATR_SBD" IS 'Associado da SBD. | Matr�cula';
COMMENT ON COLUMN S3C."USUARIO"."NOME_APRES" IS 'Nome de apresenta��o no site com pronome de tratamento, mai�sculas e min�sculas e tudo mais.Aparece na p�gina inicial. | Nome de Apresenta��o';
COMMENT ON COLUMN S3C."USUARIO"."HOST_COMPL" IS 'Complemento de host sendo xxxxx do formato: www.xxxxx.dermatosbd.org.br. Por exemplo, para www.joao.dermatosbd.org.br, utilize apenas joao neste campo. | Nome de Dom�nio';
COMMENT ON COLUMN S3C."USUARIO"."TEMPLATE_SEQ" IS 'Layout escolhido varia��o espec�fica de cores. | Template';
COMMENT ON COLUMN S3C."USUARIO"."PUBLICAR" IS 'Publica��o do site ativada ou n�o. | Pode Publicar?';
COMMENT ON COLUMN S3C."USUARIO"."FOTO_SITE" IS 'Arquivo contendo a foto do associado para publica��o no site. Caso queira apresentar a foto do CIAD, poder� deixar esse campo vazio. | Foto no Site';
COMMENT ON COLUMN S3C."USUARIO"."MINI_CURRICULO" IS 'Trecho que aparece na p�gina principal do associado como apresenta��o logo abaixo de seu nome. | Mini Curr�culo';
COMMENT ON COLUMN S3C."USUARIO"."CURRICULO" IS 'Texto apresentado na p�gina de curr�culo do site. | Curr�culo';
COMMENT ON COLUMN S3C."USUARIO"."ESPECIALIDADE" IS 'Relato sobre as especialidades do Dr. | Especialidade';
COMMENT ON COLUMN S3C."USUARIO"."EQUIPE" IS 'Detalhes sobre a equipe. | Equipe';
COMMENT ON COLUMN S3C."USUARIO"."MIDIA" IS 'Mat�rias publicadas na m�dia. | Publica��es na M�dia';
COMMENT ON COLUMN S3C."USUARIO"."CLINICA" IS 'Informa��es sobre a cl�nica. | Sobre a Cl�nica';
COMMENT ON COLUMN S3C."USUARIO"."COMO_CHEGAR" IS 'Dicas de como chegar na cl�nica. | Como Chegar';
COMMENT ON COLUMN S3C."USUARIO"."CONSULTA" IS 'Informa��es sobre como agendar consulta. | Marque sua Consulta';
COMMENT ON COLUMN S3C."USUARIO"."TOPO_ANIM_SEQ" IS 'Anima��o de topo escolhida para aparecer no site. | Anima��o de Topo';
COMMENT ON COLUMN S3C."USUARIO"."CONSULTA_EMAIL" IS 'Email para o qual ser�o destinados comunicados para marcar consulta. | Email Marque Consulta';
COMMENT ON COLUMN S3C."USUARIO".SYS_MOMENTO_CRIA IS 'Registra momento de grava��o. | Momento de Cria��o';
COMMENT ON COLUMN S3C."USUARIO".SYS_USUARIO_CRIA IS 'Registra usu�rio que gravou. | Usu�rio que Criou';
COMMENT ON COLUMN S3C."USUARIO".SYS_LOCAL_CRIA IS 'Registra local de grava��o. | Local de Cria��o';
COMMENT ON COLUMN S3C."USUARIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualiza��o. | Momento de Atualiza��o';
COMMENT ON COLUMN S3C."USUARIO".SYS_USUARIO_ATUALIZA IS 'Registra usu�rio que atualizou. | Usu�rio que Alterou';
COMMENT ON COLUMN S3C."USUARIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualiza��o. | Local de Altera��o';
COMMENT ON COLUMN S3C."USUARIO".SYS_STATUS IS 'Status do registro entre I=Inclu�do, A=Alterado ou Vazio=Sem modifica��o. | Status do Registro';

/* **********************************************************************************
   CRIA��O DE TABELAS DO SISTEMA
*/


-- TABELA DE SISTEMA - GRANTS GERAIS
GRANT SELECT ON S3C.SYS_CONFIG_GLOBAL TO PUBLIC;
GRANT SELECT ON S3C.SYS_CONFIG_USUARIO TO PUBLIC;
GRANT SELECT ON S3C.SYS_DELETE TO PUBLIC;
GRANT SELECT ON S3C.SYS_LOCALID TO PUBLIC;
GRANT SELECT ON S3C.SYS_OCORRENCIA TO PUBLIC;
SPOOL OFF


-- EXEMPLO PARA IMPORT DE INFORMA��ES E 
-- C�DIGO PARA ELIMINAR OBJETOS IMPORTADOS EQUIVOCADAMENTE

SET SERVEROUTPUT ON SIZE 40000
SET ECHO OFF
SELECT
'EXP S3C/XXXX@SBDB OWNER=(S3C) FILE=S3C.DMP LOG=S3C_EXP.LOG' || CHR(13) || CHR(10) ||
'IMP S3C/XXXX@SBDB FROMUSER=S3C CONSTRAINTS=NO GRANTS=NO FILE=S3C.DMP LOG=S3C_IMP.LOG IGNORE=YES' || CHR(13) || CHR(10) ||
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
$ECHO - >>"C:\S3C_PARTES.LOG"
$ECHO - >>"C:\S3C_PARTES.LOG"
$ECHO - >>"C:\S3C_PARTES.LOG"
$COMMAND /C ECHO %DATE% %TIME% >>"C:\S3C_PARTES.LOG"
$COMMAND /C FIND "ORA-" "C:\S3C_PARTE1.LOG" >>"C:\S3C_PARTES.LOG"
$COMMAND /C FIND "SP2-" "C:\S3C_PARTE1.LOG" >>"C:\S3C_PARTES.LOG"
