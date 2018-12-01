
/***********************************I-DAT-JRR-LEG-0-30/11/2018****************************************/

INSERT INTO segu.tsubsistema ( codigo, nombre, fecha_reg, prefijo, estado_reg, nombre_carpeta, id_subsis_orig)
VALUES ('LEG', 'Módulo de Contratos', '2014-01-16', 'LG', 'activo', 'legal', NULL);


select pxp.f_insert_tgui ('SISTEMA DE CONTRATOS', '', 'LEG', 'si', NULL, '', 1, '', '', 'LEG');
select pxp.f_insert_testructura_gui ('LEG', 'SISTEMA');
----------------------------------
--COPY LINES TO SUBSYSTEM data.sql FILE  
---------------------------------

select wf.f_import_tproceso_macro ('insert','LEGAL', 'LEG', 'Registro de Contratos','si');
select wf.f_import_tcategoria_documento ('insert','legales', 'Legales');
select wf.f_import_tcategoria_documento ('insert','proceso', 'Proceso');
select wf.f_import_ttipo_proceso ('insert','CON',NULL,NULL,'LEGAL','Contrato','leg.vcontrato','','si','','','Registro
de Contratos Externos, Internos, Adquisiciones y
Personal','CON',NULL);
select wf.f_import_ttabla ('insert','CON','CON','contrato','Contrato
de cualquier Tipo','','maestro','',NULL,'id_contrato','DESC','','{
	btnReclamar: true,
	gruposBarraTareasDocumento: [{name:"legales",title:"Doc. Legales",grupo:1,height:0},
                            {name:"proceso",title:"Doc del Proceso",grupo:0,height:0}],
	estadoReclamar: "pendiente_asignacion",
    constructor: function(config){
    	console.log("hi");
		if (config.estado != "borrador") {
			this.rowExpander= new Ext.ux.grid.RowExpander({
			        tpl : new Ext.Template(
			            "<br>",
			            "<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Objeto:&nbsp;&nbsp;</b> {objeto}</p>",
			            "<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Solicitud:&nbsp;&nbsp;</b> {solicitud}</p>",
			            "<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Fecha Inicio:&nbsp;&nbsp;</b> {fecha_inicio:date(\"d/m/Y\")}</p>",
			            "<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Fecha Fin\":&nbsp;&nbsp;</b> {fecha_fin:date(\"d/m/Y\")}</p>",
			            "<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Monto:&nbsp;&nbsp;</b> {monto}</p>",
			            "<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Moneda:&nbsp;&nbsp;</b> {moneda}</p>",
			            "<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Conceptos:&nbsp;&nbsp;</b> {desc_ingas}</p>",
			            "<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Ordenes de Trabajo:&nbsp;&nbsp;</b> {desc_ot}</p><br>"
			        )
		    });
    
		    this.arrayDefaultColumHidden=	["estado","fecha_mod","usr_reg","usr_mod","estado_reg","fecha_reg","objeto","fecha_inicio",
						"fecha_fin","id_gestion","id_persona","id_institucion","observaciones","solicitud","monto","id_moneda",
						"fecha_elaboracion","plazo","tipo_plazo","id_cotizacion","periodicidad_pago","tiene_retencion","modo",
						"id_contrato_fk","id_concepto_ingas","id_orden_trabajo","cargo","lugar","forma_contratacion","modalidad",
						"representante_legal","rpc","mae"];
						
		}
		Phx.vista[config.clase_generada].superclass.constructor.call(this,config);
		if (this.config.estado == "borrador") {
		  this.construyeVariablesContratos();
		}

		if (this.config.estado == "finalizado") {
		  this.getBoton("sig_estado").setDisabled(true);
		}
		this.getBoton("btnReclamar").hide();
		if(this.config.estado == this.estadoReclamar){
			this.getBoton("btnReclamar").show();
		}
		
		//Definición de evento para mostrar/ocultar componentes en función del tipo de contratos
		//this.Cmp.tipo.on("select", function(c,r,i){
		//		if(this.Cmp.tipo.getValue() == "administrativo"){
		//			alert("administrativo");
		//		} else if(this.Cmp.tipo.getValue() == "administrativo_alquiler"){
		//			alert("administrativo_alquiler");
		//		} else if (this.Cmp.tipo.getValue() == "administrativo_internacional"){
		//			alert("administrativo_internacional");
		//		}
		//	},
		//this);
		
    },
    construyeVariablesContratos: function(){
		Phx.CP.loadingShow();
		Ext.Ajax.request({
                url: "../../sis_workflow/control/Tabla/cargarDatosTablaProceso",
                params: { "tipo_proceso": "CON", "tipo_estado":"finalizado" , "limit":"100","start":"0"},
                success: this.successCotratos,
                failure: this.conexionFailure,
                timeout: this.timeout,
                scope:   this
        });
    },
    successCotratos: function(resp){    	
        Phx.CP.loadingHide();
        var reg = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));        
	    if(reg.datos){
			this.ID_CONT = reg.datos[0].atributos.id_tabla
			this.Cmp.id_contrato_fk.store.baseParams.id_tabla = this.ID_CONT;
		 }else{
			alert("Error al cargar datos de contratos")
		}
     },
    agregarArgsExtraSubmit: function(){
		if (this.config.estado == "borrador") {			
		   if (this.Cmp.id_contrato_fk.getValue() == "" || this.Cmp.id_contrato_fk.getValue() == null || this.Cmp.id_contrato_fk.getValue() == undefined) {
			   delete this.argumentExtraSubmit.nro_tramite;
			 } else {
			   var recContrato = this.Cmp.id_contrato_fk.store.getById(this.Cmp.id_contrato_fk.getValue());
			   this.argumentExtraSubmit.nro_tramite = recContrato.data.nro_tramite;
		   }
		}
    },
    iniciarEventos: function(){
    	console.log(this.Cmp);
        if (this.config.estado == "registro") {
			this.Cmp.tipo_plazo.on("select",function(c,r,i){
				if (this.Cmp.tipo_plazo.getValue() == "fecha_fija") {
					this.mostrarComponente(this.Cmp.fecha_fin);
					this.Cmp.fecha_fin.reset();
					this.Cmp.fecha_fin.allowBlank = false;
					this.ocultarComponente(this.Cmp.plazo);
					this.Cmp.plazo.reset();
					this.Cmp.plazo.allowBlank = true;
				} else if (this.Cmp.tipo_plazo.getValue() == "tiempo_indefinido") {
					this.ocultarComponente(this.Cmp.fecha_fin);
					this.Cmp.fecha_fin.reset();
					this.Cmp.fecha_fin.allowBlank = true;
					this.ocultarComponente(this.Cmp.plazo);
					this.Cmp.plazo.reset();
					this.Cmp.plazo.allowBlank = true;
				} else {
					this.ocultarComponente(this.Cmp.fecha_fin);
					this.Cmp.fecha_fin.reset();
					this.Cmp.fecha_fin.allowBlank = true;
					this.mostrarComponente(this.Cmp.plazo);
					this.Cmp.plazo.reset();
					this.Cmp.plazo.allowBlank = false;
				}


			},this);
		} else if (this.config.estado == "borrador") {
			this.Cmp.modo.on("select",function(c,r,i){
				if (this.Cmp.modo.getValue() == "adenda") {
					this.mostrarComponente(this.Cmp.id_contrato_fk);
					this.Cmp.id_contrato_fk.reset();
					this.Cmp.id_contrato_fk.allowBlank = false;
				} else {
					this.ocultarComponente(this.Cmp.id_contrato_fk);
					this.Cmp.id_contrato_fk.reset();
					this.Cmp.id_contrato_fk.allowBlank = true;
				}

			},this);

		}
   },
   onSubmit: function(o, x, force) {
   		var error = false;
   		if (this.Cmp.fecha_fin) {
   			if (this.Cmp.fecha_fin.getValue()) {
   				if (this.Cmp.fecha_fin.getValue() < this.Cmp.fecha_inicio.getValue()) {
   					error = true;
   				}	
   			}
   		}
   		if (error) {
   			alert("La fecha de finalización del contrato no puede ser menor a la fecha de inicio");
   		} else {
   			Phx.vista[this.clase_generada].superclass.onSubmit.call(this,o, x, force);
   		}
   }
}

','Contratos','','REGCONT','borrador','borrador');
select wf.f_import_ttabla ('insert','ANX','CON','anexo','Anexos del contrato como ser Boletas de Garantías, Adendas, Memorandums, etc.','','detalle','south','CON','id_anexo','ASC','id_contrato','',' ','','','borrador','borrador');
select wf.f_import_ttipo_estado ('insert','borrador','CON','Solicitados','si','no','no','ninguno','','ninguno','','','no','no',NULL,'<font
color="99CC00" size="5"><font
size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario
:<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en
estado<b>&nbsp;
{ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp;
&nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp;
{DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp;
{ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Nuevo tramite {NUM_TRAMITE} en estado "{ESTADO_ACTUAL}"','','no','','','','','','','',NULL);
select wf.f_import_ttipo_estado ('delete','pendiente_asignacion','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_estado ('delete','registro','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_estado ('insert','finalizado','CON','Elaborados','no','si','si','ninguno','','ninguno','','','si','no',NULL,'<font
color="99CC00" size="5"><font
size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario
:<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en
estado<b>&nbsp;
{ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp;
&nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp;
{DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp;
{ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Nuevo tramite {NUM_TRAMITE} en estado "{ESTADO_ACTUAL}"','','no','','','','','','','','borrador');
select wf.f_import_ttipo_estado ('delete','anulado','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_estado ('delete','firma_gerente','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_estado ('delete','firma_contraparte','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_estado ('delete','digitalizacion','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_estado ('insert','vobo_abogado','CON','Visto bueno abogado','no','no','no','listado','','ninguno','','','si','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Nuevo tramite {NUM_TRAMITE} en estado "{ESTADO_ACTUAL}"','','no','','','','','','','','borrador');
select wf.f_import_ttipo_estado ('insert','vobo_jefe_legal','CON','Firma jefe legal','no','no','no','listado','','ninguno','','','si','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Nuevo tramite {NUM_TRAMITE} en estado "{ESTADO_ACTUAL}"','','no','','','','','','','',NULL);
select wf.f_import_ttipo_estado ('delete','vobo_rpc','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_estado ('delete','vobo_gaf','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_estado ('delete','contraparte_regional','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_estado ('delete','revision','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_estado ('delete','archivo_legal','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_estado ('delete','vobo_comercial','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_estado ('insert','vobo_adqusiciones','CON','Visto bueno adquisiciones','no','no','no','segun_depto','','depto_listado','ADQ_DEPTO_SOL','','no','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','','','','vobo_abogado');
select wf.f_import_ttipo_estado ('delete','vobo_rc','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_estado ('insert','firmas','CON','Completado de firmas y digitalización','no','no','no','segun_depto','','depto_listado','','','no','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','','','',NULL);
select wf.f_import_ttipo_estado ('insert','custodia_fisica','CON','Custodia física de contrato','no','no','no','segun_depto','','depto_listado','','','no','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','','','',NULL);
select wf.f_import_ttipo_estado ('insert','asignacion','CON','Asignación de responsable legal','no','no','no','ninguno','','depto_listado','','','si','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','','','','borrador');
select wf.f_import_ttipo_estado ('insert','gs_firmas','CON','Completado de firmas y digitalización (GS)','no','no','no','listado','','ninguno','','','si','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','','','',NULL);
select wf.f_import_ttipo_estado ('insert','3ros_vb_abogado','CON','Visto bueno abogado (3ros)','no','no','no','segun_depto','','depto_listado','','','si','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','','','',NULL);
select wf.f_import_ttipo_estado ('insert','3ros_vb_jefe_legal','CON','Firma jefe legal (3ros)','no','no','no','listado','','ninguno','','','si','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','','','',NULL);
select wf.f_import_ttipo_estado ('insert','3ros_vb_tec_com','CON','Visto bueno técnico comercial (3ros)','no','no','no','listado','','ninguno','','','no','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','','','',NULL);
select wf.f_import_ttipo_estado ('insert','3ros_firmas_prov','CON','Firmas clientes y digitalización (3ros)','no','no','no','listado','','ninguno','','','no','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','','','',NULL);
select wf.f_import_ttipo_columna ('insert','tipo','CON','CON','varchar','Elija el Tipo de Contrato','30','','','','','','TextField','Tipo de Contrato','si','','{"config":{"emptyText":"Tipo...",
"typeAhead": false,       "triggerAction": "all",
"lazyRender":true,
"mode": "local",
"store":["administrativo","gestion_social","servicio_3ros"]}}',70,NULL);
select wf.f_import_ttipo_columna ('insert','objeto','CON','CON','text','','','','','','','','TextArea','Objeto del Contrato','no','','{bottom_filter: true}',90,NULL);
select wf.f_import_ttipo_columna ('insert','fecha_inicio','CON','CON','date','La fecha en la que empieza a correr el contrato','','','','','','','DateField','Fecha Inicio Estimada','no','','{"config":{format: "d/m/Y", renderer:function
(value,p,record){return value?value.dateFormat("d/m/Y"):""},
anchor : "50%"}}',170,NULL);
select wf.f_import_ttipo_columna ('insert','fecha_fin','CON','CON','date','Fecha en la que termina la validez del contrato. Dejar en blanco si no tiene fecha
final de validez','','','','','','','DateField','Fecha Fin Estimada','no','','{"config":{format:
"d/m/Y",
renderer:function (value,p,record){return value?value.dateFormat("d/m/Y"):""},
anchor:"50%"}}',180,NULL);
select wf.f_import_ttipo_columna ('insert','numero','CON','CON','varchar','Número de
contrato','','','','','','','TextField','Número de contrato','no','','{"config":{anchor:"80%", allowBlank:true},
bottom_filter: true}',130,NULL);
select wf.f_import_ttipo_columna ('insert','id_gestion','CON','CON','integer','Gestión en la que fue suscrito el contrato','','ges.gestion gestion integer','inner join param.tgestion ges on ges.id_gestion =
con.id_gestion','','{
       pfiltro : "ges.gestion",
type : "numeric"
}','gestion numeric','NumberField','Gestión','si','GESTION','{"config":{
  name : "id_gestion",
  origen : "GESTION",
  fieldLabel : "Gestion",
  allowBlank : false,
  gdisplayField : "gestion",//mapea al store del grid
  gwidth : 100,
  renderer : function (value, p, record){return String.format("{0}",
record.data["gestion"]);}
          }}',1,NULL);
select wf.f_import_ttipo_columna ('insert','id_persona','CON','CON','integer','Persona con la que se suscribe el contrato','','','','','','','NumberField','','si','','',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','id_institucion','CON','CON','integer','Institución con la que se suscribe el contrato','','','','','','','NumberField','','si','','',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','id_proveedor','CON','CON','integer','Proveedor con el que se
suscribe el contrato','','prov.desc_proveedor desc_proveedor varchar','left join param.vproveedor prov on
prov.id_proveedor = con.id_proveedor','','{pfiltro:"prov.desc_proveedor",type:"string"}','desc_proveedor string','NumberField','Proveedor','si','PROVEEDOR','{"config":{
                name:"id_proveedor",                
                origen:"PROVEEDOR",
                fieldLabel:"Proveedor",
                allowBlank:true,
                tinit:false,
                gwidth:200,                
                gdisplayField: "desc_proveedor"
             },
bottom_filter: true}',120,NULL);
select wf.f_import_ttipo_columna ('insert','observaciones','CON','CON','text','Observaciones a este Contrato','','','','','','','TextArea','','no','','',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','solicitud','CON','CON','text','Detalle de la solicitud para elaboración de contrato','','','','','','','TextArea','Solicitud','no','','',100,NULL);
select wf.f_import_ttipo_columna ('insert','monto','CON','CON','numeric','El monto del contrato por lo general debe ser el monto
total','18_2','','','','','','NumberField','Monto del contrato','no','','',150,NULL);
select wf.f_import_ttipo_columna ('insert','id_moneda','CON','CON','integer','','','mon.moneda moneda varchar','inner join param.tmoneda mon on mon.id_moneda =
con.id_moneda','','{
                pfiltro:"mon.moneda",
                type:"string"
            }','moneda string','NumberField','Moneda del contrato','si','MONEDA','{"config":{
               name:"id_moneda",
                origen:"MONEDA",
                 allowBlank:false,
                fieldLabel:"Moneda",
                gdisplayField:"moneda",//mapea al store del grid
                gwidth:50
             }}',140,NULL);
select wf.f_import_ttipo_columna ('insert','fecha_elaboracion','CON','CON','date','Fecha de Elaboración','','','','','','','DateField','Fecha de elaboración','no','','{"config":{renderer:function (value,p,record){return
value?value.dateFormat("d/m/Y"):""},
anchor:"50%",
format: "d/m/Y"}}',160,NULL);
select wf.f_import_ttipo_columna ('insert','plazo','CON','CON','integer','Plazo en Días','','','','','','','NumberField','','no','','{"config":{anchor:"80%"}}',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','tipo_plazo','CON','CON','varchar','Días hábiles o días calendario','','','','','','','string','','si','','{"config":{"emptyText":"Tipo...",
"typeAhead": false,       "triggerAction": "all",
anchor:"50%",
"lazyRender":true,
"mode": "local",
"store":["fecha_fija","tiempo_indefinido"]}}',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','id_cotizacion','CON','CON','integer','','','','','','','','NumberField','','no','','',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','periodicidad_pago','CON','CON','varchar','Periodicidad con la que se realizará los pagos al
proveedor','50','','','','','','TextField','Periodicidad Pago','si','','{"config":{"emptyText":"Period...",
"typeAhead": false,       "triggerAction": "all",
anchor:"50%",
"lazyRender":true,
"mode": "local",
"store":["mensual","bimestral","trimestral","anual","pago_unico","otro"]}}',190,NULL);
select wf.f_import_ttipo_columna ('insert','tiene_retencion','CON','CON','varchar','Si tiene retención de garantía','2','','','','','','TextField','','si','','{"config":{"emptyText":"Tiene...",
"typeAhead": false,       "triggerAction": "all",
anchor:"50%",
"lazyRender":true,
"mode": "local",
"store":["si","no"]}}',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','tipo','ANX','CON','varchar','Tipo del anexo ','30','','','','','','TextField','Tipo de Anexo','si','','{"config":
{
"typeAhead": false,
"gwidth":100, 
      		"triggerAction": "all",
"lazyRender":true,
"mode": "local",
"store":[
"Buena ejecucion de obra","Seriedad de prueba","Buen uso de anticipo","Garantia de funcionamiento de Maquinaria y Equipo"]}}',13,NULL);
select wf.f_import_ttipo_columna ('insert','descripcion','ANX','CON','varchar','Descripción del anexo registrado','1000','','','','','','TextArea','Descripción','no','','',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','fecha_desde','ANX','CON','date','Fecha inicial de la vigencia del anexo','','','','','','','DateField','Fecha Apertura','no','','{"config":{format: "d/m/Y",				renderer:function (value,p,record){return value?value.dateFormat("d/m/Y"):""},
anchor : "50%"}}',7,NULL);
select wf.f_import_ttipo_columna ('insert','fecha_hasta','ANX','CON','date','Fecha final de la vigencia del anexo','','','','','','','DateField','Fecha Vencimiento','no','','{"config":{format: "d/m/Y",				renderer:function (value,p,record){return value?value.dateFormat("d/m/Y"):""},
anchor : "50%"}}',8,NULL);
select wf.f_import_ttipo_columna ('insert','modo','CON','CON','varchar','Se refiere si será Contrato normal, adenda u otra modalidad','30','','','','','','TextField','Tipo','si','','{"config":{"emptyText":"Modo...",
"typeAhead": false,       		"triggerAction": "all",
"lazyRender":true,
"mode": "local",
"store":["contrato","adenda"]}}',220,NULL);
select wf.f_import_ttipo_columna ('insert','id_contrato_fk','CON','CON','integer','','','view.desc_contrato_fk desc_contrato_fk text','','',NULL,'desc_contrato_fk string','NumberField','','si','','{"config":{
				name: "id_contrato_fk",
				hiddenName: "id_contrato_fk",
				fieldLabel: "Contrato",
				typeAhead: false,
				forceSelection: false,
				allowBlank: true,
				disabled: false,
				emptyText: "Contratos...",
				store: new Ext.data.JsonStore({
					url: "../../sis_workflow/control/Tabla/listarTablaCombo",
					id: "id_contrato",
					root: "datos",
					sortInfo: {
						field: "id_contrato",
						direction: "ASC"
					},
					totalProperty: "total",
					fields: ["id_contrato", "numero", "tipo", "objeto", "estado", "desc_proveedor","monto","moneda","fecha_inicio","fecha_fin","nro_tramite","solicitud"],
					// turn on remote sorting
					remoteSort: true,
					baseParams: {par_filtro:"con.numero#con.tipo#con.monto#prov.desc_proveedor#con.objeto#con.monto", tipo_proceso:"CON",tipo_estado:"finalizado","id_tabla":"3"}
				}),
				valueField: "id_contrato",
				displayField: "numero",
				tpl: "<tpl for=\".\"><div class=\"x-combo-list-item\"><p> {desc_proveedor}</p><p>{solicitud}</p><p>Nro: <b>{numero}</b></p></div></tpl>",
				gdisplayField: "desc_contrato_fk",
				triggerAction: "all",
				lazyRender: true,
				mode: "remote",
				pageSize: 20,
				queryDelay: 200,
				listWidth:280,
				minChars: 2,
				gwidth: 100,
				anchor: "80%",
				renderer: function(value, p, record) {
					return String.format("{0}", record.data["desc_contrato_fk"]);
				}
				
			}}',221,NULL);
select wf.f_import_ttipo_columna ('insert','id_concepto_ingas','CON','CON','integer[]','Conceptos de Gasto','','view.desc_ingas desc_ingas text','inner join leg.vcontrato view on view.id_contrato = con.id_contrato','','','desc_ingas string','TextField','Concepto de Gasto','si','','			{"config":{
                name:"id_concepto_ingas",
                fieldLabel:"Conceptos Gasto",
                emptyText:"Conceptos de Gasto ...",
                store: new Ext.data.JsonStore({
					 url: "../../sis_parametros/control/ConceptoIngas/listarConceptoIngasMasPartida",
					 id: "id_concepto_ingas",
					 root: "datos",
					 sortInfo:{
						field: "desc_ingas",
						direction: "ASC"
                    },
                    totalProperty: "total",
                    fields: ["id_concepto_ingas","tipo","desc_ingas","movimiento","desc_partida","id_grupo_ots","filtro_ot","requiere_ot"],
                    remoteSort: true,
                    baseParams:{par_filtro:"desc_ingas#par.codigo#par.nombre_partida",movimiento:"gasto",autorizacion:"contrato"}
                    }),
                valueField: "id_concepto_ingas",
                displayField: "desc_ingas",
                gdisplayField:"desc_ingas",
                hiddenName: "id_concepto_ingas",
                forceSelection:true,
                typeAhead: false,
                triggerAction: "all",
                lazyRender:true,
                mode:"remote",
                pageSize:10,
                queryDelay:1000,
                listWidth:600,
                resizable:true,
                gwidth: 200,  
				enableMultiSelect:true,
                renderer:function(value, p, record){return String.format("{0}", record.data["desc_ingas"]);}
            }}',200,NULL);
select wf.f_import_ttipo_columna ('insert','id_orden_trabajo','CON','CON','integer[]','Ordenes de Trabajo','','view.desc_ot desc_ot text','','','','desc_ot string','TextField','','si','','			{"config":{
                name:"id_orden_trabajo",
                fieldLabel:"Ordenes de Trabajo",
                emptyText:"Ordenes de Trabajo ...",
                store: new Ext.data.JsonStore({
					 url: "../../sis_contabilidad/control/OrdenTrabajo/listarOrdenTrabajo",
					 id: "id_orden_trabajo",
					 root: "datos",
					 sortInfo:{
						field: "motivo_orden",
						direction: "ASC"
                    },
                    totalProperty: "total",
                    fields: ["id_orden_trabajo","motivo_orden","desc_orden"],
                    remoteSort: true,
                    baseParams:{par_filtro: "desc_orden#motivo_orden"}
                    }),
                valueField: "id_orden_trabajo",
                displayField: "desc_orden",
                gdisplayField:"desc_ot",
                hiddenName: "id_orden_trabajo",
                forceSelection:true,
                typeAhead: false,
                triggerAction: "all",
                lazyRender:true,
                mode:"remote",
                pageSize:10,
                queryDelay:1000,
                listWidth:600,
                resizable:true,
                gwidth: 200,  
				gwidth: 200,  
				enableMultiSelect:true,
                renderer:function(value, p, record){return String.format("{0}", record.data["desc_ot"]);}
            }}',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','cargo','CON','CON','varchar','Cargo','50','','','','','','TextField','','no','','',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','forma_contratacion','CON','CON','varchar','Forma de contratación','30','','','','','','TextField','','si','','{"config":{"emptyText":"Tipo...",
"typeAhead": false,       "triggerAction": "all",
anchor:"50%",
"lazyRender":true,
"mode": "local",
"store":["forma1","forma2","forma3"]}}',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','modalidad','CON','CON','varchar','Modalidad del contrato','30','','','','','','TextField','','si','','{"config":{"emptyText":"Tipo...",
"typeAhead": false,       "triggerAction": "all",
anchor:"50%",
"lazyRender":true,
"mode": "local",
"store":["modalidad1","modalidad2"]}}',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','representante_legal','CON','CON','varchar','Representante Legal','100','','','','','','TextField','','no','','',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','rpc','CON','CON','varchar','RPC','100','','','','','','TextField','','no','','',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','mae','CON','CON','varchar','MAE','100','','','','','','TextField','','no','','',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','contrato_adhesion','CON','CON','varchar','','2','','','','','','TextField','Adhesión','si','','{"config":{"emptyText":"Adhesion...",
"typeAhead": false,       "triggerAction": "all",
"lazyRender":true,
"mode": "local",
"store":["si","no"]}}',210,NULL);
select wf.f_import_ttipo_columna ('insert','id_abogado','CON','CON','integer','Abogado Asignado','','desc_abogado desc_abogado text','','','','desc_abogado string','NumberField','Abogado','si','FUNCIONARIO','{"config":{
       		    name:"id_abogado",
       		     hiddenName: "id_abogado",
   				origen:"FUNCIONARIO",
   				fieldLabel:"Abogado",
   				allowBlank:false,
                gwidth:200,
   				valueField: "id_funcionario",
   			    gdisplayField: "desc_abogado",   			   
      			renderer:function(value, p, record){return String.format("{0}", record.data["desc_abogado"]);}
       	     }}



',110,NULL);
select wf.f_import_ttipo_columna ('insert','id_lugar','CON','CON','integer','Lugar en el que firmará el proveedor','','lug.nombre nombre_lugar varchar','left join param.tlugar lug on lug.id_lugar = con.id_lugar','','{
                pfiltro:"lug.nombre",
                type:"string"
            }','nombre_lugar string','TextField','','si','','{
			config:{
				name: "id_lugar",				
				allowBlank: false,
				emptyText:"Lugar...",
                                                                forceSelection:true,
				store:new Ext.data.JsonStore(
				{
					url: "../../sis_parametros/control/Lugar/listarLugar",
					id: "id_lugar",
					root: "datos",
					sortInfo:{
						field: "nombre",
						direction: "ASC"
					},
					totalProperty: "total",
					fields: ["id_lugar","id_lugar_fk","codigo","nombre","tipo","sw_municipio","sw_impuesto","codigo_largo"],
					// turn on remote sorting
					remoteSort: true,
					baseParams:{par_filtro:"nombre",tipo:"departamento"}
				}),
				valueField: "id_lugar",
				displayField: "nombre",
				gdisplayField:"nombre_lugar",
				hiddenName: "id_lugar",
    			triggerAction: "all",
    			lazyRender:true,
				mode:"remote",
				pageSize:50,
				queryDelay:500,
				anchor:"100%",
				gwidth:220,
				minChars:2,
				renderer:function (value, p, record){return String.format("{0}", record.data["lugar"]);}
				
			}
		}',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','id_funcionario','CON','CON','integer','Nombre del solicitante del contrato','','solicitante solicitante text','','','','solicitante string','NumberField','Solicitante','si','FUNCIONARIO','
{"config":{
       		    name:"id_funcionario",
       		     hiddenName: "id_funcionario",
   				origen:"FUNCIONARIO",
   				fieldLabel:"Solicitante",
   				allowBlank:false,
			
                gwidth:200,
   				valueField: "id_funcionario",
   			    gdisplayField: "solicitante",   			   
      			renderer:function(value, p, record){return String.format("{0}", record.data["solicitante"]);}
       	     }}',80,NULL);
select wf.f_import_ttipo_columna ('insert','rpc_regional','CON','CON','varchar','','','','','','','','TextField','','no','','',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','bancarizacion','CON','CON','varchar','Si se bancariza o no este contrato','2','','','','','','TextField','','si','','{"config":{"emptyText":"Banc...",
"typeAhead": false,       "triggerAction": "all",
"lazyRender":true,
"mode": "local",
"store":["si","no"]}}',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','tipo_monto','CON','CON','varchar','Si el monto del contrato es abierto (por tasa o precio unitario) o cerrado con un monto total fijo','','','','','','','TextField','','si','','{"config":{"emptyText":"Monto...",
"typeAhead": false,       "triggerAction": "all",
"lazyRender":true,
"mode": "local",
"store":["abierto","cerrado"]}}',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','resolucion_bancarizacion','CON','CON','varchar','Que resolución de bancarización aplica','','','','','','','TextField','','si','','{"config":{"emptyText":"Reso...",
"typeAhead": false,       "triggerAction": "all",
"lazyRender":true,
"mode": "local",
"store":["10-0017-15","10-0011-11"]}}',NULL,NULL);
select wf.f_import_ttipo_columna ('delete','id_agencia','CON','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('delete','tipo_agencia','CON','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('delete','moneda_restrictiva','CON','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('delete','cuenta_bancaria1','CON','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('delete','entidad_bancaria1','CON','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('delete','nombre_cuenta_bancaria1','CON','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('delete','cuenta_bancaria2','CON','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('delete','entidad_bancaria2','CON','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('delete','nombre_cuenta_bancaria2','CON','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('delete','formas_pago','CON','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('insert','banco','ANX','CON','varchar','','30','','','','','','TextField','Banco','no','','',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','tipo_boleta','ANX','CON','varchar','','20','','','','','','TextField','Tipo Boleta','si','','{"config":{"emptyText":"tipo...",
"typeAhead": false,       		"triggerAction": "all",
"lazyRender":true,
"mode": "local",
"store":["boleta","poliza"]}}',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','moneda','ANX','CON','varchar','','3','','','','','','TextField','Moneda','no','','',NULL,NULL);
select wf.f_import_ttipo_columna ('insert','monto','ANX','CON','numeric','','','','','','','','NumberField','Monto','no','','',9,NULL);
select wf.f_import_ttipo_columna ('delete','tipo_garantia','ANX','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('insert','tipo_garantia','ANX','CON','varchar','','30','','','','','','TextField','Tipo de Garantia','si','','{"config":
{
"typeAhead": false,       		"triggerAction": "all",
"lazyRender":true,
"mode": "local",
"store":["emitidos","recibidos","otros"]}}',4,NULL);
select wf.f_import_ttipo_columna ('insert','tipo_documento','ANX','CON','varchar','','30','','','','','','TextField','Tipo de Documento','si','','{"config":
{
"typeAhead": false,       		"triggerAction": "all",
"lazyRender":true,
"mode": "local",
"store":["Garantias Bancarias","Poliza de seguro","Fianza Bancaria","Causion","Carta de Credito Standy"]}}',3,NULL);
select wf.f_import_ttipo_columna ('insert','nro_documento','ANX','CON','varchar','','30','','','','','','TextField','Nro de Documento','no','','',5,NULL);
select wf.f_import_ttipo_columna ('delete','nro_documento','ANX','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('insert','fecha_proceso_cierre','ANX','CON','date','','','','','','','','DateField','Inicio de Proceso de Cierre','no','','{"config":{format: "d/m/Y",				renderer:function (value,p,record){return value?value.dateFormat("d/m/Y"):""},
anchor : "50%"}}',6,NULL);
select wf.f_import_ttipo_columna ('insert','otorgante','ANX','CON','varchar','','50','','','','','','TextField','Otorgante','no','','',10,NULL);
select wf.f_import_ttipo_columna ('insert','beneficiario','ANX','CON','varchar','','50','','','','','','TextField','Beneficiario','no','','',11,NULL);
select wf.f_import_ttipo_columna ('insert','cuenta','ANX','CON','varchar','','50','','','','','','TextField','Por cuenta de','no','','',12,NULL);
select wf.f_import_ttipo_columna ('delete','gerencia','ANX','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('delete','para_garantizar','ANX','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('insert','garantizar_descripcion','ANX','CON','varchar','','100','','','','','','TextArea','Para garantizar descripcion','no','','',14,NULL);
select wf.f_import_ttipo_columna ('insert','observacion','ANX','CON','varchar','','200','','','','','','TextArea','Observaciones','no','','',15,NULL);
select wf.f_import_ttipo_columna ('delete','responsable','ANX','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('delete','id_persona','ANX','CON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
							NULL,NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_columna ('insert','id_uo','ANX','CON','integer','','','','','','','','NumberField','Gerencia','si','UO','{"config":
{
"mode":"remote",		              
"origen":"UO",                 
"gdisplayField": "nombre_unidad",
"baseParams":{gerencia:"si"}
},
"bottom_filter": true
}',1,NULL);
select wf.f_import_ttipo_columna ('insert','id_funcionario','ANX','CON','integer','','','','','','','','NumberField','Funcionario','si','','',2,NULL);
select wf.f_import_ttipo_columna ('insert','regularizado','CON','CON','varchar','Indicar si el contrato se está regularizando, saltará todos los estados y enviará a estado finalizado','2','','','','','','TextField','Regularizar?','si','','{"config":{"emptyText":"¿Regularizar?",
"typeAhead": false,
"triggerAction": "all",
anchor:"50%",
"lazyRender":true,
"mode": "local",
"listeners": {
    "afterrender": function(combo){
        combo.setValue("no");
    }
},
"store":["si","no"]}}',10,NULL);
select wf.f_import_ttipo_documento ('insert','CONTRATO','CON','Contrato','','','escaneado',0.00,NULL);
select wf.f_import_ttipo_documento ('delete','ADJ1','CON',NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_documento ('delete','ADJ2','CON',NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_documento ('delete','contrato_adhesion','CON',NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_documento ('delete','EPCONS','CON',NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_documento ('delete','PODRL','CON',NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_documento ('delete','CIREP','CON',NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_documento ('delete','NIT','CON',NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_documento ('delete','LICFUN','CON',NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_documento ('delete','REGFUN','CON',NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_documento ('delete','CERPODFUN','CON',NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_documento ('delete','BOLGAR','CON',NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_documento ('delete','CARCONT','CON',NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_documento ('delete','CERCUE','CON',NULL,NULL,NULL,NULL,NULL,NULL);
select wf.f_import_ttipo_documento ('insert','INFLEG','CON','Informe legal','','','escaneado',0.05,'{}');
select wf.f_import_tcolumna_estado ('insert','tipo','CON','CON','borrador','exigir',NULL);
select wf.f_import_tcolumna_estado ('delete','objeto','CON','CON','registro',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','numero','CON','CON','registro',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','solicitud','CON','CON','borrador','registrar',NULL);
select wf.f_import_tcolumna_estado ('insert','monto','CON','CON','borrador','exigir','');
select wf.f_import_tcolumna_estado ('insert','id_moneda','CON','CON','borrador','exigir','');
select wf.f_import_tcolumna_estado ('insert','id_proveedor','CON','CON','borrador','exigir','');
select wf.f_import_tcolumna_estado ('insert','id_gestion','CON','CON','borrador','exigir','');
select wf.f_import_tcolumna_estado ('delete','objeto','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','fecha_inicio','CON','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('insert','fecha_fin','CON','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('delete','numero','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','id_persona','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','id_institucion','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','observaciones','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','fecha_elaboracion','CON','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('delete','plazo','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','tipo_plazo','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','fecha_inicio','CON','CON','registro',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','fecha_elaboracion','CON','CON','registro',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','plazo','CON','CON','registro',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','tipo_plazo','CON','CON','registro',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','periodicidad_pago','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','periodicidad_pago','CON','CON','registro',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','tiene_retencion','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','tiene_retencion','CON','CON','registro',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','fecha_fin','CON','CON','registro',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','observaciones','CON','CON','registro',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','monto','CON','CON','registro',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','tipo','ANX','CON','borrador','exigir','');
select wf.f_import_tcolumna_estado ('delete','descripcion','ANX','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','fecha_desde','ANX','CON','borrador','exigir','');
select wf.f_import_tcolumna_estado ('insert','fecha_hasta','ANX','CON','borrador','exigir','');
select wf.f_import_tcolumna_estado ('insert','modo','CON','CON','borrador','exigir','');
select wf.f_import_tcolumna_estado ('insert','id_concepto_ingas','CON','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('delete','id_orden_trabajo','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','id_lugar','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','id_lugar','CON','CON','registro',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','id_contrato_fk','CON','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('insert','contrato_adhesion','CON','CON','borrador','exigir','');
select wf.f_import_tcolumna_estado ('delete','contrato_adhesion','CON','CON','registro',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','objeto','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','observaciones','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','objeto','CON','CON','revision',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','numero','CON','CON','revision',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','fecha_inicio','CON','CON','revision',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','fecha_elaboracion','CON','CON','revision',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','plazo','CON','CON','revision',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','tipo_plazo','CON','CON','revision',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','periodicidad_pago','CON','CON','revision',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','tiene_retencion','CON','CON','revision',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','fecha_fin','CON','CON','revision',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','observaciones','CON','CON','revision',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','monto','CON','CON','revision',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','id_lugar','CON','CON','revision',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','contrato_adhesion','CON','CON','revision',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','numero','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','fecha_inicio','CON','CON','finalizado','exigir','');
select wf.f_import_tcolumna_estado ('delete','fecha_elaboracion','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','tipo_plazo','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','periodicidad_pago','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','tiene_retencion','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','contrato_adhesion','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','id_abogado','CON','CON','revision',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','id_abogado','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','id_proveedor','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','id_funcionario','CON','CON','borrador','exigir','');
select wf.f_import_tcolumna_estado ('insert','fecha_fin','CON','CON','finalizado','exigir','');
select wf.f_import_tcolumna_estado ('delete','fecha_elaboracion','CON','CON','firma_contraparte',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','numero','CON','CON','firma_contraparte',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','fecha_inicio','CON','CON','firma_contraparte',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','tipo_plazo','CON','CON','firma_contraparte',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','periodicidad_pago','CON','CON','firma_contraparte',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','tiene_retencion','CON','CON','firma_contraparte',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','id_lugar','CON','CON','firma_contraparte',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','fecha_fin','CON','CON','firma_contraparte',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','bancarizacion','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','monto','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','tipo_monto','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','resolucion_bancarizacion','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','id_funcionario','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','id_agencia','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','tipo_agencia','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','formas_pago','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','id_abogado','CON','CON','asignacion',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','id_abogado','CON','CON','vobo_abogado',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','id_abogado','CON','CON','asignacion','exigir','');
select wf.f_import_tcolumna_estado ('delete','objeto','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','objeto','CON','CON','vobo_abogado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','fecha_elaboracion','CON','CON','vobo_abogado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','periodicidad_pago','CON','CON','vobo_abogado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','periodicidad_pago','CON','CON','custodia_fisica',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','fecha_elaboracion','CON','CON','custodia_fisica',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','numero','CON','CON','vobo_abogado','exigir','');
select wf.f_import_tcolumna_estado ('delete','fecha_inicio','CON','CON','custodia_fisica',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','monto','CON','CON','asignacion',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','monto','CON','CON','custodia_fisica',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','objeto','CON','CON','vobo_jefe_legal',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','objeto','CON','CON','asignacion',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','tipo_garantia','ANX','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','tipo_garantia','ANX','CON','borrador','exigir','');
select wf.f_import_tcolumna_estado ('insert','nro_documento','ANX','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('insert','fecha_proceso_cierre','ANX','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('insert','otorgante','ANX','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('insert','beneficiario','ANX','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('insert','cuenta','ANX','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('delete','gerencia','ANX','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','garantizar_descripcion','ANX','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('delete','para_garantizar','ANX','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','observacion','ANX','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('delete','responsable','ANX','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','id_persona','ANX','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','id_uo','ANX','CON','borrador','exigir','');
select wf.f_import_tcolumna_estado ('insert','id_funcionario','ANX','CON','borrador','exigir','');
select wf.f_import_tcolumna_estado ('insert','monto','ANX','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('delete','id_moneda','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','objeto','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','objeto','CON','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('insert','fecha_inicio','CON','CON','firmas','exigir','');
select wf.f_import_tcolumna_estado ('delete','fecha_elaboracion','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','fecha_elaboracion','CON','CON','firmas','exigir','');
select wf.f_import_tcolumna_estado ('insert','periodicidad_pago','CON','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('insert','periodicidad_pago','CON','CON','finalizado','exigir','');
select wf.f_import_tcolumna_estado ('insert','periodicidad_pago','CON','CON','firmas','exigir','');
select wf.f_import_tcolumna_estado ('delete','id_concepto_ingas','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','fecha_fin','CON','CON','firmas','exigir','');
select wf.f_import_tcolumna_estado ('delete','solicitud','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','modo','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','tipo','CON','CON','finalizado',NULL,NULL);
select wf.f_import_tcolumna_estado ('delete','numero','CON','CON','borrador',NULL,NULL);
select wf.f_import_tcolumna_estado ('insert','id_abogado','CON','CON','finalizado','exigir','');
select wf.f_import_tcolumna_estado ('insert','numero','CON','CON','finalizado','exigir','');
select wf.f_import_tcolumna_estado ('insert','fecha_elaboracion','CON','CON','finalizado','exigir','');
select wf.f_import_tcolumna_estado ('insert','regularizado','CON','CON','borrador','exigir','');
select wf.f_import_tcolumna_estado ('insert','numero','CON','CON','borrador','registrar','');
select wf.f_import_tcolumna_estado ('insert','objeto','CON','CON','finalizado','exigir','');
select wf.f_import_testructura_estado ('delete','pendiente_asignacion','registro','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','digitalizacion','finalizado','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','vobo_abogado','vobo_jefe_legal','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','vobo_jefe_legal','vobo_rpc','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','vobo_rpc','vobo_gaf','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','vobo_gaf','firma_gerente','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','contraparte_regional','vobo_abogado','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','firma_contraparte','vobo_jefe_legal','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','registro','firma_contraparte','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','revision','pendiente_asignacion','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','revision','finalizado','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','firma_contraparte','vobo_rpc','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','firma_gerente','digitalizacion','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','borrador','vobo_comercial','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','registro','vobo_rpc','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','firma_gerente','firma_contraparte','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','firma_contraparte','archivo_legal','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','archivo_legal','finalizado','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','registro','vobo_gaf','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','vobo_comercial','pendiente_asignacion','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','registro','firma_gerente','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','firma_contraparte','firma_gerente','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','vobo_jefe_legal','vobo_gaf','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','firma_contraparte','vobo_gaf','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','borrador','pendiente_asignacion','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','borrador','revision','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','digitalizacion','firma_contraparte','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','borrador','vobo_adqusiciones','CON',NULL,NULL);
select wf.f_import_testructura_estado ('insert','vobo_adqusiciones','vobo_abogado','CON',1,'');
select wf.f_import_testructura_estado ('insert','vobo_abogado','vobo_adqusiciones','CON',1,'');
select wf.f_import_testructura_estado ('delete','vobo_abogado','vobo_abogado','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','vobo_abogado','vobo_jefe_legal','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','vobo_jefe_legal','vobo_rc','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','vobo_rc','firmas','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','vobo_rc','digitalizacion','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','digitalizacion','custodia_fisica','CON',NULL,NULL);
select wf.f_import_testructura_estado ('insert','custodia_fisica','finalizado','CON',1,'');
select wf.f_import_testructura_estado ('insert','borrador','asignacion','CON',1,'"{$tabla.regularizado}"="no" AND "{$tabla.tipo}"="administrativo"');
select wf.f_import_testructura_estado ('insert','asignacion','vobo_abogado','CON',1,'');
select wf.f_import_testructura_estado ('delete','vobo_jefe_legal','firmas','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','firmas','digitalizacion','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','borrador','anulado','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','vobo_abogado','digitalizacion','CON',NULL,NULL);
select wf.f_import_testructura_estado ('insert','firmas','custodia_fisica','CON',1,'');
select wf.f_import_testructura_estado ('delete','vobo_abogado','custodia_fisica','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','borrador','finalizado','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','asignacion','finalizado','CON',NULL,NULL);
select wf.f_import_testructura_estado ('delete','vobo_abogado','firmas','CON',NULL,NULL);
select wf.f_import_testructura_estado ('insert','vobo_abogado','vobo_jefe_legal','CON',1,'');
select wf.f_import_testructura_estado ('insert','vobo_jefe_legal','firmas','CON',1,'');
select wf.f_import_testructura_estado ('insert','borrador','finalizado','CON',1,'"{$tabla.regularizado}"="si"');
select wf.f_import_testructura_estado ('insert','borrador','gs_firmas','CON',1,'"{$tabla.regularizado}"="no" AND "{$tabla.tipo}"="gestion_social"');
select wf.f_import_testructura_estado ('insert','gs_firmas','custodia_fisica','CON',1,'"{$tabla.tipo}"<>"gestion_social"');
select wf.f_import_testructura_estado ('insert','borrador','3ros_vb_abogado','CON',1,'"{$tabla.regularizado}"="no" AND "{$tabla.tipo}"="servicio_3ros"');
select wf.f_import_testructura_estado ('insert','3ros_vb_abogado','3ros_vb_tec_com','CON',1,'');
select wf.f_import_testructura_estado ('insert','3ros_vb_abogado','3ros_vb_jefe_legal','CON',1,'');
select wf.f_import_testructura_estado ('insert','3ros_vb_tec_com','3ros_vb_abogado','CON',1,'');
select wf.f_import_testructura_estado ('insert','3ros_vb_jefe_legal','3ros_firmas_prov','CON',1,'');
select wf.f_import_testructura_estado ('insert','3ros_firmas_prov','custodia_fisica','CON',1,'');
select wf.f_import_testructura_estado ('insert','gs_firmas','finalizado','CON',1,'"{$tabla.tipo}"="gestion_social"');
select wf.f_import_tfuncionario_tipo_estado ('insert','asignacion','CON',NULL,'LEG',NULL);
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_abogado','CON','5151087',NULL,NULL);
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_abogado','CON','4455805',NULL,NULL);
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_abogado','CON','1709607',NULL,NULL);
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_abogado','CON','4416096',NULL,NULL);
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_abogado','CON','4196397',NULL,NULL);
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_abogado','CON',NULL,NULL,NULL);
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_adqusiciones','CON',NULL,'ADQ-CENTRAL',NULL);
select wf.f_import_tfuncionario_tipo_estado ('insert','firmas','CON',NULL,'ADQ-CENTRAL',NULL);
select wf.f_import_tfuncionario_tipo_estado ('insert','custodia_fisica','CON',NULL,'LEG',NULL);
select wf.f_import_tfuncionario_tipo_estado ('insert','firmas','CON',NULL,'ADQ-SC','');
select wf.f_import_tfuncionario_tipo_estado ('insert','firmas','CON',NULL,'ADQ-BNI','');
select wf.f_import_tfuncionario_tipo_estado ('insert','firmas','CON',NULL,'ADQ-LP','');
select wf.f_import_tfuncionario_tipo_estado ('insert','firmas','CON',NULL,'ADQ-PTS','');
select wf.f_import_tfuncionario_tipo_estado ('insert','firmas','CON',NULL,'ADQ-OR','');
select wf.f_import_tfuncionario_tipo_estado ('insert','firmas','CON',NULL,'ADQ-CBA','');
select wf.f_import_tfuncionario_tipo_estado ('insert','firmas','CON',NULL,'ADQ-TRJ','');
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_adqusiciones','CON',NULL,'ADQ-TRJ','');
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_adqusiciones','CON',NULL,'ADQ-BNI','');
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_adqusiciones','CON',NULL,'ADQ-LP','');
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_adqusiciones','CON',NULL,'ADQ-OR','');
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_adqusiciones','CON',NULL,'ADQ-PTS','');
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_adqusiciones','CON',NULL,'ADQ-CBA','');
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_adqusiciones','CON',NULL,'ADQ-SC','');
select wf.f_import_tfuncionario_tipo_estado ('insert','vobo_jefe_legal','CON','1709607',NULL,'');
select wf.f_import_tfuncionario_tipo_estado ('insert','gs_firmas','CON','1709607',NULL,'');
select wf.f_import_tfuncionario_tipo_estado ('insert','3ros_vb_abogado','CON',NULL,'LEG','');
select wf.f_import_tfuncionario_tipo_estado ('insert','3ros_vb_jefe_legal','CON','1709607',NULL,'');
select wf.f_import_tfuncionario_tipo_estado ('insert','3ros_vb_tec_com','CON','5189324',NULL,'');
select wf.f_import_tfuncionario_tipo_estado ('insert','3ros_vb_tec_com','CON','3150751',NULL,'');
select wf.f_import_tfuncionario_tipo_estado ('insert','3ros_firmas_prov','CON','5189324',NULL,'');
select wf.f_import_tfuncionario_tipo_estado ('insert','3ros_firmas_prov','CON','3150751',NULL,'');
select wf.f_import_tfuncionario_tipo_estado ('insert','3ros_vb_tec_com','CON','5319494',NULL,'');
select wf.f_import_tfuncionario_tipo_estado ('insert','custodia_fisica','CON',NULL,'VEN','');
----------------------------------
--COPY LINES TO SUBSYSTEM dependencies.sql FILE  
---------------------------------

select wf.f_import_ttipo_documento_estado ('delete','CONTRATO','CON','borrador','CON',NULL,NULL,NULL);
select wf.f_import_ttipo_documento_estado ('delete','CONTRATO','CON','finalizado','CON',NULL,NULL,NULL);
select wf.f_import_ttipo_documento_estado ('insert','CONTRATO','CON','borrador','CON','crear','superior','');
select wf.f_import_ttipo_documento_estado ('delete','CONTRATO','CON','digitalizacion','CON',NULL,NULL,NULL);
select wf.f_import_ttipo_documento_estado ('insert','CONTRATO','CON','custodia_fisica','CON','exigir','superior','');
select wf.f_import_ttipo_documento_estado ('insert','INFLEG','CON','borrador','CON','crear','superior','');
select wf.f_import_ttipo_documento_estado ('insert','INFLEG','CON','custodia_fisica','CON','exigir','superior','"{$tabla.tipo}" not in ("gestion_social","servicio_3ros")');
select wf.f_import_ttipo_documento_estado ('delete','CONTRATO','CON','finalizado','CON',NULL,NULL,NULL);
select wf.f_import_ttipo_documento_estado ('delete','CONTRATO','CON','borrador','CON',NULL,NULL,NULL);
select wf.f_import_ttipo_documento_estado ('delete','INFLEG','CON','finalizado','CON',NULL,NULL,NULL);
select wf.f_import_ttipo_documento_estado ('insert','CONTRATO','CON','finalizado','CON','exigir','superior','"{$tabla.regularizado}"="si"');
select wf.f_import_ttipo_documento_estado ('insert','CONTRATO','CON','gs_firmas','CON','exigir','superior','');
select wf.f_import_ttipo_proceso_origen ('insert','CON','LEGAL','COT','contrato_pendiente','obligatorio','adq.f_tiene_contrato');
select wf.f_import_ttipo_estado_rol ('delete','CON','asignacion','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','borrador','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('insert','CON','asignacion','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_abogado','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_abogado','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_jefe_legal','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_jefe_legal','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','custodia_fisica','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','custodia_fisica','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','custodia_fisica','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','custodia_fisica','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('insert','CON','custodia_fisica','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('insert','CON','custodia_fisica','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','ADQ - Solicitud de Compra');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','ADQ - Solicitud de Compra');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG -  Solicitante');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG -  Solicitante');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','ADQ - Solicitud de Compra');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_jefe_legal','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_jefe_legal','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','finalizado','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG -  Solicitante');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','ADQ - Solicitud de Compra');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_adqusiciones','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('insert','CON','vobo_adqusiciones','LEG -  Solicitante');
select wf.f_import_ttipo_estado_rol ('insert','CON','vobo_adqusiciones','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('insert','CON','vobo_adqusiciones','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('insert','CON','vobo_adqusiciones','ADQ - Solicitud de Compra');
select wf.f_import_ttipo_estado_rol ('delete','CON','finalizado','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','finalizado','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('insert','CON','vobo_abogado','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('insert','CON','vobo_abogado','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','finalizado','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','finalizado','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_jefe_legal','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_jefe_legal','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_jefe_legal','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('delete','CON','vobo_jefe_legal','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('insert','CON','vobo_jefe_legal','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('insert','CON','vobo_jefe_legal','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('insert','CON','borrador','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('insert','CON','borrador','LEG - Abogado');
select wf.f_import_ttipo_estado_rol ('insert','CON','finalizado','LEG - Responsable');
select wf.f_import_ttipo_estado_rol ('insert','CON','finalizado','LEG - Abogado');

select
	*
from
	pxp.f_intermediario_ime(
		1,
		null,
		null::varchar,
		'ik70t40gvf1qonpgajqrtdc9t5',
		3135,
		'172.18.79.119',
		'99:99:99:99:99:99',
		'wf.ft_tabla_ime',
		'WF_EJSCTABLA_PRO',
		null,
		'no',
		null,
		array [ 'filtro',
		'ordenacion',
		'dir_ordenacion',
		'puntero',
		'cantidad',
		'_id_usuario_ai',
		'_nombre_usuario_ai',
		'nombre_tabla' ],
		array [ E' 0 = 0 ',
		E'',
		E'',
		E'',
		E'',
		E'NULL',
		E'NULL',
		E'contrato' ],
		array [ 'varchar',
		'varchar',
		'varchar',
		'integer',
		'integer',
		'int4',
		'varchar',
		'varchar' ],
		'',
		null,
		null
	);
	
	select
	*
from
	pxp.f_intermediario_ime(
		1,
		null,
		null::varchar,
		'ik70t40gvf1qonpgajqrtdc9t5',
		3135,
		'172.18.79.119',
		'99:99:99:99:99:99',
		'wf.ft_tabla_ime',
		'WF_EJSCTABLA_PRO',
		null,
		'no',
		null,
		array [ 'filtro',
		'ordenacion',
		'dir_ordenacion',
		'puntero',
		'cantidad',
		'_id_usuario_ai',
		'_nombre_usuario_ai',
		'nombre_tabla' ],
		array [ E' 0 = 0 ',
		E'',
		E'',
		E'',
		E'',
		E'NULL',
		E'NULL',
		E'anexo' ],
		array [ 'varchar',
		'varchar',
		'varchar',
		'integer',
		'integer',
		'int4',
		'varchar',
		'varchar' ],
		'',
		null,
		null
	);

/***********************************F-DAT-JRR-LEG-0-30/11/2018****************************************/
