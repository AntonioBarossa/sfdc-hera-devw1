import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import next from '@salesforce/apex/HDT_LC_OrderDossierWizardSignature.next';

export default class hdtOrderDossierWizardSignature extends LightningElement {
    
    @api orderParentRecord;
    dataToSubmit = {};
    isDisabledSignedDate = true;
    disabledInput = false;
    loading = false;
    isMailVisible = false;
    get mailClasses(){
        return this.isMailVisible ? 'slds-size_1-of-2 slds-show' : 'slds-size_1-of-2 slds-hide';
    }

    get hiddenEdit(){
        let result = true;
        // if(this.saleRecord.CurrentStep__c <= this.currentStep){
        //     result = true;
        // } else if(this.saleRecord.CurrentStep__c > this.currentStep){
        //     result = false;
        // }

        return result;
    }

    get disabledNext(){
        let result = false;
        // if(this.saleRecord.CurrentStep__c != this.currentStep){
        //     result = true;
        // } else {
        //     result = false;
        // }

        return result;
    }

    // get disabledInput(){
        // let result = false;
        // if(this.saleRecord.CurrentStep__c != this.currentStep){
        //     result = true;
        // } else {
        //     result = false;
        // }

        // return result;
    // }

    handleDataCollection(event){
        let fieldName = event.target.fieldName;
        let fieldValue = event.target.value;

        this.dataToSubmit[fieldName] = fieldValue;

        if (fieldName === 'ContractSigned__c') {
            this.isDisabledSignedDate = !this.isDisabledSignedDate;
            this.disabledInput = !this.disabledInput;
        }

        if (fieldName === 'DocSendingMethod__c') {
            this.isMailVisible = (fieldValue === 'Mail');
        }
    }

    handleNext(){
        this.loading = true;
        this.dataToSubmit['Id'] = this.orderParentRecord.Id;
        next({orderUpdates: this.dataToSubmit}).then(data =>{
            this.loading = false;
            
        }).catch(error => {
            this.loading = false;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    connectedCallback(){

        if (this.orderParentRecord.ContractSigned__c !== undefined) {
            this.isDisabledSignedDate = !this.orderParentRecord.ContractSigned__c;
            this.disabledInput = this.orderParentRecord.ContractSigned__c;
        }

        if (this.orderParentRecord.DocSendingMethod__c === 'Mail') {
            this.isMailVisible = true;
        }
    }

}