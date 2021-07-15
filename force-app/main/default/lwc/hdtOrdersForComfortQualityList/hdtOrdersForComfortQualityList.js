import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTableData from '@salesforce/apex/HDT_LC_OrdersForComfortQualityList.getTableData';
import confirmContract from '@salesforce/apex/HDT_LC_OrdersForComfortQualityList.confirmContract';
import cancelContract from '@salesforce/apex/HDT_LC_OrdersForComfortQualityList.cancelContract';

export default class HdtOrdersForComfortQualityList extends LightningElement {
    
    @api activityId;
    ordersList = [];
    orderId;
    action;
    loading = false;
    isDialogVisible = false;

    get columnsTable(){
        return [
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
                 tooltip: 'Open order page'
             }},
            // {label: 'Status', fieldName: 'Status', type: 'text'},
            // {label: 'Phase', fieldName: 'Phase__c', type: 'text'},
            // {label: 'Tipologia', fieldName: 'recordtypename', type: 'text'},
            {type:  'button',typeAttributes:{
                    iconName: 'utility:edit',
                    label: 'Conferma contratto', 
                    name: 'confirmContract', 
                    title: 'Conferma contratto',
                    value: 'confirmContract'
                }
            },
            {type:  'button',typeAttributes:{
                iconName: 'utility:edit',
                label: 'Annulla contratto', 
                name: 'cancelContract', 
                title: 'Annulla contratto',
                value: 'cancelContract'
             }
            }
        ];
    };

    get cancellationOptions() {
        return [
            { label: 'Annullamento da cliente', value: 'Annullamento da cliente' },
            { label: 'Firma falsa', value: 'Firma falsa' },
            { label: 'Volontà estorta', value: 'Volontà estorta' }
        ];
    }

    setTableData(){
        this.loading = true;
        getTableData({activityId: this.activityId}).then(data =>{

            console.log('getTableData: ' + JSON.stringify(data));

            this.loading = false;
            
            this.ordersList = data;

            this.ordersList.forEach(el => {
                el.Id = el.Order__c;
                el.CustomerName__c = '/lightning/r/Order/' + el.Order__c + '/view';
                el.Status = el.Order__r.Status;
                el.Phase__c = el.Order__r.Phase__c;
                el.recordtypename = el.Order__r.RecordType.Name;
                el.OrderNumber = el.Order__r.OrderNumber;
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

    confirmContractAction(){
        this.loading = true;
        confirmContract({ordId: this.orderId}).then(data =>{

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Contratto confermato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

            this.dispatchEvent(new CustomEvent('resultevent'));

        }).catch(error => {
            this.loading = false;

            let errorMessage = '';

            if (error.body.message !== undefined) {
                errorMessage = error.body.message;
            } else if(error.message !== undefined){
                errorMessage = error.message;
            } else if(error.body.pageErrors !== undefined){
                errorMessage = error.body.pageErrors[0].message;
            }

            console.log('Error: ', errorMessage);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    cancelContractAction(cancellationReason){
        this.loading = true;
        cancelContract({ordId: this.orderId, causal: cancellationReason}).then(data =>{
            this.loading = false;

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Contratto annullato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

            this.dispatchEvent(new CustomEvent('resultevent'));

        }).catch(error => {
            this.loading = false;

            let errorMessage = '';

            if (error.body.message !== undefined) {
                errorMessage = error.body.message;
            } else if(error.message !== undefined){
                errorMessage = error.message;
            } else if(error.body.pageErrors !== undefined){
                errorMessage = error.body.pageErrors[0].message;
            }

            console.log('Error: ', errorMessage);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleRowAction(event){

        let row = event.detail.row;
        let action = event.detail.action;
        this.orderId = row.Id;
        this.action = action.value;

        console.log('comfort/quality action: ' + this.action);

        if (this.action === 'confirmContract') {
            console.log('this.orderId: ' + this.orderId);
            this.confirmContractAction();
        } else {
            this.isDialogVisible = true;
        }

    }

    handleDialogResponse(event){
        if(event.detail.status == true){

            this.cancelContractAction(event.detail.choice);

        } else {
            this.isDialogVisible = false;
        }
    }

    connectedCallback(){
        console.log('acticityId: ' + this.activityId);
        this.setTableData();
    }
}