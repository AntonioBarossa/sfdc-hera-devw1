import { LightningElement, api, track } from 'lwc';
import getServicePoint from '@salesforce/apex/HDT_LC_ServicePoint.getServicePoint';

export default class hdtCreateTargetObject extends LightningElement {
    @api accountid;
    @api targetobject;
    @api selectedservicepoint;

    @track recordType = {label:'',value: ''};
    showCreateTargetObjectModal = false;
    showRecordTypeSelectionModal = false;

    get modalStatus(){
        if(this.selectedservicepoint != undefined){
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

    handleModalInit(){
        this.openRecordTypeSelection();
    }

    openRecordTypeSelection(){
        this.showRecordTypeSelectionModal = true;
    }

    closeRecordTypeSelection(){
        this.showRecordTypeSelectionModal = false;
    }

    openCreateRecordForm(){
        this.showCreateTargetObjectModal = true;
    }

    closeCreateRecordForm(){
        if(this.selectedservicepoint != undefined){
            this.selectedservicepoint = undefined;
        }
        this.showCreateTargetObjectModal = false;
    }

    getRecordType(recordType){
        this.recordType = recordType;
    }

    handleNext(event){
        this.closeRecordTypeSelection();
        this.getRecordType(event.detail);
        this.openCreateRecordForm();
    }
}