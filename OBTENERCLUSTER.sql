CREATE TABLE #DatosCluster (CLUSTER_ varchar(40), EST_SERV_ID int)
---263266956

			insert into #DatosCluster
			SELECT TOP 100
          tm.CLUSTER_,SV.EST_SERV_ID
        FROM COBRANZA_PROD.dbo.data_planta_comercial_jul20 TM
            INNER JOIN COBRANZA_PROD.dbo.GC_MAESTRA_IN DIN ON DIN.Cliente = TM.CLIENTE AND TM.CUENTA = DIN.Cuenta
            INNER JOIN DIN_MAE_EST_SERV SV ON SV.DESCRIPCION = DIN.DES_Estado_PC 
            INNER JOIN DIN_CUENTA CT ON CT.COD_CUENTA = TM.CUENTA AND DIN.Cuenta = CT.COD_CUENTA
			AND CT.SISTEMA_ID=3
            --INNER JOIN DIN_CLIENT_SISTEMA CS ON CS.CLIE_SIST_ID = CT.CLIE_SIST_ID AND CS.SISTEMA_ID = 3

		