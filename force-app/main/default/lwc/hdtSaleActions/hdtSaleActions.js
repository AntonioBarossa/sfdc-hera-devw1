import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveDraft from '@salesforce/apex/HDT_LC_SaleActions.saveDraft';
import save from '@salesforce/apex/HDT_LC_SaleActions.save';
import cancel from '@salesforce/apex/HDT_LC_SaleActions.cancel';

export default class hdtSaleActions extends LightningElement {
    @api saleRecord;
    loading = false;
    currentStep = 4;
    isDialogVisible = false;
    dialogTitle;
    dialogMessage;
    eventType;

    get disabledSave(){
        let result = false;
        if(this.saleRecord.CurrentStep__c != this.currentStep || this.saleRecord.Status__c != 'Bozza'){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    get disabledSaveDraft(){
        let result = false;
        if(this.saleRecord.Status__c != undefined && this.saleRecord.Status__c != 'Bozza'){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    get disabledCancel(){
        let result = false;
        if(this.saleRecord.Status__c != undefined && this.saleRecord.Status__c != 'Bozza'){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    saveSaleCall(){
        this.loading = true;
        save({sale: this.saleRecord}).then(data =>{
            this.loading = false;
            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Vendita salvata con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);
            this.dispatchEvent(new CustomEvent('saleupdate', { bubbles: true }));
            this.dispatchEvent(new CustomEvent('savesaleevent'));
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

    cancelSaleCall(){
        this.loading = true;
        cancel({sale: this.saleRecord}).then(data =>{
            this.loading = false;
            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Vendita anullata con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);
            // this.dispatchEvent(new CustomEvent('saleupdate', { bubbles: true }));
            this.dispatchEvent(new CustomEvent('cancelsaleevent'));
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

    handleSaveDraft(){
        this.loading = true;
        saveDraft({sale: {Id:this.saleRecord.Id, CurrentStep__c:this.saleRecord.CurrentStep__c}}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new CustomEvent('saleupdate', { bubbles: true }));
            this.dispatchEvent(new CustomEvent('savedraftevent'));
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
        this.eventType = 'saveSale';
        this.dialogTitle = 'Salva ' + this.saleRecord.Name;
        this.dialogMessage = 'Vuoi salvare ' + this.saleRecord.Name + ' ?';
        this.isDialogVisible = true;
    }

    handleCancel(){
        this.eventType = 'cancelSale';
        this.dialogTitle = 'Anulla ' + this.saleRecord.Name;
        this.dialogMessage = 'Vuoi anullare ' + this.saleRecord.Name + ' ?';
        this.isDialogVisible = true;
    }

    handleDialogResponse(event){
        if(event.detail.status == true){
            console.log(this.eventType);
            switch (this.eventType) {
                case 'saveSale':
                    this.saveSaleCall();
                    break;
                case 'cancelSale':
                    this.cancelSaleCall();
                    break;
                default:
                    break;
            }
        } else {
            this.isDialogVisible = false;
        }
    }

}