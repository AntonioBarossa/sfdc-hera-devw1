import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOrdersList from '@salesforce/apex/HDT_LC_SaleVas.getOrdersList';
import getContractsList from '@salesforce/apex/HDT_LC_SaleVas.getContractsList';
import confirmAction from '@salesforce/apex/HDT_LC_SaleVas.confirmAction';

export default class hdtSaleVas extends LightningElement {

    @api accountId;
    @api sale;
    isModalVisible = false;
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

    handleModalVisibility(){
        this.isModalVisible = true;
    }

    get isConfirmDisabled(){
        return this.selectedOption === '' ? true: false;
    }

    handleCancelEvent(){
        this.isInputVisible = false;
        this.isOrderListVisible = false;
        this.isContractsListVisible = false;
        this.isModalVisible = false;
    }

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
            this.ordersList = data;

        }).catch(error => {
            this.isLoading = false;
            this.isModalVisible = false;
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
            this.contractsList = data;
        }).catch(error => {
            this.isLoading = false;
            this.isModalVisible = false;
            console.log('Error: ', error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

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
            this.isModalVisible = false;
            this.isInputVisible = false;
            this.isOrderListVisible = false;
            this.isContractsListVisible = false;
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