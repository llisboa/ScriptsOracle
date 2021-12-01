create or replace package LB is
	function litem(Texto in varchar2, Item in number, Sep in varchar2 default '') return varchar2;
	function litem(Texto in varchar2, Item in varchar2, Sep in varchar2 default '') return number;
	function lparam(Campo in varchar2, tipo in varchar2) return varchar2;
	function lustr(Texto in varchar2) return varchar2;
	function lextenso(VV in number, Ling in varchar2) return varchar2;
	function lmontacento(Strv0 in varchar2, StrCem in varchar2, Sep in varchar2, StrDez in varchar2, StrPrimaDez in varchar2, StrUnid in varchar2) return varchar2;
	function lconcatcamp(Dominio in varchar2, Delimit in varchar2) return varchar2;
	function lnumling(Num in number, Masc in varchar2, Ling in varchar2) return varchar2;
	function ajusta_campo (texto in varchar2, tamanho in integer) return varchar2;
	procedure confirm(op in varchar2, confirm in varchar2, in_seq number, origconfirm in varchar2 default '', origseq number default 0, pedido in varchar2 default '', idioma in varchar2 default '', pVariaveis in varchar2, opDescr in varchar2, medida in varchar2 default '');
        procedure precoAlteradoAposEmb(de in varchar, para in varchar, adm in varchar2 ,servidor_msg in varchar);
        function formataValor(valor in number default -99999) return varchar2;
	procedure CondicaoPagamento (de in varchar2, para in varchar2, adm in varchar2, servidor_msg in varchar);
	procedure novoItemMapa (de in varchar2, para in varchar2, adm in varchar2, servidor_msg in varchar, DataIni in date default SYSDATE - 1);


end;

/

create or replace package body LB is
--@d:\PUBLICA\V04.50\LB2.SQL


procedure CondicaoPagamento (de in varchar2, para in varchar2,adm in varchar2, servidor_msg in varchar) is
        public_dir VARCHAR2(30);
  	arquivo varchar2(30);
  	ret integer;
  	ToT_Reg integer;
	larg number;
begin
                public_dir := 'd:\oracle\public';
  		arquivo := 'CondicaoPagamento.htm';
  		ret := DBMS_CX.DOSSHELL('DEL ' || public_dir || '\' || arquivo);

	declare
	  cursor con_pag is

--LANÇAR SENTINELA.SQL
SELECT
  MP.PED_REF PED_REF, NVL(PFORN,0) PFORN, NVL(PEXP,0) PEXP, NVL(PIMP,0) PIMP, NVL(FORN,0) FORN, NVL(EXP,0) EXP, NVL(IMP,0) IMP
FROM
  (SELECT
  PED_REF, SUM(PFORN) PFORN , SUM(PEXP) PEXP , SUM(PIMP) PIMP ,  SUM(FORN) FORN ,  SUM(EXP) EXP ,  SUM(IMP) IMP
  FROM
  (
          SELECT PI.PED_REF, SUM(NVL(PF.PERC,0)) PFORN, 0 PEXP , 0 PIMP,
                 SUM(NVL(PI.NOMINAL_METRIC_TONS,0) * NVL(PI.PREÇO_UNITÁRIO_FORNECEDOR,0)) FORN,
                 0 EXP,
                 0 IMP
  	  FROM
	         (SELECT MP.PED_REF FROM MAPA_DE_CONTROLE MP,PED WHERE MP.PED_REF = PED.REF AND ROUND(PED.SYS_MOMENTO_CRIA) > TO_DATE('01 09 2007','DD MM YYYY') GROUP BY PED_REF)PD, PED_ITEM PI,PED_FORMA_PAGAMENTO PF
	  WHERE
	         PD.PED_REF = PI.PED_REF (+) AND
	         PD.PED_REF = PF.PED_REF (+) AND
	         PF.OPERAÇÃO = 1
          GROUP BY
                 PI.PED_REF
  UNION ALL
          SELECT PI.PED_REF, 0 PFORN, SUM(NVL(PF.PERC,0)) PEXP , 0 PIMP,
                 0 FORN,
                 SUM(NVL(PI.NOMINAL_METRIC_TONS,0) * NVL(PI.PREÇO_UNITÁRIO_EXP,0)) EXP,
                 0 IMP
	  FROM
	         (SELECT MP.PED_REF FROM MAPA_DE_CONTROLE MP,PED WHERE MP.PED_REF = PED.REF AND ROUND(PED.SYS_MOMENTO_CRIA) > TO_DATE('01 09 2007','DD MM YYYY') GROUP BY PED_REF)PD, PED_ITEM PI,PED_FORMA_PAGAMENTO PF
	  WHERE
	         PD.PED_REF = PI.PED_REF (+) AND
	         PD.PED_REF = PF.PED_REF (+) AND
	         PF.OPERAÇÃO = 2
          GROUP BY
                 PI.PED_REF
  UNION ALL
          SELECT PI.PED_REF, 0 PFORN, 0 PEXP , SUM(NVL(PF.PERC,0)) PIMP,
                 0 FORN,
                 0 EXP,
                 SUM(NVL(PI.NOMINAL_METRIC_TONS,0) * NVL(PI.PREÇO_UNITÁRIO_IMP,0)) IMP
	  FROM
	         (SELECT MP.PED_REF FROM MAPA_DE_CONTROLE MP,PED WHERE MP.PED_REF = PED.REF AND ROUND(PED.SYS_MOMENTO_CRIA) > TO_DATE('01 09 2007','DD MM YYYY') GROUP BY PED_REF)PD, PED_ITEM PI,PED_FORMA_PAGAMENTO PF
	  WHERE
	         PD.PED_REF = PI.PED_REF (+) AND
	         PD.PED_REF = PF.PED_REF (+) AND
	         PF.OPERAÇÃO = 3
          GROUP BY
                 PI.PED_REF
)UN
GROUP BY
	UN.PED_REF)UNI, MAPA_DE_CONTROLE MP
WHERE
	MP.PED_REF = UNI.PED_REF (+) AND
         (UNI.PFORN <> 100 OR
          UNI.PEXP <> 100 OR
          UNI.PIMP <> 100 OR
          UNI.EXP <> 100 OR
          UNI.IMP <> 100 OR
          UNI.FORN <> 100);
begin
--Monta cabeçalho
	dbms_cx.grava_log('<html><head><title>CIEX - Forma de pagamento</title></head>',arquivo);
	dbms_cx.grava_log('<style type="text/css">',arquivo);
	dbms_cx.grava_log('<!--',arquivo);
	dbms_cx.grava_log('.etiqueta{',arquivo);
	dbms_cx.grava_log('	font-family: Verdana,Arial;',arquivo);
	dbms_cx.grava_log('	font-size: 10px;',arquivo);
	dbms_cx.grava_log('	font-style: normal;',arquivo);
	dbms_cx.grava_log('	color: #000000;',arquivo);
	dbms_cx.grava_log('	text-decoration: none;',arquivo);
	dbms_cx.grava_log('	display:block;',arquivo);
	dbms_cx.grava_log('}',arquivo);
	dbms_cx.grava_log('.campo{',arquivo);
	dbms_cx.grava_log('	font-family: Verdana,Arial;',arquivo);
	dbms_cx.grava_log('	font-size: 10px;',arquivo);
	dbms_cx.grava_log('	text-decoration: blink;',arquivo);
	dbms_cx.grava_log('	display:block;',arquivo);
	dbms_cx.grava_log('	color: #0000FF;',arquivo);
	dbms_cx.grava_log('}',arquivo);
	dbms_cx.grava_log('-->',arquivo);
	dbms_cx.grava_log('</style>',arquivo);
	dbms_cx.grava_log('<body bgcolor= #EEEEEE text= #0000FF >',arquivo);
	dbms_cx.grava_log('<p align= center ><font face= Arial  size= 3 ><b>CIEX - Pedidos com Condição de Pagemento Divergente</b></font></p>',arquivo);
	dbms_cx.grava_log('',arquivo);
	dbms_cx.grava_log('<center>',arquivo);
	dbms_cx.grava_log('',arquivo);



	dbms_cx.grava_log('',arquivo);
	dbms_cx.grava_log('<table border = 1 width = 430>',arquivo);

        dbms_cx.grava_log('  <TR>',arquivo);
        dbms_cx.grava_log('    <TD width = 100 height="23" class = etiqueta><div align="center">Closing Sheet</div></TD>',arquivo);
        dbms_cx.grava_log('    <TD width = 110 height="23" class = etiqueta><div align="center">Supllier - Intervenient 1 (%)</div></TD>',arquivo);
        dbms_cx.grava_log('    <TD width = 110 height="23" class = etiqueta><div align="center">Intervenient 1 - Intervenient 2 (%)</div></TD>',arquivo);
        dbms_cx.grava_log('    <TD width = 110 height="23" class = etiqueta><div align="center">Intervenient 2 - Payer (%)</div></TD>',arquivo);
        dbms_cx.grava_log('  </TR>',arquivo);

		for CR in con_pag loop
        dbms_cx.grava_log('  <TR>',arquivo);
        dbms_cx.grava_log('    <TD width = 100 height="23" class=etiqueta><div align="center">' || cr.ped_ref || '</div></TD>',arquivo);
        dbms_cx.grava_log('    <TD width = 110 height="23" class=campo><div align="center">' || cr.pforn || '</div></TD>',arquivo);
        dbms_cx.grava_log('    <TD width = 110 height="23" class=campo><div align="center">' || cr.pexp || '</div></TD>',arquivo);
        dbms_cx.grava_log('    <TD width = 110 height="23" class=campo><div align="center">' || cr.pimp || '</div></TD>',arquivo);
        dbms_cx.grava_log('  </TR>',arquivo);
		end loop;

	dbms_cx.grava_log('</table><br>',arquivo);
	dbms_cx.grava_log('',arquivo);
	dbms_cx.grava_log('<font face=Arial size=1 color = #FF0000>Data: ' ||  to_char(sysdate,'dd/mon/yyyy') || '</font>' ,arquivo);
	dbms_cx.grava_log('</center></body></html>',arquivo);

          ret :=   DBMS_CX.DOSSHELL('sendmail -f ' || de || ' -t ' || replace (Para, ';', ' -t' ) || ' -s "CIEX - Pedidos com Condição de Pagemento Divergente" -b "CIEX - Controle de Exportação e Importação." -a ' ||  public_dir || '\' || arquivo || ' -m ' || servidor_msg || '');
	end;
end CondicaoPagamento;




function ajusta_campo (texto in varchar2, tamanho in integer) return varchar2 is
	lenTexto integer ;
	valorCampo varchar2(50) ;
begin

	valorCampo := texto;
	lenTexto := length(Texto);

		for i in lenTexto  .. tamanho loop
			valorCampo := valorCampo || ' ';
		end loop;

	return ValorCampo;

end ajusta_campo;



procedure novoItemMapa (de in varchar2, para in varchar2,adm in varchar2, servidor_msg in varchar, DataIni in date default SYSDATE - 1) is
        public_dir VARCHAR2(30);
  	arquivo varchar2(30);
  	ret integer;
  	ToT_Reg integer;
	larg number;
begin
                public_dir := 'd:\oracle\public';
  		arquivo := 'PedidosMapa.htm';
  		ret := DBMS_CX.DOSSHELL('DEL ' || public_dir || '\' || arquivo);
		SELECT COUNT (*) INTO ToT_Reg FROM PED WHERE TO_CHAR(SYS_MOMENTO_CRIA, 'DD-MM-YYYY') = TO_CHAR(DataIni , 'DD-MM-YYYY') AND PED.REF NOT LIKE 'ICGO%';

IF ToT_Reg > 0 THEN
  declare
	cursor new_mapa is SELECT MP.PED_REF, MP.SEQ, MP.PAÍS_DESTINO, MP.PRODUTOR, MP.FORNECEDOR, MP.FORN_SALES_COND, MP.FORN_RECEIPT_COND, MP.EXPORTADOR, MP.EXP_SALES_COND, MP.EXP_RECEIPT_COND, MP.IMPORTADOR, MP.IMP_SALES_COND, MP.IMP_RECEIPT_COND, MP.DISTRIBUIDOR, MP.PAGADOR, MP.GRUPO from MAPA_DE_CONTROLE MP , PED WHERE MP.PED_REF = PED.REF (+) AND TO_CHAR(PED.SYS_MOMENTO_CRIA, 'DD-MM-YYYY') = TO_CHAR(dataini , 'DD-MM-YYYY')  ORDER BY MP.PED_REF, MP.GRUPO ;
   begin



--Monta cabeçalho do HTML

	dbms_cx.grava_log('<html><head><title>CIEX - Pedidos Inseridos no Mapa de Controle</title></head>',arquivo);
	dbms_cx.grava_log('<style type="text/css">',arquivo);
	dbms_cx.grava_log('<!--',arquivo);
	dbms_cx.grava_log('.etiqueta{',arquivo);
	dbms_cx.grava_log('	font-family: Verdana,Arial;',arquivo);
	dbms_cx.grava_log('	font-size: 10px;',arquivo);
	dbms_cx.grava_log('	font-style: normal;',arquivo);
	dbms_cx.grava_log('	color: #000000;',arquivo);
	dbms_cx.grava_log('	text-decoration: none;',arquivo);
	dbms_cx.grava_log('	display:block;',arquivo);
	dbms_cx.grava_log('}',arquivo);
	dbms_cx.grava_log('.campo{',arquivo);
	dbms_cx.grava_log('	font-family: Verdana,Arial;',arquivo);
	dbms_cx.grava_log('	font-size: 10px;',arquivo);
	dbms_cx.grava_log('	text-decoration: blink;',arquivo);
	dbms_cx.grava_log('	display:block;',arquivo);
	dbms_cx.grava_log('	color: #0000FF;',arquivo);
	dbms_cx.grava_log('}',arquivo);
	dbms_cx.grava_log('-->',arquivo);
	dbms_cx.grava_log('</style>',arquivo);
	dbms_cx.grava_log('<body bgcolor= #EEEEEE text= #0000FF >',arquivo);
	dbms_cx.grava_log('<p align= center ><font face= Arial  size= 3 ><b>CIEX - Pedidos Inseridos no Mapa de Controle</b></font></p>',arquivo);
	dbms_cx.grava_log('',arquivo);
	dbms_cx.grava_log('<center>',arquivo);
	dbms_cx.grava_log('',arquivo);


		for CR in new_mapa loop
	dbms_cx.grava_log('<hr>',arquivo);
	dbms_cx.grava_log('',arquivo);
	dbms_cx.grava_log('<table border = 0 width = 900>',arquivo);
	dbms_cx.grava_log('  <TR>',arquivo);
	dbms_cx.grava_log('    <TD width = 100 height="23" class=etiqueta>Closing Sheet:</TD>',arquivo);
	dbms_cx.grava_log('    <TD width = 96 class=campo>' || CR.PED_REF ||'</TD>',arquivo);
	dbms_cx.grava_log('    <TD width = 15 class=etiqueta>SEQ:</TD>',arquivo);
	dbms_cx.grava_log('    <TD width = 22 class=campo>' || CR.SEQ ||'</TD>',arquivo);
	dbms_cx.grava_log('    <TD width = 140 class=etiqueta>Destination Country:</TD>',arquivo);
	dbms_cx.grava_log('    <TD width = 223 class=campo>' || CR.PAÍS_DESTINO ||'</TD>',arquivo);
	dbms_cx.grava_log('    <TD width = 119 class=etiqueta>Group Of Product:</TD>',arquivo);
	dbms_cx.grava_log('    <TD width = 185 class=campo>' || CR.GRUPO ||'</TD>',arquivo);
	dbms_cx.grava_log('  </TR>',arquivo);
	dbms_cx.grava_log('</table>',arquivo);
		dbms_cx.grava_log('',arquivo);
	dbms_cx.grava_log('  <table border = 0 width = 901>',arquivo);
	dbms_cx.grava_log('    <TR> ',arquivo);
	dbms_cx.grava_log('      <TD width="110" height="23" class=etiqueta>Producer:</TD>',arquivo);
	dbms_cx.grava_log('      <TD height="23" colspan="5" class=campo>' || CR.PRODUTOR ||'</TD>',arquivo);
	dbms_cx.grava_log('    </TR>',arquivo);
		dbms_cx.grava_log('',arquivo);
	dbms_cx.grava_log('    <TR> ',arquivo);
	dbms_cx.grava_log('      <TD width = 110 height="23" class=etiqueta>Suplier:</TD>',arquivo);
	dbms_cx.grava_log('      <TD width = 250 height="23" class=campo>' || CR.FORNECEDOR ||'</TD>',arquivo);
	dbms_cx.grava_log('      <TD width = 120 height="23" class=etiqueta>Sales Inconterm:</TD>',arquivo);
	dbms_cx.grava_log('      <TD width = 120 height="23" class=campo>' || CR.FORN_SALES_COND ||'</TD>',arquivo);
	dbms_cx.grava_log('      <TD width = 120 height="23" class=Etiqueta>Receipt Inconterm:</TD>',arquivo);
	dbms_cx.grava_log('      <TD width = 171 height="23" class=campo>' || CR.FORN_RECEIPT_COND ||'</TD>',arquivo);
	dbms_cx.grava_log('    </TR>',arquivo);
		dbms_cx.grava_log('',arquivo);
	dbms_cx.grava_log('    <TR> ',arquivo);
	dbms_cx.grava_log('      <TD width = 110 height="23" class=etiqueta>Intervenient 1:</TD>',arquivo);
	dbms_cx.grava_log('      <TD width = 250 height="23" class=campo>' || CR.EXPORTADOR ||'</TD>',arquivo);
	dbms_cx.grava_log('      <TD width = 120 height="23" class=etiqueta>Sales Inconterm:</TD>',arquivo);
	dbms_cx.grava_log('      <TD width = 120 height="23" class=campo>' || CR.EXP_SALES_COND ||'</TD>',arquivo);
	dbms_cx.grava_log('      <TD width = 120 height="23" class=Etiqueta>Receipt Inconterm:</TD>',arquivo);
	dbms_cx.grava_log('      <TD width = 171 height="23" class=campo>' || CR.EXP_RECEIPT_COND ||'</TD>',arquivo);
	dbms_cx.grava_log('    </TR>',arquivo);
		dbms_cx.grava_log('',arquivo);
	dbms_cx.grava_log('    <TR> ',arquivo);
	dbms_cx.grava_log('      <TD width = 110 height="23" class=etiqueta>Intervenient 2:</TD>',arquivo);
	dbms_cx.grava_log('      <TD width = 250 height="23" class=campo>' || CR.IMPORTADOR || '</TD>',arquivo);
	dbms_cx.grava_log('      <TD width = 120 height="23" class=etiqueta>Sales Inconterm:</TD> ',arquivo);
	dbms_cx.grava_log('      <TD width = 120 height="23" class=campo>' || CR.IMP_SALES_COND || '</TD>',arquivo);
	dbms_cx.grava_log('      <TD width = 120 height="23" class=Etiqueta>Receipt Inconterm:</TD>',arquivo);
	dbms_cx.grava_log('      <TD width = 171 height="23" class=campo>' || CR.IMP_RECEIPT_COND || '</TD>',arquivo);
	dbms_cx.grava_log('    </TR>',arquivo);
		dbms_cx.grava_log('',arquivo);
	dbms_cx.grava_log('    <TR> ',arquivo);
	dbms_cx.grava_log('      <TD width= 110 height= 23 class=etiqueta>Payer:</TD>',arquivo);
	dbms_cx.grava_log('      <TD height= 23 colspan=5 class=campo>' || CR.PAGADOR ||'</TD>',arquivo);
	dbms_cx.grava_log('    </TR></table>',arquivo);
		end loop;

	dbms_cx.grava_log('<hr><br>',arquivo);
	dbms_cx.grava_log('<font face=Arial size=1 color = #FF0000>Data: ' ||  to_char(DATAINI,'dd/mon/yyyy') || '</font>' ,arquivo);
	dbms_cx.grava_log('',arquivo);
	dbms_cx.grava_log('</center></body></html>',arquivo);

          ret :=   DBMS_CX.DOSSHELL('sendmail -f ' || de || ' -t ' || replace (Para, ';', ' -t' ) || ' -s "CIEX - Pedidos inseridos no mapa de Controle" -b "CIEX - Controle de Exportação e Importação." -a ' ||  public_dir || '\' || arquivo || ' -m ' || servidor_msg || '');
	  end;
  	  else
          ret :=   DBMS_CX.DOSSHELL('sendmail -f ' || de || ' -t ' ||  replace (adm, ';', ' -t' ) || ' -s "CIEX - Pedidos inseridos no mapa de Controle - NÃO EXISTEM NOVOS PEDIDOS" -b "NÃO EXISTEM NOVOS PEDIDOS" -a ' ||  public_dir || '\' || arquivo || ' -m ' || servidor_msg || '');




END IF;

end novoItemMapa;





	procedure confirm(op in varchar2, confirm in varchar2, in_seq number, origconfirm in varchar2 default '', origseq number default 0, pedido in varchar2 default '', idioma in varchar2 default '', pVariaveis in varchar2, opDescr in varchar2, medida in varchar2 default '') is
	DESCR varchar2(3000);
	DESC_PORTO varchar2(100);
	USU_FINAL varchar2(30);
	VAL_TOL number;
	VAL_EMB number;
	MOEDA varchar2(20);
	TOTITENS number;
	MAXITEM number;
	RESP number;
	Tip_lingua varchar2(10);
	RET_PROC number;
	descrição varchar2(1000);
	POS_INI number;
	POS_FIM number;
	RET varchar2(1000);
	OutraRef varchar2(3000);
	RESP NUMBER;
	COMP varchar2(100);
	MES varchar2(1000);
	ANO varchar2(4);
	DIA varchar2(2);
	AUX NUMBER;
	PORTO_DESC varchar2(100);
        pedidoRef varchar2(100);
        packing varchar2(100);
        notes varchar2(100);
        currency varchar2(100);
        attn varchar2(100);
        shipmentFrom varchar2(100);
        priceTerm varchar2(100);
        insurance varchar2(100);
        shipmentTo  varchar2(100);
        buyer  varchar2(100);
        paymentCondition varchar2(100);
        producer varchar2(100);
        remarksOnSpecs varchar2(100);
        fromDe varchar2(100);
        priceCondition varchar2(100);
        shipment varchar2(100);
        seller varchar2(100);
        endUser varchar2(100);
        variaveis varchar2(100);

	begin
                --Verifica quais campos serão atualizados;
                variaveis := pVariaveis;
                pedidoRef := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                packing := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                notes := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                currency := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                attn := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                shipmentFrom := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                priceTerm := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                insurance := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                shipmentTo := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                buyer := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                paymentCondition := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                producer := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                seller := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                priceCondition  := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                shipment := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                fromDe := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                remarksOnSpecs := SUBSTR(variaveis,1,1);
                variaveis := SUBSTR(variaveis,(length(variaveis)- (length(variaveis) * 2) + 2),length(variaveis));
                endUser := SUBSTR(variaveis,1,1);
		OutraRef := '';
		MES := 'Janeiro.January.Enero;Fevereiro.February.Febrero;Março.March.Marzo;Abril.April.Abril;Maio.May.Mayo;Junho.June.Junio;Julho.July.Julio;Agosto.August.Agosto;Setembro.September.Septiembre;Outubro.October.Octubre;Novembro.November.Noviembre;Dezembro.December.Diciembre';
		if op = 'A' then
			--atualizar a confirmação de venda
			if not pedido is null then
				for cur_ped in (SELECT REF, IMP_COND_VENDA, EMB_PREV, FRETE_COND, CARGA_PORTO, DECODE(DISTRIBUIDOR,NULL,IMP,DISTRIBUIDOR) COMP, MOEDA FROM CXRJ.PED WHERE REF = pedido) loop
                                    for cur_cf in (select * from cxrj.confirm_venda where ref = confirm and seq = in_seq) loop
					MOEDA := cur_ped.MOEDA;
					OutraRef := OutraRef || cur_ped.REF;
					ANO := TO_CHAR(cur_ped.EMB_PREV,'YYYY');
					RET := TO_CHAR(cur_ped.EMB_PREV,'MM');
					AUX := TO_NUMBER(RET);
					RET := LITEM(MES,AUX);
					if idioma = 'C' then
						RET := LITEM(RET,3);
						RET := RET || ', ' || ANO;
					elsif idioma = 'I' then
						RET := LITEM(RET,2);
						RET := RET || ', ' || ANO;
					else
						DIA := TO_CHAR(cur_ped.EMB_PREV,'DD');
						RET := LITEM(RET,1);
						RET := DIA || ' de ' || RET || ' de ' || ANO;
					end if;
					update CXRJ.CONFIRM_VENDA set PED_REF = decode(pedidoref,1,cur_ped.REF,cur_cf.ped_ref), MOEDA = decode(currency,1,cur_ped.moeda,cur_cf.moeda) , PREÇO_DETALHE = decode(priceTerm,1,cur_ped.IMP_COND_VENDA || ' ' || cur_ped.FRETE_COND,cur_cf.preço_detalhe), ENTREGA = decode(shipment,1,RET,cur_cf.entrega), CARGA_PORTO = decode(shipmentFrom,1,cur_ped.CARGA_PORTO,cur_cf.carga_porto) , vendedor = decode(seller,1,cur_ped.COMP,cur_cf.vendedor) ,COMPRADOR = decode(buyer,1,cur_ped.COMP,cur_cf.comprador) WHERE REF = confirm AND SEQ = in_seq;
					COMMIT;
                                      end loop;
				end loop;
			end if;

			if not confirm is null then
				for cur in (SELECT EMISSOR, DESTINATÁRIO, ESPECIFICAÇÃO, EMBALAGEM, SEGURO, PAG, OBS_TERMOS, OBS, PRODUTOR, CARGA_PORTO, DESCARGA_PORTO FROM CXRJ.CONFIRM_VENDA WHERE REF = origconfirm AND SEQ = origseq) loop
                                    for cur_cf in (select * from cxrj.confirm_venda where ref = confirm and seq = in_seq) loop
                                    DESC_PORTO := cur.DESCARGA_PORTO;
					update CXRJ.CONFIRM_VENDA set EMISSOR = decode(fromDe,1,cur.EMISSOR,cur_cf.emissor), DESTINATÁRIO = decode(attn,1,cur.DESTINATÁRIO,cur_cf.DESTINATÁRIO), ESPECIFICAÇÃO = decode(remarksOnSpecs,1,cur.ESPECIFICAÇÃO,cur_cf.especificação), EMBALAGEM = decode(packing,1,cur.EMBALAGEM,cur_cf.EMBALAGEM), SEGURO = decode(insurance,1,cur.SEGURO,cur_cf.seguro), PAG = decode(paymentCondition,1,cur.PAG,cur_cf.pag) , OBS_TERMOS = decode(priceCondition,1,cur.OBS_TERMOS,cur_cf.OBS_TERMOS), OBS = decode(notes,1,cur.OBS,cur_cf.OBS) , CARGA_PORTO = decode(shipmentFrom,1,cur.CARGA_PORTO,cur_cf.CARGA_PORTO), DESCARGA_PORTO = decode(shipmentTo,1,cur.DESCARGA_PORTO,cur_cf.DESCARGA_PORTO), PRODUTOR = decode(producer,1,cur.PRODUTOR,cur_cf.PRODUTOR) WHERE REF = confirm AND SEQ = in_seq;
					COMMIT;
                                    end loop;
				end loop;
			end if;

			DELETE FROM CXRJ.CONFIRM_VENDA_ITEM WHERE CONFIRM_VENDA_REF = confirm and SEQ = in_seq;

		elsif op = 'I' then
			-- incluir a confirmação de venda
			if not pedido is null then
				for cur_ped in (SELECT REF, IMP_COND_VENDA, EMB_PREV, FRETE_COND, CARGA_PORTO, DECODE(DISTRIBUIDOR,NULL,IMP,DISTRIBUIDOR) COMP, MOEDA FROM CXRJ.PED WHERE REF = pedido) loop
					MOEDA := cur_ped.MOEDA;
					OutraRef := OutraRef || cur_ped.REF;
					ANO := TO_CHAR(cur_ped.EMB_PREV,'YYYY');
					RET := TO_CHAR(cur_ped.EMB_PREV,'MM');
					AUX := TO_NUMBER(RET);
					RET := LITEM(MES,AUX);
					if idioma = 'C' then
						RET := LITEM(RET,3);
						RET := RET || ', ' || ANO;
					elsif idioma = 'I' then
						RET := LITEM(RET,2);
						RET := RET || ', ' || ANO;
					else
						DIA := TO_CHAR(cur_ped.EMB_PREV,'DD');
						RET := LITEM(RET,1);
						RET := DIA || ' de ' || RET || ' de ' || ANO;
					end if;
					insert INTO CXRJ.CONFIRM_VENDA (REF, SEQ, PED_REF, PREÇO_DETALHE, ENTREGA, CARGA_PORTO, COMPRADOR, MOEDA) VALUES (confirm, in_seq, cur_ped.REF, cur_ped.IMP_COND_VENDA || ' ' || cur_ped.FRETE_COND, RET, cur_ped.CARGA_PORTO, cur_ped.COMP, cur_ped.MOEDA);
					COMMIT;
				end loop;
				if not confirm is null then
					for cur in (SELECT EMISSOR, DESTINATÁRIO, ESPECIFICAÇÃO, EMBALAGEM, SEGURO, PAG, OBS_TERMOS, OBS, PRODUTOR, CARGA_PORTO, DESCARGA_PORTO FROM CXRJ.CONFIRM_VENDA WHERE REF = origconfirm AND SEQ = origseq) loop
						DESC_PORTO := cur.DESCARGA_PORTO;
						update CXRJ.CONFIRM_VENDA set EMISSOR = cur.EMISSOR, DESTINATÁRIO = cur.DESTINATÁRIO, ESPECIFICAÇÃO = cur.ESPECIFICAÇÃO, EMBALAGEM = cur.EMBALAGEM, SEGURO = cur.SEGURO, PAG = cur.PAG, OBS_TERMOS = cur.OBS_TERMOS, OBS = cur.OBS, CARGA_PORTO = cur.CARGA_PORTO, DESCARGA_PORTO = cur.DESCARGA_PORTO, PRODUTOR = cur.PRODUTOR WHERE REF = confirm AND SEQ = in_seq;
						COMMIT;
					end loop;
				end if;
			else
				for cur in (SELECT EMISSOR, DESTINATÁRIO, ESPECIFICAÇÃO, EMBALAGEM, SEGURO, PAG, OBS_TERMOS, OBS, PRODUTOR, CARGA_PORTO, DESCARGA_PORTO, MOEDA FROM CXRJ.CONFIRM_VENDA WHERE REF = origconfirm AND SEQ = origseq) loop
					DESC_PORTO := cur.DESCARGA_PORTO;
					insert INTO CXRJ.CONFIRM_VENDA (REF, SEQ, EMISSOR, DESTINATÁRIO, ESPECIFICAÇÃO, EMBALAGEM, SEGURO, PAG, OBS_TERMOS, OBS, CARGA_PORTO, DESCARGA_PORTO, PRODUTOR, MOEDA) VALUES (confirm, in_seq, cur.EMISSOR, cur.DESTINATÁRIO, cur.ESPECIFICAÇÃO, cur.EMBALAGEM, cur.SEGURO, cur.PAG, cur.OBS_TERMOS, cur.OBS, cur.CARGA_PORTO, cur.DESCARGA_PORTO, cur.PRODUTOR, cur.MOEDA);
					COMMIT;
				end loop;
			end if;
		end if;
		SELECT COUNT(*) INTO TOTITENS FROM PED_ITEM WHERE PED_REF = pedido;
		if TOTITENS > 0 then
                  if opDescr = '1' then
			DESCR := '';
			for cur in (SELECT * FROM PED_ITEM WHERE PED_REF = pedido) loop
				DESCR := '';
				USU_FINAL := NVL(cur.USUÁRIO_FINAL,'');
				PORTO_DESC := NVL(cur.DESCARGA_PORTO,'');

--PRODUTO
			if nvl(cur.PROD,' ') <> ' ' THEN
				SELECT NOME INTO descrição FROM PRODUTO WHERE COD = cur.PROD;
				if not IDIOMA is null then
					Tip_lingua:= idioma || ':';
					SELECT COUNT(COD) into ret_proc FROM PRODUTO WHERE COD = cur.PROD AND UPPER (NOME) LIKE '%' || UPPER(Tip_lingua) || '%';
					if ret_proc = 0 then
						POS_FIM := instr(descrição, CHR(13) || CHR(10));
						DESCR := DESCR || ' ; ' || SUBSTR(descrição,1,POS_FIM - 1);
					else
						POS_INI := instr(descrição, Tip_lingua) + length(Tip_lingua);
						POS_FIM := instr(SUBSTR(descrição,POS_INI), CHR(13) || CHR(10)) - 1;
						if (POS_INI - length(Tip_lingua) - 1) = 0 then
							DESCR := DESCR || '';
						else
							if POS_FIM < 0 THEN
								DESCR := DESCR || ' ; ' || SUBSTR(descrição,POS_INI);
							else
								DESCR := DESCR || ' ; ' || SUBSTR(descrição,POS_INI,POS_FIM);
							end if;
						end if;
					end if;
				else
					POS_FIM := instr(descrição, CHR(13) || CHR(10));
					DESCR := DESCR || ' ; ' || SUBSTR(descrição,1,POS_FIM - 1);
				end if;
			end if;

--EMBALAGEM
				if nvl(cur.EMBALAGEM,' ') <> ' ' then
					SELECT DESCR INTO descrição FROM EMBALAGEM WHERE COD = cur.EMBALAGEM;
					if not IDIOMA is null then
						Tip_lingua := idioma || ':';
						SELECT COUNT(COD) INTO ret_proc FROM EMBALAGEM WHERE COD = cur.EMBALAGEM AND UPPER(DESCR) LIKE '%' || UPPER(Tip_lingua) || '%';
						if ret_proc = 0 then
							POS_FIM := instr(descrição, CHR(13) || CHR(10));
							DESCR := DESCR || ' ; ' || SUBSTR(descrição,1,POS_FIM - 1);
						else
							POS_INI := instr(descrição, Tip_lingua) + length(Tip_lingua);
							POS_FIM := instr(SUBSTR(descrição,POS_INI), CHR(13) || CHR(10)) - 1;
							if (POS_INI - length(Tip_lingua) - 1) = 0 then
								DESCR := DESCR || '';
							else
								if POS_FIM < 0 THEN
									DESCR := DESCR || ' ; ' || SUBSTR(descrição,POS_INI);
								else
									DESCR := DESCR || ' ; ' || SUBSTR(descrição,POS_INI,POS_FIM);
								end if;
							end if;
						end if;
					else
						POS_FIM := instr(descrição, CHR(13) || CHR(10));
						DESCR := DESCR || ' ; ' || SUBSTR(descrição,1,POS_FIM - 1);
					end if;
				end if;

--DIÂMETRO_INTERNO
				if nvl(cur.DIÂMETRO_INTERNO,0) <> 0 then
					if idioma = 'C' then
						--DESCR := DESCR || ' ; Diâmetro Interno ' || trim(replace(lnumling(cur.DIÂMETRO_INTERNO, '99999D999', 'C') || ' ', ', ', '')) || ' mm';
						DESCR := DESCR || ' ; Diametro Interno ' || trim(replace(round(cur.DIÂMETRO_INTERNO,2) || ' ', ', ', '')) || ' mm';
					elsif idioma = 'P' then
						--DESCR := DESCR || ' ; Diâmetro Interno ' || trim(replace(lnumling(cur.DIÂMETRO_INTERNO, '99999D999', 'P') || ' ', ', ', '')) || ' mm';
						DESCR := DESCR || ' ; Diâmetro Interno ' || trim(replace(round(cur.DIÂMETRO_INTERNO,2) || ' ', ', ', '')) || ' mm';
					--elsif idioma = 'I' then
					else
						--DESCR := DESCR || ' ; Internal Diameter ' || trim(replace(lnumling(cur.DIÂMETRO_INTERNO, '99999D999', 'I') || ' ', '. ', '')) || ' mm';
						DESCR := DESCR || ' ; Internal Diameter ' || trim(replace(replace(round(cur.DIÂMETRO_INTERNO,2),',','.') || ' ', ', ', '')) || ' mm';
					end if;
				end if;

--DIÂMETRO_EXTERNO
				if nvl(cur.DIÂMETRO_EXTERNO,0) <> 0 then
					if idioma = 'C' then
						--DESCR := DESCR || ' ; Diametro Externo ' || trim(replace(lnumling(cur.DIÂMETRO_EXTERNO, '99999D999', 'C') || ' ', ', ', '')) || ' mm';
						DESCR := DESCR || ' ; Diametro Externo ' || trim(replace(round(cur.DIÂMETRO_EXTERNO,2) || ' ', ', ', '')) || ' mm';
					elsif idioma = 'P' then
						--DESCR := DESCR || ' ; Diâmetro Externo ' || trim(replace(lnumling(cur.DIÂMETRO_EXTERNO, '99999D999', 'P') || ' ', ', ', '')) || ' mm';
						DESCR := DESCR || ' ; Diâmetro Externo ' || trim(replace(round(cur.DIÂMETRO_EXTERNO,2) || ' ', ', ', '')) || ' mm';
					--elsif idioma = 'I' then
					else
						--DESCR := DESCR || ' ; External Diameter ' || trim(replace(lnumling(cur.DIÂMETRO_EXTERNO, '99999D999', 'I') || ' ', '. ', '')) || ' mm';
						DESCR := DESCR || ' ; External Diameter ' || trim(replace(replace(round(cur.DIÂMETRO_EXTERNO,2),',','.') || ' ', ', ', '')) || ' mm';
					end if;
				end if;

--REVESTIMENTO
				if nvl(cur.REVESTIMENTO,' ') <> ' ' then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Recubrimento ' || cur.REVESTIMENTO;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Revestimento ' || cur.REVESTIMENTO;
					else
						DESCR := DESCR || ' ; Coating ' || cur.REVESTIMENTO;
					end if;
				end if;

--TÊMPERA
				if nvl(cur.TÊMPERA,' ') <> ' ' then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Temple ' || cur.TÊMPERA;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Têmpera ' || cur.TÊMPERA;
					else
						DESCR := DESCR || ' ; Temper ' || cur.TÊMPERA;
					end if;
				end if;


--ACABAMENTO
				if nvl(cur.ACABAMENTO,' ') <> ' ' then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Acabado ' || cur.ACABAMENTO;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Acabamento ' || cur.ACABAMENTO;
					else
						DESCR := DESCR || ' ; Finish ' || cur.ACABAMENTO;
					end if;
				end if;

--NORMA_TOLERÂNCIA
				if nvl(cur.NORMA_TOLERÂNCIA,' ') <> ' ' then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Norma de Tolerancia ' || cur.NORMA_TOLERÂNCIA;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Norma de Tolerância ' || cur.NORMA_TOLERÂNCIA;
					else
						DESCR := DESCR || ' ; Tol Norm ' || cur.NORMA_TOLERÂNCIA;
					end if;
				end if;

--NORMA_PRODUÇÃO
				if nvl(cur.NORMA_PRODUÇÃO,' ') <> ' ' then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Norma de Producion ' || cur.NORMA_PRODUÇÃO;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Norma de Produção ' || cur.NORMA_PRODUÇÃO;
					else
						DESCR := DESCR || ' ; Prod Norm ' || cur.NORMA_PRODUÇÃO;
					end if;
				end if;

--BORDAS
				if nvl(cur.BORDAS,' ') <> ' ' then
					SELECT QUANDO_TEXTO INTO descrição FROM PARAM WHERE GRUPO ='BORDAS' AND PARAM = cur.BORDAS;
					if not IDIOMA is null then
						Tip_lingua := IDIOMA || ':';
						SELECT COUNT(GRUPO) INTO RET_PROC FROM PARAM WHERE GRUPO = 'BORDAS' AND PARAM = cur.BORDAS AND UPPER(QUANDO_TEXTO) LIKE '%' || UPPER(Tip_lingua) || '%';
						if RET_PROC = 0 then
							 POS_FIM := instr(descrição, CHR(13) || CHR(10));
  							 RET := SUBSTR(descrição,1,POS_FIM - 1);
						else
							POS_INI := instr(descrição,Tip_lingua) + length(Tip_lingua);
							POS_FIM := instr(SUBSTR(descrição,POS_INI), CHR(13) || CHR(10)) - 1;
							if (POS_INI - length(Tip_lingua) - 1) = 0 then
								RET := '';
							else
								if POS_FIM < 0 then
									RET := SUBSTR(descrição,POS_INI);
								else
									RET := SUBSTR(descrição,POS_INI,POS_FIM);
								end if;
							end if;
						end if;
					else
						POS_FIM := instr(descrição, CHR(13) || CHR(10));
			  			RET := SUBSTR(descrição,1,POS_FIM - 1);
					end if;
					if idioma = 'C' then
						DESCR := DESCR || ' ; Bordas ' || nvl(RET, cur.BORDAS);
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Bordas ' || nvl(RET, cur.BORDAS);
					else
						DESCR := DESCR || ' ; Edge ' || nvl(RET, cur.BORDAS);
					end if;
				end if;

--OLEAMENTO
				if nvl(cur.OLEAMENTO,0) <> 0 then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Aceitado ' || cur.OLEAMENTO;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Oleamento ' || cur.OLEAMENTO;
					else
						DESCR := DESCR || ' ; Oiled ' || cur.OLEAMENTO;
					end if;
				end if;

--TRAT_TÉRMICO
				if nvl(cur.TRAT_TÉRMICO,0) <> 0 then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Tratam Termico ' || cur.TRAT_TÉRMICO;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Tratam Térmico ' || cur.TRAT_TÉRMICO;
					else
						DESCR := DESCR || ' ; Thermical Treat ' || cur.TRAT_TÉRMICO;
					end if;
				end if;

--TRAT_QUÍMICO
				if nvl(cur.TRAT_QUÍMICO,0) <> 0 then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Tratam Quimico ' || cur.TRAT_QUÍMICO;
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Tratam Químico ' || cur.TRAT_QUÍMICO;
					else
						DESCR := DESCR || ' ; Chemic Treat ' || cur.TRAT_QUÍMICO;
					end if;
				end if;

--LA
				if nvl(cur.LA,0) <> 0 then
					DESCR := DESCR || ' ; LA';
				end if;

--LE
				if nvl(cur.LE,0) <> 0 then
					DESCR := DESCR || ' ; LE';
				end if;

--LÍNGUA
				if nvl(cur.LÍNGUA,0) <> 0 then
					if idioma = 'C' then
						DESCR := DESCR || ' ; Lingua ';
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Língua ';
					else
						DESCR := DESCR || ' ; Tonque ';
					end if;
				end if;

--COMPOSIÇÃO_QUÍMICA
				if nvl(cur.COMPOSIÇÃO_QUÍMICA,' ') <> ' ' then
					DESCR := DESCR || ' ; ' || cur.COMPOSIÇÃO_QUÍMICA;
				end if;

--TOLERÂNCIA_MIN
				if nvl(cur.TOLERÂNCIA_MIN,0) <> 0 then
					VAL_TOL := cur.TOLERÂNCIA_MIN * 100;
					VAL_TOL := round(VAL_TOL);
					if idioma = 'C' then
						DESCR := DESCR || ' ; Tolerancia Min ' || VAL_TOL || ' %';
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Tolerancia Min ' || VAL_TOL || ' %';
					else
						DESCR := DESCR || ' ; Tolerance Min ' || VAL_TOL || ' %';
					end if;
				end if;

--TOLERÂNCIA_MAX
				if nvl(cur.TOLERÂNCIA_MAX,0) <> 0 then
					VAL_TOL := cur.TOLERÂNCIA_MAX * 100;
					VAL_TOL := round(VAL_TOL);
					if idioma = 'C' then
						DESCR := DESCR || ' ; Tolerancia Max ' || trim(VAL_TOL) || ' %';
					elsif idioma = 'P' then
						DESCR := DESCR || ' ; Tolerância Max ' || trim(VAL_TOL) || ' %';
					else
						DESCR := DESCR || ' ; Tolerance Max ' || trim(VAL_TOL) || ' %';
					end if;
				end if;

--EMBALAGEM_PESO_MAX
				if nvl(cur.EMBALAGEM_PESO_MAX,0) <> 0 then
					Tip_lingua := nvl(idioma,'I') || ':';
					SELECT COUNT(COD) INTO ret_proc FROM UNID_QUANTID WHERE COD = cur.PED_UNID AND UPPER(NOME) LIKE '%' || UPPER(Tip_lingua) || '%';
					SELECT NOME INTO descrição FROM UNID_QUANTID WHERE COD = cur.PED_UNID;
					if ret_proc = 0 then
						POS_FIM := instr(descrição,CHR(13) || CHR(10));
						RET := SUBSTR(descrição,1,POS_FIM - 1);
					else
						POS_INI := instr(descrição, Tip_lingua) + length(Tip_lingua);
						POS_FIM := instr(SUBSTR(descrição,POS_INI), CHR(13) || CHR(10)) - 1;
						if (POS_INI - length(Tip_lingua) - 1) = 0 then
							RET := ' ';
						else
							if POS_FIM < 0 then
								RET := SUBSTR(DESCRIÇÃO,POS_INI);
							else
								RET := SUBSTR(DESCRIÇÃO,POS_INI,POS_FIM);
							end if;
						end if;
					end if;
					VAL_EMB := round(cur.EMBALAGEM_PESO_MAX,1);
					if idioma = 'C' then
						if (VAL_EMB > 0) AND (VAL_EMB < 1) then
							DESCR := DESCR || ' ; Peso Max da Embalaje ' || '0' || VAL_EMB || ' ' || RET;
						else
							DESCR := DESCR || ' ; Peso Max da Embalaje ' || VAL_EMB || ' ' || RET;
						end if;
					elsif idioma = 'P' then
						if (VAL_EMB > 0) AND (VAL_EMB < 1) then
							DESCR := DESCR || ' ; Peso Max da Embalagem ' || '0' || VAL_EMB || ' ' || RET;
						else
							DESCR := DESCR || ' ; Peso Max da Embalagem ' || VAL_EMB || ' ' || RET;
						end if;
					else
						if (VAL_EMB > 0) AND (VAL_EMB < 1) then
							DESCR := DESCR || ' ; Max Weight of Volumes ' || '0' || replace(VAL_EMB,',','.') || ' ' || RET;
						else
							DESCR := DESCR || ' ; Max Weight of Volumes ' || replace(VAL_EMB,',','.') || ' ' || RET;
						end if;
					end if;
				end if;

--EMBALAGEM_PESO_MIN
				if nvl(cur.EMBALAGEM_PESO_MIN,0) <> 0 then
					Tip_lingua := nvl(idioma,'I') || ':';
					SELECT COUNT(COD) INTO ret_proc FROM UNID_QUANTID WHERE COD = cur.PED_UNID AND UPPER(NOME) LIKE '%' || UPPER(Tip_lingua) || '%';
					SELECT NOME INTO descrição FROM UNID_QUANTID WHERE COD = cur.PED_UNID;
					if ret_proc = 0 then
						POS_FIM := instr(descrição,CHR(13) || CHR(10));
						RET := SUBSTR(descrição,1,POS_FIM - 1);
					else
						POS_INI := instr(descrição, Tip_lingua) + length(Tip_lingua);
						POS_FIM := instr(SUBSTR(descrição,POS_INI), CHR(13) || CHR(10)) - 1;
						if (POS_INI - length(Tip_lingua) - 1) = 0 then
							RET := ' ';
						else
							if POS_FIM < 0 then
								RET := SUBSTR(DESCRIÇÃO,POS_INI);
							else
								RET := SUBSTR(DESCRIÇÃO,POS_INI,POS_FIM);
							end if;
						end if;
					end if;
					VAL_EMB := round(cur.EMBALAGEM_PESO_MIN,1);
					if idioma = 'C' then
						if (VAL_EMB > 0) AND (VAL_EMB < 1) then
							DESCR := DESCR || ' ; Peso Min da Embalaje ' || '0' || VAL_EMB || ' ' || RET;
						else
							DESCR := DESCR || ' ; Peso Min da Embalaje ' || VAL_EMB || ' ' || RET;
						end if;
					elsif idioma = 'P' then
						if (VAL_EMB > 0) AND (VAL_EMB < 1) then
							DESCR := DESCR || ' ; Peso Min da Embalagem ' || '0' || VAL_EMB || ' ' || RET;
						else
							DESCR := DESCR || ' ; Peso Min da Embalagem ' || VAL_EMB || ' ' || RET;
						end if;
					else
						if (VAL_EMB > 0) AND (VAL_EMB < 1) then
							DESCR := DESCR || ' ; Min Weight of Volumes ' || '0' || replace(VAL_EMB,',','.') || ' ' || RET;
						else
							DESCR := DESCR || ' ; Min Weight of Volumes ' || replace(VAL_EMB,',','.') || ' ' || RET;
						end if;
					end if;
				end if;

				if litem(OutraRef, 'PO ' || cur.PO) = 0 and NVL(cur.PO, ' ') <> ' ' then
					if OutraRef is null then
						OutraRef := OutraRef || 'PO ' || cur.PO;
					else
						OutraRef := OutraRef || ';PO ' || cur.PO;
					end if;
				end if;
				SELECT MAX(ITEM) INTO MAXITEM FROM CXRJ.CONFIRM_VENDA_ITEM WHERE CONFIRM_VENDA_REF = confirm AND SEQ = in_seq;
				MAXITEM := NVL(MAXITEM,0) + 1;
				if DESCR <> ' ' then
					DESCR := SUBSTR(DESCR,4);
				end if;
				INSERT INTO CXRJ.CONFIRM_VENDA_ITEM (CONFIRM_VENDA_REF, SEQ, ITEM, DESCR, DIMENSÃO, QTD, UNID, QUALIDADE, PREÇO, PREÇO_C) VALUES (confirm, in_seq, MAXITEM, NVL(DESCR,NULL), cur.DIMENSÃO, cur.NOMINAL_METRIC_TONS, cur.PED_UNID, SUBSTR(cur.PROD_DESCR,1,15), cur.PREÇO_UNITÁRIO_IMP, cur.PREÇO_UNITÁRIO_FORNECEDOR);
			end loop;
			RET := idioma;
                        update CXRJ.CONFIRM_VENDA set DESCARGA_PORTO = DECODE(shipmentTo,1,DECODE(PORTO_DESC,NULL,DESC_PORTO,PORTO_DESC),confirm_venda.descarga_porto), USUÁRIO_FINAL = decode(endUser,1,USU_FINAL,confirm_venda.usuário_final), OUTRA_REF = DECODE(OutraRef,NULL,NULL,replace(OutraRef,';',CHR(13) || CHR(10))), IDIOMA = RET, DIMENSÃO = medida, EMISSÃO_DATA = decode(op,'I',sysdate,confirm_venda.emissão_data), dt_revisão = decode(op,'A',sysdate,null)  WHERE REF = confirm AND SEQ = in_seq;
			COMMIT;
                  else
			DESCR := '';
			for cur in (SELECT * FROM PED_ITEM WHERE PED_REF = pedido) loop

                               if litem(OutraRef, 'PO ' || cur.PO) = 0 and NVL(cur.PO, ' ') <> ' ' then
                                        if OutraRef is null then
                                                OutraRef := OutraRef || 'PO ' || cur.PO;
                                        else
                                                OutraRef := OutraRef || ';PO ' || cur.PO;
                                        end if;
                                end if;
				DESCR := '';
				USU_FINAL := NVL(cur.USUÁRIO_FINAL,'');
				PORTO_DESC := NVL(cur.DESCARGA_PORTO,'');
-- ****
				SELECT MAX(ITEM) INTO MAXITEM FROM CXRJ.CONFIRM_VENDA_ITEM WHERE CONFIRM_VENDA_REF = confirm AND SEQ = in_seq;
				MAXITEM := NVL(MAXITEM,0) + 1;
				INSERT INTO CXRJ.CONFIRM_VENDA_ITEM (CONFIRM_VENDA_REF, SEQ, ITEM, DESCR, DIMENSÃO, QTD, UNID, PREÇO, PREÇO_C) VALUES (confirm, in_seq, MAXITEM, cur.PROD_DESCR, cur.DIMENSÃO, cur.NOMINAL_METRIC_TONS, cur.PED_UNID, cur.PREÇO_UNITÁRIO_IMP, cur.PREÇO_UNITÁRIO_FORNECEDOR);
			end loop;
			RET := idioma;
			update CXRJ.CONFIRM_VENDA set DESCARGA_PORTO = DECODE(shipmentTo,1,DECODE(PORTO_DESC,NULL,DESC_PORTO,PORTO_DESC),confirm_venda.descarga_porto), USUÁRIO_FINAL = decode(endUser,1,USU_FINAL,confirm_venda.usuário_final), OUTRA_REF = DECODE(OutraRef,NULL,NULL,replace(OutraRef,';',CHR(13) || CHR(10))), IDIOMA = RET, DIMENSÃO = medida, EMISSÃO_DATA = decode(op,'I',sysdate,confirm_venda.emissão_data), dt_revisão = decode(op,'A',sysdate,null)  WHERE REF = confirm AND SEQ = in_seq;
			COMMIT;
                  end if;
		end if;

	end confirm;

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
		elsif Ling = 'EURO' then
	    		StrUnid := 'One;Two;Three;Four;Five;Six;Seven;Eight;Nine';
	    		StrPrimaDez := 'Eleven;Twelve;Thirteen;Fourteen;Fifteen;Sixteen;Seventeen;Eighteen;Nineteen';
	    		StrDez := 'Ten;Twenty;Thirty;Forty;Fifty;Sixty;Seventy;Eighty;Ninety';
	    		StrCem := 'One Hundred;Two Hundred;Three Hundred;Four Hundred;Five Hundred;Six Hundred;Seven Hundred;Eight Hundred;Nine Hundred';
	    		StrMil := 'Thousand.Thousand;Million.Millions;Billion.Billions;Trillion.Trillions';
	    		StrCent := 'Cent.Cents';
			MOEDA := 'Euro;Euro;Euro';
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
--Função criada para enviar por e-mail os preços(do pedido) alterados após terem suas marcadorias embarcadas || Gilvan Data: 06/07/2006
        procedure precoAlteradoAposEmb(de in varchar, para in varchar, adm in varchar2 ,servidor_msg in varchar) as
        Begin
        Declare
        public_dir VARCHAR2(30);
        arquivo varchar2(30);
        ret integer;
        PRECO_IMP VARCHAR2(1);
        PRECO_EXP VARCHAR2(1);
        COR_IMP VARCHAR2(25);
        COR_EXP VARCHAR2(25);
        TOT_REG INTEGER;
        cursor c_cad_log is sELECT * from cxrj.preco_ped_emb_diferente where ATUALIZAÇÃO_IMP_PED = 'A' or ATUALIZAÇÃO_EXP_PED = 'A' ORDER BY PEDIDO, ITEM;
        begin
            arquivo := 'PreçosAlterados.htm';
            Ret :=   DBMS_CX.DOSSHELL('DEL ' || public_dir || '\' || arquivo);
            sELECT COUNT(*) INTO TOT_REG from cxrj.preco_ped_emb_diferente where ATUALIZAÇÃO_IMP_PED = 'A' or ATUALIZAÇÃO_EXP_PED = 'A' ORDER BY PEDIDO, ITEM;
            IF TOT_REG > 0 THEN
                public_dir := 'd:\oracle\public';
                dbms_cx.grava_log('<html><head><title>CIEX - Preços alterados após o embarque.</title></head><body bgcolor= #C0C0C0 text= #0000FF >',arquivo);
                dbms_cx.grava_log('<p align= center ><font face= Arial  size= 3 ><b>CIEX - Preços alterados após o embarque</b></font></p><table border= 1  width= 100% >',arquivo);
                dbms_cx.grava_log('<tr><td width= 9%  align= center ><p align= center ><b><font face= Arial SIZE =2>Pedido</font></b></td>',arquivo);
                dbms_cx.grava_log('<td width= 8%  align= center ><b><font face= Arial SIZE = 2>Embarque</font></b></td>',arquivo);
                dbms_cx.grava_log('<td width= 13%  align= center ><b><font face= Arial SIZE =2>Preço Imp. Pedido <BR></font> <font face = arial size = 1>Anterior / Atual</font></b></td><td width= 7%  align= CENTER ><b><font face= Arial SIZE =2 >Preço Imp. Embarque</font></b></td>',arquivo);
                dbms_cx.grava_log('<td width= 13%  align= center ><b><font face= Arial SIZE =2>Preço Exp. Pedido <BR></font> <font face = arial size = 1>Anterior / Atual</font></b></td><td width= 7%  align= center ><b><font face= Arial SIZE =2 >Preço Exp. Embarque</font></b></td>',arquivo);
                dbms_cx.grava_log('<td width= 14%  align= center ><b><font face= Arial SIZE =2>Última Atualização Pedido</font></b></td>',arquivo);
                dbms_cx.grava_log('<td width= 14%  align= center ><b><font face= Arial SIZE =2 >Última Atualização Embarque</font></b></td>',arquivo);
                for  CUR in  C_CAD_LOG loop -- células da tabela
                    if CUR.preço_IMP_pedido_NEW <> CUR.PREÇO_IMP_EMBARQUE THEN
			COR_IMP := ' COLOR = #FF0000';
                    ELSE
			COR_IMP := '';
                    END IF;
                    if CUR.preço_EXP_pedido_NEW <> CUR.PREÇO_EXP_EMBARQUE THEN
			COR_EXP := ' COLOR = #FF0000';
                    ELSE
			COR_EXP := '';
                    END IF;
                    dbms_cx.grava_log('<tr><td width=9% align=center><font face=Arial size=1> ' || CUR.PEDIDO || '.' || CUR.ITEM || '</font></td>',arquivo);
                    dbms_cx.grava_log('<td width=8% align=center><font face=Arial size=1>' || CUR.EMBARQUE || ' </font></td>',arquivo);
                    dbms_cx.grava_log('<td width=13% align=center><font face=Arial size=1' || COR_IMP || ' >' || formataValor(cur.Preço_Imp_Pedido_Old) || ' / ' || formataValor(cur.Preço_Imp_Pedido_New) || ' </font></td>',arquivo);
                    dbms_cx.grava_log('<td width=7% align=CENTER><font face=Arial size=1>' || formataValor(CUR.preço_imp_embarque) || ' </font></td>',arquivo);
                    dbms_cx.grava_log('<td width=13% align=center><font face=Arial size=1' || COR_EXP || ' >' || formataValor(CUR.preço_exp_pedido_old) || ' / ' ||  formataValor(CUR.preço_EXP_pedido_new) || ' </font></td>',arquivo);
                    dbms_cx.grava_log('<td width=7% align=CENTER><font face=Arial size=1>' || formataValor(CUR.preço_exp_embarque) || ' </font></td>',arquivo);
                    dbms_cx.grava_log('<td width=14% align=center><font face=Arial size=1>' || CUR.ATUALIZAÇÃO_PEDIDO || ' </font></td>',arquivo);
                    dbms_cx.grava_log('<td width=14% align=center><font face=Arial size=1>' || CUR.ATUALIZAÇÃO_EMBARQUE || ' </font></td>',arquivo);
                end loop;
                dbms_cx.grava_log('</table><font face=Arial size=1 color = #FF0000>Data: ' || to_char(sysdate,'dd/mon/yyyy') || '</font></body></html>',arquivo); -- fim da tabela e fim do HTML
                Ret :=   DBMS_CX.DOSSHELL('sendmail -f ' || de || ' -t ' || replace(Para, ';', ' -t ') || ' -s "CIEX - Preços alterados após o embarque" -b "CIEX - Controle de Exportação e Importação." -a ' ||  public_dir || '\' || arquivo || ' -m ' || servidor_msg || '');
                Ret :=   DBMS_CX.DOSSHELL('DEL ' || public_dir || '\' || arquivo);
            ELSE
              Ret := DBMS_CX.DOSSHELL('sendmail -f ' || de || ' -t ' || replace(adm, ';', ' -t') || ' -s "CIEX - Preços alterados após o embarque - NENHUM PREÇO FOI ALTERADO" -b "NENHUM PREÇO FOI ALTERADO - ' || to_char(sysdate,'dd/mon/yyyy') || '"  -m ' || servidor_msg || '');
            END IF;
            delete from cxrj.preco_ped_emb_diferente;
            commit;
            exception
                when others then
                    Ret := DBMS_CX.DOSSHELL('sendmail -f ' || de || ' -t ' || replace(adm, ';', ' -t') || ' -s "ERRO - CIEX - Preços alterados após o embarque - ERRO" -b"' || sqlerrm || chr(10) || to_char(sysdate,'dd/mon/yyyy') || '" -m ' || servidor_msg || '');
                    raise_application_error (-20000, 'Erro Precos alterados apos o embarque: ' || chr(10) || sqlerrm);
            end;
        end precoAlteradoAposEmb;
--função criada para auxiliar a procedure PreçoAlteradoApósEmb || Gilvan Data: 06/07/2006
        function formataValor(valor in number default -99999) return varchar2 is
        result varchar2(25);
        begin
            if valor = -99999 then
                result := 'Nulo';
            else
                result := TO_CHAR(valor,'999G999G9990D00');
            end if;
            return nvl(result,'Nulo');
        exception
          when others then
              raise_application_error (-20000, 'Erro na função formataValor: ' || chr(10) || sqlerrm);
        end formataValor;
end lb;
/