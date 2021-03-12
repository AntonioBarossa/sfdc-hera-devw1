import { LightningElement, api } from 'lwc';

export default class HdtQuoteAmendContract extends LightningElement {
    
    @api contractId;
    iframeSrcAmend = '';;
    
    getIframeSrc(contractId){
        return '/apex/sbqq__AmendContract?id=' + contractId;
        // return '/apex/sbqq__AmendContract?id=8007Y000002vCnkQAE'; //used for testing
    }

    connectedCallback(){
        this.iframeSrcAmend = this.getIframeSrc(this.contractId);
    }

    disconnectedCallback(){
        // this.dispatchEvent(new CustomEvent('cretedquotelines'));
    }

    handleCloseModal(){
        this.dispatchEvent(new CustomEvent('close_amend_contract'));
    }
}