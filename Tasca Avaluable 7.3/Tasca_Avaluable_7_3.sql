-- 1  Carrega la informació de l’arxiu Employees.xmlal mysql workbench.
-- Explica tot el procés amb captures de pantalla i copia el codi

-- Cream la base de dades
CREATE DATABASE IF NOT EXISTS Employees;
USE Employees;

-- Cream la taula on es guardarán les dades

CREATE TABLE employees (

	-- Assignam un id a la taula
	id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Posam una columna per a les dades del xml amb format LONGTEXT
    dades LONGTEXT
);

-- Hem de moure el fitxer a aquesta carpeta per poder importar-lo
SHOW VARIABLES LIKE 'secure_file_priv';

-- Insertam el xml a la columna dades
INSERT INTO employees(dades)
VALUES (LOAD_FILE('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Employees.xml'));

SELECT * FROM employees;

-- 1.1 Com podem obtenir el nom de tots els empleats que treballen a la sucursal "Headquarters"?
SELECT ExtractValue(dades,
'//employee[assigned_branch/assigned_branch_name="Headquarters"]/first_name')
FROM employees;

-- 1.2 Quants empleats hi ha a l'àrea d'Operacions ("Operations")
SELECT ExtractValue(dades,
'count(//employee[department/department_name="Operations"])')
FROM employees;

-- 1.3 Quins són els noms dels empleats que tenen com a superior a l'empleat amb emp_id="4"?
SELECT ExtractValue(dades,
'//employee[superior_emp_id="4"]/first_name')
FROM employees;

-- 1.4 Quina és la data d'inici de l'empleat amb emp_id="7"?
SELECT ExtractValue(dades,
'//employee[@emp_id="7"]/start_date')
FROM employees;

-- 1.5 Obtenir les ciutats on es troben les sucursals a les quals estan assignats els empleats amb el títol de "Head Teller".
SELECT ExtractValue(dades,
'//employee[title="Head Teller"]/assigned_branch/assigned_branch_city')
FROM employees;