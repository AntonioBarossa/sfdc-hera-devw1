import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import execModalExitActions from '@salesforce/apex/HDT_LC_QuoteAmendContract.execModalExitActions';

export default class HdtQuoteAmendContract extends LightningElement {
    
    @api saleId;
    @api contractId;
    @api isCommunity;
    @api quoteId;
    title="Aggiunta Bonus o VAS";
    iframeSrcAmend = '';;
    
    getIframeSrc(contractId){

        let link = '';

        if(this.isCommunity) {
            link = '/HC/s/sfdcpage/%2Fapex%2Fsbqq__AmendContract?id=' + contractId;
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

        execModalExitActions({contractId: this.contractId, saleId: this.saleId, quoteId: this.quoteId}).then(data =>{
            this.dispatchEvent(new CustomEvent('close_amend_contract'));

            if(data){
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Aggiunta sconti e bonus configurata con successo',
                    variant: 'success'
                });
                this.dispatchEvent(toastSuccessMessage);
            }

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