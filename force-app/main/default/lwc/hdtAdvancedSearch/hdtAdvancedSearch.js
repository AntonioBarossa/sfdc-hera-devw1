import {LightningElement, track,api} from 'lwc';
import getServicePoints from '@salesforce/apex/HDT_LC_AdvancedSearch.getServicePoints';
import getContracts from '@salesforce/apex/HDT_LC_AdvancedSearch.getContracts';
import callWebService from '@salesforce/apex/HDT_LC_AdvancedSearch.callWebService';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getContractFromRow from '@salesforce/apex/HDT_QR_Contract.getContractFromRow';

export default class HdtAdvancedSearch extends LightningElement {

    @track filterInputWord = null;
    openmodel = false;
    submitButtonStatus = true;
    @api searchInputValue = null;
    queryType = 'pod';
    tableData = [];
    tableColumns = [];
    isLoaded = false;
    columns = [];
    originalData = [];
    pages = [];
    preloading = false;
    @track currentPage = 0;
    totalPage = 0;
    customSetting = null;
    confirmButtonDisabled = true;

    @api servicePointRetrievedData;

    rowToSend;
    @api maxRowSelected=false;
    @api disabledinput;
    @api accountid;

    apiSearchButtonStatus= true;
    apiSearchInputValue=null;
    @api targetObject
    @api outputContract=[];

    notFoundMsg={
        'pod':'Codice POD/PDR non trovato su SFDC, Eseguire una nuova ricerca o verifica esistenza su SAP',
        'contract':'Codice Contratto non trovato su SFDC, Eseguire una nuova riceerca o verifica esistenza su SAP',
        'serialnumber':'Nessun record trovato'
    }

    connectedCallback() {
        if (this.maxRowSelected ===false){
            this.maxRowSelected= 1
        }else {
            this.maxRowSelected = this.originalData.length
        }
    }

    /**
     * Filter Data-Table
     */
    handleFilterDataTable(event) {
        let val = event.target.value;
        let self = this;
        let data;
        setTimeout(function () {
            data = JSON.parse(JSON.stringify(self.originalData));
            if (val.trim() !== '') {
                data = data.filter(row => {
                    let found = false;
                    Object.values(row).forEach(v => {
                        if (v !== undefined && null != v.toLowerCase() && (v.toLowerCase().search(val.toLowerCase())  !== -1 ) ) {
                            found = true;
                        }
                    });
                    if (found) return row;
                })
            }
            self.createTable(data); // redesign table
            self.currentPage = 0; // reset page
        }, 1000);
    }

    /**
     * validate search input length
     */
    handleSearchInputKeyChange(event) {
        this.searchInputValue = event.target.value;
        if (this.searchInputValue.length > 3) {
            this.submitButtonStatus = false;
        } else {
            this.submitButtonStatus = true;

        }
    }

    closeModal() {
        this.openmodel = false;
    }

    /**
     * get input value and also validate input value
     */
    searchAction(event) {
        this.submitButtonStatus = true;
        this.apiSearchButtonStatus = true;

        console.log('event value: '+ event.target.value);

        if (event.target.value.length > 3) {
            this.submitButtonStatus = false;
            this.searchInputValue = event.target.value;
        }
    }

    /**
     * Create header for Data-Table header with original data
     */
    formatTableHeaderColumns(rowData) {
        let columns = [];
        this.tableColumns = [];
        rowData.forEach(row => {
            let keys = Object.keys(row);
            columns = columns.concat(keys);
        });
        let columnsUniq = [...new Set(columns)];
        columnsUniq.forEach(field => this.tableColumns.push({label: field, fieldName: field}));
    }

    /**
     * Create Data-Table
     */
    createTable(data) {
        let i, j, temporary, chunk = 5;
        this.pages = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pages.push(temporary);
        }
        this.totalPage = this.pages.length;
        this.reLoadTable();
    }

    reLoadTable() {
        this.tableData = this.pages[this.currentPage];

        console.log('tableData********'+ JSON.stringify(this.tableData));

    }

    nextPage() {
        if (this.currentPage < this.totalPage - 1) this.currentPage++;
        this.reLoadTable();
    }

    previousPage() {
        if (this.currentPage > 0) this.currentPage--;
        this.reLoadTable();
    }

    alert(title,msg,variant){
        const event = ShowToastEvent({
            title: title,
            message:  msg,
            variant: variant
        });
        dispatchEvent(event);
    }

    get getCurrentPage() {
        if (this.totalPage===0) return 0;
        return this.currentPage + 1;
    }

    onselected(value){
        this.queryType = value.detail;
        this.apiSearchButtonStatus= true;
    }

    submitContract(event){

        event.preventDefault();
        this.preloading = true;
        console.log('executing query search', this.accountid);
        getContracts({accountid:this.accountid}).then(data =>{
            this.preloading = false;
            if (data.length > 0) {
                this.originalData = JSON.parse(JSON.stringify(data));
                this.createTable(data);
                this.formatTableHeaderColumns(data);
                this.submitButtonStatus = true;
                this.openmodel = true;
                this.isLoaded = true;
            } else {
                this.alert('Dati tabela','Nessun record trovato','warn')
                this.tableData = data;
            }
        });
        
    }

    /**
     * 

     * Calling Apex callWebService method
     * TODO this method is not finished yet need webserivce.
     */
    callApi(event){
        callWebService({pod:this.searchInputValue}).then(data=>{
            if (data == null){
                console.log("call this.handleConfirm()");
            }else {
                console.log("process data");
            }
        }).catch(error => {
            this.preloading = false;
            let errorMsg = error;
            if ('body' in error && 'message' in error.body) {
                errorMsg = error.body.message
            }
            this.alert('',errorMsg,'error')
        });
        // test
        this.handleConfirm();
    }

    /**
     * Call apex class and get data
     */
    submitSearch(event) {
        event.preventDefault();

        console.log('event value submitSearch() '+ event.target.value);

        this.preloading = true;
        let qty = this.queryType;
        getServicePoints({parameter: this.searchInputValue,queryType:this.queryType}).then(data => {
            this.preloading = false;
            if (data.length > 0) {
                this.originalData = JSON.parse(JSON.stringify(data));
                this.createTable(data);
                this.formatTableHeaderColumns(data);
                this.submitButtonStatus = true;
                this.openmodel = true;
                this.isLoaded = true;
                this.apiSearchButtonStatus=true;
                this.searchInputValue= null;
            } else {
                this.alert('Dati tabela',this.notFoundMsg[qty],'warn')
                this.tableData = data;
                this.apiSearchButtonStatus=false;
            }
        }).catch(error => {
            this.preloading = false;
            let errorMsg = error;
            if ('body' in error && 'message' in error.body) {
                errorMsg = error.body.message
            }
            this.alert('',errorMsg,'error')
        });

    }
     /**
     * Get selected record from table
     */
    getSelectedServicePoint(event){
        this.preloading = true;
        let selectedRows = event.detail.selectedRows;
        this.confirmButtonDisabled = (selectedRows === undefined || selectedRows.length == 0) ? true : false;
        this.rowToSend = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
        this.preloading = false;

        console.log('rowToSend: ', JSON.parse(JSON.stringify(this.rowToSend)));

        let contractNumber = this.rowToSend['Contract Number'];
        console.log('rowToSend for Contract'+ JSON.stringify(contractNumber));
        
        getContractFromRow({cNumber:contractNumber,accountId:this.AccountId}).then(data=>{
            this.outputContract= data;
            console.log('outputContract *******'+ JSON.stringify(this.outputContract));
        });

    }

    /**
     * Handle action when confirm button is pressed
     */
    handleConfirm(){
        this.preloading = true;
        this.closeModal();

            this.dispatchEvent(new CustomEvent('servicepointselection', {
                detail: this.rowToSend
            }));       
        this.confirmButtonDisabled = true;
        this.preloading = false;

    }

@api
    getTargetObject(targetObject){
        this.targetObject = targetObject;
    }
    

}