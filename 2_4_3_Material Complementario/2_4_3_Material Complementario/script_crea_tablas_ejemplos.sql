﻿DROP TABLE EMPLEADOS;
DROP TABLE TRAMO_DESCTO_SINDICATO;
DROP TABLE TRAMO_ASIG_JEFE;
DROP TABLE HABER_CALC_SALARIO;
DROP TABLE RESULTADO_PROCESO;
DROP TABLE ERROR_PROCESO;
DROP TABLE TRAMO_BONIF_ANNOS_TRAB;
DROP SEQUENCE SEQ_ERROR_PROC;

CREATE SEQUENCE SEQ_ERROR_PROC;

CREATE TABLE EMPLEADOS
AS SELECT * FROM employees;

CREATE TABLE TRAMO_BONIF_ANNOS_TRAB
(rango_ini NUMBER(2) NOT NULL,
 rango_fin NUMBER(2) NOT NULL,
 porc_bonif NUMBER(2) NOT NULL,
 CONSTRAINT PK_TBONIF_ANNOS_TRAB PRIMARY KEY(rango_ini,rango_fin));

CREATE TABLE TRAMO_ASIG_JEFE
(tramo_inf_aj NUMBER(2) NOT NULL,
 tramo_sup_aj NUMBER(2) NOT NULL,
 porc_asig_jefe NUMBER(2) NOT NULL,
 CONSTRAINT PK_TRAMO_ASIG_JEFE PRIMARY KEY(tramo_inf_aj,tramo_sup_aj));

 CREATE TABLE tramo_descto_sindicato
(nro_tramo_ds  NUMBER(2) NOT NULL,
 tramo_inf_ds NUMBER(8) NOT NULL,
 tramo_sup_ds NUMBER(8) NOT NULL,
 porc_ds NUMBER(4,3) NOT NULL);

 CREATE TABLE HABER_CALC_SALARIO
 (id_empleado NUMBER(3) NOT NULL,
  anno_mes_proc NUMBER(6) NOT NULL,
  valor_sldo_base NUMBER(8) NOT NULL,
  valor_comision NUMBER(5) NOT NULL,
  valor_comision_jefe NUMBER(5) NOT NULL,
  valor_colacion NUMBER(5) NOT NULL,
  valor_movil NUMBER(8) NOT NULL,
  valor_descto_sindicato NUMBER(8) NOT NULL,
  valor_alc_liquido NUMBER(8) NOT NULL,
  CONSTRAINT PK_HABER_CAL_SALARIO PRIMARY KEY(id_empleado,anno_mes_proc));

CREATE TABLE RESULTADO_PROCESO
(sec_resul NUMBER(3) NOT NULL,
 proceso_resul VARCHAR2(100) NOT NULL,
 mensaje_resul VARCHAR2(250) NOT NULL);

CREATE TABLE ERROR_PROCESO
(sec_error NUMBER(3) NOT NULL,
 rutina_error VARCHAR2(100) NOT NULL,
 mensaje_error VARCHAR2(250) NOT NULL);
 
INSERT INTO TRAMO_ASIG_JEFE VALUES(5,7,5);
INSERT INTO TRAMO_ASIG_JEFE VALUES(8,10,7);
INSERT INTO TRAMO_ASIG_JEFE VALUES(11,15,9);
INSERT INTO TRAMO_ASIG_JEFE VALUES(16,20,10);

INSERT INTO TRAMO_BONIF_ANNOS_TRAB VALUES(15,17,5);
INSERT INTO TRAMO_BONIF_ANNOS_TRAB VALUES(18,21,12);
INSERT INTO TRAMO_BONIF_ANNOS_TRAB VALUES(22,25,15);
INSERT INTO TRAMO_BONIF_ANNOS_TRAB VALUES(26,30,18);

INSERT INTO tramo_descto_sindicato VALUES(1,1000,3000,0.02);
INSERT INTO tramo_descto_sindicato VALUES(2,3001,6000,0.025);
INSERT INTO tramo_descto_sindicato VALUES(3,8000,10000,0.035);
INSERT INTO tramo_descto_sindicato VALUES(4,10001,30000,0.045);
COMMIT;