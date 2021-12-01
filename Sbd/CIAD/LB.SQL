create or replace package lb is

	function litem(Texto in varchar2, Item in number, Sep in varchar2 default '') return varchar2;
	function litem(Texto in varchar2, Item in varchar2, Sep in varchar2 default '') return number;
	function lparam(Campo in varchar2, tipo in varchar2) return varchar2;
	function lustr(Texto in varchar2) return varchar2;
	function lextenso(VV in number, Ling in varchar2) return varchar2;
	function lmontacento(Strv0 in varchar2, StrCem in varchar2, Sep in varchar2, StrDez in varchar2, StrPrimaDez in varchar2, StrUnid in varchar2) return varchar2;
	function lconcatcamp(Dominio in varchar2, Delimit in varchar2) return varchar2;
	function lnumling(Num in number, Masc in varchar2, Ling in varchar2) return varchar2;
        function LInsereEspaco(Str in varchar2, Tamanho in number) return varchar2;


end lb;
/ 


create or replace package body lb is
	

	function litem(Texto in varchar2, Item in number, Sep in varchar2 default '') return varchar2 is
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



	function litem(Texto in varchar2, Item in varchar2, Sep in varchar2 default '') return number is
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


	function lparam(Campo in varchar2, Tipo in varchar2) return varchar2 is
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


	function lustr(Texto in varchar2) return varchar2 is
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
	    		StrDez := 'Ten;Twenty;Thirty;Forty;Fifty;Sixty;Seventy;Eighty;Ninety';
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
	    		StrDez := 'Ten;Twenty;Thirty;Forty;Fifty;Sixty;Seventy;Eighty;Ninety';
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
	    		StrDez := 'Ten;Twenty;Thirty;Forty;Fifty;Sixty;Seventy;Eighty;Ninety';
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


	function lmontacento (Strv0 in varchar2, StrCem in varchar2, Sep in varchar2, StrDez in varchar2, StrPrimaDez in varchar2, StrUnid in varchar2) return varchar2 is
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


	function lconcatcamp(Dominio in varchar2, Delimit in varchar2) return varchar2 is
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


end lb;
/


