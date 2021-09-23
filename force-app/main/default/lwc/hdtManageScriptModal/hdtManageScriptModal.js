
/*
 * File: hdtManageScriptModal.js
 * Project: HERA
 * File Created: Monday, 7th June 2021 2:02:59 pm
 * Author: fdefelice
 * DESCRIPTION: 
 * -----
 * HISTORY:
 * Last Modified: Tuesday, 15th June 2021 12:57:01 pm
 * Modified By: fdefelice
 * Changes: 
 * --END--
 */


import { LightningElement, api } from 'lwc';

export default class HdtManageScriptModal extends LightningElement {

    @api scriptProcessName;//Script Process
    @api recordId;//record starting Object
    @api buttonLabel;
    @api childAdditionalInfo="";//API field of child Record you want to show info in the title
    @api linkReitek;
    @api hasLink;
    openModal;

    
    connectedCallback(){// stub parameters for test purpose
        if(!this.scriptProcessName){
            this.scriptProcessName='Mini Vocal Order';
            this.buttonLabel='OTP';
            this.recordId='8011X000002SkvlQAC';
            this.childAdditionalInfo='orderNumber';
        }
    }


    

    showModal(){
        this.openModal=true;
    }

    closeModal(){
        this.openModal=false;
    }






}