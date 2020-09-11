USE [Cob_Operaciones]
GO
/****** Object:  StoredProcedure [dbo].[SP_Riesgo_Score_Convergente_Carga_ejecucion_Exportacion]    Script Date: 11/08/2020 12:22:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[SP_Riesgo_Score_Convergente_Carga_ejecucion_Exportacion]
As

Begin


--------------------------------------------------------------------------------
----------------------- CARGAR PLANTA EXPORTADA DEL 1005 -----------------------
--------------------------------------------------------------------------------

DROP TABLE [dbo].[Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm]

CREATE TABLE [dbo].[Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm](
	[COD_TIPO_IDENTIFICACION] [tinyint] NOT NULL,
	[NRO_IDENTIFICACION] [varchar](50) NULL,
	[COD_SISTEMA] [tinyint] NULL,
	--[COD_CLIENTE] [int] NULL,
	[COD_CLIENTE] [varchar](15) NULL,
	[COD_CUENTA] [varchar](10) NULL,
	[TELEFONO] [varchar](20) NULL,
	[COD_SEGMENTO] [tinyint] NULL,
	[CLIENTE_ACTIVO] [bit] NULL,
	[MAX_FECHA_ALTA] [date] NULL
) 

--------------------------------------------------------------------------------
----------------------- CARGAR PLANTA EXPORTADA DEL 1005 -----------------------
--------------------------------------------------------------------------------

BULK INSERT [dbo].[Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm]--_temp  --
  
  FROM '\\gppesplcli1212\servidor_FACO\operaciones\DESA\GESTORES\MOVIL\Pagos\HOY\Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm.txt'
 
	    WITH 
      (
        FIELDTERMINATOR = '|', ROWTERMINATOR = '\n'
      )
      
 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------FACTURADO MOVIL ------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------

truncate table Riesgo_ScoreConv_Fact_Mov  

insert into  Riesgo_ScoreConv_Fact_Mov  
SELECT DISTINCT										
LTRIM(RTRIM(TCCCLI)) AS Cliente,
LTRIM(RTRIM(TCNFOL)) AS tcnfol,
LTRIM(RTRIM(TCNTEL)) AS tcntel,
'STC' AS Sistema_origen,
LTRIM(RTRIM(TCNURE)) AS Recibo_1,
FEMITE AS Ciclo_1,
CAST(FVENCE AS DATE) AS Fecha_Vencimiento_1,	
CAST(TCTOTB AS NUMERIC(9,2)) AS Total_Facturado_1,
CASE WHEN FECPAGO_FMC_MAX IS NOT NULL THEN CAST(FECPAGO_FMC_MAX AS DATE) ELSE NULL END AS Fecha_Pago_1,0
from  BD_COCI.DBO.MOVIL_HISTORICO_FACTURADO_INPUT
 where DATEDIFF(MONTH,CONVERT(smalldatetime,FVENCE,121),convert(varchar(10),getdate()+8,112))>=1 
 and DATEDIFF(MONTH,CONVERT(smalldatetime,FVENCE,121),convert(varchar(10),getdate()+8,112))<=6
 AND CAST(TCTOTB AS NUMERIC(9,2)) > 0
 ORDER BY Cliente, tcnfol
 
 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------DEUDA MOVIL ------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------

truncate table Riesgo_ScoreConv_Sal_Mov 

insert into Riesgo_ScoreConv_Sal_Mov 
SELECT LTRIM(RTRIM(Anexo)) AS Anexo, 
CAST(CASE WHEN LEN(LTRIM(RTRIM(Fecha_Vencimiento))) = 10 THEN LTRIM(RTRIM(Fecha_Vencimiento)) ELSE  '2000-10-01' END AS varchar) AS FVENC,
SUM(CAST(Mto_Documento AS FLOAT)) AS MTODOC, SUM(CAST(Mto_Exigible AS FLOAT)) AS MTOEXIG 
--into Riesgo_ScoreConv_Sal_Mov
FROM Cob_Operaciones..Mov_Sal_Mae_Documentos
GROUP BY LTRIM(RTRIM(Anexo)), CAST(CASE WHEN LEN(LTRIM(RTRIM(Fecha_Vencimiento))) = 10 THEN LTRIM(RTRIM(Fecha_Vencimiento)) ELSE '2000-10-01' END AS varchar)

 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------ACTUALIZA DEUDA MOVIL ------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------

UPDATE Riesgo_ScoreConv_Fact_Mov
SET
Exigible_1 = ISNULL(B.MTOEXIG,0)
FROM Riesgo_ScoreConv_Fact_Mov A
LEFT JOIN Riesgo_ScoreConv_Sal_Mov B			
ON A.tcnfol = B.Anexo AND CONVERT(varchar(10),A.Fecha_Vencimiento_1) = B.FVENC


 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------CONTACTO MOVIL ------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------

TRUNCATE TABLE   Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm

INSERT INTO Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm
SELECT DISTINCT cod_Cliente, nro_identificacion, CAST(GETDATE() AS DATE) AS Fecha_Vencimiento_0,0,0  
FROM  Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm  


 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------ACTUALIZA CONTACTO MOVIL --------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------

--UPDATE Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm 
--SET Contactos_Mov = ISNULL(W.Q,0)
--FROM Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm V 
--LEFT JOIN 
-- (SELECT MES, COD_Cliente, COUNT(*) AS Q
--  FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm A 
-- INNER JOIN (SELECT CASE WHEN LEN(LTRIM(RTRIM(FEC_LLAMADA))) = 8 THEN LEFT(FEC_LLAMADA,4) ELSE '2000' END + CASE WHEN LEN(LTRIM(RTRIM(FEC_LLAMADA))) = 8 THEN SUBSTRING(FEC_LLAMADA,5,2) ELSE '01' END AS MES, TELEFONO_GESTION, COUNT(*) AS Q 
-- FROM BD_COCI.DBO.IC_PV_MAE_CONTACTOS_MOVIL
-- GROUP BY CASE WHEN LEN(LTRIM(RTRIM(FEC_LLAMADA))) = 8 THEN LEFT(FEC_LLAMADA,4) ELSE '2000' END + CASE WHEN LEN(LTRIM(RTRIM(FEC_LLAMADA))) = 8 THEN SUBSTRING(FEC_LLAMADA,5,2) ELSE '01' END, TELEFONO_GESTION) B						
--		ON RIGHT('0000000000000'+A.telefono,13) = RIGHT('0000000000000'+B.TELEFONO_GESTION,13) 		 																																																										   
--		AND DATEDIFF(MONTH,B.MES+'01',GETDATE()) = 1
-- GROUP BY MES, COD_Cliente) W	
--		ON RIGHT('0000000000000'+V.COD_Cliente,13) = RIGHT('0000000000000'+W.COD_Cliente,13) 
--		AND DATEDIFF(MONTH,W.MES+'01',V.Fecha_Vencimiento_0) = 1
       

	   


 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------FACTURADO AMDOCS ------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------
 
--SELECT * FROM GPPESPLCLI1005.srms.[dbo].[JAS_FACTURADO_AMDOCS_TMP_curva_ope] WHERE FINANCIAL_ACCOUNT_KEY='391915116'
--SELECT * FROM GPPESPLCLI1005.srms.[dbo].[JAS_FACTURADO_AMDOCS_TMP]  WHERE FINANCIAL_ACCOUNT_KEY='340469032'
----truncate table Riesgo_ScoreConv_Fact_Mov  

TRUNCATE TABLE Riesgo_ScoreConv_Fact_AMDOCS

----insert into  Riesgo_ScoreConv_Fact_AMDOCS  
----SELECT DISTINCT										
---- LTRIM(RTRIM(customer_key)) AS Cliente,
----LTRIM(RTRIM(FINANCIAL_ACCOUNT_KEY)) AS tcnfol,
---- LTRIM(RTRIM(TELEFONO))    tcntel,
----'AMD' AS Sistema_origen,
----LTRIM(RTRIM(LEGAL_INVOICE_NUMBER)) AS Recibo_1,
----FECHA_EMISION AS Ciclo_1,
----CAST(FECHA_VENCIMIENTO AS DATE) AS Fecha_Vencimiento_1,	
----CAST(MONTO_FACTURADO AS NUMERIC(9,2)) AS Total_Facturado_1,
----CASE WHEN DIA_PAGO_MAXIMO_SC IS NOT NULL THEN CAST(DIA_PAGO_MAXIMO_SC AS DATE) ELSE NULL END AS Fecha_Pago_1,0
----FROM GPPESPLCLI1005.srms.[dbo].[JAS_FACTURADO_AMDOCS_TMP] 
---- where DATEDIFF(MONTH,CONVERT(smalldatetime,FECHA_VENCIMIENTO,121),convert(varchar(10),getdate()+8,112))>=1 
---- and DATEDIFF(MONTH,CONVERT(smalldatetime,FECHA_VENCIMIENTO,121),convert(varchar(10),getdate()+8,112))<=6
---- AND CAST(MONTO_FACTURADO AS NUMERIC(9,2)) > 0
---- ORDER BY Cliente, tcnfol
   

insert into Riesgo_ScoreConv_Fact_AMDOCS
SELECT DISTINCT										
 LTRIM(RTRIM(customer_key)) AS Cliente,
LTRIM(RTRIM(FINANCIAL_ACCOUNT_KEY)) AS tcnfol,
 --LTRIM(RTRIM(TELEFONO))    tcntel,
 LTRIM(RTRIM(TELEFONO))   ,
'AMD' AS Sistema_origen,
LTRIM(RTRIM(LEGAL_INVOICE_NUMBER)) AS Recibo_1,
FECHA_EMISION AS Ciclo_1,
CAST(FECHA_VENCIMIENTO AS DATE) AS Fecha_Vencimiento_1,	
CAST(MONTO_FACTURADO AS MONEY) AS Total_Facturado_1,
CASE WHEN DIA_PAGO_MAXIMO IS NOT NULL 
	 THEN CAST(DIA_PAGO_MAXIMO AS DATE) 
	 ELSE NULL 
	 END AS Fecha_Pago_1,0
FROM GPPESPLCLI1005.srms.[dbo].[RATIO_FACTURADO_AMDOCS] 
 where DATEDIFF(MONTH,CONVERT(smalldatetime,FECHA_VENCIMIENTO,121),convert(varchar(10),getdate()+8,112))>=1 
 and DATEDIFF(MONTH,CONVERT(smalldatetime,FECHA_VENCIMIENTO,121),convert(varchar(10),getdate()+8,112))<=6
 AND CAST(MONTO_FACTURADO AS MONEY) > 0
 ORDER BY Cliente, tcnfol
 -- ORDER BY Cliente, tcnfol


 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------DEUDA AMDOCS ------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------

--truncate table   Riesgo_ScoreConv_Sal_Mov 

insert into Riesgo_ScoreConv_Sal_Mov 
SELECT LTRIM(RTRIM(COD_CTA_FINAN)) AS Anexo, 
CAST(CASE WHEN LEN(LTRIM(RTRIM(CONVERT(DATE,MIN_FECHA_VENCIMIENTO)))) = 10 THEN LTRIM(RTRIM(CONVERT(DATE,MIN_FECHA_VENCIMIENTO))) ELSE  '2000-10-01' END AS varchar) AS FVENC,
SUM(CAST(Monto_Balance_Total_sin_reclamo AS FLOAT)) AS MTODOC, SUM(CAST(Monto_Balance_Total_sin_reclamo AS FLOAT)) AS MTOEXIG 
FROM FullStack_Mov_deuda_total2_cor01_agrupado
GROUP BY LTRIM(RTRIM(COD_CTA_FINAN)), CAST(CASE WHEN LEN(LTRIM(RTRIM(CONVERT(DATE,MIN_FECHA_VENCIMIENTO)))) = 10 THEN LTRIM(RTRIM(CONVERT(DATE,MIN_FECHA_VENCIMIENTO))) ELSE '2000-10-01' END AS varchar)

 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------ACTUALIZA DEUDA AMDOCS ------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------

UPDATE   Riesgo_ScoreConv_Fact_AMDOCS
SET
Exigible_1 = ISNULL(B.MTOEXIG,0)
FROM Riesgo_ScoreConv_Fact_AMDOCS A
LEFT JOIN Riesgo_ScoreConv_Sal_Mov B			
ON A.tcnfol = B.Anexo AND CONVERT(varchar(10),A.Fecha_Vencimiento_1) = B.FVENC


-- --------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------CONTACTO AMDOCS ------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------

--TRUNCATE TABLE  Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm

--INSERT INTO Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm
--SELECT DISTINCT cod_Cliente, nro_identificacion, CAST(GETDATE() AS DATE) AS Fecha_Vencimiento_0,0,0  
--FROM  Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm  


-- --------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------ACTUALIZA CONTACTO AMDOCS --------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------

--UPDATE Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm 
--SET Contactos_Mov = ISNULL(W.Q,0)
--FROM Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm V 
--LEFT JOIN 
-- (SELECT MES, COD_Cliente, COUNT(*) AS Q
--  FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm A 
-- INNER JOIN (SELECT CASE WHEN LEN(LTRIM(RTRIM(FEC_LLAMADA))) = 8 THEN LEFT(FEC_LLAMADA,4) ELSE '2000' END + CASE WHEN LEN(LTRIM(RTRIM(FEC_LLAMADA))) = 8 THEN SUBSTRING(FEC_LLAMADA,5,2) ELSE '01' END AS MES, TELEFONO_GESTION, COUNT(*) AS Q 
-- FROM BD_COCI.DBO.IC_PV_MAE_CONTACTOS_MOVIL
-- GROUP BY CASE WHEN LEN(LTRIM(RTRIM(FEC_LLAMADA))) = 8 THEN LEFT(FEC_LLAMADA,4) ELSE '2000' END + CASE WHEN LEN(LTRIM(RTRIM(FEC_LLAMADA))) = 8 THEN SUBSTRING(FEC_LLAMADA,5,2) ELSE '01' END, TELEFONO_GESTION) B						
--		ON RIGHT('0000000000000'+A.telefono,13) = RIGHT('0000000000000'+B.TELEFONO_GESTION,13) 		 																																																										   
--		AND DATEDIFF(MONTH,B.MES+'01',GETDATE()) = 1
-- GROUP BY MES, COD_Cliente) W	
--		ON RIGHT('0000000000000'+V.COD_Cliente,13) = RIGHT('0000000000000'+W.COD_Cliente,13) 
--		AND DATEDIFF(MONTH,W.MES+'01',V.Fecha_Vencimiento_0) = 1





 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------FACTURADO MOV CON AMDOCS ------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------

 	   
drop table Riesgo_ScoreConv_Fact_Mov_AMDOCS


--- GENERO BASE QUE ESTÁ MIGRADA
select distinct a.*, b.cod_cliente as Cliente_AMD, b.FINANCIAL_ACCOUNT as tcnfol_AMD
into Riesgo_ScoreConv_Fact_Mov_AMDOCS
FROM Riesgo_ScoreConv_Fact_Mov a inner join FullStack_Mov_Mae_Suscriptores_FA  b   
on CAST(a.tcnfol AS BIGINT)=CAST(b.NUM_ANEXO AS BIGINT) -- and  a.Sistema_origen='STC'

---- ELIMINO FACTURAS QUE YA ESTÁN EN AMDOCS
DELETE Riesgo_ScoreConv_Fact_Mov_AMDOCS
FROM Riesgo_ScoreConv_Fact_Mov_AMDOCS A INNER JOIN Riesgo_ScoreConv_Fact_AMDOCS B
ON A.Cliente_AMD=B.CLIENTE AND A.tcnfol_AMD=B.TCNFOL AND A.FECHA_VENCIMIENTO_1=B.FECHA_VENCIMIENTO_1 
--AND B.Sistema_origen<>'STC'

---- ELIMINO FACTURAS QUE YA ESTÁN EN AMDOCS
DELETE Riesgo_ScoreConv_Fact_Mov_AMDOCS
FROM Riesgo_ScoreConv_Fact_Mov_AMDOCS A INNER JOIN Riesgo_ScoreConv_Fact_AMDOCS B
ON A.Cliente_AMD=B.CLIENTE AND A.tcntel=B.tcntel AND A.FECHA_VENCIMIENTO_1=B.FECHA_VENCIMIENTO_1 
--AND B.Sistema_origen<>'STC'

  

--INSERTO  FACTURAS DE STC CON COD_CUENTA AMDOCS
INSERT INTO Riesgo_ScoreConv_Fact_AMDOCS
SELECT Cliente_AMD,tcnfol_AMD,tcntel,Sistema_origen	,Recibo_1,Ciclo_1,Fecha_Vencimiento_1,Total_Facturado_1,Fecha_Pago_1,Exigible_1
FROM Riesgo_ScoreConv_Fact_Mov_AMDOCS


---- ELIMINAR CLIENTES QUE ESTÁN EN AMDOCS
DELETE  Riesgo_ScoreConv_Fact_Mov
FROM Riesgo_ScoreConv_Fact_Mov A INNER JOIN  Riesgo_ScoreConv_Fact_Mov_AMDOCS B
ON A.CLIENTE=B.CLIENTE AND A.TCNTEL=B.TCNTEL

---- ELIMINAR CLIENTES QUE ESTÁN EN AMDOCS
DELETE  Riesgo_ScoreConv_Fact_Mov
FROM Riesgo_ScoreConv_Fact_Mov A INNER JOIN  Riesgo_ScoreConv_Fact_Mov_AMDOCS B
ON A.CLIENTE=B.CLIENTE AND A.TCNFOL=B.TCNFOL

--- INSERTA CLIENTES QUE SOLO SON STC
INSERT INTO Riesgo_ScoreConv_Fact_AMDOCS
SELECT * FROM  Riesgo_ScoreConv_Fact_Mov

--- LIMPIA TABLA
 TRUNCATE TABLE Riesgo_ScoreConv_Fact_Mov

 --- INSERTA TABLA
 INSERT INTO Riesgo_ScoreConv_Fact_Mov
 SELECT * FROM  Riesgo_ScoreConv_Fact_AMDOCS



 ------- PARCHE ------  Eliminar al cliente de toda la planta por telefono y vcto
 select * into Score_Validacion_STC from Riesgo_ScoreConv_Fact_Mov where Sistema_origen='STC'
 select * into Score_Validacion_AMD from Riesgo_ScoreConv_Fact_Mov where Sistema_origen<>'STC'

---- ELIMINO FACTURAS QUE YA ESTÁN EN AMDOCS
DELETE Score_Validacion_STC
FROM Score_Validacion_STC A INNER JOIN Score_Validacion_AMD B
ON  A.tcntel=B.tcntel AND A.FECHA_VENCIMIENTO_1=B.FECHA_VENCIMIENTO_1 

 TRUNCATE TABLE Riesgo_ScoreConv_Fact_Mov
 TRUNCATE TABLE Riesgo_ScoreConv_Fact_AMDOCS

 
 drop table  Riesgo_ScoreConv_Fact_Mov

 SELECT * into Riesgo_ScoreConv_Fact_Mov  FROM  Score_Validacion_STC
 
 INSERT INTO Riesgo_ScoreConv_Fact_Mov    
 SELECT * FROM  Score_Validacion_AMD
 
 drop table  Riesgo_ScoreConv_Fact_AMDOCS

 --SELECT * into Riesgo_ScoreConv_Fact_mov  FROM  Score_Validacion_STC   
 --SELECT * into Riesgo_ScoreConv_Fact_AMDOCS  FROM  Score_Validacion_AMD   

 --insert into Riesgo_ScoreConv_Fact_mov
 --SELECT * FROM Riesgo_ScoreConv_Fact_AMDOCS

 SELECT * into Riesgo_ScoreConv_Fact_AMDOCS FROM  Riesgo_ScoreConv_Fact_mov
 
 --SELECT COUNT(0) FROM  Riesgo_ScoreConv_Fact_mov    --11,606,504
 --SELECT COUNT(0) FROM  Riesgo_ScoreConv_Fact_AMDOCS   --11,032,475

 --SELECT COUNT(0) FROM  Score_Validacion_STC    --11,606,504
 --SELECT COUNT(0) FROM  Score_Validacion_AMD   --11,032,475

 drop table Score_Validacion_STC
 drop table Score_Validacion_AMD


 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------FACTURADO FIJA ------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------
 
 
truncate table   Riesgo_ScoreConv_Fact_Fij  

insert into Riesgo_ScoreConv_Fact_Fij
SELECT DISTINCT 
LTRIM(RTRIM(cliente)) AS Cliente,
LTRIM(RTRIM(cuenta)) AS Cuenta,
'N.EEEEEEEEEEEEE' AS Inscripcion,
LTRIM(RTRIM(telefono)) AS Telefono,
'ATIS' AS Sistema_origen,
LTRIM(RTRIM(Nro_RECIBO)) AS Recibo_1,
Ciclo AS Ciclo_1,
CAST(fec_vto AS DATE) AS Fecha_Vencimiento_1,
Total_Factur AS Total_Facturado_1,
CASE WHEN fecha_transaccion_final IS NOT NULL THEN CAST(LTRIM(RTRIM(fecha_transaccion_final)) AS DATE) ELSE NULL END AS Fecha_Pago_1,0
FROM    BD_COCI..RAV_VENCIMIENTO_TRANSFERENCIA
 where DATEDIFF(MONTH,CONVERT(smalldatetime,fec_vto,121),convert(varchar(10),getdate()+8,112))>=1 
 and DATEDIFF(MONTH,CONVERT(smalldatetime,fec_vto,121),convert(varchar(10),getdate()+8,112))<=6
AND Total_Factur > 0
ORDER BY Cliente, Cuenta

 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------ACTUALIZA DEUDA FIJA ------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------
 
UPDATE Riesgo_ScoreConv_Fact_Fij
SET
Exigible_1 = CASE WHEN LTRIM(RTRIM(S_MTO_TOT_IM)) = '+' THEN B.MTO_TOT_IM
                  WHEN LTRIM(RTRIM(S_MTO_TOT_IM)) = '-' THEN 0
                  ELSE 0 END
FROM Riesgo_ScoreConv_Fact_Fij A
LEFT JOIN COPA.ATIS.cop_detalle_saldos B	WITH (NOLOCK)	
ON RIGHT('0000000000000'+A.Cliente,13) = RIGHT('0000000000000'+LTRIM(RTRIM(B.COD_CLI_CD)),13) 
AND RIGHT('0000000000000'+A.Cuenta,13) = RIGHT('0000000000000'+LTRIM(RTRIM(B.COD_CTA_CD)),13) 
AND RIGHT('000000000000000'+A.Recibo_1,15) = RIGHT('000000000000000'+LTRIM(RTRIM(B.NUM_DOC_NU)),15)
COLLATE Latin1_General_CI_AS

 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------CONTACTO FIJA ------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------

UPDATE Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm
SET Contactos_Fij = ISNULL(B.Q,0)
FROM Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm A
LEFT JOIN (
	SELECT LEFT(LTRIM(RTRIM(FECHA_LLAMADA)),6) AS MES, 
	CASE WHEN LEFT(LTRIM(RTRIM(DNI_CLIENTE)),1) = '_' THEN SUBSTRING(LTRIM(RTRIM(DNI_CLIENTE)),2,20) ELSE SUBSTRING(LTRIM(RTRIM(DNI_CLIENTE)),1,20) END AS DNI_CLIENTE,
	COUNT(*) AS Q 
	FROM  GPPESPLCLI1005.SRMS.dbo.IC_PV_MAE_CONTACTOS_FIJA_ATENTO_201505_201512 --bd_coci..IC_PV_MAE_CONTACTOS_FIJA_ATENTO_201505_201512
	GROUP BY LEFT(LTRIM(RTRIM(FECHA_LLAMADA)),6), 
	CASE WHEN LEFT(LTRIM(RTRIM(DNI_CLIENTE)),1) = '_' THEN SUBSTRING(LTRIM(RTRIM(DNI_CLIENTE)),2,20) ELSE SUBSTRING(LTRIM(RTRIM(DNI_CLIENTE)),1,20) END) B						
	ON RIGHT('0000000000000'+A.nro_identificacion,13) = RIGHT('0000000000000'+LTRIM(RTRIM(B.DNI_CLIENTE)),13) 
	AND DATEDIFF(MONTH,B.MES+'01',A.Fecha_Vencimiento_0) = 1
	
 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------FACTURADO CABLE ------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------

 

truncate table  Riesgo_ScoreConv_Fact_Tmm 

insert into Riesgo_ScoreConv_Fact_Tmm 
SELECT DISTINCT 
LTRIM(RTRIM(CLIENTE)) AS Cliente,
LTRIM(RTRIM(CUENTA)) AS Cuenta,
LTRIM(RTRIM(COD_SERVICIO)) AS Servicio,
'CMS' AS Sistema_origen,
LTRIM(RTRIM(NRO_COMPROB_CMS)) AS Recibo_1,
FECHA_EMISION AS Emision_1,
CAST(FECHA_VENCIMIENTO AS DATE) AS Fecha_Vencimiento_1,
TOTAL_IMPORTE AS Total_Facturado_1,
CASE WHEN FECHA_PAGO IS NOT NULL THEN CAST(LTRIM(RTRIM(FECHA_PAGO)) AS DATE) ELSE NULL END AS Fecha_Pago_1,0
FROM  BD_COCI..TMM_01_FACTURADO_HISTORICO_INPUT
 where DATEDIFF(MONTH,CONVERT(smalldatetime,FECHA_VENCIMIENTO,121),convert(varchar(10),getdate()+8,112))>=1 
 and DATEDIFF(MONTH,CONVERT(smalldatetime,FECHA_VENCIMIENTO,121),convert(varchar(10),getdate()+8,112))<=6
AND TOTAL_IMPORTE > 0
ORDER BY Cliente, Cuenta


 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------ACTUALIZA DEUDA CABLE ------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------
 
UPDATE Riesgo_ScoreConv_Fact_Tmm
SET Exigible_1 = ISNULL(B.Mto_Exigible,0)   
FROM Riesgo_ScoreConv_Fact_Tmm A
LEFT JOIN  COB_operaciones..tmm_sal_mae_documentos B			
ON RIGHT('0000000000000'+LTRIM(RTRIM(A.Cliente)),13) = RIGHT('0000000000000'+LTRIM(RTRIM(B.CLIENTE)),13)
AND RIGHT('0000000000000'+LTRIM(RTRIM(A.Cuenta)),13) = RIGHT('0000000000000'+LTRIM(RTRIM(B.CUENTA)),13)
AND RIGHT('000000000000000'+LTRIM(RTRIM(A.Recibo_1)),15) = RIGHT('000000000000000'+LTRIM(RTRIM(B.Nro_Documento)),15)


--DBCC SHRINKFILE (Cob_Operaciones_log, 1) WITH NO_INFOMSGS;


 --------------------------------------------------------------------------------------------------------------------------
 ----------------------------------------------------- ACTUALIZACIÓN CLIENTES EN NULL ------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------
 
UPDATE cob_operaciones..Riesgo_ScoreConv_Fact_Tmm SET
CLIENTE=B.CLIENTE
FROM cob_operaciones..Riesgo_ScoreConv_Fact_Tmm a inner join  TMM_SAL_MAE_SERVICIOS b
on  a.cuenta =b.cuenta and a.servicio =b.servicio and (a.cliente is null or  a.cliente='')


 --------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------PROCEDIMIENTO ------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------
 
----DROP TABLE Riesgo_ScoreConv

----SELECT COD_TIPO_IDENTIFICACION AS TIP_DOC, RIGHT('000000000000000'+LTRIM(RTRIM(NRO_IDENTIFICACION)),15) AS DOC, COD_SEGMENTO AS SEG, 
----MIN(MAX_FECHA_ALTA) AS MAX_FEC_ALTA
----INTO Riesgo_ScoreConv
----FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm
----GROUP BY COD_TIPO_IDENTIFICACION, RIGHT('000000000000000'+LTRIM(RTRIM(NRO_IDENTIFICACION)),15), COD_SEGMENTO

----ALTER TABLE Riesgo_ScoreConv
----ADD
----ANTIG INT


----UPDATE Riesgo_ScoreConv
----SET ANTIG = CASE WHEN MAX_FEC_ALTA IS NULL THEN NULL ELSE DATEDIFF(MONTH,MAX_FEC_ALTA,GETDATE()) END
----FROM Riesgo_ScoreConv A


----ALTER TABLE Riesgo_ScoreConv
----ADD
----FACT1_SUM_TF NUMERIC(15,2),
----FACT2_SUM_TF NUMERIC(15,2),
----FACT3_SUM_TF NUMERIC(15,2),
----FACT4_SUM_TF NUMERIC(15,2),
----FACT5_SUM_TF NUMERIC(15,2),
----FACT6_SUM_TF NUMERIC(15,2),
----FACT1_Q_TF INT,
----FACT2_Q_TF INT,
----FACT3_Q_TF INT,
----FACT4_Q_TF INT,
----FACT5_Q_TF INT,
----FACT6_Q_TF INT,
----FACT1_SUM_TM NUMERIC(15,2),
----FACT2_SUM_TM NUMERIC(15,2),
----FACT3_SUM_TM NUMERIC(15,2),
----FACT4_SUM_TM NUMERIC(15,2),
----FACT5_SUM_TM NUMERIC(15,2),
----FACT6_SUM_TM NUMERIC(15,2),
----FACT1_Q_TM INT,
----FACT2_Q_TM INT,
----FACT3_Q_TM INT,
----FACT4_Q_TM INT,
----FACT5_Q_TM INT,
----FACT6_Q_TM INT,
----FACT1_SUM_CABLE NUMERIC(15,2),
----FACT2_SUM_CABLE NUMERIC(15,2),
----FACT3_SUM_CABLE NUMERIC(15,2),
----FACT4_SUM_CABLE NUMERIC(15,2),
----FACT5_SUM_CABLE NUMERIC(15,2),
----FACT6_SUM_CABLE NUMERIC(15,2),
----FACT1_Q_CABLE INT,
----FACT2_Q_CABLE INT,
----FACT3_Q_CABLE INT,
----FACT4_Q_CABLE INT,
----FACT5_Q_CABLE INT,
----FACT6_Q_CABLE INT



----ALTER TABLE Riesgo_ScoreConv
----ADD
----DPAGO1_PROM_TF NUMERIC(15,2),
----DPAGO2_PROM_TF NUMERIC(15,2),
----DPAGO3_PROM_TF NUMERIC(15,2),
----DPAGO4_PROM_TF NUMERIC(15,2),
----DPAGO5_PROM_TF NUMERIC(15,2),
----DPAGO6_PROM_TF NUMERIC(15,2),
----DPAGO1_MAX_TF NUMERIC(15,2),
----DPAGO1_PROM_TM NUMERIC(15,2),
----DPAGO2_PROM_TM NUMERIC(15,2),
----DPAGO3_PROM_TM NUMERIC(15,2),
----DPAGO4_PROM_TM NUMERIC(15,2),
----DPAGO5_PROM_TM NUMERIC(15,2),
----DPAGO6_PROM_TM NUMERIC(15,2),
----DPAGO1_MAX_TM NUMERIC(15,2),
----DPAGO1_PROM_CABLE NUMERIC(15,2),
----DPAGO2_PROM_CABLE NUMERIC(15,2),
----DPAGO3_PROM_CABLE NUMERIC(15,2),
----DPAGO4_PROM_CABLE NUMERIC(15,2),
----DPAGO5_PROM_CABLE NUMERIC(15,2),
----DPAGO6_PROM_CABLE NUMERIC(15,2),
----DPAGO1_MAX_CABLE NUMERIC(15,2)



----UPDATE Riesgo_ScoreConv
----SET 
----FACT1_SUM_TF = ISNULL(Q.FACT,0),
----FACT1_Q_TF = ISNULL(Q.FACT_Q,0),
----DPAGO1_PROM_TF = DPAGO,
----DPAGO1_MAX_TF = DPAGO_MAX
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,GETDATE()) <= 30 
----           AND Fecha_Pago_1 IS NULL THEN DATEDIFF(DAY,Fecha_Vencimiento_1,GETDATE()) 
----           WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO,
----           MAX(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,GETDATE()) <= 30 AND Fecha_Pago_1 IS NULL THEN DATEDIFF(DAY,Fecha_Vencimiento_1,GETDATE()) 
----           WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END) AS DPAGO_MAX
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN  Riesgo_ScoreConv_Fact_Fij B			
----           ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 0
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			
----ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT2_SUM_TF = ISNULL(Q.FACT,0),
----FACT2_Q_TF = ISNULL(Q.FACT_Q,0),
----DPAGO2_PROM_TF = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Fij B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 1
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT3_SUM_TF = ISNULL(Q.FACT,0),
----FACT3_Q_TF = ISNULL(Q.FACT_Q,0),
----DPAGO3_PROM_TF = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Fij B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 2
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT4_SUM_TF = ISNULL(Q.FACT,0),
----FACT4_Q_TF = ISNULL(Q.FACT_Q,0),
----DPAGO4_PROM_TF = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Fij B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 3 
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT5_SUM_TF = ISNULL(Q.FACT,0),
----FACT5_Q_TF = ISNULL(Q.FACT_Q,0),
----DPAGO5_PROM_TF = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Fij B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 4
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT6_SUM_TF = ISNULL(Q.FACT,0),
----FACT6_Q_TF = ISNULL(Q.FACT_Q,0),
----DPAGO6_PROM_TF = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Fij B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 5
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT1_SUM_TM = ISNULL(Q.FACT,0),
----FACT1_Q_TM = ISNULL(Q.FACT_Q,0),
----DPAGO1_PROM_TM = DPAGO,
----DPAGO1_MAX_TM = DPAGO_MAX
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,GETDATE()) <= 30 
----           AND Fecha_Pago_1 IS NULL THEN DATEDIFF(DAY,Fecha_Vencimiento_1,GETDATE()) 
----           WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO,
----           MAX(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,GETDATE()) <= 30 AND Fecha_Pago_1 IS NULL THEN DATEDIFF(DAY,Fecha_Vencimiento_1,GETDATE()) 
----           WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END) AS DPAGO_MAX
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN  Riesgo_ScoreConv_Fact_Mov B			
----           ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 0
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			
----ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT2_SUM_TM = ISNULL(Q.FACT,0),
----FACT2_Q_TM = ISNULL(Q.FACT_Q,0),
----DPAGO2_PROM_TM = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Mov B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 1
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT3_SUM_TM = ISNULL(Q.FACT,0),
----FACT3_Q_TM = ISNULL(Q.FACT_Q,0),
----DPAGO3_PROM_TM = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Mov B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 2
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT4_SUM_TM = ISNULL(Q.FACT,0),
----FACT4_Q_TM = ISNULL(Q.FACT_Q,0),
----DPAGO4_PROM_TM = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Mov B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 3 
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT5_SUM_TM = ISNULL(Q.FACT,0),
----FACT5_Q_TM = ISNULL(Q.FACT_Q,0),
----DPAGO5_PROM_TM = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Mov B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 4
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT6_SUM_TM = ISNULL(Q.FACT,0),
----FACT6_Q_TM = ISNULL(Q.FACT_Q,0),
----DPAGO6_PROM_TM = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Mov B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 5
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT1_SUM_CABLE = ISNULL(Q.FACT,0),
----FACT1_Q_CABLE = ISNULL(Q.FACT_Q,0),
----DPAGO1_PROM_CABLE = DPAGO,
----DPAGO1_MAX_CABLE = DPAGO_MAX
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,GETDATE()) <= 30 
----           AND Fecha_Pago_1 IS NULL THEN DATEDIFF(DAY,Fecha_Vencimiento_1,GETDATE()) 
----           WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO,
----           MAX(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,GETDATE()) <= 30 AND Fecha_Pago_1 IS NULL THEN DATEDIFF(DAY,Fecha_Vencimiento_1,GETDATE()) 
----           WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END) AS DPAGO_MAX
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN  Riesgo_ScoreConv_Fact_Tmm B			
----           ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 0
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			
----ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT2_SUM_CABLE = ISNULL(Q.FACT,0),
----FACT2_Q_CABLE = ISNULL(Q.FACT_Q,0),
----DPAGO2_PROM_CABLE = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Tmm B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 1
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT3_SUM_CABLE = ISNULL(Q.FACT,0),
----FACT3_Q_CABLE = ISNULL(Q.FACT_Q,0),
----DPAGO3_PROM_CABLE = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Tmm B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 2
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT4_SUM_CABLE = ISNULL(Q.FACT,0),
----FACT4_Q_CABLE = ISNULL(Q.FACT_Q,0),
----DPAGO4_PROM_CABLE = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Tmm B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 3 
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT5_SUM_CABLE = ISNULL(Q.FACT,0),
----FACT5_Q_CABLE = ISNULL(Q.FACT_Q,0),
----DPAGO5_PROM_CABLE = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Tmm B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 4
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----UPDATE Riesgo_ScoreConv
----SET 
----FACT6_SUM_CABLE = ISNULL(Q.FACT,0),
----FACT6_Q_CABLE = ISNULL(Q.FACT_Q,0),
----DPAGO6_PROM_CABLE = DPAGO
----FROM Riesgo_ScoreConv P
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15) AS DOC, SUM(B.Total_Facturado_1) AS FACT, COUNT(B.Total_Facturado_1) AS FACT_Q,
----           ROUND(AVG(CASE WHEN DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) > 90 OR Fecha_Pago_1 IS NULL THEN 90 ELSE DATEDIFF(DAY,Fecha_Vencimiento_1,Fecha_Pago_1) END),0) AS DPAGO
----           FROM (SELECT DISTINCT NRO_IDENTIFICACION, COD_CLIENTE FROM Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm) A
----           INNER JOIN Riesgo_ScoreConv_Fact_Tmm B			ON RIGHT('0000000000000'+A.COD_CLIENTE,13) = RIGHT('0000000000000'+B.Cliente,13) AND DATEDIFF(MONTH,Fecha_Vencimiento_1,GETDATE()) = 5
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(A.NRO_IDENTIFICACION)),15)) Q			ON P.DOC = Q.DOC


----ALTER TABLE Riesgo_ScoreConv
----ADD
----CONT1_TF INT,
----CONT1_TM INT,
----CONT_ULT1M INT


----UPDATE Riesgo_ScoreConv
----SET
----CONT1_TF = ISNULL(B.CONT1,0)
----FROM Riesgo_ScoreConv A
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(nro_identificacion)),15) AS DOC, SUM(Contactos_fij) AS CONT1
----           FROM Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(nro_identificacion)),15)) B		ON A.DOC = B.DOC


----UPDATE Riesgo_ScoreConv
----SET
----CONT1_TM = ISNULL(B.CONT1,0)
----FROM Riesgo_ScoreConv A
----LEFT JOIN (SELECT RIGHT('000000000000000'+LTRIM(RTRIM(nro_identificacion)),15) AS DOC, SUM(Contactos_mov) AS CONT1
----           FROM Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm
----           GROUP BY RIGHT('000000000000000'+LTRIM(RTRIM(nro_identificacion)),15)) B		ON A.DOC = B.DOC


----UPDATE Riesgo_ScoreConv
----SET
----CONT_ULT1M = CONT1_TF + CONT1_TM
----FROM Riesgo_ScoreConv A


----ALTER TABLE Riesgo_ScoreConv
----ADD
----FACT1_SUM NUMERIC(15,2),
----FACT2_SUM NUMERIC(15,2),
----FACT3_SUM NUMERIC(15,2),
----FACT4_SUM NUMERIC(15,2),
----FACT5_SUM NUMERIC(15,2),
----FACT6_SUM NUMERIC(15,2),
----INDF1 SMALLINT,
----INDF2 SMALLINT,
----INDF3 SMALLINT,
----INDF4 SMALLINT,
----INDF5 SMALLINT,
----INDF6 SMALLINT


----UPDATE Riesgo_ScoreConv
----SET
----FACT1_SUM = FACT1_SUM_TF + FACT1_SUM_TM + FACT1_SUM_CABLE,
----FACT2_SUM = FACT2_SUM_TF + FACT2_SUM_TM + FACT2_SUM_CABLE,
----FACT3_SUM = FACT3_SUM_TF + FACT3_SUM_TM + FACT3_SUM_CABLE,
----FACT4_SUM = FACT4_SUM_TF + FACT4_SUM_TM + FACT4_SUM_CABLE,
----FACT5_SUM = FACT5_SUM_TF + FACT5_SUM_TM + FACT5_SUM_CABLE,
----FACT6_SUM = FACT6_SUM_TF + FACT6_SUM_TM + FACT6_SUM_CABLE,
----INDF1 = CASE WHEN FACT1_Q_TF + FACT1_Q_TM + FACT1_Q_CABLE > 0 THEN 1 ELSE 0 END, 
----INDF2 = CASE WHEN FACT2_Q_TF + FACT2_Q_TM + FACT2_Q_CABLE > 0 THEN 1 ELSE 0 END, 
----INDF3 = CASE WHEN FACT3_Q_TF + FACT3_Q_TM + FACT3_Q_CABLE > 0 THEN 1 ELSE 0 END, 
----INDF4 = CASE WHEN FACT4_Q_TF + FACT4_Q_TM + FACT4_Q_CABLE > 0 THEN 1 ELSE 0 END, 
----INDF5 = CASE WHEN FACT5_Q_TF + FACT5_Q_TM + FACT5_Q_CABLE > 0 THEN 1 ELSE 0 END, 
----INDF6 = CASE WHEN FACT6_Q_TF + FACT6_Q_TM + FACT6_Q_CABLE > 0 THEN 1 ELSE 0 END
----FROM Riesgo_ScoreConv


----ALTER TABLE Riesgo_ScoreConv
----ADD
----DPAGO1_PROM NUMERIC(15,2),
----DPAGO2_PROM NUMERIC(15,2),
----DPAGO3_PROM NUMERIC(15,2),
----DPAGO4_PROM NUMERIC(15,2),
----DPAGO5_PROM NUMERIC(15,2),
----DPAGO6_PROM NUMERIC(15,2),
----DPAGO1_MAX NUMERIC(15,2)


----UPDATE Riesgo_ScoreConv
----SET
----DPAGO1_PROM = CASE WHEN (CASE WHEN DPAGO1_PROM_TF IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO1_PROM_TM IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO1_PROM_CABLE IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN -99 
----                   ELSE ROUND((ISNULL(DPAGO1_PROM_TF,0) + ISNULL(DPAGO1_PROM_TM,0) + ISNULL(DPAGO1_PROM_CABLE,0)) / (CASE WHEN DPAGO1_PROM_TF IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO1_PROM_TM IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO1_PROM_CABLE IS NOT NULL THEN 1 ELSE 0 END),2) END,
----DPAGO2_PROM = CASE WHEN (CASE WHEN DPAGO2_PROM_TF IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO2_PROM_TM IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO2_PROM_CABLE IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN -99 
----                   ELSE ROUND((ISNULL(DPAGO2_PROM_TF,0) + ISNULL(DPAGO2_PROM_TM,0) + ISNULL(DPAGO2_PROM_CABLE,0)) / (CASE WHEN DPAGO2_PROM_TF IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO2_PROM_TM IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO2_PROM_CABLE IS NOT NULL THEN 1 ELSE 0 END),2) END,
----DPAGO3_PROM = CASE WHEN (CASE WHEN DPAGO3_PROM_TF IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO3_PROM_TM IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO3_PROM_CABLE IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN -99 
----                   ELSE ROUND((ISNULL(DPAGO3_PROM_TF,0) + ISNULL(DPAGO3_PROM_TM,0) + ISNULL(DPAGO3_PROM_CABLE,0)) / (CASE WHEN DPAGO3_PROM_TF IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO3_PROM_TM IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO3_PROM_CABLE IS NOT NULL THEN 1 ELSE 0 END),2) END,
----DPAGO4_PROM = CASE WHEN (CASE WHEN DPAGO4_PROM_TF IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO4_PROM_TM IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO4_PROM_CABLE IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN -99 
----                   ELSE ROUND((ISNULL(DPAGO4_PROM_TF,0) + ISNULL(DPAGO4_PROM_TM,0) + ISNULL(DPAGO4_PROM_CABLE,0)) / (CASE WHEN DPAGO4_PROM_TF IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO4_PROM_TM IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO4_PROM_CABLE IS NOT NULL THEN 1 ELSE 0 END),2) END,
----DPAGO5_PROM = CASE WHEN (CASE WHEN DPAGO5_PROM_TF IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO5_PROM_TM IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO5_PROM_CABLE IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN -99 
----                   ELSE ROUND((ISNULL(DPAGO5_PROM_TF,0) + ISNULL(DPAGO5_PROM_TM,0) + ISNULL(DPAGO5_PROM_CABLE,0)) / (CASE WHEN DPAGO5_PROM_TF IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO5_PROM_TM IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO5_PROM_CABLE IS NOT NULL THEN 1 ELSE 0 END),2) END,
----DPAGO6_PROM = CASE WHEN (CASE WHEN DPAGO6_PROM_TF IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO6_PROM_TM IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO6_PROM_CABLE IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN -99 
----                   ELSE ROUND((ISNULL(DPAGO6_PROM_TF,0) + ISNULL(DPAGO6_PROM_TM,0) + ISNULL(DPAGO6_PROM_CABLE,0)) / (CASE WHEN DPAGO6_PROM_TF IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO6_PROM_TM IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO6_PROM_CABLE IS NOT NULL THEN 1 ELSE 0 END),2) END,                                                                           
----DPAGO1_MAX = CASE WHEN (CASE WHEN DPAGO1_MAX_TF IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO1_MAX_TM IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN DPAGO1_MAX_CABLE IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN -99
----                  ELSE CASE WHEN ISNULL(DPAGO1_MAX_TF,-99) >= ISNULL(DPAGO1_MAX_TM,-99) AND ISNULL(DPAGO1_MAX_TF,-99) >= ISNULL(DPAGO1_MAX_CABLE,-99) THEN ISNULL(DPAGO1_MAX_TF,-99)
----                            WHEN ISNULL(DPAGO1_MAX_TM,-99) >= ISNULL(DPAGO1_MAX_TF,-99) AND ISNULL(DPAGO1_MAX_TM,-99) >= ISNULL(DPAGO1_MAX_CABLE,-99) THEN ISNULL(DPAGO1_MAX_TM,-99) 
----                            ELSE ISNULL(DPAGO1_MAX_CABLE,-99) END END                                                                          
----FROM Riesgo_ScoreConv


----ALTER TABLE Riesgo_ScoreConv
----ADD
----DPAGO_PROM_ULT6M INT,
----DPAGO_PROM_ULT3M INT,
----FACT_PEND_ULT6M NUMERIC(15,2)


----UPDATE Riesgo_ScoreConv
----SET
----DPAGO_PROM_ULT6M = CASE WHEN ((CASE WHEN DPAGO1_PROM = -99 THEN 0 ELSE 1 END) + (CASE WHEN DPAGO2_PROM = -99 THEN 0 ELSE 1 END) + (CASE WHEN DPAGO3_PROM = -99 THEN 0 ELSE 1 END) + (CASE WHEN DPAGO4_PROM = -99 THEN 0 ELSE 1 END) + (CASE WHEN DPAGO5_PROM = -99 THEN 0 ELSE 1 END) + (CASE WHEN DPAGO6_PROM = -99 THEN 0 ELSE 1 END)) = 0 THEN -99 
----                        ELSE
----                         ((CASE WHEN DPAGO1_PROM = -99 THEN 0 ELSE 1 END)*DPAGO1_PROM + (CASE WHEN DPAGO2_PROM = -99 THEN 0 ELSE 1 END)*DPAGO2_PROM + (CASE WHEN DPAGO3_PROM = -99 THEN 0 ELSE 1 END)*DPAGO3_PROM + (CASE WHEN DPAGO4_PROM = -99 THEN 0 ELSE 1 END)*DPAGO4_PROM + (CASE WHEN DPAGO5_PROM = -99 THEN 0 ELSE 1 END)*DPAGO5_PROM + (CASE WHEN DPAGO6_PROM = -99 THEN 0 ELSE 1 END)*DPAGO6_PROM) / 
----                         ((CASE WHEN DPAGO1_PROM = -99 THEN 0 ELSE 1 END) + (CASE WHEN DPAGO2_PROM = -99 THEN 0 ELSE 1 END) + (CASE WHEN DPAGO3_PROM = -99 THEN 0 ELSE 1 END) + (CASE WHEN DPAGO4_PROM = -99 THEN 0 ELSE 1 END) + (CASE WHEN DPAGO5_PROM = -99 THEN 0 ELSE 1 END) + (CASE WHEN DPAGO6_PROM = -99 THEN 0 ELSE 1 END)) END,
----DPAGO_PROM_ULT3M = CASE WHEN ((CASE WHEN DPAGO1_PROM = -99 THEN 0 ELSE 1 END) + (CASE WHEN DPAGO2_PROM = -99 THEN 0 ELSE 1 END) + (CASE WHEN DPAGO3_PROM = -99 THEN 0 ELSE 1 END)) = 0 THEN -99 
----                        ELSE
----                         ((CASE WHEN DPAGO1_PROM = -99 THEN 0 ELSE 1 END)*DPAGO1_PROM + (CASE WHEN DPAGO2_PROM = -99 THEN 0 ELSE 1 END)*DPAGO2_PROM + (CASE WHEN DPAGO3_PROM = -99 THEN 0 ELSE 1 END)*DPAGO3_PROM) / 
----                         ((CASE WHEN DPAGO1_PROM = -99 THEN 0 ELSE 1 END) + (CASE WHEN DPAGO2_PROM = -99 THEN 0 ELSE 1 END) + (CASE WHEN DPAGO3_PROM = -99 THEN 0 ELSE 1 END)) END               
----FROM Riesgo_ScoreConv


----UPDATE Riesgo_ScoreConv
----SET
----FACT_PEND_ULT6M = (5*INDF1*FACT1_SUM + 3*INDF2*FACT2_SUM + INDF3*FACT3_SUM - INDF4*FACT4_SUM - 3*INDF5*FACT5_SUM - 5*INDF6*FACT6_SUM) / 35.0
----FROM Riesgo_ScoreConv


----ALTER TABLE Riesgo_ScoreConv
----ADD
----V_1 VARCHAR(2),
----V_2 VARCHAR(2),
----V_3 VARCHAR(2),
----V_4 VARCHAR(2),
----V_5 VARCHAR(2),
----V_6 VARCHAR(2),
----PROB decimal (10,6),
----GRUPO VARCHAR(3)


----UPDATE Riesgo_ScoreConv
----SET V_1 = CASE WHEN ANTIG >= 0 AND ANTIG <= 11 THEN '1'
----               WHEN ANTIG >= 12 AND ANTIG <= 21 THEN '2'
----               WHEN ANTIG >= 22 AND ANTIG <= 31 THEN '3'
----               WHEN ANTIG >= 32 AND ANTIG <= 48 THEN '4'
----               WHEN ANTIG >= 49 AND ANTIG <= 84 THEN '5'
----               WHEN ANTIG >= 85 THEN '6'
----               ELSE '99' END
----FROM Riesgo_ScoreConv


----UPDATE Riesgo_ScoreConv
----SET V_2 = CASE WHEN DPAGO1_MAX = -99 THEN '3'
----               WHEN DPAGO1_MAX <= 21 THEN '1'
----               WHEN DPAGO1_MAX <= 64 THEN '2'
----               WHEN DPAGO1_MAX > 64 THEN '4'
----               ELSE '99' END
----FROM Riesgo_ScoreConv


----UPDATE Riesgo_ScoreConv
----SET V_3 = CASE WHEN FACT_PEND_ULT6M <= -7.57 OR FACT_PEND_ULT6M > 14.24 OR INDF1 + INDF2 + INDF3 + INDF4 + INDF5 + INDF6 <= 1 THEN '1'
----               WHEN (FACT_PEND_ULT6M > -7.57 AND FACT_PEND_ULT6M <= -1.915) OR (FACT_PEND_ULT6M > 3.969 AND FACT_PEND_ULT6M <= 14.24) THEN '2'
----               WHEN FACT_PEND_ULT6M > 1.423 AND FACT_PEND_ULT6M <= 3.969 THEN '3'
----               WHEN (FACT_PEND_ULT6M > -1.915 AND FACT_PEND_ULT6M <= -0.216) OR (FACT_PEND_ULT6M >= 0 AND FACT_PEND_ULT6M <= 1.423) THEN '4'
----               WHEN FACT_PEND_ULT6M > -0.216 AND FACT_PEND_ULT6M < 0 THEN '5'
----               ELSE '99' END
----FROM Riesgo_ScoreConv


----UPDATE Riesgo_ScoreConv
----SET V_4 = CASE WHEN CONT_ULT1M = 0 THEN '1'
----               WHEN CONT_ULT1M >= 1 THEN '2'
----               ELSE '99' END
----FROM Riesgo_ScoreConv


----UPDATE Riesgo_ScoreConv
----SET V_5 = CASE WHEN DPAGO_PROM_ULT3M <= 0 AND DPAGO_PROM_ULT3M <> -99 THEN '1'
----               WHEN DPAGO_PROM_ULT3M <= 2 AND DPAGO_PROM_ULT3M <> -99 THEN '2'
----               WHEN DPAGO_PROM_ULT3M <= 4 AND DPAGO_PROM_ULT3M <> -99 THEN '3'
----               WHEN DPAGO_PROM_ULT3M <= 6 AND DPAGO_PROM_ULT3M <> -99 THEN '4'
----               WHEN DPAGO_PROM_ULT3M <= 11 OR DPAGO_PROM_ULT3M = -99 THEN '5'
----               WHEN DPAGO_PROM_ULT3M <= 37 THEN '6'
----               WHEN DPAGO_PROM_ULT3M > 37 THEN '7'
----               ELSE '99' END
----FROM Riesgo_ScoreConv


----UPDATE Riesgo_ScoreConv
----SET V_6 = CASE WHEN DPAGO_PROM_ULT6M <= -1 AND DPAGO_PROM_ULT6M <> -99 THEN '1'
----               WHEN DPAGO_PROM_ULT6M <= 0 AND DPAGO_PROM_ULT6M <> -99 THEN '2'
----               WHEN DPAGO_PROM_ULT6M <= 2 AND DPAGO_PROM_ULT6M <> -99 THEN '3'
----               WHEN DPAGO_PROM_ULT6M <= 4 AND DPAGO_PROM_ULT6M <> -99 THEN '4'
----               WHEN DPAGO_PROM_ULT6M <= 7 AND DPAGO_PROM_ULT6M <> -99 THEN '5'
----               WHEN DPAGO_PROM_ULT6M <= 18 OR DPAGO_PROM_ULT6M = -99 THEN '6'
----               WHEN DPAGO_PROM_ULT6M <= 33 THEN '7'
----               WHEN DPAGO_PROM_ULT6M > 33 THEN '8'
----               ELSE '99' END
----FROM Riesgo_ScoreConv


----UPDATE Riesgo_ScoreConv
----SET PROB = ROUND(1/(1+EXP(-1*(-0.2444 + 
----           CASE WHEN V_1 = '1' THEN -0.5414 WHEN V_1 = '2' THEN -0.4347 WHEN V_1 = '3' THEN -0.2482 WHEN V_1 = '4' THEN -0.1966 WHEN V_1 = '5' THEN -0.1268
----                WHEN V_1 = '6' THEN 0 END + 
----           CASE WHEN V_2 = '1' THEN 1.572 WHEN V_2 = '2' THEN 1.141 WHEN V_2 = '3' THEN 0.8873 WHEN V_2 = '4' THEN 0 END +
----           CASE WHEN V_3 = '1' THEN -0.5152 WHEN V_3 = '2' THEN -0.3666 WHEN V_3 = '3' THEN -0.2018 WHEN V_3 = '4' THEN -0.1092 WHEN V_3 = '5' THEN 0 END +
----           CASE WHEN V_4 = '1' THEN 0.1234 WHEN V_4 = '2' THEN 0 END +
----           CASE WHEN V_5 = '1' THEN 0.9077 WHEN V_5 = '2' THEN 0.7999 WHEN V_5 = '3' THEN 0.68 WHEN V_5 = '4' THEN 0.5849 WHEN V_5 = '5' THEN 0.5683
----                WHEN V_5 = '6' THEN 0.2199 WHEN V_5 = '7' THEN 0 END +
----           CASE WHEN V_6 = '1' THEN 2.246 WHEN V_6 = '2' THEN 1.946 WHEN V_6 = '3' THEN 1.654 WHEN V_6 = '4' THEN 1.454 WHEN V_6 = '5' THEN 1.229
----                WHEN V_6 = '6' THEN 1.098 WHEN V_6 = '7' THEN 0.5513 WHEN V_6 = '8' THEN 0 END))),6) 
----FROM Riesgo_ScoreConv


----UPDATE Riesgo_ScoreConv
----SET GRUPO = CASE WHEN PROB >= 0.96573106 THEN '1'
----                 WHEN PROB >= 0.92600877 THEN '2'
----                 WHEN PROB >= 0.82564713 THEN '3'
----                 WHEN PROB >= 0.75110464 THEN '4'
----                 WHEN PROB >= 0.53074909 THEN '5'
----                 WHEN PROB < 0.53074909 AND PROB >= 0 THEN '6'
----                 ELSE '99' END
----FROM Riesgo_ScoreConv

----drop table Riesgo_ScoreConv_Grupos

----SELECT DOC, GRUPO
----INTO Riesgo_ScoreConv_Grupos
----FROM Riesgo_ScoreConv
----WHERE ANTIG >= 6 AND INDF1 + INDF2 + INDF3 + INDF4 + INDF5 + INDF6 >= 3


--Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm
--Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm
--Riesgo_ScoreConv_Sal_Mov
--Riesgo_ScoreConv_Fact_Mov
--Riesgo_ScoreConv_Fact_Fij
--Riesgo_ScoreConv_Fact_Tmm

  --Declare @exportar as varchar(1000)         
  --SET @exportar= 'bcp "select * from cob_operaciones..Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm"  QUERYOUT "\\gppesplcli1212\servidor_FACO\operaciones\DESA\GESTORES\MOVIL\Pagos\HOY\Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm1212.txt"  -c -t^| -T -P'
  --EXEC master..xp_cmdshell @exportar	
  
  Declare @exportar1 as varchar(1000)         
  SET @exportar1= 'bcp "select * from cob_operaciones..Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm"  QUERYOUT "\\gppesplcli1212\servidor_FACO\operaciones\DESA\GESTORES\MOVIL\Pagos\HOY\Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm.txt"  -c -t^| -T -P'
  EXEC master..xp_cmdshell @exportar1	
  
  Declare @exportar2 as varchar(1000)         
  SET @exportar2= 'bcp "select * from cob_operaciones..Riesgo_ScoreConv_Sal_Mov"  QUERYOUT "\\gppesplcli1212\servidor_FACO\operaciones\DESA\GESTORES\MOVIL\Pagos\HOY\Riesgo_ScoreConv_Sal_Mov.txt"  -c -t^| -T -P'
  EXEC master..xp_cmdshell @exportar2
  
  Declare @exportar3 as varchar(1000)         
  SET @exportar3= 'bcp "select * from cob_operaciones..Riesgo_ScoreConv_Fact_Mov"  QUERYOUT "\\gppesplcli1212\servidor_FACO\operaciones\DESA\GESTORES\MOVIL\Pagos\HOY\Riesgo_ScoreConv_Fact_Mov.txt"  -c -t^| -T -P'
  EXEC master..xp_cmdshell @exportar3	
    
  Declare @exportar4 as varchar(1000)         
  SET @exportar4= 'bcp "select * from cob_operaciones..Riesgo_ScoreConv_Fact_Fij"  QUERYOUT "\\gppesplcli1212\servidor_FACO\operaciones\DESA\GESTORES\MOVIL\Pagos\HOY\Riesgo_ScoreConv_Fact_Fij.txt"  -c -t^| -T -P'
  EXEC master..xp_cmdshell @exportar4	
  
  Declare @exportar5 as varchar(1000)         
  SET @exportar5= 'bcp "select * from cob_operaciones..Riesgo_ScoreConv_Fact_Tmm"  QUERYOUT "\\gppesplcli1212\servidor_FACO\operaciones\DESA\GESTORES\MOVIL\Pagos\HOY\Riesgo_ScoreConv_Fact_Tmm.txt"  -c -t^| -T -P'
  EXEC master..xp_cmdshell @exportar5

END
