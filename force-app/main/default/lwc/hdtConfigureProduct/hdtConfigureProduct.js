import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuotes from '@salesforce/apex/HDT_LC_ConfigureProduct.getQuotes';

export default class hdtConfigureProduct extends LightningElement {
    
    @api saleRecord;
    quotesData;
    loaded = false;
    showEditQuote = false;
    selectedQuoteId;

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
                    "Id"                   :el[0].Quote__c,
                    "Name"                 :el[0].Quote__r.Name,
                    "OpportunityName"      :el[0].Opportunity__r.Name
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
}