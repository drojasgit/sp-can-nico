/*
	version: 1.1.4
	fecha: 03-04-2020
*/

create or replace PACKAGE BODY PKG_CONSULTAS_CANONICO AS 

    C_PRODUCTO_FINACIERO CONSTANT VARCHAR2(10) := 'financiero';
    C_CLIENTE CONSTANT VARCHAR2(10) := 'cliente';

    /*
     *    Este procedimiento obtiene todos los datos del contacto mediante el rut del contacto 
     *    @param P_RUT_CONTACTO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */   
    PROCEDURE PRC_GET_CONTACTOS_FULL(P_RUT_CONTACTO IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT CON.ID_CONTACTO, CON.RUT, CON.NOMBRE,CON.ESTADO_CONTACTO, CON.COD_NACIONALIDAD, CON.NACIONALIDAD, 
                CON.APELLIDO_PATERNO, CON.APELLIDO_MATERNO,CON.GRUPO_CONTACTO,CON.FUENTE_ORIGEN, 
                to_char(CON.FECHA_ULTIMO_CONTACTO, 'yyyy-MM-dd HH24:Mi:ss'), CON.TIPO_ULTIMO_CONTACTO, 
                to_char(CON.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION,
                to_char(CON.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, CON.ESTADO
                FROM CONTACTO CON
                JOIN CONTACTO_ENTIDAD CE ON CE.ID_CONTACTO = CON.ID_CONTACTO
                AND CON.RUT = P_RUT_CONTACTO;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_CONTACTOS_FULL;
    
    /*
     *    Este procedimiento obtiene todos los datos de entidad contacto
     *    </br>por el id de la entidad y el tipo de relación (cliente - local - cadena)
     *    @param P_RUT_CONTACTO IN VARCHAR
     *    @param P_ID_ENTIDAD IN VARCHAR
     *    @param P_ENTIDAD IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */   
    PROCEDURE PRC_GET_CONTACTOS_ENTIDAD_FULL(P_RUT_CONTACTO IN VARCHAR, P_ID_ENTIDAD IN VARCHAR, P_ENTIDAD IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            IF P_ID_ENTIDAD IS NULL OR P_ENTIDAD IS NULL THEN
                OPEN P_RESP FOR SELECT CE.ID_CONTACTO_ENTIDAD, CE.TIPO_RELACION, CE.TIPO_CONTACTO, CE.CARGO, CE.CONTACTABLE, 
                CE.MOTIVO_NO_CONTACTABLE, CE.RUT_FIRMA_CONJUNTA, CE.ROL_CONTACTO, CE.TIPO_FIRMA, 
                to_char(CE.FECHA_INICIO_VIGENCIA,'yyyy-MM-dd HH24:Mi:ss') FECHA_INICIO_VIGENCIA, 
                to_char(CE.FECHA_FIN_VIGENCIA,'yyyy-MM-dd HH24:Mi:ss') FECHA_FIN_VIGENCIA, CE.URL_DOCUMENTO_DIGITAL, 
                CE.NUMERO_DOCUMENTO_DIGITAL, to_char(CON.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                to_char(CON.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, CON.ESTADO
                FROM CONTACTO_ENTIDAD CE JOIN CONTACTO CON
                ON CE.ID_CONTACTO = CON.ID_CONTACTO
                AND CON.RUT = P_RUT_CONTACTO;
            ELSE
                OPEN P_RESP FOR SELECT CE.ID_CONTACTO_ENTIDAD, CE.TIPO_RELACION, CE.TIPO_CONTACTO, CE.CARGO, CE.CONTACTABLE, 
                CE.MOTIVO_NO_CONTACTABLE,  CE.RUT_FIRMA_CONJUNTA, CE.ROL_CONTACTO, CE.TIPO_FIRMA, 
                to_char(CE.FECHA_INICIO_VIGENCIA,'yyyy-MM-dd HH24:Mi:ss') FECHA_INICIO_VIGENCIA, 
                to_char(CE.FECHA_FIN_VIGENCIA,'yyyy-MM-dd HH24:Mi:ss') FECHA_FIN_VIGENCIA, CE.URL_DOCUMENTO_DIGITAL, 
                CE.NUMERO_DOCUMENTO_DIGITAL, to_char(CON.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                to_char(CON.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, CON.ESTADO
                FROM CONTACTO_ENTIDAD CE JOIN CONTACTO CON
                ON CE.ID_CONTACTO = CON.ID_CONTACTO
                AND CON.ID_CONTACTO = P_ID_ENTIDAD
                AND CE.TIPO_RELACION = P_ENTIDAD;
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_CONTACTOS_ENTIDAD_FULL;
    /*
     *    Este procedimiento obtiene el ID, TIPO y NOMBRE de la dirección
     *    </br>por el id de la entidad y el tipo de relación (contacto - cliente - comercio_secundario)
     *    @param P_ID_ENTIDAD IN VARCHAR
     *    @param P_ENTIDAD IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */   
    PROCEDURE PRC_GET_DIRECCION_ENTIDAD(P_ID_ENTIDAD IN VARCHAR, P_ENTIDAD IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT D.ID_DIRECCION, D.TIPO_DIRECCION AS TIPO, D.DIRECCION AS NOMBRE
                    FROM DIRECCION_ENTIDAD DE JOIN DIRECCION D
                    ON D.ID_DIRECCION = DE.ID_DIRECCION
                    AND DE.ID_DIRECCION_ENTIDAD = P_ID_ENTIDAD
                    AND DE.TIPO_RELACION = P_ENTIDAD;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_DIRECCION_ENTIDAD;

    /*
     *    Este procedimiento obtiene todos los datos de la dirección
     *    </br>por el id de la entidad y el tipo de relación (contacto - cliente - comercio_secundario)
     *    </br>y si se quiere filtrar por el tipo de cliente.
     *    @param P_ID_ENTIDAD IN VARCHAR
     *    @param P_ENTIDAD IN VARCHAR
     *    @param P_TIPO_CLIENTE IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */ 
    PROCEDURE PRC_GET_DIRECCION_FULL(P_ID_ENTIDAD IN VARCHAR, P_ENTIDAD IN VARCHAR, P_TIPO_CLIENTE IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            IF P_ENTIDAD = C_CLIENTE AND P_TIPO_CLIENTE IS NULL THEN
                OPEN P_RESP FOR SELECT DI.ID_DIRECCION, DI.TIPO_DIRECCION, DI.OFICINA_DISTRIBUCION, DI.NUMERO_LOCAL, DI.NUMERO_CALLE, 
                DI.ESTACIONAL, DI.DIRECCION, DI.COD_CIUDAD, DI.CIUDAD, DI.COD_REGION, DI.REGION, DI.COD_COMUNA, DI.COMUNA, DI.UBICACION, DI.PAIS, 
                to_char(DI.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                to_char(DI.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, DI.LATITUD, DI.LONGITUD, DI.ESTADO
                FROM CLIENTE CLI 
                JOIN DIRECCION_ENTIDAD DE ON CLI.ID_CLIENTE = DE.ID_ENTIDAD
                JOIN DIRECCION DI ON DE.ID_DIRECCION = DI.ID_DIRECCION
                AND DE.TIPO_RELACION = P_ENTIDAD
                AND DE.ID_ENTIDAD = P_ID_ENTIDAD;
            ELSIF P_ENTIDAD = C_CLIENTE AND P_TIPO_CLIENTE IS NOT NULL THEN 
                OPEN P_RESP FOR SELECT DI.ID_DIRECCION, DI.TIPO_DIRECCION, DI.OFICINA_DISTRIBUCION, DI.NUMERO_LOCAL, DI.NUMERO_CALLE, 
                DI.ESTACIONAL, DI.DIRECCION, DI.COD_CIUDAD, DI.CIUDAD, DI.COD_REGION, DI.REGION, DI.COD_COMUNA, DI.COMUNA, DI.UBICACION, DI.PAIS, 
                to_char(DI.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                to_char(DI.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, DI.LATITUD, DI.LONGITUD, DI.ESTADO
                FROM CLIENTE CLI 
                JOIN DIRECCION_ENTIDAD DE ON CLI.ID_CLIENTE = DE.ID_ENTIDAD
                AND CLI.TIPO_CLIENTE = P_TIPO_CLIENTE
                JOIN DIRECCION DI ON DE.ID_DIRECCION = DI.ID_DIRECCION
                AND DE.TIPO_RELACION = P_ENTIDAD
                AND DE.ID_ENTIDAD = P_ID_ENTIDAD;
            ELSE
                OPEN P_RESP FOR SELECT DI.ID_DIRECCION, DI.TIPO_DIRECCION, DI.OFICINA_DISTRIBUCION, DI.NUMERO_LOCAL, DI.NUMERO_CALLE, 
                DI.ESTACIONAL, DI.DIRECCION, DI.COD_CIUDAD, DI.CIUDAD, DI.COD_REGION, DI.REGION, DI.COD_COMUNA, DI.COMUNA, DI.UBICACION, DI.PAIS, 
                to_char(DI.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                to_char(DI.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, DI.LATITUD, DI.LONGITUD, DI.ESTADO
                FROM DIRECCION DI
                JOIN DIRECCION_ENTIDAD DE ON DE.ID_DIRECCION = DI.ID_DIRECCION
                AND DE.TIPO_RELACION = P_ENTIDAD
                AND DE.ID_ENTIDAD = P_ID_ENTIDAD;
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_DIRECCION_FULL;
    /*
     *    Este procedimiento obtiene los datos de la cadena y del padre (cliente).
     *    @param P_ID_CADENA IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */    
    PROCEDURE PRC_GET_CADENA_FULL(P_ID_CADENA IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
              OPEN P_RESP FOR SELECT ID_CADENA, NOMBRE_CADENA, to_char(FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
              to_char(FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, ESTADO
              FROM CADENA 
              WHERE ID_CADENA = P_ID_CADENA;
        EXCEPTION
            WHEN ROWTYPE_MISMATCH THEN
                dbms_output.put_line('Se asignó a una variable o a un parámetro un valor de tipo incompatible.');
            WHEN OTHERS THEN
                err_num := SQLCODE;
                err_msg := SQLERRM;
                dbms_output.put_line('Error:' || TO_CHAR(err_num));
                dbms_output.put_line(err_msg);
    END PRC_GET_CADENA_FULL;
    /*
     *    Este procedimiento obtiene todos los datos del local por el id de la cadena
     *    @param P_ID_CADENA IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */ 
    PROCEDURE PRC_GET_LOCALES_CADENA_FULL(P_ID_CADENA IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT LO.ID_LOCAL, LO.NOMBRE_FANTASIA, LO.FECHA_CREACION, LO.FECHA_ACTUALIZACION, LO.ESTADO, 
                    DI.ID_DIRECCION, DI.TIPO_DIRECCION, DI.OFICINA_DISTRIBUCION, DI.NUMERO_LOCAL, DI.NUMERO_CALLE, DI.ESTACIONAL, DI.DIRECCION, 
                    DI.COD_CIUDAD, DI.CIUDAD, DI.COD_REGION, DI.REGION, DI.COD_COMUNA, DI.COMUNA, DI.UBICACION, DI.PAIS, 
                    to_char(DI.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                    to_char(DI.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, DI.LATITUD, DI.LONGITUD, 
                    DI.ESTADO AS ESTADO_DIRECCION
                    FROM LOCAL LO
                    JOIN CADENA CA ON CA.ID_CADENA = LO.ID_CADENA
                    AND CA.ID_CADENA = P_ID_CADENA
                    LEFT JOIN DIRECCION DI ON LO.ID_DIRECCION = DI.ID_DIRECCION;

        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_LOCALES_CADENA_FULL;

    /*
     *    Este procedimiento obtiene todos los datos del medio de contacto por el id del contacto
     *    @param P_ID_CONTACTO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */
    PROCEDURE PRC_GET_MEDIO_CONTACTO_FULL(P_ID_CONTACTO IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT MC.ID_MEDIO_CONTACTO, MC.TIPO, MC.VALOR, MC.MEDIO_PREFERIDO, 
            to_char(MC.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
            to_char(MC.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, MC.ESTADO 
            FROM MEDIO_CONTACTO MC
            JOIN CONTACTO CO ON MC.ID_CONTACTO = CO.ID_CONTACTO
            AND CO.ID_CONTACTO = P_ID_CONTACTO;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_MEDIO_CONTACTO_FULL;
    /*
     *    Este procedimiento obtiene todos los datos del local, dirección y 
     *    </br>el ID, TIPO y NOMBRE de la cadena mediante el id del local
     *    @param P_ID_LOCAL IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */   
    PROCEDURE PRC_GET_LOCAL_FULL(P_ID_LOCAL IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT LO.ID_LOCAL, LO.NOMBRE_FANTASIA, TO_CHAR(LO.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECH_CREA_LOCAL, 
            TO_CHAR(LO.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECH_ACTU_LOCAL, LO.ESTADO ESTADO_LOCAL, DI.ID_DIRECCION, 
            DI.TIPO_DIRECCION, DI.OFICINA_DISTRIBUCION, DI.NUMERO_LOCAL, DI.NUMERO_CALLE, DI.ESTACIONAL, DI.DIRECCION, DI.COD_CIUDAD, 
            DI.CIUDAD, DI.COD_REGION, DI.REGION, DI.COD_COMUNA, DI.COMUNA, DI.UBICACION, DI.PAIS, 
            TO_CHAR(DI.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECH_CREAC_LOCAL, 
            TO_CHAR(DI.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECH_ACTU_DIREC, DI.LATITUD, DI.LONGITUD, DI.ESTADO ESTADO_DIREC
            FROM LOCAL LO
            LEFT JOIN DIRECCION DI ON DI.ID_DIRECCION = LO.ID_DIRECCION
            AND LO.ID_LOCAL = P_ID_LOCAL;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_LOCAL_FULL;
    /*
     *    Este procedimiento obtiene el ID, TIPO y NOMBRE del punto de venta mediante el id del local
     *    @param P_ID_LOCAL IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */     
    PROCEDURE PRC_GET_PTO_VTA_LOCAL_LOV(P_ID_LOCAL IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT PV.ID_PUNTO_VENTA, 'PUNTO_VENTA' TIPO, NULL NOMBRE 
            FROM PUNTO_VENTA PV 
            WHERE PV.ID_PUNTO_VENTA = P_ID_LOCAL;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_PTO_VTA_LOCAL_LOV;
    /*
     *    Este procedimiento obtiene toda la información del medio de contacto del local
     *    @param P_ID_LOCAL IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */ 
    PROCEDURE PRC_GET_MEDIO_CONTACTO_LOCAL_FULL(P_ID_LOCAL IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT MC.ID_MEDIO_CONTACTO, MC.TIPO, MC.VALOR, MC.MEDIO_PREFERIDO, 
            to_char(MC.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
            to_char(MC.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, MC.ESTADO 
            FROM MEDIO_CONTACTO MC
            JOIN LOCAL LO ON LO.ID_LOCAL = MC.ID_LOCAL
            AND LO.ID_LOCAL = P_ID_LOCAL;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_MEDIO_CONTACTO_LOCAL_FULL;
    /*
     *    Este procedimiento obtiene todos los datos del punto de venta mediante su id
     *    @param P_ID_PTO_VTA IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */
    PROCEDURE PRC_GET_PTO_VTA_FULL(P_ID_PTO_VTA IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT ID_PUNTO_VENTA, IND_TNMSPROPINA, ESTADO_INSTALACION, 
            TO_CHAR(FECHA_HABILITACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_HABILITACION, 
            TO_CHAR(FECHA_EFEC_INSTALA, 'yyyy-MM-dd HH24:Mi:ss') FECHA_EFEC_INSTALA, DLL_DOLAR, DLL, ES_BENCINERA, IND_COBRADOR, 
            TO_CHAR(FECHA_CREACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
            TO_CHAR(FECHA_ACTUALIZACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, 
            ESTADO, FECHA_ACTIVACION, FECHA_INACTIVACION, TARIFA_COBRO_X_EQUIPAMIENTO, SURCHARGE, SERIETE, 
            PAGO_TIPO_B, FECHA_RETIRO_EQUIPO, FECHA_INICIO_SERV, FECHA_FIN_SERV, MOTIVO_BAJAS, NUM_SERIE_PINPAD
            FROM PUNTO_VENTA PV 
            WHERE ID_PUNTO_VENTA = P_ID_PTO_VTA;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_PTO_VTA_FULL;
    /*
     *    Este procedimiento obtiene todos los datos del rubro mediante el id del punto de venta
     *    @param P_ID_PTO_VTA IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */
    PROCEDURE PRC_GET_RUBRO_PTO_VTA_FULL(P_ID_PTO_VTA IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT RC.ID_RUBRO_CLIENTE, RC.ACTIVIDAD_ECONOMICA, RC.RUBRO, RC.RUBRO_INTERNO_TBK, 
            TO_CHAR(RC.FECHA_INICIO_VIGENCIA, 'yyyy-MM-dd HH24:Mi:ss') FECHA_INICIO_VIGENCIA,
            TO_CHAR(RC.FECHA_FIN_VIGENCIA, 'yyyy-MM-dd HH24:Mi:ss') FECHA_FIN_VIGENCIA,
            TO_CHAR(RC.FECHA_CREACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION,
            TO_CHAR(RC.FECHA_ACTUALIZACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTULIZACION,
            RC.ESTADO 
            FROM PUNTO_VENTA PV
            JOIN ATRIBUTOS_PRODUCTO AP ON AP.ID_PUNTO_VENTA = PV.ID_PUNTO_VENTA
            AND PV.ID_PUNTO_VENTA = P_ID_PTO_VTA
            JOIN RUBRO_CLIENTE RC ON RC.ID_RUBRO_CLIENTE = AP.ID_RUBRO_CLIENTE;

        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_RUBRO_PTO_VTA_FULL;

    /*
     *    Este procedimiento obtiene todos los datos de los atributos de producto con respecto al id del punto de venta
     *    @param P_ID_PTO_VTA IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */
    PROCEDURE PRC_GET_ATRIBUTOS_PRODUCTO_PTO_VTA_FULL(P_ID_PTO_VTA IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT AP.ID_ATRIBUTOS_PRODUCTO, AP.IND_LIQUIDACION, AP.IND_FACTURACION, AP.FORMATO_LIQUIDACION, AP.DIRECCION_URL,
            AP.CODIGO_MALL_WEB, AP.CODIGO_COMERCIO_DOLAR, AP.CODIGO_COMERCIO_PESO, AP.CODIGO_AMEX, AP.CODIGO_AMEX_DOLAR, 
            AP.IND_AUTORIZACION_INTERNET,AP.EMPLEADO, AP.DONACION, AP.VCB, TO_CHAR(AP.FECHA_ACT_VCB, 'yyyy-MM-dd HH24:Mi:ss') FECHA_ACT_VCB, 
            TO_CHAR(AP.FECHA_DESACT_VCB, 'yyyy-MM-dd HH24:Mi:ss') FECHA_DESACT_VCB, AP.VENTA_EXTRANJERA, AP.TRANSNACIONAL, AP.TIPO_CARTOLA, 
            AP.MAF_3DSECURE,AP.LLAVE_EECC, AP.TIPO_CAPTURA, AP.CONTACTLESS, 
            TO_CHAR(AP.FECHA_CONTACTLESS, 'yyyy-MM-dd HH24:Mi:ss') FECHA_CONTACTLESS,
            TO_CHAR(AP.FECHA_DESACT_CONTACTLESS, 'yyyy-MM-dd HH24:Mi:ss') FECHA_DESACT_CONTACTLESS, AP.LIQUIDACION_PARAMETRICA, AP.CBSP,
            TO_CHAR(AP.FECHA_CREACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
            TO_CHAR(AP.FECHA_ACTUALIZACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, AP.ESTADO, AP.VENTA_SOLO_TC, AP.ADELANTAMIENTO_CUOTAS,
            AP.FECHA_INICIO_ADEL_CUOTA, AP.FECHA_FIN_ADEL_CUOTA
            FROM PUNTO_VENTA PV 
            JOIN ATRIBUTOS_PRODUCTO AP ON AP.ID_PUNTO_VENTA = PV.ID_PUNTO_VENTA
            AND PV.ID_PUNTO_VENTA = P_ID_PTO_VTA;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_ATRIBUTOS_PRODUCTO_PTO_VTA_FULL;
    /*
     *    Este procedimiento obtiene todos los datos del medio de pago y la cuenta de abono
     *    </br>mediante el id del punto de venta asociado.
     *    @param P_ID_LOCAL IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */
    PROCEDURE PRC_GET_MEDIO_PAGO_MARCA_PTO_VTA_FULL(P_ID_PTO_VTA IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT MP.ID_MEDIO_PAGO_MARCA, MP.MARCA, MP.TASA_COMISION,MP.TASA_TRANSACCION, MP.DESFACE_ABONO, 
            TO_CHAR(MP.FECHA_CREACION, 'yyyy-MM-dd HH24:Mi:ss') FECH_CREA_MEDIO_PAGO_MARCA, 
            TO_CHAR(MP.FECHA_ACTUALIZACION, 'yyyy-MM-dd HH24:Mi:ss') FECH_ACTU_MEDIO_PAGO_MARCA, MP.MEDIO_PAGO, 
            MP.MONEDA MONEDA_MEDIO_PAGO_MARCA, MP.MES_GRACIA, MP.ESTADO ESTADO_MEDIO_PAGO_MARCA, CB.ID_CUENTA_ABONO, CB.COD_SUCURSAL,
            CB.ID_BANCO, CB.BANCO, CB.PROPIEDAD_CUENTA, CB.RUT2_TIT_CTA_CTE, CB.RUT_TIT_CTA_CTE, CB.NUM_CTA_CTE, CB.NOMBRE_TIT_CTA_CTE, 
            CB.IND_BIPERSONAL, CB.MONEDA MONEDA_CTA_ABONO, CB.TIPO_CTA_ABONO, 
            TO_CHAR(CB.FECHA_CREACION, 'yyyy-MM-dd HH24:Mi:ss') FECH_CREA_CTA_ABONO,
            TO_CHAR(CB.FECHA_ACTUALIZACION, 'yyyy-MM-dd HH24:Mi:ss') FECH_ACTU_CTA_ABONO, CB.ESTADO ESTADO_CTA_ABONO
            FROM MEDIO_PAGO_MARCA MP
            JOIN PUNTO_VENTA PV ON PV.ID_PUNTO_VENTA = MP.ID_PUNTO_VENTA
            AND PV.ID_PUNTO_VENTA = P_ID_PTO_VTA
            LEFT JOIN CUENTA_ABONO CB ON CB.ID_CUENTA_ABONO = MP.ID_CUENTA_ABONO;            
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_MEDIO_PAGO_MARCA_PTO_VTA_FULL;
    /*
     *    Este procedimiento obtiene todos los datos del producto contratado basándose en el id del punto de venta.
     *    @param P_ID_PTO_VTA IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */
    PROCEDURE PRC_GET_PRODUCTOS_CONTRATADOS_PTO_VTA_FULL(P_ID_PTO_VTA IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS 
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT PC.ID_PRODUCTO_CONTRATADO, PC.NOMBRE_PRODUCTO, 
            TO_CHAR(PC.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
            TO_CHAR(PC.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, PC.ESTADO,
            PC.TIPO_PRODUCTO, PC.MAX_NCUOTAS, PC.CANAL_OPERACION
            FROM PUNTO_VENTA PV
            JOIN PUNTO_VENTA_PRODUCTO_REL PR ON PV.ID_PUNTO_VENTA = PR.ID_PUNTO_VENTA
            AND PV.ID_PUNTO_VENTA = P_ID_PTO_VTA
            JOIN PRODUCTO_CONTRATADO PC ON PR.ID_PRODUCTO_CONTRATADO = PC.ID_PRODUCTO_CONTRATADO;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_PRODUCTOS_CONTRATADOS_PTO_VTA_FULL;
    /*
     *    Este procedimiento obtiene los productos financieros mediante el id del punto de venta 
     *    y el id del producto canal
     *    @param P_ID_PTO_VTA IN VARCHAR
     *    @param P_ID_PRODUCTO_CONTRATADO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */
    PROCEDURE PRC_GET_PRODUCTOS_FINANCIEROS_PTO_VTA_FULL(P_ID_PTO_VTA IN VARCHAR, P_ID_PROD_CANAL IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS 
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT PC.ID_PRODUCTO_CONTRATADO, PC.NOMBRE_PRODUCTO, 
            TO_CHAR(PC.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
            TO_CHAR(PC.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, 
            PC.TIPO_PRODUCTO, PC.MAX_NCUOTAS, PC.CANAL_OPERACION, PC.ESTADO
            FROM PUNTO_VENTA_PRODUCTO_REL PR  
            JOIN PRODUCTO_CONTRATADO PC ON PC.ID_PRODUCTO_CONTRATADO = PR.ID_PRODUCTO_FINANCIERO
            AND PC.TIPO_PRODUCTO = C_PRODUCTO_FINACIERO AND PR.ID_PRODUCTO_CONTRATADO = P_ID_PROD_CANAL
            JOIN PUNTO_VENTA PV ON PV.ID_PUNTO_VENTA = PR.ID_PUNTO_VENTA
            AND PV.ID_PUNTO_VENTA = P_ID_PTO_VTA;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_PRODUCTOS_FINANCIEROS_PTO_VTA_FULL;
    /*
     *    Este procedimiento obtiene los productos financieros mediante el id del producto canal
     *    @param P_ID_PRODUCTO_CONTRATADO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */
    PROCEDURE PRC_GET_PRODUCTOS_FINANCIEROS_FULL(P_ID_PROD_CANAL IN VARCHAR, P_RESP OUT SYS_REFCURSOR) is
    err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT PC.ID_PRODUCTO_CONTRATADO, PC.NOMBRE_PRODUCTO, 
            TO_CHAR(PC.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
            TO_CHAR(PC.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, 
            PC.TIPO_PRODUCTO, PC.MAX_NCUOTAS, PC.CANAL_OPERACION, PC.ESTADO
            FROM PUNTO_VENTA_PRODUCTO_REL PR  
            JOIN PRODUCTO_CONTRATADO PC ON PC.ID_PRODUCTO_CONTRATADO = PR.ID_PRODUCTO_FINANCIERO
            AND PC.TIPO_PRODUCTO = C_PRODUCTO_FINACIERO AND PR.ID_PRODUCTO_CONTRATADO = P_ID_PROD_CANAL;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_PRODUCTOS_FINANCIEROS_FULL;

    /*
     *    Este procedimiento obtiene toda la información de cliente mediante su RUT 
     *    o un filtrandolo por su tipo (PSP - COM)
     *    @param P_RUT_CLIENTE IN VARCHAR
     *    @param P_TIPO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */
    PROCEDURE PRC_GET_CLIENTE_FULL(P_RUT_CLIENTE IN VARCHAR, P_TIPO IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            IF P_TIPO IS NULL THEN
                OPEN P_RESP FOR SELECT CLI.ID_CLIENTE, CLI.RUT_CLIENTE, CLI.RUT_EJECUTIVO, CLI.RAZON_SOCIAL, CLI.NOMBRE_EJECUTIVO,
                CLI.TIPO_CLIENTE, CLI.GIRO_COMERCIAL, TO_CHAR(CLI.FECHA_CONV_GRP_NEGOCIADOR,'yyyy-MM-dd HH24:Mi:ss') FECHA_CONV_GRP_NEGOCIADOR,
                TO_CHAR(CLI.FECHA_INGRESO_COMERCIO,'yyyy-MM-dd HH24:Mi:ss') FECHA_INGRESO_COMERCIO, 
                TO_CHAR(CLI.FECHA_ESTADO_BASE_NEG,'yyyy-MM-dd HH24:Mi:ss') FECHA_ESTADO_BASE_NEG, 
                TO_CHAR(CLI.FECHA_CONT_RUT,'yyyy-MM-dd HH24:Mi:ss') FECHA_CONT_RUT, 
                TO_CHAR(CLI.FECHA_ADHERIDO_PORTAL,'yyyy-MM-dd HH24:Mi:ss') FECHA_ADHERIDO_PORTAL, CLI.ESTADO_BASE_NEGATIVA, CLI.SEGMENTO,
                CLI.CONTINUIDAD_RUT, CLI.GRUPO_ECONOMICO, CLI.ADHERIDO_PORTAL, CLI.RUT_GRUPO_NEGOCIADOR, 
                CLI.NOMBRE_GRUPO_NEGOCIADOR, CLI.FECHA_AFILIACION, CLI.FECHA_DESAFILIACION, CLI.ESTADO_CLIENTE, CLI.FORMA_INCORPORACION,
                CLI.MARCA_EMBARGO, CLI.MARCA_EVALUACION, CLI.BOLETA_GARANTIA, TO_CHAR(CLI.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION,
                TO_CHAR(CLI.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, CLI.ESTADO, CLI.PAR, CLI.TIPO_PERSONA
                FROM CLIENTE CLI
                WHERE CLI.RUT_CLIENTE = P_RUT_CLIENTE;
            ELSE
                OPEN P_RESP FOR SELECT CLI.ID_CLIENTE, CLI.RUT_CLIENTE, CLI.RUT_EJECUTIVO, CLI.RAZON_SOCIAL, CLI.NOMBRE_EJECUTIVO,
                CLI.TIPO_CLIENTE, CLI.GIRO_COMERCIAL, TO_CHAR(CLI.FECHA_CONV_GRP_NEGOCIADOR,'yyyy-MM-dd HH24:Mi:ss') FECHA_CONV_GRP_NEGOCIADOR,
                TO_CHAR(CLI.FECHA_INGRESO_COMERCIO,'yyyy-MM-dd HH24:Mi:ss') FECHA_INGRESO_COMERCIO, 
                TO_CHAR(CLI.FECHA_ESTADO_BASE_NEG,'yyyy-MM-dd HH24:Mi:ss') FECHA_ESTADO_BASE_NEG, 
                TO_CHAR(CLI.FECHA_CONT_RUT,'yyyy-MM-dd HH24:Mi:ss') FECHA_CONT_RUT, 
                TO_CHAR(CLI.FECHA_ADHERIDO_PORTAL,'yyyy-MM-dd HH24:Mi:ss') FECHA_ADHERIDO_PORTAL, CLI.ESTADO_BASE_NEGATIVA, CLI.SEGMENTO,
                CLI.CONTINUIDAD_RUT, CLI.GRUPO_ECONOMICO, CLI.ADHERIDO_PORTAL, CLI.RUT_GRUPO_NEGOCIADOR, 
                CLI.NOMBRE_GRUPO_NEGOCIADOR, CLI.FECHA_AFILIACION, CLI.FECHA_DESAFILIACION, CLI.ESTADO_CLIENTE, CLI.FORMA_INCORPORACION,
                CLI.MARCA_EMBARGO, CLI.MARCA_EVALUACION, CLI.BOLETA_GARANTIA, TO_CHAR(CLI.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION,
                TO_CHAR(CLI.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, CLI.ESTADO, CLI.PAR, CLI.TIPO_PERSONA
                FROM CLIENTE CLI
                WHERE CLI.RUT_CLIENTE = P_RUT_CLIENTE AND CLI.TIPO_CLIENTE = P_TIPO;
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);      
        END PRC_GET_CLIENTE_FULL;
    /*
     *    Este procedimiento devuelve el ID, TIPO y NOMBRE de la relación de los clientes mediante el rut de un cliente
     *    </br>y el tipo de cliente si se quire filtrar.
     *    @param P_RUT_CLIENTE IN VARCHAR
     *    @param P_TIPO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */
    PROCEDURE PRC_GET_CLIENTE_RELACION_LOV(P_ID_CLIENTE IN VARCHAR, P_TIPO IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            IF P_TIPO IS NULL THEN
                OPEN P_RESP FOR 
                SELECT CLI.RUT_CLIENTE, REL.TIPO_RELACION, REL.JERARQUIA  FROM(
                  select ID_CLIENTE_PADRE ID , TIPO_RELACION, 'PADRE' AS JERARQUIA from RELACION_CLIENTE where ID_CLIENTE_HIJO = P_ID_CLIENTE
                    UNION ALL
                  select ID_CLIENTE_HIJO ID,  TIPO_RELACION, 'HIJO' AS JERARQUIA  from RELACION_CLIENTE where ID_CLIENTE_PADRE = P_ID_CLIENTE) REL
                JOIN CLIENTE CLI 
                ON REL.ID = CLI.ID_CLIENTE;
            ELSE
                 OPEN P_RESP FOR 
                SELECT CLI.RUT_CLIENTE, REL.TIPO_RELACION, REL.JERARQUIA  FROM(
                  select ID_CLIENTE_PADRE ID , TIPO_RELACION, 'PADRE' AS JERARQUIA from RELACION_CLIENTE where ID_CLIENTE_HIJO = P_ID_CLIENTE
                    UNION ALL
                  select ID_CLIENTE_HIJO ID,  TIPO_RELACION, 'HIJO' AS JERARQUIA  from RELACION_CLIENTE where ID_CLIENTE_PADRE = P_ID_CLIENTE) REL
                JOIN CLIENTE CLI 
                ON REL.ID = CLI.ID_CLIENTE AND CLI.TIPO_CLIENTE = P_TIPO;
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);      
        END PRC_GET_CLIENTE_RELACION_LOV;
        
        /*
     *    Este procedimiento obtiene todos los datos del contacto mediante el rut del cliente
     *    </br>y el el tipo de cliente en caso de filtrarlo.
     *    @param P_RUT_CLIENTE IN VARCHAR
     *    @param P_TIPO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */ 
    PROCEDURE PRC_GET_CONTACTOS_CLIENTE_FULL(P_RUT_CLIENTE IN VARCHAR, P_TIPO IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            IF P_TIPO IS NULL THEN 
                OPEN P_RESP FOR SELECT CON.ID_CONTACTO, CON.RUT, CON.NOMBRE,CON.ESTADO_CONTACTO, CON.COD_NACIONALIDAD, CON.NACIONALIDAD, 
                CON.APELLIDO_PATERNO, CON.APELLIDO_MATERNO,CON.GRUPO_CONTACTO,CON.FUENTE_ORIGEN, 
                to_char(CON.FECHA_ULTIMO_CONTACTO, 'yyyy-MM-dd HH24:Mi:ss'), CON.TIPO_ULTIMO_CONTACTO, 
                to_char(CON.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION,
                to_char(CON.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, CON.ESTADO
                FROM CLIENTE CLI 
                JOIN CONTACTO_ENTIDAD CE ON CE.ID_ENTIDAD = CLI.ID_CLIENTE
                AND CLI.RUT_CLIENTE = P_RUT_CLIENTE 
                JOIN CONTACTO CON ON CE.ID_CONTACTO = CON.ID_CONTACTO;
            ELSE
                OPEN P_RESP FOR SELECT CON.ID_CONTACTO, CON.RUT, CON.NOMBRE,CON.ESTADO_CONTACTO, CON.NACIONALIDAD, 
                CON.APELLIDO_PATERNO, CON.APELLIDO_MATERNO,CON.GRUPO_CONTACTO,CON.FUENTE_ORIGEN, 
                to_char(CON.FECHA_ULTIMO_CONTACTO, 'yyyy-MM-dd HH24:Mi:ss'), CON.TIPO_ULTIMO_CONTACTO, 
                to_char(CON.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION,
                to_char(CON.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, CON.ESTADO
                FROM CLIENTE CLI 
                JOIN CONTACTO_ENTIDAD CE ON CE.ID_ENTIDAD = CLI.ID_CLIENTE
                AND CLI.RUT_CLIENTE = P_RUT_CLIENTE AND CLI.TIPO_CLIENTE = P_TIPO
                JOIN CONTACTO CON ON CE.ID_CONTACTO = CON.ID_CONTACTO;
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_CONTACTOS_CLIENTE_FULL;

    /*
     *    Este procedimiento obtiene el ID, TIPO y NOMBRE de la cadena mediante el rut del cliente
     *    @param P_RUT_CLIENTE IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */
    PROCEDURE PRC_GET_CADENA_CLIENTE_FULL(P_RUT_CLIENTE IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
              OPEN P_RESP FOR SELECT CAD.ID_CADENA, CAD.NOMBRE_CADENA,to_char(CAD.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
              to_char(CAD.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, CAD.ESTADO
              FROM CADENA CAD JOIN CLIENTE CLI
              ON CAD.ID_CLIENTE = CLI.ID_CLIENTE
              AND CLI.RUT_CLIENTE = P_RUT_CLIENTE;
        EXCEPTION
            WHEN ROWTYPE_MISMATCH THEN
                dbms_output.put_line('Se asignó a una variable o a un parámetro un valor de tipo incompatible.');
            WHEN OTHERS THEN
                err_num := SQLCODE;
                err_msg := SQLERRM;
                dbms_output.put_line('Error:' || TO_CHAR(err_num));
                dbms_output.put_line(err_msg);
    END PRC_GET_CADENA_CLIENTE_FULL;

    /*
     *    Este procedimiento obtiene todos los datos del medio de contacto por el RUT del cliente
     *    </br>y el tipo de cliente si se quire filtrar.
     *    @param P_RUT_CLIENTE IN VARCHAR
     *    @param P_TIPO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */
    PROCEDURE PRC_GET_MEDIO_CONTACTO_CLIENTE_FULL(P_RUT_CLIENTE IN VARCHAR, P_TIPO IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            IF P_TIPO IS NULL THEN
                OPEN P_RESP FOR SELECT MC.ID_MEDIO_CONTACTO, MC.TIPO, MC.VALOR, MC.MEDIO_PREFERIDO, 
                to_char(MC.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                to_char(MC.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, 
                MC.ESTADO 
                FROM MEDIO_CONTACTO MC
                JOIN CLIENTE CLI ON CLI.ID_CLIENTE = MC.ID_CLIENTE
                AND CLI.RUT_CLIENTE = P_RUT_CLIENTE;
            ELSE
                OPEN P_RESP FOR SELECT MC.ID_MEDIO_CONTACTO, MC.TIPO, MC.VALOR, MC.MEDIO_PREFERIDO, 
                to_char(MC.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                to_char(MC.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, 
                MC.ESTADO 
                FROM MEDIO_CONTACTO MC
                JOIN CLIENTE CLI ON CLI.ID_CLIENTE = MC.ID_CLIENTE
                AND CLI.RUT_CLIENTE = P_RUT_CLIENTE
                AND CLI.TIPO_CLIENTE = P_TIPO;
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_MEDIO_CONTACTO_CLIENTE_FULL;
    /*
     *    Este procedimiento obtiene el ID, TIPO y NOMBRE del local 
     *    </br>mediante el RUT de un cliente
     *    @param P_RUT_CLIENTE IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */   
    PROCEDURE PRC_GET_LOCAL_CLIENTE_LOV(P_RUT_CLIENTE IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT LO.ID_LOCAL, 'random' TIPO, LO.NOMBRE_FANTASIA
            FROM LOCAL LO
            JOIN CLIENTE CLI ON CLI.ID_CLIENTE = LO.ID_CLIENTE
            AND CLI.RUT_CLIENTE = P_RUT_CLIENTE;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_LOCAL_CLIENTE_LOV;

    /*
     *    Este procedimiento obtiene todos los datos del local, dirección y 
     *    </br>el ID, TIPO y NOMBRE de la cadena mediante el RUT del cliente.
     *    @param P_RUT_CLIENTE IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */   
    PROCEDURE PRC_GET_LOCAL_CLIENTE_FULL(P_RUT_CLIENTE IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT LO.ID_LOCAL, LO.NOMBRE_FANTASIA, TO_CHAR(LO.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECH_CREA_LOCAL, 
            TO_CHAR(LO.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECH_ACTU_LOCAL, LO.ESTADO ESTADO_LOCAL, DI.ID_DIRECCION, 
            DI.TIPO_DIRECCION, DI.OFICINA_DISTRIBUCION, DI.NUMERO_LOCAL, DI.NUMERO_CALLE, DI.ESTACIONAL, DI.DIRECCION, DI.COD_CIUDAD, 
            DI.CIUDAD, DI.COD_REGION, DI.REGION, DI.COD_COMUNA, DI.COMUNA, DI.UBICACION, DI.PAIS, 
            TO_CHAR(DI.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECH_CREAC_LOCAL, 
            TO_CHAR(DI.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECH_ACTU_DIREC, DI.LATITUD, DI.LONGITUD, DI.ESTADO ESTADO_DIREC
            FROM LOCAL LO
            JOIN CLIENTE CLI ON CLI.ID_CLIENTE = LO.ID_CLIENTE
            AND CLI.RUT_CLIENTE = P_RUT_CLIENTE
            LEFT JOIN DIRECCION DI ON DI.ID_DIRECCION = LO.ID_DIRECCION;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_LOCAL_CLIENTE_FULL;

    /*
     *    Este procedimiento obtiene todo la información del rubro mediante el RUT del cliente
     *    </br>y el tipo de cliente si se quire filtrar.
     *    @param P_RUT_CLIENTE IN VARCHAR
     *    @param P_TIPO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */   
    PROCEDURE PRC_GET_RUBRO_CLIENTE_FULL(P_RUT_CLIENTE IN VARCHAR,  P_TIPO IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            IF P_TIPO IS NULL THEN
                OPEN P_RESP FOR SELECT RC.ID_RUBRO_CLIENTE, RC.ACTIVIDAD_ECONOMICA, RC.RUBRO, RC.RUBRO_INTERNO_TBK, 
                TO_CHAR(RC.FECHA_INICIO_VIGENCIA,'yyyy-MM-dd HH24:Mi:ss') FECHA_INICIO_VIGENCIA, 
                TO_CHAR(RC.FECHA_FIN_VIGENCIA,'yyyy-MM-dd HH24:Mi:ss') FECHA_FIN_VIGENCIA, 
                TO_CHAR(RC.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                TO_CHAR(RC.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, RC.ESTADO
                FROM RUBRO_CLIENTE RC
                JOIN CLIENTE CLI ON CLI.ID_CLIENTE = RC.ID_CLIENTE
                AND CLI.RUT_CLIENTE = P_RUT_CLIENTE;
            ELSE
                OPEN P_RESP FOR SELECT RC.ID_RUBRO_CLIENTE, RC.ACTIVIDAD_ECONOMICA, RC.RUBRO, RC.RUBRO_INTERNO_TBK, 
                TO_CHAR(RC.FECHA_INICIO_VIGENCIA,'yyyy-MM-dd HH24:Mi:ss') FECHA_INICIO_VIGENCIA, 
                TO_CHAR(RC.FECHA_FIN_VIGENCIA,'yyyy-MM-dd HH24:Mi:ss') FECHA_FIN_VIGENCIA, 
                TO_CHAR(RC.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                TO_CHAR(RC.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, RC.ESTADO
                FROM RUBRO_CLIENTE RC
                JOIN CLIENTE CLI ON CLI.ID_CLIENTE = RC.ID_CLIENTE
                AND CLI.RUT_CLIENTE = P_RUT_CLIENTE AND CLI.TIPO_CLIENTE = P_TIPO;
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_RUBRO_CLIENTE_FULL;
    /*
     *    Este procedimiento obtiene todos los datos de la cuenta de abono mediante el RUT de un cliente
     *    </br>y el tipo de cliente si se quire filtrar.
     *    @param P_RUT_CLIENTE IN VARCHAR
     *    @param P_TIPO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */   
    PROCEDURE PRC_GET_CTA_ABONO_CLIENTE_FULL(P_RUT_CLIENTE IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT CB.ID_CUENTA_ABONO, CB.COD_SUCURSAL, CB.ID_BANCO, CB.BANCO, CB.PROPIEDAD_CUENTA, CB.RUT2_TIT_CTA_CTE, 
            CB.RUT_TIT_CTA_CTE, CB.NUM_CTA_CTE, CB.NOMBRE_TIT_CTA_CTE, CB.IND_BIPERSONAL, CB.MONEDA, CB.TIPO_CTA_ABONO, 
            TO_CHAR(CB.FECHA_CREACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION,
            TO_CHAR(CB.FECHA_ACTUALIZACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, CB.ESTADO 
            FROM CUENTA_ABONO CB
            JOIN CLIENTE CLI ON CLI.ID_CLIENTE = CB.ID_CLIENTE
            AND CLI.RUT_CLIENTE = P_RUT_CLIENTE;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_CTA_ABONO_CLIENTE_FULL; 
  
    /*
     *    Este procedimiento obtiene toda la información del medio pago marca mediante el RUT de un cliente.
     *    </br>y el tipo de cliente si se quire filtrar.
     *    @param P_RUT_CLIENTE IN VARCHAR
     *    @param P_TIPO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */   

    PROCEDURE PRC_GET_MEDIO_PAGO_MARCA_CLIENTE_FULL(P_RUT_CLIENTE IN VARCHAR, P_TIPO IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            IF P_TIPO IS NULL THEN 
                OPEN P_RESP FOR SELECT MP.ID_MEDIO_PAGO_MARCA, MP.MARCA, MP.TASA_COMISION,MP.TASA_TRANSACCION, MP.DESFACE_ABONO, 
                TO_CHAR(MP.FECHA_CREACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                TO_CHAR(MP.FECHA_ACTUALIZACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, MP.MEDIO_PAGO, 
                MP.MONEDA MONEDA_MEDIO_PAGO_MARCA, MP.MES_GRACIA, MP.ESTADO 
                FROM CLIENTE CLI
                JOIN CUENTA_ABONO CB ON CLI.RUT_CLIENTE = P_RUT_CLIENTE
                AND CLI.ID_CLIENTE = CB.ID_CLIENTE
                JOIN MEDIO_PAGO_MARCA MP ON CB.ID_CUENTA_ABONO = MP.ID_CUENTA_ABONO;
            ELSE
                OPEN P_RESP FOR SELECT MP.ID_MEDIO_PAGO_MARCA, MP.MARCA, MP.TASA_COMISION,MP.TASA_TRANSACCION, MP.DESFACE_ABONO, 
                TO_CHAR(MP.FECHA_CREACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                TO_CHAR(MP.FECHA_ACTUALIZACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, MP.MEDIO_PAGO, 
                MP.MONEDA MONEDA_MEDIO_PAGO_MARCA, MP.MES_GRACIA, MP.ESTADO 
                FROM CLIENTE CLI
                JOIN CUENTA_ABONO CB ON CLI.RUT_CLIENTE = P_RUT_CLIENTE
                AND CLI.ID_CLIENTE = CB.ID_CLIENTE AND CLI.TIPO_CLIENTE = P_TIPO
                JOIN MEDIO_PAGO_MARCA MP ON CB.ID_CUENTA_ABONO = MP.ID_CUENTA_ABONO;
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_MEDIO_PAGO_MARCA_CLIENTE_FULL;

    /*
     *    Este procedimiento obtiene toda la información del producto contratado mediante el ID de la cuenta de abono
     *    </br>y el tipo de cliente si se quire filtrar.
     *    @param P_ID_CUENTA_ABONO IN VARCHAR
     *    @param P_TIPO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */ 
    PROCEDURE PRC_GET_PROD_CONTRATADOS_CLIENTE_FULL(P_RUT_CLIENTE IN VARCHAR, P_TIPO IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            IF P_TIPO IS NULL THEN
                OPEN P_RESP FOR SELECT PC.ID_PRODUCTO_CONTRATADO, PC.NOMBRE_PRODUCTO, 
                TO_CHAR(PC.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                TO_CHAR(PC.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, PC.ESTADO,
                PC.TIPO_PRODUCTO, PC.MAX_NCUOTAS, PC.CANAL_OPERACION
                FROM CLIENTE CLI 
                JOIN PRODUCTO_CONTRATADO PC ON CLI.ID_CLIENTE = PC.ID_CLIENTE
                AND CLI.RUT_CLIENTE = P_RUT_CLIENTE;
            ELSE
                OPEN P_RESP FOR SELECT PC.ID_PRODUCTO_CONTRATADO, PC.NOMBRE_PRODUCTO, 
                TO_CHAR(PC.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                TO_CHAR(PC.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, PC.ESTADO,
                PC.TIPO_PRODUCTO, PC.MAX_NCUOTAS, PC.CANAL_OPERACION
                FROM CLIENTE CLI 
                JOIN PRODUCTO_CONTRATADO PC ON CLI.ID_CLIENTE = PC.ID_CLIENTE
                AND CLI.RUT_CLIENTE = P_RUT_CLIENTE 
                AND CLI.TIPO_CLIENTE = P_TIPO
                ;
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_PROD_CONTRATADOS_CLIENTE_FULL;
    /*
     *    Este procedimiento obtiene toda la información de los productos financieros mediante el rut del cliente,
     *    </br>el id de un producto canal y el tipo de cliente en caso de querer filtrarlo.
     *    @param P_RUT_CLIENTE IN VARCHAR
     *    @param P_TIPO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */   
    PROCEDURE PRC_GET_PROD_FINANCIEROS_CLIENTE_FULL(P_RUT_CLIENTE IN VARCHAR, P_ID_PROD_CANAL IN VARCHAR, P_TIPO IN VARCHAR, 
    P_RESP OUT SYS_REFCURSOR) 
        IS
            err_num number;
            err_msg varchar2(255);
        BEGIN
            IF P_TIPO IS NULL THEN 
                OPEN P_RESP FOR SELECT PC.ID_PRODUCTO_CONTRATADO, PC.NOMBRE_PRODUCTO, 
                TO_CHAR(PC.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                TO_CHAR(PC.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, 
                PC.TIPO_PRODUCTO, PC.MAX_NCUOTAS, PC.CANAL_OPERACION, PC.ESTADO
                FROM CLIENTE CLI
                JOIN PRODUCTO_CONTRATADO PC ON CLI.ID_CLIENTE = PC.ID_CLIENTE
                AND CLI.RUT_CLIENTE = P_RUT_CLIENTE
                JOIN PUNTO_VENTA_PRODUCTO_REL PR ON PC.ID_PRODUCTO_CONTRATADO = PR.ID_PRODUCTO_FINANCIERO
                AND PC.TIPO_PRODUCTO = C_PRODUCTO_FINACIERO
                AND PR.ID_PRODUCTO_CONTRATADO = P_ID_PROD_CANAL;
            ELSE
               OPEN P_RESP FOR SELECT PC.ID_PRODUCTO_CONTRATADO, PC.NOMBRE_PRODUCTO, 
                TO_CHAR(PC.FECHA_CREACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                TO_CHAR(PC.FECHA_ACTUALIZACION,'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, 
                PC.TIPO_PRODUCTO, PC.MAX_NCUOTAS, PC.CANAL_OPERACION, PC.ESTADO
                FROM CLIENTE CLI
                JOIN PRODUCTO_CONTRATADO PC ON CLI.ID_CLIENTE = PC.ID_CLIENTE
                AND CLI.RUT_CLIENTE = P_RUT_CLIENTE AND CLI.TIPO_CLIENTE = P_TIPO
                JOIN PUNTO_VENTA_PRODUCTO_REL PR ON PC.ID_PRODUCTO_CONTRATADO = PR.ID_PRODUCTO_FINANCIERO
                AND PC.TIPO_PRODUCTO = C_PRODUCTO_FINACIERO
                AND PR.ID_PRODUCTO_CONTRATADO = P_ID_PROD_CANAL;
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_PROD_FINANCIEROS_CLIENTE_FULL;
    /*
     *    Este procedimiento obtiene toda la información de los atributos producto mediante el rut del cliente
     *    </br>y el tipo de cliente en caso de querer filtrarlo.
     *    @param P_RUT_CLIENTE IN VARCHAR
     *    @param P_TIPO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */   
    PROCEDURE PRC_GET_ATRIBUTOS_PRODUCTO_CLIENTE_FULL(P_RUT_CLIENTE IN VARCHAR, P_TIPO IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            IF P_TIPO IS NULL THEN 
                OPEN P_RESP FOR SELECT AP.ID_ATRIBUTOS_PRODUCTO, AP.IND_LIQUIDACION, AP.IND_FACTURACION, AP.FORMATO_LIQUIDACION, AP.DIRECCION_URL,
                AP.CODIGO_MALL_WEB, AP.CODIGO_COMERCIO_DOLAR, AP.CODIGO_COMERCIO_PESO, AP.CODIGO_AMEX, AP.CODIGO_AMEX_DOLAR, 
                AP.IND_AUTORIZACION_INTERNET,AP.EMPLEADO, AP.DONACION, AP.VCB, TO_CHAR(AP.FECHA_ACT_VCB, 'yyyy-MM-dd HH24:Mi:ss') FECHA_ACT_VCB, 
                TO_CHAR(AP.FECHA_DESACT_VCB, 'yyyy-MM-dd HH24:Mi:ss') FECHA_DESACT_VCB, AP.VENTA_EXTRANJERA, AP.TRANSNACIONAL, AP.TIPO_CARTOLA, 
                AP.MAF_3DSECURE,AP.LLAVE_EECC, AP.TIPO_CAPTURA, AP.CONTACTLESS, 
                TO_CHAR(AP.FECHA_CONTACTLESS, 'yyyy-MM-dd HH24:Mi:ss') FECHA_CONTACTLESS,
                TO_CHAR(AP.FECHA_DESACT_CONTACTLESS, 'yyyy-MM-dd HH24:Mi:ss') FECHA_DESACT_CONTACTLESS, AP.LIQUIDACION_PARAMETRICA, AP.CBSP,
                TO_CHAR(AP.FECHA_CREACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                TO_CHAR(AP.FECHA_ACTUALIZACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, AP.ESTADO, AP.VENTA_SOLO_TC,
                AP.ADELANTAMIENTO_CUOTAS, AP.FECHA_INICIO_ADEL_CUOTA, AP.FECHA_FIN_ADEL_CUOTA
                FROM CLIENTE CLI
                JOIN RUBRO_CLIENTE RC ON RC.ID_CLIENTE = CLI.ID_CLIENTE
                JOIN ATRIBUTOS_PRODUCTO AP ON AP.ID_RUBRO_CLIENTE = RC.ID_RUBRO_CLIENTE
                AND CLI.RUT_CLIENTE = P_RUT_CLIENTE;
            ELSE
                OPEN P_RESP FOR SELECT AP.ID_ATRIBUTOS_PRODUCTO, AP.IND_LIQUIDACION, AP.IND_FACTURACION, AP.FORMATO_LIQUIDACION, AP.DIRECCION_URL,
                AP.CODIGO_MALL_WEB, AP.CODIGO_COMERCIO_DOLAR, AP.CODIGO_COMERCIO_PESO, AP.CODIGO_AMEX, AP.CODIGO_AMEX_DOLAR, 
                AP.IND_AUTORIZACION_INTERNET,AP.EMPLEADO, AP.DONACION, AP.VCB, TO_CHAR(AP.FECHA_ACT_VCB, 'yyyy-MM-dd HH24:Mi:ss') FECHA_ACT_VCB, 
                TO_CHAR(AP.FECHA_DESACT_VCB, 'yyyy-MM-dd HH24:Mi:ss') FECHA_DESACT_VCB, AP.VENTA_EXTRANJERA, AP.TRANSNACIONAL, AP.TIPO_CARTOLA, 
                AP.MAF_3DSECURE,AP.LLAVE_EECC, AP.TIPO_CAPTURA, AP.CONTACTLESS, 
                TO_CHAR(AP.FECHA_CONTACTLESS, 'yyyy-MM-dd HH24:Mi:ss') FECHA_CONTACTLESS,
                TO_CHAR(AP.FECHA_DESACT_CONTACTLESS, 'yyyy-MM-dd HH24:Mi:ss') FECHA_DESACT_CONTACTLESS, AP.LIQUIDACION_PARAMETRICA, AP.CBSP,
                TO_CHAR(AP.FECHA_CREACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
                TO_CHAR(AP.FECHA_ACTUALIZACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, AP.ESTADO, AP.VENTA_SOLO_TC,
                AP.ADELANTAMIENTO_CUOTAS, AP.FECHA_INICIO_ADEL_CUOTA, AP.FECHA_FIN_ADEL_CUOTA
                FROM CLIENTE CLI
                JOIN RUBRO_CLIENTE RC ON RC.ID_CLIENTE = CLI.ID_CLIENTE
                JOIN ATRIBUTOS_PRODUCTO AP ON AP.ID_RUBRO_CLIENTE = RC.ID_RUBRO_CLIENTE
                AND CLI.RUT_CLIENTE = P_RUT_CLIENTE AND CLI.TIPO_CLIENTE = P_TIPO;
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_ATRIBUTOS_PRODUCTO_CLIENTE_FULL;


    /*
     *    Este procedimiento obtiene el ID, TIPO y NOMBRE del comercio secundario asociado a un cliente mediante su RUT.
     *    @param P_RUT_CLIENTE IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */   
    PROCEDURE PRC_GET_COMERCIO_SECUNDARIO_CLIENTE_LOV(P_RUT_CLIENTE IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT CS.ID_COMERCIO_SECUNDARIO, CS.RAZON_SOCIAL, NULL NOMBRE
            FROM COMERCIO_SECUNDARIO CS
            JOIN CLIENTE CLI ON CLI.ID_CLIENTE = CS.ID_CLIENTE_PSP
            AND CLI.RUT_CLIENTE = P_RUT_CLIENTE;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_COMERCIO_SECUNDARIO_CLIENTE_LOV;
    /*
     *    Este procedimiento obtiene todos los datos del comercio secundario mediante el RUT del cliente.
     *    @param P_RUT_CLIENTE IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */   
    PROCEDURE PRC_GET_COMERCIO_SECUNDARIO_CLIENTE_FULL(P_RUT_CLIENTE IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT CS.ID_COMERCIO_SECUNDARIO, CS.RUT_COMERCIO_SECUNDARIO, CS.RAZON_SOCIAL, 
            TO_CHAR(CS.FECHA_CREACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
            TO_CHAR(CS.FECHA_ACTUALIZACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, CS.ESTADO, 
            TO_CHAR(CS.FECHA_CONTRATO, 'yyyy-MM-dd HH24:Mi:ss') FECHA_CONTRATO
            FROM COMERCIO_SECUNDARIO CS
            JOIN CLIENTE CLI ON CLI.ID_CLIENTE = CS.ID_CLIENTE_PSP
            AND CLI.RUT_CLIENTE = P_RUT_CLIENTE;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_COMERCIO_SECUNDARIO_CLIENTE_FULL;
    /*
     *    Este procedimiento obtiene todos los datos del producto_asociado mediante el id del comercio secundario.
     *    @param P_ID_COMERCIO_SECUNDARIO IN VARCHAR
     *    @param P_RESP OUT SYS_REFCURSOR   
     */   
    PROCEDURE PRC_GET_PROD_ASOC_FULL(P_ID_COMERCIO_SECUNDARIO IN VARCHAR, P_RESP OUT SYS_REFCURSOR) IS
        err_num number;
        err_msg varchar2(255);
        BEGIN
            OPEN P_RESP FOR SELECT PA.ID_PRODUCTO_ASOCIADO, TO_CHAR(PA.FECHA_HABILITACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_HABILITACION,
            TO_CHAR(PA.FECHA_DESHABILITACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_DESHABILITACION, 
            TO_CHAR(PA.FECHA_CREACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_CREACION, 
            TO_CHAR(PA.FECHA_ACTUALIZACION, 'yyyy-MM-dd HH24:Mi:ss') FECHA_ACTUALIZACION, PA.ESTADO
            FROM PRODUCTO_ASOCIADO PA
            JOIN COMERCIO_SECUNDARIO CS ON CS.ID_COMERCIO_SECUNDARIO = PA.ID_COMERCIO_SECUNDARIO
            AND CS.ID_COMERCIO_SECUNDARIO = P_ID_COMERCIO_SECUNDARIO;
        EXCEPTION
          WHEN OTHERS THEN
            err_num := SQLCODE;
            err_msg := SQLERRM;
            dbms_output.put_line('Error:' || TO_CHAR(err_num));
            dbms_output.put_line(err_msg);
    END PRC_GET_PROD_ASOC_FULL; 
    

END PKG_CONSULTAS_CANONICO;