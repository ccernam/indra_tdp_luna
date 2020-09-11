use cobra 

--03-MARZO-2020 2 horas 47 MINUTOS  
/****************************************************************************************************************************************/
PRINT '/**********  INICIO DE SCRIPT 09_PASOS_UPDATE_MODELO_LUNA_02  **********\'
PRINT 'HORA INICIO: ' + cast(cast(getdate() as dateTIME) as varchar(20))
/****************************************************************************************************************************************/



EXEC [LUNA].[SP_RUN_ESTRATEGIA]	--OK 5 MINUTOS
go
EXEC [LUNA].[SP_LOAD_MASTER_CONTACTOS]	--OK 6 MINUTOS
go
-----------------------------------AGREGADO POR JAS ----------------------------------
EXEC LUNA.SP_ACTUALIZA_CONTACTOS_BASES_MASIVA_BI
-----------------------------------------------------------------------------------
go
--- ACTUALIZANDO PILOTOS POR SI SE REGULARIZARON ALGUNOS ---
EXEC LUNA.SP_RUN_PILOTOS
go

EXEC [LUNA].[SP_RUN_INDICADORES]	--1 HORA 55 MIN 28-04			
--DELETE LUNA.CONF_INDICADORES WHERE COD_INDICADOR= 26 
--INDICADOR IND_INCREMENTO_ARPU DESACTIVADO
--1 IND_INFOCORP >>>>>>>>>> 2017-04-28 >> 3873767 REGISTROS
--2 IND_DEBITO >>>>>>>>>>>> 2017-04-28 >> 117441 REGISTROS
--3 IND_DIGITALIZADO >>>>>> 2016-07-11 >> 835915 REGISTROS
--4 IND_HFC >>>>>>>>>>>>>>> 2017-04-01 >> 163715 REGISTROS
--5 IND_APC >>>>>>>>>>>>>>> 2017-04-28 >> 9770028 REGISTROS
--6 IND_FINANCIAMIENTO >>>> 2017-04-28 >> 26478 REGISTROS
--7 IND_RANGO_MONTO >>>>>>> 2017-04-28 >> 11023103 REGISTROS
--8 IND_INTOCABLE >>>>>>>>> 2017-04-28 >> 1550958 REGISTROS
--9 IND_RECLAMO >>>>>>>>>>> 2017-04-28 >> 1661045 REGISTROS
--10 IND_AVERIA >>>>>>>>>>> 2017-04-28 >> 1905300 REGISTROS
--11 IND_FACTURA_DIGITAL >> 2017-04-28 >> 802652 REGISTROS
--12 IND_LIDERES_OPINION >> 2016-11-29 >> 1819 REGISTROS
--13 IND_PORTABILIDAD >>>>> 2017-04-28 >> 1027205 REGISTROS
--14 IND_PLAYAS >>>>>>>>>>> 2017-02-23 >> 8258 REGISTROS
--Warning: Null value is eliminated by an aggregate or other SET operation.
--15 IND_RURAL >>>>>>>>>>>> 2017-04-28 >> 25607 REGISTROS
--16 IND_VENTA_FINANCIADA > 2017-04-28 >> 181309 REGISTROS
--18 IND_EXCLUSION >>>>>>>> 2017-02-25 >> 180164 REGISTROS
--19 IND_CARIBU >>>>>>>>>>> 2017-04-28 >> 1953728 REGISTROS
--20 IND_TUP_SERTEL >>>>>>> 2017-04-28 >> 582636 REGISTROS
--21 IND_XDSL >>>>>>>>>>>>> 2017-04-28 >> 265928 REGISTROS
--22 COD_PILOTO >>>>>>>>>>> 2017-04-12 >> 5173533 REGISTROS
--23 IND_DESCUENTO >>>>>>>> 2017-04-28 >> 10994883 REGISTROS
--24 TIPO_CLIENTE >>>>>>>>> 2017-04-28 >> 16575402 REGISTROS
--25 RECUPERO_EQUIPOS >>>>> 2017-04-28 >> 181309 REGISTROS
--27 IND_FRAUDE >>>>>>>>>>> 2017-04-28 >> 59212 REGISTROS
--28 IND_ALTA_COMPONENTES > 2017-04-01 >> 662302 REGISTROS
--29 IND_ZONA_CRITICA >>>>> 2017-04-28 >> 723877 REGISTROS
--30 IND_ZONA_EMERGENCIA >> 2017-04-28 >> 2787206 REGISTROS
--31 IND_ZONA_CRITICA_2 >>> 2017-04-28 >> 57063 REGISTROS
--32 IND_AJUSTE50_VENC_EN > 2017-04-17 >> 34961 REGISTROS
--33 IND_BONO_VIDEO >>>>>>> 2017-04-17 >> 4626810 REGISTROS

go

/****************************************************************************************************************************************/
PRINT 'HORA FIN: ' + cast(cast(getdate() as dateTIME) as varchar(20))
PRINT '\**********  FIN DE SCRIPT 09_PASOS_UPDATE_MODELO_LUNA_02  **********/'
/****************************************************************************************************************************************/