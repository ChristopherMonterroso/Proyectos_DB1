DECLARE @TableName VARCHAR(255);

DECLARE TableCursor CURSOR FOR
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE';

-- Crear triggers para cada tabla
OPEN TableCursor;

FETCH NEXT FROM TableCursor INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Trigger para INSERT
    EXEC('
    CREATE TRIGGER trg_' + @TableName + '_Insert 
    ON ' + @TableName + ' 
    AFTER INSERT 
    AS
    BEGIN
        INSERT INTO HistorialCambios (Descripción,  Tipo)
        VALUES (''Se ha insertado un registro en la tabla ' + @TableName + ''', ''INSERT'');
    END;
    ');

    -- Trigger para UPDATE
    EXEC('
    CREATE TRIGGER trg_' + @TableName + '_Update 
    ON ' + @TableName + ' 
    AFTER UPDATE 
    AS
    BEGIN
        INSERT INTO HistorialCambios (Descripción,  Tipo)
        VALUES (''Se ha actualizado un registro en la tabla ' + @TableName + ''',  ''UPDATE'');
    END;
    ');

    -- Trigger para DELETE
    EXEC('
    CREATE TRIGGER trg_' + @TableName + '_Delete 
    ON ' + @TableName + ' 
    AFTER DELETE 
    AS
    BEGIN
        INSERT INTO HistorialCambios (Descripción, Tipo)
        VALUES (''Se ha eliminado un registro en la tabla ' + @TableName + ''', ''DELETE'');
    END;
    ');

    FETCH NEXT FROM TableCursor INTO @TableName;
END;

CLOSE TableCursor;
DEALLOCATE TableCursor;

DROP TRIGGER trg_HistorialCambios_Insert;
DROP TRIGGER trg_HistorialCambios_Update;
DROP TRIGGER trg_HistorialCambios_Delete;

SELECT 
    OBJECT_NAME(object_id) AS TableName,  -- Devuelve el nombre de la tabla
    name AS TriggerName,                  -- Devuelve el nombre del trigger
    type_desc AS TriggerType              -- Devuelve el tipo de trigger
FROM 
    sys.triggers
ORDER BY 
    TableName;


DECLARE @TriggerName VARCHAR(255);

-- Crear un cursor para obtener todos los triggers de la base de datos
DECLARE TriggerCursor CURSOR FOR
SELECT TRIGGER_NAME 
FROM INFORMATION_SCHEMA.TRIGGERS;

-- Abrir el cursor y eliminar todos los triggers
OPEN TriggerCursor;

FETCH NEXT FROM TriggerCursor INTO @TriggerName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Eliminar el trigger
    EXEC('DROP TRIGGER ' + @TriggerName + ';');

    -- Obtener el siguiente trigger
    FETCH NEXT FROM TriggerCursor INTO @TriggerName;
END;

-- Cerrar y liberar el cursor
CLOSE TriggerCursor;
DEALLOCATE TriggerCursor;
