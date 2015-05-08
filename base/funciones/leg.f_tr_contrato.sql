CREATE OR REPLACE FUNCTION leg.f_tr_contrato (
)
RETURNS trigger AS
$body$
DECLARE
  v_cotizacion		record;
  v_id_tipo_estado_siguiente	integer[];
  v_id_estado_registro	integer;
  v_codigo_estado_siguiente	varchar;
  v_id_tipo_estado			integer;
  v_id_funcionario			integer;
  v_id_usuario_reg			integer;
  v_id_depto				integer;
  v_codigo_estado			varchar;
  v_id_estado_wf_ant		integer; 
  v_id_estado_wf			integer;
  v_id_proceso_wf			integer;
  v_obs						text;
  v_id_estado_actual		integer;
  v_id_abogado				integer;
BEGIN
	IF TG_OP = 'UPDATE' THEN
    	if (OLD.estado != 'registro' and NEW.estado = 'registro') then
        	select e.id_funcionario into v_id_abogado
            from wf.testado_wf e
            where id_estado_wf = NEW.id_estado_wf;
            
            update leg.tcontrato
            set id_abogado= v_id_abogado
            where id_contrato = NEW.id_contrato; 
        end if;
        if (OLD.estado != 'finalizado' and NEW.estado = 'finalizado' and NEW.id_cotizacion is not null) then
            --obtener datos de la cotizacion
            select c.*,ewf.id_tipo_estado,ewf.id_funcionario,ewf.id_depto into v_cotizacion
            from adq.tcotizacion c
            inner join wf.testado_wf ewf on ewf.id_estado_wf = c.id_estado_wf
            where id_cotizacion = NEW.id_cotizacion;
                    
            
            --cambiar la cotizacion al estado siguiente
            SELECT  
                 ps_id_tipo_estado
            into
                    	
                v_id_tipo_estado_siguiente
                    
            FROM wf.f_obtener_estado_wf(
            v_cotizacion.id_proceso_wf,
             NULL,
             v_cotizacion.id_tipo_estado,
             'siguiente',
             NEW.id_usuario_mod);
             
             select
             te.codigo
            into
             v_codigo_estado_siguiente
            from wf.ttipo_estado te
            where te.id_tipo_estado = v_id_tipo_estado_siguiente[1];
             
             /*Registrar el estado de registro*/
            v_id_estado_registro =  wf.f_registra_estado_wf(v_id_tipo_estado_siguiente[1],   --p_id_tipo_estado_siguiente
                                                             v_cotizacion.id_funcionario, 
                                                             v_cotizacion.id_estado_wf,   --  p_id_estado_wf_anterior
                                                             v_cotizacion.id_proceso_wf,
                                                             NEW.id_usuario_mod,
                                                             NEW.id_usuario_ai,
                                                             NEW.usuario_ai,
                                                             v_cotizacion.id_depto,
                                                             'Finalización de registro de contrato');
            
            update adq.tcotizacion  c set 
             id_estado_wf =  v_id_estado_registro,
             estado = v_codigo_estado_siguiente,
             id_usuario_mod=NEW.id_usuario_mod,
             fecha_mod=now()
           where c.id_cotizacion  = NEW.id_cotizacion; 
             
        end if;
        
        if (OLD.estado != 'borrador' and NEW.estado = 'borrador' and  NEW.id_cotizacion is not null) then
            	
                select 
                  te.id_tipo_estado
                 into
                  v_id_tipo_estado
                 from wf.tproceso_wf pwf
                 inner join wf.ttipo_estado te on te.id_tipo_proceso = pwf.id_tipo_proceso
                 where pwf.id_proceso_wf = NEW.id_proceso_wf and te.codigo = 'anulado';
                 
                 IF v_id_tipo_estado is NULL  THEN             
                    raise exception 'No se parametrizo el estado "anulado" para el proceso';                 
                 END IF;
                 
                 select c.id_estado_wf, c.id_proceso_wf, ewf.obs into v_id_estado_wf,v_id_proceso_wf,v_obs
                 from  leg.tcontrato c
                 inner join wf.testado_wf ewf on ewf.id_estado_wf = c.id_estado_wf
                 where c.id_contrato=OLD.id_contrato;
                
                 
                 v_id_estado_actual =  wf.f_registra_estado_wf(v_id_tipo_estado, 
                                                           NULL, 
                                                           v_id_estado_wf, 
                                                           v_id_proceso_wf,
                                                            NEW.id_usuario_mod,
                                                            NEW.id_usuario_ai,
                                                            NEW.usuario_ai,
                                                           NULL,
                                                           v_obs);
                                                           
            update  leg.tcontrato  
            set estado = 'anulado',
            id_estado_wf =  v_id_estado_actual,
            id_usuario_mod = NEW.id_usuario_mod,
            fecha_mod=now()
            where id_contrato=NEW.id_contrato;
                                                          
    		  
            --obtener datos de la cotizacion
            select c.*,ewf.id_tipo_estado,ewf.id_funcionario,ewf.id_depto into v_cotizacion
            from adq.tcotizacion c
            inner join wf.testado_wf ewf on ewf.id_estado_wf = c.id_estado_wf
            where id_cotizacion = NEW.id_cotizacion;
            
            --cambiar la cotizacion al estado anterior
            SELECT  
               ps_id_tipo_estado,
               ps_id_funcionario,
               ps_id_usuario_reg,
               ps_id_depto,
               ps_codigo_estado,
               ps_id_estado_wf_ant
            into
               v_id_tipo_estado,
               v_id_funcionario,
               v_id_usuario_reg,
               v_id_depto,
               v_codigo_estado,
               v_id_estado_wf_ant 
            FROM wf.f_obtener_estado_ant_log_wf(v_cotizacion.id_estado_wf);
            
            v_id_estado_registro = wf.f_registra_estado_wf(
                              v_id_tipo_estado, 
                              v_id_funcionario, 
                              v_cotizacion.id_estado_wf, 
                              v_cotizacion.id_proceso_wf, 
                              NEW.id_usuario_mod,
                              NEW.id_usuario_ai,
                              NEW.usuario_ai,
                              v_id_depto,
                              v_obs);
            
            update adq.tcotizacion  c set 
             id_estado_wf =  v_id_estado_registro,
             estado = v_codigo_estado,
             id_usuario_mod=NEW.id_usuario_mod,
             fecha_mod=now()
           where c.id_cotizacion  = NEW.id_cotizacion;
           
        end if;
    END IF;
    RETURN NULL;
    
    

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;