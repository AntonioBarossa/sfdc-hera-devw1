import { LightningElement, api } from 'lwc';


export default class hdtCreateTargetObject extends LightningElement {
    @api accountid;
    @api targetobject;

    recordType;
    showRecordTypeSelectionModal = false;
    showCreateTargetObjectModal = false;
    
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