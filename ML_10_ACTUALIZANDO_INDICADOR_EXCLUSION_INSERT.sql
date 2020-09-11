use cobra

--03-MARZO-2020 3 min

/****************************************************************************************************************************************/
PRINT '/**********  INICIO DE SCRIPT 10_ACTUALIZANDO_INDICADOR_EXCLUSION_INSERT  **********\'
PRINT 'HORA INICIO: ' + cast(cast(getdate() as dateTIME) as varchar(20))
/****************************************************************************************************************************************/

--- insert 

INSERT INTO cobra.LUNA.DATA_IND_EXCLUSION_JAS
SELECT * FROM SRMS.DBO.DATA_IND_EXCLUSION_JAS_BK_12082017 WHERE MOTIVO IN 
(
SELECT DISTINCT MOTIVO FROM SRMS.DBO.data_ind_exclusion_jas_cuenta_BK_12082017
)


INSERT INTO cobra.luna.data_ind_exclusion_jas_cuenta 
SELECT * FROM SRMS.DBO.data_ind_exclusion_jas_cuenta_BK_12082017  WHERE MOTIVO IN 
(
SELECT DISTINCT MOTIVO FROM SRMS.DBO.data_ind_exclusion_jas_cuenta_BK_12082017
)


print 'inicia ejecucion indicador 18 -- ' + cast(cast(getdate() as dateTIME) as varchar(20))

EXEC LUNA.SP_RUN_INDICADOR 18


print 'fin ejecucion indicador 18 -- ' + cast(cast(getdate() as dateTIME) as varchar(20))


UPDATE cobra.LUNA.DATA_IND_EXCLUSION_JAS
SET 
COD_SISTEMA=4,
COD_CLIENTE=CAST(B.COD_CLIENTE AS BIGINT),
COD_CUENTA=CAST(B.COD_CUENTA AS BIGINT)
FROM cobra.LUNA.DATA_IND_EXCLUSION_JAS A
JOIN COBRA.AMDOCS.PLANTA_SERVICIO B ON A.COD_CUENTA=CAST(B.COD_SERVICIO AS BIGINT)
WHERE A.COD_SISTEMA=3


UPDATE cobra.luna.data_ind_exclusion_jas_cuenta
SET 
COD_SISTEMA=4,
COD_CLIENTE=CAST(B.COD_CLIENTE AS BIGINT),
COD_CUENTA=CAST(B.COD_CUENTA AS BIGINT)
FROM cobra.luna.data_ind_exclusion_jas_cuenta A
JOIN COBRA.AMDOCS.PLANTA_SERVICIO B ON A.COD_CUENTA=CAST(B.COD_SERVICIO AS BIGINT)
WHERE A.COD_SISTEMA=3


----------------- DEPURANDO TABLAS TEMPORALES ---
DROP TABLE ##TEMPORAL


-----------------------

/****************************************************************************************************************************************/
PRINT 'HORA FIN: ' + cast(cast(getdate() as dateTIME) as varchar(20))
PRINT '\**********  FIN DE SCRIPT 10_ACTUALIZANDO_INDICADOR_EXCLUSION_INSERT  **********/'
/****************************************************************************************************************************************/