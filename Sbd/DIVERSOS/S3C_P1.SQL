/* **********************************************************************************
   INTERCRAFT SOLUTIONS INFORMÁTICA LTDA - 2008
   SCRIPT CRIADO EM 22/09/2011 02:42

   IMPORTANTE!!!
   * O SISTEMA LOGARÁ SYSTEM PARA INICIAR A EXECUÇÃO, LOGO, MUITO CUIDADO!
   * CASO O USUÁRIO DO ESQUEMA JÁ EXISTA, ESTE SERÁ ELIMINADO, PORTANTO, TENHA A CERTEZA DAQUILO QUE ESTÁ FAZENDO.
   * ARQUIVO C:\S3C.LOG REGISTRARÁ O LOG DE EXECUÇÃO, QUE DEVE SER VERIFICADO.
   * CASO BANCO POSSUA ACENTOS, PRECISARÁ GARANTIR FORMATO ANSI ANTES DA EXECUÇÃO. PARA ISSO, EDITE O CONTEÚDO NO NOTEPAD E SALVE FAZENDO OPÇÃO POR ESTE FORMATO.
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

-- DEFININDO USUÁRIO DE ESQUEMA
DROP USER S3C CASCADE;
CREATE USER S3C IDENTIFIED BY XXXXXX DEFAULT TABLESPACE T_S3C_DAT;
GRANT DBA TO S3C;
GRANT SELECT ON DBA_JOBS TO S3C;
GRANT ALL PRIVILEGES TO S3C;

-- CONECTANDO COM USUÁRIO DE ESQUEMA
DISCONNECT;
CONNECT S3C/XXXX@SBDB;

/* **********************************************************************************
   CRIAÇÃO DE TABELAS
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

COMMENT ON TABLE S3C."DNS_EXEC" IS 'GERAL | Execuções de DNS. | Comandos no DNS';

COMMENT ON COLUMN S3C."DNS_EXEC"."SEQ" IS 'Sequencial sendo tratado pelo servidor sempre o menor primeiro. | Sequencial';
COMMENT ON COLUMN S3C."DNS_EXEC"."DNS_COMANDO" IS 'Comando DNS que será executado. | Comando DNS';
COMMENT ON COLUMN S3C."DNS_EXEC"."DNS_MOMENTO" IS 'Momento de execução. | Momento DNS';
COMMENT ON COLUMN S3C."DNS_EXEC"."DNS_RESULT" IS 'Resultado da execução. | Resultado DNS';
COMMENT ON COLUMN S3C."DNS_EXEC"."HEADER_COMANDO" IS 'Comando a ser tratado pelo cscript adsutil. | Comando Header';
COMMENT ON COLUMN S3C."DNS_EXEC"."HEADER_MOMENTO" IS 'Momento de inscrição do header no IIS. | Momento Header';
COMMENT ON COLUMN S3C."DNS_EXEC"."HEADER_RESULT" IS 'Resultado da tentativa de inscrição do header. | Resultado Header';
COMMENT ON COLUMN S3C."DNS_EXEC".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN S3C."DNS_EXEC".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN S3C."DNS_EXEC".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN S3C."DNS_EXEC".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN S3C."DNS_EXEC".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN S3C."DNS_EXEC".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN S3C."DNS_EXEC".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

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

COMMENT ON TABLE S3C."SYS_CONFIG_GLOBAL" IS 'Sistema | Armazena parâmetros globais do aplicativo. | Configuração Global';

COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL"."PARAM" IS 'Parametro. | Parâmetro';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL"."DESCR" IS 'Descrição. | Descrição';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL"."CONFIG" IS 'Configuração. | Configuração';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL"."PROP_EXTEND" IS 'Propriedades extendidas para configuração. | Propriedades';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL"."FORMATO" IS 'Formato de apresentação do campo MEMO, HTML ou vazio para texto comum. | Formato';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN S3C."SYS_CONFIG_GLOBAL".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

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

COMMENT ON TABLE S3C."SYS_CONFIG_USUARIO" IS 'Sistema | Parâmetros específicos de usuários do sistema. | Configuração de Usuário';

COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO"."USUARIO" IS 'Usuário. | Usuário';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO"."PARAM" IS 'Parametro. | Parâmetro';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO"."DESCR" IS 'Descrição. | Descrição';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO"."CONFIG" IS 'Configuração. | Configuração';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN S3C."SYS_CONFIG_USUARIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

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

COMMENT ON TABLE S3C."SYS_DELETE" IS 'Sistema | Registro de exclusões do sistema. | Registro de Exclusões';

COMMENT ON COLUMN S3C."SYS_DELETE"."TABELA" IS 'Nome da tabela onde a exclusão ocorreu. | Tabela';
COMMENT ON COLUMN S3C."SYS_DELETE"."CHAVE" IS 'Conteúdo da chave do registro excluído. | Chave';
COMMENT ON COLUMN S3C."SYS_DELETE"."MOMENTO" IS 'Momento em que ocorreu a exclusão. | Momento de Exclusão';
COMMENT ON COLUMN S3C."SYS_DELETE"."USUARIO" IS 'Detalhes do usuário que efetuou a exclusão. | Usuário';
COMMENT ON COLUMN S3C."SYS_DELETE"."LOCAL" IS 'De onde partiu a exclusão. | Local';

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

COMMENT ON TABLE S3C."SYS_LOCALID" IS 'Sistema | Especificações de localidade para sistema distribuído. | Detalhes de Localidade';

COMMENT ON COLUMN S3C."SYS_LOCALID"."NOME" IS 'Nome em caso de sistema distribuído. | Nome';
COMMENT ON COLUMN S3C."SYS_LOCALID"."CORRENTE" IS 'Marcado caso seja localidade corrente. | Corrente';
COMMENT ON COLUMN S3C."SYS_LOCALID"."PACOTE" IS 'Número do último pacote gerado. | Pacote Gerado';
COMMENT ON COLUMN S3C."SYS_LOCALID"."PACOTE_REC" IS 'Número do último pacote recebido. | Pacote Recebido';
COMMENT ON COLUMN S3C."SYS_LOCALID"."MOMENTO" IS 'Momento do último pacote gerado. | Momento de Geração';
COMMENT ON COLUMN S3C."SYS_LOCALID"."MOMENTO_REC" IS 'Momento do último pacote recebido. | Momento de Recebimento';
COMMENT ON COLUMN S3C."SYS_LOCALID"."MODELO" IS 'Modelo. | Modelo';
COMMENT ON COLUMN S3C."SYS_LOCALID"."DESCR" IS 'Descrição de localidade, responsabilidade ou qualquer texto que informe sobre a localidade. | Descrição';
COMMENT ON COLUMN S3C."SYS_LOCALID"."OBS" IS 'Observações sobre a localidade. | Observações';
COMMENT ON COLUMN S3C."SYS_LOCALID".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN S3C."SYS_LOCALID".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN S3C."SYS_LOCALID".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN S3C."SYS_LOCALID".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN S3C."SYS_LOCALID".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN S3C."SYS_LOCALID".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN S3C."SYS_LOCALID".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

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

COMMENT ON TABLE S3C."SYS_OCORRENCIA" IS 'Sistema | Registro de ocorrências do sistema. | Registro de Ocorrências';

COMMENT ON COLUMN S3C."SYS_OCORRENCIA"."SEQ" IS 'Sequencial da ocorrência. | Sequencial';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA"."APLICACAO" IS 'Nome do aplicativo onde ocorreu o registro. | Aplicação';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA"."OCORRENCIA" IS 'Detalhes da ocorrência. | Ocorrência';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA"."USUARIO" IS 'Usuário logado no momento da ocorrência. | Usuário';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA"."MOMENTO" IS 'Momento em que ocorreu a situação. | Momento';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA"."LOCAL" IS 'Local onde ocorreu o registro. | Localidade';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN S3C."SYS_OCORRENCIA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

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

COMMENT ON TABLE S3C."TEMPLATE" IS 'GERAL | Templates de sites. | Opções de Site';

COMMENT ON COLUMN S3C."TEMPLATE"."SEQ" IS 'Sequencial da template. | Sequencial';
COMMENT ON COLUMN S3C."TEMPLATE"."TEMPLATE" IS 'Nome de apresentação para escolha pelo associado. | Nome do Tipo de Site';
COMMENT ON COLUMN S3C."TEMPLATE"."THEME" IS 'Tema programado para esta template. | Tema';
COMMENT ON COLUMN S3C."TEMPLATE".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN S3C."TEMPLATE".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN S3C."TEMPLATE".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN S3C."TEMPLATE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN S3C."TEMPLATE".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN S3C."TEMPLATE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN S3C."TEMPLATE".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

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

COMMENT ON TABLE S3C."TOPO_ANIM" IS 'GERAL | Animações de topo. | Animação de Topo';

COMMENT ON COLUMN S3C."TOPO_ANIM"."SEQ" IS 'Sequencial da template. | Sequencial';
COMMENT ON COLUMN S3C."TOPO_ANIM"."ANIMACAO" IS 'Nome de apresentação para escolha pelo associado. | Título da Animação';
COMMENT ON COLUMN S3C."TOPO_ANIM"."COMPL" IS 'Aponta para diretório onde foram salvas as imagens: App_Themes\Tema\Img\Head\Complemento\Imagens... | Complemento de Diretório';
COMMENT ON COLUMN S3C."TOPO_ANIM".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN S3C."TOPO_ANIM".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN S3C."TOPO_ANIM".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN S3C."TOPO_ANIM".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN S3C."TOPO_ANIM".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN S3C."TOPO_ANIM".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN S3C."TOPO_ANIM".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

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

COMMENT ON TABLE S3C."USUARIO" IS 'GERAL | Lista de usuários. | Usuários';

COMMENT ON COLUMN S3C."USUARIO"."SEQ" IS 'Sequencial de registro no S3C. | Sequencial';
COMMENT ON COLUMN S3C."USUARIO"."MATR_SBD" IS 'Associado da SBD. | Matrícula';
COMMENT ON COLUMN S3C."USUARIO"."NOME_APRES" IS 'Nome de apresentação no site com pronome de tratamento, maiúsculas e minúsculas e tudo mais.Aparece na página inicial. | Nome de Apresentação';
COMMENT ON COLUMN S3C."USUARIO"."HOST_COMPL" IS 'Complemento de host sendo xxxxx do formato: www.xxxxx.dermatosbd.org.br. Por exemplo, para www.joao.dermatosbd.org.br, utilize apenas joao neste campo. | Nome de Domínio';
COMMENT ON COLUMN S3C."USUARIO"."TEMPLATE_SEQ" IS 'Layout escolhido variação específica de cores. | Template';
COMMENT ON COLUMN S3C."USUARIO"."PUBLICAR" IS 'Publicação do site ativada ou não. | Pode Publicar?';
COMMENT ON COLUMN S3C."USUARIO"."FOTO_SITE" IS 'Arquivo contendo a foto do associado para publicação no site. Caso queira apresentar a foto do CIAD, poderá deixar esse campo vazio. | Foto no Site';
COMMENT ON COLUMN S3C."USUARIO"."MINI_CURRICULO" IS 'Trecho que aparece na página principal do associado como apresentação logo abaixo de seu nome. | Mini Currículo';
COMMENT ON COLUMN S3C."USUARIO"."CURRICULO" IS 'Texto apresentado na página de currículo do site. | Currículo';
COMMENT ON COLUMN S3C."USUARIO"."ESPECIALIDADE" IS 'Relato sobre as especialidades do Dr. | Especialidade';
COMMENT ON COLUMN S3C."USUARIO"."EQUIPE" IS 'Detalhes sobre a equipe. | Equipe';
COMMENT ON COLUMN S3C."USUARIO"."MIDIA" IS 'Matérias publicadas na mídia. | Publicações na Mídia';
COMMENT ON COLUMN S3C."USUARIO"."CLINICA" IS 'Informações sobre a clínica. | Sobre a Clínica';
COMMENT ON COLUMN S3C."USUARIO"."COMO_CHEGAR" IS 'Dicas de como chegar na clínica. | Como Chegar';
COMMENT ON COLUMN S3C."USUARIO"."CONSULTA" IS 'Informações sobre como agendar consulta. | Marque sua Consulta';
COMMENT ON COLUMN S3C."USUARIO"."TOPO_ANIM_SEQ" IS 'Animação de topo escolhida para aparecer no site. | Animação de Topo';
COMMENT ON COLUMN S3C."USUARIO"."CONSULTA_EMAIL" IS 'Email para o qual serão destinados comunicados para marcar consulta. | Email Marque Consulta';
COMMENT ON COLUMN S3C."USUARIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN S3C."USUARIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN S3C."USUARIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN S3C."USUARIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN S3C."USUARIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN S3C."USUARIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN S3C."USUARIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

/* **********************************************************************************
   CRIAÇÃO DE TABELAS DO SISTEMA
*/


-- TABELA DE SISTEMA - GRANTS GERAIS
GRANT SELECT ON S3C.SYS_CONFIG_GLOBAL TO PUBLIC;
GRANT SELECT ON S3C.SYS_CONFIG_USUARIO TO PUBLIC;
GRANT SELECT ON S3C.SYS_DELETE TO PUBLIC;
GRANT SELECT ON S3C.SYS_LOCALID TO PUBLIC;
GRANT SELECT ON S3C.SYS_OCORRENCIA TO PUBLIC;
SPOOL OFF


-- EXEMPLO PARA IMPORT DE INFORMAÇÕES E 
-- CÓDIGO PARA ELIMINAR OBJETOS IMPORTADOS EQUIVOCADAMENTE

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
