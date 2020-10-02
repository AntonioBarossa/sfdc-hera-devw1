import { LightningElement, api, track } from 'lwc';


export default class hdtCreateTargetObject extends LightningElement {
    @api accountid;
    @api targetobject;

    recordTypeId;
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

    getRecordTypeId(recordTypeId){
        this.recordTypeId = recordTypeId;
    }

    handleNext(event){
        console.log(event.detail);
        this.closeRecordTypeSelection();
        this.getRecordTypeId(event.detail);
        this.openCreateRecordForm();
    }
}