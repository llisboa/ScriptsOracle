UPDATE SYS_USUÁRIO SET ASSINATURA=NULL;
COMMIT;
DROP  DIRECTORY IMG ;
CREATE  DIRECTORY IMG AS 'E:\ARTES\ASSINATURAS'
/
BEGIN
 
 	LP.limportassinatura('IMG', 'assvaleria.gif','VALERIA');
	LP.limportassinatura('IMG', 'assronald.gif','RONALD');
	LP.limportassinatura('IMG', 'assalair.gif','ALAIR');
	LP.limportassinatura('IMG', 'assfrançoise.gif','FRANCOISE');
	LP.limportassinatura('IMG', 'assmylene.gif','MYLENE'); 
	LP.limportassinatura('IMG', 'assjoaog.gif','JOAOG');
END;
/
commit;
/
