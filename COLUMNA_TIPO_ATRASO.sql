    SELECT  top 100
                         AM.ID
                       ,DC.DOC_FISCAL_ID AS DOC_FISCAL_ID
                        ,MN.TIPO_MON_ID AS TIPO_MON_ID
                       ,ISNULL(ST.SISTEMA_ID,3) AS SISTEMA_ID
                        ,AM.tipo_serv_id AS TPO_SERV_ID
                        ,CT.CUENTA_ID AS CUENTA_ID
                        ,AM.codigo_cliente COD_CLIENTE
                        ,AM.Cuenta_id AS COD_CUENTA
                        ,AM.NRO_Documento AS NRO_DOCUMENTO
                        ,AM.NRO_DOC_CLIENTE AS NRO_DOC_CLIENTE
                        ,AM.Fecha_Emision AS FECHA_EMISION
                        ,AM.Fecha_Vencim AS FECHA_VENCIM
                        ,AM.fecha_deuda AS FECHA_DEUDA
                        ,AM.cod_Inscripcion AS INSCRIPCION
                        ,AM.nro_doc_cuota AS GRUPO_CARGO
                        ,AM.MONTO_Factura AS MONTO_FACTURA
                        ,AM.MONTO_Ajuste AS MONTO_AJUSTE
                        ,AM.MONTO_Pagado AS MONTO_PAGADO
                        ,AM.MONTO_RECLAMO AS MONTO_RECLAMO
                        ,AM.MONTO_EXIGIBLE AS MONTO_EXIGIBLE
                        ,CASE WHEN MONTO_EXIGIBLE >= 0.01 AND  MONTO_EXIGIBLE <= 5 THEN 1 ELSE 0 END AS RANGO_SALDO
                        ,CASE WHEN MONTO_EXIGIBLE > 0  THEN 0  ELSE 1 END AS ESTADO_MTO_EXIG
                        ,CASE WHEN CT.CUENTA_ID IS NULL THEN 1 ELSE 0 END AS ESTADO_MIGRA
                        ,'1' AS ESTADO
                        ,'jmpaucar' AS USUARIO_CREACION
                        ,AM.dFechaCargaArchivo AS FECHA_CREACION
                        ,null as USUARIO_MODIFICA
                        ,null as FECHA_MODIFICA
						,CASE
						WHEN DATEDIFF(DAY,AM.Fecha_Vencim,GETDATE()) >= DP.VALORENTERO  THEN 'ANTIGUOS'
						WHEN DATEDIFF(DAY,AM.Fecha_Vencim,GETDATE()) <= DP.VALORENTERO THEN 'NUEVOS'
						END AS TIPO_ATRASO
						  FROM dbo.DIN_00_CARGA_DEUDA_AMDOCS  AM
                            LEFT JOIN DIN_CLIENT_SISTEMA ST ON  ST.CODIGO_CLIENTE  = AM.CODIGO_CLIENTE AND ST.SISTEMA_ID = 3
                            LEFT JOIN DIN_CUENTA CT  ON CT.NUM_CUENTA = AM.cuenta_id AND CT.CLIE_SIST_ID = ST.CLIE_SIST_ID
                            LEFT JOIN DIN_CLIENTE CL ON CL.CLIENTE_ID = ST.CLIENTE_ID --AND CL.SISTEMA_FLG = 3
                            --INNER JOIN DIN_MAE_SISTEMA STS ON STS.SISTEMA_ID = AM.sistema_id
                            INNER JOIN DIN_MAE_DOC_FISCAL DC ON DC.DOC_FISCAL_ID = AM.doc_fiscal_id
                            INNER JOIN DIN_MAE_MONEDA MN ON MN.TIPO_MON_ID =  AM.tipo_mon_id
							INNER JOIN DIN_MAE_PARAMETROS DP ON AM.ID=DP.MAE_PARAMETROS_ID
                                WHERE AM.sistema_id = 3 AND
								DP.MAE_PARAMETROS_ID=1 


								