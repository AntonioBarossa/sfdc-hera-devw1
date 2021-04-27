import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import execModalExitActions from '@salesforce/apex/HDT_LC_QuoteAmendContract.execModalExitActions';

export default class HdtQuoteAmendContract extends LightningElement {
    
    @api saleId;
    @api contractId;
    @api isCommunity;
    iframeSrcAmend = '';;
    
    getIframeSrc(contractId){

        let link = '';

        if(this.isCommunity) {
            console.log('amend - isCommunity');
        } else {
            link = '/apex/sbqq__AmendContract?id=' + contractId;
        }

        return link;
    }

    connectedCallback(){
        this.iframeSrcAmend = this.getIframeSrc(this.contractId);
    }

    disconnectedCallback(){
        this.dispatchEvent(new CustomEvent('cretedquotelines'));
    }

    handleCloseModal(){

        execModalExitActions({contractId: this.contractId, saleId: this.saleId}).then(data =>{
            this.dispatchEvent(new CustomEvent('close_amend_contract'));
            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Amend configurato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);
        }).catch(error => {
            this.dispatchEvent(new CustomEvent('close_amend_contract'));
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