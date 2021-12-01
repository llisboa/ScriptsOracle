                        set transaction read write;

                        delete from EMB_RE cur where
                        exists(select * from EMB_RE_t t where T.EMB_REF = cur.EMB_REF  AND T.RE = cur.RE AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from PROCESSO_LANÇAMENTO cur where
                        exists(select * from PROCESSO_LANÇAMENTO_t t where T.EMPRESA = cur.EMPRESA  AND T.PROCESSO_REF = cur.PROCESSO_REF  AND T.SEQ = cur.SEQ AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from BL_CARGA cur where
                        exists(select * from BL_CARGA_t t where T.PED_REF = cur.PED_REF  AND T.PED_ITEM = cur.PED_ITEM  AND T.VIAGEM_REF = cur.VIAGEM_REF  AND T.BL_SEQ = cur.BL_SEQ AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from BL cur where
                        exists(select * from BL_t t where T.VIAGEM_REF = cur.VIAGEM_REF  AND T.SEQ = cur.SEQ AND NVL(SYS_STATUS,'X') <> 'N' );

                        delete from PROCESSO cur where
                        exists(select * from PROCESSO_t t where T.EMPRESA = cur.EMPRESA  AND T.REF = cur.REF AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from EMB_FAMÍLIA cur where
                        exists(select * from EMB_FAMÍLIA_t t where T.EMB_REF = cur.EMB_REF  AND T.SEQ = cur.SEQ )
			and not exists(select * from bl_carga c where cur.emb_ref = c.emb_ref and cur.seq = c.família);

                        delete from EMB_FAMÍLIA_GENÉRICA cur where
                        exists(select * from EMB_FAMÍLIA_GENÉRICA_t t where T.EMB_REF = cur.EMB_REF  AND T.SEQ = cur.SEQ)
			and not exists(select * from bl_carga c where cur.emb_ref = c.emb_ref and cur.seq = c.família_genérica);

                        delete from MAPA_DE_CONTROLE cur where
                        exists(select * from MAPA_DE_CONTROLE_t t where T.PED_REF = cur.PED_REF  AND T.SEQ = cur.SEQ AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from EMB_MENSAGEM cur where
                        exists(select * from EMB_MENSAGEM_t t where T.EMB_REF = cur.EMB_REF  AND T.SEQ = cur.SEQ AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from RESULT cur where
                        exists(select * from RESULT_t t where T.PED_REF = cur.PED_REF  AND T.EMB_SEQ = cur.EMB_SEQ  AND T.SEQ = cur.SEQ AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from FECH_SUBSTITUÍDO cur where
                        exists(select * from FECH_SUBSTITUÍDO_t t where T.SUBSTITUÍDO = cur.SUBSTITUÍDO  AND T.SUBSTITUTO = cur.SUBSTITUTO AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from FECH_CONTATO cur where
                        exists(select * from FECH_CONTATO_t t where T.FECH_REF = cur.FECH_REF  AND T.CIA_COD = cur.CIA_COD  AND T.CONTATO_NOME = cur.CONTATO_NOME AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from FAX_CHAVE cur where
                        exists(select * from FAX_CHAVE_t t where T.FAX_REF = cur.FAX_REF  AND T.CHAVE = cur.CHAVE AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from FATURA cur where
                        exists(select * from FATURA_t t where T.REF = cur.REF AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from EMB_TOTALIZA cur where
                        exists(select * from EMB_TOTALIZA_t t where T.EMB_REF = cur.EMB_REF  AND T.SEQ = cur.SEQ AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from FAX_DESTINO cur where
                        exists(select * from FAX_DESTINO_t t where T.FAX_REF = cur.FAX_REF  AND T.SEQ = cur.SEQ AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from EMB_LANÇ cur where
                        exists(select * from EMB_LANÇ_t t where T.EMB_REF = cur.EMB_REF  AND T.SEQ = cur.SEQ AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from EMB_DOC_REL cur where
                        exists(select * from EMB_DOC_REL_t t where T.EMB_REF = cur.EMB_REF  AND T.DOC = cur.DOC  AND T.EMB_REL = cur.EMB_REL AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from EMB_DOC_DESTINO cur where
                        exists(select * from EMB_DOC_DESTINO_t t where T.EMB_REF = cur.EMB_REF  AND T.SEQ = cur.SEQ  AND T.CIA = cur.CIA AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from CONFIRM_VENDA_ITEM cur where
                        exists(select * from CONFIRM_VENDA_ITEM_t t where T.CONFIRM_VENDA_REF = cur.CONFIRM_VENDA_REF  AND T.SEQ = cur.SEQ  AND T.ITEM = cur.ITEM AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from CARTA_FECH cur where
                        exists(select * from CARTA_FECH_t t where T.CARTA_REF = cur.CARTA_REF  AND T.FECH_REF = cur.FECH_REF AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from EMB_SD cur where
                        exists(select * from EMB_SD_t t where T.EMB_REF = cur.EMB_REF  AND T.SD = cur.SD AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from PROG_CARGA cur where
                        exists(select * from PROG_CARGA_t t where T.FECH_REF = cur.FECH_REF  AND T.POSICIONAMENTO_DATA = cur.POSICIONAMENTO_DATA  AND T.PED_REF = cur.PED_REF  AND T.PED_ITEM = cur.PED_ITEM AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from NOTA_CRÉDITO_PAG cur where
                        exists(select * from NOTA_CRÉDITO_PAG_t t where T.NOTA_CRÉDITO_REF = cur.NOTA_CRÉDITO_REF  AND T.SEQ = cur.SEQ AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from NOTA_DÉBITO_FECH cur where
                        exists(select * from NOTA_DÉBITO_FECH_t t where T.NOTA_DÉBITO_REF = cur.NOTA_DÉBITO_REF  AND T.FECH_REF = cur.FECH_REF AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from INSTRUÇÃO_PAG_FECH cur where
                        exists(select * from INSTRUÇÃO_PAG_FECH_t t where T.INSTRUÇÃO_PAG_REF = cur.INSTRUÇÃO_PAG_REF  AND T.FECH_REF = cur.FECH_REF AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from NOTA_CRÉDITO_FECH cur where
                        exists(select * from NOTA_CRÉDITO_FECH_t t where T.NOTA_CRÉDITO_REF = cur.NOTA_CRÉDITO_REF  AND T.FECH_REF = cur.FECH_REF AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from PED_CONTATO cur where
                        exists(select * from PED_CONTATO_t t where T.PED_REF = cur.PED_REF  AND T.CIA_COD = cur.CIA_COD  AND T.CONTATO_NOME = cur.CONTATO_NOME AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from NOTA_DÉBITO_RECEB cur where
                        exists(select * from NOTA_DÉBITO_RECEB_t t where T.NOTA_DÉBITO_REF = cur.NOTA_DÉBITO_REF  AND T.SEQ = cur.SEQ AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from PED_LANÇ cur where
                        exists(select * from PED_LANÇ_t t where T.PED_REF = cur.PED_REF  AND T.SEQ = cur.SEQ AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from PED_RESULT cur where
                        exists(select * from PED_RESULT_t t where T.PED_REF = cur.PED_REF  AND T.SEQ = cur.SEQ AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from EMB_F cur where
                        exists(select * from EMB_F_t t where T.PED_REF = cur.PED_REF  AND T.SEQ = cur.SEQ AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from PROG cur where
                        exists(select * from PROG_t t where T.FECH_REF = cur.FECH_REF  AND T.POSICIONAMENTO_DATA = cur.POSICIONAMENTO_DATA AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from NOTA_DÉBITO cur where
                        exists(select * from NOTA_DÉBITO_t t where T.REF = cur.REF AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from CARTA cur where
                        exists(select * from CARTA_t t where T.REF = cur.REF AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from FAX cur where
                        exists(select * from FAX_t t where T.REF = cur.REF AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from INSTRUÇÃO_PAG cur where
                        exists(select * from INSTRUÇÃO_PAG_t t where T.REF = cur.REF AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from FECH_CARGA cur where
                        exists(select * from FECH_CARGA_t t where T.FECH_REF = cur.FECH_REF  AND T.PED_REF = cur.PED_REF  AND T.PED_ITEM = cur.PED_ITEM AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from NOTA_CRÉDITO cur where
                        exists(select * from NOTA_CRÉDITO_t t where T.REF = cur.REF AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from CONFIRM_VENDA cur where
                        exists(select * from CONFIRM_VENDA_t t where T.REF = cur.REF  AND T.SEQ = cur.SEQ AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from FECH cur where
                        exists(select * from FECH_t t where T.REF = cur.REF AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from PED_ITEM cur where
                        exists(select * from PED_ITEM_t t where T.PED_REF = cur.PED_REF  AND T.ITEM = cur.ITEM AND NVL(SYS_STATUS,'X') <> 'N' )
			and not exists (select * from bl_carga t where cur.ped_ref = t.ped_ref)
			and not exists (select * from fech_carga t where cur.ped_ref = t.ped_ref);


                        delete from VIAGEM_ESCALA cur where
                        exists(select * from VIAGEM_ESCALA_t t where T.VIAGEM_REF = cur.VIAGEM_REF  AND T.ESCALA = cur.ESCALA AND NVL(SYS_STATUS,'X') <> 'N' );


                        delete from PED cur where
                        exists(select * from PED_t t where T.REF = cur.REF AND NVL(SYS_STATUS,'X') <> 'N' )
			and not exists (select * from bl_carga t where cur.ref = t.ped_ref)
			and not exists (select * from mapa_de_controle t where cur.ref = t.ped_ref)
			and not exists (select * from result t where cur.ref = t.ped_ref)
			and not exists (select * from ped_lanç t where cur.ref = t.ped_ref)
			and not exists (select * from bl_carga t where cur.ref = t.ped_ref)
			and not exists (select * from ped_contato t where cur.ref = t.ped_ref)
			and not exists (select * from emb_f t where cur.ref = t.ped_ref)
			and not exists (select * from confirm_venda t where cur.ref = t.ped_ref)
			and not exists (select * from ped_item t where cur.ref = t.ped_ref)
			;


                        delete from EMB cur where
			not exists (select * from bl where bl.emb_ref = cur.ref) 
			and not exists (select * from bl_carga where bl_carga.emb_ref = cur.ref) 
                        and exists(select * from EMB_t t where T.REF = cur.REF);


                        delete from VIAGEM cur where
                        exists(select * from VIAGEM_t t where T.REF = cur.REF )
                        and not exists(select * from emb t2 where T2.viagem = cur.REF)
                        and not exists(select * from bl t3 where T3.viagem_ref = cur.REF)
                        and not exists(select * from viagem_escala t5 where T5.viagem_ref = cur.REF)
                        and not exists(select * from bl_carga t4 where T4.viagem_ref = cur.REF);

