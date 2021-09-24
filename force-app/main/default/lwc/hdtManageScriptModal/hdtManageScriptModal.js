
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
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import isDecisionalScript from '@salesforce/apex/HDT_LC_DecisionalScriptController.isDecisionalScript';

export default class HdtManageScriptModal extends LightningElement {

    @api scriptProcessName;//Script Process
    @api recordId;//record starting Object
    @api buttonLabel;
    @api childAdditionalInfo="";//API field of child Record you want to show info in the title
    @api linkReitek;
    @api hasLink;
    isDecisional = false;
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
        isDecisionalScript({processName: this.scriptProcessName}).then(isDecisional => {
            this.isDecisional = isDecisional;
            this.openModal = true;
        },error => {
            this.dispatchEvent(new ShowToastEvent({
                variant: 'error',
                title: 'Non è stato possibile determinare il tipo dello script',
                message: error
            }));
        })
    }

    closeModal(){
        this.openModal=false;
    }

}