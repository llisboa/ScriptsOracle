

insert into IDIOMA (
                                     COD,
                                     DESCR)
select 
                                     COD,
                                     DESCR from IDIOMA_T ;

insert into PAÍS (
                                     COD,
                                     NOME,
                                     ABREVIATURA,
                                     BANDEIRA_COD,
                                     IDIOMA,
                                     MSG)
select 
                                     COD,
                                     NOME,
                                     ABREVIATURA,
                                     BANDEIRA_COD,
                                     IDIOMA,
                                     MSG from PAÍS_T ;

insert into NAVIO (
                                     COD,
                                     ANO_CONSTRUÇÃO,
                                     NOME,
                                     NOME_ANTERIOR,
                                     BANDEIRA,
                                     NAVIO_TIPO,
                                     DWAT,
                                     LOA,
                                     BEAN,
                                     GRT,
                                     NRT,
                                     CAPACIDADE_GRÃO,
                                     CAPACIDADE_FARDO,
                                     CALADO_VERÃO,
                                     GUINDASTE_NUM,
                                     GUINDASTE_DIMENSÃO,
                                     ESCOTILHA_NUM,
                                     ESCOTILHA_DIMENSÃO,
                                     ESCOTILHA_FECHAM_TIPO,
                                     EQUIPAMENTO,
                                     TANKTOP_STRENGTH,
                                     SOCIEDADE_CLASSIFICADORA,
                                     CLASSE,
                                     OBS,
                                     OWNER,
                                     CALL_SIGN,
                                     N_TANKS,
                                     SBT,
                                     DOUBLE_HULL,
                                     DOUBLE_BOTTOM,
                                     INERT_GAS_SYS,
                                     HEATING_COILS,
                                     IMO_NUM,
                                     IMO_TYPE,
                                     COATING,
                                     CARGO_PUMPS,
                                     CUBIC_CAPACITY,
                                     CARGO_LINES,
                                     CARGO_MANIFOLDS,
                                     MAJORS_AP,
                                     SUMMER_DRAFT)
select 
                                     COD,
                                     ANO_CONSTRUÇÃO,
                                     NOME,
                                     NOME_ANTERIOR,
                                     BANDEIRA,
                                     NAVIO_TIPO,
                                     DWAT,
                                     LOA,
                                     BEAN,
                                     GRT,
                                     NRT,
                                     CAPACIDADE_GRÃO,
                                     CAPACIDADE_FARDO,
                                     CALADO_VERÃO,
                                     GUINDASTE_NUM,
                                     GUINDASTE_DIMENSÃO,
                                     ESCOTILHA_NUM,
                                     ESCOTILHA_DIMENSÃO,
                                     ESCOTILHA_FECHAM_TIPO,
                                     EQUIPAMENTO,
                                     TANKTOP_STRENGTH,
                                     SOCIEDADE_CLASSIFICADORA,
                                     CLASSE,
                                     OBS,
                                     OWNER,
                                     CALL_SIGN,
                                     N_TANKS,
                                     SBT,
                                     DOUBLE_HULL,
                                     DOUBLE_BOTTOM,
                                     INERT_GAS_SYS,
                                     HEATING_COILS,
                                     IMO_NUM,
                                     IMO_TYPE,
                                     COATING,
                                     CARGO_PUMPS,
                                     CUBIC_CAPACITY,
                                     CARGO_LINES,
                                     CARGO_MANIFOLDS,
                                     MAJORS_AP,
                                     SUMMER_DRAFT from NAVIO_T ;

insert into MOEDA (
                                     COD,
                                     NOME)
select 
                                     COD,
                                     NOME from MOEDA_T ;

insert into MODALIDADE_FRETE (
                                     COD,
                                     DESCR,
                                     OBS)
select 
                                     COD,
                                     DESCR,
                                     OBS from MODALIDADE_FRETE_T ;

insert into COND_PAG (
                                     COD,
                                     DESCR,
                                     PERÍODO,
                                     OBS,
                                     FIN_COND)
select 
                                     COD,
                                     DESCR,
                                     PERÍODO,
                                     OBS,
                                     FIN_COND from COND_PAG_T ;

insert into INCOTERM (
                                     COD,
                                     DESCR,
                                     OBS)
select 
                                     COD,
                                     DESCR,
                                     OBS from INCOTERM_T ;

              insert into CIA (
                                     LOGO,
                                     LOGOTIPO,
                                     COD,
                                     CGC,
                                     NOME,
                                     ENDEREÇO,
                                     BAIRRO,
                                     CIDADE,
                                     ESTADO,
                                     PAÍS,
                                     CEP,
                                     CAIXA_POSTAL,
                                     TELEFONE,
                                     FAX,
                                     TELEX,
                                     E_MAIL,
                                     F_COD,
                                     MARCAÇÃO,
                                     OBS,
                                     LOCAL_RESULT)
                                    select   LOGO,
                                     LOGOTIPO,
                                     COD,
                                     CGC,
                                     NOME,
                                     ENDEREÇO,
                                     BAIRRO,
                                     CIDADE,
                                     ESTADO,
                                     PAÍS,
                                     CEP,
                                     CAIXA_POSTAL,
                                     TELEFONE,
                                     FAX,
                                     TELEX,
                                     E_MAIL,
                                     F_COD,
                                     MARCAÇÃO,
                                     OBS,
                                     LOCAL_RESULT from CIA_T;
insert into CARTA_CRÉDITO (
                                     REF,
                                     REF_LC,
                                     DATA_EMISS,
                                     MOEDA,
                                     VALOR,
                                     PESO,
                                     BCO_EMISSOR,
                                     BCO_NEGOCIADOR,
                                     BCO_AVISADOR,
                                     BCO_CONFIRMADOR,
                                     BCO_RECEBEDOR,
                                     VALIDADE_LC,
                                     VALIDADE_EMB,
                                     FORM_PAGAMENTO,
                                     TOLER_QTD,
                                     TOLER_VALOR,
                                     APRESENT_DOC,
                                     UNID_PESO)
select 
                                     REF,
                                     REF_LC,
                                     DATA_EMISS,
                                     MOEDA,
                                     VALOR,
                                     PESO,
                                     BCO_EMISSOR,
                                     BCO_NEGOCIADOR,
                                     BCO_AVISADOR,
                                     BCO_CONFIRMADOR,
                                     BCO_RECEBEDOR,
                                     VALIDADE_LC,
                                     VALIDADE_EMB,
                                     FORM_PAGAMENTO,
                                     TOLER_QTD,
                                     TOLER_VALOR,
                                     APRESENT_DOC,
                                     UNID_PESO from CARTA_CRÉDITO_T ;

insert into VIAGEM (
                                     REF,
                                     NAVIO,
                                     NAVIO_ÚLTIMO,
                                     CORRENTE,
                                     OBS)
select 
                                     REF,
                                     NAVIO,
                                     NAVIO_ÚLTIMO,
                                     CORRENTE,
                                     OBS from VIAGEM_T ;

insert into VIA_TRANSPORTE (
                                     COD,
                                     DESCR,
                                     TIPO)
select 
                                     COD,
                                     DESCR,
                                     TIPO from VIA_TRANSPORTE_T ;

insert into UNID_QUANTID (
                                     COD,
                                     NOME)
select 
                                     COD,
                                     NOME from UNID_QUANTID_T ;

insert into GRUPO_PRODUTO (
                                     COD,
                                     DESCR)
select 
                                     COD,
                                     DESCR from GRUPO_PRODUTO_T ;

insert into PORTO (
                                     COD,
                                     NOME,
                                     CIDADE,
                                     ESTADO,
                                     PAÍS,
                                     RESTRIÇÕES,
                                     OBS)
select 
                                     COD,
                                     NOME,
                                     CIDADE,
                                     ESTADO,
                                     PAÍS,
                                     RESTRIÇÕES,
                                     OBS from PORTO_T ;

insert into EMB (
                                     CALC_NOMINAL_PED,
                                     REF,
                                     VIAGEM,
                                     FRETE_UNID,
                                     FRETE_VALOR,
                                     FRETE_POR_MT,
                                     FRETE_VALOR_POR_UNID,
                                     FRETE_VALOR_TOTAL,
                                     FRETE_COND,
                                     DATA_EMBARQUE,
                                     DATA_EMISSÃO_DOC,
                                     CARGA_PORTO,
                                     DESCARGA_PORTO,
                                     TRANSPORTADOR,
                                     MOEDA,
                                     IDIOMA,
                                     PESO_UNID,
                                     PREÇO_UNITÁRIO_UNID,
                                     PREÇO_UNID,
                                     NEGOCIADOR,
                                     EMBARCADOR,
                                     EMB_ENDEREÇO,
                                     EMB_PAÍS,
                                     EMB_COND_VENDA,
                                     EMB_COND_PAG,
                                     EMB_COMENTÁRIOS,
                                     EXP,
                                     EXP_ENDEREÇO,
                                     EXP_PAÍS,
                                     EXP_COND_VENDA,
                                     EXP_COND_PAG,
                                     EXP_COMENTÁRIOS,
                                     EXP_LOGOTIPO,
                                     EXP_FAT,
                                     IMP,
                                     IMP_ENDEREÇO,
                                     IMP_PAÍS,
                                     IMP_COND_VENDA,
                                     IMP_COND_PAG,
                                     IMP_COMENTÁRIOS,
                                     IMP_LOGOTIPO,
                                     IMP_FAT,
                                     PAGADOR,
                                     PAG_ENDEREÇO,
                                     PAG_PAÍS,
                                     CONSIGNATÁRIO,
                                     CONSIGN_ENDEREÇO,
                                     CONSIGN_PAÍS,
                                     NOTIFICAR,
                                     NOTIFICAR_ENDEREÇO,
                                     NOTIFICAR_PAÍS,
                                     NUM_BL_DESCR,
                                     FAMÍLIA_GENÉRICA,
                                     TIPO_DESCR_MERCADORIA,
                                     MARCAÇÃO,
                                     TOTALIZAÇÃO_EMBALAGEM,
                                     CONFIG,
                                     EMB_ACORDO,
                                     VIA_TRANSPORTE,
                                     CARTA_CRED_REF,
                                     EMB_DATA,
                                     CARTA_CRÉDITO_BANCO_ABRIDOR,
                                     CARTA_CRÉDITO_REF,
                                     BANCO_AVISADOR,
                                     BANCO_CONFIRM,
                                     CALC_QTD_PED_UNID,
                                     CALC_PESO_LÍQUIDO,
                                     CALC_PESO_BRUTO,
                                     CALC_QTD_VOL,
                                     CALC_EXP_TOT_ITEM,
                                     CALC_EXP_TOT_EMB,
                                     CALC_EXP_COND_PAG,
                                     CALC_EXP_COND_VENDA,
                                     CALC_IMP_TOT_ITEM,
                                     CALC_IMP_TOT_EMB,
                                     CALC_IMP_COND_PAG,
                                     CALC_IMP_COND_VENDA,
                                     CALC_FRETE_TOTAL,
                                     CALC_PEND)
select 
                                     CALC_NOMINAL_PED,
                                     REF,
                                     VIAGEM,
                                     FRETE_UNID,
                                     FRETE_VALOR,
                                     FRETE_POR_MT,
                                     FRETE_VALOR_POR_UNID,
                                     FRETE_VALOR_TOTAL,
                                     FRETE_COND,
                                     DATA_EMBARQUE,
                                     DATA_EMISSÃO_DOC,
                                     CARGA_PORTO,
                                     DESCARGA_PORTO,
                                     TRANSPORTADOR,
                                     MOEDA,
                                     IDIOMA,
                                     PESO_UNID,
                                     PREÇO_UNITÁRIO_UNID,
                                     PREÇO_UNID,
                                     NEGOCIADOR,
                                     EMBARCADOR,
                                     EMB_ENDEREÇO,
                                     EMB_PAÍS,
                                     EMB_COND_VENDA,
                                     EMB_COND_PAG,
                                     EMB_COMENTÁRIOS,
                                     EXP,
                                     EXP_ENDEREÇO,
                                     EXP_PAÍS,
                                     EXP_COND_VENDA,
                                     EXP_COND_PAG,
                                     EXP_COMENTÁRIOS,
                                     EXP_LOGOTIPO,
                                     EXP_FAT,
                                     IMP,
                                     IMP_ENDEREÇO,
                                     IMP_PAÍS,
                                     IMP_COND_VENDA,
                                     IMP_COND_PAG,
                                     IMP_COMENTÁRIOS,
                                     IMP_LOGOTIPO,
                                     IMP_FAT,
                                     PAGADOR,
                                     PAG_ENDEREÇO,
                                     PAG_PAÍS,
                                     CONSIGNATÁRIO,
                                     CONSIGN_ENDEREÇO,
                                     CONSIGN_PAÍS,
                                     NOTIFICAR,
                                     NOTIFICAR_ENDEREÇO,
                                     NOTIFICAR_PAÍS,
                                     NUM_BL_DESCR,
                                     FAMÍLIA_GENÉRICA,
                                     TIPO_DESCR_MERCADORIA,
                                     MARCAÇÃO,
                                     TOTALIZAÇÃO_EMBALAGEM,
                                     CONFIG,
                                     EMB_ACORDO,
                                     VIA_TRANSPORTE,
                                     CARTA_CRED_REF,
                                     EMB_DATA,
                                     CARTA_CRÉDITO_BANCO_ABRIDOR,
                                     CARTA_CRÉDITO_REF,
                                     BANCO_AVISADOR,
                                     BANCO_CONFIRM,
                                     CALC_QTD_PED_UNID,
                                     CALC_PESO_LÍQUIDO,
                                     CALC_PESO_BRUTO,
                                     CALC_QTD_VOL,
                                     CALC_EXP_TOT_ITEM,
                                     CALC_EXP_TOT_EMB,
                                     CALC_EXP_COND_PAG,
                                     CALC_EXP_COND_VENDA,
                                     CALC_IMP_TOT_ITEM,
                                     CALC_IMP_TOT_EMB,
                                     CALC_IMP_COND_PAG,
                                     CALC_IMP_COND_VENDA,
                                     CALC_FRETE_TOTAL,
                                     CALC_PEND from EMB_T ;

insert into PRODUTO (
                                     COD,
                                     NOME,
                                     GRUPO,
                                     NCM,
                                     NALADI,
                                     NCM_OBS,
                                     NALADI_OBS,
                                     MEDIDAS)
select 
                                     COD,
                                     NOME,
                                     GRUPO,
                                     NCM,
                                     NALADI,
                                     NCM_OBS,
                                     NALADI_OBS,
                                     MEDIDAS from PRODUTO_T ;

insert into VIAGEM_ESCALA (
                                     VIAGEM_REF,
                                     ESCALA,
                                     PORTO,
                                     ETA,
                                     ETS,
                                     ATA,
                                     ATS,
                                     LD,
                                     OBS)
select 
                                     VIAGEM_REF,
                                     ESCALA,
                                     PORTO,
                                     ETA,
                                     ETS,
                                     ATA,
                                     ATS,
                                     LD,
                                     OBS from VIAGEM_ESCALA_T ;

insert into EMBALAGEM (
                                     COD,
                                     DESCR,
                                     OBS)
select 
                                     COD,
                                     DESCR,
                                     OBS from EMBALAGEM_T ;

insert into DOC (
                                     COD,
                                     NOME,
                                     OBJETO_VINCULADO,
                                     FORMULÁRIO_PARAM)
select 
                                     COD,
                                     NOME,
                                     OBJETO_VINCULADO,
                                     FORMULÁRIO_PARAM from DOC_T ;

insert into PARAM (
                                     GRUPO,
                                     PARAM,
                                     QUANDO_TEXTO)
select 
                                     GRUPO,
                                     PARAM,
                                     QUANDO_TEXTO from PARAM_T ;

insert into PED (
                                     REF,
                                     PED_DATA,
                                     MOEDA,
                                     TAXA_USD,
                                     VIA_TRANSPORTE,
                                     CARGA_PORTO,
                                     PAÍS_DESTINO,
                                     FORNECEDOR,
                                     FORNECEDOR_REF,
                                     FORNECEDOR_COND_RECEB,
                                     EXP,
                                     EXP_REF,
                                     EXP_COND_RECEB,
                                     IMP,
                                     IMP_REF,
                                     IMP_COND_RECEB,
                                     DISTRIBUIDOR,
                                     PAGADOR,
                                     FRETE_COND,
                                     FRETE_PREV_POR_MT,
                                     FRETE_PREV_VALOR,
                                     EMB_PREV,
                                     MARCAÇÃO,
                                     OBS,
                                     TIPO_VENDA,
                                     GRUPO_PROD,
                                     SUPERVISOR_VENDA,
                                     PRODUÇÃO_PREV,
                                     PARIDADE,
                                     INSPEÇÃO_EXTERNA,
                                     RESPONSÁVEL_INSP_EXT,
                                     AGENTE,
                                     TAXA_JUROS_FINANCIAM,
                                     JUROS_NO_PREÇO,
                                     COMISSÃO_PERCENT,
                                     COMISSÃO_MT,
                                     ADICIONAL_PERCENT,
                                     ADICIONAL_MT,
                                     INCIDÊNCIA,
                                     TIPO,
                                     ANEXO,
                                     BENEFICIÁRIO,
                                     LOCAL_PAG,
                                     BANCO,
                                     F_QUANTIDADE,
                                     F_PREÇO,
                                     F_RESULTADO,
                                     F_RESULTADO_MT,
                                     F_RESULTADO_P,
                                     F_COMISSÃO_FORN,
                                     F_COMISSÃO_FORN_P,
                                     F_PROFIT_SPLIT,
                                     F_DELIV_PURCHASE,
                                     F_DELIV_SALES,
                                     F_PAY_PURCHASE,
                                     F_PAY_SALES,
                                     F_OBS,
                                     FORNECEDOR_COND_VENDA,
                                     EXP_COND_VENDA,
                                     IMP_COND_VENDA,
                                     INSTRUC_INTERNA,
                                     PRODUTOR,
                                     CERTIFI_QUALIDADE_CSN,
                                     CLIENTE_CSN,
                                     CLIENTE_FINAL_CSN,
                                     COMISSÃO_CSN,
                                     NUM_CSN,
                                     OV,
                                     PORTO_DESTINO_CSN)
select 
                                     REF,
                                     PED_DATA,
                                     MOEDA,
                                     TAXA_USD,
                                     VIA_TRANSPORTE,
                                     CARGA_PORTO,
                                     PAÍS_DESTINO,
                                     FORNECEDOR,
                                     FORNECEDOR_REF,
                                     FORNECEDOR_COND_RECEB,
                                     EXP,
                                     EXP_REF,
                                     EXP_COND_RECEB,
                                     IMP,
                                     IMP_REF,
                                     IMP_COND_RECEB,
                                     DISTRIBUIDOR,
                                     PAGADOR,
                                     FRETE_COND,
                                     FRETE_PREV_POR_MT,
                                     FRETE_PREV_VALOR,
                                     EMB_PREV,
                                     MARCAÇÃO,
                                     OBS,
                                     TIPO_VENDA,
                                     GRUPO_PROD,
                                     SUPERVISOR_VENDA,
                                     PRODUÇÃO_PREV,
                                     PARIDADE,
                                     INSPEÇÃO_EXTERNA,
                                     RESPONSÁVEL_INSP_EXT,
                                     AGENTE,
                                     TAXA_JUROS_FINANCIAM,
                                     JUROS_NO_PREÇO,
                                     COMISSÃO_PERCENT,
                                     COMISSÃO_MT,
                                     ADICIONAL_PERCENT,
                                     ADICIONAL_MT,
                                     INCIDÊNCIA,
                                     TIPO,
                                     ANEXO,
                                     BENEFICIÁRIO,
                                     LOCAL_PAG,
                                     BANCO,
                                     F_QUANTIDADE,
                                     F_PREÇO,
                                     F_RESULTADO,
                                     F_RESULTADO_MT,
                                     F_RESULTADO_P,
                                     F_COMISSÃO_FORN,
                                     F_COMISSÃO_FORN_P,
                                     F_PROFIT_SPLIT,
                                     F_DELIV_PURCHASE,
                                     F_DELIV_SALES,
                                     F_PAY_PURCHASE,
                                     F_PAY_SALES,
                                     F_OBS,
                                     FORNECEDOR_COND_VENDA,
                                     EXP_COND_VENDA,
                                     IMP_COND_VENDA,
                                     INSTRUC_INTERNA,
                                     PRODUTOR,
                                     CERTIFI_QUALIDADE_CSN,
                                     CLIENTE_CSN,
                                     CLIENTE_FINAL_CSN,
                                     COMISSÃO_CSN,
                                     NUM_CSN,
                                     OV,
                                     PORTO_DESTINO_CSN from PED_T ;

insert into DEPTO (
                                     COD,
                                     NOME)
select 
                                     COD,
                                     NOME from DEPTO_T ;

insert into FECH (
                                     REF,
                                     FECH_DATA,
                                     MOEDA,
                                     VIAGEM_REF,
                                     CARGA_PORTO_ESCALA,
                                     DESCARGA_PORTO_ESCALA,
                                     CONTRATANTE,
                                     CORRETOR,
                                     PROPRIETÁRIO,
                                     NEGOCIANTE,
                                     FRETE_DETALHE,
                                     FRETE_UNID,
                                     FRETE_VALOR,
                                     FRETE_VALOR_POR_UNID,
                                     FRETE_PAG_DETALHE,
                                     COMISSÃO_FRETE,
                                     COMISSÃO_BASE,
                                     COMISSÃO_PERCENT,
                                     CIA_PAGADORA,
                                     CARGA_AGENTE,
                                     CARGA_ESTIVA,
                                     CARGA_ESTIVA_CUSTO,
                                     CARGA_DETALHE,
                                     CARGA_OBS,
                                     DESCARGA_AGENTE,
                                     DESCARGA_ESTIVA,
                                     DESCARGA_ESTIVA_CUSTO,
                                     DESCARGA_DETALHE,
                                     DESCARGA_OBS,
                                     DETENÇÃO,
                                     DEMORA,
                                     OBS,
                                     DESPACHANTE)
select 
                                     REF,
                                     FECH_DATA,
                                     MOEDA,
                                     VIAGEM_REF,
                                     CARGA_PORTO_ESCALA,
                                     DESCARGA_PORTO_ESCALA,
                                     CONTRATANTE,
                                     CORRETOR,
                                     PROPRIETÁRIO,
                                     NEGOCIANTE,
                                     FRETE_DETALHE,
                                     FRETE_UNID,
                                     FRETE_VALOR,
                                     FRETE_VALOR_POR_UNID,
                                     FRETE_PAG_DETALHE,
                                     COMISSÃO_FRETE,
                                     COMISSÃO_BASE,
                                     COMISSÃO_PERCENT,
                                     CIA_PAGADORA,
                                     CARGA_AGENTE,
                                     CARGA_ESTIVA,
                                     CARGA_ESTIVA_CUSTO,
                                     CARGA_DETALHE,
                                     CARGA_OBS,
                                     DESCARGA_AGENTE,
                                     DESCARGA_ESTIVA,
                                     DESCARGA_ESTIVA_CUSTO,
                                     DESCARGA_DETALHE,
                                     DESCARGA_OBS,
                                     DETENÇÃO,
                                     DEMORA,
                                     OBS,
                                     DESPACHANTE from FECH_T ;

insert into PED_ITEM (
                                     PED_REF,
                                     ITEM,
                                     USUÁRIO_FINAL,
                                     USUÁRIO_REF,
                                     PED_UNID,
                                     NOMINAL_PED_UNID,
                                     TOTAL_FECH,
                                     TOTAL_EMB,
                                     TOLERÂNCIA_MIN,
                                     TOLERÂNCIA_MAX,
                                     PROD,
                                     DESCARGA_PORTO,
                                     EMBALAGEM,
                                     EMBALAGEM_PESO_MIN,
                                     EMBALAGEM_PESO_MAX,
                                     PREÇO_UNITÁRIO_FORNECEDOR,
                                     PREÇO_UNITÁRIO_EXP,
                                     PREÇO_UNITÁRIO_IMP,
                                     ESPESSURA_TIPO,
                                     ESPESSURA_MM,
                                     LARGURA_MM,
                                     COMPRIMENTO_MM,
                                     ESPESSURA_POL,
                                     LARGURA_POL,
                                     COMPRIMENTO_POL,
                                     NCM,
                                     NALADI,
                                     P,
                                     LOTE,
                                     OV,
                                     NE_ITEM,
                                     NE_ENVIO,
                                     TBN,
                                     FSE,
                                     PO,
                                     BL_CODE,
                                     USO_FINAL,
                                     DIÂMETRO_INTERNO,
                                     DIÂMETRO_EXTERNO,
                                     PESO_POR_FOLHA,
                                     AÇO_TIPO,
                                     REVESTIMENTO,
                                     TÊMPERA,
                                     ACABAMENTO,
                                     NORMA_TOLERÂNCIA,
                                     NORMA_PRODUÇÃO,
                                     BORDAS,
                                     OLEAMENTO,
                                     TRAT_TÉRMICO,
                                     TRAT_QUÍMICO,
                                     LA,
                                     LE,
                                     LÍNGUA,
                                     PROD_DESCR,
                                     COMPOSIÇÃO_QUÍMICA,
                                     MARCAÇÃO_PRODUÇÃO,
                                     COMENTÁRIO,
                                     PED_USINA_DATA,
                                     PED_USINA_ID,
                                     PED_USINA_CONFIRM,
                                     LAYDAY_INÍCIO,
                                     LAYDAY_FINAL,
                                     QTD_VOL,
                                     PESO_LÍQUIDO,
                                     PESO_BRUTO,
                                     FECH_REQUISITADO,
                                     FECH_NOTIFICADO,
                                     CANCEL_DATA,
                                     CANCEL_MOTIVO,
                                     SEGURO_PERCENT,
                                     CUR_PERCENT,
                                     SUPERFÍCIE,
                                     DIAMET_INT_MAX_TOLER,
                                     DIAMET_INT_MIM_TOLER,
                                     TQ,
                                     CERTIF_QUALIDADE,
                                     RABO_PEIXE,
                                     RABO_PEIXE_MAX,
                                     LÍNGUA_MAX,
                                     MARCAÇÃO_ESPECIAL_DOC,
                                     OBS,
                                     MARCAÇÃO,
                                     NOMINAL_MT,
                                     DIMENSÃO,
                                     TOL_CSN,
                                     RECOZIDO_CSN,
                                     TOL_ESPESSURA_CSN,
                                     TOL_LARGURA_CSN,
                                     TOL_COMPRIMENTO_CSN,
                                     MARCAÇÃO_DIF_CSN,
                                     FACE_PESADA_CSN,
                                     APLAINAMENTO_CSN,
                                     PASSIVAÇÃO_CSN,
                                     ACABAMENTO_CSN,
                                     FAIXA_PESO_CSN,
                                     SOLDAS_CSN,
                                     NUM_SOLDAS_CSN,
                                     MARCAÇÃO_SOLDA_CSN,
                                     VERNIZ_DOURADO_CSN,
                                     POSIÇÃO_FOLHA_PALLET_CSN,
                                     RUGOSIDADE_CSN,
                                     ESQUADRIA_CSN,
                                     NUM_CONSULTA_CSN,
                                     TOLERÂNCIA_PADRÃO_CSN,
                                     MARCAÇOES_ADICIONAIS_CSN)
select 
                                     PED_REF,
                                     ITEM,
                                     USUÁRIO_FINAL,
                                     USUÁRIO_REF,
                                     PED_UNID,
                                     NOMINAL_PED_UNID,
                                     TOTAL_FECH,
                                     TOTAL_EMB,
                                     TOLERÂNCIA_MIN,
                                     TOLERÂNCIA_MAX,
                                     PROD,
                                     DESCARGA_PORTO,
                                     EMBALAGEM,
                                     EMBALAGEM_PESO_MIN,
                                     EMBALAGEM_PESO_MAX,
                                     PREÇO_UNITÁRIO_FORNECEDOR,
                                     PREÇO_UNITÁRIO_EXP,
                                     PREÇO_UNITÁRIO_IMP,
                                     ESPESSURA_TIPO,
                                     ESPESSURA_MM,
                                     LARGURA_MM,
                                     COMPRIMENTO_MM,
                                     ESPESSURA_POL,
                                     LARGURA_POL,
                                     COMPRIMENTO_POL,
                                     NCM,
                                     NALADI,
                                     P,
                                     LOTE,
                                     OV,
                                     NE_ITEM,
                                     NE_ENVIO,
                                     TBN,
                                     FSE,
                                     PO,
                                     BL_CODE,
                                     USO_FINAL,
                                     DIÂMETRO_INTERNO,
                                     DIÂMETRO_EXTERNO,
                                     PESO_POR_FOLHA,
                                     AÇO_TIPO,
                                     REVESTIMENTO,
                                     TÊMPERA,
                                     ACABAMENTO,
                                     NORMA_TOLERÂNCIA,
                                     NORMA_PRODUÇÃO,
                                     BORDAS,
                                     OLEAMENTO,
                                     TRAT_TÉRMICO,
                                     TRAT_QUÍMICO,
                                     LA,
                                     LE,
                                     LÍNGUA,
                                     PROD_DESCR,
                                     COMPOSIÇÃO_QUÍMICA,
                                     MARCAÇÃO_PRODUÇÃO,
                                     COMENTÁRIO,
                                     PED_USINA_DATA,
                                     PED_USINA_ID,
                                     PED_USINA_CONFIRM,
                                     LAYDAY_INÍCIO,
                                     LAYDAY_FINAL,
                                     QTD_VOL,
                                     PESO_LÍQUIDO,
                                     PESO_BRUTO,
                                     FECH_REQUISITADO,
                                     FECH_NOTIFICADO,
                                     CANCEL_DATA,
                                     CANCEL_MOTIVO,
                                     SEGURO_PERCENT,
                                     CUR_PERCENT,
                                     SUPERFÍCIE,
                                     DIAMET_INT_MAX_TOLER,
                                     DIAMET_INT_MIM_TOLER,
                                     TQ,
                                     CERTIF_QUALIDADE,
                                     RABO_PEIXE,
                                     RABO_PEIXE_MAX,
                                     LÍNGUA_MAX,
                                     MARCAÇÃO_ESPECIAL_DOC,
                                     OBS,
                                     MARCAÇÃO,
                                     NOMINAL_MT,
                                     DIMENSÃO,
                                     TOL_CSN,
                                     RECOZIDO_CSN,
                                     TOL_ESPESSURA_CSN,
                                     TOL_LARGURA_CSN,
                                     TOL_COMPRIMENTO_CSN,
                                     MARCAÇÃO_DIF_CSN,
                                     FACE_PESADA_CSN,
                                     APLAINAMENTO_CSN,
                                     PASSIVAÇÃO_CSN,
                                     ACABAMENTO_CSN,
                                     FAIXA_PESO_CSN,
                                     SOLDAS_CSN,
                                     NUM_SOLDAS_CSN,
                                     MARCAÇÃO_SOLDA_CSN,
                                     VERNIZ_DOURADO_CSN,
                                     POSIÇÃO_FOLHA_PALLET_CSN,
                                     RUGOSIDADE_CSN,
                                     ESQUADRIA_CSN,
                                     NUM_CONSULTA_CSN,
                                     TOLERÂNCIA_PADRÃO_CSN,
                                     MARCAÇOES_ADICIONAIS_CSN from PED_ITEM_T ;

insert into CONFIRM_VENDA (
                                     REF,
                                     SEQ,
                                     EMISSÃO_DATA,
                                     EMISSOR,
                                     PED_REF,
                                     OUTRA_REF,
                                     COMPRADOR,
                                     USUÁRIO_FINAL,
                                     DESTINATÁRIO,
                                     ENTREGA,
                                     CARGA_PORTO,
                                     IDIOMA,
                                     DIMENSÃO,
                                     PREÇO_DETALHE,
                                     ESPECIFICAÇÃO,
                                     EMBALAGEM,
                                     SEGURO,
                                     PAG,
                                     OBS,
                                     OBS_TERMOS,
                                     PRODUTOR,
                                     DESCARGA_PORTO,
                                     ASSINATURA,
                                     DT_REVISÃO,
                                     EMPRESA_REL,
                                     MOEDA,
                                     VENDEDOR)
select 
                                     REF,
                                     SEQ,
                                     EMISSÃO_DATA,
                                     EMISSOR,
                                     PED_REF,
                                     OUTRA_REF,
                                     COMPRADOR,
                                     USUÁRIO_FINAL,
                                     DESTINATÁRIO,
                                     ENTREGA,
                                     CARGA_PORTO,
                                     IDIOMA,
                                     DIMENSÃO,
                                     PREÇO_DETALHE,
                                     ESPECIFICAÇÃO,
                                     EMBALAGEM,
                                     SEGURO,
                                     PAG,
                                     OBS,
                                     OBS_TERMOS,
                                     PRODUTOR,
                                     DESCARGA_PORTO,
                                     ASSINATURA,
                                     DT_REVISÃO,
                                     EMPRESA_REL,
                                     MOEDA,
                                     VENDEDOR from CONFIRM_VENDA_T ;

insert into ESCRITÓRIO (
                                     ESCRITÓRIO,
                                     DESCR)
select 
                                     ESCRITÓRIO,
                                     DESCR from ESCRITÓRIO_T ;

insert into DIVISÃO (
                                     ESCRITÓRIO,
                                     DIVISÃO,
                                     DESCR)
select 
                                     ESCRITÓRIO,
                                     DIVISÃO,
                                     DESCR from DIVISÃO_T ;

insert into FECH_CARGA (
                                     FECH_REF,
                                     PED_REF,
                                     PED_ITEM,
                                     QTD_PED_UNID,
                                     QTD_FRETE_UNID,
                                     QTD_TOTAL,
                                     NOMEAÇÃO_DATA,
                                     ACEITAÇÃO_FORNECEDOR_DATA,
                                     CANCEL_DATA,
                                     CANCEL_MOTIVO)
select 
                                     FECH_REF,
                                     PED_REF,
                                     PED_ITEM,
                                     QTD_PED_UNID,
                                     QTD_FRETE_UNID,
                                     QTD_TOTAL,
                                     NOMEAÇÃO_DATA,
                                     ACEITAÇÃO_FORNECEDOR_DATA,
                                     CANCEL_DATA,
                                     CANCEL_MOTIVO from FECH_CARGA_T ;

insert into HIST_PADRAO (
                                     CLIENTE,
                                     FORNECEDOR,
                                     GRUPO,
                                     PAÍS_DESTINO)
select 
                                     CLIENTE,
                                     FORNECEDOR,
                                     GRUPO,
                                     PAÍS_DESTINO from HIST_PADRAO_T ;

insert into FAX (
                                     REF,
                                     USUÁRIO,
                                     MOMENTO_CRIA,
                                     MOMENTO_ENVIA,
                                     MOMENTO_CONFIRM,
                                     PÁGINAS_ADICIONAIS,
                                     DOC,
                                     DE,
                                     ASSUNTO,
                                     FAX_CORPO,
                                     FAX_OBJ,
                                     COMENTÁRIO,
                                     CANCEL)
select 
                                     REF,
                                     USUÁRIO,
                                     MOMENTO_CRIA,
                                     MOMENTO_ENVIA,
                                     MOMENTO_CONFIRM,
                                     PÁGINAS_ADICIONAIS,
                                     DOC,
                                     DE,
                                     ASSUNTO,
                                     FAX_CORPO,
                                     FAX_OBJ,
                                     COMENTÁRIO,
                                     CANCEL from FAX_T ;

insert into CONTA (
                                     EMPRESA,
                                     CONTA,
                                     NOME)
select 
                                     EMPRESA,
                                     CONTA,
                                     NOME from CONTA_T ;

insert into INSTRUÇÃO_PAG (
                                     REF,
                                     SOLICITAÇÃO_DATA,
                                     MOEDA,
                                     VALOR,
                                     RECEBEDOR,
                                     PAG_DATA,
                                     PAG_FORMA,
                                     HISTÓRICO,
                                     OBS,
                                     PAGADOR,
                                     RESPONSÁVEL,
                                     SOLICITANTE,
                                     AUTORIZADOR,
                                     COM_CÓPIA)
select 
                                     REF,
                                     SOLICITAÇÃO_DATA,
                                     MOEDA,
                                     VALOR,
                                     RECEBEDOR,
                                     PAG_DATA,
                                     PAG_FORMA,
                                     HISTÓRICO,
                                     OBS,
                                     PAGADOR,
                                     RESPONSÁVEL,
                                     SOLICITANTE,
                                     AUTORIZADOR,
                                     COM_CÓPIA from INSTRUÇÃO_PAG_T ;

insert into EMB_F (
                                     PED_REF,
                                     SEQ,
                                     FATURA,
                                     INV_DATA,
                                     NAVIO,
                                     BL_DATA,
                                     COMPETÊNCIA,
                                     QUANTIDADE,
                                     VALOR,
                                     RESULT1,
                                     RESULT2,
                                     RESULT3,
                                     RESULT4,
                                     RESULT5,
                                     POSIÇÃO,
                                     OBSERVAÇÃO)
select 
                                     PED_REF,
                                     SEQ,
                                     FATURA,
                                     INV_DATA,
                                     NAVIO,
                                     BL_DATA,
                                     COMPETÊNCIA,
                                     QUANTIDADE,
                                     VALOR,
                                     RESULT1,
                                     RESULT2,
                                     RESULT3,
                                     RESULT4,
                                     RESULT5,
                                     POSIÇÃO,
                                     OBSERVAÇÃO from EMB_F_T ;

insert into TIPO_REF (
                                     TIPO,
                                     DESCR,
                                     DEPTO,
                                     ARQUIVO)
select 
                                     TIPO,
                                     DESCR,
                                     DEPTO,
                                     ARQUIVO from TIPO_REF_T ;

insert into NOTA_DÉBITO (
                                     REF,
                                     DOC_DATA,
                                     MOEDA,
                                     TAXA_USD,
                                     VALOR,
                                     CIA,
                                     CONTATO,
                                     CIA_SUB,
                                     CONTATO_SUB,
                                     TEXTO,
                                     TRANSFERÊNCIA_DETALHE,
                                     ASSUNTO,
                                     EMISSÃO_DATA)
select 
                                     REF,
                                     DOC_DATA,
                                     MOEDA,
                                     TAXA_USD,
                                     VALOR,
                                     CIA,
                                     CONTATO,
                                     CIA_SUB,
                                     CONTATO_SUB,
                                     TEXTO,
                                     TRANSFERÊNCIA_DETALHE,
                                     ASSUNTO,
                                     EMISSÃO_DATA from NOTA_DÉBITO_T ;

insert into LANÇ (
                                     LANÇ,
                                     NOME)
select 
                                     LANÇ,
                                     NOME from LANÇ_T ;

insert into RAMO_ATIVIDADE (
                                     COD,
                                     NOME)
select 
                                     COD,
                                     NOME from RAMO_ATIVIDADE_T ;

insert into PROG (
                                     FECH_REF,
                                     POSICIONAMENTO_DATA,
                                     ARMAZÉM,
                                     TERNO_NUM,
                                     FLUXO,
                                     OBS)
select 
                                     FECH_REF,
                                     POSICIONAMENTO_DATA,
                                     ARMAZÉM,
                                     TERNO_NUM,
                                     FLUXO,
                                     OBS from PROG_T ;

insert into NOTA_CRÉDITO (
                                     REF,
                                     DOC_DATA,
                                     MOEDA,
                                     TAXA_USD,
                                     VALOR,
                                     CIA,
                                     CONTATO,
                                     CIA_SUB,
                                     CONTATO_SUB,
                                     TEXTO,
                                     EMISSOR,
                                     ASSUNTO,
                                     EMISSÃO_DATA)
select 
                                     REF,
                                     DOC_DATA,
                                     MOEDA,
                                     TAXA_USD,
                                     VALOR,
                                     CIA,
                                     CONTATO,
                                     CIA_SUB,
                                     CONTATO_SUB,
                                     TEXTO,
                                     EMISSOR,
                                     ASSUNTO,
                                     EMISSÃO_DATA from NOTA_CRÉDITO_T ;

insert into CARTA (
                                     REF,
                                     EMPRESA,
                                     IDIOMA,
                                     DOC_DATA,
                                     CIA,
                                     CONTATO,
                                     CIA_SUB,
                                     CONTATO_SUB,
                                     ASSUNTO,
                                     TEXTO,
                                     EMISSÃO_DATA,
                                     COM_CÓPIA,
                                     USUÁRIO,
                                     SUPERVISOR)
select 
                                     REF,
                                     EMPRESA,
                                     IDIOMA,
                                     DOC_DATA,
                                     CIA,
                                     CONTATO,
                                     CIA_SUB,
                                     CONTATO_SUB,
                                     ASSUNTO,
                                     TEXTO,
                                     EMISSÃO_DATA,
                                     COM_CÓPIA,
                                     USUÁRIO,
                                     SUPERVISOR from CARTA_T ;

insert into DIVISÃO_PRODUTO (
                                     ESCRITÓRIO,
                                     DIVISÃO,
                                     PROD)
select 
                                     ESCRITÓRIO,
                                     DIVISÃO,
                                     PROD from DIVISÃO_PRODUTO_T ;

insert into DIVISÃO_TIPO_REF (
                                     ESCRITÓRIO,
                                     DIVISÃO,
                                     TIPO_REF)
select 
                                     ESCRITÓRIO,
                                     DIVISÃO,
                                     TIPO_REF from DIVISÃO_TIPO_REF_T ;

insert into FATURA (
                                     REF,
                                     EMPRESA,
                                     DOC_DATA,
                                     CIA,
                                     CONTATO,
                                     CIA_SUB,
                                     CONTATO_SUB,
                                     FECH_REF,
                                     BANCO_DETALHE,
                                     ASSUNTO,
                                     EMISSÃO_DATA,
                                     USUÁRIO,
                                     SUPERVISOR)
select 
                                     REF,
                                     EMPRESA,
                                     DOC_DATA,
                                     CIA,
                                     CONTATO,
                                     CIA_SUB,
                                     CONTATO_SUB,
                                     FECH_REF,
                                     BANCO_DETALHE,
                                     ASSUNTO,
                                     EMISSÃO_DATA,
                                     USUÁRIO,
                                     SUPERVISOR from FATURA_T ;

insert into EMB_DOC_DESTINO (
                                     EMB_REF,
                                     SEQ,
                                     CIA,
                                     ORIGINAL_NUM,
                                     CÓPIA_NUM,
                                     ORIGINAL_VISADA_NUM,
                                     CÓPIA_VISADA_NUM)
select 
                                     EMB_REF,
                                     SEQ,
                                     CIA,
                                     ORIGINAL_NUM,
                                     CÓPIA_NUM,
                                     ORIGINAL_VISADA_NUM,
                                     CÓPIA_VISADA_NUM from EMB_DOC_DESTINO_T ;

insert into EMB_MENSAGEM (
                                     EMB_REF,
                                     SEQ,
                                     MSG,
                                     EXP,
                                     IMP,
                                     DOC_ALADI,
                                     DOC_BORDERÔ_I,
                                     DOC_BORDERÔ_P,
                                     DOC_CÂMARA_COMÉRCIO,
                                     DOC_CARTA_I,
                                     DOC_CARTA_P,
                                     DOC_CONHECIM_ROD,
                                     DOC_FATURA,
                                     DOC_FATURA_JUROS,
                                     DOC_FECH_CAMBIO,
                                     DOC_FIRJAN,
                                     DOC_MERCOSUL,
                                     DOC_MERCOSUL_BOLIVIA,
                                     DOC_MERCOSUL_CHILE,
                                     DOC_PLIST_WEIG_CERT,
                                     DOC_SAQUE_JUR_2_VIAS,
                                     DOC_SAQUE_JUR_3_VIAS,
                                     DOC_SAQUE_2_VIAS,
                                     DOC_SAQUE_3_VIAS,
                                     DOC_ALADI_CERTIF_ORIGEM,
                                     DOC_BL,
                                     DOC_CÂM_COM_CERTIF_O,
                                     DOC_CAPA,
                                     DOC_CONHECIM_RODOVIÁRIO,
                                     DOC_CHECK_LIST,
                                     DOC_CARTA_DEOP_INGLÊS,
                                     DOC_CARTA_DEOP_PORTUG,
                                     DOC_FECHAM_CÂMBIO,
                                     DOC_FIRJAN_CERTIF_ORIGEM,
                                     DOC_FORM_A,
                                     DOC_INSTR_PAG,
                                     DOC_MERCOSUL_CERTIF_ORIGEM,
                                     DOC_PACKING_LIST,
                                     DOC_SAQUE,
                                     DOC_WEIGHT_CERTIFICATE,
                                     DOC_SAQUE_JUROS)
select 
                                     EMB_REF,
                                     SEQ,
                                     MSG,
                                     EXP,
                                     IMP,
                                     DOC_ALADI,
                                     DOC_BORDERÔ_I,
                                     DOC_BORDERÔ_P,
                                     DOC_CÂMARA_COMÉRCIO,
                                     DOC_CARTA_I,
                                     DOC_CARTA_P,
                                     DOC_CONHECIM_ROD,
                                     DOC_FATURA,
                                     DOC_FATURA_JUROS,
                                     DOC_FECH_CAMBIO,
                                     DOC_FIRJAN,
                                     DOC_MERCOSUL,
                                     DOC_MERCOSUL_BOLIVIA,
                                     DOC_MERCOSUL_CHILE,
                                     DOC_PLIST_WEIG_CERT,
                                     DOC_SAQUE_JUR_2_VIAS,
                                     DOC_SAQUE_JUR_3_VIAS,
                                     DOC_SAQUE_2_VIAS,
                                     DOC_SAQUE_3_VIAS,
                                     DOC_ALADI_CERTIF_ORIGEM,
                                     DOC_BL,
                                     DOC_CÂM_COM_CERTIF_O,
                                     DOC_CAPA,
                                     DOC_CONHECIM_RODOVIÁRIO,
                                     DOC_CHECK_LIST,
                                     DOC_CARTA_DEOP_INGLÊS,
                                     DOC_CARTA_DEOP_PORTUG,
                                     DOC_FECHAM_CÂMBIO,
                                     DOC_FIRJAN_CERTIF_ORIGEM,
                                     DOC_FORM_A,
                                     DOC_INSTR_PAG,
                                     DOC_MERCOSUL_CERTIF_ORIGEM,
                                     DOC_PACKING_LIST,
                                     DOC_SAQUE,
                                     DOC_WEIGHT_CERTIFICATE,
                                     DOC_SAQUE_JUROS from EMB_MENSAGEM_T ;

insert into EMPRESA_CONTA (
                                     EMPRESA)
select 
                                     EMPRESA from EMPRESA_CONTA_T ;

insert into CONTA_CORRENTE (
                                     COD,
                                     CONTA_CORRENTE)
select 
                                     COD,
                                     CONTA_CORRENTE from CONTA_CORRENTE_T ;

insert into EMB_LANÇ (
                                     EMB_REF,
                                     SEQ,
                                     LANÇ,
                                     VALOR,
                                     VALOR_POR_MT,
                                     TOTAL_PERCENT,
                                     TOTAL_TIPO,
                                     EXP,
                                     IMP,
                                     UNID,
                                     NA_FATURA,
                                     BENEFICIÁRIO,
                                     COMISSÃO_MODALIDADE,
                                     INSTRUÇÃO_REMESSA,
                                     EXP_CALC,
                                     IMP_CALC)
select 
                                     EMB_REF,
                                     SEQ,
                                     LANÇ,
                                     VALOR,
                                     VALOR_POR_MT,
                                     TOTAL_PERCENT,
                                     TOTAL_TIPO,
                                     EXP,
                                     IMP,
                                     UNID,
                                     NA_FATURA,
                                     BENEFICIÁRIO,
                                     COMISSÃO_MODALIDADE,
                                     INSTRUÇÃO_REMESSA,
                                     EXP_CALC,
                                     IMP_CALC from EMB_LANÇ_T ;

insert into EMPRESA (
                                     EMPRESA,
                                     RELACIONADA)
select 
                                     EMPRESA,
                                     RELACIONADA from EMPRESA_T ;

insert into FAX_CHAVE (
                                     FAX_REF,
                                     CHAVE)
select 
                                     FAX_REF,
                                     CHAVE from FAX_CHAVE_T ;

insert into EMB_SD (
                                     EMB_REF,
                                     SD,
                                     AVERBAÇÃO_DATA)
select 
                                     EMB_REF,
                                     SD,
                                     AVERBAÇÃO_DATA from EMB_SD_T ;

insert into EMB_TOTALIZA (
                                     EMB_REF,
                                     SEQ,
                                     LANÇ,
                                     EXP,
                                     IMP,
                                     EXP_DESCR,
                                     IMP_DESCR,
                                     EXP_CALC,
                                     IMP_CALC)
select 
                                     EMB_REF,
                                     SEQ,
                                     LANÇ,
                                     EXP,
                                     IMP,
                                     EXP_DESCR,
                                     IMP_DESCR,
                                     EXP_CALC,
                                     IMP_CALC from EMB_TOTALIZA_T ;

insert into EMB_DOC_REL (
                                     EMB_REF,
                                     DOC,
                                     EMB_REL)
select 
                                     EMB_REF,
                                     DOC,
                                     EMB_REL from EMB_DOC_REL_T ;

insert into NOTA_DÉBITO_RECEB (
                                     NOTA_DÉBITO_REF,
                                     SEQ,
                                     RECEB_DATA,
                                     MOEDA,
                                     TAXA_USD,
                                     VALOR,
                                     OBS)
select 
                                     NOTA_DÉBITO_REF,
                                     SEQ,
                                     RECEB_DATA,
                                     MOEDA,
                                     TAXA_USD,
                                     VALOR,
                                     OBS from NOTA_DÉBITO_RECEB_T ;

insert into SUB_CONTA (
                                     EMPRESA,
                                     SUB_CONTA,
                                     CONTA,
                                     NOME,
                                     REPORT)
select 
                                     EMPRESA,
                                     SUB_CONTA,
                                     CONTA,
                                     NOME,
                                     REPORT from SUB_CONTA_T ;

insert into RESULT (
                                     PED_REF,
                                     EMB_SEQ,
                                     SEQ,
                                     INV_DATA,
                                     RESULT1,
                                     RESULT2,
                                     RESULT3,
                                     RESULT4,
                                     RESULT5,
                                     DATA1,
                                     DATA2,
                                     DATA3,
                                     DATA4,
                                     DATA5,
                                     POSIÇÃO,
                                     OBSERVAÇÃO)
select 
                                     PED_REF,
                                     EMB_SEQ,
                                     SEQ,
                                     INV_DATA,
                                     RESULT1,
                                     RESULT2,
                                     RESULT3,
                                     RESULT4,
                                     RESULT5,
                                     DATA1,
                                     DATA2,
                                     DATA3,
                                     DATA4,
                                     DATA5,
                                     POSIÇÃO,
                                     OBSERVAÇÃO from RESULT_T ;

insert into RELACIONADA (
                                     REF)
select 
                                     REF from RELACIONADA_T ;

insert into PROG_CARGA (
                                     FECH_REF,
                                     POSICIONAMENTO_DATA,
                                     PED_REF,
                                     PED_ITEM)
select 
                                     FECH_REF,
                                     POSICIONAMENTO_DATA,
                                     PED_REF,
                                     PED_ITEM from PROG_CARGA_T ;

insert into PRODUTO_ESPECIF (
                                     COD,
                                     SEQ,
                                     NCM,
                                     NALADI,
                                     MENOR_ESPESSURA,
                                     MAIOR_ESPESSURA,
                                     MENOR_LARGURA,
                                     MAIOR_LARGURA,
                                     MENOR_COMPRIMENTO,
                                     MAIOR_COMPRIMENTO,
                                     REVESTIMENTO,
                                     TÊMPERA,
                                     DESCR,
                                     DESCR_NALADI)
select 
                                     COD,
                                     SEQ,
                                     NCM,
                                     NALADI,
                                     MENOR_ESPESSURA,
                                     MAIOR_ESPESSURA,
                                     MENOR_LARGURA,
                                     MAIOR_LARGURA,
                                     MENOR_COMPRIMENTO,
                                     MAIOR_COMPRIMENTO,
                                     REVESTIMENTO,
                                     TÊMPERA,
                                     DESCR,
                                     DESCR_NALADI from PRODUTO_ESPECIF_T ;

insert into CARTA_FECH (
                                     CARTA_REF,
                                     FECH_REF)
select 
                                     CARTA_REF,
                                     FECH_REF from CARTA_FECH_T ;

insert into CIA_CONTATO (
                                     CIA_COD,
                                     CONTATO_NOME,
                                     TELEFONE,
                                     FUNÇÃO)
select 
                                     CIA_COD,
                                     CONTATO_NOME,
                                     TELEFONE,
                                     FUNÇÃO from CIA_CONTATO_T ;

insert into PED_RESULT (
                                     PED_REF,
                                     SEQ,
                                     LANÇ,
                                     VALOR,
                                     VALOR_POR_MT,
                                     TOTAL_PERCENT,
                                     TOTAL_TIPO,
                                     COMPETÊNCIA,
                                     CALC,
                                     OBS)
select 
                                     PED_REF,
                                     SEQ,
                                     LANÇ,
                                     VALOR,
                                     VALOR_POR_MT,
                                     TOTAL_PERCENT,
                                     TOTAL_TIPO,
                                     COMPETÊNCIA,
                                     CALC,
                                     OBS from PED_RESULT_T ;

insert into INSTRUÇÃO_PAG_FECH (
                                     INSTRUÇÃO_PAG_REF,
                                     FECH_REF)
select 
                                     INSTRUÇÃO_PAG_REF,
                                     FECH_REF from INSTRUÇÃO_PAG_FECH_T ;

insert into PED_CONTATO (
                                     PED_REF,
                                     CIA_COD,
                                     CONTATO_NOME)
select 
                                     PED_REF,
                                     CIA_COD,
                                     CONTATO_NOME from PED_CONTATO_T ;

insert into FAX_DESTINO (
                                     FAX_REF,
                                     SEQ,
                                     TIPO,
                                     CIA,
                                     CONTATO,
                                     CONTATO_2,
                                     CONTATO_3,
                                     DESCR,
                                     OBS)
select 
                                     FAX_REF,
                                     SEQ,
                                     TIPO,
                                     CIA,
                                     CONTATO,
                                     CONTATO_2,
                                     CONTATO_3,
                                     DESCR,
                                     OBS from FAX_DESTINO_T ;

insert into NOTA_DÉBITO_FECH (
                                     NOTA_DÉBITO_REF,
                                     FECH_REF)
select 
                                     NOTA_DÉBITO_REF,
                                     FECH_REF from NOTA_DÉBITO_FECH_T ;

insert into NOTA_CRÉDITO_PAG (
                                     NOTA_CRÉDITO_REF,
                                     SEQ,
                                     PAG_DATA,
                                     MOEDA,
                                     TAXA_USD,
                                     VALOR,
                                     OBS)
select 
                                     NOTA_CRÉDITO_REF,
                                     SEQ,
                                     PAG_DATA,
                                     MOEDA,
                                     TAXA_USD,
                                     VALOR,
                                     OBS from NOTA_CRÉDITO_PAG_T ;

insert into NOTA_CRÉDITO_FECH (
                                     NOTA_CRÉDITO_REF,
                                     FECH_REF)
select 
                                     NOTA_CRÉDITO_REF,
                                     FECH_REF from NOTA_CRÉDITO_FECH_T ;

insert into CIA_RAMO_ATIVIDADE (
                                     CIA_COD,
                                     RAMO_ATIVIDADE)
select 
                                     CIA_COD,
                                     RAMO_ATIVIDADE from CIA_RAMO_ATIVIDADE_T ;

insert into LOCAL_RESULT (
                                     COD,
                                     DESCR)
select 
                                     COD,
                                     DESCR from LOCAL_RESULT_T ;

insert into INCOTERM_LANÇ (
                                     INCOTERM,
                                     LANÇ)
select 
                                     INCOTERM,
                                     LANÇ from INCOTERM_LANÇ_T ;

insert into CONFIRM_VENDA_ITEM (
                                     CONFIRM_VENDA_REF,
                                     SEQ,
                                     ITEM,
                                     DESCR,
                                     DIMENSÃO,
                                     QTD,
                                     UNID,
                                     PREÇO,
                                     MOEDA,
                                     QUALIDADE,
                                     PREÇO_C)
select 
                                     CONFIRM_VENDA_REF,
                                     SEQ,
                                     ITEM,
                                     DESCR,
                                     DIMENSÃO,
                                     QTD,
                                     UNID,
                                     PREÇO,
                                     MOEDA,
                                     QUALIDADE,
                                     PREÇO_C from CONFIRM_VENDA_ITEM_T ;

insert into FECH_SUBSTITUÍDO (
                                     SUBSTITUÍDO,
                                     SUBSTITUTO,
                                     SUBSTITUIÇÃO_DATA)
select 
                                     SUBSTITUÍDO,
                                     SUBSTITUTO,
                                     SUBSTITUIÇÃO_DATA from FECH_SUBSTITUÍDO_T ;

insert into FECH_CONTATO (
                                     FECH_REF,
                                     CIA_COD,
                                     CONTATO_NOME)
select 
                                     FECH_REF,
                                     CIA_COD,
                                     CONTATO_NOME from FECH_CONTATO_T ;

insert into PED_LANÇ (
                                     PED_REF,
                                     SEQ,
                                     LANÇ,
                                     VALOR,
                                     VALOR_POR_MT,
                                     TOTAL_PERCENT,
                                     TOTAL_TIPO,
                                     EXP,
                                     IMP,
                                     BENEFICIÁRIO,
                                     COMISSÃO_MODALIDADE,
                                     INSTRUÇÃO_REMESSA,
                                     EXP_CALC,
                                     IMP_CALC,
                                     OBS)
select 
                                     PED_REF,
                                     SEQ,
                                     LANÇ,
                                     VALOR,
                                     VALOR_POR_MT,
                                     TOTAL_PERCENT,
                                     TOTAL_TIPO,
                                     EXP,
                                     IMP,
                                     BENEFICIÁRIO,
                                     COMISSÃO_MODALIDADE,
                                     INSTRUÇÃO_REMESSA,
                                     EXP_CALC,
                                     IMP_CALC,
                                     OBS from PED_LANÇ_T ;

insert into ANEXO (
                                     NOME,
                                     SUB_CONTA,
                                     SUB_CONTA_REL)
select 
                                     NOME,
                                     SUB_CONTA,
                                     SUB_CONTA_REL from ANEXO_T ;

insert into HIST_PADRAO_LANÇAMENTO (
                                     CLIENTE,
                                     PAÍS_DESTINO,
                                     FORNECEDOR,
                                     GRUPO,
                                     SEQ,
                                     HISTORICO,
                                     COMPLEMENTO,
                                     DÉBITO_RS,
                                     CRÉDITO_RS,
                                     DÉBITO_US,
                                     CRÉDITO_US,
                                     EMPRESA,
                                     RELACIONADA)
select 
                                     CLIENTE,
                                     PAÍS_DESTINO,
                                     FORNECEDOR,
                                     GRUPO,
                                     SEQ,
                                     HISTORICO,
                                     COMPLEMENTO,
                                     DÉBITO_RS,
                                     CRÉDITO_RS,
                                     DÉBITO_US,
                                     CRÉDITO_US,
                                     EMPRESA,
                                     RELACIONADA from HIST_PADRAO_LANÇAMENTO_T ;

insert into MAPA (
                                     WORKSHEET,
                                     SEQ,
                                     EMPRESA,
                                     ARQUIVO,
                                     TITULO,
                                     LINHA,
                                     COLUNA,
                                     COR,
                                     LARGURA,
                                     FONT,
                                     FONT_NEGRITO,
                                     FONT_TAM,
                                     ALINHAMENTO)
select 
                                     WORKSHEET,
                                     SEQ,
                                     EMPRESA,
                                     ARQUIVO,
                                     TITULO,
                                     LINHA,
                                     COLUNA,
                                     COR,
                                     LARGURA,
                                     FONT,
                                     FONT_NEGRITO,
                                     FONT_TAM,
                                     ALINHAMENTO from MAPA_T ;

insert into MAPA_DE_CONTROLE (
                                     PED_REF,
                                     FORNECEDOR,
                                     PAÍS_DESTINO,
                                     FORN_SALES_COND,
                                     GRUPO,
                                     EMPRESA,
                                     PRODUTOR,
                                     EXPORTADOR,
                                     EXP_SALES_COND,
                                     IMPORTADOR,
                                     IMP_SALES_COND,
                                     DISTRIBUIDOR,
                                     PAGADOR,
                                     FINA_REF,
                                     SEQ,
                                     FORN_RECEIPT_COND,
                                     EXP_RECEIPT_COND,
                                     IMP_RECEIPT_COND,
                                     IEXCEL,
                                     NAVIO,
                                     BL_DATA,
                                     STATUS,
                                     ITENS,
                                     EEXCEL)
select 
                                     PED_REF,
                                     FORNECEDOR,
                                     PAÍS_DESTINO,
                                     FORN_SALES_COND,
                                     GRUPO,
                                     EMPRESA,
                                     PRODUTOR,
                                     EXPORTADOR,
                                     EXP_SALES_COND,
                                     IMPORTADOR,
                                     IMP_SALES_COND,
                                     DISTRIBUIDOR,
                                     PAGADOR,
                                     FINA_REF,
                                     SEQ,
                                     FORN_RECEIPT_COND,
                                     EXP_RECEIPT_COND,
                                     IMP_RECEIPT_COND,
                                     IEXCEL,
                                     NAVIO,
                                     BL_DATA,
                                     STATUS,
                                     ITENS,
                                     EEXCEL from MAPA_DE_CONTROLE_T ;

insert into PLANILHA_DEF (
                                     WORKSHEET,
                                     SEQ,
                                     EMPRESA,
                                     ARQUIVO,
                                     TIPO,
                                     HISTÓRICO,
                                     DATAHIST,
                                     COLUNACRT,
                                     CRT,
                                     COLUNADBCR,
                                     DÉBITO,
                                     CRÉDITO)
select 
                                     WORKSHEET,
                                     SEQ,
                                     EMPRESA,
                                     ARQUIVO,
                                     TIPO,
                                     HISTÓRICO,
                                     DATAHIST,
                                     COLUNACRT,
                                     CRT,
                                     COLUNADBCR,
                                     DÉBITO,
                                     CRÉDITO from PLANILHA_DEF_T ;

insert into PLANILHA_STC (
                                     WORKSHEET,
                                     EMPRESA,
                                     ARQUIVO,
                                     MAPA)
select 
                                     WORKSHEET,
                                     EMPRESA,
                                     ARQUIVO,
                                     MAPA from PLANILHA_STC_T ;

insert into PROCESSO (
                                     EMPRESA,
                                     REF,
                                     OUTROS,
                                     CONTRATO,
                                     FORNECEDOR,
                                     OV,
                                     PO,
                                     PRAZO,
                                     CLIENTE,
                                     NAVIO,
                                     CARGA_PORTO,
                                     DESCARGA_PORTO,
                                     PAÍS_DESTINO,
                                     BL_DATA,
                                     EMB_DATA,
                                     DOC_DATA,
                                     GRUPO,
                                     PESO_LÍQUIDO,
                                     PESO_BRUTO,
                                     FINANCEIRO,
                                     OBS)
select 
                                     EMPRESA,
                                     REF,
                                     OUTROS,
                                     CONTRATO,
                                     FORNECEDOR,
                                     OV,
                                     PO,
                                     PRAZO,
                                     CLIENTE,
                                     NAVIO,
                                     CARGA_PORTO,
                                     DESCARGA_PORTO,
                                     PAÍS_DESTINO,
                                     BL_DATA,
                                     EMB_DATA,
                                     DOC_DATA,
                                     GRUPO,
                                     PESO_LÍQUIDO,
                                     PESO_BRUTO,
                                     FINANCEIRO,
                                     OBS from PROCESSO_T ;


insert into HISTORICO (
                                     NOME)
select 
                                     NOME from HISTORICO_T ;

insert into PROCESSO_LANÇAMENTO (
                                     CRÉDITO_US,
                                     DÉBITO_US,
                                     CRÉDITO_RS,
                                     DÉBITO_RS,
                                     COMPLEMENTO,
                                     HISTORICO,
                                     DATA,
                                     EMPRESA,
                                     PROCESSO_REF,
                                     SEQ,
                                     TAXA,
                                     WORKSHEET,
                                     ARQUIVO,
                                     TRANSAÇÃO,
                                     TSEQ)
select 
                                     CRÉDITO_US,
                                     DÉBITO_US,
                                     CRÉDITO_RS,
                                     DÉBITO_RS,
                                     COMPLEMENTO,
                                     HISTORICO,
                                     DATA,
                                     EMPRESA,
                                     PROCESSO_REF,
                                     SEQ,
                                     TAXA,
                                     WORKSHEET,
                                     ARQUIVO,
                                     TRANSAÇÃO,
                                     TSEQ from PROCESSO_LANÇAMENTO_T ;

insert into BL (
                                     VIAGEM_REF,
                                     SEQ,
                                     BL_NUM,
                                     BL_DATA,
                                     EMB_REF,
                                     MSG)
select 
                                     VIAGEM_REF,
                                     SEQ,
                                     BL_NUM,
                                     BL_DATA,
                                     EMB_REF,
                                     MSG from BL_T ;

insert into EMB_FAMÍLIA (
                                     EMB_REF,
                                     SEQ,
                                     FAMÍLIA)
select 
                                     EMB_REF,
                                     SEQ,
                                     FAMÍLIA from EMB_FAMÍLIA_T ;

insert into EMB_FAMÍLIA_GENÉRICA (
                                     EMB_REF,
                                     SEQ,
                                     FAMÍLIA)
select 
                                     EMB_REF,
                                     SEQ,
                                     FAMÍLIA from EMB_FAMÍLIA_GENÉRICA_T ;

insert into EMB_RE (
                                     EMB_REF,
                                     RE,
                                     EMISSÃO_DATA)
select 
                                     EMB_REF,
                                     RE,
                                     EMISSÃO_DATA from EMB_RE_T ;



insert into BL_CARGA (
                                     PED_REF,
                                     PED_ITEM,
                                     VIAGEM_REF,
                                     BL_SEQ,
                                     FECH_REF,
                                     QTD_PED_UNID,
                                     QTD_VOL,
                                     PESO_LÍQUIDO,
                                     PESO_BRUTO,
                                     EMB_DATA,
                                     EMB_REF,
                                     EMB_SEQ,
                                     FAMÍLIA_GENÉRICA,
                                     FAMÍLIA,
                                     DESCR         ,
                                     EMBALAGEM,
                                     NCM,
                                     NALADI,
                                     EXP_PREÇO_UNIT,
                                     IMP_PREÇO_UNIT,
                                     CALC_EXP_EMB,
                                     CALC_EXP_FOB,
                                     CALC_IMP_EMB,
                                     CALC_IMP_FOB,
                                     NOMINAL_PED_UNID)
select 
                                     PED_REF,
                                     PED_ITEM,
                                     VIAGEM_REF,
                                     BL_SEQ,
                                     FECH_REF,
                                     QTD_PED_UNID,
                                     QTD_VOL,
                                     PESO_LÍQUIDO,
                                     PESO_BRUTO,
                                     EMB_DATA,
                                     EMB_REF,
                                     EMB_SEQ,
                                     FAMÍLIA_GENÉRICA,
                                     FAMÍLIA,
                                     DESCR         ,
                                     EMBALAGEM,
                                     NCM,
                                     NALADI,
                                     EXP_PREÇO_UNIT,
                                     IMP_PREÇO_UNIT,
                                     CALC_EXP_EMB,
                                     CALC_EXP_FOB,
                                     CALC_IMP_EMB,
                                     CALC_IMP_FOB,
                                     NOMINAL_PED_UNID from BL_CARGA_T  ;





