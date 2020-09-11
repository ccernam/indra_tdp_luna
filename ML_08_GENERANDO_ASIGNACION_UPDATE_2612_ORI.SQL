USE COBRA

/****************************************************************************************************************************************/
PRINT '/**********  INICIO DE SCRIPT 08_GENERANDO_ASIGNACION_UPDATE  **********\'
PRINT 'HORA INICIO: ' + cast(cast(getdate() as dateTIME) as varchar(20))
/****************************************************************************************************************************************/

DROP TABLE #JAS_DISTRIBUCION
SELECT DISTINCT X.* INTO #JAS_DISTRIBUCION FROM (
SELECT DISTINCT COD_LUNA,COD_AGENCIA_TEMPRANA COD_AGENCIA,1 COD_GESTION,CONVERT(DATE,GETDATE()) FECHA_ASIGNACION FROM SRMS.DBO.JAS_UNIVERSO_TEMPRANA
UNION
SELECT DISTINCT COD_LUNA,0 COD_AGENCIA,2 COD_GESTION,CONVERT(DATE,GETDATE()) FECHA_ASIGNACION FROM SRMS.DBO.JAS_UNIVERSO_TEMPRANA---SRMS.DBO.JAS_UNIVERSO_AVANZADA
) X
---- 11782523

---SELECT COUNT(1) FROM cobra.LUNA.MASTER_AGENCIA_ASIGNADA  --- 11669659

--SELECT 11782523 - 11669659  --- 112,864

--- LIMPIANDO Y CARGANDO ----
TRUNCATE TABLE cobra.LUNA.MASTER_AGENCIA_ASIGNADA
INSERT INTO cobra.LUNA.MASTER_AGENCIA_ASIGNADA(COD_LUNA,COD_AGENCIA,COD_GESTION,FECHA_ASIGNACION)
SELECT DISTINCT COD_LUNA,COD_AGENCIA,COD_GESTION,FECHA_ASIGNACION FROM #JAS_DISTRIBUCION
  

------ ACTUALIZANDO PARAMETROS ISLA ALTAS .... 

update COBRA.DBO.jas_luna_fecha_alta_atento_parametro
set fecha_alta=DATEADD(MONTH,-4,CAST(LEFT(CAST(GETDATE() AS DATE),7)+'-01' AS DATE))


/****************************************************************************************************************************************/
PRINT 'HORA FIN: ' + cast(cast(getdate() as dateTIME) as varchar(20))
PRINT '\**********  FIN DE SCRIPT 08_GENERANDO_ASIGNACION_UPDATE  **********/'
/****************************************************************************************************************************************/


------------------------- consulta para pegar en el excel
SELECT COD_AGENCIA_CALL AS COD_AGENCIA_TEMPRANA,
						  CASE WHEN  COD_AGENCIA_CALL = 1   THEN 'HDEC'  
						  WHEN  COD_AGENCIA_CALL = 5   THEN 'ATENTO'
					      WHEN  COD_AGENCIA_CALL = 22 THEN 'FASTCO'
						  WHEN  COD_AGENCIA_CALL = 14 THEN 'HDEC PREMIUM'
						  WHEN  COD_AGENCIA_CALL = 15 THEN 'OPERACIONES'
						   ELSE '0' END AGENCIA,COD_CONVERGENCIA,
COD_RANGO_DEUDA_TEMPRANA,COD_SCORE_CONVERGENTE,COUNT(DISTINCT COD_LUNA) CTD 
 FROM LUNA.EXP_MASTER_LUNA
GROUP BY COD_CONVERGENCIA,COD_SCORE_CONVERGENTE,COD_RANGO_DEUDA_TEMPRANA,COD_AGENCIA_CALL
 