import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBillingProfileList from '@salesforce/apex/HDT_LC_ManageBillingProfile.getBillingProfileList';


export default class hdtManageBillingProfile extends LightningElement {
    @api accountId;
    billingProfileData = [];
    emptyTable = false;
    columnsLength;
    loading = false;
    rowToSend;
    @api disabledInput;

    columns = [
        {label: 'Metodo di pagamento', fieldName: 'PaymentMethod__c', type: 'text'},
        {label: 'Billing Profile Name', fieldName: 'Name', type: 'text'},
        {label: 'Indirizzo di Fatturazione', fieldName: 'InvoicingAddressFormula__c', type: 'text'},
        {label: 'Modalita invio bolletta', fieldName: 'BillSendingMethod__c', type: 'text'},
        // {label: 'IBAN', fieldName: 'FormulaIBAN__c', type: 'text'},
        {label: 'IBAN', fieldName: 'IBAN__c', type: 'text'},
        {label: 'E-mail', fieldName: 'InvoiceEmailAddress__c', type: 'text'}
    ];

    @api
    disableManage(){
        this.disabledInput = true;
    }

    @api
    getBillingProfileData(){
        this.loading = true;
        getBillingProfileList({accountId: this.accountId}).then(data =>{
            this.loading = false;
            console.log('XXX getBillingProfileData: resultData -> '+ JSON.stringify(data));
            
            if(data.length == 0){
                this.emptyTable = true;
                this.columnsLength = this.columns.length;
            } else {
                this.emptyTable = false;
                this.billingProfileData = data;
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

    connectedCallback(){
        this.getBillingProfileData();
    }

    getSelectedBillingProfile(event){
        let selectedRows = event.detail.selectedRows;
        console.log('XXX getSelectedBillingProfile: selectedRows -> ' + JSON.stringify(selectedRows));
        this.rowToSend = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
        this.dispatchEvent(new CustomEvent('selectedbillingprofile', {detail: this.rowToSend}));
    }

}