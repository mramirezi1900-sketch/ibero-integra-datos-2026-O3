-- ============================================================================
-- SCRIPT DE SETUP: BASE DE DATOS Y FUENTES HETEROGÉNEAS
-- ============================================================================
IF DB_ID('DB_Customer360_Lab') IS NULL
    CREATE DATABASE DB_Customer360_Lab;
GO

USE DB_Customer360_Lab;
GO

-- Limpieza previa de objetos
IF OBJECT_ID('vw_Gold_Cliente_360', 'V') IS NOT NULL DROP VIEW vw_Gold_Cliente_360;
IF OBJECT_ID('Tabla_Interacciones', 'U') IS NOT NULL DROP TABLE Tabla_Interacciones;
IF OBJECT_ID('Tabla_Tickets', 'U') IS NOT NULL DROP TABLE Tabla_Tickets;
IF OBJECT_ID('Tabla_Ventas', 'U') IS NOT NULL DROP TABLE Tabla_Ventas;
IF OBJECT_ID('Tabla_Clientes', 'U') IS NOT NULL DROP TABLE Tabla_Clientes;
GO

-- 1. Tabla Maestra de Clientes
CREATE TABLE Tabla_Clientes (
    cliente_id INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    ciudad VARCHAR(50) NULL
);

-- 2. Tabla Transaccional de Ventas
CREATE TABLE Tabla_Ventas (
    venta_id INT PRIMARY KEY IDENTITY(100,1),
    cliente_id INT FOREIGN KEY REFERENCES Tabla_Clientes(cliente_id),
    monto_venta DECIMAL(10,2) NOT NULL,
    fecha_venta DATETIME NOT NULL
);

-- 3. Tabla de Soporte / Incidencias
CREATE TABLE Tabla_Tickets (
    ticket_id INT PRIMARY KEY IDENTITY(1000,1),
    cliente_id INT FOREIGN KEY REFERENCES Tabla_Clientes(cliente_id),
    tipo_incidencia VARCHAR(50) NOT NULL,
    estado VARCHAR(20) NOT NULL
);

-- 4. Tabla de Interacciones Web/App (Origen heterogéneo conectado por email)
CREATE TABLE Tabla_Interacciones (
    interaccion_id INT PRIMARY KEY IDENTITY(5000,1),
    email_usuario VARCHAR(100) NOT NULL,
    fecha_interaccion DATETIME NOT NULL,
    plataforma VARCHAR(30) NOT NULL
);
GO

-- INSERCIÓN DE DATOS DE PRUEBA
INSERT INTO Tabla_Clientes (nombre, email, ciudad) VALUES
(' Carlos Mendoza ', 'CARLOS.MENDOZA@EMAIL.COM', 'León'),
('Ana Sofía Torres', 'ana.torres@email.com', 'Guadalajara'),
('Roberto Gómez', 'roberto.gomez@email.com', NULL),
('María Fernández', 'maria.f@email.com', 'Querétaro');

INSERT INTO Tabla_Ventas (cliente_id, monto_venta, fecha_venta) VALUES
(1, 1200.50, '2026-08-10'),
(1, 450.00, '2026-08-25'),
(2, 3100.00, '2026-08-15');

INSERT INTO Tabla_Tickets (cliente_id, tipo_incidencia, estado) VALUES
(1, 'Falla en Pago', 'Cerrado'),
(1, 'Retraso de Envío', 'En Proceso'),
(3, 'Facturación', 'Abierto');

INSERT INTO Tabla_Interacciones (email_usuario, fecha_interaccion, plataforma) VALUES
('carlos.mendoza@email.com ', '2026-09-01 14:30:00', 'App Móvil'),
('ANA.TORRES@EMAIL.COM', '2026-09-02 09:15:00', 'Sitio Web');
GO