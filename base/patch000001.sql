/***********************************I-SCP-VAN-LEG-ETR-0-02/03/2021****************************************/
CREATE TABLE leg.tcontrato (
	id_contrato serial4 NOT NULL,
	id_estado_wf int4 NOT NULL,
	id_proceso_wf int4 NOT NULL,
	"estado" varchar(50) NOT NULL,
	tipo varchar(30) NULL,
	objeto text NULL,
	fecha_inicio date NULL,
	fecha_fin date NULL,
	numero varchar(50) NULL,
	id_gestion int4 NULL,
	id_persona int4 NULL,
	id_institucion int4 NULL,
	id_proveedor int4 NULL,
	observaciones text NULL,
	solicitud text NULL,
	monto numeric(18, 2) NULL,
	id_moneda int4 NULL,
	fecha_elaboracion date NULL,
	plazo int4 NULL,
	tipo_plazo varchar NULL,
	id_cotizacion int4 NULL,
	periodicidad_pago varchar(50) NULL,
	tiene_retencion varchar(2) NULL,
	modo varchar(30) NULL,
	id_lugar int4 NULL,
	id_contrato_fk int4 NULL,
	id_concepto_ingas _int4 NULL,
	id_orden_trabajo _int4 NULL,
	cargo varchar(50) NULL,
	forma_contratacion varchar(30) NULL,
	modalidad varchar(30) NULL,
	representante_legal varchar(100) NULL,
	rpc varchar(100) NULL,
	mae varchar(100) NULL,
	contrato_adhesion varchar(2) NULL,
	id_abogado int4 NULL,
	id_funcionario int4 NULL,
	rpc_regional varchar NOT NULL DEFAULT 'no'::character varying,
	bancarizacion varchar(2) NULL,
	tipo_monto varchar NULL,
	resolucion_bancarizacion varchar NULL,
	id_tipo_cc int4 NULL,
	plazo_auxiliar varchar(1000) NULL,
	numero_proceso_contratacion varchar(100) NULL,
	regularizado varchar(2) NULL,
    id_carpeta int,
    CONSTRAINT tcontrato_pkey PRIMARY KEY (id_contrato)
    )
INHERITS (pxp.tbase);

comment
on column leg.tcontrato.id_carpeta is 'proviene del modulo gestion social';

/*alter table leg.tcontrato
    add constraint tcontrato_tcontrato_id_carpeta_fk
        foreign key (id_carpeta) references mgs.tcarpetas;*/
/***********************************F-SCP-VAN-LEG-ETR-0-02/03/2021****************************************/