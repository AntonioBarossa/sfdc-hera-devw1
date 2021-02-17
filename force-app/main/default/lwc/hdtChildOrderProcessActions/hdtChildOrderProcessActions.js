import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import save from '@salesforce/apex/HDT_LC_ChildOrderProcessActions.save';

export default class hdtChildOrderProcessActions extends LightningElement {
    @api order;
    loading = false;
    
    get disabledSave(){
        return false;
        // return (this.order.Step__c <= 2 || this.order.Step__c === undefined);
    }

    handleSave(){
        this.loading = true;
        save({order: this.order}).then(data =>{
            this.loading = false;

            this.dispatchEvent(new CustomEvent('saveevent'));

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Processo confermato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

        }).catch(error => {
            this.loading = false;
            console.log((error.body.message !== undefined) ? error.body.message : error.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: (error.body.message !== undefined) ? error.body.message : error.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }
}