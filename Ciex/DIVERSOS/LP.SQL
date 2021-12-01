create or replace package lp is

	function lrefdoc(FEmb in varchar2, FDoc in number) return varchar2;
	procedure limportacialogo(Dir in varchar2, Arq in varchar2, CiaCod in varchar2);
	procedure limportassinatura(Dir in varchar2, Arq in varchar2, usuário_p in varchar2);
	function lordem(Texto in varchar2) return varchar2;
	procedure prog_atualiza_stat (nome_prog in varchar2, hora_exec in varchar2,  intervalo_horas in varchar2 default '168');
--	procedure atualiza_stat;

end lp;
/ 


create or replace package body lp is
	

	function lrefdoc(FEmb in varchar2, FDoc in number) return varchar2 is
	begin
		for cur in 
		(SELECT DISTINCT * FROM (select 
		EMB_DOC_REL.EMB_REL EMB_REF
		FROM EMB_DOC, EMB_DOC_REL
		WHERE EMB_DOC.EMB_REF = EMB_DOC_REL.EMB_REF (+) AND
		EMB_DOC.SEQ = EMB_DOC_REL.DOC (+) AND
		EMB_DOC.EMB_REF = FEmb AND
		EMB_DOC.SEQ = FDoc UNION
		SELECT EMB_REF FROM EMB_DOC WHERE
		EMB_DOC.EMB_REF = FEmb AND
		EMB_DOC.SEQ = FDoc) ORDER BY 1) loop

				
			dbms_output.put_line(cur.emb_ref);			

		end loop;

	exception
		when others then
			raise_application_error ( -20000, 'erro em refdoc: ' || SQLERRM);

	end lrefdoc;

	
	procedure limportacialogo(Dir in varchar2, Arq in varchar2, CiaCod in varchar2) is
	Tam integer;
	Orig bfile := bfilename(Dir, Arq);
	Dest blob;
	begin
		dbms_lob.createtemporary(Dest, true, dbms_lob.session);
		dbms_lob.open(Orig, dbms_lob.lob_readonly);
		dbms_lob.open(Dest, dbms_lob.lob_readwrite);
		Tam := dbms_lob.getlength(Orig);
		
		dbms_lob.loadfromfile(Dest, Orig, Tam);
		update CIA set LOGO = Dest where lb.litem(CiaCod, COD) <> 0;
		
		dbms_lob.close(Orig);
		dbms_lob.close(Dest);
	end limportacialogo;


	
	procedure limportassinatura(Dir in varchar2, Arq in varchar2, usuário_p in varchar2) is
	Tam integer;
	Orig bfile := bfilename(Dir, Arq);
	Dest blob;
	begin
		dbms_lob.createtemporary(Dest, true, dbms_lob.session);
		dbms_lob.open(Orig, dbms_lob.lob_readonly);
		dbms_lob.open(Dest, dbms_lob.lob_readwrite);
		Tam := dbms_lob.getlength(Orig);
		
		dbms_lob.loadfromfile(Dest, Orig, Tam);
		update SYS_USUÁRIO set ASSINATURA = Dest where lb.litem(usuário_p,USUÁRIO) <> 0;
		
		dbms_lob.close(Orig);
		dbms_lob.close(Dest);
	end limportassinatura ;



	function lordem(Texto in varchar2) return varchar2 is
	Ret varchar2(100);
	Ano number;
	begin
		Ano := to_number(substr(Texto, 6, 2));
		Ret := lpad(Texto, 5);
		if Ano < 60 then
			Ret := Ret || '20';
		else
			Ret := Ret || '19';
		end if;
		Ret := Ret || substr(Texto, 6);
		return Ret;	
	end lordem;	
	

	procedure prog_atualiza_stat (nome_prog in varchar2, hora_exec in varchar2,  intervalo_horas in varchar2 default '168');
	begin
                begin
			  for cur in (select job from user_jobs where what like '% ' || nome_prog || ' %') loop
	                       dbms_job.remove(cur.job);
                          end loop;
 		exception
		          when others then
        	          null;
	        end;
                dbms_job.submit(job,'/* '|| nome_prog ||', to_date('' || to_char(sysdate,'DD-MM-YYYY') || '' || hora_exec ||''),'SYSDATE+(' || intervalo_horas || '/24)');
	end;    	

	
--	procedure atualiza_stat is 
--        begin
--             delete * from icft.teste;
--             insert into icft.teste select * from icft.realizado_com_duração where INI >= TO_DATE('01-02-03 00:00:00', 'DD-MM-YY HH24:MI:SS') and INI <= TO_DATE('22-03-03 00:00:00', 'DD-MM-YY HH24:MI:SS')
--        end;



end lp;
/
