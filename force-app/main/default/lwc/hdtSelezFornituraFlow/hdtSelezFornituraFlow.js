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
    'CONTRACT_BONUS_COMM':{
        label: 'Contratti',
        sObjectName: 'Contract',
        emptyMessage: 'Non ci sono Contratti',
        dataProcessFunction: (data) => {
            data.forEach((item) => {
                item.PodPdr = item.ServicePoint__c !== undefined ? item.ServicePoint__r.ServicePointCode__c : '';
                item.ServicePointAddr = item.ServicePoint__c !== undefined ? item.ServicePoint__r.SupplyAddress__c : '';
            });
        },
        columns: [
            {label: 'Codice Contratto Sap', fieldName: 'SAPContractCode__c', type: 'text'},
            {label: 'Numero Contratto', fieldName: 'ContractNumber', type: 'text'},
            {label: 'POD/PDR', fieldName: 'PodPdr', type: 'text'},
            {label: 'Indirizzo fornitura', fieldName: 'ServicePointAddr', type: 'text'}
        ]
    },
    'ORDERS_ELE':{
        label: 'Ordini Energia Elettrica',
        sObjectName: 'Order',
        emptyMessage: 'Non ci sono ordini',
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
                item.ContractNumber = item.Contract__r !== undefined ? item.Contract__r.SAPContractCode__c : ''
            });
        },
        columns: [
            {label: 'Nome', fieldName: 'Name', type: 'text'},
            {label: 'Codice Contratto SAP', fieldName: 'ContractNumber', type: 'text'},
            {label: 'Data installazione', fieldName: 'InstallDate', type: 'date'},
            {label: 'Referente', fieldName: 'ContactName', type: 'text'},
            {label: 'Prodotto', fieldName: 'ProductName', type: 'text'},
        ]
    },
    'SUBS_ANALISI_CONSUMI':{
        label : 'Subscriptions Analisi Consumi',
        sObjectName: 'SBQQ__Subscription__c',
        emptyMessage: 'Non ci sono subscriptions, oppure vi è già una richiesta aperta.',
        dataProcessFunction: (data) => {
            data.forEach((item) => {
                item.ProductName = item.SBQQ__Product__r !== undefined ? item.SBQQ__Product__r.Name : '';
                item.ContractNumber = item.SBQQ__Contract__r !== undefined ? item.SBQQ__Contract__r.SAPContractCode__c : '';
                item.PodPdr = (item.SBQQ__Contract__r !== undefined && item.SBQQ__Contract__r.ServicePoint__r !== undefined)?
                    item.SBQQ__Contract__r.ServicePoint__r.ServicePointCode__c : '';
                item.ServicePointAddr = (item.SBQQ__Contract__r !== undefined && item.SBQQ__Contract__r.ServicePoint__r !== undefined)?
                    item.SBQQ__Contract__r.ServicePoint__r.SupplyAddress__c : '';
            });
        },
        columns: [
            {label: 'Nome Prodotto', fieldName: 'ProductName', type: 'text'},
            {label: 'Codice Contratto SAP', fieldName: 'ContractNumber', type: 'text'},
            {label: 'POD/PDR', fieldName: 'PodPdr', type: 'text'},
            {label: 'Indirizzo fornitura', fieldName: 'ServicePointAddr', type: 'text'}
        ]
    },
    'SUBS_ANALISI_CONSUMI_RENEW':
    {
        label : 'Subscriptions Analisi Consumi Rinnovabili',
        sObjectName: 'SBQQ__Subscription__c',
        emptyMessage: 'Non ci sono subscriptions, oppure vi è già una richiesta aperta.',
        dataProcessFunction: (data) => {
            data.forEach((item) => {
                item.ProductName = item.SBQQ__Product__r !== undefined ? item.SBQQ__Product__r.Name : '';
                item.ContractNumber = item.SBQQ__Contract__r !== undefined ? item.SBQQ__Contract__r.SAPContractCode__c : '';
                item.PodPdr = (item.SBQQ__Contract__r !== undefined && item.SBQQ__Contract__r.ServicePoint__r !== undefined)?
                    item.SBQQ__Contract__r.ServicePoint__r.ServicePointCode__c : '';
                item.ServicePointAddr = (item.SBQQ__Contract__r !== undefined && item.SBQQ__Contract__r.ServicePoint__r !== undefined)?
                    item.SBQQ__Contract__r.ServicePoint__r.SupplyAddress__c : '';
            });
        },
        columns: [
            {label: 'Nome Prodotto', fieldName: 'ProductName', type: 'text'},
            {label: 'Codice Contratto SAP', fieldName: 'ContractNumber', type: 'text'},
            {label: 'POD/PDR', fieldName: 'PodPdr', type: 'text'},
            {label: 'Indirizzo fornitura', fieldName: 'ServicePointAddr', type: 'text'}
        ]
    },
    'SUBS_VAS_SERVIZIO':{
        label : 'VAS Servizio',
        sObjectName: 'SBQQ__Subscription__c',
        emptyMessage: 'Non ci sono subscriptions, oppure vi è già una richiesta aperta.',
        dataProcessFunction: (data) => {
            data.forEach((item) => {
                item.ProductName = item.SBQQ__Product__r !== undefined ? item.SBQQ__Product__r.Name : '';
                item.ContractNumber = item.SBQQ__Contract__r !== undefined ? item.SBQQ__Contract__r.SAPContractCode__c : '';
                item.PodPdr = (item.SBQQ__Contract__r !== undefined && item.SBQQ__Contract__r.ServicePoint__r !== undefined)?
                    item.SBQQ__Contract__r.ServicePoint__r.ServicePointCode__c : '';
                item.ServicePointAddr = (item.SBQQ__Contract__r !== undefined && item.SBQQ__Contract__r.ServicePoint__r !== undefined)?
                    item.SBQQ__Contract__r.ServicePoint__r.SupplyAddress__c : '';
            });
        },
        columns: [
            {label: 'Nome Prodotto', fieldName: 'ProductName', type: 'text'},
            {label: 'Numero Contratto SAP', fieldName: 'ContractNumber', type: 'text'},
            {label: 'POD/PDR', fieldName: 'PodPdr', type: 'text'},
            {label: 'Indirizzo fornitura', fieldName: 'ServicePointAddr', type: 'text'}
        ]
    },
    'SUBS_VAS_SERVIZIO_RENEW':{
        label : 'VAS Servizio Rinnovabili',
        sObjectName: 'SBQQ__Subscription__c',
        emptyMessage: 'Non ci sono subscriptions, oppure vi è già una richiesta aperta.',
        dataProcessFunction: (data) => {
            data.forEach((item) => {
                item.ProductName = item.SBQQ__Product__r !== undefined ? item.SBQQ__Product__r.Name : '';
                item.ContractNumber = item.SBQQ__Contract__r !== undefined ? item.SBQQ__Contract__r.SAPContractCode__c : '';
                item.PodPdr = (item.SBQQ__Contract__r !== undefined && item.SBQQ__Contract__r.ServicePoint__r !== undefined)?
                    item.SBQQ__Contract__r.ServicePoint__r.ServicePointCode__c : '';
                item.ServicePointAddr = (item.SBQQ__Contract__r !== undefined && item.SBQQ__Contract__r.ServicePoint__r !== undefined)?
                    item.SBQQ__Contract__r.ServicePoint__r.SupplyAddress__c : '';
            });
        },
        columns: [
            {label: 'Nome Prodotto', fieldName: 'ProductName', type: 'text'},
            {label: 'Numero Contratto SAP', fieldName: 'ContractNumber', type: 'text'},
            {label: 'POD/PDR', fieldName: 'PodPdr', type: 'text'},
            {label: 'Indirizzo fornitura', fieldName: 'ServicePointAddr', type: 'text'}
        ]
    },
    //Segnalazioni VAS - START
    'CONTRACTS_VAS':{
        label : 'Contratti',
        sObjectName: 'Contract',
        emptyMessage: 'Non ci sono contratti',
        dataProcessFunction: (data) => {
            data.forEach((item) => {
                item.PodPdr = item.ServicePoint__r !== undefined? item.ServicePoint__r.ServicePointCode__c : '';
                item.ServicePointAddr = item.ServicePoint__r !== undefined ? item.ServicePoint__r.SupplyAddress__c : '';
            });
        },
        columns: [
            {label: 'Codice Contratto SAP', fieldName: 'SAPContractCode__c', type: 'text'},
            {label: 'POD/PDR', fieldName: 'PodPdr', type: 'text'},
            {label: 'Indirizzo fornitura', fieldName: 'ServicePointAddr', type: 'text'},
            {label: 'Stato Contratto', fieldName: 'Status', type: 'text'}
        ]
    },
    'SUBS_FROM_CONTRACT':{
        label : 'Subscriptions VAS',
        sObjectName: 'SBQQ__Subscription__c',
        emptyMessage: 'Non ci sono subscriptions',
        columns: [
            {label: 'Subscription #', fieldName: 'Name', type: 'text'},
            {label: 'VAS', fieldName: 'SBQQ__ProductName__c', type: 'text'}
        ]
    },
    'ASSETS_FROM_CONTRACT':{
        label : 'Asset VAS',
        sObjectName: 'Asset',
        emptyMessage: 'Non ci sono asset attivi',
        dataProcessFunction: (data) => {
            data.forEach((item) => {
                item.ProductName = item.Product2 !== undefined ? item.Product2.Name : '';
            });
        },
        columns: [
            {label: 'Nome asset', fieldName: 'Name', type: 'text'},
            {label: 'VAS', fieldName: 'ProductName', type: 'text'}
        ]
    },
    //Segnalazioni VAS - END
    'CONTRACT_ELE_ACTIVE':{
        label : 'Contratti Attivi (Energia Elettrica)',
        sObjectName: 'Contract',
        emptyMessage: 'Non ci sono contratti attivi',
        dataProcessFunction: (data) => {
            data.forEach((item) => {
                item.PodPdr = item.ServicePoint__r !== undefined? item.ServicePoint__r.ServicePointCode__c : '';
                item.ServicePointAddr = item.ServicePoint__r !== undefined ? item.ServicePoint__r.SupplyAddress__c : '';
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
    
    defaultSelection;

    connectedCallback(){
        const keys = this.groupOptions.split(";").map(key => key.trim());
        this.radioGroupOptions = keys.filter(key => DATA_ACCESS_MAP[key]!=null).map(key => {
            return {
                label: DATA_ACCESS_MAP[key].label,
                value: key
            };
        });
        if(this.radioGroupOptions?.length === 1){
            let key = this.radioGroupOptions[0].value;
            this.handleRadioGroupChange({detail:{value : key}});
            if(keys.length > this.radioGroupOptions.length && keys[keys.length-1] && DATA_ACCESS_MAP[key].defaultSelection){
                this.defaultSelection = keys[keys.length-1];
            }
        }
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
        getFornitura({searchString: this.accountId, key: this.selectedOption}).then(data =>{
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