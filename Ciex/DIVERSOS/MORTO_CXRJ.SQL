                        delete from CIA_T;
                        delete from EMB_FAMÍLIA_T;
                        delete from EMB_FAMÍLIA_GENÉRICA_T;
                        delete from EMB_RE_T;
                        delete from BL_T;
                        delete from BL_CARGA_T;
                        delete from PLANILHA_STC_T;
                        delete from MAPA_DE_CONTROLE_T;
                        delete from MAPA_T;
                        delete from ANEXO_T;
                        delete from PLANILHA_DEF_T;
                        delete from CIA_RAMO_ATIVIDADE_T;
                        delete from FRETE_T;
                        delete from LOCAL_RESULT_T;
                        delete from CONFIRM_VENDA_ITEM_T;
                        delete from INCOTERM_LANÇ_T;
                        delete from CIA_CONTATO_T;
                        delete from EMB_SD_T;
                        delete from LOG_IMPORT_T;
                        delete from EMB_MENSAGEM_T;
                        delete from EMB_LANÇ_T;
                        delete from EMB_DOC_REL_T;
                        delete from DIVISÃO_TIPO_REF_T;
                        delete from DIVISÃO_PRODUTO_T;
                        delete from EMB_TOTALIZA_T;
                        delete from PED_RESULT_T;
                        delete from CARTA_FECH_T;
                        delete from PARAM_CSN_T;
                        delete from SUB_CONTA_T;
                        delete from PED_CONTATO_T;
                        delete from RESULT_T;
                        delete from PED_LANÇ_T;
                        delete from RELACIONADA_T;
                        delete from PRODUTO_ESPECIF_T;
                        delete from SYS_DELETE_T;
                        delete from EMB_F_T;
                        delete from RAMO_ATIVIDADE_T;
                        delete from LANÇ_T;
                        delete from TIPO_REF_T;
                        delete from CARTA_T;
                        delete from FECH_CARGA_T;
                        delete from DIVISÃO_T;
                        delete from CONTA_T;
                        delete from ESCRITÓRIO_T;
                        delete from CONFIRM_VENDA_T;
                        delete from DEPTO_T;
                        delete from PED_ITEM_T;
                        delete from COSIPA_NEGOCIAÇÃO_T;
                        delete from FECH_T;
                        delete from DOC_T;
                        delete from EMB_T;
                        delete from PRODUTO_T;
                        delete from EMBALAGEM_T;
                        delete from VIAGEM_ESCALA_T;
                        delete from PED_T;
                        delete from PARAM_T;
                        delete from CIA_T;
                        delete from COND_PAG_T;
                        delete from CARTA_CRÉDITO_T;
                        delete from GRUPO_PRODUTO_T;
                        delete from INCOTERM_T;
                        delete from MODALIDADE_FRETE_T;
                        delete from MOEDA_T;
                        delete from PORTO_T;
                        delete from UNID_QUANTID_T;
                        delete from VIA_TRANSPORTE_T;
                        delete from VIAGEM_T;
                        delete from NAVIO_T;
                        delete from PAÍS_T;
                        delete from IDIOMA_T;
                        COMMIT;

                        set transaction read write;

               insert into CIA_T (
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
                                     LOCAL_RESULT from CIA;

                        insert into IDIOMA_T (
                                     COD,
                                     DESCR)
                        select 
                                     COD,
                                     DESCR from IDIOMA;

                        insert into PAÍS_T (
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
                                     MSG from PAÍS;

                        insert into NAVIO_T (
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
                                     SUMMER_DRAFT from NAVIO;

                        insert into MOEDA_T (
                                     COD,
                                     NOME)
                        select 
                                     COD,
                                     NOME from MOEDA;

                        insert into MODALIDADE_FRETE_T (
                                     COD,
                                     DESCR,
                                     OBS)
                        select 
                                     COD,
                                     DESCR,
                                     OBS from MODALIDADE_FRETE;

                        insert into COND_PAG_T (
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
                                     FIN_COND from COND_PAG;

                        insert into INCOTERM_T (
                                     COD,
                                     DESCR,
                                     OBS)
                        select 
                                     COD,
                                     DESCR,
                                     OBS from INCOTERM;

                        insert into CARTA_CRÉDITO_T (
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
                                     UNID_PESO from CARTA_CRÉDITO;

                        insert into VIAGEM_T (
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
                                     OBS from VIAGEM t where 
                                     NOT EXISTS 
                                     (SELECT VV2.VIAGEM_REF FROM
                                     (SELECT VIAGEM_REF FROM BL_CARGA WHERE EXISTS
                                     (SELECT PP2.PED_REF FROM
                                     (SELECT PD2.PED_REF FROM 
                                     (SELECT PED_REF, MAX(NVL(INV_DATA,SYSDATE)) DATA FROM RESULT GROUP BY PED_REF) PD2
                                     WHERE PD2.DATA >= TO_DATE ('01-01-2003','DD-MM-YYYY'))PP2
                                     WHERE BL_CARGA.PED_REF = PP2.PED_REF) GROUP BY VIAGEM_REF)VV2
                                     WHERE VV2.VIAGEM_REF = t.REF)
                                     AND
                                     EXISTS 
                                     (SELECT VV1.VIAGEM_REF FROM
                                     (SELECT VIAGEM_REF FROM BL_CARGA WHERE EXISTS
                                     (SELECT PP1.PED_REF FROM
                                     (SELECT PD1.PED_REF FROM 
                                     (SELECT PED_REF, MAX(NVL(INV_DATA,SYSDATE)) DATA FROM RESULT GROUP BY PED_REF) PD1
                                     WHERE PD1.DATA < TO_DATE ('01-01-2003','DD-MM-YYYY'))PP1
                                     WHERE BL_CARGA.PED_REF = PP1.PED_REF) GROUP BY VIAGEM_REF)VV1
                                     WHERE VV1.VIAGEM_REF = t.REF);


--movido
                        insert into PED_T (
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
                                     PORTO_DESTINO_CSN from PED t where EXISTS (
					SELECT VV.PED_REF FROM 
					(SELECT BL_CARGA.PED_REF FROM VIAGEM_T, BL_CARGA
					WHERE BL_CARGA.VIAGEM_REF = VIAGEM_T.REF
					GROUP BY BL_CARGA.PED_REF) VV
					WHERE VV.PED_REF = T.REF);


                        insert into VIA_TRANSPORTE_T (
                                     COD,
                                     DESCR,
                                     TIPO)
                        select 
                                     COD,
                                     DESCR,
                                     TIPO from VIA_TRANSPORTE;

                        insert into UNID_QUANTID_T (
                                     COD,
                                     NOME)
                        select 
                                     COD,
                                     NOME from UNID_QUANTID;

                        insert into GRUPO_PRODUTO_T (
                                     COD,
                                     DESCR)
                        select 
                                     COD,
                                     DESCR from GRUPO_PRODUTO;

                        insert into PORTO_T (
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
                                     OBS from PORTO;

                        insert into EMB_T (
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
                                     CALC_PEND from EMB t where 
				     EXISTS(SELECT * FROM  VIAGEM_T cur WHERE T.VIAGEM = CUR.REF);
					

                        insert into PRODUTO_T (
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
                                     MEDIDAS from PRODUTO;

                        insert into VIAGEM_ESCALA_T (
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
                                     OBS from VIAGEM_ESCALA t where EXISTS(
					SELECT VIAGEM_T.REF  FROM VIAGEM_T
					WHERE VIAGEM_T.REF = T.VIAGEM_REF);

                        insert into EMBALAGEM_T (
                                     COD,
                                     DESCR,
                                     OBS)
                        select 
                                     COD,
                                     DESCR,
                                     OBS from EMBALAGEM;

                        insert into DOC_T (
                                     COD,
                                     NOME,
                                     OBJETO_VINCULADO,
                                     FORMULÁRIO_PARAM)
                        select 
                                     COD,
                                     NOME,
                                     OBJETO_VINCULADO,
                                     FORMULÁRIO_PARAM from DOC;

                        insert into PARAM_T (
                                     GRUPO,
                                     PARAM,
                                     QUANDO_TEXTO)
                        select 
                                     GRUPO,
                                     PARAM,
                                     QUANDO_TEXTO from PARAM;


--Feita alteração no pedido


                        insert into DEPTO_T (
                                     COD,
                                     NOME)
                        select 
                                     COD,
                                     NOME from DEPTO;

                        insert into FECH_T (
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
                                     DESPACHANTE from FECH t where 
 				     EXISTS( SELECT VIAGEM_T.REF FROM VIAGEM_T WHERE
						T.VIAGEM_REF = VIAGEM_T.REF);

                        insert into PED_ITEM_T (
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
                                     MARCAÇOES_ADICIONAIS_CSN from PED_ITEM t where exists(select * from PED_T CUR where T.PED_REF = CUR.REF);

                        insert into CONFIRM_VENDA_T (
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
				     VENDEDOR,
                                     EMPRESA_REL,
                                     MOEDA)
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
				     VENDEDOR,
                                     EMPRESA_REL,
                                     MOEDA from CONFIRM_VENDA t where 
				     EXISTS (SELECT PED_T.REF FROM PED_T WHERE  T.PED_REF = PED_T.REF);

                        insert into ESCRITÓRIO_T (
                                     ESCRITÓRIO,
                                     DESCR)
                        select 
                                     ESCRITÓRIO,
                                     DESCR from ESCRITÓRIO;

                        insert into DIVISÃO_T (
                                     ESCRITÓRIO,
                                     DIVISÃO,
                                     DESCR)
                        select 
                                     ESCRITÓRIO,
                                     DIVISÃO,
                                     DESCR from DIVISÃO;


                        insert into FECH_CARGA_T (
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
                                     CANCEL_MOTIVO from FECH_CARGA t where exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF);






                        insert into HIST_PADRAO_T (
                                     CLIENTE,
                                     FORNECEDOR,
                                     GRUPO,
                                     PAÍS_DESTINO)
                        select 
                                     CLIENTE,
                                     FORNECEDOR,
                                     GRUPO,
                                     PAÍS_DESTINO from HIST_PADRAO;

                        insert into FAX_T (
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
                                     CANCEL from FAX t where T.MOMENTO_CRIA <   TO_DATE('01-01-2003','DD-MM-YYYY');

                        insert into CONTA_T (
                                     EMPRESA,
                                     CONTA,
                                     NOME)
                        select 
                                     EMPRESA,
                                     CONTA,
                                     NOME from CONTA;

                        insert into INSTRUÇÃO_PAG_T (
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
                                     COM_CÓPIA from INSTRUÇÃO_PAG t where T.SOLICITAÇÃO_DATA <   TO_DATE('01-01-2003','DD-MM-YYYY');

                        insert into EMB_F_T (
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
                                     OBSERVAÇÃO from EMB_F t where exists(select * from PED_T CUR where T.PED_REF = CUR.REF);

                        insert into TIPO_REF_T (
                                     TIPO,
                                     DESCR,
                                     DEPTO,
                                     ARQUIVO)
                        select 
                                     TIPO,
                                     DESCR,
                                     DEPTO,
                                     ARQUIVO from TIPO_REF;

                        insert into NOTA_DÉBITO_T (
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
                                     EMISSÃO_DATA from NOTA_DÉBITO t where T.DOC_DATA <   TO_DATE('01-01-2003','DD-MM-YYYY');

                        insert into LANÇ_T (
                                     LANÇ,
                                     NOME)
                        select 
                                     LANÇ,
                                     NOME from LANÇ;

                        insert into RAMO_ATIVIDADE_T (
                                     COD,
                                     NOME)
                        select 
                                     COD,
                                     NOME from RAMO_ATIVIDADE;

                        insert into PROG_T (
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
                                     OBS from PROG t where exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF);

                        insert into NOTA_CRÉDITO_T (
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
                                     EMISSÃO_DATA from NOTA_CRÉDITO t where T.DOC_DATA <   TO_DATE('01-01-2003','DD-MM-YYYY');

                        insert into CARTA_T (
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
                                     SUPERVISOR from CARTA t where 
				     EXISTS( 
				SELECT CARTA_FECH.CARTA_REF, CARTA_FECH.FECH_REF FROM CARTA_FECH, FECH_T
				WHERE CARTA_FECH.FECH_REF = FECH_T.REF AND
				CARTA_FECH.CARTA_REF = T.REF);


                        insert into DIVISÃO_PRODUTO_T (
                                     ESCRITÓRIO,
                                     DIVISÃO,
                                     PROD)
                        select 
                                     ESCRITÓRIO,
                                     DIVISÃO,
                                     PROD from DIVISÃO_PRODUTO;

                        insert into DIVISÃO_TIPO_REF_T (
                                     ESCRITÓRIO,
                                     DIVISÃO,
                                     TIPO_REF)
                        select 
                                     ESCRITÓRIO,
                                     DIVISÃO,
                                     TIPO_REF from DIVISÃO_TIPO_REF;

                        insert into FATURA_T (
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
                                     SUPERVISOR from FATURA t where 
					EXISTS ( SELECT FECH_T.REF FROM FECH_T
					WHERE T.FECH_REF = FECH_T.REF);

                        insert into EMB_DOC_DESTINO_T (
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
                                     CÓPIA_VISADA_NUM from EMB_DOC_DESTINO;

                        insert into EMB_MENSAGEM_T (
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
                                     DOC_SAQUE_JUROS from EMB_MENSAGEM t where exists(select * from EMB_T CUR where T.EMB_REF = CUR.REF);

                        insert into EMPRESA_CONTA_T (
                                     EMPRESA)
                        select 
                                     EMPRESA from EMPRESA_CONTA;

                        insert into CONTA_CORRENTE_T (
                                     COD,
                                     CONTA_CORRENTE)
                        select 
                                     COD,
                                     CONTA_CORRENTE from CONTA_CORRENTE;

                        insert into EMB_LANÇ_T (
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
                                     IMP_CALC from EMB_LANÇ t where exists(select * from EMB_T CUR where T.EMB_REF = CUR.REF);

                        insert into EMPRESA_T (
                                     EMPRESA,
                                     RELACIONADA)
                        select 
                                     EMPRESA,
                                     RELACIONADA from EMPRESA;

                        insert into FAX_CHAVE_T (
                                     FAX_REF,
                                     CHAVE)
                        select 
                                     FAX_REF,
                                     CHAVE from FAX_CHAVE t where exists(select * from FAX_T CUR where T.FAX_REF = CUR.REF);

                        insert into EMB_SD_T (
                                     EMB_REF,
                                     SD,
                                     AVERBAÇÃO_DATA)
                        select 
                                     EMB_REF,
                                     SD,
                                     AVERBAÇÃO_DATA from EMB_SD t where exists(select * from EMB_T CUR where T.EMB_REF = CUR.REF);

                        insert into EMB_TOTALIZA_T (
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
                                     IMP_CALC from EMB_TOTALIZA t where exists(select * from EMB_T CUR where T.EMB_REF = CUR.REF);

                        insert into EMB_DOC_REL_T (
                                     EMB_REF,
                                     DOC,
                                     EMB_REL)
                        select 
                                     EMB_REF,
                                     DOC,
                                     EMB_REL from EMB_DOC_REL t where exists(select * from EMB_T CUR where T.EMB_REL = CUR.REF);

                        insert into NOTA_DÉBITO_RECEB_T (
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
                                     OBS from NOTA_DÉBITO_RECEB t where exists(select * from NOTA_DÉBITO_T CUR where T.NOTA_DÉBITO_REF = CUR.REF);

                        insert into SUB_CONTA_T (
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
                                     REPORT from SUB_CONTA;

                        insert into RESULT_T (
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
                                     OBSERVAÇÃO from RESULT t where exists(select * from EMB_F_T CUR where T.PED_REF = CUR.PED_REF AND T.EMB_SEQ = CUR.SEQ);

                        insert into RELACIONADA_T (
                                     REF)
                        select 
                                     REF from RELACIONADA;

                        insert into PROG_CARGA_T (
                                     FECH_REF,
                                     POSICIONAMENTO_DATA,
                                     PED_REF,
                                     PED_ITEM)
                        select 
                                     FECH_REF,
                                     POSICIONAMENTO_DATA,
                                     PED_REF,
                                     PED_ITEM from PROG_CARGA t where exists(select * from FECH_CARGA_T CUR where T.FECH_REF = CUR.FECH_REF AND T.PED_REF = CUR.PED_REF AND T.PED_ITEM = CUR.PED_ITEM) or exists(select * from PROG_T CUR where T.FECH_REF = CUR.FECH_REF AND T.POSICIONAMENTO_DATA = CUR.POSICIONAMENTO_DATA);

                        insert into PRODUTO_ESPECIF_T (
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
                                     DESCR_NALADI from PRODUTO_ESPECIF;

                        insert into CARTA_FECH_T (
                                     CARTA_REF,
                                     FECH_REF)
                        select 
                                     CARTA_REF,
                                     FECH_REF from CARTA_FECH t where exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF);

                        insert into CIA_CONTATO_T (
                                     CIA_COD,
                                     CONTATO_NOME,
                                     TELEFONE,
                                     FUNÇÃO)
                        select 
                                     CIA_COD,
                                     CONTATO_NOME,
                                     TELEFONE,
                                     FUNÇÃO from CIA_CONTATO;

                        insert into PED_RESULT_T (
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
                                     OBS from PED_RESULT t where exists(select * from PED_T CUR where T.PED_REF = CUR.REF);

                        insert into INSTRUÇÃO_PAG_FECH_T (
                                     INSTRUÇÃO_PAG_REF,
                                     FECH_REF)
                        select 
                                     INSTRUÇÃO_PAG_REF,
                                     FECH_REF from INSTRUÇÃO_PAG_FECH t where exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF) or exists(select * from INSTRUÇÃO_PAG_T CUR where T.INSTRUÇÃO_PAG_REF = CUR.REF);

                        insert into PED_CONTATO_T (
                                     PED_REF,
                                     CIA_COD,
                                     CONTATO_NOME)
                        select 
                                     PED_REF,
                                     CIA_COD,
                                     CONTATO_NOME from PED_CONTATO t where exists(select * from PED_T CUR where T.PED_REF = CUR.REF);

                        insert into FAX_DESTINO_T (
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
                                     OBS from FAX_DESTINO t where exists(select * from FAX_T CUR where T.FAX_REF = CUR.REF);

                        insert into NOTA_DÉBITO_FECH_T (
                                     NOTA_DÉBITO_REF,
                                     FECH_REF)
                        select 
                                     NOTA_DÉBITO_REF,
                                     FECH_REF from NOTA_DÉBITO_FECH t where exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF) or exists(select * from NOTA_DÉBITO_T CUR where T.NOTA_DÉBITO_REF = CUR.REF);

                        insert into NOTA_CRÉDITO_PAG_T (
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
                                     OBS from NOTA_CRÉDITO_PAG t where exists(select * from NOTA_CRÉDITO_T CUR where T.NOTA_CRÉDITO_REF = CUR.REF);

                        insert into NOTA_CRÉDITO_FECH_T (
                                     NOTA_CRÉDITO_REF,
                                     FECH_REF)
                        select 
                                     NOTA_CRÉDITO_REF,
                                     FECH_REF from NOTA_CRÉDITO_FECH t where exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF) or exists(select * from NOTA_CRÉDITO_T CUR where T.NOTA_CRÉDITO_REF = CUR.REF);

                        insert into CIA_RAMO_ATIVIDADE_T (
                                     CIA_COD,
                                     RAMO_ATIVIDADE)
                        select 
                                     CIA_COD,
                                     RAMO_ATIVIDADE from CIA_RAMO_ATIVIDADE;

                        insert into LOCAL_RESULT_T (
                                     COD,
                                     DESCR)
                        select 
                                     COD,
                                     DESCR from LOCAL_RESULT;

                        insert into INCOTERM_LANÇ_T (
                                     INCOTERM,
                                     LANÇ)
                        select 
                                     INCOTERM,
                                     LANÇ from INCOTERM_LANÇ;

                        insert into CONFIRM_VENDA_ITEM_T (
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
                                     PREÇO_C from CONFIRM_VENDA_ITEM t where exists(select * from CONFIRM_VENDA_T CUR where T.CONFIRM_VENDA_REF = CUR.REF AND T.SEQ = CUR.SEQ);

                        insert into FECH_SUBSTITUÍDO_T (
                                     SUBSTITUÍDO,
                                     SUBSTITUTO,
                                     SUBSTITUIÇÃO_DATA)
                        select 
                                     SUBSTITUÍDO,
                                     SUBSTITUTO,
                                     SUBSTITUIÇÃO_DATA from FECH_SUBSTITUÍDO t where exists(select * from FECH_T CUR where T.SUBSTITUTO = CUR.REF) or exists(select * from FECH_T CUR where T.SUBSTITUÍDO = CUR.REF);

                        insert into FECH_CONTATO_T (
                                     FECH_REF,
                                     CIA_COD,
                                     CONTATO_NOME)
                        select 
                                     FECH_REF,
                                     CIA_COD,
                                     CONTATO_NOME from FECH_CONTATO t where exists(select * from FECH_T CUR where T.FECH_REF = CUR.REF);

                        insert into PED_LANÇ_T (
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
                                     OBS from PED_LANÇ t where exists(select * from PED_T CUR where T.PED_REF = CUR.REF);

                        insert into ANEXO_T (
                                     NOME,
                                     SUB_CONTA,
                                     SUB_CONTA_REL)
                        select 
                                     NOME,
                                     SUB_CONTA,
                                     SUB_CONTA_REL from ANEXO;

                        insert into HIST_PADRAO_LANÇAMENTO_T (
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
                                     RELACIONADA from HIST_PADRAO_LANÇAMENTO;

                        insert into MAPA_T (
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
                                     ALINHAMENTO from MAPA;

                        insert into MAPA_DE_CONTROLE_T (
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
                                     EEXCEL from MAPA_DE_CONTROLE t where exists(select * from PED_T CUR where T.PED_REF = CUR.REF);

                        insert into PLANILHA_DEF_T (
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
                                     CRÉDITO from PLANILHA_DEF;

                        insert into PLANILHA_STC_T (
                                     WORKSHEET,
                                     EMPRESA,
                                     ARQUIVO,
                                     MAPA)
                        select 
                                     WORKSHEET,
                                     EMPRESA,
                                     ARQUIVO,
                                     MAPA from PLANILHA_STC;

                        insert into PROCESSO_T (
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
                                     OBS from PROCESSO t where exists(select * from MAPA_DE_CONTROLE_T CUR where T.REF = CUR.FINA_REF);


                        insert into BL_T (
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
                                     MSG from BL t where 
  					EXISTS(
					SELECT * FROM VIAGEM_T WHERE VIAGEM_T.REF = T.VIAGEM_REF );


                        insert into BL_CARGA_T (
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
                                     NOMINAL_PED_UNID from BL_CARGA t where  exists(select * from BL_T CUR where T.VIAGEM_REF = CUR.VIAGEM_REF AND T.BL_SEQ = CUR.SEQ);

                        insert into HISTORICO_T (
                                     NOME)
                        select 
                                     NOME from HISTORICO;

                        insert into PROCESSO_LANÇAMENTO_T (
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
                                     TSEQ from PROCESSO_LANÇAMENTO t where exists(select * from PROCESSO_T CUR where T.EMPRESA = CUR.EMPRESA AND T.PROCESSO_REF = CUR.REF);

                        insert into EMB_FAMÍLIA_T (
                                     EMB_REF,
                                     SEQ,
                                     FAMÍLIA)
                        select 
                                     EMB_REF,
                                     SEQ,
                                     FAMÍLIA from EMB_FAMÍLIA t where exists(select * from EMB_T CUR where T.EMB_REF = CUR.REF);

                        insert into EMB_FAMÍLIA_GENÉRICA_T (
                                     EMB_REF,
                                     SEQ,
                                     FAMÍLIA)
                        select 
                                     EMB_REF,
                                     SEQ,
                                     FAMÍLIA from EMB_FAMÍLIA_GENÉRICA t where exists(select * from EMB_T CUR where T.EMB_REF = CUR.REF);

                        insert into EMB_RE_T (
                                     EMB_REF,
                                     RE,
                                     EMISSÃO_DATA)
                        select 
                                     EMB_REF,
                                     RE,
                                     EMISSÃO_DATA from EMB_RE t where exists(select * from EMB_T CUR where T.EMB_REF = CUR.REF);







--compensações
--insere pedidos extras para a fech carga

				
                        insert into PED_ITEM_T (
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
				     SYS_STATUS,
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
				     'N' STATUS,
                                     MARCAÇOES_ADICIONAIS_CSN from PED_ITEM t where 
				     exists(select * from FECH_CARGA_T CUR where T.PED_REF = CUR.PED_REF AND  T.ITEM = CUR.PED_ITEM)
				     and not exists (select * from ped_item_t cur2 where cur2.ped_ref = t.ped_ref and cur2.item = t.item) ;


-- fim da inserção extra em ped _item

--inserção extra em ped

                        insert into PED_T (
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
				     SYS_STATUS,
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
				     'N' STATUS,
                                     OV,
                                     PORTO_DESTINO_CSN from PED t where 
					EXISTS (select * from fech_carga_t cur where t.ref = cur.ped_ref)
				        and not exists (select * from ped_t cur2 where t.ref = cur2.ref) ;
--fim da inserção extra em ped



--compensação embarque

                        insert into EMB_T (
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
			 	     SYS_STATUS,
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
				     'N' STATUS,
                                     CALC_PEND from EMB t where 
				     NOT EXISTS(SELECT * FROM  EMB_T cur WHERE T.REF = CUR.REF)
				     AND 
				     EXISTS(SELECT * FROM BL_T CUR2 WHERE CUR2.EMB_REF = T.REF );

--fim da compensação do embarque
                        insert into EMB_T (
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
				     SYS_STATUS,
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
				     'N' STATUS,
                                     CALC_PEND from EMB t where 
				     NOT EXISTS(SELECT * FROM  EMB_T cur WHERE T.REF = CUR.REF)
				     AND 
				     EXISTS(SELECT * FROM BL_CARGA_T CUR2 WHERE CUR2.EMB_REF = T.REF );

                        insert into EMB_FAMÍLIA_T (
                                     EMB_REF,
                                     SEQ,
				     SYS_STATUS,
                                     FAMÍLIA)
                        select 
                                     EMB_REF,
                                     SEQ,
				     'N' STATUS,
                                     FAMÍLIA from EMB_FAMÍLIA t where  not exists(select * from EMB_FAMÍLIA_T CUR where T.EMB_REF = CUR.EMB_REF) and
					exists (select * from emb_t where emb_t.ref = t.emb_ref);



                        insert into EMB_FAMÍLIA_GENÉRICA_T (
                                     EMB_REF,
                                     SEQ,
				     SYS_STATUS,
                                     FAMÍLIA)
                        select 
                                     EMB_REF,
                                     SEQ,
				     'N' STATUS,
                                     FAMÍLIA from EMB_FAMÍLIA_GENÉRICA t where  not exists(select * from EMB_FAMÍLIA_GENÉRICA_T CUR where T.EMB_REF = CUR.EMB_REF) and
					exists (select * from emb_t where emb_t.ref = t.emb_ref);


                        insert into VIAGEM_T (
                                     REF,
                                     NAVIO,
                                     NAVIO_ÚLTIMO,
				     SYS_STATUS,
                                     CORRENTE,
                                     OBS)
                        select
                                     REF,
                                     NAVIO,
                                     NAVIO_ÚLTIMO,
                                     'N' STATUS,
			             CORRENTE,
                                     OBS from VIAGEM t where
					not exists(select * from viagem_t where viagem_t.ref = t.ref) and
					exists
					(
					select * from (select emb_t.viagem from emb_t group by emb_t.viagem) e
					where t.ref = e.viagem
					);
					


                        COMMIT;
