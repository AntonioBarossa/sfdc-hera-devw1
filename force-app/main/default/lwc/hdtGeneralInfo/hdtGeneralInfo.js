import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateSale from '@salesforce/apex/HDT_LC_GeneralInfo.updateSale';

export default class HdtGeneralInfo extends LightningElement {
    @api saleRecord = {};
    disabledInput = false;
    disabledNext = false;
    hiddenEdit = true;
    loading = false;
    dataToSubmit = {};
    currentStep = 1;
    nextStep = 2;

    toggle(){
        this.disabledInput = !this.disabledInput;
        this.disabledNext = !this.disabledNext;
        this.hiddenEdit = !this.hiddenEdit;
    }

    handleDataCollection(event){
        this.dataToSubmit[event.target.fieldName] = event.target.value;
    }

    initDataToSubmit(){
        this.dataToSubmit['Id'] = this.saleRecord.Id;
        this.dataToSubmit['CurrentStep__c'] = this.nextStep;
    }

    updateSaleRecord(saleData){
        this.loading = true;
        updateSale({sale: saleData}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new CustomEvent('saleupdate'));
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

    handleNext(){
        this.updateSaleRecord(this.dataToSubmit);
        this.toggle();
    }

    handleEdit(){
        this.updateSaleRecord({Id: this.saleRecord.Id, CurrentStep__c: this.currentStep});
        this.toggle();
    }

    connectedCallback(){
        this.initDataToSubmit();
        if(this.saleRecord.CurrentStep__c != this.currentStep){
            this.toggle();
        }
    }
}