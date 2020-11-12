import { LightningElement, api } from 'lwc';

export default class hdtEditQuote extends LightningElement {

    @api quoteId;
    iframeSrc;
    
    getIframeSrc(quoteId){
        return '/apex/sbqq__sb?scontrolCaching=1&amp;id=' + quoteId +'#quote/le?qId='+ quoteId;
    }

    connectedCallback(){
        this.iframeSrc = this.getIframeSrc(this.quoteId);
    }

    handleCloseModal(){
        this.dispatchEvent(new CustomEvent('closeeditquote'));
    }
}