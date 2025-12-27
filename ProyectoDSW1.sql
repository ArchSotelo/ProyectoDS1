
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
    CodigoUsuario CHAR(5) NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    Apellido NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150) UNIQUE NOT NULL,
    Telefono CHAR(9) NOT NULL,
    ContrasenaHash NVARCHAR(255) NOT NULL,
    IdRol INT NOT NULL,    
    FechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    Activo BIT NOT NULL DEFAULT 1,
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

--SELECT * FROM Rol

-- SLA por prioridad
INSERT INTO tb_SlaPrioridad (IdPrioridad, HorasLimite) VALUES
(1, 8),   -- Alta (8 horas)
(2, 24),  -- Media (24 horas)
(3, 48);  -- Baja (48 horas)


SELECT * FROM tb_Usuarios


--Listar Usuarios
CREATE OR ALTER PROC usp_ListarUsuario
AS
BEGIN
    SELECT u.IdUsuario, 
           u.CodigoUsuario, 
           u.Nombre, 
           u.Apellido,
           u.Email, 
           u.Telefono, 
           u.ContrasenaHash,
           r.IdRol,
           r.Nombre, 
           u.Activo
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
    @Codigo CHAR(5),
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Email NVARCHAR(150),
    @Telefono CHAR(9),
    @Contrasena NVARCHAR(255),
    @Rol INT,
    @Activo BIT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tb_Usuarios(CodigoUsuario, Nombre, Apellido, Email, Telefono, ContrasenaHash,IdRol, Activo)
    VALUES(@Codigo, @Nombre, @Apellido, @Email, @Telefono, @Contrasena, @Rol, @Activo);
    SELECT SCOPE_IDENTITY() AS NuevoIdUsuario;
END
GO

EXEC usp_InsertarUsuario 
    @Codigo = 'JP001',
    @Nombre = 'Juan',
    @Apellido = 'Perez',
    @Email = 'juan.perez@email.com',
    @Telefono = '987265447',
    @Contrasena= 'hashSeguro123',
    @Rol = 2;
    
--Editar Usuario
CREATE OR ALTER PROC usp_EditarUsuario
    @IdUsuario INT,
    @Codigo CHAR(5),
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Email NVARCHAR(150),
    @Telefono CHAR(9),
    @Contrasena NVARCHAR(255),
    @Rol INT,
    @Activo BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE tb_Usuarios
    SET CodigoUsuario = @Codigo,
        Nombre = @Nombre,
        Apellido = @Apellido,
        Email = @Email,
        Telefono = @Telefono,
        ContrasenaHash = @Contrasena,
        IdRol = @Rol,
        Activo = @Activo
    WHERE IdUsuario = @IdUsuario;
END
GO

EXEC usp_EditarUsuario 
    @IdUsuario = 8,
    @Nombre = 'Juan Pérez',
    @Email = 'juan.perez@email.com',
    @Contrasena= 'hashSeguro123',
    @Rol = 2,
    @Activo = 0;

--Eliminar Usuario
CREATE OR ALTER PROC usp_EliminarUsuario
    @IdUsuario INT
AS
BEGIN
    DELETE FROM tb_Usuarios
    WHERE IdUsuario = @IdUsuario;
END
GO


INSERT INTO tb_Usuarios
(CodigoUsuario, Nombre, Apellido, Email, Telefono, ContrasenaHash, IdRol)
VALUES
('U0001','Juan','Perez','juan.perez1@mail.com','900000001','HASH123',1),
('U0002','Maria','Gomez','maria.gomez2@mail.com','900000002','HASH123',2),
('U0003','Luis','Torres','luis.torres3@mail.com','900000003','HASH123',3),
('U0004','Ana','Ramos','ana.ramos4@mail.com','900000004','HASH123',1),
('U0005','Carlos','Diaz','carlos.diaz5@mail.com','900000005','HASH123',2),
('U0006','Lucia','Fernandez','lucia.fernandez6@mail.com','900000006','HASH123',3),
('U0007','Pedro','Castro','pedro.castro7@mail.com','900000007','HASH123',1),
('U0008','Rosa','Mendoza','rosa.mendoza8@mail.com','900000008','HASH123',2),
('U0009','Jorge','Vargas','jorge.vargas9@mail.com','900000009','HASH123',3),
('U0010','Elena','Soto','elena.soto10@mail.com','900000010','HASH123',1),

('U0011','Miguel','Navarro','miguel.navarro11@mail.com','900000011','HASH123',2),
('U0012','Patricia','Flores','patricia.flores12@mail.com','900000012','HASH123',3),
('U0013','Ricardo','Silva','ricardo.silva13@mail.com','900000013','HASH123',1),
('U0014','Carmen','Lopez','carmen.lopez14@mail.com','900000014','HASH123',2),
('U0015','Diego','Reyes','diego.reyes15@mail.com','900000015','HASH123',3),
('U0016','Sandra','Paredes','sandra.paredes16@mail.com','900000016','HASH123',1),
('U0017','Oscar','Ruiz','oscar.ruiz17@mail.com','900000017','HASH123',2),
('U0018','Veronica','Salas','veronica.salas18@mail.com','900000018','HASH123',3),
('U0019','Hugo','Morales','hugo.morales19@mail.com','900000019','HASH123',1),
('U0020','Paola','Rojas','paola.rojas20@mail.com','900000020','HASH123',2),

('U0021','Andres','Campos','andres.campos21@mail.com','900000021','HASH123',3),
('U0022','Natalia','Ibarra','natalia.ibarra22@mail.com','900000022','HASH123',1),
('U0023','Sebastian','Ortega','sebastian.ortega23@mail.com','900000023','HASH123',2),
('U0024','Daniela','Cruz','daniela.cruz24@mail.com','900000024','HASH123',3),
('U0025','Fernando','Mejia','fernando.mejia25@mail.com','900000025','HASH123',1),
('U0026','Adriana','Leon','adriana.leon26@mail.com','900000026','HASH123',2),
('U0027','Victor','Espinoza','victor.espinoza27@mail.com','900000027','HASH123',3),
('U0028','Monica','Guerrero','monica.guerrero28@mail.com','900000028','HASH123',1),
('U0029','Raul','Chavez','raul.chavez29@mail.com','900000029','HASH123',2),
('U0030','Claudia','Peña','claudia.pena30@mail.com','900000030','HASH123',3),

('U0031','Ivan','Acosta','ivan.acosta31@mail.com','900000031','HASH123',1),
('U0032','Lorena','Figueroa','lorena.figueroa32@mail.com','900000032','HASH123',2),
('U0033','Julio','Benitez','julio.benitez33@mail.com','900000033','HASH123',3),
('U0034','Mariana','Delgado','mariana.delgado34@mail.com','900000034','HASH123',1),
('U0035','Sergio','Molina','sergio.molina35@mail.com','900000035','HASH123',2),
('U0036','Valeria','Aguirre','valeria.aguirre36@mail.com','900000036','HASH123',3),
('U0037','Alberto','Rios','alberto.rios37@mail.com','900000037','HASH123',1),
('U0038','Silvia','Cornejo','silvia.cornejo38@mail.com','900000038','HASH123',2),
('U0039','Martin','Zapata','martin.zapata39@mail.com','900000039','HASH123',3),
('U0040','Karen','Bustamante','karen.bustamante40@mail.com','900000040','HASH123',1),

('U0041','Bruno','Velasquez','bruno.velasquez41@mail.com','900000041','HASH123',2),
('U0042','Rocio','Nuñez','rocio.nunez42@mail.com','900000042','HASH123',3),
('U0043','Alex','Quiroz','alex.quiroz43@mail.com','900000043','HASH123',1),
('U0044','Fiorella','Montoya','fiorella.montoya44@mail.com','900000044','HASH123',2),
('U0045','Gonzalo','Luna','gonzalo.luna45@mail.com','900000045','HASH123',3),
('U0046','Pamela','Arce','pamela.arce46@mail.com','900000046','HASH123',1),
('U0047','Esteban','Cabrera','esteban.cabrera47@mail.com','900000047','HASH123',2),
('U0048','Noelia','Sanchez','noelia.sanchez48@mail.com','900000048','HASH123',3),
('U0049','Cristian','Valdez','cristian.valdez49@mail.com','900000049','HASH123',1),
('U0050','Milagros','Huaman','milagros.huaman50@mail.com','900000050','HASH123',2);

-- ======================================================
-- SP TICKETS
-- ======================================================

--Listar ticket
CREATE OR ALTER PROC usp_ListarTickets
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        t.IdTicket,
        t.Titulo,
        t.FechaCreacion,

        u.Nombre + ' ' + u.Apellido AS UsuarioCreador,

        e.Nombre AS Estado,
        p.Nombre AS Prioridad,
        c.Nombre AS Categoria
    FROM tb_Tickets t
    INNER JOIN tb_Usuarios u ON t.IdUsuarioCreador = u.IdUsuario
    INNER JOIN tb_Estados e ON t.IdEstado = e.IdEstado
    INNER JOIN tb_Prioridades p ON t.IdPrioridad = p.IdPrioridad
    INNER JOIN tb_Categorias c ON t.IdCategoria = c.IdCategoria
    ORDER BY t.FechaCreacion DESC;
END
GO
EXEC usp_ListarTickets


--Buscar ticket
CREATE OR ALTER PROC usp_BuscarTicket
    @IdTicket INT
AS
BEGIN
    SELECT 
        t.IdTicket,
        t.Titulo,
        t.Descripcion,
        t.FechaCreacion,
        t.FechaCierre,
        u.Nombre + ' ' + u.Apellido AS UsuarioCreador,
        e.Nombre AS Estado,
        p.Nombre AS Prioridad,
        c.Nombre AS Categoria
    FROM tb_Tickets t
        INNER JOIN tb_Usuarios u ON t.IdUsuarioCreador = u.IdUsuario
        INNER JOIN tb_Estados e ON t.IdEstado = e.IdEstado
        INNER JOIN tb_Prioridades p ON t.IdPrioridad = p.IdPrioridad
        INNER JOIN tb_Categorias c ON t.IdCategoria = c.IdCategoria
    WHERE t.IdTicket = @IdTicket
END
GO
EXEC usp_BuscarTicket 3

--Crear ticket
CREATE OR ALTER PROC usp_CrearTicket
    @Titulo NVARCHAR(150),
    @Descripcion NVARCHAR(MAX),
    @IdPrioridad INT,
    @IdCategoria INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tb_Tickets
    (
        Titulo,
        Descripcion,
        IdUsuarioCreador,
        IdEstado,
        IdPrioridad,
        IdCategoria
    )
    VALUES
    (
        @Titulo,
        @Descripcion,
        1,      -- Admin por defecto
        1,      -- Estado: Abierto
        @IdPrioridad,
        @IdCategoria
    );

    SELECT SCOPE_IDENTITY() AS NuevoIdTicket;
END
GO

EXEC usp_CrearTicket
    @Titulo = 'Error al iniciar sesión',
    @Descripcion = 'El sistema no permite ingresar con credenciales válidas',
    @IdPrioridad = 1,
    @IdCategoria = 1;

SELECT * FROM tb_Tickets ORDER BY IdTicket DESC;


 

--listar prioridades
CREATE OR ALTER PROC usp_ListarPrioridades
AS
BEGIN
    SELECT IdPrioridad, Nombre
    FROM tb_Prioridades
END
GO

--listar categorias
CREATE OR ALTER PROC usp_ListarCategorias
AS
BEGIN
    SELECT IdCategoria, Nombre
    FROM tb_Categorias
END
GO

--listar estados
CREATE OR ALTER PROC usp_ListarEstados
AS
BEGIN
    SELECT IdEstado, Nombre
    FROM tb_Estados
END
GO

EXEC usp_ListarPrioridades
EXEC usp_ListarCategorias
EXEC usp_ListarEstados

--Actualizar ticket
CREATE OR ALTER PROC usp_ActualizarTicket
    @IdTicket INT,
    @Titulo NVARCHAR(150),
    @Descripcion NVARCHAR(MAX),
    @IdPrioridad INT,
    @IdCategoria INT,
    @IdEstado INT
AS
BEGIN
    UPDATE tb_Tickets
    SET
        Titulo = @Titulo,
        Descripcion = @Descripcion,
        IdPrioridad = @IdPrioridad,
        IdCategoria = @IdCategoria,
        IdEstado = @IdEstado
    WHERE IdTicket = @IdTicket;
END
GO

--Cambiar Estado
CREATE OR ALTER PROC usp_CambiarEstadoTicket
    @IdTicket INT,
    @NuevoEstado INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EstadoActual INT;

    BEGIN TRY

        BEGIN TRAN;

        -- Validar que el ticket existe
        IF NOT EXISTS (SELECT 1 FROM tb_Tickets WHERE IdTicket = @IdTicket)
        BEGIN
            RAISERROR('El ticket no existe', 16, 1);
            ROLLBACK TRAN;
            RETURN;
        END;

        -- Obtener estado actual
        SELECT @EstadoActual = IdEstado 
        FROM tb_Tickets 
        WHERE IdTicket = @IdTicket;

        -- Validar transición (no se puede retroceder)
        IF NOT(
                (@EstadoActual = 1 AND @NuevoEstado IN (2,3)) OR
                (@EstadoActual = 2 AND @NuevoEstado = 3)
              )
        BEGIN
            RAISERROR('Transición no permitida', 16, 1);
            ROLLBACK TRAN;
            RETURN;
        END;

        -- Actualizar ticket
        UPDATE tb_Tickets
        SET 
            IdEstado = @NuevoEstado,
            FechaCierre = CASE WHEN @NuevoEstado = 3 THEN GETDATE() ELSE FechaCierre END
        WHERE IdTicket = @IdTicket;

        -- Registrar historial
        INSERT INTO tb_HistorialTickets(IdTicket, IdUsuario, DescripcionCambio, FechaCambio)
        VALUES
        (
            @IdTicket,
            @IdUsuario,
            CONCAT(
                'Estado cambiado de ', 
                (SELECT Nombre FROM tb_Estados WHERE IdEstado = @EstadoActual),
                ' a ',
                (SELECT Nombre FROM tb_Estados WHERE IdEstado = @NuevoEstado)
            ),
            GETDATE()
        );

        COMMIT TRAN;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        DECLARE @MensajeError NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @Severidad INT = ERROR_SEVERITY();
        DECLARE @EstadoError INT = ERROR_STATE();

        RAISERROR(@MensajeError, @Severidad, @EstadoError);

    END CATCH
END
GO


EXEC usp_CambiarEstadoTicket
    @IdTicket = 9,
    @NuevoEstado = 2,
    @IdUsuario = 1;

SELECT * FROM tb_Tickets WHERE IdTicket = 6;
SELECT * FROM tb_HistorialTickets WHERE IdTicket = 3 ORDER BY FechaCambio DESC;

--LISTAR HISTORIAL DE TICKET
CREATE OR ALTER PROC usp_ListarHistorialTicket
    @IdTicket INT
AS
BEGIN
    SELECT 
        h.FechaCambio,
        u.Nombre AS Usuario,
        h.DescripcionCambio
    FROM tb_HistorialTickets h
    INNER JOIN tb_Usuarios u ON u.IdUsuario = h.IdUsuario
    WHERE h.IdTicket = @IdTicket
    ORDER BY h.FechaCambio DESC;
END
GO
EXEC usp_ListarHistorialTicket 6

--==========================================================================
CREATE OR ALTER PROC usp_VerificarUsuario
    @Email NVARCHAR(150),
    @ContrasenaHash NVARCHAR(255)
AS
BEGIN
    SELECT IdUsuario , Nombre, Apellido, IdRol
    FROM tb_Usuarios
    WHERE Email = @Email AND ContrasenaHash = @ContrasenaHash AND Activo = 1;
END
GO

EXEC usp_VerificarUsuario 'admin@helpdesk.local' , 'HASH_TEMPORAL'


SELECT * FROM tb_Usuarios


----------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE usp_DashboardTotales
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SUM(CASE WHEN e.Nombre = 'Abierto' THEN 1 ELSE 0 END) AS Abiertos,
        SUM(CASE WHEN e.Nombre = 'En proceso' THEN 1 ELSE 0 END) AS EnProceso,
        SUM(CASE WHEN e.Nombre = 'Cerrado' THEN 1 ELSE 0 END) AS Cerrados,
        COUNT(*) AS Total
    FROM tb_Tickets t
    INNER JOIN tb_Estados e ON t.IdEstado = e.IdEstado;
END
GO


EXEC usp_DashboardTotales



