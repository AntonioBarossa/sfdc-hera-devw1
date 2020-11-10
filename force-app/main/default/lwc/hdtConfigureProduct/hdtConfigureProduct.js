import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuotes from '@salesforce/apex/HDT_LC_ConfigureProduct.getQuotes';

export default class hdtConfigureProduct extends LightningElement {
    
    @api saleRecord;
    quotesData;

    getQuotesData(){
        getQuotes({saleId: this.saleRecord.Id}).then(data =>{
            this.quotesData = data;

            console.log(JSON.parse(JSON.stringify( this.quotesData)));

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
        // this.getQuotesData();
        console.log('saleRecord: ',JSON.stringify(this.saleRecord));
    }
}