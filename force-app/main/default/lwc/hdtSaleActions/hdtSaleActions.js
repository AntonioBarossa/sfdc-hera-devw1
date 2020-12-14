import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveDraft from '@salesforce/apex/HDT_LC_SaleActions.saveDraft';
import save from '@salesforce/apex/HDT_LC_SaleActions.save';

export default class hdtSaleActions extends LightningElement {
    @api saleRecord;
    loading = false;
    currentStep = 4;

    get disabledSave(){
        let result = false;
        if(this.saleRecord.CurrentStep__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    handleSaveDraft(){
        this.loading = true;
        saveDraft({sale: {Id:this.saleRecord.Id, CurrentStep__c:this.saleRecord.CurrentStep__c}}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new CustomEvent('saleupdate', { bubbles: true }));
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

    handleSave(){
        
        console.log('saleRecord: ', JSON.parse(JSON.stringify(this.saleRecord)));

        this.loading = true;
        save({sale: this.saleRecord}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new CustomEvent('saleupdate', { bubbles: true }));
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

}