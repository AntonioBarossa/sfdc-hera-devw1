import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFornitura from '@salesforce/apex/HDT_LC_SaleVas.getFornitura';

const DATA_ACCESS_MAP = {
    'ORDERS_IN_PROGRESS_VAS':{
        label: 'Ordini in corso VAS',
        sObjectName: 'Order',
        emptyMessage: 'Non ci sono ordini in corso',
        dataProcessFunction: (data) => {
            data.forEach((item) => {
                item.PodPdr = item.ServicePoint__c !== undefined ? item.ServicePoint__r.ServicePointCode__c : '';
                item.ServicePointAddr = item.ServicePoint__c !== undefined ? item.ServicePoint__r.SupplyAddress__c : '';
            });
        },
        columns: [
            {label: 'Tipo', fieldName: 'Type', type: 'text'},
            {label: 'Numero Ordine', fieldName: 'OrderNumber', type: 'text'},
            {label: 'Processo', fieldName: 'ProcessType__c', type: 'text'},
            {label: 'POD/PDR', fieldName: 'PodPdr', type: 'text'},
            {label: 'Indirizzo fornitura', fieldName: 'ServicePointAddr', type: 'text'}
        ]
    },
    'ASSETS_ACTIVATED':{
        label : 'Asset attivati',
        sObjectName: 'Asset',
        emptyMessage: 'Non ci sono asset attivi',
        dataProcessFunction: (data) => {
            data.forEach((item) => {
                item.ContactName = item.Contact !== undefined ? item.Contact.Name : '';
                item.ProductName = item.Product2 !== undefined ? item.Product2.Name : '';
            });
        },
        columns: [
            {label: 'Nome', fieldName: 'Name', type: 'text'},
            {label: 'Numero serial', fieldName: 'SerialNumber', type: 'text'},
            {label: 'Data installazione', fieldName: 'InstallDate', type: 'date'},
            {label: 'Referente', fieldName: 'ContactName', type: 'text'},
            {label: 'Prodotto', fieldName: 'ProductName', type: 'text'},
        ]
    },
    'SUBS_ANALISI_CONSUMI':{
        label : 'Subscriptions Analisi Consumi',
        sObjectName: 'SBQQ__Subscription__c',
        emptyMessage: 'Non ci sono subscriptions',
        dataProcessFunction: (data) => {
            data.forEach((item) => {
                item.ContractNumber = item.SBQQ__Contract__r !== undefined ? item.SBQQ__Contract__r.ContractNumber : '';
                item.PodPdr = (item.SBQQ__Contract__r !== undefined && item.SBQQ__Contract__r.ServicePoint__r !== undefined)?
                    item.SBQQ__Contract__r.ServicePoint__r.ServicePointCode__c : '';
                item.ServicePointAddr = (item.SBQQ__Contract__r !== undefined && item.SBQQ__Contract__r.ServicePoint__r !== undefined)?
                    item.SBQQ__Contract__r.ServicePoint__r.SupplyAddress__c : '';
            });
        },
        columns: [
            {label: 'Numero Contratto', fieldName: 'ContractNumber', type: 'text'},
            {label: 'POD/PDR', fieldName: 'PodPdr', type: 'text'},
            {label: 'Indirizzo fornitura', fieldName: 'ServicePointAddr', type: 'text'}
        ]
    }
};
const ROWS_PER_PAGE = 4;

export default class HdtSelezFornituraFlow extends LightningElement {

    //input values
    @api accountId;
    @api groupOptions;

    //output values
    @api recordId;
    @api sObjectName;
    
    emptyMessage = '';
    
    selectedRecord = {};
    selectedOption = '';
    isLoading = false;
    totalPages = 0;
    @track pages = [];
    currentPage = 0;
    @track tableData;
    @track tableColumns = [];

    radioGroupOptions;

    connectedCallback(){
        const keys = this.groupOptions.split(";").map(key => key.trim());
        this.radioGroupOptions = keys.filter(key => DATA_ACCESS_MAP[key]!=null).map(key => {
            return {
                label: DATA_ACCESS_MAP[key].label,
                value: key
            };
        });
        
        //this.handleRadioGroupChange({detail:{value:this.groupOption}});
    }

    handleRadioGroupChange(event) {
        this.tableData = null;
        this.totalPages = 0;
        this.selectedOption = event.detail.value;
        this.confirmedSelectedOption = '';
        
        this.loadRecords();
    }

    loadRecords(){
        this.isLoading = true;
        getFornitura({accountId:this.accountId, key: this.selectedOption}).then(data =>{
            this.isLoading = false;
            
            if(data.length > 0){
                console.log( JSON.stringify(data) );
                if (DATA_ACCESS_MAP[this.selectedOption].dataProcessFunction) {
                    DATA_ACCESS_MAP[this.selectedOption].dataProcessFunction(data);
                }
                this.createTable(data);
            } else {
                this.emptyMessage = DATA_ACCESS_MAP[this.selectedOption].emptyMessage;
            }

        }).catch(error => {
            this.isLoading = false;
            console.log('Error: ', error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    //Pagination start
    createTable(data) {
        this.tableColumns = DATA_ACCESS_MAP[this.selectedOption].columns;

        let i, j, temporary, chunk = ROWS_PER_PAGE;
        this.pages = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pages.push(temporary);
        }
        this.totalPages = this.pages.length;
        this.reLoadTable();
    }

    reLoadTable() {
        this.tableData = this.pages[this.currentPage];
    }

    get showPaginationButtons(){
        return this.totalPages > 1;
    }

    get getCurrentPage() {
        if (this.totalPages===0){
            return 0;   
        } else {
            return this.currentPage + 1;
        }
    }

    nextPage() {
        if (this.currentPage < this.totalPages - 1) {
            this.currentPage++;
        }
        this.reLoadTable();
    }

    previousPage() {
        if (this.currentPage > 0){
            this.currentPage--;
        }
        this.reLoadTable();
    }
    //Pagination end

    getSelectedRecord(event){
        let selectedRows = event.detail.selectedRows;
        if (selectedRows[0] !== undefined) {
            this.selectedRecord = selectedRows[0];
            this.recordId = selectedRows[0].Id;
            this.sObjectName = DATA_ACCESS_MAP[this.selectedOption].sObjectName;
            console.log(this.recordId, this.sObjectName);
        }
        else {
            this.selectedRecord = {};
            this.recordId = null;
            this.sObjectName = null;
        }
    }

    @api
    validate() {
        if (this.recordId) {
            return { isValid: true }; 
        }
        else {
            // If the component is invalid, return the isValid parameter 
            // as false and return an error message. 
            return {
                isValid: false,
                errorMessage: 'Non hai selezionato nessun elemento'
            };
        }
    }
}