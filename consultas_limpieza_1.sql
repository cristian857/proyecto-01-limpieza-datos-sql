-- =================================================================================================================
--                                       PROYECTO 1 - LIMPIEZA DE DATOS            
-- =================================================================================================================

-- ----------------------------------------------------------------------------------------------------------------- 
/* El proyecto trata sobre la limpieza y preparación de datos, detro de las operaciones que se realizan están: 
crear la base de datos "clean", importar los datos  desde el archivo limpieza.CSV con lo cual se crea la tabla 
que contiene la información, renombrar algunas columnas, eliminar duplicados, remover espacios extras, 
actualizar valores en los registros y columnas, cambiar el tipo de dato de algunas columnas, modificar formatos, 
agregar nuevas columnas, cálculos con fechas, exportar datos. Se implementaron cláusulas como:
CREATE, SELECT, UPDATE, RENAME, CASE, REPLACE, ALTER, WHERE, GROUP BY, HAVING y 
funciones como: COUNT, LENGTH, TRIM, CAST, DATE_FORMAT, STR_TO_DATE, CONCAT, SUBSTRING, TIMESTAMPDIFF
*/
-- ------------------------------------------------------------------------------------------------------------------

-- -------------------- Crear base de datos clean e importar archivo de datos limpieza.CSV --------------------------
CREATE DATABASE IF NOT EXISTS clean;

-- Seleccionar la base de datos a trabajar
USE clean;

-- Activar/Desactivar Modo Seguro - 0 desactivar - 1 activar
-- Permitir realizar modificaciones
SET sql_safe_updates = 0;

-- Explorar la tabla limpieza
SELECT * FROM limpieza LIMIT 10;

-- --------------------------------------------------- Renombrar Columnas -------------------------------------------

-- Renombrar columnas: Id_empleado, Gender, Last_name, Start_date
ALTER TABLE limpieza CHANGE COLUMN `ï»¿Id?empleado` Id_empleado VARCHAR(20);
ALTER TABLE limpieza CHANGE COLUMN `gÃ©nero` Gender VARCHAR(20); 
ALTER TABLE limpieza CHANGE COLUMN Apellido Last_name VARCHAR(50);
ALTER TABLE limpieza CHANGE COLUMN star_date Start_date VARCHAR(50);

-- Verficar cambios en los nombre de las columnas
DESCRIBE limpieza;

--  ------------------------------------------------ Eliminar duplicados ------------------------------------------- 

-- Mostrar si hay registros duplicados
SELECT id_empleado, COUNT(*) AS cantidad_duplicados
FROM limpieza
GROUP BY id_empleado
HAVING COUNT(*) > 1;

-- Contar la cantidad de registros duplicados 
SELECT COUNT(*) AS cantidad_duplicados
FROM (
	  SELECT id_empleado, COUNT(*) AS cantidad_duplicados
	  FROM limpieza
	  GROUP BY id_empleado
	  HAVING COUNT(*) > 1
    ) AS subquery;

-- Cambiar el nombre de la tabla 'limpieza' por 'conduplicados'
RENAME TABLE limpieza TO conduplicados; 

-- Crear tabla temporal (sin datos duplicados) llamada 'Temp_limpieza'
CREATE TEMPORARY TABLE Temp_limpieza AS
SELECT DISTINCT * FROM conduplicados;

-- Contar el número de registros de las tablas 'conduplicados' y 'Temp_limpieza'
SELECT COUNT(*) AS original FROM conduplicados;
SELECT COUNT(*) AS newtable FROM Temp_limpieza;

-- Convertir la tabla temporal a permanente 
CREATE TABLE limpieza AS SELECT * FROM Temp_limpieza;

-- Verificar nuevamente si aún hay duplicados en la tabla 'limpieza'
SELECT COUNT(*) AS cantidad_duplicados
FROM (
    SELECT Id_emp
    FROM limpieza
    GROUP BY Id_emp
    HAVING COUNT(*) > 1
) AS subquery;

 -- Eliminar tabla que contiene los duplicados 'conduplicados'
 DROP TABLE conduplicados;

-- --------------------------------------------- Remover espacios extras en columnas ---------------------------------

-- Identificar espacios extra en column name
SELECT name
FROM limpieza
WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0;

-- Prueba: remover espacios de columna name
SELECT name, TRIM(name) AS name
FROM limpieza
WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0;

-- Remover espacios de columna name
UPDATE limpieza SET name = TRIM(name)
WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0;

-- Identificar espacios extra en columna Last_Name
SELECT Last_name
FROM limpieza
WHERE LENGTH(Last_name) - LENGTH(TRIM(Last_name)) > 0;

-- Prueba: remover espacios extra en Last_Name
SELECT Last_name, TRIM(Last_name) AS name
FROM limpieza
WHERE LENGTH(Last_name) - LENGTH(TRIM(Last_name)) > 0;

-- Remover espacios extra de Last_Name
UPDATE limpieza SET Last_name = TRIM(Last_name)
WHERE LENGTH(Last_name) - LENGTH(TRIM(Last_name)) > 0;


-- Explorar si hay dos o más espacios entre dos palabras  en area

-- Adicionar a propósito espacios extra en columna area
UPDATE limpieza SET area = REPLACE(area, ' ', '       '); 

-- Explorar si hay dos o más espacios entre dos palabras  
SELECT area FROM limpieza
WHERE area REGEXP '\s{2,}';

-- Prueba: remover dos o más espacios entre dos palabras en area
SELECT area, TRIM(REGEXP_REPLACE(area, '\s{2,}', ' ')) AS ensayo
FROM limpieza;
 
--  Remover dos o más espacios entre dos palabras en area
UPDATE limpieza 
SET area = TRIM(REGEXP_REPLACE(area, '\s{2,}', ' '));


-- -------------------------------------- Actualizar columna gender con valores en Inglés ----------------------------

-- Prueba: actualizar columna gender con valores en Inglés
SELECT gender,
    CASE
        WHEN gender = 'hombre' THEN 'male'
        WHEN gender = 'mujer' THEN 'female'
        ELSE 'other'
    END AS gender1
FROM limpieza;
  
-- Actualizar columna gender con valores en Inglés
UPDATE limpieza 
SET gender = 
	CASE
        WHEN gender = 'hombre' THEN 'male'
        WHEN gender = 'mujer' THEN 'female'
        ELSE 'other'
	END; 

-- -------------------------- Modificar valores y propiedad - tipo de dato de columna type --------------------------

-- Modificar columna type de int a text
ALTER TABLE limpieza MODIFY COLUMN TYPE TEXT;

-- Prueba: actualizar valores columna type: 1 = Remoto, 0 = Hybrid
SELECT type,
    CASE
        WHEN type = 1 THEN 'Remote'
        WHEN type = 0 THEN 'Hybrid'
        ELSE 'other'
    END AS ejemplo
FROM limpieza;

-- Actualizar valores columna type: 1 = Remoto, 0 = Hybrid
UPDATE limpieza 
SET type = 
	CASE
        WHEN type = 1 THEN 'Remote'
        WHEN type = 0 THEN 'Hybrid'
        ELSE 'other'
    END; 

-- ----------------------------------------- Modificar columna salary de text a int ---------------------------------

-- Prueba: actualizar valores columna salary 
SELECT salary, CAST(TRIM(REPLACE(REPLACE(salary, '$', ''), ',', '')) AS DECIMAL (15 , 2 )) AS salary1
FROM limpieza;

-- Actualizar valores columna salary 
UPDATE limpieza SET salary = CAST(TRIM(REPLACE(REPLACE(salary, '$', ''), ',', '')) AS DECIMAL (15, 2 ));

-- Modificar propiedad columna salary de text a int
ALTER TABLE limpieza MODIFY COLUMN salary INT NULL;


-- --------------------------- Modificar columna birth_date, formato y tipo de dato -------------------------------

-- Explorar columna birth_date
DESCRIBE limpieza;

SELECT birth_date FROM limpieza;

-- Prueba: modificar columna birth_date, formato y tipo de dato
SELECT birth_date,
    CASE
        WHEN birth_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
        WHEN birth_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birth_date, '%m-%d-%Y'), '%Y-%m-%d')
        ELSE NULL
    END AS new_birth_date
FROM limpieza;

-- Actualizar columna birth_date, formato y tipo de dato
UPDATE limpieza SET birth_date = 
	CASE
        WHEN birth_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
        WHEN birth_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birth_date, '%m-%d-%Y'), '%Y-%m-%d')
        ELSE NULL
    END;

-- Modificar tipo de dato de birth_date a date
ALTER TABLE limpieza MODIFY COLUMN birth_date DATE;


-- ------------------------------- Modificar columna start_date, formato y tipo de dato ----------------------------

-- Explorar columna start_date
DESCRIBE limpieza;

SELECT start_date FROM limpieza;

-- Prueba: modificar columna start_date, formato y tipo de dato
SELECT start_date,
    CASE
        WHEN start_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(start_date, '%m/%d/%Y'), '%Y-%m-%d')
        WHEN start_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(start_date, '%m-%d-%Y'), '%Y-%m-%d')
        ELSE NULL
    END AS new_start_date
FROM limpieza;

-- Actualizar columna start_date, formato y tipo de dato
UPDATE limpieza SET start_date = 
	CASE
        WHEN start_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(start_date, '%m/%d/%Y'), '%Y-%m-%d')
        WHEN start_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(start_date, '%m-%d-%Y'), '%Y-%m-%d')
        ELSE NULL
    END;

-- Modificar tipo de dato columna start_date a date
ALTER TABLE limpieza MODIFY COLUMN start_date DATE;


-- ---------------------------------- Modificar Columna finish_date ----------------------------------------------

-- Explorar columna finish date
SELECT finish_date FROM limpieza;

-- Pruebas: hacer consultas de como quedarían los datos ensayando diversos cambios.

-- convertir el valor en objeto de fecha (timestamp)
SELECT finish_date, STR_TO_DATE(finish_date, '%Y-%m-%d %H:%i:%s') AS fecha
FROM limpieza;  

-- convertir objeto en formato de fecha, luego dar formato deseado '%Y-%m-%d %H:'
SELECT finish_date, DATE_FORMAT(STR_TO_DATE(finish_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d') AS fecha
FROM limpieza; 

-- separar solo la hora(marca de tiempo)
SELECT finish_date, DATE_FORMAT(finish_date, '%H:%i:%s') AS hour_stamp
FROM limpieza;

-- Dividir los elementos de la hora
SELECT finish_date,
    DATE_FORMAT(finish_date, '%H') AS hora,
    DATE_FORMAT(finish_date, '%i') AS minutos,
    DATE_FORMAT(finish_date, '%s') AS segundos,
    DATE_FORMAT(finish_date, '%H:%i:%s') AS hour_stamp
FROM limpieza;

-- Agregar columna de respaldo date_backup
ALTER TABLE limpieza ADD COLUMN date_backup TEXT; 

-- Copiar los datos de finish_date a la columna de respaldo date_backup
UPDATE limpieza SET date_backup = finish_date; 

-- Prueba: Actualizar columna finish_date a formato timestamp
SELECT finish_date, STR_TO_DATE(finish_date, '%Y-%m-%d %H:%i:%s') AS formato
FROM limpieza; 
 
-- Actualizar columna finish_date a formato timestamp
UPDATE limpieza SET finish_date = STR_TO_DATE(finish_date, '%Y-%m-%d %H:%i:%s UTC') 
WHERE finish_date <> '';

-- Dividir la columna finish_date en fecha y hora

 -- Crear las columnas que albergarán los nuevos datos, columa fecha y columna hora
ALTER TABLE limpieza
	ADD COLUMN fecha DATE,
	ADD COLUMN hora TIME;

-- Actualizar los valores de las columnas fecha y hora
UPDATE limpieza
SET fecha = DATE(finish_date),
    hora = TIME(finish_date)
WHERE finish_date IS NOT NULL AND finish_date <> '';

 -- Actualizar valores en blanco a nulos en la columna finish_date
UPDATE limpieza SET finish_date = NULL 
WHERE finish_date = '';

-- Actualizar la propiedad - tipo de dato de la columna finish_date a datetime
ALTER TABLE limpieza MODIFY COLUMN finish_date DATETIME;

-- Verificar los resultados
DESCRIBE limpieza;

-- --------------------------------- Cálculos con fechas ---------------------------------------------------------

-- Agregar columna para albergar la edad
ALTER TABLE limpieza ADD COLUMN age INT;

-- Calcular la edad a la que ingresó a la empresa
SELECT name, birth_date, start_date, TIMESTAMPDIFF(YEAR, birth_date, start_date) AS edad_de_ingreso
FROM limpieza; 

-- Actualizar valores de columna age - calcular la edad
UPDATE limpieza SET age = TIMESTAMPDIFF(YEAR, birth_date, CURDATE());


-- ------------------------------- Crear columna con email del empleado ------------------------------------------

-- Prueba: agregar columna con el email del empleado 
SELECT CONCAT(SUBSTRING_INDEX(name, ' ', 1), '_', SUBSTRING(Last_name, 1, 2), '.', SUBSTRING(type, 1, 1), '@consulting.com') AS email
FROM limpieza;

-- Agregar columna 'email' para que contenga el correo electrónico
ALTER TABLE limpieza ADD COLUMN email VARCHAR(100);

-- Actualizar valores de la columna 'email' con los datos del correo electrónico
UPDATE limpieza 
SET email = CONCAT(SUBSTRING_INDEX(Name, ' ', 1),'_', SUBSTRING(Last_name, 1, 2), '.', SUBSTRING(Type, 1, 1), '@consulting.com');

-- ----------------------------------- Calcular cantidad de empleados por área ------------------------------------
SELECT area, COUNT(*) AS cantidad_empleados FROM limpieza
GROUP BY area
ORDER BY cantidad_empleados DESC;

-- -------------------------------------- Crear y exportar el set de datos definitivo -----------------------------
SELECT id_empleado, name, last_name, age, gender, area, salary, email, finish_date FROM limpieza
WHERE finish_date <= CURDATE() OR finish_date IS NULL
ORDER BY area, last_name;

