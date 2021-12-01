-------------------------------------------------------------------------------------
-- COMPARAÇÃO DO CXRJ COM O CXSP
-------------------------------------------------------------------------------------

create or replace package dbms_compara_CXRJ_CXSP is
        procedure COMPARA;
        function momento(cria in date, atualiza in date) return date;
        function maisatual(cria1 in date, atualiza1 in date, cria2 in date, atualiza2 in date) return varchar2;

        PRAGMA RESTRICT_REFERENCES(momento, WNDS, WNPS);
        PRAGMA RESTRICT_REFERENCES(maisatual, WNDS, WNPS);
end;
/

create or replace package body dbms_compara_CXRJ_CXSP is



function momento(cria in date, atualiza in date) return date is
begin
        if cria is null then
                return atualiza;
        elsif atualiza is null then
                return cria;
        else
                if atualiza >= cria then
                        return atualiza;
                else
                        return cria;
                end if;
        end if;
end;


function maisatual(cria1 in date, atualiza1 in date, cria2 in date, atualiza2 in date) return varchar2 is
begin
        if momento(cria1, atualiza1) > momento(cria2, atualiza2) then
                return 'mais novo CXRJ';
        elsif momento(cria1, atualiza1) < momento(cria2, atualiza2) then
                return 'mais novo CXSP';
        else
                return 'mesma data';
        end if;
end;


procedure COMPARA is
reglog utl_file.file_type;
prim boolean;

begin
        begin
                reglog := utl_file.fopen('D:\ORACLE\PUBLIC', 'RESULT_CXRJ_CXSP.TXT', 'w');
        exception
                when others then
                        raise_application_error ( -20000, 'erro ao tentar abrir o arquivo de resultado -> ' || SQLERRM);
        end;

        -- LOCAL_RESULT QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.LOCAL_RESULT RJ, CXSP.LOCAL_RESULT@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> LOCAL_RESULT QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif LOCAL_RESULT que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- LOCAL_RESULT QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.LOCAL_RESULT@CXSP REL, CXRJ.LOCAL_RESULT RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> LOCAL_RESULT QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif LOCAL_RESULT que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- LOCAL_RESULT QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.DESCR, REL.DESCR, '', 'DESCR.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.LOCAL_RESULT RJ, CXSP.LOCAL_RESULT@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.DESCR,null,'n',RJ.DESCR) <> decode(REL.DESCR,null,'n',REL.DESCR) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode 
                (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> LOCAL_RESULT QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif LOCAL_RESULT que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- COND_PAG QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.COND_PAG RJ, CXSP.COND_PAG@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> COND_PAG QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif COND_PAG que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- COND_PAG QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.COND_PAG@CXSP REL, CXRJ.COND_PAG RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> COND_PAG QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif COND_PAG que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- COND_PAG QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.DESCR, REL.DESCR, '', 'DESCR.') || decode(RJ.PERÍODO, REL.PERÍODO, '', 'PERÍODO.') || decode(RJ.OBS, REL.OBS, '', 'OBS.') || decode(RJ.FIN_COND, REL.FIN_COND, '', 'FIN_COND.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.COND_PAG RJ, CXSP.COND_PAG@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.DESCR,null,'n',RJ.DESCR) <> decode(REL.DESCR,null,'n',REL.DESCR) OR decode (RJ.PERÍODO,null,'n',RJ.PERÍODO) <> decode(REL.PERÍODO,null,'n',REL.PERÍODO) OR decode (RJ.OBS,null,'n',RJ.OBS) <> decode(REL.OBS,null,'n',REL.OBS) OR decode (RJ.FIN_COND,null,'n',RJ.FIN_COND) <> decode(REL.FIN_COND,null,'n',REL.FIN_COND) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode 
                (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> COND_PAG QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif COND_PAG que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- COSIPA_NEGOCIAÇÃO QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.REF chk from CXRJ.COSIPA_NEGOCIAÇÃO RJ, CXSP.COSIPA_NEGOCIAÇÃO@CXSP REL where RJ.REF LIKE 'BH%' and RJ.REF = REL.REF (+) and REL.REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> COSIPA_NEGOCIAÇÃO QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif COSIPA_NEGOCIAÇÃO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- COSIPA_NEGOCIAÇÃO QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.REF chk from CXSP.COSIPA_NEGOCIAÇÃO@CXSP REL, CXRJ.COSIPA_NEGOCIAÇÃO RJ where REL.REF = RJ.REF (+) and RJ.REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> COSIPA_NEGOCIAÇÃO QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif COSIPA_NEGOCIAÇÃO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- COSIPA_NEGOCIAÇÃO QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.REF || ' -> ' || decode(RJ.REF_EXT, REL.REF_EXT, '', 'REF_EXT.') || decode(RJ.DATA_ORD, REL.DATA_ORD, '', 'DATA_ORD.') || decode(RJ.ALTERA, REL.ALTERA, '', 'ALTERA.') || decode(RJ.MÊS_NEG, REL.MÊS_NEG, '', 'MÊS_NEG.') || decode(RJ.MÊS_EMB, REL.MÊS_EMB, '', 'MÊS_EMB.') || decode(RJ.AGENTE, REL.AGENTE, '', 'AGENTE.') || decode(RJ.PRODUTO, REL.PRODUTO, '', 'PRODUTO.') || decode(RJ.TON, REL.TON, '', 'TON.') || decode(RJ.PAÍS_DESTINO, REL.PAÍS_DESTINO, '', 'PAÍS_DESTINO.') || decode(RJ.PORTO_DESTINO, REL.PORTO_DESTINO, '', 'PORTO_DESTINO.') || decode(RJ.IMP, REL.IMP, '', 'IMP.') || decode(RJ.OUTRO_DOC, REL.OUTRO_DOC, '', 'OUTRO_DOC.') || decode(RJ.PEÇAS, REL.PEÇAS, '', 'PEÇAS.') || decode(RJ.TRAT_TÉRMICO, REL.TRAT_TÉRMICO, '', 'TRAT_TÉRMICO.') || decode(RJ.TOLER_PROD_LOT_MAX, REL.TOLER_PROD_LOT_MAX, '', 'TOLER_PROD_LOT_MAX.') || decode(RJ.TOLER_PROD_LOT_MIN, REL.TOLER_PROD_LOT_MIN, '', 'TOLER_PROD_LOT_MIN.') || decode(RJ.COND_PAG, REL.COND_PAG, '', 'COND_PAG.') || decode(RJ.TERMO_ENTREGA, REL.TERMO_ENTREGA, '', 'TERMO_ENTREGA.') || decode(RJ.PREÇO, REL.PREÇO, '', 'PREÇO.') || decode(RJ.COMISS_AGENTE, REL.COMISS_AGENTE, '', 'COMISS_AGENTE.') || decode(RJ.OBS_GERAL, REL.OBS_GERAL, '', 'OBS_GERAL.') || decode(RJ.INSP_CLASS, REL.INSP_CLASS, '', 'INSP_CLASS.') || decode(RJ.FATURA_LÂMINA, 
                REL.FATURA_LÂMINA, '', 'FATURA_LÂMINA.') || decode(RJ.FATURA_OUTRO, REL.FATURA_OUTRO, '', 'FATURA_OUTRO.') || decode(RJ.EXTERNAL_SURVEY_TYPE, REL.EXTERNAL_SURVEY_TYPE, '', 'EXTERNAL_SURVEY_TYPE.') || decode(RJ.EXTERNAL_SURVEYOR, REL.EXTERNAL_SURVEYOR, '', 'EXTERNAL_SURVEYOR.') || decode(RJ.SURVEY_SIGN_CERTIF, REL.SURVEY_SIGN_CERTIF, '', 'SURVEY_SIGN_CERTIF.') || decode(RJ.CLASS_ORG, REL.CLASS_ORG, '', 'CLASS_ORG.') || decode(RJ.END_USER, REL.END_USER, '', 'END_USER.') || decode(RJ.HRP, REL.HRP, '', 'HRP.') || decode(RJ.HRC, REL.HRC, '', 'HRC.') || decode(RJ.CRC, REL.CRC, '', 'CRC.') || decode(RJ.PREDAYS, REL.PREDAYS, '', 'PREDAYS.') || decode(RJ.POSDAYS, REL.POSDAYS, '', 'POSDAYS.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.COSIPA_NEGOCIAÇÃO RJ, CXSP.COSIPA_NEGOCIAÇÃO@CXSP REL where RJ.REF LIKE 'BH%' and RJ.REF = REL.REF and (decode (RJ.REF_EXT,null,'n',RJ.REF_EXT) <> decode(REL.REF_EXT,null,'n',REL.REF_EXT) OR 
                decode (RJ.DATA_ORD,null,'n',RJ.DATA_ORD) <> decode(REL.DATA_ORD,null,'n',REL.DATA_ORD) OR decode (RJ.ALTERA,null,'n',RJ.ALTERA) <> decode(REL.ALTERA,null,'n',REL.ALTERA) OR decode (RJ.MÊS_NEG,null,'n',RJ.MÊS_NEG) <> decode(REL.MÊS_NEG,null,'n',REL.MÊS_NEG) OR decode (RJ.MÊS_EMB,null,'n',RJ.MÊS_EMB) <> decode(REL.MÊS_EMB,null,'n',REL.MÊS_EMB) OR decode (RJ.AGENTE,null,'n',RJ.AGENTE) <> decode(REL.AGENTE,null,'n',REL.AGENTE) OR decode (RJ.PRODUTO,null,'n',RJ.PRODUTO) <> decode(REL.PRODUTO,null,'n',REL.PRODUTO) OR decode (RJ.TON,null,'n',RJ.TON) <> decode(REL.TON,null,'n',REL.TON) OR decode (RJ.PAÍS_DESTINO,null,'n',RJ.PAÍS_DESTINO) <> decode(REL.PAÍS_DESTINO,null,'n',REL.PAÍS_DESTINO) OR decode (RJ.PORTO_DESTINO,null,'n',RJ.PORTO_DESTINO) <> decode(REL.PORTO_DESTINO,null,'n',REL.PORTO_DESTINO) OR decode (RJ.IMP,null,'n',RJ.IMP) <> decode(REL.IMP,null,'n',REL.IMP) OR decode (RJ.OUTRO_DOC,null,'n',RJ.OUTRO_DOC) <> decode(REL.OUTRO_DOC,null,'n',REL.OUTRO_DOC) OR decode (RJ.PEÇAS,null,'n',RJ.PEÇAS) <> decode(REL.PEÇAS,null,'n',REL.PEÇAS) OR decode (RJ.TRAT_TÉRMICO,null,'n',RJ.TRAT_TÉRMICO) <> decode(REL.TRAT_TÉRMICO,null,'n',REL.TRAT_TÉRMICO) OR decode (RJ.TOLER_PROD_LOT_MAX,null,'n',RJ.TOLER_PROD_LOT_MAX) <> decode(REL.TOLER_PROD_LOT_MAX,null,'n',REL.TOLER_PROD_LOT_MAX) OR decode (RJ.TOLER_PROD_LOT_MIN,null,'n',RJ.TOLER_PROD_LOT_MIN) <> decode(REL.TOLER_PROD_LOT_MIN,null,'n',REL.TOLER_PROD_LOT_MIN) OR decode 
                (RJ.COND_PAG,null,'n',RJ.COND_PAG) <> decode(REL.COND_PAG,null,'n',REL.COND_PAG) OR decode (RJ.TERMO_ENTREGA,null,'n',RJ.TERMO_ENTREGA) <> decode(REL.TERMO_ENTREGA,null,'n',REL.TERMO_ENTREGA) OR decode (RJ.PREÇO,null,'n',RJ.PREÇO) <> decode(REL.PREÇO,null,'n',REL.PREÇO) OR decode (RJ.COMISS_AGENTE,null,'n',RJ.COMISS_AGENTE) <> decode(REL.COMISS_AGENTE,null,'n',REL.COMISS_AGENTE) OR decode (RJ.OBS_GERAL,null,'n',RJ.OBS_GERAL) <> decode(REL.OBS_GERAL,null,'n',REL.OBS_GERAL) OR decode (RJ.INSP_CLASS,null,'n',RJ.INSP_CLASS) <> decode(REL.INSP_CLASS,null,'n',REL.INSP_CLASS) OR decode (RJ.FATURA_LÂMINA,null,'n',RJ.FATURA_LÂMINA) <> decode(REL.FATURA_LÂMINA,null,'n',REL.FATURA_LÂMINA) OR decode (RJ.FATURA_OUTRO,null,'n',RJ.FATURA_OUTRO) <> decode(REL.FATURA_OUTRO,null,'n',REL.FATURA_OUTRO) OR decode (RJ.EXTERNAL_SURVEY_TYPE,null,'n',RJ.EXTERNAL_SURVEY_TYPE) <> decode(REL.EXTERNAL_SURVEY_TYPE,null,'n',REL.EXTERNAL_SURVEY_TYPE) OR decode (RJ.EXTERNAL_SURVEYOR,null,'n',RJ.EXTERNAL_SURVEYOR) <> decode(REL.EXTERNAL_SURVEYOR,null,'n',REL.EXTERNAL_SURVEYOR) OR decode (RJ.SURVEY_SIGN_CERTIF,null,'n',RJ.SURVEY_SIGN_CERTIF) <> decode(REL.SURVEY_SIGN_CERTIF,null,'n',REL.SURVEY_SIGN_CERTIF) OR decode (RJ.CLASS_ORG,null,'n',RJ.CLASS_ORG) <> decode(REL.CLASS_ORG,null,'n',REL.CLASS_ORG) OR decode (RJ.END_USER,null,'n',RJ.END_USER) <> decode(REL.END_USER,null,'n',REL.END_USER) OR decode (RJ.HRP,null,'n',RJ.HRP) <> decode(REL.HRP,null,'n',REL.HRP) OR 
                decode (RJ.HRC,null,'n',RJ.HRC) <> decode(REL.HRC,null,'n',REL.HRC) OR decode (RJ.CRC,null,'n',RJ.CRC) <> decode(REL.CRC,null,'n',REL.CRC) OR decode (RJ.PREDAYS,null,'n',RJ.PREDAYS) <> decode(REL.PREDAYS,null,'n',REL.PREDAYS) OR decode (RJ.POSDAYS,null,'n',RJ.POSDAYS) <> decode(REL.POSDAYS,null,'n',REL.POSDAYS) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> COSIPA_NEGOCIAÇÃO QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif COSIPA_NEGOCIAÇÃO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- DEPTO QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.DEPTO RJ, CXSP.DEPTO@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> DEPTO QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif DEPTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- DEPTO QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.DEPTO@CXSP REL, CXRJ.DEPTO RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> DEPTO QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif DEPTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- DEPTO QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.NOME, REL.NOME, '', 'NOME.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.DEPTO RJ, CXSP.DEPTO@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.NOME,null,'n',RJ.NOME) <> decode(REL.NOME,null,'n',REL.NOME) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode 
                (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> DEPTO QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif DEPTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- EMBALAGEM QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.EMBALAGEM RJ, CXSP.EMBALAGEM@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> EMBALAGEM QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif EMBALAGEM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- EMBALAGEM QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.EMBALAGEM@CXSP REL, CXRJ.EMBALAGEM RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> EMBALAGEM QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif EMBALAGEM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- EMBALAGEM QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.DESCR, REL.DESCR, '', 'DESCR.') || decode(RJ.OBS, REL.OBS, '', 'OBS.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.EMBALAGEM RJ, CXSP.EMBALAGEM@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.DESCR,null,'n',RJ.DESCR) <> decode(REL.DESCR,null,'n',REL.DESCR) OR decode (RJ.OBS,null,'n',RJ.OBS) <> decode(REL.OBS,null,'n',REL.OBS) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode 
                (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> EMBALAGEM QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif EMBALAGEM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- ESCRITÓRIO QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.ESCRITÓRIO chk from CXRJ.ESCRITÓRIO RJ, CXSP.ESCRITÓRIO@CXSP REL where   and RJ.ESCRITÓRIO = REL.ESCRITÓRIO (+) and REL.ESCRITÓRIO is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> ESCRITÓRIO QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif ESCRITÓRIO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- ESCRITÓRIO QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.ESCRITÓRIO chk from CXSP.ESCRITÓRIO@CXSP REL, CXRJ.ESCRITÓRIO RJ where REL.ESCRITÓRIO = RJ.ESCRITÓRIO (+) and RJ.ESCRITÓRIO is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> ESCRITÓRIO QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif ESCRITÓRIO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- ESCRITÓRIO QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.ESCRITÓRIO || ' -> ' || decode(RJ.DESCR, REL.DESCR, '', 'DESCR.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.ESCRITÓRIO RJ, CXSP.ESCRITÓRIO@CXSP REL where   and RJ.ESCRITÓRIO = REL.ESCRITÓRIO and (decode (RJ.DESCR,null,'n',RJ.DESCR) <> decode(REL.DESCR,null,'n',REL.DESCR) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode 
                (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> ESCRITÓRIO QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif ESCRITÓRIO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- GRUPO_PRODUTO QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.GRUPO_PRODUTO RJ, CXSP.GRUPO_PRODUTO@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> GRUPO_PRODUTO QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif GRUPO_PRODUTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- GRUPO_PRODUTO QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.GRUPO_PRODUTO@CXSP REL, CXRJ.GRUPO_PRODUTO RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> GRUPO_PRODUTO QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif GRUPO_PRODUTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- GRUPO_PRODUTO QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.DESCR, REL.DESCR, '', 'DESCR.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.GRUPO_PRODUTO RJ, CXSP.GRUPO_PRODUTO@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.DESCR,null,'n',RJ.DESCR) <> decode(REL.DESCR,null,'n',REL.DESCR) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode 
                (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> GRUPO_PRODUTO QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif GRUPO_PRODUTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- IDIOMA QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.IDIOMA RJ, CXSP.IDIOMA@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> IDIOMA QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif IDIOMA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- IDIOMA QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.IDIOMA@CXSP REL, CXRJ.IDIOMA RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> IDIOMA QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif IDIOMA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- IDIOMA QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.DESCR, REL.DESCR, '', 'DESCR.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.IDIOMA RJ, CXSP.IDIOMA@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.DESCR,null,'n',RJ.DESCR) <> decode(REL.DESCR,null,'n',REL.DESCR) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode 
                (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> IDIOMA QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif IDIOMA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- INCOTERM QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.INCOTERM RJ, CXSP.INCOTERM@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> INCOTERM QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif INCOTERM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- INCOTERM QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.INCOTERM@CXSP REL, CXRJ.INCOTERM RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> INCOTERM QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif INCOTERM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- INCOTERM QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.DESCR, REL.DESCR, '', 'DESCR.') || decode(RJ.OBS, REL.OBS, '', 'OBS.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.INCOTERM RJ, CXSP.INCOTERM@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.DESCR,null,'n',RJ.DESCR) <> decode(REL.DESCR,null,'n',REL.DESCR) OR decode (RJ.OBS,null,'n',RJ.OBS) <> decode(REL.OBS,null,'n',REL.OBS) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) 
                <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> INCOTERM QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif INCOTERM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- LANÇ QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.LANÇ chk from CXRJ.LANÇ RJ, CXSP.LANÇ@CXSP REL where   and RJ.LANÇ = REL.LANÇ (+) and REL.LANÇ is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> LANÇ QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif LANÇ que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- LANÇ QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.LANÇ chk from CXSP.LANÇ@CXSP REL, CXRJ.LANÇ RJ where REL.LANÇ = RJ.LANÇ (+) and RJ.LANÇ is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> LANÇ QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif LANÇ que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- LANÇ QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.LANÇ || ' -> ' || decode(RJ.NOME, REL.NOME, '', 'NOME.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.LANÇ RJ, CXSP.LANÇ@CXSP REL where   and RJ.LANÇ = REL.LANÇ and (decode (RJ.NOME,null,'n',RJ.NOME) <> decode(REL.NOME,null,'n',REL.NOME) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode 
                (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> LANÇ QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif LANÇ que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- MODALIDADE_FRETE QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.MODALIDADE_FRETE RJ, CXSP.MODALIDADE_FRETE@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> MODALIDADE_FRETE QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif MODALIDADE_FRETE que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- MODALIDADE_FRETE QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.MODALIDADE_FRETE@CXSP REL, CXRJ.MODALIDADE_FRETE RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> MODALIDADE_FRETE QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif MODALIDADE_FRETE que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- MODALIDADE_FRETE QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.DESCR, REL.DESCR, '', 'DESCR.') || decode(RJ.OBS, REL.OBS, '', 'OBS.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.MODALIDADE_FRETE RJ, CXSP.MODALIDADE_FRETE@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.DESCR,null,'n',RJ.DESCR) <> decode(REL.DESCR,null,'n',REL.DESCR) OR decode (RJ.OBS,null,'n',RJ.OBS) <> decode(REL.OBS,null,'n',REL.OBS) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode 
                (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> MODALIDADE_FRETE QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif MODALIDADE_FRETE que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- MOEDA QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.MOEDA RJ, CXSP.MOEDA@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> MOEDA QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif MOEDA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- MOEDA QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.MOEDA@CXSP REL, CXRJ.MOEDA RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> MOEDA QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif MOEDA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- MOEDA QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.NOME, REL.NOME, '', 'NOME.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.MOEDA RJ, CXSP.MOEDA@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.NOME,null,'n',RJ.NOME) <> decode(REL.NOME,null,'n',REL.NOME) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode 
                (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> MOEDA QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif MOEDA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- PARAM QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.GRUPO || '.' || RJ.PARAM chk from CXRJ.PARAM RJ, CXSP.PARAM@CXSP REL where   and RJ.GRUPO = REL.GRUPO (+) and RJ.PARAM = REL.PARAM (+) and REL.GRUPO is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PARAM QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PARAM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PARAM QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.GRUPO || '.' || REL.PARAM chk from CXSP.PARAM@CXSP REL, CXRJ.PARAM RJ where REL.GRUPO = RJ.GRUPO (+) and REL.PARAM = RJ.PARAM (+) and RJ.GRUPO is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PARAM QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PARAM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PARAM QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.GRUPO || '.' || RJ.PARAM || ' -> ' || decode(RJ.QUANDO_TEXTO, REL.QUANDO_TEXTO, '', 'QUANDO_TEXTO.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.PARAM RJ, CXSP.PARAM@CXSP REL where   and RJ.GRUPO = REL.GRUPO and RJ.PARAM = REL.PARAM and (decode (RJ.QUANDO_TEXTO,null,'n',RJ.QUANDO_TEXTO) <> decode(REL.QUANDO_TEXTO,null,'n',REL.QUANDO_TEXTO) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> 
                decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PARAM QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PARAM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- RAMO_ATIVIDADE QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.RAMO_ATIVIDADE RJ, CXSP.RAMO_ATIVIDADE@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> RAMO_ATIVIDADE QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif RAMO_ATIVIDADE que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- RAMO_ATIVIDADE QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.RAMO_ATIVIDADE@CXSP REL, CXRJ.RAMO_ATIVIDADE RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> RAMO_ATIVIDADE QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif RAMO_ATIVIDADE que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- RAMO_ATIVIDADE QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.NOME, REL.NOME, '', 'NOME.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.RAMO_ATIVIDADE RJ, CXSP.RAMO_ATIVIDADE@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.NOME,null,'n',RJ.NOME) <> decode(REL.NOME,null,'n',REL.NOME) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode 
                (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> RAMO_ATIVIDADE QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif RAMO_ATIVIDADE que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- VIA_TRANSPORTE QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.VIA_TRANSPORTE RJ, CXSP.VIA_TRANSPORTE@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> VIA_TRANSPORTE QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif VIA_TRANSPORTE que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- VIA_TRANSPORTE QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.VIA_TRANSPORTE@CXSP REL, CXRJ.VIA_TRANSPORTE RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> VIA_TRANSPORTE QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif VIA_TRANSPORTE que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- VIA_TRANSPORTE QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.DESCR, REL.DESCR, '', 'DESCR.') || decode(RJ.TIPO, REL.TIPO, '', 'TIPO.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.VIA_TRANSPORTE RJ, CXSP.VIA_TRANSPORTE@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.DESCR,null,'n',RJ.DESCR) <> decode(REL.DESCR,null,'n',REL.DESCR) OR decode (RJ.TIPO,null,'n',RJ.TIPO) <> decode(REL.TIPO,null,'n',REL.TIPO) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode 
                (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> VIA_TRANSPORTE QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif VIA_TRANSPORTE que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- UNID_QUANTID QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.UNID_QUANTID RJ, CXSP.UNID_QUANTID@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> UNID_QUANTID QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif UNID_QUANTID que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- UNID_QUANTID QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.UNID_QUANTID@CXSP REL, CXRJ.UNID_QUANTID RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> UNID_QUANTID QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif UNID_QUANTID que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- UNID_QUANTID QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.NOME, REL.NOME, '', 'NOME.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.UNID_QUANTID RJ, CXSP.UNID_QUANTID@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.NOME,null,'n',RJ.NOME) <> decode(REL.NOME,null,'n',REL.NOME) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode 
                (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> UNID_QUANTID QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif UNID_QUANTID que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- PAÍS QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.PAÍS RJ, CXSP.PAÍS@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PAÍS QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PAÍS que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PAÍS QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.PAÍS@CXSP REL, CXRJ.PAÍS RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PAÍS QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PAÍS que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PAÍS QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.NOME, REL.NOME, '', 'NOME.') || decode(RJ.ABREVIATURA, REL.ABREVIATURA, '', 'ABREVIATURA.') || decode(RJ.BANDEIRA_COD, REL.BANDEIRA_COD, '', 'BANDEIRA_COD.') || decode(RJ.IDIOMA, REL.IDIOMA, '', 'IDIOMA.') || decode(RJ.MSG, REL.MSG, '', 'MSG.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.PAÍS RJ, CXSP.PAÍS@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.NOME,null,'n',RJ.NOME) <> decode(REL.NOME,null,'n',REL.NOME) OR decode (RJ.ABREVIATURA,null,'n',RJ.ABREVIATURA) <> decode(REL.ABREVIATURA,null,'n',REL.ABREVIATURA) OR decode (RJ.BANDEIRA_COD,null,'n',RJ.BANDEIRA_COD) <> decode(REL.BANDEIRA_COD,null,'n',REL.BANDEIRA_COD) OR decode (RJ.IDIOMA,null,'n',RJ.IDIOMA) <> decode(REL.IDIOMA,null,'n',REL.IDIOMA) OR decode (RJ.MSG,null,'n',RJ.MSG) <> 
                decode(REL.MSG,null,'n',REL.MSG) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PAÍS QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PAÍS que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- DIVISÃO QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.ESCRITÓRIO || '.' || RJ.DIVISÃO chk from CXRJ.DIVISÃO RJ, CXSP.DIVISÃO@CXSP REL where   and RJ.ESCRITÓRIO = REL.ESCRITÓRIO (+) and RJ.DIVISÃO = REL.DIVISÃO (+) and REL.ESCRITÓRIO is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> DIVISÃO QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif DIVISÃO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- DIVISÃO QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.ESCRITÓRIO || '.' || REL.DIVISÃO chk from CXSP.DIVISÃO@CXSP REL, CXRJ.DIVISÃO RJ where REL.ESCRITÓRIO = RJ.ESCRITÓRIO (+) and REL.DIVISÃO = RJ.DIVISÃO (+) and RJ.ESCRITÓRIO is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> DIVISÃO QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif DIVISÃO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- DIVISÃO QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.ESCRITÓRIO || '.' || RJ.DIVISÃO || ' -> ' || decode(RJ.DESCR, REL.DESCR, '', 'DESCR.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.DIVISÃO RJ, CXSP.DIVISÃO@CXSP REL where   and RJ.ESCRITÓRIO = REL.ESCRITÓRIO and RJ.DIVISÃO = REL.DIVISÃO and (decode (RJ.DESCR,null,'n',RJ.DESCR) <> decode(REL.DESCR,null,'n',REL.DESCR) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> 
                decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> DIVISÃO QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif DIVISÃO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- TIPO_REF QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.TIPO chk from CXRJ.TIPO_REF RJ, CXSP.TIPO_REF@CXSP REL where   and RJ.TIPO = REL.TIPO (+) and REL.TIPO is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> TIPO_REF QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif TIPO_REF que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- TIPO_REF QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.TIPO chk from CXSP.TIPO_REF@CXSP REL, CXRJ.TIPO_REF RJ where REL.TIPO = RJ.TIPO (+) and RJ.TIPO is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> TIPO_REF QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif TIPO_REF que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- TIPO_REF QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.TIPO || ' -> ' || decode(RJ.DESCR, REL.DESCR, '', 'DESCR.') || decode(RJ.DEPTO, REL.DEPTO, '', 'DEPTO.') || decode(RJ.ARQUIVO, REL.ARQUIVO, '', 'ARQUIVO.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.TIPO_REF RJ, CXSP.TIPO_REF@CXSP REL where   and RJ.TIPO = REL.TIPO and (decode (RJ.DESCR,null,'n',RJ.DESCR) <> decode(REL.DESCR,null,'n',REL.DESCR) OR decode (RJ.DEPTO,null,'n',RJ.DEPTO) <> decode(REL.DEPTO,null,'n',REL.DEPTO) OR decode (RJ.ARQUIVO,null,'n',RJ.ARQUIVO) <> decode(REL.ARQUIVO,null,'n',REL.ARQUIVO) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode 
                (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> TIPO_REF QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif TIPO_REF que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- INCOTERM_LANÇ QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.INCOTERM || '.' || RJ.LANÇ chk from CXRJ.INCOTERM_LANÇ RJ, CXSP.INCOTERM_LANÇ@CXSP REL where   and RJ.INCOTERM = REL.INCOTERM (+) and RJ.LANÇ = REL.LANÇ (+) and REL.INCOTERM is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> INCOTERM_LANÇ QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif INCOTERM_LANÇ que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- INCOTERM_LANÇ QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.INCOTERM || '.' || REL.LANÇ chk from CXSP.INCOTERM_LANÇ@CXSP REL, CXRJ.INCOTERM_LANÇ RJ where REL.INCOTERM = RJ.INCOTERM (+) and REL.LANÇ = RJ.LANÇ (+) and RJ.INCOTERM is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> INCOTERM_LANÇ QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif INCOTERM_LANÇ que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- INCOTERM_LANÇ QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.INCOTERM || '.' || RJ.LANÇ || ' -> ' || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.INCOTERM_LANÇ RJ, CXSP.INCOTERM_LANÇ@CXSP REL where   and RJ.INCOTERM = REL.INCOTERM and RJ.LANÇ = REL.LANÇ and (decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> 
                decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> INCOTERM_LANÇ QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif INCOTERM_LANÇ que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- PRODUTO QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.PRODUTO RJ, CXSP.PRODUTO@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PRODUTO QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PRODUTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PRODUTO QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.PRODUTO@CXSP REL, CXRJ.PRODUTO RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PRODUTO QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PRODUTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PRODUTO QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.NOME, REL.NOME, '', 'NOME.') || decode(RJ.GRUPO, REL.GRUPO, '', 'GRUPO.') || decode(RJ.NCM, REL.NCM, '', 'NCM.') || decode(RJ.NALADI, REL.NALADI, '', 'NALADI.') || decode(RJ.NCM_OBS, REL.NCM_OBS, '', 'NCM_OBS.') || decode(RJ.NALADI_OBS, REL.NALADI_OBS, '', 'NALADI_OBS.') || decode(RJ.MEDIDAS, REL.MEDIDAS, '', 'MEDIDAS.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.PRODUTO RJ, CXSP.PRODUTO@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.NOME,null,'n',RJ.NOME) <> decode(REL.NOME,null,'n',REL.NOME) OR decode (RJ.GRUPO,null,'n',RJ.GRUPO) <> decode(REL.GRUPO,null,'n',REL.GRUPO) OR decode (RJ.NCM,null,'n',RJ.NCM) <> decode(REL.NCM,null,'n',REL.NCM) OR decode (RJ.NALADI,null,'n',RJ.NALADI) <> decode(REL.NALADI,null,'n',REL.NALADI) OR decode 
                (RJ.NCM_OBS,null,'n',RJ.NCM_OBS) <> decode(REL.NCM_OBS,null,'n',REL.NCM_OBS) OR decode (RJ.NALADI_OBS,null,'n',RJ.NALADI_OBS) <> decode(REL.NALADI_OBS,null,'n',REL.NALADI_OBS) OR decode (RJ.MEDIDAS,null,'n',RJ.MEDIDAS) <> decode(REL.MEDIDAS,null,'n',REL.MEDIDAS) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PRODUTO QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PRODUTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- DIVISÃO_PRODUTO QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.ESCRITÓRIO || '.' || RJ.DIVISÃO || '.' || RJ.PROD chk from CXRJ.DIVISÃO_PRODUTO RJ, CXSP.DIVISÃO_PRODUTO@CXSP REL where   and RJ.ESCRITÓRIO = REL.ESCRITÓRIO (+) and RJ.DIVISÃO = REL.DIVISÃO (+) and RJ.PROD = REL.PROD (+) and REL.ESCRITÓRIO is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> DIVISÃO_PRODUTO QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif DIVISÃO_PRODUTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- DIVISÃO_PRODUTO QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.ESCRITÓRIO || '.' || REL.DIVISÃO || '.' || REL.PROD chk from CXSP.DIVISÃO_PRODUTO@CXSP REL, CXRJ.DIVISÃO_PRODUTO RJ where REL.ESCRITÓRIO = RJ.ESCRITÓRIO (+) and REL.DIVISÃO = RJ.DIVISÃO (+) and REL.PROD = RJ.PROD (+) and RJ.ESCRITÓRIO is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> DIVISÃO_PRODUTO QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif DIVISÃO_PRODUTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- DIVISÃO_PRODUTO QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.ESCRITÓRIO || '.' || RJ.DIVISÃO || '.' || RJ.PROD || ' -> ' || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.DIVISÃO_PRODUTO RJ, CXSP.DIVISÃO_PRODUTO@CXSP REL where   and RJ.ESCRITÓRIO = REL.ESCRITÓRIO and RJ.DIVISÃO = REL.DIVISÃO and RJ.PROD = REL.PROD and (decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode 
                (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> DIVISÃO_PRODUTO QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif DIVISÃO_PRODUTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- DIVISÃO_TIPO_REF QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.ESCRITÓRIO || '.' || RJ.DIVISÃO || '.' || RJ.TIPO_REF chk from CXRJ.DIVISÃO_TIPO_REF RJ, CXSP.DIVISÃO_TIPO_REF@CXSP REL where   and RJ.ESCRITÓRIO = REL.ESCRITÓRIO (+) and RJ.DIVISÃO = REL.DIVISÃO (+) and RJ.TIPO_REF = REL.TIPO_REF (+) and REL.ESCRITÓRIO is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> DIVISÃO_TIPO_REF QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif DIVISÃO_TIPO_REF que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- DIVISÃO_TIPO_REF QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.ESCRITÓRIO || '.' || REL.DIVISÃO || '.' || REL.TIPO_REF chk from CXSP.DIVISÃO_TIPO_REF@CXSP REL, CXRJ.DIVISÃO_TIPO_REF RJ where REL.ESCRITÓRIO = RJ.ESCRITÓRIO (+) and REL.DIVISÃO = RJ.DIVISÃO (+) and REL.TIPO_REF = RJ.TIPO_REF (+) and RJ.ESCRITÓRIO is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> DIVISÃO_TIPO_REF QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif DIVISÃO_TIPO_REF que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- DIVISÃO_TIPO_REF QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.ESCRITÓRIO || '.' || RJ.DIVISÃO || '.' || RJ.TIPO_REF || ' -> ' || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.DIVISÃO_TIPO_REF RJ, CXSP.DIVISÃO_TIPO_REF@CXSP REL where   and RJ.ESCRITÓRIO = REL.ESCRITÓRIO and RJ.DIVISÃO = REL.DIVISÃO and RJ.TIPO_REF = REL.TIPO_REF and (decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode 
                (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> DIVISÃO_TIPO_REF QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif DIVISÃO_TIPO_REF que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- PRODUTO_ESPECIF QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD || '.' || RJ.SEQ chk from CXRJ.PRODUTO_ESPECIF RJ, CXSP.PRODUTO_ESPECIF@CXSP REL where   and RJ.COD = REL.COD (+) and RJ.SEQ = REL.SEQ (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PRODUTO_ESPECIF QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PRODUTO_ESPECIF que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PRODUTO_ESPECIF QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD || '.' || REL.SEQ chk from CXSP.PRODUTO_ESPECIF@CXSP REL, CXRJ.PRODUTO_ESPECIF RJ where REL.COD = RJ.COD (+) and REL.SEQ = RJ.SEQ (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PRODUTO_ESPECIF QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PRODUTO_ESPECIF que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PRODUTO_ESPECIF QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || '.' || RJ.SEQ || ' -> ' || decode(RJ.NCM, REL.NCM, '', 'NCM.') || decode(RJ.NALADI, REL.NALADI, '', 'NALADI.') || decode(RJ.MENOR_ESPESSURA, REL.MENOR_ESPESSURA, '', 'MENOR_ESPESSURA.') || decode(RJ.MAIOR_ESPESSURA, REL.MAIOR_ESPESSURA, '', 'MAIOR_ESPESSURA.') || decode(RJ.MENOR_LARGURA, REL.MENOR_LARGURA, '', 'MENOR_LARGURA.') || decode(RJ.MAIOR_LARGURA, REL.MAIOR_LARGURA, '', 'MAIOR_LARGURA.') || decode(RJ.MENOR_COMPRIMENTO, REL.MENOR_COMPRIMENTO, '', 'MENOR_COMPRIMENTO.') || decode(RJ.MAIOR_COMPRIMENTO, REL.MAIOR_COMPRIMENTO, '', 'MAIOR_COMPRIMENTO.') || decode(RJ.REVESTIMENTO, REL.REVESTIMENTO, '', 'REVESTIMENTO.') || decode(RJ.TÊMPERA, REL.TÊMPERA, '', 'TÊMPERA.') || decode(RJ.DESCR, REL.DESCR, '', 'DESCR.') || decode(RJ.DESCR_NALADI, REL.DESCR_NALADI, '', 'DESCR_NALADI.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || 
                decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.PRODUTO_ESPECIF RJ, CXSP.PRODUTO_ESPECIF@CXSP REL where   and RJ.COD = REL.COD and RJ.SEQ = REL.SEQ and (decode (RJ.NCM,null,'n',RJ.NCM) <> decode(REL.NCM,null,'n',REL.NCM) OR decode (RJ.NALADI,null,'n',RJ.NALADI) <> decode(REL.NALADI,null,'n',REL.NALADI) OR decode (RJ.MENOR_ESPESSURA,null,'n',RJ.MENOR_ESPESSURA) <> decode(REL.MENOR_ESPESSURA,null,'n',REL.MENOR_ESPESSURA) OR decode (RJ.MAIOR_ESPESSURA,null,'n',RJ.MAIOR_ESPESSURA) <> decode(REL.MAIOR_ESPESSURA,null,'n',REL.MAIOR_ESPESSURA) OR decode (RJ.MENOR_LARGURA,null,'n',RJ.MENOR_LARGURA) <> decode(REL.MENOR_LARGURA,null,'n',REL.MENOR_LARGURA) OR decode (RJ.MAIOR_LARGURA,null,'n',RJ.MAIOR_LARGURA) <> decode(REL.MAIOR_LARGURA,null,'n',REL.MAIOR_LARGURA) OR decode (RJ.MENOR_COMPRIMENTO,null,'n',RJ.MENOR_COMPRIMENTO) <> decode(REL.MENOR_COMPRIMENTO,null,'n',REL.MENOR_COMPRIMENTO) OR decode (RJ.MAIOR_COMPRIMENTO,null,'n',RJ.MAIOR_COMPRIMENTO) <> decode(REL.MAIOR_COMPRIMENTO,null,'n',REL.MAIOR_COMPRIMENTO) OR decode (RJ.REVESTIMENTO,null,'n',RJ.REVESTIMENTO) <> decode(REL.REVESTIMENTO,null,'n',REL.REVESTIMENTO) OR decode (RJ.TÊMPERA,null,'n',RJ.TÊMPERA) <> decode(REL.TÊMPERA,null,'n',REL.TÊMPERA) OR decode (RJ.DESCR,null,'n',RJ.DESCR) <> decode(REL.DESCR,null,'n',REL.DESCR) OR decode (RJ.DESCR_NALADI,null,'n',RJ.DESCR_NALADI) <> decode(REL.DESCR_NALADI,null,'n',REL.DESCR_NALADI) OR decode 
                (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PRODUTO_ESPECIF QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PRODUTO_ESPECIF que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- PORTO QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.PORTO RJ, CXSP.PORTO@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PORTO QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PORTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PORTO QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.PORTO@CXSP REL, CXRJ.PORTO RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PORTO QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PORTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PORTO QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.NOME, REL.NOME, '', 'NOME.') || decode(RJ.CIDADE, REL.CIDADE, '', 'CIDADE.') || decode(RJ.ESTADO, REL.ESTADO, '', 'ESTADO.') || decode(RJ.PAÍS, REL.PAÍS, '', 'PAÍS.') || decode(RJ.RESTRIÇÕES, REL.RESTRIÇÕES, '', 'RESTRIÇÕES.') || decode(RJ.OBS, REL.OBS, '', 'OBS.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.PORTO RJ, CXSP.PORTO@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.NOME,null,'n',RJ.NOME) <> decode(REL.NOME,null,'n',REL.NOME) OR decode (RJ.CIDADE,null,'n',RJ.CIDADE) <> decode(REL.CIDADE,null,'n',REL.CIDADE) OR decode (RJ.ESTADO,null,'n',RJ.ESTADO) <> decode(REL.ESTADO,null,'n',REL.ESTADO) OR decode (RJ.PAÍS,null,'n',RJ.PAÍS) <> decode(REL.PAÍS,null,'n',REL.PAÍS) OR decode (RJ.RESTRIÇÕES,null,'n',RJ.RESTRIÇÕES) <> 
                decode(REL.RESTRIÇÕES,null,'n',REL.RESTRIÇÕES) OR decode (RJ.OBS,null,'n',RJ.OBS) <> decode(REL.OBS,null,'n',REL.OBS) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PORTO QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PORTO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- NAVIO QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.COD chk from CXRJ.NAVIO RJ, CXSP.NAVIO@CXSP REL where   and RJ.COD = REL.COD (+) and REL.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> NAVIO QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif NAVIO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- NAVIO QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.COD chk from CXSP.NAVIO@CXSP REL, CXRJ.NAVIO RJ where REL.COD = RJ.COD (+) and RJ.COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> NAVIO QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif NAVIO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- NAVIO QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.COD || ' -> ' || decode(RJ.ANO_CONSTRUÇÃO, REL.ANO_CONSTRUÇÃO, '', 'ANO_CONSTRUÇÃO.') || decode(RJ.NOME, REL.NOME, '', 'NOME.') || decode(RJ.NOME_ANTERIOR, REL.NOME_ANTERIOR, '', 'NOME_ANTERIOR.') || decode(RJ.BANDEIRA, REL.BANDEIRA, '', 'BANDEIRA.') || decode(RJ.NAVIO_TIPO, REL.NAVIO_TIPO, '', 'NAVIO_TIPO.') || decode(RJ.DWAT, REL.DWAT, '', 'DWAT.') || decode(RJ.LOA, REL.LOA, '', 'LOA.') || decode(RJ.BEAN, REL.BEAN, '', 'BEAN.') || decode(RJ.GRT, REL.GRT, '', 'GRT.') || decode(RJ.NRT, REL.NRT, '', 'NRT.') || decode(RJ.CAPACIDADE_GRÃO, REL.CAPACIDADE_GRÃO, '', 'CAPACIDADE_GRÃO.') || decode(RJ.CAPACIDADE_FARDO, REL.CAPACIDADE_FARDO, '', 'CAPACIDADE_FARDO.') || decode(RJ.CALADO_VERÃO, REL.CALADO_VERÃO, '', 'CALADO_VERÃO.') || decode(RJ.GUINDASTE_NUM, REL.GUINDASTE_NUM, '', 'GUINDASTE_NUM.') || decode(RJ.GUINDASTE_DIMENSÃO, REL.GUINDASTE_DIMENSÃO, '', 'GUINDASTE_DIMENSÃO.') || decode(RJ.ESCOTILHA_NUM, REL.ESCOTILHA_NUM, '', 'ESCOTILHA_NUM.') || decode(RJ.ESCOTILHA_DIMENSÃO, REL.ESCOTILHA_DIMENSÃO, '', 'ESCOTILHA_DIMENSÃO.') || decode(RJ.ESCOTILHA_FECHAM_TIPO, REL.ESCOTILHA_FECHAM_TIPO, '', 'ESCOTILHA_FECHAM_TIPO.') || decode(RJ.EQUIPAMENTO, REL.EQUIPAMENTO, '', 'EQUIPAMENTO.') || decode(RJ.TANKTOP_STRENGTH, REL.TANKTOP_STRENGTH, '', 'TANKTOP_STRENGTH.') || decode(RJ.SOCIEDADE_CLASSIFICADORA, 
                REL.SOCIEDADE_CLASSIFICADORA, '', 'SOCIEDADE_CLASSIFICADORA.') || decode(RJ.CLASSE, REL.CLASSE, '', 'CLASSE.') || decode(RJ.OBS, REL.OBS, '', 'OBS.') || decode(RJ.OWNER, REL.OWNER, '', 'OWNER.') || decode(RJ.CALL_SIGN, REL.CALL_SIGN, '', 'CALL_SIGN.') || decode(RJ.N_TANKS, REL.N_TANKS, '', 'N_TANKS.') || decode(RJ.SBT, REL.SBT, '', 'SBT.') || decode(RJ.DOUBLE_HULL, REL.DOUBLE_HULL, '', 'DOUBLE_HULL.') || decode(RJ.DOUBLE_BOTTOM, REL.DOUBLE_BOTTOM, '', 'DOUBLE_BOTTOM.') || decode(RJ.INERT_GAS_SYS, REL.INERT_GAS_SYS, '', 'INERT_GAS_SYS.') || decode(RJ.HEATING_COILS, REL.HEATING_COILS, '', 'HEATING_COILS.') || decode(RJ.IMO_NUM, REL.IMO_NUM, '', 'IMO_NUM.') || decode(RJ.IMO_TYPE, REL.IMO_TYPE, '', 'IMO_TYPE.') || decode(RJ.COATING, REL.COATING, '', 'COATING.') || decode(RJ.CARGO_PUMPS, REL.CARGO_PUMPS, '', 'CARGO_PUMPS.') || decode(RJ.CUBIC_CAPACITY, REL.CUBIC_CAPACITY, '', 'CUBIC_CAPACITY.') || decode(RJ.CARGO_LINES, REL.CARGO_LINES, '', 'CARGO_LINES.') || decode(RJ.CARGO_MANIFOLDS, REL.CARGO_MANIFOLDS, '', 'CARGO_MANIFOLDS.') || decode(RJ.MAJORS_AP, REL.MAJORS_AP, '', 'MAJORS_AP.') || decode(RJ.SUMMER_DRAFT, REL.SUMMER_DRAFT, '', 'SUMMER_DRAFT.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, 
                REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.NAVIO RJ, CXSP.NAVIO@CXSP REL where   and RJ.COD = REL.COD and (decode (RJ.ANO_CONSTRUÇÃO,null,'n',RJ.ANO_CONSTRUÇÃO) <> decode(REL.ANO_CONSTRUÇÃO,null,'n',REL.ANO_CONSTRUÇÃO) OR decode (RJ.NOME,null,'n',RJ.NOME) <> decode(REL.NOME,null,'n',REL.NOME) OR decode (RJ.NOME_ANTERIOR,null,'n',RJ.NOME_ANTERIOR) <> decode(REL.NOME_ANTERIOR,null,'n',REL.NOME_ANTERIOR) OR decode (RJ.BANDEIRA,null,'n',RJ.BANDEIRA) <> decode(REL.BANDEIRA,null,'n',REL.BANDEIRA) OR decode (RJ.NAVIO_TIPO,null,'n',RJ.NAVIO_TIPO) <> decode(REL.NAVIO_TIPO,null,'n',REL.NAVIO_TIPO) OR decode (RJ.DWAT,null,'n',RJ.DWAT) <> decode(REL.DWAT,null,'n',REL.DWAT) OR decode (RJ.LOA,null,'n',RJ.LOA) <> decode(REL.LOA,null,'n',REL.LOA) OR decode (RJ.BEAN,null,'n',RJ.BEAN) <> decode(REL.BEAN,null,'n',REL.BEAN) OR decode (RJ.GRT,null,'n',RJ.GRT) <> decode(REL.GRT,null,'n',REL.GRT) OR decode (RJ.NRT,null,'n',RJ.NRT) <> decode(REL.NRT,null,'n',REL.NRT) OR decode (RJ.CAPACIDADE_GRÃO,null,'n',RJ.CAPACIDADE_GRÃO) <> decode(REL.CAPACIDADE_GRÃO,null,'n',REL.CAPACIDADE_GRÃO) OR decode (RJ.CAPACIDADE_FARDO,null,'n',RJ.CAPACIDADE_FARDO) <> 
                decode(REL.CAPACIDADE_FARDO,null,'n',REL.CAPACIDADE_FARDO) OR decode (RJ.CALADO_VERÃO,null,'n',RJ.CALADO_VERÃO) <> decode(REL.CALADO_VERÃO,null,'n',REL.CALADO_VERÃO) OR decode (RJ.GUINDASTE_NUM,null,'n',RJ.GUINDASTE_NUM) <> decode(REL.GUINDASTE_NUM,null,'n',REL.GUINDASTE_NUM) OR decode (RJ.GUINDASTE_DIMENSÃO,null,'n',RJ.GUINDASTE_DIMENSÃO) <> decode(REL.GUINDASTE_DIMENSÃO,null,'n',REL.GUINDASTE_DIMENSÃO) OR decode (RJ.ESCOTILHA_NUM,null,'n',RJ.ESCOTILHA_NUM) <> decode(REL.ESCOTILHA_NUM,null,'n',REL.ESCOTILHA_NUM) OR decode (RJ.ESCOTILHA_DIMENSÃO,null,'n',RJ.ESCOTILHA_DIMENSÃO) <> decode(REL.ESCOTILHA_DIMENSÃO,null,'n',REL.ESCOTILHA_DIMENSÃO) OR decode (RJ.ESCOTILHA_FECHAM_TIPO,null,'n',RJ.ESCOTILHA_FECHAM_TIPO) <> decode(REL.ESCOTILHA_FECHAM_TIPO,null,'n',REL.ESCOTILHA_FECHAM_TIPO) OR decode (RJ.EQUIPAMENTO,null,'n',RJ.EQUIPAMENTO) <> decode(REL.EQUIPAMENTO,null,'n',REL.EQUIPAMENTO) OR decode (RJ.TANKTOP_STRENGTH,null,'n',RJ.TANKTOP_STRENGTH) <> decode(REL.TANKTOP_STRENGTH,null,'n',REL.TANKTOP_STRENGTH) OR decode (RJ.SOCIEDADE_CLASSIFICADORA,null,'n',RJ.SOCIEDADE_CLASSIFICADORA) <> decode(REL.SOCIEDADE_CLASSIFICADORA,null,'n',REL.SOCIEDADE_CLASSIFICADORA) OR decode (RJ.CLASSE,null,'n',RJ.CLASSE) <> decode(REL.CLASSE,null,'n',REL.CLASSE) OR decode (RJ.OBS,null,'n',RJ.OBS) <> decode(REL.OBS,null,'n',REL.OBS) OR decode (RJ.OWNER,null,'n',RJ.OWNER) <> decode(REL.OWNER,null,'n',REL.OWNER) OR decode 
                (RJ.CALL_SIGN,null,'n',RJ.CALL_SIGN) <> decode(REL.CALL_SIGN,null,'n',REL.CALL_SIGN) OR decode (RJ.N_TANKS,null,'n',RJ.N_TANKS) <> decode(REL.N_TANKS,null,'n',REL.N_TANKS) OR decode (RJ.SBT,null,'n',RJ.SBT) <> decode(REL.SBT,null,'n',REL.SBT) OR decode (RJ.DOUBLE_HULL,null,'n',RJ.DOUBLE_HULL) <> decode(REL.DOUBLE_HULL,null,'n',REL.DOUBLE_HULL) OR decode (RJ.DOUBLE_BOTTOM,null,'n',RJ.DOUBLE_BOTTOM) <> decode(REL.DOUBLE_BOTTOM,null,'n',REL.DOUBLE_BOTTOM) OR decode (RJ.INERT_GAS_SYS,null,'n',RJ.INERT_GAS_SYS) <> decode(REL.INERT_GAS_SYS,null,'n',REL.INERT_GAS_SYS) OR decode (RJ.HEATING_COILS,null,'n',RJ.HEATING_COILS) <> decode(REL.HEATING_COILS,null,'n',REL.HEATING_COILS) OR decode (RJ.IMO_NUM,null,'n',RJ.IMO_NUM) <> decode(REL.IMO_NUM,null,'n',REL.IMO_NUM) OR decode (RJ.IMO_TYPE,null,'n',RJ.IMO_TYPE) <> decode(REL.IMO_TYPE,null,'n',REL.IMO_TYPE) OR decode (RJ.COATING,null,'n',RJ.COATING) <> decode(REL.COATING,null,'n',REL.COATING) OR decode (RJ.CARGO_PUMPS,null,'n',RJ.CARGO_PUMPS) <> decode(REL.CARGO_PUMPS,null,'n',REL.CARGO_PUMPS) OR decode (RJ.CUBIC_CAPACITY,null,'n',RJ.CUBIC_CAPACITY) <> decode(REL.CUBIC_CAPACITY,null,'n',REL.CUBIC_CAPACITY) OR decode (RJ.CARGO_LINES,null,'n',RJ.CARGO_LINES) <> decode(REL.CARGO_LINES,null,'n',REL.CARGO_LINES) OR decode (RJ.CARGO_MANIFOLDS,null,'n',RJ.CARGO_MANIFOLDS) <> decode(REL.CARGO_MANIFOLDS,null,'n',REL.CARGO_MANIFOLDS) OR decode (RJ.MAJORS_AP,null,'n',RJ.MAJORS_AP) <> 
                decode(REL.MAJORS_AP,null,'n',REL.MAJORS_AP) OR decode (RJ.SUMMER_DRAFT,null,'n',RJ.SUMMER_DRAFT) <> decode(REL.SUMMER_DRAFT,null,'n',REL.SUMMER_DRAFT) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> NAVIO QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif NAVIO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- CIA_CONTATO QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.CIA_COD || '.' || RJ.CONTATO_NOME chk from CXRJ.CIA_CONTATO RJ, CXSP.CIA_CONTATO@CXSP REL where   and RJ.CIA_COD = REL.CIA_COD (+) and RJ.CONTATO_NOME = REL.CONTATO_NOME (+) and REL.CIA_COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> CIA_CONTATO QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif CIA_CONTATO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- CIA_CONTATO QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.CIA_COD || '.' || REL.CONTATO_NOME chk from CXSP.CIA_CONTATO@CXSP REL, CXRJ.CIA_CONTATO RJ where REL.CIA_COD = RJ.CIA_COD (+) and REL.CONTATO_NOME = RJ.CONTATO_NOME (+) and RJ.CIA_COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> CIA_CONTATO QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif CIA_CONTATO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- CIA_CONTATO QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.CIA_COD || '.' || RJ.CONTATO_NOME || ' -> ' || decode(RJ.TELEFONE, REL.TELEFONE, '', 'TELEFONE.') || decode(RJ.FUNÇÃO, REL.FUNÇÃO, '', 'FUNÇÃO.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.CIA_CONTATO RJ, CXSP.CIA_CONTATO@CXSP REL where   and RJ.CIA_COD = REL.CIA_COD and RJ.CONTATO_NOME = REL.CONTATO_NOME and (decode (RJ.TELEFONE,null,'n',RJ.TELEFONE) <> decode(REL.TELEFONE,null,'n',REL.TELEFONE) OR decode (RJ.FUNÇÃO,null,'n',RJ.FUNÇÃO) <> decode(REL.FUNÇÃO,null,'n',REL.FUNÇÃO) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) 
                <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> CIA_CONTATO QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif CIA_CONTATO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- VIAGEM QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.REF chk from CXRJ.VIAGEM RJ, CXSP.VIAGEM@CXSP REL where   and RJ.REF = REL.REF (+) and REL.REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> VIAGEM QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif VIAGEM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- VIAGEM QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.REF chk from CXSP.VIAGEM@CXSP REL, CXRJ.VIAGEM RJ where REL.REF = RJ.REF (+) and RJ.REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> VIAGEM QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif VIAGEM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- VIAGEM QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.REF || ' -> ' || decode(RJ.NAVIO, REL.NAVIO, '', 'NAVIO.') || decode(RJ.NAVIO_ÚLTIMO, REL.NAVIO_ÚLTIMO, '', 'NAVIO_ÚLTIMO.') || decode(RJ.CORRENTE, REL.CORRENTE, '', 'CORRENTE.') || decode(RJ.OBS, REL.OBS, '', 'OBS.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.VIAGEM RJ, CXSP.VIAGEM@CXSP REL where   and RJ.REF = REL.REF and (decode (RJ.NAVIO,null,'n',RJ.NAVIO) <> decode(REL.NAVIO,null,'n',REL.NAVIO) OR decode (RJ.NAVIO_ÚLTIMO,null,'n',RJ.NAVIO_ÚLTIMO) <> decode(REL.NAVIO_ÚLTIMO,null,'n',REL.NAVIO_ÚLTIMO) OR decode (RJ.CORRENTE,null,'n',RJ.CORRENTE) <> decode(REL.CORRENTE,null,'n',REL.CORRENTE) OR decode (RJ.OBS,null,'n',RJ.OBS) <> decode(REL.OBS,null,'n',REL.OBS) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> 
                decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> VIAGEM QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif VIAGEM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- CIA_RAMO_ATIVIDADE QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.CIA_COD || '.' || RJ.RAMO_ATIVIDADE chk from CXRJ.CIA_RAMO_ATIVIDADE RJ, CXSP.CIA_RAMO_ATIVIDADE@CXSP REL where   and RJ.CIA_COD = REL.CIA_COD (+) and RJ.RAMO_ATIVIDADE = REL.RAMO_ATIVIDADE (+) and REL.CIA_COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> CIA_RAMO_ATIVIDADE QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif CIA_RAMO_ATIVIDADE que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- CIA_RAMO_ATIVIDADE QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.CIA_COD || '.' || REL.RAMO_ATIVIDADE chk from CXSP.CIA_RAMO_ATIVIDADE@CXSP REL, CXRJ.CIA_RAMO_ATIVIDADE RJ where REL.CIA_COD = RJ.CIA_COD (+) and REL.RAMO_ATIVIDADE = RJ.RAMO_ATIVIDADE (+) and RJ.CIA_COD is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> CIA_RAMO_ATIVIDADE QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif CIA_RAMO_ATIVIDADE que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- CIA_RAMO_ATIVIDADE QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.CIA_COD || '.' || RJ.RAMO_ATIVIDADE || ' -> ' || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.CIA_RAMO_ATIVIDADE RJ, CXSP.CIA_RAMO_ATIVIDADE@CXSP REL where   and RJ.CIA_COD = REL.CIA_COD and RJ.RAMO_ATIVIDADE = REL.RAMO_ATIVIDADE and (decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode 
                (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> CIA_RAMO_ATIVIDADE QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif CIA_RAMO_ATIVIDADE que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- PED QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.REF chk from CXRJ.PED RJ, CXSP.PED@CXSP REL where RJ.REF LIKE 'BH%' and RJ.REF = REL.REF (+) and REL.REF is null AND RJ.REF LIKE 'BH%';
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PED QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.REF chk from CXSP.PED@CXSP REL, CXRJ.PED RJ where REL.REF = RJ.REF (+) and RJ.REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PED QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.REF || ' -> ' || decode(RJ.PED_DATA, REL.PED_DATA, '', 'PED_DATA.') || decode(RJ.MOEDA, REL.MOEDA, '', 'MOEDA.') || decode(RJ.TAXA_USD, REL.TAXA_USD, '', 'TAXA_USD.') || decode(RJ.VIA_TRANSPORTE, REL.VIA_TRANSPORTE, '', 'VIA_TRANSPORTE.') || decode(RJ.CARGA_PORTO, REL.CARGA_PORTO, '', 'CARGA_PORTO.') || decode(RJ.PAÍS_DESTINO, REL.PAÍS_DESTINO, '', 'PAÍS_DESTINO.') || decode(RJ.FORNECEDOR, REL.FORNECEDOR, '', 'FORNECEDOR.') || decode(RJ.FORNECEDOR_REF, REL.FORNECEDOR_REF, '', 'FORNECEDOR_REF.') || decode(RJ.FORNECEDOR_COND_RECEB, REL.FORNECEDOR_COND_RECEB, '', 'FORNECEDOR_COND_RECEB.') || decode(RJ.EXP, REL.EXP, '', 'EXP.') || decode(RJ.EXP_REF, REL.EXP_REF, '', 'EXP_REF.') || decode(RJ.EXP_COND_RECEB, REL.EXP_COND_RECEB, '', 'EXP_COND_RECEB.') || decode(RJ.IMP, REL.IMP, '', 'IMP.') || decode(RJ.IMP_REF, REL.IMP_REF, '', 'IMP_REF.') || decode(RJ.IMP_COND_RECEB, REL.IMP_COND_RECEB, '', 'IMP_COND_RECEB.') || decode(RJ.DISTRIBUIDOR, REL.DISTRIBUIDOR, '', 'DISTRIBUIDOR.') || decode(RJ.PAGADOR, REL.PAGADOR, '', 'PAGADOR.') || decode(RJ.FRETE_COND, REL.FRETE_COND, '', 'FRETE_COND.') || decode(RJ.FRETE_PREV_POR_MT, REL.FRETE_PREV_POR_MT, '', 'FRETE_PREV_POR_MT.') || decode(RJ.FRETE_PREV_VALOR, REL.FRETE_PREV_VALOR, '', 'FRETE_PREV_VALOR.') || decode(RJ.EMB_PREV, REL.EMB_PREV, '', 'EMB_PREV.') || 
                decode(RJ.MARCAÇÃO, REL.MARCAÇÃO, '', 'MARCAÇÃO.') || decode(RJ.OBS, REL.OBS, '', 'OBS.') || decode(RJ.TIPO_VENDA, REL.TIPO_VENDA, '', 'TIPO_VENDA.') || decode(RJ.GRUPO_PROD, REL.GRUPO_PROD, '', 'GRUPO_PROD.') || decode(RJ.SUPERVISOR_VENDA, REL.SUPERVISOR_VENDA, '', 'SUPERVISOR_VENDA.') || decode(RJ.PRODUÇÃO_PREV, REL.PRODUÇÃO_PREV, '', 'PRODUÇÃO_PREV.') || decode(RJ.PARIDADE, REL.PARIDADE, '', 'PARIDADE.') || decode(RJ.INSPEÇÃO_EXTERNA, REL.INSPEÇÃO_EXTERNA, '', 'INSPEÇÃO_EXTERNA.') || decode(RJ.RESPONSÁVEL_INSP_EXT, REL.RESPONSÁVEL_INSP_EXT, '', 'RESPONSÁVEL_INSP_EXT.') || decode(RJ.AGENTE, REL.AGENTE, '', 'AGENTE.') || decode(RJ.TAXA_JUROS_FINANCIAM, REL.TAXA_JUROS_FINANCIAM, '', 'TAXA_JUROS_FINANCIAM.') || decode(RJ.JUROS_NO_PREÇO, REL.JUROS_NO_PREÇO, '', 'JUROS_NO_PREÇO.') || decode(RJ.COMISSÃO_PERCENT, REL.COMISSÃO_PERCENT, '', 'COMISSÃO_PERCENT.') || decode(RJ.COMISSÃO_MT, REL.COMISSÃO_MT, '', 'COMISSÃO_MT.') || decode(RJ.ADICIONAL_PERCENT, REL.ADICIONAL_PERCENT, '', 'ADICIONAL_PERCENT.') || decode(RJ.ADICIONAL_MT, REL.ADICIONAL_MT, '', 'ADICIONAL_MT.') || decode(RJ.INCIDÊNCIA, REL.INCIDÊNCIA, '', 'INCIDÊNCIA.') || decode(RJ.TIPO, REL.TIPO, '', 'TIPO.') || decode(RJ.ANEXO, REL.ANEXO, '', 'ANEXO.') || decode(RJ.BENEFICIÁRIO, REL.BENEFICIÁRIO, '', 'BENEFICIÁRIO.') || decode(RJ.LOCAL_PAG, REL.LOCAL_PAG, '', 'LOCAL_PAG.') || decode(RJ.BANCO, REL.BANCO, '', 'BANCO.') || decode(RJ.F_QUANTIDADE, REL.F_QUANTIDADE, '', 
                'F_QUANTIDADE.') || decode(RJ.F_PREÇO, REL.F_PREÇO, '', 'F_PREÇO.') || decode(RJ.F_RESULTADO, REL.F_RESULTADO, '', 'F_RESULTADO.') || decode(RJ.F_RESULTADO_MT, REL.F_RESULTADO_MT, '', 'F_RESULTADO_MT.') || decode(RJ.F_RESULTADO_P, REL.F_RESULTADO_P, '', 'F_RESULTADO_P.') || decode(RJ.F_COMISSÃO_FORN, REL.F_COMISSÃO_FORN, '', 'F_COMISSÃO_FORN.') || decode(RJ.F_COMISSÃO_FORN_P, REL.F_COMISSÃO_FORN_P, '', 'F_COMISSÃO_FORN_P.') || decode(RJ.F_PROFIT_SPLIT, REL.F_PROFIT_SPLIT, '', 'F_PROFIT_SPLIT.') || decode(RJ.F_DELIV_PURCHASE, REL.F_DELIV_PURCHASE, '', 'F_DELIV_PURCHASE.') || decode(RJ.F_DELIV_SALES, REL.F_DELIV_SALES, '', 'F_DELIV_SALES.') || decode(RJ.F_PAY_PURCHASE, REL.F_PAY_PURCHASE, '', 'F_PAY_PURCHASE.') || decode(RJ.F_PAY_SALES, REL.F_PAY_SALES, '', 'F_PAY_SALES.') || decode(RJ.F_OBS, REL.F_OBS, '', 'F_OBS.') || decode(RJ.FORNECEDOR_COND_VENDA, REL.FORNECEDOR_COND_VENDA, '', 'FORNECEDOR_COND_VENDA.') || decode(RJ.EXP_COND_VENDA, REL.EXP_COND_VENDA, '', 'EXP_COND_VENDA.') || decode(RJ.IMP_COND_VENDA, REL.IMP_COND_VENDA, '', 'IMP_COND_VENDA.') || decode(RJ.INSTRUC_INTERNA, REL.INSTRUC_INTERNA, '', 'INSTRUC_INTERNA.') || decode(RJ.PRODUTOR, REL.PRODUTOR, '', 'PRODUTOR.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || 
                decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.PED RJ, CXSP.PED@CXSP REL where RJ.REF LIKE 'BH%' and RJ.REF = REL.REF and (decode (RJ.PED_DATA,null,'n',RJ.PED_DATA) <> decode(REL.PED_DATA,null,'n',REL.PED_DATA) OR decode (RJ.MOEDA,null,'n',RJ.MOEDA) <> decode(REL.MOEDA,null,'n',REL.MOEDA) OR decode (RJ.TAXA_USD,null,'n',RJ.TAXA_USD) <> decode(REL.TAXA_USD,null,'n',REL.TAXA_USD) OR decode (RJ.VIA_TRANSPORTE,null,'n',RJ.VIA_TRANSPORTE) <> decode(REL.VIA_TRANSPORTE,null,'n',REL.VIA_TRANSPORTE) OR decode (RJ.CARGA_PORTO,null,'n',RJ.CARGA_PORTO) <> decode(REL.CARGA_PORTO,null,'n',REL.CARGA_PORTO) OR decode (RJ.PAÍS_DESTINO,null,'n',RJ.PAÍS_DESTINO) <> decode(REL.PAÍS_DESTINO,null,'n',REL.PAÍS_DESTINO) OR decode (RJ.FORNECEDOR,null,'n',RJ.FORNECEDOR) <> decode(REL.FORNECEDOR,null,'n',REL.FORNECEDOR) OR decode (RJ.FORNECEDOR_REF,null,'n',RJ.FORNECEDOR_REF) <> decode(REL.FORNECEDOR_REF,null,'n',REL.FORNECEDOR_REF) OR decode (RJ.FORNECEDOR_COND_RECEB,null,'n',RJ.FORNECEDOR_COND_RECEB) <> decode(REL.FORNECEDOR_COND_RECEB,null,'n',REL.FORNECEDOR_COND_RECEB) OR decode (RJ.EXP,null,'n',RJ.EXP) <> decode(REL.EXP,null,'n',REL.EXP) OR decode 
                (RJ.EXP_REF,null,'n',RJ.EXP_REF) <> decode(REL.EXP_REF,null,'n',REL.EXP_REF) OR decode (RJ.EXP_COND_RECEB,null,'n',RJ.EXP_COND_RECEB) <> decode(REL.EXP_COND_RECEB,null,'n',REL.EXP_COND_RECEB) OR decode (RJ.IMP,null,'n',RJ.IMP) <> decode(REL.IMP,null,'n',REL.IMP) OR decode (RJ.IMP_REF,null,'n',RJ.IMP_REF) <> decode(REL.IMP_REF,null,'n',REL.IMP_REF) OR decode (RJ.IMP_COND_RECEB,null,'n',RJ.IMP_COND_RECEB) <> decode(REL.IMP_COND_RECEB,null,'n',REL.IMP_COND_RECEB) OR decode (RJ.DISTRIBUIDOR,null,'n',RJ.DISTRIBUIDOR) <> decode(REL.DISTRIBUIDOR,null,'n',REL.DISTRIBUIDOR) OR decode (RJ.PAGADOR,null,'n',RJ.PAGADOR) <> decode(REL.PAGADOR,null,'n',REL.PAGADOR) OR decode (RJ.FRETE_COND,null,'n',RJ.FRETE_COND) <> decode(REL.FRETE_COND,null,'n',REL.FRETE_COND) OR decode (RJ.FRETE_PREV_POR_MT,null,'n',RJ.FRETE_PREV_POR_MT) <> decode(REL.FRETE_PREV_POR_MT,null,'n',REL.FRETE_PREV_POR_MT) OR decode (RJ.FRETE_PREV_VALOR,null,'n',RJ.FRETE_PREV_VALOR) <> decode(REL.FRETE_PREV_VALOR,null,'n',REL.FRETE_PREV_VALOR) OR decode (RJ.EMB_PREV,null,'n',RJ.EMB_PREV) <> decode(REL.EMB_PREV,null,'n',REL.EMB_PREV) OR decode (RJ.MARCAÇÃO,null,'n',RJ.MARCAÇÃO) <> decode(REL.MARCAÇÃO,null,'n',REL.MARCAÇÃO) OR decode (RJ.OBS,null,'n',RJ.OBS) <> decode(REL.OBS,null,'n',REL.OBS) OR decode (RJ.TIPO_VENDA,null,'n',RJ.TIPO_VENDA) <> decode(REL.TIPO_VENDA,null,'n',REL.TIPO_VENDA) OR decode (RJ.GRUPO_PROD,null,'n',RJ.GRUPO_PROD) <> 
                decode(REL.GRUPO_PROD,null,'n',REL.GRUPO_PROD) OR decode (RJ.SUPERVISOR_VENDA,null,'n',RJ.SUPERVISOR_VENDA) <> decode(REL.SUPERVISOR_VENDA,null,'n',REL.SUPERVISOR_VENDA) OR decode (RJ.PRODUÇÃO_PREV,null,'n',RJ.PRODUÇÃO_PREV) <> decode(REL.PRODUÇÃO_PREV,null,'n',REL.PRODUÇÃO_PREV) OR decode (RJ.PARIDADE,null,'n',RJ.PARIDADE) <> decode(REL.PARIDADE,null,'n',REL.PARIDADE) OR decode (RJ.INSPEÇÃO_EXTERNA,null,'n',RJ.INSPEÇÃO_EXTERNA) <> decode(REL.INSPEÇÃO_EXTERNA,null,'n',REL.INSPEÇÃO_EXTERNA) OR decode (RJ.RESPONSÁVEL_INSP_EXT,null,'n',RJ.RESPONSÁVEL_INSP_EXT) <> decode(REL.RESPONSÁVEL_INSP_EXT,null,'n',REL.RESPONSÁVEL_INSP_EXT) OR decode (RJ.AGENTE,null,'n',RJ.AGENTE) <> decode(REL.AGENTE,null,'n',REL.AGENTE) OR decode (RJ.TAXA_JUROS_FINANCIAM,null,'n',RJ.TAXA_JUROS_FINANCIAM) <> decode(REL.TAXA_JUROS_FINANCIAM,null,'n',REL.TAXA_JUROS_FINANCIAM) OR decode (RJ.JUROS_NO_PREÇO,null,'n',RJ.JUROS_NO_PREÇO) <> decode(REL.JUROS_NO_PREÇO,null,'n',REL.JUROS_NO_PREÇO) OR decode (RJ.COMISSÃO_PERCENT,null,'n',RJ.COMISSÃO_PERCENT) <> decode(REL.COMISSÃO_PERCENT,null,'n',REL.COMISSÃO_PERCENT) OR decode (RJ.COMISSÃO_MT,null,'n',RJ.COMISSÃO_MT) <> decode(REL.COMISSÃO_MT,null,'n',REL.COMISSÃO_MT) OR decode (RJ.ADICIONAL_PERCENT,null,'n',RJ.ADICIONAL_PERCENT) <> decode(REL.ADICIONAL_PERCENT,null,'n',REL.ADICIONAL_PERCENT) OR decode (RJ.ADICIONAL_MT,null,'n',RJ.ADICIONAL_MT) <> decode(REL.ADICIONAL_MT,null,'n',REL.ADICIONAL_MT) OR decode 
                (RJ.INCIDÊNCIA,null,'n',RJ.INCIDÊNCIA) <> decode(REL.INCIDÊNCIA,null,'n',REL.INCIDÊNCIA) OR decode (RJ.TIPO,null,'n',RJ.TIPO) <> decode(REL.TIPO,null,'n',REL.TIPO) OR decode (RJ.ANEXO,null,'n',RJ.ANEXO) <> decode(REL.ANEXO,null,'n',REL.ANEXO) OR decode (RJ.BENEFICIÁRIO,null,'n',RJ.BENEFICIÁRIO) <> decode(REL.BENEFICIÁRIO,null,'n',REL.BENEFICIÁRIO) OR decode (RJ.LOCAL_PAG,null,'n',RJ.LOCAL_PAG) <> decode(REL.LOCAL_PAG,null,'n',REL.LOCAL_PAG) OR decode (RJ.BANCO,null,'n',RJ.BANCO) <> decode(REL.BANCO,null,'n',REL.BANCO) OR decode (RJ.F_QUANTIDADE,null,'n',RJ.F_QUANTIDADE) <> decode(REL.F_QUANTIDADE,null,'n',REL.F_QUANTIDADE) OR decode (RJ.F_PREÇO,null,'n',RJ.F_PREÇO) <> decode(REL.F_PREÇO,null,'n',REL.F_PREÇO) OR decode (RJ.F_RESULTADO,null,'n',RJ.F_RESULTADO) <> decode(REL.F_RESULTADO,null,'n',REL.F_RESULTADO) OR decode (RJ.F_RESULTADO_MT,null,'n',RJ.F_RESULTADO_MT) <> decode(REL.F_RESULTADO_MT,null,'n',REL.F_RESULTADO_MT) OR decode (RJ.F_RESULTADO_P,null,'n',RJ.F_RESULTADO_P) <> decode(REL.F_RESULTADO_P,null,'n',REL.F_RESULTADO_P) OR decode (RJ.F_COMISSÃO_FORN,null,'n',RJ.F_COMISSÃO_FORN) <> decode(REL.F_COMISSÃO_FORN,null,'n',REL.F_COMISSÃO_FORN) OR decode (RJ.F_COMISSÃO_FORN_P,null,'n',RJ.F_COMISSÃO_FORN_P) <> decode(REL.F_COMISSÃO_FORN_P,null,'n',REL.F_COMISSÃO_FORN_P) OR decode (RJ.F_PROFIT_SPLIT,null,'n',RJ.F_PROFIT_SPLIT) <> decode(REL.F_PROFIT_SPLIT,null,'n',REL.F_PROFIT_SPLIT) OR decode 
                (RJ.F_DELIV_PURCHASE,null,'n',RJ.F_DELIV_PURCHASE) <> decode(REL.F_DELIV_PURCHASE,null,'n',REL.F_DELIV_PURCHASE) OR decode (RJ.F_DELIV_SALES,null,'n',RJ.F_DELIV_SALES) <> decode(REL.F_DELIV_SALES,null,'n',REL.F_DELIV_SALES) OR decode (RJ.F_PAY_PURCHASE,null,'n',RJ.F_PAY_PURCHASE) <> decode(REL.F_PAY_PURCHASE,null,'n',REL.F_PAY_PURCHASE) OR decode (RJ.F_PAY_SALES,null,'n',RJ.F_PAY_SALES) <> decode(REL.F_PAY_SALES,null,'n',REL.F_PAY_SALES) OR decode (RJ.F_OBS,null,'n',RJ.F_OBS) <> decode(REL.F_OBS,null,'n',REL.F_OBS) OR decode (RJ.FORNECEDOR_COND_VENDA,null,'n',RJ.FORNECEDOR_COND_VENDA) <> decode(REL.FORNECEDOR_COND_VENDA,null,'n',REL.FORNECEDOR_COND_VENDA) OR decode (RJ.EXP_COND_VENDA,null,'n',RJ.EXP_COND_VENDA) <> decode(REL.EXP_COND_VENDA,null,'n',REL.EXP_COND_VENDA) OR decode (RJ.IMP_COND_VENDA,null,'n',RJ.IMP_COND_VENDA) <> decode(REL.IMP_COND_VENDA,null,'n',REL.IMP_COND_VENDA) OR decode (RJ.INSTRUC_INTERNA,null,'n',RJ.INSTRUC_INTERNA) <> decode(REL.INSTRUC_INTERNA,null,'n',REL.INSTRUC_INTERNA) OR decode (RJ.PRODUTOR,null,'n',RJ.PRODUTOR) <> decode(REL.PRODUTOR,null,'n',REL.PRODUTOR) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> 
                decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- VIAGEM_ESCALA QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.VIAGEM_REF || '.' || RJ.ESCALA chk from CXRJ.VIAGEM_ESCALA RJ, CXSP.VIAGEM_ESCALA@CXSP REL where   and RJ.VIAGEM_REF = REL.VIAGEM_REF (+) and RJ.ESCALA = REL.ESCALA (+) and REL.VIAGEM_REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> VIAGEM_ESCALA QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif VIAGEM_ESCALA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- VIAGEM_ESCALA QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.VIAGEM_REF || '.' || REL.ESCALA chk from CXSP.VIAGEM_ESCALA@CXSP REL, CXRJ.VIAGEM_ESCALA RJ where REL.VIAGEM_REF = RJ.VIAGEM_REF (+) and REL.ESCALA = RJ.ESCALA (+) and RJ.VIAGEM_REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> VIAGEM_ESCALA QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif VIAGEM_ESCALA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- VIAGEM_ESCALA QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.VIAGEM_REF || '.' || RJ.ESCALA || ' -> ' || decode(RJ.PORTO, REL.PORTO, '', 'PORTO.') || decode(RJ.ETA, REL.ETA, '', 'ETA.') || decode(RJ.ETS, REL.ETS, '', 'ETS.') || decode(RJ.ATA, REL.ATA, '', 'ATA.') || decode(RJ.ATS, REL.ATS, '', 'ATS.') || decode(RJ.LD, REL.LD, '', 'LD.') || decode(RJ.OBS, REL.OBS, '', 'OBS.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.VIAGEM_ESCALA RJ, CXSP.VIAGEM_ESCALA@CXSP REL where   and RJ.VIAGEM_REF = REL.VIAGEM_REF and RJ.ESCALA = REL.ESCALA and (decode (RJ.PORTO,null,'n',RJ.PORTO) <> decode(REL.PORTO,null,'n',REL.PORTO) OR decode (RJ.ETA,null,'n',RJ.ETA) <> decode(REL.ETA,null,'n',REL.ETA) OR decode (RJ.ETS,null,'n',RJ.ETS) <> decode(REL.ETS,null,'n',REL.ETS) OR decode (RJ.ATA,null,'n',RJ.ATA) <> decode(REL.ATA,null,'n',REL.ATA) OR decode 
                (RJ.ATS,null,'n',RJ.ATS) <> decode(REL.ATS,null,'n',REL.ATS) OR decode (RJ.LD,null,'n',RJ.LD) <> decode(REL.LD,null,'n',REL.LD) OR decode (RJ.OBS,null,'n',RJ.OBS) <> decode(REL.OBS,null,'n',REL.OBS) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> VIAGEM_ESCALA QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif VIAGEM_ESCALA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- EMB_F QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.PED_REF || '.' || RJ.SEQ chk from CXRJ.EMB_F RJ, CXSP.EMB_F@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.PED_REF = REL.PED_REF (+) and RJ.SEQ = REL.SEQ (+) and REL.PED_REF is null AND RJ.PED_REF LIKE 'BH%';
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> EMB_F QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif EMB_F que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- EMB_F QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.PED_REF || '.' || REL.SEQ chk from CXSP.EMB_F@CXSP REL, CXRJ.EMB_F RJ where REL.PED_REF = RJ.PED_REF (+) and REL.SEQ = RJ.SEQ (+) and RJ.PED_REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> EMB_F QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif EMB_F que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- EMB_F QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.PED_REF || '.' || RJ.SEQ || ' -> ' || decode(RJ.FATURA, REL.FATURA, '', 'FATURA.') || decode(RJ.INV_DATA, REL.INV_DATA, '', 'INV_DATA.') || decode(RJ.NAVIO, REL.NAVIO, '', 'NAVIO.') || decode(RJ.BL_DATA, REL.BL_DATA, '', 'BL_DATA.') || decode(RJ.COMPETÊNCIA, REL.COMPETÊNCIA, '', 'COMPETÊNCIA.') || decode(RJ.QUANTIDADE, REL.QUANTIDADE, '', 'QUANTIDADE.') || decode(RJ.VALOR, REL.VALOR, '', 'VALOR.') || decode(RJ.RESULT1, REL.RESULT1, '', 'RESULT1.') || decode(RJ.RESULT2, REL.RESULT2, '', 'RESULT2.') || decode(RJ.RESULT3, REL.RESULT3, '', 'RESULT3.') || decode(RJ.RESULT4, REL.RESULT4, '', 'RESULT4.') || decode(RJ.RESULT5, REL.RESULT5, '', 'RESULT5.') || decode(RJ.POSIÇÃO, REL.POSIÇÃO, '', 'POSIÇÃO.') || decode(RJ.OBSERVAÇÃO, REL.OBSERVAÇÃO, '', 'OBSERVAÇÃO.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 
                'SYS_STATUS.') chk from CXRJ.EMB_F RJ, CXSP.EMB_F@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.PED_REF = REL.PED_REF and RJ.SEQ = REL.SEQ and (decode (RJ.FATURA,null,'n',RJ.FATURA) <> decode(REL.FATURA,null,'n',REL.FATURA) OR decode (RJ.INV_DATA,null,'n',RJ.INV_DATA) <> decode(REL.INV_DATA,null,'n',REL.INV_DATA) OR decode (RJ.NAVIO,null,'n',RJ.NAVIO) <> decode(REL.NAVIO,null,'n',REL.NAVIO) OR decode (RJ.BL_DATA,null,'n',RJ.BL_DATA) <> decode(REL.BL_DATA,null,'n',REL.BL_DATA) OR decode (RJ.COMPETÊNCIA,null,'n',RJ.COMPETÊNCIA) <> decode(REL.COMPETÊNCIA,null,'n',REL.COMPETÊNCIA) OR decode (RJ.QUANTIDADE,null,'n',RJ.QUANTIDADE) <> decode(REL.QUANTIDADE,null,'n',REL.QUANTIDADE) OR decode (RJ.VALOR,null,'n',RJ.VALOR) <> decode(REL.VALOR,null,'n',REL.VALOR) OR decode (RJ.RESULT1,null,'n',RJ.RESULT1) <> decode(REL.RESULT1,null,'n',REL.RESULT1) OR decode (RJ.RESULT2,null,'n',RJ.RESULT2) <> decode(REL.RESULT2,null,'n',REL.RESULT2) OR decode (RJ.RESULT3,null,'n',RJ.RESULT3) <> decode(REL.RESULT3,null,'n',REL.RESULT3) OR decode (RJ.RESULT4,null,'n',RJ.RESULT4) <> decode(REL.RESULT4,null,'n',REL.RESULT4) OR decode (RJ.RESULT5,null,'n',RJ.RESULT5) <> decode(REL.RESULT5,null,'n',REL.RESULT5) OR decode (RJ.POSIÇÃO,null,'n',RJ.POSIÇÃO) <> decode(REL.POSIÇÃO,null,'n',REL.POSIÇÃO) OR decode (RJ.OBSERVAÇÃO,null,'n',RJ.OBSERVAÇÃO) <> decode(REL.OBSERVAÇÃO,null,'n',REL.OBSERVAÇÃO) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> 
                decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> EMB_F QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif EMB_F que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- EMB QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.REF chk from CXRJ.EMB RJ, CXSP.EMB@CXSP REL where   and RJ.REF = REL.REF (+) and REL.REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> EMB QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif EMB que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- EMB QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.REF chk from CXSP.EMB@CXSP REL, CXRJ.EMB RJ where REL.REF = RJ.REF (+) and RJ.REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> EMB QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif EMB que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- EMB QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.REF || ' -> ' || decode(RJ.CALC_NOMINAL_PED, REL.CALC_NOMINAL_PED, '', 'CALC_NOMINAL_PED.') || decode(RJ.VIAGEM, REL.VIAGEM, '', 'VIAGEM.') || decode(RJ.FRETE_UNID, REL.FRETE_UNID, '', 'FRETE_UNID.') || decode(RJ.FRETE_VALOR, REL.FRETE_VALOR, '', 'FRETE_VALOR.') || decode(RJ.FRETE_POR_MT, REL.FRETE_POR_MT, '', 'FRETE_POR_MT.') || decode(RJ.FRETE_VALOR_POR_UNID, REL.FRETE_VALOR_POR_UNID, '', 'FRETE_VALOR_POR_UNID.') || decode(RJ.FRETE_VALOR_TOTAL, REL.FRETE_VALOR_TOTAL, '', 'FRETE_VALOR_TOTAL.') || decode(RJ.FRETE_COND, REL.FRETE_COND, '', 'FRETE_COND.') || decode(RJ.DATA_EMBARQUE, REL.DATA_EMBARQUE, '', 'DATA_EMBARQUE.') || decode(RJ.DATA_EMISSÃO_DOC, REL.DATA_EMISSÃO_DOC, '', 'DATA_EMISSÃO_DOC.') || decode(RJ.CARGA_PORTO, REL.CARGA_PORTO, '', 'CARGA_PORTO.') || decode(RJ.DESCARGA_PORTO, REL.DESCARGA_PORTO, '', 'DESCARGA_PORTO.') || decode(RJ.TRANSPORTADOR, REL.TRANSPORTADOR, '', 'TRANSPORTADOR.') || decode(RJ.MOEDA, REL.MOEDA, '', 'MOEDA.') || decode(RJ.IDIOMA, REL.IDIOMA, '', 'IDIOMA.') || decode(RJ.PESO_UNID, REL.PESO_UNID, '', 'PESO_UNID.') || decode(RJ.PREÇO_UNITÁRIO_UNID, REL.PREÇO_UNITÁRIO_UNID, '', 'PREÇO_UNITÁRIO_UNID.') || decode(RJ.PREÇO_UNID, REL.PREÇO_UNID, '', 'PREÇO_UNID.') || decode(RJ.NEGOCIADOR, REL.NEGOCIADOR, '', 'NEGOCIADOR.') || decode(RJ.EMBARCADOR, REL.EMBARCADOR, 
                '', 'EMBARCADOR.') || decode(RJ.EMB_ENDEREÇO, REL.EMB_ENDEREÇO, '', 'EMB_ENDEREÇO.') || decode(RJ.EMB_PAÍS, REL.EMB_PAÍS, '', 'EMB_PAÍS.') || decode(RJ.EMB_COND_VENDA, REL.EMB_COND_VENDA, '', 'EMB_COND_VENDA.') || decode(RJ.EMB_COND_PAG, REL.EMB_COND_PAG, '', 'EMB_COND_PAG.') || decode(RJ.EMB_COMENTÁRIOS, REL.EMB_COMENTÁRIOS, '', 'EMB_COMENTÁRIOS.') || decode(RJ.EXP, REL.EXP, '', 'EXP.') || decode(RJ.EXP_ENDEREÇO, REL.EXP_ENDEREÇO, '', 'EXP_ENDEREÇO.') || decode(RJ.EXP_PAÍS, REL.EXP_PAÍS, '', 'EXP_PAÍS.') || decode(RJ.EXP_COND_VENDA, REL.EXP_COND_VENDA, '', 'EXP_COND_VENDA.') || decode(RJ.EXP_COND_PAG, REL.EXP_COND_PAG, '', 'EXP_COND_PAG.') || decode(RJ.EXP_COMENTÁRIOS, REL.EXP_COMENTÁRIOS, '', 'EXP_COMENTÁRIOS.') || decode(RJ.EXP_LOGOTIPO, REL.EXP_LOGOTIPO, '', 'EXP_LOGOTIPO.') || decode(RJ.EXP_FAT, REL.EXP_FAT, '', 'EXP_FAT.') || decode(RJ.IMP, REL.IMP, '', 'IMP.') || decode(RJ.IMP_ENDEREÇO, REL.IMP_ENDEREÇO, '', 'IMP_ENDEREÇO.') || decode(RJ.IMP_PAÍS, REL.IMP_PAÍS, '', 'IMP_PAÍS.') || decode(RJ.IMP_COND_VENDA, REL.IMP_COND_VENDA, '', 'IMP_COND_VENDA.') || decode(RJ.IMP_COND_PAG, REL.IMP_COND_PAG, '', 'IMP_COND_PAG.') || decode(RJ.IMP_COMENTÁRIOS, REL.IMP_COMENTÁRIOS, '', 'IMP_COMENTÁRIOS.') || decode(RJ.IMP_LOGOTIPO, REL.IMP_LOGOTIPO, '', 'IMP_LOGOTIPO.') || decode(RJ.IMP_FAT, REL.IMP_FAT, '', 'IMP_FAT.') || decode(RJ.PAGADOR, REL.PAGADOR, '', 'PAGADOR.') || decode(RJ.PAG_ENDEREÇO, REL.PAG_ENDEREÇO, '', 'PAG_ENDEREÇO.') || 
                decode(RJ.PAG_PAÍS, REL.PAG_PAÍS, '', 'PAG_PAÍS.') || decode(RJ.CONSIGNATÁRIO, REL.CONSIGNATÁRIO, '', 'CONSIGNATÁRIO.') || decode(RJ.CONSIGN_ENDEREÇO, REL.CONSIGN_ENDEREÇO, '', 'CONSIGN_ENDEREÇO.') || decode(RJ.CONSIGN_PAÍS, REL.CONSIGN_PAÍS, '', 'CONSIGN_PAÍS.') || decode(RJ.NOTIFICAR, REL.NOTIFICAR, '', 'NOTIFICAR.') || decode(RJ.NOTIFICAR_ENDEREÇO, REL.NOTIFICAR_ENDEREÇO, '', 'NOTIFICAR_ENDEREÇO.') || decode(RJ.NOTIFICAR_PAÍS, REL.NOTIFICAR_PAÍS, '', 'NOTIFICAR_PAÍS.') || decode(RJ.NUM_BL_DESCR, REL.NUM_BL_DESCR, '', 'NUM_BL_DESCR.') || decode(RJ.FAMÍLIA_GENÉRICA, REL.FAMÍLIA_GENÉRICA, '', 'FAMÍLIA_GENÉRICA.') || decode(RJ.TIPO_DESCR_MERCADORIA, REL.TIPO_DESCR_MERCADORIA, '', 'TIPO_DESCR_MERCADORIA.') || decode(RJ.MARCAÇÃO, REL.MARCAÇÃO, '', 'MARCAÇÃO.') || decode(RJ.TOTALIZAÇÃO_EMBALAGEM, REL.TOTALIZAÇÃO_EMBALAGEM, '', 'TOTALIZAÇÃO_EMBALAGEM.') || decode(RJ.CONFIG, REL.CONFIG, '', 'CONFIG.') || decode(RJ.EMB_ACORDO, REL.EMB_ACORDO, '', 'EMB_ACORDO.') || decode(RJ.VIA_TRANSPORTE, REL.VIA_TRANSPORTE, '', 'VIA_TRANSPORTE.') || decode(RJ.CARTA_CRED_REF, REL.CARTA_CRED_REF, '', 'CARTA_CRED_REF.') || decode(RJ.EMB_DATA, REL.EMB_DATA, '', 'EMB_DATA.') || decode(RJ.CARTA_CRÉDITO_BANCO_ABRIDOR, REL.CARTA_CRÉDITO_BANCO_ABRIDOR, '', 'CARTA_CRÉDITO_BANCO_ABRIDOR.') || decode(RJ.CARTA_CRÉDITO_REF, REL.CARTA_CRÉDITO_REF, '', 'CARTA_CRÉDITO_REF.') || decode(RJ.BANCO_AVISADOR, REL.BANCO_AVISADOR, '', 'BANCO_AVISADOR.') || 
                decode(RJ.BANCO_CONFIRM, REL.BANCO_CONFIRM, '', 'BANCO_CONFIRM.') || decode(RJ.CALC_QTD_PED_UNID, REL.CALC_QTD_PED_UNID, '', 'CALC_QTD_PED_UNID.') || decode(RJ.CALC_PESO_LÍQUIDO, REL.CALC_PESO_LÍQUIDO, '', 'CALC_PESO_LÍQUIDO.') || decode(RJ.CALC_PESO_BRUTO, REL.CALC_PESO_BRUTO, '', 'CALC_PESO_BRUTO.') || decode(RJ.CALC_QTD_VOL, REL.CALC_QTD_VOL, '', 'CALC_QTD_VOL.') || decode(RJ.CALC_EXP_TOT_ITEM, REL.CALC_EXP_TOT_ITEM, '', 'CALC_EXP_TOT_ITEM.') || decode(RJ.CALC_EXP_TOT_EMB, REL.CALC_EXP_TOT_EMB, '', 'CALC_EXP_TOT_EMB.') || decode(RJ.CALC_EXP_COND_PAG, REL.CALC_EXP_COND_PAG, '', 'CALC_EXP_COND_PAG.') || decode(RJ.CALC_EXP_COND_VENDA, REL.CALC_EXP_COND_VENDA, '', 'CALC_EXP_COND_VENDA.') || decode(RJ.CALC_IMP_TOT_ITEM, REL.CALC_IMP_TOT_ITEM, '', 'CALC_IMP_TOT_ITEM.') || decode(RJ.CALC_IMP_TOT_EMB, REL.CALC_IMP_TOT_EMB, '', 'CALC_IMP_TOT_EMB.') || decode(RJ.CALC_IMP_COND_PAG, REL.CALC_IMP_COND_PAG, '', 'CALC_IMP_COND_PAG.') || decode(RJ.CALC_IMP_COND_VENDA, REL.CALC_IMP_COND_VENDA, '', 'CALC_IMP_COND_VENDA.') || decode(RJ.CALC_FRETE_TOTAL, REL.CALC_FRETE_TOTAL, '', 'CALC_FRETE_TOTAL.') || decode(RJ.CALC_PEND, REL.CALC_PEND, '', 'CALC_PEND.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 
                'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.EMB RJ, CXSP.EMB@CXSP REL where   and RJ.REF = REL.REF and (decode (RJ.CALC_NOMINAL_PED,null,'n',RJ.CALC_NOMINAL_PED) <> decode(REL.CALC_NOMINAL_PED,null,'n',REL.CALC_NOMINAL_PED) OR decode (RJ.VIAGEM,null,'n',RJ.VIAGEM) <> decode(REL.VIAGEM,null,'n',REL.VIAGEM) OR decode (RJ.FRETE_UNID,null,'n',RJ.FRETE_UNID) <> decode(REL.FRETE_UNID,null,'n',REL.FRETE_UNID) OR decode (RJ.FRETE_VALOR,null,'n',RJ.FRETE_VALOR) <> decode(REL.FRETE_VALOR,null,'n',REL.FRETE_VALOR) OR decode (RJ.FRETE_POR_MT,null,'n',RJ.FRETE_POR_MT) <> decode(REL.FRETE_POR_MT,null,'n',REL.FRETE_POR_MT) OR decode (RJ.FRETE_VALOR_POR_UNID,null,'n',RJ.FRETE_VALOR_POR_UNID) <> decode(REL.FRETE_VALOR_POR_UNID,null,'n',REL.FRETE_VALOR_POR_UNID) OR decode (RJ.FRETE_VALOR_TOTAL,null,'n',RJ.FRETE_VALOR_TOTAL) <> decode(REL.FRETE_VALOR_TOTAL,null,'n',REL.FRETE_VALOR_TOTAL) OR decode (RJ.FRETE_COND,null,'n',RJ.FRETE_COND) <> decode(REL.FRETE_COND,null,'n',REL.FRETE_COND) OR decode (RJ.DATA_EMBARQUE,null,'n',RJ.DATA_EMBARQUE) <> decode(REL.DATA_EMBARQUE,null,'n',REL.DATA_EMBARQUE) OR decode (RJ.DATA_EMISSÃO_DOC,null,'n',RJ.DATA_EMISSÃO_DOC) <> decode(REL.DATA_EMISSÃO_DOC,null,'n',REL.DATA_EMISSÃO_DOC) OR 
                decode (RJ.CARGA_PORTO,null,'n',RJ.CARGA_PORTO) <> decode(REL.CARGA_PORTO,null,'n',REL.CARGA_PORTO) OR decode (RJ.DESCARGA_PORTO,null,'n',RJ.DESCARGA_PORTO) <> decode(REL.DESCARGA_PORTO,null,'n',REL.DESCARGA_PORTO) OR decode (RJ.TRANSPORTADOR,null,'n',RJ.TRANSPORTADOR) <> decode(REL.TRANSPORTADOR,null,'n',REL.TRANSPORTADOR) OR decode (RJ.MOEDA,null,'n',RJ.MOEDA) <> decode(REL.MOEDA,null,'n',REL.MOEDA) OR decode (RJ.IDIOMA,null,'n',RJ.IDIOMA) <> decode(REL.IDIOMA,null,'n',REL.IDIOMA) OR decode (RJ.PESO_UNID,null,'n',RJ.PESO_UNID) <> decode(REL.PESO_UNID,null,'n',REL.PESO_UNID) OR decode (RJ.PREÇO_UNITÁRIO_UNID,null,'n',RJ.PREÇO_UNITÁRIO_UNID) <> decode(REL.PREÇO_UNITÁRIO_UNID,null,'n',REL.PREÇO_UNITÁRIO_UNID) OR decode (RJ.PREÇO_UNID,null,'n',RJ.PREÇO_UNID) <> decode(REL.PREÇO_UNID,null,'n',REL.PREÇO_UNID) OR decode (RJ.NEGOCIADOR,null,'n',RJ.NEGOCIADOR) <> decode(REL.NEGOCIADOR,null,'n',REL.NEGOCIADOR) OR decode (RJ.EMBARCADOR,null,'n',RJ.EMBARCADOR) <> decode(REL.EMBARCADOR,null,'n',REL.EMBARCADOR) OR decode (RJ.EMB_ENDEREÇO,null,'n',RJ.EMB_ENDEREÇO) <> decode(REL.EMB_ENDEREÇO,null,'n',REL.EMB_ENDEREÇO) OR decode (RJ.EMB_PAÍS,null,'n',RJ.EMB_PAÍS) <> decode(REL.EMB_PAÍS,null,'n',REL.EMB_PAÍS) OR decode (RJ.EMB_COND_VENDA,null,'n',RJ.EMB_COND_VENDA) <> decode(REL.EMB_COND_VENDA,null,'n',REL.EMB_COND_VENDA) OR decode (RJ.EMB_COND_PAG,null,'n',RJ.EMB_COND_PAG) <> decode(REL.EMB_COND_PAG,null,'n',REL.EMB_COND_PAG) OR decode 
                (RJ.EMB_COMENTÁRIOS,null,'n',RJ.EMB_COMENTÁRIOS) <> decode(REL.EMB_COMENTÁRIOS,null,'n',REL.EMB_COMENTÁRIOS) OR decode (RJ.EXP,null,'n',RJ.EXP) <> decode(REL.EXP,null,'n',REL.EXP) OR decode (RJ.EXP_ENDEREÇO,null,'n',RJ.EXP_ENDEREÇO) <> decode(REL.EXP_ENDEREÇO,null,'n',REL.EXP_ENDEREÇO) OR decode (RJ.EXP_PAÍS,null,'n',RJ.EXP_PAÍS) <> decode(REL.EXP_PAÍS,null,'n',REL.EXP_PAÍS) OR decode (RJ.EXP_COND_VENDA,null,'n',RJ.EXP_COND_VENDA) <> decode(REL.EXP_COND_VENDA,null,'n',REL.EXP_COND_VENDA) OR decode (RJ.EXP_COND_PAG,null,'n',RJ.EXP_COND_PAG) <> decode(REL.EXP_COND_PAG,null,'n',REL.EXP_COND_PAG) OR decode (RJ.EXP_COMENTÁRIOS,null,'n',RJ.EXP_COMENTÁRIOS) <> decode(REL.EXP_COMENTÁRIOS,null,'n',REL.EXP_COMENTÁRIOS) OR decode (RJ.EXP_LOGOTIPO,null,'n',RJ.EXP_LOGOTIPO) <> decode(REL.EXP_LOGOTIPO,null,'n',REL.EXP_LOGOTIPO) OR decode (RJ.EXP_FAT,null,'n',RJ.EXP_FAT) <> decode(REL.EXP_FAT,null,'n',REL.EXP_FAT) OR decode (RJ.IMP,null,'n',RJ.IMP) <> decode(REL.IMP,null,'n',REL.IMP) OR decode (RJ.IMP_ENDEREÇO,null,'n',RJ.IMP_ENDEREÇO) <> decode(REL.IMP_ENDEREÇO,null,'n',REL.IMP_ENDEREÇO) OR decode (RJ.IMP_PAÍS,null,'n',RJ.IMP_PAÍS) <> decode(REL.IMP_PAÍS,null,'n',REL.IMP_PAÍS) OR decode (RJ.IMP_COND_VENDA,null,'n',RJ.IMP_COND_VENDA) <> decode(REL.IMP_COND_VENDA,null,'n',REL.IMP_COND_VENDA) OR decode (RJ.IMP_COND_PAG,null,'n',RJ.IMP_COND_PAG) <> decode(REL.IMP_COND_PAG,null,'n',REL.IMP_COND_PAG) OR decode 
                (RJ.IMP_COMENTÁRIOS,null,'n',RJ.IMP_COMENTÁRIOS) <> decode(REL.IMP_COMENTÁRIOS,null,'n',REL.IMP_COMENTÁRIOS) OR decode (RJ.IMP_LOGOTIPO,null,'n',RJ.IMP_LOGOTIPO) <> decode(REL.IMP_LOGOTIPO,null,'n',REL.IMP_LOGOTIPO) OR decode (RJ.IMP_FAT,null,'n',RJ.IMP_FAT) <> decode(REL.IMP_FAT,null,'n',REL.IMP_FAT) OR decode (RJ.PAGADOR,null,'n',RJ.PAGADOR) <> decode(REL.PAGADOR,null,'n',REL.PAGADOR) OR decode (RJ.PAG_ENDEREÇO,null,'n',RJ.PAG_ENDEREÇO) <> decode(REL.PAG_ENDEREÇO,null,'n',REL.PAG_ENDEREÇO) OR decode (RJ.PAG_PAÍS,null,'n',RJ.PAG_PAÍS) <> decode(REL.PAG_PAÍS,null,'n',REL.PAG_PAÍS) OR decode (RJ.CONSIGNATÁRIO,null,'n',RJ.CONSIGNATÁRIO) <> decode(REL.CONSIGNATÁRIO,null,'n',REL.CONSIGNATÁRIO) OR decode (RJ.CONSIGN_ENDEREÇO,null,'n',RJ.CONSIGN_ENDEREÇO) <> decode(REL.CONSIGN_ENDEREÇO,null,'n',REL.CONSIGN_ENDEREÇO) OR decode (RJ.CONSIGN_PAÍS,null,'n',RJ.CONSIGN_PAÍS) <> decode(REL.CONSIGN_PAÍS,null,'n',REL.CONSIGN_PAÍS) OR decode (RJ.NOTIFICAR,null,'n',RJ.NOTIFICAR) <> decode(REL.NOTIFICAR,null,'n',REL.NOTIFICAR) OR decode (RJ.NOTIFICAR_ENDEREÇO,null,'n',RJ.NOTIFICAR_ENDEREÇO) <> decode(REL.NOTIFICAR_ENDEREÇO,null,'n',REL.NOTIFICAR_ENDEREÇO) OR decode (RJ.NOTIFICAR_PAÍS,null,'n',RJ.NOTIFICAR_PAÍS) <> decode(REL.NOTIFICAR_PAÍS,null,'n',REL.NOTIFICAR_PAÍS) OR decode (RJ.NUM_BL_DESCR,null,'n',RJ.NUM_BL_DESCR) <> decode(REL.NUM_BL_DESCR,null,'n',REL.NUM_BL_DESCR) OR decode (RJ.FAMÍLIA_GENÉRICA,null,'n',RJ.FAMÍLIA_GENÉRICA) <> 
                decode(REL.FAMÍLIA_GENÉRICA,null,'n',REL.FAMÍLIA_GENÉRICA) OR decode (RJ.TIPO_DESCR_MERCADORIA,null,'n',RJ.TIPO_DESCR_MERCADORIA) <> decode(REL.TIPO_DESCR_MERCADORIA,null,'n',REL.TIPO_DESCR_MERCADORIA) OR decode (RJ.MARCAÇÃO,null,'n',RJ.MARCAÇÃO) <> decode(REL.MARCAÇÃO,null,'n',REL.MARCAÇÃO) OR decode (RJ.TOTALIZAÇÃO_EMBALAGEM,null,'n',RJ.TOTALIZAÇÃO_EMBALAGEM) <> decode(REL.TOTALIZAÇÃO_EMBALAGEM,null,'n',REL.TOTALIZAÇÃO_EMBALAGEM) OR decode (RJ.CONFIG,null,'n',RJ.CONFIG) <> decode(REL.CONFIG,null,'n',REL.CONFIG) OR decode (RJ.EMB_ACORDO,null,'n',RJ.EMB_ACORDO) <> decode(REL.EMB_ACORDO,null,'n',REL.EMB_ACORDO) OR decode (RJ.VIA_TRANSPORTE,null,'n',RJ.VIA_TRANSPORTE) <> decode(REL.VIA_TRANSPORTE,null,'n',REL.VIA_TRANSPORTE) OR decode (RJ.CARTA_CRED_REF,null,'n',RJ.CARTA_CRED_REF) <> decode(REL.CARTA_CRED_REF,null,'n',REL.CARTA_CRED_REF) OR decode (RJ.EMB_DATA,null,'n',RJ.EMB_DATA) <> decode(REL.EMB_DATA,null,'n',REL.EMB_DATA) OR decode (RJ.CARTA_CRÉDITO_BANCO_ABRIDOR,null,'n',RJ.CARTA_CRÉDITO_BANCO_ABRIDOR) <> decode(REL.CARTA_CRÉDITO_BANCO_ABRIDOR,null,'n',REL.CARTA_CRÉDITO_BANCO_ABRIDOR) OR decode (RJ.CARTA_CRÉDITO_REF,null,'n',RJ.CARTA_CRÉDITO_REF) <> decode(REL.CARTA_CRÉDITO_REF,null,'n',REL.CARTA_CRÉDITO_REF) OR decode (RJ.BANCO_AVISADOR,null,'n',RJ.BANCO_AVISADOR) <> decode(REL.BANCO_AVISADOR,null,'n',REL.BANCO_AVISADOR) OR decode (RJ.BANCO_CONFIRM,null,'n',RJ.BANCO_CONFIRM) <> 
                decode(REL.BANCO_CONFIRM,null,'n',REL.BANCO_CONFIRM) OR decode (RJ.CALC_QTD_PED_UNID,null,'n',RJ.CALC_QTD_PED_UNID) <> decode(REL.CALC_QTD_PED_UNID,null,'n',REL.CALC_QTD_PED_UNID) OR decode (RJ.CALC_PESO_LÍQUIDO,null,'n',RJ.CALC_PESO_LÍQUIDO) <> decode(REL.CALC_PESO_LÍQUIDO,null,'n',REL.CALC_PESO_LÍQUIDO) OR decode (RJ.CALC_PESO_BRUTO,null,'n',RJ.CALC_PESO_BRUTO) <> decode(REL.CALC_PESO_BRUTO,null,'n',REL.CALC_PESO_BRUTO) OR decode (RJ.CALC_QTD_VOL,null,'n',RJ.CALC_QTD_VOL) <> decode(REL.CALC_QTD_VOL,null,'n',REL.CALC_QTD_VOL) OR decode (RJ.CALC_EXP_TOT_ITEM,null,'n',RJ.CALC_EXP_TOT_ITEM) <> decode(REL.CALC_EXP_TOT_ITEM,null,'n',REL.CALC_EXP_TOT_ITEM) OR decode (RJ.CALC_EXP_TOT_EMB,null,'n',RJ.CALC_EXP_TOT_EMB) <> decode(REL.CALC_EXP_TOT_EMB,null,'n',REL.CALC_EXP_TOT_EMB) OR decode (RJ.CALC_EXP_COND_PAG,null,'n',RJ.CALC_EXP_COND_PAG) <> decode(REL.CALC_EXP_COND_PAG,null,'n',REL.CALC_EXP_COND_PAG) OR decode (RJ.CALC_EXP_COND_VENDA,null,'n',RJ.CALC_EXP_COND_VENDA) <> decode(REL.CALC_EXP_COND_VENDA,null,'n',REL.CALC_EXP_COND_VENDA) OR decode (RJ.CALC_IMP_TOT_ITEM,null,'n',RJ.CALC_IMP_TOT_ITEM) <> decode(REL.CALC_IMP_TOT_ITEM,null,'n',REL.CALC_IMP_TOT_ITEM) OR decode (RJ.CALC_IMP_TOT_EMB,null,'n',RJ.CALC_IMP_TOT_EMB) <> decode(REL.CALC_IMP_TOT_EMB,null,'n',REL.CALC_IMP_TOT_EMB) OR decode (RJ.CALC_IMP_COND_PAG,null,'n',RJ.CALC_IMP_COND_PAG) <> decode(REL.CALC_IMP_COND_PAG,null,'n',REL.CALC_IMP_COND_PAG) OR decode 
                (RJ.CALC_IMP_COND_VENDA,null,'n',RJ.CALC_IMP_COND_VENDA) <> decode(REL.CALC_IMP_COND_VENDA,null,'n',REL.CALC_IMP_COND_VENDA) OR decode (RJ.CALC_FRETE_TOTAL,null,'n',RJ.CALC_FRETE_TOTAL) <> decode(REL.CALC_FRETE_TOTAL,null,'n',REL.CALC_FRETE_TOTAL) OR decode (RJ.CALC_PEND,null,'n',RJ.CALC_PEND) <> decode(REL.CALC_PEND,null,'n',REL.CALC_PEND) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> EMB QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif EMB que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- PED_RESULT QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.PED_REF || '.' || RJ.SEQ chk from CXRJ.PED_RESULT RJ, CXSP.PED_RESULT@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.PED_REF = REL.PED_REF (+) and RJ.SEQ = REL.SEQ (+) and REL.PED_REF is null AND RJ.PED_REF LIKE 'BH%';
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED_RESULT QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED_RESULT que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PED_RESULT QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.PED_REF || '.' || REL.SEQ chk from CXSP.PED_RESULT@CXSP REL, CXRJ.PED_RESULT RJ where REL.PED_REF = RJ.PED_REF (+) and REL.SEQ = RJ.SEQ (+) and RJ.PED_REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED_RESULT QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED_RESULT que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PED_RESULT QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.PED_REF || '.' || RJ.SEQ || ' -> ' || decode(RJ.LANÇ, REL.LANÇ, '', 'LANÇ.') || decode(RJ.VALOR, REL.VALOR, '', 'VALOR.') || decode(RJ.VALOR_POR_MT, REL.VALOR_POR_MT, '', 'VALOR_POR_MT.') || decode(RJ.TOTAL_PERCENT, REL.TOTAL_PERCENT, '', 'TOTAL_PERCENT.') || decode(RJ.TOTAL_TIPO, REL.TOTAL_TIPO, '', 'TOTAL_TIPO.') || decode(RJ.COMPETÊNCIA, REL.COMPETÊNCIA, '', 'COMPETÊNCIA.') || decode(RJ.CALC, REL.CALC, '', 'CALC.') || decode(RJ.OBS, REL.OBS, '', 'OBS.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.PED_RESULT RJ, CXSP.PED_RESULT@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.PED_REF = REL.PED_REF and RJ.SEQ = REL.SEQ and (decode (RJ.LANÇ,null,'n',RJ.LANÇ) <> decode(REL.LANÇ,null,'n',REL.LANÇ) OR decode (RJ.VALOR,null,'n',RJ.VALOR) <> decode(REL.VALOR,null,'n',REL.VALOR) OR decode 
                (RJ.VALOR_POR_MT,null,'n',RJ.VALOR_POR_MT) <> decode(REL.VALOR_POR_MT,null,'n',REL.VALOR_POR_MT) OR decode (RJ.TOTAL_PERCENT,null,'n',RJ.TOTAL_PERCENT) <> decode(REL.TOTAL_PERCENT,null,'n',REL.TOTAL_PERCENT) OR decode (RJ.TOTAL_TIPO,null,'n',RJ.TOTAL_TIPO) <> decode(REL.TOTAL_TIPO,null,'n',REL.TOTAL_TIPO) OR decode (RJ.COMPETÊNCIA,null,'n',RJ.COMPETÊNCIA) <> decode(REL.COMPETÊNCIA,null,'n',REL.COMPETÊNCIA) OR decode (RJ.CALC,null,'n',RJ.CALC) <> decode(REL.CALC,null,'n',REL.CALC) OR decode (RJ.OBS,null,'n',RJ.OBS) <> decode(REL.OBS,null,'n',REL.OBS) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED_RESULT QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED_RESULT que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- PED_LANÇ QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.PED_REF || '.' || RJ.SEQ chk from CXRJ.PED_LANÇ RJ, CXSP.PED_LANÇ@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.PED_REF = REL.PED_REF (+) and RJ.SEQ = REL.SEQ (+) and REL.PED_REF is null AND RJ.PED_REF LIKE 'BH%';
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED_LANÇ QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED_LANÇ que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PED_LANÇ QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.PED_REF || '.' || REL.SEQ chk from CXSP.PED_LANÇ@CXSP REL, CXRJ.PED_LANÇ RJ where REL.PED_REF = RJ.PED_REF (+) and REL.SEQ = RJ.SEQ (+) and RJ.PED_REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED_LANÇ QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED_LANÇ que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PED_LANÇ QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.PED_REF || '.' || RJ.SEQ || ' -> ' || decode(RJ.LANÇ, REL.LANÇ, '', 'LANÇ.') || decode(RJ.VALOR, REL.VALOR, '', 'VALOR.') || decode(RJ.VALOR_POR_MT, REL.VALOR_POR_MT, '', 'VALOR_POR_MT.') || decode(RJ.TOTAL_PERCENT, REL.TOTAL_PERCENT, '', 'TOTAL_PERCENT.') || decode(RJ.TOTAL_TIPO, REL.TOTAL_TIPO, '', 'TOTAL_TIPO.') || decode(RJ.EXP, REL.EXP, '', 'EXP.') || decode(RJ.IMP, REL.IMP, '', 'IMP.') || decode(RJ.BENEFICIÁRIO, REL.BENEFICIÁRIO, '', 'BENEFICIÁRIO.') || decode(RJ.COMISSÃO_MODALIDADE, REL.COMISSÃO_MODALIDADE, '', 'COMISSÃO_MODALIDADE.') || decode(RJ.INSTRUÇÃO_REMESSA, REL.INSTRUÇÃO_REMESSA, '', 'INSTRUÇÃO_REMESSA.') || decode(RJ.EXP_CALC, REL.EXP_CALC, '', 'EXP_CALC.') || decode(RJ.IMP_CALC, REL.IMP_CALC, '', 'IMP_CALC.') || decode(RJ.OBS, REL.OBS, '', 'OBS.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, 
                '', 'SYS_STATUS.') chk from CXRJ.PED_LANÇ RJ, CXSP.PED_LANÇ@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.PED_REF = REL.PED_REF and RJ.SEQ = REL.SEQ and (decode (RJ.LANÇ,null,'n',RJ.LANÇ) <> decode(REL.LANÇ,null,'n',REL.LANÇ) OR decode (RJ.VALOR,null,'n',RJ.VALOR) <> decode(REL.VALOR,null,'n',REL.VALOR) OR decode (RJ.VALOR_POR_MT,null,'n',RJ.VALOR_POR_MT) <> decode(REL.VALOR_POR_MT,null,'n',REL.VALOR_POR_MT) OR decode (RJ.TOTAL_PERCENT,null,'n',RJ.TOTAL_PERCENT) <> decode(REL.TOTAL_PERCENT,null,'n',REL.TOTAL_PERCENT) OR decode (RJ.TOTAL_TIPO,null,'n',RJ.TOTAL_TIPO) <> decode(REL.TOTAL_TIPO,null,'n',REL.TOTAL_TIPO) OR decode (RJ.EXP,null,'n',RJ.EXP) <> decode(REL.EXP,null,'n',REL.EXP) OR decode (RJ.IMP,null,'n',RJ.IMP) <> decode(REL.IMP,null,'n',REL.IMP) OR decode (RJ.BENEFICIÁRIO,null,'n',RJ.BENEFICIÁRIO) <> decode(REL.BENEFICIÁRIO,null,'n',REL.BENEFICIÁRIO) OR decode (RJ.COMISSÃO_MODALIDADE,null,'n',RJ.COMISSÃO_MODALIDADE) <> decode(REL.COMISSÃO_MODALIDADE,null,'n',REL.COMISSÃO_MODALIDADE) OR decode (RJ.INSTRUÇÃO_REMESSA,null,'n',RJ.INSTRUÇÃO_REMESSA) <> decode(REL.INSTRUÇÃO_REMESSA,null,'n',REL.INSTRUÇÃO_REMESSA) OR decode (RJ.EXP_CALC,null,'n',RJ.EXP_CALC) <> decode(REL.EXP_CALC,null,'n',REL.EXP_CALC) OR decode (RJ.IMP_CALC,null,'n',RJ.IMP_CALC) <> decode(REL.IMP_CALC,null,'n',REL.IMP_CALC) OR decode (RJ.OBS,null,'n',RJ.OBS) <> decode(REL.OBS,null,'n',REL.OBS) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> 
                decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED_LANÇ QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED_LANÇ que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- PED_ITEM QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.PED_REF || '.' || RJ.ITEM chk from CXRJ.PED_ITEM RJ, CXSP.PED_ITEM@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.PED_REF = REL.PED_REF (+) and RJ.ITEM = REL.ITEM (+) and REL.PED_REF is null AND RJ.PED_REF LIKE 'BH%';
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED_ITEM QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED_ITEM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PED_ITEM QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.PED_REF || '.' || REL.ITEM chk from CXSP.PED_ITEM@CXSP REL, CXRJ.PED_ITEM RJ where REL.PED_REF = RJ.PED_REF (+) and REL.ITEM = RJ.ITEM (+) and RJ.PED_REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED_ITEM QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED_ITEM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PED_ITEM QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.PED_REF || '.' || RJ.ITEM || ' -> ' || decode(RJ.USUÁRIO_FINAL, REL.USUÁRIO_FINAL, '', 'USUÁRIO_FINAL.') || decode(RJ.USUÁRIO_REF, REL.USUÁRIO_REF, '', 'USUÁRIO_REF.') || decode(RJ.PED_UNID, REL.PED_UNID, '', 'PED_UNID.') || decode(RJ.NOMINAL_PED_UNID, REL.NOMINAL_PED_UNID, '', 'NOMINAL_PED_UNID.') || decode(RJ.TOTAL_FECH, REL.TOTAL_FECH, '', 'TOTAL_FECH.') || decode(RJ.TOTAL_EMB, REL.TOTAL_EMB, '', 'TOTAL_EMB.') || decode(RJ.TOLERÂNCIA_MIN, REL.TOLERÂNCIA_MIN, '', 'TOLERÂNCIA_MIN.') || decode(RJ.TOLERÂNCIA_MAX, REL.TOLERÂNCIA_MAX, '', 'TOLERÂNCIA_MAX.') || decode(RJ.PROD, REL.PROD, '', 'PROD.') || decode(RJ.DESCARGA_PORTO, REL.DESCARGA_PORTO, '', 'DESCARGA_PORTO.') || decode(RJ.EMBALAGEM, REL.EMBALAGEM, '', 'EMBALAGEM.') || decode(RJ.EMBALAGEM_PESO_MIN, REL.EMBALAGEM_PESO_MIN, '', 'EMBALAGEM_PESO_MIN.') || decode(RJ.EMBALAGEM_PESO_MAX, REL.EMBALAGEM_PESO_MAX, '', 'EMBALAGEM_PESO_MAX.') || decode(RJ.PREÇO_UNITÁRIO_FORNECEDOR, REL.PREÇO_UNITÁRIO_FORNECEDOR, '', 'PREÇO_UNITÁRIO_FORNECEDOR.') || decode(RJ.PREÇO_UNITÁRIO_EXP, REL.PREÇO_UNITÁRIO_EXP, '', 'PREÇO_UNITÁRIO_EXP.') || decode(RJ.PREÇO_UNITÁRIO_IMP, REL.PREÇO_UNITÁRIO_IMP, '', 'PREÇO_UNITÁRIO_IMP.') || decode(RJ.ESPESSURA_TIPO, REL.ESPESSURA_TIPO, '', 'ESPESSURA_TIPO.') || decode(RJ.ESPESSURA_MM, REL.ESPESSURA_MM, '', 'ESPESSURA_MM.') 
                || decode(RJ.LARGURA_MM, REL.LARGURA_MM, '', 'LARGURA_MM.') || decode(RJ.COMPRIMENTO_MM, REL.COMPRIMENTO_MM, '', 'COMPRIMENTO_MM.') || decode(RJ.ESPESSURA_POL, REL.ESPESSURA_POL, '', 'ESPESSURA_POL.') || decode(RJ.LARGURA_POL, REL.LARGURA_POL, '', 'LARGURA_POL.') || decode(RJ.COMPRIMENTO_POL, REL.COMPRIMENTO_POL, '', 'COMPRIMENTO_POL.') || decode(RJ.NCM, REL.NCM, '', 'NCM.') || decode(RJ.NALADI, REL.NALADI, '', 'NALADI.') || decode(RJ.P, REL.P, '', 'P.') || decode(RJ.LOTE, REL.LOTE, '', 'LOTE.') || decode(RJ.OV, REL.OV, '', 'OV.') || decode(RJ.NE_ITEM, REL.NE_ITEM, '', 'NE_ITEM.') || decode(RJ.NE_ENVIO, REL.NE_ENVIO, '', 'NE_ENVIO.') || decode(RJ.TBN, REL.TBN, '', 'TBN.') || decode(RJ.FSE, REL.FSE, '', 'FSE.') || decode(RJ.PO, REL.PO, '', 'PO.') || decode(RJ.BL_CODE, REL.BL_CODE, '', 'BL_CODE.') || decode(RJ.USO_FINAL, REL.USO_FINAL, '', 'USO_FINAL.') || decode(RJ.DIÂMETRO_INTERNO, REL.DIÂMETRO_INTERNO, '', 'DIÂMETRO_INTERNO.') || decode(RJ.DIÂMETRO_EXTERNO, REL.DIÂMETRO_EXTERNO, '', 'DIÂMETRO_EXTERNO.') || decode(RJ.PESO_POR_FOLHA, REL.PESO_POR_FOLHA, '', 'PESO_POR_FOLHA.') || decode(RJ.AÇO_TIPO, REL.AÇO_TIPO, '', 'AÇO_TIPO.') || decode(RJ.REVESTIMENTO, REL.REVESTIMENTO, '', 'REVESTIMENTO.') || decode(RJ.TÊMPERA, REL.TÊMPERA, '', 'TÊMPERA.') || decode(RJ.ACABAMENTO, REL.ACABAMENTO, '', 'ACABAMENTO.') || decode(RJ.NORMA_TOLERÂNCIA, REL.NORMA_TOLERÂNCIA, '', 'NORMA_TOLERÂNCIA.') || decode(RJ.NORMA_PRODUÇÃO, REL.NORMA_PRODUÇÃO, 
                '', 'NORMA_PRODUÇÃO.') || decode(RJ.BORDAS, REL.BORDAS, '', 'BORDAS.') || decode(RJ.OLEAMENTO, REL.OLEAMENTO, '', 'OLEAMENTO.') || decode(RJ.TRAT_TÉRMICO, REL.TRAT_TÉRMICO, '', 'TRAT_TÉRMICO.') || decode(RJ.TRAT_QUÍMICO, REL.TRAT_QUÍMICO, '', 'TRAT_QUÍMICO.') || decode(RJ.LA, REL.LA, '', 'LA.') || decode(RJ.LE, REL.LE, '', 'LE.') || decode(RJ.LÍNGUA, REL.LÍNGUA, '', 'LÍNGUA.') || decode(RJ.PROD_DESCR, REL.PROD_DESCR, '', 'PROD_DESCR.') || decode(RJ.COMPOSIÇÃO_QUÍMICA, REL.COMPOSIÇÃO_QUÍMICA, '', 'COMPOSIÇÃO_QUÍMICA.') || decode(RJ.MARCAÇÃO_PRODUÇÃO, REL.MARCAÇÃO_PRODUÇÃO, '', 'MARCAÇÃO_PRODUÇÃO.') || decode(RJ.COMENTÁRIO, REL.COMENTÁRIO, '', 'COMENTÁRIO.') || decode(RJ.PED_USINA_DATA, REL.PED_USINA_DATA, '', 'PED_USINA_DATA.') || decode(RJ.PED_USINA_ID, REL.PED_USINA_ID, '', 'PED_USINA_ID.') || decode(RJ.PED_USINA_CONFIRM, REL.PED_USINA_CONFIRM, '', 'PED_USINA_CONFIRM.') || decode(RJ.LAYDAY_INÍCIO, REL.LAYDAY_INÍCIO, '', 'LAYDAY_INÍCIO.') || decode(RJ.LAYDAY_FINAL, REL.LAYDAY_FINAL, '', 'LAYDAY_FINAL.') || decode(RJ.QTD_VOL, REL.QTD_VOL, '', 'QTD_VOL.') || decode(RJ.PESO_LÍQUIDO, REL.PESO_LÍQUIDO, '', 'PESO_LÍQUIDO.') || decode(RJ.PESO_BRUTO, REL.PESO_BRUTO, '', 'PESO_BRUTO.') || decode(RJ.FECH_REQUISITADO, REL.FECH_REQUISITADO, '', 'FECH_REQUISITADO.') || decode(RJ.FECH_NOTIFICADO, REL.FECH_NOTIFICADO, '', 'FECH_NOTIFICADO.') || decode(RJ.CANCEL_DATA, REL.CANCEL_DATA, '', 'CANCEL_DATA.') || decode(RJ.CANCEL_MOTIVO, 
                REL.CANCEL_MOTIVO, '', 'CANCEL_MOTIVO.') || decode(RJ.SEGURO_PERCENT, REL.SEGURO_PERCENT, '', 'SEGURO_PERCENT.') || decode(RJ.CUR_PERCENT, REL.CUR_PERCENT, '', 'CUR_PERCENT.') || decode(RJ.SUPERFÍCIE, REL.SUPERFÍCIE, '', 'SUPERFÍCIE.') || decode(RJ.DIAMET_INT_MAX_TOLER, REL.DIAMET_INT_MAX_TOLER, '', 'DIAMET_INT_MAX_TOLER.') || decode(RJ.DIAMET_INT_MIM_TOLER, REL.DIAMET_INT_MIM_TOLER, '', 'DIAMET_INT_MIM_TOLER.') || decode(RJ.TQ, REL.TQ, '', 'TQ.') || decode(RJ.CERTIF_QUALIDADE, REL.CERTIF_QUALIDADE, '', 'CERTIF_QUALIDADE.') || decode(RJ.RABO_PEIXE, REL.RABO_PEIXE, '', 'RABO_PEIXE.') || decode(RJ.RABO_PEIXE_MAX, REL.RABO_PEIXE_MAX, '', 'RABO_PEIXE_MAX.') || decode(RJ.LÍNGUA_MAX, REL.LÍNGUA_MAX, '', 'LÍNGUA_MAX.') || decode(RJ.MARCAÇÃO_ESPECIAL_DOC, REL.MARCAÇÃO_ESPECIAL_DOC, '', 'MARCAÇÃO_ESPECIAL_DOC.') || decode(RJ.OBS, REL.OBS, '', 'OBS.') || decode(RJ.MARCAÇÃO, REL.MARCAÇÃO, '', 'MARCAÇÃO.') || decode(RJ.NOMINAL_MT, REL.NOMINAL_MT, '', 'NOMINAL_MT.') || decode(RJ.DIMENSÃO, REL.DIMENSÃO, '', 'DIMENSÃO.') || decode(RJ.TOL_CSN, REL.TOL_CSN, '', 'TOL_CSN.') || decode(RJ.RECOZIDO_CSN, REL.RECOZIDO_CSN, '', 'RECOZIDO_CSN.') || decode(RJ.TOL_ESPESSURA_CSN, REL.TOL_ESPESSURA_CSN, '', 'TOL_ESPESSURA_CSN.') || decode(RJ.TOL_LARGURA_CSN, REL.TOL_LARGURA_CSN, '', 'TOL_LARGURA_CSN.') || decode(RJ.TOL_COMPRIMENTO_CSN, REL.TOL_COMPRIMENTO_CSN, '', 'TOL_COMPRIMENTO_CSN.') || decode(RJ.MARCAÇÃO_DIF_CSN, REL.MARCAÇÃO_DIF_CSN, '', 
                'MARCAÇÃO_DIF_CSN.') || decode(RJ.FACE_PESADA_CSN, REL.FACE_PESADA_CSN, '', 'FACE_PESADA_CSN.') || decode(RJ.APLAINAMENTO_CSN, REL.APLAINAMENTO_CSN, '', 'APLAINAMENTO_CSN.') || decode(RJ.PASSIVAÇÃO_CSN, REL.PASSIVAÇÃO_CSN, '', 'PASSIVAÇÃO_CSN.') || decode(RJ.ACABAMENTO_CSN, REL.ACABAMENTO_CSN, '', 'ACABAMENTO_CSN.') || decode(RJ.FAIXA_PESO_CSN, REL.FAIXA_PESO_CSN, '', 'FAIXA_PESO_CSN.') || decode(RJ.SOLDAS_CSN, REL.SOLDAS_CSN, '', 'SOLDAS_CSN.') || decode(RJ.NUM_SOLDAS_CSN, REL.NUM_SOLDAS_CSN, '', 'NUM_SOLDAS_CSN.') || decode(RJ.MARCAÇÃO_SOLDA_CSN, REL.MARCAÇÃO_SOLDA_CSN, '', 'MARCAÇÃO_SOLDA_CSN.') || decode(RJ.VERNIZ_DOURADO_CSN, REL.VERNIZ_DOURADO_CSN, '', 'VERNIZ_DOURADO_CSN.') || decode(RJ.POSIÇÃO_FOLHA_PALLET_CSN, REL.POSIÇÃO_FOLHA_PALLET_CSN, '', 'POSIÇÃO_FOLHA_PALLET_CSN.') || decode(RJ.RUGOSIDADE_CSN, REL.RUGOSIDADE_CSN, '', 'RUGOSIDADE_CSN.') || decode(RJ.ESQUADRIA_CSN, REL.ESQUADRIA_CSN, '', 'ESQUADRIA_CSN.') || decode(RJ.NUM_CONSULTA_CSN, REL.NUM_CONSULTA_CSN, '', 'NUM_CONSULTA_CSN.') || decode(RJ.TOLERÂNCIA_PADRÃO_CSN, REL.TOLERÂNCIA_PADRÃO_CSN, '', 'TOLERÂNCIA_PADRÃO_CSN.') || decode(RJ.MARCAÇOES_ADICIONAIS_CSN, REL.MARCAÇOES_ADICIONAIS_CSN, '', 'MARCAÇOES_ADICIONAIS_CSN.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || 
                decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.PED_ITEM RJ, CXSP.PED_ITEM@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.PED_REF = REL.PED_REF and RJ.ITEM = REL.ITEM and (decode (RJ.USUÁRIO_FINAL,null,'n',RJ.USUÁRIO_FINAL) <> decode(REL.USUÁRIO_FINAL,null,'n',REL.USUÁRIO_FINAL) OR decode (RJ.USUÁRIO_REF,null,'n',RJ.USUÁRIO_REF) <> decode(REL.USUÁRIO_REF,null,'n',REL.USUÁRIO_REF) OR decode (RJ.PED_UNID,null,'n',RJ.PED_UNID) <> decode(REL.PED_UNID,null,'n',REL.PED_UNID) OR decode (RJ.NOMINAL_PED_UNID,null,'n',RJ.NOMINAL_PED_UNID) <> decode(REL.NOMINAL_PED_UNID,null,'n',REL.NOMINAL_PED_UNID) OR decode (RJ.TOTAL_FECH,null,'n',RJ.TOTAL_FECH) <> decode(REL.TOTAL_FECH,null,'n',REL.TOTAL_FECH) OR decode (RJ.TOTAL_EMB,null,'n',RJ.TOTAL_EMB) <> decode(REL.TOTAL_EMB,null,'n',REL.TOTAL_EMB) OR decode (RJ.TOLERÂNCIA_MIN,null,'n',RJ.TOLERÂNCIA_MIN) <> decode(REL.TOLERÂNCIA_MIN,null,'n',REL.TOLERÂNCIA_MIN) OR decode (RJ.TOLERÂNCIA_MAX,null,'n',RJ.TOLERÂNCIA_MAX) <> decode(REL.TOLERÂNCIA_MAX,null,'n',REL.TOLERÂNCIA_MAX) OR decode (RJ.PROD,null,'n',RJ.PROD) <> decode(REL.PROD,null,'n',REL.PROD) OR decode (RJ.DESCARGA_PORTO,null,'n',RJ.DESCARGA_PORTO) <> 
                decode(REL.DESCARGA_PORTO,null,'n',REL.DESCARGA_PORTO) OR decode (RJ.EMBALAGEM,null,'n',RJ.EMBALAGEM) <> decode(REL.EMBALAGEM,null,'n',REL.EMBALAGEM) OR decode (RJ.EMBALAGEM_PESO_MIN,null,'n',RJ.EMBALAGEM_PESO_MIN) <> decode(REL.EMBALAGEM_PESO_MIN,null,'n',REL.EMBALAGEM_PESO_MIN) OR decode (RJ.EMBALAGEM_PESO_MAX,null,'n',RJ.EMBALAGEM_PESO_MAX) <> decode(REL.EMBALAGEM_PESO_MAX,null,'n',REL.EMBALAGEM_PESO_MAX) OR decode (RJ.PREÇO_UNITÁRIO_FORNECEDOR,null,'n',RJ.PREÇO_UNITÁRIO_FORNECEDOR) <> decode(REL.PREÇO_UNITÁRIO_FORNECEDOR,null,'n',REL.PREÇO_UNITÁRIO_FORNECEDOR) OR decode (RJ.PREÇO_UNITÁRIO_EXP,null,'n',RJ.PREÇO_UNITÁRIO_EXP) <> decode(REL.PREÇO_UNITÁRIO_EXP,null,'n',REL.PREÇO_UNITÁRIO_EXP) OR decode (RJ.PREÇO_UNITÁRIO_IMP,null,'n',RJ.PREÇO_UNITÁRIO_IMP) <> decode(REL.PREÇO_UNITÁRIO_IMP,null,'n',REL.PREÇO_UNITÁRIO_IMP) OR decode (RJ.ESPESSURA_TIPO,null,'n',RJ.ESPESSURA_TIPO) <> decode(REL.ESPESSURA_TIPO,null,'n',REL.ESPESSURA_TIPO) OR decode (RJ.ESPESSURA_MM,null,'n',RJ.ESPESSURA_MM) <> decode(REL.ESPESSURA_MM,null,'n',REL.ESPESSURA_MM) OR decode (RJ.LARGURA_MM,null,'n',RJ.LARGURA_MM) <> decode(REL.LARGURA_MM,null,'n',REL.LARGURA_MM) OR decode (RJ.COMPRIMENTO_MM,null,'n',RJ.COMPRIMENTO_MM) <> decode(REL.COMPRIMENTO_MM,null,'n',REL.COMPRIMENTO_MM) OR decode (RJ.ESPESSURA_POL,null,'n',RJ.ESPESSURA_POL) <> decode(REL.ESPESSURA_POL,null,'n',REL.ESPESSURA_POL) OR decode (RJ.LARGURA_POL,null,'n',RJ.LARGURA_POL) <> 
                decode(REL.LARGURA_POL,null,'n',REL.LARGURA_POL) OR decode (RJ.COMPRIMENTO_POL,null,'n',RJ.COMPRIMENTO_POL) <> decode(REL.COMPRIMENTO_POL,null,'n',REL.COMPRIMENTO_POL) OR decode (RJ.NCM,null,'n',RJ.NCM) <> decode(REL.NCM,null,'n',REL.NCM) OR decode (RJ.NALADI,null,'n',RJ.NALADI) <> decode(REL.NALADI,null,'n',REL.NALADI) OR decode (RJ.P,null,'n',RJ.P) <> decode(REL.P,null,'n',REL.P) OR decode (RJ.LOTE,null,'n',RJ.LOTE) <> decode(REL.LOTE,null,'n',REL.LOTE) OR decode (RJ.OV,null,'n',RJ.OV) <> decode(REL.OV,null,'n',REL.OV) OR decode (RJ.NE_ITEM,null,'n',RJ.NE_ITEM) <> decode(REL.NE_ITEM,null,'n',REL.NE_ITEM) OR decode (RJ.NE_ENVIO,null,'n',RJ.NE_ENVIO) <> decode(REL.NE_ENVIO,null,'n',REL.NE_ENVIO) OR decode (RJ.TBN,null,'n',RJ.TBN) <> decode(REL.TBN,null,'n',REL.TBN) OR decode (RJ.FSE,null,'n',RJ.FSE) <> decode(REL.FSE,null,'n',REL.FSE) OR decode (RJ.PO,null,'n',RJ.PO) <> decode(REL.PO,null,'n',REL.PO) OR decode (RJ.BL_CODE,null,'n',RJ.BL_CODE) <> decode(REL.BL_CODE,null,'n',REL.BL_CODE) OR decode (RJ.USO_FINAL,null,'n',RJ.USO_FINAL) <> decode(REL.USO_FINAL,null,'n',REL.USO_FINAL) OR decode (RJ.DIÂMETRO_INTERNO,null,'n',RJ.DIÂMETRO_INTERNO) <> decode(REL.DIÂMETRO_INTERNO,null,'n',REL.DIÂMETRO_INTERNO) OR decode (RJ.DIÂMETRO_EXTERNO,null,'n',RJ.DIÂMETRO_EXTERNO) <> decode(REL.DIÂMETRO_EXTERNO,null,'n',REL.DIÂMETRO_EXTERNO) OR decode (RJ.PESO_POR_FOLHA,null,'n',RJ.PESO_POR_FOLHA) <> 
                decode(REL.PESO_POR_FOLHA,null,'n',REL.PESO_POR_FOLHA) OR decode (RJ.AÇO_TIPO,null,'n',RJ.AÇO_TIPO) <> decode(REL.AÇO_TIPO,null,'n',REL.AÇO_TIPO) OR decode (RJ.REVESTIMENTO,null,'n',RJ.REVESTIMENTO) <> decode(REL.REVESTIMENTO,null,'n',REL.REVESTIMENTO) OR decode (RJ.TÊMPERA,null,'n',RJ.TÊMPERA) <> decode(REL.TÊMPERA,null,'n',REL.TÊMPERA) OR decode (RJ.ACABAMENTO,null,'n',RJ.ACABAMENTO) <> decode(REL.ACABAMENTO,null,'n',REL.ACABAMENTO) OR decode (RJ.NORMA_TOLERÂNCIA,null,'n',RJ.NORMA_TOLERÂNCIA) <> decode(REL.NORMA_TOLERÂNCIA,null,'n',REL.NORMA_TOLERÂNCIA) OR decode (RJ.NORMA_PRODUÇÃO,null,'n',RJ.NORMA_PRODUÇÃO) <> decode(REL.NORMA_PRODUÇÃO,null,'n',REL.NORMA_PRODUÇÃO) OR decode (RJ.BORDAS,null,'n',RJ.BORDAS) <> decode(REL.BORDAS,null,'n',REL.BORDAS) OR decode (RJ.OLEAMENTO,null,'n',RJ.OLEAMENTO) <> decode(REL.OLEAMENTO,null,'n',REL.OLEAMENTO) OR decode (RJ.TRAT_TÉRMICO,null,'n',RJ.TRAT_TÉRMICO) <> decode(REL.TRAT_TÉRMICO,null,'n',REL.TRAT_TÉRMICO) OR decode (RJ.TRAT_QUÍMICO,null,'n',RJ.TRAT_QUÍMICO) <> decode(REL.TRAT_QUÍMICO,null,'n',REL.TRAT_QUÍMICO) OR decode (RJ.LA,null,'n',RJ.LA) <> decode(REL.LA,null,'n',REL.LA) OR decode (RJ.LE,null,'n',RJ.LE) <> decode(REL.LE,null,'n',REL.LE) OR decode (RJ.LÍNGUA,null,'n',RJ.LÍNGUA) <> decode(REL.LÍNGUA,null,'n',REL.LÍNGUA) OR decode (RJ.PROD_DESCR,null,'n',RJ.PROD_DESCR) <> decode(REL.PROD_DESCR,null,'n',REL.PROD_DESCR) OR decode (RJ.COMPOSIÇÃO_QUÍMICA,null,'n',RJ.COMPOSIÇÃO_QUÍMICA) 
                <> decode(REL.COMPOSIÇÃO_QUÍMICA,null,'n',REL.COMPOSIÇÃO_QUÍMICA) OR decode (RJ.MARCAÇÃO_PRODUÇÃO,null,'n',RJ.MARCAÇÃO_PRODUÇÃO) <> decode(REL.MARCAÇÃO_PRODUÇÃO,null,'n',REL.MARCAÇÃO_PRODUÇÃO) OR decode (RJ.COMENTÁRIO,null,'n',RJ.COMENTÁRIO) <> decode(REL.COMENTÁRIO,null,'n',REL.COMENTÁRIO) OR decode (RJ.PED_USINA_DATA,null,'n',RJ.PED_USINA_DATA) <> decode(REL.PED_USINA_DATA,null,'n',REL.PED_USINA_DATA) OR decode (RJ.PED_USINA_ID,null,'n',RJ.PED_USINA_ID) <> decode(REL.PED_USINA_ID,null,'n',REL.PED_USINA_ID) OR decode (RJ.PED_USINA_CONFIRM,null,'n',RJ.PED_USINA_CONFIRM) <> decode(REL.PED_USINA_CONFIRM,null,'n',REL.PED_USINA_CONFIRM) OR decode (RJ.LAYDAY_INÍCIO,null,'n',RJ.LAYDAY_INÍCIO) <> decode(REL.LAYDAY_INÍCIO,null,'n',REL.LAYDAY_INÍCIO) OR decode (RJ.LAYDAY_FINAL,null,'n',RJ.LAYDAY_FINAL) <> decode(REL.LAYDAY_FINAL,null,'n',REL.LAYDAY_FINAL) OR decode (RJ.QTD_VOL,null,'n',RJ.QTD_VOL) <> decode(REL.QTD_VOL,null,'n',REL.QTD_VOL) OR decode (RJ.PESO_LÍQUIDO,null,'n',RJ.PESO_LÍQUIDO) <> decode(REL.PESO_LÍQUIDO,null,'n',REL.PESO_LÍQUIDO) OR decode (RJ.PESO_BRUTO,null,'n',RJ.PESO_BRUTO) <> decode(REL.PESO_BRUTO,null,'n',REL.PESO_BRUTO) OR decode (RJ.FECH_REQUISITADO,null,'n',RJ.FECH_REQUISITADO) <> decode(REL.FECH_REQUISITADO,null,'n',REL.FECH_REQUISITADO) OR decode (RJ.FECH_NOTIFICADO,null,'n',RJ.FECH_NOTIFICADO) <> decode(REL.FECH_NOTIFICADO,null,'n',REL.FECH_NOTIFICADO) OR decode (RJ.CANCEL_DATA,null,'n',RJ.CANCEL_DATA) <> 
                decode(REL.CANCEL_DATA,null,'n',REL.CANCEL_DATA) OR decode (RJ.CANCEL_MOTIVO,null,'n',RJ.CANCEL_MOTIVO) <> decode(REL.CANCEL_MOTIVO,null,'n',REL.CANCEL_MOTIVO) OR decode (RJ.SEGURO_PERCENT,null,'n',RJ.SEGURO_PERCENT) <> decode(REL.SEGURO_PERCENT,null,'n',REL.SEGURO_PERCENT) OR decode (RJ.CUR_PERCENT,null,'n',RJ.CUR_PERCENT) <> decode(REL.CUR_PERCENT,null,'n',REL.CUR_PERCENT) OR decode (RJ.SUPERFÍCIE,null,'n',RJ.SUPERFÍCIE) <> decode(REL.SUPERFÍCIE,null,'n',REL.SUPERFÍCIE) OR decode (RJ.DIAMET_INT_MAX_TOLER,null,'n',RJ.DIAMET_INT_MAX_TOLER) <> decode(REL.DIAMET_INT_MAX_TOLER,null,'n',REL.DIAMET_INT_MAX_TOLER) OR decode (RJ.DIAMET_INT_MIM_TOLER,null,'n',RJ.DIAMET_INT_MIM_TOLER) <> decode(REL.DIAMET_INT_MIM_TOLER,null,'n',REL.DIAMET_INT_MIM_TOLER) OR decode (RJ.TQ,null,'n',RJ.TQ) <> decode(REL.TQ,null,'n',REL.TQ) OR decode (RJ.CERTIF_QUALIDADE,null,'n',RJ.CERTIF_QUALIDADE) <> decode(REL.CERTIF_QUALIDADE,null,'n',REL.CERTIF_QUALIDADE) OR decode (RJ.RABO_PEIXE,null,'n',RJ.RABO_PEIXE) <> decode(REL.RABO_PEIXE,null,'n',REL.RABO_PEIXE) OR decode (RJ.RABO_PEIXE_MAX,null,'n',RJ.RABO_PEIXE_MAX) <> decode(REL.RABO_PEIXE_MAX,null,'n',REL.RABO_PEIXE_MAX) OR decode (RJ.LÍNGUA_MAX,null,'n',RJ.LÍNGUA_MAX) <> decode(REL.LÍNGUA_MAX,null,'n',REL.LÍNGUA_MAX) OR decode (RJ.MARCAÇÃO_ESPECIAL_DOC,null,'n',RJ.MARCAÇÃO_ESPECIAL_DOC) <> decode(REL.MARCAÇÃO_ESPECIAL_DOC,null,'n',REL.MARCAÇÃO_ESPECIAL_DOC) OR decode (RJ.OBS,null,'n',RJ.OBS) <> 
                decode(REL.OBS,null,'n',REL.OBS) OR decode (RJ.MARCAÇÃO,null,'n',RJ.MARCAÇÃO) <> decode(REL.MARCAÇÃO,null,'n',REL.MARCAÇÃO) OR decode (RJ.NOMINAL_MT,null,'n',RJ.NOMINAL_MT) <> decode(REL.NOMINAL_MT,null,'n',REL.NOMINAL_MT) OR decode (RJ.DIMENSÃO,null,'n',RJ.DIMENSÃO) <> decode(REL.DIMENSÃO,null,'n',REL.DIMENSÃO) OR decode (RJ.TOL_CSN,null,'n',RJ.TOL_CSN) <> decode(REL.TOL_CSN,null,'n',REL.TOL_CSN) OR decode (RJ.RECOZIDO_CSN,null,'n',RJ.RECOZIDO_CSN) <> decode(REL.RECOZIDO_CSN,null,'n',REL.RECOZIDO_CSN) OR decode (RJ.TOL_ESPESSURA_CSN,null,'n',RJ.TOL_ESPESSURA_CSN) <> decode(REL.TOL_ESPESSURA_CSN,null,'n',REL.TOL_ESPESSURA_CSN) OR decode (RJ.TOL_LARGURA_CSN,null,'n',RJ.TOL_LARGURA_CSN) <> decode(REL.TOL_LARGURA_CSN,null,'n',REL.TOL_LARGURA_CSN) OR decode (RJ.TOL_COMPRIMENTO_CSN,null,'n',RJ.TOL_COMPRIMENTO_CSN) <> decode(REL.TOL_COMPRIMENTO_CSN,null,'n',REL.TOL_COMPRIMENTO_CSN) OR decode (RJ.MARCAÇÃO_DIF_CSN,null,'n',RJ.MARCAÇÃO_DIF_CSN) <> decode(REL.MARCAÇÃO_DIF_CSN,null,'n',REL.MARCAÇÃO_DIF_CSN) OR decode (RJ.FACE_PESADA_CSN,null,'n',RJ.FACE_PESADA_CSN) <> decode(REL.FACE_PESADA_CSN,null,'n',REL.FACE_PESADA_CSN) OR decode (RJ.APLAINAMENTO_CSN,null,'n',RJ.APLAINAMENTO_CSN) <> decode(REL.APLAINAMENTO_CSN,null,'n',REL.APLAINAMENTO_CSN) OR decode (RJ.PASSIVAÇÃO_CSN,null,'n',RJ.PASSIVAÇÃO_CSN) <> decode(REL.PASSIVAÇÃO_CSN,null,'n',REL.PASSIVAÇÃO_CSN) OR decode (RJ.ACABAMENTO_CSN,null,'n',RJ.ACABAMENTO_CSN) <> 
                decode(REL.ACABAMENTO_CSN,null,'n',REL.ACABAMENTO_CSN) OR decode (RJ.FAIXA_PESO_CSN,null,'n',RJ.FAIXA_PESO_CSN) <> decode(REL.FAIXA_PESO_CSN,null,'n',REL.FAIXA_PESO_CSN) OR decode (RJ.SOLDAS_CSN,null,'n',RJ.SOLDAS_CSN) <> decode(REL.SOLDAS_CSN,null,'n',REL.SOLDAS_CSN) OR decode (RJ.NUM_SOLDAS_CSN,null,'n',RJ.NUM_SOLDAS_CSN) <> decode(REL.NUM_SOLDAS_CSN,null,'n',REL.NUM_SOLDAS_CSN) OR decode (RJ.MARCAÇÃO_SOLDA_CSN,null,'n',RJ.MARCAÇÃO_SOLDA_CSN) <> decode(REL.MARCAÇÃO_SOLDA_CSN,null,'n',REL.MARCAÇÃO_SOLDA_CSN) OR decode (RJ.VERNIZ_DOURADO_CSN,null,'n',RJ.VERNIZ_DOURADO_CSN) <> decode(REL.VERNIZ_DOURADO_CSN,null,'n',REL.VERNIZ_DOURADO_CSN) OR decode (RJ.POSIÇÃO_FOLHA_PALLET_CSN,null,'n',RJ.POSIÇÃO_FOLHA_PALLET_CSN) <> decode(REL.POSIÇÃO_FOLHA_PALLET_CSN,null,'n',REL.POSIÇÃO_FOLHA_PALLET_CSN) OR decode (RJ.RUGOSIDADE_CSN,null,'n',RJ.RUGOSIDADE_CSN) <> decode(REL.RUGOSIDADE_CSN,null,'n',REL.RUGOSIDADE_CSN) OR decode (RJ.ESQUADRIA_CSN,null,'n',RJ.ESQUADRIA_CSN) <> decode(REL.ESQUADRIA_CSN,null,'n',REL.ESQUADRIA_CSN) OR decode (RJ.NUM_CONSULTA_CSN,null,'n',RJ.NUM_CONSULTA_CSN) <> decode(REL.NUM_CONSULTA_CSN,null,'n',REL.NUM_CONSULTA_CSN) OR decode (RJ.TOLERÂNCIA_PADRÃO_CSN,null,'n',RJ.TOLERÂNCIA_PADRÃO_CSN) <> decode(REL.TOLERÂNCIA_PADRÃO_CSN,null,'n',REL.TOLERÂNCIA_PADRÃO_CSN) OR decode (RJ.MARCAÇOES_ADICIONAIS_CSN,null,'n',RJ.MARCAÇOES_ADICIONAIS_CSN) <> decode(REL.MARCAÇOES_ADICIONAIS_CSN,null,'n',REL.MARCAÇOES_ADICIONAIS_CSN) OR 
                decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED_ITEM QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED_ITEM que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- PED_CONTATO QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.PED_REF || '.' || RJ.CIA_COD || '.' || RJ.CONTATO_NOME chk from CXRJ.PED_CONTATO RJ, CXSP.PED_CONTATO@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.PED_REF = REL.PED_REF (+) and RJ.CIA_COD = REL.CIA_COD (+) and RJ.CONTATO_NOME = REL.CONTATO_NOME (+) and REL.PED_REF is null AND RJ.PED_REF LIKE 'BH%';
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED_CONTATO QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED_CONTATO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PED_CONTATO QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.PED_REF || '.' || REL.CIA_COD || '.' || REL.CONTATO_NOME chk from CXSP.PED_CONTATO@CXSP REL, CXRJ.PED_CONTATO RJ where REL.PED_REF = RJ.PED_REF (+) and REL.CIA_COD = RJ.CIA_COD (+) and REL.CONTATO_NOME = RJ.CONTATO_NOME (+) and RJ.PED_REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED_CONTATO QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED_CONTATO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- PED_CONTATO QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.PED_REF || '.' || RJ.CIA_COD || '.' || RJ.CONTATO_NOME || ' -> ' || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.PED_CONTATO RJ, CXSP.PED_CONTATO@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.PED_REF = REL.PED_REF and RJ.CIA_COD = REL.CIA_COD and RJ.CONTATO_NOME = REL.CONTATO_NOME and (decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode 
                (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> PED_CONTATO QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif PED_CONTATO que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- FECH QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.REF chk from CXRJ.FECH RJ, CXSP.FECH@CXSP REL where   and RJ.REF = REL.REF (+) and REL.REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> FECH QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif FECH que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- FECH QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.REF chk from CXSP.FECH@CXSP REL, CXRJ.FECH RJ where REL.REF = RJ.REF (+) and RJ.REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> FECH QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif FECH que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- FECH QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.REF || ' -> ' || decode(RJ.FECH_DATA, REL.FECH_DATA, '', 'FECH_DATA.') || decode(RJ.MOEDA, REL.MOEDA, '', 'MOEDA.') || decode(RJ.VIAGEM_REF, REL.VIAGEM_REF, '', 'VIAGEM_REF.') || decode(RJ.CARGA_PORTO_ESCALA, REL.CARGA_PORTO_ESCALA, '', 'CARGA_PORTO_ESCALA.') || decode(RJ.DESCARGA_PORTO_ESCALA, REL.DESCARGA_PORTO_ESCALA, '', 'DESCARGA_PORTO_ESCALA.') || decode(RJ.CONTRATANTE, REL.CONTRATANTE, '', 'CONTRATANTE.') || decode(RJ.CORRETOR, REL.CORRETOR, '', 'CORRETOR.') || decode(RJ.PROPRIETÁRIO, REL.PROPRIETÁRIO, '', 'PROPRIETÁRIO.') || decode(RJ.NEGOCIANTE, REL.NEGOCIANTE, '', 'NEGOCIANTE.') || decode(RJ.FRETE_DETALHE, REL.FRETE_DETALHE, '', 'FRETE_DETALHE.') || decode(RJ.FRETE_UNID, REL.FRETE_UNID, '', 'FRETE_UNID.') || decode(RJ.FRETE_VALOR, REL.FRETE_VALOR, '', 'FRETE_VALOR.') || decode(RJ.FRETE_VALOR_POR_UNID, REL.FRETE_VALOR_POR_UNID, '', 'FRETE_VALOR_POR_UNID.') || decode(RJ.FRETE_PAG_DETALHE, REL.FRETE_PAG_DETALHE, '', 'FRETE_PAG_DETALHE.') || decode(RJ.COMISSÃO_FRETE, REL.COMISSÃO_FRETE, '', 'COMISSÃO_FRETE.') || decode(RJ.COMISSÃO_BASE, REL.COMISSÃO_BASE, '', 'COMISSÃO_BASE.') || decode(RJ.COMISSÃO_PERCENT, REL.COMISSÃO_PERCENT, '', 'COMISSÃO_PERCENT.') || decode(RJ.CIA_PAGADORA, REL.CIA_PAGADORA, '', 'CIA_PAGADORA.') || decode(RJ.CARGA_AGENTE, REL.CARGA_AGENTE, '', 'CARGA_AGENTE.') 
                || decode(RJ.CARGA_ESTIVA, REL.CARGA_ESTIVA, '', 'CARGA_ESTIVA.') || decode(RJ.CARGA_ESTIVA_CUSTO, REL.CARGA_ESTIVA_CUSTO, '', 'CARGA_ESTIVA_CUSTO.') || decode(RJ.CARGA_DETALHE, REL.CARGA_DETALHE, '', 'CARGA_DETALHE.') || decode(RJ.CARGA_OBS, REL.CARGA_OBS, '', 'CARGA_OBS.') || decode(RJ.DESCARGA_AGENTE, REL.DESCARGA_AGENTE, '', 'DESCARGA_AGENTE.') || decode(RJ.DESCARGA_ESTIVA, REL.DESCARGA_ESTIVA, '', 'DESCARGA_ESTIVA.') || decode(RJ.DESCARGA_ESTIVA_CUSTO, REL.DESCARGA_ESTIVA_CUSTO, '', 'DESCARGA_ESTIVA_CUSTO.') || decode(RJ.DESCARGA_DETALHE, REL.DESCARGA_DETALHE, '', 'DESCARGA_DETALHE.') || decode(RJ.DESCARGA_OBS, REL.DESCARGA_OBS, '', 'DESCARGA_OBS.') || decode(RJ.DETENÇÃO, REL.DETENÇÃO, '', 'DETENÇÃO.') || decode(RJ.DEMORA, REL.DEMORA, '', 'DEMORA.') || decode(RJ.OBS, REL.OBS, '', 'OBS.') || decode(RJ.DESPACHANTE, REL.DESPACHANTE, '', 'DESPACHANTE.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.FECH RJ, 
                CXSP.FECH@CXSP REL where   and RJ.REF = REL.REF and (decode (RJ.FECH_DATA,null,'n',RJ.FECH_DATA) <> decode(REL.FECH_DATA,null,'n',REL.FECH_DATA) OR decode (RJ.MOEDA,null,'n',RJ.MOEDA) <> decode(REL.MOEDA,null,'n',REL.MOEDA) OR decode (RJ.VIAGEM_REF,null,'n',RJ.VIAGEM_REF) <> decode(REL.VIAGEM_REF,null,'n',REL.VIAGEM_REF) OR decode (RJ.CARGA_PORTO_ESCALA,null,'n',RJ.CARGA_PORTO_ESCALA) <> decode(REL.CARGA_PORTO_ESCALA,null,'n',REL.CARGA_PORTO_ESCALA) OR decode (RJ.DESCARGA_PORTO_ESCALA,null,'n',RJ.DESCARGA_PORTO_ESCALA) <> decode(REL.DESCARGA_PORTO_ESCALA,null,'n',REL.DESCARGA_PORTO_ESCALA) OR decode (RJ.CONTRATANTE,null,'n',RJ.CONTRATANTE) <> decode(REL.CONTRATANTE,null,'n',REL.CONTRATANTE) OR decode (RJ.CORRETOR,null,'n',RJ.CORRETOR) <> decode(REL.CORRETOR,null,'n',REL.CORRETOR) OR decode (RJ.PROPRIETÁRIO,null,'n',RJ.PROPRIETÁRIO) <> decode(REL.PROPRIETÁRIO,null,'n',REL.PROPRIETÁRIO) OR decode (RJ.NEGOCIANTE,null,'n',RJ.NEGOCIANTE) <> decode(REL.NEGOCIANTE,null,'n',REL.NEGOCIANTE) OR decode (RJ.FRETE_DETALHE,null,'n',RJ.FRETE_DETALHE) <> decode(REL.FRETE_DETALHE,null,'n',REL.FRETE_DETALHE) OR decode (RJ.FRETE_UNID,null,'n',RJ.FRETE_UNID) <> decode(REL.FRETE_UNID,null,'n',REL.FRETE_UNID) OR decode (RJ.FRETE_VALOR,null,'n',RJ.FRETE_VALOR) <> decode(REL.FRETE_VALOR,null,'n',REL.FRETE_VALOR) OR decode (RJ.FRETE_VALOR_POR_UNID,null,'n',RJ.FRETE_VALOR_POR_UNID) <> decode(REL.FRETE_VALOR_POR_UNID,null,'n',REL.FRETE_VALOR_POR_UNID) 
                OR decode (RJ.FRETE_PAG_DETALHE,null,'n',RJ.FRETE_PAG_DETALHE) <> decode(REL.FRETE_PAG_DETALHE,null,'n',REL.FRETE_PAG_DETALHE) OR decode (RJ.COMISSÃO_FRETE,null,'n',RJ.COMISSÃO_FRETE) <> decode(REL.COMISSÃO_FRETE,null,'n',REL.COMISSÃO_FRETE) OR decode (RJ.COMISSÃO_BASE,null,'n',RJ.COMISSÃO_BASE) <> decode(REL.COMISSÃO_BASE,null,'n',REL.COMISSÃO_BASE) OR decode (RJ.COMISSÃO_PERCENT,null,'n',RJ.COMISSÃO_PERCENT) <> decode(REL.COMISSÃO_PERCENT,null,'n',REL.COMISSÃO_PERCENT) OR decode (RJ.CIA_PAGADORA,null,'n',RJ.CIA_PAGADORA) <> decode(REL.CIA_PAGADORA,null,'n',REL.CIA_PAGADORA) OR decode (RJ.CARGA_AGENTE,null,'n',RJ.CARGA_AGENTE) <> decode(REL.CARGA_AGENTE,null,'n',REL.CARGA_AGENTE) OR decode (RJ.CARGA_ESTIVA,null,'n',RJ.CARGA_ESTIVA) <> decode(REL.CARGA_ESTIVA,null,'n',REL.CARGA_ESTIVA) OR decode (RJ.CARGA_ESTIVA_CUSTO,null,'n',RJ.CARGA_ESTIVA_CUSTO) <> decode(REL.CARGA_ESTIVA_CUSTO,null,'n',REL.CARGA_ESTIVA_CUSTO) OR decode (RJ.CARGA_DETALHE,null,'n',RJ.CARGA_DETALHE) <> decode(REL.CARGA_DETALHE,null,'n',REL.CARGA_DETALHE) OR decode (RJ.CARGA_OBS,null,'n',RJ.CARGA_OBS) <> decode(REL.CARGA_OBS,null,'n',REL.CARGA_OBS) OR decode (RJ.DESCARGA_AGENTE,null,'n',RJ.DESCARGA_AGENTE) <> decode(REL.DESCARGA_AGENTE,null,'n',REL.DESCARGA_AGENTE) OR decode (RJ.DESCARGA_ESTIVA,null,'n',RJ.DESCARGA_ESTIVA) <> decode(REL.DESCARGA_ESTIVA,null,'n',REL.DESCARGA_ESTIVA) OR decode (RJ.DESCARGA_ESTIVA_CUSTO,null,'n',RJ.DESCARGA_ESTIVA_CUSTO) <> 
                decode(REL.DESCARGA_ESTIVA_CUSTO,null,'n',REL.DESCARGA_ESTIVA_CUSTO) OR decode (RJ.DESCARGA_DETALHE,null,'n',RJ.DESCARGA_DETALHE) <> decode(REL.DESCARGA_DETALHE,null,'n',REL.DESCARGA_DETALHE) OR decode (RJ.DESCARGA_OBS,null,'n',RJ.DESCARGA_OBS) <> decode(REL.DESCARGA_OBS,null,'n',REL.DESCARGA_OBS) OR decode (RJ.DETENÇÃO,null,'n',RJ.DETENÇÃO) <> decode(REL.DETENÇÃO,null,'n',REL.DETENÇÃO) OR decode (RJ.DEMORA,null,'n',RJ.DEMORA) <> decode(REL.DEMORA,null,'n',REL.DEMORA) OR decode (RJ.OBS,null,'n',RJ.OBS) <> decode(REL.OBS,null,'n',REL.OBS) OR decode (RJ.DESPACHANTE,null,'n',RJ.DESPACHANTE) <> decode(REL.DESPACHANTE,null,'n',REL.DESPACHANTE) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode 
                (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> FECH QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif FECH que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- RESULT QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.PED_REF || '.' || RJ.EMB_SEQ || '.' || RJ.SEQ chk from CXRJ.RESULT RJ, CXSP.RESULT@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.PED_REF = REL.PED_REF (+) and RJ.EMB_SEQ = REL.EMB_SEQ (+) and RJ.SEQ = REL.SEQ (+) and REL.PED_REF is null AND RJ.PED_REF LIKE 'BH%';
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> RESULT QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif RESULT que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- RESULT QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.PED_REF || '.' || REL.EMB_SEQ || '.' || REL.SEQ chk from CXSP.RESULT@CXSP REL, CXRJ.RESULT RJ where REL.PED_REF = RJ.PED_REF (+) and REL.EMB_SEQ = RJ.EMB_SEQ (+) and REL.SEQ = RJ.SEQ (+) and RJ.PED_REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> RESULT QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif RESULT que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- RESULT QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.PED_REF || '.' || RJ.EMB_SEQ || '.' || RJ.SEQ || ' -> ' || decode(RJ.INV_DATA, REL.INV_DATA, '', 'INV_DATA.') || decode(RJ.RESULT1, REL.RESULT1, '', 'RESULT1.') || decode(RJ.RESULT2, REL.RESULT2, '', 'RESULT2.') || decode(RJ.RESULT3, REL.RESULT3, '', 'RESULT3.') || decode(RJ.RESULT4, REL.RESULT4, '', 'RESULT4.') || decode(RJ.RESULT5, REL.RESULT5, '', 'RESULT5.') || decode(RJ.DATA1, REL.DATA1, '', 'DATA1.') || decode(RJ.DATA2, REL.DATA2, '', 'DATA2.') || decode(RJ.DATA3, REL.DATA3, '', 'DATA3.') || decode(RJ.DATA4, REL.DATA4, '', 'DATA4.') || decode(RJ.DATA5, REL.DATA5, '', 'DATA5.') || decode(RJ.POSIÇÃO, REL.POSIÇÃO, '', 'POSIÇÃO.') || decode(RJ.OBSERVAÇÃO, REL.OBSERVAÇÃO, '', 'OBSERVAÇÃO.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.RESULT RJ, CXSP.RESULT@CXSP REL where 
                RJ.PED_REF LIKE 'BH%' and RJ.PED_REF = REL.PED_REF and RJ.EMB_SEQ = REL.EMB_SEQ and RJ.SEQ = REL.SEQ and (decode (RJ.INV_DATA,null,'n',RJ.INV_DATA) <> decode(REL.INV_DATA,null,'n',REL.INV_DATA) OR decode (RJ.RESULT1,null,'n',RJ.RESULT1) <> decode(REL.RESULT1,null,'n',REL.RESULT1) OR decode (RJ.RESULT2,null,'n',RJ.RESULT2) <> decode(REL.RESULT2,null,'n',REL.RESULT2) OR decode (RJ.RESULT3,null,'n',RJ.RESULT3) <> decode(REL.RESULT3,null,'n',REL.RESULT3) OR decode (RJ.RESULT4,null,'n',RJ.RESULT4) <> decode(REL.RESULT4,null,'n',REL.RESULT4) OR decode (RJ.RESULT5,null,'n',RJ.RESULT5) <> decode(REL.RESULT5,null,'n',REL.RESULT5) OR decode (RJ.DATA1,null,'n',RJ.DATA1) <> decode(REL.DATA1,null,'n',REL.DATA1) OR decode (RJ.DATA2,null,'n',RJ.DATA2) <> decode(REL.DATA2,null,'n',REL.DATA2) OR decode (RJ.DATA3,null,'n',RJ.DATA3) <> decode(REL.DATA3,null,'n',REL.DATA3) OR decode (RJ.DATA4,null,'n',RJ.DATA4) <> decode(REL.DATA4,null,'n',REL.DATA4) OR decode (RJ.DATA5,null,'n',RJ.DATA5) <> decode(REL.DATA5,null,'n',REL.DATA5) OR decode (RJ.POSIÇÃO,null,'n',RJ.POSIÇÃO) <> decode(REL.POSIÇÃO,null,'n',REL.POSIÇÃO) OR decode (RJ.OBSERVAÇÃO,null,'n',RJ.OBSERVAÇÃO) <> decode(REL.OBSERVAÇÃO,null,'n',REL.OBSERVAÇÃO) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> 
                decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> RESULT QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif RESULT que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- BL QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.VIAGEM_REF || '.' || RJ.SEQ chk from CXRJ.BL RJ, CXSP.BL@CXSP REL where   and RJ.VIAGEM_REF = REL.VIAGEM_REF (+) and RJ.SEQ = REL.SEQ (+) and REL.VIAGEM_REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> BL QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif BL que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- BL QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.VIAGEM_REF || '.' || REL.SEQ chk from CXSP.BL@CXSP REL, CXRJ.BL RJ where REL.VIAGEM_REF = RJ.VIAGEM_REF (+) and REL.SEQ = RJ.SEQ (+) and RJ.VIAGEM_REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> BL QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif BL que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- BL QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.VIAGEM_REF || '.' || RJ.SEQ || ' -> ' || decode(RJ.BL_NUM, REL.BL_NUM, '', 'BL_NUM.') || decode(RJ.BL_DATA, REL.BL_DATA, '', 'BL_DATA.') || decode(RJ.EMB_REF, REL.EMB_REF, '', 'EMB_REF.') || decode(RJ.MSG, REL.MSG, '', 'MSG.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.BL RJ, CXSP.BL@CXSP REL where   and RJ.VIAGEM_REF = REL.VIAGEM_REF and RJ.SEQ = REL.SEQ and (decode (RJ.BL_NUM,null,'n',RJ.BL_NUM) <> decode(REL.BL_NUM,null,'n',REL.BL_NUM) OR decode (RJ.BL_DATA,null,'n',RJ.BL_DATA) <> decode(REL.BL_DATA,null,'n',REL.BL_DATA) OR decode (RJ.EMB_REF,null,'n',RJ.EMB_REF) <> decode(REL.EMB_REF,null,'n',REL.EMB_REF) OR decode (RJ.MSG,null,'n',RJ.MSG) <> decode(REL.MSG,null,'n',REL.MSG) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> 
                decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> BL QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif BL que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- BL_CARGA QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.PED_REF || '.' || RJ.PED_ITEM || '.' || RJ.VIAGEM_REF || '.' || RJ.BL_SEQ chk from CXRJ.BL_CARGA RJ, CXSP.BL_CARGA@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.PED_REF = REL.PED_REF (+) and RJ.PED_ITEM = REL.PED_ITEM (+) and RJ.VIAGEM_REF = REL.VIAGEM_REF (+) and RJ.BL_SEQ = REL.BL_SEQ (+) and REL.PED_REF is null AND RJ.PED_REF LIKE 'BH%';
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> BL_CARGA QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif BL_CARGA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- BL_CARGA QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.PED_REF || '.' || REL.PED_ITEM || '.' || REL.VIAGEM_REF || '.' || REL.BL_SEQ chk from CXSP.BL_CARGA@CXSP REL, CXRJ.BL_CARGA RJ where REL.PED_REF = RJ.PED_REF (+) and REL.PED_ITEM = RJ.PED_ITEM (+) and REL.VIAGEM_REF = RJ.VIAGEM_REF (+) and REL.BL_SEQ = RJ.BL_SEQ (+) and RJ.PED_REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> BL_CARGA QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif BL_CARGA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- BL_CARGA QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.PED_REF || '.' || RJ.PED_ITEM || '.' || RJ.VIAGEM_REF || '.' || RJ.BL_SEQ || ' -> ' || decode(RJ.FECH_REF, REL.FECH_REF, '', 'FECH_REF.') || decode(RJ.QTD_PED_UNID, REL.QTD_PED_UNID, '', 'QTD_PED_UNID.') || decode(RJ.QTD_VOL, REL.QTD_VOL, '', 'QTD_VOL.') || decode(RJ.PESO_LÍQUIDO, REL.PESO_LÍQUIDO, '', 'PESO_LÍQUIDO.') || decode(RJ.PESO_BRUTO, REL.PESO_BRUTO, '', 'PESO_BRUTO.') || decode(RJ.EMB_DATA, REL.EMB_DATA, '', 'EMB_DATA.') || decode(RJ.EMB_REF, REL.EMB_REF, '', 'EMB_REF.') || decode(RJ.EMB_SEQ, REL.EMB_SEQ, '', 'EMB_SEQ.') || decode(RJ.FAMÍLIA_GENÉRICA, REL.FAMÍLIA_GENÉRICA, '', 'FAMÍLIA_GENÉRICA.') || decode(RJ.FAMÍLIA, REL.FAMÍLIA, '', 'FAMÍLIA.') || decode(RJ.DESCR         , REL.DESCR         , '', 'DESCR         .') || decode(RJ.EMBALAGEM, REL.EMBALAGEM, '', 'EMBALAGEM.') || decode(RJ.NCM, REL.NCM, '', 'NCM.') || decode(RJ.NALADI, REL.NALADI, '', 'NALADI.') || decode(RJ.EXP_PREÇO_UNIT, REL.EXP_PREÇO_UNIT, '', 'EXP_PREÇO_UNIT.') || decode(RJ.IMP_PREÇO_UNIT, REL.IMP_PREÇO_UNIT, '', 'IMP_PREÇO_UNIT.') || decode(RJ.CALC_EXP_EMB, REL.CALC_EXP_EMB, '', 'CALC_EXP_EMB.') || decode(RJ.CALC_EXP_FOB, REL.CALC_EXP_FOB, '', 'CALC_EXP_FOB.') || decode(RJ.CALC_IMP_EMB, REL.CALC_IMP_EMB, '', 'CALC_IMP_EMB.') || decode(RJ.CALC_IMP_FOB, REL.CALC_IMP_FOB, '', 'CALC_IMP_FOB.') || 
                decode(RJ.NOMINAL_PED_UNID, REL.NOMINAL_PED_UNID, '', 'NOMINAL_PED_UNID.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.BL_CARGA RJ, CXSP.BL_CARGA@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.PED_REF = REL.PED_REF and RJ.PED_ITEM = REL.PED_ITEM and RJ.VIAGEM_REF = REL.VIAGEM_REF and RJ.BL_SEQ = REL.BL_SEQ and (decode (RJ.FECH_REF,null,'n',RJ.FECH_REF) <> decode(REL.FECH_REF,null,'n',REL.FECH_REF) OR decode (RJ.QTD_PED_UNID,null,'n',RJ.QTD_PED_UNID) <> decode(REL.QTD_PED_UNID,null,'n',REL.QTD_PED_UNID) OR decode (RJ.QTD_VOL,null,'n',RJ.QTD_VOL) <> decode(REL.QTD_VOL,null,'n',REL.QTD_VOL) OR decode (RJ.PESO_LÍQUIDO,null,'n',RJ.PESO_LÍQUIDO) <> decode(REL.PESO_LÍQUIDO,null,'n',REL.PESO_LÍQUIDO) OR decode (RJ.PESO_BRUTO,null,'n',RJ.PESO_BRUTO) <> decode(REL.PESO_BRUTO,null,'n',REL.PESO_BRUTO) OR decode (RJ.EMB_DATA,null,'n',RJ.EMB_DATA) <> decode(REL.EMB_DATA,null,'n',REL.EMB_DATA) OR decode 
                (RJ.EMB_REF,null,'n',RJ.EMB_REF) <> decode(REL.EMB_REF,null,'n',REL.EMB_REF) OR decode (RJ.EMB_SEQ,null,'n',RJ.EMB_SEQ) <> decode(REL.EMB_SEQ,null,'n',REL.EMB_SEQ) OR decode (RJ.FAMÍLIA_GENÉRICA,null,'n',RJ.FAMÍLIA_GENÉRICA) <> decode(REL.FAMÍLIA_GENÉRICA,null,'n',REL.FAMÍLIA_GENÉRICA) OR decode (RJ.FAMÍLIA,null,'n',RJ.FAMÍLIA) <> decode(REL.FAMÍLIA,null,'n',REL.FAMÍLIA) OR decode (RJ.DESCR         ,null,'n',RJ.DESCR         ) <> decode(REL.DESCR         ,null,'n',REL.DESCR         ) OR decode (RJ.EMBALAGEM,null,'n',RJ.EMBALAGEM) <> decode(REL.EMBALAGEM,null,'n',REL.EMBALAGEM) OR decode (RJ.NCM,null,'n',RJ.NCM) <> decode(REL.NCM,null,'n',REL.NCM) OR decode (RJ.NALADI,null,'n',RJ.NALADI) <> decode(REL.NALADI,null,'n',REL.NALADI) OR decode (RJ.EXP_PREÇO_UNIT,null,'n',RJ.EXP_PREÇO_UNIT) <> decode(REL.EXP_PREÇO_UNIT,null,'n',REL.EXP_PREÇO_UNIT) OR decode (RJ.IMP_PREÇO_UNIT,null,'n',RJ.IMP_PREÇO_UNIT) <> decode(REL.IMP_PREÇO_UNIT,null,'n',REL.IMP_PREÇO_UNIT) OR decode (RJ.CALC_EXP_EMB,null,'n',RJ.CALC_EXP_EMB) <> decode(REL.CALC_EXP_EMB,null,'n',REL.CALC_EXP_EMB) OR decode (RJ.CALC_EXP_FOB,null,'n',RJ.CALC_EXP_FOB) <> decode(REL.CALC_EXP_FOB,null,'n',REL.CALC_EXP_FOB) OR decode (RJ.CALC_IMP_EMB,null,'n',RJ.CALC_IMP_EMB) <> decode(REL.CALC_IMP_EMB,null,'n',REL.CALC_IMP_EMB) OR decode (RJ.CALC_IMP_FOB,null,'n',RJ.CALC_IMP_FOB) <> decode(REL.CALC_IMP_FOB,null,'n',REL.CALC_IMP_FOB) OR decode 
                (RJ.NOMINAL_PED_UNID,null,'n',RJ.NOMINAL_PED_UNID) <> decode(REL.NOMINAL_PED_UNID,null,'n',REL.NOMINAL_PED_UNID) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> BL_CARGA QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif BL_CARGA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        -- FECH_CARGA QUE TEM NO CXRJ e NÃO TEM NO CXSP
        declare
                cursor EN is select RJ.FECH_REF || '.' || RJ.PED_REF || '.' || RJ.PED_ITEM chk from CXRJ.FECH_CARGA RJ, CXSP.FECH_CARGA@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.FECH_REF = REL.FECH_REF (+) and RJ.PED_REF = REL.PED_REF (+) and RJ.PED_ITEM = REL.PED_ITEM (+) and REL.FECH_REF is null AND RJ.PED_REF LIKE 'BH%';
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> FECH_CARGA QUE TEM NO CXRJ e NÃO TEM NO CXSP <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif FECH_CARGA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- FECH_CARGA QUE TEM NO CXSP e NÃO TEM NO CXRJ
        declare
                cursor EN is select REL.FECH_REF || '.' || REL.PED_REF || '.' || REL.PED_ITEM chk from CXSP.FECH_CARGA@CXSP REL, CXRJ.FECH_CARGA RJ where REL.FECH_REF = RJ.FECH_REF (+) and REL.PED_REF = RJ.PED_REF (+) and REL.PED_ITEM = RJ.PED_ITEM (+) and RJ.FECH_REF is null;
        begin
                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> FECH_CARGA QUE TEM NO CXSP e NÃO TEM NO CXRJ <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif FECH_CARGA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;

        -- FECH_CARGA QUE TEM NOS DOIS COM CAMPOS DIFERENTES
        declare
                cursor EN is select maisatual(RJ.SYS_MOMENTO_CRIA, RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_ATUALIZA) || ' -> ' || RJ.FECH_REF || '.' || RJ.PED_REF || '.' || RJ.PED_ITEM || ' -> ' || decode(RJ.QTD_PED_UNID, REL.QTD_PED_UNID, '', 'QTD_PED_UNID.') || decode(RJ.QTD_FRETE_UNID, REL.QTD_FRETE_UNID, '', 'QTD_FRETE_UNID.') || decode(RJ.QTD_TOTAL, REL.QTD_TOTAL, '', 'QTD_TOTAL.') || decode(RJ.NOMEAÇÃO_DATA, REL.NOMEAÇÃO_DATA, '', 'NOMEAÇÃO_DATA.') || decode(RJ.ACEITAÇÃO_FORNECEDOR_DATA, REL.ACEITAÇÃO_FORNECEDOR_DATA, '', 'ACEITAÇÃO_FORNECEDOR_DATA.') || decode(RJ.CANCEL_DATA, REL.CANCEL_DATA, '', 'CANCEL_DATA.') || decode(RJ.CANCEL_MOTIVO, REL.CANCEL_MOTIVO, '', 'CANCEL_MOTIVO.') || decode(RJ.SYS_MOMENTO_CRIA, REL.SYS_MOMENTO_CRIA, '', 'SYS_MOMENTO_CRIA.') || decode(RJ.SYS_USUÁRIO_CRIA, REL.SYS_USUÁRIO_CRIA, '', 'SYS_USUÁRIO_CRIA.') || decode(RJ.SYS_LOCAL_CRIA, REL.SYS_LOCAL_CRIA, '', 'SYS_LOCAL_CRIA.') || decode(RJ.SYS_MOMENTO_ATUALIZA, REL.SYS_MOMENTO_ATUALIZA, '', 'SYS_MOMENTO_ATUALIZA.') || decode(RJ.SYS_USUÁRIO_ATUALIZA, REL.SYS_USUÁRIO_ATUALIZA, '', 'SYS_USUÁRIO_ATUALIZA.') || decode(RJ.SYS_LOCAL_ATUALIZA, REL.SYS_LOCAL_ATUALIZA, '', 'SYS_LOCAL_ATUALIZA.') || decode(RJ.SYS_STATUS, REL.SYS_STATUS, '', 'SYS_STATUS.') chk from CXRJ.FECH_CARGA RJ, CXSP.FECH_CARGA@CXSP REL where RJ.PED_REF LIKE 'BH%' and RJ.FECH_REF = REL.FECH_REF and RJ.PED_REF = REL.PED_REF and RJ.PED_ITEM = REL.PED_ITEM and (decode 
                (RJ.QTD_PED_UNID,null,'n',RJ.QTD_PED_UNID) <> decode(REL.QTD_PED_UNID,null,'n',REL.QTD_PED_UNID) OR decode (RJ.QTD_FRETE_UNID,null,'n',RJ.QTD_FRETE_UNID) <> decode(REL.QTD_FRETE_UNID,null,'n',REL.QTD_FRETE_UNID) OR decode (RJ.QTD_TOTAL,null,'n',RJ.QTD_TOTAL) <> decode(REL.QTD_TOTAL,null,'n',REL.QTD_TOTAL) OR decode (RJ.NOMEAÇÃO_DATA,null,'n',RJ.NOMEAÇÃO_DATA) <> decode(REL.NOMEAÇÃO_DATA,null,'n',REL.NOMEAÇÃO_DATA) OR decode (RJ.ACEITAÇÃO_FORNECEDOR_DATA,null,'n',RJ.ACEITAÇÃO_FORNECEDOR_DATA) <> decode(REL.ACEITAÇÃO_FORNECEDOR_DATA,null,'n',REL.ACEITAÇÃO_FORNECEDOR_DATA) OR decode (RJ.CANCEL_DATA,null,'n',RJ.CANCEL_DATA) <> decode(REL.CANCEL_DATA,null,'n',REL.CANCEL_DATA) OR decode (RJ.CANCEL_MOTIVO,null,'n',RJ.CANCEL_MOTIVO) <> decode(REL.CANCEL_MOTIVO,null,'n',REL.CANCEL_MOTIVO) OR decode (RJ.SYS_MOMENTO_CRIA,null,'n',RJ.SYS_MOMENTO_CRIA) <> decode(REL.SYS_MOMENTO_CRIA,null,'n',REL.SYS_MOMENTO_CRIA) OR decode (RJ.SYS_USUÁRIO_CRIA,null,'n',RJ.SYS_USUÁRIO_CRIA) <> decode(REL.SYS_USUÁRIO_CRIA,null,'n',REL.SYS_USUÁRIO_CRIA) OR decode (RJ.SYS_LOCAL_CRIA,null,'n',RJ.SYS_LOCAL_CRIA) <> decode(REL.SYS_LOCAL_CRIA,null,'n',REL.SYS_LOCAL_CRIA) OR decode (RJ.SYS_MOMENTO_ATUALIZA,null,'n',RJ.SYS_MOMENTO_ATUALIZA) <> decode(REL.SYS_MOMENTO_ATUALIZA,null,'n',REL.SYS_MOMENTO_ATUALIZA) OR decode (RJ.SYS_USUÁRIO_ATUALIZA,null,'n',RJ.SYS_USUÁRIO_ATUALIZA) <> decode(REL.SYS_USUÁRIO_ATUALIZA,null,'n',REL.SYS_USUÁRIO_ATUALIZA) OR decode 
                (RJ.SYS_LOCAL_ATUALIZA,null,'n',RJ.SYS_LOCAL_ATUALIZA) <> decode(REL.SYS_LOCAL_ATUALIZA,null,'n',REL.SYS_LOCAL_ATUALIZA) OR decode (RJ.SYS_STATUS,null,'n',RJ.SYS_STATUS) <> decode(REL.SYS_STATUS,null,'n',REL.SYS_STATUS));
        begin

                prim := true;
                for cur in EN loop
                        if prim then
                                utl_file.new_line(reglog);
                                utL_file.put_line(reglog, '=====> FECH_CARGA QUE TEM NOS DOIS COM CAMPOS DIFERENTES <=====');
                                prim := false;
                        end if;
                        utl_file.put_line(reglog, cur.chk);
                end loop;
        exception
                when others then
                        raise_application_error ( -20000, 'erro durante verif FECH_CARGA que tem no CXRJ e não tem no CXSP -> ' || SQLERRM );
        end;


        utl_file.fclose(reglog);
exception
        when others then
                if utl_file.is_open(reglog) then
                        utl_file.fclose(reglog);
                end if;
                raise_application_error ( -20000, 'erro COMPARA CXRJ com CXSP -> ' || SQLERRM );
end;

end;

/

