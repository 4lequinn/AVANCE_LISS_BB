DROP TABLE empleados;
DROP TABLE datos_empleado;
DROP TABLE empleados_retirados;

CREATE TABLE empleados 
AS SELECT * FROM employees;

CREATE TABLE empleados_retirados 
AS SELECT * FROM employees;
TRUNCATE TABLE empleados_retirados;

CREATE TABLE datos_empleado 
(nombre  VARCHAR2(25),
 fecha   DATE);