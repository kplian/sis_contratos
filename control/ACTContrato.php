<?php
/**
*@package pXP
*@file ACTContrato.php
*@author  RCM
*@date 17/01/2014
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTContrato extends ACTbase{    
			
	function listarContratos(){
		$this->objParam->defecto('ordenacion','id_contrato');
		$this->objParam->defecto('dir_ordenacion','asc');
        
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODContrato','listarContratos');
		} else{
			$this->objFunc=$this->create('MODContrato');
			
			$this->res=$this->objFunc->listarContratos($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}			
}

?>