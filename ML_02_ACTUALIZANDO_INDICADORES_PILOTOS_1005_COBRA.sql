USE COBRA
--03-MARZO-20 33 MIN  

/****************************************************************************************************************************************/
PRINT '/**********  INICIO DE SCRIPT 02_ACTUALIZANDO_INDICADORES_PILOTOS_1005_COBRA  **********\'
PRINT 'HORA INICIO: ' + cast(cast(getdate() as dateTIME) as varchar(20))
/****************************************************************************************************************************************/

---- INDICADORES 
--SELECT * FROM COBRA.LUNA.DATA_IND_INFOCORP

UPDATE COBRA.LUNA.DATA_IND_INFOCORP SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_INFOCORP A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_DIGITALIZADO SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_DIGITALIZADO A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_HFC SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_HFC A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_APC SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_APC A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_FINANCIAMIENTO SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_FINANCIAMIENTO A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_RECLAMO SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_RECLAMO A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_AVERIA SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_AVERIA A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_FACTURA_DIGITAL SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_FACTURA_DIGITAL A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_RURAL SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_RURAL A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_TUP_SERTEL SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_TUP_SERTEL A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_XDSL SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_XDSL A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_DESCUENTO SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_DESCUENTO A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_RECUPERO_EQUIPOS SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_RECUPERO_EQUIPOS A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_FRAUDE SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_FRAUDE A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_ALTA_COMPONENTE SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_ALTA_COMPONENTE A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_AJUSTE50_VENC_ENE_FEB SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_AJUSTE50_VENC_ENE_FEB A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_BONO_VIDEO SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_BONO_VIDEO A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
go
UPDATE cobra.DBO.jas_piloto_gestion_66 SET COD_SISTEMA=4,CLIENTE=B.COD_CLIENTE,anexo=B.COD_CUENTA FROM cobra.DBO.jas_piloto_gestion_66 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.anexo AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE cobra.DBO.jas_piloto_gestion_67 SET COD_SISTEMA=4,CLIENTE=B.COD_CLIENTE,anexo=B.COD_CUENTA FROM cobra.DBO.jas_piloto_gestion_67 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.anexo AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE cobra.DBO.jas_piloto_gestion_68 SET COD_SISTEMA=4,CLIENTE=B.COD_CLIENTE,anexo=B.COD_CUENTA FROM cobra.DBO.jas_piloto_gestion_68 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.anexo AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE cobra.DBO.jas_piloto_gestion_69 SET COD_SISTEMA=4,CLIENTE=B.COD_CLIENTE,anexo=B.COD_CUENTA FROM cobra.DBO.jas_piloto_gestion_69 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.anexo AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE cobra.DBO.jas_piloto_gestion_70 SET COD_SISTEMA=4,CLIENTE=B.COD_CLIENTE,anexo=B.COD_CUENTA FROM cobra.DBO.jas_piloto_gestion_70 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.anexo AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_PILOTO_PENALIDADES_MOVIL SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_PILOTO_PENALIDADES_MOVIL A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_PILOTO_PRIORIZADOS_PREMIUM SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_PILOTO_PRIORIZADOS_PREMIUM A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_PILOTO_PROSP_BAJA_PREMIUM SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_PILOTO_PROSP_BAJA_PREMIUM A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.[LUNA].[DATA_PILOTOS_PREMIUM_80_81_82] SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.[LUNA].[DATA_PILOTOS_PREMIUM_80_81_82] A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3

go
----- pilotos

UPDATE cobra.DBO.jas_piloto_gestion_66 SET COD_SISTEMA=4,CLIENTE=B.COD_CLIENTE,anexo=B.COD_CUENTA FROM cobra.DBO.jas_piloto_gestion_66 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.anexo AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE cobra.DBO.jas_piloto_gestion_67 SET COD_SISTEMA=4,CLIENTE=B.COD_CLIENTE,anexo=B.COD_CUENTA FROM cobra.DBO.jas_piloto_gestion_67 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.anexo AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE cobra.DBO.jas_piloto_gestion_68 SET COD_SISTEMA=4,CLIENTE=B.COD_CLIENTE,anexo=B.COD_CUENTA FROM cobra.DBO.jas_piloto_gestion_68 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.anexo AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE cobra.DBO.jas_piloto_gestion_69 SET COD_SISTEMA=4,CLIENTE=B.COD_CLIENTE,anexo=B.COD_CUENTA FROM cobra.DBO.jas_piloto_gestion_69 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.anexo AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE cobra.DBO.jas_piloto_gestion_70 SET COD_SISTEMA=4,CLIENTE=B.COD_CLIENTE,anexo=B.COD_CUENTA FROM cobra.DBO.jas_piloto_gestion_70 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.anexo AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_PILOTO_PENALIDADES_MOVIL SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_PILOTO_PENALIDADES_MOVIL A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_PILOTO_PRIORIZADOS_PREMIUM SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_PILOTO_PRIORIZADOS_PREMIUM A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_PILOTO_PROSP_BAJA_PREMIUM SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_PILOTO_PROSP_BAJA_PREMIUM A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.[LUNA].[DATA_PILOTOS_PREMIUM_80_81_82] SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.[LUNA].[DATA_PILOTOS_PREMIUM_80_81_82] A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.[LUNA].[DATA_PILOTOS_CHURN_FIJA_74_79] SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.[LUNA].[DATA_PILOTOS_CHURN_FIJA_74_79] A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.[LUNA].[DATA_PILOTOS_PREMIUM_80_81_82] SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.[LUNA].[DATA_PILOTOS_PREMIUM_80_81_82] A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE cobra.dbo.DATA_PILOTO_87 SET tcnfol=B.COD_CUENTA FROM cobra.dbo.DATA_PILOTO_87 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.TCNFOL AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) ---WHERE A.COD_SISTEMA=3
UPDATE COBRA.[LUNA].[DATA_PILOTOS_CHURN_FIJA_83_93] SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.[LUNA].[DATA_PILOTOS_CHURN_FIJA_83_93] A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE cobra.dbo.DATA_PILOTO_94 SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM cobra.dbo.DATA_PILOTO_94 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.[LUNA].[DATA_PILOTOS_66_95] SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.[LUNA].[DATA_PILOTOS_66_95] A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE cobra.luna.DATA_PILOTOS_PREMIUM_96_99 SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM cobra.luna.DATA_PILOTOS_PREMIUM_96_99 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE SRMS.[DBO].[JAS_PENALIDADES_MOVIL_KAREN] SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM SRMS.[DBO].[JAS_PENALIDADES_MOVIL_KAREN] A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_VARIBLES_EXT_TDP_1 SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_VARIBLES_EXT_TDP_1 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_VARIBLES_EXT_TDP_2 SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_VARIBLES_EXT_TDP_2 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_VARIBLES_EXT_TDP_3 SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_VARIBLES_EXT_TDP_3 A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_PILOTO_HDEC_PRIORIZADO SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_PILOTO_HDEC_PRIORIZADO A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_PILOTO_HDEC_NO_PRIO SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_PILOTO_HDEC_NO_PRIO A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_MIGRACION_FULLSTACK SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_MIGRACION_FULLSTACK A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3
UPDATE COBRA.LUNA.DATA_IND_DEBITO_IBK SET COD_SISTEMA=4,COD_CLIENTE=B.COD_CLIENTE,COD_CUENTA=B.COD_CUENTA FROM COBRA.LUNA.DATA_IND_DEBITO_IBK A JOIN AMDOCS.PLANTA_SERVICIO B ON CAST(A.COD_CUENTA AS BIGINT)=CAST(B.COD_SERVICIO AS BIGINT) WHERE A.COD_SISTEMA=3

go
------ DATA CONTACTOS
UPDATE LUNA.DATA_CONTACTOS
SET 
COD_SISTEMA=4,
COD_CLIENTE=B.CUSTOMER_KEY
FROM LUNA.DATA_CONTACTOS A
JOIN SRMS.[ID_COBRA].[stc_clientes_STC_REL_CLIENTES_fsk] B
ON CAST(A.COD_CLIENTE AS BIGINT)=CAST(B.COD_CLIENTE AS BIGINT)
WHERE A.COD_SISTEMA=3

go
---- EXCLUSIONES

UPDATE cobra.LUNA.DATA_IND_EXCLUSION_JAS
SET 
COD_SISTEMA=4,
COD_CLIENTE=CAST(B.COD_CLIENTE AS BIGINT),
COD_CUENTA=CAST(B.COD_CUENTA AS BIGINT)
FROM cobra.LUNA.DATA_IND_EXCLUSION_JAS A
JOIN COBRA.AMDOCS.PLANTA_SERVICIO B ON A.COD_CUENTA=CAST(B.COD_SERVICIO AS BIGINT)
WHERE A.COD_SISTEMA=3

go
UPDATE cobra.luna.data_ind_exclusion_jas_cuenta
SET 
COD_SISTEMA=4,
COD_CLIENTE=CAST(B.COD_CLIENTE AS BIGINT),
COD_CUENTA=CAST(B.COD_CUENTA AS BIGINT)
FROM cobra.luna.data_ind_exclusion_jas_cuenta A
JOIN COBRA.AMDOCS.PLANTA_SERVICIO B ON A.COD_CUENTA=CAST(B.COD_SERVICIO AS BIGINT)
WHERE A.COD_SISTEMA=3

go
/****************************************************************************************************************************************/
PRINT 'HORA FIN: ' + cast(cast(getdate() as dateTIME) as varchar(20))
PRINT '\**********  FIN DE SCRIPT 02_ACTUALIZANDO_INDICADORES_PILOTOS_1005_COBRA  **********/'
/****************************************************************************************************************************************/