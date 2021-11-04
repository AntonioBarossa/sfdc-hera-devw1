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

import templateModal from './templateModal.html';
import templateStandard from './templateStandard.html';

import getScriptConfig from '@salesforce/apex/HDT_LC_HdtScriptManagementModal.getScriptConfig';

const columns = [
    {label: 'Nome Script', fieldName: 'scriptName', type: 'text'},
    {label: 'Stato', fieldName: 'status', type: 'text'},
    {type: 'button', initialWidth: 120, typeAttributes:{
            label: 'Avvia', 
            title: 'Avvia',
            name: 'startScript', 
            value: 'startScript',
            iconName: 'utility:call',
            disabled: {fieldName :'completed'}
        }
    }
];

export default class HdtManageScriptModal extends LightningElement {

    @api recordId;//record starting Object
    @api activityId;
    @api childAdditionalInfo='';//API field of child Record you want to show info in the title
    @api linkReitek;
    @api hasLink;
    @api modal = false;
    openModal = false;
    isLoading = false;

    scriptConfig;
    scriptConfigs;
    columns = columns;

    render() {
        return this.modal ? templateModal : templateStandard;
    }
    
    connectedCallback(){
        this.loadScriptConfig();
    }

    @api
    showModal(){
        this.openModal = true;
        this.loadScriptConfig();
    }

    closeModal(){
        console.log("closeModal");
        this.openModal = false;
        this.dispatchEvent(new CustomEvent('close'));
    }

    confirmModal(evt){
        /*console.log("confirmModal");
        this.openModal = false;
        this.dispatchEvent(new CustomEvent('confirm'));*/

        let scriptConfigs = this.scriptConfigs;
        scriptConfigs.forEach(scriptConfig => {
            if (scriptConfig.scriptName === this.scriptConfig.scriptName) {
                scriptConfig.status = 'Completato';
                scriptConfig.completed = true;
            }
        });
        this.scriptConfigs = scriptConfigs;
        this.scriptConfig = null;
    }

    handleRowAction(event){
        let scriptConfig = event.detail.row;
        let action = event.detail.action;

        if (action.value === 'startScript') {
            this.scriptConfig = scriptConfig;
        }
    }

    loadScriptConfig(){
        if (this.recordId) {
            this.isLoading = true;
            getScriptConfig({recordId: this.recordId}).then(scriptConfigs => {
                
                if (scriptConfigs.length>0) {
                    scriptConfigs.forEach(scriptConfig => {
                        scriptConfig.status = 'Da Completare';
                        scriptConfig.completed = false;
                    });
                    console.log(JSON.stringify(scriptConfigs));
                    this.scriptConfigs = scriptConfigs;
                }

                this.isLoading = false;
            },error => {
                console.log(error);
                const evt = new ShowToastEvent({
                    title: 'Errore caricamento Script',
                    message: 'Non è stato possibile recuperare le informazioni relative agli script',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            });
        }
    }
}