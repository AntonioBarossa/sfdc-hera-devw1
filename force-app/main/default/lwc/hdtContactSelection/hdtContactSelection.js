import { LightningElement,api,track } from 'lwc';
import getListRecords from '@salesforce/apex/HDT_LC_ContactSelection.getListRecords';
import getAdministrators from '@salesforce/apex/HDT_LC_ContactSelection.getAdministrators';

export default class HdtContactSelection extends LightningElement {

    @api searchLabel;
    @api searchVariant;
    @api searchPlaceholder;
    @api showAdministrators;
    @api maxRow;
    @api results;
    @api accountId;
    @api queryParams;

    @track columns;
    @track administratorColumns;
    @track data;
    @track isLoading;
    @track queryParamsString;
    @track showNoRecordMessage = false;

    handleKeyUp(event){
        try{
        if (event.keyCode === 13) {
            var inp=this.template.querySelector("lightning-input");
            var temp = Object.assign({}, JSON.parse(this.queryParams));
            if(inp.value != null && inp.value != ""){
                temp.soslSearchTerm = inp.value;
            }
            this.queryParamsString = JSON.stringify(temp);
            this.getListRecords();
        }
        }catch(error){
            console.error(error);
        }   
    }

    get shownColumns(){
        return this.showAdministrators === true ? this.administratorColumns : this.columns;
    }

    getAdministrators(){
        try{
            getAdministrators({
                accountId: this.accountId
                })
                .then(result => {
                    console.log('RESULT: ' + result)
                    var wiredResponse = JSON.parse(result);
                    if(Object.keys(wiredResponse).length > 0){
                        this.data = wiredResponse;
                        this.showNoRecordMessage = false;
                    }else{
                        this.data = null;
                        this.showNoRecordMessage = true;
                    }
                    
                    this.isLoading = false;
                })
                .catch(error => {
                    console.log('error ' + JSON.stringify(error) + ' ' + this.queryParamsString);
                    this.isLoading = false;
                });
            }catch(error){
                console.error(error);
            }
    }

    getListRecords(){
        try{
            getListRecords({
                accountId: this.accountId
                })
                .then(result => {
                    console.log('RESULT: ' + result)
                    var wiredResponse = JSON.parse(result);
                    if(Object.keys(wiredResponse).length > 0){
                        this.data = wiredResponse;
                        this.showNoRecordMessage = false;
                    }else{
                        this.data = null;
                        this.showNoRecordMessage = true;
                    }
                    
                    this.isLoading = false;
                })
                .catch(error => {
                    console.log('error ' + JSON.stringify(error) + ' ' + this.queryParamsString);
                    this.isLoading = false;
                });
            }catch(error){
                console.error(error);
            }
    }


    connectedCallback(){
        this.isLoading = true;
        this.queryParamsString = this.queryParams;
        //this.columns = JSON.parse(this.columns);
        this.columns = [
            { label: 'Nome Contatto', fieldName: 'Name', type: 'text' },
            { label: 'Ruolo', fieldName: 'Roles', type: 'text' },
            { label: 'Telefono', fieldName: 'Phone', type: 'phone' },
            { label: 'Cellulare', fieldName: 'MobilePhone', type: 'phone' },
            { label: 'Email', fieldName: 'Email', type: 'email' },
            { label: 'PEC', fieldName: 'CertifiedEmail__c', type: 'email' },
            { label: 'Fax', fieldName: 'Fax', type: 'phone' }
        ];

        this.administratorColumns = [
            { label: 'Nome Amministratore', fieldName: 'Name', type: 'text' },
            { label: 'Indirizzo', fieldName: 'MailingAddressFormula__c', type: 'text' },
            //{ label: 'Telefono', fieldName: 'Phone', type: 'phone' },
            { label: 'Cellulare', fieldName: 'MobilePhone', type: 'phone' }
            //{ label: 'Email', fieldName: 'Email', type: 'email' },
            //{ label: 'PEC', fieldName: 'CertifiedEmail__c', type: 'email' },
            //{ label: 'Fax', fieldName: 'Fax', type: 'phone' }
        ];

        if (this.showAdministrators === true) {
            console.log('ADMIN: ' + this.showAdministrators);
            this.getAdministrators();
        } else {
            console.log('NO ADMIN: ' + this.showAdministrators);
            this.getListRecords();
        }
    }
    handleRowSelection(event){
        const selectedRows = event.detail.selectedRows;
        this.dispatchEvent(new CustomEvent('recordselected', {detail: {selectedRows}}));
    }
}