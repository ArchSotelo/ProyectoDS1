
CREATE DATABASE BD_HELPDESKMC;
GO

USE BD_HELPDESKMC;
GO

-- ======================================================
-- TABLAS MAESTRAS
-- ======================================================

-- Estados (Abierto, En proceso, Cerrado, etc.)
CREATE TABLE tb_Estados (
    IdEstado INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(50) NOT NULL
);
GO

-- Prioridades (Alta, Media, Baja)
CREATE TABLE tb_Prioridades (
    IdPrioridad INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(50) NOT NULL
);
GO

-- Categorías (Software, Hardware, Red...)
CREATE TABLE tb_Categorias (
    IdCategoria INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL
    --
);
GO

CREATE TABLE tb_Rol (
    IdRol INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL
)
GO


-- SLA por prioridad
CREATE TABLE tb_SlaPrioridad (
    IdPrioridad INT PRIMARY KEY,
    HorasLimite INT NOT NULL,
    FOREIGN KEY (IdPrioridad) REFERENCES tb_Prioridades(IdPrioridad)
);
GO

-- ======================================================
-- USUARIOS
-- ======================================================
CREATE TABLE tb_Usuarios (
    IdUsuario INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150) UNIQUE NOT NULL,
    ContrasenaHash NVARCHAR(255) NOT NULL,
    IdRol INT NOT NULL,    
    Activo BIT NOT NULL DEFAULT 1

    FOREIGN KEY (IdRol) REFERENCES tb_Rol(IdRol)
);
GO

-- ======================================================
-- TICKETS
-- ======================================================
CREATE TABLE tb_Tickets (
    IdTicket INT IDENTITY(1,1) PRIMARY KEY,
    Titulo NVARCHAR(150) NOT NULL,
    Descripcion NVARCHAR(MAX) NOT NULL,
    FechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    FechaCierre DATETIME NULL,

    IdUsuarioCreador INT NOT NULL,
    IdUsuarioAsignado INT NULL,
    IdEstado INT NOT NULL,
    IdPrioridad INT NOT NULL,
    IdCategoria INT NOT NULL,

    FOREIGN KEY (IdUsuarioCreador) REFERENCES tb_Usuarios(IdUsuario),
    FOREIGN KEY (IdUsuarioAsignado) REFERENCES tb_Usuarios(IdUsuario),
    FOREIGN KEY (IdEstado) REFERENCES tb_Estados(IdEstado),
    FOREIGN KEY (IdPrioridad) REFERENCES tb_Prioridades(IdPrioridad),
    FOREIGN KEY (IdCategoria) REFERENCES tb_Categorias(IdCategoria)
);
GO

-- ======================================================
-- COMENTARIOS EN TICKETS
-- ======================================================
CREATE TABLE tb_Comentarios (
    IdComentario INT IDENTITY(1,1) PRIMARY KEY,
    IdTicket INT NOT NULL,
    IdUsuario INT NOT NULL,
    FechaComentario DATETIME NOT NULL DEFAULT GETDATE(),
    Texto NVARCHAR(MAX) NOT NULL,
    FOREIGN KEY (IdTicket) REFERENCES tb_Tickets(IdTicket),
    FOREIGN KEY (IdUsuario) REFERENCES tb_Usuarios(IdUsuario)
);
GO

-- ======================================================
-- ARCHIVOS ADJUNTOS
-- ======================================================
CREATE TABLE tb_ArchivosAdjuntos (
    IdAdjunto INT IDENTITY(1,1) PRIMARY KEY,
    IdTicket INT NOT NULL,
    NombreArchivo NVARCHAR(150) NOT NULL,
    RutaArchivo NVARCHAR(255) NOT NULL,
    FechaSubida DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (IdTicket) REFERENCES tb_Tickets(IdTicket)
);
GO

-- ======================================================
-- HISTORIAL DE TICKETS (AUDITORIA)
-- ======================================================
CREATE TABLE tb_HistorialTickets (
    IdHistorial INT IDENTITY(1,1) PRIMARY KEY,
    IdTicket INT NOT NULL,
    IdUsuario INT NOT NULL,
    FechaCambio DATETIME NOT NULL DEFAULT GETDATE(),
    DescripcionCambio NVARCHAR(255) NOT NULL,
    FOREIGN KEY (IdTicket) REFERENCES tb_Tickets(IdTicket),
    FOREIGN KEY (IdUsuario) REFERENCES tb_Usuarios(IdUsuario)
);
GO

--tabla  

-- ======================================================
-- SEMILLA DE DATOS (SEED)
-- ======================================================

-- Estados iniciales
INSERT INTO tb_Estados (Nombre) VALUES ('Abierto'), ('En proceso'), ('Cerrado');

-- Prioridades iniciales
INSERT INTO tb_Prioridades (Nombre) VALUES ('Alta'), ('Media'), ('Baja');

-- Categorías iniciales
INSERT INTO tb_Categorias (Nombre) VALUES
('Software'), ('Hardware'), ('Redes'), ('Infraestructura'), ('Base de Datos');

--Rol iniciales
INSERT INTO tb_Rol (Nombre) VALUES 
('Administrador'),  ('Tecnico'), ('Usuario') 

SELECT * FROM Rol

-- SLA por prioridad
INSERT INTO tb_SlaPrioridad (IdPrioridad, HorasLimite) VALUES
(1, 8),   -- Alta (8 horas)
(2, 24),  -- Media (24 horas)
(3, 48);  -- Baja (48 horas)

-- Usuario Admin por defecto
INSERT INTO tb_Usuarios (Nombre, Email, ContrasenaHash, IdRol)
VALUES ('Administrador', 'admin@helpdesk.local', 'HASH_TEMPORAL', 1);
GO

SELECT * FROM tb_Usuarios


--Listar Usuarios
CREATE OR ALTER PROC usp_ListarUsuario
AS
BEGIN
    SELECT u.IdUsuario, u.Nombre, u.Email, u.ContrasenaHash ,r.Nombre, u.Activo
    FROM tb_Usuarios u INNER JOIN tb_Rol r  ON u.IdRol = r.IdRol
    ORDER BY u.IdUsuario DESC
END
GO

EXEC usp_ListarUsuario

--Listar Rol
CREATE OR ALTER PROC usp_ListarRol
AS
BEGIN 
    SELECT *
    FROM tb_Rol
END
GO

EXEC usp_ListarRol

--Inserta Nuevo Usuario
CREATE OR ALTER PROC  usp_InsertarUsuario
    @Nombre NVARCHAR(100),
    @Email NVARCHAR(150),
    @Contrasena NVARCHAR(255),
    @Rol INT,
    @Activo BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tb_Usuarios(Nombre, Email, ContrasenaHash,IdRol, Activo)
    VALUES(@Nombre, @Email, @Contrasena, @Rol, @Activo);

    SELECT SCOPE_IDENTITY() AS NuevoIdUsuario;
END
GO

EXEC usp_InsertarUsuario 
    @Nombre = 'Juan Pérez',
    @Email = 'juan.perez@email.com',
    @Contrasena= 'hashSeguro123',
    @Rol = 2;
    
--Editar Usuario
CREATE OR ALTER PROC usp_EditarUsuario
    @IdUsuario INT,
    @Nombre NVARCHAR(100),
    @Email NVARCHAR(150),
    @Contrasena NVARCHAR(255),
    @Rol INT,
    @Activo BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE tb_Usuarios
    SET Nombre = @Nombre,
        Email = @Email,
        ContrasenaHash = @Contrasena,
        IdRol = @Rol,
        Activo = @Activo
    WHERE IdUsuario = @IdUsuario;
END
GO

--Eliminar Usuario
CREATE OR ALTER PROC usp_EliminarUsuario
    @IdUsuario INT
AS
BEGIN
    DELETE FROM tb_Usuarios
    WHERE IdUsuario = @IdUsuario;
END
GO
