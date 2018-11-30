--------------- SQL ---------------

CREATE OR REPLACE FUNCTION leg.f_contrato_tmp_wf (
)
RETURNS boolean AS
$body$
DECLARE
  v_r record;

  v_codigo_tipo_proceso varchar;
  v_id_proceso_macro	integer;

  v_num_tramite varchar;
  v_id_proceso_wf integer;
  v_id_estado_wf integer;
  --v_id_proceso_macro  integer;
  v_codigo_estado varchar;

  v_resp_doc boolean;
  
  v_id_tipo_estado integer;
  v_id_estado_actual integer;
BEGIN
  for v_r in (
  select c.id_contrato,
         c.id_gestion,
         c.numero,
         c.id_proceso_wf,
         c.id_estado_wf
  from leg.tcontrato c
  where c.solicitud = 'migrado')
  loop
    raise notice 'CONTRATO: %', v_r;
/*
    -- inciiar el tramite en el sistema de WF
    SELECT ps_num_tramite,
           ps_id_proceso_wf,
           ps_id_estado_wf,
           ps_codigo_estado
    into v_num_tramite,
         v_id_proceso_wf,
         v_id_estado_wf,
         v_codigo_estado
    FROM wf.f_inicia_tramite(1,
      NULL,
      '',
      v_r.id_gestion,
      'CON',
      314,
      NULL,
      'Contrato migrado - ID:' || v_r.id_contrato || ' COD:' || v_r.numero
      , '');

    -- UPDATE DATOS wf
    UPDATE leg.tcontrato
    SET id_proceso_wf = v_id_proceso_wf,
        id_estado_wf = v_id_estado_wf,
        estado = v_codigo_estado
    WHERE id_contrato = v_r.id_contrato;

    -- inserta documentos en estado borrador si estan configurados
    v_resp_doc =  wf.f_inserta_documento_wf(1, v_id_proceso_wf, v_id_estado_wf);

    -- verificar documentos
    v_resp_doc = wf.f_verifica_documento(1, v_id_estado_wf);
    --*/
    
     select
              te.id_tipo_estado
            into
              v_id_tipo_estado
            from wf.tproceso_wf pw
            inner join wf.ttipo_proceso tp on pw.id_tipo_proceso =
              tp.id_tipo_proceso
            inner join wf.ttipo_estado te on te.id_tipo_proceso =
              tp.id_tipo_proceso and te.codigo = 'finalizado'
            where pw.id_proceso_wf = v_r.id_proceso_wf;
                     
           IF v_id_tipo_estado is NULL THEN
              raise exception
                'El estado vbcajero para la solicitud de efectivo no esta parametrizado en el workflow'
                ;
           END IF;
  
           v_id_estado_actual =  wf.f_registra_estado_wf(v_id_tipo_estado,
                                                       314,
                                                       v_r.id_estado_wf,
                                                       v_r.id_proceso_wf,
                                                       1,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       'MIGRADO'
                                                         );


               -- actualiza estado en solicitud de efectivo
            update leg.tcontrato
            set id_estado_wf = v_id_estado_actual,
                estado = 'finalizado',
                estado_reg = 'activo'
            where id_contrato = v_r.id_contrato;
  end loop;
  return true;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;