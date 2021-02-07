import { LightningElement, api, track } from 'lwc';
import getServicePoint from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.getServicePoint';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class hdtCreateTargetObject extends LightningElement {
    @api accountid;
    @api targetobject;
    @api selectedservicepoint;
    @api sale;
    @api disabledinput;
    @api showCreateTargetObjectButton;

    @track recordType = {label:'',value: '', DeveloperName: ''};

    showCreateTargetObjectModal = false;
    showRecordTypeSelectionModal = false;

    get modalStatus(){
        if(this.selectedservicepoint != undefined){


            if(this.showCreateTargetObjectModal == false){

                this.showCreateTargetObjectModal = true;
            }
        }
        return this.showCreateTargetObjectModal;
    }

    /**
     * Open record type selection modal on record create init
     */
    handleModalInit(){
        this.openRecordTypeSelection();
    }

    /**
     * Open record type selection modal
     */
    openRecordTypeSelection(){
        this.showRecordTypeSelectionModal = true;
    }

    /**
     * Close record type selection
     */
    closeRecordTypeSelection(){
        this.showRecordTypeSelectionModal = false;
    }

    /**
     * Open create form
     */
    openCreateRecordForm(){
        this.showCreateTargetObjectModal = true;
    }

    /**
     * Close create form
     */
    closeCreateRecordForm(){
        if(this.selectedservicepoint != undefined){
            this.selectedservicepoint = undefined;
        }
        this.showCreateTargetObjectModal = false;
    }

    /**
     * Get selected record type
     * @param {*} recordType 
     */
    getRecordType(recordType){
        this.recordType = recordType;
        console.log('hdtCreateTargetObject - getRecordType: ', JSON.stringify(this.recordType));
    }

    /**
     * Handle event on next button press
     * @param {*} event 
     */
    handleNext(event){

        console.log('handleNext'+ JSON.stringify(event.detail));

        this.closeRecordTypeSelection();
        this.getRecordType(event.detail);
        this.openCreateRecordForm();
    }

    /**
     * Dispatch created service point
     * @param {*} event 
     */
    handleNewServicePoint(event){
        this.dispatchEvent(new CustomEvent('newservicepoint', {detail: event.detail}));
    }

    /**
     * Dispatch event for ServicePoint confirm
     */
    handleConfirmServicePoint(event){
        let servicePoint = event.detail;
        this.dispatchEvent(new CustomEvent('confirmservicepoint', {detail: servicePoint}));
    }
}