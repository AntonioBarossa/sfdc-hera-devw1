/*
 * File: hdtScriptManagementModal.js
 * Project: HERA
 * File Created: Thursday, 3rd June 2021 4:06:52 pm
 * Author: fdefelice
 * -----
 * Last Modified: Thursday, 3rd June 2021 4:30:25 pm
 * Modified By: fdefelice
 * -----
 */

import getHTMLScript from '@salesforce/apex/HDT_LC_HdtScriptManagementModal.getScriptText';
import { LightningElement, api, wire } from 'lwc';

export default class HdtScriptManagementModal extends LightningElement {

    @api scriptProcessName;//button Label or Process
    @api recordId;//record starting Object

    openModal;
    htmlScript;


    @wire(getHTMLScript, {processName : '$scriptProcessName', recordId : '$recordId'})
    setRichText({error, data}){
        if (data) {
            console.log(data)
            this.htmlScript=data;
        } else if (error) {
            console.error(error)
            this.showGenericErrorToast()
        }
    } 
    
    showGenericErrorToast() {
		this.showToast('error', 'Errore', 'Si è verificato un errore. Ricaricare la pagina e riprovare. Se il problema persiste contattare il supporto tecnico.');
	}
	
	showToast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({
			variant: variant,
			title: title,
			message: message
		}));
	}
    
    connectedCallback(){
        if(!this.scriptProcessName){
            this.scriptProcessName='Mini Vocal Order';
            this.recordId='a3g1j000000XPX7AAO';
        }
    }

    _linkReitek;//private var
    get linkReitek(){
        return this._linkReitek;
    }
    set linkReitek(value){
        this._linkReitek=value;
        if(!value){
            this.enableConfirmButton();
        }
    }
/*     
    @api
    get buttonLabel(){
        return this._buttonLabel;
    }
    set buttonLabel(value){
        this._buttonLabel
    }
 */

    
    

    showModal(){
        this.openModal=true;
    }

    closeModal(){
        this.openModal=false;
    }
    saveRecLink(){
        let link= this._linkReitek;
        //do stuff
        this.closeModal();
    }

    enableConfirmButton(){
        let btConferma = this.template.querySelector('[data-id="scriptModalBt"]');
        btConferma.disabled=false;
    }
}