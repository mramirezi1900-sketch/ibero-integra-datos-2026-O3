
-- ============================================================
-- CUSTOMER 360 - CREACION DE TODAS LAS VISTAS
-- BASE DE DATOS: DB_Customer360_Lab
-- ============================================================

USE DB_Customer360_Lab;
GO

-- ============================================================
-- 1. ELIMINAR VISTAS ANTERIORES
-- ============================================================

IF OBJECT_ID('vw_Gold_Cliente_360', 'V') IS NOT NULL
    DROP VIEW vw_Gold_Cliente_360;
GO

IF OBJECT_ID('vw_Silver_Interacciones', 'V') IS NOT NULL
    DROP VIEW vw_Silver_Interacciones;
GO

IF OBJECT_ID('vw_Silver_Ventas', 'V') IS NOT NULL
    DROP VIEW vw_Silver_Ventas;
GO

IF OBJECT_ID('vw_Silver_Clientes', 'V') IS NOT NULL
    DROP VIEW vw_Silver_Clientes;
GO

-- ============================================================
-- 2. VISTA SILVER: CLIENTES
-- Limpieza y normalizacion de datos
-- ============================================================

CREATE VIEW vw_Silver_Clientes
AS
SELECT
    cliente_id,
    LTRIM(RTRIM(nombre)) AS nombre,
    LOWER(LTRIM(RTRIM(email))) AS email,
    ISNULL(ciudad, 'No especificada') AS ciudad
FROM Tabla_Clientes;
GO

-- ============================================================
-- 3. VISTA SILVER: VENTAS
-- Agregacion de informacion comercial
-- ============================================================

CREATE VIEW vw_Silver_Ventas
AS
SELECT
    cliente_id,
    COUNT(venta_id) AS total_compras,
    SUM(monto_venta) AS monto_total_ventas,
    AVG(monto_venta) AS promedio_compra,
    MAX(fecha_venta) AS fecha_ultima_compra
FROM Tabla_Ventas
GROUP BY cliente_id;
GO

-- ============================================================
-- 4. VISTA SILVER: INTERACCIONES
-- Integracion mediante correo electronico
-- ============================================================

CREATE VIEW vw_Silver_Interacciones
AS
SELECT
    c.cliente_id,
    c.nombre,
    c.email,
    COUNT(i.interaccion_id) AS total_interacciones,
    MAX(i.fecha_interaccion) AS ultima_interaccion,
    STRING_AGG(i.plataforma, ', ') AS plataformas_utilizadas
FROM Tabla_Interacciones i
INNER JOIN vw_Silver_Clientes c
    ON LOWER(LTRIM(RTRIM(i.email_usuario))) = c.email
GROUP BY
    c.cliente_id,
    c.nombre,
    c.email;
GO

-- ============================================================
-- 5. VISTA GOLD: CLIENTE 360
-- Integracion de clientes, ventas, tickets e interacciones
-- ============================================================

CREATE VIEW vw_Gold_Cliente_360
AS
SELECT
    c.cliente_id,
    c.nombre,
    c.email,
    c.ciudad,

    -- INFORMACION COMERCIAL
    ISNULL(v.total_compras, 0) AS total_compras,
    ISNULL(v.monto_total_ventas, 0) AS monto_total_ventas,
    ISNULL(v.promedio_compra, 0) AS promedio_compra,
    v.fecha_ultima_compra,

    -- INFORMACION DE SOPORTE
    ISNULL(t.total_tickets, 0) AS total_tickets,
    ISNULL(t.tickets_abiertos, 0) AS tickets_abiertos,
    ISNULL(t.tickets_en_proceso, 0) AS tickets_en_proceso,
    ISNULL(t.tickets_cerrados, 0) AS tickets_cerrados,

    -- INFORMACION DIGITAL
    ISNULL(i.total_interacciones, 0) AS total_interacciones,
    i.ultima_interaccion,
    ISNULL(i.plataformas_utilizadas, 'Sin interacciones')
        AS plataformas_utilizadas

FROM vw_Silver_Clientes c

LEFT JOIN vw_Silver_Ventas v
    ON c.cliente_id = v.cliente_id

LEFT JOIN (
    SELECT
        cliente_id,
        COUNT(ticket_id) AS total_tickets,
        SUM(CASE WHEN estado = 'Abierto'
            THEN 1 ELSE 0 END) AS tickets_abiertos,
        SUM(CASE WHEN estado = 'En Proceso'
            THEN 1 ELSE 0 END) AS tickets_en_proceso,
        SUM(CASE WHEN estado = 'Cerrado'
            THEN 1 ELSE 0 END) AS tickets_cerrados
    FROM Tabla_Tickets
    GROUP BY cliente_id
) t
    ON c.cliente_id = t.cliente_id

LEFT JOIN vw_Silver_Interacciones i
    ON c.cliente_id = i.cliente_id;
GO

-- ============================================================
-- 6. CONSULTAR TODAS LAS VISTAS
-- ============================================================

-- Vista Silver de clientes
SELECT * FROM vw_Silver_Clientes;
GO

-- Vista Silver de ventas
SELECT * FROM vw_Silver_Ventas;
GO

-- Vista Silver de interacciones
SELECT * FROM vw_Silver_Interacciones;
GO

-- Vista Gold de Customer 360
SELECT * FROM vw_Gold_Cliente_360;
GO

-- ============================================================
-- 7. CONSULTAS ANALITICAS ADICIONALES
-- ============================================================

-- Clientes con mayor monto de compras
SELECT
    nombre,
    email,
    monto_total_ventas
FROM vw_Gold_Cliente_360
ORDER BY monto_total_ventas DESC;
GO

-- Clientes con incidencias pendientes
SELECT
    nombre,
    total_tickets,
    tickets_abiertos,
    tickets_en_proceso
FROM vw_Gold_Cliente_360
WHERE tickets_abiertos > 0
   OR tickets_en_proceso > 0;
GO

-- Clientes que utilizan plataformas digitales
SELECT
    nombre,
    total_interacciones,
    plataformas_utilizadas,
    ultima_interaccion
FROM vw_Gold_Cliente_360
WHERE total_interacciones > 0;
GO

-- Resumen general de Customer 360
SELECT
    COUNT(*) AS total_clientes,
    SUM(total_compras) AS compras_totales,
    SUM(monto_total_ventas) AS ingresos_totales,
    SUM(total_tickets) AS tickets_totales,
    SUM(total_interacciones) AS interacciones_totales
FROM vw_Gold_Cliente_360;
GO
