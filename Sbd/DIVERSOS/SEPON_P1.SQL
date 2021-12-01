/* **********************************************************************************
   INTERCRAFT SOLUTIONS INFORMÁTICA LTDA - 2008
   SCRIPT CRIADO EM 22/09/2011 02:42

   IMPORTANTE!!!
   * O SISTEMA LOGARÁ SYSTEM PARA INICIAR A EXECUÇÃO, LOGO, MUITO CUIDADO!
   * CASO O USUÁRIO DO ESQUEMA JÁ EXISTA, ESTE SERÁ ELIMINADO, PORTANTO, TENHA A CERTEZA DAQUILO QUE ESTÁ FAZENDO.
   * ARQUIVO C:\SEPON.LOG REGISTRARÁ O LOG DE EXECUÇÃO, QUE DEVE SER VERIFICADO.
   * CASO BANCO POSSUA ACENTOS, PRECISARÁ GARANTIR FORMATO ANSI ANTES DA EXECUÇÃO. PARA ISSO, EDITE O CONTEÚDO NO NOTEPAD E SALVE FAZENDO OPÇÃO POR ESTE FORMATO.
*/

SET ECHO ON
SET HEADING OFF
SET PAGESIZE 0
SET LINES 10000
SET LINESIZE 10000
SET SERVEROUTPUT ON SIZE 40000
SPOOL C:\SEPON_PARTE1.LOG

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
for cur in (select job from user_jobs where schema_user='SEPON') loop
dbms_job.remove(cur.job);
end loop;
end;
/

-- INICIALIZANDO TABLESPACE
ALTER TABLESPACE T_SEPON_DAT OFFLINE;
DROP TABLESPACE T_SEPON_DAT INCLUDING CONTENTS;
CREATE TABLESPACE T_SEPON_DAT DATAFILE 'C:\oracle\product\10.2.0\oradata\SBDB\SEPON.DBF' SIZE 100M REUSE
AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL;

-- DEFININDO USUÁRIO DE ESQUEMA
DROP USER SEPON CASCADE;
CREATE USER SEPON IDENTIFIED BY XXXXXX DEFAULT TABLESPACE T_SEPON_DAT;
GRANT DBA TO SEPON;
GRANT SELECT ON DBA_JOBS TO SEPON;
GRANT ALL PRIVILEGES TO SEPON;

-- CONECTANDO COM USUÁRIO DE ESQUEMA
DISCONNECT;
CONNECT SEPON/XXXX@SBDB;

/* **********************************************************************************
   CRIAÇÃO DE TABELAS
*/

-- TABELA BOLETO
CREATE TABLE SEPON."BOLETO" (
   "SEQ" NUMBER (11,0),
   "DATA_EMISSAO" DATE,
   "DATA_VENCIM" DATE,
   "NOSSO_NUM" VARCHAR2 (50),
   "VALOR" NUMBER (16,2),
   "SACADO_NOME" VARCHAR2 (50),
   "SACADO_CPF" VARCHAR2 (50),
   "SACADO_ENDERECO" VARCHAR2 (200),
   "SACADO_NUMERO" VARCHAR2 (20),
   "SACADO_COMPLEMENTO" VARCHAR2 (20),
   "SACADO_BAIRRO" VARCHAR2 (50),
   "SACADO_CIDADE" VARCHAR2 (50),
   "SACADO_ESTADO" VARCHAR2 (2),
   "SACADO_CEP" VARCHAR2 (10),
   "SACADO_TEL_RES" VARCHAR2 (50),
   "SACADO_TEL_COM" VARCHAR2 (50),
   "SACADO_TEL_CEL" VARCHAR2 (50),
   "INSTRUCAO_SUP_1" VARCHAR2 (50),
   "INSTRUCAO_SUP_2" VARCHAR2 (50),
   "INSTRUCAO_INF_1" VARCHAR2 (50),
   "INSTRUCAO_INF_2" VARCHAR2 (50),
   "INSTRUCAO_INF_3" VARCHAR2 (50),
   "INSTRUCAO_INF_4" VARCHAR2 (50),
   "INSTRUCAO_INF_5" VARCHAR2 (50),
   "INSTRUCAO_INF_6" VARCHAR2 (50),
   "DATA_PAGAM" DATE,
   "CONFIRM_OPER_SEQ" NUMBER (11,0),
   "DATA_BAIXA" DATE,
   "CANCEL" NUMBER (1,0),
   "TIPO_ACESSO_SEQ" NUMBER (11,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SEPON."BOLETO" ADD CONSTRAINT "ID_BOLETO"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SEPON."BOLETO" IS 'SEPON | Boletos do sistema. | Boleto';

COMMENT ON COLUMN SEPON."BOLETO"."SEQ" IS 'Sequencial de boleto. | Sequencial';
COMMENT ON COLUMN SEPON."BOLETO"."DATA_EMISSAO" IS 'Data da emissão do boleto. | Data de Emissão';
COMMENT ON COLUMN SEPON."BOLETO"."DATA_VENCIM" IS 'Data de vencimento do boleto. | Data de Vencimento';
COMMENT ON COLUMN SEPON."BOLETO"."NOSSO_NUM" IS 'Nosso número enviado ao banco para identificação do boleto. | Nosso Número';
COMMENT ON COLUMN SEPON."BOLETO"."VALOR" IS 'Valor do boleto a ser pago. | Valor';
COMMENT ON COLUMN SEPON."BOLETO"."SACADO_NOME" IS 'Nome que aparece no campo de sacado no boleto. | Nome do Sacado';
COMMENT ON COLUMN SEPON."BOLETO"."SACADO_CPF" IS 'CPF do sacado. | CPF';
COMMENT ON COLUMN SEPON."BOLETO"."SACADO_ENDERECO" IS 'Endereço completo, tipo (rua, av.), logradouro e número do sacado. | Endereço Completo';
COMMENT ON COLUMN SEPON."BOLETO"."SACADO_NUMERO" IS 'Número do endereço do sacado. | Número';
COMMENT ON COLUMN SEPON."BOLETO"."SACADO_COMPLEMENTO" IS 'Complemento do endereço do sacado. | Complemento';
COMMENT ON COLUMN SEPON."BOLETO"."SACADO_BAIRRO" IS 'Bairro do sacado. | Bairro';
COMMENT ON COLUMN SEPON."BOLETO"."SACADO_CIDADE" IS 'Nome da cidade do sacado. | Cidade';
COMMENT ON COLUMN SEPON."BOLETO"."SACADO_ESTADO" IS 'Estado do sacado. | Estado';
COMMENT ON COLUMN SEPON."BOLETO"."SACADO_CEP" IS 'CEP do sacado. | CEP';
COMMENT ON COLUMN SEPON."BOLETO"."SACADO_TEL_RES" IS 'Número do telefone residencial no formato: DDI DDD e TELEFONE. | Telefone';
COMMENT ON COLUMN SEPON."BOLETO"."SACADO_TEL_COM" IS 'Número do telefone comercial no formato: DDI DDD e TELEFONE. | Telefone';
COMMENT ON COLUMN SEPON."BOLETO"."SACADO_TEL_CEL" IS 'Número do telefone celular: DDI DDD e TELEFONE. | Telefone Celular';
COMMENT ON COLUMN SEPON."BOLETO"."INSTRUCAO_SUP_1" IS 'Linha de instrução superior. | Instrução Superior 1';
COMMENT ON COLUMN SEPON."BOLETO"."INSTRUCAO_SUP_2" IS 'Linha de instrução superior. | Instrução Superior 2';
COMMENT ON COLUMN SEPON."BOLETO"."INSTRUCAO_INF_1" IS 'Linha de instrução inferior. | Instrução Inferior 1';
COMMENT ON COLUMN SEPON."BOLETO"."INSTRUCAO_INF_2" IS 'Linha de instrução inferior. | Instrução Inferior 2';
COMMENT ON COLUMN SEPON."BOLETO"."INSTRUCAO_INF_3" IS 'Linha de instrução inferior. | Instrução Inferior 3';
COMMENT ON COLUMN SEPON."BOLETO"."INSTRUCAO_INF_4" IS 'Linha de instrução inferior. | Instrução Inferior 4';
COMMENT ON COLUMN SEPON."BOLETO"."INSTRUCAO_INF_5" IS 'Linha de instrução inferior. | Instrução Inferior 5';
COMMENT ON COLUMN SEPON."BOLETO"."INSTRUCAO_INF_6" IS 'Linha de instrução inferior. | Instrução Inferior 6';
COMMENT ON COLUMN SEPON."BOLETO"."DATA_PAGAM" IS 'Data na qual o boleto foi pago. | Data de Pagamento';
COMMENT ON COLUMN SEPON."BOLETO"."CONFIRM_OPER_SEQ" IS 'Registro do operador que confirma o pagamento. | Operador Confirmador';
COMMENT ON COLUMN SEPON."BOLETO"."DATA_BAIXA" IS 'Registro da data em que o operador deu baixa no boleto. | Data de Baixa';
COMMENT ON COLUMN SEPON."BOLETO"."CANCEL" IS 'Marcar para informar que este boleto foi cancelado. | Cancelado';
COMMENT ON COLUMN SEPON."BOLETO"."TIPO_ACESSO_SEQ" IS 'Tipo de acesso comprado vinculado ao evento. | Tipo de Acesso';
COMMENT ON COLUMN SEPON."BOLETO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."BOLETO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."BOLETO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."BOLETO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."BOLETO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."BOLETO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."BOLETO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA CONEXAO
CREATE TABLE SEPON."CONEXAO" (
   "SEQ" NUMBER (11,0),
   "LINK_SEQ" NUMBER (11,0),
   "USUARIO_SEQ" NUMBER (11,0),
   "USUARIO_NOME" VARCHAR2 (200),
   "MOMENTO_ENTRADA" DATE,
   "MOMENTO_CONFIRM" DATE,
   "SLIDE_VISUALIZADO" NUMBER (11,0),
   "IP_CLIENTE" VARCHAR2 (200),
   "IP_SERVIDOR" VARCHAR2 (200),
   "NAVEGADOR" CLOB,
   "VEL_CALC_KBITSEG" NUMBER (16,12),
   "EVENTO_SEQ" NUMBER (11,0),
   "VIDEO_SEQ" NUMBER (11,0),
   "INSTR" VARCHAR2 (200)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SEPON."CONEXAO" ADD CONSTRAINT "ID_CONEXAO"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SEPON."CONEXAO" IS 'SEPON | Conexões de usuários. | Conexão';

COMMENT ON COLUMN SEPON."CONEXAO"."SEQ" IS 'Sequencial que não se repete. | Sequencial';
COMMENT ON COLUMN SEPON."CONEXAO"."LINK_SEQ" IS 'Identificação do link pelo qual a conexão foi estabelecida. | Link';
COMMENT ON COLUMN SEPON."CONEXAO"."USUARIO_SEQ" IS 'Usuário conectado no momento. | Usuário';
COMMENT ON COLUMN SEPON."CONEXAO"."USUARIO_NOME" IS 'Nome do usuário utilizado no momento da conexão. | Nome do Usuário';
COMMENT ON COLUMN SEPON."CONEXAO"."MOMENTO_ENTRADA" IS 'Momento de conexão do usuário. | Entrada';
COMMENT ON COLUMN SEPON."CONEXAO"."MOMENTO_CONFIRM" IS 'Último momento que usuário confirmou estar assistindo. | Confirmação';
COMMENT ON COLUMN SEPON."CONEXAO"."SLIDE_VISUALIZADO" IS 'Último slide visualizado pelo usuário. | Slide Visualizado';
COMMENT ON COLUMN SEPON."CONEXAO"."IP_CLIENTE" IS 'Identificação de rede (IP) da máquina do cliente. | IP do Cliente';
COMMENT ON COLUMN SEPON."CONEXAO"."IP_SERVIDOR" IS 'Caminho utilizado para acesso ao vídeo do servidor. | IP do Servidor';
COMMENT ON COLUMN SEPON."CONEXAO"."NAVEGADOR" IS 'Detalhes sobre o navegador do cliente. | Navegador';
COMMENT ON COLUMN SEPON."CONEXAO"."VEL_CALC_KBITSEG" IS 'Velocidade de fluxo calculado em Kbits/seg. | Vel.Calculada Kbits/Seg';
COMMENT ON COLUMN SEPON."CONEXAO"."EVENTO_SEQ" IS 'Evento sendo acessado pelo usuário. | Evento';
COMMENT ON COLUMN SEPON."CONEXAO"."VIDEO_SEQ" IS 'Vídeo sendo acessado pelo usuário. | Vídeo';
COMMENT ON COLUMN SEPON."CONEXAO"."INSTR" IS 'Instrução a ser tratada pelo cliente (DESC=Desconecta). | Instrução';
COMMENT ON COLUMN SEPON."CONEXAO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."CONEXAO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."CONEXAO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."CONEXAO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."CONEXAO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."CONEXAO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."CONEXAO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EVENTO
CREATE TABLE SEPON."EVENTO" (
   "SEQ" NUMBER (11,0),
   "DATA_CAD" DATE,
   "TIPO" VARCHAR2 (1),
   "TITULO" VARCHAR2 (200),
   "DESCR" CLOB,
   "PALESTRANTE" CLOB,
   "ONLINE_PONTO_PUBLIC" VARCHAR2 (200),
   "VALOR" NUMBER (16,2),
   "INICIO" DATE,
   "TERMINO" DATE,
   "ABERTURA" NUMBER (1,0),
   "DIRETORIO" VARCHAR2 (200),
   "IDIOMAS_SLIDE" VARCHAR2 (5),
   "COMENT_CLASSIF" NUMBER (1,0),
   "MOMENTO_PUBLIC" DATE,
   "IMPORTANTE" VARCHAR2 (4000),
   "REGULAMENTO" CLOB
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SEPON."EVENTO" ADD CONSTRAINT "ID_EVENTO"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SEPON."EVENTO" IS 'SEPON | Eventos ou palestras. | Evento';

COMMENT ON COLUMN SEPON."EVENTO"."SEQ" IS 'Sequencial do evento ou palestra. | Sequencial';
COMMENT ON COLUMN SEPON."EVENTO"."DATA_CAD" IS 'Data de cadastro. | Data de Cadastro';
COMMENT ON COLUMN SEPON."EVENTO"."TIPO" IS 'Tipo (P=Palestra ou E=Evento). | Tipo de Evento';
COMMENT ON COLUMN SEPON."EVENTO"."TITULO" IS 'Título do evento ou palestra. | Título';
COMMENT ON COLUMN SEPON."EVENTO"."DESCR" IS 'Descrição. | Descrição';
COMMENT ON COLUMN SEPON."EVENTO"."PALESTRANTE" IS 'Palestrantes ou participantes da palestra. | Palestrante';
COMMENT ON COLUMN SEPON."EVENTO"."ONLINE_PONTO_PUBLIC" IS 'Ponto de publicação quando for utilizado ambiente de difusão seletiva. | Ponto de Publicação';
COMMENT ON COLUMN SEPON."EVENTO"."VALOR" IS 'Valor do evento a ser cobrado em boleto (sem desconto). | Valor';
COMMENT ON COLUMN SEPON."EVENTO"."INICIO" IS 'Data de início do evento. | Data de Início';
COMMENT ON COLUMN SEPON."EVENTO"."TERMINO" IS 'Data de término do evento. | Data de Término';
COMMENT ON COLUMN SEPON."EVENTO"."ABERTURA" IS 'Mostrar abertura na entrada? | Abertura?';
COMMENT ON COLUMN SEPON."EVENTO"."DIRETORIO" IS 'Diretório de localização dos arquivos em disco a partir do diretório de palestras. | Diretório';
COMMENT ON COLUMN SEPON."EVENTO"."IDIOMAS_SLIDE" IS 'Existência de slides nestes idiomas (P=Português, I=Inglês ou PI=Ambos). | Idiomas';
COMMENT ON COLUMN SEPON."EVENTO"."COMENT_CLASSIF" IS 'Exibir pergunta, opinião ou sugestão ou apenas comentário. | Exibir Pergunta, Sugestão e Opinião?';
COMMENT ON COLUMN SEPON."EVENTO"."MOMENTO_PUBLIC" IS 'Momento em que o evento será publicado. | Publicar em';
COMMENT ON COLUMN SEPON."EVENTO"."IMPORTANTE" IS 'Texto mais detalhado sobre o evento. | Saiba mais';
COMMENT ON COLUMN SEPON."EVENTO"."REGULAMENTO" IS 'Cada linha corresponde a uma cláusula contratual vinculada a este evento específico. Cláusulas genéricas devem ser colocadas em parâmetro do sistema. | Regulamento';
COMMENT ON COLUMN SEPON."EVENTO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."EVENTO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."EVENTO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."EVENTO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."EVENTO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."EVENTO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."EVENTO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EVENTO_CONTRATO
CREATE TABLE SEPON."EVENTO_CONTRATO" (
   "EVENTO_SEQ" NUMBER (11,0),
   "SEQ" NUMBER (11,0),
   "USUARIO_SEQ" NUMBER (11,0),
   "DATA_CONTRAT" DATE,
   "CONTRAT_HORAS" NUMBER (11,0),
   "CONTRAT_MOMENTO_INICIO" DATE,
   "BOLETO_SEQ" NUMBER (11,0),
   "CONTRAT_ATE" DATE,
   "OBS" CLOB
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SEPON."EVENTO_CONTRATO" ADD CONSTRAINT "ID_EVENTO_CONTRATO"
PRIMARY KEY("EVENTO_SEQ", "SEQ");

COMMENT ON TABLE SEPON."EVENTO_CONTRATO" IS 'SEPON | Liberação de acesso mediante contratação de horas. | Contrato de Evento';

COMMENT ON COLUMN SEPON."EVENTO_CONTRATO"."EVENTO_SEQ" IS 'Evento contemplado por este cadastramento de contrato. | Evento';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO"."SEQ" IS 'Sequencial de contrato para aquele evento. | Sequencial';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO"."USUARIO_SEQ" IS 'Usuário com o qual se estabelece a relação de contratação. | Usuário';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO"."DATA_CONTRAT" IS 'Data de contratação. | Data de Contratação';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO"."CONTRAT_HORAS" IS 'Horas contratadas mediante pagamento do boleto. | Horas Contratadas';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO"."CONTRAT_MOMENTO_INICIO" IS 'Início do período contratado a contar do primeiro acesso após liberação. | Período Iniciado Em';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO"."BOLETO_SEQ" IS 'Número do boleto que deverá ser pago para liberação de acesso. | Boleto';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO"."CONTRAT_ATE" IS 'Período contratado até a data especificada. | Contratado até';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO"."OBS" IS 'Observações referente ao contrato. | Observações';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."EVENTO_CONTRATO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA EVENTO_GRATUIDADE
CREATE TABLE SEPON."EVENTO_GRATUIDADE" (
   "EVENTO_SEQ" NUMBER (11,0),
   "SEQ" NUMBER (11,0),
   "USUARIO_SEQ" NUMBER (11,0),
   "DATA_CONTRAT" DATE,
   "GRATIS_HORAS" NUMBER (11,0),
   "GRATIS_MOMENTO_INICIO" DATE
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SEPON."EVENTO_GRATUIDADE" ADD CONSTRAINT "ID_EVENTO_GRATUIDADE"
PRIMARY KEY("EVENTO_SEQ", "SEQ");

COMMENT ON TABLE SEPON."EVENTO_GRATUIDADE" IS 'SEPON | Liberação de acesso mediante possibilidade de gratuidade. | Gratuidade de Evento';

COMMENT ON COLUMN SEPON."EVENTO_GRATUIDADE"."EVENTO_SEQ" IS 'Evento contemplado por este cadastramento de contrato. | Evento';
COMMENT ON COLUMN SEPON."EVENTO_GRATUIDADE"."SEQ" IS 'Sequencial de contrato para aquele evento. | Sequencial';
COMMENT ON COLUMN SEPON."EVENTO_GRATUIDADE"."USUARIO_SEQ" IS 'Usuário com o qual se estabelece a relação de contratação. | Usuário';
COMMENT ON COLUMN SEPON."EVENTO_GRATUIDADE"."DATA_CONTRAT" IS 'Data de contratação. | Data de Entrada';
COMMENT ON COLUMN SEPON."EVENTO_GRATUIDADE"."GRATIS_HORAS" IS 'Horas de gratuidade do serviço para o usuário. | Horas de Gratuidade';
COMMENT ON COLUMN SEPON."EVENTO_GRATUIDADE"."GRATIS_MOMENTO_INICIO" IS 'Primeiro acesso a contar como início do período de gratuidade que o usuário ter por direito. | Início da Gratuidade';
COMMENT ON COLUMN SEPON."EVENTO_GRATUIDADE".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."EVENTO_GRATUIDADE".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."EVENTO_GRATUIDADE".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."EVENTO_GRATUIDADE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."EVENTO_GRATUIDADE".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."EVENTO_GRATUIDADE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."EVENTO_GRATUIDADE".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA FORMA_ACESSO
CREATE TABLE SEPON."FORMA_ACESSO" (
   "EVENTO_SEQ" NUMBER (11,0),
   "SEQ" NUMBER (11,0),
   "TIPO_ACESSO_SEQ" NUMBER (11,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SEPON."FORMA_ACESSO" ADD CONSTRAINT "ID_FORMA_ACESSO"
PRIMARY KEY("EVENTO_SEQ", "SEQ");

COMMENT ON TABLE SEPON."FORMA_ACESSO" IS 'SEPON | Definição de forma de acesso de evento específico. | Forma de Acesso';

COMMENT ON COLUMN SEPON."FORMA_ACESSO"."EVENTO_SEQ" IS 'Evento que possui esta possibilidade de acesso programada. | Evento';
COMMENT ON COLUMN SEPON."FORMA_ACESSO"."SEQ" IS 'Sequencial no evento da possibilidade de acesso. | Sequencial';
COMMENT ON COLUMN SEPON."FORMA_ACESSO"."TIPO_ACESSO_SEQ" IS 'Tipo de acesso programado vinculado ao evento. | Tipo de Acesso';
COMMENT ON COLUMN SEPON."FORMA_ACESSO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."FORMA_ACESSO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."FORMA_ACESSO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."FORMA_ACESSO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."FORMA_ACESSO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."FORMA_ACESSO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."FORMA_ACESSO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA LINK
CREATE TABLE SEPON."LINK" (
   "SEQ" NUMBER (11,0),
   "NOME" VARCHAR2 (200),
   "NR_CONN_ATUAL" NUMBER (11,0),
   "NR_CONN_MAX" NUMBER (11,0),
   "IP_SERVIDOR" VARCHAR2 (200),
   "VEL_CALC_KBITSEG" NUMBER (16,12),
   "AOVIVO" NUMBER (1,0),
   "GRAVADO" NUMBER (1,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SEPON."LINK" ADD CONSTRAINT "ID_LINK"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SEPON."LINK" IS 'SEPON | Possibilidade de aceso por links diferentes. | Link';

COMMENT ON COLUMN SEPON."LINK"."SEQ" IS 'Sequencial de link. | Sequencial';
COMMENT ON COLUMN SEPON."LINK"."NOME" IS 'Nome do link. | Nome';
COMMENT ON COLUMN SEPON."LINK"."NR_CONN_ATUAL" IS 'Número de conexões atualmente ativas. | Conexões Ativas';
COMMENT ON COLUMN SEPON."LINK"."NR_CONN_MAX" IS 'Número de conexões máximas permitida neste link. | Conexões Máximas';
COMMENT ON COLUMN SEPON."LINK"."IP_SERVIDOR" IS 'IP ou caminha a ser utilizado para acesso ao vídeo no servidor (sem ponto de publicação). | IP do Servidor';
COMMENT ON COLUMN SEPON."LINK"."VEL_CALC_KBITSEG" IS 'Velocidade de fluxo calculado em Kbits/seg. | Vel.Calculada Kbits/Seg';
COMMENT ON COLUMN SEPON."LINK"."AOVIVO" IS 'Marcar para informar que este link poderá ser utilizado para vídeos ao vivo. | Ao Vivo';
COMMENT ON COLUMN SEPON."LINK"."GRAVADO" IS 'Marcar para informar que este link poderá ser utilizado para vídeos gravados. | Nome dos Arquivos Gravados';
COMMENT ON COLUMN SEPON."LINK".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."LINK".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."LINK".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."LINK".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."LINK".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."LINK".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."LINK".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA LOG
CREATE TABLE SEPON."LOG" (
   "SEQ" NUMBER (11,0),
   "CATEGORIA" VARCHAR2 (50),
   "MOMENTO" DATE,
   "TEXTO" CLOB,
   "VIDEO_SEQ" NUMBER (11,0),
   "ASSIST_SEQ" NUMBER (11,0),
   "USUARIO_SEQ" NUMBER (11,0),
   "NOME" VARCHAR2 (200),
   "EMAIL" VARCHAR2 (200),
   "MATR_SBD" NUMBER (11,0),
   "LINK_SEQ" NUMBER (11,0),
   "CONEXAO_SEQ" NUMBER (11,0),
   "SLIDE_VISUALIZADO" NUMBER (11,0),
   "IP_CLIENTE" VARCHAR2 (200),
   "IP_SERVIDOR" VARCHAR2 (200),
   "NAVEGADOR" CLOB,
   "LIDO" NUMBER (1,0),
   "DURACAO" NUMBER (11,0),
   "ULTIMA_CONFIRM" DATE,
   "VEL_CALC_KBITSEG" NUMBER (11,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SEPON."LOG" ADD CONSTRAINT "ID_LOG"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SEPON."LOG" IS 'SEPON | Registro de log do sistema que incluir perguntas e comentários. | Log';

COMMENT ON COLUMN SEPON."LOG"."SEQ" IS 'Sequencial de registro. | Sequencial';
COMMENT ON COLUMN SEPON."LOG"."CATEGORIA" IS 'Categoria do registro de log. | Categoria';
COMMENT ON COLUMN SEPON."LOG"."MOMENTO" IS 'Data de cadastro. | Data de Cadastro';
COMMENT ON COLUMN SEPON."LOG"."TEXTO" IS 'Texto de registro no log. | Texto';
COMMENT ON COLUMN SEPON."LOG"."VIDEO_SEQ" IS 'Vídeo assistido no momento do registro. | Vídeo';
COMMENT ON COLUMN SEPON."LOG"."ASSIST_SEQ" IS 'Sequencial de audiência do vídeo que era assistido no momento do registro. | Audiência';
COMMENT ON COLUMN SEPON."LOG"."USUARIO_SEQ" IS 'Usuário que originou o pedido de registro de log. | Usuário';
COMMENT ON COLUMN SEPON."LOG"."NOME" IS 'Nome completo do usuário. | Nome Completo';
COMMENT ON COLUMN SEPON."LOG"."EMAIL" IS 'Email do usuário. | Email';
COMMENT ON COLUMN SEPON."LOG"."MATR_SBD" IS 'Matrícula do associado. | Matrícula SBD';
COMMENT ON COLUMN SEPON."LOG"."LINK_SEQ" IS 'Sequencial histórico de link. | Sequencial';
COMMENT ON COLUMN SEPON."LOG"."CONEXAO_SEQ" IS 'Número da conexão que gerou este registro. | Conexão';
COMMENT ON COLUMN SEPON."LOG"."SLIDE_VISUALIZADO" IS 'Número do slide visualizado no momento do registro, caso se aplique. | Slide';
COMMENT ON COLUMN SEPON."LOG"."IP_CLIENTE" IS 'Identificação de rede (IP) da máquina do cliente. | IP do Cliente';
COMMENT ON COLUMN SEPON."LOG"."IP_SERVIDOR" IS 'Caminho utilizado para acesso ao vídeo do servidor. | IP do Servidor';
COMMENT ON COLUMN SEPON."LOG"."NAVEGADOR" IS 'Detalhes sobre o navegador do cliente. | Navegador';
COMMENT ON COLUMN SEPON."LOG"."LIDO" IS 'Se o registro já foi lido ou não. | Lido';
COMMENT ON COLUMN SEPON."LOG"."DURACAO" IS 'Duração em Minutos. | Duração (mins)';
COMMENT ON COLUMN SEPON."LOG"."ULTIMA_CONFIRM" IS 'Momento de última confirmação. | Última Confirmação';
COMMENT ON COLUMN SEPON."LOG"."VEL_CALC_KBITSEG" IS 'Velocidade calculada. | Velocidade Calculada';
COMMENT ON COLUMN SEPON."LOG".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."LOG".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."LOG".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."LOG".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."LOG".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."LOG".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."LOG".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA PARTICIPANTE
CREATE TABLE SEPON."PARTICIPANTE" (
   "EVENTO_SEQ" NUMBER (11,0),
   "USUARIO_SEQ" NUMBER (11,0)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SEPON."PARTICIPANTE" ADD CONSTRAINT "ID_PARTICIPANTE"
PRIMARY KEY("EVENTO_SEQ", "USUARIO_SEQ");

COMMENT ON TABLE SEPON."PARTICIPANTE" IS 'SEPON | Participantes cadastrados em determinado evento. | Participante';

COMMENT ON COLUMN SEPON."PARTICIPANTE"."EVENTO_SEQ" IS 'Evento para registro da participação de usuário. | Evento';
COMMENT ON COLUMN SEPON."PARTICIPANTE"."USUARIO_SEQ" IS 'Usuário cadastrado que participou do evento. | Usuário';
COMMENT ON COLUMN SEPON."PARTICIPANTE".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."PARTICIPANTE".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."PARTICIPANTE".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."PARTICIPANTE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."PARTICIPANTE".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."PARTICIPANTE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."PARTICIPANTE".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SLIDE
CREATE TABLE SEPON."SLIDE" (
   "EVENTO_SEQ" NUMBER (11,0),
   "SEQ" NUMBER (11,0),
   "IDIOMAS" VARCHAR2 (5),
   "TITULO" VARCHAR2 (200),
   "DESCR" CLOB,
   "ARQUIVO" VARCHAR2 (200)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SEPON."SLIDE" ADD CONSTRAINT "ID_SLIDE"
PRIMARY KEY("EVENTO_SEQ", "SEQ");

COMMENT ON TABLE SEPON."SLIDE" IS 'SEPON | Lista de slides relacionados ao evento. | Slide';

COMMENT ON COLUMN SEPON."SLIDE"."EVENTO_SEQ" IS 'Evento no qual o slide está inserido. | Evento';
COMMENT ON COLUMN SEPON."SLIDE"."SEQ" IS 'Sequencial do slide naquele evento. | Sequencial';
COMMENT ON COLUMN SEPON."SLIDE"."IDIOMAS" IS 'Idiomas para os quais existe slide disponível (P=Português, I=Inglês ou PI=Ambos). | Idiomas';
COMMENT ON COLUMN SEPON."SLIDE"."TITULO" IS 'Título ou legenda do slide. Também utilizado como marcador para busca no site. | Título';
COMMENT ON COLUMN SEPON."SLIDE"."DESCR" IS 'Quando existem mais informações sobre o slide. | Descrição';
COMMENT ON COLUMN SEPON."SLIDE"."ARQUIVO" IS 'Arquivo do slide disponível no diretório de palestra correspondente. | Nome do Arquivo';
COMMENT ON COLUMN SEPON."SLIDE".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."SLIDE".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."SLIDE".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."SLIDE".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."SLIDE".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."SLIDE".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."SLIDE".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SYS_CONFIG_GLOBAL
CREATE TABLE SEPON."SYS_CONFIG_GLOBAL" (
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

ALTER TABLE SEPON."SYS_CONFIG_GLOBAL" ADD CONSTRAINT "ID_SYS_CONFIG_GLOBAL"
PRIMARY KEY("PARAM");

COMMENT ON TABLE SEPON."SYS_CONFIG_GLOBAL" IS 'Sistema | Armazena parâmetros globais do aplicativo. | Configuração Global';

COMMENT ON COLUMN SEPON."SYS_CONFIG_GLOBAL"."PARAM" IS 'Parametro. | Parâmetro';
COMMENT ON COLUMN SEPON."SYS_CONFIG_GLOBAL"."DESCR" IS 'Descrição. | Descrição';
COMMENT ON COLUMN SEPON."SYS_CONFIG_GLOBAL"."CONFIG" IS 'Configuração. | Configuração';
COMMENT ON COLUMN SEPON."SYS_CONFIG_GLOBAL"."PROP_EXTEND" IS 'Propriedades extendidas para configuração. | Propriedades';
COMMENT ON COLUMN SEPON."SYS_CONFIG_GLOBAL"."FORMATO" IS 'Formato de apresentação do campo MEMO, HTML ou vazio para texto comum. | Formato';
COMMENT ON COLUMN SEPON."SYS_CONFIG_GLOBAL".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."SYS_CONFIG_GLOBAL".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."SYS_CONFIG_GLOBAL".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."SYS_CONFIG_GLOBAL".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."SYS_CONFIG_GLOBAL".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."SYS_CONFIG_GLOBAL".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."SYS_CONFIG_GLOBAL".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SYS_CONFIG_USUARIO
CREATE TABLE SEPON."SYS_CONFIG_USUARIO" (
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

ALTER TABLE SEPON."SYS_CONFIG_USUARIO" ADD CONSTRAINT "ID_SYS_CONFIG_USUARIO"
PRIMARY KEY("USUARIO", "PARAM");

COMMENT ON TABLE SEPON."SYS_CONFIG_USUARIO" IS 'Sistema | Parâmetros específicos de usuários do sistema. | Configuração de Usuário';

COMMENT ON COLUMN SEPON."SYS_CONFIG_USUARIO"."USUARIO" IS 'Usuário. | Usuário';
COMMENT ON COLUMN SEPON."SYS_CONFIG_USUARIO"."PARAM" IS 'Parametro. | Parâmetro';
COMMENT ON COLUMN SEPON."SYS_CONFIG_USUARIO"."DESCR" IS 'Descrição. | Descrição';
COMMENT ON COLUMN SEPON."SYS_CONFIG_USUARIO"."CONFIG" IS 'Configuração. | Configuração';
COMMENT ON COLUMN SEPON."SYS_CONFIG_USUARIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."SYS_CONFIG_USUARIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."SYS_CONFIG_USUARIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."SYS_CONFIG_USUARIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."SYS_CONFIG_USUARIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."SYS_CONFIG_USUARIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."SYS_CONFIG_USUARIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SYS_DELETE
CREATE TABLE SEPON."SYS_DELETE" (
   "TABELA" VARCHAR2 (70),
   "CHAVE" VARCHAR2 (300),
   "MOMENTO" DATE,
   "USUARIO" VARCHAR2 (100),
   "LOCAL" VARCHAR2 (20)
);

ALTER TABLE SEPON."SYS_DELETE" ADD CONSTRAINT "ID_SYS_DELETE"
PRIMARY KEY("TABELA", "CHAVE");

COMMENT ON TABLE SEPON."SYS_DELETE" IS 'Sistema | Registro de exclusões do sistema. | Registro de Exclusões';

COMMENT ON COLUMN SEPON."SYS_DELETE"."TABELA" IS 'Nome da tabela onde a exclusão ocorreu. | Tabela';
COMMENT ON COLUMN SEPON."SYS_DELETE"."CHAVE" IS 'Conteúdo da chave do registro excluído. | Chave';
COMMENT ON COLUMN SEPON."SYS_DELETE"."MOMENTO" IS 'Momento em que ocorreu a exclusão. | Momento de Exclusão';
COMMENT ON COLUMN SEPON."SYS_DELETE"."USUARIO" IS 'Detalhes do usuário que efetuou a exclusão. | Usuário';
COMMENT ON COLUMN SEPON."SYS_DELETE"."LOCAL" IS 'De onde partiu a exclusão. | Local';

-- TABELA SYS_LOCALID
CREATE TABLE SEPON."SYS_LOCALID" (
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

ALTER TABLE SEPON."SYS_LOCALID" ADD CONSTRAINT "ID_SYS_LOCALID"
PRIMARY KEY("NOME");

COMMENT ON TABLE SEPON."SYS_LOCALID" IS 'Sistema | Especificações de localidade para sistema distribuído. | Detalhes de Localidade';

COMMENT ON COLUMN SEPON."SYS_LOCALID"."NOME" IS 'Nome em caso de sistema distribuído. | Nome';
COMMENT ON COLUMN SEPON."SYS_LOCALID"."CORRENTE" IS 'Marcado caso seja localidade corrente. | Corrente';
COMMENT ON COLUMN SEPON."SYS_LOCALID"."PACOTE" IS 'Número do último pacote gerado. | Pacote Gerado';
COMMENT ON COLUMN SEPON."SYS_LOCALID"."PACOTE_REC" IS 'Número do último pacote recebido. | Pacote Recebido';
COMMENT ON COLUMN SEPON."SYS_LOCALID"."MOMENTO" IS 'Momento do último pacote gerado. | Momento de Geração';
COMMENT ON COLUMN SEPON."SYS_LOCALID"."MOMENTO_REC" IS 'Momento do último pacote recebido. | Momento de Recebimento';
COMMENT ON COLUMN SEPON."SYS_LOCALID"."MODELO" IS 'Modelo. | Modelo';
COMMENT ON COLUMN SEPON."SYS_LOCALID"."DESCR" IS 'Descrição de localidade, responsabilidade ou qualquer texto que informe sobre a localidade. | Descrição';
COMMENT ON COLUMN SEPON."SYS_LOCALID"."OBS" IS 'Observações sobre a localidade. | Observações';
COMMENT ON COLUMN SEPON."SYS_LOCALID".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."SYS_LOCALID".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."SYS_LOCALID".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."SYS_LOCALID".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."SYS_LOCALID".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."SYS_LOCALID".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."SYS_LOCALID".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA SYS_OCORRENCIA
CREATE TABLE SEPON."SYS_OCORRENCIA" (
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

ALTER TABLE SEPON."SYS_OCORRENCIA" ADD CONSTRAINT "ID_SYS_OCORRENCIA"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SEPON."SYS_OCORRENCIA" IS 'Sistema | Registro de ocorrências do sistema. | Registro de Ocorrências';

COMMENT ON COLUMN SEPON."SYS_OCORRENCIA"."SEQ" IS 'Sequencial da ocorrência. | Sequencial';
COMMENT ON COLUMN SEPON."SYS_OCORRENCIA"."APLICACAO" IS 'Nome do aplicativo onde ocorreu o registro. | Aplicação';
COMMENT ON COLUMN SEPON."SYS_OCORRENCIA"."OCORRENCIA" IS 'Detalhes da ocorrência. | Ocorrência';
COMMENT ON COLUMN SEPON."SYS_OCORRENCIA"."USUARIO" IS 'Usuário logado no momento da ocorrência. | Usuário';
COMMENT ON COLUMN SEPON."SYS_OCORRENCIA"."MOMENTO" IS 'Momento em que ocorreu a situação. | Momento';
COMMENT ON COLUMN SEPON."SYS_OCORRENCIA"."LOCAL" IS 'Local onde ocorreu o registro. | Localidade';
COMMENT ON COLUMN SEPON."SYS_OCORRENCIA".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."SYS_OCORRENCIA".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."SYS_OCORRENCIA".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."SYS_OCORRENCIA".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."SYS_OCORRENCIA".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."SYS_OCORRENCIA".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."SYS_OCORRENCIA".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA TIPO_ACESSO
CREATE TABLE SEPON."TIPO_ACESSO" (
   "SEQ" NUMBER (11,0),
   "TITULO" VARCHAR2 (200),
   "DESCR" CLOB,
   "LIVRE" NUMBER (1,0),
   "GRATIS_HORAS" NUMBER (11,0),
   "CONTRAT_HORAS" NUMBER (11,0),
   "CONTRAT_VALOR_PERCENT" NUMBER (16,12),
   "ASSOCIADO" NUMBER (1,0),
   "CONVIDADO" NUMBER (1,0),
   "INSCRITO" NUMBER (1,0),
   "PARTICIPANTE_EVENTO" NUMBER (1,0),
   "GRATIS_ATE" DATE,
   "CONTRAT_ATE" DATE
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SEPON."TIPO_ACESSO" ADD CONSTRAINT "ID_TIPO_ACESSO"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SEPON."TIPO_ACESSO" IS 'SEPON | Forma padronizada de definição de acesso para determinado público. | Tipo de Acesso';

COMMENT ON COLUMN SEPON."TIPO_ACESSO"."SEQ" IS 'Sequencial do tipo de acesso. | Sequencial';
COMMENT ON COLUMN SEPON."TIPO_ACESSO"."TITULO" IS 'Título do tipo de acesso. | Título';
COMMENT ON COLUMN SEPON."TIPO_ACESSO"."DESCR" IS 'Detalhes sobre o tipo de acesso. | Descrição';
COMMENT ON COLUMN SEPON."TIPO_ACESSO"."LIVRE" IS 'Marcado se o acesso ao evento ou palestra é livre para este tipo de público. | Livre';
COMMENT ON COLUMN SEPON."TIPO_ACESSO"."GRATIS_HORAS" IS 'Gratuidade para público escolhido durante um período de horas. | Horas de Gratuidade';
COMMENT ON COLUMN SEPON."TIPO_ACESSO"."CONTRAT_HORAS" IS 'Horas de direito do contratado mediante pagamento de boleto. | Horas Contratadas';
COMMENT ON COLUMN SEPON."TIPO_ACESSO"."CONTRAT_VALOR_PERCENT" IS 'Percentual do valor a ser pago para contratação do período. | % do Valor';
COMMENT ON COLUMN SEPON."TIPO_ACESSO"."ASSOCIADO" IS 'Marcado para definição do público como associados SBD. | Associado';
COMMENT ON COLUMN SEPON."TIPO_ACESSO"."CONVIDADO" IS 'Marcado para definição do público como convidados. | Convidado';
COMMENT ON COLUMN SEPON."TIPO_ACESSO"."INSCRITO" IS 'Marcado para definição do público como inscritos. | Inscrito';
COMMENT ON COLUMN SEPON."TIPO_ACESSO"."PARTICIPANTE_EVENTO" IS 'Marcado para definição do público como participantes daquele evento. | Participante';
COMMENT ON COLUMN SEPON."TIPO_ACESSO"."GRATIS_ATE" IS 'Acesso gratuito até  a data especificada. | Grátis até';
COMMENT ON COLUMN SEPON."TIPO_ACESSO"."CONTRAT_ATE" IS 'Período contratado até a data especificada. | Contrato até';
COMMENT ON COLUMN SEPON."TIPO_ACESSO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."TIPO_ACESSO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."TIPO_ACESSO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."TIPO_ACESSO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."TIPO_ACESSO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."TIPO_ACESSO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."TIPO_ACESSO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA USUARIO
CREATE TABLE SEPON."USUARIO" (
   "SEQ" NUMBER (11,0),
   "CPF" VARCHAR2 (20),
   "IDIOMA_PREF" VARCHAR2 (1),
   "MATR_SBD" NUMBER (11,0),
   "CRM" VARCHAR2 (20),
   "NOME" VARCHAR2 (200),
   "LOGIN" VARCHAR2 (20),
   "SENHA" VARCHAR2 (20),
   "MOMENTO_INSCR" DATE,
   "VALIDO_ATE" DATE,
   "ASSOCIADO" NUMBER (1,0),
   "CONVIDADO" NUMBER (1,0),
   "INSCRITO" NUMBER (1,0),
   "OPERADOR" NUMBER (1,0),
   "ENDERECO" VARCHAR2 (200),
   "NUMERO" VARCHAR2 (20),
   "COMPLEMENTO" VARCHAR2 (20),
   "BAIRRO" VARCHAR2 (50),
   "CIDADE" VARCHAR2 (50),
   "ESTADO" VARCHAR2 (2),
   "CEP" VARCHAR2 (10),
   "PAIS" VARCHAR2 (50),
   "TEL_RES" VARCHAR2 (50),
   "TEL_COM" VARCHAR2 (50),
   "TEL_CEL" VARCHAR2 (50),
   "FAX" VARCHAR2 (50),
   "EMAIL" VARCHAR2 (200),
   "CARGO" VARCHAR2 (200),
   "INSTITUICAO" VARCHAR2 (200),
   "CANCEL" DATE
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SEPON."USUARIO" ADD CONSTRAINT "ID_USUARIO"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SEPON."USUARIO" IS 'SEPON | Usuários do sistema entre associados, convidados, inscritos, participantes e operadores. | Usuário';

COMMENT ON COLUMN SEPON."USUARIO"."SEQ" IS 'Sequencial do usuário. | Sequencial';
COMMENT ON COLUMN SEPON."USUARIO"."CPF" IS 'CPF a ser utilizado para qualquer controle AMB ou CFM. | CPF';
COMMENT ON COLUMN SEPON."USUARIO"."IDIOMA_PREF" IS 'Idioma de preferência do usuário (P=Português ou I=Inglês). | Idioma de Preferência';
COMMENT ON COLUMN SEPON."USUARIO"."MATR_SBD" IS 'Matrícula do associado. | Matrícula SBD';
COMMENT ON COLUMN SEPON."USUARIO"."CRM" IS 'CRM quando usuário for um médico registrado. | CRM';
COMMENT ON COLUMN SEPON."USUARIO"."NOME" IS 'Nome completo do usuário. | Nome Completo';
COMMENT ON COLUMN SEPON."USUARIO"."LOGIN" IS 'Login cadastrado pelo usuário no momento da sua inscrição. | Login Cadastrado';
COMMENT ON COLUMN SEPON."USUARIO"."SENHA" IS 'Senha definida pelo próprio usuário. | Senha';
COMMENT ON COLUMN SEPON."USUARIO"."MOMENTO_INSCR" IS 'Momento em que o usuário se inscreve. | Momento de Inscrição';
COMMENT ON COLUMN SEPON."USUARIO"."VALIDO_ATE" IS 'Validade deste login, ou seja, último momento em que o usuário poderá efetuar login em dd/MM/yyyy hh:mm. | Valido Até';
COMMENT ON COLUMN SEPON."USUARIO"."ASSOCIADO" IS 'Marcado se o usuário é um associado da SBD. | Associado';
COMMENT ON COLUMN SEPON."USUARIO"."CONVIDADO" IS 'Marcado se o usuário é um convidado da SBD. | Convidado';
COMMENT ON COLUMN SEPON."USUARIO"."INSCRITO" IS 'Marcado se o usuário foi inscrito no sistema de eventos. | Inscrito';
COMMENT ON COLUMN SEPON."USUARIO"."OPERADOR" IS 'Marcado se usuário é um operador do sistema. | Operador';
COMMENT ON COLUMN SEPON."USUARIO"."ENDERECO" IS 'Seu endereço completo, tipo (rua, av.), logradouro e número. | Endereço Completo';
COMMENT ON COLUMN SEPON."USUARIO"."NUMERO" IS 'Número. | Número';
COMMENT ON COLUMN SEPON."USUARIO"."COMPLEMENTO" IS 'Complemento. | Complemento';
COMMENT ON COLUMN SEPON."USUARIO"."BAIRRO" IS 'Bairro. | Bairro';
COMMENT ON COLUMN SEPON."USUARIO"."CIDADE" IS 'Cidade. | Cidade';
COMMENT ON COLUMN SEPON."USUARIO"."ESTADO" IS 'Estado. | Estado';
COMMENT ON COLUMN SEPON."USUARIO"."CEP" IS 'CEP designado para o logradouro. | CEP';
COMMENT ON COLUMN SEPON."USUARIO"."PAIS" IS 'País. | País';
COMMENT ON COLUMN SEPON."USUARIO"."TEL_RES" IS 'Número do telefone residencial no formato: DDI DDD e TELEFONE. | Telefone';
COMMENT ON COLUMN SEPON."USUARIO"."TEL_COM" IS 'Número do telefone comercial no formato: DDI DDD e TELEFONE. | Telefone';
COMMENT ON COLUMN SEPON."USUARIO"."TEL_CEL" IS 'Número do telefone celular: DDI DDD e TELEFONE. | Telefone Celular';
COMMENT ON COLUMN SEPON."USUARIO"."FAX" IS 'Fax. | Fax';
COMMENT ON COLUMN SEPON."USUARIO"."EMAIL" IS 'Email do usuário. | E-mail';
COMMENT ON COLUMN SEPON."USUARIO"."CARGO" IS 'Cargo. | Cargo';
COMMENT ON COLUMN SEPON."USUARIO"."INSTITUICAO" IS 'Nome da instituição onde trabalha. | Instituição onde Trabalha';
COMMENT ON COLUMN SEPON."USUARIO"."CANCEL" IS 'Data de cancelamento. | Data de Cancelamento';
COMMENT ON COLUMN SEPON."USUARIO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."USUARIO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."USUARIO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."USUARIO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."USUARIO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."USUARIO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."USUARIO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA VIDEO
CREATE TABLE SEPON."VIDEO" (
   "SEQ" NUMBER (11,0),
   "EVENTO_SEQ" NUMBER (11,0),
   "TITULO" VARCHAR2 (200),
   "DESCR" CLOB,
   "IDIOMA" VARCHAR2 (1),
   "PLAYB_ARQUIVO" VARCHAR2 (200),
   "DURACAO_MIN" NUMBER (11,0),
   "ORDEM" NUMBER (11,0),
   "MOMENTO_PUBLIC" DATE,
   "PALESTRANTE" CLOB
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SEPON."VIDEO" ADD CONSTRAINT "ID_VIDEO"
PRIMARY KEY("SEQ");

COMMENT ON TABLE SEPON."VIDEO" IS 'SEPON | Vídeos cadastrados no sistema. | Vídeo';

COMMENT ON COLUMN SEPON."VIDEO"."SEQ" IS 'Sequencial de vídeo. | Sequencial';
COMMENT ON COLUMN SEPON."VIDEO"."EVENTO_SEQ" IS 'Evento com o qual o vídeo se relaciona. | Evento';
COMMENT ON COLUMN SEPON."VIDEO"."TITULO" IS 'Título do vídeo. | Título';
COMMENT ON COLUMN SEPON."VIDEO"."DESCR" IS 'Descrição do vídeo. | Descrição';
COMMENT ON COLUMN SEPON."VIDEO"."IDIOMA" IS 'Idioma do vídeo (P=Português ou I=Inglês). | Idioma';
COMMENT ON COLUMN SEPON."VIDEO"."PLAYB_ARQUIVO" IS 'Arquivo de playback para eventos gravados. | Nome do Arquivo de Playback';
COMMENT ON COLUMN SEPON."VIDEO"."DURACAO_MIN" IS 'Duração deste vídeo em minutos. | Duração (mins)';
COMMENT ON COLUMN SEPON."VIDEO"."ORDEM" IS 'Ordem de apresentação ou posicionamento específico na tela. | Ordenação';
COMMENT ON COLUMN SEPON."VIDEO"."MOMENTO_PUBLIC" IS 'Momento em que o vídeo será publicado. | Publicar em';
COMMENT ON COLUMN SEPON."VIDEO"."PALESTRANTE" IS 'Palestrantes ou participantes para apresentação quando for evento. | Palestrante';
COMMENT ON COLUMN SEPON."VIDEO".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."VIDEO".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."VIDEO".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."VIDEO".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."VIDEO".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."VIDEO".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."VIDEO".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

-- TABELA VIDEO_ASSIST
CREATE TABLE SEPON."VIDEO_ASSIST" (
   "VIDEO_SEQ" NUMBER (11,0),
   "SEQ" NUMBER (11,0),
   "MOMENTO" DATE,
   "USUARIO_SEQ" NUMBER (11,0),
   "NAVEGADOR" CLOB,
   "DURACAO_MIN" NUMBER (16,4)
,
   SYS_MOMENTO_CRIA DATE,
   SYS_USUARIO_CRIA VARCHAR2 (100),
   SYS_LOCAL_CRIA VARCHAR2 (100),
   SYS_MOMENTO_ATUALIZA DATE,
   SYS_USUARIO_ATUALIZA VARCHAR2 (100),
   SYS_LOCAL_ATUALIZA VARCHAR2 (100),
   SYS_STATUS CHAR (1)
);

ALTER TABLE SEPON."VIDEO_ASSIST" ADD CONSTRAINT "ID_VIDEO_ASSIST"
PRIMARY KEY("VIDEO_SEQ", "SEQ");

COMMENT ON TABLE SEPON."VIDEO_ASSIST" IS 'SEPON | Audiência de vídeos do sistema. | Vídeo Assistido';

COMMENT ON COLUMN SEPON."VIDEO_ASSIST"."VIDEO_SEQ" IS 'Vídeo que foi assistido pelo usuário. | Vídeo Assistido';
COMMENT ON COLUMN SEPON."VIDEO_ASSIST"."SEQ" IS 'Sequencial de vezes que o vídeo foi assistido. | Sequencial';
COMMENT ON COLUMN SEPON."VIDEO_ASSIST"."MOMENTO" IS 'Momento no qual o vídeo foi assistido. | Momento';
COMMENT ON COLUMN SEPON."VIDEO_ASSIST"."USUARIO_SEQ" IS 'Usuário que assistiu o vídeo. | Usuário';
COMMENT ON COLUMN SEPON."VIDEO_ASSIST"."NAVEGADOR" IS 'Detalhes sobre o navegador do cliente. | Navegador';
COMMENT ON COLUMN SEPON."VIDEO_ASSIST"."DURACAO_MIN" IS 'Duração em minutos do tempo pelo qual, supostamente, o vídeo foi assistido. | Duração (mins)';
COMMENT ON COLUMN SEPON."VIDEO_ASSIST".SYS_MOMENTO_CRIA IS 'Registra momento de gravação. | Momento de Criação';
COMMENT ON COLUMN SEPON."VIDEO_ASSIST".SYS_USUARIO_CRIA IS 'Registra usuário que gravou. | Usuário que Criou';
COMMENT ON COLUMN SEPON."VIDEO_ASSIST".SYS_LOCAL_CRIA IS 'Registra local de gravação. | Local de Criação';
COMMENT ON COLUMN SEPON."VIDEO_ASSIST".SYS_MOMENTO_ATUALIZA IS 'Registra momento de atualização. | Momento de Atualização';
COMMENT ON COLUMN SEPON."VIDEO_ASSIST".SYS_USUARIO_ATUALIZA IS 'Registra usuário que atualizou. | Usuário que Alterou';
COMMENT ON COLUMN SEPON."VIDEO_ASSIST".SYS_LOCAL_ATUALIZA IS 'Registra local de atualização. | Local de Alteração';
COMMENT ON COLUMN SEPON."VIDEO_ASSIST".SYS_STATUS IS 'Status do registro entre I=Incluído, A=Alterado ou Vazio=Sem modificação. | Status do Registro';

/* **********************************************************************************
   CRIAÇÃO DE TABELAS DO SISTEMA
*/


-- TABELA DE SISTEMA - GRANTS GERAIS
GRANT SELECT ON SEPON.SYS_CONFIG_GLOBAL TO PUBLIC;
GRANT SELECT ON SEPON.SYS_CONFIG_USUARIO TO PUBLIC;
GRANT SELECT ON SEPON.SYS_DELETE TO PUBLIC;
GRANT SELECT ON SEPON.SYS_LOCALID TO PUBLIC;
GRANT SELECT ON SEPON.SYS_OCORRENCIA TO PUBLIC;
SPOOL OFF


-- EXEMPLO PARA IMPORT DE INFORMAÇÕES E 
-- CÓDIGO PARA ELIMINAR OBJETOS IMPORTADOS EQUIVOCADAMENTE

SET SERVEROUTPUT ON SIZE 40000
SET ECHO OFF
SELECT
'EXP SEPON/XXXX@SBDB OWNER=(SEPON) FILE=SEPON.DMP LOG=SEPON_EXP.LOG' || CHR(13) || CHR(10) ||
'IMP SEPON/XXXX@SBDB FROMUSER=SEPON CONSTRAINTS=NO GRANTS=NO FILE=SEPON.DMP LOG=SEPON_IMP.LOG IGNORE=YES' || CHR(13) || CHR(10) ||
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
$ECHO - >>"C:\SEPON_PARTES.LOG"
$ECHO - >>"C:\SEPON_PARTES.LOG"
$ECHO - >>"C:\SEPON_PARTES.LOG"
$COMMAND /C ECHO %DATE% %TIME% >>"C:\SEPON_PARTES.LOG"
$COMMAND /C FIND "ORA-" "C:\SEPON_PARTE1.LOG" >>"C:\SEPON_PARTES.LOG"
$COMMAND /C FIND "SP2-" "C:\SEPON_PARTE1.LOG" >>"C:\SEPON_PARTES.LOG"
