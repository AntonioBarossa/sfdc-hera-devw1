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
        
        // createQuoteLine({quoteId: this.quoteId}).then(data =>{
        //     console.log('Disconnected hdtEditQuote: ');
        //     console.log('Created QuoteLines: ');
            
        //     console.log(JSON.parse(JSON.stringify(data)));
        //     this.dispatchEvent(new CustomEvent('cretedquotelines'));

        // }).catch(error => {
        //     const toastErrorMessage = new ShowToastEvent({
        //         title: 'Errore',
        //         message: error.message,
        //         variant: 'error'
        //     });
        //     this.dispatchEvent(toastErrorMessage);
        // });
        
    }

    handleCloseModal(){
        this.dispatchEvent(new CustomEvent('closeeditquote'));
    }
}