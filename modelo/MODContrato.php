<?php
/**
*@package pXP
*@file MODContrato.php
*@author  RCM
*@date 17/01/2015
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODContrato extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarContratos(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='leg.ft_contrato_sel';
		$this->transaccion='LEG_CONTRA_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
        $this->captura('id_usuario_reg','int4'); 
        $this->captura('id_usuario_mod','int4'); 
        $this->captura('fecha_reg','timestamp'); 
        $this->captura('fecha_mod','timestamp'); 
        $this->captura('estado_reg','varchar'); 
        $this->captura('id_usuario_ai','int4'); 
        $this->captura('usuario_ai','varchar'); 
        $this->captura('id_contrato','int4'); 
        $this->captura('id_estado_wf','int4'); 
        $this->captura('id_proceso_wf','int4'); 
        $this->captura('estado','varchar'); 
        $this->captura('tipo','varchar'); 
        $this->captura('objeto','text'); 
        $this->captura('fecha_inicio','date'); 
        $this->captura('fecha_fin','date');
        $this->captura('numero','varchar');  
        $this->captura('id_gestion','int4'); 
        $this->captura('id_persona','int4'); 
        $this->captura('id_institucion','int4');  
        $this->captura('id_proveedor','int4'); 
        $this->captura('observaciones','text');
        $this->captura('solicitud','text'); 
        $this->captura('monto','numeric'); 
        $this->captura('id_moneda','int4'); 
        $this->captura('fecha_elaboracion','date'); 
        $this->captura('plazo','int4'); 
        $this->captura('tipo_plazo','varchar'); 
        $this->captura('id_cotizacion','int4'); 
        $this->captura('sujeto_contrato','text');
        $this->captura('moneda','varchar'); 
        $this->captura('usr_reg','varchar'); 
        $this->captura('usr_mod','varchar'); 
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>