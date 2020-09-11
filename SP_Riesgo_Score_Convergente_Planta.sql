USE [COBRA]
GO
/****** Object:  StoredProcedure [dbo].[SP_Riesgo_Score_Convergente_Planta]    Script Date: 12/08/2020 09:37:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[SP_Riesgo_Score_Convergente_Planta]
As

Begin

--***************************************  [ELIMINAR PLANTA ANTERIOR ] ********************************------

DROP TABLE dbo.Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm

--***************************************  [GENERAR PLANTA ] ********************************------
SELECT  
	A.COD_TIPO_IDENTIFICACION,
	A.NRO_IDENTIFICACION,
	A.COD_SISTEMA,
	convert(varchar (15), A.COD_CLIENTE ) as COD_CLIENTE ,
	A.COD_CUENTA,
	A.TELEFONO,
	A.COD_SEGMENTO,
	A.CLIENTE_ACTIVO,
	MIN(A.FECHA_ALTA)'MAX_FECHA_ALTA'
into  dbo.Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm
FROM LUNA.VIEW_RESUMEN_LUNA_SERVICIO AS A
INNER JOIN  LUNA.VIEW_MASTER_CUENTA AS B
ON (A.COD_SISTEMA = B.COD_SISTEMA AND A.COD_CLIENTE = B.COD_CLIENTE AND A.COD_CUENTA = B.COD_CUENTA)
WHERE A.COD_SEGMENTO >= 4 AND A.COD_ESTADO < 30 AND B.IND_TUP_SERTEL IS NULL  AND A.CLIENTE_ACTIVO = 1
GROUP BY
	A.COD_TIPO_IDENTIFICACION,
	A.NRO_IDENTIFICACION,
	A.COD_SISTEMA,
	A.COD_CLIENTE,
	A.COD_CUENTA,
	A.TELEFONO,
	A.COD_SEGMENTO,
	A.CLIENTE_ACTIVO
	
	
	
--***************************************  [EXPORTAR PLANTAS ] ********************************------


Declare     @query4 as varchar(1000)
SET @query4 = 'bcp "select * from COBRA.dbo.Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm"   QUERYOUT "\\gppesplcli1212\Servidor_FACO\Operaciones\DESA\GESTORES\MOVIL\Pagos\HOY\Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm.txt"  -c -t^| -T -P' 
EXEC master..xp_cmdshell @query4


END