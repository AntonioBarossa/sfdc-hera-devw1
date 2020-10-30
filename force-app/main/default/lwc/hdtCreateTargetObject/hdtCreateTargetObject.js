import { LightningElement, api, track } from 'lwc';
import getServicePoint from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.getServicePoint';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class hdtCreateTargetObject extends LightningElement {
    @api accountid;
    @api targetobject;
    @api selectedservicepoint;
    @api sale;

    @track recordType = {label:'',value: ''};
    showCreateTargetObjectModal = false;
    showRecordTypeSelectionModal = false;

    get modalStatus(){
        if(this.selectedservicepoint != undefined){
            console.log('hdtCreateTargetObject: ' + JSON.stringify(this.sale));

            if(this.showCreateTargetObjectModal == false){
                this.showCreateTargetObjectModal = true;
            }

            getServicePoint({code:this.selectedservicepoint['Codice POD/PDR'],fields:'Id, RecordTypeId, RecordType.name'}).then(data =>{
                this.recordType.label = data[0].RecordType.Name
                this.recordType.value = data[0].RecordTypeId
                
            }).catch(error => {
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error'
                });
                this.dispatchEvent(toastErrorMessage);
            });
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

    /**
     * Dispatch created service point
     * @param {*} event 
     */
    handleNewServicePoint(event){
        this.dispatchEvent(new CustomEvent('newservicepoint', {detail: event.detail}));
    }
}