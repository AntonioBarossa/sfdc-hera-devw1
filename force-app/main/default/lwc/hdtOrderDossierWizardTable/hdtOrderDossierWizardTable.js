import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getTableData from '@salesforce/apex/HDT_LC_OrderDossierWizardTable.getTableData';

export default class hdtOrderDossierWizardTable extends NavigationMixin(LightningElement) {

    @api orderParentId;
    orderId = '';
    action = '';
    loading = false;
    childOrdersList = [];
    orderItemList = [];

    columnsDocumenti = [
        {fieldName: 'CustomerName__c', // This field should have the actual URL in it.
         type: 'url', 
         sortable: "false",
         label: 'Numero Ordine',
         typeAttributes: {
             label: {
                 fieldName: 'OrderNumber' 
                 // whatever field contains the actual label of the link
             },
             target: '_parent', 
             tooltip: 'Open the customer page'
         }},
        {label: 'POD/PDR', fieldName: 'pod', type: 'text'},
        {label: 'Status', fieldName: 'Status', type: 'text'},
        {label: 'Tipologia', fieldName: 'recordtypename', type: 'text'},
        {type:  'button',typeAttributes:{
                iconName: 'utility:edit',
                label: 'Avvia Processo', 
                name: 'editRecord', 
                title: 'Avvia Processo', 
                disabled: false, 
                value: 'Avvia Processo'
            }
        }
    ];

    setTableData(){
        this.loading = true;
        getTableData({orderParentId: this.orderParentId}).then(data =>{

            this.loading = false;
            
            this.childOrdersList = data.childOrdersList;// let orderList = results.orderList;
            this.orderItemList = data.orderItemList;

            this.childOrdersList.forEach(ord => {
                if(ord.RecordType){
                    ord.recordtypename = ord.RecordType.Name;
                }
                ord.pod = '';
                ord.CustomerName__c = '/lightning/r/Order/' + ord.Id + '/view';
                ord.pod = ord.ServicePoint__r.ServicePointCode__c;

            });

        }).catch(error => {
            this.loaded = true;
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleRowAction(event){

        let row = event.detail.row;
        let action = event.detail.action;
        this.orderId = row.Id;
        this.action = action.value;

        this.dispatchEvent(new CustomEvent('handlerowactionevent', {
            detail:{
                c__orderParent: this.orderParentId,
                c__orderId: this.orderId,
                action: this.action
            }
        }));


    }

    connectedCallback(){
        this.setTableData();
    }
}