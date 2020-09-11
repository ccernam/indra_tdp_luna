USE COBRA
--03-MARZO-2020     10 MIN 
/****************************************************************************************************************************************/
PRINT '/**********  INICIO DE SCRIPT 03_ACTUALIZANDO_INDICADOR_EXCLUSION_DELETE  **********\'
PRINT 'HORA INICIO: ' + cast(cast(getdate() as dateTIME) as varchar(20))
/****************************************************************************************************************************************/

drop table SRMS.DBO.data_ind_exclusion_jas_cuenta_BK_12082017
SELECT * INTO SRMS.DBO.data_ind_exclusion_jas_cuenta_BK_12082017 FROM cobra.luna.data_ind_exclusion_jas_cuenta 

drop table SRMS.DBO.DATA_IND_EXCLUSION_JAS_BK_12082017
SELECT * INTO SRMS.DBO.DATA_IND_EXCLUSION_JAS_BK_12082017 FROM cobra.LUNA.DATA_IND_EXCLUSION_JAS WHERE MOTIVO IN 
(
SELECT DISTINCT MOTIVO FROM SRMS.DBO.data_ind_exclusion_jas_cuenta_BK_12082017
)
-- 38613

---SELECT * FROM SRMS.DBO.DATA_IND_EXCLUSION_JAS_BK_12082017 WHERE MOTIVO='CUENTAS_EXCLUIR_DESCUENTO_45'

DELETE FROM cobra.LUNA.DATA_IND_EXCLUSION_JAS
WHERE 
MOTIVO IN 
(
SELECT DISTINCT MOTIVO FROM SRMS.DBO.data_ind_exclusion_jas_cuenta_BK_12082017
) --- 38613



DELETE FROM cobra.luna.data_ind_exclusion_jas_cuenta 
WHERE 
MOTIVO IN 
(
SELECT DISTINCT MOTIVO FROM SRMS.DBO.data_ind_exclusion_jas_cuenta_BK_12082017
) --- 33782



print 'inicia ejecucion indicador 18 -- ' + cast(cast(getdate() as dateTIME) as varchar(20))

EXEC LUNA.SP_RUN_INDICADOR 18


print 'fin ejecucion indicador 18 -- ' + cast(cast(getdate() as dateTIME) as varchar(20))


/****************************************************************************************************************************************/
PRINT 'HORA FIN: ' + cast(cast(getdate() as dateTIME) as varchar(20))
PRINT '\**********  FIN DE SCRIPT 03_ACTUALIZANDO_INDICADOR_EXCLUSION_DELETE  **********/'
/****************************************************************************************************************************************/