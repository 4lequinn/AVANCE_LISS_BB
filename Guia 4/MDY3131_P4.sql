
SET SERVEROUTPUT ON;


-- Caso 1 

-- Variables bind
VARIABLE b_anno_proceso number(7)
VARIABLE b_mov_mariapinto number(7);
VARIABLE b_mov_curacavi number(7);
VARIABLE b_mov_talagante number(7);
VARIABLE b_mov_elmonte number(7);
VARIABLE b_mov_buin number(7);

EXECUTE :b_anno_proceso:=2020;
EXECUTE :b_mov_mariapinto:=20000;
EXECUTE :b_mov_curacavi:=25000;
EXECUTE :b_mov_talagante:=30000;
EXECUTE :b_mov_elmonte:=35000;
EXECUTE :b_mov_buin:=40000;

DECLARE
--variables

    CURSOR c1 IS
    SELECT e.id_emp,e.numrun_emp,e.dvrun_emp,
        e.PNOMBRE_EMP||' '||e.snombre_emp||' '||e.appaterno_emp||' '||e.apmaterno_emp as "NOMBRE_EMPLEADO",
        c.nombre_comuna,e.sueldo_base,
        trunc(e.sueldo_base/100000) as "PORC_AUMENTO",
        ROUND((trunc(e.sueldo_base/100000)/100)*e.sueldo_base) AS "VALOR_MOVIL_NORMAL",
        CASE c.id_comuna
            WHEN 117 THEN 20000
            WHEN 118 THEN 25000
            WHEN 119 THEN 30000
            WHEN 120 THEN 35000
            WHEN 121 THEN 40000 
            ELSE
                0
            end  as "VALOR_MOVIL_EXTRA",
            ROUND((trunc(e.sueldo_base/100000)/100)*e.sueldo_base)+
            CASE c.id_comuna
            WHEN 117 THEN 20000
            WHEN 118 THEN 25000
            WHEN 119 THEN 30000
            WHEN 120 THEN 35000
            WHEN 121 THEN 40000 
            ELSE
                0
            end  as "VALOR_TOTAL_MOVIL"
    FROM empleado e
    INNER JOIN comuna c
    ON e.id_comuna = c.ID_COMUNA;

BEGIN
  EXECUTE IMMEDIATE 'TRUNCATE TABLE PROY_MOVILIZACION';  
  
  select min(id_emp),
         max(id_emp)
  into v_min_id_emp, v_max_id_emp 
  FROM empleado;

  while v_max_id_emp = v_min_id_emp 
  loop
    select e.id_emp, e.numrun_emp, e.dvrun_emp, 
    e.pnombre_emp||' '||e.snombre_emp||' '||e.appaterno_emp||' '||e.apmaterno_emp as v_nombre_empleado,
    e.id_comuna,
    c.nombre_comuna,
    e.sueldo_base
    INTO v_id_emp,
    v_numrun_emp,
    v_dvrun_emp,
    v_nombre_empleado,
    v_id_comuna,
    v_nombre_comuna,
    v_sueldo_base
    FROM empleado e
    join comuna c on c.id_comuna = e.id_comuna
    where e.id_emp = v_min_id_emp;
    v_porc_movil_normal := trunc(v_sueldo_base100000);
    v_valor_movil_normal := round(v_sueldo_base*v_porc_movil_normal100);
    
    v_valor_movil_extra := case
    when v_id_comuna = 117 then v_mov_mariapinto
    when v_id_comuna = 118 then v_mov_curacavi
    when v_id_comuna = 119 then v_mov_talagante
    when v_id_comuna = 120 then v_mov_elmonte
    when v_id_comuna = 121 then v_mov_buin
    ELSE 0
    END;
    v_valor_total_movil := v_valor_movil_normal + v_valor_movil_extra;
    INSERT INTO proy_movilizacion 
    VALUES (v_anno_proceso,v_id_emp,v_numrun_emp,v_dvrun_emp,v_nombre_empleado,v_nombre_comuna,v_sueldo_base,v_porc_movil_normal,v_valor_movil_normal,v_valor_movil_extra,v_valor_total_movil);
    v_min_id_emp := v_min_id_emp + 10;
  END LOOP;
  Commit;
END;


--Caso 2
SET SERVEROUTPUT ON;
DECLARE 
    CURSOR c1 IS 
        SELECT ID_EMP, NUMRUN_EMP, 
        DVRUN_EMP, pnombre_emp ||' '|| SNOMBRE_EMP|| ' '|| APPATERNO_EMP|| ' '||
        APMATERNO_EMP as "nombre", 
        -- NOMBRE USUARIO
        LOWER(SUBSTR(NOMBRE_ESTADO_CIVIL,0,1)) || SUBSTR(pnombre_emp,0,3)  || LENGTH(pnombre_emp) || '*' || SUBSTR(SUELDO_BASE,-1,1) || DVRUN_EMP  ||
        TRUNC(MONTHS_BETWEEN(SYSDATE,FECHA_CONTRATO)/12) as "nombre_usuario",
        -- CONTRASENIA
        SUBSTR(NUMRUN_EMP,3,1) || TO_NUMBER(TO_CHAR(FECHA_NAC,'YYYY') ) + 2 ||SUBSTR((SUELDO_BASE - 1),-3,3) ||
        
        CASE ec.ID_ESTADO_CIVIL
            WHEN 60 THEN LOWER(substr(APPATERNO_EMP,0,2))
            WHEN 10 THEN LOWER(substr(APPATERNO_EMP,0,2)) -- OK
            WHEN 20 THEN LOWER(substr(APPATERNO_EMP,0,1) ||  substr(APPATERNO_EMP,-1,1))-- 
            WHEN 30 THEN LOWER(substr(APPATERNO_EMP,0,1) ||  substr(APPATERNO_EMP,-1,1))-- OK
            WHEN 40 THEN LOWER(substr(APPATERNO_EMP,-3,2)) -- OK 
            WHEN 50 THEN LOWER(substr(APPATERNO_EMP,-2,2))  
            ELSE
                'X'
        END || ID_EMP AS "clave_usuario",
        -- ANIOS
        TRUNC(MONTHS_BETWEEN(SYSDATE,FECHA_CONTRATO)/12) AS "anios"
        FROM empleado e
        INNER JOIN ESTADO_CIVIL ec
        ON e.ID_ESTADO_CIVIL = ec.ID_ESTADO_CIVIL;
        
        -- Registros
        reg_c1 c1%rowtype;
        reg_usuario USUARIO_CLAVE%rowtype;
        
BEGIN

    -- TRUNCAR LA TABLA EN TIEMPO DE EJECUCION
    EXECUTE IMMEDIATE 'TRUNCATE TABLE USUARIO_CLAVE';    
    
    :b_fecha_proceso := '&dia' ||'/'||'&mes'||'/'||'&anio';

    FOR reg_c1 IN c1
    LOOP
        -- Calculos
        reg_usuario.ID_EMP := reg_c1.id_emp;
        reg_usuario.NUMRUN_EMP := reg_c1.NUMRUN_EMP;
        reg_usuario.DVRUN_EMP := reg_c1.DVRUN_EMP;
        reg_usuario.NOMBRE_EMPLEADO := reg_c1."nombre";
        reg_usuario.NOMBRE_USUARIO := reg_c1."nombre_usuario";
        reg_usuario.CLAVE_USUARIO := reg_c1."clave_usuario" || TO_CHAR(TO_DATE(:b_fecha_proceso),'MMYYYY');
        
        IF TO_NUMBER(reg_c1."anios") < 10 THEN
        -- NOMBRE USUARIO
             reg_usuario.NOMBRE_USUARIO := reg_usuario.NOMBRE_USUARIO || 'X';
        END IF;
        
        -- Objetivo
        INSERT INTO USUARIO_CLAVE VALUES reg_usuario;
        COMMIT;
    END LOOP;
END;

--Caso 3

-- CREAMOS UNA COPIA DE LA TABLA CAMI�N

CREATE TABLE CAMION_BACKUP AS SELECT * FROM CAMION;

-- CREAMOS VARIABLES BIND
VAR b_fecha_proceso VARCHAR2(10);
VAR b_pct_arriendo NUMBER;

EXECUTE :b_pct_arriendo := 0.225;

PRINT :b_pct_arriendo;


-- ACTIVAMOS LA SALIDA DE DBMS
SET SERVEROUTPUT ON;

DECLARE 
    -- DECLARAMOS EL CURSOR EXPLICITO
    CURSOR c1(p_fecha DATE) IS
    SELECT c.id_camion, c.NRO_PATENTE, c.VALOR_ARRIENDO_DIA,  c.VALOR_GARANTIA_DIA,
                COUNT(TO_CHAR(ac.FECHA_INI_ARRIENDO,'YYYY') ) AS "total_arriendo"
                FROM CAMION c
                LEFT JOIN ARRIENDO_CAMION ac
                ON c.id_camion = ac.id_camion
                GROUP BY c.id_camion,  c.NRO_PATENTE, c.VALOR_ARRIENDO_DIA, TO_CHAR(ac.FECHA_INI_ARRIENDO,'YYYY'), c.VALOR_GARANTIA_DIA
                HAVING  TO_CHAR(ac.FECHA_INI_ARRIENDO,'YYYY') = TO_NUMBER(TO_CHAR(p_fecha,'YYYY')) - 1 OR TO_CHAR(ac.FECHA_INI_ARRIENDO,'YYYY') IS NULL
                ORDER BY c.id_camion ASC;

                
    -- DECLARAMOS UNA VARIABLE DE TIPO RECORD
    REG_C1 c1%ROWTYPE;
    REG_HISTORIAL HIST_ARRIENDO_ANUAL_CAMION%ROWTYPE;
        
BEGIN
    :b_fecha_proceso := '&dia' || '/' || '&mes' || '/' || '&anio';
    
    -- TRUNCAR TABLA EN TIEMPO DE EJECUCI�N
    EXECUTE IMMEDIATE 'TRUNCATE TABLE HIST_ARRIENDO_ANUAL_CAMION';
    
    FOR REG_C1 IN c1(TO_DATE(:b_fecha_proceso))
    LOOP
        BEGIN
            -- CaLCULOS           
            REG_HISTORIAL.ANNO_PROCESO := TO_NUMBER(TO_CHAR(TO_DATE(:b_fecha_proceso),'YYYY'));
            REG_HISTORIAL.ID_CAMION := REG_C1.ID_CAMION;
            REG_HISTORIAL.NRO_PATENTE := REG_C1.NRO_PATENTE;
            REG_HISTORIAL.VALOR_ARRIENDO_DIA := REG_C1.VALOR_ARRIENDO_DIA;
            REG_HISTORIAL.TOTAL_VECES_ARRENDADO := REG_C1."total_arriendo";
            REG_HISTORIAL.VALOR_GARACTIA_DIA := REG_C1.VALOR_GARANTIA_DIA;
            
            -- VALOR GARANTIA ARRIENDO
            IF REG_HISTORIAL.TOTAL_VECES_ARRENDADO = 4 THEN
                REG_HISTORIAL.VALOR_GARACTIA_DIA :=  (REG_HISTORIAL.VALOR_ARRIENDO_DIA *  REG_HISTORIAL.TOTAL_VECES_ARRENDADO) - round((REG_HISTORIAL.VALOR_ARRIENDO_DIA * :b_pct_arriendo),0) ;
            END IF;
            -- OBJETIVO 
            
            -- INSERTAR EN LA TABLA HISTORIAL
            INSERT INTO HIST_ARRIENDO_ANUAL_CAMION VALUES REG_HISTORIAL;
            -- ACTUALIZAR EN LA TABLA CAMION
            UPDATE CAMION_BACKUP SET VALOR_GARANTIA_DIA = REG_HISTORIAL.VALOR_GARACTIA_DIA 
            WHERE ID_CAMION = REG_HISTORIAL.ID_CAMION;
            
            COMMIT;
            
        EXCEPTION
            WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE(SQLERRM || ' ' || SQLCODE); 
        END;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR EN EL BLOQUE AN�NIMO ' || SQLERRM);
END;