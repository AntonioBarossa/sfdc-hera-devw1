import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getTableData from '@salesforce/apex/HDT_LC_OrderDossierWizardTable.getTableData';
import next from '@salesforce/apex/HDT_LC_OrderDossierWizardTable.next';
import edit from '@salesforce/apex/HDT_LC_OrderDossierWizardTable.edit';
export default class hdtOrderDossierWizardTable extends NavigationMixin(LightningElement) {

    @api orderParentRecord;
    orderId = '';
    action = '';
    loading = false;
    childOrdersList = [];
    orderItemList = [];
    currentStep = 2;

    get hiddenEdit(){
        let result = true;
        if(this.orderParentRecord.Step__c <= this.currentStep){
            result = true;
        } else if(this.orderParentRecord.Step__c > this.currentStep){
            result = false;
        }

        return result;
    }

    get disabledNext(){
        let result = false;
        if(this.orderParentRecord.Step__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    get disabledInput(){
        let result = false;
        if(this.orderParentRecord.Step__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    columnsDocumenti = [];

    setTableData(){
        this.loading = true;
        getTableData({orderParentId: this.orderParentRecord.Id}).then(data =>{

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
                c__orderParent: this.orderParentRecord.Id,
                c__orderId: this.orderId,
                action: this.action
            }
        }));


    }

    connectedCallback(){
        this.columnsDocumenti = [
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
                    disabled: this.disabledInput,
                    value: 'Avvia Processo'
                }
            }
        ];
        this.setTableData();
    }

    handleNext(){
        this.loading = true;
        next({orderUpdates: {Id:this.orderParentRecord.Id}}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new CustomEvent('orderrefresh', { bubbles: true }));
        }).catch(error => {
            this.loading = false;
            console.log((error.body.message !== undefined) ? error.body.message : error.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: (error.body.message !== undefined) ? error.body.message : error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleEdit(){
        this.loading = true;
        edit({orderParentId:this.orderParentRecord.Id}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new CustomEvent('orderrefresh', { bubbles: true }));
        }).catch(error => {
            this.loading = false;
            console.log((error.body.message !== undefined) ? error.body.message : error.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: (error.body.message !== undefined) ? error.body.message : error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }
}