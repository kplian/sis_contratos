/*******************************
CONFIGURACION DEL FORMULARIO
********************************/
{
	btnReclamar: true,
	estadoReclamar: "pendiente_asignacion",
	swOT: false,
	arrConceptoIngas: [],

    constructor: function(config){
		Phx.vista[config.clase_generada].superclass.constructor.call(this,config);
		if (this.config.estado == "borrador") {
		  this.construyeVariablesContratos();
		}
		//Habilitar boton de Reclamación
		this.getBoton("btnReclamar").hide();
		if(this.config.estado == this.estadoReclamar){
			this.getBoton("btnReclamar").show();
		}
		
		//Crea combo de los tipos de documentos
		this.tbar.addField(new Ext.form.Label({name: 'label', text:'Documentos:', width: 80}));
		this.cmbTipoDoc = new Ext.form.ComboBox({
	        name: 'cmbTipoDoc',
	        fieldLabel: 'Documentos',
	        typeAhead: false,
	        forceSelection: true,
	        allowBlank: true,
	        emptyText: 'Documento...',
	        store: new Ext.data.JsonStore({
	            url: '../../sis_workflow/control/TipoDocumento/listarTipoDocumentoXTipoPRocesoEstado',
	            id: 'id_tipo_documento',
	            root: 'datos',
	            sortInfo: {
	                field: 'nombre',
	                direction: 'ASC'
	            },
	            totalProperty: 'total',
	            fields: ['id_tipo_documento','id_tipo_proceso','id_proceso_macro','nombre','codigo','descripcion','nombre_vista','nombre_archivo_plantilla','esquema_vista'],
	            // turn on remote sorting
	            remoteSort: true,
	            baseParams: {
	            	start: 0,
	            	limit: 10,
	            	id_tipo_proceso: this.config.configProceso[0].atributos.id_tipo_proceso,
	            	estado_desc: this.config.estado
	            }
	        }),
	        valueField: 'id_tipo_documento',
			displayField: 'nombre',
			hiddenName: 'cmbTipoDoc',
			forceSelection:true,
			typeAhead: false,
			triggerAction: 'all',
			lazyRender:true,
			mode:'remote',
			pageSize:10,
			queryDelay:1000,
			width:155,
			minChars:2
	    });
	    
	    this.cmbTipoDoc.store.on('exception', this.conexionFailure);
	    this.cmbTipoDoc.on('select',this.onDocumento,this);
		this.tbar.addField(this.cmbTipoDoc);
		

    },
    construyeVariablesContratos: function(){
		Phx.CP.loadingShow();
		Ext.Ajax.request({
                url: "../../sis_workflow/control/Tabla/cargarDatosTablaProceso",
                params: { "tipo_proceso": "CON", "tipo_estado":"finalizado" , "limit":"100","start":"0"},
                success: this.successContratos,
                failure: this.conexionFailure,
                timeout: this.timeout,
                scope: this
        });
    },
    successContratos: function(resp){
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
    	console.log(this.Cmp.id_orden_trabajo.internal);
		if (this.config.estado == "borrador") {
		   if (this.Cmp.id_contrato_fk.getValue() == "") {
			   delete this.argumentExtraSubmit.nro_tramite;
			 } else {
			   var recContrato = this.Cmp.id_contrato_fk.store.getById(this.Cmp.id_contrato_fk.getValue());
			   this.argumentExtraSubmit.nro_tramite = recContrato.data.nro_tramite;
		   }
		}
    },
    iniciarEventos: function(){

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
				this.ocultarComponente(this.Cmp.id_contrato_fk);
				this.Cmp.id_contrato_fk.reset();
				this.Cmp.id_contrato_fk.allowBlank = true;
				if (this.Cmp.modo.getValue() == "adenda") {
					this.mostrarComponente(this.Cmp.id_contrato_fk);
					this.Cmp.id_contrato_fk.reset();
					this.Cmp.id_contrato_fk.allowBlank = false;
				}

			},this);

		}
		
		//Evento para setear proveedor al combo de Contrato Base
		this.Cmp.id_proveedor.on("select",function(c,r,i){
			var id_proveedor = -1;
			
			if(this.Cmp.id_proveedor.getValue()){
				id_proveedor = this.Cmp.id_proveedor.getValue();
			} else {
				alert("Seleccione un proveedor");
			}
			Ext.apply(this.Cmp.id_contrato_fk.store.baseParams,{id_proveedor: id_proveedor})
			this.Cmp.id_contrato_fk.setValue("");
			this.Cmp.id_contrato_fk.modificado=true;
		},this);
		
		//Evento para definir obligatoriedad de registro de OTs en funcion del Concepto de Gasto
		this.Cmp.id_concepto_ingas.on("select",function(c,r,i){
			if(this.Cmp.id_concepto_ingas.getValue()){
				//console.log(this.Cmp.id_concepto_ingas.internal)
				//Recorre todos los items marcados del combo de COncepto de gasto y almacena en un array todos los
				//id_concepto_ingas que requieren ot
				var recConIngGas;		
				if(this.Cmp.id_concepto_ingas.internal.items){
					this.Cmp.id_concepto_ingas.internal.items.forEach(function(entry,index,object) {
					    //console.log(entry,index,entry === object[index]);
					    var recConIngGas = this.Cmp.id_concepto_ingas.store.getById(entry.id_concepto_ingas);
					    if(recConIngGas){
					    	if(recConIngGas.data.requiere_ot=='obligatorio'){
					    		alert('requiere ot: '+ entry.desc_ingas +' '+entry.id_concepto_ingas)
					    		this.arrConceptoIngas.push(recConIngGas.id);	
					    	}
					    }
					    //console.log(recConIngGas);
					},this);
				}
				
				//Verifica si lis items seleccionados en el combo de concepto ingas estan en el array de ids con ot requerido
				//para obligar o no el registro de ots
				var boolOTreq=true;
				if(this.Cmp.id_concepto_ingas.internal.items){
					this.Cmp.id_concepto_ingas.internal.items.forEach(function(entry,index,object) {
						if(this.arrConceptoIngas.indexOf(entry.id_concepto_ingas)!=-1){
							alert(entry.id_concepto_ingas)
							boolOTreq = false;
						}
					},this);
				 }
				 this.Cmp.id_orden_trabajo.allowBlank = boolOTreq;

			} else {
				this.Cmp.id_orden_trabajo.allowBlank = true;
			}
		},this)
		
    },
	
	onButtonNew: function() {
		Phx.vista[this.config.clase_generada].superclass.onButtonNew.call(this);
		if (this.config.estado == "borrador") {
			//Se oculta el combo de contratos			
			this.ocultarComponente(this.Cmp.id_contrato_fk);
			this.Cmp.id_contrato_fk.reset();
			this.Cmp.id_contrato_fk.allowBlank = true;
		}
	},
	
	onButtonEdit: function() {
		Phx.vista[this.config.clase_generada].superclass.onButtonEdit.call(this);
		if (this.config.estado == "borrador") {
			this.ocultarComponente(this.Cmp.id_contrato_fk);
			this.Cmp.id_contrato_fk.reset();
			this.Cmp.id_contrato_fk.allowBlank = true;

			if(this.Cmp.modo.getValue()=="adenda"){
				this.mostrarComponente(this.Cmp.id_contrato_fk);
				this.Cmp.id_contrato_fk.reset();
				this.Cmp.id_contrato_fk.allowBlank = false;
			}
		}
	},
	
	onDocumento: function(){
		var rec = this.sm.getSelected();
		var recDoc = this.cmbTipoDoc.store.getById(this.cmbTipoDoc.getValue());
		console.log(recDoc)
		Phx.CP.loadingShow();
		Ext.Ajax.request({
			url : '../../sis_workflow/control/TipoDocumento/generarDocumento',
			params : {
				id_proceso_wf    		: rec.data.id_proceso_wf,
				id_tipo_documento		: recDoc.data.id_tipo_documento,
				nombre_vista	 		: recDoc.data.nombre_vista,
				esquema_vista    		: recDoc.data.esquema_vista,
				nombre_archivo_plantilla: recDoc.data.nombre_archivo_plantilla
			},
			success : this.successExport,
			failure : this.conexionFailure,
			timeout : this.timeout,
			scope : this
		});
	},
	
	preparaMenu:function(n){
    	var data = this.getSelectedData();
        var tb =this.tbar;
        Phx.vista[this.config.clase_generada].superclass.preparaMenu.call(this,n);
        this.cmbTipoDoc.enable();
	},
	
	liberaMenu:function(){
		var tb = Phx.vista[this.config.clase_generada].superclass.liberaMenu.call(this);
        if(tb){
			this.cmbTipoDoc.disable();
        }

		return tb;
  	}
  	  
  	  
}

/*************************
CONFIGURACION DEL CAMPOS
**************************/