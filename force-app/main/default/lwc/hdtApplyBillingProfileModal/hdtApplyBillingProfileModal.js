import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuoteLineBundle from '@salesforce/apex/HDT_LC_ApplyBillingProfileModal.getQuoteLineBundle';
import updateQuoteLinesBillingProfile from '@salesforce/apex/HDT_LC_ApplyBillingProfileModal.updateQuoteLinesBillingProfile';

export default class hdtApplyBillingProfileModal extends LightningElement {

    @api sale;
    @api selectedBillingProfile;
    loading = false;
    quoteBundleData;
    disabledConfirm = true;
    selectedQuoteItems;

    columns = [
        {label: 'Nome', fieldName: 'Name', type: 'text'},
        {label: 'Prodotto', fieldName: 'ProductName', type: 'text'}
    ];

    getModalData(){
        this.loading = true;

        getQuoteLineBundle({saleId: this.sale.Id, paymentMethod: this.selectedBillingProfile.PaymentMethod__c}).then(data =>{
            this.loading = false;
            
            if(data.length == 0){
                
                this.handleCancelEvent();
                const event = ShowToastEvent({
                    title: 'Sucesso',
                    message:  'Nessun record trovato',
                    variant: 'warn'
                });
                dispatchEvent(event);

            } else {
                let quoteBundleArray = [];

                data.forEach(el => {
                    quoteBundleArray.push({
                        "Id"                   :el.Id,
                        "Name"                 :el.Name,
                        "ProductName"          :el.SBQQ__Product__r.Name
                    });
                });

                this.quoteBundleData = quoteBundleArray;
            }

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

    updateQuoteBundle(){
        this.loading = true;

        updateQuoteLinesBillingProfile({quoteLinesToUpdate: this.selectedQuoteItems, billingProfileId: this.selectedBillingProfile.Id}).then(data =>{
            this.loading = false;
            
            this.handleCancelEvent();

            const event = ShowToastEvent({
                title: '',
                message:  'Quote line Bundle aggiornati con successo',
                variant: 'success'
            });
            dispatchEvent(event);

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

    handleCancelEvent(){
        this.dispatchEvent(new CustomEvent('cancelapply'));
    }

    connectedCallback(){
        this.getModalData();
    }

    getSelectedQuoteItems(event){
        let selectedRows = event.detail.selectedRows;

        if(selectedRows.length > 0){
            this.disabledConfirm = false;
            this.selectedQuoteItems = selectedRows;
        } else {
            this.disabledConfirm = true;
        }
    }

    handleConfirmEvent(){
        this.updateQuoteBundle();
    }
}