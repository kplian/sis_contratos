CREATE OR REPLACE FUNCTION "leg"."ft_contrato_sel"(	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Contratos
 FUNCION: 		leg.ft_contrato_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'leg.tcontrato'
 AUTOR: 		 RCM
 FECHA:	        17/01/2015
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/

DECLARE

	v_consulta    		varchar;
	v_parametros  		record;
	v_nombre_funcion   	text;
	v_resp				varchar;
			    
BEGIN

	v_nombre_funcion = 'leg.ft_contrato_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'LEG_CONTRA_SEL'
 	#DESCRIPCION:	Consulta de la vista de contratos
 	#AUTOR:		RCM	
 	#FECHA:		17/01/2015   
	***********************************/

	if(p_transaccion='LEG_CONTRA_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						con.id_usuario_reg,
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
                        con.sujeto_contrato,
                        con.moneda,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod	
						from leg.vcontrato con
						inner join segu.tusuario usu1 on usu1.id_usuario = con.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = con.id_usuario_mod
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'LEG_CONTRA_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		RCM
 	#FECHA:		17/01/2015
	***********************************/

	elsif(p_transaccion='LEG_CONTRA_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_contrato)
					    from leg.vcontrato con
                        inner join segu.tusuario usu1 on usu1.id_usuario = con.id_usuario_reg
                        left join segu.tusuario usu2 on usu2.id_usuario = con.id_usuario_mod
					    where ';
			
			--Definicion de la respuesta		    
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;
					
	else
					     
		raise exception 'Transaccion inexistente';
					         
	end if;
					
EXCEPTION
					
	WHEN OTHERS THEN
			v_resp='';
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
			v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
			v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
			raise exception '%',v_resp;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
ALTER FUNCTION "adq"."ft_grupo_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
