import  SaleVas  from 'c/hdtSaleVas';
import { api } from 'lwc';
//import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class HdtSelezioneFornituraFlow extends SaleVas {
    @api accountId;
    @api selectedOrder;
    @api get ordId(){
        return this.selectedOrder==undefined? null : this.selectedOrder.Id;
    }

    ordersListcolumns = [
        {label: 'Tipo', fieldName: 'Type', type: 'text'},
        {label: 'Numero Ordine', fieldName: 'OrderNumber', type: 'text'},
        {label: 'Processo', fieldName: 'ProcessType__c', type: 'text'},
        {label: 'POD/PDR', fieldName: 'PodPdr', type: 'text'},
        {label: 'Indirizzo fornitura', fieldName: 'ServicePointAddr', type: 'text'}
    ];

    connectedCallback(){
        this.handleRadioGroupChange({detail:{value:"Ordini in corso"}});
    }

    createTable(data){
        console.log("override");
        data.forEach(item=>{
            item.Type = 'Ordine';
            item.PodPdr = item.ServicePoint__c !== undefined ? item.ServicePoint__r.ServicePointCode__c : '';
            item.ServicePointAddr = item.ServicePoint__c !== undefined ? item.ServicePoint__r.SupplyAddress__c : '';
        });
        console.log(data)
        super.createTable(data);
    }
/*
    getSelectedOrder(event){
        super.getSelectedOrder(event);
        console.log(this.selectedOrder);
        const attributeChangeEvent = new FlowAttributeChangeEvent('selectedOrder', this.selectedOrder);
        this.dispatchEvent(attributeChangeEvent);
    }
    */
}