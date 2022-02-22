/***********************************I-DEP-RCM-LEG-1-17/01/2015*****************************************/
CREATE VIEW leg.vcontrato (
    id_usuario_reg,
    id_usuario_mod,
    fecha_reg,
    fecha_mod,
    estado_reg,
    id_usuario_ai,
    usuario_ai,
    id_contrato,
    id_estado_wf,
    id_proceso_wf,
    estado,
    tipo,
    objeto,
    fecha_inicio,
    fecha_fin,
    numero,
    id_gestion,
    id_persona,
    id_institucion,
    id_proveedor,
    observaciones,
    solicitud,
    monto,
    id_moneda,
    fecha_elaboracion,
    plazo,
    tipo_plazo,
    id_cotizacion,
    sujeto_contrato,
    moneda,
    id_contrato_fk,
    desc_ingas,
    desc_ot,
    desc_contrato_fk,
    contrato_adhesion,
    id_lugar,
    lugar,
    id_funcionario,
    solicitante,
    id_abogado,
    desc_abogado,
    rpc_regional,
    regularizado)
AS
SELECT con.id_usuario_reg,
    con.id_usuario_mod,
    con.fecha_reg,
    con.fecha_mod,
    con.estado_reg,
    con.id_usuario_ai,
    con.usuario_ai,
    con.id_contrato,
    con.id_estado_wf,
    con.id_proceso_wf,
    con.estado,
    con.tipo,
    con.objeto,
    con.fecha_inicio,
    con.fecha_fin,
    con.numero,
    con.id_gestion,
    con.id_persona,
    con.id_institucion,
    con.id_proveedor,
    con.observaciones,
    con.solicitud,
    con.monto,
    con.id_moneda,
    con.fecha_elaboracion,
    con.plazo,
    con.tipo_plazo,
    con.id_cotizacion,
        CASE
            WHEN con.id_persona IS NOT NULL THEN per.nombre_completo1
            WHEN con.id_institucion IS NOT NULL THEN ins.nombre::text
            WHEN con.id_proveedor IS NOT NULL THEN pro.desc_proveedor::text
            ELSE 'S/N'::text
        END AS sujeto_contrato,
    mon.moneda,
    con.id_contrato_fk,
    (
    SELECT pxp.list(ci.desc_ingas::text) AS list
    FROM param.tconcepto_ingas ci
    WHERE ci.id_concepto_ingas = ANY (con.id_concepto_ingas)
    ) AS desc_ingas,
    (
    SELECT pxp.list(ot.desc_orden::text) AS list
    FROM conta.torden_trabajo ot
    WHERE ot.id_orden_trabajo = ANY (con.id_orden_trabajo)
    ) AS desc_ot,
        CASE
            WHEN fkcon.id_persona IS NOT NULL THEN (fkper.nombre_completo1 ||
                ' - '::text) || fkcon.numero::text
            WHEN fkcon.id_institucion IS NOT NULL THEN (fkins.nombre::text ||
                ' - '::text) || fkcon.numero::text
            WHEN fkcon.id_proveedor IS NOT NULL THEN
                (fkpro.desc_proveedor::text || ' - '::text) || fkcon.numero::text
            ELSE 'S/N - '::text || fkcon.numero::text
        END AS desc_contrato_fk,
    con.contrato_adhesion,
    con.id_lugar,
    lug.nombre AS lugar,
    con.id_funcionario,
    fun.desc_funcionario1 AS solicitante,
    con.id_abogado,
    abo.desc_funcionario1 AS desc_abogado,
    con.rpc_regional,
    con.regularizado
FROM leg.tcontrato con
     JOIN param.tmoneda mon ON mon.id_moneda = con.id_moneda
     LEFT JOIN segu.vpersona per ON per.id_persona = con.id_persona
     LEFT JOIN param.tinstitucion ins ON ins.id_institucion = con.id_institucion
     LEFT JOIN param.vproveedor pro ON pro.id_proveedor = con.id_proveedor
     LEFT JOIN leg.tcontrato fkcon ON fkcon.id_contrato = con.id_contrato_fk
     LEFT JOIN segu.vpersona fkper ON fkper.id_persona = fkcon.id_persona
     LEFT JOIN param.tinstitucion fkins ON fkins.id_institucion = fkcon.id_institucion
     LEFT JOIN param.vproveedor fkpro ON fkpro.id_proveedor = fkcon.id_proveedor
     LEFT JOIN param.tlugar lug ON lug.id_lugar = con.id_lugar
     LEFT JOIN orga.vfuncionario fun ON fun.id_funcionario = con.id_funcionario
     LEFT JOIN orga.vfuncionario abo ON abo.id_funcionario = con.id_abogado;

ALTER VIEW leg.vcontrato
  OWNER TO postgres;
/***********************************F-DEP-RCM-LEG-1-17/01/2015*****************************************/

/***********************************I-DEP-RCM-LEG-1-03/03/2015*****************************************/
CREATE TRIGGER tcontrato_tr BEFORE UPDATE 
ON leg.tcontrato FOR EACH ROW 
EXECUTE PROCEDURE leg.f_tr_contrato();
/***********************************F-DEP-RCM-LEG-1-03/03/2015*****************************************/