---------------------------------------------------------------
--------------- VALIDACIONES ----------GPPESPLCLI1005 ---------
---------------------------------------------------------------
--ASEGURAR QUE ESTÉN ACTUALIZADOA LAS BASES (MAESTRAS LUNA)  EN BD COBRA:

--PASO 1 OK

--SERVIDOR		:	GPPESPLCLI1005
--BASE DATOS	:	COBRA

select COUNT(*) from LUNA.VIEW_RESUMEN_LUNA_SERVICIO        --73330582                             
select COUNT(*) from LUNA.VIEW_MASTER_CUENTA                --45637770                             


---------------------------------------------------------------
--------------- VALIDACIONES --------GPPESPLCLI1212 ----------- 
---------------------------------------------------------------
--PASO 2 OK

--SERVIDOR	:	GPPESPLCLI1212

select COUNT(*) from BD_COCI.DBO.MOVIL_HISTORICO_FACTURADO_INPUT                   --FACTURADO MOVIL (STC)
select COUNT(*) from Cob_Operaciones..Mov_Sal_Mae_Documentos                       --DEUDA MOVIL (STC  
select COUNT(*) FROM BD_COCI.DBO.IC_PV_MAE_CONTACTOS_MOVIL                         --BASE CONTACTO MOVIL
select COUNT(*) FROM BD_COCI..RAV_VENCIMIENTO_TRANSFERENCIA                        --FACTURADO FIJA (ATS) 
select COUNT(*) FROM Inteligencia_FaCo..RAV_2014								   --REGISTRO VENTAS (ATIS)   
select COUNT(*) FROM COPA.ATIS.cop_detalle_saldos								   -- DEUDA FIJA
--select COUNT(*) FROM bd_coci..IC_PV_MAE_CONTACTOS_FIJA_ATENTO_201505_201512      -- BASE CONTACTO FIJA (SE DEBE GENERAR, NO EXISTE)
select COUNT(*) FROM BD_COCI..TMM_01_FACTURADO_HISTORICO_INPUT                     -- FACTURADO CABLE
select COUNT(*) FROM COB_operaciones..tmm_sal_mae_documentos                       -- DEUDA CABLE


---------------------------------------------------------------
----------------- GPPESPLCLI1005 ------------------------------
------------ carga la base de plantas y exporta --------------- 
---------------------------------------------------------------

--PASO 3 OK 

--SERVIDOR	:	GPPESPLCLI1005

USE COBRA 
EXEC [SP_Riesgo_Score_Convergente_Planta]             
-- RESULTADO: select count(0) from  Riesgo_ScoreConv_Plantas_Fij_Mov_Tmmm			--13249424 


---------------------------------------------------------------
------------------------ GPPESPLCLI1212 -----------------------
--carga, cruza con facturados y deuda, después exporta tablas -
---------------------------------------------------------------
 
--PASO 4 OK

--SERVIDOR	:	GPPESPLCLI1212

USE Cob_Operaciones
EXEC [SP_Riesgo_Score_Convergente_Carga_ejecucion_Exportacion]


---------------------------------------------------------------
----------------------- GPPESPLCLI1005 ------------------------
--carga, ejecuta procedimiento de calculo y exporta tablas ---- 
---------------------------------------------------------------

--PASO 5 OK

--SERVIDOR	:	GPPESPLCLI1005

	
USE COBRA
exec [dbo].[SP_Riesgo_Score_Convergente_Cargar_y_Ejecutar_Proceso]  


-------------------------------------------------------------
---- TABLAS A VALIDAR EN 1005 cuantas aprox------------------
-------------------------------------------------------------

--																	MES ANTERIOR		MES ACTUAL
select count(0) from Riesgo_ScoreConv_Contactos_Fij_Mov_Tmmm       --	10789096		10906538		
select count(0) from Riesgo_ScoreConv_Sal_Mov                      --	32640758		32640758		
select count(0) from Riesgo_ScoreConv_Fact_Mov                     --	23800332		23278959		
select count(0) from Riesgo_ScoreConv_Fact_Fij                     --	11830623		11568220		
select count(0) from Riesgo_ScoreConv_Fact_Tmm                     --	720462			165643			
select count(0) from dbo.Riesgo_ScoreConv                          --	7399893			7443817			
select count(0) from dbo.Riesgo_ScoreConv_grupos                   --	4646259			4496688			





------------------------------------------------------------
-----EXPORTAR SCORE CONVERGENTE-----------------------------
------------------------------------------------------------



DECLARE @FECHA VARCHAR(10)
DECLARE @DIA VARCHAR(4) = RIGHT('00' + CONVERT(VARCHAR(2),DAY(GETDATE())),2)  
DECLARE @MES VARCHAR(4) = RIGHT('00' + CONVERT(VARCHAR(2),MONTH(GETDATE())),2)  	
DECLARE @EXP_TRAN_DEUDA_01 AS VARCHAR(1000) 
SET	@FECHA = @DIA +  @MES 

Declare @exportar4 as varchar(1000)         
SET @exportar4= 'bcp "select * from cobra.dbo.EXPORTAR_SCORE_CONVERGENTE"  QUERYOUT "\\gppesplcli1212\servidor_FACO\operaciones\DESA\GESTORES\MOVIL\Pagos\HOY\Riesgo_ScoreConv_'+ @FECHA +'.txt"  -c -t^| -T -P'
EXEC master..xp_cmdshell @exportar4   
