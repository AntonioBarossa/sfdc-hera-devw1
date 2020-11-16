import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createQuoteLine from '@salesforce/apex/HDT_LC_EditQuote.createQuoteLine';

export default class hdtEditQuote extends LightningElement {

    @api quoteId;
    iframeSrc;
    
    getIframeSrc(quoteId){
        return '/apex/sbqq__sb?scontrolCaching=1&amp;id=' + quoteId +'#quote/le?qId='+ quoteId;
    }

    connectedCallback(){
        this.iframeSrc = this.getIframeSrc(this.quoteId);
    }

    disconnectedCallback(){
        console.log('OK!');
        
        createQuoteLine({quoteId: this.quoteId}).then(data =>{
            

        }).catch(error => {
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
        
    }

    handleCloseModal(){
        this.dispatchEvent(new CustomEvent('closeeditquote'));
    }
}