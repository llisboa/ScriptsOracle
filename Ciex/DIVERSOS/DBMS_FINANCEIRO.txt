create or replace package  DBMS_FINANCEIRO is
	procedure mensagemNovoProcesso (vrFinaRef in varchar2, vrEmpresa in varchar2, de in varchar2, para in varchar2, servidor in varchar2);
	procedure mensagemNovoPedido (vData in date,de in varchar2, para in varchar2, adm in varchar2, servidor in varchar2);
	procedure mensagemNovoEmbarque (vData in date,de in varchar2, para in varchar2, adm in varchar2, servidor in varchar2);
	procedure mensagemPedidoEditado (de in varchar2, para in varchar2, adm in varchar2, servidor in varchar2);
	procedure lanca_despesa_padrao (v_referencia  in varchar2) ;
	procedure lancamento_worksheet (proc in varchar2, arquivo in varchar2, worksheet in varchar2, tipo in varchar2, coluna_imp in integer, linha in number, coluna in number, valor in number, nome_banco in varchar2, data in date, sub_conta in number, despesa in varchar, transacao in varchar2, v_historico in varchar2) ;
	procedure atualiza_saldo (proc in varchar2, work in varchar2) ;
	procedure atualiza_juros ( v_ref in varchar2 , v_empresa in varchar2) ;
	procedure calcula_juros ( v_referencia in varchar2);
	procedure atualiza_proft (v_referencia in varchar2) ;
	procedure log_erro_lancamento_worksheet (arquivo in varchar2, worksheet in varchar2, tipo in varchar2, linha in number, coluna in number, empresa_conta in varchar2, processo in varchar2  default '', situacao in varchar2, transacao in varchar2, coluna_imp in number);
	procedure ordenar_lancamento (v_ref in varchar2, v_empresa in varchar2  default 'ambas');
	procedure ordenar (v_referencia in varchar2);
	procedure lanca_despesa_padrao_empresa (v_processo in varchar2, v_empresa in varchar2) ;


end;

/
create or replace package body DBMS_FINANCEIRO is
--exec dbms_financeiro.mensagemPedidoEditado ('daniel.costa@xxxxxxx.com.br', 'daniel.costa@xxxxxxx.com.br', 'daniel.costa@xxxxxxx.com.br', '10.0.0.5')
--@C:\2008\Financeiro\DBMS_FINANCEIRO.SQL
procedure mensagemPedidoEditado (de in varchar2, para in varchar2, adm in varchar2, servidor in varchar2) is
        public_dir VARCHAR2(30);
  	arquivo varchar2(30);
  	ret integer;
  	ToT_Reg integer;
	larg number;
	cont number;

	primeiro varchar2(1);

	vImp varchar2(30);
	vExp varchar2(30);
	vForn varchar2(30);
	vDist varchar2(30);
	vPag varchar2(30);
	vProd varchar2(30);


begin


select count (*) into cont from log_altera_pedido;

if nvl(cont,0) !=0 then
                public_dir := 'd:\oracle\public';
  		arquivo := 'PedidosAlterados.htm';
  		ret := DBMS_CX.DOSSHELL('DEL ' || public_dir || '\' || arquivo);

	dbms_cx.grava_log('<html>',arquivo);
	dbms_cx.grava_log('<head><title>Ciex - Pedidos Alterados</title>',arquivo);
	dbms_cx.grava_log('<style type="text/css">',arquivo);
	dbms_cx.grava_log('<!--',arquivo);
	dbms_cx.grava_log('.TextoNormal {',arquivo);
	dbms_cx.grava_log('	font-family: Verdana, Arial;',arquivo);
	dbms_cx.grava_log('	font-size: 10px;',arquivo);
	dbms_cx.grava_log('}',arquivo);
	dbms_cx.grava_log('.TextoNormal_2 {',arquivo);
	dbms_cx.grava_log('	font-family: Verdana, Arial;',arquivo);
	dbms_cx.grava_log('	font-size: 15px;',arquivo);
	dbms_cx.grava_log('	font-weight: bolder;',arquivo);
	dbms_cx.grava_log('}',arquivo);
	dbms_cx.grava_log('.Label {',arquivo);
	dbms_cx.grava_log('	font-family: Arial;',arquivo);
dbms_cx.grava_log('	font-size: 11px;',arquivo);
dbms_cx.grava_log('	font-weight:bold;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.BoxText {',arquivo);
dbms_cx.grava_log('	font-family: Verdana, Arial;',arquivo);
dbms_cx.grava_log('	font-size: 11px;',arquivo);
dbms_cx.grava_log('	color: #000000;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.borda_tabela {',arquivo);
dbms_cx.grava_log('	border: 1px solid #000000;',arquivo);
dbms_cx.grava_log('	font-family: ARIAL;',arquivo);
dbms_cx.grava_log('	font-size: 11px;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.style3 {color: #990000}',arquivo);
dbms_cx.grava_log('-->',arquivo);
dbms_cx.grava_log('</style>',arquivo);
dbms_cx.grava_log('</head>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<body bgcolor= #EEEEEE text= #0000FF>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<center>',arquivo);
dbms_cx.grava_log('<span class="TextoNormal_2">Pedidos Alterados</span><br>',arquivo);
dbms_cx.grava_log('<hr width="800">',arquivo);
dbms_cx.grava_log('<br>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<table width="800" border="0">',arquivo);
dbms_cx.grava_log('  <tr class="borda_tabela">',arquivo);
dbms_cx.grava_log('    <td width="120" >Pedido</td>',arquivo);
dbms_cx.grava_log('    <td width="136" >Campo</td>',arquivo);
dbms_cx.grava_log('    <td width="290" >Alterações</td>',arquivo);
dbms_cx.grava_log('    <td width="100" >Usuário</td>',arquivo);
dbms_cx.grava_log('    <td width="55" >Local</td>',arquivo);
dbms_cx.grava_log('    <td width="73" >Data</td>',arquivo);
dbms_cx.grava_log('  </tr>',arquivo);
dbms_cx.grava_log('</table>',arquivo);
dbms_cx.grava_log('',arquivo);


	declare cursor cur_ped is
		SELECT PED_REF FROM LOG_ALTERA_PEDIDO GROUP BY PED_REF;

	begin



		for cur_p in cur_ped loop
		primeiro := 's';
		declare cursor cur_campo is
			SELECT * FROM LOG_ALTERA_PEDIDO WHERE PED_REF = cur_p.PED_REF;
		begin

			dbms_cx.grava_log('<table width="800" border="0" bordercolor="#000000">',arquivo);
			dbms_cx.grava_log('  <tr>',arquivo);
			dbms_cx.grava_log('    <td class="borda_tabela">',arquivo);
			dbms_cx.grava_log('',arquivo);

		for cur_c in cur_campo loop

			dbms_cx.grava_log('<table width="800" border="0">',arquivo);
			dbms_cx.grava_log('  <tr class="BoxText">',arquivo);

			if primeiro = 's' then
				dbms_cx.grava_log('    <td width="120" >' || cur_c.PED_REF || '</td>',arquivo);
				primeiro := 'n';
			else
				dbms_cx.grava_log('    <td width="120" ></td>',arquivo);
			end if;

			dbms_cx.grava_log('    <td width="136" >' || cur_c.CAMPO || '</td>',arquivo);
			dbms_cx.grava_log('    <td width="290" ><span class="style3">de:</span>' || cur_c.DE || ' <span class="style3">para</span>:' || cur_c.PARA || '</td>',arquivo);
			dbms_cx.grava_log('    <td width="100" >' || cur_c.USUÁRIO || '</td>',arquivo);
			dbms_cx.grava_log('    <td width="55" >' || cur_c.LOCAL || '</td>',arquivo);
			dbms_cx.grava_log('    <td width="73" >' || TO_CHAR(cur_c.MOMENTO,'DD-MM-YYYY') || '</td>',arquivo);
			dbms_cx.grava_log('  </tr>',arquivo);
			dbms_cx.grava_log('',arquivo);
			dbms_cx.grava_log('</table>',arquivo);
		end loop;

		end;

dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('	</td>',arquivo);
dbms_cx.grava_log('  </tr>',arquivo);
dbms_cx.grava_log('</table>',arquivo);

		end loop;

		end;

dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('</center>',arquivo);
dbms_cx.grava_log('</body>',arquivo);
dbms_cx.grava_log('</html>',arquivo);


	ret := dbms_cx.sendmail(de, para,'Pedidos Alterados', servidor, 'Pedidos Alterados' ,public_dir || '\' || arquivo);
	delete from log_altera_pedido;
ELSE
	ret := dbms_cx.sendmail(de, adm, 'Pedidos Alterados', servidor, 'Não houveram pedidos alterados');


end if;

end mensagemPedidoEditado;

procedure mensagemNovoProcesso  (vrFinaRef in varchar2, vrEmpresa in varchar2, de in varchar2, para in varchar2, servidor in varchar2) is
        public_dir VARCHAR2(30);
  	arquivo varchar2(30);
  	ret integer;
  	ToT_Reg integer;
	larg number;

	cont number;
begin

			select count (*) into cont from ped;
		--variaveis para a escrita do Email

                public_dir := 'd:\oracle\public';
  		arquivo := 'NovoProcesso.htm';
  		ret := DBMS_CX.DOSSHELL('DEL ' || public_dir || '\' || arquivo);




	declare
		cursor cur_mc IS select * from processo where ref = vrFinaRef and empresa = vrEmpresa ;

		begin
			for cur in cur_mc loop

dbms_cx.grava_log('<html>',arquivo);
dbms_cx.grava_log('<head><title>Ciex - Processos Criados</title>',arquivo);
dbms_cx.grava_log('<style type="text/css">',arquivo);
dbms_cx.grava_log('<!--',arquivo);
dbms_cx.grava_log('.TextoNormal {',arquivo);
dbms_cx.grava_log('	font-family: Verdana, Arial;',arquivo);
dbms_cx.grava_log('	font-size: 10px;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.TextoNormal_2 {',arquivo);
dbms_cx.grava_log('	font-family: Verdana, Arial;',arquivo);
dbms_cx.grava_log('	font-size: 15px;',arquivo);
dbms_cx.grava_log('	font-weight: bolder;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.Label {',arquivo);
dbms_cx.grava_log('	font-family: Arial;',arquivo);
dbms_cx.grava_log('	font-size: 11px;',arquivo);
dbms_cx.grava_log('	font-weight:bold;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.BoxText {',arquivo);
dbms_cx.grava_log('	font-family: Verdana, Arial;',arquivo);
dbms_cx.grava_log('	font-size: 11px;',arquivo);
dbms_cx.grava_log('	color: #000000;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.style1 {font-size: 12px}',arquivo);
dbms_cx.grava_log('-->',arquivo);
dbms_cx.grava_log('</style>',arquivo);
dbms_cx.grava_log('</head>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<body bgcolor= #EEEEEE text= #0000FF>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<center>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<span class="TextoNormal_2">Processo Criado pelo Financeiro</span><br>',arquivo);
dbms_cx.grava_log('<hr width="800">',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<table width="800" border="0">',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log(' <tr>',arquivo);
dbms_cx.grava_log('    <td width="12%" class="Label">Ref:</td>',arquivo);
dbms_cx.grava_log('    <td width="21%" class="BoxText"> '  || cur.REF || ' </td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="14%" class="Label">Empresa:</td>',arquivo);
dbms_cx.grava_log('    <td width="21%" class="BoxText">'  || cur.EMPRESA || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="16%" class="Label">Data de Criação</td>',arquivo);
dbms_cx.grava_log('    <td width="16%" class="BoxText">'  || TO_CHAR (SYSDATE,'DD-MM-YYYY') || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('  </tr>',arquivo);
dbms_cx.grava_log(' ',arquivo);
dbms_cx.grava_log('</table>',arquivo);
dbms_cx.grava_log('<br>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<table width="800" border="0">',arquivo);
dbms_cx.grava_log('  <tr>',arquivo);
dbms_cx.grava_log('    <td width="12%" class="Label">Fornecedor:</td>',arquivo);
dbms_cx.grava_log('    <td width="21%" class="BoxText">'  || cur.FORNECEDOR || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="14%" class="Label">Porto Carga:</td>',arquivo);
dbms_cx.grava_log('    <td width="21%" class="BoxText">'  || cur.CARGA_PORTO || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="16%" class="Label">Peso Líquido (Ton):</td>',arquivo);
dbms_cx.grava_log('    <td width="16%" class="BoxText">'  || cur.PESO_LÍQUIDO || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('  </tr>',arquivo);
dbms_cx.grava_log('  <tr>',arquivo);
dbms_cx.grava_log('    <td class="Label">Cliente:</td>',arquivo);
dbms_cx.grava_log('    <td class="BoxText">'  || cur.CLIENTE  || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="14%" class="Label">Porto Descarga:</td>',arquivo);
dbms_cx.grava_log('    <td width="21%" class="BoxText">'  || cur.DESCARGA_PORTO || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="16%" class="Label">Peso Bruto (Ton):</td>',arquivo);
dbms_cx.grava_log('    <td width="16%" class="BoxText">'  || cur.PESO_BRUTO || '</td>',arquivo);
dbms_cx.grava_log('  </tr>',arquivo);
dbms_cx.grava_log(' <tr>',arquivo);
dbms_cx.grava_log('    <td class="Label">País Destino:</td>',arquivo);
dbms_cx.grava_log('    <td class="BoxText">'  || cur.PAÍS_DESTINO || '</td>',arquivo);
dbms_cx.grava_log('  ',arquivo);
dbms_cx.grava_log('    <td width="14%" class="Label">Navio:</td>',arquivo);
dbms_cx.grava_log('    <td width="21%" class="BoxText">'  || cur.NAVIO || '</td>',arquivo);
dbms_cx.grava_log('  ',arquivo);
dbms_cx.grava_log('  </tr>',arquivo);
dbms_cx.grava_log('  <tr>',arquivo);
dbms_cx.grava_log('    <td class="Label">Produto:</td>',arquivo);
dbms_cx.grava_log('    <td class="BoxText">'  || cur.GRUPO || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td class="Label">Data BL:</td>',arquivo);
dbms_cx.grava_log('    <td class="BoxText">'  || TO_CHAR(cur.BL_DATA,'DD-MM-YYYY') || '</td>',arquivo);
dbms_cx.grava_log('  </tr>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('</table>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<br>',arquivo);
dbms_cx.grava_log('<table border = 0>',arquivo);
dbms_cx.grava_log('  <tr><td class = "TextoNormal">'  || TO_CHAR(SYSDATE,'DD-MM-YYYY') || '</td>',arquivo);
dbms_cx.grava_log('</tr></table>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('</center>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('</body>',arquivo);
dbms_cx.grava_log('</html>',arquivo);
			end loop;

		end;


	ret := dbms_cx.sendmail(de, para,'Processos Criados pelo Financeiro',servidor, 'Processos Criados pelo Financeiro',public_dir || '\' || arquivo);
end;

procedure mensagemNovoPedido (vData in date,de in varchar2, para in varchar2, adm in varchar2, servidor in varchar2) is
        public_dir VARCHAR2(30);
  	arquivo varchar2(30);
  	ret integer;
  	ToT_Reg integer;
	larg number;
	cont number;

	vImp varchar2(30);
	vExp varchar2(30);
	vForn varchar2(30);
	vDist varchar2(30);
	vPag varchar2(30);
	vProd varchar2(30);


begin


select count (*) into cont from ped where to_char(sys_momento_cria, 'DD-MM-YYYY')  = to_char(vData, 'DD-MM-YYYY');


if nvl(cont,0) !=0 then
                public_dir := 'd:\oracle\public';
  		arquivo := 'PedidosCriados.htm';
  		ret := DBMS_CX.DOSSHELL('DEL ' || public_dir || '\' || arquivo);

dbms_cx.grava_log('<html>',arquivo);
dbms_cx.grava_log('<head><title>Ciex - Processos Criados</title>',arquivo);
dbms_cx.grava_log('<style type="text/css">',arquivo);
dbms_cx.grava_log('<!--',arquivo);
dbms_cx.grava_log('.TextoNormal {',arquivo);
dbms_cx.grava_log('	font-family: Verdana, Arial;',arquivo);
dbms_cx.grava_log('	font-size: 10px;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.TextoNormal_2 {',arquivo);
dbms_cx.grava_log('	font-family: Verdana, Arial;',arquivo);
dbms_cx.grava_log('	font-size: 15px;',arquivo);
dbms_cx.grava_log('	font-weight: bolder;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.Label {',arquivo);
dbms_cx.grava_log('	font-family: Arial;',arquivo);
dbms_cx.grava_log('	font-size: 11px;',arquivo);
dbms_cx.grava_log('	font-weight:bold;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.BoxText {',arquivo);
dbms_cx.grava_log('	font-family: Verdana, Arial;',arquivo);
dbms_cx.grava_log('	font-size: 11px;',arquivo);
dbms_cx.grava_log('	color: #000000;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.style1 {font-size: 12px}',arquivo);
dbms_cx.grava_log('-->',arquivo);
dbms_cx.grava_log('</style>',arquivo);
dbms_cx.grava_log('</head>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<body bgcolor= #EEEEEE text= #0000FF>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<center>',arquivo);

dbms_cx.grava_log('<span class="TextoNormal_2">Pedidos Criados</span><br>',arquivo);

	declare
		cursor c_pedidos is select * from ped where to_char(sys_momento_cria, 'DD-MM-YYYY')  = to_char(vData, 'DD-MM-YYYY');
	begin




		for cur in c_pedidos loop

	vImp := '';
	vExp := '';
	vForn := '';
	vDist := '';
	vPag := '';
	vProd := '';


select f_cod into vimp from cia where cod = nvl(cur.imp,'xxx');
select f_cod into vForn from cia where cod = nvl(cur.fornecedor,'xxx');
select f_cod into vexp from cia where cod = nvl(cur.exp,'xxx');
select f_cod into vdist from cia where cod = nvl(cur.distribuidor,'xxx');
select f_cod into vpag from cia where cod = nvl(cur.pagador,'xxx');
--select f_cod into vprod from cia where cod = nvl(cur.produtor,'xxx');




dbms_cx.grava_log('<hr width="800">',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<table width="800" border="0">',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log(' <tr>',arquivo);
dbms_cx.grava_log('    <td width="12%" class="Label">Ref:</td>',arquivo);
dbms_cx.grava_log('    <td width="17%" class="BoxText">' || cur.ref  || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="17%" class="Label">Usuario:</td>',arquivo);
dbms_cx.grava_log('    <td width="17%" class="BoxText">' || cur.sys_usuário_cria  || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="21%" class="Label">Local:</td>',arquivo);
dbms_cx.grava_log('    <td width="16%" class="BoxText">' || cur.sys_local_cria  || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('  </tr>',arquivo);
dbms_cx.grava_log(' ',arquivo);
dbms_cx.grava_log('</table>',arquivo);
dbms_cx.grava_log('<br>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<table width="800" border="0">',arquivo);
dbms_cx.grava_log('  <tr>',arquivo);
dbms_cx.grava_log('    <td width="12%" height="19" class="Label">Produtor:</td>',arquivo);
dbms_cx.grava_log('    <td width="17%" class="BoxText">' || nvl(vprod,'')  || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="17%" class="Label">Pagador:</td>',arquivo);
dbms_cx.grava_log('    <td width="17%" class="BoxText">' || nvl(vpag,'') || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="21%" class="Label">Distribuidor:</td>',arquivo);
dbms_cx.grava_log('    <td width="16%" class="BoxText">' || nvl(vdist,'') || '</td>',arquivo);
dbms_cx.grava_log('  </tr>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('  <tr>',arquivo);
dbms_cx.grava_log('    <td width="12%" height="19" class="Label">Fornecedor:</td>',arquivo);
dbms_cx.grava_log('    <td width="17%" class="BoxText">' || nvl(vforn,'') || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="17%" class="Label">Forn. Cond Venda :</td>',arquivo);
dbms_cx.grava_log('    <td width="17%" class="BoxText">' || cur.fornecedor_cond_venda  || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="21%" class="Label">Peso Líquido (Ton):</td>',arquivo);
dbms_cx.grava_log('    <td width="16%" class="BoxText">' || cur.fornecedor_cond_receb  || '</td>',arquivo);
dbms_cx.grava_log('  </tr>',arquivo);
dbms_cx.grava_log('  <tr>',arquivo);
dbms_cx.grava_log('    <td class="Label">Intervenient I:</td>',arquivo);
dbms_cx.grava_log('    <td class="BoxText">' || nvl(vimp,'') || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="17%" class="Label">Int I . Cond Venda:</td>',arquivo);
dbms_cx.grava_log('    <td width="17%" class="BoxText">' || cur.imp_cond_venda  || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="21%" class="Label">Int I . Cond. Recebimento:</td>',arquivo);
dbms_cx.grava_log('    <td width="16%" class="BoxText">' || cur.imp_cond_receb  || '</td>',arquivo);
dbms_cx.grava_log('  </tr>',arquivo);
dbms_cx.grava_log(' <tr>',arquivo);
dbms_cx.grava_log('    <td class="Label">Intervenient II:</td>',arquivo);
dbms_cx.grava_log('    <td class="BoxText">' || nvl(vexp,'')  || '</td>',arquivo);
dbms_cx.grava_log('  ',arquivo);
dbms_cx.grava_log('    <td width="17%" class="Label">Int II . Cond Venda:</td>',arquivo);
dbms_cx.grava_log('    <td width="17%" class="BoxText">' || cur.exp_cond_venda  || '</td>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('    <td width="21%" class="Label">Int II . Cond. Recebimento:</td>',arquivo);
dbms_cx.grava_log('    <td width="16%" class="BoxText">' || cur.exp_cond_receb || '</td>',arquivo);
dbms_cx.grava_log('  </tr>',arquivo);
dbms_cx.grava_log('</table>',arquivo);


		end loop;

	end;

dbms_cx.grava_log('<br>',arquivo);
dbms_cx.grava_log('<table border = 0>',arquivo);
dbms_cx.grava_log('  <tr><td class = "TextoNormal">'  || TO_CHAR(vData,'DD-MM-YYYY') || '</td>',arquivo);
dbms_cx.grava_log('</tr></table>',arquivo);




dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('</center>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('</body>',arquivo);
dbms_cx.grava_log('</html>',arquivo);







	ret := dbms_cx.sendmail(de, para,'Pedidos Criados', servidor, 'Pedidos Criados em ' || to_char (vData,'DD-MM-YYYY') ,public_dir || '\' || arquivo);
ELSE
	ret := dbms_cx.sendmail(de, adm, 'Pedidos Criados', servidor, 'Não houveram pedidos criados em ' || to_char (vData,'DD-MM-YYYY') );

end if;

end mensagemNovoPedido;


procedure mensagemNovoEmbarque (vData in date,de in varchar2, para in varchar2, adm in varchar2, servidor in varchar2) is
        public_dir VARCHAR2(30);
  	arquivo varchar2(30);
  	ret integer;
  	ToT_Reg integer;
	larg number;
	cont number;
begin

	select count (*) into cont from bl_carga where to_char(sys_momento_cria, 'DD-MM-YYYY')  = to_char(vData, 'DD-MM-YYYY');


if nvl(cont, 0) != 0 then

                public_dir := 'd:\oracle\public';
  		arquivo := 'CargasEmbarcadas.htm';
  		ret := DBMS_CX.DOSSHELL('DEL ' || public_dir || '\' || arquivo);

dbms_cx.grava_log('<html>',arquivo);
dbms_cx.grava_log('<head><title>Ciex - Processos Criados</title>',arquivo);
dbms_cx.grava_log('<style type="text/css">',arquivo);
dbms_cx.grava_log('<!--',arquivo);
dbms_cx.grava_log('.TextoNormal {',arquivo);
dbms_cx.grava_log('	font-family: Verdana, Arial;',arquivo);
dbms_cx.grava_log('	font-size: 10px;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.TextoNormal_2 {',arquivo);
dbms_cx.grava_log('	font-family: Verdana, Arial;',arquivo);
dbms_cx.grava_log('	font-size: 15px;',arquivo);
dbms_cx.grava_log('	font-weight: bolder;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.Label {',arquivo);
dbms_cx.grava_log('	font-family: Arial;',arquivo);
dbms_cx.grava_log('	font-size: 11px;',arquivo);
dbms_cx.grava_log('	font-weight:bold;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.BoxText {',arquivo);
dbms_cx.grava_log('	font-family: Verdana, Arial;',arquivo);
dbms_cx.grava_log('	font-size: 11px;',arquivo);
dbms_cx.grava_log('	color: #000000;',arquivo);
dbms_cx.grava_log('}',arquivo);
dbms_cx.grava_log('.style1 {font-size: 12px}',arquivo);
dbms_cx.grava_log('-->',arquivo);
dbms_cx.grava_log('</style>',arquivo);
dbms_cx.grava_log('</head>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<body bgcolor= #EEEEEE text= #0000FF>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('<center>',arquivo);

dbms_cx.grava_log('<span class="TextoNormal_2">Cargas Embarcadas</span><br>',arquivo);

	declare
		cursor cur_embarque is

	select
		ped.ref, ped.fornecedor, ped.pagador, nv3.prod, ped.país_destino, nv3.grupo, nv3.ped_ref, nv3.ped_item, nv3.carga_porto, nv3.descarga_porto, nv3.data_embarque, nv3.bl_data, nv3.navio
	from
		(select
			ped_item.prod, produto.grupo, nv2.ped_ref, nv2.ped_item, nv2.carga_porto, nv2.descarga_porto, nv2.data_embarque, nv2.bl_data, nv2.navio
		from
			(
			select 	bl_carga.ped_ref, bl_carga.ped_item, nv1.carga_porto, nv1.descarga_porto, nv1.data_embarque, nv1.bl_data, nv1.navio
			from
				(
				select bl.viagem_ref, bl.seq, emb.carga_porto, emb.descarga_porto, emb.data_embarque, bl.bl_data, viagem.navio
				from bl, viagem, emb, bl_carga
				where
				bl_carga.viagem_ref = bl.viagem_ref and
				to_char(bl_carga.sys_momento_cria, 'DD-MM-YYYY')  = to_char(vData, 'DD-MM-YYYY') and
				bl_carga.bl_seq = bl.seq and
				bl.viagem_ref = viagem.ref and
				bl.emb_ref = emb.ref
				) nv1, bl_carga
			where
				bl_carga.viagem_ref || '.' || bl_carga.bl_seq = nv1.viagem_ref  || '.' || nv1.seq
			) nv2, ped_item, produto
		where
			  nv2.ped_ref  || '.' || nv2.ped_item = ped_item.ped_ref  || '.' || ped_item.item and
			  ped_item.prod = produto.cod
		)nv3, ped
	where
		ped.ref = nv3.ped_ref;


		begin

			select count (*) ped into cont from ped;

		end;

dbms_cx.grava_log('<br>',arquivo);
dbms_cx.grava_log('<table border = 0>',arquivo);
dbms_cx.grava_log('  <tr><td class = "TextoNormal">'  || TO_CHAR(vData,'DD-MM-YYYY') || '</td>',arquivo);
dbms_cx.grava_log('</tr></table>',arquivo);


dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('</center>',arquivo);
dbms_cx.grava_log('',arquivo);
dbms_cx.grava_log('</body>',arquivo);
dbms_cx.grava_log('</html>',arquivo);


else
	ret := dbms_cx.sendmail(de, adm, 'Cargas Embarcadas', servidor, 'Não houveram pedidos criados em ' || to_char (vData,'DD-MM-YYYY') );
end if;

end mensagemNovoEmbarque ;

-- exec dbms_financeiro.lanca_despesa_padrao('SPP00800001/01');
procedure lanca_despesa_padrao (v_referencia  in varchar2) is
	vr varchar2 (3000);
	rept number;
	v_processo varchar2(30);
	cont number;
	v_seq number;
	v_seq_t number;
	v_seq_m number;
	v_seq_desp number;
	v_relacionada varchar2 (30);
begin

if substr(v_referencia,-1,1) != ';' then
   vr := v_referencia || ';' ;
else
   vr := v_referencia ;
end if;

rept := length(vr) - length(replace(vr,';','') );

for w in 1 .. rept loop


	v_processo := lb.litem(vr,w,';');

	declare cursor rs_empresa is select empresa from mapa_de_controle mc where mc.fina_ref = v_processo group by empresa;
	begin

		for cur_empresa in rs_empresa loop

			declare cursor rs_lancamentos is select * from processo_lançamento where processo_lançamento.empresa = cur_empresa.empresa and processo_lançamento.processo_ref = v_processo and nvl(processo_lançamento.despesa_padrao_seq, 0) != 0 ;
			begin

			  for cur_lancamentos in rs_lancamentos loop


				v_seq_m := 0	;
				select max(tseq) into v_seq_m from processo_lançamento where processo_lançamento.empresa = cur_empresa.empresa and processo_lançamento.processo_ref = v_processo;
				v_seq_m := nvl(v_seq_m, 0) ;

				v_seq := cur_lancamentos.seq;
				v_seq_t := nvl(cur_lancamentos.tseq, v_seq_m) ;
				v_seq_desp := cur_lancamentos.despesa_padrao_seq;

				delete from processo_lançamento where processo_lançamento.empresa = cur_empresa.empresa and processo_lançamento.processo_ref = v_processo and processo_lançamento.seq  = v_seq ;


					declare cursor rs_despesa is select * from despesa_padrao_item where nome_espelho = cur_empresa.empresa and seq = v_seq_desp;
					begin

						for cur in rs_despesa loop

							if nvl(cur.fixo, 0) != 0 then
								insert into processo_lançamento (empresa, processo_ref, seq, historico, débito_us, despesa_padrao_seq, tseq) values (cur.nome_espelho, v_processo,v_seq, cur.lançamento, cur.fixo, cur.seq, v_seq_t);
							end if;

							if nvl(cur.p_pro_plit, 0) != 0 then
								insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft, despesa_padrao_seq, tseq) values (cur.nome_espelho, v_processo, v_seq, cur.lançamento, cur.p_pro_plit, 'P', cur.seq, v_seq_t);
							end if;

							if nvl(cur.taxa_juros, 0) != 0 then
								insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft,data_ini, data_fim, despesa_padrao_seq, tseq) values (cur.nome_espelho, v_processo, v_seq, cur.lançamento, cur.taxa_juros, 'J', cur.data_inicial, cur.data_final, cur.seq, v_seq_t);
							end if;

						end loop;

					end;

			  end loop;
			end;

			-- ############################
			declare cursor rs_despesa2 is select * from despesa_padrao_item where nome_espelho = cur_empresa.empresa and not exists (select * from processo_lançamento pl where pl.despesa_padrao_seq = despesa_padrao_item.seq and pl.empresa = despesa_padrao_item.nome_espelho and pl.processo_ref = v_processo );
				begin


				select count (*) into cont from ped;

					for cur2 in rs_despesa2 loop

						v_seq_m := 0	;
						v_seq := 0;
						select max(tseq) into v_seq_m from processo_lançamento where processo_lançamento.empresa = cur_empresa.empresa and processo_lançamento.processo_ref = v_processo;
						select max(seq) into v_seq from processo_lançamento where processo_lançamento.empresa = cur_empresa.empresa and processo_lançamento.processo_ref = v_processo;
						v_seq_m := nvl(v_seq_m, 0) + 10 ;
						v_seq := nvl(v_seq, 0) + 10 ;

						if nvl(cur2.fixo, 0) != 0 then
							insert into processo_lançamento (empresa, processo_ref, seq, historico, débito_us, despesa_padrao_seq, tseq) values (cur2.nome_espelho, v_processo,v_seq, cur2.lançamento, cur2.fixo, cur2.seq, v_seq_t);
						end if;

						if nvl(cur2.p_pro_plit, 0) != 0 then
							insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft, despesa_padrao_seq, tseq) values (cur2.nome_espelho, v_processo, v_seq, cur2.lançamento, cur2.p_pro_plit, 'P', cur2.seq, v_seq_t);
						end if;
							if nvl(cur2.taxa_juros, 0) != 0 then
							insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft,data_ini, data_fim, despesa_padrao_seq, tseq) values (cur2.nome_espelho, v_processo, v_seq, cur2.lançamento, cur2.taxa_juros, 'J', cur2.data_inicial, cur2.data_final, cur2.seq, v_seq_t);
						end if;

						end loop;

				end;
			-- ############################

			v_seq_m := 0	;
			select max(tseq) into v_seq_m from processo_lançamento where processo_lançamento.empresa = cur_empresa.empresa and processo_lançamento.processo_ref = v_processo;
			update processo_lançamento set tseq = tseq + nvl(v_seq_m, 0) where processo_lançamento.empresa = cur_empresa.empresa and processo_lançamento.processo_ref = v_processo and despesa_padrao_proft = 'P';



				-- insere dados da relacionada
			select relacionada into v_relacionada from empresa  where empresa = cur_empresa.empresa;


-- ########################################################################################################################
		if nvl(v_relacionada, 'nulo') != 'nulo' then

			declare cursor rs_lancamentos_relacionada is select * from processo_lançamento where processo_lançamento.empresa = v_relacionada and processo_lançamento.processo_ref = v_processo and nvl(processo_lançamento.despesa_padrao_seq, 0) != 0 ;
			begin

			  for cur_lancamentos_relacionada in rs_lancamentos_relacionada loop


				v_seq_m := 0	;
				select max(tseq) into v_seq_m from processo_lançamento where processo_lançamento.empresa = v_relacionada and processo_lançamento.processo_ref = v_processo;
				v_seq_m := nvl(v_seq_m, 0) ;

				v_seq := cur_lancamentos_relacionada.seq;
				v_seq_t := nvl(cur_lancamentos_relacionada.tseq, v_seq_m) ;
				v_seq_desp := cur_lancamentos_relacionada.despesa_padrao_seq;

				delete from processo_lançamento where processo_lançamento.empresa = v_relacionada and processo_lançamento.processo_ref = v_processo and processo_lançamento.seq  = v_seq ;

					declare cursor rs_despesa_relacionada is select * from despesa_padrao_item where nome_espelho = cur_empresa.empresa and seq = v_seq_desp and relacionada = - 1;
					begin

						for cur_r in rs_despesa_relacionada loop

							if nvl(cur_r.fixo, 0) != 0 then
								insert into processo_lançamento (empresa, processo_ref, seq, historico, débito_us, despesa_padrao_seq, tseq) values (v_relacionada, v_processo,v_seq, cur_r.lançamento, cur_r.fixo, cur_r.seq, v_seq_t);
							end if;

							if nvl(cur_r.p_pro_plit, 0) != 0 then
								insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft, despesa_padrao_seq, tseq) values (v_relacionada, v_processo, v_seq, cur_r.lançamento, cur_r.p_pro_plit, 'P', cur_r.seq, v_seq_t);
							end if;

							if nvl(cur_r.taxa_juros, 0) != 0 then
								insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft,data_ini, data_fim, despesa_padrao_seq, tseq) values (v_relacionada, v_processo, v_seq, cur_r.lançamento, cur_r.taxa_juros, 'J', cur_r.data_inicial, cur_r.data_final, cur_r.seq, v_seq_t);
							end if;

						end loop;

					end;

				select count (*) into cont from ped;


	-- LANÇA DESPESAS DA RELACIONADA QUE POSSAM NÃO TER SIDO LANÇADAS

			  end loop;

			end;




				declare cursor rs_despesa2_relacionada is
				select * from despesa_padrao_item where not exists
				(select * from processo_lançamento pl where pl.processo_ref = v_processo and pl.despesa_padrao_seq = despesa_padrao_item.seq and pl.empresa = v_relacionada and ((sub_conta <> 9999 and sub_conta <> 9998) or sub_conta is null)) and relacionada = -1 and nome_espelho = cur_empresa.empresa;


				begin
					for cur2_relacionada in rs_despesa2_relacionada loop


					v_seq_m := 0	;
					v_seq := 0;
					select max(tseq) into v_seq_m from processo_lançamento where processo_lançamento.empresa = v_relacionada and processo_lançamento.processo_ref = v_processo;
					select max(seq) into v_seq from processo_lançamento where processo_lançamento.empresa = v_relacionada and processo_lançamento.processo_ref = v_processo;
					v_seq_m := nvl(v_seq_m, 0) + 10 ;
					v_seq := nvl(v_seq, 0) + 10 ;

						if nvl(cur2_relacionada.fixo, 0) != 0 then
							insert into processo_lançamento (empresa, processo_ref, seq, historico, débito_us, despesa_padrao_seq, tseq) values (v_relacionada, v_processo,v_seq, cur2_relacionada.lançamento, cur2_relacionada.fixo, cur2_relacionada.seq, v_seq_t);
						end if;

						if nvl(cur2_relacionada.p_pro_plit, 0) != 0 then
							insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft, despesa_padrao_seq, tseq) values (v_relacionada, v_processo, v_seq, cur2_relacionada.lançamento, cur2_relacionada.p_pro_plit, 'P', cur2_relacionada.seq, v_seq_t);
						end if;
							if nvl(cur2_relacionada.taxa_juros, 0) != 0 then
							insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft,data_ini, data_fim, despesa_padrao_seq, tseq) values (v_relacionada, v_processo, v_seq, cur2_relacionada.lançamento, cur2_relacionada.taxa_juros, 'J', cur2_relacionada.data_inicial, cur2_relacionada.data_final, cur2_relacionada.seq, v_seq_t);
						end if;

						end loop;
					end;
			--

					v_seq_m := 0	;
					select max(tseq) into v_seq_m from processo_lançamento where processo_lançamento.empresa = v_relacionada and processo_lançamento.processo_ref = v_processo;
					update processo_lançamento set tseq = tseq + nvl(v_seq_m, 0) where processo_lançamento.empresa = v_relacionada and processo_lançamento.processo_ref = v_processo and despesa_padrao_proft = 'P';






		end if;
-- ########################################################################################################################

		end loop; --cur_empresa
	end;


end loop;

COMMIT;
end;

--   @d:\pacs\dbms_financeiro.txt
procedure lancamento_worksheet (proc in varchar2, arquivo in varchar2, worksheet in varchar2, tipo in varchar2, coluna_imp in integer, linha in number, coluna in number, valor in number, nome_banco in varchar2, data in date, sub_conta in number, despesa in varchar, transacao in varchar2, v_historico in varchar2) is
	v_seq number;
	cont number;
	v_transacao_seq number;
begin



		declare cursor cur_empresa is select p.empresa from processo p where p.ref = proc group by p.empresa;

			begin

			for cur in cur_empresa loop

				-- Verifca qual o proximo sequencial
				select max(pl.seq) into v_seq from processo_lançamento pl where pl.empresa = cur.empresa and pl.processo_ref = proc;
	 			v_seq := nvl(v_seq,0) + 10;
				select max(pl.transação_seq) into v_transacao_seq from processo_lançamento pl where pl.transação = transacao;
	 			v_transacao_seq := nvl(v_transacao_seq, 0) + 1;




					-- Efetua o lançamento%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					if nvl(despesa,'N') = 'C' then
						insert into processo_lançamento (empresa, processo_ref, seq, data, crédito_us, débito_us, credito_saldo, debito_saldo, historico, worksheet, arquivo, sub_conta, transação, transação_seq, coluna, data_saldo)
						values (cur.empresa, proc, v_seq, data, valor, 0, valor, 0, v_historico, worksheet, arquivo, sub_conta, transacao, v_transacao_seq, coluna, data);

						select count (*) into cont from importacao_worksheet iw where iw.linha = linha and iw.coluna = coluna and iw.transação = transacao and nvl(iw.erro,0) = 0;
						if nvl(cont, 0) = 0 then
							insert into importacao_worksheet (linha, coluna, transação, erro, tipo) values (linha,coluna_imp,transacao,0, tipo);
						end if;

						commit;
					else
						if nvl(despesa,'N')  = 'D' then
							insert into processo_lançamento (empresa, processo_ref, seq, data, crédito_us, débito_us, credito_saldo, debito_saldo, historico, worksheet, arquivo, sub_conta, transação, transação_seq, coluna, data_saldo)
							values (cur.empresa, proc, v_seq, data, 0, valor, 0, valor, v_historico, worksheet, arquivo, sub_conta, transacao, v_transacao_seq, coluna, data);

							select count (*) into cont from importacao_worksheet iw where iw.linha = linha  and iw.coluna = coluna and iw.transação = transacao and nvl(iw.erro,0) = 0;
							if nvl(cont, 0) = 0 then
								insert into importacao_worksheet (linha, coluna, transação, erro, tipo) values (linha,coluna_imp,transacao,0, tipo);
							end if;

							commit;
						end if;
					end if;
					-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






				end loop;

			end;


end;


--   @d:\pacs\dbms_financeiro.txt
--   exec dbms_financeiro.atualiza_saldo ('BHP00800004/01;','EXPDIVPRICO');
procedure atualiza_saldo (proc in varchar2, work in varchar2) is
	rept number;
	cont number;
	v_processo varchar2 (30);
	total_recebido number;
	data_receipt date;
	total_pago number;
	data_paid date;
begin



	rept := length(proc) - length(replace(proc,';',''));
	if nvl(rept,0) = 0 then
	rept := 1;
	end if;



	for w in   1 .. rept loop

		v_processo := lb.litem(proc,w,';');



		declare cursor rs_empresa is select empresa from processo where ref = v_processo group by empresa;
		begin
		for cur in rs_empresa loop

-- RECEBIMENTO ##############################################################################################################
		--Totaliza o saldo a receber do processo

				total_recebido := 0;

				select sum(SR.cs) into total_recebido from
				(select nvl(pl.credito_saldo,0) cs from
					(select m.worksheet, m.coluna, m.titulo from mapa m where m.worksheet = work and m.titulo = 'DEB_FAT1') cl,
					processo_lançamento pl
				where
					cl.worksheet  || '.' || cl.coluna = pl.worksheet  || '.' || pl.coluna and
					nvl(pl.sub_conta,0) <> 9999 and
					nvl(pl.sub_conta,0) <> 9998 and
					pl.processo_ref = v_processo and
					pl.empresa = cur.empresa) SR;


		--Verifica adata mais atual do recebimento
				select max(data) into data_receipt from
					(select m.worksheet, m.coluna, m.titulo from mapa m where m.worksheet = work and m.titulo = 'DEB_FAT1') cl,
					processo_lançamento pl
				where
					cl.worksheet  || '.' || cl.coluna = pl.worksheet  || '.' || pl.coluna and
					nvl(pl.sub_conta,0) <> 9999 and
					nvl(pl.sub_conta,0) <> 9998 and
					pl.processo_ref = v_processo and
					pl.empresa = cur.empresa;


			declare cursor rs_receipt is
				select pl.* from
					(select m.worksheet, m.coluna, m.titulo from mapa m where m.worksheet = work and m.titulo = 'ALERTA_FAT1') cl,
					processo_lançamento pl
				where
					cl.worksheet  || '.' || cl.coluna = pl.worksheet  || '.' || pl.coluna and
					nvl(pl.sub_conta,0) <> 9999 and
					nvl(pl.sub_conta,0) <> 9998 and
					pl.processo_ref = v_processo and
					pl.empresa = cur.empresa
				order by
					pl.processo_ref, pl.empresa, pl.data, pl.seq 	;

		--Faz o calculos dos saldos à receber
			begin

				for cur_receipt in rs_receipt loop

					update processo_lançamento pl set pl.complemento = 'SALDO A RECEBER' where pl.empresa = cur_receipt.empresa and pl.processo_ref = cur_receipt.processo_ref and 	pl.seq = cur_receipt.seq;


					if nvl(cur_receipt.credito_saldo ,0) < total_recebido then
						update processo_lançamento pl set pl.data = data_receipt, pl.complemento = 'SALDO A RECEBER', crédito_us = 0, débito_us = 0 where pl.empresa = cur_receipt.empresa and pl.processo_ref = cur_receipt.processo_ref and 	pl.seq = cur_receipt.seq;
						total_recebido := total_recebido - cur_receipt.credito_saldo;
					else
						if nvl(cur_receipt.credito_saldo, 0)  > total_recebido then
							update processo_lançamento pl set pl.data = data_receipt, pl.complemento = 'SALDO A RECEBER', crédito_us = credito_saldo - total_recebido, débito_us = 0 where pl.empresa = cur_receipt.empresa and pl.processo_ref = cur_receipt.processo_ref and 	pl.seq = cur_receipt.seq;
							total_recebido := 0;
						else
							if nvl(cur_receipt.credito_saldo, 0)  = total_recebido then
								update processo_lançamento pl set pl.data = data_receipt, pl.complemento = 'SALDO A RECEBER', crédito_us = 0, débito_us = 0 where pl.empresa = cur_receipt.empresa and pl.processo_ref = cur_receipt.processo_ref and 	pl.seq = cur_receipt.seq;
								total_recebido := 0;
							end if;
						end if;
					end if;



				end loop;


			end;

-- FIM RECEBIMENTO ######################################################################################################################
-- PAGAMENTO ############################################################################################################################
		--Totaliza o SALDO A PAGAR do processo
				total_pago := 0;

				select sum(SP.cs) into total_pago from
				(select nvl(pl.debito_saldo,0) cs from
					(select m.worksheet, m.coluna, m.titulo from mapa m where m.worksheet = work and m.titulo = 'DEB_FAT2') cl,
					processo_lançamento pl
				where
					cl.worksheet  || '.' || cl.coluna = pl.worksheet  || '.' || pl.coluna and
					nvl(pl.sub_conta,0) <> 9999 and
					nvl(pl.sub_conta,0) <> 9998 and
					pl.processo_ref = v_processo and
					pl.empresa = cur.empresa) SP;

		--Verifica adata mais atual do recebimento
				select max(data) into data_paid from
					(select m.worksheet, m.coluna, m.titulo from mapa m where m.worksheet = work and m.titulo = 'DEB_FAT2') cl,
					processo_lançamento pl
				where
					cl.worksheet  || '.' || cl.coluna = pl.worksheet  || '.' || pl.coluna and
					nvl(pl.sub_conta,0) <> 9999 and
					nvl(pl.sub_conta,0) <> 9998 and
					pl.processo_ref = v_processo and
					pl.empresa = cur.empresa;


			declare cursor rs_paid is
				select pl.* from
					(select m.worksheet, m.coluna, m.titulo from mapa m where m.worksheet = work and m.titulo = 'ALERTA_FAT2') cl,
					processo_lançamento pl
				where
					cl.worksheet  || '.' || cl.coluna = pl.worksheet  || '.' || pl.coluna and
					nvl(pl.sub_conta,0) <> 9999 and
					nvl(pl.sub_conta,0) <> 9998 and
					pl.processo_ref = v_processo and
					pl.empresa = cur.empresa
				order by
					pl.processo_ref, pl.empresa, pl.data, pl.seq 	;

		--Faz o calculos dos saldos à receber
			begin

				for cur_paid in rs_paid loop

					update processo_lançamento pl set pl.complemento = 'SALDO A PAGAR' where pl.empresa = cur_paid.empresa and pl.processo_ref = cur_paid.processo_ref and 	pl.seq = cur_paid.seq;



					if nvl(cur_paid.debito_saldo ,0) < total_pago then
						update processo_lançamento pl set pl.data = data_paid, pl.complemento = 'SALDO A PAGAR', crédito_us = 0, débito_us = 0 where pl.empresa = cur_paid.empresa and pl.processo_ref = cur_paid.processo_ref and 	pl.seq = cur_paid.seq;
						total_pago := total_pago - cur_paid.debito_saldo;
					else
						if nvl(cur_paid.debito_saldo, 0) > total_pago then
							update processo_lançamento pl set pl.data = data_paid, pl.complemento = 'SALDO A PAGAR', débito_us = debito_saldo - total_pago, crédito_us = 0 where pl.empresa = cur_paid.empresa and pl.processo_ref = cur_paid.processo_ref and 	pl.seq = cur_paid.seq;
							total_pago := 0;
						else
							if nvl(cur_paid.debito_saldo, 0)  = total_pago then
								update processo_lançamento pl set pl.data = data_paid, pl.complemento = 'SALDO A PAGAR', crédito_us = 0, débito_us = 0 where pl.empresa = cur_paid.empresa and pl.processo_ref = cur_paid.processo_ref and 	pl.seq = cur_paid.seq;
								total_pago := 0;
							end if;
						end if;
					end if;



				end loop;


			end;
-- FIM PAGAMENTO #######################################################################################################################




		end loop;
		end;






	end loop;

COMMIT;
end;

--   @d:\pacs\dbms_financeiro.txt
procedure atualiza_juros ( v_ref in varchar2 ,v_empresa in varchar2)is
	v_taxa number;
	v_seq  number;
	cont number;
	Acum number;
	dt date;
	calc number;
	vl number;
begin


	select max(seq) into v_seq from processo_lançamento where empresa = v_empresa and processo_ref = v_ref and despesa_padrao_proft = 'J';

	if nvl( v_seq,0) != 0 then

		select nvl(taxa,0) into v_taxa from processo_lançamento where empresa = v_empresa and processo_ref = v_ref and seq = v_seq ;

	declare cursor cur_juros is select * from processo_lançamento where ((sub_conta <> 9999 and sub_conta <> 9998)  or nvl(sub_conta,0) = 0) and empresa = v_empresa and processo_ref = v_ref and data is not null order by tseq;

	begin

		--limpa as variaveis para o calculo
		dt := null;
		calc := 0;
		vl := 0 ;
		Acum := 0;
		--looping que efetua o cálculo do juros
		for cur in cur_juros loop


			Acum := Acum - nvl(cur.débito_us,0) + nvl(cur.crédito_us,0);

				if dt is not null then
					calc := calc + (vl * v_taxa * round (cur.data - dt)/36000);
				end if;

				dt := cur.data;
				vl := Acum;
		end loop;


		-- Insere o calculo dos juros na tela de lançamento do processo
		if calc < 0 then
			update processo_lançamento set débito_us = round(calc,2) where processo_ref  = v_ref and empresa = v_empresa and seq = v_seq;
		else
			update processo_lançamento set crédito_us = round(calc,2) where processo_ref  = v_ref and empresa = v_empresa and seq = v_seq;
		end if;

		commit;
	end;


	end if;


end;

--   @d:\pacs\dbms_financeiro.txt

-- exec dbms_financeiro.calcula_juros('BHC00700052/01');
procedure calcula_juros ( v_referencia in varchar2) is
	data_limite date;
	data_inicial date;
	data_final date;
	total number;
	valor number;
	vr varchar2 (3000);
	rept number;
	v_ref varchar2(30);
	cont number;

	Acum number;
	dt date;
	calc number;
	vl number;
	v_taxa number;
begin

if substr(v_referencia,-1,1) != ';' then
   vr := v_referencia || ';' ;
else
   vr := v_referencia ;
end if;

rept := length(vr) - length(replace(vr,';','') );

for w in 1 .. rept loop

	v_ref := lb.litem(vr,w,';');

	declare cursor cur_empresa is select empresa from processo where ref = v_ref group by empresa;
	begin

		for cur in cur_empresa loop


			select data_juros into data_limite from processo where empresa = cur.empresa and ref = v_ref;
			data_limite := nvl(data_limite, add_months(sysdate,2400));

			declare cursor rs_juros is select * from processo_lançamento where despesa_padrao_proft = 'J' and empresa = cur.empresa and processo_ref = v_ref order by data_ini;

				begin

					for cur_juros in rs_juros loop

						declare cursor rs_despesa is select * from processo_lançamento where ((sub_conta <> 9999 and sub_conta <> 9998) or sub_conta is null ) and empresa = cur_juros.empresa and processo_ref = v_ref and data <= cur_juros.data_fim and data >= cur_juros.data_ini order by data;

						begin


						dt := null;
						calc := 0;
						vl := 0;
						Acum :=0;
						v_taxa := nvl(cur_juros.taxa, 0);

							for cur_despesa in rs_despesa loop

								Acum := Acum - nvl(cur_despesa.débito_us,0) + nvl(cur_despesa.crédito_us,0);

									if dt is not null then
										calc := calc + (vl * round (cur_despesa.data - dt) * (v_taxa /36000) );
									end if;

								dt := cur_despesa.data;
								vl := Acum;


							-- Insere o calculo dos juros na tela de lançamento do processo
							if calc < 0 then
								update processo_lançamento set  crédito_us = 0, débito_us = ABS(round(calc,2)) where processo_ref  = v_ref and empresa = cur_juros.empresa and seq = cur_juros.seq;
							else
								update processo_lançamento set  débito_us = 0, crédito_us = round(calc,2) where processo_ref  = v_ref and empresa = cur_juros.empresa and seq = cur_juros.seq;
							end if;


							end loop;

						end;



					end loop;
				end;


		end loop;
	end;

end loop;

end;

--   @d:\pacs\dbms_financeiro.txt
--   exec dbms_financeiro.atualiza_proft('SPP00700064/01');
procedure atualiza_proft (v_referencia in varchar2) is
	v_seq_proft number;
	v_taxa number;
	vr varchar2 (3000);
	total number;
	valor number;
	v_ref varchar2(30);
	rept number;
begin

if substr(v_referencia,-1,1) != ';' then
   vr := v_referencia || ';' ;
else
   vr := v_referencia ;
end if;

rept := length(vr) - length(replace(vr,';','') );

for w in 1 .. rept loop

	v_ref := lb.litem(vr,w,';');

	declare cursor cur_empresa is select empresa from processo where ref = v_ref;

	begin

		for cur in cur_empresa loop


			declare cursor cur_emp is select seq from processo_lançamento where empresa = cur.empresa and processo_ref = v_ref and despesa_padrao_proft = 'P';
				begin


					for rs_emp in cur_emp loop


					--Verifica a taxa de juros utilizada para o caldulo do proft
					select taxa into v_taxa from processo_lançamento where empresa = cur.empresa and processo_ref = v_ref and seq = rs_emp.seq;
					v_taxa := nvl(v_taxa, 0);

					-- Efetua o somatório dos valores
					select sum(nvl(crédito_us, 0) - nvl(débito_us, 0)) into total from processo_lançamento where ((sub_conta <> 9999 and sub_conta <> 9998) or sub_conta is null ) and empresa = cur.empresa and processo_ref = v_ref and nvl(despesa_padrao_proft,'X') <> 'P';

					total := nvl(total, 0);

					--Efetua o calculo do valor do proft
					valor := round (((total * v_taxa)/100), 2);

					-- Insere o valor do profit no lançamento
					if valor > 0 then
						update processo_lançamento set complemento = 'PROFIT ' || v_taxa || ' %', crédito_us = 0 , débito_us = abs(valor) where empresa = cur.empresa and processo_ref = v_ref and seq = rs_emp.seq;
					else
						update processo_lançamento set complemento = 'PROFIT ' || v_taxa || ' %', débito_us = 0 , crédito_us = abs(valor) where empresa = cur.empresa and processo_ref = v_ref and seq = rs_emp.seq;
					end if;

					commit;




					end loop;




				end;




--			select max(seq) into v_seq_proft from processo_lançamento where empresa = cur.empresa and processo_ref = v_ref and despesa_padrao_proft = 'P';
--
--
--			if nvl(v_seq_proft, 0) != 0 then
--
--			end if;


		end loop;

	end;

end loop;
end;

--   @d:\pacs\dbms_financeiro.txt

procedure log_erro_lancamento_worksheet (arquivo in varchar2, worksheet in varchar2, tipo in varchar2, linha in number, coluna in number, empresa_conta in varchar2, processo in varchar2 default '', situacao in varchar2, transacao in varchar2, coluna_imp in number) is
	cont number;
	v_seq number;
begin

	select max(seq) into v_seq from log_importação;
	v_seq := nvl(v_seq,0) + 1;

	insert into log_importação (seq, data, situação, transação, processo, empresa, linha, coluna, tipo, worksheet, arquivo) values (v_seq, to_date(to_char(sysdate,'DD-MM-YYYY'),'DD-MM-YYYY'), situacao, transacao, processo, empresa_conta, linha, coluna, tipo, worksheet, arquivo );

	select count (*) into cont from importacao_worksheet iw where iw.linha = linha and iw.coluna = coluna and iw.transação = transacao and nvl(iw.erro,0) = 1;

		if nvl(cont, 0) = 0 then
		  insert into importacao_worksheet (linha, coluna, transação, erro, tipo) values (linha, coluna_imp, transacao, 1, tipo);
		end if;


end;

--   @d:\pacs\dbms_financeiro.txt
-- exec	dbms_financeiro.ordenar_lancamento('SPP00700060/01');
procedure ordenar_lancamento (v_ref in varchar2, v_empresa in varchar2 default 'ambas') is
	sq number;

begin

	if v_empresa != 'ambas' then

			update processo_lançamento set tseq = nvl(tseq,0) * (-1) where empresa = v_empresa and processo_ref = v_ref;
			declare cursor rso2 is select * from processo_lançamento where nvl(sub_conta,0) <> 9999 and nvl(sub_conta,0) <> 9998 and empresa = v_empresa and processo_ref = v_ref order by nvl(data,add_months(sysdate,12000)) , tseq desc, crédito_us desc, débito_us desc, seq;

			begin

			sq := 10;

				for cur_rso2 in rso2 loop
					update processo_lançamento set tseq = sq where empresa = v_empresa and processo_ref = v_ref and seq = cur_rso2.seq;
					sq := sq + 10;
				end loop;
			end;
	else

		declare cursor rs_empresa is select empresa from processo where ref = v_ref group by empresa ;
		begin

			for cur_empresa in rs_empresa loop

				update processo_lançamento set tseq = nvl(tseq,0) * (-1) where empresa = cur_empresa.empresa and processo_ref = v_ref;
				declare cursor rso is select * from processo_lançamento where nvl(sub_conta,0) <> 9999 and nvl(sub_conta,0) <> 9998 and empresa = cur_empresa.empresa and processo_ref = v_ref order by nvl(data,add_months(sysdate,12000)) , tseq desc, crédito_us desc, débito_us desc, seq;

				begin
				sq := 10;

					for cur_rso in rso loop
						update processo_lançamento set tseq = sq where empresa = cur_empresa.empresa and processo_ref = v_ref and seq = cur_rso.seq;
						sq := sq + 10;
					end loop;

				end;



			end loop;

		end;




	end if;



commit;

end;

--   @d:\pacs\dbms_financeiro.txt

procedure ordenar (v_referencia in varchar2) is
	vr varchar2 (3000);
	v_ref varchar2(30);
	rept number;
begin

	if substr(v_referencia,-1,1) != ';' then
	   vr := v_referencia || ';' ;
	else
	   vr := v_referencia ;
	end if;

	rept := length(vr) - length(replace(vr,';','') );

	for w in 1 .. rept loop

		v_ref := lb.litem(vr,w,';');
		dbms_financeiro.ordenar_lancamento (v_ref);

	end loop;



end;

-- exec dbms_financeiro.lanca_despesa_padrao_empresa('SPP00700066/01','ITF CCS X INTERMESA BR')
procedure lanca_despesa_padrao_empresa (v_processo in varchar2, v_empresa in varchar2) is
	vr varchar2 (3000);
	rept number;
	cont number;
	v_seq number;
	v_seq_t number;
	v_seq_m number;
	v_seq_desp number;
	v_relacionada varchar2 (30);
	emp_mapa varchar2 (50);
begin


	select empresa into emp_mapa from mapa_de_controle where fina_ref = v_processo;



if nvl(emp_mapa, 'nulo') = v_empresa then
--neste caso a empresa escolhida é a principal
-- ############################################################
	declare cursor rs_empresa is select empresa from mapa_de_controle mc where mc.fina_ref = v_processo group by empresa;
	begin

		for cur_empresa in rs_empresa loop

			declare cursor rs_lancamentos is select * from processo_lançamento where processo_lançamento.empresa = cur_empresa.empresa and processo_lançamento.processo_ref = v_processo and nvl(processo_lançamento.despesa_padrao_seq, 0) != 0 ;
			begin

			  for cur_lancamentos in rs_lancamentos loop


				v_seq_m := 0	;
				select max(tseq) into v_seq_m from processo_lançamento where processo_lançamento.empresa = cur_empresa.empresa and processo_lançamento.processo_ref = v_processo;
				v_seq_m := nvl(v_seq_m, 0) ;

				v_seq := cur_lancamentos.seq;
				v_seq_t := nvl(cur_lancamentos.tseq, v_seq_m) ;
				v_seq_desp := cur_lancamentos.despesa_padrao_seq;

				delete from processo_lançamento where processo_lançamento.empresa = cur_empresa.empresa and processo_lançamento.processo_ref = v_processo and processo_lançamento.seq  = v_seq ;


					declare cursor rs_despesa is select * from despesa_padrao_item where nome_espelho = cur_empresa.empresa and seq = v_seq_desp;
					begin

						for cur in rs_despesa loop

							if nvl(cur.fixo, 0) != 0 then
								insert into processo_lançamento (empresa, processo_ref, seq, historico, débito_us, despesa_padrao_seq, tseq) values (cur.nome_espelho, v_processo,v_seq, cur.lançamento, cur.fixo, cur.seq, v_seq_t);
							end if;

							if nvl(cur.p_pro_plit, 0) != 0 then
								insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft, despesa_padrao_seq, tseq) values (cur.nome_espelho, v_processo, v_seq, cur.lançamento, cur.p_pro_plit, 'P', cur.seq, v_seq_t);
							end if;

							if nvl(cur.taxa_juros, 0) != 0 then
								insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft,data_ini, data_fim, despesa_padrao_seq, tseq) values (cur.nome_espelho, v_processo, v_seq, cur.lançamento, cur.taxa_juros, 'J', cur.data_inicial, cur.data_final, cur.seq, v_seq_t);
							end if;

						end loop;

					end;

			  end loop;
			end;

			-- ############################
			declare cursor rs_despesa2 is select * from despesa_padrao_item where nome_espelho = cur_empresa.empresa and not exists (select * from processo_lançamento pl where pl.despesa_padrao_seq = despesa_padrao_item.seq and pl.empresa = despesa_padrao_item.nome_espelho and pl.processo_ref = v_processo );
				begin


				select count (*) into cont from ped;

					for cur2 in rs_despesa2 loop

						v_seq_m := 0	;
						v_seq := 0;
						select max(tseq) into v_seq_m from processo_lançamento where processo_lançamento.empresa = cur_empresa.empresa and processo_lançamento.processo_ref = v_processo;
						select max(seq) into v_seq from processo_lançamento where processo_lançamento.empresa = cur_empresa.empresa and processo_lançamento.processo_ref = v_processo;
						v_seq_m := nvl(v_seq_m, 0) + 10 ;
						v_seq := nvl(v_seq, 0) + 10 ;

						if nvl(cur2.fixo, 0) != 0 then
							insert into processo_lançamento (empresa, processo_ref, seq, historico, débito_us, despesa_padrao_seq, tseq) values (cur2.nome_espelho, v_processo,v_seq, cur2.lançamento, cur2.fixo, cur2.seq, v_seq_t);
						end if;

						if nvl(cur2.p_pro_plit, 0) != 0 then
							insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft, despesa_padrao_seq, tseq) values (cur2.nome_espelho, v_processo, v_seq, cur2.lançamento, cur2.p_pro_plit, 'P', cur2.seq, v_seq_t);
						end if;
							if nvl(cur2.taxa_juros, 0) != 0 then
							insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft,data_ini, data_fim, despesa_padrao_seq, tseq) values (cur2.nome_espelho, v_processo, v_seq, cur2.lançamento, cur2.taxa_juros, 'J', cur2.data_inicial, cur2.data_final, cur2.seq, v_seq_t);
						end if;

						end loop;

				end;
			-- ############################

			v_seq_m := 0	;
			select max(tseq) into v_seq_m from processo_lançamento where processo_lançamento.empresa = cur_empresa.empresa and processo_lançamento.processo_ref = v_processo;
			update processo_lançamento set tseq = tseq + nvl(v_seq_m, 0) where processo_lançamento.empresa = cur_empresa.empresa and processo_lançamento.processo_ref = v_processo and despesa_padrao_proft = 'P';

		end loop; --cur_empresa
	end;
--########################################################################
else
--neste caso a empreesa escolhida é a relacionada
--#######################################################################################################
v_relacionada := v_empresa;

			declare cursor rs_lancamentos_relacionada is select * from processo_lançamento where processo_lançamento.empresa = v_relacionada and processo_lançamento.processo_ref = v_processo and nvl(processo_lançamento.despesa_padrao_seq, 0) != 0 ;
			begin

			  for cur_lancamentos_relacionada in rs_lancamentos_relacionada loop


				v_seq_m := 0	;
				select max(tseq) into v_seq_m from processo_lançamento where processo_lançamento.empresa = v_relacionada and processo_lançamento.processo_ref = v_processo;
				v_seq_m := nvl(v_seq_m, 0) ;

				v_seq := cur_lancamentos_relacionada.seq;
				v_seq_t := nvl(cur_lancamentos_relacionada.tseq, v_seq_m) ;
				v_seq_desp := cur_lancamentos_relacionada.despesa_padrao_seq;

				delete from processo_lançamento where processo_lançamento.empresa = v_relacionada and processo_lançamento.processo_ref = v_processo and processo_lançamento.seq  = v_seq ;

					declare cursor rs_despesa_relacionada is select * from despesa_padrao_item where nome_espelho = emp_mapa and seq = v_seq_desp and relacionada = - 1;
					begin

						for cur_r in rs_despesa_relacionada loop

							if nvl(cur_r.fixo, 0) != 0 then
								insert into processo_lançamento (empresa, processo_ref, seq, historico, débito_us, despesa_padrao_seq, tseq) values (v_relacionada, v_processo,v_seq, cur_r.lançamento, cur_r.fixo, cur_r.seq, v_seq_t);
							end if;

							if nvl(cur_r.p_pro_plit, 0) != 0 then
								insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft, despesa_padrao_seq, tseq) values (v_relacionada, v_processo, v_seq, cur_r.lançamento, cur_r.p_pro_plit, 'P', cur_r.seq, v_seq_t);
							end if;

							if nvl(cur_r.taxa_juros, 0) != 0 then
								insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft,data_ini, data_fim, despesa_padrao_seq, tseq) values (v_relacionada, v_processo, v_seq, cur_r.lançamento, cur_r.taxa_juros, 'J', cur_r.data_inicial, cur_r.data_final, cur_r.seq, v_seq_t);
							end if;

						end loop;

					end;

				select count (*) into cont from ped;


	-- LANÇA DESPESAS DA RELACIONADA QUE POSSAM NÃO TER SIDO LANÇADAS

			  end loop;

			end;




				declare cursor rs_despesa2_relacionada is
				select * from despesa_padrao_item where not exists
				(select * from processo_lançamento pl where pl.processo_ref = v_processo and pl.despesa_padrao_seq = despesa_padrao_item.seq and pl.empresa = v_relacionada and ((sub_conta <> 9999 and sub_conta <> 9998) or sub_conta is null)) and relacionada = -1 and nome_espelho = emp_mapa;


				begin
					for cur2_relacionada in rs_despesa2_relacionada loop


					v_seq_m := 0	;
					v_seq := 0;
					select max(tseq) into v_seq_m from processo_lançamento where processo_lançamento.empresa = v_relacionada and processo_lançamento.processo_ref = v_processo;
					select max(seq) into v_seq from processo_lançamento where processo_lançamento.empresa = v_relacionada and processo_lançamento.processo_ref = v_processo;
					v_seq_m := nvl(v_seq_m, 0) + 10 ;
					v_seq := nvl(v_seq, 0) + 10 ;

						if nvl(cur2_relacionada.fixo, 0) != 0 then
							insert into processo_lançamento (empresa, processo_ref, seq, historico, débito_us, despesa_padrao_seq, tseq) values (v_relacionada, v_processo,v_seq, cur2_relacionada.lançamento, cur2_relacionada.fixo, cur2_relacionada.seq, v_seq_t);
						end if;

						if nvl(cur2_relacionada.p_pro_plit, 0) != 0 then
							insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft, despesa_padrao_seq, tseq) values (v_relacionada, v_processo, v_seq, cur2_relacionada.lançamento, cur2_relacionada.p_pro_plit, 'P', cur2_relacionada.seq, v_seq_t);
						end if;
							if nvl(cur2_relacionada.taxa_juros, 0) != 0 then
							insert into processo_lançamento (empresa, processo_ref, seq, historico, taxa, despesa_padrao_proft,data_ini, data_fim, despesa_padrao_seq, tseq) values (v_relacionada, v_processo, v_seq, cur2_relacionada.lançamento, cur2_relacionada.taxa_juros, 'J', cur2_relacionada.data_inicial, cur2_relacionada.data_final, cur2_relacionada.seq, v_seq_t);
						end if;

						end loop;
					end;
			--

					v_seq_m := 0	;
					select max(tseq) into v_seq_m from processo_lançamento where processo_lançamento.empresa = v_relacionada and processo_lançamento.processo_ref = v_processo;
					update processo_lançamento set tseq = tseq + nvl(v_seq_m, 0) where processo_lançamento.empresa = v_relacionada and processo_lançamento.processo_ref = v_processo and despesa_padrao_proft = 'P';







--########################################################################################################
end if;



COMMIT;
end;



end;
/