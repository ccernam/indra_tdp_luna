go
create view v_datosconvergencia
as
SELECT        c.NRO_DOCUMENT, SER.CLUSTER, SER.NRO_TELEFONO, CASE WHEN SER.CLUSTER = 'Voz+Int' OR
                         SER.CLUSTER = 'Int' OR
                         SER.CLUSTER = 'Voz+Int+Tv' OR
                         SER.CLUSTER = 'Voz' THEN 'Fijo' WHEN LEN(SER.NRO_TELEFONO) = 9 AND SER.NRO_TELEFONO LIKE '9%' THEN 'Movil' END AS convergencia
FROM            dbo.DIN_CLIENTE AS c INNER JOIN
                         dbo.DIN_CLIENT_SISTEMA AS cs ON c.CLIENTE_ID = cs.CLIENTE_ID INNER JOIN
                         dbo.DIN_CUENTA AS cta ON cta.CLIE_SIST_ID = cs.CLIE_SIST_ID INNER JOIN
                         dbo.DIN_SERVICIO AS SER ON SER.CUENTA_ID = cta.CUENTA_ID
GROUP BY c.NRO_DOCUMENT, SER.CLUSTER, SER.NRO_TELEFONO

create proc [dbo].[sp_listarConvergencia]
as
SELECT a.NRO_DOCUMENT
	,stuff((
			SELECT  ', ' + CAST(count(convergencia)as varchar)+' '+convergencia
			FROM v_datosconvergencia pc
			where pc.NRO_DOCUMENT=a.NRO_DOCUMENT
			group by convergencia
			for xml path('')
			), 1, 1, '') Convergencia
FROM v_datoscoNvergencia a
GROUP BY a.NRO_DOCUMENT
ORDER BY a.NRO_DOCUMENT