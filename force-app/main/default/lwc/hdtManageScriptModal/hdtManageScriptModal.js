
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
    @api activityId;
    @api buttonLabel;
    @api childAdditionalInfo="";//API field of child Record you want to show info in the title
    @api linkReitek;
    @api hasLink;
    @api isInsideModal = false;
    @api openModal = false;
    isScriptConfirmed = false;
    isDecisional;

    get hasScriptType() {
        return (this.isDecisional!=null);
    }
    
    connectedCallback(){
        if (this.openModal) {
            this.checkScriptType();
        }
    }

    showModal(){
        this.checkScriptType();
    }

    closeModal(){
        console.log("closeModal");
        this.openModal = false;
        this.dispatchEvent(new CustomEvent('close'));
    }

    confirmModal(){
        console.log("confirmModal");
        this.isScriptConfirmed = true;
        this.openModal = false;
        this.dispatchEvent(new CustomEvent('confirm'));
    }

    checkScriptType() {
        return isDecisionalScript({processName: this.scriptProcessName}).then(isDecisional => {
            this.isDecisional = isDecisional;
            this.openModal = true;
        },error => {
            this.dispatchEvent(new ShowToastEvent({
                variant: 'error',
                title: 'Non è stato possibile determinare il tipo dello script',
                message: error
            }));
        });
    }

}