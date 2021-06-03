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


import { LightningElement, api } from 'lwc';

export default class HdtScriptManagementModal extends LightningElement {

    @api buttonLabel;
    openModal;

    connectedCallback(){
        if(!this.buttonLabel){
            this.buttonLabel='Vocal Order';
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