import { LightningElement, api, track } from 'lwc';
import getServicePoint from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.getServicePoint';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCustomSettingFieldsRequiredEle from '@salesforce/apex/HDT_QR_ServicePoint.getCustomSettingFieldsRequiredEle';
import getCustomSettingFieldsRequiredGas from '@salesforce/apex/HDT_QR_ServicePoint.getCustomSettingFieldsRequiredGas';

export default class hdtCreateTargetObject extends LightningElement {
    @api accountid;
    @api targetobject;
    @api selectedservicepoint;
    @api sale;
    @api disabledinput;
    @api showCreateTargetObjectButton;
    @api rowSplitEle = [];
    @api rowSplitGas = [];

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

    connectedCallback(){
        console.log('****************************************this.disabledinput'+ this.disabledinput);
        console.log('targetObject***'+ JSON.stringify(this.targetobject));
        console.log('recordType***'+ JSON.stringify(this.recordType));

        getCustomSettingFieldsRequiredEle().then(data=>{
            this.rowSplitEle = data.FieldRequiredEle__c.split(",");
            console.log('rowSplitEle****'+ JSON.stringify(this.rowSplitEle));
        });
        getCustomSettingFieldsRequiredGas().then(data=>{

            this.rowSplitGas = data.FieldRequiredGas__c.split(",");
            console.log('rowSplitGas****'+ JSON.stringify(this.rowSplitGas));
        });
        console.log('connect to hdtCreateTragetObject');
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

        console.log('hdtCreateTargetObject - handleConfirmServicePoint: ', JSON.stringify(servicePoint));

        this.dispatchEvent(new CustomEvent('confirmservicepoint', {detail: servicePoint}));
    }
}