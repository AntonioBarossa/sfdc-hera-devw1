import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import createQuoteLine from '@salesforce/apex/HDT_LC_EditQuote.createQuoteLine';
import assocPodToQuoteLine from '@salesforce/apex/HDT_LC_EditQuote.assocPodToQuoteLine';

export default class hdtEditQuote extends LightningElement {

    @api sale;
    @api quoteId;
    iframeSrc;
    
    getIframeSrc(quoteId){
        return '/apex/sbqq__sb?scontrolCaching=1&amp;id=' + quoteId +'#quote/le?qId='+ quoteId;
    }

    connectedCallback(){
        this.iframeSrc = this.getIframeSrc(this.quoteId);
    }

    disconnectedCallback(){

        this.dispatchEvent(new CustomEvent('cretedquotelines'));
        
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

        assocPodToQuoteLine({saleId: this.sale.Id, quoteId: this.quoteId}).then(data =>{
            this.dispatchEvent(new CustomEvent('closeeditquote'));
            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'QuoteLine configurato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);
        }).catch(error => {
            this.dispatchEvent(new CustomEvent('closeeditquote'));
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
            console.log('Error: ', error.body.message);
        });
    }
}