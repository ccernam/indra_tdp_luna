use COBRA
--03-MARZO-20	1 MIN
/****************************************************************************************************************************************/
PRINT '/**********  INICIO DE SCRIPT 00_DEPURACION_MASTER_LUNA DE DUPLICADOS LUNA  **********\'
PRINT 'HORA INICIO: ' + cast(cast(getdate() as dateTIME) as varchar(20))
/****************************************************************************************************************************************/


--- IDENTIFICANDO LOS CODIGOS LUNA QUE TIENEN DUPLICADO POR PROCESO DE RICHARD

	DROP TABLE #JAS_BASE_DUPLICADO
	select a.*,
	ROW_NUMBER() OVER(PARTITION BY A.COD_TIPO_IDENTIFICACION,A.NRO_IDENTIFICACION ORDER BY A.FLAG_ACTIVO DESC,
	LEN(ISNULL(A.NOMBRE,'')+ISNULL(A.APELLIDO_PATERNO,'')+ISNULL(A.APELLIDO_MATERNO,'')) DESC) ORDEN  
	INTO #JAS_BASE_DUPLICADO
	from cobra.luna.master_luna a join 
	(select COD_TIPO_IDENTIFICACION,NRO_IDENTIFICACION,count(1) ctd from cobra.luna.master_luna
	---where FLAG_ACTIVO=1
	group by COD_TIPO_IDENTIFICACION,NRO_IDENTIFICACION having count(1)>1
	) b
	on a.cod_tipo_identificacion=b.COD_TIPO_IDENTIFICACION and a.NRO_IDENTIFICACION=b.NRO_IDENTIFICACION
	order by cod_tipo_identificacion,NRO_IDENTIFICACION desc

--- ELIMINANDO LOS CODIGO LUNA DUPLICADOS - NOS QUEDAMOS SOLAMENTE CON UNO

	 DELETE ---SELECT * 
	FROM cobra.luna.master_luna WHERE COD_LUNA IN (SELECT COD_LUNA FROM #JAS_BASE_DUPLICADO WHERE ORDEN>1)


/****************************************************************************************************************************************/
PRINT 'HORA FIN: ' + cast(cast(getdate() as dateTIME) as varchar(20))
PRINT '\**********  FIN DE SCRIPT 00_DEPURACION_MASTER_LUNA DE DUPLICADOS LUNA  **********/'
/****************************************************************************************************************************************/