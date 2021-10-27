import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuoteLineBundle from '@salesforce/apex/HDT_LC_ApplyBillingProfileModal.getQuoteLineBundle';
import updateQuoteLinesBillingProfile from '@salesforce/apex/HDT_LC_ApplyBillingProfileModal.updateQuoteLinesBillingProfile';

export default class hdtApplyBillingProfileModal extends LightningElement {

    @api sale;
    @api selectedBillingProfile;
    loading = false;
    quoteBundleData;
    disabledConfirm = true;
    selectedQuoteItems;
    complementaryBundleArray = []; //used in case their is an additional product to main 'Offerta commerciale' - HRAWRM-424

    columns = [
        {label: 'Nome', fieldName: 'Name', type: 'text'},
        {label: 'Billing Profile', fieldName: 'BillingProfile', type: 'text'},
        {label: 'Prodotto', fieldName: 'ProductName', type: 'text'},
        {label: 'POD/PDR', fieldName: 'ServicePointCode', type: 'text'}
    ];

    getModalData(){
        this.loading = true;

        console.log('this.selectedBillingProfile: ', JSON.parse(JSON.stringify(this.selectedBillingProfile)));

        let paymentMethodRaw = this.selectedBillingProfile.PaymentMethod__c;
        let paymentMethodToSend = this.selectedBillingProfile.PaymentMethod__c;

        getQuoteLineBundle({saleId: this.sale.Id, paymentMethod: paymentMethodToSend, sendingBillMode: this.selectedBillingProfile.BillSendingMethod__c}).then(data =>{
            this.loading = false;
            
            if(data.listPodPdr.length == 0 && data.listVas.length == 0 && data.listVasCambioOfferta.length == 0){
                
                this.handleCancelEvent();
                const event = ShowToastEvent({
                    title: '',
                    message:  'Nessun Prodotto selezionato è compatibile con questo metodo di pagamento',
                    variant: 'warn'
                });
                dispatchEvent(event);

            } else {
                let quoteBundleArray = [];

                console.log('hdtApplyBillingProfileModal: ', JSON.parse(JSON.stringify(data)));

                data.listPodPdr.forEach(el => {
                    quoteBundleArray.push({
                        "Id"                   :el.SBQQ__RequiredBy__c,
                        "Name"                 :el.SBQQ__RequiredBy__r.Name,
                        "BillingProfile"       :el.SBQQ__RequiredBy__r.BillingProfile__c !== undefined ? el.SBQQ__RequiredBy__r.BillingProfile__r.Name : '',
                        "ProductName"          :el.SBQQ__RequiredBy__r.SBQQ__Product__r.Name !== undefined ? el.SBQQ__RequiredBy__r.SBQQ__Product__r.Name : '',
                        "ServicePointCode"     :el.ServicePoint__c !== undefined ? el.ServicePoint__r.ServicePointCode__c : ''
                    });
                });

                if (data.listPodPdr.length == 0) {
                    data.listVas.forEach(el => {
                        quoteBundleArray.push({
                            "Id"                   :el.Id,
                            "Name"                 :el.Name,
                            "BillingProfile"       :el.BillingProfile__c !== undefined ? el.BillingProfile__r.Name : '',
                            "ProductName"          :el.SBQQ__Product__r.Name !== undefined ? el.SBQQ__Product__r.Name : '',
                            "ServicePointCode"     :el.ServicePoint__c !== undefined ? el.ServicePoint__r.ServicePointCode__c : ''
                        });
                    });
                } else {
                    data.listVas.forEach(el => { //used in case their is an additional product to main 'Offerta commerciale' - HRAWRM-424
                        this.complementaryBundleArray.push({
                            "Id"                   :el.Id,
                            "Name"                 :el.Name,
                            "BillingProfile"       :el.BillingProfile__c !== undefined ? el.BillingProfile__r.Name : '',
                            "ProductName"          :el.SBQQ__Product__r.Name !== undefined ? el.SBQQ__Product__r.Name : '',
                            "ServicePointCode"     :el.ServicePoint__c !== undefined ? el.ServicePoint__r.ServicePointCode__c : ''
                        });
                    });
                }

                data.listVasCambioOfferta.forEach(el => {
                    quoteBundleArray.push({
                        "Id"                     :el.Id,
                        "Name"                   :el.Name,
                        "BillingProfile"         :el.BillingProfile__c !== undefined ? el.BillingProfile__r.Name : '',
                        "ProductName"            :el.SBQQ__Product__r.Name !== undefined ? el.SBQQ__Product__r.Name : '',
                        "ServicePointCode"       :el.ServicePoint__c !== undefined ? el.ServicePoint__r.ServicePointCode__c : '',
                        "IsCambioOfferta"        :true, //not shown on table, used to perform logic later
                        "BillingProfilePrevious" :el.SBQQ__Quote__r.ContractReference__r.BillingProfile__r.Name //not shown on table, used to perform logic later
                    });
                });

                data.listBonus?.forEach(el => {
                    quoteBundleArray.push({
                        "Id"                   :el.Id,
                        "Name"                 :el.Name,
                        "BillingProfile"       :el.BillingProfile__c !== undefined ? el.BillingProfile__r.Name : '',
                        "ProductName"          :el.SBQQ__Product__r.Name !== undefined ? el.SBQQ__Product__r.Name : '',
                        "ServicePointCode"     :el.ServicePoint__c !== undefined ? el.ServicePoint__r.ServicePointCode__c : ''
                    });
                });

                this.quoteBundleData = quoteBundleArray;
            }

        }).catch(error => {
            this.loading = false;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    updateQuoteBundle(){
        this.loading = true;

        if (this.complementaryBundleArray.length > 0) { //used in case their is an additional product to main 'Offerta commerciale' - HRAWRM-424

            console.log('complementaryBundleArray assign before: ' + JSON.stringify(this.selectedQuoteItems));

            this.selectedQuoteItems = [...this.selectedQuoteItems, ...this.complementaryBundleArray];

            console.log('complementaryBundleArray assign after: ' + JSON.stringify(this.selectedQuoteItems));
        }

        updateQuoteLinesBillingProfile({quoteLinesToUpdate: this.selectedQuoteItems, billingProfileId: this.selectedBillingProfile.Id}).then(data =>{
            this.loading = false;
            
            this.handleCancelEvent();

            let hasBillingProfileChanged = false;

            this.selectedQuoteItems.forEach(el => {
                if (el.IsCambioOfferta && el.BillingProfilePrevious != this.selectedBillingProfile.Name) {
                    hasBillingProfileChanged = true;
                }
            });

            if (hasBillingProfileChanged) {
                const evt = new ShowToastEvent({
                    title: '',
                    message: "Si sta associando un metodo di pagamento differente. Ricordare al cliente che se ci sono vas associati al vecchio metodo di pagamento dovrà pagare l'importo residuo in unica soluzione.",
                    variant: 'warning',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
            }
            
            const event = ShowToastEvent({
                title: '',
                message:  'Quote line Bundle aggiornati con successo',
                variant: 'success'
            });
            this.dispatchEvent(event);

            this.dispatchEvent(new CustomEvent('salewizard__refreshproductstable', {
                bubbles: true,
                composed: true
            }));

        }).catch(error => {
            this.loading = false;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleCancelEvent(){
        this.dispatchEvent(new CustomEvent('cancelapply'));
    }

    connectedCallback(){
        this.getModalData();
    }

    getSelectedQuoteItems(event){
        let selectedRows = event.detail.selectedRows;

        if(selectedRows.length > 0){
            this.disabledConfirm = false;
            this.selectedQuoteItems = selectedRows;
        } else {
            this.disabledConfirm = true;
        }
    }

    handleConfirmEvent(){
        this.updateQuoteBundle();
    }
}