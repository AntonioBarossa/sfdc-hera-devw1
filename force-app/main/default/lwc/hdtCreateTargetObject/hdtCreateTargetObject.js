import { LightningElement, api, track,wire } from 'lwc';
import getServicePoint from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.getServicePoint';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCustomSettingFieldsRequiredEle from '@salesforce/apex/HDT_QR_ServicePoint.getCustomSettingFieldsRequiredEle';
import getCustomSettingFieldsRequiredGas from '@salesforce/apex/HDT_QR_ServicePoint.getCustomSettingFieldsRequiredGas';
import getCustomSettingFieldsRequiredAcqua from '@salesforce/apex/HDT_QR_ServicePoint.getCustomSettingFieldsRequiredAcqua';
import getCustomSettingFieldsRequiredAmbiente from '@salesforce/apex/HDT_QR_ServicePoint.getCustomSettingFieldsRequiredAmbiente';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = [
    'Account.CustomerMarking__c'
];
export default class hdtCreateTargetObject extends LightningElement {
    @api accountid;
    @api customercode;
    @api targetobject;
    @api selectedservicepoint;
    @api sale;
    @api disabledinput;
    @api showCreateTargetObjectButton;
    @api rowSplitEle = [];
    @api rowSplitGas = [];
    @api rowSplitAcqua = [];
    @api rowSplitAmbiente = [];
    @api isricercainsap;
    @api processtype;
    @track recordType = {label:'',value: '', DeveloperName: ''};
    @track customerMarking='';
    @wire(getRecord, { recordId: '$accountid', fields: FIELDS })
        wiredAccount({ error, data }) {
			if (data) {
				this.customerMarking = data.fields.CustomerMarking__c.value;
			}
		}
    showCreateTargetObjectModal = false;
    showRecordTypeSelectionModal = false;
    get modalStatus(){
        
        if(this.selectedservicepoint != undefined){

            if(this.showCreateTargetObjectModal == false && (this.processtype == '' || this.processtype == undefined)){
                this.showCreateTargetObjectModal = true;
            }
        }
        return this.showCreateTargetObjectModal;
    }

    connectedCallback(){

        getCustomSettingFieldsRequiredEle().then(data=>{
            this.rowSplitEle = data.FieldRequiredEle__c.split(",");
        });
        getCustomSettingFieldsRequiredGas().then(data=>{
            this.rowSplitGas = data.FieldRequiredGas__c.split(",");
        });
        getCustomSettingFieldsRequiredAcqua().then(data=>{
            this.rowSplitAcqua = data.FieldRequiredWater__c.split(",");
        });
        getCustomSettingFieldsRequiredAmbiente().then(data=>{
            this.rowSplitAmbiente = data.FieldRequiredWaste__c.split(",");
        });
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
    }

    /**
     * Handle event on next button press
     * @param {*} event 
     */
    handleNext(event){
        this.closeRecordTypeSelection();
        this.getRecordType(event.detail);
        this.openCreateRecordForm();
    }

    handleCustomerMarkingCompatibilty(event){
        var recordType = event.detail.label;
        if(this.customerMarking && this.customerMarking.indexOf('MMS')>-1){
            if(recordType.indexOf('Elettrico')>-1 || recordType.indexOf('Gas')>-1){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message:'Su clienti MMS non è possibile creare un ' + recordType,
                        variant: 'error',
                    }),
                );
            }else{
                this.handleNext(event);
            }            
        }else{
            this.handleNext(event);
        }
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