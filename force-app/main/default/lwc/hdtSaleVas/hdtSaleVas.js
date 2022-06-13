import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOrdersList from '@salesforce/apex/HDT_LC_SaleVas.getOrdersList';
import getContractsList from '@salesforce/apex/HDT_LC_SaleVas.getContractsList';
import getContractsAndOrdersMap from '@salesforce/apex/HDT_LC_SaleVas.getContractsAndOrdersMap';
import confirmAction from '@salesforce/apex/HDT_LC_SaleVas.confirmAction';
import handleNotMigratedContract from '@salesforce/apex/HDT_LC_SaleVas.handleNotMigratedContract';
import checkTransition from '@salesforce/apex/HDT_LC_SaleVas.transitionCheckNew';

export default class hdtSaleVas extends LightningElement {

    @api accountId;
    @api sale;
    // isModalVisible = false;
    isInputVisible = false;
    isOrderListVisible = false;
    showEmptyOrdersMessage = false;
    isContractsListVisible = false;
    isCompleteListVisible = false;
    showEmptyContractsMessage = false;
    showEmptyMessage = false;
    ordersList = [];
    selectedOrder = {};
    contractsList = [];
    completeList = [];
    selectedContract = {};
    selectedFromCompleteList = {};
    selectedOption = '';
    confirmedSelectedOption = '';
    inputText = '';
    labelSelectedOptions = '';
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
        return this.selectedOption === '' || this.confirmedSelectedOption === '' || this.disabledInput ? true: false;
    }

    // handleCancelEvent(){
    //     this.isInputVisible = false;
    //     this.isOrderListVisible = false;
    //     this.isContractsListVisible = false;
    //     this.isModalVisible = false;
    // }

    radioGroupOptions = [
        // {'label': 'Ordini in corso', 'value': 'Ordini in corso'},
        // {'label': 'Contratti Attivi', 'value': 'Contratti Attivi'},
        {'label': 'Contratto attivo/ordine in corso (solo per fatturazione)', 'value': 'Contratto attivo/ordine in corso'},
        {'label': 'Senza contratto', 'value': 'VAS stand alone'},
        {'label': 'Contratto non migrato', 'value': 'Contratto non migrato'}
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

    completeListcolumns = [
        // {label: 'Nome Contrato', fieldName: 'Name', type: 'text'},
        // {label: 'Numero Contrato', fieldName: 'ContractNumber', type: 'text'},
        // {label: 'Nome Ordine', fieldName: 'Name', type: 'text'},
        // {label: 'Numero Ordine', fieldName: 'OrderNumber', type: 'text'},
        {label: 'Tipo', fieldName: 'Type', type: 'text'},
        // {label: 'Nome', fieldName: 'Name', type: 'text'},
        {label: 'Numero', fieldName: 'Number', type: 'text'},
        {label: 'Processo', fieldName: 'Process', type: 'text'},
        {label: 'POD/PDR', fieldName: 'PodPdr', type: 'text'},
        {label: 'Indirizzo fornitura', fieldName: 'ServicePointAddr', type: 'text'},
        // {label: 'Status', fieldName: 'Status', type: 'text'}
    ];

    handleRadioGroupChange(event) {
        this.totalPages = 0;
        this.isOrderListVisible = false;
        this.isContractsListVisible = false;
        this.isInputVisible = false;
        this.selectedOption = event.detail.value;
        this.confirmedSelectedOption = '';
        
        switch (this.selectedOption) {
            case 'Ordini in corso':
                this.isOrderListVisible = true;
                // this.isInputVisible = true;
                this.handleOrdersList();
                break;

            case 'Contratti Attivi':
                this.isContractsListVisible = true;
                // this.isInputVisible = true;
                this.handleContractsList();
                break;
            
            case 'Contratto attivo/ordine in corso':
                this.isCompleteListVisible = true;
                this.isInputVisible = false;
                this.handleContractsAndOrdersList();
                break;

            case 'VAS stand alone':
                this.confirmedSelectedOption = 'VAS stand alone';
                this.isInputVisible = true;
                this.labelSelectedOptions = 'Comune';
                this.isCompleteListVisible = false;
                break;

            case 'Contratto non migrato':
                this.confirmedSelectedOption = 'Contratto non migrato';
                this.labelSelectedOptions = 'Codice contratto';
                this.isInputVisible = true;
                this.isCompleteListVisible = false;
                break;
        }

    }

    handleOrdersList(){
        this.isLoading = true;
        getOrdersList({accountId:this.accountId}).then(data =>{
            this.isLoading = false;
            // this.ordersList = data;
            
            if(data.length > 0){
                this.createTable(data);
            } else {
                this.showEmptyOrdersMessage = true;
            }

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

            if(data.length > 0){
                this.createTable(data);
            } else {
                this.showEmptyContractsMessage = true;
            }

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

    handleContractsAndOrdersList(){
        this.isLoading = true;
        getContractsAndOrdersMap({accountId:this.accountId}).then(data =>{
            this.isLoading = false;

            this.completeList = [...data.contractsList, ...data.ordersList];

            console.log('handleContractsAndOrdersList: ', JSON.stringify(this.completeList));

            this.completeList.forEach(item => {
                item.Type = item.ContractNumber !== undefined ? 'Contratto' : 'Ordine';
                item.Number = item.ContractNumber !== undefined ? item.SAPContractCode__c : item.OrderNumber;
                item.PodPdr = item.ServicePoint__c !== undefined ? item.ServicePoint__r.ServicePointCode__c : '';
                item.ServicePointAddr = item.ServicePoint__c !== undefined ? item.ServicePoint__r.SupplyAddress__c : '';
                item.city = item.ServicePoint__c !== undefined ? item.ServicePoint__r.SupplyCity__c : '';
                item.Process = item.ProcessType__c !== undefined ? item.ProcessType__c : '';
            });

            if(this.completeList.length > 0){
                this.createTable(this.completeList);
            } else {
                this.showEmptyMessage = true;
            }


        }).catch(error => {
            this.isLoading = false;
            console.log('Error: ', JSON.stringify(error));
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

    handleInputText(event){
        if ( this.labelSelectedOptions === 'Comune' && event.detail.value === null ){

            const toastWarning = new ShowToastEvent({
                title: 'Warning',
                message: 'Necessario inserire un comune!',
                variant: 'warning'
            });
            this.dispatchEvent(toastWarning);

        } else {
            this.inputText = event.detail.value;
        }
    }

    handleConfirmEvent(){
        this.isLoading = true;
        console.log('********' + JSON.stringify(this.sale));
        
        if(this.selectedOption == 'Contratto non migrato'){

            handleNotMigratedContract({
                contract:this.inputText,
                sale: this.sale
                }).then(data =>{
                this.isLoading = false;
                // this.isModalVisible = false;
                this.isInputVisible = false;
                this.isOrderListVisible = false;
                this.isContractsListVisible = false;
                this.isCompleteListVisible = false;
                this.selectedOption = '';
                this.confirmedSelectedOption = '';
                this.inputText = '';
                this.totalPages = 0;
                let errorMessage = '';
                
                if(data == 'Errore Data Cessazione'){
                    errorMessage = 'Data Cessazione non valida. Verificare e riprovare.';
                }
                else if(data == 'Errore Contratto Assente'){
                    errorMessage = 'Contratto non trovato. Verificare e riprovare.';
                }

                if(data == 'Success')
                {
                    //this.dispatchEvent(new CustomEvent('createvas'));
                    const toastSuccessMessage = new ShowToastEvent({
                        title: 'Successo',
                        message: 'VAS confermato con successo',
                        variant: 'success'
                    });
                    this.dispatchEvent(toastSuccessMessage);

                    //this.dispatchEvent(new CustomEvent('createvas'));
                    const toastWarning = new ShowToastEvent({
                        title: 'Warning',
                        message: 'E stato creato un caso transitorio!',
                        variant: 'warning'
                    });
                    this.dispatchEvent(toastWarning);
                }
                else
                {
                    //this.dispatchEvent(new CustomEvent('createvas'));
                    const toastWarning = new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error'
                    });
                    this.dispatchEvent(toastWarning);
                }
                this.dispatchEvent(new CustomEvent('salewizard__refreshproductstable', {
                    bubbles: true,
                    composed: true
                }));
    
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
        else{
            checkTransition({

                salesId : this.sale.Id,
                comune : this.inputText,
                tipologia : this.selectedOption

            }).then(data =>{
                let dat = data;

                if(dat.res || (dat.messRes === 'transitorio' && this.selectedOption !== 'VAS stand alone')){
                    confirmAction({
                        selectedOption:this.confirmedSelectedOption,
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
                        this.isCompleteListVisible = false;
                        this.selectedOption = '';
                        this.confirmedSelectedOption = '';
                        this.inputText = '';
                        this.totalPages = 0;
                        if(dat.res)
                        {
                            this.dispatchEvent(new CustomEvent('createvas'));
                            const toastSuccessMessage = new ShowToastEvent({
                                title: 'Successo',
                                message: 'VAS confermato con successo',
                                variant: 'success'
                            });
                            this.dispatchEvent(toastSuccessMessage);
                        }
                        else
                        {
                            this.dispatchEvent(new CustomEvent('createvas'));
                            const toastWarning = new ShowToastEvent({
                                title: 'Warning',
                                message: 'E stato creato un caso transitorio!',
                                variant: 'warning'
                            });
                            this.dispatchEvent(toastWarning);
                        }
                        this.dispatchEvent(new CustomEvent('salewizard__refreshproductstable', {
                            bubbles: true,
                            composed: true
                        }));
            
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
                }else{
                    if(dat.messRes == 'city'){
                        this.isLoading = false;
                        //this.dispatchEvent(new CustomEvent('createvas'));
                        const toastSuccessMessage = new ShowToastEvent({
                            title: 'Error',
                            message: 'Inserisci un Comune Valido',
                            variant: 'Error'
                        });
                        this.dispatchEvent(toastSuccessMessage);
                    }else if( dat.messRes == 'AccountMigratoTransitorio' ){
                        this.isLoading = false;
                        //this.dispatchEvent(new CustomEvent('createvas'));
                        const toastSuccessMessage = new ShowToastEvent({
                            title: 'Error',
                            message: 'Impossibile effettuare vendita fuori ambito per cliente migrato. Necessario creare un nuovo cliente clone',
                            variant: 'Error'
                        });
                        this.dispatchEvent(toastSuccessMessage);
                    }else{
                        this.isLoading = false;
                        //this.dispatchEvent(new CustomEvent('createvas'));
                        const toastSuccessMessage = new ShowToastEvent({
                            title: 'Error',
                            message: 'VAS Non innescabile per Transitorio',
                            variant: 'Error'
                        });
                        this.dispatchEvent(toastSuccessMessage);
                    }
                }
            });
        }
    }

    getSelectedOrder(event){
        let selectedRows = event.detail.selectedRows;
        this.selectedOrder = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
        console.log('# SupplyCity >>> ' + JSON.stringify(this.selectedOrder.ServicePoint__r.SupplyCity__c));
    }

    getSelectedContract(event){
        let selectedRows = event.detail.selectedRows;
        this.selectedContract = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
    }

    getSelectedFromCompleteList(event) {
        let selectedRows = event.detail.selectedRows;
        this.selectedFromCompleteList = (selectedRows[0] !== undefined) ? selectedRows[0]: {};

        console.log('getSelectedFromCompleteList: ', this.selectedFromCompleteList);

        if(this.selectedFromCompleteList.Type === 'Contratto') {
            this.confirmedSelectedOption = 'Contratti Attivi';
            // delete this.selectedFromCompleteList.Type;
            // delete this.selectedFromCompleteList.Number;
            this.selectedContract = this.selectedFromCompleteList;
            this.inputText = this.selectedContract.ServicePoint__r.SupplyCity__c;
            console.log('# Contract Selection: SupplyCity >>> ' + JSON.stringify(this.inputText));
            this.selectedOrder = {};
        } else if (this.selectedFromCompleteList.Type === 'Ordine') {
            this.confirmedSelectedOption = 'Ordini in corso';
            // delete this.selectedFromCompleteList.Type;
            // delete this.selectedFromCompleteList.Number;
            this.selectedOrder = this.selectedFromCompleteList;            
            /**@frpanico
             * Added this.inputTex for checkTransition
             */
            this.inputText = this.selectedOrder.ServicePoint__r.SupplyCity__c;
            console.log('# Order Selection: SupplyCity >>> ' + JSON.stringify(this.inputText));
            this.selectedContract = {};
        }
    }
}