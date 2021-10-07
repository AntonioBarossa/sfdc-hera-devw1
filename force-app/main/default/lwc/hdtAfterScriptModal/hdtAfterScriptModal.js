import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import initPostSaleAction from '@salesforce/apex/HDT_LC_AfterScriptModal.initPostSaleAction';

export default class HdtAfterScriptModal extends NavigationMixin(LightningElement) {
    @api showModal;
    @api order;
    initPostSalesProcess = false;

    handleClose(){
        this.showModal = false;
    }

    handleStartPostsalesProcess(){

        const buildURLQuery = obj =>
                Object.entries(obj)
                        .map(pair => pair.map(encodeURIComponent).join('='))
                        .join('&');

        let params = buildURLQuery({
            c__processType:'Modifica Privacy',
            c__recordTypeName: 'HDT_RT_GestionePrivacy',
            c__accid: this.order.AccountId,
            c__flowName: 'HDT_FL_PostSalesMasterDispatch'
        });

        let url = '/lightning/cmp/c__HDT_LCP_OpenAuraCmp?' + params;

        initPostSaleAction().then(result => {
            
            this.handleClose();

            if (result.isCommunity) {
                window.open(url, "_blank");
            } else {
                window.open(url,"_self");
            }

        }).catch(error => {
            this.loading = false;
            console.log(JSON.stringify(error));
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: 'Errore',
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });

    }
}