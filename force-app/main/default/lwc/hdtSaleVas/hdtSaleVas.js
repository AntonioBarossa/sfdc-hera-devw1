import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOrdersList from '@salesforce/apex/HDT_LC_SaleVas.getOrdersList';
import getContractsList from '@salesforce/apex/HDT_LC_SaleVas.getContractsList';
import confirmAction from '@salesforce/apex/HDT_LC_SaleVas.confirmAction';

export default class hdtSaleVas extends LightningElement {

    @api accountId;
    @api sale;
    // isModalVisible = false;
    isInputVisible = false;
    isOrderListVisible = false;
    isContractsListVisible = false;
    ordersList = [];
    selectedOrder = {};
    contractsList = [];
    selectedContract = {};
    selectedOption = '';
    inputText = '';
    isLoading = false;
    @api disabledInput;
    totalPages = 0;
    @track pages = [];
    currentPage = 0;
    @track tableData = [];

    // handleModalVisibility(){
    //     this.isModalVisible = true;
    // }

    get isConfirmDisabled(){
        return this.selectedOption === '' || this.disabledInput ? true: false;
    }

    // handleCancelEvent(){
    //     this.isInputVisible = false;
    //     this.isOrderListVisible = false;
    //     this.isContractsListVisible = false;
    //     this.isModalVisible = false;
    // }

    radioGroupOptions = [
        {'label': 'Ordini in corso', 'value': 'Ordini in corso'},
        {'label': 'Contratti Attivi', 'value': 'Contratti Attivi'},
        {'label': 'VAS stand alone', 'value': 'VAS stand alone'}
    ];

    ordersListcolumns = [
        {label: 'Nome Ordine', fieldName: 'Name', type: 'text'},
        {label: 'Numero Ordine', fieldName: 'OrderNumber', type: 'text'},
        {label: 'Status', fieldName: 'Status', type: 'text'}
    ];

    contractsListcolumns = [
        {label: 'Nome Contrato', fieldName: 'Name', type: 'text'},
        {label: 'Numero Contrato', fieldName: 'ContractNumber', type: 'text'},
        {label: 'Status', fieldName: 'Status', type: 'text'}
    ];

    handleRadioGroupChange(event) {
        this.totalPages = 0;
        this.isOrderListVisible = false;
        this.isContractsListVisible = false;
        this.isInputVisible = false;
        this.selectedOption = event.detail.value;
        
        switch (this.selectedOption) {
            case 'Ordini in corso':
                this.isOrderListVisible = true;
                this.isInputVisible = true;
                this.handleOrdersList();
                break;

            case 'Contratti Attivi':
                this.isContractsListVisible = true;
                this.isInputVisible = true;
                this.handleContractsList();
                break;

            case 'VAS stand alone':
                this.isInputVisible = true;
                break;
        }

    }

    handleOrdersList(){
        this.isLoading = true;
        getOrdersList({accountId:this.accountId}).then(data =>{
            this.isLoading = false;
            // this.ordersList = data;
            this.createTable(data);

        }).catch(error => {
            this.isLoading = false;
            // this.isModalVisible = false;
            console.log('Error: ', error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleContractsList(){
        this.isLoading = true;
        getContractsList({accountId:this.accountId}).then(data =>{
            this.isLoading = false;
            // this.contractsList = data;
            this.createTable(data);
        }).catch(error => {
            this.isLoading = false;
            // this.isModalVisible = false;
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
        let i, j, temporary, chunk = 4;
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
        return this.totalPages > 0;
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

    handleInputText(event){
        this.inputText = event.detail.value;
    }

    handleConfirmEvent(){
        this.isLoading = true;
        confirmAction({
            selectedOption:this.selectedOption,
            order:this.selectedOrder,
            contract:this.selectedContract,
            supplyCity:this.inputText,
            accountId: this.accountId,
            sale: this.sale
            }).then(data =>{
            this.isLoading = false;
            // this.isModalVisible = false;
            this.isInputVisible = false;
            this.isOrderListVisible = false;
            this.isContractsListVisible = false;
            this.selectedOption = '';
            this.inputText = '';

            this.dispatchEvent(new CustomEvent('createvas'));
            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'VAS confermato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

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

    getSelectedOrder(event){
        let selectedRows = event.detail.selectedRows;
        this.selectedOrder = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
    }

    getSelectedContract(event){
        let selectedRows = event.detail.selectedRows;
        this.selectedContract = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
    }
}