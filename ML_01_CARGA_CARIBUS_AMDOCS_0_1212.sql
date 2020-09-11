USE COBRANZA_PROD

--03-MARZO-20	 10 MIN 

/****************************************************************************************************************************************/
PRINT '/**********  INICIO DE SCRIPT 01_CARGA_CARIBUS_AMDOCS_0_1212  **********\'
PRINT 'HORA INICIO: ' + cast(cast(getdate() as dateTIME) as varchar(20))
/****************************************************************************************************************************************/


/**********************************************************************************************************/
------------------------  *********** EJECUTAR EN 1212 ********************  -----------------------------
/**********************************************************************************************************/

Drop table COB_OPERACIONES.DBO.JAS_FullStack_Mov_Sal_Mae_Caribu_Flag_Collection

CREATE TABLE  COB_OPERACIONES.DBO.JAS_FullStack_Mov_Sal_Mae_Caribu_Flag_Collection(
	CUENTA_FINANCIERA varchar(10) NULL,
	CARIBU_FLAG	 varchar(1) NULL,
	CARIBU_START_DATE  varchar(10) NULL
)


insert into COB_OPERACIONES.DBO.JAS_FullStack_Mov_Sal_Mae_Caribu_Flag_Collection
select *
from openquery(amdocs,'
SELECT DISTINCT financial_account_key,CARIBU_FLAG,CARIBU_START_DATE from odsdmp.financial_account 
where CARIBU_FLAG in (''Y'',''N'')  OR CARIBU_START_DATE is not null
'
)

DELETE COB_OPERACIONES.DBO.JAS_FullStack_Mov_Sal_Mae_Caribu_Flag_Collection
where CARIBU_FLAG is null

--- EXPORTANDO

EXEC SP_EXPORTAR_TABLA_1212_JAS 'COB_OPERACIONES','DBO','JAS_FullStack_Mov_Sal_Mae_Caribu_Flag_Collection','',''


/****************************************************************************************************************************************/
PRINT 'HORA FIN: ' + cast(cast(getdate() as dateTIME) as varchar(20))
PRINT '\**********  FIN DE SCRIPT 01_CARGA_CARIBUS_AMDOCS_0_1212  **********/'
/****************************************************************************************************************************************/