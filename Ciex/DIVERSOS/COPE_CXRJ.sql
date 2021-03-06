-----------------------------------------------------------------------------
-- C?DIGO DE IMPLEMENTA??O DE AUTOMA??ES PARA EMBARQUE CIEX OPERACIONAL
-- 
-- desenvolvedor...: Luciano Lisb?a -- data: 16/06/2002
-- programa assist.: HOTT -- data: 10/08/2002
--
-----------------------------------------------------------------------------

create or replace package cope_cxrj is

        FUNCTION SUB_TOTAL_LIQ (SEQ in number, DOC in Number)  return number;
	FUNCTION SUB_TOTAL_PREC (SEQ IN NUMBER, DOC IN NUMBER) return number;
	FUNCTION SUB_TOTAL_VOL (SEQ IN NUMBER, DOC IN NUMBER) return number;
	FUNCTION TOT_GERAL_LIQ (DOC IN NUMBER) return number;
	FUNCTION TOT_GERAL_PREC (DOC IN NUMBER) return number;
	FUNCTION SUB_TOTAL_BRUTO_PKL (SEQ IN NUMBER, DOC IN NUMBER) return number;
	FUNCTION SUB_TOTAL_LIQ_PKL (SEQ IN NUMBER, DOC IN NUMBER) return number;
	FUNCTION SUB_TOTAL_VOL_PKL (SEQ IN NUMBER, DOC IN NUMBER) return number;
	FUNCTION TOT_GERAL_LIQ_MERCOSUL (DOC IN NUMBER) return number;
	FUNCTION TOT_GERAL_LIQ_BOLIVIA (DOC IN NUMBER) return number;
	FUNCTION TOT_GERAL_LIQ_CHILE (DOC IN NUMBER) return number;
	FUNCTION TOT_GERAL_LIQ_ALADI (DOC IN NUMBER) return number;
	FUNCTION TOT_GERAL_LIQ_COMERCIO (DOC IN NUMBER) return number;
	FUNCTION TOT_GERAL_LIQ_FIRJAN (DOC IN NUMBER) return number;
	FUNCTION TOT_GERAL_LIQ_RODOV (DOC IN NUMBER) return number;
	FUNCTION TOT_GERAL_LIQ_PKL (DOC IN NUMBER) return number;
end;
/


create or replace package body cope_cxrj is


	FUNCTION SUB_TOTAL_LIQ (SEQ IN NUMBER, DOC IN NUMBER) return number is
	VALOR number;
	CC NUMBER;
	SOMA NUMBER;
	SOMA_AUX NUMBER;
	SOMA_FAM NUMBER;
	TOT_ITEM NUMBER;
	CONTROL NUMBER;
	cursor C_REC is SELECT DOC_SEQ, SEQ_ITEM, FAM?LIA, PESO_L?QUIDO FROM DOC_FATURA_DET WHERE DOC_SEQ = DOC ORDER BY SEQ_ITEM;
	V_REC C_REC%ROWTYPE;

	BEGIN
	CC:=0;
	SOMA:=0;
	TOT_ITEM := 0;
	CONTROL := 0;
	SOMA_FAM := 0;

	OPEN C_REC;
	WHILE CC < SEQ LOOP
		IF V_REC.FAM?LIA IS NULL AND NOT V_REC.PESO_L?QUIDO IS NULL THEN
			SOMA := SOMA + V_REC.PESO_L?QUIDO;
			TOT_ITEM := TOT_ITEM + 1;
		ELSE
			SOMA_AUX := SOMA;
			SOMA:=0;
			TOT_ITEM := 0;
		END IF;
	FETCH C_REC INTO V_REC;	 
	CC:= V_REC.SEQ_ITEM;
	END LOOP;

	IF NVL(SOMA,'') <> '' THEN
 		SOMA_AUX := SOMA;
	END IF;
	IF (SEQ = CC AND V_REC.PESO_L?QUIDO IS NULL AND SOMA > 0) THEN
		VALOR:= SOMA;
	ELSE
		VALOR:= NULL;
	END IF;

        if TOT_ITEM < 2 then
             VALOR := NULL;
        end if;
		
        SELECT COUNT(FAM?LIA) INTO SOMA_FAM FROM DOC_FATURA_DET WHERE (DOC_SEQ = DOC) AND (NVL(FAM?LIA,' ') <> ' ');
        if SOMA_FAM < 2 then
           VALOR := NULL;
        end if;

	CLOSE C_REC;

	RETURN VALOR;

	END SUB_TOTAL_LIQ ;

	FUNCTION SUB_TOTAL_PREC (SEQ IN NUMBER, DOC IN NUMBER) return number IS
	VALOR number;
	CC NUMBER;
	SOMA NUMBER;
	SOMA_AUX NUMBER;
	cursor C_REC is SELECT DOC_SEQ, SEQ_ITEM, FAM?LIA, PRE?O_UNIT, PESO_L?QUIDO FROM DOC_FATURA_DET WHERE DOC_SEQ = DOC ORDER BY SEQ_ITEM;
	V_REC C_REC%ROWTYPE;
	BEGIN
	CC:=0;
	SOMA:=0;
	OPEN C_REC;
	WHILE CC < SEQ LOOP

		IF V_REC.FAM?LIA IS NULL AND NOT V_REC.PRE?O_UNIT IS NULL THEN
			SOMA := SOMA + ROUND(V_REC.PRE?O_UNIT* V_REC.PESO_L?QUIDO,2);
		ELSE
			SOMA_AUX := SOMA;
			SOMA:=0;
		END IF;
	FETCH C_REC INTO V_REC;	 
	CC:= V_REC.SEQ_ITEM;

	END LOOP;

	IF NVL(SOMA,'') <> '' THEN
 		SOMA_AUX := SOMA;
	END IF;
	IF (SEQ = CC AND V_REC.PRE?O_UNIT IS NULL AND SOMA > 0) THEN
		VALOR:= SOMA;
	ELSE
		VALOR:= NULL;
	END IF;

	CLOSE C_REC;

	RETURN (VALOR);
	END SUB_TOTAL_PREC;


	FUNCTION SUB_TOTAL_VOL (SEQ IN NUMBER, DOC IN NUMBER) return number IS
	VALOR number;
	CC NUMBER;
	SOMA NUMBER;
	SOMA_AUX NUMBER;

	cursor C_REC is SELECT DOC_SEQ, SEQ_ITEM, FAM?LIA, VOLUME FROM DOC_FATURA_DET WHERE DOC_SEQ = DOC ORDER BY SEQ_ITEM;
	V_REC C_REC%ROWTYPE;

	BEGIN
	CC:=0;
	SOMA:=0;
	OPEN C_REC;
	WHILE CC < SEQ LOOP

	IF V_REC.FAM?LIA IS NULL AND NOT V_REC.VOLUME IS NULL THEN
		SOMA := SOMA + V_REC.VOLUME;
	ELSE
		SOMA_AUX := SOMA;
		SOMA:=0;
	END IF;
	FETCH C_REC INTO V_REC;	 
	CC:= V_REC.SEQ_ITEM;

	END LOOP;

	IF NVL(SOMA,'') <> '' THEN
 		SOMA_AUX := SOMA;
	END IF;
	IF (SEQ = CC AND V_REC.VOLUME IS NULL AND SOMA > 0) THEN
		VALOR:= SOMA;
	ELSE
		VALOR:= NULL;
	END IF;

	CLOSE C_REC;

	RETURN (VALOR);
	END SUB_TOTAL_VOL;


	FUNCTION TOT_GERAL_PREC (DOC IN NUMBER) return number is
	TOT NUMBER;
	TOT_PRE?O NUMBER;
	
	begin
	TOT := 0;	
	TOT_PRE?O := 0;

	For CUR_ITEM in (SELECT PESO_L?QUIDO, PRE?O_UNIT FROM DOC_FATURA_DET WHERE DOC_SEQ = DOC) loop
	   IF NVL(CUR_ITEM.PESO_L?QUIDO,0) <> 0 THEN
		TOT_PRE?O := TOT_PRE?O + ROUND(CUR_ITEM.PESO_L?QUIDO*CUR_ITEM.PRE?O_UNIT,2);
		TOT := TOT + 1;
	   END IF;
	end loop;
	
	IF TOT < 2 THEN
	   RETURN NULL;
	ELSE
	   RETURN (TOT_PRE?O);
	END IF;

	END TOT_GERAL_PREC;

	FUNCTION TOT_GERAL_LIQ (DOC IN NUMBER) return number is
	TOT NUMBER;
	TOT_LIQ NUMBER;
	
	begin
	TOT := 0;	
	TOT_LIQ := 0;

	For CUR_ITEM in (SELECT PESO_L?QUIDO FROM DOC_FATURA_DET WHERE DOC_SEQ = DOC) loop
	   IF NVL(CUR_ITEM.PESO_L?QUIDO,0) <> 0 THEN
		TOT_LIQ := TOT_LIQ + CUR_ITEM.PESO_L?QUIDO;
		TOT := TOT + 1;
	   END IF;
	end loop;
	
	IF TOT < 2 THEN
	   RETURN NULL;
	ELSE
	   RETURN (TOT_LIQ);
	END IF;

	END TOT_GERAL_LIQ;




	FUNCTION SUB_TOTAL_BRUTO_PKL (SEQ IN NUMBER, DOC IN NUMBER) return number is
	VALOR number;
	CC NUMBER;
	SOMA NUMBER;
	SOMA_AUX NUMBER;
	SOMA_FAM NUMBER;
	TOT_ITEM NUMBER;
	CONTROL NUMBER;
	cursor C_REC is SELECT DOC_SEQ, SEQ_ITEM, FAM?LIA, PESO_BRUTO FROM DOC_PLIST_WEIG_CERT_DET WHERE DOC_SEQ = DOC ORDER BY SEQ_ITEM;
	V_REC C_REC%ROWTYPE;

	BEGIN
	CC:=0;
	SOMA:=0;
	TOT_ITEM := 0;
	CONTROL := 0;
	SOMA_FAM := 0;

	OPEN C_REC;
	WHILE CC < SEQ LOOP
		IF V_REC.FAM?LIA IS NULL AND NOT V_REC.PESO_BRUTO IS NULL THEN
			SOMA := SOMA + V_REC.PESO_BRUTO;
			TOT_ITEM := TOT_ITEM + 1;
		ELSE
			SOMA_AUX := SOMA;
			SOMA:=0;
			TOT_ITEM := 0;
		END IF;
	FETCH C_REC INTO V_REC;	 
	CC:= V_REC.SEQ_ITEM;
	END LOOP;

	IF NVL(SOMA,'') <> '' THEN
 		SOMA_AUX := SOMA;
	END IF;
	IF (SEQ = CC AND V_REC.PESO_BRUTO IS NULL AND SOMA > 0) THEN
		VALOR:= SOMA;
	ELSE
		VALOR:= NULL;
	END IF;

        if TOT_ITEM < 2 then
             VALOR := NULL;
        end if;
		
        SELECT COUNT(FAM?LIA) INTO SOMA_FAM FROM DOC_PLIST_WEIG_CERT_DET WHERE (DOC_SEQ = DOC) AND (NVL(FAM?LIA,' ') <> ' ');
        if SOMA_FAM < 2 then
           VALOR := NULL;
        end if;

	CLOSE C_REC;

	RETURN VALOR;

	END SUB_TOTAL_BRUTO_PKL ;

	FUNCTION SUB_TOTAL_LIQ_PKL (SEQ IN NUMBER, DOC IN NUMBER) return number is
	VALOR number;
	CC NUMBER;
	SOMA NUMBER;
	SOMA_AUX NUMBER;
	SOMA_FAM NUMBER;
	TOT_ITEM NUMBER;
	CONTROL NUMBER;
	cursor C_REC is SELECT DOC_SEQ, SEQ_ITEM, FAM?LIA, PESO_L?QUIDO FROM DOC_PLIST_WEIG_CERT_DET WHERE DOC_SEQ = DOC ORDER BY SEQ_ITEM;
	V_REC C_REC%ROWTYPE;

	BEGIN
	CC:=0;
	SOMA:=0;
	TOT_ITEM := 0;
	CONTROL := 0;
	SOMA_FAM := 0;

	OPEN C_REC;
	WHILE CC < SEQ LOOP
		IF V_REC.FAM?LIA IS NULL AND NOT V_REC.PESO_L?QUIDO IS NULL THEN
			SOMA := SOMA + V_REC.PESO_L?QUIDO;
			TOT_ITEM := TOT_ITEM + 1;
		ELSE
			SOMA_AUX := SOMA;
			SOMA:=0;
			TOT_ITEM := 0;
		END IF;
	FETCH C_REC INTO V_REC;	 
	CC:= V_REC.SEQ_ITEM;
	END LOOP;

	IF NVL(SOMA,'') <> '' THEN
 		SOMA_AUX := SOMA;
	END IF;
	IF (SEQ = CC AND V_REC.PESO_L?QUIDO IS NULL AND SOMA > 0) THEN
		VALOR:= SOMA;
	ELSE
		VALOR:= NULL;
	END IF;

        if TOT_ITEM < 2 then
             VALOR := NULL;
        end if;
		
        SELECT COUNT(FAM?LIA) INTO SOMA_FAM FROM DOC_PLIST_WEIG_CERT_DET WHERE (DOC_SEQ = DOC) AND (NVL(FAM?LIA,' ') <> ' ');
        if SOMA_FAM < 2 then
           VALOR := NULL;
        end if;

	CLOSE C_REC;

	RETURN VALOR;

	END SUB_TOTAL_LIQ_PKL ;


	FUNCTION SUB_TOTAL_VOL_PKL (SEQ IN NUMBER, DOC IN NUMBER) return number IS
	VALOR number;
	CC NUMBER;
	SOMA NUMBER;
	SOMA_AUX NUMBER;

	cursor C_REC is SELECT DOC_SEQ, SEQ_ITEM, FAM?LIA, VOLUME FROM DOC_PLIST_WEIG_CERT_DET WHERE DOC_SEQ = DOC ORDER BY SEQ_ITEM;
	V_REC C_REC%ROWTYPE;

	BEGIN
	CC:=0;
	SOMA:=0;
	OPEN C_REC;
	WHILE CC < SEQ LOOP

	IF V_REC.FAM?LIA IS NULL AND NOT V_REC.VOLUME IS NULL THEN
		SOMA := SOMA + V_REC.VOLUME;
	ELSE
		SOMA_AUX := SOMA;
		SOMA:=0;
	END IF;
	FETCH C_REC INTO V_REC;	 
	CC:= V_REC.SEQ_ITEM;

	END LOOP;

	IF NVL(SOMA,'') <> '' THEN
 		SOMA_AUX := SOMA;
	END IF;
	IF (SEQ = CC AND V_REC.VOLUME IS NULL AND SOMA > 0) THEN
		VALOR:= SOMA;
	ELSE
		VALOR:= NULL;
	END IF;

	CLOSE C_REC;

	RETURN (VALOR);
	END SUB_TOTAL_VOL_PKL;

	FUNCTION TOT_GERAL_LIQ_MERCOSUL (DOC IN NUMBER) return number is
	TOT NUMBER;
	TOT_LIQ NUMBER;
	
	begin
	TOT := 0;	
	TOT_LIQ := 0;

	For CUR_ITEM in (SELECT PESO_L?QUIDO FROM DOC_MERCOSUL_DET WHERE DOC_SEQ = DOC) loop
	   IF NVL(CUR_ITEM.PESO_L?QUIDO,0) <> 0 THEN
		TOT_LIQ := TOT_LIQ + CUR_ITEM.PESO_L?QUIDO;
		TOT := TOT + 1;
	   END IF;
	end loop;
	
	IF TOT < 2 THEN
	   RETURN NULL;
	ELSE
	   RETURN (TOT_LIQ);
	END IF;

	END TOT_GERAL_LIQ_MERCOSUL;

	FUNCTION TOT_GERAL_LIQ_BOLIVIA (DOC IN NUMBER) return number is
	TOT NUMBER;
	TOT_LIQ NUMBER;
	
	begin
	TOT := 0;	
	TOT_LIQ := 0;

	For CUR_ITEM in (SELECT PESO_L?QUIDO FROM DOC_MERCOSUL_BOLIV_DET WHERE DOC_SEQ = DOC) loop
	   IF NVL(CUR_ITEM.PESO_L?QUIDO,0) <> 0 THEN
		TOT_LIQ := TOT_LIQ + CUR_ITEM.PESO_L?QUIDO;
		TOT := TOT + 1;
	   END IF;
	end loop;
	
	IF TOT < 2 THEN
	   RETURN NULL;
	ELSE
	   RETURN (TOT_LIQ);
	END IF;

	END TOT_GERAL_LIQ_BOLIVIA;

	FUNCTION TOT_GERAL_LIQ_CHILE (DOC IN NUMBER) return number is
	TOT NUMBER;
	TOT_LIQ NUMBER;
	
	begin
	TOT := 0;	
	TOT_LIQ := 0;

	For CUR_ITEM in (SELECT PESO_L?QUIDO FROM DOC_MERCOSUL_CHILE_DET WHERE DOC_SEQ = DOC) loop
	   IF NVL(CUR_ITEM.PESO_L?QUIDO,0) <> 0 THEN
		TOT_LIQ := TOT_LIQ + CUR_ITEM.PESO_L?QUIDO;
		TOT := TOT + 1;
	   END IF;
	end loop;
	
	IF TOT < 2 THEN
	   RETURN NULL;
	ELSE
	   RETURN (TOT_LIQ);
	END IF;

	END TOT_GERAL_LIQ_CHILE;

	FUNCTION TOT_GERAL_LIQ_ALADI (DOC IN NUMBER) return number is
	TOT NUMBER;
	TOT_LIQ NUMBER;
	
	begin
	TOT := 0;	
	TOT_LIQ := 0;

	For CUR_ITEM in (SELECT PESO_L?QUIDO FROM DOC_ALADI_DET WHERE DOC_SEQ = DOC) loop
	   IF NVL(CUR_ITEM.PESO_L?QUIDO,0) <> 0 THEN
		TOT_LIQ := TOT_LIQ + CUR_ITEM.PESO_L?QUIDO;
		TOT := TOT + 1;
	   END IF;
	end loop;
	
	IF TOT < 2 THEN
	   RETURN NULL;
	ELSE
	   RETURN (TOT_LIQ);
	END IF;

	END TOT_GERAL_LIQ_ALADI;

	FUNCTION TOT_GERAL_LIQ_COMERCIO (DOC IN NUMBER) return number is
	TOT NUMBER;
	TOT_LIQ NUMBER;
	
	begin
	TOT := 0;	
	TOT_LIQ := 0;

	For CUR_ITEM in (SELECT PESO_L?QUIDO FROM DOC_C?MARA_COM?RCIO_DET WHERE DOC_SEQ = DOC) loop
	   IF NVL(CUR_ITEM.PESO_L?QUIDO,0) <> 0 THEN
		TOT_LIQ := TOT_LIQ + CUR_ITEM.PESO_L?QUIDO;
		TOT := TOT + 1;
	   END IF;
	end loop;
	
	IF TOT < 2 THEN
	   RETURN NULL;
	ELSE
	   RETURN (TOT_LIQ);
	END IF;

	END TOT_GERAL_LIQ_COMERCIO;

	FUNCTION TOT_GERAL_LIQ_FIRJAN (DOC IN NUMBER) return number is
	TOT NUMBER;
	TOT_LIQ NUMBER;
	
	begin
	TOT := 0;	
	TOT_LIQ := 0;

	For CUR_ITEM in (SELECT PESO_L?QUIDO FROM DOC_FIRJAN_DET WHERE DOC_SEQ = DOC) loop
	   IF NVL(CUR_ITEM.PESO_L?QUIDO,0) <> 0 THEN
		TOT_LIQ := TOT_LIQ + CUR_ITEM.PESO_L?QUIDO;
		TOT := TOT + 1;
	   END IF;
	end loop;
	
	IF TOT < 2 THEN
	   RETURN NULL;
	ELSE
	   RETURN (TOT_LIQ);
	END IF;

	END TOT_GERAL_LIQ_FIRJAN;


	FUNCTION TOT_GERAL_LIQ_RODOV (DOC IN NUMBER) return number is
	TOT NUMBER;
	TOT_LIQ NUMBER;
	
	begin
	TOT := 0;	
	TOT_LIQ := 0;

	For CUR_ITEM in (SELECT PESO_L?QUIDO FROM DOC_CONHECIMENT_ROD_DET WHERE DOC_SEQ = DOC) loop
	   IF NVL(CUR_ITEM.PESO_L?QUIDO,0) <> 0 THEN
		TOT_LIQ := TOT_LIQ + CUR_ITEM.PESO_L?QUIDO;
		TOT := TOT + 1;
	   END IF;
	end loop;
	
	IF TOT < 2 THEN
	   RETURN NULL;
	ELSE
	   RETURN (TOT_LIQ);
	END IF;

	END TOT_GERAL_LIQ_RODOV;


	FUNCTION TOT_GERAL_LIQ_PKL (DOC IN NUMBER) return number is
	TOT NUMBER;
	TOT_LIQ NUMBER;
	
	begin
	TOT := 0;	
	TOT_LIQ := 0;

	For CUR_ITEM in (SELECT PESO_L?QUIDO FROM DOC_PLIST_WEIG_CERT_DET WHERE DOC_SEQ = DOC) loop
	   IF NVL(CUR_ITEM.PESO_L?QUIDO,0) <> 0 THEN
		TOT_LIQ := TOT_LIQ + CUR_ITEM.PESO_L?QUIDO;
		TOT := TOT + 1;
	   END IF;
	end loop;
	
	IF TOT < 2 THEN
	   RETURN NULL;
	ELSE
	   RETURN (TOT_LIQ);
	END IF;

	END TOT_GERAL_LIQ_PKL;



end cope_cxrj;
/


