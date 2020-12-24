import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuotes from '@salesforce/apex/HDT_LC_ConfigureProduct.getQuotes';
import cancelQuote from '@salesforce/apex/HDT_LC_ConfigureProduct.cancelQuote';
import updateSale from '@salesforce/apex/HDT_LC_ConfigureProduct.updateSale';

export default class hdtConfigureProduct extends LightningElement {
    
    @api saleRecord;
    quotesData;
    loaded = false;
    showEditQuote = false;
    selectedQuoteId;
    cancelQuoteId;
    dialogTitle;
    dialogMessage;
    isDialogVisible = false;
    currentStep = 3;
    nextStep = 4;

    get hiddenEdit(){
        let result = true;
        if(this.saleRecord.CurrentStep__c <= this.currentStep){
            result = true;
        } else if(this.saleRecord.CurrentStep__c > this.currentStep){
            result = false;
        }

        return result;
    }

    get disabledNext(){
        let result = false;
        if(this.saleRecord.CurrentStep__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    get disabledInput(){
        let result = false;
        if(this.saleRecord.CurrentStep__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    get disabledButton(){
        let result = false;
        if(this.saleRecord.CurrentStep__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    @api
    getQuotesData(){
        this.loaded = false;
        getQuotes({saleId: this.saleRecord.Id}).then(data =>{
            this.loaded = true;

            let quotesArray = [];
            let count = 0;

            data.forEach(el => {
                quotesArray.push({
                    "Count"                :++count,
                    "Id"                   :el.quote[0].Id,
                    "Name"                 :el.quote[0].Name,
                    "Type"                 :el.quote[0].SBQQ__Type__c,
                    "OpportunityName"      :el.quote[0].SBQQ__Opportunity2__r.Name,
                    "QuoteLines"           :el.quoteLines
                });
            });

            this.quotesData = quotesArray;

        }).catch(error => {
            this.loaded = true;
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    connectedCallback(){
        this.getQuotesData();
    }

    handleOpenConfigureModal(event){
        this.selectedQuoteId = event.currentTarget.dataset.id;
        this.showEditQuote = true;
    }

    handleCloseEditQuoteEvent(){
        this.showEditQuote = false;
    }

    handleQuoteDelete(event){
        this.cancelQuoteId = event.currentTarget.dataset.id;
        let quoteName = event.currentTarget.dataset.name;
        this.dialogTitle = "Cancella la Quote " + quoteName;
        this.dialogMessage = "Sei sicuro di voler cancellare la Quote " + quoteName + " ?";
        this.isDialogVisible = true;
    }

    handleDialogResponse(event){
        if(event.detail.status == true){
            this.loaded = false;
            cancelQuote({quoteId:this.cancelQuoteId}).then(data =>{
                this.loaded = true;
    
                this.getQuotesData();
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Quote eliminata con successo',
                    variant: 'success'
                });
                this.dispatchEvent(toastSuccessMessage);
                this.dispatchEvent(new CustomEvent('quotecancel'));
    
            }).catch(error => {
                this.loaded = true;
                console.log(error.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: error.message,
                    variant: 'error'
                });
                this.dispatchEvent(toastErrorMessage);
            });

        } else {
            this.isDialogVisible = false;
        }
    }

    handleCreatedQuoteLinesEvent(){
        this.getQuotesData();
    }

    updateSaleRecord(saleData){
        this.loaded = false;
        updateSale({sale: saleData}).then(data =>{
            this.loaded = true;
            this.dispatchEvent(new CustomEvent('saleupdate', { bubbles: true }));
        }).catch(error => {
            this.loaded = true;
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
        this.updateSaleRecord({Id: this.saleRecord.Id, CurrentStep__c: this.nextStep});
    }

    handleEdit(){
        this.updateSaleRecord({Id: this.saleRecord.Id, CurrentStep__c: this.currentStep});
    }
}