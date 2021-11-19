import  SaleVas  from 'c/hdtSaleVas';
import { api, track } from 'lwc';
import getTempNuovaAttivazContracts from '@salesforce/apex/HDT_LC_SaleVas.getTempNuovaAttivazContracts';
import getOrdersListNotActive from '@salesforce/apex/HDT_LC_SaleVas.getOrdersListNotActive';

export default class HdtSelezioneFornituraFlow extends SaleVas {
    @api accountId;
    @api selectedOrder;
    @api get ordId(){
        return this.selectedOrder==undefined? null : this.selectedOrder.Id;
    }

    @api get contrId(){
        return this.selectedContract==undefined? null : this.selectedContract.Id;
    }

    @api groupOption;//Ordini in corso;Contratti Attivi;

    get contextObject(){
        let option = this.groupOption;
        switch(option){
            case 'Ordini in corso': return 'Order'
            case 'Contratti Attivi': return 'Contract'
        }
    }

    ordersListcolumns=[
        {label: 'Tipo', fieldName: 'Type', type: 'text'},
        {label: 'Numero Ordine', fieldName: 'OrderNumber', type: 'text'},
        {label: 'Processo', fieldName: 'ProcessType__c', type: 'text'},
        {label: 'Status', fieldName: 'Status', type: 'text'},
        {label: 'POD/PDR', fieldName: 'PodPdr', type: 'text'},
        {label: 'Indirizzo fornitura', fieldName: 'ServicePointAddr', type: 'text'}
    ];

    contractsListcolumns = [
        {label: 'Tipo', fieldName: 'Type', type: 'text'},
 //     {label: 'Numero Contratto', fieldName: 'ContractNumber', type: 'text'}, 
        {label: 'Codice Contratto SAP', fieldName: 'SAPContractCode', type: 'text'},
        {label: 'POD/PDR', fieldName: 'PodPdr', type: 'text'},
        {label: 'Indirizzo fornitura', fieldName: 'ServicePointAddr', type: 'text'}
    ];

    connectedCallback(){
        this.handleRadioGroupChange({detail:{value:this.groupOption}});
    }

    createTable(data){
        console.log("override");
        data.forEach(item=>{
            item.Type = this.contextObject;
            item.PodPdr = item.ServicePoint__c !== undefined ? item.ServicePoint__r.ServicePointCode__c : '';
            item.ServicePointAddr = item.ServicePoint__c !== undefined ? item.ServicePoint__r.SupplyAddress__c : '';
            item.SAPContractCode = item.SAPContractCode__c;
        });
        console.log(data)
        super.createTable(data);
    }

    handleTemporaneaAttivazioneContracts(){
        this.isLoading = true;
        getTempNuovaAttivazContracts({accountId:this.accountId}).then(data =>{
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

    handleOrdersList(){
        this.isLoading = true;
        getOrdersListNotActive({accountId:this.accountId}).then(data =>{
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



    handleContractsList(){//override Method
        if(this.groupOption){//condition always true, modify just in case
            this.handleTemporaneaAttivazioneContracts()
        }else{//not override method
            super.handleContractsList();
        }
    }




    @api
    validate() {
        if(this.ordId || this.contrId || this.showEmptyOrdersMessage || this.showEmptyContractsMessage) { 
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