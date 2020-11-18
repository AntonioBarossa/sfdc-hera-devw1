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

            console.log('QuoteLines: ', JSON.parse(JSON.stringify(data)));

            let quotesArray = [];
            let count = 0;

            data.forEach(el => {
                quotesArray.push({
                    "Count"                :++count,
                    "Id"                   :el.quote[0].Id,
                    "Name"                 :el.quote[0].Name,
                    "OpportunityName"      :el.quote[0].SBQQ__Opportunity2__r.Name,
                    "QuoteLines"           :el.quoteLines
                });
            });

            console.log('QuoteLinesArray: ', quotesArray);

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