import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isUserOwner from '@salesforce/apex/HDT_LC_OrdersForComfortQualityList.checkOwner';
import getTableData from '@salesforce/apex/HDT_LC_OrdersForComfortQualityList.getTableData';
import confirmContract from '@salesforce/apex/HDT_LC_OrdersForComfortQualityList.confirmContract';
import cancelContract from '@salesforce/apex/HDT_LC_OrdersForComfortQualityList.cancelContract';
import getCachedUuid from '@salesforce/apex/HDT_LC_CtToolbar.getCachedUuid';

export default class HdtOrdersForComfortQualityList extends LightningElement {
    
    @api activityId;
    @track ordersList = [];
    activity;
    order;
    action;
    @track loading = false;
    isDialogVisible = false;
    isNotOwner = false;
    @track showTable = false;

    get columnsTable(){
        return [
            {fieldName: 'CustomerName__c', // This field should have the actual URL in it.
             type: 'url', 
             sortable: "false",
             label: 'Numero Ordine',
             typeAttributes: {
                 label: { fieldName: 'OrderNumber' }, // whatever field contains the actual label of the link
                 target: '_parent', 
                 tooltip: 'Open order page'
             }},
            {label: 'Prodotto', fieldName: 'CommercialProduct__c', type: 'text'},
            // {label: 'Status', fieldName: 'Status', type: 'text'},
            // {label: 'Status Esito', fieldName: 'StatusEsito', type: 'text'},
            // {label: 'Phase', fieldName: 'Phase__c', type: 'text'},
            // {label: 'Tipologia', fieldName: 'recordtypename', type: 'text'},
            {type:  'button',typeAttributes:{
                                    iconName: {fieldName: 'confirmIcon'},
                                    label: {fieldName: 'confirmText'}, 
                                    name: 'confirmContract', 
                                    title: 'Conferma contratto',
                                    value: 'confirmContract',
                                    disabled: {fieldName :'disabledActionButton'}
                }
            },
            {type:  'button',typeAttributes:{
                                    iconName: {fieldName: 'cancelIcon'},
                                    label: {fieldName: 'cancelText'}, 
                                    name: 'cancelContract', 
                                    title: 'Annulla contratto',
                                    value: 'cancelContract',
                                    disabled: {fieldName :'disabledActionButton'}
             }
            }
        ];
    };

    get cancellationOptions() {
        return [
            { label: 'Il cliente rinuncia', value: 'Il cliente rinuncia' },
            { label: 'Firma falsa', value: 'Firma falsa' },
            { label: 'Volontà estorta', value: 'Volontà estorta' }
        ];
    }

    setTableData(isOperationRunning = false){
        this.loading = true;
        getTableData({activityId: this.activityId}).then(data =>{

            console.log('getTableData: ' + JSON.stringify(data));
            console.log('Size Data: ' + data.length);
            console.log('is operation running: ' + isOperationRunning);
            this.loading = isOperationRunning;
            if(data.length > 0){
                this.ordersList = data;
                this.showTable = true;
                if (data[0].Order__c != undefined) {
                    this.ordersList.forEach(el => {
                        el.Id = el.Order__c;
                        el.CustomerName__c = '/lightning/r/Order/' + el.Order__c + '/view';
                        el.Status = el.Order__r.Status;
                        el.Phase__c = el.Order__r.Phase__c;
                        el.recordtypename = el.Order__r.RecordType.Name;
                        el.OrderNumber = el.Order__r.OrderNumber;
                        el.DateComfortCall__c = el.Order__r.DateComfortCall__c;
                        el.disabledActionButton = el.Order__r.ConfirmCustomerContract__c !== undefined || el.Order__r.CancellationReason__c !== undefined;
                        el.confirmText = el.Order__r.ConfirmCustomerContract__c !== undefined ? 'Confermato' : 'Conferma contratto';
                        el.cancelText = el.Order__r.CancellationReason__c !== undefined ? 'Annullato' : 'Annulla contratto';
                        el.confirmIcon = el.Order__r.ConfirmCustomerContract__c !== undefined ? 'utility:edit' : 'utility:edit';
                        el.cancelIcon = el.Order__r.CancellationReason__c !== undefined ? 'utility:edit' : 'utility:edit';
                        el.StatusEsito =  (el.Order__r.ConfirmCustomerContract__c !== undefined || el.Order__r.CancellationReason__c !== undefined) ? (el.Order__r.ConfirmCustomerContract__c !== undefined ? 'Confermato' : 'Annullato') : 'In attesa';
                        el.CommercialProduct__c = (el.Order__r.VasSubtype__c !== undefined && el.Order__r.VasSubtype__c === 'Analisi Consumi')  ?  el.Order__r.VasSubtype__c : el.CommercialProduct__c;
                    });
                } else {
                    this.ordersList.forEach(el => {
                        el.Id = el.Id;
                        el.CustomerName__c = '/lightning/r/Order/' + el.Id + '/view';
                        el.Status = el.Status;
                        el.Phase__c = el.Phase__c;
                        el.recordtypename = el.RecordType.Name;
                        el.OrderNumber = el.OrderNumber;
                        el.DateComfortCall__c = el.DateComfortCall__c;
                        el.disabledActionButton = el.ConfirmCustomerContract__c !== undefined || el.CancellationReason__c !== undefined;
                        el.confirmText = el.ConfirmCustomerContract__c !== undefined ? 'Confermato' : 'Conferma contratto';
                        el.cancelText = el.CancellationReason__c !== undefined ? 'Annullato' : 'Annulla contratto';
                        el.confirmIcon = el.ConfirmCustomerContract__c !== undefined ? 'utility:edit' : 'utility:edit';
                        el.cancelIcon = el.CancellationReason__c !== undefined ? 'utility:edit' : 'utility:edit';
                        el.StatusEsito =  (el.ConfirmCustomerContract__c !== undefined || el.CancellationReason__c !== undefined) ? (el.ConfirmCustomerContract__c !== undefined ? 'Confermato' : 'Annullato') : 'In attesa';
                        el.CommercialProduct__c = (el.VasSubtype__c !== undefined && el.VasSubtype__c === 'Analisi Consumi')  ?  el.VasSubtype__c : el.CommercialProduct__c;
                    });
                }
            }
            else {
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Nessun Ordine da Esitare',
                    message: 'Non sono presenti Ordini da Esitare.',
                    variant: 'warning'
                });
                this.dispatchEvent(toastErrorMessage);
            }
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

    isRedirectEnabled(){
        let count = 0;

        this.ordersList.forEach(el => {
            if (!el.disabledActionButton) {
                count++;
            }
        });

        return count == 1;
    }

    confirmContractAction(type){
        this.loading = true;
        confirmContract({ordId: this.orderId, activityId: this.activityId, type: type}).then(data =>{
            this.loading = false;
            if(data!=null){
                getCachedUuid().then(cachedUuid => {
                    if(cachedUuid!=null){
                        window.TOOLBAR.EASYCIM.saveScript(cachedUuid, data.Campaign.PositiveOutcomeDefaultStatus__c, true)
                    }
                });
            }
            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Contratto confermato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

            if(this.isRedirectEnabled()){
                this.dispatchEvent(new CustomEvent('resultevent',{detail: {orderId: this.orderId}}));
            }

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
        cancelContract({ordId: this.orderId, activityId: this.activityId, causal: cancellationReason}).then(data =>{
            if(data!=null){
                getCachedUuid().then(cachedUuid => {
                    if(cachedUuid!=null){
                        window.TOOLBAR.EASYCIM.saveScript(cachedUuid, data.Campaign.PositiveOutcomeDefaultStatus__c, true)
                    }
                });
            }
            this.loading = false;
            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Contratto annullato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

            this.dispatchEvent(new CustomEvent('resultevent',{detail: {orderId: this.orderId}}));

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

        let type = row.DateComfortCall__c !== undefined ? 'Comfort' : 'Quality';

        //disable button
        /* let tmp = [...this.ordersList];
        tmp.forEach(ord =>{
            if( ord.Id === row.Id ){
                ord.disabledActionButton = false;
            }
        });
        this.ordersList = [...tmp]; */

        console.log('call type: ' + type);
        console.log('comfort/quality action: ' + this.action);

        if (this.action === 'confirmContract') {
            console.log('this.orderId: ' + this.orderId);
            this.confirmContractAction(type);
        } else {
            if (type === 'Quality') {
                this.isDialogVisible = true;
            } else {
                this.cancelContractAction('Annullato per no conferma cliente');
            }
        }
        this.showTable=false;
        this.setTableData(false);
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
        this.loading = true;
        isUserOwner({activityId: this.activityId}).then(data =>{
            console.log('@@@@Data ' + JSON.stringify(data));
            if (data === 'OK'){
                this.setTableData();
            }else if (data === 'KO'){
                this.loading = false;
                this.isNotOwner = true;
            }
        });
    }
}