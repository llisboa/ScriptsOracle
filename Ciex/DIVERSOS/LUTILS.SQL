create or replace package lutils is

        procedure drop_user_tables;
	procedure disable_user_triggers;
	procedure enable_user_triggers;
	procedure cria_views_sql;
	procedure drop_user_views;
	procedure atualiza_serv;

	function servidor return varchar2;

	procedure compara(esquema1 in varchar2, esquema2 in varchar2);

end;
/
create or replace package body lutils is

	procedure drop_user_tables is
	cursor tabs is select table_name from user_tables;
        sqlcursor integer;

	begin
                sqlcursor := dbms_sql.open_cursor;
		for cur in tabs loop
			dbms_sql.parse(sqlcursor, 'DROP TABLE ' || cur.TABLE_NAME || ' CASCADE CONSTRAINTS', dbms_sql.v7);
		end loop;
		dbms_sql.close_cursor(sqlcursor);
	end;

	procedure atualiza_serv is
	txt varchar2(4000);
	begin
		UPDATE SYS_CONFIG_GLOBAL SET CONFIG = LUTILS.SERVIDOR WHERE PARAM = 'Servidor';

		txt := '';
		for cur in (select table_name from all_tables where owner = 'CXRJ' and tablespace_name <> 'TRANSF') loop
			txt := txt || ';' || cur.table_name;
		end loop;
		UPDATE SYS_CONFIG_GLOBAL SET CONFIG = SUBSTR(txt,2) where PARAM = 'Tabelas';

		txt := '';
		for cur in (select view_name from all_views where owner = 'CXRJ') loop
			txt := txt || ';' || cur.view_name;
		end loop;
		UPDATE SYS_CONFIG_GLOBAL SET CONFIG = SUBSTR(txt,2) where PARAM = 'Visões';

	end;

	procedure drop_user_views is
	cursor tabs is select view_name from user_views;
        sqlcursor integer;

	begin
                sqlcursor := dbms_sql.open_cursor;
		for cur in tabs loop
			dbms_sql.parse(sqlcursor, 'DROP VIEW ' || cur.VIEW_NAME, dbms_sql.v7);
		end loop;
		dbms_sql.close_cursor(sqlcursor);
	end;



	procedure disable_user_triggers is
	cursor tabs is select TRIGGER_NAME from USER_TRIGGERS;
        sqlcursor integer;

	begin
                sqlcursor := dbms_sql.open_cursor;
		for cur in tabs loop
			dbms_sql.parse(sqlcursor, 'ALTER TRIGGER ' || cur.TRIGGER_NAME || ' DISABLE', dbms_sql.v7);
		end loop;
		dbms_sql.close_cursor(sqlcursor);
	end;


	procedure enable_user_triggers is
	cursor tabs is select TRIGGER_NAME from USER_TRIGGERS;
        sqlcursor integer;

	begin
                sqlcursor := dbms_sql.open_cursor;
		for cur in tabs loop
			dbms_sql.parse(sqlcursor, 'ALTER TRIGGER ' || cur.TRIGGER_NAME || ' ENABLE', dbms_sql.v7);
		end loop;
		dbms_sql.close_cursor(sqlcursor);
	end;


	procedure cria_views_sql is
	reglog utl_file.file_type;
	reglogSP utl_file.file_type;	
	reglogBH utl_file.file_type;

	begin
	        begin
	                reglog := utl_file.fopen(DBMS_CX.PUBLIC_DIR(), 'VIEWS_CXRJ.SQL', 'w', 4000);
	                reglogSP := utl_file.fopen(DBMS_CX.PUBLIC_DIR(), 'VIEWS_CXSP.SQL', 'w', 4000);
	                reglogBH := utl_file.fopen(DBMS_CX.PUBLIC_DIR(), 'VIEWS_CXBH.SQL', 'w', 4000);
	        exception
	                when others then
	                        raise_application_error ( -20000, 'erro ao tentar abrir o arquivo de resultado -> ' || SQLCODE || ':' || SQLERRM);
	        end;

		declare
			cursor vw is select view_name, text from user_views;
		begin
			for cur in vw loop
				utl_file.put_line(reglog, 'EXEC DBMS_OUTPUT.PUT_LINE(''--> view ' || cur.view_name || ''');');
				utl_file.put_line(reglog, 'CREATE OR REPLACE VIEW ' || cur.view_name || ' AS');
				utl_file.put_line(reglog, REPLACE(REPLACE(cur.text, 'CXSP', 'CXRJ'), 'CXBH', 'CXRJ'));
				utl_file.put_line(reglog, '/');
				utl_file.new_line(reglog);

				utl_file.put_line(reglogSP, 'EXEC DBMS_OUTPUT.PUT_LINE(''--> view ' || cur.view_name || ''');');
				utl_file.put_line(reglogSP, 'CREATE OR REPLACE VIEW ' || cur.view_name || ' AS');
				utl_file.put_line(reglogSP, REPLACE(REPLACE(cur.text, 'CXRJ', 'CXSP'), 'CXBH', 'CXSP'));
				utl_file.put_line(reglogSP, '/');
				utl_file.new_line(reglogSP);

				utl_file.put_line(reglogBH, 'EXEC DBMS_OUTPUT.PUT_LINE(''--> view ' || cur.view_name || ''');');
				utl_file.put_line(reglogBH, 'CREATE OR REPLACE VIEW ' || cur.view_name || ' AS');
				utl_file.put_line(reglogBH, REPLACE(REPLACE(cur.text, 'CXRJ', 'CXBH'), 'CXSP', 'CXBH'));
				utl_file.put_line(reglogBH, '/');
				utl_file.new_line(reglogBH);
			end loop;		
	        exception
	                when others then
	                        raise_application_error ( -20000, 'erro enquanto dump das views no arquivo -> ' || SQLCODE || ':' || SQLERRM);
	        end;

	        utl_file.fclose(reglog);
	        utl_file.fclose(reglogSP);	        
		utl_file.fclose(reglogBH);
	exception
	        when others then
        	        if utl_file.is_open(reglog) then
	                        utl_file.fclose(reglog);
        	        end if;
	                raise_application_error ( -20000, 'erro durante a criação de VIEWS.SQL -> ' || SQLCODE || ':' || SQLERRM );
	end;

	function servidor return varchar2 is
	servidor varchar2(200);		

	begin
		SELECT MACHINE INTO servidor FROM V$SESSION WHERE OSUSER LIKE 'SYSTEM%' AND TYPE LIKE 'BACKGROUND%' AND ROWNUM = 1;
		return servidor;
	end;

	procedure compara(esquema1 in varchar2, esquema2 in varchar2) is

	reglog utl_file.file_type;
	type type_cursor is ref cursor;
	pesquisa type_cursor;
	txt varchar2(200);
	primalinha boolean;

	begin
		
	        begin
	                reglog := utl_file.fopen(DBMS_CX.PUBLIC_DIR(), 'RESULT_' || esquema1 || '_' || esquema2 || '.TXT', 'w');
	        exception
	                when others then
	                        raise_application_error ( -20000, 'erro ao tentar abrir o arquivo de resultado -> ' || SQLCODE || ':' || SQLERRM);
	        end;

	        -- tabelas que existem no esquema1 e não existem no esquema2
	        begin
			open pesquisa for 
				select Q1.table_name from
				(select table_name from all_tables where owner = esquema1) Q1, 
				(select table_name from all_tables where owner = esquema2) Q2
				where Q1.table_name = Q2.table_name (+) and
				Q2.table_name is null;
			primalinha := true;
			loop
				fetch pesquisa into txt;
				exit when pesquisa%notfound;
				if primalinha then
					utl_file.new_line(reglog);
					utl_file.put_line(reglog, '===== TABELAS EXISTENTES NO ' || esquema1 || ' QUE NÃO EXISTEM NO ' || esquema2 || ' =====');
					primalinha := false;
				end if;
				utl_file.put_line(reglog, txt);
			end loop;
			close pesquisa;

	        exception
	                when others then
	                        raise_application_error ( -20000, 'erro verificando tabelas existentes no esquema ' || esquema1 || ' que não existiam no esquema ' || esquema2 || ' -> ' || SQLCODE || ':' || SQLERRM );
	        end;



	        -- tabelas que existem no esquema2 e não existem no esquema1
	        begin
			open pesquisa for 
				select Q2.table_name from
				(select table_name from all_tables where owner = esquema2) Q2, 
				(select table_name from all_tables where owner = esquema1) Q1
				where Q2.table_name = Q1.table_name (+) and
				Q1.table_name is null;
			primalinha := true;
			loop
				fetch pesquisa into txt;
				exit when pesquisa%notfound;
				if primalinha then
					utl_file.new_line(reglog);
					utl_file.put_line(reglog, '===== TABELAS EXISTENTES NO ' || esquema2 || ' QUE NÃO EXISTEM NO ' || esquema1 || ' =====');
					primalinha := false;
				end if;
				utl_file.put_line(reglog, txt);
			end loop;
			close pesquisa;

	        exception
	                when others then
	                        raise_application_error ( -20000, 'erro verificando tabelas existentes no esquema ' || esquema2 || ' que não existiam no esquema ' || esquema1 || ' -> ' || SQLCODE || ':' || SQLERRM );
	        end;


		-- looping entre as tabelas comuns
		declare
			cursor tabelas is 
				select Q1.table_name from
				(select table_name from all_tables where owner = esquema1) Q1, 
				(select table_name from all_tables where owner = esquema2) Q2
				where Q1.table_name = Q2.table_name;
		begin
			null;
			-- for cur in tabelas loop
			
				-- registro no esquema1 que não existem no esquema2
				-- open pesquisa for 

			
			-- end loop;
		exception
	                when others then
	                        raise_application_error ( -20000, 'erro durante looping entre tabelas comuns -> ' || SQLCODE || ':' || SQLERRM );
		end;



	        utl_file.fclose(reglog);
	exception
        when others then
                if utl_file.is_open(reglog) then
                        utl_file.fclose(reglog);
                end if;
                raise_application_error ( -20000, 'erro durante a comparação -> ' || SQLCODE || ':' || SQLERRM );
	end;

end;
/
