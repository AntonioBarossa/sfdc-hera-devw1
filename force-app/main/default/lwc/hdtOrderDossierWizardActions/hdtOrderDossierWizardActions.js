import { LightningElement, api } from 'lwc';

export default class hdtOrderDossierWizardActions extends LightningElement {
    
    @api orderParentRecord;
    currentStep = 2;

    get disabledSave(){
        let result = false;
        if(this.orderParentRecord.Step__c != this.currentStep || this.orderParentRecord.Status != 'Draft'){
            result = true;
        } else {
            result = false;
        }
        return result;
    }

    get disabledSaveDraft(){
        let result = false;
        if(this.orderParentRecord.Status != undefined && this.orderParentRecord.Status != 'Draft'){
            result = true;
        } else {
            result = false;
        }
        return result;
    }

    get disabledCancel(){
        let result = false;
        if(this.orderParentRecord.Status != undefined && this.orderParentRecord.Status != 'Draft'){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

}