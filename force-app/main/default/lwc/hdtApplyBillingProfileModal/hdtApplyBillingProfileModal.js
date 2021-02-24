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
        {label: 'Prodotto', fieldName: 'ProductName', type: 'text'},
        {label: 'POD/PDR', fieldName: 'ServicePointCode', type: 'text'}
    ];

    getModalData(){
        this.loading = true;

        console.log('this.selectedBillingProfile: ', JSON.parse(JSON.stringify(this.selectedBillingProfile)));

        let paymentMethodRaw = this.selectedBillingProfile.PaymentMethod__c;
        let paymentMethodToSend = paymentMethodRaw.includes("Bollettino") ? 'Bollettino' : this.selectedBillingProfile.PaymentMethod__c;

        getQuoteLineBundle({saleId: this.sale.Id, paymentMethod: paymentMethodToSend}).then(data =>{
            this.loading = false;
            
            if(data.length == 0){
                
                this.handleCancelEvent();
                const event = ShowToastEvent({
                    title: '',
                    message:  'Nessun record trovato',
                    variant: 'warn'
                });
                dispatchEvent(event);

            } else {
                let quoteBundleArray = [];

                console.log('hdtApplyBillingProfileModal: ', JSON.parse(JSON.stringify(data)));

                data.forEach(el => {
                    quoteBundleArray.push({
                        "Id"                   :el.SBQQ__RequiredBy__c,
                        "Name"                 :el.SBQQ__RequiredBy__r.Name,
                        "ProductName"          :el.SBQQ__RequiredBy__r.SBQQ__Product__r.Name,
                        "ServicePointCode"     :el.ServicePoint__r.ServicePointCode__c
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